Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8D8966B0340
	for <linux-mm@kvack.org>; Thu, 17 Nov 2016 14:11:59 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id i131so57061105wmf.3
        for <linux-mm@kvack.org>; Thu, 17 Nov 2016 11:11:59 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id o192si12501938wmg.112.2016.11.17.11.11.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 17 Nov 2016 11:11:58 -0800 (PST)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [PATCH 3/9] mm: workingset: turn shadow node shrinker bugs into warnings
Date: Thu, 17 Nov 2016 14:11:32 -0500
Message-Id: <20161117191138.22769-4-hannes@cmpxchg.org>
In-Reply-To: <20161117191138.22769-1-hannes@cmpxchg.org>
References: <20161117191138.22769-1-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jan Kara <jack@suse.cz>, "Kirill A. Shutemov" <kirill@shutemov.name>, Linus Torvalds <torvalds@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

When the shadow page shrinker tries to reclaim a radix tree node but
finds it in an unexpected state - it should contain no pages, and
non-zero shadow entries - there is no need to kill the executing task
or even the entire system. Warn about the invalid state, then leave
that tree node be. Simply don't put it back on the shadow LRU for
future reclaim and move on.

Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
---
 mm/workingset.c | 20 ++++++++++++--------
 1 file changed, 12 insertions(+), 8 deletions(-)

diff --git a/mm/workingset.c b/mm/workingset.c
index 617475f529f4..3cfc61d84a52 100644
--- a/mm/workingset.c
+++ b/mm/workingset.c
@@ -418,23 +418,27 @@ static enum lru_status shadow_lru_isolate(struct list_head *item,
 	 * no pages, so we expect to be able to remove them all and
 	 * delete and free the empty node afterwards.
 	 */
-	BUG_ON(!workingset_node_shadows(node));
-	BUG_ON(workingset_node_pages(node));
-
+	if (WARN_ON_ONCE(!workingset_node_shadows(node)))
+		goto out_invalid;
+	if (WARN_ON_ONCE(workingset_node_pages(node)))
+		goto out_invalid;
 	for (i = 0; i < RADIX_TREE_MAP_SIZE; i++) {
 		if (node->slots[i]) {
-			BUG_ON(!radix_tree_exceptional_entry(node->slots[i]));
+			if (WARN_ON_ONCE(!radix_tree_exceptional_entry(node->slots[i])))
+				goto out_invalid;
+			if (WARN_ON_ONCE(!mapping->nrexceptional))
+				goto out_invalid;
 			node->slots[i] = NULL;
 			workingset_node_shadows_dec(node);
-			BUG_ON(!mapping->nrexceptional);
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
2.10.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
