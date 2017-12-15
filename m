Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f200.google.com (mail-yb0-f200.google.com [209.85.213.200])
	by kanga.kvack.org (Postfix) with ESMTP id 95CF06B0287
	for <linux-mm@kvack.org>; Fri, 15 Dec 2017 17:05:56 -0500 (EST)
Received: by mail-yb0-f200.google.com with SMTP id u5so7994016ybm.6
        for <linux-mm@kvack.org>; Fri, 15 Dec 2017 14:05:56 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id c73si1444370ywh.761.2017.12.15.14.05.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 15 Dec 2017 14:05:55 -0800 (PST)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH v5 78/78] fscache: Convert to XArray
Date: Fri, 15 Dec 2017 14:04:50 -0800
Message-Id: <20171215220450.7899-79-willy@infradead.org>
In-Reply-To: <20171215220450.7899-1-willy@infradead.org>
References: <20171215220450.7899-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, David Howells <dhowells@redhat.com>, Shaohua Li <shli@kernel.org>, Jens Axboe <axboe@kernel.dk>, Rehas Sachdeva <aquannie@gmail.com>, Marc Zyngier <marc.zyngier@arm.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, linux-f2fs-devel@lists.sourceforge.net, linux-nilfs@vger.kernel.org, linux-btrfs@vger.kernel.org, linux-xfs@vger.kernel.org, linux-usb@vger.kernel.org, linux-raid@vger.kernel.org

From: Matthew Wilcox <mawilcox@microsoft.com>

Removes another user of radix_tree_preload().

Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>
---
 fs/fscache/cookie.c     |   6 +-
 fs/fscache/internal.h   |   2 +-
 fs/fscache/object.c     |   2 +-
 fs/fscache/page.c       | 152 +++++++++++++++++++++---------------------------
 fs/fscache/stats.c      |   6 +-
 include/linux/fscache.h |   8 +--
 6 files changed, 76 insertions(+), 100 deletions(-)

