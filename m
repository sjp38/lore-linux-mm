Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id F0EE46B008A
	for <linux-mm@kvack.org>; Sun,  5 Dec 2010 12:30:02 -0500 (EST)
Received: by pxi12 with SMTP id 12so2314206pxi.14
        for <linux-mm@kvack.org>; Sun, 05 Dec 2010 09:30:01 -0800 (PST)
From: Minchan Kim <minchan.kim@gmail.com>
Subject: [PATCH v4 2/7] deactivate invalidated pages
Date: Mon,  6 Dec 2010 02:29:10 +0900
Message-Id: <d57730effe4b48012d31ceca07938ed3eb401aba.1291568905.git.minchan.kim@gmail.com>
In-Reply-To: <cover.1291568905.git.minchan.kim@gmail.com>
References: <cover.1291568905.git.minchan.kim@gmail.com>
In-Reply-To: <cover.1291568905.git.minchan.kim@gmail.com>
References: <cover.1291568905.git.minchan.kim@gmail.com>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Minchan Kim <minchan.kim@gmail.com>, Peter Zijlstra <peterz@infradead.org>, Wu Fengguang <fengguang.wu@intel.com>, Johannes Weiner <hannes@cmpxchg.org>, Nick Piggin <npiggin@kernel.dk>, Mel Gorman <mel@csn.ul.ie>
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
Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Wu Fengguang <fengguang.wu@intel.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Nick Piggin <npiggin@kernel.dk>
Cc: Mel Gorman <mel@csn.ul.ie>

Andrew. Before applying this series, please drop below two patches.
 mm-deactivate-invalidated-pages.patch
 mm-deactivate-invalidated-pages-fix.patch

Changelog since v3:
 - Change function comments - suggested by Johannes
 - Change function name - suggested by Johannes
 - add only dirty/writeback pages to deactive pagevec

Changelog since v2:
 - mapped page leaves alone - suggested by Mel
 - pass part related PG_reclaim in next patch.

Changelog since v1:
 - modify description
 - correct typo
 - add some comment

Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
---
 include/linux/swap.h |    1 +
 mm/swap.c            |   78 ++++++++++++++++++++++++++++++++++++++++++++++++++
 mm/truncate.c        |   17 ++++++++--
 3 files changed, 92 insertions(+), 4 deletions(-)

diff --git a/include/linux/swap.h b/include/linux/swap.h
index eba53e7..605ab62 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -213,6 +213,7 @@ extern void mark_page_accessed(struct page *);
 extern void lru_add_drain(void);
 extern int lru_add_drain_all(void);
 extern void rotate_reclaimable_page(struct page *page);
+extern void deactivate_page(struct page *page);
 extern void swap_setup(void);
 
 extern void add_page_to_unevictable_list(struct page *page);
diff --git a/mm/swap.c b/mm/swap.c
index d5822b0..1f36f6f 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -39,6 +39,8 @@ int page_cluster;
 
 static DEFINE_PER_CPU(struct pagevec[NR_LRU_LISTS], lru_add_pvecs);
 static DEFINE_PER_CPU(struct pagevec, lru_rotate_pvecs);
+static DEFINE_PER_CPU(struct pagevec, lru_deactivate_pvecs);
+
 
 /*
  * This path almost never happens for VM activity - pages are normally
@@ -267,6 +269,59 @@ void add_page_to_unevictable_list(struct page *page)
 }
 
 /*
+ * If the page can not be invalidated, it is moved to the
+ * inactive list to speed up its reclaim.  It is moved to the
+ * head of the list, rather than the tail, to give the flusher
+ * threads some time to write it out, as this is much more
+ * effective than the single-page writeout from reclaim.
+ */
+static void lru_deactivate(struct page *page, struct zone *zone)
+{
+	int lru, file;
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
+static void ____pagevec_lru_deactivate(struct pagevec *pvec)
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
+		lru_deactivate(page, zone);
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
@@ -292,6 +347,29 @@ static void drain_cpu_pagevecs(int cpu)
 		pagevec_move_tail(pvec);
 		local_irq_restore(flags);
 	}
+
+	pvec = &per_cpu(lru_deactivate_pvecs, cpu);
+	if (pagevec_count(pvec))
+		____pagevec_lru_deactivate(pvec);
+}
+
+/**
+ * deactivate_page - forcefully deactivate a page
+ * @page: page to deactivate
+ *
+ * This function hints the VM that @page is a good reclaim candidate,
+ * for example if its invalidation fails due to the page being dirty
+ * or under writeback.
+ */
+void deactivate_page(struct page *page)
+{
+	if (likely(get_page_unless_zero(page))) {
+		struct pagevec *pvec = &get_cpu_var(lru_deactivate_pvecs);
+
+		if (!pagevec_add(pvec, page))
+			____pagevec_lru_deactivate(pvec);
+		put_cpu_var(lru_deactivate_pvecs);
+	}
 }
 
 void lru_add_drain(void)
diff --git a/mm/truncate.c b/mm/truncate.c
index cd94607..ef03cbc 100644
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
@@ -359,8 +360,16 @@ unsigned long invalidate_mapping_pages(struct address_space *mapping,
 			if (lock_failed)
 				continue;
 
-			ret += invalidate_inode_page(page);
-
+			ret = invalidate_inode_page(page);
+			/*
+			 * If the page is dirty or under writeback, we can not
+			 * invalidate it now.  But we assume that attempted
+			 * invalidation is a hint that the page is no longer
+			 * of interest and try to speed up its reclaim.
+			 */
+			if (!ret && (PageDirty(page) || PageWriteback(page)))
+				deactivate_page(page);
+			count += ret;
 			unlock_page(page);
 			if (next > end)
 				break;
@@ -369,7 +378,7 @@ unsigned long invalidate_mapping_pages(struct address_space *mapping,
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
