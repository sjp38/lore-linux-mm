Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id EF01C8295A
	for <linux-mm@kvack.org>; Thu, 14 Apr 2016 10:37:58 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id dx6so50539639pad.0
        for <linux-mm@kvack.org>; Thu, 14 Apr 2016 07:37:58 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id u6si7775990pfa.186.2016.04.14.07.37.31
        for <linux-mm@kvack.org>;
        Thu, 14 Apr 2016 07:37:31 -0700 (PDT)
From: Matthew Wilcox <willy@linux.intel.com>
Subject: [PATCH 08/19] radix-tree: Rename INDIRECT_PTR to INTERNAL_NODE
Date: Thu, 14 Apr 2016 10:37:11 -0400
Message-Id: <1460644642-30642-9-git-send-email-willy@linux.intel.com>
In-Reply-To: <1460644642-30642-1-git-send-email-willy@linux.intel.com>
References: <1460644642-30642-1-git-send-email-willy@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <willy@linux.intel.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Konstantin Khlebnikov <koct9i@gmail.com>, Kirill Shutemov <kirill.shutemov@linux.intel.com>, Jan Kara <jack@suse.com>, Neil Brown <neilb@suse.de>, Ross Zwisler <ross.zwisler@linux.intel.com>

The name RADIX_TREE_INDIRECT_PTR doesn't really match the meaning.
RADIX_TREE_INTERNAL_NODE is a better name.

Signed-off-by: Matthew Wilcox <willy@linux.intel.com>
---
 include/linux/radix-tree.h | 30 +++++++++++++-----------------
 lib/radix-tree.c           |  2 +-
 2 files changed, 14 insertions(+), 18 deletions(-)

diff --git a/include/linux/radix-tree.h b/include/linux/radix-tree.h
index c0d223c..c8cc879 100644
--- a/include/linux/radix-tree.h
+++ b/include/linux/radix-tree.h
@@ -29,20 +29,16 @@
 #include <linux/rcupdate.h>
 
 /*
- * An indirect pointer (root->rnode pointing to a radix_tree_node, rather
- * than a data item) is signalled by the low bit set in the root->rnode
- * pointer.
- *
- * In this case root->height is > 0, but the indirect pointer tests are
- * needed for RCU lookups (because root->height is unreliable). The only
- * time callers need worry about this is when doing a lookup_slot under
- * RCU.
- *
- * Indirect pointer in fact is also used to tag the last pointer of a node
- * when it is shrunk, before we rcu free the node. See shrink code for
- * details.
+ * Entries in the radix tree have the low bit set if they refer to a
+ * radix_tree_node.  If the low bit is clear then the entry is user data.
+ *
+ * We also use the low bit to indicate that the slot will be freed in the
+ * next RCU idle period, and users need to re-walk the tree to find the
+ * new slot for the index that they were looking for.  See the comment in
+ * radix_tree_shrink() for details.
  */
-#define RADIX_TREE_INDIRECT_PTR		1
+#define RADIX_TREE_INTERNAL_NODE	1
+
 /*
  * A common use of the radix tree is to store pointers to struct pages;
  * but shmem/tmpfs needs also to store swap entries in the same tree:
@@ -63,7 +59,7 @@
 
 static inline int radix_tree_is_indirect_ptr(void *ptr)
 {
-	return (int)((unsigned long)ptr & RADIX_TREE_INDIRECT_PTR);
+	return (int)((unsigned long)ptr & RADIX_TREE_INTERNAL_NODE);
 }
 
 /*** radix-tree API starts here ***/
@@ -228,7 +224,7 @@ static inline void *radix_tree_deref_slot_protected(void **pslot,
  */
 static inline int radix_tree_deref_retry(void *arg)
 {
-	return unlikely((unsigned long)arg & RADIX_TREE_INDIRECT_PTR);
+	return unlikely(radix_tree_is_indirect_ptr(arg));
 }
 
 /**
@@ -250,7 +246,7 @@ static inline int radix_tree_exceptional_entry(void *arg)
 static inline int radix_tree_exception(void *arg)
 {
 	return unlikely((unsigned long)arg &
-		(RADIX_TREE_INDIRECT_PTR | RADIX_TREE_EXCEPTIONAL_ENTRY));
+		(RADIX_TREE_INTERNAL_NODE | RADIX_TREE_EXCEPTIONAL_ENTRY));
 }
 
 /**
@@ -448,7 +444,7 @@ radix_tree_chunk_size(struct radix_tree_iter *iter)
 
 static inline void *indirect_to_ptr(void *ptr)
 {
-	return (void *)((unsigned long)ptr & ~RADIX_TREE_INDIRECT_PTR);
+	return (void *)((unsigned long)ptr & ~RADIX_TREE_INTERNAL_NODE);
 }
 
 /**
diff --git a/lib/radix-tree.c b/lib/radix-tree.c
index 909527a..1fe546c 100644
--- a/lib/radix-tree.c
+++ b/lib/radix-tree.c
@@ -68,7 +68,7 @@ static DEFINE_PER_CPU(struct radix_tree_preload, radix_tree_preloads) = { 0, };
 
 static inline void *ptr_to_indirect(void *ptr)
 {
-	return (void *)((unsigned long)ptr | RADIX_TREE_INDIRECT_PTR);
+	return (void *)((unsigned long)ptr | RADIX_TREE_INTERNAL_NODE);
 }
 
 #define RADIX_TREE_RETRY	ptr_to_indirect(NULL)
-- 
2.8.0.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
