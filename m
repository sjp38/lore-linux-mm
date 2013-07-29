Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx127.postini.com [74.125.245.127])
	by kanga.kvack.org (Postfix) with SMTP id B42366B0081
	for <linux-mm@kvack.org>; Mon, 29 Jul 2013 15:19:58 -0400 (EDT)
Received: from /spool/local
	by e33.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <cody@linux.vnet.ibm.com>;
	Mon, 29 Jul 2013 19:19:57 -0000
Received: from d03relay05.boulder.ibm.com (d03relay05.boulder.ibm.com [9.17.195.107])
	by d03dlp03.boulder.ibm.com (Postfix) with ESMTP id 80CA919D803E
	for <linux-mm@kvack.org>; Mon, 29 Jul 2013 13:19:43 -0600 (MDT)
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay05.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r6TJJlZh133888
	for <linux-mm@kvack.org>; Mon, 29 Jul 2013 13:19:52 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r6TJJhrU020250
	for <linux-mm@kvack.org>; Mon, 29 Jul 2013 13:19:47 -0600
From: Cody P Schafer <cody@linux.vnet.ibm.com>
Subject: [PATCH v2 5/5] mm/zswap: use postorder iteration when destroying rbtree
Date: Mon, 29 Jul 2013 12:19:30 -0700
Message-Id: <1375125570-9401-6-git-send-email-cody@linux.vnet.ibm.com>
In-Reply-To: <1375125570-9401-1-git-send-email-cody@linux.vnet.ibm.com>
References: <1375125570-9401-1-git-send-email-cody@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, David Woodhouse <David.Woodhouse@intel.com>, Rik van Riel <riel@redhat.com>, Michel Lespinasse <walken@google.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Cody P Schafer <cody@linux.vnet.ibm.com>

Signed-off-by: Cody P Schafer <cody@linux.vnet.ibm.com>
Reviewed-by: Seth Jennings <sjenning@linux.vnet.ibm.com>
---
 mm/zswap.c | 16 ++--------------
 1 file changed, 2 insertions(+), 14 deletions(-)

diff --git a/mm/zswap.c b/mm/zswap.c
index deda2b6..5c853b2 100644
--- a/mm/zswap.c
+++ b/mm/zswap.c
@@ -790,26 +790,14 @@ static void zswap_frontswap_invalidate_page(unsigned type, pgoff_t offset)
 static void zswap_frontswap_invalidate_area(unsigned type)
 {
 	struct zswap_tree *tree = zswap_trees[type];
-	struct rb_node *node;
-	struct zswap_entry *entry;
+	struct zswap_entry *entry, *n;
 
 	if (!tree)
 		return;
 
 	/* walk the tree and free everything */
 	spin_lock(&tree->lock);
-	/*
-	 * TODO: Even though this code should not be executed because
-	 * the try_to_unuse() in swapoff should have emptied the tree,
-	 * it is very wasteful to rebalance the tree after every
-	 * removal when we are freeing the whole tree.
-	 *
-	 * If post-order traversal code is ever added to the rbtree
-	 * implementation, it should be used here.
-	 */
-	while ((node = rb_first(&tree->rbroot))) {
-		entry = rb_entry(node, struct zswap_entry, rbnode);
-		rb_erase(&entry->rbnode, &tree->rbroot);
+	rbtree_postorder_for_each_entry_safe(entry, n, &tree->rbroot, rbnode) {
 		zbud_free(tree->pool, entry->handle);
 		zswap_entry_cache_free(entry);
 		atomic_dec(&zswap_stored_pages);
-- 
1.8.3.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
