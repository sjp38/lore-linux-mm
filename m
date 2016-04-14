Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id DE00A828DF
	for <linux-mm@kvack.org>; Thu, 14 Apr 2016 10:18:27 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id c20so131054947pfc.2
        for <linux-mm@kvack.org>; Thu, 14 Apr 2016 07:18:27 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id uk4si9817724pab.234.2016.04.14.07.18.26
        for <linux-mm@kvack.org>;
        Thu, 14 Apr 2016 07:18:27 -0700 (PDT)
From: Matthew Wilcox <willy@linux.intel.com>
Subject: [PATCH v2 09/29] radix-tree: Add missing sibling entry functionality
Date: Thu, 14 Apr 2016 10:16:30 -0400
Message-Id: <1460643410-30196-10-git-send-email-willy@linux.intel.com>
In-Reply-To: <1460643410-30196-1-git-send-email-willy@linux.intel.com>
References: <1460643410-30196-1-git-send-email-willy@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <willy@linux.intel.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Konstantin Khlebnikov <koct9i@gmail.com>, Kirill Shutemov <kirill.shutemov@linux.intel.com>, Jan Kara <jack@suse.com>, Neil Brown <neilb@suse.de>, Ross Zwisler <ross.zwisler@linux.intel.com>

The code I previously added to enable multiorder radix tree entries was
untested and therefore buggy.  This commit adds the support functions that
Ross and I decided were necessary over a four-week period of iterating
various designs.

Signed-off-by: Matthew Wilcox <willy@linux.intel.com>
Reviewed-by: Ross Zwisler <ross.zwisler@linux.intel.com>
---
 lib/radix-tree.c | 40 ++++++++++++++++++++++++++++++++++++++++
 1 file changed, 40 insertions(+)

diff --git a/lib/radix-tree.c b/lib/radix-tree.c
index 799f341..585965a 100644
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
+static inline unsigned long get_slot_offset(struct radix_tree_node *parent,
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
+		unsigned long siboff = get_slot_offset(parent, entry);
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
