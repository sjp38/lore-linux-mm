Subject: [PATCH,incomplete] shm integration into shrink_mmap
References: <Pine.LNX.4.21.0006071025330.14304-100000@duckman.distro.conectiva> <qww7lc1pnt0.fsf@sap.com> <20000607154350.N30951@redhat.com>
From: Christoph Rohland <cr@sap.com>
Date: 08 Jun 2000 17:04:24 +0200
In-Reply-To: "Stephen C. Tweedie"'s message of "Wed, 7 Jun 2000 15:43:50 +0100"
Message-ID: <qwwg0qob4ef.fsf_-_@sap.com>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="=-=-="
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@conectiva.com.br>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

--=-=-=

Hi Rik,

Here is my first proposal for changing shm to be integrated into
shrink_mmap.

It gives you a function 'int shm_write_swap (struct page *page)' to
write out a page to swap and replace the pte in the shm structures.  I
tested the stuff with no swapping and it seems stable so far. But
shm_write_swap is completely untested.

It probably needs to add the pages in shm_nopage_core to your lru
queues and of course it needs the calls from shrink_mmap.

I think it would be nicer to only have a notify function instead of
shm_write_swap, which gets the page and the swap_entry and can simply
put the swap_entry into the shm structures without handling the
swapping at all.

What do you think?
        		Christoph


--=-=-=
Content-Disposition: attachment; filename=patch-shm_shrink_mmap

diff -uNr 4-1-ac10/include/linux/mm.h c/include/linux/mm.h
--- 4-1-ac10/include/linux/mm.h	Wed Jun  7 11:47:52 2000
+++ c/include/linux/mm.h	Thu Jun  8 10:20:52 2000
@@ -176,6 +176,7 @@
 #define PG_skip			10
 #define PG_unused_03		11
 #define PG_highmem		12
+#define PG_shm			13
 				/* bits 21-30 unused */
 #define PG_reserved		31
 
@@ -220,6 +221,9 @@
 #define PageClearSwapCache(page)	clear_bit(PG_swap_cache, &(page)->flags)
 
 #define PageTestandClearSwapCache(page)	test_and_clear_bit(PG_swap_cache, &(page)->flags)
+
+#define PageSHM(page)			test_bit(PG_shm, &(page)->flags)
+#define SetPageSHM(page)		set_bit(PG_shm, &(page)->flags)
 
 #ifdef CONFIG_HIGHMEM
 #define PageHighMem(page)		test_bit(PG_highmem, &(page)->flags)
diff -uNr 4-1-ac10/ipc/shm.c c/ipc/shm.c
--- 4-1-ac10/ipc/shm.c	Wed Jun  7 11:43:52 2000
+++ c/ipc/shm.c	Thu Jun  8 15:12:00 2000
@@ -81,6 +81,7 @@
 	unsigned long		shm_npages; /* size of segment (pages) */
 	pte_t			**shm_dir;  /* ptr to arr of ptrs to frames */ 
 	int			id;
+	struct address_space    mapping;
 	union permap {
 		struct shmem {
 			time_t			atime;
@@ -130,7 +131,6 @@
 static int sysvipc_shm_read_proc(char *buffer, char **start, off_t offset, int length, int *eof, void *data);
 #endif
 
-static void zshm_swap (int prio, int gfp_mask);
 static void zmap_unuse(swp_entry_t entry, struct page *page);
 static void shmzero_open(struct vm_area_struct *shmd);
 static void shmzero_close(struct vm_area_struct *shmd);
@@ -628,7 +628,9 @@
 		if (pte_none(pte))
 			continue;
 		if (pte_present(pte)) {
-			__free_page (pte_page(pte));
+			struct page *page = pte_page(pte);
+			page->mapping = NULL; /* make __free_pages_ok happy */
+			__free_page (page);
 			rss++;
 		} else {
 			swap_free(pte_to_swp_entry(pte));
@@ -744,6 +746,12 @@
 	shp->shm_npages = numpages;
 	shp->shm_nattch = 0;
 	shp->shm_namelen = namelen;
+	INIT_LIST_HEAD (&shp->mapping.pages);
+	shp->mapping.nrpages = 0;
+	shp->mapping.a_ops = NULL;
+	shp->mapping.host = (void *) shp;
+	shp->mapping.i_mmap = NULL;
+	spin_lock_init(&shp->mapping.i_shared_lock);
 	return(shp);
 }
 
@@ -1441,6 +1449,9 @@
 			(*swp)--;
 		}
 		(*rss)++;
+		SetPageSHM(page);
+		page->mapping = &shp->mapping;
+		page->index   = idx;
 		pte = pte_mkdirty(mk_pte(page, PAGE_SHARED));
 		SHM_ENTRY(shp, idx) = pte;
 	}
