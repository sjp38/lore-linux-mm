Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e3.ny.us.ibm.com (8.12.10/8.12.9) with ESMTP id iAAL3lW7675584
	for <linux-mm@kvack.org>; Wed, 10 Nov 2004 16:03:47 -0500
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay04.pok.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id iAAL3he0279924
	for <linux-mm@kvack.org>; Wed, 10 Nov 2004 16:03:47 -0500
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11/8.12.11) with ESMTP id iAAL3hU7030898
	for <linux-mm@kvack.org>; Wed, 10 Nov 2004 16:03:43 -0500
Subject: [PATCH] bug in radix_tree_delete
From: Dave Kleikamp <shaggy@austin.ibm.com>
Content-Type: text/plain
Message-Id: <1100120622.7468.16.camel@localhost>
Mime-Version: 1.0
Date: Wed, 10 Nov 2004 15:03:42 -0600
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

I was looking through the radix tree code and came across what I think
is a bug in radix_tree_delete.

	for (idx = 0; idx < RADIX_TREE_TAG_LONGS; idx++) {
		if (pathp[0].node->tags[tag][idx]) {
			tags[tag] = 1;
			nr_cleared_tags--;
			break;
		}
	}

The above loop should only be executed if tags[tag] is zero.  Otherwise,
when walking up the tree, we can decrement nr_cleared_tags twice or more
for the same value of tag, thus potentially exiting the outer loop too
early.

radix-tree: Ensure that nr_cleared_tags is only decremented once for each tag.

Signed-off-by: Dave Kleikamp <shaggy@austin.ibm.com>
diff -Nurp linux-2.6.10-rc1-mm4/lib/radix-tree.c linux/lib/radix-tree.c
--- linux-2.6.10-rc1-mm4/lib/radix-tree.c	2004-11-10 14:45:18.259269000 -0600
+++ linux/lib/radix-tree.c	2004-11-10 14:45:59.292031072 -0600
@@ -725,8 +725,10 @@ void *radix_tree_delete(struct radix_tre
 		for (tag = 0; tag < RADIX_TREE_TAGS; tag++) {
 			int idx;
 
-			if (!tags[tag])
-				tag_clear(pathp[0].node, tag, pathp[0].offset);
+			if (tags[tag])
+				continue;
+
+			tag_clear(pathp[0].node, tag, pathp[0].offset);
 
 			for (idx = 0; idx < RADIX_TREE_TAG_LONGS; idx++) {
 				if (pathp[0].node->tags[tag][idx]) {


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
