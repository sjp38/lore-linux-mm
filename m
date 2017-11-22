Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 00A8C6B0272
	for <linux-mm@kvack.org>; Wed, 22 Nov 2017 16:08:19 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id 4so17172169pge.8
        for <linux-mm@kvack.org>; Wed, 22 Nov 2017 13:08:18 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id i5si387958pgq.737.2017.11.22.13.08.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Nov 2017 13:08:17 -0800 (PST)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH 19/62] xarray: Define struct xa_node
Date: Wed, 22 Nov 2017 13:06:56 -0800
Message-Id: <20171122210739.29916-20-willy@infradead.org>
In-Reply-To: <20171122210739.29916-1-willy@infradead.org>
References: <20171122210739.29916-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>

From: Matthew Wilcox <mawilcox@microsoft.com>

This is a direct replacement for struct radix_tree_node.  Use a #define
so that radix tree users continue to work without change.

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 include/linux/radix-tree.h | 29 +++--------------------------
 include/linux/xarray.h     | 24 ++++++++++++++++++++++++
 2 files changed, 27 insertions(+), 26 deletions(-)

diff --git a/include/linux/radix-tree.h b/include/linux/radix-tree.h
index 015bc1bdc3d2..1da1fb01e993 100644
--- a/include/linux/radix-tree.h
+++ b/include/linux/radix-tree.h
@@ -32,6 +32,7 @@
 
 /* Keep unconverted code working */
 #define radix_tree_root		xarray
+#define radix_tree_node		xa_node
 
 /*
  * The bottom two bits of the slot determine how the remaining bits in the
@@ -60,41 +61,17 @@ static inline bool radix_tree_is_internal_node(void *ptr)
 
 /*** radix-tree API starts here ***/
 
-#define RADIX_TREE_MAX_TAGS 3
-
 #define RADIX_TREE_MAP_SHIFT	XA_CHUNK_SHIFT
 #define RADIX_TREE_MAP_SIZE	(1UL << RADIX_TREE_MAP_SHIFT)
 #define RADIX_TREE_MAP_MASK	(RADIX_TREE_MAP_SIZE-1)
 
-#define RADIX_TREE_TAG_LONGS	\
-	((RADIX_TREE_MAP_SIZE + BITS_PER_LONG - 1) / BITS_PER_LONG)
+#define RADIX_TREE_MAX_TAGS	XA_MAX_TAGS
+#define RADIX_TREE_TAG_LONGS	XA_TAG_LONGS
 
 #define RADIX_TREE_INDEX_BITS  (8 /* CHAR_BIT */ * sizeof(unsigned long))
 #define RADIX_TREE_MAX_PATH (DIV_ROUND_UP(RADIX_TREE_INDEX_BITS, \
 					  RADIX_TREE_MAP_SHIFT))
 
-/*
- * @count is the count of every non-NULL element in the ->slots array
- * whether that is a data entry, a retry entry, a user pointer,
- * a sibling entry or a pointer to the next level of the tree.
- * @exceptional is the count of every element in ->slots which is
- * either a data entry or a sibling entry for data.
- */
-struct radix_tree_node {
-	unsigned char	shift;		/* Bits remaining in each slot */
-	unsigned char	offset;		/* Slot offset in parent */
-	unsigned char	count;		/* Total entry count */
-	unsigned char	exceptional;	/* Exceptional entry count */
-	struct radix_tree_node *parent;		/* Used when ascending tree */
-	struct radix_tree_root *root;		/* The tree we belong to */
-	union {
-		struct list_head private_list;	/* For tree user */
-		struct rcu_head	rcu_head;	/* Used when freeing node */
-	};
-	void __rcu	*slots[RADIX_TREE_MAP_SIZE];
-	unsigned long	tags[RADIX_TREE_MAX_TAGS][RADIX_TREE_TAG_LONGS];
-};
-
 /* The top bits of xa_flags are used to store the root tags and the IDR flag */
 #define ROOT_IS_IDR	((__force gfp_t)(1 << __GFP_BITS_SHIFT))
 #define ROOT_TAG_SHIFT	(__GFP_BITS_SHIFT + 1)
diff --git a/include/linux/xarray.h b/include/linux/xarray.h
index 03d430ec3bce..1513a9e85580 100644
--- a/include/linux/xarray.h
+++ b/include/linux/xarray.h
@@ -143,6 +143,30 @@ static inline bool xa_is_value(void *entry)
 #endif
 #define XA_CHUNK_SIZE		(1UL << XA_CHUNK_SHIFT)
 #define XA_CHUNK_MASK		(XA_CHUNK_SIZE - 1)
+#define XA_MAX_TAGS		3
+#define XA_TAG_LONGS		DIV_ROUND_UP(XA_CHUNK_SIZE, BITS_PER_LONG)
+
+/*
+ * @count is the count of every non-NULL element in the ->slots array
+ * whether that is a data entry, a retry entry, a user pointer,
+ * a sibling entry or a pointer to the next level of the tree.
+ * @exceptional is the count of every element in ->slots which is
+ * either a data entry or a sibling entry for data.
+ */
+struct xa_node {
+	unsigned char	shift;		/* Bits remaining in each slot */
+	unsigned char	offset;		/* Slot offset in parent */
+	unsigned char	count;		/* Total entry count */
+	unsigned char	exceptional;	/* Exceptional entry count */
+	struct xa_node *parent;		/* Used when ascending tree */
+	struct xarray *	root;		/* The tree we belong to */
+	union {
+		struct list_head private_list;	/* For tree user */
+		struct rcu_head	rcu_head;	/* Used when freeing node */
+	};
+	void __rcu	*slots[XA_CHUNK_SIZE];
+	unsigned long	tags[XA_MAX_TAGS][XA_TAG_LONGS];
+};
 
 /*
  * Internal entries have the bottom two bits set to the value 10b.  Most
-- 
2.15.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
