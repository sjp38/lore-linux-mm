Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx166.postini.com [74.125.245.166])
	by kanga.kvack.org (Postfix) with SMTP id E695D6B0005
	for <linux-mm@kvack.org>; Tue,  9 Apr 2013 03:20:10 -0400 (EDT)
Received: from /spool/local
	by e28smtp05.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <liwanp@linux.vnet.ibm.com>;
	Tue, 9 Apr 2013 12:46:55 +0530
Received: from d28relay03.in.ibm.com (d28relay03.in.ibm.com [9.184.220.60])
	by d28dlp03.in.ibm.com (Postfix) with ESMTP id 333CA125804F
	for <linux-mm@kvack.org>; Tue,  9 Apr 2013 12:51:28 +0530 (IST)
Received: from d28av01.in.ibm.com (d28av01.in.ibm.com [9.184.220.63])
	by d28relay03.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r397Jvc47012692
	for <linux-mm@kvack.org>; Tue, 9 Apr 2013 12:49:58 +0530
Received: from d28av01.in.ibm.com (loopback [127.0.0.1])
	by d28av01.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r397K2PN009557
	for <linux-mm@kvack.org>; Tue, 9 Apr 2013 07:20:03 GMT
Date: Tue, 9 Apr 2013 15:19:59 +0800
From: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Subject: Re: [PATCH 1/3] mm, vmscan: count accidental reclaimed pages failed
 to put into lru
Message-ID: <20130409071959.GA30316@hacker.(null)>
Reply-To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
References: <1365470478-645-1-git-send-email-iamjoonsoo.kim@lge.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1365470478-645-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan@kernel.org>

On Tue, Apr 09, 2013 at 10:21:16AM +0900, Joonsoo Kim wrote:
>In shrink_(in)active_list(), we can fail to put into lru, and these pages
>are reclaimed accidentally. Currently, these pages are not counted
>for sc->nr_reclaimed, but with this information, we can stop to reclaim
>earlier, so can reduce overhead of reclaim.
>

Great Catch!

Regards,
Wanpeng Li 

>Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
>
>diff --git a/include/linux/gfp.h b/include/linux/gfp.h
>index 0f615eb..5d60ae0 100644
>--- a/include/linux/gfp.h
>+++ b/include/linux/gfp.h
>@@ -365,7 +365,7 @@ void *alloc_pages_exact_nid(int nid, size_t size, gfp_t gfp_mask);
> extern void __free_pages(struct page *page, unsigned int order);
> extern void free_pages(unsigned long addr, unsigned int order);
> extern void free_hot_cold_page(struct page *page, int cold);
>-extern void free_hot_cold_page_list(struct list_head *list, int cold);
>+extern unsigned long free_hot_cold_page_list(struct list_head *list, int cold);
>
> extern void __free_memcg_kmem_pages(struct page *page, unsigned int order);
> extern void free_memcg_kmem_pages(unsigned long addr, unsigned int order);
>diff --git a/mm/page_alloc.c b/mm/page_alloc.c
>index 8fcced7..a5f3952 100644
>--- a/mm/page_alloc.c
>+++ b/mm/page_alloc.c
>@@ -1360,14 +1360,18 @@ out:
> /*
>  * Free a list of 0-order pages
>  */
>-void free_hot_cold_page_list(struct list_head *list, int cold)
>+unsigned long free_hot_cold_page_list(struct list_head *list, int cold)
> {
>+	unsigned long nr_reclaimed = 0;
> 	struct page *page, *next;
>
> 	list_for_each_entry_safe(page, next, list, lru) {
> 		trace_mm_page_free_batched(page, cold);
> 		free_hot_cold_page(page, cold);
>+		nr_reclaimed++;
> 	}
>+
>+	return nr_reclaimed;
> }
>
> /*
>diff --git a/mm/vmscan.c b/mm/vmscan.c
>index 88c5fed..eff2927 100644
>--- a/mm/vmscan.c
>+++ b/mm/vmscan.c
>@@ -915,7 +915,6 @@ static unsigned long shrink_page_list(struct list_head *page_list,
> 		 */
> 		__clear_page_locked(page);
> free_it:
>-		nr_reclaimed++;
>
> 		/*
> 		 * Is there need to periodically free_page_list? It would
>@@ -954,7 +953,7 @@ keep:
> 	if (nr_dirty && nr_dirty == nr_congested && global_reclaim(sc))
> 		zone_set_flag(zone, ZONE_CONGESTED);
>
>-	free_hot_cold_page_list(&free_pages, 1);
>+	nr_reclaimed += free_hot_cold_page_list(&free_pages, 1);
>
> 	list_splice(&ret_pages, page_list);
> 	count_vm_events(PGACTIVATE, pgactivate);
>@@ -1321,7 +1320,7 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
> 	if (nr_taken == 0)
> 		return 0;
>
>-	nr_reclaimed = shrink_page_list(&page_list, zone, sc, TTU_UNMAP,
>+	nr_reclaimed += shrink_page_list(&page_list, zone, sc, TTU_UNMAP,
> 					&nr_dirty, &nr_writeback, false);
>
> 	spin_lock_irq(&zone->lru_lock);
>@@ -1343,7 +1342,7 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
>
> 	spin_unlock_irq(&zone->lru_lock);
>
>-	free_hot_cold_page_list(&page_list, 1);
>+	nr_reclaimed += free_hot_cold_page_list(&page_list, 1);
>
> 	/*
> 	 * If reclaim is isolating dirty pages under writeback, it implies
>@@ -1438,7 +1437,7 @@ static void move_active_pages_to_lru(struct lruvec *lruvec,
> 		__count_vm_events(PGDEACTIVATE, pgmoved);
> }
>
>-static void shrink_active_list(unsigned long nr_to_scan,
>+static unsigned long shrink_active_list(unsigned long nr_to_scan,
> 			       struct lruvec *lruvec,
> 			       struct scan_control *sc,
> 			       enum lru_list lru)
>@@ -1534,7 +1533,7 @@ static void shrink_active_list(unsigned long nr_to_scan,
> 	__mod_zone_page_state(zone, NR_ISOLATED_ANON + file, -nr_taken);
> 	spin_unlock_irq(&zone->lru_lock);
>
>-	free_hot_cold_page_list(&l_hold, 1);
>+	return free_hot_cold_page_list(&l_hold, 1);
> }
>
> #ifdef CONFIG_SWAP
>@@ -1617,7 +1616,8 @@ static unsigned long shrink_list(enum lru_list lru, unsigned long nr_to_scan,
> {
> 	if (is_active_lru(lru)) {
> 		if (inactive_list_is_low(lruvec, lru))
>-			shrink_active_list(nr_to_scan, lruvec, sc, lru);
>+			return shrink_active_list(nr_to_scan, lruvec, sc, lru);
>+
> 		return 0;
> 	}
>
>@@ -1861,8 +1861,8 @@ static void shrink_lruvec(struct lruvec *lruvec, struct scan_control *sc)
> 	 * rebalance the anon lru active/inactive ratio.
> 	 */
> 	if (inactive_anon_is_low(lruvec))
>-		shrink_active_list(SWAP_CLUSTER_MAX, lruvec,
>-				   sc, LRU_ACTIVE_ANON);
>+		sc->nr_reclaimed += shrink_active_list(SWAP_CLUSTER_MAX,
>+					lruvec, sc, LRU_ACTIVE_ANON);
>
> 	throttle_vm_writeout(sc->gfp_mask);
> }
>@@ -2470,23 +2470,27 @@ unsigned long try_to_free_mem_cgroup_pages(struct mem_cgroup *memcg,
> }
> #endif
>
>-static void age_active_anon(struct zone *zone, struct scan_control *sc)
>+static unsigned long age_active_anon(struct zone *zone,
>+					struct scan_control *sc)
> {
>+	unsigned long nr_reclaimed = 0;
> 	struct mem_cgroup *memcg;
>
> 	if (!total_swap_pages)
>-		return;
>+		return 0;
>
> 	memcg = mem_cgroup_iter(NULL, NULL, NULL);
> 	do {
> 		struct lruvec *lruvec = mem_cgroup_zone_lruvec(zone, memcg);
>
> 		if (inactive_anon_is_low(lruvec))
>-			shrink_active_list(SWAP_CLUSTER_MAX, lruvec,
>-					   sc, LRU_ACTIVE_ANON);
>+			nr_reclaimed += shrink_active_list(SWAP_CLUSTER_MAX,
>+					lruvec, sc, LRU_ACTIVE_ANON);
>
> 		memcg = mem_cgroup_iter(NULL, memcg, NULL);
> 	} while (memcg);
>+
>+	return nr_reclaimed;
> }
>
> static bool zone_balanced(struct zone *zone, int order,
>@@ -2666,7 +2670,7 @@ loop_again:
> 			 * Do some background aging of the anon list, to give
> 			 * pages a chance to be referenced before reclaiming.
> 			 */
>-			age_active_anon(zone, &sc);
>+			sc.nr_reclaimed += age_active_anon(zone, &sc);
>
> 			/*
> 			 * If the number of buffer_heads in the machine
>-- 
>1.7.9.5
>
>--
>To unsubscribe, send a message with 'unsubscribe linux-mm' in
>the body to majordomo@kvack.org.  For more info on Linux MM,
>see: http://www.linux-mm.org/ .
>Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
