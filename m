Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f175.google.com (mail-ob0-f175.google.com [209.85.214.175])
	by kanga.kvack.org (Postfix) with ESMTP id 0C53182F66
	for <linux-mm@kvack.org>; Thu, 15 Oct 2015 12:04:36 -0400 (EDT)
Received: by obbda8 with SMTP id da8so69049884obb.1
        for <linux-mm@kvack.org>; Thu, 15 Oct 2015 09:04:35 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id x186si2565696oix.20.2015.10.15.09.04.30
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Oct 2015 09:04:30 -0700 (PDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 3/6] ksm: don't fail stable tree lookups if walking over stale stable_nodes
Date: Thu, 15 Oct 2015 18:04:22 +0200
Message-Id: <1444925065-4841-4-git-send-email-aarcange@redhat.com>
In-Reply-To: <1444925065-4841-1-git-send-email-aarcange@redhat.com>
References: <1444925065-4841-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, Petr Holasek <pholasek@redhat.com>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>

The stable_nodes can become stale at any time if the underlying pages
gets freed. The stable_node gets collected and removed from the stable
rbtree if that is detected during the rbtree tree lookups.

Don't fail the lookup if running into stale stable_nodes, just restart
the lookup after collecting the stale entries. Otherwise the CPU spent
in the preparation stage is wasted and the lookup must be repeated at
the next loop potentially failing a second time in a second stale
entry.

This also will contribute to pruning the stable tree and releasing the
stable_node memory more efficiently.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 mm/ksm.c | 30 +++++++++++++++++++++++++++---
 1 file changed, 27 insertions(+), 3 deletions(-)

diff --git a/mm/ksm.c b/mm/ksm.c
index 39ef485..929b5c2 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -1225,7 +1225,18 @@ again:
 		stable_node = rb_entry(*new, struct stable_node, node);
 		tree_page = get_ksm_page(stable_node, false);
 		if (!tree_page)
-			return NULL;
+			/*
+			 * If we walked over a stale stable_node,
+			 * get_ksm_page() will call rb_erase() and it
+			 * may rebalance the tree from under us. So
+			 * restart the search from scratch. Returning
+			 * NULL would be safe too, but we'd generate
+			 * false negative insertions just because some
+			 * stable_node was stale which would waste CPU
+			 * by doing the preparation work twice at the
+			 * next KSM pass.
+			 */
+			goto again;
 
 		ret = memcmp_pages(page, tree_page);
 		put_page(tree_page);
@@ -1301,12 +1312,14 @@ static struct stable_node *stable_tree_insert(struct page *kpage)
 	unsigned long kpfn;
 	struct rb_root *root;
 	struct rb_node **new;
-	struct rb_node *parent = NULL;
+	struct rb_node *parent;
 	struct stable_node *stable_node;
 
 	kpfn = page_to_pfn(kpage);
 	nid = get_kpfn_nid(kpfn);
 	root = root_stable_tree + nid;
+again:
+	parent = NULL;
 	new = &root->rb_node;
 
 	while (*new) {
@@ -1317,7 +1330,18 @@ static struct stable_node *stable_tree_insert(struct page *kpage)
 		stable_node = rb_entry(*new, struct stable_node, node);
 		tree_page = get_ksm_page(stable_node, false);
 		if (!tree_page)
-			return NULL;
+			/*
+			 * If we walked over a stale stable_node,
+			 * get_ksm_page() will call rb_erase() and it
+			 * may rebalance the tree from under us. So
+			 * restart the search from scratch. Returning
+			 * NULL would be safe too, but we'd generate
+			 * false negative insertions just because some
+			 * stable_node was stale which would waste CPU
+			 * by doing the preparation work twice at the
+			 * next KSM pass.
+			 */
+			goto again;
 
 		ret = memcmp_pages(kpage, tree_page);
 		put_page(tree_page);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
