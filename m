Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f199.google.com (mail-qt0-f199.google.com [209.85.216.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3025B831F4
	for <linux-mm@kvack.org>; Thu, 18 May 2017 13:37:27 -0400 (EDT)
Received: by mail-qt0-f199.google.com with SMTP id k11so16880133qtk.4
        for <linux-mm@kvack.org>; Thu, 18 May 2017 10:37:27 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 32si6211617qtq.98.2017.05.18.10.37.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 May 2017 10:37:26 -0700 (PDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 2/3] ksm: swap the two output parameters of chain/chain_prune
Date: Thu, 18 May 2017 19:37:20 +0200
Message-Id: <20170518173721.22316-3-aarcange@redhat.com>
In-Reply-To: <20170518173721.22316-1-aarcange@redhat.com>
References: <20170518173721.22316-1-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
Cc: Evgheni Dereveanchin <ederevea@redhat.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Petr Holasek <pholasek@redhat.com>, Hugh Dickins <hughd@google.com>, Arjan van de Ven <arjan@linux.intel.com>, Davidlohr Bueso <dave@stgolabs.net>, Gavin Guo <gavin.guo@canonical.com>, Jay Vosburgh <jay.vosburgh@canonical.com>, Mel Gorman <mgorman@techsingularity.net>, Dan Carpenter <dan.carpenter@oracle.com>

Some static checker complains if chain/chain_prune returns a
potentially stale pointer.

There are two output parameters to chain/chain_prune, one is tree_page
the other is stable_node_dup. Like in get_ksm_page the caller has to
check tree_page is NULL before touching the stable_node. Similarly in
chain/chain_prune the caller has to check tree_page before touching
the stable_node_dup returned or the original stable_node passed as
parameter.

Because the tree_page is never returned as a stale pointer, it may be
more intuitive to return tree_page and to pass stable_node_dup for
reference instead of the reverse.

This patch purely swaps the two output parameters of chain/chain_prune
as a cleanup for the static checker and to mimic the get_ksm_page
behavior more closely. There's no change to the caller at all except
the swap, it's purely a cleanup and it is a noop from the caller point
of view.

Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 mm/ksm.c | 78 ++++++++++++++++++++++++++++++++++++++++++----------------------
 1 file changed, 52 insertions(+), 26 deletions(-)

diff --git a/mm/ksm.c b/mm/ksm.c
index 959036064bb7..7b2e26f9cf41 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -1315,14 +1315,14 @@ bool is_page_sharing_candidate(struct stable_node *stable_node)
 	return __is_page_sharing_candidate(stable_node, 0);
 }
 
-static struct stable_node *stable_node_dup(struct stable_node **_stable_node,
-					   struct page **tree_page,
-					   struct rb_root *root,
-					   bool prune_stale_stable_nodes)
+struct page *stable_node_dup(struct stable_node **_stable_node_dup,
+			     struct stable_node **_stable_node,
+			     struct rb_root *root,
+			     bool prune_stale_stable_nodes)
 {
 	struct stable_node *dup, *found = NULL, *stable_node = *_stable_node;
 	struct hlist_node *hlist_safe;
-	struct page *_tree_page;
+	struct page *_tree_page, *tree_page = NULL;
 	int nr = 0;
 	int found_rmap_hlist_len;
 
@@ -1355,14 +1355,14 @@ static struct stable_node *stable_node_dup(struct stable_node **_stable_node,
 			if (!found ||
 			    dup->rmap_hlist_len > found_rmap_hlist_len) {
 				if (found)
-					put_page(*tree_page);
+					put_page(tree_page);
 				found = dup;
 				found_rmap_hlist_len = found->rmap_hlist_len;
-				*tree_page = _tree_page;
+				tree_page = _tree_page;
 
+				/* skip put_page for found dup */
 				if (!prune_stale_stable_nodes)
 					break;
-				/* skip put_page */
 				continue;
 			}
 		}
@@ -1419,7 +1419,8 @@ static struct stable_node *stable_node_dup(struct stable_node **_stable_node,
 		}
 	}
 
-	return found;
+	*_stable_node_dup = found;
+	return tree_page;
 }
 
 static struct stable_node *stable_node_dup_any(struct stable_node *stable_node,
@@ -1435,35 +1436,60 @@ static struct stable_node *stable_node_dup_any(struct stable_node *stable_node,
 			   typeof(*stable_node), hlist_dup);
 }
 
