Date: Sat, 6 Oct 2007 21:38:52 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: [PATCH 1/7] swapin_readahead: excise NUMA bogosity
In-Reply-To: <Pine.LNX.4.64.0710062130400.16223@blonde.wat.veritas.com>
Message-ID: <Pine.LNX.4.64.0710062136070.16223@blonde.wat.veritas.com>
References: <Pine.LNX.4.64.0710062130400.16223@blonde.wat.veritas.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andi Kleen <ak@suse.de>, Christoph Lameter <clameter@sgi.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

For three years swapin_readahead has been cluttered with fanciful
CONFIG_NUMA code, advancing addr, and stepping on to the next vma
at the boundary, to line up the mempolicy for each page allocation.

It _might_ be a good idea to allocate swap more according to vma
layout; but the fact is, that's not how we do it at all, 2.6 even
less than 2.4: swap is allocated as needed for pages as they sink
to the bottom of the inactive LRUs.  Sometimes that may match vma
layout, but not so often that it's worth going to these misleading
vma->vm_next lengths: rip all that out.

Originally I intended to retain the incrementation of addr, but
correct its initial value: valid_swaphandles generally supplies
an offset below the target addr (this is readaround rather than
readahead), but addr has not been adjusted accordingly, so in the
interleave case it has usually been allocating the target page
from the "wrong" node (though that may not matter very much).

But look at the equivalent shmem_swapin code: either by oversight
or by design, though it has all the apparatus for choosing a new
mempolicy per page, it uses the same idx throughout, choosing the
same mempolicy and interleave node for each page of the cluster.

Which is actually a much better strategy: each node has its own
LRUs and its own kswapd, so if you're betting on any particular
relationship between swap and node, the best bet is that nearby
swap entries belong to pages from the same node - even when the
mempolicy of the target page is to interleave.  And examining a
map of nodes corresponding to swap entries on a numa=fake system
bears this out.  (We could later tweak swap allocation to make it
even more likely, but this patch is merely about removing cruft.)

So, neither adjust nor increment addr in swapin_readahead, and
then shmem_swapin can use it too; the pseudo-vma to pass policy
need only be set up once per cluster, and so few fields of pvma
are used, let's skip the memset - from shmem_alloc_page also.

Signed-off-by: Hugh Dickins <hugh@veritas.com>
---

 mm/memory.c |   47 ++++++++++++++---------------------------------
 mm/shmem.c  |   43 ++++++++++++-------------------------------
 2 files changed, 26 insertions(+), 64 deletions(-)

