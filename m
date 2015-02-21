Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 188CC6B0038
	for <linux-mm@kvack.org>; Fri, 20 Feb 2015 22:54:07 -0500 (EST)
Received: by padhz1 with SMTP id hz1so12770789pad.9
        for <linux-mm@kvack.org>; Fri, 20 Feb 2015 19:54:06 -0800 (PST)
Received: from mail-pa0-x22c.google.com (mail-pa0-x22c.google.com. [2607:f8b0:400e:c03::22c])
        by mx.google.com with ESMTPS id qn11si15238926pdb.229.2015.02.20.19.54.06
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 20 Feb 2015 19:54:06 -0800 (PST)
Received: by pablf10 with SMTP id lf10so12726050pab.12
        for <linux-mm@kvack.org>; Fri, 20 Feb 2015 19:54:06 -0800 (PST)
Date: Fri, 20 Feb 2015 19:54:03 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH 02/24] mm: update_lru_size do the __mod_zone_page_state
In-Reply-To: <alpine.LSU.2.11.1502201941340.14414@eggly.anvils>
Message-ID: <alpine.LSU.2.11.1502201951270.14414@eggly.anvils>
References: <alpine.LSU.2.11.1502201941340.14414@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Ning Qu <quning@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Konstantin Khlebnikov <koct9i@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Konstantin Khlebnikov pointed out (nearly three years ago, when lumpy
reclaim was removed) that lru_size can be updated by -nr_taken once
per call to isolate_lru_pages(), instead of page by page.

Update it inside isolate_lru_pages(), or at its two callsites?  I
chose to update it at the callsites, rearranging and grouping the
updates by nr_taken and nr_scanned together in both.

With one exception, mem_cgroup_update_lru_size(,lru,) is then used
where __mod_zone_page_state(,NR_LRU_BASE+lru,) is used; and we shall
be adding some more calls in a later commit.  Make the code a little
smaller and simpler by incorporating stat update in lru_size update.

The exception was move_active_pages_to_lru(), which aggregated the
pgmoved stat update separately from the individual lru_size updates;
but I still think this a simplification worth making.

However, the __mod_zone_page_state is not peculiar to mem_cgroups: so
better use the name update_lru_size, calls mem_cgroup_update_lru_size
when CONFIG_MEMCG.

Signed-off-by: Hugh Dickins <hughd@google.com>
---
 include/linux/memcontrol.h |    6 ------
 include/linux/mm_inline.h  |   24 ++++++++++++++++++------
 mm/memcontrol.c            |    4 +++-
 mm/vmscan.c                |   23 ++++++++++-------------
 4 files changed, 31 insertions(+), 26 deletions(-)

--- thpfs.orig/include/linux/memcontrol.h	2015-02-08 18:54:22.000000000 -0800
+++ thpfs/include/linux/memcontrol.h	2015-02-20 19:33:31.052085168 -0800
@@ -275,12 +275,6 @@ mem_cgroup_get_lru_size(struct lruvec *l
 }
 
 static inline void
-mem_cgroup_update_lru_size(struct lruvec *lruvec, enum lru_list lru,
-			      int increment)
-{
-}
-
-static inline void
 mem_cgroup_print_oom_info(struct mem_cgroup *memcg, struct task_struct *p)
 {
 }
--- thpfs.orig/include/linux/mm_inline.h	2015-02-20 19:33:25.928096883 -0800
+++ thpfs/include/linux/mm_inline.h	2015-02-20 19:33:31.052085168 -0800
@@ -22,22 +22,34 @@ static inline int page_is_file_cache(str
 	return !PageSwapBacked(page);
 }
 
