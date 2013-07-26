Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx184.postini.com [74.125.245.184])
	by kanga.kvack.org (Postfix) with SMTP id 96BC86B0038
	for <linux-mm@kvack.org>; Fri, 26 Jul 2013 17:14:23 -0400 (EDT)
Received: from /spool/local
	by e7.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <cody@linux.vnet.ibm.com>;
	Fri, 26 Jul 2013 17:14:22 -0400
Received: from d01relay01.pok.ibm.com (d01relay01.pok.ibm.com [9.56.227.233])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id 7927A6E8041
	for <linux-mm@kvack.org>; Fri, 26 Jul 2013 17:14:15 -0400 (EDT)
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay01.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r6QLEK35116192
	for <linux-mm@kvack.org>; Fri, 26 Jul 2013 17:14:20 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r6QLEJLp013542
	for <linux-mm@kvack.org>; Fri, 26 Jul 2013 18:14:20 -0300
From: Cody P Schafer <cody@linux.vnet.ibm.com>
Subject: [PATCH 5/5] mm/zswap: use postorder iteration when destroying rbtree
Date: Fri, 26 Jul 2013 14:13:43 -0700
Message-Id: <1374873223-25557-6-git-send-email-cody@linux.vnet.ibm.com>
In-Reply-To: <1374873223-25557-1-git-send-email-cody@linux.vnet.ibm.com>
References: <1374873223-25557-1-git-send-email-cody@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, David Woodhouse <David.Woodhouse@intel.com>, Rik van Riel <riel@redhat.com>, Michel Lespinasse <walken@google.com>, Seth Jennings <sjenning@linux.vnet.ibm.com>, Cody P Schafer <cody@linux.vnet.ibm.com>

Signed-off-by: Cody P Schafer <cody@linux.vnet.ibm.com>
---
 mm/zswap.c | 15 ++-------------
 1 file changed, 2 insertions(+), 13 deletions(-)

diff --git a/mm/zswap.c b/mm/zswap.c
index deda2b6..98d99c4 100644
--- a/mm/zswap.c
+++ b/mm/zswap.c
@@ -791,25 +791,14 @@ static void zswap_frontswap_invalidate_area(unsigned type)
 {
 	struct zswap_tree *tree = zswap_trees[type];
 	struct rb_node *node;
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
