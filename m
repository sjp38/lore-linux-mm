Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9D4066B0277
	for <linux-mm@kvack.org>; Wed, 22 Nov 2017 16:08:20 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id h28so15483468pfh.16
        for <linux-mm@kvack.org>; Wed, 22 Nov 2017 13:08:20 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id 33si14352812plt.597.2017.11.22.13.08.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Nov 2017 13:08:19 -0800 (PST)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH 42/62] vmalloc: Convert to xarray
Date: Wed, 22 Nov 2017 13:07:19 -0800
Message-Id: <20171122210739.29916-43-willy@infradead.org>
In-Reply-To: <20171122210739.29916-1-willy@infradead.org>
References: <20171122210739.29916-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>

From: Matthew Wilcox <mawilcox@microsoft.com>

The radix tree of vmap blocks is simpler to express as an XArray.
Saves a couple of hundred bytes of text and eliminates a user of the
radix tree preload API.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 mm/vmalloc.c | 37 ++++++++++++-------------------------
 1 file changed, 12 insertions(+), 25 deletions(-)

diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index 673942094328..cc5de1ee6520 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -821,12 +821,11 @@ struct vmap_block {
 static DEFINE_PER_CPU(struct vmap_block_queue, vmap_block_queue);
 
 /*
- * Radix tree of vmap blocks, indexed by address, to quickly find a vmap block
+ * XArray of vmap blocks, indexed by address, to quickly find a vmap block
  * in the free path. Could get rid of this if we change the API to return a
  * "cookie" from alloc, to be passed to free. But no big deal yet.
  */
-static DEFINE_SPINLOCK(vmap_block_tree_lock);
-static RADIX_TREE(vmap_block_tree, GFP_ATOMIC);
+static DEFINE_XARRAY(vmap_block_tree);
 
 /*
  * We should probably have a fallback mechanism to allocate virtual memory
@@ -865,8 +864,8 @@ static void *new_vmap_block(unsigned int order, gfp_t gfp_mask)
 	struct vmap_block *vb;
 	struct vmap_area *va;
 	unsigned long vb_idx;
-	int node, err;
-	void *vaddr;
+	int node;
+	void *ret, *vaddr;
 
 	node = numa_node_id();
 
@@ -883,13 +882,6 @@ static void *new_vmap_block(unsigned int order, gfp_t gfp_mask)
 		return ERR_CAST(va);
 	}
 
-	err = radix_tree_preload(gfp_mask);
-	if (unlikely(err)) {
-		kfree(vb);
-		free_vmap_area(va);
-		return ERR_PTR(err);
-	}
-
 	vaddr = vmap_block_vaddr(va->va_start, 0);
 	spin_lock_init(&vb->lock);
 	vb->va = va;
@@ -902,11 +894,12 @@ static void *new_vmap_block(unsigned int order, gfp_t gfp_mask)
 	INIT_LIST_HEAD(&vb->free_list);
 
 	vb_idx = addr_to_vb_idx(va->va_start);
-	spin_lock(&vmap_block_tree_lock);
-	err = radix_tree_insert(&vmap_block_tree, vb_idx, vb);
-	spin_unlock(&vmap_block_tree_lock);
-	BUG_ON(err);
-	radix_tree_preload_end();
+	ret = xa_store(&vmap_block_tree, vb_idx, vb, gfp_mask);
+	if (IS_ERR(ret)) {
+		kfree(vb);
+		free_vmap_area(va);
+		return ret;
+	}
 
 	vbq = &get_cpu_var(vmap_block_queue);
 	spin_lock(&vbq->lock);
@@ -923,9 +916,7 @@ static void free_vmap_block(struct vmap_block *vb)
 	unsigned long vb_idx;
 
 	vb_idx = addr_to_vb_idx(vb->va->va_start);
-	spin_lock(&vmap_block_tree_lock);
-	tmp = radix_tree_delete(&vmap_block_tree, vb_idx);
-	spin_unlock(&vmap_block_tree_lock);
+	tmp = xa_store(&vmap_block_tree, vb_idx, NULL, GFP_NOWAIT);
 	BUG_ON(tmp != vb);
 
 	free_vmap_area_noflush(vb->va);
@@ -1031,7 +1022,6 @@ static void *vb_alloc(unsigned long size, gfp_t gfp_mask)
 static void vb_free(const void *addr, unsigned long size)
 {
 	unsigned long offset;
-	unsigned long vb_idx;
 	unsigned int order;
 	struct vmap_block *vb;
 
@@ -1045,10 +1035,7 @@ static void vb_free(const void *addr, unsigned long size)
 	offset = (unsigned long)addr & (VMAP_BLOCK_SIZE - 1);
 	offset >>= PAGE_SHIFT;
 
-	vb_idx = addr_to_vb_idx((unsigned long)addr);
-	rcu_read_lock();
-	vb = radix_tree_lookup(&vmap_block_tree, vb_idx);
-	rcu_read_unlock();
+	vb = xa_load(&vmap_block_tree, addr_to_vb_idx((unsigned long)addr));
 	BUG_ON(!vb);
 
 	vunmap_page_range((unsigned long)addr, (unsigned long)addr + size);
-- 
2.15.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
