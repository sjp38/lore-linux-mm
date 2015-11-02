Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 620FA6B0038
	for <linux-mm@kvack.org>; Mon,  2 Nov 2015 12:01:35 -0500 (EST)
Received: by pacfv9 with SMTP id fv9so160248164pac.3
        for <linux-mm@kvack.org>; Mon, 02 Nov 2015 09:01:35 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id zo6si36230982pbc.29.2015.11.02.09.01.34
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 02 Nov 2015 09:01:34 -0800 (PST)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 2/5] ksm: don't fail stable tree lookups if walking over stale stable_nodes
Date: Mon,  2 Nov 2015 18:01:28 +0100
Message-Id: <1446483691-8494-3-git-send-email-aarcange@redhat.com>
In-Reply-To: <1446483691-8494-1-git-send-email-aarcange@redhat.com>
References: <1446483691-8494-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>, Davidlohr Bueso <dave@stgolabs.net>
Cc: linux-mm@kvack.org, Petr Holasek <pholasek@redhat.com>, Andrew Morton <akpm@linux-foundation.org>

The stable_nodes can become stale at any time if the underlying pages
gets freed. The stable_node gets collected and removed from the stable
rbtree if that is detected during the rbtree lookups.

Don't fail the lookup if running into stale stable_nodes, just restart
the lookup after collecting the stale stable_nodes. Otherwise the CPU
spent in the preparation stage is wasted and the lookup must be
repeated at the next loop potentially failing a second time in a
second stale stable_node.

If we don't prune aggressively we delay the merging of the unstable
node candidates and at the same time we delay the freeing of the stale
stable_nodes. Keeping stale stable_nodes around wastes memory and it
can't provide any benefit.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
Acked-by: Hugh Dickins <hughd@google.com>
---
 mm/ksm.c | 32 +++++++++++++++++++++++++++-----
 1 file changed, 27 insertions(+), 5 deletions(-)

diff --git a/mm/ksm.c b/mm/ksm.c
index e87dec7..9f182f9 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -1177,8 +1177,18 @@ again:
 		cond_resched();
 		stable_node = rb_entry(*new, struct stable_node, node);
 		tree_page = get_ksm_page(stable_node, false);
-		if (!tree_page)
-			return NULL;
+		if (!tree_page) {
+			/*
+			 * If we walked over a stale stable_node,
+			 * get_ksm_page() will call rb_erase() and it
+			 * may rebalance the tree from under us. So
+			 * restart the search from scratch. Returning
+			 * NULL would be safe too, but we'd generate
+			 * false negative insertions just because some
+			 * stable_node was stale.
+			 */
+			goto again;
+		}
 
 		ret = memcmp_pages(page, tree_page);
 		put_page(tree_page);
@@ -1254,12 +1264,14 @@ static struct stable_node *stable_tree_insert(struct page *kpage)
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
@@ -1269,8 +1281,18 @@ static struct stable_node *stable_tree_insert(struct page *kpage)
 		cond_resched();
 		stable_node = rb_entry(*new, struct stable_node, node);
 		tree_page = get_ksm_page(stable_node, false);
-		if (!tree_page)
-			return NULL;
+		if (!tree_page) {
+			/*
+			 * If we walked over a stale stable_node,
+			 * get_ksm_page() will call rb_erase() and it
+			 * may rebalance the tree from under us. So
+			 * restart the search from scratch. Returning
+			 * NULL would be safe too, but we'd generate
+			 * false negative insertions just because some
+			 * stable_node was stale.
+			 */
+			goto again;
+		}
 
 		ret = memcmp_pages(kpage, tree_page);
 		put_page(tree_page);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
