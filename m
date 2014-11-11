Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id AB0DB900014
	for <linux-mm@kvack.org>; Tue, 11 Nov 2014 09:59:43 -0500 (EST)
Received: by mail-pd0-f177.google.com with SMTP id v10so10196645pde.36
        for <linux-mm@kvack.org>; Tue, 11 Nov 2014 06:59:43 -0800 (PST)
Received: from mail-pa0-x233.google.com (mail-pa0-x233.google.com. [2607:f8b0:400e:c03::233])
        by mx.google.com with ESMTPS id qa7si320587pac.91.2014.11.11.06.59.41
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 11 Nov 2014 06:59:42 -0800 (PST)
Received: by mail-pa0-f51.google.com with SMTP id kq14so10834502pab.10
        for <linux-mm@kvack.org>; Tue, 11 Nov 2014 06:59:41 -0800 (PST)
From: SeongJae Park <sj38.park@gmail.com>
Subject: [RFC v1 4/6] gcma: discard swap cache pages to meet successful GCMA allocation
Date: Wed, 12 Nov 2014 00:00:08 +0900
Message-Id: <1415718010-18663-5-git-send-email-sj38.park@gmail.com>
In-Reply-To: <1415718010-18663-1-git-send-email-sj38.park@gmail.com>
References: <1415718010-18663-1-git-send-email-sj38.park@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: lauraa@codeaurora.org, minchan@kernel.org, sergey.senozhatsky@gmail.com, linux-mm@kvack.org, SeongJae Park <sj38.park@gmail.com>

GCMA's goal is to allocate contiguous memory successfully anytime
as well as efficient usage of reserved memory space.

For memory efficiency, we allowed using reserved space as swap cache
so we should be able to drain those swap cache pages when GCMA user
want to get contiguos memory successfully, anytime.

We just discard swap caches pages if needed.
It's okay because we have used write-through mode of frontswap so
all of data should be on disk already.

Signed-off-by: SeongJae Park <sj38.park@gmail.com>
---
 mm/gcma.c | 192 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++----
 1 file changed, 181 insertions(+), 11 deletions(-)

diff --git a/mm/gcma.c b/mm/gcma.c
index d459116..9c07128 100644
--- a/mm/gcma.c
+++ b/mm/gcma.c
@@ -80,6 +80,50 @@ static void set_swap_slot(struct page *page, struct swap_slot_entry *slot)
 }
 
 /*
+ * Flags for status of a page in gcma
+ *
+ * GF_SWAP_LRU
+ * The page is being used for frontswap and hang on frontswap LRU list.
+ * It can be drained for contiguous memory allocation anytime.
+ * Protected by slru_lock.
+ *
+ * GF_RECLAIMING
+ * The page is being draining for contiguous memory allocation.
+ * Frontswap guests should not use it.
+ * Protected by slru_lock.
+ *
+ * GF_ISOLATED
+ * The page is isolated for contiguous memory allocation.
+ * GCMA guests can use the page safely while frontswap guests should not.
+ * Protected by gcma->lock.
+ */
+enum gpage_flags {
+	GF_SWAP_LRU = 0x1,
+	GF_RECLAIMING = 0x2,
+	GF_ISOLATED = 0x4,
+};
+
+static int gpage_flag(struct page *page, int flag)
+{
+	return page->private & flag;
+}
+
+static void set_gpage_flag(struct page *page, int flag)
+{
+	page->private |= flag;
+}
+
+static void clear_gpage_flag(struct page *page, int flag)
+{
+	page->private &= ~flag;
+}
+
+static void clear_gpage_flagall(struct page *page)
+{
+	page->private = 0;
+}
+
+/*
  * gcma_init - initializes a contiguous memory area
  *
  * @start_pfn	start pfn of contiguous memory area
@@ -137,11 +181,13 @@ static struct page *gcma_alloc_page(struct gcma *gcma)
 	bitmap_set(bitmap, bit, 1);
 	page = pfn_to_page(gcma->base_pfn + bit);
 	spin_unlock(&gcma->lock);
+	clear_gpage_flagall(page);
 
 out:
 	return page;
 }
 
+/* Caller should hold slru_lock */
 static void gcma_free_page(struct gcma *gcma, struct page *page)
 {
 	unsigned long pfn, offset;
@@ -151,7 +197,18 @@ static void gcma_free_page(struct gcma *gcma, struct page *page)
 	spin_lock(&gcma->lock);
 	offset = pfn - gcma->base_pfn;
 
-	bitmap_clear(gcma->bitmap, offset, 1);
+	if (likely(!gpage_flag(page, GF_RECLAIMING))) {
+		bitmap_clear(gcma->bitmap, offset, 1);
+	} else {
+		/*
+		 * The page should be safe to be used for a thread which
+		 * reclaimed the page.
+		 * To prevent further allocation from other thread,
+		 * set bitmap and mark the page as isolated.
+		 */
+		bitmap_set(gcma->bitmap, offset, 1);
+		set_gpage_flag(page, GF_ISOLATED);
+	}
 	spin_unlock(&gcma->lock);
 }
 
