From: kanoj@google.engr.sgi.com (Kanoj Sarcar)
Message-Id: <200002252308.PAA76871@google.engr.sgi.com>
Subject: [RFC] [RFT] Shared /dev/zero mmaping feature
Date: Fri, 25 Feb 2000 15:08:49 -0800 (PST)
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
Cc: torvalds@transmeta.com, Kanoj Sarcar <kanoj@google.engr.sgi.com>
List-ID: <linux-mm.kvack.org>

Hi all,

This is a patch against 2.3.47 that tries to implement shared /dev/zero
mappings. This is just a first cut attempt, I am hoping I will find a
few people to apply the patch and throw some real life programs at it
(preferably on low memory machines so that swapping is induced). 

Currently, you will also need to turn on CONFIG_SYSVIPC, but most of
the shm.c code can be split into a new ipc/shm_core.c file that is
always compiled in, irrespective of CONFIG_SYSVIPC. Linus, do you 
think this is the proper direction to follow?

Thanks. Comments and feedback welcome ...

Kanoj


--- drivers/char/mem.c	Fri Feb 25 13:03:46 2000
+++ drivers/char/mem.c	Fri Feb 25 14:26:44 2000
@@ -433,8 +433,12 @@
 
 static int mmap_zero(struct file * file, struct vm_area_struct * vma)
 {
+	int ret;
+	extern int map_zero_setup(struct vm_area_struct *);
+
 	if (vma->vm_flags & VM_SHARED)
-		return -EINVAL;
+		if (ret = map_zero_setup(vma))
+			return ret;
 	if (zeromap_page_range(vma->vm_start, vma->vm_end - vma->vm_start, vma->vm_page_prot))
 		return -EAGAIN;
 	return 0;
--- ipc/shm.c	Fri Feb 25 13:04:14 2000
+++ ipc/shm.c	Fri Feb 25 14:56:39 2000
@@ -11,6 +11,7 @@
  * HIGHMEM support, Ingo Molnar <mingo@redhat.com>
  * avoid vmalloc and make shmmax, shmall, shmmni sysctl'able,
  *                         Christoph Rohland <hans-christoph.rohland@sap.com>
+ * Shared /dev/zero support, Kanoj Sarcar <kanoj@sgi.com>
  */
 
 #include <linux/config.h>
@@ -70,6 +71,13 @@
 static int sysvipc_shm_read_proc(char *buffer, char **start, off_t offset, int length, int *eof, void *data);
 #endif
 
+static void zshm_swap (int prio, int gfp_mask, zone_t *zone);
+static void zmap_unuse(swp_entry_t entry, struct page *page);
+static void shmzero_open(struct vm_area_struct *shmd);
+static void shmzero_close(struct vm_area_struct *shmd);
+static int zero_id;
+static struct kern_ipc_perm zero_perm;
+
 size_t shm_ctlmax = SHMMAX;
 int shm_ctlall = SHMALL;
 int shm_ctlmni = SHMMNI;
@@ -103,6 +111,8 @@
 #ifdef CONFIG_PROC_FS
 	create_proc_read_entry("sysvipc/shm", 0, 0, sysvipc_shm_read_proc, NULL);
 #endif
+	zero_id = ipc_addid(&shm_ids, &zero_perm, shm_ctlmni);
+	shm_unlock(zero_id);
 	return;
 }
 
@@ -179,6 +189,26 @@
 	return 0;
 }
 
