Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id BBB268295A
	for <linux-mm@kvack.org>; Thu, 14 Apr 2016 10:38:06 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id u190so132306129pfb.0
        for <linux-mm@kvack.org>; Thu, 14 Apr 2016 07:38:06 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id e65si7776846pfd.212.2016.04.14.07.38.02
        for <linux-mm@kvack.org>;
        Thu, 14 Apr 2016 07:38:02 -0700 (PDT)
From: Matthew Wilcox <willy@linux.intel.com>
Subject: [PATCH 06/19] radix tree test suite: Remove dependencies on height
Date: Thu, 14 Apr 2016 10:37:09 -0400
Message-Id: <1460644642-30642-7-git-send-email-willy@linux.intel.com>
In-Reply-To: <1460644642-30642-1-git-send-email-willy@linux.intel.com>
References: <1460644642-30642-1-git-send-email-willy@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <willy@linux.intel.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Konstantin Khlebnikov <koct9i@gmail.com>, Kirill Shutemov <kirill.shutemov@linux.intel.com>, Jan Kara <jack@suse.com>, Neil Brown <neilb@suse.de>, Ross Zwisler <ross.zwisler@linux.intel.com>

verify_node() can use node->shift instead of the height.

tree_verify_min_height() can be converted over to using node_maxindex()
and shift_maxindex() instead of radix_tree_maxindex().

Signed-off-by: Matthew Wilcox <willy@linux.intel.com>
---
 tools/testing/radix-tree/test.c | 34 +++++++++++++++++++++++-----------
 tools/testing/radix-tree/test.h |  3 ++-
 2 files changed, 25 insertions(+), 12 deletions(-)

diff --git a/tools/testing/radix-tree/test.c b/tools/testing/radix-tree/test.c
index da54f11..3004c58 100644
--- a/tools/testing/radix-tree/test.c
+++ b/tools/testing/radix-tree/test.c
@@ -143,7 +143,7 @@ void item_full_scan(struct radix_tree_root *root, unsigned long start,
 }
 
 static int verify_node(struct radix_tree_node *slot, unsigned int tag,
-			unsigned int height, int tagged)
+			int tagged)
 {
 	int anyset = 0;
 	int i;
@@ -159,7 +159,8 @@ static int verify_node(struct radix_tree_node *slot, unsigned int tag,
 		}
 	}
 	if (tagged != anyset) {
-		printf("tag: %u, height %u, tagged: %d, anyset: %d\n", tag, height, tagged, anyset);
+		printf("tag: %u, shift %u, tagged: %d, anyset: %d\n",
+			tag, slot->shift, tagged, anyset);
 		for (j = 0; j < RADIX_TREE_MAX_TAGS; j++) {
 			printf("tag %d: ", j);
 			for (i = 0; i < RADIX_TREE_TAG_LONGS; i++)
@@ -171,10 +172,10 @@ static int verify_node(struct radix_tree_node *slot, unsigned int tag,
 	assert(tagged == anyset);
 
 	/* Go for next level */
-	if (height > 1) {
+	if (slot->shift > 0) {
 		for (i = 0; i < RADIX_TREE_MAP_SIZE; i++)
 			if (slot->slots[i])
-				if (verify_node(slot->slots[i], tag, height - 1,
+				if (verify_node(slot->slots[i], tag,
 					    !!test_bit(i, slot->tags[tag]))) {
 					printf("Failure at off %d\n", i);
 					for (j = 0; j < RADIX_TREE_MAX_TAGS; j++) {
@@ -191,9 +192,10 @@ static int verify_node(struct radix_tree_node *slot, unsigned int tag,
 
 void verify_tag_consistency(struct radix_tree_root *root, unsigned int tag)
 {
-	if (!root->height)
+	struct radix_tree_node *node = root->rnode;
+	if (!radix_tree_is_indirect_ptr(node))
 		return;
-	verify_node(root->rnode, tag, root->height, !!root_tag_get(root, tag));
+	verify_node(node, tag, !!root_tag_get(root, tag));
 }
 
 void item_kill_tree(struct radix_tree_root *root)
@@ -218,9 +220,19 @@ void item_kill_tree(struct radix_tree_root *root)
 
 void tree_verify_min_height(struct radix_tree_root *root, int maxindex)
 {
-	assert(radix_tree_maxindex(root->height) >= maxindex);
-	if (root->height > 1)
-		assert(radix_tree_maxindex(root->height-1) < maxindex);
-	else if (root->height == 1)
-		assert(radix_tree_maxindex(root->height-1) <= maxindex);
+	unsigned shift;
+	struct radix_tree_node *node = root->rnode;
+	if (!radix_tree_is_indirect_ptr(node)) {
+		assert(maxindex == 0);
+		return;
+	}
+
+	node = indirect_to_ptr(node);
+	assert(maxindex <= node_maxindex(node));
+
+	shift = node->shift;
+	if (shift > 0)
+		assert(maxindex > shift_maxindex(shift - RADIX_TREE_MAP_SHIFT));
+	else
+		assert(maxindex > 0);
 }
diff --git a/tools/testing/radix-tree/test.h b/tools/testing/radix-tree/test.h
index 67217c9..866c8c6 100644
--- a/tools/testing/radix-tree/test.h
+++ b/tools/testing/radix-tree/test.h
@@ -42,4 +42,5 @@ extern int nr_allocated;
 void *indirect_to_ptr(void *ptr);
 void radix_tree_dump(struct radix_tree_root *root);
 int root_tag_get(struct radix_tree_root *root, unsigned int tag);
-unsigned long radix_tree_maxindex(unsigned int height);
+unsigned long node_maxindex(struct radix_tree_node *);
+unsigned long shift_maxindex(unsigned int shift);
-- 
2.8.0.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
