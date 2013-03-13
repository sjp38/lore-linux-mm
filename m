Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx141.postini.com [74.125.245.141])
	by kanga.kvack.org (Postfix) with SMTP id D3CF26B0006
	for <linux-mm@kvack.org>; Wed, 13 Mar 2013 11:34:28 -0400 (EDT)
Received: from /spool/local
	by e8.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <sjenning@linux.vnet.ibm.com>;
	Wed, 13 Mar 2013 11:34:27 -0400
Received: from d01relay03.pok.ibm.com (d01relay03.pok.ibm.com [9.56.227.235])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id D67326E804C
	for <linux-mm@kvack.org>; Wed, 13 Mar 2013 11:34:07 -0400 (EDT)
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay03.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r2DFY9lK110912
	for <linux-mm@kvack.org>; Wed, 13 Mar 2013 11:34:09 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r2DFY84T029398
	for <linux-mm@kvack.org>; Wed, 13 Mar 2013 12:34:09 -0300
Message-ID: <51409C65.1040207@linux.vnet.ibm.com>
Date: Wed, 13 Mar 2013 10:33:57 -0500
From: Seth Jennings <sjenning@linux.vnet.ibm.com>
MIME-Version: 1.0
Subject: Re: zsmalloc limitations and related topics
References: <0efe9610-1aa5-4aa9-bde9-227acfa969ca@default> <20130313151359.GA3130@linux.vnet.ibm.com>
In-Reply-To: <20130313151359.GA3130@linux.vnet.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>, minchan@kernel.org, Nitin Gupta <nitingupta910@gmail.com>, Konrad Wilk <konrad.wilk@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Bob Liu <lliubbo@gmail.com>, Luigi Semenzato <semenzato@google.com>, Mel Gorman <mgorman@suse.de>

The periodic writeback that Rob mentions would go something like this
for zswap:

---
 mm/filemap.c |    3 +--
 mm/zswap.c   |   63 +++++++++++++++++++++++++++++++++++++++++++++++++++++-----
 2 files changed, 59 insertions(+), 7 deletions(-)

diff --git a/mm/filemap.c b/mm/filemap.c
index 83efee7..fe63e95 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -735,12 +735,11 @@ repeat:
 	if (page && !radix_tree_exception(page)) {
 		lock_page(page);
 		/* Has the page been truncated? */
-		if (unlikely(page->mapping != mapping)) {
+		if (unlikely(page_mapping(page) != mapping)) {
 			unlock_page(page);
 			page_cache_release(page);
 			goto repeat;
 		}
-		VM_BUG_ON(page->index != offset);
 	}
 	return page;
 }
diff --git a/mm/zswap.c b/mm/zswap.c
index 82b8d59..0b2351e 100644
--- a/mm/zswap.c
+++ b/mm/zswap.c
@@ -42,6 +42,9 @@
 #include <linux/writeback.h>
 #include <linux/pagemap.h>
 
+#include <linux/workqueue.h>
+#include <linux/time.h>
+
 /*********************************
 * statistics
 **********************************/
