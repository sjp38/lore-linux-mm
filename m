Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 102A0280251
	for <linux-mm@kvack.org>; Wed, 19 Oct 2016 13:24:56 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id b75so12529114lfg.3
        for <linux-mm@kvack.org>; Wed, 19 Oct 2016 10:24:55 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id b67si4356572lfg.317.2016.10.19.10.24.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Oct 2016 10:24:54 -0700 (PDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [PATCH 5/5] mm: workingset: turn shadow node shrinker bugs into warnings
Date: Wed, 19 Oct 2016 13:24:28 -0400
Message-Id: <20161019172428.7649-6-hannes@cmpxchg.org>
In-Reply-To: <20161019172428.7649-1-hannes@cmpxchg.org>
References: <20161019172428.7649-1-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, Dave Jones <davej@codemonkey.org.uk>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

When the shadow page shrinker tries to reclaim a radix tree node but
finds it in an unexpected state--it should contain no pages, and
non-zero shadow entries--there is no need to kill the executing task
or even the entire system.

Warn about the invalid state, then leave that tree node be. Simply
don't put it back on the shadow LRU for future reclaim and move on.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/workingset.c | 19 ++++++++++++-------
 1 file changed, 12 insertions(+), 7 deletions(-)

diff --git a/mm/workingset.c b/mm/workingset.c
index 617475f529f4..5f07db171c03 100644
--- a/mm/workingset.c
+++ b/mm/workingset.c
@@ -418,23 +418,28 @@ static enum lru_status shadow_lru_isolate(struct list_head *item,
 	 * no pages, so we expect to be able to remove them all and
 	 * delete and free the empty node afterwards.
 	 */
-	BUG_ON(!workingset_node_shadows(node));
-	BUG_ON(workingset_node_pages(node));
+	if (WARN_ON_ONCE(!workingset_node_shadows(node)))
+		goto out_invalid;
+	if (WARN_ON_ONCE(workingset_node_pages(node)))
+		goto out_invalid;
 
 	for (i = 0; i < RADIX_TREE_MAP_SIZE; i++) {
 		if (node->slots[i]) {
-			BUG_ON(!radix_tree_exceptional_entry(node->slots[i]));
+			if (WARN_ON_ONCE(!radix_tree_exceptional_entry(node->slots[i])))
+				goto out_invalid;
 			node->slots[i] = NULL;
 			workingset_node_shadows_dec(node);
-			BUG_ON(!mapping->nrexceptional);
+			if (WARN_ON_ONCE(!mapping->nrexceptional))
+				goto out_invalid;
 			mapping->nrexceptional--;
 		}
 	}
-	BUG_ON(workingset_node_shadows(node));
+	if (WARN_ON_ONCE(workingset_node_shadows(node)))
+		goto out_invalid;
 	inc_node_state(page_pgdat(virt_to_page(node)), WORKINGSET_NODERECLAIM);
-	if (!__radix_tree_delete_node(&mapping->page_tree, node))
-		BUG();
+	__radix_tree_delete_node(&mapping->page_tree, node);
 
+out_invalid:
 	spin_unlock(&mapping->tree_lock);
 	ret = LRU_REMOVED_RETRY;
 out:
-- 
2.10.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
