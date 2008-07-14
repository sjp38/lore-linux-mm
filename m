Date: Tue, 15 Jul 2008 04:13:44 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [mmotm][PATCH 4/9] revert shm change of shm_locked pages are unevictable patch
In-Reply-To: <20080715040402.F6EF.KOSAKI.MOTOHIRO@jp.fujitsu.com>
References: <20080715040402.F6EF.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Message-Id: <20080715041226.F6FB.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>
Cc: kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

Patch title: shm_locked-pages-are-unevictable-revert-shm-change.patch
Against: mmotm Jul 14
Applies after: shm_locked-pages-are-unevictable.patch


shm_locked-pages-are-unevictable.patch changed several shmem code
because that putback_lru_page() had needed page lock.

it has little performance degression and isn't necessary now.
So, reverting is better.

fixup to handle changes to putback_lru_page() change.  Add retry to
loop check_move_unevictable_page().

Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Signed-off-by: Lee Schermerhorn <lee.schermerhorn@hp.com>


 include/linux/mm.h |    9 ++++-----
 ipc/shm.c          |   16 ++--------------
 mm/shmem.c         |   10 +++++-----
 mm/vmscan.c        |   19 +++++--------------
 4 files changed, 16 insertions(+), 38 deletions(-)

Index: b/include/linux/mm.h
===================================================================
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -709,13 +709,12 @@ static inline int page_mapped(struct pag
 extern void show_free_areas(void);
 
 #ifdef CONFIG_SHMEM
-extern struct address_space *shmem_lock(struct file *file, int lock,
-					struct user_struct *user);
+extern int shmem_lock(struct file *file, int lock, struct user_struct *user);
 #else
-static inline struct address_space *shmem_lock(struct file *file, int lock,
-					struct user_struct *user)
+static inline int shmem_lock(struct file *file, int lock,
+			    struct user_struct *user)
 {
-	return NULL;
+	return 0;
 }
 #endif
 struct file *shmem_file_setup(char *name, loff_t size, unsigned long flags);
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
@@ -1468,12 +1468,11 @@ static struct mempolicy *shmem_get_polic
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
@@ -1481,14 +1480,15 @@ struct address_space *shmem_lock(struct 
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
+
 out_nomem:
 	spin_unlock(&info->lock);
 	return retval;
Index: b/mm/vmscan.c
===================================================================
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2454,8 +2454,10 @@ static void show_page_path(struct page *
  */
 static void check_move_unevictable_page(struct page *page, struct zone *zone)
 {
+	VM_BUG_ON(PageActive(page));
 
-	ClearPageUnevictable(page); /* for page_evictable() */
+retry:
+	ClearPageUnevictable(page);
 	if (page_evictable(page, NULL)) {
 		enum lru_list l = LRU_INACTIVE_ANON + page_is_file_cache(page);
 
@@ -2471,6 +2473,8 @@ static void check_move_unevictable_page(
 		 */
 		SetPageUnevictable(page);
 		list_move(&page->lru, &zone->lru[LRU_UNEVICTABLE].list);
+		if (page_evictable(page, NULL))
+			goto retry;
 	}
 }
 
@@ -2510,16 +2514,6 @@ void scan_mapping_unevictable_pages(stru
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
@@ -2529,9 +2523,6 @@ void scan_mapping_unevictable_pages(stru
 
 			if (PageLRU(page) && PageUnevictable(page))
 				check_move_unevictable_page(page, zone);
-
-			unlock_page(page);
-
 		}
 		if (zone)
 			spin_unlock_irq(&zone->lru_lock);


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
