Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx110.postini.com [74.125.245.110])
	by kanga.kvack.org (Postfix) with SMTP id E5FB06B0038
	for <linux-mm@kvack.org>; Mon, 13 May 2013 06:21:31 -0400 (EDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 4/4] mm: Remove lru parameter from __pagevec_lru_add and remove parts of pagevec API
Date: Mon, 13 May 2013 11:21:22 +0100
Message-Id: <1368440482-27909-5-git-send-email-mgorman@suse.de>
In-Reply-To: <1368440482-27909-1-git-send-email-mgorman@suse.de>
References: <1368440482-27909-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexey Lyahkov <alexey.lyashkov@gmail.com>, Andrew Perepechko <anserper@ya.ru>, Robin Dong <sanbai@taobao.com>
Cc: Theodore Tso <tytso@mit.edu>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Bernd Schubert <bernd.schubert@fastmail.fm>, David Howells <dhowells@redhat.com>, Trond Myklebust <Trond.Myklebust@netapp.com>, Linux-fsdevel <linux-fsdevel@vger.kernel.org>, Linux-ext4 <linux-ext4@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, Linux-mm <linux-mm@kvack.org>, Mel Gorman <mgorman@suse.de>

Now that the LRU to add a page to is decided at LRU-add time, remove the
misleading lru parameter from __pagevec_lru_add. A consequence of this is
that the pagevec_lru_add_file, pagevec_lru_add_anon and similar helpers
are misleading as the caller no longer has direct control over what LRU
the page is added to. Unused helpers are removed by this patch and existing
users of pagevec_lru_add_file() are converted to use lru_cache_add_file()
directly and use the per-cpu pagevecs instead of creating their own pagevec.

Signed-off-by: Mel Gorman <mgorman@suse.de>
Reviewed-by: Jan Kara <jack@suse.cz>
---
 fs/cachefiles/rdwr.c    | 30 +++++++-----------------------
 fs/nfs/dir.c            |  7 ++-----
 include/linux/pagevec.h | 34 +---------------------------------
 mm/swap.c               | 12 ++++--------
 4 files changed, 14 insertions(+), 69 deletions(-)

diff --git a/fs/cachefiles/rdwr.c b/fs/cachefiles/rdwr.c
index 4809922..d24c13e 100644
--- a/fs/cachefiles/rdwr.c
+++ b/fs/cachefiles/rdwr.c
@@ -12,6 +12,7 @@
 #include <linux/mount.h>
 #include <linux/slab.h>
 #include <linux/file.h>
