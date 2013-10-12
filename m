Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id A1F496B0031
	for <linux-mm@kvack.org>; Sat, 12 Oct 2013 05:39:05 -0400 (EDT)
Received: by mail-pa0-f50.google.com with SMTP id fb1so5500213pad.37
        for <linux-mm@kvack.org>; Sat, 12 Oct 2013 02:39:05 -0700 (PDT)
Received: from epcpsbgm1.samsung.com (epcpsbgm1 [203.254.230.26])
 by mailout3.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0MUJ004FZUT1JFC0@mailout3.samsung.com> for
 linux-mm@kvack.org; Sat, 12 Oct 2013 18:39:01 +0900 (KST)
From: Weijie Yang <weijie.yang@samsung.com>
References: <000201ceb836$4c549740$e4fdc5c0$%yang@samsung.com>
 <20130924010308.GG17725@bbox>
 <000001ceba6a$997d0490$cc770db0$%yang@samsung.com> <20131011071259.GC6847@bbox>
In-reply-to: <20131011071259.GC6847@bbox>
Subject: RE: [PATCH v3 2/3] mm/zswap: bugfix: memory leak when invalidate and
 reclaim occur concurrently
Date: Sat, 12 Oct 2013 17:37:55 +0800
Message-id: <000001cec72e$df422480$9dc66d80$%yang@samsung.com>
MIME-version: 1.0
Content-type: text/plain; charset=Windows-1252
Content-transfer-encoding: 7bit
Content-language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Minchan Kim' <minchan@kernel.org>
Cc: akpm@linux-foundation.org, sjenning@linux.vnet.ibm.com, bob.liu@oracle.com, weijie.yang.kh@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, stable@vger.kernel.org

Hi, all

I thought out a new way to resolve this problem: use CAS instead of refcount.

It not only resolve this problem, but also fix another issue,
can be expanded to support frontswap get_and_free mode easily.
And I use it in an zswap variant which writeback zbud page directly.

If it is accepted, I will resent it instead of the previous refactor patch

please see below, Request For Comments, Thanks.

On Fri, Oct 11, 2013 at 3:13 PM, Minchan Kim <minchan@kernel.org> wrote:
> On Thu, Sep 26, 2013 at 11:42:17AM +0800, Weijie Yang wrote:
> > On Tue, Sep 24, 2013 at 9:03 AM, Minchan Kim <minchan@kernel.org> wrote:
> > > On Mon, Sep 23, 2013 at 04:21:49PM +0800, Weijie Yang wrote:
> > > >
> > > > Modify:
> > > >  - check the refcount in fail path, free memory if it is not referenced.
> > >
> > > Hmm, I don't like this because zswap refcount routine is already mess for me.
> > > I'm not sure why it was designed from the beginning. I hope we should fix it first.
> > >
> > > 1. zswap_rb_serach could include zswap_entry_get semantic if it founds a entry from
> > >    the tree. Of course, we should ranme it as find_get_zswap_entry like find_get_page.
> > > 2. zswap_entry_put could hide resource free function like zswap_free_entry so that
> > >    all of caller can use it easily following pattern.
> > >
> > >   find_get_zswap_entry
> > >   ...
> > >   ...
> > >   zswap_entry_put
> > >
> > > Of course, zswap_entry_put have to check the entry is in the tree or not
> > > so if someone already removes it from the tree, it should avoid double remove.
> > >
> > > One of the concern I can think is that approach extends critical section
> > > but I think it would be no problem because more bottleneck would be [de]compress
> > > functions. If it were really problem, we can mitigate a problem with moving
> > > unnecessary functions out of zswap_free_entry because it seem to be rather
> > > over-enginnering.
> >
> > I refactor the zswap refcount routine according to Minchan's idea.
> > Here is the new patch, Any suggestion is welcomed.
> >
> > To Seth and Bob, would you please review it again?
> 
> Yeah, Seth, Bob. You guys are right persons to review this because this
> scheme was suggested by me who is biased so it couldn't be a fair. ;-)
> But anyway, I will review code itself.

Consider the following scenario:
thread 0: reclaim entry x(get refcount, but not call zswap_get_swap_cache_page)
thread 1: call zswap_frontswap_invalidate_page to invalidate entry x.
	finished, entry x and its zbud is not freed as its refcount != 0
	now, the swap_map[x] = 0
thread 0: now call zswap_get_swap_cache_page
	swapcache_prepare return -ENOENT because entry x is not used any more
	zswap_get_swap_cache_page return ZSWAP_SWAPCACHE_NOMEM
	zswap_writeback_entry do nothing except put refcount
Now, the memory of zswap_entry x and its zpage leak.