diff --git a/fs/fscache/cookie.c b/fs/fscache/cookie.c
index e9054e0c1a49..6d45134d609e 100644
--- a/fs/fscache/cookie.c
+++ b/fs/fscache/cookie.c
@@ -109,9 +109,7 @@ struct fscache_cookie *__fscache_acquire_cookie(
 	cookie->netfs_data	= netfs_data;
 	cookie->flags		= (1 << FSCACHE_COOKIE_NO_DATA_YET);
 
-	/* radix tree insertion won't use the preallocation pool unless it's
-	 * told it may not wait */
-	INIT_RADIX_TREE(&cookie->stores, GFP_NOFS & ~__GFP_DIRECT_RECLAIM);
+	xa_init(&cookie->stores);
 
 	switch (cookie->def->type) {
 	case FSCACHE_COOKIE_TYPE_INDEX:
@@ -608,7 +606,7 @@ void __fscache_relinquish_cookie(struct fscache_cookie *cookie, bool retire)
 	/* Clear pointers back to the netfs */
 	cookie->netfs_data	= NULL;
 	cookie->def		= NULL;
-	BUG_ON(!radix_tree_empty(&cookie->stores));
+	BUG_ON(!xa_empty(&cookie->stores));
 
 	if (cookie->parent) {
 		ASSERTCMP(atomic_read(&cookie->parent->usage), >, 0);
diff --git a/fs/fscache/internal.h b/fs/fscache/internal.h
index 0ff4b49a0037..468d9bd7f8c3 100644
--- a/fs/fscache/internal.h
+++ b/fs/fscache/internal.h
@@ -200,7 +200,7 @@ extern atomic_t fscache_n_stores_oom;
 extern atomic_t fscache_n_store_ops;
 extern atomic_t fscache_n_store_calls;
 extern atomic_t fscache_n_store_pages;
-extern atomic_t fscache_n_store_radix_deletes;
+extern atomic_t fscache_n_store_xarray_deletes;
 extern atomic_t fscache_n_store_pages_over_limit;
 
 extern atomic_t fscache_n_store_vmscan_not_storing;
diff --git a/fs/fscache/object.c b/fs/fscache/object.c
index aa0e71f02c33..ed165736a358 100644
--- a/fs/fscache/object.c
+++ b/fs/fscache/object.c
@@ -956,7 +956,7 @@ static const struct fscache_state *_fscache_invalidate_object(struct fscache_obj
 	 * retire the object instead.
 	 */
 	if (!fscache_use_cookie(object)) {
-		ASSERT(radix_tree_empty(&object->cookie->stores));
+		ASSERT(xa_empty(&object->cookie->stores));
 		set_bit(FSCACHE_OBJECT_RETIRED, &object->flags);
 		_leave(" [no cookie]");
 		return transit_to(KILL_OBJECT);
diff --git a/fs/fscache/page.c b/fs/fscache/page.c
index 961029e04027..315e2745f822 100644
--- a/fs/fscache/page.c
+++ b/fs/fscache/page.c
@@ -22,13 +22,7 @@
  */
 bool __fscache_check_page_write(struct fscache_cookie *cookie, struct page *page)
 {
-	void *val;
-
-	rcu_read_lock();
-	val = radix_tree_lookup(&cookie->stores, page->index);
-	rcu_read_unlock();
-
-	return val != NULL;
+	return xa_load(&cookie->stores, page->index) != NULL;
 }
 EXPORT_SYMBOL(__fscache_check_page_write);
 
@@ -64,15 +58,15 @@ bool __fscache_maybe_release_page(struct fscache_cookie *cookie,
 				  struct page *page,
 				  gfp_t gfp)
 {
+	XA_STATE(xas, &cookie->stores, page->index);
 	struct page *xpage;
-	void *val;
 
 	_enter("%p,%p,%x", cookie, page, gfp);
 
 try_again:
 	rcu_read_lock();
-	val = radix_tree_lookup(&cookie->stores, page->index);
-	if (!val) {
+	xpage = xas_load(&xas);
+	if (!xpage) {
 		rcu_read_unlock();
 		fscache_stat(&fscache_n_store_vmscan_not_storing);
 		__fscache_uncache_page(cookie, page);
@@ -81,31 +75,32 @@ bool __fscache_maybe_release_page(struct fscache_cookie *cookie,
 
 	/* see if the page is actually undergoing storage - if so we can't get
 	 * rid of it till the cache has finished with it */
-	if (radix_tree_tag_get(&cookie->stores, page->index,
-			       FSCACHE_COOKIE_STORING_TAG)) {
+	if (xas_get_tag(&xas, FSCACHE_COOKIE_STORING_TAG)) {
 		rcu_read_unlock();
+		xas_retry(&xas, XA_RETRY_ENTRY);
 		goto page_busy;
 	}
 
 	/* the page is pending storage, so we attempt to cancel the store and
 	 * discard the store request so that the page can be reclaimed */
-	spin_lock(&cookie->stores_lock);
+	xas_retry(&xas, XA_RETRY_ENTRY);
+	xas_lock(&xas);
 	rcu_read_unlock();
 
-	if (radix_tree_tag_get(&cookie->stores, page->index,
-			       FSCACHE_COOKIE_STORING_TAG)) {
+	xpage = xas_load(&xas);
+	if (xas_get_tag(&xas, FSCACHE_COOKIE_STORING_TAG)) {
 		/* the page started to undergo storage whilst we were looking,
 		 * so now we can only wait or return */
 		spin_unlock(&cookie->stores_lock);
 		goto page_busy;
 	}
 
-	xpage = radix_tree_delete(&cookie->stores, page->index);
+	xas_store(&xas, NULL);
 	spin_unlock(&cookie->stores_lock);
 
 	if (xpage) {
 		fscache_stat(&fscache_n_store_vmscan_cancelled);
-		fscache_stat(&fscache_n_store_radix_deletes);
+		fscache_stat(&fscache_n_store_xarray_deletes);
 		ASSERTCMP(xpage, ==, page);
 	} else {
 		fscache_stat(&fscache_n_store_vmscan_gone);
@@ -149,17 +144,19 @@ static void fscache_end_page_write(struct fscache_object *object,
 	spin_lock(&object->lock);
 	cookie = object->cookie;
 	if (cookie) {
+		XA_STATE(xas, &cookie->stores, page->index);
 		/* delete the page from the tree if it is now no longer
 		 * pending */
-		spin_lock(&cookie->stores_lock);
-		radix_tree_tag_clear(&cookie->stores, page->index,
-				     FSCACHE_COOKIE_STORING_TAG);
-		if (!radix_tree_tag_get(&cookie->stores, page->index,
-					FSCACHE_COOKIE_PENDING_TAG)) {
-			fscache_stat(&fscache_n_store_radix_deletes);
-			xpage = radix_tree_delete(&cookie->stores, page->index);
+		xas_lock(&xas);
+		xpage = xas_load(&xas);
+		xas_clear_tag(&xas, FSCACHE_COOKIE_STORING_TAG);
+		if (xas_get_tag(&xas, FSCACHE_COOKIE_PENDING_TAG)) {
+			xpage = NULL;
+		} else {
+			fscache_stat(&fscache_n_store_xarray_deletes);
+			xas_store(&xas, NULL);
 		}
-		spin_unlock(&cookie->stores_lock);
+		xas_unlock(&xas);
 		wake_up_bit(&cookie->flags, 0);
 	}
 	spin_unlock(&object->lock);
@@ -765,13 +762,12 @@ static void fscache_release_write_op(struct fscache_operation *_op)
  */
 static void fscache_write_op(struct fscache_operation *_op)
 {
+	XA_STATE(xas, NULL, 0);
 	struct fscache_storage *op =
 		container_of(_op, struct fscache_storage, op);
 	struct fscache_object *object = op->op.object;
 	struct fscache_cookie *cookie;
 	struct page *page;
-	unsigned n;
-	void *results[1];
 	int ret;
 
 	_enter("{OP%x,%d}", op->op.debug_id, atomic_read(&op->op.usage));
@@ -804,29 +800,25 @@ static void fscache_write_op(struct fscache_operation *_op)
 		return;
 	}
 
-	spin_lock(&cookie->stores_lock);
+	xas.xa = &cookie->stores;
+	xas_lock(&xas);
 
 	fscache_stat(&fscache_n_store_calls);
 
 	/* find a page to store */
-	page = NULL;
-	n = radix_tree_gang_lookup_tag(&cookie->stores, results, 0, 1,
-				       FSCACHE_COOKIE_PENDING_TAG);
-	if (n != 1)
+	page = xas_find_tag(&xas, ULONG_MAX, FSCACHE_COOKIE_PENDING_TAG);
+	if (!page)
 		goto superseded;
-	page = results[0];
-	_debug("gang %d [%lx]", n, page->index);
+	_debug("found %lx", page->index);
 	if (page->index >= op->store_limit) {
 		fscache_stat(&fscache_n_store_pages_over_limit);
 		goto superseded;
 	}
 
-	radix_tree_tag_set(&cookie->stores, page->index,
-			   FSCACHE_COOKIE_STORING_TAG);
-	radix_tree_tag_clear(&cookie->stores, page->index,
-			     FSCACHE_COOKIE_PENDING_TAG);
+	xas_set_tag(&xas, FSCACHE_COOKIE_STORING_TAG);
+	xas_clear_tag(&xas, FSCACHE_COOKIE_PENDING_TAG);
+	xas_unlock(&xas);
 
-	spin_unlock(&cookie->stores_lock);
 	spin_unlock(&object->lock);
 
 	fscache_stat(&fscache_n_store_pages);
@@ -848,7 +840,7 @@ static void fscache_write_op(struct fscache_operation *_op)
 	/* this writer is going away and there aren't any more things to
 	 * write */
 	_debug("cease");
-	spin_unlock(&cookie->stores_lock);
+	xas_unlock(&xas);
 	clear_bit(FSCACHE_OBJECT_PENDING_WRITE, &object->flags);
 	spin_unlock(&object->lock);
 	fscache_op_complete(&op->op, true);
@@ -860,32 +852,25 @@ static void fscache_write_op(struct fscache_operation *_op)
  */
 void fscache_invalidate_writes(struct fscache_cookie *cookie)
 {
+	XA_STATE(xas, &cookie->stores, 0);
+	unsigned int cleared = 0;
 	struct page *page;
-	void *results[16];
-	int n, i;
 
 	_enter("");
 
-	for (;;) {
-		spin_lock(&cookie->stores_lock);
-		n = radix_tree_gang_lookup_tag(&cookie->stores, results, 0,
-					       ARRAY_SIZE(results),
-					       FSCACHE_COOKIE_PENDING_TAG);
-		if (n == 0) {
-			spin_unlock(&cookie->stores_lock);
-			break;
-		}
-
-		for (i = n - 1; i >= 0; i--) {
-			page = results[i];
-			radix_tree_delete(&cookie->stores, page->index);
-		}
+	xas_lock(&xas);
+	xas_for_each_tag(&xas, page, ULONG_MAX, FSCACHE_COOKIE_PENDING_TAG) {
+		xas_store(&xas, NULL);
+		put_page(page);
+		if (++cleared % XA_CHECK_SCHED)
+			continue;
 
-		spin_unlock(&cookie->stores_lock);
-
-		for (i = n - 1; i >= 0; i--)
-			put_page(results[i]);
+		xas_pause(&xas);
+		xas_unlock(&xas);
+		cond_resched();
+		xas_lock(&xas);
 	}
+	xas_unlock(&xas);
 
 	wake_up_bit(&cookie->flags, 0);
 
@@ -925,9 +910,11 @@ int __fscache_write_page(struct fscache_cookie *cookie,
 			 struct page *page,
 			 gfp_t gfp)
 {
+	XA_STATE(xas, &cookie->stores, page->index);
 	struct fscache_storage *op;
 	struct fscache_object *object;
 	bool wake_cookie = false;
+	struct page *xpage;
 	int ret;
 
 	_enter("%p,%x,", cookie, (u32) page->flags);
@@ -952,10 +939,7 @@ int __fscache_write_page(struct fscache_cookie *cookie,
 		(1 << FSCACHE_OP_WAITING) |
 		(1 << FSCACHE_OP_UNUSE_COOKIE);
 
-	ret = radix_tree_maybe_preload(gfp & ~__GFP_HIGHMEM);
-	if (ret < 0)
-		goto nomem_free;
-
+retry:
 	ret = -ENOBUFS;
 	spin_lock(&cookie->lock);
 
@@ -967,23 +951,19 @@ int __fscache_write_page(struct fscache_cookie *cookie,
 	if (test_bit(FSCACHE_IOERROR, &object->cache->flags))
 		goto nobufs;
 
-	/* add the page to the pending-storage radix tree on the backing
-	 * object */
+	/* add the page to the pending-storage xarray on the backing object */
 	spin_lock(&object->lock);
-	spin_lock(&cookie->stores_lock);
+	xas_lock(&xas);
 
 	_debug("store limit %llx", (unsigned long long) object->store_limit);
 
-	ret = radix_tree_insert(&cookie->stores, page->index, page);
-	if (ret < 0) {
-		if (ret == -EEXIST)
-			goto already_queued;
-		_debug("insert failed %d", ret);
+	xpage = xas_create(&xas);
+	if (xpage)
+		goto already_queued;
+	if (xas_error(&xas))
 		goto nobufs_unlock_obj;
-	}
-
-	radix_tree_tag_set(&cookie->stores, page->index,
-			   FSCACHE_COOKIE_PENDING_TAG);
+	xas_store(&xas, page);
+	xas_set_tag(&xas, FSCACHE_COOKIE_PENDING_TAG);
 	get_page(page);
 
 	/* we only want one writer at a time, but we do need to queue new
@@ -991,7 +971,7 @@ int __fscache_write_page(struct fscache_cookie *cookie,
 	if (test_and_set_bit(FSCACHE_OBJECT_PENDING_WRITE, &object->flags))
 		goto already_pending;
 
-	spin_unlock(&cookie->stores_lock);
+	xas_unlock(&xas);
 	spin_unlock(&object->lock);
 
 	op->op.debug_id	= atomic_inc_return(&fscache_op_debug_id);
@@ -1002,7 +982,6 @@ int __fscache_write_page(struct fscache_cookie *cookie,
 		goto submit_failed;
 
 	spin_unlock(&cookie->lock);
-	radix_tree_preload_end();
 	fscache_stat(&fscache_n_store_ops);
 	fscache_stat(&fscache_n_stores_ok);
 
@@ -1014,30 +993,31 @@ int __fscache_write_page(struct fscache_cookie *cookie,
 already_queued:
 	fscache_stat(&fscache_n_stores_again);
 already_pending:
-	spin_unlock(&cookie->stores_lock);
+	xas_unlock(&xas);
 	spin_unlock(&object->lock);
 	spin_unlock(&cookie->lock);
-	radix_tree_preload_end();
 	fscache_put_operation(&op->op);
 	fscache_stat(&fscache_n_stores_ok);
 	_leave(" = 0");
 	return 0;
 
 submit_failed:
-	spin_lock(&cookie->stores_lock);
-	radix_tree_delete(&cookie->stores, page->index);
-	spin_unlock(&cookie->stores_lock);
+	xa_erase(&cookie->stores, page->index);
 	wake_cookie = __fscache_unuse_cookie(cookie);
 	put_page(page);
 	ret = -ENOBUFS;
 	goto nobufs;
 
 nobufs_unlock_obj:
-	spin_unlock(&cookie->stores_lock);
+	xas_unlock(&xas);
 	spin_unlock(&object->lock);
+	spin_unlock(&cookie->lock);
+	if (xas_nomem(&xas, gfp))
+		goto retry;
+	goto nobufs2;
 nobufs:
 	spin_unlock(&cookie->lock);
-	radix_tree_preload_end();
+nobufs2:
 	fscache_put_operation(&op->op);
 	if (wake_cookie)
 		__fscache_wake_unused_cookie(cookie);
@@ -1045,8 +1025,6 @@ int __fscache_write_page(struct fscache_cookie *cookie,
 	_leave(" = -ENOBUFS");
 	return -ENOBUFS;
 
-nomem_free:
-	fscache_put_operation(&op->op);
 nomem:
 	fscache_stat(&fscache_n_stores_oom);
 	_leave(" = -ENOMEM");
diff --git a/fs/fscache/stats.c b/fs/fscache/stats.c
index 7ac6e839b065..9c012b4229cd 100644
--- a/fs/fscache/stats.c
+++ b/fs/fscache/stats.c
@@ -63,7 +63,7 @@ atomic_t fscache_n_stores_oom;
 atomic_t fscache_n_store_ops;
 atomic_t fscache_n_store_calls;
 atomic_t fscache_n_store_pages;
-atomic_t fscache_n_store_radix_deletes;
+atomic_t fscache_n_store_xarray_deletes;
 atomic_t fscache_n_store_pages_over_limit;
 
 atomic_t fscache_n_store_vmscan_not_storing;
@@ -232,11 +232,11 @@ static int fscache_stats_show(struct seq_file *m, void *v)
 		   atomic_read(&fscache_n_stores_again),
 		   atomic_read(&fscache_n_stores_nobufs),
 		   atomic_read(&fscache_n_stores_oom));
-	seq_printf(m, "Stores : ops=%u run=%u pgs=%u rxd=%u olm=%u\n",
+	seq_printf(m, "Stores : ops=%u run=%u pgs=%u xar=%u olm=%u\n",
 		   atomic_read(&fscache_n_store_ops),
 		   atomic_read(&fscache_n_store_calls),
 		   atomic_read(&fscache_n_store_pages),
-		   atomic_read(&fscache_n_store_radix_deletes),
+		   atomic_read(&fscache_n_store_xarray_deletes),
 		   atomic_read(&fscache_n_store_pages_over_limit));
 
 	seq_printf(m, "VmScan : nos=%u gon=%u bsy=%u can=%u wt=%u\n",
diff --git a/include/linux/fscache.h b/include/linux/fscache.h
index 6a2f631a913f..74ea31368c09 100644
--- a/include/linux/fscache.h
+++ b/include/linux/fscache.h
@@ -22,7 +22,7 @@
 #include <linux/list.h>
 #include <linux/pagemap.h>
 #include <linux/pagevec.h>
-#include <linux/radix-tree.h>
+#include <linux/xarray.h>
 
 #if defined(CONFIG_FSCACHE) || defined(CONFIG_FSCACHE_MODULE)
 #define fscache_available() (1)
@@ -175,9 +175,9 @@ struct fscache_cookie {
 	const struct fscache_cookie_def	*def;		/* definition */
 	struct fscache_cookie		*parent;	/* parent of this entry */
 	void				*netfs_data;	/* back pointer to netfs */
-	struct radix_tree_root		stores;		/* pages to be stored on this cookie */
-#define FSCACHE_COOKIE_PENDING_TAG	0		/* pages tag: pending write to cache */
-#define FSCACHE_COOKIE_STORING_TAG	1		/* pages tag: writing to cache */
+	struct xarray			stores;		/* pages to be stored on this cookie */
+#define FSCACHE_COOKIE_PENDING_TAG	XA_TAG_0	/* pages tag: pending write to cache */
+#define FSCACHE_COOKIE_STORING_TAG	XA_TAG_1	/* pages tag: writing to cache */
 
 	unsigned long			flags;
 #define FSCACHE_COOKIE_LOOKING_UP	0	/* T if non-index cookie being looked up still */
-- 
2.15.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