@@ -1473,124 +1484,55 @@
 	return(page);
 }
 
-#define OKAY	0
-#define RETRY	1
-#define FAILED	2
-
-static int shm_swap_core(struct shmid_kernel *shp, unsigned long idx, swp_entry_t swap_entry, int *counter, struct page **outpage)
-{
-	pte_t page;
-	struct page *page_map;
-
-	page = SHM_ENTRY(shp, idx);
-	if (!pte_present(page))
-		return RETRY;
-	page_map = pte_page(page);
-	if (page_map->zone->free_pages > page_map->zone->pages_high)
-		return RETRY;
-	if (shp->id != zero_id) swap_attempts++;
-
-	if (--counter < 0) /* failed */
-		return FAILED;
-	if (page_count(page_map) != 1)
-		return RETRY;
-
-	lock_page(page_map);
-	if (!(page_map = prepare_highmem_swapout(page_map)))
-		return FAILED;
-	SHM_ENTRY (shp, idx) = swp_entry_to_pte(swap_entry);
-
-	/* add the locked page to the swap cache before allowing
-	   the swapin path to run lookup_swap_cache(). This avoids
-	   reading a not yet uptodate block from disk.
-	   NOTE: we just accounted the swap space reference for this
-	   swap cache page at __get_swap_page() time. */
-	add_to_swap_cache(*outpage = page_map, swap_entry);
-	return OKAY;
-}
-
-static void shm_swap_postop(struct page *page)
+int shm_write_swap (struct page *page)
 {
-	lock_kernel();
-	rw_swap_page(WRITE, page, 0);
-	unlock_kernel();
-	page_cache_release(page);
-}
+	struct shmid_kernel *shp;
+	swp_entry_t swap_entry;
+	unsigned long idx;
+
+	if (!PageSHM (page))
+		BUG();
 
-static int shm_swap_preop(swp_entry_t *swap_entry)
-{
 	lock_kernel();
 	/* subtle: preload the swap count for the swap cache. We can't
 	   increase the count inside the critical section as we can't release
 	   the shm_lock there. And we can't acquire the big lock with the
 	   shm_lock held (otherwise we would deadlock too easily). */
-	*swap_entry = __get_swap_page(2);
-	if (!(*swap_entry).val) {
+	swap_entry = __get_swap_page(2);
+	if (!swap_entry.val) {
 		unlock_kernel();
-		return 1;
+		return 0;
 	}
 	unlock_kernel();
-	return 0;
-}
-
-/*
- * Goes through counter = (shm_rss / (prio + 1)) present shm pages.
- */
-static unsigned long swap_id; /* currently being swapped */
-static unsigned long swap_idx; /* next to swap */
 
-int shm_swap (int prio, int gfp_mask)
-{
-	struct shmid_kernel *shp;
-	swp_entry_t swap_entry;
-	unsigned long id, idx;
-	int loop = 0;
-	int counter;
-	struct page * page_map;
-
-	zshm_swap(prio, gfp_mask);
-	counter = shm_rss / (prio + 1);
-	if (!counter)
-		return 0;
-	if (shm_swap_preop(&swap_entry))
-		return 0;
+	shp = (struct shmid_kernel *) page->mapping->host;
+	idx = page->index;
+	if (shp->id != zero_id) swap_attempts++;
 
+	lock_page(page);
+	if (!(page = prepare_highmem_swapout(page)))
+		goto err;
 	shm_lockall();
-check_id:
-	shp = shm_get(swap_id);
-	if(shp==NULL || shp->shm_flags & PRV_LOCKED) {
-next_id:
-		swap_idx = 0;
-		if (++swap_id > shm_ids.max_id) {
-			swap_id = 0;
-			if (loop) {
-failed:
-				shm_unlockall();
-				__swap_free(swap_entry, 2);
-				return 0;
-			}
-			loop = 1;
-		}
-		goto check_id;
-	}
-	id = swap_id;
-
-check_table:
-	idx = swap_idx++;
-	if (idx >= shp->shm_npages)
-		goto next_id;
-
-	switch (shm_swap_core(shp, idx, swap_entry, &counter, &page_map)) {
-		case RETRY: goto check_table;
-		case FAILED: goto failed;
-	}
+	SHM_ENTRY (shp, idx) = swp_entry_to_pte(swap_entry);
 	swap_successes++;
 	shm_swp++;
 	shm_rss--;
 	shm_unlockall();
 
-	shm_swap_postop(page_map);
+	/* add the locked page to the swap cache before allowing
+	   the swapin path to run lookup_swap_cache(). This avoids
+	   reading a not yet uptodate block from disk.
+	   NOTE: we just accounted the swap space reference for this
+	   swap cache page at __get_swap_page() time. */
+	add_to_swap_cache(page, swap_entry);
+	lock_kernel();
+	rw_swap_page(WRITE, page, 0);
+	unlock_kernel();
+	page_cache_release(page);
 	return 1;
+err:
+	__swap_free(swap_entry, 2);
+	return 0;
 }
 
 /*
@@ -1718,7 +1660,6 @@
 #define VMA_TO_SHP(vma)		((vma)->vm_file->private_data)
 
 static spinlock_t zmap_list_lock = SPIN_LOCK_UNLOCKED;
-static unsigned long zswap_idx; /* next to swap */
 static struct shmid_kernel *zswap_shp = &zshmid_kernel;
 static int zshm_rss;
 
@@ -1864,63 +1805,5 @@
 	}
 	shm_unlock(zero_id);
 	spin_unlock(&zmap_list_lock);
