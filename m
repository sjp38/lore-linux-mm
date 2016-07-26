Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id DDD3C6B0005
	for <linux-mm@kvack.org>; Tue, 26 Jul 2016 04:11:47 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id ag5so276313323pad.2
        for <linux-mm@kvack.org>; Tue, 26 Jul 2016 01:11:47 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id a78si38073650pfg.228.2016.07.26.01.11.46
        for <linux-mm@kvack.org>;
        Tue, 26 Jul 2016 01:11:47 -0700 (PDT)
Date: Tue, 26 Jul 2016 17:16:22 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 5/5] mm, vmscan: Account for skipped pages as a partial
 scan
Message-ID: <20160726081621.GC15721@js1304-P5Q-DELUXE>
References: <1469110261-7365-1-git-send-email-mgorman@techsingularity.net>
 <1469110261-7365-6-git-send-email-mgorman@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1469110261-7365-6-git-send-email-mgorman@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Michal Hocko <mhocko@suse.cz>, Vlastimil Babka <vbabka@suse.cz>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Thu, Jul 21, 2016 at 03:11:01PM +0100, Mel Gorman wrote:
> Page reclaim determines whether a pgdat is unreclaimable by examining how
> many pages have been scanned since a page was freed and comparing that to
> the LRU sizes. Skipped pages are not reclaim candidates but contribute to
> scanned. This can prematurely mark a pgdat as unreclaimable and trigger
> an OOM kill.
> 
> This patch accounts for skipped pages as a partial scan so that an
> unreclaimable pgdat will still be marked as such but by scaling the cost
> of a skip, it'll avoid the pgdat being marked prematurely.
> 
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>
> ---
>  mm/vmscan.c | 20 ++++++++++++++++++--
>  1 file changed, 18 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index 6810d81f60c7..e5af357dd4ac 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -1424,7 +1424,7 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
>  	LIST_HEAD(pages_skipped);
>  
>  	for (scan = 0; scan < nr_to_scan && nr_taken < nr_to_scan &&
> -					!list_empty(src); scan++) {
> +					!list_empty(src);) {
>  		struct page *page;
>  
>  		page = lru_to_page(src);
> @@ -1438,6 +1438,12 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
>  			continue;
>  		}
>  
> +		/*
> +		 * Account for scanned and skipped separetly to avoid the pgdat
> +		 * being prematurely marked unreclaimable by pgdat_reclaimable.
> +		 */
> +		scan++;
> +

This logic has potential unbounded retry problem. src would not become
empty if __isolate_lru_page() return -EBUSY since we move failed page
to src list again in this case.

Thanks.

>  		switch (__isolate_lru_page(page, mode)) {
>  		case 0:
>  			nr_pages = hpage_nr_pages(page);
> @@ -1465,14 +1471,24 @@ static unsigned long isolate_lru_pages(unsigned long nr_to_scan,
>  	 */
>  	if (!list_empty(&pages_skipped)) {
>  		int zid;
> +		unsigned long total_skipped = 0;
>  
> -		list_splice(&pages_skipped, src);
>  		for (zid = 0; zid < MAX_NR_ZONES; zid++) {
>  			if (!nr_skipped[zid])
>  				continue;
>  
>  			__count_zid_vm_events(PGSCAN_SKIP, zid, nr_skipped[zid]);
> +			total_skipped += nr_skipped[zid];
>  		}
> +
> +		/*
> +		 * Account skipped pages as a partial scan as the pgdat may be
> +		 * close to unreclaimable. If the LRU list is empty, account
> +		 * skipped pages as a full scan.
> +		 */
> +		scan += list_empty(src) ? total_skipped : total_skipped >> 2;
> +
> +		list_splice(&pages_skipped, src);
>  	}
>  	*nr_scanned = scan;
>  	trace_mm_vmscan_lru_isolate(sc->reclaim_idx, sc->order, nr_to_scan, scan,
> -- 
> 2.6.4
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