+static inline struct shmid_kernel *newseg_alloc(int numpages)
+{
+	struct shmid_kernel *shp;
+
+	shp = (struct shmid_kernel *) kmalloc (sizeof (*shp), GFP_KERNEL);
+	if (!shp)
+		return 0;
+
+	shp->shm_dir = shm_alloc (numpages);
+	if (!shp->shm_dir) {
+		kfree(shp);
+		return 0;
+	}
+	shp->shm_npages = numpages;
+	shp->attaches = NULL;
+	shp->shm_nattch = 0;
+	init_MUTEX(&shp->sem);
+	return(shp);
+}
+
 static int newseg (key_t key, int shmflg, size_t size)
 {
 	struct shmid_kernel *shp;
@@ -193,15 +223,8 @@
 	if (shm_tot + numpages >= shm_ctlall)
 		return -ENOSPC;
 
-	shp = (struct shmid_kernel *) kmalloc (sizeof (*shp), GFP_KERNEL);
-	if (!shp)
-		return -ENOMEM;
-
-	shp->shm_dir = shm_alloc (numpages);
-	if (!shp->shm_dir) {
-		kfree(shp);
+	if (!(shp = newseg_alloc(numpages)))
 		return -ENOMEM;
-	}
 	id = ipc_addid(&shm_ids, &shp->shm_perm, shm_ctlmni);
 	if(id == -1) {
 		shm_free(shp->shm_dir,numpages);
@@ -212,13 +235,10 @@
 	shp->shm_perm.mode = (shmflg & S_IRWXUGO);
 	shp->shm_segsz = size;
 	shp->shm_cpid = current->pid;
-	shp->attaches = NULL;
-	shp->shm_lpid = shp->shm_nattch = 0;
+	shp->shm_lpid = 0;
 	shp->shm_atime = shp->shm_dtime = 0;
 	shp->shm_ctime = CURRENT_TIME;
-	shp->shm_npages = numpages;
 	shp->id = shm_buildid(id,shp->shm_perm.seq);
-	init_MUTEX(&shp->sem);
 
 	shm_tot += numpages;
 	shm_unlock(id);
@@ -255,6 +275,35 @@
 	return err;
 }
 
+static void killseg_core(struct shmid_kernel *shp, int doacc)
+{
+	int i, numpages, rss, swp;
+
+	numpages = shp->shm_npages;
+	for (i = 0, rss = 0, swp = 0; i < numpages ; i++) {
+		pte_t pte;
+		pte = SHM_ENTRY (shp,i);
+		if (pte_none(pte))
+			continue;
+		if (pte_present(pte)) {
+			__free_page (pte_page(pte));
+			rss++;
+		} else {
+			swap_free(pte_to_swp_entry(pte));
+			swp++;
+		}
+	}
+	shm_free (shp->shm_dir, numpages);
+	kfree(shp);
+	if (doacc) {
+		shm_lockall();
+		shm_rss -= rss;
+		shm_swp -= swp;
+		shm_tot -= numpages;
+		shm_unlockall();
+	}
+}
+
 /*
  * Only called after testing nattch and SHM_DEST.
  * Here pages, pgtable and shmid_kernel are freed.
@@ -262,8 +311,6 @@
 static void killseg (int shmid)
 {
 	struct shmid_kernel *shp;
-	int i, numpages;
-	int rss, swp;
 
 	down(&shm_ids.sem);
 	shp = shm_lock(shmid);
@@ -284,28 +331,8 @@
 		BUG();
 	shm_unlock(shmid);
 	up(&shm_ids.sem);
+	killseg_core(shp, 1);
 
-	numpages = shp->shm_npages;
-	for (i = 0, rss = 0, swp = 0; i < numpages ; i++) {
-		pte_t pte;
-		pte = SHM_ENTRY (shp,i);
-		if (pte_none(pte))
-			continue;
-		if (pte_present(pte)) {
-			__free_page (pte_page(pte));
-			rss++;
-		} else {
-			swap_free(pte_to_swp_entry(pte));
-			swp++;
-		}
-	}
-	shm_free (shp->shm_dir, numpages);
-	kfree(shp);
-	shm_lockall();
-	shm_rss -= rss;
-	shm_swp -= swp;
-	shm_tot -= numpages;
-	shm_unlockall();
 	return;
 }
 
@@ -835,10 +862,12 @@
 	struct shmid_kernel *shp;
 	unsigned int idx;
 	struct page * page;
+	int is_shmzero;
 
 	shp = (struct shmid_kernel *) shmd->vm_private_data;
 	idx = (address - shmd->vm_start) >> PAGE_SHIFT;
 	idx += shmd->vm_pgoff;
+	is_shmzero = (shp->id == zero_id);
 
 	/*
 	 * A shared mapping past the last page of the file is an error
@@ -850,7 +879,7 @@
 		return NULL;
 	}
 	down(&shp->sem);
-	if(shp != shm_lock(shp->id))
+	if ((shp != shm_lock(shp->id)) && (is_shmzero == 0))
 		BUG();
 
 	pte = SHM_ENTRY(shp,idx);
@@ -864,7 +893,7 @@
 			if (!page)
 				goto oom;
 			clear_highpage(page);
-			if(shp != shm_lock(shp->id))
+			if ((shp != shm_lock(shp->id)) && (is_shmzero == 0))
 				BUG();
 		} else {
 			swp_entry_t entry = pte_to_swp_entry(pte);
@@ -882,11 +911,11 @@
 			delete_from_swap_cache(page);
 			page = replace_with_highmem(page);
 			swap_free(entry);
-			if(shp != shm_lock(shp->id))
+			if ((shp != shm_lock(shp->id)) && (is_shmzero == 0))
 				BUG();
-			shm_swp--;
+			if (is_shmzero) shm_swp--;
 		}
-		shm_rss++;
+		if (is_shmzero) shm_rss++;
 		pte = pte_mkdirty(mk_pte(page, PAGE_SHARED));
 		SHM_ENTRY(shp, idx) = pte;
 	} else
@@ -904,6 +933,65 @@
 	return NOPAGE_OOM;
 }
 
+#define OKAY	0
+#define RETRY	1
+#define FAILED	2
+
+static int shm_swap_core(struct shmid_kernel *shp, unsigned long idx, swp_entry_t swap_entry, zone_t *zone, int *counter, struct page **outpage)
+{
+	pte_t page;
+	struct page *page_map;
+
+	page = SHM_ENTRY(shp, idx);
+	if (!pte_present(page))
+		return RETRY;
+	page_map = pte_page(page);
+	if (zone && (!memclass(page_map->zone, zone)))
+		return RETRY;
+	if (shp->id != zero_id) swap_attempts++;
+
+	if (--counter < 0) /* failed */
+		return FAILED;
+	if (page_count(page_map) != 1)
+		return RETRY;
+
+	if (!(page_map = prepare_highmem_swapout(page_map)))
+		return FAILED;
+	SHM_ENTRY (shp, idx) = swp_entry_to_pte(swap_entry);
+
+	/* add the locked page to the swap cache before allowing
+	   the swapin path to run lookup_swap_cache(). This avoids
+	   reading a not yet uptodate block from disk.
+	   NOTE: we just accounted the swap space reference for this
+	   swap cache page at __get_swap_page() time. */
+	add_to_swap_cache(*outpage = page_map, swap_entry);
+	return OKAY;
+}
+
+static void shm_swap_postop(struct page *page)
+{
+	lock_kernel();
+	rw_swap_page(WRITE, page, 0);
+	unlock_kernel();
+	__free_page(page);
+}
+
+static int shm_swap_preop(swp_entry_t *swap_entry)
+{
+	lock_kernel();
+	/* subtle: preload the swap count for the swap cache. We can't
+	   increase the count inside the critical section as we can't release
+	   the shm_lock there. And we can't acquire the big lock with the
+	   shm_lock held (otherwise we would deadlock too easily). */
+	*swap_entry = __get_swap_page(2);
+	if (!(*swap_entry).val) {
+		unlock_kernel();
+		return 1;
+	}
+	unlock_kernel();
+	return 0;
+}
+
 /*
  * Goes through counter = (shm_rss >> prio) present shm pages.
  */
