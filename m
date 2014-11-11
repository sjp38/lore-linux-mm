Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 6E198900014
	for <linux-mm@kvack.org>; Tue, 11 Nov 2014 09:59:40 -0500 (EST)
Received: by mail-pa0-f50.google.com with SMTP id eu11so10752274pac.37
        for <linux-mm@kvack.org>; Tue, 11 Nov 2014 06:59:40 -0800 (PST)
Received: from mail-pd0-x22f.google.com (mail-pd0-x22f.google.com. [2607:f8b0:400e:c02::22f])
        by mx.google.com with ESMTPS id kb15si62357pad.2.2014.11.11.06.59.38
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 11 Nov 2014 06:59:39 -0800 (PST)
Received: by mail-pd0-f175.google.com with SMTP id y13so10270609pdi.20
        for <linux-mm@kvack.org>; Tue, 11 Nov 2014 06:59:38 -0800 (PST)
From: SeongJae Park <sj38.park@gmail.com>
Subject: [RFC v1 3/6] gcma: evict frontswap pages in LRU order when memory is full
Date: Wed, 12 Nov 2014 00:00:07 +0900
Message-Id: <1415718010-18663-4-git-send-email-sj38.park@gmail.com>
In-Reply-To: <1415718010-18663-1-git-send-email-sj38.park@gmail.com>
References: <1415718010-18663-1-git-send-email-sj38.park@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: lauraa@codeaurora.org, minchan@kernel.org, sergey.senozhatsky@gmail.com, linux-mm@kvack.org, SeongJae Park <sj38.park@gmail.com>

GCMA uses free pages of the reserved space as swap cache so sometime we
ends up shortage of free space as time goes by and we should drain some
pages of swap cache for keeping new swapout pages in cache.
For it, GCMA manages swap cache in LRU order so we can keep active pages
in memory if possible. It could make swap-cache hit ratio high rather
than random evicting.

Signed-off-by: SeongJae Park <sj38.park@gmail.com>
---
 mm/gcma.c | 93 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++----
 1 file changed, 88 insertions(+), 5 deletions(-)

diff --git a/mm/gcma.c b/mm/gcma.c
index ddfc0d8..d459116 100644
--- a/mm/gcma.c
+++ b/mm/gcma.c
@@ -19,6 +19,9 @@
 #include <linux/highmem.h>
 #include <linux/gcma.h>
 
