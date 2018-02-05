Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id A48FA6B02A7
	for <linux-mm@kvack.org>; Sun,  4 Feb 2018 20:29:42 -0500 (EST)
Received: by mail-pl0-f71.google.com with SMTP id w16so10037407plp.20
        for <linux-mm@kvack.org>; Sun, 04 Feb 2018 17:29:42 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id h3si1063481pgr.575.2018.02.04.17.28.06
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 04 Feb 2018 17:28:07 -0800 (PST)
From: Davidlohr Bueso <dbueso@suse.de>
Subject: [PATCH 62/64] drivers: use mm locking wrappers (the rest)
Date: Mon,  5 Feb 2018 02:27:52 +0100
Message-Id: <20180205012754.23615-63-dbueso@wotan.suse.de>
In-Reply-To: <20180205012754.23615-1-dbueso@wotan.suse.de>
References: <20180205012754.23615-1-dbueso@wotan.suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, mingo@kernel.org
Cc: peterz@infradead.org, ldufour@linux.vnet.ibm.com, jack@suse.cz, mhocko@kernel.org, kirill.shutemov@linux.intel.com, mawilcox@microsoft.com, mgorman@techsingularity.net, dave@stgolabs.net, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Davidlohr Bueso <dbueso@suse.de>

From: Davidlohr Bueso <dave@stgolabs.net>

This converts the rest of the drivers' mmap_sem usage to
mm locking wrappers. This becomes quite straightforward
with the mmrange in place.

Signed-off-by: Davidlohr Bueso <dbueso@suse.de>
---
 drivers/media/v4l2-core/videobuf-core.c            |  5 ++-
 drivers/media/v4l2-core/videobuf-dma-contig.c      |  5 ++-
 drivers/media/v4l2-core/videobuf-dma-sg.c          |  4 +-
 drivers/misc/cxl/cxllib.c                          |  5 ++-
 drivers/misc/cxl/fault.c                           |  5 ++-
 drivers/misc/mic/scif/scif_rma.c                   | 14 +++---
 drivers/misc/sgi-gru/grufault.c                    | 52 +++++++++++++---------
 drivers/misc/sgi-gru/grufile.c                     |  5 ++-
 drivers/oprofile/buffer_sync.c                     | 12 ++---
 .../media/atomisp/pci/atomisp2/hmm/hmm_bo.c        |  5 ++-
 drivers/tee/optee/call.c                           |  5 ++-
 drivers/vfio/vfio_iommu_spapr_tce.c                |  8 ++--
 drivers/vfio/vfio_iommu_type1.c                    | 15 ++++---
 13 files changed, 80 insertions(+), 60 deletions(-)

diff --git a/drivers/media/v4l2-core/videobuf-core.c b/drivers/media/v4l2-core/videobuf-core.c
index 9a89d3ae170f..2081606e179e 100644
--- a/drivers/media/v4l2-core/videobuf-core.c
+++ b/drivers/media/v4l2-core/videobuf-core.c
@@ -533,11 +533,12 @@ int videobuf_qbuf(struct videobuf_queue *q, struct v4l2_buffer *b)
 	enum v4l2_field field;
 	unsigned long flags = 0;
 	int retval;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	MAGIC_CHECK(q->int_ops->magic, MAGIC_QTYPE_OPS);
 
 	if (b->memory == V4L2_MEMORY_MMAP)
-		down_read(&current->mm->mmap_sem);
+		mm_read_lock(current->mm, &mmrange);
 
 	videobuf_queue_lock(q);
 	retval = -EBUSY;
@@ -624,7 +625,7 @@ int videobuf_qbuf(struct videobuf_queue *q, struct v4l2_buffer *b)
 	videobuf_queue_unlock(q);
 
 	if (b->memory == V4L2_MEMORY_MMAP)
-		up_read(&current->mm->mmap_sem);
+		mm_read_unlock(current->mm, &mmrange);
 
 	return retval;
 }
