Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id D26F86B0062
	for <linux-mm@kvack.org>; Sun, 17 May 2009 23:52:53 -0400 (EDT)
Received: by pxi37 with SMTP id 37so2355065pxi.12
        for <linux-mm@kvack.org>; Sun, 17 May 2009 20:53:42 -0700 (PDT)
From: Huang Shijie <shijie8@gmail.com>
Subject: [PATCH] lib : make radix_tree_delete() faster
Date: Mon, 18 May 2009 11:52:15 +0800
Message-Id: <1242618735-3588-1-git-send-email-root@localhost.localdomain>
In-Reply-To: <y>
References: <y>
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, Huang Shijie <shijie8@gmail.com>, zyzii@tom.com
List-ID: <linux-mm.kvack.org>

From: Huang Shijie <shijie8@gmail.com>

	radix_tree_delete() calls radix_tree_tag_clear() to
clear the tag along the path of  the index. The radix_tree_tag_clear()
will lookup and create the path which has been created by the
radix_tree_delete() already.

	I introduce radix_tree_tag_clear_path() to do the clear for the
path. The radix_tree_delete() calls radix_tree_tag_clear_path() instead of
radix_tree_tag_clear(), and this will save the CPU by
RADIX_TREE_MAX_TAGS*lookup.  This makes the radix_tree_delete() faster.

Signed-off-by: Huang Shijie <shijie8@gmail.com>
---
 lib/radix-tree.c |   30 +++++++++++++++++++++---------
 1 files changed, 21 insertions(+), 9 deletions(-)

diff --git a/lib/radix-tree.c b/lib/radix-tree.c
index 4bb42a0..f6430eb 100644
--- a/lib/radix-tree.c
+++ b/lib/radix-tree.c
@@ -495,6 +495,24 @@ void *radix_tree_tag_set(struct radix_tree_root *root,
 }
 EXPORT_SYMBOL(radix_tree_tag_set);
 
+/*
+ * Return 0 on succeeding to clear all the tag along the path,
+ * else return 1.
+ */
+static inline int radix_tree_tag_clear_path(struct radix_tree_path *pathp,
+			struct radix_tree_path *path_start, unsigned int tag)
+{
+	while (pathp->node && pathp > path_start) {
+		if (!tag_get(pathp->node, tag, pathp->offset))
+			return 1;
+		tag_clear(pathp->node, tag, pathp->offset);
+		if (any_tag_set(pathp->node, tag))
+			return 1;
+		pathp--;
+	}
+	return 0;
+}
+
 /**
  *	radix_tree_tag_clear - clear a tag on a radix tree node
  *	@root:		radix tree root
@@ -546,14 +564,8 @@ void *radix_tree_tag_clear(struct radix_tree_root *root,
 	if (slot == NULL)
 		goto out;
 
-	while (pathp->node) {
-		if (!tag_get(pathp->node, tag, pathp->offset))
-			goto out;
-		tag_clear(pathp->node, tag, pathp->offset);
-		if (any_tag_set(pathp->node, tag))
-			goto out;
-		pathp--;
-	}
+	if (radix_tree_tag_clear_path(pathp, path, tag))
+		goto out;
 
 	/* clear the root's tag bit */
 	if (root_tag_get(root, tag))
@@ -1134,7 +1146,7 @@ void *radix_tree_delete(struct radix_tree_root *root, unsigned long index)
 	 */
 	for (tag = 0; tag < RADIX_TREE_MAX_TAGS; tag++) {
 		if (tag_get(pathp->node, tag, pathp->offset))
-			radix_tree_tag_clear(root, index, tag);
+			radix_tree_tag_clear_path(pathp, path, tag);
 	}
 
 	to_free = NULL;
-- 
1.6.0.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
