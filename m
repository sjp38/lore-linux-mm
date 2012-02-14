Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx116.postini.com [74.125.245.116])
	by kanga.kvack.org (Postfix) with SMTP id C203B6B13F0
	for <linux-mm@kvack.org>; Tue, 14 Feb 2012 04:01:16 -0500 (EST)
Received: from /spool/local
	by e23smtp04.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <xiaoguangrong@linux.vnet.ibm.com>;
	Tue, 14 Feb 2012 08:45:38 +1000
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.235.138])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q1E8u3iv2629768
	for <linux-mm@kvack.org>; Tue, 14 Feb 2012 19:56:03 +1100
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q1E91Cop011454
	for <linux-mm@kvack.org>; Tue, 14 Feb 2012 20:01:12 +1100
Message-ID: <4F3A22D7.1070307@linux.vnet.ibm.com>
Date: Tue, 14 Feb 2012 17:01:11 +0800
From: Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: [PATCH 3/4] prio_tree: simplify prio_tree_expand
References: <4F3A2285.7060700@linux.vnet.ibm.com>
In-Reply-To: <4F3A2285.7060700@linux.vnet.ibm.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

In current code, the deleted-node is recorded from first to last,
actually, we can directly attach these node on 'node' we will insert
as the left child, it can let the code more readable

Signed-off-by: Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>
---
 lib/prio_tree.c |   38 ++++++++++++++------------------------
 1 files changed, 14 insertions(+), 24 deletions(-)

diff --git a/lib/prio_tree.c b/lib/prio_tree.c
index 888e8b3..928482b 100644
--- a/lib/prio_tree.c
+++ b/lib/prio_tree.c
@@ -94,43 +94,33 @@ static inline unsigned long prio_tree_maxindex(unsigned int bits)
 static struct prio_tree_node *prio_tree_expand(struct prio_tree_root *root,
 		struct prio_tree_node *node, unsigned long max_heap_index)
 {
-	struct prio_tree_node *first = NULL, *prev, *last = NULL;
+	struct prio_tree_node *prev;

 	if (max_heap_index > prio_tree_maxindex(root->index_bits))
 		root->index_bits++;

+	prev = node;
+	INIT_PRIO_TREE_NODE(node);
+
 	while (max_heap_index > prio_tree_maxindex(root->index_bits)) {
+		struct prio_tree_node *tmp = root->prio_tree_node;
+
 		root->index_bits++;

 		if (prio_tree_empty(root))
 			continue;

-		if (first == NULL) {
-			first = root->prio_tree_node;
-			prio_tree_remove(root, root->prio_tree_node);
-			INIT_PRIO_TREE_NODE(first);
-			last = first;
-		} else {
-			prev = last;
-			last = root->prio_tree_node;
-			prio_tree_remove(root, root->prio_tree_node);
-			INIT_PRIO_TREE_NODE(last);
-			prev->left = last;
-			last->parent = prev;
-		}
-	}
-
-	INIT_PRIO_TREE_NODE(node);
+		prio_tree_remove(root, root->prio_tree_node);
+		INIT_PRIO_TREE_NODE(tmp);

-	if (first) {
-		node->left = first;
-		first->parent = node;
-	} else
-		last = node;
+		prev->left = tmp;
+		tmp->parent = prev;
+		prev = tmp;
+	}

 	if (!prio_tree_empty(root)) {
-		last->left = root->prio_tree_node;
-		last->left->parent = last;
+		prev->left = root->prio_tree_node;
+		prev->left->parent = prev;
 	}

 	root->prio_tree_node = node;
-- 
1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