diff --git a/drivers/media/v4l2-core/videobuf-dma-contig.c b/drivers/media/v4l2-core/videobuf-dma-contig.c
index e02353e340dd..8b1f58807c0d 100644
--- a/drivers/media/v4l2-core/videobuf-dma-contig.c
+++ b/drivers/media/v4l2-core/videobuf-dma-contig.c
@@ -166,12 +166,13 @@ static int videobuf_dma_contig_user_get(struct videobuf_dma_contig_memory *mem,
 	unsigned long pages_done, user_address;
 	unsigned int offset;
 	int ret;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	offset = vb->baddr & ~PAGE_MASK;
 	mem->size = PAGE_ALIGN(vb->size + offset);
 	ret = -EINVAL;
 
-	down_read(&mm->mmap_sem);
+	mm_read_lock(mm, &mmrange);
 
 	vma = find_vma(mm, vb->baddr);
 	if (!vma)
@@ -203,7 +204,7 @@ static int videobuf_dma_contig_user_get(struct videobuf_dma_contig_memory *mem,
 	}
 
 out_up:
-	up_read(&current->mm->mmap_sem);
+	mm_read_unlock(current->mm, &mmrange);
 
 	return ret;
 }
diff --git a/drivers/media/v4l2-core/videobuf-dma-sg.c b/drivers/media/v4l2-core/videobuf-dma-sg.c
index 64a4cd62eeb3..e7ff32aca981 100644
--- a/drivers/media/v4l2-core/videobuf-dma-sg.c
+++ b/drivers/media/v4l2-core/videobuf-dma-sg.c
@@ -204,9 +204,9 @@ static int videobuf_dma_init_user(struct videobuf_dmabuf *dma, int direction,
 	int ret;
 	DEFINE_RANGE_LOCK_FULL(mmrange);
 
-	down_read(&current->mm->mmap_sem);
+	mm_read_lock(current->mm, &mmrange);
 	ret = videobuf_dma_init_user_locked(dma, direction, data, size, &mmrange);
-	up_read(&current->mm->mmap_sem);
+	mm_read_unlock(current->mm, &mmrange);
 
 	return ret;
 }
diff --git a/drivers/misc/cxl/cxllib.c b/drivers/misc/cxl/cxllib.c
index 30ccba436b3b..bf147735945c 100644
--- a/drivers/misc/cxl/cxllib.c
+++ b/drivers/misc/cxl/cxllib.c
@@ -214,11 +214,12 @@ int cxllib_handle_fault(struct mm_struct *mm, u64 addr, u64 size, u64 flags)
 	u64 dar;
 	struct vm_area_struct *vma = NULL;
 	unsigned long page_size;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	if (mm == NULL)
 		return -EFAULT;
 
-	down_read(&mm->mmap_sem);
+	mm_read_lock(mm, &mmrange);
 
 	vma = find_vma(mm, addr);
 	if (!vma) {
@@ -250,7 +251,7 @@ int cxllib_handle_fault(struct mm_struct *mm, u64 addr, u64 size, u64 flags)
 	}
 	rc = 0;
 out:
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm, &mmrange);
 	return rc;
 }
 EXPORT_SYMBOL_GPL(cxllib_handle_fault);
diff --git a/drivers/misc/cxl/fault.c b/drivers/misc/cxl/fault.c
index 70dbb6de102c..f95169703f71 100644
--- a/drivers/misc/cxl/fault.c
+++ b/drivers/misc/cxl/fault.c
@@ -317,6 +317,7 @@ static void cxl_prefault_vma(struct cxl_context *ctx)
 	struct vm_area_struct *vma;
 	int rc;
 	struct mm_struct *mm;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	mm = get_mem_context(ctx);
 	if (mm == NULL) {
@@ -325,7 +326,7 @@ static void cxl_prefault_vma(struct cxl_context *ctx)
 		return;
 	}
 
-	down_read(&mm->mmap_sem);
+	mm_read_lock(mm, &mmrange);
 	for (vma = mm->mmap; vma; vma = vma->vm_next) {
 		for (ea = vma->vm_start; ea < vma->vm_end;
 				ea = next_segment(ea, slb.vsid)) {
@@ -340,7 +341,7 @@ static void cxl_prefault_vma(struct cxl_context *ctx)
 			last_esid = slb.esid;
 		}
 	}
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm, &mmrange);
 
 	mmput(mm);
 }
