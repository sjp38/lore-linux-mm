Date: Sat, 6 Oct 2007 21:43:36 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: [PATCH 3/7] swapin needs gfp_mask for loop on tmpfs
In-Reply-To: <Pine.LNX.4.64.0710062130400.16223@blonde.wat.veritas.com>
Message-ID: <Pine.LNX.4.64.0710062139490.16223@blonde.wat.veritas.com>
References: <Pine.LNX.4.64.0710062130400.16223@blonde.wat.veritas.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Miklos Szeredi <miklos@szeredi.hu>, Fengguang Wu <wfg@mail.ustc.edu.cn>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Building in a filesystem on a loop device on a tmpfs file can hang when
swapping, the loop thread caught in that infamous throttle_vm_writeout.

In theory this is a long standing problem, which I've either never seen
in practice, or long ago suppressed the recollection, after discounting
my load and my tmpfs size as unrealistically high.  But now, with the
new aops, it has become easy to hang on one machine.

Loop used to grab_cache_page before the old prepare_write to tmpfs,
which seems to have been enough to free up some memory for any swapin
needed; but the new write_begin lets tmpfs find or allocate the page
(much nicer, since grab_cache_page missed tmpfs pages in swapcache).

When allocating a fresh page, tmpfs respects loop's mapping_gfp_mask,
which has __GFP_IO|__GFP_FS stripped off, and throttle_vm_writeout is
designed to break out when __GFP_IO or GFP_FS is unset; but when tmfps
swaps in, read_swap_cache_async allocates with GFP_HIGHUSER_MOVABLE
regardless of the mapping_gfp_mask - hence the hang.

So, pass gfp_mask down the line from shmem_getpage to shmem_swapin
to swapin_readahead to read_swap_cache_async to add_to_swap_cache.

Signed-off-by: Hugh Dickins <hugh@veritas.com>
---
I did once see what looked like this hang on 2.6.23-rc3-git10,
and on some -mm's just _before_ the new aops went in; but those
cases were much harder to reproduce, and I've not seen it on any
2.6.23-rc since then, so haven't worried about it for 2.6.23.

I see there's currently lots of interest in throttle_vm_writeout,
though I've not been following in detail.  CC'ed interested parties.
It's possible that forthcoming changes might fix my hang differently,
but there's currently so much ferment that I've not tried more than
Fengguang's moving the gfp_mask test (which unsurprisingly didn't help).
I'm sending this out now because I want the fix, and it does seem wrong
to have been ignoring mapping_gfp_mask here before (I think I was aware
of the deficiency when I first did loop on tmpfs, but reluctant to ask
for changes outside shmem.c when no problem was seen).

 include/linux/swap.h |    6 +++---
 mm/memory.c          |    3 ++-
 mm/shmem.c           |   28 ++++++++++++++--------------
 mm/swap_state.c      |   18 +++++++++---------
 mm/swapfile.c        |    3 ++-
 5 files changed, 30 insertions(+), 28 deletions(-)