@@ -912,7 +1000,6 @@
 
 int shm_swap (int prio, int gfp_mask, zone_t *zone)
 {
-	pte_t page;
 	struct shmid_kernel *shp;
 	swp_entry_t swap_entry;
 	unsigned long id, idx;
@@ -919,21 +1006,13 @@
 	int loop = 0;
 	int counter;
 	struct page * page_map;
-	
+
+	zshm_swap(prio, gfp_mask, zone);
 	counter = shm_rss >> prio;
 	if (!counter)
 		return 0;
-	lock_kernel();
-	/* subtle: preload the swap count for the swap cache. We can't
-	   increase the count inside the critical section as we can't release
-	   the shm_lock there. And we can't acquire the big lock with the
-	   shm_lock held (otherwise we would deadlock too easily). */
-	swap_entry = __get_swap_page(2);
-	if (!swap_entry.val) {
-		unlock_kernel();
+	if (shm_swap_preop(&swap_entry))
 		return 0;
-	}
-	unlock_kernel();
 
 	shm_lockall();
 check_id:
@@ -943,8 +1022,12 @@
 		swap_idx = 0;
 		if (++swap_id > shm_ids.max_id) {
 			swap_id = 0;
-			if (loop)
-				goto failed;
+			if (loop) {
+failed:
+				shm_unlockall();
+				__swap_free(swap_entry, 2);
+				return 0;
+			}
 			loop = 1;
 		}
 		goto check_id;
@@ -956,43 +1039,16 @@
 	if (idx >= shp->shm_npages)
 		goto next_id;
 
-	page = SHM_ENTRY(shp, idx);
-	if (!pte_present(page))
-		goto check_table;
-	page_map = pte_page(page);
-	if (zone && (!memclass(page_map->zone, zone)))
-		goto check_table;
-	swap_attempts++;
-
-	if (--counter < 0) { /* failed */
-failed:
-		shm_unlockall();
-		__swap_free(swap_entry, 2);
-		return 0;
+	switch (shm_swap_core(shp, idx, swap_entry, zone, &counter, &page_map)) {
+		case RETRY: goto check_table;
+		case FAILED: goto failed;
 	}
-	if (page_count(page_map) != 1)
-		goto check_table;
-
-	if (!(page_map = prepare_highmem_swapout(page_map)))
-		goto failed;
-	SHM_ENTRY (shp, idx) = swp_entry_to_pte(swap_entry);
 	swap_successes++;
 	shm_swp++;
 	shm_rss--;
-
-	/* add the locked page to the swap cache before allowing
-	   the swapin path to run lookup_swap_cache(). This avoids
-	   reading a not yet uptodate block from disk.
-	   NOTE: we just accounted the swap space reference for this
-	   swap cache page at __get_swap_page() time. */
-	add_to_swap_cache(page_map, swap_entry);
 	shm_unlockall();
 
-	lock_kernel();
-	rw_swap_page(WRITE, page_map, 0);
-	unlock_kernel();
-
-	__free_page(page_map);
+	shm_swap_postop(page_map);
 	return 1;
 }
 
@@ -1014,12 +1070,29 @@
 	swap_free(entry);
 }
 
