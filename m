Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx114.postini.com [74.125.245.114])
	by kanga.kvack.org (Postfix) with SMTP id 8F0166B005C
	for <linux-mm@kvack.org>; Fri,  6 Jan 2012 16:10:27 -0500 (EST)
Received: by iacb35 with SMTP id b35so3945273iac.14
        for <linux-mm@kvack.org>; Fri, 06 Jan 2012 13:10:26 -0800 (PST)
Date: Fri, 6 Jan 2012 13:10:11 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH 1/2] SHM_UNLOCK: fix long unpreemptible section
Message-ID: <alpine.LSU.2.00.1201061303320.12082@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@gmail.com>, Minchan Kim <minchan.kim@gmail.com>, Rik van Riel <riel@redhat.com>, Shaohua Li <shaohua.li@intel.com>, Eric Dumazet <eric.dumazet@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, Michel Lespinasse <walken@google.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

scan_mapping_unevictable_pages() is used to make SysV SHM_LOCKed pages
evictable again once the shared memory is unlocked.  It does this with
pagevec_lookup()s across the whole object (which might occupy most of
memory), and takes 300ms to unlock 7GB here.  A cond_resched() every
PAGEVEC_SIZE pages would be good.

However, KOSAKI-san points out that this is called under shmem.c's
info->lock, and it's also under shm.c's shm_lock(), both spinlocks.
There is no strong reason for that: we need to take these pages off
the unevictable list soonish, but those locks are not required for it.

So move the call to scan_mapping_unevictable_pages() from shmem.c's
unlock handling up to shm.c's unlock handling.  Remove the recently
added barrier, not needed now we have spin_unlock() before the scan.

Use get_file(), with subsequent fput(), to make sure we have a
reference to mapping throughout scan_mapping_unevictable_pages():
that's something that was previously guaranteed by the shm_lock().

Remove shmctl's lru_add_drain_all(): we don't fault in pages at
SHM_LOCK time, and we lazily discover them to be Unevictable later,
so it serves no purpose for SHM_LOCK; and serves no purpose for
SHM_UNLOCK, since pages still on pagevec are not marked Unevictable.

The original code avoided redundant rescans by checking VM_LOCKED
flag at its level: now avoid them by checking shp's SHM_LOCKED.

The original code called scan_mapping_unevictable_pages() on a
locked area at shm_destroy() time: perhaps we once had accounting
cross-checks which required that, but not now, so skip the overhead
and just let inode eviction deal with them.

Put check_move_unevictable_page() and scan_mapping_unevictable_pages()
under CONFIG_SHMEM (with stub for the TINY case when ramfs is used),
more as comment than to save space; comment them used for SHM_UNLOCK.

Signed-off-by: Hugh Dickins <hughd@google.com>
Cc: stable@vger.kernel.org [back to 2.6.32 but will need respins]
---
This version of the patch spun to apply on top of mmotm.

 ipc/shm.c   |   37 ++++++++++++++++++++++---------------
 mm/shmem.c  |    7 -------
 mm/vmscan.c |   12 +++++++++++-
 3 files changed, 33 insertions(+), 23 deletions(-)

