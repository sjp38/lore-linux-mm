From: Paolo 'Blaisorblade' Giarrusso <blaisorblade@yahoo.it>
Subject: [PATCH 03/11] RFP prot support: handle MANYPROTS VMAs
Date: Sat, 31 Mar 2007 02:35:25 +0200
Message-ID: <20070331003524.3415.94582.stgit@americanbeauty.home.lan>
In-Reply-To: <20070331003453.3415.70825.stgit@americanbeauty.home.lan>
References: <20070331003453.3415.70825.stgit@americanbeauty.home.lan>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: mingo@redhat.com, linux-mm@kvack.org, Jeff Dike <jdike@addtoit.com>, Paolo 'Blaisorblade' Giarrusso <blaisorblade@yahoo.it>
List-ID: <linux-mm.kvack.org>

Handle the possible existance of VM_MANYPROTS vmas, without actually creating
them.

* Replace old uses of pgoff_to_pte with pgoff_prot_to_pte.
* Introduce the flag, use it to read permissions from the PTE rather than from
  the VMA flags.
* Replace the linear_page_index() check with save_nonlinear_pte(), which
  encapsulates the check.
2.6.14+ updates:
* Add VM_MANYPROTS among cases needing copying of PTE at fork time rather than
  faulting.
* check for VM_MANYPROTS in do_file_pte before complaining for pte_file PTE
* check for VM_MANYPROTS in *_populate, when we skip installing pte_file PTE's
  for linear areas

Below there is a long explaination of why I've added VM_MANYPROTS, rather
than simply overload VM_NONLINEAR. You can freely skip that if you have real
work to do :-).

However, this patch is only sufficient if VM_MANYPROTS vmas are also marked as
nonlinear. Otherwise also other changes are needed.

I've implemented both solutions - I've sent only full support for the easy case,
but possibly I'll afterwards reintroduce the other changes; in particular,
they're needed to make this useful for general usage beyond UML.

*) remap_file_pages protection support: add VM_MANYPROTS to fix existing usage of mprotect()

Distinguish between "normal" VMA and VMA with variable protection, by
adding the VM_MANYPROTS flag. This is needed for various reasons:

* notify the arch fault handlers that they must not check VMA protection for
  giving SIGSEGV
* fixing regression of mprotect() on !VM_MANYPROTS mappings (see below)
* (in next patches) giving a sensible behaviour to mprotect on VM_MANYPROTS
  mappings

* (theoretical, rejected) avoid regression in max file offset with r_f_p() for
  older mappings; we could use either the old offset encoding or the new
  offset-prot encoding depending on this flag.
  It's trivial to do, just I don't know whether existing apps will overflow
  the new limits. They go down from 2Tb to 1Tb on i386 and 512G on PPC, and
  from 256G to 128G on S390/31 bits. However this was rejected by a comment in
  an earlier iteration of this patch, because such applications should have
  moved to 64bit anyway.
* (possible feature) on MAP_PRIVATE mappings, especially when they are readonly,
  we can easily support VM_MANYPROTS. This has been explicitly requested by
  Ulrich Drepper for DSO handling - creating a PROT_NONE VMA for guard pages is
  bad. And that is worse when you have a binary with 100 DSO, or a program with
  really many threads - Ulrich profiled a workload where the RB-tree lookup
  function is a performance bottleneck.

In fact, without this flag, we'd have indeed a regression with
remap_file_pages VS mprotect, on uniform nonlinear VMAs.

mprotect alters the VMA prots and walks each present PTE, ignoring installed
ones, even when pte_file() is on; their saved prots will be restored on faults,
ignoring VMA ones and losing the mprotect() on them. So, in do_file_page(), we
must restore anyway VMA prots when the VMA is uniform, as we used to do before
this trail of patches.

Signed-off-by: Paolo 'Blaisorblade' Giarrusso <blaisorblade@yahoo.it>
---

 include/linux/mm.h      |    7 +++++++
 include/linux/pagemap.h |   22 ++++++++++++++++++++++
 mm/fremap.c             |    4 ++--
 mm/memory.c             |   41 +++++++++++++++++++++++++++++------------
 mm/rmap.c               |    3 +--
 5 files changed, 61 insertions(+), 16 deletions(-)

diff --git a/include/linux/mm.h b/include/linux/mm.h
index bcea993..1959d9b 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -168,7 +168,14 @@ extern int do_mprotect(unsigned long start, size_t len, unsigned long prot);
 #define VM_ACCOUNT	0x00100000	/* Is a VM accounted object */
 #define VM_HUGETLB	0x00400000	/* Huge TLB Page VM */
 #define VM_NONLINEAR	0x00800000	/* Is non-linear (remap_file_pages) */
