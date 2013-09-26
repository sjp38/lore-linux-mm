Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f43.google.com (mail-pa0-f43.google.com [209.85.220.43])
	by kanga.kvack.org (Postfix) with ESMTP id F2FA36B0031
	for <linux-mm@kvack.org>; Wed, 25 Sep 2013 23:43:52 -0400 (EDT)
Received: by mail-pa0-f43.google.com with SMTP id hz1so710602pad.16
        for <linux-mm@kvack.org>; Wed, 25 Sep 2013 20:43:52 -0700 (PDT)
Received: from epcpsbgm1.samsung.com (epcpsbgm1 [203.254.230.26])
 by mailout4.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0MTP007GCRP05030@mailout4.samsung.com> for
 linux-mm@kvack.org; Thu, 26 Sep 2013 12:43:48 +0900 (KST)
From: Weijie Yang <weijie.yang@samsung.com>
References: <000201ceb836$4c549740$e4fdc5c0$%yang@samsung.com>
 <20130924010308.GG17725@bbox>
In-reply-to: <20130924010308.GG17725@bbox>
Subject: RE: [PATCH v3 2/3] mm/zswap: bugfix: memory leak when invalidate and
 reclaim occur concurrently
Date: Thu, 26 Sep 2013 11:42:17 +0800
Message-id: <000001ceba6a$997d0490$cc770db0$%yang@samsung.com>
MIME-version: 1.0
Content-type: text/plain; charset=Windows-1252
Content-transfer-encoding: 7bit
Content-language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Minchan Kim' <minchan@kernel.org>
Cc: akpm@linux-foundation.org, sjenning@linux.vnet.ibm.com, bob.liu@oracle.com, weijie.yang.kh@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, stable@vger.kernel.org, d.j.shin@samsung.com, heesub.shin@samsung.com, kyungmin.park@samsung.com, hau.chen@samsung.com, bifeng.tong@samsung.com, rui.xie@samsung.com

On Tue, Sep 24, 2013 at 9:03 AM, Minchan Kim <minchan@kernel.org> wrote: 
> On Mon, Sep 23, 2013 at 04:21:49PM +0800, Weijie Yang wrote:
> >
> > Modify:
> >  - check the refcount in fail path, free memory if it is not referenced.
> 
> Hmm, I don't like this because zswap refcount routine is already mess for me.
> I'm not sure why it was designed from the beginning. I hope we should fix it first.
> 
> 1. zswap_rb_serach could include zswap_entry_get semantic if it founds a entry from
>    the tree. Of course, we should ranme it as find_get_zswap_entry like find_get_page.
> 2. zswap_entry_put could hide resource free function like zswap_free_entry so that
>    all of caller can use it easily following pattern.
> 
>   find_get_zswap_entry
>   ...
>   ...
>   zswap_entry_put
> 
> Of course, zswap_entry_put have to check the entry is in the tree or not
> so if someone already removes it from the tree, it should avoid double remove.
> 
> One of the concern I can think is that approach extends critical section
> but I think it would be no problem because more bottleneck would be [de]compress
> functions. If it were really problem, we can mitigate a problem with moving
> unnecessary functions out of zswap_free_entry because it seem to be rather
> over-enginnering.

I refactor the zswap refcount routine according to Minchan's idea.
Here is the new patch, Any suggestion is welcomed.

To Seth and Bob, would you please review it again?

mm/zswap.c |  116
++++++++++++++++++++++++++++++++++++++++++++++++++++----------------------------------------------------------------
 1 file changed, 52 insertions(+), 64 deletions(-)

diff --git a/mm/zswap.c b/mm/zswap.c
old mode 100644
new mode 100755
index deda2b6..bd04910
--- a/mm/zswap.c
+++ b/mm/zswap.c
@@ -217,6 +217,7 @@ static struct zswap_entry *zswap_entry_cache_alloc(gfp_t gfp)
 	if (!entry)
 		return NULL;
 	entry->refcount = 1;
+	RB_CLEAR_NODE(&entry->rbnode);
 	return entry;
 }
 
@@ -232,10 +233,20 @@ static void zswap_entry_get(struct zswap_entry *entry)
 }
 
 /* caller must hold the tree lock */
