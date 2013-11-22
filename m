Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f47.google.com (mail-qa0-f47.google.com [209.85.216.47])
	by kanga.kvack.org (Postfix) with ESMTP id C75E16B0036
	for <linux-mm@kvack.org>; Fri, 22 Nov 2013 17:11:20 -0500 (EST)
Received: by mail-qa0-f47.google.com with SMTP id w5so910184qac.13
        for <linux-mm@kvack.org>; Fri, 22 Nov 2013 14:11:20 -0800 (PST)
Received: from mail-qc0-x233.google.com (mail-qc0-x233.google.com [2607:f8b0:400d:c01::233])
        by mx.google.com with ESMTPS id w7si2512qeg.76.2013.11.22.14.11.18
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 22 Nov 2013 14:11:19 -0800 (PST)
Received: by mail-qc0-f179.google.com with SMTP id x13so1209639qcv.24
        for <linux-mm@kvack.org>; Fri, 22 Nov 2013 14:11:18 -0800 (PST)
From: Dan Streetman <ddstreet@ieee.org>
Subject: [PATCH] mm/zswap: reverse zswap_entry tree/refcount relationship
Date: Fri, 22 Nov 2013 17:10:54 -0500
Message-Id: <1385158254-6304-1-git-send-email-ddstreet@ieee.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjennings@variantweb.net>
Cc: Dan Streetman <ddstreet@ieee.org>, linux-mm@kvack.org, linux-kernel <linux-kernel@vger.kernel.org>, Bob Liu <bob.liu@oracle.com>, Minchan Kim <minchan@kernel.org>, Weijie Yang <weijie.yang@samsung.com>

Currently, zswap_entry_put removes the entry from its tree if
the resulting refcount is 0.  Several places in code put an
entry's initial reference, but they also must remove the entry
from its tree first, which makes the tree removal in zswap_entry_put
redundant.

I believe this has the refcount model backwards - the initial
refcount reference shouldn't be managed by multiple different places
in code, and the put function shouldn't be removing the entry
from the tree.  I think the correct model is for the tree to be
the owner of the initial entry reference.  This way, the only time
any code needs to put the entry is if it's also done a get previously.
The various places in code that remove the entry from the tree simply
do that, and the zswap_rb_erase function does the put of the initial
reference.

This patch moves the initial referencing completely into the tree
functions - zswap_rb_insert gets the entry, while zswap_rb_erase
puts the entry.  The zswap_entry_get/put functions are still available
for any code that needs to use an entry outside of the tree lock.
Also, the zswap_entry_find_get function is renamed to zswap_rb_search_get
since the function behavior and return value is closer to zswap_rb_search
than zswap_entry_get.  All code that previously removed the entry from
the tree and put it now only remove the entry from the tree.

The comment headers for most of the tree insert/search/erase functions
and the get/put functions are updated to clarify if the tree lock
needs to be held as well as when the caller needs to get/put an
entry (i.e. iff the caller is using the entry outside the tree lock).

Signed-off-by: Dan Streetman <ddstreet@ieee.org>
---

This patch requires the writethrough patch to have been applied, but
the patch idea doesn't require the writethrough patch.

 mm/zswap.c | 130 ++++++++++++++++++++++++++++++++++---------------------------
 1 file changed, 72 insertions(+), 58 deletions(-)

diff --git a/mm/zswap.c b/mm/zswap.c
index fc35a7a..8c27eb2 100644
--- a/mm/zswap.c
+++ b/mm/zswap.c
@@ -215,7 +215,7 @@ static struct zswap_entry *zswap_entry_cache_alloc(gfp_t gfp)
 	entry = kmem_cache_alloc(zswap_entry_cache, gfp);
 	if (!entry)
 		return NULL;
-	entry->refcount = 1;
+	entry->refcount = 0;
 	RB_CLEAR_NODE(&entry->rbnode);
 	return entry;
 }
@@ -228,9 +228,51 @@ static void zswap_entry_cache_free(struct zswap_entry *entry)
 /*********************************
 * rbtree functions
 **********************************/
