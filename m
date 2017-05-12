Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 945CB6B02E1
	for <linux-mm@kvack.org>; Fri, 12 May 2017 15:38:12 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id v27so22602220qtg.6
        for <linux-mm@kvack.org>; Fri, 12 May 2017 12:38:12 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id r4si4213838qtb.29.2017.05.12.12.38.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 12 May 2017 12:38:11 -0700 (PDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 1/1] ksm: fix use after free with merge_across_nodes = 0
Date: Fri, 12 May 2017 21:38:05 +0200
Message-Id: <20170512193805.8807-2-aarcange@redhat.com>
In-Reply-To: <20170512193805.8807-1-aarcange@redhat.com>
References: <20170512193805.8807-1-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
Cc: Evgheni Dereveanchin <ederevea@redhat.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Petr Holasek <pholasek@redhat.com>, Hugh Dickins <hughd@google.com>, Arjan van de Ven <arjan@linux.intel.com>, Davidlohr Bueso <dave@stgolabs.net>, Gavin Guo <gavin.guo@canonical.com>, Jay Vosburgh <jay.vosburgh@canonical.com>, Mel Gorman <mgorman@techsingularity.net>

If merge_across_nodes was manually set to 0 (not the default value) by
the admin or a tuned profile on NUMA systems triggering cross-NODE
page migrations, a stable_node use after free could materialize.

If the chain is collapsed stable_node would point to the old chain
that was already freed. stable_node_dup would be the stable_node dup
now converted to a regular stable_node and indexed in the rbtree in
replacement of the freed stable_node chain (not anymore a dup).

This special case where the chain is collapsed in the NUMA replacement
path, is now detected by setting stable_node to NULL by the
chain_prune callee if it decides to collapse the chain. This tells the
NUMA replacement code that even if stable_node and stable_node_dup are
different, this is not a chain if stable_node is NULL, as the
stable_node_dup was converted to a regular stable_node and the chain
was collapsed.

It is generally safer for the callee to force the caller stable_node
to NULL the moment it become stale so any other mistake like this
would result in an instant Oops easier to debug than an use after free.

Otherwise the replace logic would act like if stable_node was a valid
chain, when in fact it was freed. Notably
stable_node_chain_add_dup(page_node, stable_node) would run on a
stable stable_node.

Andrey Ryabinin found the source of the use after free in
chain_prune().

Reported-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
Reported-by: Evgheni Dereveanchin <ederevea@redhat.com>
Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 mm/ksm.c | 66 +++++++++++++++++++++++++++++++++++++++++++++++++++++-----------
 1 file changed, 55 insertions(+), 11 deletions(-)

diff --git a/mm/ksm.c b/mm/ksm.c
index 44a1b2a..b53fd58 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -338,6 +338,7 @@ static inline void stable_node_chain_add_dup(struct stable_node *dup,
 
 static inline void __stable_node_dup_del(struct stable_node *dup)
 {
+	VM_BUG_ON(!is_stable_node_dup(dup));
 	hlist_del(&dup->hlist_dup);
 	ksm_stable_node_dups--;
 }
@@ -1315,12 +1316,12 @@ bool is_page_sharing_candidate(struct stable_node *stable_node)
 	return __is_page_sharing_candidate(stable_node, 0);
 }
 
