Date: Wed, 25 Jun 2008 19:14:54 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [-mm][PATCH 10/10] putback_lru_page()/unevictable page handling rework v4
In-Reply-To: <20080625191014.D86A.KOSAKI.MOTOHIRO@jp.fujitsu.com>
References: <20080625185717.D84C.KOSAKI.MOTOHIRO@jp.fujitsu.com> <20080625191014.D86A.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Message-Id: <20080625191237.D86D.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Rik van Riel <riel@redhat.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroy@jp.fujitsu.com>

Agghh, typo to kamezawa-san's e-mail.
resend this patch.


===========================================================
putback_lru_page()/unevictable page handling rework.

Changelog
================
V3 -> V4
   o fix broken recheck logic in putback_lru_page().
   o fix shmem_lock() prototype.

V2 -> V3
   o remove lock_page() from scan_mapping_unevictable_pages() and
     scan_zone_unevictable_pages().
   o revert ipc/shm.c mm/shmem.c change of SHMEM unevictable patch.
     it become unnecessary by this patch.

V1 -> V2
   o undo unintented comment killing.
   o move putback_lru_page() from move_to_new_page() to unmap_and_move().
   o folded depend patch
       http://marc.info/?l=linux-mm&m=121337119621958&w=2
       http://marc.info/?l=linux-kernel&m=121362782406478&w=2
       http://marc.info/?l=linux-mm&m=121377572909776&w=2


Now, putback_lru_page() requires that the page is locked.
And in some special case, implicitly unlock it.

This patch tries to make putback_lru_pages() to be lock_page() free.
(Of course, some callers must take the lock.)

The main reason that putback_lru_page() assumes that page is locked
is to avoid the change in page's status among Mlocked/Not-Mlocked.

Once it is added to unevictable list, the page is removed from
unevictable list only when page is munlocked. (there are other special
case. but we ignore the special case.)
So, status change during putback_lru_page() is fatal and page should 
be locked.

putback_lru_page() in this patch has a new concepts.
When it adds page to unevictable list, it checks the status is 
changed or not again. if changed, retry to putback.

This patche changes also caller side and cleaning up lock/unlock_page().

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

---
 include/linux/mm.h |    9 +---
 ipc/shm.c          |   16 -------
 mm/internal.h      |    2 
 mm/migrate.c       |   60 +++++++++------------------
 mm/mlock.c         |   51 +++++++++++++----------
 mm/shmem.c         |    9 +---
 mm/vmscan.c        |  114 +++++++++++++++++++++++------------------------------
 7 files changed, 110 insertions(+), 151 deletions(-)

