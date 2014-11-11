Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id 6E116900014
	for <linux-mm@kvack.org>; Tue, 11 Nov 2014 09:59:37 -0500 (EST)
Received: by mail-pa0-f44.google.com with SMTP id bj1so10855117pad.3
        for <linux-mm@kvack.org>; Tue, 11 Nov 2014 06:59:37 -0800 (PST)
Received: from mail-pd0-x22e.google.com (mail-pd0-x22e.google.com. [2607:f8b0:400e:c02::22e])
        by mx.google.com with ESMTPS id pu3si20213676pdb.150.2014.11.11.06.59.35
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 11 Nov 2014 06:59:35 -0800 (PST)
Received: by mail-pd0-f174.google.com with SMTP id p10so10255410pdj.33
        for <linux-mm@kvack.org>; Tue, 11 Nov 2014 06:59:35 -0800 (PST)
From: SeongJae Park <sj38.park@gmail.com>
Subject: [RFC v1 2/6] gcma: utilize reserved memory as swap cache
Date: Wed, 12 Nov 2014 00:00:06 +0900
Message-Id: <1415718010-18663-3-git-send-email-sj38.park@gmail.com>
In-Reply-To: <1415718010-18663-1-git-send-email-sj38.park@gmail.com>
References: <1415718010-18663-1-git-send-email-sj38.park@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: lauraa@codeaurora.org, minchan@kernel.org, sergey.senozhatsky@gmail.com, linux-mm@kvack.org, SeongJae Park <sj38.park@gmail.com>

GCMA reserves an amount of memory during boot and the memory space
should be always available for guest of that area. However, the guest
doesn't need it everytime so this patch makes the reserved memory as
swap cache via write-through frontswap for memory efficiency.

If the guest declares to need it sometime, we can discard all of swap
cache because every data should be on swap disk by write-through
frontswap. It makes allocation latency for the guest really small.

The drawback of the approach is that it could degrade system performance
due to earlier swapout by reserving if the user makes GCMA area big(e.g.,
1/3 of the system memory) and swap-cache hit ratio is low.
It's a trade-off for getting guaranteed low latency contiguous memory
allocation.

Signed-off-by: SeongJae Park <sj38.park@gmail.com>
---
 include/linux/gcma.h |   2 +-
 mm/gcma.c            | 330 ++++++++++++++++++++++++++++++++++++++++++++++++++-
 2 files changed, 330 insertions(+), 2 deletions(-)

diff --git a/include/linux/gcma.h b/include/linux/gcma.h
index 3016968..d733a9b 100644
--- a/include/linux/gcma.h
+++ b/include/linux/gcma.h
@@ -4,7 +4,7 @@
  * GCMA aims for contiguous memory allocation with success and fast
  * latency guarantee.
  * It reserves large amount of memory and let it be allocated to the
- * contiguous memory request.
+ * contiguous memory request and utilize them as swap cache.
  *
  * Copyright (C) 2014  LG Electronics Inc.,
  * Copyright (C) 2014  Minchan Kim <minchan@kernel.org>
diff --git a/mm/gcma.c b/mm/gcma.c
index 20a8473..ddfc0d8 100644
--- a/mm/gcma.c
+++ b/mm/gcma.c
@@ -4,7 +4,7 @@
  * GCMA aims for contiguous memory allocation with success and fast
  * latency guarantee.
  * It reserves large amount of memory and let it be allocated to the
- * contiguous memory request.
+ * contiguous memory request and utilize as swap cache using frontswap.
  *
  * Copyright (C) 2014  LG Electronics Inc.,
  * Copyright (C) 2014  Minchan Kim <minchan@kernel.org>
@@ -15,6 +15,7 @@
 
 #include <linux/module.h>
 #include <linux/slab.h>
+#include <linux/frontswap.h>
 #include <linux/highmem.h>
 #include <linux/gcma.h>
 
@@ -35,6 +36,42 @@ static struct gcma_info ginfo = {
 	.lock = __SPIN_LOCK_UNLOCKED(ginfo.lock),
 };
 