-static int zswap_entry_put(struct zswap_entry *entry)
+static int zswap_entry_put(struct zswap_tree *tree, struct zswap_entry *entry)
 {
-	entry->refcount--;
-	return entry->refcount;
+	int refcount = --entry->refcount;
+
+	if (refcount <= 0) {
+		if (!RB_EMPTY_NODE(&entry->rbnode)) {
+			rb_erase(&entry->rbnode, &tree->rbroot);
+			RB_CLEAR_NODE(&entry->rbnode);
+		}
+
+		zswap_free_entry(tree, entry);
+	}
+
+	return refcount;
 }
 
 /*********************************
@@ -258,6 +269,17 @@ static struct zswap_entry *zswap_rb_search(struct rb_root *root, pgoff_t offset)
 	return NULL;
 }
 
+static struct zswap_entry *zswap_entry_find_get(struct rb_root *root, pgoff_t offset)
+{
+	struct zswap_entry *entry = NULL;
+
+	entry = zswap_rb_search(root, offset);
+	if (entry)
+		zswap_entry_get(entry);
+
+	return entry;
+}
+
 /*
  * In the case that a entry with the same offset is found, a pointer to
  * the existing entry is stored in dupentry and the function returns -EEXIST
@@ -387,7 +409,7 @@ static void zswap_free_entry(struct zswap_tree *tree, struct zswap_entry *entry)
 enum zswap_get_swap_ret {
 	ZSWAP_SWAPCACHE_NEW,
 	ZSWAP_SWAPCACHE_EXIST,
-	ZSWAP_SWAPCACHE_NOMEM
+	ZSWAP_SWAPCACHE_FAIL,
 };
 
 /*
@@ -401,9 +423,9 @@ enum zswap_get_swap_ret {
  * added to the swap cache, and returned in retpage.
  *
  * If success, the swap cache page is returned in retpage
- * Returns 0 if page was already in the swap cache, page is not locked
- * Returns 1 if the new page needs to be populated, page is locked
- * Returns <0 on error
+ * Returns ZSWAP_SWAPCACHE_EXIST if page was already in the swap cache
+ * Returns ZSWAP_SWAPCACHE_NEW if the new page needs to be populated, page is locked
+ * Returns ZSWAP_SWAPCACHE_FAIL on error
  */
 static int zswap_get_swap_cache_page(swp_entry_t entry,
 				struct page **retpage)
@@ -475,7 +497,7 @@ static int zswap_get_swap_cache_page(swp_entry_t entry,
 	if (new_page)
 		page_cache_release(new_page);
 	if (!found_page)
-		return ZSWAP_SWAPCACHE_NOMEM;
+		return ZSWAP_SWAPCACHE_FAIL;
 	*retpage = found_page;
 	return ZSWAP_SWAPCACHE_EXIST;
 }
@@ -517,23 +539,22 @@ static int zswap_writeback_entry(struct zbud_pool *pool, unsigned long handle)
 
 	/* find and ref zswap entry */
 	spin_lock(&tree->lock);
-	entry = zswap_rb_search(&tree->rbroot, offset);
+	entry = zswap_entry_find_get(&tree->rbroot, offset);
 	if (!entry) {
 		/* entry was invalidated */
 		spin_unlock(&tree->lock);
 		return 0;
 	}
