Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3B8D86B030B
	for <linux-mm@kvack.org>; Wed, 16 Nov 2016 17:35:20 -0500 (EST)
Received: by mail-it0-f70.google.com with SMTP id w132so76046938ita.1
        for <linux-mm@kvack.org>; Wed, 16 Nov 2016 14:35:20 -0800 (PST)
Received: from p3plsmtps2ded02.prod.phx3.secureserver.net (p3plsmtps2ded02.prod.phx3.secureserver.net. [208.109.80.59])
        by mx.google.com with ESMTPS id n188si6764099itb.65.2016.11.16.14.35.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Nov 2016 14:35:19 -0800 (PST)
From: Matthew Wilcox <mawilcox@linuxonhyperv.com>
Subject: [PATCH 15/29] radix-tree: Create node_tag_set()
Date: Wed, 16 Nov 2016 16:17:18 -0800
Message-Id: <1479341856-30320-54-git-send-email-mawilcox@linuxonhyperv.com>
In-Reply-To: <1479341856-30320-1-git-send-email-mawilcox@linuxonhyperv.com>
References: <1479341856-30320-1-git-send-email-mawilcox@linuxonhyperv.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Konstantin Khlebnikov <koct9i@gmail.com>, Ross Zwisler <ross.zwisler@linux.intel.com>
Cc: linux-fsdevel@vger.kernel.org, Matthew Wilcox <willy@linux.intel.com>, linux-mm@kvack.org, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>

From: Matthew Wilcox <willy@linux.intel.com>

Similar to node_tag_clear(), factor node_tag_set() out of
radix_tree_range_tag_if_tagged().

Signed-off-by: Matthew Wilcox <willy@linux.intel.com>
---
 lib/radix-tree.c | 41 +++++++++++++++++++----------------------
 1 file changed, 19 insertions(+), 22 deletions(-)

diff --git a/lib/radix-tree.c b/lib/radix-tree.c
index baf4ba1..bf1303f 100644
--- a/lib/radix-tree.c
+++ b/lib/radix-tree.c
@@ -1028,6 +1028,22 @@ static void node_tag_clear(struct radix_tree_root *root,
 		root_tag_clear(root, tag);
 }
 
+static void node_tag_set(struct radix_tree_root *root,
+				struct radix_tree_node *node,
+				unsigned int tag, unsigned int offset)
+{
+	while (node) {
+		if (tag_get(node, tag, offset))
+			return;
+		tag_set(node, tag, offset);
+		offset = node->offset;
+		node = node->parent;
+	}
+
+	if (!root_tag_get(root, tag))
+		root_tag_set(root, tag);
+}
+
 /**
  *	radix_tree_tag_clear - clear a tag on a radix tree node
  *	@root:		radix tree root
@@ -1268,7 +1284,7 @@ unsigned long radix_tree_range_tag_if_tagged(struct radix_tree_root *root,
 		unsigned long nr_to_tag,
 		unsigned int iftag, unsigned int settag)
 {
-	struct radix_tree_node *parent, *node, *child;
+	struct radix_tree_node *node, *child;
 	unsigned long maxindex;
 	unsigned long tagged = 0;
 	unsigned long index = *first_indexp;
@@ -1303,22 +1319,8 @@ unsigned long radix_tree_range_tag_if_tagged(struct radix_tree_root *root,
 			continue;
 		}
 
-		/* tag the leaf */
 		tagged++;
-		tag_set(node, settag, offset);
-
-		/* walk back up the path tagging interior nodes */
-		parent = node;
-		for (;;) {
-			offset = parent->offset;
-			parent = parent->parent;
-			if (!parent)
-				break;
-			/* stop if we find a node with the tag already set */
-			if (tag_get(parent, settag, offset))
-				break;
-			tag_set(parent, settag, offset);
-		}
+		node_tag_set(root, node, settag, offset);
  next:
 		/* Go to next entry in node */
 		index = ((index >> node->shift) + 1) << node->shift;
@@ -1340,12 +1342,7 @@ unsigned long radix_tree_range_tag_if_tagged(struct radix_tree_root *root,
 		if (tagged >= nr_to_tag)
 			break;
 	}
-	/*
-	 * We need not to tag the root tag if there is no tag which is set with
-	 * settag within the range from *first_indexp to last_index.
-	 */
-	if (tagged > 0)
-		root_tag_set(root, settag);
+
 	*first_indexp = index;
 
 	return tagged;
-- 
2.10.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
