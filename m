Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9AFAF6B0275
	for <linux-mm@kvack.org>; Thu, 14 Apr 2016 10:21:58 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id dx6so49966029pad.0
        for <linux-mm@kvack.org>; Thu, 14 Apr 2016 07:21:58 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id 128si12390657pfu.156.2016.04.14.07.21.57
        for <linux-mm@kvack.org>;
        Thu, 14 Apr 2016 07:21:57 -0700 (PDT)
From: Matthew Wilcox <willy@linux.intel.com>
Subject: [PATCH v2 08/29] Introduce CONFIG_RADIX_TREE_MULTIORDER
Date: Thu, 14 Apr 2016 10:16:29 -0400
Message-Id: <1460643410-30196-9-git-send-email-willy@linux.intel.com>
In-Reply-To: <1460643410-30196-1-git-send-email-willy@linux.intel.com>
References: <1460643410-30196-1-git-send-email-willy@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <willy@linux.intel.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Konstantin Khlebnikov <koct9i@gmail.com>, Kirill Shutemov <kirill.shutemov@linux.intel.com>, Jan Kara <jack@suse.com>, Neil Brown <neilb@suse.de>, Ross Zwisler <ross.zwisler@linux.intel.com>

I've been receiving increasingly concerned notes from 0day about how much
my recent changes have been bloating the radix tree.  Make it happier by
only including multiorder support if CONFIG_TRANSPARENT_HUGEPAGES is set.
This is an independent Kconfig option, so other radix tree users can
also set it if they have a need.

Signed-off-by: Matthew Wilcox <willy@linux.intel.com>
Reviewed-by: Ross Zwisler <ross.zwisler@linux.intel.com>
---
 lib/Kconfig                             |  3 +++
 lib/radix-tree.c                        | 26 ++++++++++++++++++--------
 mm/Kconfig                              |  1 +
 tools/testing/radix-tree/linux/kernel.h |  1 +
 4 files changed, 23 insertions(+), 8 deletions(-)

diff --git a/lib/Kconfig b/lib/Kconfig
index 3cca122..56403a6 100644
--- a/lib/Kconfig
+++ b/lib/Kconfig
@@ -362,6 +362,9 @@ config INTERVAL_TREE
 
 	  for more information.
 
+config RADIX_TREE_MULTIORDER
+	bool
+
 config ASSOCIATIVE_ARRAY
 	bool
 	help
diff --git a/lib/radix-tree.c b/lib/radix-tree.c
index 1624c41..799f341 100644
--- a/lib/radix-tree.c
+++ b/lib/radix-tree.c
@@ -484,6 +484,7 @@ int __radix_tree_create(struct radix_tree_root *root, unsigned long index,
 		slot = node->slots[offset];
 	}
 
+#ifdef CONFIG_RADIX_TREE_MULTIORDER
 	/* Insert pointers to the canonical entry */
 	if ((shift - order) > 0) {
 		int i, n = 1 << (shift - order);
@@ -499,6 +500,7 @@ int __radix_tree_create(struct radix_tree_root *root, unsigned long index,
 			node->count++;
 		}
 	}
+#endif
 
 	if (nodep)
 		*nodep = node;
@@ -1469,6 +1471,20 @@ bool __radix_tree_delete_node(struct radix_tree_root *root,
 	return deleted;
 }
 
+static inline void delete_sibling_entries(struct radix_tree_node *node,
+					void *ptr, unsigned offset)
+{
+#ifdef CONFIG_RADIX_TREE_MULTIORDER
+	int i;
+	for (i = 1; offset + i < RADIX_TREE_MAP_SIZE; i++) {
+		if (node->slots[offset + i] != ptr)
+			break;
+		node->slots[offset + i] = NULL;
+		node->count--;
+	}
+#endif
+}
+
 /**
  *	radix_tree_delete_item    -    delete an item from a radix tree
  *	@root:		radix tree root
@@ -1484,7 +1500,7 @@ void *radix_tree_delete_item(struct radix_tree_root *root,
 			     unsigned long index, void *item)
 {
 	struct radix_tree_node *node;
-	unsigned int offset, i;
+	unsigned int offset;
 	void **slot;
 	void *entry;
 	int tag;
@@ -1513,13 +1529,7 @@ void *radix_tree_delete_item(struct radix_tree_root *root,
 			radix_tree_tag_clear(root, index, tag);
 	}
 
-	/* Delete any sibling slots pointing to this slot */
-	for (i = 1; offset + i < RADIX_TREE_MAP_SIZE; i++) {
-		if (node->slots[offset + i] != ptr_to_indirect(slot))
-			break;
-		node->slots[offset + i] = NULL;
-		node->count--;
-	}
+	delete_sibling_entries(node, ptr_to_indirect(slot), offset);
 	node->slots[offset] = NULL;
 	node->count--;
 
diff --git a/mm/Kconfig b/mm/Kconfig
index 989f8f3..6d5b39e 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -393,6 +393,7 @@ config TRANSPARENT_HUGEPAGE
 	bool "Transparent Hugepage Support"
 	depends on HAVE_ARCH_TRANSPARENT_HUGEPAGE
 	select COMPACTION
+	select RADIX_TREE_MULTIORDER
 	help
 	  Transparent Hugepages allows the kernel to use huge pages and
 	  huge tlb transparently to the applications whenever possible.
diff --git a/tools/testing/radix-tree/linux/kernel.h b/tools/testing/radix-tree/linux/kernel.h
index 31fe2c77..8ea0ed4 100644
--- a/tools/testing/radix-tree/linux/kernel.h
+++ b/tools/testing/radix-tree/linux/kernel.h
@@ -9,6 +9,7 @@
 
 #include "../../include/linux/compiler.h"
 
+#define CONFIG_RADIX_TREE_MULTIORDER
 #define CONFIG_SHMEM
 #define CONFIG_SWAP
 
-- 
2.8.0.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