-}
-
-static void zshm_swap (int prio, int gfp_mask)
-{
-	struct shmid_kernel *shp;
-	swp_entry_t swap_entry;
-	unsigned long idx;
-	int loop = 0;
-	int counter;
-	struct page * page_map;
-
-	counter = zshm_rss / (prio + 1);
-	if (!counter)
-		return;
-next:
-	if (shm_swap_preop(&swap_entry))
-		return;
-
-	spin_lock(&zmap_list_lock);
-	shm_lock(zero_id);
-	if (zshmid_kernel.zero_list.next == 0)
-		goto failed;
-next_id:
-	if (zswap_shp == &zshmid_kernel) {
-		if (loop) {
-failed:
-			shm_unlock(zero_id);
-			spin_unlock(&zmap_list_lock);
-			__swap_free(swap_entry, 2);
-			return;
-		}
-		zswap_shp = list_entry(zshmid_kernel.zero_list.next, 
-					struct shmid_kernel, zero_list);
-		zswap_idx = 0;
-		loop = 1;
-	}
-	shp = zswap_shp;
-
-check_table:
-	idx = zswap_idx++;
-	if (idx >= shp->shm_npages) {
-		zswap_shp = list_entry(zswap_shp->zero_list.next, 
-					struct shmid_kernel, zero_list);
-		zswap_idx = 0;
-		goto next_id;
-	}
-
-	switch (shm_swap_core(shp, idx, swap_entry, &counter, &page_map)) {
-		case RETRY: goto check_table;
-		case FAILED: goto failed;
-	}
-	shm_unlock(zero_id);
-	spin_unlock(&zmap_list_lock);
-
-	shm_swap_postop(page_map);
-	if (counter)
-		goto next;
-	return;
 }
 
diff -uNr 4-1-ac10/ipc/util.c c/ipc/util.c
--- 4-1-ac10/ipc/util.c	Mon Jun  5 11:12:29 2000
+++ c/ipc/util.c	Thu Jun  8 13:27:27 2000
@@ -243,11 +243,6 @@
     return;
 }
 
-int shm_swap (int prio, int gfp_mask)
-{
-    return 0;
-}
-
 asmlinkage long sys_semget (key_t key, int nsems, int semflg)
 {
 	return -ENOSYS;
diff -uNr 4-1-ac10/mm/vmscan.c c/mm/vmscan.c
--- 4-1-ac10/mm/vmscan.c	Mon Jun  5 11:12:29 2000
+++ c/mm/vmscan.c	Thu Jun  8 13:28:17 2000
@@ -471,11 +471,6 @@
 				ret = 1;
 				goto done;
 			}
-			while (shm_swap(priority, gfp_mask)) {
-				ret = 1;
-				if (!--count)
-					goto done;
-			}
 		}
 
 		/*

--=-=-=--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
