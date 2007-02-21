From: Nick Piggin <npiggin@suse.de>
Message-Id: <20070221023750.6306.91917.sendpatchset@linux.site>
In-Reply-To: <20070221023656.6306.246.sendpatchset@linux.site>
References: <20070221023656.6306.246.sendpatchset@linux.site>
Subject: [patch 5/6] mm: merge nopfn into fault
Date: Wed, 21 Feb 2007 05:50:31 +0100 (CET)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux Memory Management <linux-mm@kvack.org>, Andrew Morton <akpm@osdl.org>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, Nick Piggin <npiggin@suse.de>, Benjamin Herrenschmidt <benh@kernel.crashing.org>
List-ID: <linux-mm.kvack.org>

Remove ->nopfn and reimplement the existing handlers with ->fault

Signed-off-by: Nick Piggin <npiggin@suse.de>

 arch/powerpc/platforms/cell/spufs/file.c |   90 ++++++++++++++++---------------
 drivers/char/mspec.c                     |   29 ++++++---
 include/linux/mm.h                       |    8 --
 mm/memory.c                              |   58 +------------------
 4 files changed, 71 insertions(+), 114 deletions(-)

Index: linux-2.6/drivers/char/mspec.c
===================================================================
--- linux-2.6.orig/drivers/char/mspec.c
+++ linux-2.6/drivers/char/mspec.c
@@ -182,24 +182,25 @@ mspec_close(struct vm_area_struct *vma)
 
 
 /*
- * mspec_nopfn
+ * mspec_fault
  *
  * Creates a mspec page and maps it to user space.
  */