diff --git a/drivers/misc/mic/scif/scif_rma.c b/drivers/misc/mic/scif/scif_rma.c
index 6ecac843e5f3..4bbdf875b5da 100644
--- a/drivers/misc/mic/scif/scif_rma.c
+++ b/drivers/misc/mic/scif/scif_rma.c
@@ -274,19 +274,21 @@ static inline int
 __scif_dec_pinned_vm_lock(struct mm_struct *mm,
 			  int nr_pages, bool try_lock)
 {
+	DEFINE_RANGE_LOCK_FULL(mmrange);
+
 	if (!mm || !nr_pages || !scif_ulimit_check)
 		return 0;
 	if (try_lock) {
-		if (!down_write_trylock(&mm->mmap_sem)) {
+		if (!mm_write_trylock(mm, &mmrange)) {
 			dev_err(scif_info.mdev.this_device,
 				"%s %d err\n", __func__, __LINE__);
 			return -1;
 		}
 	} else {
-		down_write(&mm->mmap_sem);
+		mm_write_lock(mm, &mmrange);
 	}
 	mm->pinned_vm -= nr_pages;
-	up_write(&mm->mmap_sem);
+	mm_write_unlock(mm, &mmrange);
 	return 0;
 }
 
@@ -1386,11 +1388,11 @@ int __scif_pin_pages(void *addr, size_t len, int *out_prot,
 		prot |= SCIF_PROT_WRITE;
 retry:
 		mm = current->mm;
-		down_write(&mm->mmap_sem);
+		mm_write_lock(mm, &mmrange);
 		if (ulimit) {
 			err = __scif_check_inc_pinned_vm(mm, nr_pages);
 			if (err) {
-				up_write(&mm->mmap_sem);
+				mm_write_unlock(mm, &mmrange);
 				pinned_pages->nr_pages = 0;
 				goto error_unmap;
 			}
@@ -1402,7 +1404,7 @@ int __scif_pin_pages(void *addr, size_t len, int *out_prot,
 				(prot & SCIF_PROT_WRITE) ? FOLL_WRITE : 0,
 				pinned_pages->pages,
 				NULL, &mmrange);
-		up_write(&mm->mmap_sem);
+		mm_write_unlock(mm, &mmrange);
 		if (nr_pages != pinned_pages->nr_pages) {
 			if (try_upgrade) {
 				if (ulimit)
diff --git a/drivers/misc/sgi-gru/grufault.c b/drivers/misc/sgi-gru/grufault.c
index b35d60bb2197..bac8bb94ba65 100644
--- a/drivers/misc/sgi-gru/grufault.c
+++ b/drivers/misc/sgi-gru/grufault.c
@@ -76,20 +76,21 @@ struct vm_area_struct *gru_find_vma(unsigned long vaddr)
  *	- NULL if vaddr invalid OR is not a valid GSEG vaddr.
  */
 
-static struct gru_thread_state *gru_find_lock_gts(unsigned long vaddr)
+static struct gru_thread_state *gru_find_lock_gts(unsigned long vaddr,
+						  struct range_lock *mmrange)
 {
 	struct mm_struct *mm = current->mm;
 	struct vm_area_struct *vma;
 	struct gru_thread_state *gts = NULL;
 
-	down_read(&mm->mmap_sem);
+	mm_read_lock(mm, mmrange);
 	vma = gru_find_vma(vaddr);
 	if (vma)
 		gts = gru_find_thread_state(vma, TSID(vaddr, vma));
 	if (gts)
 		mutex_lock(&gts->ts_ctxlock);
 	else
-		up_read(&mm->mmap_sem);
+		mm_read_unlock(mm, mmrange);
 	return gts;
 }
 
@@ -98,8 +99,9 @@ static struct gru_thread_state *gru_alloc_locked_gts(unsigned long vaddr)
 	struct mm_struct *mm = current->mm;
 	struct vm_area_struct *vma;
 	struct gru_thread_state *gts = ERR_PTR(-EINVAL);
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
-	down_write(&mm->mmap_sem);
+	mm_write_lock(mm, &mmrange);
 	vma = gru_find_vma(vaddr);
 	if (!vma)
 		goto err;
@@ -108,21 +110,22 @@ static struct gru_thread_state *gru_alloc_locked_gts(unsigned long vaddr)
 	if (IS_ERR(gts))
 		goto err;
 	mutex_lock(&gts->ts_ctxlock);
-	downgrade_write(&mm->mmap_sem);
+	mm_downgrade_write(mm, &mmrange);
 	return gts;
 
 err:
-	up_write(&mm->mmap_sem);
+	mm_write_unlock(mm, &mmrange);
 	return gts;
 }
 
 /*
  * Unlock a GTS that was previously locked with gru_find_lock_gts().
  */
-static void gru_unlock_gts(struct gru_thread_state *gts)
+static void gru_unlock_gts(struct gru_thread_state *gts,
+			   struct range_lock *mmrange)
 {
 	mutex_unlock(&gts->ts_ctxlock);
-	up_read(&current->mm->mmap_sem);
+	mm_read_unlock(current->mm, mmrange);
 }
 
 /*
@@ -597,9 +600,9 @@ static irqreturn_t gru_intr(int chiplet, int blade)
 		if (!gts->ts_force_cch_reload) {
 			DEFINE_RANGE_LOCK_FULL(mmrange);
 
-			if (down_read_trylock(&gts->ts_mm->mmap_sem)) {
+			if (mm_read_trylock(gts->ts_mm, &mmrange)) {
 				gru_try_dropin(gru, gts, tfh, NULL, &mmrange);
-				up_read(&gts->ts_mm->mmap_sem);
+				mm_read_unlock(gts->ts_mm, &mmrange);
 			}
 		} else {
 			tfh_user_polling_mode(tfh);
@@ -672,7 +675,7 @@ int gru_handle_user_call_os(unsigned long cb)
 	if ((cb & (GRU_HANDLE_STRIDE - 1)) || ucbnum >= GRU_NUM_CB)
 		return -EINVAL;
 
-	gts = gru_find_lock_gts(cb);
+	gts = gru_find_lock_gts(cb, &mmrange);
 	if (!gts)
 		return -EINVAL;
 	gru_dbg(grudev, "address 0x%lx, gid %d, gts 0x%p\n", cb, gts->ts_gru ? gts->ts_gru->gs_gid : -1, gts);
@@ -699,7 +702,7 @@ int gru_handle_user_call_os(unsigned long cb)
 		ret = gru_user_dropin(gts, tfh, cbk, &mmrange);
 	}
 exit:
-	gru_unlock_gts(gts);
+	gru_unlock_gts(gts, &mmrange);
 	return ret;
 }
 
@@ -713,12 +716,13 @@ int gru_get_exception_detail(unsigned long arg)
 	struct gru_control_block_extended *cbe;
 	struct gru_thread_state *gts;
 	int ucbnum, cbrnum, ret;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	STAT(user_exception);
 	if (copy_from_user(&excdet, (void __user *)arg, sizeof(excdet)))
 		return -EFAULT;
 
-	gts = gru_find_lock_gts(excdet.cb);
+	gts = gru_find_lock_gts(excdet.cb, &mmrange);
 	if (!gts)
 		return -EINVAL;
 
@@ -743,7 +747,7 @@ int gru_get_exception_detail(unsigned long arg)
 	} else {
 		ret = -EAGAIN;
 	}
-	gru_unlock_gts(gts);
+	gru_unlock_gts(gts, &mmrange);
 
 	gru_dbg(grudev,
 		"cb 0x%lx, op %d, exopc %d, cbrstate %d, cbrexecstatus 0x%x, ecause 0x%x, "
@@ -787,6 +791,7 @@ int gru_user_unload_context(unsigned long arg)
 {
 	struct gru_thread_state *gts;
 	struct gru_unload_context_req req;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	STAT(user_unload_context);
 	if (copy_from_user(&req, (void __user *)arg, sizeof(req)))
@@ -797,13 +802,13 @@ int gru_user_unload_context(unsigned long arg)
 	if (!req.gseg)
 		return gru_unload_all_contexts();
 
-	gts = gru_find_lock_gts(req.gseg);
+	gts = gru_find_lock_gts(req.gseg, &mmrange);
 	if (!gts)
 		return -EINVAL;
 
 	if (gts->ts_gru)
 		gru_unload_context(gts, 1);
-	gru_unlock_gts(gts);
+	gru_unlock_gts(gts, &mmrange);
 
 	return 0;
 }
@@ -817,6 +822,7 @@ int gru_user_flush_tlb(unsigned long arg)
 	struct gru_thread_state *gts;
 	struct gru_flush_tlb_req req;
 	struct gru_mm_struct *gms;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	STAT(user_flush_tlb);
 	if (copy_from_user(&req, (void __user *)arg, sizeof(req)))
@@ -825,12 +831,12 @@ int gru_user_flush_tlb(unsigned long arg)
 	gru_dbg(grudev, "gseg 0x%lx, vaddr 0x%lx, len 0x%lx\n", req.gseg,
 		req.vaddr, req.len);
 
-	gts = gru_find_lock_gts(req.gseg);
+	gts = gru_find_lock_gts(req.gseg, &mmrange);
 	if (!gts)
 		return -EINVAL;
 
 	gms = gts->ts_gms;
-	gru_unlock_gts(gts);
+	gru_unlock_gts(gts, &mmrange);
 	gru_flush_tlb_range(gms, req.vaddr, req.len);
 
 	return 0;
@@ -843,6 +849,7 @@ long gru_get_gseg_statistics(unsigned long arg)
 {
 	struct gru_thread_state *gts;
 	struct gru_get_gseg_statistics_req req;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	if (copy_from_user(&req, (void __user *)arg, sizeof(req)))
 		return -EFAULT;
@@ -852,10 +859,10 @@ long gru_get_gseg_statistics(unsigned long arg)
 	 * If no gts exists in the array, the context has never been used & all
 	 * statistics are implicitly 0.
 	 */
-	gts = gru_find_lock_gts(req.gseg);
+	gts = gru_find_lock_gts(req.gseg, &mmrange);
 	if (gts) {
 		memcpy(&req.stats, &gts->ustats, sizeof(gts->ustats));
-		gru_unlock_gts(gts);
+		gru_unlock_gts(gts, &mmrange);
 	} else {
 		memset(&req.stats, 0, sizeof(gts->ustats));
 	}
@@ -875,13 +882,14 @@ int gru_set_context_option(unsigned long arg)
 	struct gru_thread_state *gts;
 	struct gru_set_context_option_req req;
 	int ret = 0;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	STAT(set_context_option);
 	if (copy_from_user(&req, (void __user *)arg, sizeof(req)))
 		return -EFAULT;
 	gru_dbg(grudev, "op %d, gseg 0x%lx, value1 0x%lx\n", req.op, req.gseg, req.val1);
 
-	gts = gru_find_lock_gts(req.gseg);
+	gts = gru_find_lock_gts(req.gseg, &mmrange);
 	if (!gts) {
 		gts = gru_alloc_locked_gts(req.gseg);
 		if (IS_ERR(gts))
@@ -912,7 +920,7 @@ int gru_set_context_option(unsigned long arg)
 	default:
 		ret = -EINVAL;
 	}
-	gru_unlock_gts(gts);
+	gru_unlock_gts(gts, &mmrange);
 
 	return ret;
 }
diff --git a/drivers/misc/sgi-gru/grufile.c b/drivers/misc/sgi-gru/grufile.c
index 104a05f6b738..1403a4f73cbd 100644
--- a/drivers/misc/sgi-gru/grufile.c
+++ b/drivers/misc/sgi-gru/grufile.c
@@ -136,6 +136,7 @@ static int gru_create_new_context(unsigned long arg)
 	struct vm_area_struct *vma;
 	struct gru_vma_data *vdata;
 	int ret = -EINVAL;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	if (copy_from_user(&req, (void __user *)arg, sizeof(req)))
 		return -EFAULT;
@@ -148,7 +149,7 @@ static int gru_create_new_context(unsigned long arg)
 	if (!(req.options & GRU_OPT_MISS_MASK))
 		req.options |= GRU_OPT_MISS_FMM_INTR;
 
-	down_write(&current->mm->mmap_sem);
+	mm_write_lock(current->mm, &mmrange);
 	vma = gru_find_vma(req.gseg);
 	if (vma) {
 		vdata = vma->vm_private_data;
@@ -159,7 +160,7 @@ static int gru_create_new_context(unsigned long arg)
 		vdata->vd_tlb_preload_count = req.tlb_preload_count;
 		ret = 0;
 	}
-	up_write(&current->mm->mmap_sem);
+	mm_write_unlock(current->mm, &mmrange);
 
 	return ret;
 }
diff --git a/drivers/oprofile/buffer_sync.c b/drivers/oprofile/buffer_sync.c
index ac27f3d3fbb4..33a36b97f8a5 100644
--- a/drivers/oprofile/buffer_sync.c
+++ b/drivers/oprofile/buffer_sync.c
@@ -90,12 +90,13 @@ munmap_notify(struct notifier_block *self, unsigned long val, void *data)
 	unsigned long addr = (unsigned long)data;
 	struct mm_struct *mm = current->mm;
 	struct vm_area_struct *mpnt;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
-	down_read(&mm->mmap_sem);
+	mm_read_lock(mm, &mmrange);
 
 	mpnt = find_vma(mm, addr);
 	if (mpnt && mpnt->vm_file && (mpnt->vm_flags & VM_EXEC)) {
-		up_read(&mm->mmap_sem);
+		mm_read_unlock(mm, &mmrange);
 		/* To avoid latency problems, we only process the current CPU,
 		 * hoping that most samples for the task are on this CPU
 		 */
@@ -103,7 +104,7 @@ munmap_notify(struct notifier_block *self, unsigned long val, void *data)
 		return 0;
 	}
 
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm, &mmrange);
 	return 0;
 }
 
