Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f44.google.com (mail-pb0-f44.google.com [209.85.160.44])
	by kanga.kvack.org (Postfix) with ESMTP id B07216B0036
	for <linux-mm@kvack.org>; Tue,  1 Apr 2014 15:49:16 -0400 (EDT)
Received: by mail-pb0-f44.google.com with SMTP id rp16so10398488pbb.3
        for <linux-mm@kvack.org>; Tue, 01 Apr 2014 12:49:16 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id vn9si4880204pbc.131.2014.04.01.12.49.15
        for <linux-mm@kvack.org>;
        Tue, 01 Apr 2014 12:49:15 -0700 (PDT)
Date: Tue, 1 Apr 2014 12:49:13 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: Only force scan in reclaim when none of the LRUs
 are big enough.
Message-Id: <20140401124913.c27f190e2342d6e5c2c29277@linux-foundation.org>
In-Reply-To: <alpine.LSU.2.11.1403151957160.21388@eggly.anvils>
References: <alpine.LSU.2.11.1403151957160.21388@eggly.anvils>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Suleiman Souhlal <suleiman@google.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>, Rafael Aquini <aquini@redhat.com>, Michal Hocko <mhocko@suse.cz>, Yuanhan Liu <yuanhan.liu@linux.intel.com>, Seth Jennings <sjennings@variantweb.net>, Bob Liu <bob.liu@oracle.com>, Minchan Kim <minchan@kernel.org>, Luigi Semenzato <semenzato@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sat, 15 Mar 2014 20:36:02 -0700 (PDT) Hugh Dickins <hughd@google.com> wrote:

> From: Suleiman Souhlal <suleiman@google.com>
> 
> Prior to this change, we would decide whether to force scan a LRU
> during reclaim if that LRU itself was too small for the current
> priority. However, this can lead to the file LRU getting force
> scanned even if there are a lot of anonymous pages we can reclaim,
> leading to hot file pages getting needlessly reclaimed.

Struggling a bit here.  You're referring to this code?

			size = get_lru_size(lruvec, lru);
			scan = size >> sc->priority;

			if (!scan && force_scan)
				scan = min(size, SWAP_CLUSTER_MAX);

So we're talking about the case where the LRU is so small that it
contains fewer than (1<<sc->priority) pages?

If so, then I'd expect that in normal operation this situation rarely
occurs?  Surely the LRUs normally contain many more pages than this.

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

And yet the patch makes a large difference.  What am I missing here?

> --- 3.14-rc6/mm/vmscan.c	2014-02-02 18:49:07.949302116 -0800
> +++ linux/mm/vmscan.c	2014-03-15 19:31:44.948977032 -0700
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

That's a poor comment.

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

And so is that.  Both comments explain *what* the code is doing (which
was fairly obvious from the code!) but they fail to explain *why* the
code is doing what it does.

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

Also the "and don't force_scan" part appears to be flatly untrue.  Either
the comment is wrong or the code should be along the lines of

	if (scan) {
		some_scanned = true;
		force_scan = false;
	}

Can we fix these things please?  And retest if necessary.

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
