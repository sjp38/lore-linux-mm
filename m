Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id 339746B0261
	for <linux-mm@kvack.org>; Fri, 12 Aug 2016 14:38:48 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id le9so5584205pab.0
        for <linux-mm@kvack.org>; Fri, 12 Aug 2016 11:38:48 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id k84si10104810pfa.56.2016.08.12.11.38.43
        for <linux-mm@kvack.org>;
        Fri, 12 Aug 2016 11:38:43 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv2 06/41] radix-tree: Handle multiorder entries being deleted by replace_clear_tags
Date: Fri, 12 Aug 2016 21:37:49 +0300
Message-Id: <1471027104-115213-7-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1471027104-115213-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1471027104-115213-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Theodore Ts'o <tytso@mit.edu>, Andreas Dilger <adilger.kernel@dilger.ca>, Jan Kara <jack@suse.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, Hugh Dickins <hughd@google.com>, Andrea Arcangeli <aarcange@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, Matthew Wilcox <willy@infradead.org>, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-ext4@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-block@vger.kernel.org, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>

From: Matthew Wilcox <willy@infradead.org>

radix_tree_replace_clear_tags() can be called with NULL as the replacement
value; in this case we need to delete sibling entries which point to
the slot.

Signed-off-by: Matthew Wilcox <willy@infradead.org>
Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 lib/radix-tree.c | 11 ++++++++++-
 1 file changed, 10 insertions(+), 1 deletion(-)

diff --git a/lib/radix-tree.c b/lib/radix-tree.c
index e49f32f7c537..89092c4011b8 100644
--- a/lib/radix-tree.c
+++ b/lib/radix-tree.c
@@ -1799,17 +1799,23 @@ void *radix_tree_delete(struct radix_tree_root *root, unsigned long index)
 }
 EXPORT_SYMBOL(radix_tree_delete);
 
+/*
+ * If the caller passes NULL for @entry, it must take care to adjust
+ * node->count.  See page_cache_tree_delete() for an example.
+ */
 struct radix_tree_node *radix_tree_replace_clear_tags(
 			struct radix_tree_root *root,
 			unsigned long index, void *entry)
 {
 	struct radix_tree_node *node;
 	void **slot;
+	unsigned int offset;
 
 	__radix_tree_lookup(root, index, &node, &slot);
 
 	if (node) {
-		unsigned int tag, offset = get_slot_offset(node, slot);
+		unsigned int tag;
+		offset = get_slot_offset(node, slot);
 		for (tag = 0; tag < RADIX_TREE_MAX_TAGS; tag++)
 			node_tag_clear(root, node, tag, offset);
 	} else {
@@ -1818,6 +1824,9 @@ struct radix_tree_node *radix_tree_replace_clear_tags(
 	}
 
 	radix_tree_replace_slot(slot, entry);
+	if (!entry && node)
+		delete_sibling_entries(node, node_to_entry(slot), offset);
+
 	return node;
 }
 
-- 
2.8.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