-static struct stable_node *stable_node_dup(struct stable_node *stable_node,
+static struct stable_node *stable_node_dup(struct stable_node **_stable_node,
 					   struct page **tree_page,
 					   struct rb_root *root,
 					   bool prune_stale_stable_nodes)
 {
-	struct stable_node *dup, *found = NULL;
+	struct stable_node *dup, *found = NULL, *stable_node = *_stable_node;
 	struct hlist_node *hlist_safe;
 	struct page *_tree_page;
 	int nr = 0;
@@ -1393,6 +1394,15 @@ static struct stable_node *stable_node_dup(struct stable_node *stable_node,
 			free_stable_node(stable_node);
 			ksm_stable_node_chains--;
 			ksm_stable_node_dups--;
+			/*
+			 * NOTE: the caller depends on the
+			 * *_stable_node to become NULL if the chain
+			 * was collapsed. Enforce that if anything
+			 * uses a stale (freed) stable_node chain a
+			 * visible crash will materialize (instead of
+			 * an use after free).
+			 */
+			*_stable_node = stable_node = NULL;
 		} else if (__is_page_sharing_candidate(found, 1)) {
 			/*
 			 * Refile our candidate at the head
@@ -1422,11 +1432,12 @@ static struct stable_node *stable_node_dup_any(struct stable_node *stable_node,
 			   typeof(*stable_node), hlist_dup);
 }
 
-static struct stable_node *__stable_node_chain(struct stable_node *stable_node,
+static struct stable_node *__stable_node_chain(struct stable_node **_stable_node,
 					       struct page **tree_page,
 					       struct rb_root *root,
 					       bool prune_stale_stable_nodes)
 {
+	struct stable_node *stable_node = *_stable_node;
 	if (!is_stable_node_chain(stable_node)) {
 		if (is_page_sharing_candidate(stable_node)) {
 			*tree_page = get_ksm_page(stable_node, false);
@@ -1434,11 +1445,11 @@ static struct stable_node *__stable_node_chain(struct stable_node *stable_node,
 		}
 		return NULL;
 	}
-	return stable_node_dup(stable_node, tree_page, root,
+	return stable_node_dup(_stable_node, tree_page, root,
 			       prune_stale_stable_nodes);
 }
 
-static __always_inline struct stable_node *chain_prune(struct stable_node *s_n,
+static __always_inline struct stable_node *chain_prune(struct stable_node **s_n,
 						       struct page **t_p,
 						       struct rb_root *root)
 {
@@ -1449,7 +1460,7 @@ static __always_inline struct stable_node *chain(struct stable_node *s_n,
 						 struct page **t_p,
 						 struct rb_root *root)
 {
-	return __stable_node_chain(s_n, t_p, root, false);
+	return __stable_node_chain(&s_n, t_p, root, false);
 }
 
 /*
@@ -1490,7 +1501,15 @@ static struct page *stable_tree_search(struct page *page)
 		cond_resched();
 		stable_node = rb_entry(*new, struct stable_node, node);
 		stable_node_any = NULL;
-		stable_node_dup = chain_prune(stable_node, &tree_page, root);
+		stable_node_dup = chain_prune(&stable_node, &tree_page, root);
+		/*
+		 * NOTE: stable_node may have been freed by
+		 * chain_prune() if the returned stable_node_dup is
+		 * not NULL. stable_node_dup may have been inserted in
+		 * the rbtree instead as a regular stable_node (in
+		 * order to collapse the stable_node chain if a single
+		 * stable_node dup was found in it).
+		 */
 		if (!stable_node_dup) {
 			/*
 			 * Either all stable_node dups were full in
@@ -1605,20 +1624,33 @@ static struct page *stable_tree_search(struct page *page)
 		return NULL;
 
 replace:
-	if (stable_node_dup == stable_node) {
+	/*
+	 * If stable_node was a chain and chain_prune collapsed it,
+	 * stable_node will be NULL here. In that case the
+	 * stable_node_dup is the regular stable_node that has
+	 * replaced the chain. If stable_node is not NULL and equal to
+	 * stable_node_dup there was no chain and stable_node_dup is
+	 * the regular stable_node in the stable rbtree. Otherwise
+	 * stable_node is the chain and stable_node_dup is the dup to
+	 * replace.
+	 */
+	if (!stable_node || stable_node_dup == stable_node) {
+		VM_BUG_ON(is_stable_node_chain(stable_node_dup));
+		VM_BUG_ON(is_stable_node_dup(stable_node_dup));
 		/* there is no chain */
 		if (page_node) {
 			VM_BUG_ON(page_node->head != &migrate_nodes);
 			list_del(&page_node->list);
 			DO_NUMA(page_node->nid = nid);
-			rb_replace_node(&stable_node->node, &page_node->node,
+			rb_replace_node(&stable_node_dup->node,
+					&page_node->node,
 					root);
 			if (is_page_sharing_candidate(page_node))
 				get_page(page);
 			else
 				page = NULL;
 		} else {
-			rb_erase(&stable_node->node, root);
+			rb_erase(&stable_node_dup->node, root);
 			page = NULL;
 		}
 	} else {
@@ -1645,7 +1677,17 @@ static struct page *stable_tree_search(struct page *page)
 	/* stable_node_dup could be null if it reached the limit */
 	if (!stable_node_dup)
 		stable_node_dup = stable_node_any;
-	if (stable_node_dup == stable_node) {
+	/*
+	 * If stable_node was a chain and chain_prune collapsed it,
+	 * stable_node will be NULL here. In that case the
+	 * stable_node_dup is the regular stable_node that has
+	 * replaced the chain. If stable_node is not NULL and equal to
+	 * stable_node_dup there was no chain and stable_node_dup is
+	 * the regular stable_node in the stable rbtree.
+	 */
+	if (!stable_node || stable_node_dup == stable_node) {
+		VM_BUG_ON(is_stable_node_chain(stable_node_dup));
+		VM_BUG_ON(is_stable_node_dup(stable_node_dup));
 		/* chain is missing so create it */
 		stable_node = alloc_stable_node_chain(stable_node_dup,
 						      root);
@@ -1658,6 +1700,8 @@ static struct page *stable_tree_search(struct page *page)
 	 * of the current nid for this page
 	 * content.
 	 */
+	VM_BUG_ON(!is_stable_node_chain(stable_node));
+	VM_BUG_ON(!is_stable_node_dup(stable_node_dup));
 	VM_BUG_ON(page_node->head != &migrate_nodes);
 	list_del(&page_node->list);
 	DO_NUMA(page_node->nid = nid);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