-static unsigned long
-mspec_nopfn(struct vm_area_struct *vma, unsigned long address)
+static struct page *
+mspec_fault(struct fault_data *fdata)
 {
 	unsigned long paddr, maddr;
 	unsigned long pfn;
-	int index;
-	struct vma_data *vdata = vma->vm_private_data;
+	int index = fdata->pgoff;
+	struct vma_data *vdata = fdata->vma->vm_private_data;
 
-	index = (address - vma->vm_start) >> PAGE_SHIFT;
 	maddr = (volatile unsigned long) vdata->maddr[index];
 	if (maddr == 0) {
 		maddr = uncached_alloc_page(numa_node_id());
-		if (maddr == 0)
-			return NOPFN_OOM;
+		if (maddr == 0) {
+			fdata->type = VM_FAULT_OOM;
+			return NULL;
+		}
 
 		spin_lock(&vdata->lock);
 		if (vdata->maddr[index] == 0) {
@@ -219,13 +220,21 @@ mspec_nopfn(struct vm_area_struct *vma, 
 
 	pfn = paddr >> PAGE_SHIFT;
 
-	return pfn;
+	fdata->type = VM_FAULT_MINOR;
+	/*
+	 * vm_insert_pfn can fail with -EBUSY, but in that case it will
+	 * be because another thread has installed the pte first, so it
+	 * is no problem.
+	 */
+	vm_insert_pfn(fdata->vma, fdata->address, pfn);
+
+	return NULL;
 }
 
 static struct vm_operations_struct mspec_vm_ops = {
 	.open = mspec_open,
 	.close = mspec_close,
-	.nopfn = mspec_nopfn
+	.fault = mspec_fault,
 };
 
 /*
Index: linux-2.6/include/linux/mm.h
===================================================================
--- linux-2.6.orig/include/linux/mm.h
+++ linux-2.6/include/linux/mm.h
@@ -230,7 +230,6 @@ struct vm_operations_struct {
 	void (*close)(struct vm_area_struct * area);
 	struct page * (*fault)(struct vm_area_struct *vma, struct fault_data * fdata);
 	struct page * (*nopage)(struct vm_area_struct * area, unsigned long address, int *type);
-	unsigned long (*nopfn)(struct vm_area_struct * area, unsigned long address);
 	int (*populate)(struct vm_area_struct * area, unsigned long address, unsigned long len, pgprot_t prot, unsigned long pgoff, int nonblock);
 
 	/* notification that a previously read-only page is about to become
@@ -660,13 +659,6 @@ static inline int page_mapped(struct pag
 #define NOPAGE_OOM	((struct page *) (-1))
 
 /*
- * Error return values for the *_nopfn functions
- */
-#define NOPFN_SIGBUS	((unsigned long) -1)
-#define NOPFN_OOM	((unsigned long) -2)
-#define NOPFN_REFAULT	((unsigned long) -3)
-
-/*
  * Different kinds of faults, as returned by handle_mm_fault().
  * Used to decide whether a process gets delivered SIGBUS or
  * just gets major/minor fault counters bumped up.
Index: linux-2.6/mm/memory.c
===================================================================
--- linux-2.6.orig/mm/memory.c
+++ linux-2.6/mm/memory.c
@@ -1288,6 +1288,11 @@ EXPORT_SYMBOL(vm_insert_page);
  *
  * This function should only be called from a vm_ops->fault handler, and
  * in that case the handler should return NULL.
+ *
+ * vma cannot be a COW mapping.
+ *
+ * As this is called only for pages that do not currently exist, we
+ * do not need to flush old virtual caches or the TLB.
  */
 int vm_insert_pfn(struct vm_area_struct *vma, unsigned long addr,
 		unsigned long pfn)
@@ -2343,56 +2348,6 @@ static int do_nonlinear_fault(struct mm_
 }
 
 /*
- * do_no_pfn() tries to create a new page mapping for a page without
- * a struct_page backing it
- *
- * As this is called only for pages that do not currently exist, we
- * do not need to flush old virtual caches or the TLB.
- *
- * We enter with non-exclusive mmap_sem (to exclude vma changes,
- * but allow concurrent faults), and pte mapped but not yet locked.
- * We return with mmap_sem still held, but pte unmapped and unlocked.
- *
- * It is expected that the ->nopfn handler always returns the same pfn
- * for a given virtual mapping.
- *
- * Mark this `noinline' to prevent it from bloating the main pagefault code.
- */
-static noinline int do_no_pfn(struct mm_struct *mm, struct vm_area_struct *vma,
-		     unsigned long address, pte_t *page_table, pmd_t *pmd,
-		     int write_access)
-{
-	spinlock_t *ptl;
-	pte_t entry;
-	unsigned long pfn;
-	int ret = VM_FAULT_MINOR;
-
-	pte_unmap(page_table);
-	BUG_ON(!(vma->vm_flags & VM_PFNMAP));
-	BUG_ON(is_cow_mapping(vma->vm_flags));
-
-	pfn = vma->vm_ops->nopfn(vma, address & PAGE_MASK);
-	if (unlikely(pfn == NOPFN_OOM))
-		return VM_FAULT_OOM;
-	else if (unlikely(pfn == NOPFN_SIGBUS))
-		return VM_FAULT_SIGBUS;
-	else if (unlikely(pfn == NOPFN_REFAULT))
-		return VM_FAULT_MINOR;
-
-	page_table = pte_offset_map_lock(mm, pmd, address, &ptl);
-
-	/* Only go through if we didn't race with anybody else... */
-	if (pte_none(*page_table)) {
-		entry = pfn_pte(pfn, vma->vm_page_prot);
-		if (write_access)
-			entry = maybe_mkwrite(pte_mkdirty(entry), vma);
-		set_pte_at(mm, address, page_table, entry);
-	}
-	pte_unmap_unlock(page_table, ptl);
-	return ret;
-}
-
-/*
  * Fault of a previously existing named mapping. Repopulate the pte
  * from the encoded file_pte if possible. This enables swappable
  * nonlinear vmas.
@@ -2463,9 +2418,6 @@ static inline int handle_pte_fault(struc
 				if (vma->vm_ops->fault || vma->vm_ops->nopage)
 					return do_linear_fault(mm, vma, address,
 						pte, pmd, write_access, entry);
-				if (unlikely(vma->vm_ops->nopfn))
-					return do_no_pfn(mm, vma, address, pte,
-							 pmd, write_access);
 			}
 			return do_anonymous_page(mm, vma, address,
 						 pte, pmd, write_access);
Index: linux-2.6/arch/powerpc/platforms/cell/spufs/file.c
===================================================================
--- linux-2.6.orig/arch/powerpc/platforms/cell/spufs/file.c
+++ linux-2.6/arch/powerpc/platforms/cell/spufs/file.c
@@ -95,16 +95,16 @@ spufs_mem_write(struct file *file, const
 	return ret;
 }
 
-static unsigned long spufs_mem_mmap_nopfn(struct vm_area_struct *vma,
-					  unsigned long address)
+static struct page *spufs_mem_mmap_fault(struct vm_area_struct *vma,
+					  struct faul_data *fdata)
 {
 	struct spu_context *ctx = vma->vm_file->private_data;
-	unsigned long pfn, offset = address - vma->vm_start;
+	unsigned long pfn, offset = fdata->pgoff << PAGE_SHIFT;
 
-	offset += vma->vm_pgoff << PAGE_SHIFT;
-
-	if (offset >= LS_SIZE)
-		return NOPFN_SIGBUS;
+	if (offset >= LS_SIZE) {
+		fdata->type = VM_FAULT_SIGBUS;
+		return NULL;
+	}
 
 	spu_acquire(ctx);
 
@@ -121,12 +121,13 @@ static unsigned long spufs_mem_mmap_nopf
 
 	spu_release(ctx);
 
-	return NOPFN_REFAULT;
+	fdata->type = VM_FAULT_MINOR;
+	return NULL;
 }
 
 
 static struct vm_operations_struct spufs_mem_mmap_vmops = {
-	.nopfn = spufs_mem_mmap_nopfn,
+	.fault = spufs_mem_mmap_fault,
 };
 
 static int
@@ -151,42 +152,45 @@ static const struct file_operations spuf
 	.mmap    = spufs_mem_mmap,
 };
 
-static unsigned long spufs_ps_nopfn(struct vm_area_struct *vma,
-				    unsigned long address,
+static struct page *spufs_ps_fault(struct vm_area_struct *vma,
+				    struct fault_data *fdata,
 				    unsigned long ps_offs,
 				    unsigned long ps_size)
 {
 	struct spu_context *ctx = vma->vm_file->private_data;
-	unsigned long area, offset = address - vma->vm_start;
+	unsigned long area, offset = fdata->pgoff << PAGE_SHIFT;
 	int ret;
 
-	offset += vma->vm_pgoff << PAGE_SHIFT;
-	if (offset >= ps_size)
-		return NOPFN_SIGBUS;
+	if (offset >= ps_size) {
+		fdata->type = VM_FAULT_SIGBUS;
+		return NULL;
+	}
+
+	fdata->type = VM_FAULT_MINOR;
 
 	/* error here usually means a signal.. we might want to test
 	 * the error code more precisely though
 	 */
 	ret = spu_acquire_runnable(ctx, 0);
 	if (ret)
-		return NOPFN_REFAULT;
+		return NULL;
 
 	area = ctx->spu->problem_phys + ps_offs;
 	vm_insert_pfn(vma, address, (area + offset) >> PAGE_SHIFT);
 	spu_release(ctx);
 
-	return NOPFN_REFAULT;
+	return NULL;
 }
 
 #if SPUFS_MMAP_4K
-static unsigned long spufs_cntl_mmap_nopfn(struct vm_area_struct *vma,
-					   unsigned long address)
+static struct page *spufs_cntl_mmap_fault(struct vm_area_struct *vma,
+					   struct fault_data *fdata)
 {
-	return spufs_ps_nopfn(vma, address, 0x4000, 0x1000);
+	return spufs_ps_fault(vma, fdata, 0x4000, 0x1000);
 }
 
 static struct vm_operations_struct spufs_cntl_mmap_vmops = {
-	.nopfn = spufs_cntl_mmap_nopfn,
+	.fault = spufs_cntl_mmap_fault,
 };
 
 /*
@@ -783,23 +787,23 @@ static ssize_t spufs_signal1_write(struc
 	return 4;
 }
 
-static unsigned long spufs_signal1_mmap_nopfn(struct vm_area_struct *vma,
-					      unsigned long address)
+static struct page *spufs_signal1_mmap_fault(struct vm_area_struct *vma,
+					      struct fault_data *fdata)
 {
 #if PAGE_SIZE == 0x1000
-	return spufs_ps_nopfn(vma, address, 0x14000, 0x1000);
+	return spufs_ps_fault(vma, fdata, 0x14000, 0x1000);
 #elif PAGE_SIZE == 0x10000
 	/* For 64k pages, both signal1 and signal2 can be used to mmap the whole
 	 * signal 1 and 2 area
 	 */
-	return spufs_ps_nopfn(vma, address, 0x10000, 0x10000);
+	return spufs_ps_fault(vma, fdata, 0x10000, 0x10000);
 #else
 #error unsupported page size
 #endif
 }
 
 static struct vm_operations_struct spufs_signal1_mmap_vmops = {
-	.nopfn = spufs_signal1_mmap_nopfn,
+	.fault = spufs_signal1_mmap_fault,
 };
 
 static int spufs_signal1_mmap(struct file *file, struct vm_area_struct *vma)
@@ -891,23 +895,23 @@ static ssize_t spufs_signal2_write(struc
 }
 
 #if SPUFS_MMAP_4K
-static unsigned long spufs_signal2_mmap_nopfn(struct vm_area_struct *vma,
-					      unsigned long address)
+static struct page *spufs_signal2_mmap_fault(struct vm_area_struct *vma,
+					      struct fault_data *fdata)
 {
 #if PAGE_SIZE == 0x1000
-	return spufs_ps_nopfn(vma, address, 0x1c000, 0x1000);
+	return spufs_ps_fault(vma, fdata, 0x1c000, 0x1000);
 #elif PAGE_SIZE == 0x10000
 	/* For 64k pages, both signal1 and signal2 can be used to mmap the whole
 	 * signal 1 and 2 area
 	 */
-	return spufs_ps_nopfn(vma, address, 0x10000, 0x10000);
+	return spufs_ps_fault(vma, fdata, 0x10000, 0x10000);
 #else
 #error unsupported page size
 #endif
 }
 
 static struct vm_operations_struct spufs_signal2_mmap_vmops = {
-	.nopfn = spufs_signal2_mmap_nopfn,
+	.fault = spufs_signal2_mmap_fault,
 };
 
 static int spufs_signal2_mmap(struct file *file, struct vm_area_struct *vma)
@@ -992,14 +996,14 @@ DEFINE_SIMPLE_ATTRIBUTE(spufs_signal2_ty
 					spufs_signal2_type_set, "%llu");
 
 #if SPUFS_MMAP_4K
-static unsigned long spufs_mss_mmap_nopfn(struct vm_area_struct *vma,
-					  unsigned long address)
+static struct page *spufs_mss_mmap_fault(struct vm_area_struct *vma,
+					  struct fault_data *fdata)
 {
-	return spufs_ps_nopfn(vma, address, 0x0000, 0x1000);
+	return spufs_ps_fault(vma, fdata, 0x0000, 0x1000);
 }
 
 static struct vm_operations_struct spufs_mss_mmap_vmops = {
-	.nopfn = spufs_mss_mmap_nopfn,
+	.fault = spufs_mss_mmap_fault,
 };
 
 /*
@@ -1037,14 +1041,14 @@ static const struct file_operations spuf
 	.mmap	 = spufs_mss_mmap,
 };
 
-static unsigned long spufs_psmap_mmap_nopfn(struct vm_area_struct *vma,
-					    unsigned long address)
+static struct page *spufs_psmap_mmap_fault(struct vm_area_struct *vma,
+					    struct fault_data *fdata)
 {
-	return spufs_ps_nopfn(vma, address, 0x0000, 0x20000);
+	return spufs_ps_fault(vma, fdata, 0x0000, 0x20000);
 }
 
 static struct vm_operations_struct spufs_psmap_mmap_vmops = {
-	.nopfn = spufs_psmap_mmap_nopfn,
+	.fault = spufs_psmap_mmap_fault,
 };
 
 /*
@@ -1081,14 +1085,14 @@ static const struct file_operations spuf
 
 
 #if SPUFS_MMAP_4K
-static unsigned long spufs_mfc_mmap_nopfn(struct vm_area_struct *vma,
-					  unsigned long address)
+static struct page *spufs_mfc_mmap_fault(struct vm_area_struct *vma,
+					  struct fault_data *fdata)
 {
-	return spufs_ps_nopfn(vma, address, 0x3000, 0x1000);
+	return spufs_ps_fault(vma, fdata, 0x3000, 0x1000);
 }
 
 static struct vm_operations_struct spufs_mfc_mmap_vmops = {
-	.nopfn = spufs_mfc_mmap_nopfn,
+	.fault = spufs_mfc_mmap_fault,
 };
 
 /*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
