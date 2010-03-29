Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 0875A6B01AC
	for <linux-mm@kvack.org>; Mon, 29 Mar 2010 10:57:42 -0400 (EDT)
Received: by qw-out-1920.google.com with SMTP id 4so3615908qwk.44
        for <linux-mm@kvack.org>; Mon, 29 Mar 2010 07:57:40 -0700 (PDT)
From: Bob Liu <lliubbo@gmail.com>
Subject: [RFC][PATCH] migrate_pages:skip migration between intersect nodes
Date: Mon, 29 Mar 2010 22:57:09 +0800
Message-Id: <1269874629-1736-1-git-send-email-lliubbo@gmail.com>
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, cl@linux-foundation.org, lee.schermerhorn@hp.com, andi@firstfloor.org, minchar.kim@gmail.com, Bob Liu <lliubbo@gmail.com>
List-ID: <linux-mm.kvack.org>

In current do_migrate_pages(),if from_nodes and to_nodes have some
intersect nodes,pages in these intersect nodes will also be
migrated.
eg. Assume that, from_nodes: 1,2,3,4 to_nodes: 2,3,4,5. Then these
migrates will happen:
migrate_pages(4,5);
migrate_pages(3,4);
migrate_pages(2,3);
migrate_pages(1,2);

But the user just want all pages in from_nodes move to to_nodes,
only migrate(1,2)(ignore the intersect nodes.) can satisfied 
the user's request.

I amn't sure what's migrate_page's semantic.
Hoping for your suggestions.

Signed-off-by: Bob Liu <lliubbo@gmail.com>
---
 mm/mempolicy.c |    7 ++-----
 1 files changed, 2 insertions(+), 5 deletions(-)

diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 08f40a2..c6dd931 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -922,7 +922,7 @@ int do_migrate_pages(struct mm_struct *mm,
 	 * moved to an empty node, then there is nothing left worth migrating.
 	 */
 
-	tmp = *from_nodes;
+	nodes_andnot(tmp, *from_nodes, *to_nodes);
 	while (!nodes_empty(tmp)) {
 		int s,d;
 		int source = -1;
@@ -935,10 +935,7 @@ int do_migrate_pages(struct mm_struct *mm,
 
 			source = s;	/* Node moved. Memorize */
 			dest = d;
-
-			/* dest not in remaining from nodes? */
-			if (!node_isset(dest, tmp))
-				break;
+			break;
 		}
 		if (source == -1)
 			break;
-- 
1.5.6.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
