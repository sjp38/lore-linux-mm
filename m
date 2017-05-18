Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 418FF831F8
	for <linux-mm@kvack.org>; Thu, 18 May 2017 13:37:27 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id z142so18225065qkz.8
        for <linux-mm@kvack.org>; Thu, 18 May 2017 10:37:27 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id k66si6007846qke.89.2017.05.18.10.37.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 May 2017 10:37:26 -0700 (PDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 1/3] ksm: cleanup stable_node chain collapse case
Date: Thu, 18 May 2017 19:37:19 +0200
Message-Id: <20170518173721.22316-2-aarcange@redhat.com>
In-Reply-To: <20170518173721.22316-1-aarcange@redhat.com>
References: <20170518173721.22316-1-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
Cc: Evgheni Dereveanchin <ederevea@redhat.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Petr Holasek <pholasek@redhat.com>, Hugh Dickins <hughd@google.com>, Arjan van de Ven <arjan@linux.intel.com>, Davidlohr Bueso <dave@stgolabs.net>, Gavin Guo <gavin.guo@canonical.com>, Jay Vosburgh <jay.vosburgh@canonical.com>, Mel Gorman <mgorman@techsingularity.net>, Dan Carpenter <dan.carpenter@oracle.com>

When the stable_node chain is collapsed we can as well set the caller
stable_node to match the returned stable_node_dup in chain_prune().

This way the collapse case becomes indistinguishable from the regular
stable_node case and we can remove two branches from the KSM page
migration handling slow paths.

While it was all correct this looks cleaner (and faster) as the caller
has to deal with fewer special cases.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 mm/ksm.c | 50 ++++++++++++++++++++++++++++----------------------
 1 file changed, 28 insertions(+), 22 deletions(-)

diff --git a/mm/ksm.c b/mm/ksm.c
index fc0c73bd6cb3..959036064bb7 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -1394,14 +1394,18 @@ static struct stable_node *stable_node_dup(struct stable_node **_stable_node,
 			ksm_stable_node_chains--;
 			ksm_stable_node_dups--;
 			/*
-			 * NOTE: the caller depends on the
-			 * *_stable_node to become NULL if the chain
-			 * was collapsed. Enforce that if anything
-			 * uses a stale (freed) stable_node chain a
-			 * visible crash will materialize (instead of
-			 * an use after free).
+			 * NOTE: the caller depends on the stable_node
+			 * to be equal to stable_node_dup if the chain
+			 * was collapsed.
 			 */
-			*_stable_node = stable_node = NULL;
+			*_stable_node = found;
+			/*
+			 * Just for robustneess as stable_node is
+			 * otherwise left as a stable pointer, the
+			 * compiler shall optimize it away at build
+			 * time.
+			 */
+			stable_node = NULL;
 		} else if (__is_page_sharing_candidate(found, 1)) {
 			/*
 			 * Refile our candidate at the head
@@ -1507,7 +1511,11 @@ static struct page *stable_tree_search(struct page *page)
 		 * not NULL. stable_node_dup may have been inserted in
 		 * the rbtree instead as a regular stable_node (in
 		 * order to collapse the stable_node chain if a single
-		 * stable_node dup was found in it).
+		 * stable_node dup was found in it). In such case the
+		 * stable_node is overwritten by the calleee to point
+		 * to the stable_node_dup that was collapsed in the
+		 * stable rbtree and stable_node will be equal to
+		 * stable_node_dup like if the chain never existed.
 		 */
 		if (!stable_node_dup) {
 			/*
@@ -1625,15 +1633,13 @@ static struct page *stable_tree_search(struct page *page)
 replace:
 	/*
 	 * If stable_node was a chain and chain_prune collapsed it,
-	 * stable_node will be NULL here. In that case the
-	 * stable_node_dup is the regular stable_node that has
-	 * replaced the chain. If stable_node is not NULL and equal to
-	 * stable_node_dup there was no chain and stable_node_dup is
-	 * the regular stable_node in the stable rbtree. Otherwise
-	 * stable_node is the chain and stable_node_dup is the dup to
-	 * replace.
+	 * stable_node has been updated to be the new regular
+	 * stable_node. A collapse of the chain is indistinguishable
+	 * from the case there was no chain in the stable
+	 * rbtree. Otherwise stable_node is the chain and
+	 * stable_node_dup is the dup to replace.
 	 */
-	if (!stable_node || stable_node_dup == stable_node) {
+	if (stable_node_dup == stable_node) {
 		VM_BUG_ON(is_stable_node_chain(stable_node_dup));
 		VM_BUG_ON(is_stable_node_dup(stable_node_dup));
 		/* there is no chain */
@@ -1678,13 +1684,13 @@ static struct page *stable_tree_search(struct page *page)
 		stable_node_dup = stable_node_any;
 	/*
 	 * If stable_node was a chain and chain_prune collapsed it,
-	 * stable_node will be NULL here. In that case the
-	 * stable_node_dup is the regular stable_node that has
-	 * replaced the chain. If stable_node is not NULL and equal to
-	 * stable_node_dup there was no chain and stable_node_dup is
-	 * the regular stable_node in the stable rbtree.
+	 * stable_node has been updated to be the new regular
+	 * stable_node. A collapse of the chain is indistinguishable
+	 * from the case there was no chain in the stable
+	 * rbtree. Otherwise stable_node is the chain and
+	 * stable_node_dup is the dup to replace.
 	 */
-	if (!stable_node || stable_node_dup == stable_node) {
+	if (stable_node_dup == stable_node) {
 		VM_BUG_ON(is_stable_node_chain(stable_node_dup));
 		VM_BUG_ON(is_stable_node_dup(stable_node_dup));
 		/* chain is missing so create it */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
