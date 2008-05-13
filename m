Date: Tue, 13 May 2008 09:47:23 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: [patch 1/2] spufs: convert nopfn to fault
Message-ID: <20080513074723.GB12869@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>, Jeremy Kerr <jk@ozlabs.org>
List-ID: <linux-mm.kvack.org>

This version fixes the 64K page size fault problem that Jeremy found in
testing.
--

spufs: convert nopfn to fault

From: Nick Piggin <npiggin@suse.de>

Signed-off-by: Nick Piggin <npiggin@suse.de>
Acked-by: Jeremy Kerr <jk@ozlabs.org>
---

 arch/powerpc/platforms/cell/spufs/file.c     |   91 ++++++++++++---------------
 arch/powerpc/platforms/cell/spufs/sputrace.c |    8 +-
 2 files changed, 46 insertions(+), 53 deletions(-)

Index: linux-2.6/arch/powerpc/platforms/cell/spufs/file.c
===================================================================
--- linux-2.6.orig/arch/powerpc/platforms/cell/spufs/file.c
+++ linux-2.6/arch/powerpc/platforms/cell/spufs/file.c
@@ -237,11 +237,13 @@ spufs_mem_write(struct file *file, const
 	return size;
 }
 
-static unsigned long spufs_mem_mmap_nopfn(struct vm_area_struct *vma,
-					  unsigned long address)
+static int
+spufs_mem_mmap_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 {
 	struct spu_context *ctx	= vma->vm_file->private_data;
-	unsigned long pfn, offset, addr0 = address;
+	unsigned long address = (unsigned long)vmf->virtual_address;
+	unsigned long pfn, offset;
+
 #ifdef CONFIG_SPU_FS_64K_LS
 	struct spu_state *csa = &ctx->csa;
 	int psize;
@@ -259,15 +261,15 @@ static unsigned long spufs_mem_mmap_nopf
 	}
 #endif /* CONFIG_SPU_FS_64K_LS */
 
-	offset = (address - vma->vm_start) + (vma->vm_pgoff << PAGE_SHIFT);
+	offset = vmf->pgoff << PAGE_SHIFT;
 	if (offset >= LS_SIZE)
-		return NOPFN_SIGBUS;
+		return VM_FAULT_SIGBUS;
 
-	pr_debug("spufs_mem_mmap_nopfn address=0x%lx -> 0x%lx, offset=0x%lx\n",
-		 addr0, address, offset);
+	pr_debug("spufs_mem_mmap_fault address=0x%lx, offset=0x%lx\n",
+			address, offset);
 
 	if (spu_acquire(ctx))
-		return NOPFN_REFAULT;
+		return VM_FAULT_NOPAGE;
 
 	if (ctx->state == SPU_STATE_SAVED) {
 		vma->vm_page_prot = __pgprot(pgprot_val(vma->vm_page_prot)
@@ -282,12 +284,12 @@ static unsigned long spufs_mem_mmap_nopf
 
 	spu_release(ctx);
 
-	return NOPFN_REFAULT;
+	return VM_FAULT_NOPAGE;
 }
 
 
 static struct vm_operations_struct spufs_mem_mmap_vmops = {
-	.nopfn = spufs_mem_mmap_nopfn,
+	.fault = spufs_mem_mmap_fault,
 };
 
 static int spufs_mem_mmap(struct file *file, struct vm_area_struct *vma)
@@ -350,20 +352,19 @@ static const struct file_operations spuf
 #endif
 };
 
