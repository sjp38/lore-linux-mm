Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx179.postini.com [74.125.245.179])
	by kanga.kvack.org (Postfix) with SMTP id 957336B0148
	for <linux-mm@kvack.org>; Sun, 19 Feb 2012 16:24:21 -0500 (EST)
Received: by mail-bk0-f41.google.com with SMTP id y12so5453710bkt.14
        for <linux-mm@kvack.org>; Sun, 19 Feb 2012 13:24:21 -0800 (PST)
Subject: [PATCH 2/3] mm: replace per-cpu lru-add page-vectors with page-lists
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
Date: Mon, 20 Feb 2012 01:24:17 +0400
Message-ID: <20120219212417.16861.63119.stgit@zurg>
In-Reply-To: <20120219212412.16861.36936.stgit@zurg>
References: <20120219212412.16861.36936.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org
Cc: Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Johannes Weiner <jweiner@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

This patch replaces page-vectors with page-lists in lru_cache_add*() functions.
We can use page->lru for linking because page obviously not in lru.

Now per-cpu batch limited with its pages total size, not pages count,
otherwise it can be extremely huge if there many huge-pages inside:
PAGEVEC_SIZE * HPAGE_SIZE = 28Mb, per-cpu!
These pages are hidden from memory reclaimer for a while.
New limit: LRU_CACHE_ADD_BATCH = 64 (* PAGE_SIZE = 256Kb)

So, huge-page adding now will always drain per-cpu list. Huge-page allocation
and preparation is long procedure, thus nobody will notice this draining.

Draining procedure disables preemption only for pages list isolation,
thus batch size can be increased without negative effect for latency.

Plus this patch introduces new function lru_cache_add_list() and use it in
mpage_readpages() and read_pages(). There pages already collected in list.
Unlike to single-page lru-add, list-add reuse page-referencies from caller,
thus we save one page_get()/page_put() per page.

Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
---
 fs/mpage.c           |   21 +++++++----
 include/linux/swap.h |    2 +
 mm/readahead.c       |   15 +++++---
 mm/swap.c            |   99 +++++++++++++++++++++++++++++++++++++++++++++-----
 4 files changed, 114 insertions(+), 23 deletions(-)

diff --git a/fs/mpage.c b/fs/mpage.c
index 643e9f5..6474f41 100644
--- a/fs/mpage.c
+++ b/fs/mpage.c
@@ -15,6 +15,7 @@
 #include <linux/kernel.h>
 #include <linux/module.h>
 #include <linux/mm.h>
+#include <linux/swap.h>
 #include <linux/kdev_t.h>
 #include <linux/gfp.h>
 #include <linux/bio.h>