Index: b/mm/vmscan.c
===================================================================
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -486,31 +486,21 @@ int remove_mapping(struct address_space 
  * Page may still be unevictable for other reasons.
  *
  * lru_lock must not be held, interrupts must be enabled.
- * Must be called with page locked.
- *
- * return 1 if page still locked [not truncated], else 0
  */
-int putback_lru_page(struct page *page)
+#ifdef CONFIG_UNEVICTABLE_LRU
+void putback_lru_page(struct page *page)
 {
 	int lru;
-	int ret = 1;
 	int was_unevictable;
 
-	VM_BUG_ON(!PageLocked(page));
 	VM_BUG_ON(PageLRU(page));
 
+	was_unevictable = TestClearPageUnevictable(page);
+
+redo:
 	lru = !!TestClearPageActive(page);
-	was_unevictable = TestClearPageUnevictable(page); /* for page_evictable() */
 
-	if (unlikely(!page->mapping)) {
-		/*
-		 * page truncated.  drop lock as put_page() will
-		 * free the page.
-		 */
-		VM_BUG_ON(page_count(page) != 1);
-		unlock_page(page);
-		ret = 0;
-	} else if (page_evictable(page, NULL)) {
+	if (page_evictable(page, NULL)) {
 		/*
 		 * For evictable pages, we can use the cache.
 		 * In event of a race, worst case is we end up with an
@@ -519,40 +509,55 @@ int putback_lru_page(struct page *page)
 		 */
 		lru += page_is_file_cache(page);
 		lru_cache_add_lru(page, lru);
-		mem_cgroup_move_lists(page, lru);
-#ifdef CONFIG_UNEVICTABLE_LRU
-		if (was_unevictable)
-			count_vm_event(NORECL_PGRESCUED);
-#endif
 	} else {
 		/*
 		 * Put unevictable pages directly on zone's unevictable
 		 * list.
 		 */
+		lru = LRU_UNEVICTABLE;
 		add_page_to_unevictable_list(page);
-		mem_cgroup_move_lists(page, LRU_UNEVICTABLE);
-#ifdef CONFIG_UNEVICTABLE_LRU
-		if (!was_unevictable)
-			count_vm_event(NORECL_PGCULLED);
-#endif
 	}
 
+	mem_cgroup_move_lists(page, lru);
+
+	/*
+	 * page's status can change while we move it among lru. If an evictable
+	 * page is on unevictable list, it never be freed. To avoid that,
+	 * check after we added it to the list, again.
+	 */
+	if (lru == LRU_UNEVICTABLE && page_evictable(page, NULL)) {
+		if (!isolate_lru_page(page)) {
+			ClearPageUnevictable(page);
+			put_page(page);
+			goto redo;
+		}
+		/* This means someone else dropped this page from LRU
+		 * So, it will be freed or putback to LRU again. There is
+		 * nothing to do here.
+		 */
+	}
+
+	if (was_unevictable && lru != LRU_UNEVICTABLE)
+		count_vm_event(NORECL_PGRESCUED);
+	else if (!was_unevictable && lru == LRU_UNEVICTABLE)
+		count_vm_event(NORECL_PGCULLED);
+
 	put_page(page);		/* drop ref from isolate */
-	return ret;		/* ret => "page still locked" */
 }
 
-/*
- * Cull page that shrink_*_list() has detected to be unevictable
- * under page lock to close races with other tasks that might be making
- * the page evictable.  Avoid stranding an evictable page on the
- * unevictable list.
- */
-static void cull_unevictable_page(struct page *page)
+#else
+
+void putback_lru_page(struct page *page)
 {
-	lock_page(page);
-	if (putback_lru_page(page))
-		unlock_page(page);
+	int lru;
+	VM_BUG_ON(PageLRU(page));
+
+	lru = !!TestClearPageActive(page) + page_is_file_cache(page);
+	lru_cache_add_lru(page, lru);
+	mem_cgroup_move_lists(page, lru);
+	put_page(page);
 }
+#endif
 
 /*
  * shrink_page_list() returns the number of reclaimed pages
@@ -746,8 +751,8 @@ free_it:
 		continue;
 
 cull_mlocked:
-		if (putback_lru_page(page))
-			unlock_page(page);
+		unlock_page(page);
+		putback_lru_page(page);
 		continue;
 
 activate_locked:
@@ -1127,7 +1132,7 @@ static unsigned long shrink_inactive_lis
 			list_del(&page->lru);
 			if (unlikely(!page_evictable(page, NULL))) {
 				spin_unlock_irq(&zone->lru_lock);
-				cull_unevictable_page(page);
+				putback_lru_page(page);
 				spin_lock_irq(&zone->lru_lock);
 				continue;
 			}
@@ -1231,7 +1236,7 @@ static void shrink_active_list(unsigned 
 		list_del(&page->lru);
 
 		if (unlikely(!page_evictable(page, NULL))) {
-			cull_unevictable_page(page);
+			putback_lru_page(page);
 			continue;
 		}
 
@@ -2394,9 +2399,6 @@ int zone_reclaim(struct zone *zone, gfp_
  */
 int page_evictable(struct page *page, struct vm_area_struct *vma)
 {
-
-	VM_BUG_ON(PageUnevictable(page));
-
 	if (mapping_unevictable(page_mapping(page)))
 		return 0;
 
@@ -2452,8 +2454,8 @@ static void show_page_path(struct page *
  */
 static void check_move_unevictable_page(struct page *page, struct zone *zone)
 {
-
-	ClearPageUnevictable(page); /* for page_evictable() */
+retry:
+	ClearPageUnevictable(page);
 	if (page_evictable(page, NULL)) {
 		enum lru_list l = LRU_INACTIVE_ANON + page_is_file_cache(page);
 
@@ -2469,6 +2471,8 @@ static void check_move_unevictable_page(
 		 */
 		SetPageUnevictable(page);
 		list_move(&page->lru, &zone->lru[LRU_UNEVICTABLE].list);
+		if (page_evictable(page, NULL))
+			goto retry;
 	}
 }
 
@@ -2508,16 +2512,6 @@ void scan_mapping_unevictable_pages(stru
 				next = page_index;
 			next++;
 
-			if (TestSetPageLocked(page)) {
-				/*
-				 * OK, let's do it the hard way...
-				 */
-				if (zone)
-					spin_unlock_irq(&zone->lru_lock);
-				zone = NULL;
-				lock_page(page);
-			}
-
 			if (pagezone != zone) {
 				if (zone)
 					spin_unlock_irq(&zone->lru_lock);
@@ -2527,9 +2521,6 @@ void scan_mapping_unevictable_pages(stru
 
 			if (PageLRU(page) && PageUnevictable(page))
 				check_move_unevictable_page(page, zone);
-
-			unlock_page(page);
-
 		}
 		if (zone)
 			spin_unlock_irq(&zone->lru_lock);
@@ -2565,15 +2556,10 @@ void scan_zone_unevictable_pages(struct 
 		for (scan = 0;  scan < batch_size; scan++) {
 			struct page *page = lru_to_page(l_unevictable);
 
-			if (TestSetPageLocked(page))
-				continue;
-
 			prefetchw_prev_lru_page(page, l_unevictable, flags);
 
 			if (likely(PageLRU(page) && PageUnevictable(page)))
 				check_move_unevictable_page(page, zone);
-
-			unlock_page(page);
 		}
 		spin_unlock_irq(&zone->lru_lock);
 
Index: b/mm/mlock.c
===================================================================
--- a/mm/mlock.c
+++ b/mm/mlock.c
@@ -55,21 +55,22 @@ EXPORT_SYMBOL(can_do_mlock);
  */
 void __clear_page_mlock(struct page *page)
 {
-	VM_BUG_ON(!PageLocked(page));	/* for LRU isolate/putback */
 
 	dec_zone_page_state(page, NR_MLOCK);
 	count_vm_event(NORECL_PGCLEARED);
-	if (!isolate_lru_page(page)) {
-		putback_lru_page(page);
-	} else {
-		/*
-		 * Page not on the LRU yet.  Flush all pagevecs and retry.
-		 */
-		lru_add_drain_all();
-		if (!isolate_lru_page(page))
+	if (page->mapping) {	/* truncated ? */
+		if (!isolate_lru_page(page)) {
 			putback_lru_page(page);
-		else if (PageUnevictable(page))
-			count_vm_event(NORECL_PGSTRANDED);
+		} else {
+			/*
+			 *Page not on the LRU yet. Flush all pagevecs and retry.
+			 */
+			lru_add_drain_all();
+			if (!isolate_lru_page(page))
+				putback_lru_page(page);
+			else if (PageUnevictable(page))
+				count_vm_event(NORECL_PGSTRANDED);
+		}
 	}
 }
 
@@ -79,7 +80,7 @@ void __clear_page_mlock(struct page *pag
  */
 void mlock_vma_page(struct page *page)
 {
-	BUG_ON(!PageLocked(page));
+	VM_BUG_ON(!page->mapping);
 
 	if (!TestSetPageMlocked(page)) {
 		inc_zone_page_state(page, NR_MLOCK);
@@ -109,7 +110,7 @@ void mlock_vma_page(struct page *page)
  */
 static void munlock_vma_page(struct page *page)
 {
-	BUG_ON(!PageLocked(page));
+	VM_BUG_ON(!page->mapping);
 
 	if (TestClearPageMlocked(page)) {
 		dec_zone_page_state(page, NR_MLOCK);
@@ -169,7 +170,8 @@ static int __mlock_vma_pages_range(struc
 
 		/*
 		 * get_user_pages makes pages present if we are
-		 * setting mlock.
+		 * setting mlock. and this extra reference count will
+		 * disable migration of this page.
 		 */
 		ret = get_user_pages(current, mm, addr,
 				min_t(int, nr_pages, ARRAY_SIZE(pages)),
@@ -197,14 +199,8 @@ static int __mlock_vma_pages_range(struc
 		for (i = 0; i < ret; i++) {
 			struct page *page = pages[i];
 
-			/*
-			 * page might be truncated or migrated out from under
-			 * us.  Check after acquiring page lock.
-			 */
-			lock_page(page);
-			if (page->mapping)
+			if (page_mapcount(page))
 				mlock_vma_page(page);
-			unlock_page(page);
 			put_page(page);		/* ref from get_user_pages() */
 
 			/*
@@ -240,6 +236,9 @@ static int __munlock_pte_handler(pte_t *
 	struct page *page;
 	pte_t pte;
 
+	/*
+	 * page is never be unmapped by page-reclaim. we lock this page now.
+	 */
 retry:
 	pte = *ptep;
 	/*
@@ -261,7 +260,15 @@ retry:
 		goto out;
 
 	lock_page(page);
-	if (!page->mapping) {
+	/*
+	 * Because we lock page here, we have to check 2 cases.
+	 * - the page is migrated.
+	 * - the page is truncated (file-cache only)
+	 * Note: Anonymous page doesn't clear page->mapping even if it
+	 * is removed from rmap.
+	 */
+	if (!page->mapping ||
+	     (PageAnon(page) && !page_mapcount(page))) {
 		unlock_page(page);
 		goto retry;
 	}
Index: b/mm/migrate.c
===================================================================
--- a/mm/migrate.c
+++ b/mm/migrate.c
@@ -67,9 +67,7 @@ int putback_lru_pages(struct list_head *
 
 	list_for_each_entry_safe(page, page2, l, lru) {
 		list_del(&page->lru);
-		lock_page(page);
-		if (putback_lru_page(page))
-			unlock_page(page);
+		putback_lru_page(page);
 		count++;
 	}
 	return count;
@@ -579,7 +577,6 @@ static int fallback_migrate_page(struct 
 static int move_to_new_page(struct page *newpage, struct page *page)
 {
 	struct address_space *mapping;
-	int unlock = 1;
 	int rc;
 
 	/*
@@ -614,16 +611,10 @@ static int move_to_new_page(struct page 
 
 	if (!rc) {
 		remove_migration_ptes(page, newpage);
-		/*
-		 * Put back on LRU while holding page locked to
-		 * handle potential race with, e.g., munlock()
-		 */
-		unlock = putback_lru_page(newpage);
 	} else
 		newpage->mapping = NULL;
 
-	if (unlock)
-		unlock_page(newpage);
+	unlock_page(newpage);
 
 	return rc;
 }
@@ -640,19 +631,18 @@ static int unmap_and_move(new_page_t get
 	struct page *newpage = get_new_page(page, private, &result);
 	int rcu_locked = 0;
 	int charge = 0;
-	int unlock = 1;
 
 	if (!newpage)
 		return -ENOMEM;
 
 	if (page_count(page) == 1)
 		/* page was freed from under us. So we are done. */
-		goto end_migration;
+		goto move_newpage;
 
 	charge = mem_cgroup_prepare_migration(page, newpage);
 	if (charge == -ENOMEM) {
 		rc = -ENOMEM;
-		goto end_migration;
+		goto move_newpage;
 	}
 	/* prepare cgroup just returns 0 or -ENOMEM */
 	BUG_ON(charge);
@@ -660,7 +650,7 @@ static int unmap_and_move(new_page_t get
 	rc = -EAGAIN;
 	if (TestSetPageLocked(page)) {
 		if (!force)
-			goto end_migration;
+			goto move_newpage;
 		lock_page(page);
 	}
 
@@ -721,39 +711,29 @@ rcu_unlock:
 		rcu_read_unlock();
 
 unlock:
+	unlock_page(page);
 
 	if (rc != -EAGAIN) {
  		/*
- 		 * A page that has been migrated has all references
- 		 * removed and will be freed. A page that has not been
- 		 * migrated will have kepts its references and be
- 		 * restored.
- 		 */
- 		list_del(&page->lru);
-		if (!page->mapping) {
-			VM_BUG_ON(page_count(page) != 1);
-			unlock_page(page);
-			put_page(page);		/* just free the old page */
-			goto end_migration;
-		} else
-			unlock = putback_lru_page(page);
+		 * A page that has been migrated has all references
+		 * removed and will be freed. A page that has not been
+		 * migrated will have kepts its references and be
+		 * restored.
+		 */
+		list_del(&page->lru);
+		putback_lru_page(page);
 	}
 
-	if (unlock)
-		unlock_page(page);
-
-end_migration:
+move_newpage:
 	if (!charge)
 		mem_cgroup_end_migration(newpage);
 
-	if (!newpage->mapping) {
-		/*
-		 * Migration failed or was never attempted.
-		 * Free the newpage.
-		 */
-		VM_BUG_ON(page_count(newpage) != 1);
-		put_page(newpage);
-	}
+	/*
+	 * Move the new page to the LRU. If migration was not successful
+	 * then this will free the page.
+	 */
+	putback_lru_page(newpage);
+
 	if (result) {
 		if (rc)
 			*result = rc;
Index: b/mm/internal.h
===================================================================
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -43,7 +43,7 @@ static inline void __put_page(struct pag
  * in mm/vmscan.c:
  */
 extern int isolate_lru_page(struct page *page);
-extern int putback_lru_page(struct page *page);
+extern void putback_lru_page(struct page *page);
 
 /*
  * in mm/page_alloc.c
Index: b/ipc/shm.c
===================================================================
--- a/ipc/shm.c
+++ b/ipc/shm.c
@@ -737,7 +737,6 @@ asmlinkage long sys_shmctl(int shmid, in
 	case SHM_LOCK:
 	case SHM_UNLOCK:
 	{
-		struct address_space *mapping = NULL;
 		struct file *uninitialized_var(shm_file);
 
 		lru_add_drain_all();  /* drain pagevecs to lru lists */
@@ -769,29 +768,18 @@ asmlinkage long sys_shmctl(int shmid, in
 		if(cmd==SHM_LOCK) {
 			struct user_struct * user = current->user;
 			if (!is_file_hugepages(shp->shm_file)) {
-				mapping = shmem_lock(shp->shm_file, 1, user);
-				if (IS_ERR(mapping))
-					err = PTR_ERR(mapping);
-				mapping = NULL;
+				err = shmem_lock(shp->shm_file, 1, user);
 				if (!err && !(shp->shm_perm.mode & SHM_LOCKED)){
 					shp->shm_perm.mode |= SHM_LOCKED;
 					shp->mlock_user = user;
 				}
 			}
 		} else if (!is_file_hugepages(shp->shm_file)) {
-			mapping = shmem_lock(shp->shm_file, 0, shp->mlock_user);
+			shmem_lock(shp->shm_file, 0, shp->mlock_user);
 			shp->shm_perm.mode &= ~SHM_LOCKED;
 			shp->mlock_user = NULL;
-			if (mapping) {
-				shm_file = shp->shm_file;
-				get_file(shm_file);	/* hold across unlock */
-			}
 		}
 		shm_unlock(shp);
-		if (mapping) {
-			scan_mapping_unevictable_pages(mapping);
-			fput(shm_file);
-		}
 		goto out;
 	}
 	case IPC_RMID:
Index: b/mm/shmem.c
===================================================================
--- a/mm/shmem.c
+++ b/mm/shmem.c
@@ -1474,12 +1474,11 @@ static struct mempolicy *shmem_get_polic
 }
 #endif
 
-struct address_space *shmem_lock(struct file *file, int lock,
-				 struct user_struct *user)
+int shmem_lock(struct file *file, int lock, struct user_struct *user)
 {
 	struct inode *inode = file->f_path.dentry->d_inode;
 	struct shmem_inode_info *info = SHMEM_I(inode);
-	struct address_space *retval = ERR_PTR(-ENOMEM);
+	int retval = -ENOMEM;
 
 	spin_lock(&info->lock);
 	if (lock && !(info->flags & VM_LOCKED)) {
@@ -1487,14 +1486,14 @@ struct address_space *shmem_lock(struct 
 			goto out_nomem;
 		info->flags |= VM_LOCKED;
 		mapping_set_unevictable(file->f_mapping);
-		retval = NULL;
 	}
 	if (!lock && (info->flags & VM_LOCKED) && user) {
 		user_shm_unlock(inode->i_size, user);
 		info->flags &= ~VM_LOCKED;
 		mapping_clear_unevictable(file->f_mapping);
-		retval = file->f_mapping;
+		scan_mapping_unevictable_pages(file->f_mapping);
 	}
+	retval = 0;
 out_nomem:
 	spin_unlock(&info->lock);
 	return retval;
Index: b/include/linux/mm.h
===================================================================
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -706,13 +706,12 @@ static inline int page_mapped(struct pag
 extern void show_free_areas(void);
 
 #ifdef CONFIG_SHMEM
-extern struct address_space *shmem_lock(struct file *file, int lock,
-					struct user_struct *user);
+extern int shmem_lock(struct file *file, int lock, struct user_struct *user);
 #else
-static inline struct address_space *shmem_lock(struct file *file, int lock,
-					struct user_struct *user)
+static inline int shmem_lock(struct file *file, int lock,
+			     struct user_struct *user)
 {
-	return NULL;
+	return 0;
 }
 #endif
 struct file *shmem_file_setup(char *name, loff_t size, unsigned long flags);


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
