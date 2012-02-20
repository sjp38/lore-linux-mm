Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx207.postini.com [74.125.245.207])
	by kanga.kvack.org (Postfix) with SMTP id 5B2E66B00EA
	for <linux-mm@kvack.org>; Mon, 20 Feb 2012 12:23:01 -0500 (EST)
Received: by mail-bk0-f41.google.com with SMTP id y12so6268158bkt.14
        for <linux-mm@kvack.org>; Mon, 20 Feb 2012 09:23:00 -0800 (PST)
Subject: [PATCH v2 06/22] mm: deprecate pagevec lru-add functions
From: Konstantin Khlebnikov <khlebnikov@openvz.org>
Date: Mon, 20 Feb 2012 21:22:58 +0400
Message-ID: <20120220172257.22196.41219.stgit@zurg>
In-Reply-To: <20120220171138.22196.65847.stgit@zurg>
References: <20120220171138.22196.65847.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org
Cc: Hugh Dickins <hughd@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

They mostly unused, the last user is fs/cachefiles/rdwr.c
This patch replaces __pagevec_lru_add() with smaller implementation.
It is exported, so we should keep it for a while.

Plus simplify and fix pathetic single-page page-vector operations in
nfs_symlink(), this was second pagevec_lru_add_file() user.

Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
---
 fs/nfs/dir.c            |   10 +++-------
 include/linux/pagevec.h |    4 +++-
 mm/swap.c               |   27 +++++++--------------------
 3 files changed, 13 insertions(+), 28 deletions(-)

diff --git a/fs/nfs/dir.c b/fs/nfs/dir.c
index 0d71eb6..cbbc03c 100644
--- a/fs/nfs/dir.c
+++ b/fs/nfs/dir.c
@@ -1863,7 +1863,6 @@ static int nfs_unlink(struct inode *dir, struct dentry *dentry)
  */
 static int nfs_symlink(struct inode *dir, struct dentry *dentry, const char *symname)
 {
-	struct pagevec lru_pvec;
 	struct page *page;
 	char *kaddr;
 	struct iattr attr;
@@ -1903,15 +1902,12 @@ static int nfs_symlink(struct inode *dir, struct dentry *dentry, const char *sym
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
-	} else
-		__free_page(page);
+	}
+	put_page(page);
 
 	return 0;
 }
diff --git a/include/linux/pagevec.h b/include/linux/pagevec.h
index 2aa12b8..4df37fe 100644
--- a/include/linux/pagevec.h
+++ b/include/linux/pagevec.h
@@ -21,7 +21,6 @@ struct pagevec {
 };
 
 void __pagevec_release(struct pagevec *pvec);
-void __pagevec_lru_add(struct pagevec *pvec, enum lru_list lru);
 unsigned pagevec_lookup(struct pagevec *pvec, struct address_space *mapping,
 		pgoff_t start, unsigned nr_pages);
 unsigned pagevec_lookup_tag(struct pagevec *pvec,
@@ -64,6 +63,9 @@ static inline void pagevec_release(struct pagevec *pvec)
 		__pagevec_release(pvec);
 }
 
+/* Use lru_cache_add_list() instead */
+void __deprecated __pagevec_lru_add(struct pagevec *pvec, enum lru_list lru);
+
 static inline void __pagevec_lru_add_anon(struct pagevec *pvec)
 {
 	__pagevec_lru_add(pvec, LRU_INACTIVE_ANON);
diff --git a/mm/swap.c b/mm/swap.c
index 303fbc3..0d8845c 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -772,33 +772,20 @@ void lru_add_page_tail(struct zone* zone,
 }
 #endif /* CONFIG_TRANSPARENT_HUGEPAGE */
 
-static void __pagevec_lru_add_fn(struct page *page, void *arg)
-{
-	enum lru_list lru = (enum lru_list)arg;
-	struct zone *zone = page_zone(page);
-	int file = is_file_lru(lru);
-	int active = is_active_lru(lru);
-
-	VM_BUG_ON(PageActive(page));
-	VM_BUG_ON(PageUnevictable(page));
-	VM_BUG_ON(PageLRU(page));
-
-	SetPageLRU(page);
-	if (active)
-		SetPageActive(page);
-	update_page_reclaim_stat(zone, page, file, active);
-	add_page_to_lru_list(zone, page, lru);
-}
-
 /*
  * Add the passed pages to the LRU, then drop the caller's refcount
  * on them.  Reinitialises the caller's pagevec.
  */
 void __pagevec_lru_add(struct pagevec *pvec, enum lru_list lru)
 {
-	VM_BUG_ON(is_unevictable_lru(lru));
+	LIST_HEAD(pages);
+	int i;
 
-	pagevec_lru_move_fn(pvec, __pagevec_lru_add_fn, (void *)lru);
+	VM_BUG_ON(is_unevictable_lru(lru));
+	for ( i = 0 ; i < pvec->nr ; i++ )
+		list_add_tail(&pvec->pages[i]->lru, &pages);
+	pagevec_reinit(pvec);
+	__lru_cache_add_list(&pages, lru);
 }
 EXPORT_SYMBOL(__pagevec_lru_add);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