-static struct zswap_entry *zswap_rb_search(struct rb_root *root, pgoff_t offset)
+
+/*
+ * Carries out the common pattern of freeing and entry's zsmalloc allocation,
+ * freeing the entry itself, and decrementing the number of stored pages.
+ */
+static void zswap_free_entry(struct zswap_tree *tree,
+			struct zswap_entry *entry)
+{
+	zbud_free(tree->pool, entry->handle);
+	zswap_entry_cache_free(entry);
+	atomic_dec(&zswap_stored_pages);
+	zswap_pool_pages = zbud_get_pool_size(tree->pool);
+}
+
+/* caller must hold the tree lock
+ * this must be used if the entry will be used outside
+ * the tree lock
+ */
+static void zswap_entry_get(struct zswap_entry *entry)
+{
+	entry->refcount++;
+}
+
+/* caller must hold the tree lock
+* remove from the tree and free it, if nobody reference the entry
+*/
+static void zswap_entry_put(struct zswap_tree *tree,
+			struct zswap_entry *entry)
+{
+	int refcount = --entry->refcount;
+
+	BUG_ON(refcount < 0);
+	if (refcount == 0)
+		zswap_free_entry(tree, entry);
+}
+
+/* caller much hold the tree lock
+ * This will find the entry for the offset, and return it
+ * If no entry is found, NULL is returned
+ * If the entry will be used outside the tree lock,
+ * then zswap_rb_search_get should be used instead
+ */
+static struct zswap_entry *zswap_rb_search(struct zswap_tree *tree, pgoff_t offset)
 {
-	struct rb_node *node = root->rb_node;
+	struct rb_node *node = tree->rbroot.rb_node;
 	struct zswap_entry *entry;
 
 	while (node) {
@@ -246,13 +288,14 @@ static struct zswap_entry *zswap_rb_search(struct rb_root *root, pgoff_t offset)
 }
 
 /*
+ * caller must hold the tree lock
  * In the case that a entry with the same offset is found, a pointer to
  * the existing entry is stored in dupentry and the function returns -EEXIST
  */
-static int zswap_rb_insert(struct rb_root *root, struct zswap_entry *entry,
+static int zswap_rb_insert(struct zswap_tree *tree, struct zswap_entry *entry,
 			struct zswap_entry **dupentry)
 {
-	struct rb_node **link = &root->rb_node, *parent = NULL;
+	struct rb_node **link = &tree->rbroot.rb_node, *parent = NULL;
 	struct zswap_entry *myentry;
 
 	while (*link) {
@@ -267,60 +310,38 @@ static int zswap_rb_insert(struct rb_root *root, struct zswap_entry *entry,
 			return -EEXIST;
 		}
 	}
+	zswap_entry_get(entry);
 	rb_link_node(&entry->rbnode, parent, link);
-	rb_insert_color(&entry->rbnode, root);
+	rb_insert_color(&entry->rbnode, &tree->rbroot);
 	return 0;
 }
 
-static void zswap_rb_erase(struct rb_root *root, struct zswap_entry *entry)
+
+/* caller must hold the tree lock
+ * after calling, the entry may have been freed,
+ * and so should no longer be used
+ */
+static void zswap_rb_erase(struct zswap_tree *tree, struct zswap_entry *entry)
 {
 	if (!RB_EMPTY_NODE(&entry->rbnode)) {
-		rb_erase(&entry->rbnode, root);
+		rb_erase(&entry->rbnode, &tree->rbroot);
 		RB_CLEAR_NODE(&entry->rbnode);
+		zswap_entry_put(tree, entry);
 	}
 }
 
-/*
- * Carries out the common pattern of freeing and entry's zsmalloc allocation,
- * freeing the entry itself, and decrementing the number of stored pages.
- */
-static void zswap_free_entry(struct zswap_tree *tree,
-			struct zswap_entry *entry)
-{
-	zbud_free(tree->pool, entry->handle);
-	zswap_entry_cache_free(entry);
-	atomic_dec(&zswap_stored_pages);
-	zswap_pool_pages = zbud_get_pool_size(tree->pool);
-}
-
-/* caller must hold the tree lock */
-static void zswap_entry_get(struct zswap_entry *entry)
-{
-	entry->refcount++;
-}
-
 /* caller must hold the tree lock
-* remove from the tree and free it, if nobody reference the entry
-*/
-static void zswap_entry_put(struct zswap_tree *tree,
-			struct zswap_entry *entry)
-{
-	int refcount = --entry->refcount;
-
-	BUG_ON(refcount < 0);
-	if (refcount == 0) {
-		zswap_rb_erase(&tree->rbroot, entry);
-		zswap_free_entry(tree, entry);
-	}
-}
-
-/* caller must hold the tree lock */
-static struct zswap_entry *zswap_entry_find_get(struct rb_root *root,
+ * this is the same as zswap_rb_search but also gets
+ * the entry before returning it (if found).  This
+ * (or zswap_entry_get) must be used if the entry will be
+ * used outside the tree lock
+ */
+static struct zswap_entry *zswap_rb_search_get(struct zswap_tree *tree,
 				pgoff_t offset)
 {
 	struct zswap_entry *entry = NULL;
 
-	entry = zswap_rb_search(root, offset);
+	entry = zswap_rb_search(tree, offset);
 	if (entry)
 		zswap_entry_get(entry);
 
@@ -435,7 +456,7 @@ static int zswap_evict_entry(struct zbud_pool *pool, unsigned long handle)
 
 	/* find zswap entry */
 	spin_lock(&tree->lock);
-	entry = zswap_rb_search(&tree->rbroot, offset);
+	entry = zswap_rb_search(tree, offset);
 	if (!entry) {
 		/* entry was invalidated */
 		spin_unlock(&tree->lock);
@@ -444,10 +465,7 @@ static int zswap_evict_entry(struct zbud_pool *pool, unsigned long handle)
 	BUG_ON(offset != entry->offset);
 
 	/* remove from rbtree */
-	zswap_rb_erase(&tree->rbroot, entry);
-
-	/* drop initial reference */
-	zswap_entry_put(tree, entry);
+	zswap_rb_erase(tree, entry);
 
 	zswap_evicted_pages++;
 
@@ -532,12 +550,11 @@ static int zswap_frontswap_store(unsigned type, pgoff_t offset,
 	/* map */
 	spin_lock(&tree->lock);
 	do {
-		ret = zswap_rb_insert(&tree->rbroot, entry, &dupentry);
+		ret = zswap_rb_insert(tree, entry, &dupentry);
 		if (ret == -EEXIST) {
 			zswap_duplicate_entry++;
 			/* remove from rbtree */
-			zswap_rb_erase(&tree->rbroot, dupentry);
-			zswap_entry_put(tree, dupentry);
+			zswap_rb_erase(tree, dupentry);
 		}
 	} while (ret == -EEXIST);
 	spin_unlock(&tree->lock);
@@ -570,7 +587,7 @@ static int zswap_frontswap_load(unsigned type, pgoff_t offset,
 
 	/* find */
 	spin_lock(&tree->lock);
-	entry = zswap_entry_find_get(&tree->rbroot, offset);
+	entry = zswap_rb_search_get(tree, offset);
 	if (!entry) {
 		/* entry was evicted */
 		spin_unlock(&tree->lock);
@@ -604,7 +621,7 @@ static void zswap_frontswap_invalidate_page(unsigned type, pgoff_t offset)
 
 	/* find */
 	spin_lock(&tree->lock);
-	entry = zswap_rb_search(&tree->rbroot, offset);
+	entry = zswap_rb_search(tree, offset);
 	if (!entry) {
 		/* entry was evicted */
 		spin_unlock(&tree->lock);
@@ -612,10 +629,7 @@ static void zswap_frontswap_invalidate_page(unsigned type, pgoff_t offset)
 	}
 
 	/* remove from rbtree */
-	zswap_rb_erase(&tree->rbroot, entry);
-
-	/* drop the initial reference from entry creation */
-	zswap_entry_put(tree, entry);
+	zswap_rb_erase(tree, entry);
 
 	spin_unlock(&tree->lock);
 }
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
