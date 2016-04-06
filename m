Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f179.google.com (mail-pf0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 2FEDA6B0263
	for <linux-mm@kvack.org>; Wed,  6 Apr 2016 17:22:04 -0400 (EDT)
Received: by mail-pf0-f179.google.com with SMTP id e128so41076340pfe.3
        for <linux-mm@kvack.org>; Wed, 06 Apr 2016 14:22:04 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id yk5si6891850pab.160.2016.04.06.14.21.52
        for <linux-mm@kvack.org>;
        Wed, 06 Apr 2016 14:21:52 -0700 (PDT)
From: Matthew Wilcox <willy@linux.intel.com>
Subject: [PATCH 09/30] radix-tree: Add missing sibling entry functionality
Date: Wed,  6 Apr 2016 17:21:18 -0400
Message-Id: <1459977699-2349-10-git-send-email-willy@linux.intel.com>
In-Reply-To: <1459977699-2349-1-git-send-email-willy@linux.intel.com>
References: <1459977699-2349-1-git-send-email-willy@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <willy@linux.intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Konstantin Khlebnikov <koct9i@gmail.com>, Kirill Shutemov <kirill.shutemov@linux.intel.com>, Jan Kara <jack@suse.com>, Neil Brown <neilb@suse.de>

The code I previously added to enable multiorder radix tree entries was
untested and hence buggy.  This commit adds the support functions that
Ross and I decided were necessary over a four-week period of iterating
various designs.

Signed-off-by: Matthew Wilcox <willy@linux.intel.com>
Reviewed-by: Ross Zwisler <ross.zwisler@linux.intel.com>
---
 lib/radix-tree.c | 40 ++++++++++++++++++++++++++++++++++++++++
 1 file changed, 40 insertions(+)

diff --git a/lib/radix-tree.c b/lib/radix-tree.c
index ae53ad56e01e..40343f28a705 100644
--- a/lib/radix-tree.c
+++ b/lib/radix-tree.c
@@ -80,6 +80,46 @@ static inline void *indirect_to_ptr(void *ptr)
 	return (void *)((unsigned long)ptr & ~RADIX_TREE_INDIRECT_PTR);
 }
 
+#ifdef CONFIG_RADIX_TREE_MULTIORDER
+/* Sibling slots point directly to another slot in the same node */
+static inline bool is_sibling_entry(struct radix_tree_node *parent, void *node)
+{
+	void **ptr = node;
+	return (parent->slots <= ptr) &&
+			(ptr < parent->slots + RADIX_TREE_MAP_SIZE);
+}
+#else
+static inline bool is_sibling_entry(struct radix_tree_node *parent, void *node)
+{
+	return false;
+}
+#endif
+
+static inline unsigned get_sibling_offset(struct radix_tree_node *parent,
+						 void **slot)
+{
+	return slot - parent->slots;
+}
+
+static unsigned radix_tree_descend(struct radix_tree_node *parent,
+				struct radix_tree_node **nodep, unsigned offset)
+{
+	void **entry = rcu_dereference_raw(parent->slots[offset]);
+
+#ifdef CONFIG_RADIX_TREE_MULTIORDER
+	if (radix_tree_is_indirect_ptr(entry)) {
+		uintptr_t siboff = entry - parent->slots;
+		if (siboff < RADIX_TREE_MAP_SIZE) {
+			offset = siboff;
+			entry = rcu_dereference_raw(parent->slots[offset]);
+		}
+	}
+#endif
+
+	*nodep = (void *)entry;
+	return offset;
+}
+
 static inline gfp_t root_gfp_mask(struct radix_tree_root *root)
 {
 	return root->gfp_mask & __GFP_BITS_MASK;
-- 
2.8.0.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
