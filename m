Date: Fri, 28 Apr 2006 20:22:51 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Message-Id: <20060429032251.4999.54239.sendpatchset@schroedinger.engr.sgi.com>
In-Reply-To: <20060429032246.4999.21714.sendpatchset@schroedinger.engr.sgi.com>
References: <20060429032246.4999.21714.sendpatchset@schroedinger.engr.sgi.com>
Subject: [PATCH 1/7] PM cleanup: Rename "ignrefs" to "migration"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: linux-mm@kvack.org, Hugh Dickins <hugh@veritas.com>, Lee Schermerhorn <lee.schermerhorn@hp.com>, Christoph Lameter <clameter@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

migrate is a better name since it is only used by page migration.

Signed-off-by: Christoph Lameter <clameter@sgi.com>
Signed-off-by: Andrew Morton <akpm@osdl.org>
---

 mm/rmap.c |   18 +++++++++---------
 1 files changed, 9 insertions(+), 9 deletions(-)

diff -puN mm/rmap.c~swapless-v2-try_to_unmap-rename-ignrefs-to-migration mm/rmap.c
--- devel/mm/rmap.c~swapless-v2-try_to_unmap-rename-ignrefs-to-migration	2006-04-13 17:09:50.000000000 -0700
+++ devel-akpm/mm/rmap.c	2006-04-13 17:10:01.000000000 -0700
@@ -578,7 +578,7 @@ void page_remove_rmap(struct page *page)
  * repeatedly from either try_to_unmap_anon or try_to_unmap_file.
  */
 static int try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
-				int ignore_refs)
+				int migration)
 {
 	struct mm_struct *mm = vma->vm_mm;
 	unsigned long address;
@@ -602,7 +602,7 @@ static int try_to_unmap_one(struct page 
 	 */
 	if ((vma->vm_flags & VM_LOCKED) ||
 			(ptep_clear_flush_young(vma, address, pte)
-				&& !ignore_refs)) {
+				&& !migration)) {
 		ret = SWAP_FAIL;
 		goto out_unmap;
 	}
@@ -736,7 +736,7 @@ static void try_to_unmap_cluster(unsigne
 	pte_unmap_unlock(pte - 1, ptl);
 }
 
-static int try_to_unmap_anon(struct page *page, int ignore_refs)
+static int try_to_unmap_anon(struct page *page, int migration)
 {
 	struct anon_vma *anon_vma;
 	struct vm_area_struct *vma;
@@ -747,7 +747,7 @@ static int try_to_unmap_anon(struct page
 		return ret;
 
 	list_for_each_entry(vma, &anon_vma->head, anon_vma_node) {
-		ret = try_to_unmap_one(page, vma, ignore_refs);
+		ret = try_to_unmap_one(page, vma, migration);
 		if (ret == SWAP_FAIL || !page_mapped(page))
 			break;
 	}
@@ -764,7 +764,7 @@ static int try_to_unmap_anon(struct page
  *
  * This function is only called from try_to_unmap for object-based pages.
  */
-static int try_to_unmap_file(struct page *page, int ignore_refs)
+static int try_to_unmap_file(struct page *page, int migration)
 {
 	struct address_space *mapping = page->mapping;
 	pgoff_t pgoff = page->index << (PAGE_CACHE_SHIFT - PAGE_SHIFT);
@@ -778,7 +778,7 @@ static int try_to_unmap_file(struct page
 
 	spin_lock(&mapping->i_mmap_lock);
 	vma_prio_tree_foreach(vma, &iter, &mapping->i_mmap, pgoff, pgoff) {
-		ret = try_to_unmap_one(page, vma, ignore_refs);
+		ret = try_to_unmap_one(page, vma, migration);
 		if (ret == SWAP_FAIL || !page_mapped(page))
 			goto out;
 	}
@@ -863,16 +863,16 @@ out:
  * SWAP_AGAIN	- we missed a mapping, try again later
  * SWAP_FAIL	- the page is unswappable
  */
-int try_to_unmap(struct page *page, int ignore_refs)
+int try_to_unmap(struct page *page, int migration)
 {
 	int ret;
 
 	BUG_ON(!PageLocked(page));
 
 	if (PageAnon(page))
-		ret = try_to_unmap_anon(page, ignore_refs);
+		ret = try_to_unmap_anon(page, migration);
 	else
-		ret = try_to_unmap_file(page, ignore_refs);
+		ret = try_to_unmap_file(page, migration);
 
 	if (!page_mapped(page))
 		ret = SWAP_SUCCESS;
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