--- patch2/include/linux/swap.h	2007-10-04 19:24:33.000000000 +0100
+++ patch3/include/linux/swap.h	2007-10-04 19:24:36.000000000 +0100
@@ -233,9 +233,9 @@ extern int move_from_swap_cache(struct p
 extern void free_page_and_swap_cache(struct page *);
 extern void free_pages_and_swap_cache(struct page **, int);
 extern struct page *lookup_swap_cache(swp_entry_t);
-extern struct page *read_swap_cache_async(swp_entry_t,
+extern struct page *read_swap_cache_async(swp_entry_t, gfp_t,
 			struct vm_area_struct *vma, unsigned long addr);
-extern struct page *swapin_readahead(swp_entry_t,
+extern struct page *swapin_readahead(swp_entry_t, gfp_t,
 			struct vm_area_struct *vma, unsigned long addr);
 
 /* linux/mm/swapfile.c */
@@ -311,7 +311,7 @@ static inline void swap_free(swp_entry_t
 {
 }
 
-static inline struct page *swapin_readahead(swp_entry_t swp,
+static inline struct page *swapin_readahead(swp_entry_t swp, gfp_t gfp_mask,
 			struct vm_area_struct *vma, unsigned long addr)
 {
 	return NULL;
--- patch2/mm/memory.c	2007-10-04 19:24:33.000000000 +0100
+++ patch3/mm/memory.c	2007-10-04 19:24:36.000000000 +0100
@@ -2020,7 +2020,8 @@ static int do_swap_page(struct mm_struct
 	page = lookup_swap_cache(entry);
 	if (!page) {
 		grab_swap_token(); /* Contend for token _before_ read-in */
-		page = swapin_readahead(entry, vma, address);
+		page = swapin_readahead(entry,
+					GFP_HIGHUSER_MOVABLE, vma, address);
 		if (!page) {
 			/*
 			 * Back out if somebody else faulted in this pte
--- patch2/mm/shmem.c	2007-10-04 19:24:33.000000000 +0100
+++ patch3/mm/shmem.c	2007-10-04 19:24:36.000000000 +0100
@@ -1010,8 +1010,8 @@ out:
 	return err;
 }
 
-static struct page *shmem_swapin(struct shmem_inode_info *info,
-				       swp_entry_t entry, unsigned long idx)
+static struct page *shmem_swapin(swp_entry_t entry, gfp_t gfp,
+			struct shmem_inode_info *info, unsigned long idx)
 {
 	struct vm_area_struct pvma;
 	struct page *page;
@@ -1021,13 +1021,13 @@ static struct page *shmem_swapin(struct 
 	pvma.vm_pgoff = idx;
 	pvma.vm_ops = NULL;
 	pvma.vm_policy = mpol_shared_policy_lookup(&info->policy, idx);
-	page = swapin_readahead(entry, &pvma, 0);
+	page = swapin_readahead(entry, gfp, &pvma, 0);
 	mpol_free(pvma.vm_policy);
 	return page;
 }
 
-static struct page *shmem_alloc_page(gfp_t gfp, struct shmem_inode_info *info,
-					unsigned long idx)
+static struct page *shmem_alloc_page(gfp_t gfp,
+			struct shmem_inode_info *info, unsigned long idx)
 {
 	struct vm_area_struct pvma;
 	struct page *page;
@@ -1048,14 +1048,14 @@ static inline int shmem_parse_mpol(char 
 	return 1;
 }
 
-static inline struct page *
-shmem_swapin(struct shmem_inode_info *info,swp_entry_t entry,unsigned long idx)
+static inline struct page *shmem_swapin(swp_entry_t entry, gfp_t gfp,
+			struct shmem_inode_info *info, unsigned long idx)
 {
-	return swapin_readahead(entry, NULL, 0);
+	return swapin_readahead(entry, gfp, NULL, 0);
 }
 
-static inline struct page *
-shmem_alloc_page(gfp_t gfp,struct shmem_inode_info *info, unsigned long idx)
+static inline struct page *shmem_alloc_page(gfp_t gfp,
+			struct shmem_inode_info *info, unsigned long idx)
 {
 	return alloc_page(gfp | __GFP_ZERO);
 }
@@ -1078,6 +1078,7 @@ static int shmem_getpage(struct inode *i
 	struct page *swappage;
 	swp_entry_t *entry;
 	swp_entry_t swap;
+	gfp_t gfp;
 	int error;
 
 	if (idx >= SHMEM_MAX_INDEX)
@@ -1102,6 +1103,7 @@ repeat:
 	error = 0;
 	if (sgp == SGP_QUICK)
 		goto failed;
+	gfp = mapping_gfp_mask(mapping);
 
 	spin_lock(&info->lock);
 	shmem_recalc_inode(inode);
@@ -1124,7 +1126,7 @@ repeat:
 				*type |= VM_FAULT_MAJOR;
 			}
 			spin_unlock(&info->lock);
-			swappage = shmem_swapin(info, swap, idx);
+			swappage = shmem_swapin(swap, gfp, info, idx);
 			if (!swappage) {
 				spin_lock(&info->lock);
 				entry = shmem_swp_alloc(info, idx, sgp);
@@ -1236,9 +1238,7 @@ repeat:
 
 		if (!filepage) {
 			spin_unlock(&info->lock);
-			filepage = shmem_alloc_page(mapping_gfp_mask(mapping),
-						    info,
-						    idx);
+			filepage = shmem_alloc_page(gfp, info, idx);
 			if (!filepage) {
 				shmem_unacct_blocks(info->flags, 1);
 				shmem_free_blocks(inode, 1);
--- patch2/mm/swap_state.c	2007-10-04 19:24:33.000000000 +0100
+++ patch3/mm/swap_state.c	2007-10-04 19:24:36.000000000 +0100
@@ -106,7 +106,8 @@ out:
 	return error;
 }
 
-static int add_to_swap_cache(struct page *page, swp_entry_t entry)
+static int add_to_swap_cache(struct page *page, swp_entry_t entry,
+				gfp_t gfp_mask)
 {
 	int error;
 
@@ -116,7 +117,7 @@ static int add_to_swap_cache(struct page
 		return -ENOENT;
 	}
 	SetPageLocked(page);
-	error = __add_to_swap_cache(page, entry, GFP_KERNEL);
+	error = __add_to_swap_cache(page, entry, gfp_mask & GFP_KERNEL);
 	/*
 	 * Anon pages are already on the LRU, we don't run lru_cache_add here.
 	 */
@@ -329,7 +330,7 @@ struct page * lookup_swap_cache(swp_entr
  * A failure return means that either the page allocation failed or that
  * the swap entry is no longer in use.
  */
-struct page *read_swap_cache_async(swp_entry_t entry,
+struct page *read_swap_cache_async(swp_entry_t entry, gfp_t gfp_mask,
 			struct vm_area_struct *vma, unsigned long addr)
 {
 	struct page *found_page, *new_page = NULL;
@@ -349,8 +350,7 @@ struct page *read_swap_cache_async(swp_e
 		 * Get a new page to read into from swap.
 		 */
 		if (!new_page) {
-			new_page = alloc_page_vma(GFP_HIGHUSER_MOVABLE,
-								vma, addr);
+			new_page = alloc_page_vma(gfp_mask, vma, addr);
 			if (!new_page)
 				break;		/* Out of memory */
 		}
@@ -365,7 +365,7 @@ struct page *read_swap_cache_async(swp_e
 		 * the just freed swap entry for an existing page.
 		 * May fail (-ENOMEM) if radix-tree node allocation failed.
 		 */
-		err = add_to_swap_cache(new_page, entry);
+		err = add_to_swap_cache(new_page, entry, gfp_mask);
 		if (!err) {
 			/*
 			 * Initiate read into locked page and return.
@@ -399,7 +399,7 @@ struct page *read_swap_cache_async(swp_e
  *
  * Caller must hold down_read on the vma->vm_mm if vma is not NULL.
  */
-struct page *swapin_readahead(swp_entry_t entry,
+struct page *swapin_readahead(swp_entry_t entry, gfp_t gfp_mask,
 			struct vm_area_struct *vma, unsigned long addr)
 {
 	int nr_pages;
@@ -418,11 +418,11 @@ struct page *swapin_readahead(swp_entry_
 	for (end_offset = offset + nr_pages; offset < end_offset; offset++) {
 		/* Ok, do the async read-ahead now */
 		page = read_swap_cache_async(swp_entry(swp_type(entry), offset),
-						vma, addr);
+						gfp_mask, vma, addr);
 		if (!page)
 			break;
 		page_cache_release(page);
 	}
 	lru_add_drain();	/* Push any new pages onto the LRU now */
-	return read_swap_cache_async(entry, vma, addr);
+	return read_swap_cache_async(entry, gfp_mask, vma, addr);
 }
--- patch2/mm/swapfile.c	2007-09-27 11:28:39.000000000 +0100
+++ patch3/mm/swapfile.c	2007-10-04 19:24:36.000000000 +0100
@@ -737,7 +737,8 @@ static int try_to_unuse(unsigned int typ
 		 */
 		swap_map = &si->swap_map[i];
 		entry = swp_entry(type, i);
-		page = read_swap_cache_async(entry, NULL, 0);
+		page = read_swap_cache_async(entry,
+					GFP_HIGHUSER_MOVABLE, NULL, 0);
 		if (!page) {
 			/*
 			 * Either swap_duplicate() failed because entry

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