-static struct stable_node *__stable_node_chain(struct stable_node **_stable_node,
-					       struct page **tree_page,
-					       struct rb_root *root,
-					       bool prune_stale_stable_nodes)
+/*
+ * Like for get_ksm_page, this function can free the *_stable_node and
+ * *_stable_node_dup if the returned tree_page is NULL.
+ *
+ * It can also free and overwrite *_stable_node with the found
+ * stable_node_dup if the chain is collapsed (in which case
+ * *_stable_node will be equal to *_stable_node_dup like if the chain
+ * never existed). It's up to the caller to verify tree_page is not
+ * NULL before dereferencing *_stable_node or *_stable_node_dup.
+ *
+ * *_stable_node_dup is really a second output parameter of this
+ * function and will be overwritten in all cases, the caller doesn't
+ * need to initialize it.
+ */
+static struct page *__stable_node_chain(struct stable_node **_stable_node_dup,
+					struct stable_node **_stable_node,
+					struct rb_root *root,
+					bool prune_stale_stable_nodes)
 {
 	struct stable_node *stable_node = *_stable_node;
 	if (!is_stable_node_chain(stable_node)) {
 		if (is_page_sharing_candidate(stable_node)) {
-			*tree_page = get_ksm_page(stable_node, false);
-			return stable_node;
+			*_stable_node_dup = stable_node;
+			return get_ksm_page(stable_node, false);
 		}
+		/*
+		 * _stable_node_dup set to NULL means the stable_node
+		 * reached the ksm_max_page_sharing limit.
+		 */
+		*_stable_node_dup = NULL;
 		return NULL;
 	}
-	return stable_node_dup(_stable_node, tree_page, root,
+	return stable_node_dup(_stable_node_dup, _stable_node, root,
 			       prune_stale_stable_nodes);
 }
 
-static __always_inline struct stable_node *chain_prune(struct stable_node **s_n,
-						       struct page **t_p,
-						       struct rb_root *root)
+static __always_inline struct page *chain_prune(struct stable_node **s_n_d,
+						struct stable_node **s_n,
+						struct rb_root *root)
 {
-	return __stable_node_chain(s_n, t_p, root, true);
+	return __stable_node_chain(s_n_d, s_n, root, true);
 }
 
-static __always_inline struct stable_node *chain(struct stable_node *s_n,
-						 struct page **t_p,
-						 struct rb_root *root)
+static __always_inline struct page *chain(struct stable_node **s_n_d,
+					  struct stable_node *s_n,
+					  struct rb_root *root)
 {
-	return __stable_node_chain(&s_n, t_p, root, false);
+	struct stable_node *old_stable_node = s_n;
+	struct page *tree_page;
+
+	tree_page = __stable_node_chain(s_n_d, &s_n, root, false);
+	/* not pruning dups so s_n cannot have changed */
+	VM_BUG_ON(s_n != old_stable_node);
+	return tree_page;
 }
 
 /*
@@ -1504,7 +1530,7 @@ static struct page *stable_tree_search(struct page *page)
 		cond_resched();
 		stable_node = rb_entry(*new, struct stable_node, node);
 		stable_node_any = NULL;
-		stable_node_dup = chain_prune(&stable_node, &tree_page, root);
+		tree_page = chain_prune(&stable_node_dup, &stable_node,	root);
 		/*
 		 * NOTE: stable_node may have been freed by
 		 * chain_prune() if the returned stable_node_dup is
@@ -1745,7 +1771,7 @@ static struct stable_node *stable_tree_insert(struct page *kpage)
 		cond_resched();
 		stable_node = rb_entry(*new, struct stable_node, node);
 		stable_node_any = NULL;
-		stable_node_dup = chain(stable_node, &tree_page, root);
+		tree_page = chain(&stable_node_dup, stable_node, root);
 		if (!stable_node_dup) {
 			/*
 			 * Either all stable_node dups were full in

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