+/* XXX: What's the ideal? */
+#define NR_EVICT_BATCH	32
+
 struct gcma {
 	spinlock_t lock;
 	unsigned long *bitmap;
@@ -49,9 +52,13 @@ struct frontswap_tree {
 	spinlock_t lock;
 };
 
+static LIST_HEAD(slru_list);	/* LRU list of swap cache */
+static spinlock_t slru_lock;	/* protect slru_list */
 static struct frontswap_tree *gcma_swap_trees[MAX_SWAPFILES];
 static struct kmem_cache *swap_slot_entry_cache;
 
+static unsigned long evict_frontswap_pages(unsigned long nr_pages);
+
 static struct frontswap_tree *swap_tree(struct page *page)
 {
 	return (struct frontswap_tree *)page->mapping;
@@ -209,6 +216,7 @@ static struct page *frontswap_alloc_page(struct gcma **res_gcma)
 	struct page *page;
 	struct gcma *gcma;
 
+retry:
 	spin_lock(&ginfo.lock);
 	gcma = list_first_entry(&ginfo.head, struct gcma, list);
 	list_move_tail(&gcma->list, &ginfo.head);
@@ -216,13 +224,18 @@ static struct page *frontswap_alloc_page(struct gcma **res_gcma)
 	list_for_each_entry(gcma, &ginfo.head, list) {
 		page = gcma_alloc_page(gcma);
 		if (page) {
-			*res_gcma = gcma;
-			goto out;
+			spin_unlock(&ginfo.lock);
+			goto got;
 		}
 	}
-
-out:
 	spin_unlock(&ginfo.lock);
+
+	/* Failed to alloc a page from entire gcma. Evict adequate LRU
+	 * frontswap slots and try allocation again */
+	if (evict_frontswap_pages(NR_EVICT_BATCH))
+		goto retry;
+
+got:
 	*res_gcma = gcma;
 	return page;
 }
@@ -240,7 +253,7 @@ static void swap_slot_entry_get(struct swap_slot_entry *entry)
 }
 
 /*
- * Caller should hold frontswap tree spinlock.
+ * Caller should hold frontswap tree spinlock and slru_lock.
  * Remove from the tree and free it, if nobody reference the entry.
  */
 static void swap_slot_entry_put(struct frontswap_tree *tree,
@@ -251,11 +264,67 @@ static void swap_slot_entry_put(struct frontswap_tree *tree,
 	BUG_ON(refcount < 0);
 
 	if (refcount == 0) {
+		struct page *page = entry->page;
+
 		frontswap_rb_erase(&tree->rbroot, entry);
+		list_del(&page->lru);
+
 		frontswap_free_entry(entry);
 	}
 }
 
+/*
+ * evict_frontswap_pages - evict @nr_pages LRU frontswap backed pages
+ *
+ * @nr_pages	number of LRU pages to be evicted
+ *
+ * Returns number of successfully evicted pages
+ */
+static unsigned long evict_frontswap_pages(unsigned long nr_pages)
+{
+	struct frontswap_tree *tree;
+	struct swap_slot_entry *entry;
+	struct page *page, *n;
+	unsigned long evicted = 0;
+	LIST_HEAD(free_pages);
+
+	spin_lock(&slru_lock);
+	list_for_each_entry_safe_reverse(page, n, &slru_list, lru) {
+		entry = swap_slot(page);
+
+		/*
+		 * the entry could be free by other thread in the while.
+		 * check whether the situation occurred and avoid others to
+		 * free it by compare reference count and increase it
+		 * atomically.
+		 */
+		if (!atomic_inc_not_zero(&entry->refcount))
+			continue;
+
+		list_move(&page->lru, &free_pages);
+		if (++evicted >= nr_pages)
+			break;
+	}
+	spin_unlock(&slru_lock);
+
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
+	return evicted;
+}
+
 /* Caller should hold frontswap tree spinlock */
 static struct swap_slot_entry *frontswap_find_get(struct frontswap_tree *tree,
 						pgoff_t offset)
@@ -339,9 +408,15 @@ int gcma_frontswap_store(unsigned type, pgoff_t offset,
 		ret = frontswap_rb_insert(&tree->rbroot, entry, &dupentry);
 		if (ret == -EEXIST) {
 			frontswap_rb_erase(&tree->rbroot, dupentry);
+			spin_lock(&slru_lock);
 			swap_slot_entry_put(tree, dupentry);
+			spin_unlock(&slru_lock);
 		}
 	} while (ret == -EEXIST);
+
+	spin_lock(&slru_lock);
+	list_add(&gcma_page->lru, &slru_list);
+	spin_unlock(&slru_lock);
 	spin_unlock(&tree->lock);
 
 	return ret;
@@ -378,7 +453,10 @@ int gcma_frontswap_load(unsigned type, pgoff_t offset,
 	kunmap_atomic(dst);
 
 	spin_lock(&tree->lock);
+	spin_lock(&slru_lock);
+	list_move(&gcma_page->lru, &slru_list);
 	swap_slot_entry_put(tree, entry);
+	spin_unlock(&slru_lock);
 	spin_unlock(&tree->lock);
 
 	return 0;
@@ -396,7 +474,9 @@ void gcma_frontswap_invalidate_page(unsigned type, pgoff_t offset)
 		return;
 	}
 
+	spin_lock(&slru_lock);
 	swap_slot_entry_put(tree, entry);
+	spin_unlock(&slru_lock);
 	spin_unlock(&tree->lock);
 }
 
@@ -411,7 +491,9 @@ void gcma_frontswap_invalidate_area(unsigned type)
 	spin_lock(&tree->lock);
 	rbtree_postorder_for_each_entry_safe(entry, n, &tree->rbroot, rbnode) {
 		frontswap_rb_erase(&tree->rbroot, entry);
+		spin_lock(&slru_lock);
 		swap_slot_entry_put(tree, entry);
+		spin_unlock(&slru_lock);
 	}
 	tree->rbroot = RB_ROOT;
 	spin_unlock(&tree->lock);
@@ -479,6 +561,7 @@ static int __init init_gcma(void)
 {
 	pr_info("loading gcma\n");
 
+	spin_lock_init(&slru_lock);
 	swap_slot_entry_cache = KMEM_CACHE(swap_slot_entry, 0);
 	if (swap_slot_entry_cache == NULL)
 		return -ENOMEM;
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