+
+#ifndef CONFIG_MMU
 #define VM_MAPPED_COPY	0x01000000	/* T if mapped copy of data (nommu mmap) */
+#else
+#define VM_MANYPROTS	0x01000000	/* The VM individual pages have
+					   different protections
+					   (remap_file_pages)*/
+#endif
 #define VM_INSERTPAGE	0x02000000	/* The vma has had "vm_insert_page()" done on it */
 #define VM_ALWAYSDUMP	0x04000000	/* Always include in core dumps */
 
diff --git a/include/linux/pagemap.h b/include/linux/pagemap.h
index 10b96cc..acd10e8 100644
--- a/include/linux/pagemap.h
+++ b/include/linux/pagemap.h
@@ -155,6 +155,28 @@ static inline pgoff_t linear_page_index(struct vm_area_struct *vma,
 	return pgoff >> (PAGE_CACHE_SHIFT - PAGE_SHIFT);
 }
 
+/***
+ * Checks if the PTE is nonlinear, and if yes sets it.
+ * @vma: the VMA in which @addr is; we don't check if it's VM_NONLINEAR, just
+ * if this PTE is nonlinear.
+ * @addr: the addr which @pte refers to.
+ * @pte: the old PTE value (to read its protections.
+ * @ptep: the PTE pointer (for setting it).
+ * @mm: passed to set_pte_at.
+ * @page: the page which was installed (to read its ->index, i.e. the old
+ * offset inside the file.
+ */
+static inline void save_nonlinear_pte(pte_t pte, pte_t * ptep, struct
+		vm_area_struct *vma, struct mm_struct *mm, struct page* page,
+		unsigned long addr)
+{
+	pgprot_t pgprot = pte_to_pgprot(pte);
+	if (linear_page_index(vma, addr) != page->index ||
+		pgprot_val(pgprot) != pgprot_val(vma->vm_page_prot))
+		set_pte_at(mm, addr, ptep, pgoff_prot_to_pte(page->index,
+					pgprot));
+}
+
 extern void FASTCALL(__lock_page(struct page *page));
 extern void FASTCALL(__lock_page_nosync(struct page *page));
 extern void FASTCALL(unlock_page(struct page *page));