@@ -255,8 +256,9 @@ lookup_dcookie(struct mm_struct *mm, unsigned long addr, off_t *offset)
 {
 	unsigned long cookie = NO_COOKIE;
 	struct vm_area_struct *vma;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
-	down_read(&mm->mmap_sem);
+	mm_read_lock(mm, &mmrange);
 	for (vma = find_vma(mm, addr); vma; vma = vma->vm_next) {
 
 		if (addr < vma->vm_start || addr >= vma->vm_end)
@@ -276,7 +278,7 @@ lookup_dcookie(struct mm_struct *mm, unsigned long addr, off_t *offset)
 
 	if (!vma)
 		cookie = INVALID_COOKIE;
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm, &mmrange);
 
 	return cookie;
 }
diff --git a/drivers/staging/media/atomisp/pci/atomisp2/hmm/hmm_bo.c b/drivers/staging/media/atomisp/pci/atomisp2/hmm/hmm_bo.c
index 79bd540d7882..f38303ea8470 100644
--- a/drivers/staging/media/atomisp/pci/atomisp2/hmm/hmm_bo.c
+++ b/drivers/staging/media/atomisp/pci/atomisp2/hmm/hmm_bo.c
@@ -983,6 +983,7 @@ static int alloc_user_pages(struct hmm_buffer_object *bo,
 	int i;
 	struct vm_area_struct *vma;
 	struct page **pages;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	pages = kmalloc_array(bo->pgnr, sizeof(struct page *), GFP_KERNEL);
 	if (unlikely(!pages))
@@ -996,9 +997,9 @@ static int alloc_user_pages(struct hmm_buffer_object *bo,
 	}
 
 	mutex_unlock(&bo->mutex);
-	down_read(&current->mm->mmap_sem);
+	mm_read_lock(current->mm, &mmrange);
 	vma = find_vma(current->mm, (unsigned long)userptr);
-	up_read(&current->mm->mmap_sem);
+	mm_read_unlock(current->mm, &mmrange);
 	if (vma == NULL) {
 		dev_err(atomisp_dev, "find_vma failed\n");
 		kfree(bo->page_obj);
diff --git a/drivers/tee/optee/call.c b/drivers/tee/optee/call.c
index a5afbe6dee68..488a08e17a93 100644
--- a/drivers/tee/optee/call.c
+++ b/drivers/tee/optee/call.c
@@ -561,11 +561,12 @@ static int check_mem_type(unsigned long start, size_t num_pages)
 {
 	struct mm_struct *mm = current->mm;
 	int rc;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
-	down_read(&mm->mmap_sem);
+	mm_read_lock(mm, &mmrange);
 	rc = __check_mem_type(find_vma(mm, start),
 			      start + num_pages * PAGE_SIZE);
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm, &mmrange);
 
 	return rc;
 }
diff --git a/drivers/vfio/vfio_iommu_spapr_tce.c b/drivers/vfio/vfio_iommu_spapr_tce.c
index 759a5bdd40e1..114da7865bd2 100644
--- a/drivers/vfio/vfio_iommu_spapr_tce.c
+++ b/drivers/vfio/vfio_iommu_spapr_tce.c
@@ -44,7 +44,7 @@ static long try_increment_locked_vm(struct mm_struct *mm, long npages)
 	if (!npages)
 		return 0;
 
-	down_write(&mm->mmap_sem);
+	mm_write_lock(mm, &mmrange);
 	locked = mm->locked_vm + npages;
 	lock_limit = rlimit(RLIMIT_MEMLOCK) >> PAGE_SHIFT;
 	if (locked > lock_limit && !capable(CAP_IPC_LOCK))
@@ -58,7 +58,7 @@ static long try_increment_locked_vm(struct mm_struct *mm, long npages)
 			rlimit(RLIMIT_MEMLOCK),
 			ret ? " - exceeded" : "");
 
