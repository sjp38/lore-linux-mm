Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 805816B005D
	for <linux-mm@kvack.org>; Sat, 14 Apr 2018 10:13:35 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id v19so6476546pfn.7
        for <linux-mm@kvack.org>; Sat, 14 Apr 2018 07:13:35 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id e7-v6si7875031plk.397.2018.04.14.07.13.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sat, 14 Apr 2018 07:13:34 -0700 (PDT)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v11 63/63] radix tree: Remove radix_tree_clear_tags
Date: Sat, 14 Apr 2018 07:13:16 -0700
Message-Id: <20180414141316.7167-64-willy@infradead.org>
In-Reply-To: <20180414141316.7167-1-willy@infradead.org>
References: <20180414141316.7167-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>, Jan Kara <jack@suse.cz>, Jeff Layton <jlayton@redhat.com>, Lukas Czerner <lczerner@redhat.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Christoph Hellwig <hch@lst.de>, Goldwyn Rodrigues <rgoldwyn@suse.com>, Nicholas Piggin <npiggin@gmail.com>, Ryusuke Konishi <konishi.ryusuke@lab.ntt.co.jp>, linux-nilfs@vger.kernel.org, Jaegeuk Kim <jaegeuk@kernel.org>, Chao Yu <yuchao0@huawei.com>, linux-f2fs-devel@lists.sourceforge.net, Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>, Mike Kravetz <mike.kravetz@oracle.com>

From: Matthew Wilcox <mawilcox@microsoft.com>

The page cache was the only user of this interface and it has now
been converted to the XArray.  Transform the test into a test of
xas_init_tags().

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 include/linux/radix-tree.h           |  2 --
 lib/radix-tree.c                     | 13 -----------
 tools/testing/radix-tree/main.c      | 12 +++++------
 tools/testing/radix-tree/tag_check.c | 32 +++++++++++++---------------
 4 files changed, 21 insertions(+), 38 deletions(-)

diff --git a/include/linux/radix-tree.h b/include/linux/radix-tree.h
index ceff6856470a..3f778e3beba6 100644
--- a/include/linux/radix-tree.h
+++ b/include/linux/radix-tree.h
@@ -255,8 +255,6 @@ void radix_tree_iter_delete(struct radix_tree_root *,
 			struct radix_tree_iter *iter, void __rcu **slot);
 void *radix_tree_delete_item(struct radix_tree_root *, unsigned long, void *);
 void *radix_tree_delete(struct radix_tree_root *, unsigned long);
-void radix_tree_clear_tags(struct radix_tree_root *, struct radix_tree_node *,
-			   void __rcu **slot);
 unsigned int radix_tree_gang_lookup(const struct radix_tree_root *,
 			void **results, unsigned long first_index,
 			unsigned int max_items);
diff --git a/lib/radix-tree.c b/lib/radix-tree.c
index f15b9ee000b8..13a2eb2baddc 100644
--- a/lib/radix-tree.c
+++ b/lib/radix-tree.c
@@ -1709,19 +1709,6 @@ void *radix_tree_delete(struct radix_tree_root *root, unsigned long index)
 }
 EXPORT_SYMBOL(radix_tree_delete);
 
-void radix_tree_clear_tags(struct radix_tree_root *root,
-			   struct radix_tree_node *node,
-			   void __rcu **slot)
-{
-	if (node) {
-		unsigned int tag, offset = get_slot_offset(node, slot);
-		for (tag = 0; tag < RADIX_TREE_MAX_TAGS; tag++)
-			node_tag_clear(root, node, tag, offset);
-	} else {
-		root_tag_clear_all(root);
-	}
-}
-
 /**
  *	radix_tree_tagged - test whether any items in the tree are tagged
  *	@root:		radix tree root
diff --git a/tools/testing/radix-tree/main.c b/tools/testing/radix-tree/main.c
index 257f3f8aacaa..13987313311c 100644
--- a/tools/testing/radix-tree/main.c
+++ b/tools/testing/radix-tree/main.c
@@ -35,12 +35,12 @@ void __gang_check(unsigned long middle, long down, long up, int chunk, int hop)
 
 void gang_check(void)
 {
-	__gang_check(1 << 30, 128, 128, 35, 2);
-	__gang_check(1 << 31, 128, 128, 32, 32);
-	__gang_check(1 << 31, 128, 128, 32, 100);
-	__gang_check(1 << 31, 128, 128, 17, 7);
-	__gang_check(0xffff0000, 0, 65536, 17, 7);
-	__gang_check(0xfffffffe, 1, 1, 17, 7);
+	__gang_check(1UL << 30, 128, 128, 35, 2);
+	__gang_check(1UL << 31, 128, 128, 32, 32);
+	__gang_check(1UL << 31, 128, 128, 32, 100);
+	__gang_check(1UL << 31, 128, 128, 17, 7);
+	__gang_check(0xffff0000UL, 0, 65536, 17, 7);
+	__gang_check(0xfffffffeUL, 1, 1, 17, 7);
 }
 
 void __big_gang_check(void)
diff --git a/tools/testing/radix-tree/tag_check.c b/tools/testing/radix-tree/tag_check.c
index 543181e4847b..340bc4f72f34 100644
--- a/tools/testing/radix-tree/tag_check.c
+++ b/tools/testing/radix-tree/tag_check.c
@@ -331,29 +331,27 @@ static void single_check(void)
 	item_kill_tree(&tree);
 }
 
-void radix_tree_clear_tags_test(void)
+void init_tags_test(void)
 {
+	DEFINE_XARRAY(tree);
+	XA_STATE(xas, &tree, 0);
 	unsigned long index;
-	struct radix_tree_node *node;
-	struct radix_tree_iter iter;
-	void **slot;
+	void *entry;
 
-	RADIX_TREE(tree, GFP_KERNEL);
-
-	item_insert(&tree, 0);
-	item_tag_set(&tree, 0, 0);
-	__radix_tree_lookup(&tree, 0, &node, &slot);
-	radix_tree_clear_tags(&tree, node, slot);
-	assert(item_tag_get(&tree, 0, 0) == 0);
+	xa_store(&tree, 0, xa_mk_value(0), GFP_KERNEL);
+	item_tag_set(&tree, 0, XA_TAG_0);
+	xas_load(&xas);
+	xas_init_tags(&xas);
+	assert(item_tag_get(&tree, 0, XA_TAG_0) == 0);
 
 	for (index = 0; index < 1000; index++) {
-		item_insert(&tree, index);
-		item_tag_set(&tree, index, 0);
+		xa_store(&tree, index, xa_mk_value(index), GFP_KERNEL);
+		item_tag_set(&tree, index, XA_TAG_0);
 	}
 
-	radix_tree_for_each_slot(slot, &tree, &iter, 0) {
-		radix_tree_clear_tags(&tree, iter.node, slot);
-		assert(item_tag_get(&tree, iter.index, 0) == 0);
+	xas_for_each(&xas, entry, ULONG_MAX) {
+		xas_init_tags(&xas);
+		assert(item_tag_get(&tree, xas.xa_index, XA_TAG_0) == 0);
 	}
 
 	item_kill_tree(&tree);
@@ -376,5 +374,5 @@ void tag_check(void)
 	thrash_tags();
 	rcu_barrier();
 	printv(2, "after thrash_tags: %d allocated\n", nr_allocated);
-	radix_tree_clear_tags_test();
+	init_tags_test();
 }
-- 
2.17.0
