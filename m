From: Russell King <rmk@arm.linux.org.uk>
Message-Id: <200005251424.PAA02031@raistlin.arm.linux.org.uk>
Subject: shm_alloc and friends
Date: Thu, 25 May 2000 15:24:47 +0100 (BST)
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: riel@nl.linux.org
Cc: linux-kernel@vger.rutgers.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Rik,

Ok, I re-reviewed the code (been looking at this code too long), and I
think the change is orthogonal wrt the rest of the code.  Here is a patch
of my changes to -pre8 thus far (including the --count < 0 at the end).
If you'd like to give your blessing on this code, I'll pass it to Linus
this evening for integration into the next prepre patch.

With these changes, my box has survived about 20 minutes thus far running
hdparm -t's, which is the most its survived with this.

The pluses are:
 - uses less memory than the original to store the same information -
   we're no longer wasting memory to store pointers to pointers to the
   pte and swap entries.  Instead, they're in one big array allocated
   by vmalloc().
 - code is cleaner as a result - no loops within loops to clear
   and scan arrays of values within arrays of pointers.
 - code should be faster - no longer have to divide and modulus
   the number of pages
 - no longer reliant on PAGE_SIZE >= (sizeof(pte) * PTRS_PER_PTE)

Problems:
 - memsetting the vmalloced area to initialise the pte's.
   (Note: pte_clear can't be used, because that is expected to be used
    on page tables allocated by pte_alloc - the old code made this
    mistake).
   You may have "pte_none" signified by a non-zero value on some other
   architecture, in which case, the memsetting will break this.  I don't
   see a way around this without introducing an "empty_pte()" construct
   which always satisfies (pte_none(empty_pte()) != 0)

I just noticed in this patch - the second to last hunk had my
"check_free_lists()" calls still in, which I've just deleted.  Hopefully
the patch still works.  I'll re-generate it for Linus.

--- linux.orig/ipc/shm.c	Sat May 13 01:25:16 2000
+++ linux/ipc/shm.c	Thu May 25 15:04:52 2000
@@ -81,7 +81,7 @@
 	size_t			shm_segsz;
 	unsigned long		shm_nattch;
 	unsigned long		shm_npages; /* size of segment (pages) */