+static int shm_unuse_core(struct shmid_kernel *shp, swp_entry_t entry, struct page *page)
+{
+	int n;
+
+	for (n = 0; n < shp->shm_npages; n++) {
+		if (pte_none(SHM_ENTRY(shp,n)))
+			continue;
+		if (pte_present(SHM_ENTRY(shp,n)))
+			continue;
+		if (pte_to_swp_entry(SHM_ENTRY(shp,n)).val == entry.val) {
+			shm_unuse_page(shp, n, entry, page);
+			return 1;
+		}
+	}
+	return 0;
+}
+
 /*
  * unuse_shm() search for an eventually swapped out shm page.
  */
 void shm_unuse(swp_entry_t entry, struct page *page)
 {
-	int i, n;
+	int i;
 
 	shm_lockall();
 	for (i = 0; i <= shm_ids.max_id; i++) {
@@ -1026,19 +1099,12 @@
 		struct shmid_kernel *shp = shm_get(i);
 		if(shp==NULL)
 			continue;
-		for (n = 0; n < shp->shm_npages; n++) {
-			if (pte_none(SHM_ENTRY(shp,n)))
-				continue;
-			if (pte_present(SHM_ENTRY(shp,n)))
-				continue;
-			if (pte_to_swp_entry(SHM_ENTRY(shp,n)).val == entry.val) {
-				shm_unuse_page(shp, n, entry, page);
-				goto out;
-			}
-		}
+		if (shm_unuse_core(shp, entry, page))
+			goto out;
 	}
 out:
 	shm_unlockall();
+	zmap_unuse(entry, page);
 }
 
 #ifdef CONFIG_PROC_FS
@@ -1100,3 +1166,138 @@
 	return len;
 }
 #endif