--- mmotm.orig/ipc/shm.c	2012-01-06 10:04:54.000000000 -0800
+++ mmotm/ipc/shm.c	2012-01-06 10:06:13.937943603 -0800
@@ -870,9 +870,7 @@ SYSCALL_DEFINE3(shmctl, int, shmid, int,
 	case SHM_LOCK:
 	case SHM_UNLOCK:
 	{
-		struct file *uninitialized_var(shm_file);
-
-		lru_add_drain_all();  /* drain pagevecs to lru lists */
+		struct file *shm_file;
 
 		shp = shm_lock_check(ns, shmid);
 		if (IS_ERR(shp)) {
@@ -895,22 +893,31 @@ SYSCALL_DEFINE3(shmctl, int, shmid, int,
 		err = security_shm_shmctl(shp, cmd);
 		if (err)
 			goto out_unlock;
-		
-		if(cmd==SHM_LOCK) {
+
+		shm_file = shp->shm_file;
+		if (is_file_hugepages(shm_file))
+			goto out_unlock;
+
+		if (cmd == SHM_LOCK) {
 			struct user_struct *user = current_user();
-			if (!is_file_hugepages(shp->shm_file)) {
-				err = shmem_lock(shp->shm_file, 1, user);
-				if (!err && !(shp->shm_perm.mode & SHM_LOCKED)){
-					shp->shm_perm.mode |= SHM_LOCKED;
-					shp->mlock_user = user;
-				}
+			err = shmem_lock(shm_file, 1, user);
+			if (!err && !(shp->shm_perm.mode & SHM_LOCKED)) {
+				shp->shm_perm.mode |= SHM_LOCKED;
+				shp->mlock_user = user;
 			}
-		} else if (!is_file_hugepages(shp->shm_file)) {
-			shmem_lock(shp->shm_file, 0, shp->mlock_user);
-			shp->shm_perm.mode &= ~SHM_LOCKED;
-			shp->mlock_user = NULL;
+			goto out_unlock;
 		}
+
+		/* SHM_UNLOCK */
+		if (!(shp->shm_perm.mode & SHM_LOCKED))
+			goto out_unlock;
+		shmem_lock(shm_file, 0, shp->mlock_user);
+		shp->shm_perm.mode &= ~SHM_LOCKED;
+		shp->mlock_user = NULL;
+		get_file(shm_file);
 		shm_unlock(shp);
+		scan_mapping_unevictable_pages(shm_file->f_mapping);
+		fput(shm_file);
 		goto out;
 	}
 	case IPC_RMID:
--- mmotm.orig/mm/shmem.c	2012-01-06 10:05:00.000000000 -0800
+++ mmotm/mm/shmem.c	2012-01-06 10:08:05.505947516 -0800
@@ -1068,13 +1068,6 @@ int shmem_lock(struct file *file, int lo
 		user_shm_unlock(inode->i_size, user);
 		info->flags &= ~VM_LOCKED;
 		mapping_clear_unevictable(file->f_mapping);
-		/*
-		 * Ensure that a racing putback_lru_page() can see
-		 * the pages of this mapping are evictable when we
-		 * skip them due to !PageLRU during the scan.
-		 */
-		smp_mb__after_clear_bit();
-		scan_mapping_unevictable_pages(file->f_mapping);
 	}
 	retval = 0;
 
--- mmotm.orig/mm/vmscan.c	2012-01-06 10:04:54.000000000 -0800
+++ mmotm/mm/vmscan.c	2012-01-06 10:06:13.941943604 -0800
@@ -3499,6 +3499,7 @@ int page_evictable(struct page *page, st
 	return 1;
 }
 
+#ifdef CONFIG_SHMEM
 /**
  * check_move_unevictable_page - check page for evictability and move to appropriate zone lru list
  * @page: page to check evictability and move to appropriate lru list
@@ -3509,6 +3510,8 @@ int page_evictable(struct page *page, st
  *
  * Restrictions: zone->lru_lock must be held, page must be on LRU and must
  * have PageUnevictable set.
+ *
+ * This function is only used for SysV IPC SHM_UNLOCK.
  */
 static void check_move_unevictable_page(struct page *page, struct zone *zone)
 {
@@ -3545,6 +3548,8 @@ retry:
  *
  * Scan all pages in mapping.  Check unevictable pages for
  * evictability and move them to the appropriate zone lru list.
+ *
+ * This function is only used for SysV IPC SHM_UNLOCK.
  */
 void scan_mapping_unevictable_pages(struct address_space *mapping)
 {
@@ -3590,9 +3595,14 @@ void scan_mapping_unevictable_pages(stru
 		pagevec_release(&pvec);
 
 		count_vm_events(UNEVICTABLE_PGSCANNED, pg_scanned);
+		cond_resched();
 	}
-
 }
+#else
+void scan_mapping_unevictable_pages(struct address_space *mapping)
+{
+}
+#endif /* CONFIG_SHMEM */
 
 static void warn_scan_unevictable_pages(void)
 {

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