-	up_write(&mm->mmap_sem);
+	mm_write_unlock(mm, &mmrange);
 
 	return ret;
 }
@@ -68,7 +68,7 @@ static void decrement_locked_vm(struct mm_struct *mm, long npages)
 	if (!mm || !npages)
 		return;
 
-	down_write(&mm->mmap_sem);
+	mm_write_lock(mm, &mmrange);
 	if (WARN_ON_ONCE(npages > mm->locked_vm))
 		npages = mm->locked_vm;
 	mm->locked_vm -= npages;
@@ -76,7 +76,7 @@ static void decrement_locked_vm(struct mm_struct *mm, long npages)
 			npages << PAGE_SHIFT,
 			mm->locked_vm << PAGE_SHIFT,
 			rlimit(RLIMIT_MEMLOCK));
-	up_write(&mm->mmap_sem);
+	mm_write_unlock(mm, &mmrange);
 }
 
 /*
diff --git a/drivers/vfio/vfio_iommu_type1.c b/drivers/vfio/vfio_iommu_type1.c
index 1b3b103da637..80a6ec8722fb 100644
--- a/drivers/vfio/vfio_iommu_type1.c
+++ b/drivers/vfio/vfio_iommu_type1.c
@@ -251,6 +251,7 @@ static int vfio_lock_acct(struct task_struct *task, long npage, bool *lock_cap)
 	struct mm_struct *mm;
 	bool is_current;
 	int ret;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	if (!npage)
 		return 0;
@@ -261,7 +262,7 @@ static int vfio_lock_acct(struct task_struct *task, long npage, bool *lock_cap)
 	if (!mm)
 		return -ESRCH; /* process exited */
 
