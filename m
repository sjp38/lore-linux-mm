Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 86AFA6B0267
	for <linux-mm@kvack.org>; Wed,  6 Apr 2016 17:28:05 -0400 (EDT)
Received: by mail-pa0-f52.google.com with SMTP id zm5so40597584pac.0
        for <linux-mm@kvack.org>; Wed, 06 Apr 2016 14:28:05 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTP id o68si6894186pfj.173.2016.04.06.14.21.53
        for <linux-mm@kvack.org>;
        Wed, 06 Apr 2016 14:21:53 -0700 (PDT)
From: Matthew Wilcox <willy@linux.intel.com>
Subject: [PATCH 13/30] radix-tree: Introduce radix_tree_load_root()
Date: Wed,  6 Apr 2016 17:21:22 -0400
Message-Id: <1459977699-2349-14-git-send-email-willy@linux.intel.com>
In-Reply-To: <1459977699-2349-1-git-send-email-willy@linux.intel.com>
References: <1459977699-2349-1-git-send-email-willy@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <willy@linux.intel.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Konstantin Khlebnikov <koct9i@gmail.com>, Kirill Shutemov <kirill.shutemov@linux.intel.com>, Jan Kara <jack@suse.com>, Neil Brown <neilb@suse.de>

All the tree walking functions start with some variant of this code;
centralise it in one place so we're not chasing subtly different bugs
everywhere.

Signed-off-by: Matthew Wilcox <willy@linux.intel.com>
Reviewed-by: Ross Zwisler <ross.zwisler@linux.intel.com>
---
 lib/radix-tree.c | 23 +++++++++++++++++++++++
 1 file changed, 23 insertions(+)

diff --git a/lib/radix-tree.c b/lib/radix-tree.c
index f2a314cf42cc..b3a7e6cd5773 100644
--- a/lib/radix-tree.c
+++ b/lib/radix-tree.c
@@ -405,6 +405,29 @@ static inline unsigned long radix_tree_maxindex(unsigned int height)
 	return height_to_maxindex[height];
 }
 
+static inline unsigned long node_maxindex(struct radix_tree_node *node)
+{
+	return radix_tree_maxindex(node->path & RADIX_TREE_HEIGHT_MASK);
+}
+
+static unsigned radix_tree_load_root(struct radix_tree_root *root,
+		struct radix_tree_node **nodep, unsigned long *maxindex)
+{
+	struct radix_tree_node *node = rcu_dereference_raw(root->rnode);
+
+	*nodep = node;
+
+	if (likely(radix_tree_is_indirect_ptr(node))) {
+		node = indirect_to_ptr(node);
+		*maxindex = node_maxindex(node);
+		return (node->path & RADIX_TREE_HEIGHT_MASK) *
+			RADIX_TREE_MAP_SHIFT;
+	}
+
+	*maxindex = 0;
+	return 0;
+}
+
 /*
  *	Extend a radix tree so it can store key @index.
  */
-- 
2.8.0.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
