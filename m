From: Mel Gorman <mel@csn.ul.ie>
Message-Id: <20070515150452.16348.79530.sendpatchset@skynet.skynet.ie>
In-Reply-To: <20070515150311.16348.56826.sendpatchset@skynet.skynet.ie>
References: <20070515150311.16348.56826.sendpatchset@skynet.skynet.ie>
Subject: [PATCH 5/8] Do not annotate shmem allocations explicitly
Date: Tue, 15 May 2007 16:04:52 +0100 (IST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: clameter@sgi.com
Cc: Mel Gorman <mel@csn.ul.ie>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

shmem support allocates pages for two purposes. Firstly, shmem_dir_alloc()
allocates pages to track swap vectors. These are not movable so this
patch clears all mobility-flags related to the allocation. Secondly,
shmem_alloc_pages() allocates pages on behalf of shmem_getpage(), whose
flags come from a file mapping which already sets the appropriate mobility
flags. These allocations do not need to be explicitly flagged so this patch
removes the unnecessary annotations.

Signed-off-by: Mel Gorman <mel@csn.ul.ie>
Acked-by: Andy Whitcroft <apw@shadowen.org>
---

 shmem.c |   11 ++++-------
 1 file changed, 4 insertions(+), 7 deletions(-)

diff -rup -X /usr/src/patchset-0.6/bin//dontdiff linux-2.6.21-mm2-010_biomovable/mm/shmem.c linux-2.6.21-mm2-012_shmem/mm/shmem.c
--- linux-2.6.21-mm2-010_biomovable/mm/shmem.c	2007-05-11 21:16:11.000000000 +0100
+++ linux-2.6.21-mm2-012_shmem/mm/shmem.c	2007-05-15 12:29:52.000000000 +0100
@@ -95,9 +95,9 @@ static inline struct page *shmem_dir_all
 	 * BLOCKS_PER_PAGE on indirect pages, assume PAGE_CACHE_SIZE:
 	 * might be reconsidered if it ever diverges from PAGE_SIZE.
 	 *
-	 * __GFP_MOVABLE is masked out as swap vectors cannot move
+	 * Mobility flags are masked out as swap vectors cannot move
 	 */
-	return alloc_pages((gfp_mask & ~__GFP_MOVABLE) | __GFP_ZERO,
+	return alloc_pages((gfp_mask & ~GFP_MOVABLE_MASK) | __GFP_ZERO,
 				PAGE_CACHE_SHIFT-PAGE_SHIFT);
 }
 
@@ -1053,9 +1053,7 @@ shmem_alloc_page(gfp_t gfp, struct shmem
 	pvma.vm_policy = mpol_shared_policy_lookup(&info->policy, idx);
 	pvma.vm_pgoff = idx;
 	pvma.vm_end = PAGE_SIZE;
-	page = alloc_page_vma(
-			set_migrateflags(gfp | __GFP_ZERO, __GFP_RECLAIMABLE),
-								&pvma, 0);
+	page = alloc_page_vma(gfp | __GFP_ZERO, &pvma, 0);
 	mpol_free(pvma.vm_policy);
 	return page;
 }
@@ -1075,8 +1073,7 @@ shmem_swapin(struct shmem_inode_info *in
 static inline struct page *
 shmem_alloc_page(gfp_t gfp,struct shmem_inode_info *info, unsigned long idx)
 {
-	return alloc_page(
-			set_migrateflags(gfp | __GFP_ZERO, __GFP_RECLAIMABLE));
+	return alloc_page(gfp | __GFP_ZERO);
 }
 #endif
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
