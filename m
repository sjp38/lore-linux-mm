Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9B7306B02A2
	for <linux-mm@kvack.org>; Wed, 22 Nov 2017 16:09:52 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id i123so17307921pgd.2
        for <linux-mm@kvack.org>; Wed, 22 Nov 2017 13:09:52 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id f13si13909617pgp.663.2017.11.22.13.08.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Nov 2017 13:08:20 -0800 (PST)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH 47/62] xfs: Convert mru cache to XArray
Date: Wed, 22 Nov 2017 13:07:24 -0800
Message-Id: <20171122210739.29916-48-willy@infradead.org>
In-Reply-To: <20171122210739.29916-1-willy@infradead.org>
References: <20171122210739.29916-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>

From: Matthew Wilcox <mawilcox@microsoft.com>

This eliminates a call to radix_tree_preload().

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 fs/xfs/xfs_mru_cache.c | 71 +++++++++++++++++++++++++-------------------------
 1 file changed, 35 insertions(+), 36 deletions(-)

diff --git a/fs/xfs/xfs_mru_cache.c b/fs/xfs/xfs_mru_cache.c
index f8a674d7f092..d665ac490045 100644
--- a/fs/xfs/xfs_mru_cache.c
+++ b/fs/xfs/xfs_mru_cache.c
@@ -101,10 +101,9 @@
  * an infinite loop in the code.
  */
 struct xfs_mru_cache {
-	struct radix_tree_root	store;     /* Core storage data structure.  */
+	struct xarray		store;     /* Core storage data structure.  */
 	struct list_head	*lists;    /* Array of lists, one per grp.  */
 	struct list_head	reap_list; /* Elements overdue for reaping. */
-	spinlock_t		lock;      /* Lock to protect this struct.  */
 	unsigned int		grp_count; /* Number of discrete groups.    */
 	unsigned int		grp_time;  /* Time period spanned by grps.  */
 	unsigned int		lru_grp;   /* Group containing time zero.   */
@@ -232,22 +231,24 @@ _xfs_mru_cache_list_insert(
  * data store, removing it from the reap list, calling the client's free
  * function and deleting the element from the element zone.
  *
- * We get called holding the mru->lock, which we drop and then reacquire.
- * Sparse need special help with this to tell it we know what we are doing.
+ * We get called holding the mru->store lock, which we drop and then reacquire.
+ * Sparse needs special help with this to tell it we know what we are doing.
  */
 STATIC void
 _xfs_mru_cache_clear_reap_list(
 	struct xfs_mru_cache	*mru)
-		__releases(mru->lock) __acquires(mru->lock)
+		__releases(mru->store) __acquires(mru->store)
 {
+	XA_STATE(xas, 0);
 	struct xfs_mru_cache_elem *elem, *next;
 	struct list_head	tmp;
 
 	INIT_LIST_HEAD(&tmp);
 	list_for_each_entry_safe(elem, next, &mru->reap_list, list_node) {
+		xas_set(&xas, elem->key);
 
 		/* Remove the element from the data store. */
-		radix_tree_delete(&mru->store, elem->key);
+		xas_store(&mru->store, &xas, NULL);
 
 		/*
 		 * remove to temp list so it can be freed without
@@ -255,14 +256,14 @@ _xfs_mru_cache_clear_reap_list(
 		 */
 		list_move(&elem->list_node, &tmp);
 	}
-	spin_unlock(&mru->lock);
+	xa_unlock(&mru->store);
 
 	list_for_each_entry_safe(elem, next, &tmp, list_node) {
 		list_del_init(&elem->list_node);
 		mru->free_func(elem);
 	}
 
-	spin_lock(&mru->lock);
+	xa_lock(&mru->store);
 }
 
 /*
@@ -284,7 +285,7 @@ _xfs_mru_cache_reap(
 	if (!mru || !mru->lists)
 		return;
 
-	spin_lock(&mru->lock);
+	xa_lock(&mru->store);
 	next = _xfs_mru_cache_migrate(mru, jiffies);
 	_xfs_mru_cache_clear_reap_list(mru);
 
@@ -298,7 +299,7 @@ _xfs_mru_cache_reap(
 		queue_delayed_work(xfs_mru_reap_wq, &mru->work, next);
 	}
 
-	spin_unlock(&mru->lock);
+	xa_unlock(&mru->store);
 }
 
 int
@@ -358,13 +359,8 @@ xfs_mru_cache_create(
 	for (grp = 0; grp < mru->grp_count; grp++)
 		INIT_LIST_HEAD(mru->lists + grp);
 
-	/*
-	 * We use GFP_KERNEL radix tree preload and do inserts under a
-	 * spinlock so GFP_ATOMIC is appropriate for the radix tree itself.
-	 */
-	INIT_RADIX_TREE(&mru->store, GFP_ATOMIC);
+	xa_init(&mru->store);
 	INIT_LIST_HEAD(&mru->reap_list);
-	spin_lock_init(&mru->lock);
 	INIT_DELAYED_WORK(&mru->work, _xfs_mru_cache_reap);
 
 	mru->grp_time  = grp_time;
@@ -394,17 +390,17 @@ xfs_mru_cache_flush(
 	if (!mru || !mru->lists)
 		return;
 
-	spin_lock(&mru->lock);
+	xa_lock(&mru->store);
 	if (mru->queued) {
-		spin_unlock(&mru->lock);
+		xa_unlock(&mru->store);
 		cancel_delayed_work_sync(&mru->work);
-		spin_lock(&mru->lock);
+		xa_lock(&mru->store);
 	}
 
 	_xfs_mru_cache_migrate(mru, jiffies + mru->grp_count * mru->grp_time);
 	_xfs_mru_cache_clear_reap_list(mru);
 
-	spin_unlock(&mru->lock);
+	xa_unlock(&mru->store);
 }
 
 void
@@ -431,24 +427,25 @@ xfs_mru_cache_insert(
 	unsigned long		key,
 	struct xfs_mru_cache_elem *elem)
 {
+	XA_STATE(xas, key);
 	int			error;
 
 	ASSERT(mru && mru->lists);
 	if (!mru || !mru->lists)
 		return -EINVAL;
 
-	if (radix_tree_preload(GFP_NOFS))
-		return -ENOMEM;
-
 	INIT_LIST_HEAD(&elem->list_node);
 	elem->key = key;
 
-	spin_lock(&mru->lock);
-	error = radix_tree_insert(&mru->store, key, elem);
-	radix_tree_preload_end();
+retry:
+	xa_lock(&mru->store);
+	xas_store(&mru->store, &xas, elem);
+	error = xas_error(&xas);
 	if (!error)
 		_xfs_mru_cache_list_insert(mru, elem);
-	spin_unlock(&mru->lock);
+	xa_unlock(&mru->store);
+	if (xas_nomem(&xas, GFP_NOFS))
+		goto retry;
 
 	return error;
 }
@@ -464,17 +461,18 @@ xfs_mru_cache_remove(
 	struct xfs_mru_cache	*mru,
 	unsigned long		key)
 {
+	XA_STATE(xas, key);
 	struct xfs_mru_cache_elem *elem;
 
 	ASSERT(mru && mru->lists);
 	if (!mru || !mru->lists)
 		return NULL;
 
-	spin_lock(&mru->lock);
-	elem = radix_tree_delete(&mru->store, key);
+	xa_lock(&mru->store);
+	elem = xas_store(&mru->store, &xas, NULL);
 	if (elem)
 		list_del(&elem->list_node);
-	spin_unlock(&mru->lock);
+	xa_unlock(&mru->store);
 
 	return elem;
 }
@@ -520,20 +518,21 @@ xfs_mru_cache_lookup(
 	struct xfs_mru_cache	*mru,
 	unsigned long		key)
 {
+	XA_STATE(xas, key);
 	struct xfs_mru_cache_elem *elem;
 
 	ASSERT(mru && mru->lists);
 	if (!mru || !mru->lists)
 		return NULL;
 
-	spin_lock(&mru->lock);
-	elem = radix_tree_lookup(&mru->store, key);
+	xa_lock(&mru->store);
+	elem = xas_load(&mru->store, &xas);
 	if (elem) {
 		list_del(&elem->list_node);
 		_xfs_mru_cache_list_insert(mru, elem);
-		__release(mru_lock); /* help sparse not be stupid */
+		__release(&mru->store); /* help sparse not be stupid */
 	} else
-		spin_unlock(&mru->lock);
+		xa_unlock(&mru->store);
 
 	return elem;
 }
@@ -546,7 +545,7 @@ xfs_mru_cache_lookup(
 void
 xfs_mru_cache_done(
 	struct xfs_mru_cache	*mru)
-		__releases(mru->lock)
+		__releases(mru->store)
 {
-	spin_unlock(&mru->lock);
+	xa_unlock(&mru->store);
 }
-- 
2.15.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