Consider the another scenario:
zswap entry x with offset A is already stored in zswap backend.
thread 0: reclaim entry x(get refcount, but not call zswap_get_swap_cache_page)
thread 1: store new page with the same offset A, alloc a new zswap entry y.
	This is a duplicate store and finished.
	shrink_page_list() finish, now the new page is not in swap_cache
thread 0: zswap_get_swap_cache_page get called.
	old page data is added to swap_cache
Now, swap cache has old data rather than new data for offset A.
Error will happen If do_swap_page() get page from swap_cache.

Modify:
 - re-design the zswap_entry concurrent protection by using a CAS-access flag
   instead of the refcount get/put semantic

 - use ZSWAP_SWAPCACHE_FAIL instead of ZSWAP_SWAPCACHE_NOMEM as the fail path
   can be not only caused by nomem but also by invalidate.

Signed-off-by: Weijie Yang <weijie.yang@samsung.com>
---
 mm/zswap.c |  177 +++++++++++++++++++++++++++---------------------------------
 1 file changed, 80 insertions(+), 97 deletions(-)
 mode change 100644 => 100755 mm/zswap.c

diff --git a/mm/zswap.c b/mm/zswap.c
old mode 100644
new mode 100755
index cbd9578..fcaaecb
--- a/mm/zswap.c
+++ b/mm/zswap.c
@@ -158,21 +158,23 @@ static void zswap_comp_exit(void)
  * page within zswap.
  *
  * rbnode - links the entry into red-black tree for the appropriate swap type
- * refcount - the number of outstanding reference to the entry. This is needed
- *            to protect against premature freeing of the entry by code
- *            concurent calls to load, invalidate, and writeback.  The lock
- *            for the zswap_tree structure that contains the entry must
- *            be held while changing the refcount.  Since the lock must
- *            be held, there is no reason to also make refcount atomic.
  * offset - the swap offset for the entry.  Index into the red-black tree.
+ * pos - the position or status of this entry. see below macro definition
+ *    change it by CAS, we hold this entry on success or retry if fail
+ *    protect against concurrent access by load, invalidate or writeback
+ *    even though the probability of concurrent access is very small
  * handle - zsmalloc allocation handle that stores the compressed page data
  * length - the length in bytes of the compressed page data.  Needed during
  *           decompression
  */
+#define POS_POOL      1  /* stay in pool still */
+#define POS_LOAD      2  /* is loading */
+#define POS_RECLAIM   3  /* is reclaiming */
+#define POS_FLUSH     4  /* is invalidating */
 struct zswap_entry {
 	struct rb_node rbnode;
 	pgoff_t offset;
-	int refcount;
+	atomic_t pos;
 	unsigned int length;
 	unsigned long handle;
 };
@@ -216,7 +218,6 @@ static struct zswap_entry *zswap_entry_cache_alloc(gfp_t gfp)
 	entry = kmem_cache_alloc(zswap_entry_cache, gfp);
 	if (!entry)
 		return NULL;
-	entry->refcount = 1;
 	return entry;
 }
 
@@ -225,18 +226,6 @@ static void zswap_entry_cache_free(struct zswap_entry *entry)
 	kmem_cache_free(zswap_entry_cache, entry);
 }
 
-/* caller must hold the tree lock */
-static void zswap_entry_get(struct zswap_entry *entry)
-{
-	entry->refcount++;
-}
-
-/* caller must hold the tree lock */
-static int zswap_entry_put(struct zswap_entry *entry)
-{
-	entry->refcount--;
-	return entry->refcount;
-}
 
 /*********************************
 * rbtree functions
@@ -380,6 +369,23 @@ static void zswap_free_entry(struct zswap_tree *tree, struct zswap_entry *entry)
 	zswap_pool_pages = zbud_get_pool_size(tree->pool);
 }
 
+/* caller must hold the tree lock, entry is on the tree
+* seldom called fortunately
+* return 0: free this entry successfully
+* return < 0: fail
+*/
+static int zswap_invalidate_entry(struct zswap_tree *tree, struct zswap_entry *entry)
+{
+	if (atomic_cmpxchg(&entry->pos, POS_POOL, POS_FLUSH) == POS_POOL) {
+		rb_erase(&entry->rbnode, &tree->rbroot);
+		zswap_free_entry(tree, entry);
+		return 0;
+	}
+
+	/* encounter reclaim called by another thread */
+	return -1;
+}
+
 /*********************************
 * writeback code
 **********************************/
