Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5D3226B02AC
	for <linux-mm@kvack.org>; Mon, 11 Jun 2018 10:07:19 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id j25-v6so9229490pfi.9
        for <linux-mm@kvack.org>; Mon, 11 Jun 2018 07:07:19 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id o3-v6si63464941pld.50.2018.06.11.07.07.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 11 Jun 2018 07:07:18 -0700 (PDT)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v13 72/72] radix tree: Remove radix_tree_clear_tags
Date: Mon, 11 Jun 2018 07:06:39 -0700
Message-Id: <20180611140639.17215-73-willy@infradead.org>
In-Reply-To: <20180611140639.17215-1-willy@infradead.org>
References: <20180611140639.17215-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>, Jan Kara <jack@suse.cz>, Jeff Layton <jlayton@redhat.com>, Lukas Czerner <lczerner@redhat.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Christoph Hellwig <hch@lst.de>, Goldwyn Rodrigues <rgoldwyn@suse.com>, Nicholas Piggin <npiggin@gmail.com>, Ryusuke Konishi <konishi.ryusuke@lab.ntt.co.jp>, linux-nilfs@vger.kernel.org, Jaegeuk Kim <jaegeuk@kernel.org>, Chao Yu <yuchao0@huawei.com>, linux-f2fs-devel@lists.sourceforge.net

From: Matthew Wilcox <mawilcox@microsoft.com>

The page cache was the only user of this interface and it has now
been converted to the XArray.  Transform the test into a test of
xas_init_tags().

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 include/linux/radix-tree.h           |  2 --
 lib/radix-tree.c                     | 13 -----------
 tools/testing/radix-tree/tag_check.c | 32 +++++++++++++---------------
 3 files changed, 15 insertions(+), 32 deletions(-)

diff --git a/include/linux/radix-tree.h b/include/linux/radix-tree.h
index f8ef267e4975..27c15990951d 100644
--- a/include/linux/radix-tree.h
+++ b/include/linux/radix-tree.h
@@ -252,8 +252,6 @@ void radix_tree_iter_delete(struct radix_tree_root *,
 			struct radix_tree_iter *iter, void __rcu **slot);
 void *radix_tree_delete_item(struct radix_tree_root *, unsigned long, void *);
 void *radix_tree_delete(struct radix_tree_root *, unsigned long);
-void radix_tree_clear_tags(struct radix_tree_root *, struct radix_tree_node *,
-			   void __rcu **slot);
 unsigned int radix_tree_gang_lookup(const struct radix_tree_root *,
 			void **results, unsigned long first_index,
 			unsigned int max_items);
diff --git a/lib/radix-tree.c b/lib/radix-tree.c
index ad03dc0c562f..101f1c28e1b6 100644
--- a/lib/radix-tree.c
+++ b/lib/radix-tree.c
@@ -1711,19 +1711,6 @@ void *radix_tree_delete(struct radix_tree_root *root, unsigned long index)
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
2.17.1