-static unsigned long spufs_ps_nopfn(struct vm_area_struct *vma,
-				    unsigned long address,
+static int spufs_ps_fault(struct vm_area_struct *vma,
+				    struct vm_fault *vmf,
 				    unsigned long ps_offs,
 				    unsigned long ps_size)
 {
 	struct spu_context *ctx = vma->vm_file->private_data;
-	unsigned long area, offset = address - vma->vm_start;
+	unsigned long area, offset = vmf->pgoff << PAGE_SHIFT;
 	int ret = 0;
 
-	spu_context_nospu_trace(spufs_ps_nopfn__enter, ctx);
+	spu_context_nospu_trace(spufs_ps_fault__enter, ctx);
 
-	offset += vma->vm_pgoff << PAGE_SHIFT;
 	if (offset >= ps_size)
-		return NOPFN_SIGBUS;
+		return VM_FAULT_SIGBUS;
 
 	/*
 	 * Because we release the mmap_sem, the context may be destroyed while
@@ -377,7 +378,7 @@ static unsigned long spufs_ps_nopfn(stru
 	 * pages to hand out to the user, but we don't want to wait
 	 * with the mmap_sem held.
 	 * It is possible to drop the mmap_sem here, but then we need
-	 * to return NOPFN_REFAULT because the mappings may have
+	 * to return VM_FAULT_NOPAGE because the mappings may have
 	 * hanged.
 	 */
 	if (spu_acquire(ctx))
@@ -385,14 +386,15 @@ static unsigned long spufs_ps_nopfn(stru
 
 	if (ctx->state == SPU_STATE_SAVED) {
 		up_read(&current->mm->mmap_sem);
-		spu_context_nospu_trace(spufs_ps_nopfn__sleep, ctx);
+		spu_context_nospu_trace(spufs_ps_fault__sleep, ctx);
 		ret = spufs_wait(ctx->run_wq, ctx->state == SPU_STATE_RUNNABLE);
-		spu_context_trace(spufs_ps_nopfn__wake, ctx, ctx->spu);
+		spu_context_trace(spufs_ps_fault__wake, ctx, ctx->spu);
 		down_read(&current->mm->mmap_sem);
 	} else {
 		area = ctx->spu->problem_phys + ps_offs;
-		vm_insert_pfn(vma, address, (area + offset) >> PAGE_SHIFT);
-		spu_context_trace(spufs_ps_nopfn__insert, ctx, ctx->spu);
+		vm_insert_pfn(vma, (unsigned long)vmf->virtual_address,
+					(area + offset) >> PAGE_SHIFT);
+		spu_context_trace(spufs_ps_fault__insert, ctx, ctx->spu);
 	}
 
 	if (!ret)
@@ -400,18 +402,18 @@ static unsigned long spufs_ps_nopfn(stru
 
 refault:
 	put_spu_context(ctx);
-	return NOPFN_REFAULT;
+	return VM_FAULT_NOPAGE;
 }
 
 #if SPUFS_MMAP_4K
-static unsigned long spufs_cntl_mmap_nopfn(struct vm_area_struct *vma,
-					   unsigned long address)
+static int spufs_cntl_mmap_fault(struct vm_area_struct *vma,
+					   struct vm_fault *vmf)
 {
-	return spufs_ps_nopfn(vma, address, 0x4000, 0x1000);
+	return spufs_ps_fault(vma, vmf, 0x4000, 0x1000);
 }
 
 static struct vm_operations_struct spufs_cntl_mmap_vmops = {
-	.nopfn = spufs_cntl_mmap_nopfn,
+	.fault = spufs_cntl_mmap_fault,
 };
 
 /*
@@ -1096,23 +1098,23 @@ static ssize_t spufs_signal1_write(struc
 	return 4;
 }
 
-static unsigned long spufs_signal1_mmap_nopfn(struct vm_area_struct *vma,
-					      unsigned long address)
+static int
+spufs_signal1_mmap_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 {
 #if PAGE_SIZE == 0x1000
-	return spufs_ps_nopfn(vma, address, 0x14000, 0x1000);
+	return spufs_ps_fault(vma, vmf, 0x14000, 0x1000);
 #elif PAGE_SIZE == 0x10000
 	/* For 64k pages, both signal1 and signal2 can be used to mmap the whole
 	 * signal 1 and 2 area
 	 */
-	return spufs_ps_nopfn(vma, address, 0x10000, 0x10000);
+	return spufs_ps_fault(vma, vmf, 0x10000, 0x10000);
 #else
 #error unsupported page size
 #endif
 }
 
 static struct vm_operations_struct spufs_signal1_mmap_vmops = {
-	.nopfn = spufs_signal1_mmap_nopfn,
+	.fault = spufs_signal1_mmap_fault,
 };
 
 static int spufs_signal1_mmap(struct file *file, struct vm_area_struct *vma)
@@ -1233,23 +1235,23 @@ static ssize_t spufs_signal2_write(struc
 }
 
 #if SPUFS_MMAP_4K
-static unsigned long spufs_signal2_mmap_nopfn(struct vm_area_struct *vma,
-					      unsigned long address)
+static int
+spufs_signal2_mmap_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 {
 #if PAGE_SIZE == 0x1000
-	return spufs_ps_nopfn(vma, address, 0x1c000, 0x1000);
+	return spufs_ps_fault(vma, vmf, 0x1c000, 0x1000);
 #elif PAGE_SIZE == 0x10000
 	/* For 64k pages, both signal1 and signal2 can be used to mmap the whole
 	 * signal 1 and 2 area
 	 */
-	return spufs_ps_nopfn(vma, address, 0x10000, 0x10000);
+	return spufs_ps_fault(vma, vmf, 0x10000, 0x10000);
 #else
 #error unsupported page size
 #endif
 }
 
 static struct vm_operations_struct spufs_signal2_mmap_vmops = {
-	.nopfn = spufs_signal2_mmap_nopfn,
+	.fault = spufs_signal2_mmap_fault,
 };
 
 static int spufs_signal2_mmap(struct file *file, struct vm_area_struct *vma)
@@ -1361,14 +1363,14 @@ DEFINE_SPUFS_ATTRIBUTE(spufs_signal2_typ
 		       spufs_signal2_type_set, "%llu\n", SPU_ATTR_ACQUIRE);
 
 #if SPUFS_MMAP_4K
-static unsigned long spufs_mss_mmap_nopfn(struct vm_area_struct *vma,
-					  unsigned long address)
+static int
+spufs_mss_mmap_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 {
-	return spufs_ps_nopfn(vma, address, 0x0000, 0x1000);
+	return spufs_ps_fault(vma, vmf, 0x0000, 0x1000);
 }
 
 static struct vm_operations_struct spufs_mss_mmap_vmops = {
-	.nopfn = spufs_mss_mmap_nopfn,
+	.fault = spufs_mss_mmap_fault,
 };
 
 /*
@@ -1423,14 +1425,14 @@ static const struct file_operations spuf
 	.mmap	 = spufs_mss_mmap,
 };
 
-static unsigned long spufs_psmap_mmap_nopfn(struct vm_area_struct *vma,
-					    unsigned long address)
+static int
+spufs_psmap_mmap_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 {
-	return spufs_ps_nopfn(vma, address, 0x0000, 0x20000);
+	return spufs_ps_fault(vma, vmf, 0x0000, 0x20000);
 }
 
 static struct vm_operations_struct spufs_psmap_mmap_vmops = {
-	.nopfn = spufs_psmap_mmap_nopfn,
+	.fault = spufs_psmap_mmap_fault,
 };
 
 /*
@@ -1483,14 +1485,14 @@ static const struct file_operations spuf
 
 
 #if SPUFS_MMAP_4K
-static unsigned long spufs_mfc_mmap_nopfn(struct vm_area_struct *vma,
-					  unsigned long address)
+static int
+spufs_mfc_mmap_fault(struct vm_area_struct *vma, struct vm_fault *vmf)
 {
-	return spufs_ps_nopfn(vma, address, 0x3000, 0x1000);
+	return spufs_ps_fault(vma, vmf, 0x3000, 0x1000);
 }
 
 static struct vm_operations_struct spufs_mfc_mmap_vmops = {
-	.nopfn = spufs_mfc_mmap_nopfn,
+	.fault = spufs_mfc_mmap_fault,
 };
 
 /*
Index: linux-2.6/arch/powerpc/platforms/cell/spufs/sputrace.c
===================================================================
--- linux-2.6.orig/arch/powerpc/platforms/cell/spufs/sputrace.c
+++ linux-2.6/arch/powerpc/platforms/cell/spufs/sputrace.c
@@ -182,10 +182,10 @@ struct spu_probe spu_probes[] = {
 	{ "spu_yield__enter", "ctx %p", spu_context_nospu_event },
 	{ "spu_deactivate__enter", "ctx %p", spu_context_nospu_event },
 	{ "__spu_deactivate__unload", "ctx %p spu %p", spu_context_event },
-	{ "spufs_ps_nopfn__enter", "ctx %p", spu_context_nospu_event },
-	{ "spufs_ps_nopfn__sleep", "ctx %p", spu_context_nospu_event },
-	{ "spufs_ps_nopfn__wake", "ctx %p spu %p", spu_context_event },
-	{ "spufs_ps_nopfn__insert", "ctx %p spu %p", spu_context_event },
+	{ "spufs_ps_fault__enter", "ctx %p", spu_context_nospu_event },
+	{ "spufs_ps_fault__sleep", "ctx %p", spu_context_nospu_event },
+	{ "spufs_ps_fault__wake", "ctx %p spu %p", spu_context_event },
+	{ "spufs_ps_fault__insert", "ctx %p spu %p", spu_context_event },
 	{ "spu_acquire_saved__enter", "ctx %p", spu_context_nospu_event },
 	{ "destroy_spu_context__enter", "ctx %p", spu_context_nospu_event },
 	{ "spufs_stop_callback__enter", "ctx %p spu %p", spu_context_event },

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