+#include <linux/swap.h>
 #include "internal.h"
 
 /*
@@ -227,8 +228,7 @@ static void cachefiles_read_copier(struct fscache_operation *_op)
  */
 static int cachefiles_read_backing_file_one(struct cachefiles_object *object,
 					    struct fscache_retrieval *op,
-					    struct page *netpage,
-					    struct pagevec *pagevec)
+					    struct page *netpage)
 {
 	struct cachefiles_one_read *monitor;
 	struct address_space *bmapping;
@@ -237,8 +237,6 @@ static int cachefiles_read_backing_file_one(struct cachefiles_object *object,
 
 	_enter("");
 
-	pagevec_reinit(pagevec);
-
 	_debug("read back %p{%lu,%d}",
 	       netpage, netpage->index, page_count(netpage));
 
@@ -283,9 +281,7 @@ installed_new_backing_page:
 	backpage = newpage;
 	newpage = NULL;
 
-	page_cache_get(backpage);
-	pagevec_add(pagevec, backpage);
-	__pagevec_lru_add_file(pagevec);
+	lru_cache_add_file(backpage);
 
 read_backing_page:
 	ret = bmapping->a_ops->readpage(NULL, backpage);
@@ -452,8 +448,7 @@ int cachefiles_read_or_alloc_page(struct fscache_retrieval *op,
 	if (block) {
 		/* submit the apparently valid page to the backing fs to be
 		 * read from disk */
-		ret = cachefiles_read_backing_file_one(object, op, page,
-						       &pagevec);
+		ret = cachefiles_read_backing_file_one(object, op, page);
 	} else if (cachefiles_has_space(cache, 0, 1) == 0) {
 		/* there's space in the cache we can use */
 		fscache_mark_page_cached(op, page);
@@ -482,14 +477,11 @@ static int cachefiles_read_backing_file(struct cachefiles_object *object,
 {
 	struct cachefiles_one_read *monitor = NULL;
 	struct address_space *bmapping = object->backer->d_inode->i_mapping;
-	struct pagevec lru_pvec;
 	struct page *newpage = NULL, *netpage, *_n, *backpage = NULL;
 	int ret = 0;
 
 	_enter("");
 
-	pagevec_init(&lru_pvec, 0);
-
 	list_for_each_entry_safe(netpage, _n, list, lru) {
 		list_del(&netpage->lru);
 
@@ -534,9 +526,7 @@ static int cachefiles_read_backing_file(struct cachefiles_object *object,
 		backpage = newpage;
 		newpage = NULL;
 
-		page_cache_get(backpage);
-		if (!pagevec_add(&lru_pvec, backpage))
-			__pagevec_lru_add_file(&lru_pvec);
+		lru_cache_add_file(backpage);
 
 	reread_backing_page:
 		ret = bmapping->a_ops->readpage(NULL, backpage);
@@ -559,9 +549,7 @@ static int cachefiles_read_backing_file(struct cachefiles_object *object,
 			goto nomem;
 		}
 
-		page_cache_get(netpage);
-		if (!pagevec_add(&lru_pvec, netpage))
-			__pagevec_lru_add_file(&lru_pvec);
+		lru_cache_add_file(netpage);
 
 		/* install a monitor */
 		page_cache_get(netpage);
@@ -643,9 +631,7 @@ static int cachefiles_read_backing_file(struct cachefiles_object *object,
 
 		fscache_mark_page_cached(op, netpage);
 
-		page_cache_get(netpage);
-		if (!pagevec_add(&lru_pvec, netpage))
-			__pagevec_lru_add_file(&lru_pvec);
+		lru_cache_add_file(netpage);
 
 		/* the netpage is unlocked and marked up to date here */
 		fscache_end_io(op, netpage, 0);
@@ -661,8 +647,6 @@ static int cachefiles_read_backing_file(struct cachefiles_object *object,
 
 out:
 	/* tidy up */
-	pagevec_lru_add_file(&lru_pvec);
-
 	if (newpage)
 		page_cache_release(newpage);
 	if (netpage)
diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index f23f455..787d89c 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -33,6 +33,7 @@
 #include <linux/pagevec.h>
 #include <linux/namei.h>
 #include <linux/mount.h>
+#include <linux/swap.h>
 #include <linux/sched.h>
 #include <linux/kmemleak.h>
 #include <linux/xattr.h>
@@ -1757,7 +1758,6 @@ EXPORT_SYMBOL_GPL(nfs_unlink);
  */
 int nfs_symlink(struct inode *dir, struct dentry *dentry, const char *symname)
 {
-	struct pagevec lru_pvec;
 	struct page *page;
 	char *kaddr;
 	struct iattr attr;
@@ -1797,11 +1797,8 @@ int nfs_symlink(struct inode *dir, struct dentry *dentry, const char *symname)
 	 * No big deal if we can't add this page to the page cache here.
 	 * READLINK will get the missing page from the server if needed.
 	 */
-	pagevec_init(&lru_pvec, 0);
-	if (!add_to_page_cache(page, dentry->d_inode->i_mapping, 0,
+	if (!add_to_page_cache_lru(page, dentry->d_inode->i_mapping, 0,
 							GFP_KERNEL)) {
-		pagevec_add(&lru_pvec, page);
-		pagevec_lru_add_file(&lru_pvec);
 		SetPageUptodate(page);
 		unlock_page(page);
 	} else
diff --git a/include/linux/pagevec.h b/include/linux/pagevec.h
index 2aa12b8..e4dbfab3 100644
--- a/include/linux/pagevec.h
+++ b/include/linux/pagevec.h
@@ -21,7 +21,7 @@ struct pagevec {
 };
 
 void __pagevec_release(struct pagevec *pvec);
-void __pagevec_lru_add(struct pagevec *pvec, enum lru_list lru);
+void __pagevec_lru_add(struct pagevec *pvec);
 unsigned pagevec_lookup(struct pagevec *pvec, struct address_space *mapping,
 		pgoff_t start, unsigned nr_pages);
 unsigned pagevec_lookup_tag(struct pagevec *pvec,
@@ -64,36 +64,4 @@ static inline void pagevec_release(struct pagevec *pvec)
 		__pagevec_release(pvec);
 }
 
-static inline void __pagevec_lru_add_anon(struct pagevec *pvec)
-{
-	__pagevec_lru_add(pvec, LRU_INACTIVE_ANON);
-}
-
-static inline void __pagevec_lru_add_active_anon(struct pagevec *pvec)
-{
-	__pagevec_lru_add(pvec, LRU_ACTIVE_ANON);
-}
-
-static inline void __pagevec_lru_add_file(struct pagevec *pvec)
-{
-	__pagevec_lru_add(pvec, LRU_INACTIVE_FILE);
-}
-
-static inline void __pagevec_lru_add_active_file(struct pagevec *pvec)
-{
-	__pagevec_lru_add(pvec, LRU_ACTIVE_FILE);
-}
-
-static inline void pagevec_lru_add_file(struct pagevec *pvec)
-{
-	if (pagevec_count(pvec))
-		__pagevec_lru_add_file(pvec);
-}
-
-static inline void pagevec_lru_add_anon(struct pagevec *pvec)
-{
-	if (pagevec_count(pvec))
-		__pagevec_lru_add_anon(pvec);
-}
-
 #endif /* _LINUX_PAGEVEC_H */
diff --git a/mm/swap.c b/mm/swap.c
index 7752407..bd4f524 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -499,7 +499,7 @@ void __lru_cache_add(struct page *page, enum lru_list lru)
 
 	page_cache_get(page);
 	if (!pagevec_space(pvec))
-		__pagevec_lru_add(pvec, lru);
+		__pagevec_lru_add(pvec);
 	pagevec_add(pvec, page);
 	put_cpu_var(lru_add_pvec);
 }
@@ -622,7 +622,7 @@ void lru_add_drain_cpu(int cpu)
 	struct pagevec *pvec = &per_cpu(lru_add_pvec, cpu);
 
 	if (pagevec_count(pvec))
-		__pagevec_lru_add(pvec, NR_LRU_LISTS);
+		__pagevec_lru_add(pvec);
 
 	pvec = &per_cpu(lru_rotate_pvecs, cpu);
 	if (pagevec_count(pvec)) {
@@ -821,12 +821,10 @@ void lru_add_page_tail(struct page *page, struct page *page_tail,
 static void __pagevec_lru_add_fn(struct page *page, struct lruvec *lruvec,
 				 void *arg)
 {
-	enum lru_list requested_lru = (enum lru_list)arg;
 	int file = page_is_file_cache(page);
 	int active = PageActive(page);
 	enum lru_list lru = page_lru(page);
 
-	WARN_ON_ONCE(requested_lru < NR_LRU_LISTS && requested_lru != lru);
 	VM_BUG_ON(PageUnevictable(page));
 	VM_BUG_ON(PageLRU(page));
 
@@ -840,11 +838,9 @@ static void __pagevec_lru_add_fn(struct page *page, struct lruvec *lruvec,
  * Add the passed pages to the LRU, then drop the caller's refcount
  * on them.  Reinitialises the caller's pagevec.
  */
-void __pagevec_lru_add(struct pagevec *pvec, enum lru_list lru)
+void __pagevec_lru_add(struct pagevec *pvec)
 {
-	VM_BUG_ON(is_unevictable_lru(lru));
-
-	pagevec_lru_move_fn(pvec, __pagevec_lru_add_fn, (void *)lru);
+	pagevec_lru_move_fn(pvec, __pagevec_lru_add_fn, NULL);
 }
 EXPORT_SYMBOL(__pagevec_lru_add);
 
-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