@@ -301,6 +358,7 @@ static unsigned long evict_frontswap_pages(unsigned long nr_pages)
 		if (!atomic_inc_not_zero(&entry->refcount))
 			continue;
 
+		clear_gpage_flag(page, GF_SWAP_LRU);
 		list_move(&page->lru, &free_pages);
 		if (++evicted >= nr_pages)
 			break;
@@ -377,7 +435,9 @@ int gcma_frontswap_store(unsigned type, pgoff_t offset,
 
 	entry = kmem_cache_alloc(swap_slot_entry_cache, GFP_NOIO);
 	if (!entry) {
+		spin_lock(&slru_lock);
 		gcma_free_page(gcma, gcma_page);
+		spin_unlock(&slru_lock);
 		return -ENOMEM;
 	}
 
@@ -415,6 +475,7 @@ int gcma_frontswap_store(unsigned type, pgoff_t offset,
 	} while (ret == -EEXIST);
 
 	spin_lock(&slru_lock);
+	set_gpage_flag(gcma_page, GF_SWAP_LRU);
 	list_add(&gcma_page->lru, &slru_list);
 	spin_unlock(&slru_lock);
 	spin_unlock(&tree->lock);
@@ -454,7 +515,8 @@ int gcma_frontswap_load(unsigned type, pgoff_t offset,
 
 	spin_lock(&tree->lock);
 	spin_lock(&slru_lock);
-	list_move(&gcma_page->lru, &slru_list);
+	if (likely(gpage_flag(gcma_page, GF_SWAP_LRU)))
+		list_move(&gcma_page->lru, &slru_list);
 	swap_slot_entry_put(tree, entry);
 	spin_unlock(&slru_lock);
 	spin_unlock(&tree->lock);
@@ -511,6 +573,43 @@ static struct frontswap_ops gcma_frontswap_ops = {
 };
 
 /*
+ * Return 0 if [start_pfn, end_pfn] is isolated.
+ * Otherwise, return first unisolated pfn from the start_pfn.
+ */
+static unsigned long isolate_interrupted(struct gcma *gcma,
+		unsigned long start_pfn, unsigned long end_pfn)
+{
+	unsigned long offset;
+	unsigned long *bitmap;
+	unsigned long pfn, ret = 0;
+	struct page *page;
+
+	spin_lock(&gcma->lock);
+
+	for (pfn = start_pfn; pfn < end_pfn; pfn++) {
+		int set;
+
+		offset = pfn - gcma->base_pfn;
+		bitmap = gcma->bitmap + offset / BITS_PER_LONG;
+
+		set = test_bit(pfn % BITS_PER_LONG, bitmap);
+		if (!set) {
+			ret = pfn;
+			break;
+		}
+
+		page = pfn_to_page(pfn);
+		if (!gpage_flag(page, GF_ISOLATED)) {
+			ret = pfn;
+			break;
+		}
+
+	}
+	spin_unlock(&gcma->lock);
+	return ret;
+}
+
+/*
  * gcma_alloc_contig - allocates contiguous pages
  *
  * @start_pfn	start pfn of requiring contiguous memory area
@@ -521,21 +620,92 @@ static struct frontswap_ops gcma_frontswap_ops = {
 int gcma_alloc_contig(struct gcma *gcma, unsigned long start_pfn,
 			unsigned long size)
 {
+	LIST_HEAD(free_pages);
+	struct page *page, *n;
+	struct swap_slot_entry *entry;
 	unsigned long offset;
+	unsigned long *bitmap;
+	struct frontswap_tree *tree;
+	unsigned long pfn;
+	unsigned long orig_start = start_pfn;
 
-	spin_lock(&gcma->lock);
-	offset = start_pfn - gcma->base_pfn;
+retry:
+	for (pfn = start_pfn; pfn < start_pfn + size; pfn++) {
+		spin_lock(&gcma->lock);
+
+		offset = pfn - gcma->base_pfn;
+		bitmap = gcma->bitmap + offset / BITS_PER_LONG;
+		page = pfn_to_page(pfn);
+
+		if (!test_bit(offset % BITS_PER_LONG, bitmap)) {
+			/* set a bit for prevent allocation for frontswap */
+			bitmap_set(gcma->bitmap, offset, 1);
+			set_gpage_flag(page, GF_ISOLATED);
+			spin_unlock(&gcma->lock);
+			continue;
+		}
+
+		/* Someone is using the page so it's complicated :( */
+		spin_unlock(&gcma->lock);
+		spin_lock(&slru_lock);
+		/*
+		 * If the page is in LRU, we can get swap_slot_entry from
+		 * the page with no problem.
+		 */
+		if (gpage_flag(page, GF_SWAP_LRU)) {
+			BUG_ON(gpage_flag(page, GF_RECLAIMING));
+
+			entry = swap_slot(page);
+			if (atomic_inc_not_zero(&entry->refcount)) {
+				clear_gpage_flag(page, GF_SWAP_LRU);
+				set_gpage_flag(page, GF_RECLAIMING);
+				list_move(&page->lru, &free_pages);
+				spin_unlock(&slru_lock);
+				continue;
+			}
+		}
 
-	if (bitmap_find_next_zero_area(gcma->bitmap, gcma->size, offset,
-				size, 0) != 0) {
+		/*
+		 * Someone is allocating the page but it's not yet in LRU
+		 * in case of frontswap_store or it was deleted from LRU
+		 * but not yet from gcma's bitmap in case of
+		 * frontswap_invalidate. Anycase, the race is small so retry
+		 * after a while will see success. Below isolate_interrupted
+		 * handles it.
+		 */
+		spin_lock(&gcma->lock);
+		if (!test_bit(offset % BITS_PER_LONG, bitmap)) {
+			bitmap_set(gcma->bitmap, offset, 1);
+			set_gpage_flag(page, GF_ISOLATED);
+		} else {
+			set_gpage_flag(page, GF_RECLAIMING);
+		}
 		spin_unlock(&gcma->lock);
-		pr_warn("already allocated region required: %lu, %lu",
-				start_pfn, size);
-		return -EINVAL;
+		spin_unlock(&slru_lock);
 	}
 
-	bitmap_set(gcma->bitmap, offset, size);
-	spin_unlock(&gcma->lock);
+	/*
+	 * Since we increased refcount of the page above, we can access
+	 * swap_slot_entry with safe
+	 */
+	list_for_each_entry_safe(page, n, &free_pages, lru) {
+		tree = swap_tree(page);
+		entry = swap_slot(page);
+
+		spin_lock(&tree->lock);
+		spin_lock(&slru_lock);
+		/* drop refcount increased by above loop */
+		swap_slot_entry_put(tree, entry);
+		/* free entry if the entry is still in tree */
+		if (frontswap_rb_search(&tree->rbroot, entry->offset))
+			swap_slot_entry_put(tree, entry);
+		spin_unlock(&slru_lock);
+		spin_unlock(&tree->lock);
+	}
+
+	start_pfn = isolate_interrupted(gcma, orig_start, orig_start + size);
+	if (start_pfn)
+		goto retry;
 
 	return 0;
 }
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