+struct swap_slot_entry {
+	struct gcma *gcma;
+	struct rb_node rbnode;
+	pgoff_t offset;
+	struct page *page;
+	atomic_t refcount;
+};
+
+struct frontswap_tree {
+	struct rb_root rbroot;
+	spinlock_t lock;
+};
+
+static struct frontswap_tree *gcma_swap_trees[MAX_SWAPFILES];
+static struct kmem_cache *swap_slot_entry_cache;
+
+static struct frontswap_tree *swap_tree(struct page *page)
+{
+	return (struct frontswap_tree *)page->mapping;
+}
+
+static void set_swap_tree(struct page *page, struct frontswap_tree *tree)
+{
+	page->mapping = (struct address_space *)tree;
+}
+
+static struct swap_slot_entry *swap_slot(struct page *page)
+{
+	return (struct swap_slot_entry *)page->index;
+}
+
+static void set_swap_slot(struct page *page, struct swap_slot_entry *slot)
+{
+	page->index = (pgoff_t)slot;
+}
+
 /*
  * gcma_init - initializes a contiguous memory area
  *
@@ -112,6 +149,286 @@ static void gcma_free_page(struct gcma *gcma, struct page *page)
 }
 
 /*
+ * In the case that a entry with the same offset is found, a pointer to
+ * the existing entry is stored in dupentry and the function returns -EEXIST.
+ */
+static int frontswap_rb_insert(struct rb_root *root,
+		struct swap_slot_entry *entry,
+		struct swap_slot_entry **dupentry)
+{
+	struct rb_node **link = &root->rb_node, *parent = NULL;
+	struct swap_slot_entry *myentry;
+
+	while (*link) {
+		parent = *link;
+		myentry = rb_entry(parent, struct swap_slot_entry, rbnode);
+		if (myentry->offset > entry->offset)
+			link = &(*link)->rb_left;
+		else if (myentry->offset < entry->offset)
+			link = &(*link)->rb_right;
+		else {
+			*dupentry = myentry;
+			return -EEXIST;
+		}
+	}
+	rb_link_node(&entry->rbnode, parent, link);
+	rb_insert_color(&entry->rbnode, root);
+	return 0;
+}
+
+static void frontswap_rb_erase(struct rb_root *root,
+		struct swap_slot_entry *entry)
+{
+	if (!RB_EMPTY_NODE(&entry->rbnode)) {
+		rb_erase(&entry->rbnode, root);
+		RB_CLEAR_NODE(&entry->rbnode);
+	}
+}
+
+static struct swap_slot_entry *frontswap_rb_search(struct rb_root *root,
+		pgoff_t offset)
+{
+	struct rb_node *node = root->rb_node;
+	struct swap_slot_entry *entry;
+
+	while (node) {
+		entry = rb_entry(node, struct swap_slot_entry, rbnode);
+		if (entry->offset > offset)
+			node = node->rb_left;
+		else if (entry->offset < offset)
+			node = node->rb_right;
+		else
+			return entry;
+	}
+	return NULL;
+}
+
+/* Allocates a page from gcma areas using round-robin way */
+static struct page *frontswap_alloc_page(struct gcma **res_gcma)
+{
+	struct page *page;
+	struct gcma *gcma;
+
+	spin_lock(&ginfo.lock);
+	gcma = list_first_entry(&ginfo.head, struct gcma, list);
+	list_move_tail(&gcma->list, &ginfo.head);
+
+	list_for_each_entry(gcma, &ginfo.head, list) {
+		page = gcma_alloc_page(gcma);
+		if (page) {
+			*res_gcma = gcma;
+			goto out;
+		}
+	}
+
+out:
+	spin_unlock(&ginfo.lock);
+	*res_gcma = gcma;
+	return page;
+}
+
+static void frontswap_free_entry(struct swap_slot_entry *entry)
+{
+	gcma_free_page(entry->gcma, entry->page);
+	kmem_cache_free(swap_slot_entry_cache, entry);
+}
+
+/* Caller should hold frontswap tree spinlock */
+static void swap_slot_entry_get(struct swap_slot_entry *entry)
+{
+	atomic_inc(&entry->refcount);
+}
+
+/*
+ * Caller should hold frontswap tree spinlock.
+ * Remove from the tree and free it, if nobody reference the entry.
+ */
+static void swap_slot_entry_put(struct frontswap_tree *tree,
+		struct swap_slot_entry *entry)
+{
+	int refcount = atomic_dec_return(&entry->refcount);
+
+	BUG_ON(refcount < 0);
+
+	if (refcount == 0) {
+		frontswap_rb_erase(&tree->rbroot, entry);
+		frontswap_free_entry(entry);
+	}
+}
+
+/* Caller should hold frontswap tree spinlock */
+static struct swap_slot_entry *frontswap_find_get(struct frontswap_tree *tree,
+						pgoff_t offset)
+{
+	struct swap_slot_entry *entry;
+	struct rb_root *root = &tree->rbroot;
+
+	assert_spin_locked(&tree->lock);
+	entry = frontswap_rb_search(root, offset);
+	if (entry)
+		swap_slot_entry_get(entry);
+
+	return entry;
+}
+
+void gcma_frontswap_init(unsigned type)
+{
+	struct frontswap_tree *tree;
+
+	tree = kzalloc(sizeof(struct frontswap_tree), GFP_KERNEL);
+	if (!tree) {
+		pr_warn("front swap tree for type %d failed to alloc\n", type);
+		return;
+	}
+
+	tree->rbroot = RB_ROOT;
+	spin_lock_init(&tree->lock);
+	gcma_swap_trees[type] = tree;
+}
+
+int gcma_frontswap_store(unsigned type, pgoff_t offset,
+				struct page *page)
+{
+	struct swap_slot_entry *entry, *dupentry;
+	struct gcma *gcma;
+	struct page *gcma_page = NULL;
+	struct frontswap_tree *tree = gcma_swap_trees[type];
+	u8 *src, *dst;
+	int ret;
+
+	if (!tree) {
+		WARN(1, "frontswap tree for type %d is not exist\n",
+				type);
+		return -ENODEV;
+	}
+
+	gcma_page = frontswap_alloc_page(&gcma);
+	if (!gcma_page)
+		return -ENOMEM;
+
+	entry = kmem_cache_alloc(swap_slot_entry_cache, GFP_NOIO);
+	if (!entry) {
+		gcma_free_page(gcma, gcma_page);
+		return -ENOMEM;
+	}
+
+	entry->gcma = gcma;
+	entry->page = gcma_page;
+	entry->offset = offset;
+	atomic_set(&entry->refcount, 1);
+	RB_CLEAR_NODE(&entry->rbnode);
+
+	set_swap_tree(gcma_page, tree);
+	set_swap_slot(gcma_page, entry);
+
+	/* copy from orig data to gcma-page */
+	src = kmap_atomic(page);
+	dst = kmap_atomic(gcma_page);
+	memcpy(dst, src, PAGE_SIZE);
+	kunmap_atomic(src);
+	kunmap_atomic(dst);
+
+	spin_lock(&tree->lock);
+	do {
+		/*
+		 * Though this duplication scenario may happen rarely by
+		 * race of swap layer, we handle this case here rather
+		 * than fix swap layer because handling the possibility of
+		 * duplicates is part of the tmem ABI.
+		 */
+		ret = frontswap_rb_insert(&tree->rbroot, entry, &dupentry);
+		if (ret == -EEXIST) {
+			frontswap_rb_erase(&tree->rbroot, dupentry);
+			swap_slot_entry_put(tree, dupentry);
+		}
+	} while (ret == -EEXIST);
+	spin_unlock(&tree->lock);
+
+	return ret;
+}
+
+/*
+ * Returns 0 if success,
+ * Returns non-zero if failed.
+ */
+int gcma_frontswap_load(unsigned type, pgoff_t offset,
+			       struct page *page)
+{
+	struct frontswap_tree *tree = gcma_swap_trees[type];
+	struct swap_slot_entry *entry;
+	struct page *gcma_page;
+	u8 *src, *dst;
+
+	if (!tree) {
+		WARN(1, "tree for type %d not exist\n", type);
+		return -1;
+	}
+
+	spin_lock(&tree->lock);
+	entry = frontswap_find_get(tree, offset);
+	spin_unlock(&tree->lock);
+	if (!entry)
+		return -1;
+
+	gcma_page = entry->page;
+	src = kmap_atomic(gcma_page);
+	dst = kmap_atomic(page);
+	memcpy(dst, src, PAGE_SIZE);
+	kunmap_atomic(src);
+	kunmap_atomic(dst);
+
+	spin_lock(&tree->lock);
+	swap_slot_entry_put(tree, entry);
+	spin_unlock(&tree->lock);
+
+	return 0;
+}
+
+void gcma_frontswap_invalidate_page(unsigned type, pgoff_t offset)
+{
+	struct frontswap_tree *tree = gcma_swap_trees[type];
+	struct swap_slot_entry *entry;
+
+	spin_lock(&tree->lock);
+	entry = frontswap_rb_search(&tree->rbroot, offset);
+	if (!entry) {
+		spin_unlock(&tree->lock);
+		return;
+	}
+
+	swap_slot_entry_put(tree, entry);
+	spin_unlock(&tree->lock);
+}
+
+void gcma_frontswap_invalidate_area(unsigned type)
+{
+	struct frontswap_tree *tree = gcma_swap_trees[type];
+	struct swap_slot_entry *entry, *n;
+
+	if (!tree)
+		return;
+
+	spin_lock(&tree->lock);
+	rbtree_postorder_for_each_entry_safe(entry, n, &tree->rbroot, rbnode) {
+		frontswap_rb_erase(&tree->rbroot, entry);
+		swap_slot_entry_put(tree, entry);
+	}
+	tree->rbroot = RB_ROOT;
+	spin_unlock(&tree->lock);
+
+	kfree(tree);
+	gcma_swap_trees[type] = NULL;
+}
+
+static struct frontswap_ops gcma_frontswap_ops = {
+	.init = gcma_frontswap_init,
+	.store = gcma_frontswap_store,
+	.load = gcma_frontswap_load,
+	.invalidate_page = gcma_frontswap_invalidate_page,
+	.invalidate_area = gcma_frontswap_invalidate_area
+};
+
+/*
  * gcma_alloc_contig - allocates contiguous pages
  *
  * @start_pfn	start pfn of requiring contiguous memory area
@@ -162,6 +479,17 @@ static int __init init_gcma(void)
 {
 	pr_info("loading gcma\n");
 
+	swap_slot_entry_cache = KMEM_CACHE(swap_slot_entry, 0);
+	if (swap_slot_entry_cache == NULL)
+		return -ENOMEM;
+
+	/*
+	 * By writethough mode, GCMA could discard all of pages in an instant
+	 * instead of slow writing pages out to the swap device.
+	 */
+	frontswap_writethrough(true);
+	frontswap_register_ops(&gcma_frontswap_ops);
+
 	return 0;
 }
 
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
