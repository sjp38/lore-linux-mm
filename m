Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 7483F8D0007
	for <linux-mm@kvack.org>; Mon, 29 Nov 2010 10:23:46 -0500 (EST)
Received: by pzk27 with SMTP id 27so983986pzk.14
        for <linux-mm@kvack.org>; Mon, 29 Nov 2010 07:23:41 -0800 (PST)
From: Minchan Kim <minchan.kim@gmail.com>
Subject: [PATCH v3 1/3] deactivate invalidated pages
Date: Tue, 30 Nov 2010 00:23:19 +0900
Message-Id: <6e01d81a4b575dcaaacc6b3782c505103e024085.1291043274.git.minchan.kim@gmail.com>
In-Reply-To: <cover.1291043273.git.minchan.kim@gmail.com>
References: <cover.1291043273.git.minchan.kim@gmail.com>
In-Reply-To: <cover.1291043273.git.minchan.kim@gmail.com>
References: <cover.1291043273.git.minchan.kim@gmail.com>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Ben Gamari <bgamari.foss@gmail.com>, Minchan Kim <minchan.kim@gmail.com>, Peter Zijlstra <peterz@infradead.org>, Wu Fengguang <fengguang.wu@intel.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Nick Piggin <npiggin@kernel.dk>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

Recently, there are reported problem about thrashing.
(http://marc.info/?l=rsync&m=128885034930933&w=2)
It happens by backup workloads(ex, nightly rsync).
That's because the workload makes just use-once pages
and touches pages twice. It promotes the page into
active list so that it results in working set page eviction.

Some app developer want to support POSIX_FADV_NOREUSE.
But other OSes don't support it, either.
(http://marc.info/?l=linux-mm&m=128928979512086&w=2)

By other approach, app developers use POSIX_FADV_DONTNEED.
But it has a problem. If kernel meets page is writing
during invalidate_mapping_pages, it can't work.
It is very hard for application programmer to use it.
Because they always have to sync data before calling
fadivse(..POSIX_FADV_DONTNEED) to make sure the pages could
be discardable. At last, they can't use deferred write of kernel
so that they could see performance loss.
(http://insights.oetiker.ch/linux/fadvise.html)

In fact, invalidation is very big hint to reclaimer.
It means we don't use the page any more. So let's move
the writing page into inactive list's head.

Why I need the page to head, Dirty/Writeback page would be flushed
sooner or later. It can prevent writeout of pageout which is less
effective than flusher's writeout.

Originally, I reused lru_demote of Peter with some change so added
his Signed-off-by.

Reported-by: Ben Gamari <bgamari.foss@gmail.com>
Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
Signed-off-by: Peter Zijlstra <peterz@infradead.org>
Acked-by: Rik van Riel <riel@redhat.com>
Cc: Wu Fengguang <fengguang.wu@intel.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Nick Piggin <npiggin@kernel.dk>
Cc: Mel Gorman <mel@csn.ul.ie>

Adnrew. Before applying this series, please drop below two patches.
 mm-deactivate-invalidated-pages.patch
 mm-deactivate-invalidated-pages-fix.patch

Changelog since v2:
 - mapped page leaves alone - suggested by Mel
 - pass part related PG_reclaim in next patch.

Changelog since v1:
 - modify description
 - correct typo
 - add some comment
---
 include/linux/swap.h |    1 +
 mm/swap.c            |   80 ++++++++++++++++++++++++++++++++++++++++++++++++++
 mm/truncate.c        |   16 +++++++--
 3 files changed, 93 insertions(+), 4 deletions(-)

diff --git a/include/linux/swap.h b/include/linux/swap.h
index eba53e7..84375e4 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -213,6 +213,7 @@ extern void mark_page_accessed(struct page *);
 extern void lru_add_drain(void);
 extern int lru_add_drain_all(void);
 extern void rotate_reclaimable_page(struct page *page);
+extern void lru_deactivate_page(struct page *page);
 extern void swap_setup(void);
 
 extern void add_page_to_unevictable_list(struct page *page);
diff --git a/mm/swap.c b/mm/swap.c
index 3f48542..19e0812 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -31,6 +31,7 @@
 #include <linux/backing-dev.h>
 #include <linux/memcontrol.h>
 #include <linux/gfp.h>
+#include <linux/rmap.h>
 
 #include "internal.h"
 
@@ -39,6 +40,8 @@ int page_cluster;
 
 static DEFINE_PER_CPU(struct pagevec[NR_LRU_LISTS], lru_add_pvecs);
 static DEFINE_PER_CPU(struct pagevec, lru_rotate_pvecs);
+static DEFINE_PER_CPU(struct pagevec, lru_deactivate_pvecs);
+
 
 /*
  * This path almost never happens for VM activity - pages are normally
@@ -267,6 +270,63 @@ void add_page_to_unevictable_list(struct page *page)
 }
 
 /*
+ * This function is used by invalidate_mapping_pages.
+ * If the page can't be invalidated, this function moves the page
+ * into inative list's head. Because the VM expects the page would
+ * be writeout by flusher. The flusher's writeout is much effective
+ * than reclaimer's random writeout.
+ */
+static void __lru_deactivate(struct page *page, struct zone *zone)
+{
+	int lru, file;
+	unsigned long vm_flags;
+
+	if (!PageLRU(page) || !PageActive(page))
+		return;
+
+	/* Some processes are using the page */
+	if (page_mapped(page))
+		return;
+
+	file = page_is_file_cache(page);
+	lru = page_lru_base_type(page);
+	del_page_from_lru_list(zone, page, lru + LRU_ACTIVE);
+	ClearPageActive(page);
+	ClearPageReferenced(page);
+	add_page_to_lru_list(zone, page, lru);
+	__count_vm_event(PGDEACTIVATE);
+
+	update_page_reclaim_stat(zone, page, file, 0);
+}
+
+/*
+ * This function must be called with preemption disable.
+ */
+static void __pagevec_lru_deactivate(struct pagevec *pvec)
+{
+	int i;
+	struct zone *zone = NULL;
+
+	for (i = 0; i < pagevec_count(pvec); i++) {
+		struct page *page = pvec->pages[i];
+		struct zone *pagezone = page_zone(page);
+
+		if (pagezone != zone) {
+			if (zone)
+				spin_unlock_irq(&zone->lru_lock);
+			zone = pagezone;
+			spin_lock_irq(&zone->lru_lock);
+		}
+		__lru_deactivate(page, zone);
+	}
+	if (zone)
+		spin_unlock_irq(&zone->lru_lock);
+
+	release_pages(pvec->pages, pvec->nr, pvec->cold);
+	pagevec_reinit(pvec);
+}
+
+/*
  * Drain pages out of the cpu's pagevecs.
  * Either "cpu" is the current CPU, and preemption has already been
  * disabled; or "cpu" is being hot-unplugged, and is already dead.
@@ -292,6 +352,26 @@ static void drain_cpu_pagevecs(int cpu)
 		pagevec_move_tail(pvec);
 		local_irq_restore(flags);
 	}
+
+	pvec = &per_cpu(lru_deactivate_pvecs, cpu);
+	if (pagevec_count(pvec))
+		__pagevec_lru_deactivate(pvec);
+}
+
+/*
+ * Forcefully deactivate a page.
+ * This function is used for reclaiming the page ASAP when the page
+ * can't be invalidated by Dirty/Writeback.
+ */
+void lru_deactivate_page(struct page *page)
+{
+	if (likely(get_page_unless_zero(page))) {
+		struct pagevec *pvec = &get_cpu_var(lru_deactivate_pvecs);
+
+		if (!pagevec_add(pvec, page))
+			__pagevec_lru_deactivate(pvec);
+		put_cpu_var(lru_deactivate_pvecs);
+	}
 }
 
 void lru_add_drain(void)
diff --git a/mm/truncate.c b/mm/truncate.c
index cd94607..09b9748 100644
--- a/mm/truncate.c
+++ b/mm/truncate.c
@@ -332,7 +332,8 @@ unsigned long invalidate_mapping_pages(struct address_space *mapping,
 {
 	struct pagevec pvec;
 	pgoff_t next = start;
-	unsigned long ret = 0;
+	unsigned long ret;
+	unsigned long count = 0;
 	int i;
 
 	pagevec_init(&pvec, 0);
@@ -359,8 +360,15 @@ unsigned long invalidate_mapping_pages(struct address_space *mapping,
 			if (lock_failed)
 				continue;
 
-			ret += invalidate_inode_page(page);
-
+			ret = invalidate_inode_page(page);
+			/*
+			 * If the page was dirty or under writeback we cannot
+			 * invalidate it now.  Move it to the head of the
+			 * inactive LRU for using deferred writeback of flusher.
+			 */
+			if (!ret)
+				lru_deactivate_page(page);
+			count += ret;
 			unlock_page(page);
 			if (next > end)
 				break;
@@ -369,7 +377,7 @@ unsigned long invalidate_mapping_pages(struct address_space *mapping,
 		mem_cgroup_uncharge_end();
 		cond_resched();
 	}
-	return ret;
+	return count;
 }
 EXPORT_SYMBOL(invalidate_mapping_pages);
 
-- 
1.7.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