-	zswap_entry_get(entry);
 	spin_unlock(&tree->lock);
 	BUG_ON(offset != entry->offset);
 
 	/* try to allocate swap cache page */
 	switch (zswap_get_swap_cache_page(swpentry, &page)) {
-	case ZSWAP_SWAPCACHE_NOMEM: /* no memory */
+	case ZSWAP_SWAPCACHE_FAIL: /* no memory or invalidate happened */
 		ret = -ENOMEM;
 		goto fail;
 
-	case ZSWAP_SWAPCACHE_EXIST: /* page is unlocked */
+	case ZSWAP_SWAPCACHE_EXIST:
 		/* page is already in the swap cache, ignore for now */
 		page_cache_release(page);
 		ret = -EEXIST;
@@ -562,38 +583,28 @@ static int zswap_writeback_entry(struct zbud_pool *pool, unsigned long handle)
 	zswap_written_back_pages++;
 
 	spin_lock(&tree->lock);
-
 	/* drop local reference */
-	zswap_entry_put(entry);
+	refcount = zswap_entry_put(tree, entry);
 	/* drop the initial reference from entry creation */
-	refcount = zswap_entry_put(entry);
-
-	/*
-	 * There are three possible values for refcount here:
-	 * (1) refcount is 1, load is in progress, unlink from rbtree,
-	 *     load will free
-	 * (2) refcount is 0, (normal case) entry is valid,
-	 *     remove from rbtree and free entry
-	 * (3) refcount is -1, invalidate happened during writeback,
-	 *     free entry
-	 */
-	if (refcount >= 0) {
-		/* no invalidate yet, remove from rbtree */
+	if (refcount > 0) {
 		rb_erase(&entry->rbnode, &tree->rbroot);
+		RB_CLEAR_NODE(&entry->rbnode);
+		refcount = zswap_entry_put(tree, entry);
 	}
 	spin_unlock(&tree->lock);
-	if (refcount <= 0) {
-		/* free the entry */
-		zswap_free_entry(tree, entry);
-		return 0;
-	}
-	return -EAGAIN;
+
+	goto end;
 
 fail:
 	spin_lock(&tree->lock);
-	zswap_entry_put(entry);
+	refcount = zswap_entry_put(tree, entry);
 	spin_unlock(&tree->lock);
-	return ret;
+
+end:
+	if (refcount <= 0)
+		return 0;
+	else
+		return -EAGAIN;
 }
 
 /*********************************
@@ -677,10 +688,8 @@ static int zswap_frontswap_store(unsigned type, pgoff_t offset,
 			zswap_duplicate_entry++;
 			/* remove from rbtree */
 			rb_erase(&dupentry->rbnode, &tree->rbroot);
-			if (!zswap_entry_put(dupentry)) {
-				/* free */
-				zswap_free_entry(tree, dupentry);
-			}
+			RB_CLEAR_NODE(&dupentry->rbnode);
+			zswap_entry_put(tree, dupentry);
 		}
 	} while (ret == -EEXIST);
 	spin_unlock(&tree->lock);
@@ -713,13 +722,12 @@ static int zswap_frontswap_load(unsigned type, pgoff_t offset,
 
 	/* find */
 	spin_lock(&tree->lock);
-	entry = zswap_rb_search(&tree->rbroot, offset);
+	entry = zswap_entry_find_get(&tree->rbroot, offset);
 	if (!entry) {
 		/* entry was written back */
 		spin_unlock(&tree->lock);
 		return -1;
 	}
-	zswap_entry_get(entry);
 	spin_unlock(&tree->lock);
 
 	/* decompress */
@@ -734,22 +742,9 @@ static int zswap_frontswap_load(unsigned type, pgoff_t offset,
 	BUG_ON(ret);
 
 	spin_lock(&tree->lock);
-	refcount = zswap_entry_put(entry);
-	if (likely(refcount)) {
-		spin_unlock(&tree->lock);
-		return 0;
-	}
+	zswap_entry_put(tree, entry);
 	spin_unlock(&tree->lock);
 
-	/*
-	 * We don't have to unlink from the rbtree because
-	 * zswap_writeback_entry() or zswap_frontswap_invalidate page()
-	 * has already done this for us if we are the last reference.
-	 */
-	/* free */
-
-	zswap_free_entry(tree, entry);
-
 	return 0;
 }
 
@@ -771,19 +766,12 @@ static void zswap_frontswap_invalidate_page(unsigned type, pgoff_t offset)
 
 	/* remove from rbtree */
 	rb_erase(&entry->rbnode, &tree->rbroot);
+	RB_CLEAR_NODE(&entry->rbnode);
 
 	/* drop the initial reference from entry creation */
-	refcount = zswap_entry_put(entry);
+	zswap_entry_put(tree, entry);
 
 	spin_unlock(&tree->lock);
-
-	if (refcount) {
-		/* writeback in progress, writeback will free */
-		return;
-	}
-
-	/* free */
-	zswap_free_entry(tree, entry);
 }
 
 /* frees all zswap entries for the given swap type */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
