Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 6EA736B004D
	for <linux-mm@kvack.org>; Thu, 16 Jul 2009 08:55:21 -0400 (EDT)
Date: Thu, 16 Jul 2009 20:55:16 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 2/3] mm: shrink_inactive_lis() nr_scan accounting fix
	fix
Message-ID: <20090716125516.GB28895@localhost>
References: <20090716094619.9D07.A69D9226@jp.fujitsu.com> <20090716095241.9D0D.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090716095241.9D0D.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Christoph Lameter <cl@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Thu, Jul 16, 2009 at 08:53:42AM +0800, KOSAKI Motohiro wrote:
> Subject: [PATCH] mm: shrink_inactive_lis() nr_scan accounting fix fix
> 
> If sc->isolate_pages() return 0, we don't need to call shrink_page_list().
> In past days, shrink_inactive_list() handled it properly.
> 
> But commit fb8d14e1 (three years ago commit!) breaked it. current shrink_inactive_list()
> always call shrink_page_list() although isolate_pages() return 0.
> 
> This patch restore proper return value check.

Patch looks good, but there is another minor problem..

> 
> Requirements:
>   o "nr_taken == 0" condition should stay before calling shrink_page_list().
>   o "nr_taken == 0" condition should stay after nr_scan related statistics
>      modification.
> 
> 
> Cc: Wu Fengguang <fengguang.wu@intel.com>
> Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
> ---
>  mm/vmscan.c |   30 ++++++++++++++++++------------
>  1 file changed, 18 insertions(+), 12 deletions(-)
> 
> Index: b/mm/vmscan.c
> ===================================================================
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -1071,6 +1071,20 @@ static unsigned long shrink_inactive_lis
>  		nr_taken = sc->isolate_pages(sc->swap_cluster_max,
>  			     &page_list, &nr_scan, sc->order, mode,
>  				zone, sc->mem_cgroup, 0, file);
> +
> +		if (scanning_global_lru(sc)) {
> +			zone->pages_scanned += nr_scan;
> +			if (current_is_kswapd())
> +				__count_zone_vm_events(PGSCAN_KSWAPD, zone,
> +						       nr_scan);
> +			else
> +				__count_zone_vm_events(PGSCAN_DIRECT, zone,
> +						       nr_scan);
> +		}
> +
> +		if (nr_taken == 0)
> +			goto done;

Not a newly introduced problem, but this early break might under scan
the list, if (max_scan > swap_cluster_max).  Luckily the only two
callers all call with (max_scan <= swap_cluster_max).

What shall we do? The comprehensive solution may be to
- remove the big do-while loop
- replace sc->swap_cluster_max => max_scan
- take care in the callers to not passing small max_scan values

Or to simply make this function more robust like this?

---
 mm/vmscan.c |   13 +++++++------
 1 file changed, 7 insertions(+), 6 deletions(-)

--- linux.orig/mm/vmscan.c
+++ linux/mm/vmscan.c
@@ -1098,7 +1098,7 @@ static unsigned long shrink_inactive_lis
 
 	lru_add_drain();
 	spin_lock_irq(&zone->lru_lock);
-	do {
+	while (nr_scanned < max_scan) {
 		struct page *page;
 		unsigned long nr_taken;
 		unsigned long nr_scan;
@@ -1112,6 +1112,7 @@ static unsigned long shrink_inactive_lis
 		nr_taken = sc->isolate_pages(sc->swap_cluster_max,
 			     &page_list, &nr_scan, sc->order, mode,
 				zone, sc->mem_cgroup, 0, file);
+		nr_scanned += nr_scan;
 
 		if (scanning_global_lru(sc)) {
 			zone->pages_scanned += nr_scan;
@@ -1123,8 +1124,10 @@ static unsigned long shrink_inactive_lis
 						       nr_scan);
 		}
 
-		if (nr_taken == 0)
-			goto done;
+		if (nr_taken == 0) {
+			cond_resched_lock(&zone->lru_lock);
+			continue;
+		}
 
 		nr_active = clear_active_flags(&page_list, count);
 		__count_vm_events(PGDEACTIVATE, nr_active);
@@ -1150,7 +1153,6 @@ static unsigned long shrink_inactive_lis
 
 		spin_unlock_irq(&zone->lru_lock);
 
-		nr_scanned += nr_scan;
 		nr_freed = shrink_page_list(&page_list, sc, PAGEOUT_IO_ASYNC);
 
 		/*
@@ -1212,9 +1214,8 @@ static unsigned long shrink_inactive_lis
 		__mod_zone_page_state(zone, NR_ISOLATED_ANON, -nr_anon);
 		__mod_zone_page_state(zone, NR_ISOLATED_FILE, -nr_file);
 
-  	} while (nr_scanned < max_scan);
+  	}
 
-done:
 	spin_unlock_irq(&zone->lru_lock);
 	pagevec_release(&pvec);
 	return nr_reclaimed;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