-	pte_t			**shm_dir;  /* ptr to arr of ptrs to frames */ 
+	pte_t			*shm_dir;   /* ptrs to frames */ 
 	int			id;
 	union permap {
 		struct shmem {
@@ -546,38 +546,21 @@
 	return 0;
 }
 
-#define SHM_ENTRY(shp, index) (shp)->shm_dir[(index)/PTRS_PER_PTE][(index)%PTRS_PER_PTE]
+#define SHM_ENTRY(shp, index) (shp)->shm_dir[index]
 
-static pte_t **shm_alloc(unsigned long pages, int doacc)
+static pte_t *shm_alloc(unsigned long pages, int doacc)
 {
-	unsigned short dir  = pages / PTRS_PER_PTE;
-	unsigned short last = pages % PTRS_PER_PTE;
-	pte_t **ret, **ptr, *pte;
+	pte_t *ret;
 
 	if (pages == 0)
 		return NULL;
 
-	ret = kmalloc ((dir+1) * sizeof(pte_t *), GFP_KERNEL);
+	ret = (pte_t *)vmalloc(pages * sizeof(pte_t));
 	if (!ret)
 		goto nomem;
 
-	for (ptr = ret; ptr < ret+dir ; ptr++)
-	{
-		*ptr = (pte_t *)__get_free_page (GFP_KERNEL);
-		if (!*ptr)
-			goto free;
-		for (pte = *ptr; pte < *ptr + PTRS_PER_PTE; pte++)
-			pte_clear (pte);
-	}
+	memset(ret, 0, pages * sizeof(pte_t));
 
-	/* The last one is probably not of PAGE_SIZE: we use kmalloc */
-	if (last) {
-		*ptr = kmalloc (last*sizeof(pte_t), GFP_KERNEL);
-		if (!*ptr)
-			goto free;
-		for (pte = *ptr; pte < *ptr + last; pte++)
-			pte_clear (pte);
-	}
 	if (doacc) {
 		shm_lockall();
 		shm_tot += pages;
@@ -586,27 +569,19 @@
 	}
 	return ret;
 
-free:
-	/* The last failed: we decrement first */
-	while (--ptr >= ret)
-		free_page ((unsigned long)*ptr);
-
-	kfree (ret);
 nomem:
 	return ERR_PTR(-ENOMEM);
 }
 
-static void shm_free(pte_t** dir, unsigned long pages, int doacc)
+static void shm_free(pte_t *dir, unsigned long pages, int doacc)
 {
 	int i, rss, swp;
-	pte_t **ptr = dir+pages/PTRS_PER_PTE;
 
 	if (!dir)
 		return;
 
 	for (i = 0, rss = 0, swp = 0; i < pages ; i++) {
-		pte_t pte;
-		pte = dir[i/PTRS_PER_PTE][i%PTRS_PER_PTE];
+		pte_t pte = dir[i];
 		if (pte_none(pte))
 			continue;
 		if (pte_present(pte)) {
@@ -618,16 +593,7 @@
 		}
 	}
 
-	/* first the last page */
-	if (pages%PTRS_PER_PTE)
-		kfree (*ptr);
-	/* now the whole pages */
-	while (--ptr >= dir)
-		if (*ptr)
-			free_page ((unsigned long)*ptr);
-
-	/* Now the indirect block */
-	kfree (dir);
+	vfree(dir);
 
 	if (doacc) {
 		shm_lockall();
@@ -645,7 +611,7 @@
 	struct inode *inode = dentry->d_inode;
 	struct shmid_kernel *shp;
 	unsigned long new_pages, old_pages;
-	pte_t **new_dir, **old_dir;
+	pte_t *new_dir, *old_dir;
 
 	error = inode_change_ok(inode, attr);
 	if (error)
@@ -673,18 +639,15 @@
 	old_dir = shp->shm_dir;
 	old_pages = shp->shm_npages;
 	if (old_dir){
-		pte_t *swap;
-		int i,j;
-		i = old_pages < new_pages ? old_pages : new_pages;
-		j = i % PTRS_PER_PTE;
-		i /= PTRS_PER_PTE;
-		if (j)
-			memcpy (new_dir[i], old_dir[i], j * sizeof (pte_t));
-		while (i--) {
-			swap = new_dir[i];
-			new_dir[i] = old_dir[i];
-			old_dir[i] = swap;
-		}
+		int pages = old_pages < new_pages ? old_pages : new_pages;
+
+		/*
+		 * Copy the pte pointers from the old dir to the new dir,
+		 * remembering to remove the copied pointers from the old
+		 * dir.
+		 */
+		memcpy(new_dir, old_dir, pages * sizeof(pte_t));
+		memset(old_dir, 0, pages * sizeof(pte_t));
 	}
 	shp->shm_dir = new_dir;
 	shp->shm_npages = new_pages;
@@ -700,13 +663,14 @@
 static struct shmid_kernel *seg_alloc(int numpages, size_t namelen)
 {
 	struct shmid_kernel *shp;
-	pte_t		   **dir;
+	pte_t		    *dir;
 
 	shp = (struct shmid_kernel *) kmalloc (sizeof (*shp) + namelen, GFP_KERNEL);
 	if (!shp)
 		return ERR_PTR(-ENOMEM);
-
+
 	dir = shm_alloc (numpages, namelen);
+
 	if (IS_ERR(dir)) {
 		kfree(shp);
 		return ERR_PTR(PTR_ERR(dir));
@@ -1424,7 +1388,7 @@
 		return RETRY;
 	if (shp->id != zero_id) swap_attempts++;
 
-	if (--counter < 0) /* failed */
+	if (--*counter < 0) /* failed */
 		return FAILED;
 	if (page_count(page_map) != 1)
 		return RETRY;

   _____
  |_____| ------------------------------------------------- ---+---+-
  |   |         Russell King        rmk@arm.linux.org.uk      --- ---
  | | | |   http://www.arm.linux.org.uk/~rmk/aboutme.html    /  /  |
  | +-+-+                                                     --- -+-
  /   |               THE developer of ARM Linux              |+| /|\
 /  | | |                                                     ---  |
    +-+-+ -------------------------------------------------  /\\\  |
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