--- 2.6.23-rc8-mm2/mm/memory.c	2007-09-27 11:28:39.000000000 +0100
+++ patch1/mm/memory.c	2007-10-04 19:24:31.000000000 +0100
@@ -2011,45 +2011,26 @@ int vmtruncate_range(struct inode *inode
  */
 void swapin_readahead(swp_entry_t entry, unsigned long addr,struct vm_area_struct *vma)
 {
-#ifdef CONFIG_NUMA
-	struct vm_area_struct *next_vma = vma ? vma->vm_next : NULL;
-#endif
-	int i, num;
-	struct page *new_page;
+	int nr_pages;
+	struct page *page;
 	unsigned long offset;
+	unsigned long end_offset;
 
 	/*
-	 * Get the number of handles we should do readahead io to.
+	 * Get starting offset for readaround, and number of pages to read.
+	 * Adjust starting address by readbehind (for NUMA interleave case)?
+	 * No, it's very unlikely that swap layout would follow vma layout,
+	 * more likely that neighbouring swap pages came from the same node:
+	 * so use the same "addr" to choose the same node for each swap read.
 	 */
-	num = valid_swaphandles(entry, &offset);
-	for (i = 0; i < num; offset++, i++) {
+	nr_pages = valid_swaphandles(entry, &offset);
+	for (end_offset = offset + nr_pages; offset < end_offset; offset++) {
 		/* Ok, do the async read-ahead now */
-		new_page = read_swap_cache_async(swp_entry(swp_type(entry),
-							   offset), vma, addr);
-		if (!new_page)
+		page = read_swap_cache_async(swp_entry(swp_type(entry), offset),
+						vma, addr);
+		if (!page)
 			break;
-		page_cache_release(new_page);
-#ifdef CONFIG_NUMA
-		/*
-		 * Find the next applicable VMA for the NUMA policy.
-		 */
-		addr += PAGE_SIZE;
-		if (addr == 0)
-			vma = NULL;
-		if (vma) {
-			if (addr >= vma->vm_end) {
-				vma = next_vma;
-				next_vma = vma ? vma->vm_next : NULL;
-			}
-			if (vma && addr < vma->vm_start)
-				vma = NULL;
-		} else {
-			if (next_vma && addr >= next_vma->vm_start) {
-				vma = next_vma;
-				next_vma = vma->vm_next;
-			}
-		}
-#endif
+		page_cache_release(page);
 	}
 	lru_add_drain();	/* Push any new pages onto the LRU now */
 }
--- 2.6.23-rc8-mm2/mm/shmem.c	2007-09-27 11:28:39.000000000 +0100
+++ patch1/mm/shmem.c	2007-10-04 19:24:31.000000000 +0100
@@ -1010,53 +1010,34 @@ out:
 	return err;
 }
 
-static struct page *shmem_swapin_async(struct shared_policy *p,
+static struct page *shmem_swapin(struct shmem_inode_info *info,
 				       swp_entry_t entry, unsigned long idx)
 {
-	struct page *page;
 	struct vm_area_struct pvma;
+	struct page *page;
 
 	/* Create a pseudo vma that just contains the policy */
-	memset(&pvma, 0, sizeof(struct vm_area_struct));
-	pvma.vm_end = PAGE_SIZE;
+	pvma.vm_start = 0;
 	pvma.vm_pgoff = idx;
-	pvma.vm_policy = mpol_shared_policy_lookup(p, idx);
+	pvma.vm_ops = NULL;
+	pvma.vm_policy = mpol_shared_policy_lookup(&info->policy, idx);
+	swapin_readahead(entry, 0, &pvma);
 	page = read_swap_cache_async(entry, &pvma, 0);
 	mpol_free(pvma.vm_policy);
 	return page;
 }
 
-static struct page *shmem_swapin(struct shmem_inode_info *info,
-				 swp_entry_t entry, unsigned long idx)
-{
-	struct shared_policy *p = &info->policy;
-	int i, num;
-	struct page *page;
-	unsigned long offset;
-
-	num = valid_swaphandles(entry, &offset);
-	for (i = 0; i < num; offset++, i++) {
-		page = shmem_swapin_async(p,
-				swp_entry(swp_type(entry), offset), idx);
-		if (!page)
-			break;
-		page_cache_release(page);
-	}
-	lru_add_drain();	/* Push any new pages onto the LRU now */
-	return shmem_swapin_async(p, entry, idx);
-}
-
-static struct page *
-shmem_alloc_page(gfp_t gfp, struct shmem_inode_info *info,
-		 unsigned long idx)
+static struct page *shmem_alloc_page(gfp_t gfp, struct shmem_inode_info *info,
+					unsigned long idx)
 {
 	struct vm_area_struct pvma;
 	struct page *page;
 
-	memset(&pvma, 0, sizeof(struct vm_area_struct));
-	pvma.vm_policy = mpol_shared_policy_lookup(&info->policy, idx);
+	/* Create a pseudo vma that just contains the policy */
+	pvma.vm_start = 0;
 	pvma.vm_pgoff = idx;
-	pvma.vm_end = PAGE_SIZE;
+	pvma.vm_ops = NULL;
+	pvma.vm_policy = mpol_shared_policy_lookup(&info->policy, idx);
 	page = alloc_page_vma(gfp | __GFP_ZERO, &pvma, 0);
 	mpol_free(pvma.vm_policy);
 	return page;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
