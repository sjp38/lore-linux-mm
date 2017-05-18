Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f199.google.com (mail-qk0-f199.google.com [209.85.220.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1DE7A831F5
	for <linux-mm@kvack.org>; Thu, 18 May 2017 13:37:27 -0400 (EDT)
Received: by mail-qk0-f199.google.com with SMTP id u75so18097158qka.13
        for <linux-mm@kvack.org>; Thu, 18 May 2017 10:37:27 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id q32si6170549qtf.42.2017.05.18.10.37.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 18 May 2017 10:37:26 -0700 (PDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 3/3] ksm: optimize refile of stable_node_dup at the head of the chain
Date: Thu, 18 May 2017 19:37:21 +0200
Message-Id: <20170518173721.22316-4-aarcange@redhat.com>
In-Reply-To: <20170518173721.22316-1-aarcange@redhat.com>
References: <20170518173721.22316-1-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
Cc: Evgheni Dereveanchin <ederevea@redhat.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Petr Holasek <pholasek@redhat.com>, Hugh Dickins <hughd@google.com>, Arjan van de Ven <arjan@linux.intel.com>, Davidlohr Bueso <dave@stgolabs.net>, Gavin Guo <gavin.guo@canonical.com>, Jay Vosburgh <jay.vosburgh@canonical.com>, Mel Gorman <mgorman@techsingularity.net>, Dan Carpenter <dan.carpenter@oracle.com>

If a candidate stable_node_dup has been found and it can accept
further merges it can be refiled to the head of the list to speedup
next searches without altering which dup is found and how the dups
accumulate in the chain.

We already refiled it back to the head in the prune_stale_stable_nodes
case, but we didn't refile it if not pruning (which is more
common). And we also refiled it when it was already at the head which
is unnecessary (in the prune_stale_stable_nodes case, nr > 1 means
there's more than one dup in the chain, it doesn't mean it's not
already at the head of the chain).

The stable_node_chain list is single threaded and there's no SMP
locking contention so it should be faster to refile it to the head of
the list also if prune_stale_stable_nodes is false.

A profiling shows the refile happens 1.9% of the time when a dup is
found with a max_page_sharing limit setting of 3 (with
max_page_sharing of 2 the refile never happens of course as there's
never space for one more merge) which is reasonably low. At higher
max_page_sharing values it should be much less frequent.

This is just an optimization.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 mm/ksm.c | 35 +++++++++++++++++++++++------------
 1 file changed, 23 insertions(+), 12 deletions(-)

diff --git a/mm/ksm.c b/mm/ksm.c
index 7b2e26f9cf41..e02342f4f6aa 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -1369,13 +1369,14 @@ struct page *stable_node_dup(struct stable_node **_stable_node_dup,
 		put_page(_tree_page);
 	}
 
-	/*
-	 * nr is relevant only if prune_stale_stable_nodes is true,
-	 * otherwise we may break the loop at nr == 1 even if there
-	 * are multiple entries.
-	 */
-	if (prune_stale_stable_nodes && found) {
-		if (nr == 1) {
+	if (found) {
+		/*
+		 * nr is counting all dups in the chain only if
+		 * prune_stale_stable_nodes is true, otherwise we may
+		 * break the loop at nr == 1 even if there are
+		 * multiple entries.
+		 */
+		if (prune_stale_stable_nodes && nr == 1) {
 			/*
 			 * If there's not just one entry it would
 			 * corrupt memory, better BUG_ON. In KSM
@@ -1406,12 +1407,22 @@ struct page *stable_node_dup(struct stable_node **_stable_node_dup,
 			 * time.
 			 */
 			stable_node = NULL;
-		} else if (__is_page_sharing_candidate(found, 1)) {
+		} else if (stable_node->hlist.first != &found->hlist_dup &&
+			   __is_page_sharing_candidate(found, 1)) {
 			/*
-			 * Refile our candidate at the head
-			 * after the prune if our candidate
-			 * can accept one more future sharing
-			 * in addition to the one underway.
+			 * If the found stable_node dup can accept one
+			 * more future merge (in addition to the one
+			 * that is underway) and is not at the head of
+			 * the chain, put it there so next search will
+			 * be quicker in the !prune_stale_stable_nodes
+			 * case.
+			 *
+			 * NOTE: it would be inaccurate to use nr > 1
+			 * instead of checking the hlist.first pointer
+			 * directly, because in the
+			 * prune_stale_stable_nodes case "nr" isn't
+			 * the position of the found dup in the chain,
+			 * but the total number of dups in the chain.
 			 */
 			hlist_del(&found->hlist_dup);
 			hlist_add_head(&found->hlist_dup,

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
