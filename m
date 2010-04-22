Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 820A76B01F1
	for <linux-mm@kvack.org>; Thu, 22 Apr 2010 10:13:14 -0400 (EDT)
Message-ID: <4BD05929.8040900@cn.fujitsu.com>
Date: Thu, 22 Apr 2010 22:11:53 +0800
From: Miao Xie <miaox@cn.fujitsu.com>
Reply-To: miaox@cn.fujitsu.com
MIME-Version: 1.0
Subject: [PATCH 1/2] mm: fix bugs of mpol_rebind_nodemask()
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: David Rientjes <rientjes@google.com>, Lee Schermerhorn <lee.schermerhorn@hp.com>, Nick Piggin <npiggin@suse.de>, Paul Menage <menage@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

- local variable might be an empty nodemask, so must be checked before setting
  pol->v.nodes to it.

- nodes_remap() may cause the weight of pol->v.nodes being monotonic decreasing.
  and never become large even we pass a nodemask with large weight after
  ->v.nodes become little.

this patch fixes these two problem.

Signed-off-by: Miao Xie <miaox@cn.fujitsu.com>
---
 mm/mempolicy.c |    9 ++++++---
 1 files changed, 6 insertions(+), 3 deletions(-)

diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 08f40a2..03ba9fc 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -291,12 +291,15 @@ static void mpol_rebind_nodemask(struct mempolicy *pol,
 	else if (pol->flags & MPOL_F_RELATIVE_NODES)
 		mpol_relative_nodemask(&tmp, &pol->w.user_nodemask, nodes);
 	else {
-		nodes_remap(tmp, pol->v.nodes, pol->w.cpuset_mems_allowed,
-			    *nodes);
+		tmp = *nodes;
 		pol->w.cpuset_mems_allowed = *nodes;
 	}
 
-	pol->v.nodes = tmp;
+	if (nodes_empty(tmp))
+		pol->v.nodes = *nodes;
+	else
+		pol->v.nodes = tmp;
+
 	if (!node_isset(current->il_next, tmp)) {
 		current->il_next = next_node(current->il_next, tmp);
 		if (current->il_next >= MAX_NUMNODES)
-- 
1.6.5.2


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
