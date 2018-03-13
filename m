Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id A56A86B000C
	for <linux-mm@kvack.org>; Tue, 13 Mar 2018 09:26:45 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id 73so7426858pfz.22
        for <linux-mm@kvack.org>; Tue, 13 Mar 2018 06:26:45 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id x7-v6si127384plw.740.2018.03.13.06.26.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 13 Mar 2018 06:26:44 -0700 (PDT)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v9 02/61] radix tree: Use GFP_ZONEMASK bits of gfp_t for flags
Date: Tue, 13 Mar 2018 06:25:40 -0700
Message-Id: <20180313132639.17387-3-willy@infradead.org>
In-Reply-To: <20180313132639.17387-1-willy@infradead.org>
References: <20180313132639.17387-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <mawilcox@microsoft.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Ryusuke Konishi <konishi.ryusuke@lab.ntt.co.jp>, linux-nilfs@vger.kernel.org

From: Matthew Wilcox <mawilcox@microsoft.com>

None of these bits may be used for slab allocations, so we can use them
as radix tree flags as long as we mask them off before passing them
to the slab allocator.  Move the IDR flag from the high bits to the
GFP_ZONEMASK bits.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
Acked-by: Jeff Layton <jlayton@kernel.org>
---
 include/linux/idr.h                  | 3 ++-
 include/linux/radix-tree.h           | 7 ++++---
 lib/radix-tree.c                     | 3 ++-
 tools/testing/radix-tree/linux/gfp.h | 1 +
 4 files changed, 9 insertions(+), 5 deletions(-)

diff --git a/include/linux/idr.h b/include/linux/idr.h
index 7d6a6313f0ab..913c335054f0 100644
--- a/include/linux/idr.h
+++ b/include/linux/idr.h
@@ -29,7 +29,8 @@ struct idr {
 #define IDR_FREE	0
 
 /* Set the IDR flag and the IDR_FREE tag */
-#define IDR_RT_MARKER		((__force gfp_t)(3 << __GFP_BITS_SHIFT))
+#define IDR_RT_MARKER	(ROOT_IS_IDR | (__force gfp_t)			\
+					(1 << (ROOT_TAG_SHIFT + IDR_FREE)))
 
 #define IDR_INIT_BASE(base) {						\
 	.idr_rt = RADIX_TREE_INIT(IDR_RT_MARKER),			\
diff --git a/include/linux/radix-tree.h b/include/linux/radix-tree.h
index fc55ff31eca7..6c4e2e716dac 100644
--- a/include/linux/radix-tree.h
+++ b/include/linux/radix-tree.h
@@ -104,9 +104,10 @@ struct radix_tree_node {
 	unsigned long	tags[RADIX_TREE_MAX_TAGS][RADIX_TREE_TAG_LONGS];
 };
 
-/* The top bits of gfp_mask are used to store the root tags and the IDR flag */
-#define ROOT_IS_IDR	((__force gfp_t)(1 << __GFP_BITS_SHIFT))
-#define ROOT_TAG_SHIFT	(__GFP_BITS_SHIFT + 1)
+/* The IDR tag is stored in the low bits of the GFP flags */
+#define ROOT_IS_IDR	((__force gfp_t)4)
+/* The top bits of gfp_mask are used to store the root tags */
+#define ROOT_TAG_SHIFT	(__GFP_BITS_SHIFT)
 
 struct radix_tree_root {
 	gfp_t			gfp_mask;
diff --git a/lib/radix-tree.c b/lib/radix-tree.c
index 8e00138d593f..da9e10c827df 100644
--- a/lib/radix-tree.c
+++ b/lib/radix-tree.c
@@ -146,7 +146,7 @@ static unsigned int radix_tree_descend(const struct radix_tree_node *parent,
 
 static inline gfp_t root_gfp_mask(const struct radix_tree_root *root)
 {
-	return root->gfp_mask & __GFP_BITS_MASK;
+	return root->gfp_mask & (__GFP_BITS_MASK & ~GFP_ZONEMASK);
 }
 
 static inline void tag_set(struct radix_tree_node *node, unsigned int tag,
@@ -2285,6 +2285,7 @@ void __init radix_tree_init(void)
 	int ret;
 
 	BUILD_BUG_ON(RADIX_TREE_MAX_TAGS + __GFP_BITS_SHIFT > 32);
+	BUILD_BUG_ON(ROOT_IS_IDR & ~GFP_ZONEMASK);
 	radix_tree_node_cachep = kmem_cache_create("radix_tree_node",
 			sizeof(struct radix_tree_node), 0,
 			SLAB_PANIC | SLAB_RECLAIM_ACCOUNT,
diff --git a/tools/testing/radix-tree/linux/gfp.h b/tools/testing/radix-tree/linux/gfp.h
index e3201ccf54c3..32159c08a52e 100644
--- a/tools/testing/radix-tree/linux/gfp.h
+++ b/tools/testing/radix-tree/linux/gfp.h
@@ -19,6 +19,7 @@
 
 #define __GFP_RECLAIM	(__GFP_DIRECT_RECLAIM|__GFP_KSWAPD_RECLAIM)
 
+#define GFP_ZONEMASK	0x0fu
 #define GFP_ATOMIC	(__GFP_HIGH|__GFP_ATOMIC|__GFP_KSWAPD_RECLAIM)
 #define GFP_KERNEL	(__GFP_RECLAIM | __GFP_IO | __GFP_FS)
 #define GFP_NOWAIT	(__GFP_KSWAPD_RECLAIM)
-- 
2.16.1
