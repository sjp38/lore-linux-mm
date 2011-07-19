Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 84CE96B00F8
	for <linux-mm@kvack.org>; Tue, 19 Jul 2011 18:53:10 -0400 (EDT)
Received: from hpaq5.eem.corp.google.com (hpaq5.eem.corp.google.com [172.25.149.5])
	by smtp-out.google.com with ESMTP id p6JMr7Cd026745
	for <linux-mm@kvack.org>; Tue, 19 Jul 2011 15:53:08 -0700
Received: from iyb26 (iyb26.prod.google.com [10.241.49.90])
	by hpaq5.eem.corp.google.com with ESMTP id p6JMr5Ys003601
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 19 Jul 2011 15:53:06 -0700
Received: by iyb26 with SMTP id 26so5032321iyb.37
        for <linux-mm@kvack.org>; Tue, 19 Jul 2011 15:53:05 -0700 (PDT)
Date: Tue, 19 Jul 2011 15:52:52 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH 1/3] radix_tree: clean away saw_unset_tag leftovers
In-Reply-To: <alpine.LSU.2.00.1107191549540.1593@sister.anvils>
Message-ID: <alpine.LSU.2.00.1107191551340.1593@sister.anvils>
References: <alpine.LSU.2.00.1107191549540.1593@sister.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

radix_tree_tag_get()'s BUG (when it sees a tag after saw_unset_tag) was
unsafe and removed in 2.6.34, but the pointless saw_unset_tag left behind.

Remove it now, and return 0 as soon as we see unset tag - we already rely
upon the root tag to be correct, returning 0 immediately if it's not set.

Signed-off-by: Hugh Dickins <hughd@google.com>
---
 lib/radix-tree.c |   10 ++--------
 1 file changed, 2 insertions(+), 8 deletions(-)

--- mmotm.orig/lib/radix-tree.c	2011-07-08 18:57:14.810702665 -0700
+++ mmotm/lib/radix-tree.c	2011-07-19 11:11:21.285234139 -0700
@@ -576,7 +576,6 @@ int radix_tree_tag_get(struct radix_tree
 {
 	unsigned int height, shift;
 	struct radix_tree_node *node;
-	int saw_unset_tag = 0;
 
 	/* check the root's tag bit */
 	if (!root_tag_get(root, tag))
@@ -603,15 +602,10 @@ int radix_tree_tag_get(struct radix_tree
 			return 0;
 
 		offset = (index >> shift) & RADIX_TREE_MAP_MASK;
-
-		/*
-		 * This is just a debug check.  Later, we can bale as soon as
-		 * we see an unset tag.
-		 */
 		if (!tag_get(node, tag, offset))
-			saw_unset_tag = 1;
+			return 0;
 		if (height == 1)
-			return !!tag_get(node, tag, offset);
+			return 1;
 		node = rcu_dereference_raw(node->slots[offset]);
 		shift -= RADIX_TREE_MAP_SHIFT;
 		height--;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
