Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id 419C6828F3
	for <linux-mm@kvack.org>; Thu, 14 Apr 2016 10:37:52 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id hb4so93404323pac.3
        for <linux-mm@kvack.org>; Thu, 14 Apr 2016 07:37:52 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id u6si7775990pfa.186.2016.04.14.07.37.32
        for <linux-mm@kvack.org>;
        Thu, 14 Apr 2016 07:37:33 -0700 (PDT)
From: Matthew Wilcox <willy@linux.intel.com>
Subject: [PATCH 19/19] radix-tree: Free up the bottom bit of exceptional entries for reuse
Date: Thu, 14 Apr 2016 10:37:22 -0400
Message-Id: <1460644642-30642-20-git-send-email-willy@linux.intel.com>
In-Reply-To: <1460644642-30642-1-git-send-email-willy@linux.intel.com>
References: <1460644642-30642-1-git-send-email-willy@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <willy@linux.intel.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Konstantin Khlebnikov <koct9i@gmail.com>, Kirill Shutemov <kirill.shutemov@linux.intel.com>, Jan Kara <jack@suse.com>, Neil Brown <neilb@suse.de>, Ross Zwisler <ross.zwisler@linux.intel.com>

We are guaranteed that pointers to radix_tree_nodes always have the
bottom two bits clear (because they come from a slab cache, and slab
caches have a minimum alignment of sizeof(void *)), so we can redefine
'radix_tree_is_internal_node' to only return true if the bottom two bits
have value '01'.  This frees up one quarter of the potential values
for use by the user.

Idea from Neil Brown <neilb@suse.de>

Signed-off-by: Matthew Wilcox <willy@linux.intel.com>
---
 include/linux/radix-tree.h | 38 +++++++++++++++++++++++---------------
 1 file changed, 23 insertions(+), 15 deletions(-)

diff --git a/include/linux/radix-tree.h b/include/linux/radix-tree.h
index c2f69e2..cb4b7e8 100644
--- a/include/linux/radix-tree.h
+++ b/include/linux/radix-tree.h
@@ -29,28 +29,37 @@
 #include <linux/rcupdate.h>
 
 /*
- * Entries in the radix tree have the low bit set if they refer to a
- * radix_tree_node.  If the low bit is clear then the entry is user data.
- *
- * We also use the low bit to indicate that the slot will be freed in the
- * next RCU idle period, and users need to re-walk the tree to find the
- * new slot for the index that they were looking for.  See the comment in
- * radix_tree_shrink() for details.
+ * The bottom two bits of the slot determine how the remaining bits in the
+ * slot are interpreted:
+ *
+ * 00 - data pointer
+ * 01 - internal entry
+ * 10 - exceptional entry
+ * 11 - locked exceptional entry
+ *
+ * The internal entry may be a pointer to the next level in the tree, a
+ * sibling entry, or an indicator that the entry in this slot has been moved
+ * to another location in the tree and the lookup should be restarted.  While
+ * NULL fits the 'data pointer' pattern, it means that there is no entry in
+ * the tree for this index (no matter what level of the tree it is found at).
+ * This means that you cannot store NULL in the tree as a value for the index.
  */
-#define RADIX_TREE_INTERNAL_NODE	1
+#define RADIX_TREE_ENTRY_MASK		3UL
+#define RADIX_TREE_INTERNAL_NODE	1UL
 
 /*
- * A common use of the radix tree is to store pointers to struct pages;
- * but shmem/tmpfs needs also to store swap entries in the same tree:
- * those are marked as exceptional entries to distinguish them.
+ * Most users of the radix tree store pointers but shmem/tmpfs stores swap
+ * entries in the same tree.  They are marked as exceptional entries to
+ * distinguish them from pointers to struct page.
  * EXCEPTIONAL_ENTRY tests the bit, EXCEPTIONAL_SHIFT shifts content past it.
  */
 #define RADIX_TREE_EXCEPTIONAL_ENTRY	2
 #define RADIX_TREE_EXCEPTIONAL_SHIFT	2
 
-static inline int radix_tree_is_internal_node(void *ptr)
+static inline bool radix_tree_is_internal_node(void *ptr)
 {
-	return (int)((unsigned long)ptr & RADIX_TREE_INTERNAL_NODE);
+	return ((unsigned long)ptr & RADIX_TREE_ENTRY_MASK) ==
+				RADIX_TREE_INTERNAL_NODE;
 }
 
 /*** radix-tree API starts here ***/
@@ -236,8 +245,7 @@ static inline int radix_tree_exceptional_entry(void *arg)
  */
 static inline int radix_tree_exception(void *arg)
 {
-	return unlikely((unsigned long)arg &
-		(RADIX_TREE_INTERNAL_NODE | RADIX_TREE_EXCEPTIONAL_ENTRY));
+	return unlikely((unsigned long)arg & RADIX_TREE_ENTRY_MASK);
 }
 
 /**
-- 
2.8.0.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