+
+static struct shmid_kernel *zmap_list = 0;
+static spinlock_t zmap_list_lock = SPIN_LOCK_UNLOCKED;
+static unsigned long zswap_idx = 0; /* next to swap */
+static struct shmid_kernel *zswap_shp = 0;
+
+static struct vm_operations_struct shmzero_vm_ops = {
+	open:		shmzero_open,
+	close:		shmzero_close,
+	nopage:		shm_nopage,
+	swapout:	shm_swapout,
+};
+
+int map_zero_setup(struct vm_area_struct *vma)
+{
+	struct shmid_kernel *shp;
+
+	if (!(shp = newseg_alloc((vma->vm_end - vma->vm_start) / PAGE_SIZE)))
+		return -ENOMEM;
+	shp->id = zero_id;	/* hack for shm_lock et al */
+	vma->vm_private_data = shp;
+	vma->vm_ops = &shmzero_vm_ops;
+	shmzero_open(vma);
+	spin_lock(&zmap_list_lock);
+	shp->attaches = (struct vm_area_struct *)zmap_list;
+	zmap_list = shp;
+	spin_unlock(&zmap_list_lock);
+	return 0;
+}
+
+static void shmzero_open(struct vm_area_struct *shmd)
+{
+	struct shmid_kernel *shp;
+
+	shp = (struct shmid_kernel *) shmd->vm_private_data;
+	down(&shp->sem);
+	shp->shm_nattch++;
+	up(&shp->sem);
+}
+
+static void shmzero_close(struct vm_area_struct *shmd)
+{
+	int done = 0;
+	struct shmid_kernel *shp, *prev, *cur;
+
+	shp = (struct shmid_kernel *) shmd->vm_private_data;
+	down(&shp->sem);
+	if (--shp->shm_nattch == 0)
+		done = 1;
+	up(&shp->sem);
+	if (done) {
+		spin_lock(&zmap_list_lock);
+		if (shp == zswap_shp)
+			zswap_shp = (struct shmid_kernel *)(shp->attaches);
+		if (shp == zmap_list)
+			zmap_list = (struct shmid_kernel *)(shp->attaches);
+		else {
+			prev = zmap_list;
+			cur = (struct shmid_kernel *)(prev->attaches);
+			while (cur != shp) {
+				prev = cur;
+				cur = (struct shmid_kernel *)(prev->attaches);
+			}
+			prev->attaches = (struct vm_area_struct *)(shp->attaches);
+		}
+		spin_unlock(&zmap_list_lock);
+		killseg_core(shp, 0);
+	}
+}
+
+static void zmap_unuse(swp_entry_t entry, struct page *page)
+{
+	struct shmid_kernel *shp;
+
+	spin_lock(&zmap_list_lock);
+	shp = zmap_list;
+	while (shp) {
+		if (shm_unuse_core(shp, entry, page))
+			break;
+		shp = (struct shmid_kernel *)shp->attaches;
+	}
+	spin_unlock(&zmap_list_lock);
+}
+
+static void zshm_swap (int prio, int gfp_mask, zone_t *zone)
+{
+	struct shmid_kernel *shp;
+	swp_entry_t swap_entry;
+	unsigned long idx;
+	int loop = 0;
+	int counter;
+	struct page * page_map;
+
+	counter = 10;	/* maybe we should use zshm_rss */
+	if (!counter)
+		return;
+next:
+	if (shm_swap_preop(&swap_entry))
+		return;
+
+	spin_lock(&zmap_list_lock);
+	if (zmap_list == 0)
+		goto failed;
+next_id:
+	if ((shp = zswap_shp) == 0) {
+		if (loop) {
+failed:
+			spin_unlock(&zmap_list_lock);
+			__swap_free(swap_entry, 2);
+			return;
+		}
+		zswap_shp = shp = zmap_list;
+		zswap_idx = 0;
+		loop = 1;
+	}
+
+check_table:
+	idx = zswap_idx++;
+	if (idx >= shp->shm_npages) {
+		zswap_shp = (struct shmid_kernel *)(zswap_shp->attaches);
+		zswap_idx = 0;
+		goto next_id;
+	}
+
+	switch (shm_swap_core(shp, idx, swap_entry, zone, &counter, &page_map)) {
+		case RETRY: goto check_table;
+		case FAILED: goto failed;
+	}
+	spin_unlock(&zmap_list_lock);
+
+	shm_swap_postop(page_map);
+	if (counter)
+		goto next;
+	return;
+}
--- ipc/util.c	Fri Feb 25 13:04:14 2000
+++ ipc/util.c	Fri Feb 25 14:54:39 2000
@@ -317,4 +317,9 @@
 {
 }
 
+int map_zero_setup(struct vm_area_struct *vma)
+{
+	return -EINVAL;
+}
+
 #endif /* CONFIG_SYSVIPC */
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