@@ -387,7 +393,7 @@ static void zswap_free_entry(struct zswap_tree *tree, struct zswap_entry *entry)
 enum zswap_get_swap_ret {
 	ZSWAP_SWAPCACHE_NEW,
 	ZSWAP_SWAPCACHE_EXIST,
-	ZSWAP_SWAPCACHE_NOMEM
+	ZSWAP_SWAPCACHE_FAIL,
 };
 
 /*
@@ -401,9 +407,10 @@ enum zswap_get_swap_ret {
  * added to the swap cache, and returned in retpage.
  *
  * If success, the swap cache page is returned in retpage
- * Returns 0 if page was already in the swap cache, page is not locked
- * Returns 1 if the new page needs to be populated, page is locked
- * Returns <0 on error
+ * Returns ZSWAP_SWAPCACHE_EXIST if page was already in the swap cache
+ * Returns ZSWAP_SWAPCACHE_NEW if the new page needs to be populated,
+ * 	the new page is added to swap cache and locked
+ * Returns ZSWAP_SWAPCACHE_FAIL on error
  */
 static int zswap_get_swap_cache_page(swp_entry_t entry,
 				struct page **retpage)
@@ -475,7 +482,7 @@ static int zswap_get_swap_cache_page(swp_entry_t entry,
 	if (new_page)
 		page_cache_release(new_page);
 	if (!found_page)
-		return ZSWAP_SWAPCACHE_NOMEM;
+		return ZSWAP_SWAPCACHE_FAIL;
 	*retpage = found_page;
 	return ZSWAP_SWAPCACHE_EXIST;
 }
@@ -502,7 +509,7 @@ static int zswap_writeback_entry(struct zbud_pool *pool, unsigned long handle)
 	struct page *page;
 	u8 *src, *dst;
 	unsigned int dlen;
-	int ret, refcount;
+	int ret;
 	struct writeback_control wbc = {
 		.sync_mode = WB_SYNC_NONE,
 	};
@@ -523,17 +530,23 @@ static int zswap_writeback_entry(struct zbud_pool *pool, unsigned long handle)
 		spin_unlock(&tree->lock);
 		return 0;
 	}
-	zswap_entry_get(entry);
+	/* maybe encounter load or invalidate called by another thread
+	* hold or give up this entry
+	*/
+	if (atomic_cmpxchg(&entry->pos, POS_POOL, POS_RECLAIM) != POS_POOL) {
+		spin_unlock(&tree->lock);
+		return -EAGAIN;
+	}
 	spin_unlock(&tree->lock);
 	BUG_ON(offset != entry->offset);
 
 	/* try to allocate swap cache page */
 	switch (zswap_get_swap_cache_page(swpentry, &page)) {
-	case ZSWAP_SWAPCACHE_NOMEM: /* no memory */
+	case ZSWAP_SWAPCACHE_FAIL:
 		ret = -ENOMEM;
 		goto fail;
 
-	case ZSWAP_SWAPCACHE_EXIST: /* page is unlocked */
+	case ZSWAP_SWAPCACHE_EXIST:
 		/* page is already in the swap cache, ignore for now */
 		page_cache_release(page);
 		ret = -EEXIST;
@@ -561,38 +574,23 @@ static int zswap_writeback_entry(struct zbud_pool *pool, unsigned long handle)
 	page_cache_release(page);
 	zswap_written_back_pages++;
 
+	/* once we hold this entry and get here, we can free entry safely
+	* during the period which we hold this entry:
+	* 1. if a thread call do_swap_page concurrently
+	* we will get ZSWAP_SWAPCACHE_EXIST returned or
+	* do_swap_page will hit page we added in the swap cache
+	* 2. if a thread call invalidate concurrently
+	* invalidate thread should wait until this function end
+	*/
 	spin_lock(&tree->lock);
-
-	/* drop local reference */
-	zswap_entry_put(entry);
-	/* drop the initial reference from entry creation */
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
-		rb_erase(&entry->rbnode, &tree->rbroot);
-	}
+	rb_erase(&entry->rbnode, &tree->rbroot);
 	spin_unlock(&tree->lock);
-	if (refcount <= 0) {
-		/* free the entry */
-		zswap_free_entry(tree, entry);
-		return 0;
-	}
-	return -EAGAIN;
+	zswap_free_entry(tree, entry);
+
+	return 0;
 
 fail:
-	spin_lock(&tree->lock);
-	zswap_entry_put(entry);
-	spin_unlock(&tree->lock);
+	BUG_ON(atomic_cmpxchg(&entry->pos, POS_RECLAIM, POS_POOL) != POS_RECLAIM);
 	return ret;
 }
 
