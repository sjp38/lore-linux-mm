Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id C2BC56B005A
	for <linux-mm@kvack.org>; Mon, 11 May 2009 23:03:42 -0400 (EDT)
Date: Tue, 12 May 2009 11:03:23 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH -mm] vmscan: merge duplicate code in
	shrink_active_list()
Message-ID: <20090512030323.GA10074@localhost>
References: <20090508125859.210a2a25.akpm@linux-foundation.org> <20090512025319.GD7518@localhost> <20090512115811.D613.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090512115811.D613.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "hannes@cmpxchg.org" <hannes@cmpxchg.org>, "peterz@infradead.org" <peterz@infradead.org>, "riel@redhat.com" <riel@redhat.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "tytso@mit.edu" <tytso@mit.edu>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "elladan@eskimo.com" <elladan@eskimo.com>, "npiggin@suse.de" <npiggin@suse.de>, "cl@linux-foundation.org" <cl@linux-foundation.org>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>
List-ID: <linux-mm.kvack.org>

On Tue, May 12, 2009 at 10:58:28AM +0800, KOSAKI Motohiro wrote:
> > +void move_active_pages_to_lru(enum lru_list lru, struct list_head *list)
> 
> it can be static?

Thanks, here's the updated patch.

---
vmscan: merge duplicate code in shrink_active_list()

The "move pages to active list" and "move pages to inactive list"
code blocks are mostly identical and can be served by a function.

Thanks to Andrew Morton for pointing this out.

Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
---
 mm/vmscan.c |   84 ++++++++++++++++++++------------------------------
 1 file changed, 35 insertions(+), 49 deletions(-)

--- linux.orig/mm/vmscan.c
+++ linux/mm/vmscan.c
@@ -1225,6 +1225,36 @@ static inline void note_zone_scanning_pr
  * But we had to alter page->flags anyway.
  */
 
+static void move_active_pages_to_lru(enum lru_list lru, struct list_head *list)
+{
+	unsigned long pgmoved = 0;
+
+	while (!list_empty(&list)) {
+		page = lru_to_page(&list);
+		prefetchw_prev_lru_page(page, &list, flags);
+
+		VM_BUG_ON(PageLRU(page));
+		SetPageLRU(page);
+
+		VM_BUG_ON(!PageActive(page));
+		if (lru < LRU_ACTIVE)
+			ClearPageActive(page);
+
+		list_move(&page->lru, &zone->lru[lru].list);
+		mem_cgroup_add_lru_list(page, lru);
+		pgmoved++;
+		if (!pagevec_add(&pvec, page)) {
+			spin_unlock_irq(&zone->lru_lock);
+			if (buffer_heads_over_limit)
+				pagevec_strip(&pvec);
+			__pagevec_release(&pvec);
+			spin_lock_irq(&zone->lru_lock);
+		}
+	}
+	__mod_zone_page_state(zone, NR_LRU_BASE + lru, pgmoved);
+	if (lru < LRU_ACTIVE)
+		__count_vm_events(PGDEACTIVATE, pgmoved);
+}
 
 static void shrink_active_list(unsigned long nr_pages, struct zone *zone,
 			struct scan_control *sc, int priority, int file)
@@ -1254,6 +1284,7 @@ static void shrink_active_list(unsigned 
 	}
 	reclaim_stat->recent_scanned[!!file] += pgmoved;
 
+	__count_zone_vm_events(PGREFILL, zone, pgscanned);
 	if (file)
 		__mod_zone_page_state(zone, NR_ACTIVE_FILE, -pgmoved);
 	else
@@ -1293,65 +1324,20 @@ static void shrink_active_list(unsigned 
 	}
 
 	/*
-	 * Move the pages to the [file or anon] inactive list.
+	 * Move pages back to the lru list.
 	 */
 	pagevec_init(&pvec, 1);
 
 	spin_lock_irq(&zone->lru_lock);
 	/*
-	 * Count referenced pages from currently used mappings as
-	 * rotated, even though they are moved to the inactive list.
+	 * Count referenced pages from currently used mappings as rotated.
 	 * This helps balance scan pressure between file and anonymous
 	 * pages in get_scan_ratio.
 	 */
 	reclaim_stat->recent_rotated[!!file] += pgmoved;
 
-	pgmoved = 0;  /* count pages moved to inactive list */
-	lru = LRU_BASE + file * LRU_FILE;
-	while (!list_empty(&l_inactive)) {
-		page = lru_to_page(&l_inactive);
-		prefetchw_prev_lru_page(page, &l_inactive, flags);
-		VM_BUG_ON(PageLRU(page));
-		SetPageLRU(page);
-		VM_BUG_ON(!PageActive(page));
-		ClearPageActive(page);
-
-		list_move(&page->lru, &zone->lru[lru].list);
-		mem_cgroup_add_lru_list(page, lru);
-		pgmoved++;
-		if (!pagevec_add(&pvec, page)) {
-			spin_unlock_irq(&zone->lru_lock);
-			if (buffer_heads_over_limit)
-				pagevec_strip(&pvec);
-			__pagevec_release(&pvec);
-			spin_lock_irq(&zone->lru_lock);
-		}
-	}
-	__mod_zone_page_state(zone, NR_LRU_BASE + lru, pgmoved);
-	__count_zone_vm_events(PGREFILL, zone, pgscanned);
-	__count_vm_events(PGDEACTIVATE, pgmoved);
-
-	pgmoved = 0;  /* count pages moved back to active list */
-	lru = LRU_ACTIVE + file * LRU_FILE;
-	while (!list_empty(&l_active)) {
-		page = lru_to_page(&l_active);
-		prefetchw_prev_lru_page(page, &l_active, flags);
-		VM_BUG_ON(PageLRU(page));
-		SetPageLRU(page);
-		VM_BUG_ON(!PageActive(page));
-
-		list_move(&page->lru, &zone->lru[lru].list);
-		mem_cgroup_add_lru_list(page, lru);
-		pgmoved++;
-		if (!pagevec_add(&pvec, page)) {
-			spin_unlock_irq(&zone->lru_lock);
-			if (buffer_heads_over_limit)
-				pagevec_strip(&pvec);
-			__pagevec_release(&pvec);
-			spin_lock_irq(&zone->lru_lock);
-		}
-	}
-	__mod_zone_page_state(zone, NR_LRU_BASE + lru, pgmoved);
+	move_active_pages_to_lru(LRU_ACTIVE + file * LRU_FILE, &l_active);
+	move_active_pages_to_lru(LRU_BASE   + file * LRU_FILE, &l_inactive);
 
 	spin_unlock_irq(&zone->lru_lock);
 	if (buffer_heads_over_limit)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
