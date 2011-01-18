Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 8E3826B0092
	for <linux-mm@kvack.org>; Tue, 18 Jan 2011 18:14:38 -0500 (EST)
Date: Tue, 18 Jan 2011 15:14:02 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: mm-deactivate-invalidated-pages.patch
Message-Id: <20110118151402.29441705.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


I haven't merged this.  What do we think its status/desirability is? 
Testing results?

I have a note against it: "When PageActive is unset, we need to change
cgroup lru too.".  Did that get addressed?

Thanks.


From: Minchan Kim <minchan.kim@gmail.com>

Recently, there are reported problem about thrashing. 
(http://marc.info/?l=rsync&m=128885034930933&w=2) It happens by backup
workloads(ex, nightly rsync).  That's because the workload makes just
use-once pages and touches pages twice.  It promotes the page into active
list so that it results in working set page eviction.

Some app developer want to support POSIX_FADV_NOREUSE.  But other OSes
don't support it, either. 
(http://marc.info/?l=linux-mm&m=128928979512086&w=2)

By Other approach, app developer uses POSIX_FADV_DONTNEED.  But it has a
problem.  If kernel meets page is writing during invalidate_mapping_pages,
it can't work.  It is very hard for application programmer to use it. 
Because they always have to sync data before calling
fadivse(..POSIX_FADV_DONTNEED) to make sure the pages could be
discardable.  At last, they can't use deferred write of kernel so that
they could see performance loss. 
(http://insights.oetiker.ch/linux/fadvise.html)

In fact, invalidate is very big hint to reclaimer.  It means we don't use
the page any more.  So let's move the writing page into inactive list's
head.

If it is real working set, it could have a enough time to activate the
page since we always try to keep many pages in inactive list.

I reused Peter's lru_demote() with some changes.

[akpm@linux-foundation.org: s/deactive/deactivate/g]
Reported-by: Ben Gamari <bgamari.foss@gmail.com>
Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
Signed-off-by: Peter Zijlstra <peterz@infradead.org>
Cc: Rik van Riel <riel@redhat.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Nick Piggin <npiggin@kernel.dk>
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
---

 include/linux/swap.h |    1 
 mm/swap.c            |   58 +++++++++++++++++++++++++++++++++++++++++
 mm/truncate.c        |   16 ++++++++---
 3 files changed, 71 insertions(+), 4 deletions(-)

diff -puN include/linux/swap.h~mm-deactivate-invalidated-pages include/linux/swap.h
--- a/include/linux/swap.h~mm-deactivate-invalidated-pages
+++ a/include/linux/swap.h
@@ -215,6 +215,7 @@ extern void mark_page_accessed(struct pa
 extern void lru_add_drain(void);
 extern int lru_add_drain_all(void);
 extern void rotate_reclaimable_page(struct page *page);
+extern void lru_deactivate_page(struct page *page);
 extern void swap_setup(void);
 
 extern void add_page_to_unevictable_list(struct page *page);
diff -puN mm/swap.c~mm-deactivate-invalidated-pages mm/swap.c
--- a/mm/swap.c~mm-deactivate-invalidated-pages
+++ a/mm/swap.c
@@ -39,6 +39,8 @@ int page_cluster;
 
 static DEFINE_PER_CPU(struct pagevec[NR_LRU_LISTS], lru_add_pvecs);
 static DEFINE_PER_CPU(struct pagevec, lru_rotate_pvecs);
+static DEFINE_PER_CPU(struct pagevec, lru_deactivate_pvecs);
+
 
 /*
  * This path almost never happens for VM activity - pages are normally
@@ -346,6 +348,45 @@ void add_page_to_unevictable_list(struct
 	spin_unlock_irq(&zone->lru_lock);
 }
 
+static void __pagevec_lru_deactivate(struct pagevec *pvec)
+{
+	int i, lru, file;
+
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
+
+		if (PageLRU(page)) {
+			if (PageActive(page)) {
+				file = page_is_file_cache(page);
+				lru = page_lru_base_type(page);
+				del_page_from_lru_list(zone, page,
+						lru + LRU_ACTIVE);
+				ClearPageActive(page);
+				ClearPageReferenced(page);
+				add_page_to_lru_list(zone, page, lru);
+				__count_vm_event(PGDEACTIVATE);
+
+				update_page_reclaim_stat(zone, page, file, 0);
+			}
+		}
+	}
+	if (zone)
+		spin_unlock_irq(&zone->lru_lock);
+
+	release_pages(pvec->pages, pvec->nr, pvec->cold);
+	pagevec_reinit(pvec);
+}
+
 /*
  * Drain pages out of the cpu's pagevecs.
  * Either "cpu" is the current CPU, and preemption has already been
@@ -372,6 +413,23 @@ static void drain_cpu_pagevecs(int cpu)
 		pagevec_move_tail(pvec);
 		local_irq_restore(flags);
 	}
+	pvec = &per_cpu(lru_deactivate_pvecs, cpu);
+	if (pagevec_count(pvec))
+		__pagevec_lru_deactivate(pvec);
+}
+
+/*
+ * Forecfully demote a page to the tail of the inactive list.
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
diff -puN mm/truncate.c~mm-deactivate-invalidated-pages mm/truncate.c
--- a/mm/truncate.c~mm-deactivate-invalidated-pages
+++ a/mm/truncate.c
@@ -332,7 +332,8 @@ unsigned long invalidate_mapping_pages(s
 {
 	struct pagevec pvec;
 	pgoff_t next = start;
-	unsigned long ret = 0;
+	unsigned long ret;
+	unsigned long count = 0;
 	int i;
 
 	pagevec_init(&pvec, 0);
@@ -359,8 +360,15 @@ unsigned long invalidate_mapping_pages(s
 			if (lock_failed)
 				continue;
 
-			ret += invalidate_inode_page(page);
-
+			ret = invalidate_inode_page(page);
+			/*
+			 * If the page was dirty or under writeback we cannot
+			 * invalidate it now.  Move it to the tail of the
+			 * inactive LRU so that reclaim will free it promptly.
+			 */
+			if (!ret)
+				lru_deactivate_page(page);
+			count += ret;
 			unlock_page(page);
 			if (next > end)
 				break;
@@ -369,7 +377,7 @@ unsigned long invalidate_mapping_pages(s
 		mem_cgroup_uncharge_end();
 		cond_resched();
 	}
-	return ret;
+	return count;
 }
 EXPORT_SYMBOL(invalidate_mapping_pages);
 
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