-	ret = down_write_killable(&mm->mmap_sem);
+	ret = mm_write_lock_killable(mm, &mmrange);
 	if (!ret) {
 		if (npage > 0) {
 			if (lock_cap ? !*lock_cap :
@@ -279,7 +280,7 @@ static int vfio_lock_acct(struct task_struct *task, long npage, bool *lock_cap)
 		if (!ret)
 			mm->locked_vm += npage;
 
-		up_write(&mm->mmap_sem);
+		mm_write_unlock(mm, &mmrange);
 	}
 
 	if (!is_current)
@@ -339,21 +340,21 @@ static int vaddr_get_pfn(struct mm_struct *mm, unsigned long vaddr,
 	struct page *page[1];
 	struct vm_area_struct *vma;
 	int ret;
+	DEFINE_RANGE_LOCK_FULL(mmrange);
 
 	if (mm == current->mm) {
 		ret = get_user_pages_fast(vaddr, 1, !!(prot & IOMMU_WRITE),
 					  page);
 	} else {
 		unsigned int flags = 0;
-		DEFINE_RANGE_LOCK_FULL(mmrange);
 
 		if (prot & IOMMU_WRITE)
 			flags |= FOLL_WRITE;
 
-		down_read(&mm->mmap_sem);
+		mm_read_lock(mm, &mmrange);
 		ret = get_user_pages_remote(NULL, mm, vaddr, 1, flags, page,
 					    NULL, NULL, &mmrange);
-		up_read(&mm->mmap_sem);
+		mm_read_unlock(mm, &mmrange);
 	}
 
 	if (ret == 1) {
@@ -361,7 +362,7 @@ static int vaddr_get_pfn(struct mm_struct *mm, unsigned long vaddr,
 		return 0;
 	}
 
-	down_read(&mm->mmap_sem);
+	mm_read_lock(mm, &mmrange);
 
 	vma = find_vma_intersection(mm, vaddr, vaddr + 1);
 
@@ -371,7 +372,7 @@ static int vaddr_get_pfn(struct mm_struct *mm, unsigned long vaddr,
 			ret = 0;
 	}
 
-	up_read(&mm->mmap_sem);
+	mm_read_unlock(mm, &mmrange);
 	return ret;
 }
 
-- 
2.13.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