@@ -668,19 +666,15 @@ static int zswap_frontswap_store(unsigned type, pgoff_t offset,
 	entry->offset = offset;
 	entry->handle = handle;
 	entry->length = dlen;
+	atomic_set(&entry->pos, POS_POOL);
 
 	/* map */
 	spin_lock(&tree->lock);
 	do {
 		ret = zswap_rb_insert(&tree->rbroot, entry, &dupentry);
-		if (ret == -EEXIST) {
-			zswap_duplicate_entry++;
-			/* remove from rbtree */
-			rb_erase(&dupentry->rbnode, &tree->rbroot);
-			if (!zswap_entry_put(dupentry)) {
-				/* free */
-				zswap_free_entry(tree, dupentry);
-			}
+		if (unlikely(ret == -EEXIST)) {
+			if (zswap_invalidate_entry(tree, dupentry) == 0)
+				zswap_duplicate_entry++;
 		}
 	} while (ret == -EEXIST);
 	spin_unlock(&tree->lock);
@@ -709,9 +703,10 @@ static int zswap_frontswap_load(unsigned type, pgoff_t offset,
 	struct zswap_entry *entry;
 	u8 *src, *dst;
 	unsigned int dlen;
-	int refcount, ret;
+	int ret;
 
 	/* find */
+find:
 	spin_lock(&tree->lock);
 	entry = zswap_rb_search(&tree->rbroot, offset);
 	if (!entry) {
@@ -719,7 +714,14 @@ static int zswap_frontswap_load(unsigned type, pgoff_t offset,
 		spin_unlock(&tree->lock);
 		return -1;
 	}
-	zswap_entry_get(entry);
+	/* encounter entry reclaimed by another thread
+	* just retry until that thread get ZSWAP_SWAPCACHE_EXIST returned
+	* as we hold the entry, we can do anything: get or get_and_free
+	*/
+	if (atomic_cmpxchg(&entry->pos, POS_POOL, POS_LOAD) != POS_POOL) {
+		spin_unlock(&tree->lock);
+		goto find;
+	}
 	spin_unlock(&tree->lock);
 
 	/* decompress */
@@ -733,22 +735,7 @@ static int zswap_frontswap_load(unsigned type, pgoff_t offset,
 	zbud_unmap(tree->pool, entry->handle);
 	BUG_ON(ret);
 
-	spin_lock(&tree->lock);
-	refcount = zswap_entry_put(entry);
-	if (likely(refcount)) {
-		spin_unlock(&tree->lock);
-		return 0;
-	}
-	spin_unlock(&tree->lock);
-
-	/*
-	 * We don't have to unlink from the rbtree because
-	 * zswap_writeback_entry() or zswap_frontswap_invalidate page()
-	 * has already done this for us if we are the last reference.
-	 */
-	/* free */
-
-	zswap_free_entry(tree, entry);
+	BUG_ON(atomic_cmpxchg(&entry->pos, POS_LOAD, POS_POOL) != POS_LOAD);
 
 	return 0;
 }
@@ -758,9 +745,9 @@ static void zswap_frontswap_invalidate_page(unsigned type, pgoff_t offset)
 {
 	struct zswap_tree *tree = zswap_trees[type];
 	struct zswap_entry *entry;
-	int refcount;
 
 	/* find */
+find:
 	spin_lock(&tree->lock);
 	entry = zswap_rb_search(&tree->rbroot, offset);
 	if (!entry) {
@@ -769,19 +756,18 @@ static void zswap_frontswap_invalidate_page(unsigned type, pgoff_t offset)
 		return;
 	}
 
+	/* encounter entry reclaimed by another thread
+	* just retry until that reclaim end.
+	*/
+	if (atomic_cmpxchg(&entry->pos, POS_POOL, POS_FLUSH) != POS_POOL) {
+		spin_unlock(&tree->lock);
+		goto find;
+	}
+
 	/* remove from rbtree */
 	rb_erase(&entry->rbnode, &tree->rbroot);
-
-	/* drop the initial reference from entry creation */
-	refcount = zswap_entry_put(entry);
-
 	spin_unlock(&tree->lock);
 
-	if (refcount) {
-		/* writeback in progress, writeback will free */
-		return;
-	}
-
 	/* free */
 	zswap_free_entry(tree, entry);
 }
@@ -809,10 +795,7 @@ static void zswap_frontswap_invalidate_area(unsigned type)
 	 */
 	while ((node = rb_first(&tree->rbroot))) {
 		entry = rb_entry(node, struct zswap_entry, rbnode);
-		rb_erase(&entry->rbnode, &tree->rbroot);
-		zbud_free(tree->pool, entry->handle);
-		zswap_entry_cache_free(entry);
-		atomic_dec(&zswap_stored_pages);
+		zswap_invalidate_entry(tree, entry);
 	}
 	tree->rbroot = RB_ROOT;
 	spin_unlock(&tree->lock);
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