@@ -367,29 +368,33 @@ mpage_readpages(struct address_space *mapping, struct list_head *pages,
 				unsigned nr_pages, get_block_t get_block)
 {
 	struct bio *bio = NULL;
-	unsigned page_idx;
 	sector_t last_block_in_bio = 0;
 	struct buffer_head map_bh;
 	unsigned long first_logical_block = 0;
+	struct page *page, *next;
+	int nr_added = 0;
 
 	map_bh.b_state = 0;
 	map_bh.b_size = 0;
-	for (page_idx = 0; page_idx < nr_pages; page_idx++) {
-		struct page *page = list_entry(pages->prev, struct page, lru);
 
+	list_for_each_entry_safe(page, next, pages, lru) {
 		prefetchw(&page->flags);
-		list_del(&page->lru);
-		if (!add_to_page_cache_lru(page, mapping,
+		if (!add_to_page_cache(page, mapping,
 					page->index, GFP_KERNEL)) {
 			bio = do_mpage_readpage(bio, page,
-					nr_pages - page_idx,
+					nr_pages,
 					&last_block_in_bio, &map_bh,
 					&first_logical_block,
 					get_block);
+			nr_added++;
+		} else {
+			list_del(&page->lru);
+			page_cache_release(page);
 		}
-		page_cache_release(page);
+		nr_pages--;
 	}
-	BUG_ON(!list_empty(pages));
+	BUG_ON(nr_pages);
+	lru_cache_add_list(pages, nr_added, LRU_INACTIVE_FILE);
 	if (bio)
 		mpage_bio_submit(READ, bio);
 	return 0;
diff --git a/include/linux/swap.h b/include/linux/swap.h
index 727bbe3..a4f6a84 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -212,6 +212,8 @@ extern void __lru_cache_add(struct page *, enum lru_list lru);
 extern void lru_cache_add_lru(struct page *, enum lru_list lru);
 extern void lru_add_page_tail(struct zone* zone,
 			      struct page *page, struct page *page_tail);
+extern void lru_cache_add_list(struct list_head *pages,
+			       int size, enum lru_list lru);
 extern void activate_page(struct page *);
 extern void mark_page_accessed(struct page *);
 extern void lru_add_drain(void);
diff --git a/mm/readahead.c b/mm/readahead.c
index cbcbb02..2f6fe4b 100644
--- a/mm/readahead.c
+++ b/mm/readahead.c
@@ -11,6 +11,7 @@
 #include <linux/fs.h>
 #include <linux/gfp.h>
 #include <linux/mm.h>
+#include <linux/swap.h>
 #include <linux/export.h>
 #include <linux/blkdev.h>
 #include <linux/backing-dev.h>
@@ -110,7 +111,7 @@ static int read_pages(struct address_space *mapping, struct file *filp,
 		struct list_head *pages, unsigned nr_pages)
 {
 	struct blk_plug plug;
-	unsigned page_idx;
+	struct page *page, *next;
 	int ret;
 
 	blk_start_plug(&plug);
@@ -122,15 +123,17 @@ static int read_pages(struct address_space *mapping, struct file *filp,
 		goto out;
 	}
 
-	for (page_idx = 0; page_idx < nr_pages; page_idx++) {
-		struct page *page = list_to_page(pages);
-		list_del(&page->lru);
-		if (!add_to_page_cache_lru(page, mapping,
+	list_for_each_entry_safe(page, next, pages, lru) {
+		if (!add_to_page_cache(page, mapping,
 					page->index, GFP_KERNEL)) {
 			mapping->a_ops->readpage(filp, page);
+		} else {
+			list_del(&page->lru);
+			page_cache_release(page);
+			nr_pages--;
 		}
-		page_cache_release(page);
 	}
+	lru_cache_add_list(pages, nr_pages, LRU_INACTIVE_FILE);
 	ret = 0;
 
 out:
diff --git a/mm/swap.c b/mm/swap.c
index 38b2686..2b8d376 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -36,7 +36,12 @@
 /* How many pages do we try to swap or page in/out together? */
 int page_cluster;
 
-static DEFINE_PER_CPU(struct pagevec[NR_LRU_LISTS], lru_add_pvecs);
+/* How many pages may be in per-cpu lru-add pending list */
+#define LRU_CACHE_ADD_BATCH	64
+
+static DEFINE_PER_CPU(struct list_head[NR_LRU_LISTS], lru_add_pages);
+static DEFINE_PER_CPU(int[NR_LRU_LISTS], lru_add_pending);
+
 static DEFINE_PER_CPU(struct pagevec, lru_rotate_pvecs);
 static DEFINE_PER_CPU(struct pagevec, lru_deactivate_pvecs);
 
@@ -371,14 +376,83 @@ void mark_page_accessed(struct page *page)
 }
 EXPORT_SYMBOL(mark_page_accessed);
 
+static void __lru_cache_add_list(struct list_head *pages, enum lru_list lru)
+{
+	int file = is_file_lru(lru);
+	int active = is_active_lru(lru);
+	struct page *page, *next;
+	struct zone *pagezone, *zone = NULL;
+	unsigned long uninitialized_var(flags);
+	LIST_HEAD(free_pages);
+
+	list_for_each_entry_safe(page, next, pages, lru) {
+		pagezone = page_zone(page);
+		if (pagezone != zone) {
+			if (zone)
+				spin_unlock_irqrestore(&zone->lru_lock, flags);
+			zone = pagezone;
+			spin_lock_irqsave(&zone->lru_lock, flags);
+		}
+		VM_BUG_ON(PageActive(page));
+		VM_BUG_ON(PageUnevictable(page));
+		VM_BUG_ON(PageLRU(page));
+		SetPageLRU(page);
+		if (active)
+			SetPageActive(page);
+		update_page_reclaim_stat(zone, page, file, active);
+		add_page_to_lru_list(zone, page, lru);
+		if (unlikely(put_page_testzero(page))) {
+			__ClearPageLRU(page);
+			__ClearPageActive(page);
+			del_page_from_lru_list(zone, page, lru);
+			if (unlikely(PageCompound(page))) {
+				spin_unlock_irqrestore(&zone->lru_lock, flags);
+				zone = NULL;
+				(*get_compound_page_dtor(page))(page);
+			} else
+				list_add_tail(&page->lru, &free_pages);
+		}
+	}
+	if (zone)
+		spin_unlock_irqrestore(&zone->lru_lock, flags);
+
+	free_hot_cold_page_list(&free_pages, 0);
+}
+
+/**
+ * lru_cache_add_list - add list of pages into lru, drop caller's page
+ *			references and reinitialize list.
+ * @pages	list of pages to adding
+ * @size	total size of pages in list
+ * @lru		the LRU list to which the page is added.
+ */
+void lru_cache_add_list(struct list_head *pages, int size, enum lru_list lru)
+{
+	struct list_head *list;
+
+	preempt_disable();
+	list = __this_cpu_ptr(lru_add_pages + lru);
+	list_splice_tail_init(pages, list);
+	if (likely(__this_cpu_add_return(lru_add_pending[lru], size) <=
+				LRU_CACHE_ADD_BATCH)) {
+		preempt_enable();
+		return;
+	}
+	list_replace_init(list, pages);
+	__this_cpu_write(lru_add_pending[lru], 0);
+	preempt_enable();
+	__lru_cache_add_list(pages, lru);
+	INIT_LIST_HEAD(pages);
+}
+EXPORT_SYMBOL(lru_cache_add_list);
+
 void __lru_cache_add(struct page *page, enum lru_list lru)
 {
-	struct pagevec *pvec = &get_cpu_var(lru_add_pvecs)[lru];
+	struct list_head pages = LIST_HEAD_INIT(page->lru);
+	int size = hpage_nr_pages(page);
 
 	page_cache_get(page);
-	if (!pagevec_add(pvec, page))
-		__pagevec_lru_add(pvec, lru);
-	put_cpu_var(lru_add_pvecs);
+	lru_cache_add_list(&pages, size, lru);
 }
 EXPORT_SYMBOL(__lru_cache_add);
 
@@ -498,14 +572,16 @@ static void lru_deactivate_fn(struct page *page, void *arg)
  */
 void lru_add_drain_cpu(int cpu)
 {
-	struct pagevec *pvecs = per_cpu(lru_add_pvecs, cpu);
+	struct list_head *pages = per_cpu(lru_add_pages, cpu);
 	struct pagevec *pvec;
 	int lru;
 
 	for_each_lru(lru) {
-		pvec = &pvecs[lru - LRU_BASE];
-		if (pagevec_count(pvec))
-			__pagevec_lru_add(pvec, lru);
+		if (!list_empty(pages + lru)) {
+			__lru_cache_add_list(pages + lru, lru);
+			INIT_LIST_HEAD(pages + lru);
+			per_cpu(lru_add_pending[lru], cpu) = 0;
+		}
 	}
 
 	pvec = &per_cpu(lru_rotate_pvecs, cpu);
@@ -765,6 +841,11 @@ EXPORT_SYMBOL(pagevec_lookup_tag);
 void __init swap_setup(void)
 {
 	unsigned long megs = totalram_pages >> (20 - PAGE_SHIFT);
+	int cpu, lru;
+
+	for_each_possible_cpu(cpu)
+		for_each_lru(lru)
+			INIT_LIST_HEAD(per_cpu(lru_add_pages, cpu) + lru);
 
 #ifdef CONFIG_SWAP
 	bdi_init(swapper_space.backing_dev_info);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