diff --git a/mm/fremap.c b/mm/fremap.c
index 5f50d73..f571674 100644
--- a/mm/fremap.c
+++ b/mm/fremap.c
@@ -51,7 +51,7 @@ static void zap_pte(struct mm_struct *mm, struct vm_area_struct *vma,
  * previously existing mapping.
  */
 static int install_file_pte(struct mm_struct *mm, struct vm_area_struct *vma,
-		unsigned long addr, unsigned long pgoff, pgprot_t prot)
+		unsigned long addr, unsigned long pgoff, pgprot_t pgprot)
 {
 	int err = -ENOMEM;
 	pte_t *pte;
@@ -64,7 +64,7 @@ static int install_file_pte(struct mm_struct *mm, struct vm_area_struct *vma,
 	if (!pte_none(*pte))
 		zap_pte(mm, vma, addr, pte);
 
-	set_pte_at(mm, addr, pte, pgoff_to_pte(pgoff));
+	set_pte_at(mm, addr, pte, pgoff_prot_to_pte(pgoff, pgprot));
 	/*
 	 * We don't need to run update_mmu_cache() here because the "file pte"
 	 * being installed by install_file_pte() is not a real pte - it's a
diff --git a/mm/memory.c b/mm/memory.c
index 57559a5..577b8bc 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -597,7 +597,8 @@ int copy_page_range(struct mm_struct *dst_mm, struct mm_struct *src_mm,
 	 * readonly mappings. The tradeoff is that copy_page_range is more
 	 * efficient than faulting.
 	 */
-	if (!(vma->vm_flags & (VM_HUGETLB|VM_NONLINEAR|VM_PFNMAP|VM_INSERTPAGE))) {
+	if (!(vma->vm_flags & (VM_HUGETLB|VM_NONLINEAR|VM_MANYPROTS|
+					VM_PFNMAP|VM_INSERTPAGE))) {
 		if (!vma->anon_vma)
 			return 0;
 	}
@@ -667,11 +668,11 @@ static unsigned long zap_pte_range(struct mmu_gather *tlb,
 			tlb_remove_tlb_entry(tlb, pte, addr);
 			if (unlikely(!page))
 				continue;
-			if (unlikely(details) && details->nonlinear_vma
-			    && linear_page_index(details->nonlinear_vma,
-						addr) != page->index)
-				set_pte_at(mm, addr, pte,
-					   pgoff_to_pte(page->index));
+			if (unlikely(details) && details->nonlinear_vma) {
+				save_nonlinear_pte(ptent, pte,
+						details->nonlinear_vma,
+						mm, page, addr);
+			}
 			if (PageAnon(page))
 				anon_rss--;
 			else {
@@ -2213,10 +2214,14 @@ oom:
  * We enter with non-exclusive mmap_sem (to exclude vma changes,
  * but allow concurrent faults), and pte mapped but not yet locked.
  * We return with mmap_sem still held, but pte unmapped and unlocked.
+ *
+ * __do_fault_pgprot allows specifying also page protection for VM_MANYPROTS
+ * vmas.
  */
-static int __do_fault(struct mm_struct *mm, struct vm_area_struct *vma,
+static int __do_fault_pgprot(struct mm_struct *mm, struct vm_area_struct *vma,
 		unsigned long address, pte_t *page_table, pmd_t *pmd,
-		pgoff_t pgoff, unsigned int flags, pte_t orig_pte)
+		pgoff_t pgoff, pgprot_t pgprot, unsigned int flags,
+		pte_t orig_pte)
 {
 	spinlock_t *ptl;
 	struct page *page, *faulted_page;
@@ -2307,7 +2312,7 @@ static int __do_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 	/* Only go through if we didn't race with anybody else... */
 	if (likely(pte_same(*page_table, orig_pte))) {
 		flush_icache_page(vma, page);
-		entry = mk_pte(page, vma->vm_page_prot);
+		entry = mk_pte(page, pgprot);
 		if (flags & FAULT_FLAG_WRITE)
 			entry = maybe_mkwrite(pte_mkdirty(entry), vma);
 		set_pte_at(mm, address, page_table, entry);
@@ -2348,6 +2353,15 @@ out:
 	return fdata.type;
 }
 
+static inline int __do_fault(struct mm_struct *mm, struct vm_area_struct *vma,
+		unsigned long address, pte_t *page_table, pmd_t *pmd,
+		pgoff_t pgoff, unsigned int flags, pte_t orig_pte)
+{
+	return __do_fault_pgprot(mm, vma, address, page_table, pmd, pgoff,
+			vma->vm_page_prot, flags, orig_pte);
+
+}
+
 static int do_linear_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 		unsigned long address, pte_t *page_table, pmd_t *pmd,
 		int write_access, pte_t orig_pte)
@@ -2377,11 +2391,12 @@ static int do_nonlinear_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 	unsigned int flags = FAULT_FLAG_NONLINEAR |
 				(write_access ? FAULT_FLAG_WRITE : 0);
 	pgoff_t pgoff;
+	pgprot_t pgprot;
 
 	if (!pte_unmap_same(mm, pmd, page_table, orig_pte))
 		return VM_FAULT_MINOR;
 
-	if (unlikely(!(vma->vm_flags & VM_NONLINEAR) ||
+	if (unlikely(!(vma->vm_flags & (VM_NONLINEAR | VM_MANYPROTS)) ||
 			!(vma->vm_flags & VM_CAN_NONLINEAR))) {
 		/*
 		 * Page table corrupted: show pte and kill process.
@@ -2391,9 +2406,11 @@ static int do_nonlinear_fault(struct mm_struct *mm, struct vm_area_struct *vma,
 	}
 
 	pgoff = pte_to_pgoff(orig_pte);
+	pgprot = (vma->vm_flags & VM_MANYPROTS) ? pte_file_to_pgprot(orig_pte) :
+		vma->vm_page_prot;
 
-	return __do_fault(mm, vma, address, page_table, pmd, pgoff,
-							flags, orig_pte);
+	return __do_fault_pgprot(mm, vma, address, page_table, pmd, pgoff,
+						pgprot, flags, orig_pte);
 }
 
 /*
diff --git a/mm/rmap.c b/mm/rmap.c
index 31d758d..63cd875 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -831,8 +831,7 @@ static void try_to_unmap_cluster(unsigned long cursor,
 		pteval = ptep_clear_flush(vma, address, pte);
 
 		/* If nonlinear, store the file page offset in the pte. */
-		if (page->index != linear_page_index(vma, address))
-			set_pte_at(mm, address, pte, pgoff_to_pte(page->index));
+		save_nonlinear_pte(pteval, pte, vma, mm, page, address);
 
 		/* Move the dirty bit to the physical page now the pte is gone. */
 		if (pte_dirty(pteval))



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