@@ -102,6 +105,23 @@ module_param_named(max_compression_ratio,
 */
 #define ZSWAP_MAX_OUTSTANDING_FLUSHES 64
 
+/*
+ * The amount of time in seconds for zswap is considered "idle" and periodic
+ * writeback begins
+ */
+static int zswap_pwb_idle_secs = 30;
+
+/*
+ * The delay between iterations of periodic writeback
+ */
+static unsigned long zswap_pwb_delay_secs = 1;
+
+/*
+ * The number of pages to attempt to writeback on each iteration of the periodic
+ * writeback thread
+ */
+static int zswap_pwb_writeback_pages = 32;
+
 /*********************************
 * compression functions
 **********************************/
@@ -199,6 +219,7 @@ struct zswap_entry {
  * The tree lock in the zswap_tree struct protects a few things:
  * - the rbtree
  * - the lru list
+ * - starting/modifying the pwb_work timer
  * - the refcount field of each entry in the tree
  */
 struct zswap_tree {
@@ -207,6 +228,7 @@ struct zswap_tree {
 	spinlock_t lock;
 	struct zs_pool *pool;
 	unsigned type;
+	struct delayed_work pwb_work;
 };
 
 static struct zswap_tree *zswap_trees[MAX_SWAPFILES];
@@ -492,7 +514,7 @@ static int zswap_get_swap_cache_page(swp_entry_t entry,
 		 * called after lookup_swap_cache() failed, re-calling
 		 * that would confuse statistics.
 		 */
-		found_page = find_get_page(&swapper_space, entry.val);
+		found_page = find_lock_page(&swapper_space, entry.val);
 		if (found_page)
 			break;
 
@@ -588,9 +610,8 @@ static int zswap_writeback_entry(struct zswap_tree *tree, struct zswap_entry *en
 		break; /* not reached */
 
 	case ZSWAP_SWAPCACHE_EXIST: /* page is unlocked */
-		/* page is already in the swap cache, ignore for now */
-		return -EEXIST;
-		break; /* not reached */
+		/* page is already in the swap cache, no need to decompress */
+		break;
 
 	case ZSWAP_SWAPCACHE_NEW: /* page is locked */
 		/* decompress */
@@ -698,6 +719,26 @@ static int zswap_writeback_entries(struct zswap_tree *tree, int nr)
 	return freed_nr++;
 }
 
+/*********************************
+* periodic writeback (pwb)
+**********************************/
+void zswap_pwb_work(struct work_struct *work)
+{
+	struct delayed_work *dwork;
+	struct zswap_tree *tree;
+
+	dwork  = to_delayed_work(work);
+	tree = container_of(dwork, struct zswap_tree, pwb_work);
+
+	zswap_writeback_entries(tree, zswap_pwb_writeback_pages);
+
+	spin_lock(&tree->lock);
+	if (!list_empty(&tree->lru))
+		schedule_delayed_work(&tree->pwb_work,
+			msecs_to_jiffies(MSEC_PER_SEC * zswap_pwb_delay_secs));
+	spin_unlock(&tree->lock);
+}
+
 /*******************************************
 * page pool for temporary compression result
 ********************************************/
@@ -854,8 +895,18 @@ static int zswap_frontswap_store(unsigned type, pgoff_t offset,
 	entry->handle = handle;
 	entry->length = dlen;
 
-	/* map */
 	spin_lock(&tree->lock);
+
+	if (RB_EMPTY_ROOT(&tree->rbroot))
+		/* schedule delayed periodic writeback work */
+		schedule_delayed_work(&tree->pwb_work,
+			msecs_to_jiffies(MSEC_PER_SEC * zswap_pwb_idle_secs));
+	else
+		/* update delay on already scheduled delayed work */
+		mod_delayed_work(system_wq, &tree->pwb_work,
+			msecs_to_jiffies(MSEC_PER_SEC * zswap_pwb_idle_secs));
+
+	/* map */
 	do {
 		ret = zswap_rb_insert(&tree->rbroot, entry, &dupentry);
 		if (ret == -EEXIST) {
@@ -1001,6 +1052,7 @@ static void zswap_frontswap_invalidate_area(unsigned type)
 	 * If post-order traversal code is ever added to the rbtree
 	 * implementation, it should be used here.
 	 */
+	cancel_delayed_work_sync(&tree->pwb_work);
 	while ((node = rb_first(&tree->rbroot))) {
 		entry = rb_entry(node, struct zswap_entry, rbnode);
 		rb_erase(&entry->rbnode, &tree->rbroot);
@@ -1027,6 +1079,7 @@ static void zswap_frontswap_init(unsigned type)
 	INIT_LIST_HEAD(&tree->lru);
 	spin_lock_init(&tree->lock);
 	tree->type = type;
+	INIT_DELAYED_WORK(&tree->pwb_work, zswap_pwb_work);
 	zswap_trees[type] = tree;
 	return;
 
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
