Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ee0-f44.google.com (mail-ee0-f44.google.com [74.125.83.44])
	by kanga.kvack.org (Postfix) with ESMTP id 4BD026B0035
	for <linux-mm@kvack.org>; Fri, 28 Mar 2014 14:14:46 -0400 (EDT)
Received: by mail-ee0-f44.google.com with SMTP id e49so4432968eek.3
        for <linux-mm@kvack.org>; Fri, 28 Mar 2014 11:14:45 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id o46si9520675eem.219.2014.03.28.11.14.43
        for <linux-mm@kvack.org>;
        Fri, 28 Mar 2014 11:14:44 -0700 (PDT)
Date: Fri, 28 Mar 2014 15:10:20 -0300
From: Rafael Aquini <aquini@redhat.com>
Subject: Re: [PATCH] mm: Only force scan in reclaim when none of the LRUs are
 big enough.
Message-ID: <20140328181020.GB10709@localhost.localdomain>
References: <alpine.LSU.2.11.1403151957160.21388@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1403151957160.21388@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Suleiman Souhlal <suleiman@google.com>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Michal Hocko <mhocko@suse.cz>, Yuanhan Liu <yuanhan.liu@linux.intel.com>, Seth Jennings <sjennings@variantweb.net>, Bob Liu <bob.liu@oracle.com>, Minchan Kim <minchan@kernel.org>, Luigi Semenzato <semenzato@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sat, Mar 15, 2014 at 08:36:02PM -0700, Hugh Dickins wrote:
> From: Suleiman Souhlal <suleiman@google.com>
> 
> Prior to this change, we would decide whether to force scan a LRU
> during reclaim if that LRU itself was too small for the current
> priority. However, this can lead to the file LRU getting force
> scanned even if there are a lot of anonymous pages we can reclaim,
> leading to hot file pages getting needlessly reclaimed.
> 
> To address this, we instead only force scan when none of the
> reclaimable LRUs are big enough.
> 
> Gives huge improvements with zswap. For example, when doing -j20
> kernel build in a 500MB container with zswap enabled, runtime (in
> seconds) is greatly reduced:
> 
> x without this change
> + with this change
>     N           Min           Max        Median           Avg        Stddev
> x   5       700.997       790.076       763.928        754.05      39.59493
> +   5       141.634       197.899       155.706         161.9     21.270224
> Difference at 95.0% confidence
>         -592.15 +/- 46.3521
>         -78.5293% +/- 6.14709%
>         (Student's t, pooled s = 31.7819)
> 
> Should also give some improvements in regular (non-zswap) swap cases.
> 
> Yes, hughd found significant speedup using regular swap, with several
> memcgs under pressure; and it should also be effective in the non-memcg
> case, whenever one or another zone LRU is forced too small.
> 
> Signed-off-by: Suleiman Souhlal <suleiman@google.com>
> Signed-off-by: Hugh Dickins <hughd@google.com>
> ---
> 

Acked-by: Rafael Aquini <aquini@redhat.com>

> I apologize to everyone for holding on to this so long: I think it's
> a very helpful patch (which we've been using in Google for months now).
> Been sitting on my TODO list, now prompted to send by related patches
> 
> https://lkml.org/lkml/2014/3/13/217
> https://lkml.org/lkml/2014/3/14/277
> 
> Certainly worth considering all three together, but my understanding
> is that they're actually three independent attacks on different ways
> in which we currently squeeze an LRU too small; and this patch from
> Suleiman seems to be the most valuable of the three, at least for
> the workloads I've tried it on.  But I'm not much of a page reclaim
> performance tester: please try it out to see if it's good for you.
> Thanks!
> 
>  mm/vmscan.c |   72 +++++++++++++++++++++++++++++---------------------
>  1 file changed, 42 insertions(+), 30 deletions(-)
> 
> We did experiment with different ways of writing the patch, I'm afraid
> the way it came out best indents deeper, making it look more than it is.
> 
> --- 3.14-rc6/mm/vmscan.c	2014-02-02 18:49:07.949302116 -0800
> +++ linux/mm/vmscan.c	2014-03-15 19:31:44.948977032 -0700
> @@ -1852,6 +1852,8 @@ static void get_scan_count(struct lruvec
>  	bool force_scan = false;
>  	unsigned long ap, fp;
>  	enum lru_list lru;
> +	bool some_scanned;
> +	int pass;
>  
>  	/*
>  	 * If the zone or memcg is small, nr[l] can be 0.  This
> @@ -1971,39 +1973,49 @@ static void get_scan_count(struct lruvec
>  	fraction[1] = fp;
>  	denominator = ap + fp + 1;
>  out:
> -	for_each_evictable_lru(lru) {
> -		int file = is_file_lru(lru);
> -		unsigned long size;
> -		unsigned long scan;
> -
> -		size = get_lru_size(lruvec, lru);
> -		scan = size >> sc->priority;
> -
> -		if (!scan && force_scan)
> -			scan = min(size, SWAP_CLUSTER_MAX);
> -
> -		switch (scan_balance) {
> -		case SCAN_EQUAL:
> -			/* Scan lists relative to size */
> -			break;
> -		case SCAN_FRACT:
> +	some_scanned = false;
> +	/* Only use force_scan on second pass. */
> +	for (pass = 0; !some_scanned && pass < 2; pass++) {
> +		for_each_evictable_lru(lru) {
> +			int file = is_file_lru(lru);
> +			unsigned long size;
> +			unsigned long scan;
> +
> +			size = get_lru_size(lruvec, lru);
> +			scan = size >> sc->priority;
> +
> +			if (!scan && pass && force_scan)
> +				scan = min(size, SWAP_CLUSTER_MAX);
> +
> +			switch (scan_balance) {
> +			case SCAN_EQUAL:
> +				/* Scan lists relative to size */
> +				break;
> +			case SCAN_FRACT:
> +				/*
> +				 * Scan types proportional to swappiness and
> +				 * their relative recent reclaim efficiency.
> +				 */
> +				scan = div64_u64(scan * fraction[file],
> +							denominator);
> +				break;
> +			case SCAN_FILE:
> +			case SCAN_ANON:
> +				/* Scan one type exclusively */
> +				if ((scan_balance == SCAN_FILE) != file)
> +					scan = 0;
> +				break;
> +			default:
> +				/* Look ma, no brain */
> +				BUG();
> +			}
> +			nr[lru] = scan;
>  			/*
> -			 * Scan types proportional to swappiness and
> -			 * their relative recent reclaim efficiency.
> +			 * Skip the second pass and don't force_scan,
> +			 * if we found something to scan.
>  			 */
> -			scan = div64_u64(scan * fraction[file], denominator);
> -			break;
> -		case SCAN_FILE:
> -		case SCAN_ANON:
> -			/* Scan one type exclusively */
> -			if ((scan_balance == SCAN_FILE) != file)
> -				scan = 0;
> -			break;
> -		default:
> -			/* Look ma, no brain */
> -			BUG();
> +			some_scanned |= !!scan;
>  		}
> -		nr[lru] = scan;
>  	}
>  }
>  

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