+static __always_inline void __update_lru_size(struct lruvec *lruvec,
+				enum lru_list lru, int nr_pages)
+{
+	__mod_zone_page_state(lruvec_zone(lruvec), NR_LRU_BASE + lru, nr_pages);
+}
+
+static __always_inline void update_lru_size(struct lruvec *lruvec,
+				enum lru_list lru, int nr_pages)
+{
+#ifdef CONFIG_MEMCG
+	mem_cgroup_update_lru_size(lruvec, lru, nr_pages);
+#else
+	__update_lru_size(lruvec, lru, nr_pages);
+#endif
+}
+
 static __always_inline void add_page_to_lru_list(struct page *page,
 				struct lruvec *lruvec, enum lru_list lru)
 {
-	int nr_pages = hpage_nr_pages(page);
-	mem_cgroup_update_lru_size(lruvec, lru, nr_pages);
+	update_lru_size(lruvec, lru, hpage_nr_pages(page));
 	list_add(&page->lru, &lruvec->lists[lru]);
-	__mod_zone_page_state(lruvec_zone(lruvec), NR_LRU_BASE + lru, nr_pages);
 }
 
 static __always_inline void del_page_from_lru_list(struct page *page,
 				struct lruvec *lruvec, enum lru_list lru)
 {
-	int nr_pages = hpage_nr_pages(page);
 	list_del(&page->lru);
-	mem_cgroup_update_lru_size(lruvec, lru, -nr_pages);
-	__mod_zone_page_state(lruvec_zone(lruvec), NR_LRU_BASE + lru, -nr_pages);
+	update_lru_size(lruvec, lru, -hpage_nr_pages(page));
 }
 
 /**
--- thpfs.orig/mm/memcontrol.c	2015-02-20 19:33:25.928096883 -0800
+++ thpfs/mm/memcontrol.c	2015-02-20 19:33:31.052085168 -0800
@@ -1309,7 +1309,7 @@ void mem_cgroup_update_lru_size(struct l
 	bool empty;
 
 	if (mem_cgroup_disabled())
-		return;
+		goto out;
 
 	mz = container_of(lruvec, struct mem_cgroup_per_zone, lruvec);
 	lru_size = mz->lru_size + lru;
@@ -1328,6 +1328,8 @@ void mem_cgroup_update_lru_size(struct l
 
 	if (nr_pages > 0)
 		*lru_size += nr_pages;
+out:
+	__update_lru_size(lruvec, lru, nr_pages);
 }
 
 bool mem_cgroup_is_descendant(struct mem_cgroup *memcg, struct mem_cgroup *root)
--- thpfs.orig/mm/vmscan.c	2015-02-08 18:54:22.000000000 -0800
+++ thpfs/mm/vmscan.c	2015-02-20 19:33:31.056085158 -0800
@@ -1280,7 +1280,6 @@ static unsigned long isolate_lru_pages(u
 
 	for (scan = 0; scan < nr_to_scan && !list_empty(src); scan++) {
 		struct page *page;
-		int nr_pages;
 
 		page = lru_to_page(src);
 		prefetchw_prev_lru_page(page, src, flags);
@@ -1289,10 +1288,8 @@ static unsigned long isolate_lru_pages(u
 
 		switch (__isolate_lru_page(page, mode)) {
 		case 0:
-			nr_pages = hpage_nr_pages(page);
-			mem_cgroup_update_lru_size(lruvec, lru, -nr_pages);
+			nr_taken += hpage_nr_pages(page);
 			list_move(&page->lru, dst);
-			nr_taken += nr_pages;
 			break;
 
 		case -EBUSY:
@@ -1507,8 +1504,9 @@ shrink_inactive_list(unsigned long nr_to
 	nr_taken = isolate_lru_pages(nr_to_scan, lruvec, &page_list,
 				     &nr_scanned, sc, isolate_mode, lru);
 
-	__mod_zone_page_state(zone, NR_LRU_BASE + lru, -nr_taken);
+	update_lru_size(lruvec, lru, -nr_taken);
 	__mod_zone_page_state(zone, NR_ISOLATED_ANON + file, nr_taken);
+	reclaim_stat->recent_scanned[file] += nr_taken;
 
 	if (global_reclaim(sc)) {
 		__mod_zone_page_state(zone, NR_PAGES_SCANNED, nr_scanned);
@@ -1529,8 +1527,6 @@ shrink_inactive_list(unsigned long nr_to
 
 	spin_lock_irq(&zone->lru_lock);
 
-	reclaim_stat->recent_scanned[file] += nr_taken;
-
 	if (global_reclaim(sc)) {
 		if (current_is_kswapd())
 			__count_zone_vm_events(PGSTEAL_KSWAPD, zone,
@@ -1650,7 +1646,7 @@ static void move_active_pages_to_lru(str
 		SetPageLRU(page);
 
 		nr_pages = hpage_nr_pages(page);
-		mem_cgroup_update_lru_size(lruvec, lru, nr_pages);
+		update_lru_size(lruvec, lru, nr_pages);
 		list_move(&page->lru, &lruvec->lists[lru]);
 		pgmoved += nr_pages;
 
@@ -1668,7 +1664,7 @@ static void move_active_pages_to_lru(str
 				list_add(&page->lru, pages_to_free);
 		}
 	}
-	__mod_zone_page_state(zone, NR_LRU_BASE + lru, pgmoved);
+
 	if (!is_active_lru(lru))
 		__count_vm_events(PGDEACTIVATE, pgmoved);
 }
@@ -1702,14 +1698,15 @@ static void shrink_active_list(unsigned
 
 	nr_taken = isolate_lru_pages(nr_to_scan, lruvec, &l_hold,
 				     &nr_scanned, sc, isolate_mode, lru);
-	if (global_reclaim(sc))
-		__mod_zone_page_state(zone, NR_PAGES_SCANNED, nr_scanned);
 
+	update_lru_size(lruvec, lru, -nr_taken);
+	__mod_zone_page_state(zone, NR_ISOLATED_ANON + file, nr_taken);
 	reclaim_stat->recent_scanned[file] += nr_taken;
 
+	if (global_reclaim(sc))
+		__mod_zone_page_state(zone, NR_PAGES_SCANNED, nr_scanned);
 	__count_zone_vm_events(PGREFILL, zone, nr_scanned);
-	__mod_zone_page_state(zone, NR_LRU_BASE + lru, -nr_taken);
-	__mod_zone_page_state(zone, NR_ISOLATED_ANON + file, nr_taken);
+
 	spin_unlock_irq(&zone->lru_lock);
 
 	while (!list_empty(&l_hold)) {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
