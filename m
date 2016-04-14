Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id AEAE3828DF
	for <linux-mm@kvack.org>; Thu, 14 Apr 2016 10:17:49 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id u190so131315960pfb.0
        for <linux-mm@kvack.org>; Thu, 14 Apr 2016 07:17:49 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTP id 78si7713939pfq.236.2016.04.14.07.17.34
        for <linux-mm@kvack.org>;
        Thu, 14 Apr 2016 07:17:34 -0700 (PDT)
From: Matthew Wilcox <willy@linux.intel.com>
Subject: [PATCH v2 13/29] radix-tree: Introduce radix_tree_load_root()
Date: Thu, 14 Apr 2016 10:16:34 -0400
Message-Id: <1460643410-30196-14-git-send-email-willy@linux.intel.com>
In-Reply-To: <1460643410-30196-1-git-send-email-willy@linux.intel.com>
References: <1460643410-30196-1-git-send-email-willy@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <willy@linux.intel.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Konstantin Khlebnikov <koct9i@gmail.com>, Kirill Shutemov <kirill.shutemov@linux.intel.com>, Jan Kara <jack@suse.com>, Neil Brown <neilb@suse.de>, Ross Zwisler <ross.zwisler@linux.intel.com>

All the tree walking functions start with some variant of this code;
centralise it in one place so we're not chasing subtly different bugs
everywhere.

Signed-off-by: Matthew Wilcox <willy@linux.intel.com>
Reviewed-by: Ross Zwisler <ross.zwisler@linux.intel.com>
---
 lib/radix-tree.c | 23 +++++++++++++++++++++++
 1 file changed, 23 insertions(+)

diff --git a/lib/radix-tree.c b/lib/radix-tree.c
index 6900f7b..272ce81 100644
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
