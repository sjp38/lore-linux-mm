Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f199.google.com (mail-yw0-f199.google.com [209.85.161.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9774E6B029B
	for <linux-mm@kvack.org>; Mon, 31 Oct 2016 06:02:51 -0400 (EDT)
Received: by mail-yw0-f199.google.com with SMTP id r204so165061109ywb.0
        for <linux-mm@kvack.org>; Mon, 31 Oct 2016 03:02:51 -0700 (PDT)
Received: from mail-wm0-x242.google.com (mail-wm0-x242.google.com. [2a00:1450:400c:c09::242])
        by mx.google.com with ESMTPS id n5si5676399wmf.2.2016.10.31.03.02.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 31 Oct 2016 03:02:50 -0700 (PDT)
Received: by mail-wm0-x242.google.com with SMTP id 68so10904225wmz.2
        for <linux-mm@kvack.org>; Mon, 31 Oct 2016 03:02:50 -0700 (PDT)
From: Lorenzo Stoakes <lstoakes@gmail.com>
Subject: [PATCH 1/2] mm: add locked parameter to get_user_pages()
Date: Mon, 31 Oct 2016 10:02:27 +0000
Message-Id: <20161031100228.17917-2-lstoakes@gmail.com>
In-Reply-To: <20161031100228.17917-1-lstoakes@gmail.com>
References: <20161031100228.17917-1-lstoakes@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, Jan Kara <jack@suse.cz>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@linux.intel.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>, Paolo Bonzini <pbonzini@redhat.com>, linux-kernel@vger.kernel.org, linux-cris-kernel@axis.com, linux-ia64@vger.kernel.org, dri-devel@lists.freedesktop.org, linux-rdma@vger.kernel.org, kvm@vger.kernel.org, linux-media@vger.kernel.org, devel@driverdev.osuosl.org, Lorenzo Stoakes <lstoakes@gmail.com>

This patch adds an int *locked parameter to get_user_pages() to allow
VM_FAULT_RETRY faulting behaviour similar to get_user_pages_[un]locked().

It additionally clears the way for get_user_pages_locked() to be removed as its
sole remaining useful characteristic was to allow for VM_FAULT_RETRY behaviour
when faulting in pages.

It should not introduce any functional changes, however it does allow for
subsequent changes to get_user_pages() callers to take advantage of
VM_FAULT_RETRY.

Signed-off-by: Lorenzo Stoakes <lstoakes@gmail.com>
---
 arch/cris/arch-v32/drivers/cryptocop.c                            | 2 ++
 arch/ia64/kernel/err_inject.c                                     | 2 +-
 arch/x86/mm/mpx.c                                                 | 2 +-
 drivers/gpu/drm/amd/amdgpu/amdgpu_ttm.c                           | 2 +-
 drivers/gpu/drm/radeon/radeon_ttm.c                               | 2 +-
 drivers/gpu/drm/via/via_dmablit.c                                 | 2 +-
 drivers/infiniband/core/umem.c                                    | 2 +-
 drivers/infiniband/hw/mthca/mthca_memfree.c                       | 3 ++-
 drivers/infiniband/hw/qib/qib_user_pages.c                        | 2 +-
 drivers/infiniband/hw/usnic/usnic_uiom.c                          | 2 +-
 drivers/media/v4l2-core/videobuf-dma-sg.c                         | 2 +-
 drivers/misc/mic/scif/scif_rma.c                                  | 1 +
 drivers/misc/sgi-gru/grufault.c                                   | 3 ++-
 drivers/platform/goldfish/goldfish_pipe.c                         | 2 +-
 drivers/rapidio/devices/rio_mport_cdev.c                          | 2 +-
 .../staging/vc04_services/interface/vchiq_arm/vchiq_2835_arm.c    | 3 ++-
 drivers/staging/vc04_services/interface/vchiq_arm/vchiq_arm.c     | 3 ++-
 drivers/virt/fsl_hypervisor.c                                     | 2 +-
 include/linux/mm.h                                                | 2 +-
 mm/gup.c                                                          | 8 ++++----
 mm/ksm.c                                                          | 3 ++-
 mm/mempolicy.c                                                    | 2 +-
 mm/nommu.c                                                        | 4 ++--
 virt/kvm/kvm_main.c                                               | 4 ++--
 24 files changed, 35 insertions(+), 27 deletions(-)

diff --git a/arch/cris/arch-v32/drivers/cryptocop.c b/arch/cris/arch-v32/drivers/cryptocop.c
index 0068fd4..7444b45 100644
--- a/arch/cris/arch-v32/drivers/cryptocop.c
+++ b/arch/cris/arch-v32/drivers/cryptocop.c
@@ -2723,6 +2723,7 @@ static int cryptocop_ioctl_process(struct inode *inode, struct file *filp, unsig
 			     noinpages,
 			     0,  /* read access only for in data */
 			     inpages,
+			     NULL,
 			     NULL);
 
 	if (err < 0) {
@@ -2737,6 +2738,7 @@ static int cryptocop_ioctl_process(struct inode *inode, struct file *filp, unsig
 				     nooutpages,
 				     FOLL_WRITE, /* write access for out data */
 				     outpages,
+				     NULL,
 				     NULL);
 		up_read(&current->mm->mmap_sem);
 		if (err < 0) {
diff --git a/arch/ia64/kernel/err_inject.c b/arch/ia64/kernel/err_inject.c
index 5ed0ea9..99f3fa2 100644
--- a/arch/ia64/kernel/err_inject.c
+++ b/arch/ia64/kernel/err_inject.c
@@ -142,7 +142,7 @@ store_virtual_to_phys(struct device *dev, struct device_attribute *attr,
 	u64 virt_addr=simple_strtoull(buf, NULL, 16);
 	int ret;
 
-	ret = get_user_pages(virt_addr, 1, FOLL_WRITE, NULL, NULL);
+	ret = get_user_pages(virt_addr, 1, FOLL_WRITE, NULL, NULL, NULL);
 	if (ret<=0) {
 #ifdef ERR_INJ_DEBUG
 		printk("Virtual address %lx is not existing.\n",virt_addr);
diff --git a/arch/x86/mm/mpx.c b/arch/x86/mm/mpx.c
index e4f8009..b74a7b2 100644
--- a/arch/x86/mm/mpx.c
+++ b/arch/x86/mm/mpx.c
@@ -546,7 +546,7 @@ static int mpx_resolve_fault(long __user *addr, int write)
 	int nr_pages = 1;
 
 	gup_ret = get_user_pages((unsigned long)addr, nr_pages,
-			write ? FOLL_WRITE : 0,	NULL, NULL);
+			write ? FOLL_WRITE : 0,	NULL, NULL, NULL);
 	/*
 	 * get_user_pages() returns number of pages gotten.
 	 * 0 means we failed to fault in and get anything,
diff --git a/drivers/gpu/drm/amd/amdgpu/amdgpu_ttm.c b/drivers/gpu/drm/amd/amdgpu/amdgpu_ttm.c
index dcaf691..3d9a195 100644
--- a/drivers/gpu/drm/amd/amdgpu/amdgpu_ttm.c
+++ b/drivers/gpu/drm/amd/amdgpu/amdgpu_ttm.c
@@ -584,7 +584,7 @@ int amdgpu_ttm_tt_get_user_pages(struct ttm_tt *ttm, struct page **pages)
 		list_add(&guptask.list, &gtt->guptasks);
 		spin_unlock(&gtt->guptasklock);
 
-		r = get_user_pages(userptr, num_pages, flags, p, NULL);
+		r = get_user_pages(userptr, num_pages, flags, p, NULL, NULL);
 
 		spin_lock(&gtt->guptasklock);
 		list_del(&guptask.list);
diff --git a/drivers/gpu/drm/radeon/radeon_ttm.c b/drivers/gpu/drm/radeon/radeon_ttm.c
index 3de5e6e..8b0c069 100644
--- a/drivers/gpu/drm/radeon/radeon_ttm.c
+++ b/drivers/gpu/drm/radeon/radeon_ttm.c
@@ -567,7 +567,7 @@ static int radeon_ttm_tt_pin_userptr(struct ttm_tt *ttm)
 		struct page **pages = ttm->pages + pinned;
 
 		r = get_user_pages(userptr, num_pages, write ? FOLL_WRITE : 0,
-				   pages, NULL);
+				   pages, NULL, NULL);
 		if (r < 0)
 			goto release_pages;
 
diff --git a/drivers/gpu/drm/via/via_dmablit.c b/drivers/gpu/drm/via/via_dmablit.c
index 1a3ad76..39877fe 100644
--- a/drivers/gpu/drm/via/via_dmablit.c
+++ b/drivers/gpu/drm/via/via_dmablit.c
@@ -242,7 +242,7 @@ via_lock_all_dma_pages(drm_via_sg_info_t *vsg,  drm_via_dmablit_t *xfer)
 	ret = get_user_pages((unsigned long)xfer->mem_addr,
 			     vsg->num_pages,
 			     (vsg->direction == DMA_FROM_DEVICE) ? FOLL_WRITE : 0,
-			     vsg->pages, NULL);
+			     vsg->pages, NULL, NULL);
 
 	up_read(&current->mm->mmap_sem);
 	if (ret != vsg->num_pages) {
diff --git a/drivers/infiniband/core/umem.c b/drivers/infiniband/core/umem.c
index 224ad27..1d5278f 100644
--- a/drivers/infiniband/core/umem.c
+++ b/drivers/infiniband/core/umem.c
@@ -194,7 +194,7 @@ struct ib_umem *ib_umem_get(struct ib_ucontext *context, unsigned long addr,
 		ret = get_user_pages(cur_base,
 				     min_t(unsigned long, npages,
 					   PAGE_SIZE / sizeof (struct page *)),
-				     gup_flags, page_list, vma_list);
+				     gup_flags, page_list, vma_list, NULL);
 
 		if (ret < 0)
 			goto out;
diff --git a/drivers/infiniband/hw/mthca/mthca_memfree.c b/drivers/infiniband/hw/mthca/mthca_memfree.c
index c6fe89d..45d037f 100644
--- a/drivers/infiniband/hw/mthca/mthca_memfree.c
+++ b/drivers/infiniband/hw/mthca/mthca_memfree.c
@@ -472,7 +472,8 @@ int mthca_map_user_db(struct mthca_dev *dev, struct mthca_uar *uar,
 		goto out;
 	}
 
-	ret = get_user_pages(uaddr & PAGE_MASK, 1, FOLL_WRITE, pages, NULL);
+	ret = get_user_pages(uaddr & PAGE_MASK, 1, FOLL_WRITE, pages, NULL,
+			NULL);
 	if (ret < 0)
 		goto out;
 
diff --git a/drivers/infiniband/hw/qib/qib_user_pages.c b/drivers/infiniband/hw/qib/qib_user_pages.c
index 75f0862..433dc3a 100644
--- a/drivers/infiniband/hw/qib/qib_user_pages.c
+++ b/drivers/infiniband/hw/qib/qib_user_pages.c
@@ -69,7 +69,7 @@ static int __qib_get_user_pages(unsigned long start_page, size_t num_pages,
 		ret = get_user_pages(start_page + got * PAGE_SIZE,
 				     num_pages - got,
 				     FOLL_WRITE | FOLL_FORCE,
-				     p + got, NULL);
+				     p + got, NULL, NULL);
 		if (ret < 0)
 			goto bail_release;
 	}
diff --git a/drivers/infiniband/hw/usnic/usnic_uiom.c b/drivers/infiniband/hw/usnic/usnic_uiom.c
index 1ccee6e..68d583f 100644
--- a/drivers/infiniband/hw/usnic/usnic_uiom.c
+++ b/drivers/infiniband/hw/usnic/usnic_uiom.c
@@ -145,7 +145,7 @@ static int usnic_uiom_get_pages(unsigned long addr, size_t size, int writable,
 		ret = get_user_pages(cur_base,
 					min_t(unsigned long, npages,
 					PAGE_SIZE / sizeof(struct page *)),
-					gup_flags, page_list, NULL);
+					gup_flags, page_list, NULL, NULL);
 
 		if (ret < 0)
 			goto out;
diff --git a/drivers/media/v4l2-core/videobuf-dma-sg.c b/drivers/media/v4l2-core/videobuf-dma-sg.c
index 1db0af6..66c24e6 100644
--- a/drivers/media/v4l2-core/videobuf-dma-sg.c
+++ b/drivers/media/v4l2-core/videobuf-dma-sg.c
@@ -186,7 +186,7 @@ static int videobuf_dma_init_user_locked(struct videobuf_dmabuf *dma,
 		data, size, dma->nr_pages);
 
 	err = get_user_pages(data & PAGE_MASK, dma->nr_pages,
-			     flags, dma->pages, NULL);
+			     flags, dma->pages, NULL, NULL);
 
 	if (err != dma->nr_pages) {
 		dma->nr_pages = (err >= 0) ? err : 0;
diff --git a/drivers/misc/mic/scif/scif_rma.c b/drivers/misc/mic/scif/scif_rma.c
index f806a44..6719896 100644
--- a/drivers/misc/mic/scif/scif_rma.c
+++ b/drivers/misc/mic/scif/scif_rma.c
@@ -1398,6 +1398,7 @@ int __scif_pin_pages(void *addr, size_t len, int *out_prot,
 				nr_pages,
 				(prot & SCIF_PROT_WRITE) ? FOLL_WRITE : 0,
 				pinned_pages->pages,
+				NULL,
 				NULL);
 		up_write(&mm->mmap_sem);
 		if (nr_pages != pinned_pages->nr_pages) {
diff --git a/drivers/misc/sgi-gru/grufault.c b/drivers/misc/sgi-gru/grufault.c
index 6fb773d..c6bda94 100644
--- a/drivers/misc/sgi-gru/grufault.c
+++ b/drivers/misc/sgi-gru/grufault.c
@@ -198,7 +198,8 @@ static int non_atomic_pte_lookup(struct vm_area_struct *vma,
 #else
 	*pageshift = PAGE_SHIFT;
 #endif
-	if (get_user_pages(vaddr, 1, write ? FOLL_WRITE : 0, &page, NULL) <= 0)
+	if (get_user_pages(vaddr, 1, write ? FOLL_WRITE : 0, &page, NULL, NULL)
+		<= 0)
 		return -EFAULT;
 	*paddr = page_to_phys(page);
 	put_page(page);
diff --git a/drivers/platform/goldfish/goldfish_pipe.c b/drivers/platform/goldfish/goldfish_pipe.c
index 1aba2c7..bb5c0fe 100644
--- a/drivers/platform/goldfish/goldfish_pipe.c
+++ b/drivers/platform/goldfish/goldfish_pipe.c
@@ -310,7 +310,7 @@ static ssize_t goldfish_pipe_read_write(struct file *filp, char __user *buffer,
 		 */
 		down_read(&current->mm->mmap_sem);
 		ret = get_user_pages(address, 1, is_write ? 0 : FOLL_WRITE,
-				&page, NULL);
+				&page, NULL, NULL);
 		up_read(&current->mm->mmap_sem);
 		if (ret < 0)
 			break;
diff --git a/drivers/rapidio/devices/rio_mport_cdev.c b/drivers/rapidio/devices/rio_mport_cdev.c
index 9013a58..0e507ca 100644
--- a/drivers/rapidio/devices/rio_mport_cdev.c
+++ b/drivers/rapidio/devices/rio_mport_cdev.c
@@ -894,7 +894,7 @@ rio_dma_transfer(struct file *filp, u32 transfer_mode,
 				(unsigned long)xfer->loc_addr & PAGE_MASK,
 				nr_pages,
 				dir == DMA_FROM_DEVICE ? FOLL_WRITE : 0,
-				page_list, NULL);
+				page_list, NULL, NULL);
 		up_read(&current->mm->mmap_sem);
 
 		if (pinned != nr_pages) {
diff --git a/drivers/staging/vc04_services/interface/vchiq_arm/vchiq_2835_arm.c b/drivers/staging/vc04_services/interface/vchiq_arm/vchiq_2835_arm.c
index 1091b9f..f3f0bab 100644
--- a/drivers/staging/vc04_services/interface/vchiq_arm/vchiq_2835_arm.c
+++ b/drivers/staging/vc04_services/interface/vchiq_arm/vchiq_2835_arm.c
@@ -425,7 +425,8 @@ create_pagelist(char __user *buf, size_t count, unsigned short type,
 					  num_pages,
 					  (type == PAGELIST_READ) ? FOLL_WRITE : 0,
 					  pages,
-					  NULL /*vmas */);
+					  NULL /*vmas */,
+					  NULL /* locked */);
 		up_read(&task->mm->mmap_sem);
 
 		if (actual_pages != num_pages) {
diff --git a/drivers/staging/vc04_services/interface/vchiq_arm/vchiq_arm.c b/drivers/staging/vc04_services/interface/vchiq_arm/vchiq_arm.c
index 7b6cd4d..86828d9 100644
--- a/drivers/staging/vc04_services/interface/vchiq_arm/vchiq_arm.c
+++ b/drivers/staging/vc04_services/interface/vchiq_arm/vchiq_arm.c
@@ -1479,7 +1479,8 @@ dump_phys_mem(void *virt_addr, uint32_t num_bytes)
 		num_pages,                /* len */
 		0,                        /* gup_flags */
 		pages,                    /* pages (array of page pointers) */
-		NULL);                    /* vmas */
+		NULL,                     /* vmas */
+		NULL);                    /* locked */
 	up_read(&current->mm->mmap_sem);
 
 	prev_idx = -1;
diff --git a/drivers/virt/fsl_hypervisor.c b/drivers/virt/fsl_hypervisor.c
index 150ce2a..896bc31 100644
--- a/drivers/virt/fsl_hypervisor.c
+++ b/drivers/virt/fsl_hypervisor.c
@@ -246,7 +246,7 @@ static long ioctl_memcpy(struct fsl_hv_ioctl_memcpy __user *p)
 	down_read(&current->mm->mmap_sem);
 	num_pinned = get_user_pages(param.local_vaddr - lb_offset,
 		num_pages, (param.source == -1) ? 0 : FOLL_WRITE,
-		pages, NULL);
+		pages, NULL, NULL);
 	up_read(&current->mm->mmap_sem);
 
 	if (num_pinned != num_pages) {
diff --git a/include/linux/mm.h b/include/linux/mm.h
index a92c8d7..396984e 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1277,7 +1277,7 @@ long get_user_pages_remote(struct task_struct *tsk, struct mm_struct *mm,
 			    struct vm_area_struct **vmas);
 long get_user_pages(unsigned long start, unsigned long nr_pages,
 			    unsigned int gup_flags, struct page **pages,
-			    struct vm_area_struct **vmas);
+			    struct vm_area_struct **vmas, int *locked);
 long get_user_pages_locked(unsigned long start, unsigned long nr_pages,
 		    unsigned int gup_flags, struct page **pages, int *locked);
 long __get_user_pages_unlocked(struct task_struct *tsk, struct mm_struct *mm,
diff --git a/mm/gup.c b/mm/gup.c
index ec4f827..6b5539e 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -834,7 +834,7 @@ static __always_inline long __get_user_pages_locked(struct task_struct *tsk,
  *
  *      down_read(&mm->mmap_sem);
  *      do_something()
- *      get_user_pages(tsk, mm, ..., pages, NULL);
+ *      get_user_pages(tsk, mm, ..., pages, NULL, NULL);
  *      up_read(&mm->mmap_sem);
  *
  *  to:
@@ -886,7 +886,7 @@ EXPORT_SYMBOL(__get_user_pages_unlocked);
  * get_user_pages_unlocked() is suitable to replace the form:
  *
  *      down_read(&mm->mmap_sem);
- *      get_user_pages(tsk, mm, ..., pages, NULL);
+ *      get_user_pages(tsk, mm, ..., pages, NULL, NULL);
  *      up_read(&mm->mmap_sem);
  *
  *  with:
@@ -979,10 +979,10 @@ EXPORT_SYMBOL(get_user_pages_remote);
  */
 long get_user_pages(unsigned long start, unsigned long nr_pages,
 		unsigned int gup_flags, struct page **pages,
-		struct vm_area_struct **vmas)
+		struct vm_area_struct **vmas, int *locked)
 {
 	return __get_user_pages_locked(current, current->mm, start, nr_pages,
-				       pages, vmas, NULL, false,
+				       pages, vmas, locked, true,
 				       gup_flags | FOLL_TOUCH);
 }
 EXPORT_SYMBOL(get_user_pages);
diff --git a/mm/ksm.c b/mm/ksm.c
index 9ae6011..b7468dd 100644
--- a/mm/ksm.c
+++ b/mm/ksm.c
@@ -358,7 +358,8 @@ static inline bool ksm_test_exit(struct mm_struct *mm)
 /*
  * We use break_ksm to break COW on a ksm page: it's a stripped down
  *
- *	if (get_user_pages(addr, 1, 1, 1, &page, NULL) == 1)
+ *	if (get_user_pages(addr, 1, FOLL_WRITE | FOLL_FORCE, &page,
+ *		NULL, NULL) == 1)
  *		put_page(page);
  *
  * but taking great care only to touch a ksm page, in a VM_MERGEABLE vma,
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index 0b859af..4be72c7 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -850,7 +850,7 @@ static int lookup_node(unsigned long addr)
 	struct page *p;
 	int err;
 
-	err = get_user_pages(addr & PAGE_MASK, 1, 0, &p, NULL);
+	err = get_user_pages(addr & PAGE_MASK, 1, 0, &p, NULL, NULL);
 	if (err >= 0) {
 		err = page_to_nid(p);
 		put_page(p);
diff --git a/mm/nommu.c b/mm/nommu.c
index 8b8faaf..82aaa33 100644
--- a/mm/nommu.c
+++ b/mm/nommu.c
@@ -161,7 +161,7 @@ static long __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
  */
 long get_user_pages(unsigned long start, unsigned long nr_pages,
 		    unsigned int gup_flags, struct page **pages,
-		    struct vm_area_struct **vmas)
+		    struct vm_area_struct **vmas, int *locked)
 {
 	return __get_user_pages(current, current->mm, start, nr_pages,
 				gup_flags, pages, vmas, NULL);
@@ -172,7 +172,7 @@ long get_user_pages_locked(unsigned long start, unsigned long nr_pages,
 			    unsigned int gup_flags, struct page **pages,
 			    int *locked)
 {
-	return get_user_pages(start, nr_pages, gup_flags, pages, NULL);
+	return get_user_pages(start, nr_pages, gup_flags, pages, NULL, NULL);
 }
 EXPORT_SYMBOL(get_user_pages_locked);
 
diff --git a/virt/kvm/kvm_main.c b/virt/kvm/kvm_main.c
index 2907b7b..353bcb2 100644
--- a/virt/kvm/kvm_main.c
+++ b/virt/kvm/kvm_main.c
@@ -1351,14 +1351,14 @@ static int get_user_page_nowait(unsigned long start, int write,
 	if (write)
 		flags |= FOLL_WRITE;
 
-	return get_user_pages(start, 1, flags, page, NULL);
+	return get_user_pages(start, 1, flags, page, NULL, NULL);
 }
 
 static inline int check_user_page_hwpoison(unsigned long addr)
 {
 	int rc, flags = FOLL_HWPOISON | FOLL_WRITE;
 
-	rc = get_user_pages(addr, 1, flags, NULL, NULL);
+	rc = get_user_pages(addr, 1, flags, NULL, NULL, NULL);
 	return rc == -EHWPOISON;
 }
 
-- 
2.10.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
