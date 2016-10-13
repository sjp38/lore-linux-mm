Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id EA50B280251
	for <linux-mm@kvack.org>; Wed, 12 Oct 2016 20:20:39 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id i187so36557045lfe.4
        for <linux-mm@kvack.org>; Wed, 12 Oct 2016 17:20:39 -0700 (PDT)
Received: from mail-lf0-x243.google.com (mail-lf0-x243.google.com. [2a00:1450:4010:c07::243])
        by mx.google.com with ESMTPS id v64si6449383lfi.365.2016.10.12.17.20.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Oct 2016 17:20:37 -0700 (PDT)
Received: by mail-lf0-x243.google.com with SMTP id b75so9577288lfg.3
        for <linux-mm@kvack.org>; Wed, 12 Oct 2016 17:20:37 -0700 (PDT)
From: Lorenzo Stoakes <lstoakes@gmail.com>
Subject: [PATCH 06/10] mm: replace get_user_pages() write/force parameters with gup_flags
Date: Thu, 13 Oct 2016 01:20:16 +0100
Message-Id: <20161013002020.3062-7-lstoakes@gmail.com>
In-Reply-To: <20161013002020.3062-1-lstoakes@gmail.com>
References: <20161013002020.3062-1-lstoakes@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Jan Kara <jack@suse.cz>, Hugh Dickins <hughd@google.com>, Dave Hansen <dave.hansen@linux.intel.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>, adi-buildroot-devel@lists.sourceforge.net, ceph-devel@vger.kernel.org, dri-devel@lists.freedesktop.org, intel-gfx@lists.freedesktop.org, kvm@vger.kernel.org, linux-alpha@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-cris-kernel@axis.com, linux-fbdev@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org, linux-media@vger.kernel.org, linux-mips@linux-mips.org, linux-rdma@vger.kernel.org, linux-s390@vger.kernel.org, linux-samsung-soc@vger.kernel.org, linux-scsi@vger.kernel.org, linux-security-module@vger.kernel.org, linux-sh@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, netdev@vger.kernel.org, sparclinux@vger.kernel.org, x86@kernel.org, Lorenzo Stoakes <lstoakes@gmail.com>

This patch removes the write and force parameters from get_user_pages() and
replaces them with a gup_flags parameter to make the use of FOLL_FORCE explicit
in callers as use of this flag can result in surprising behaviour (and hence
bugs) within the mm subsystem.

Signed-off-by: Lorenzo Stoakes <lstoakes@gmail.com>
---
 arch/cris/arch-v32/drivers/cryptocop.c                 |  4 +---
 arch/ia64/kernel/err_inject.c                          |  2 +-
 arch/x86/mm/mpx.c                                      |  5 ++---
 drivers/gpu/drm/amd/amdgpu/amdgpu_ttm.c                |  7 +++++--
 drivers/gpu/drm/radeon/radeon_ttm.c                    |  3 ++-
 drivers/gpu/drm/via/via_dmablit.c                      |  4 ++--
 drivers/infiniband/core/umem.c                         |  6 +++++-
 drivers/infiniband/hw/mthca/mthca_memfree.c            |  2 +-
 drivers/infiniband/hw/qib/qib_user_pages.c             |  3 ++-
 drivers/infiniband/hw/usnic/usnic_uiom.c               |  5 ++++-
 drivers/media/v4l2-core/videobuf-dma-sg.c              |  7 +++++--
 drivers/misc/mic/scif/scif_rma.c                       |  3 +--
 drivers/misc/sgi-gru/grufault.c                        |  2 +-
 drivers/platform/goldfish/goldfish_pipe.c              |  3 ++-
 drivers/rapidio/devices/rio_mport_cdev.c               |  3 ++-
 .../vc04_services/interface/vchiq_arm/vchiq_2835_arm.c |  3 +--
 .../vc04_services/interface/vchiq_arm/vchiq_arm.c      |  3 +--
 drivers/virt/fsl_hypervisor.c                          |  4 ++--
 include/linux/mm.h                                     |  2 +-
 mm/gup.c                                               | 12 +++---------
 mm/mempolicy.c                                         |  2 +-
 mm/nommu.c                                             | 18 ++++--------------
 22 files changed, 49 insertions(+), 54 deletions(-)

diff --git a/arch/cris/arch-v32/drivers/cryptocop.c b/arch/cris/arch-v32/drivers/cryptocop.c
index b5698c8..099e170 100644
--- a/arch/cris/arch-v32/drivers/cryptocop.c
+++ b/arch/cris/arch-v32/drivers/cryptocop.c
@@ -2722,7 +2722,6 @@ static int cryptocop_ioctl_process(struct inode *inode, struct file *filp, unsig
 	err = get_user_pages((unsigned long int)(oper.indata + prev_ix),
 			     noinpages,
 			     0,  /* read access only for in data */
-			     0, /* no force */
 			     inpages,
 			     NULL);
 
@@ -2736,8 +2735,7 @@ static int cryptocop_ioctl_process(struct inode *inode, struct file *filp, unsig
 	if (oper.do_cipher){
 		err = get_user_pages((unsigned long int)oper.cipher_outdata,
 				     nooutpages,
-				     1, /* write access for out data */
-				     0, /* no force */
+				     FOLL_WRITE, /* write access for out data */
 				     outpages,
 				     NULL);
 		up_read(&current->mm->mmap_sem);
diff --git a/arch/ia64/kernel/err_inject.c b/arch/ia64/kernel/err_inject.c
index 09f8457..5ed0ea9 100644
--- a/arch/ia64/kernel/err_inject.c
+++ b/arch/ia64/kernel/err_inject.c
@@ -142,7 +142,7 @@ store_virtual_to_phys(struct device *dev, struct device_attribute *attr,
 	u64 virt_addr=simple_strtoull(buf, NULL, 16);
 	int ret;
 
-	ret = get_user_pages(virt_addr, 1, VM_READ, 0, NULL, NULL);
+	ret = get_user_pages(virt_addr, 1, FOLL_WRITE, NULL, NULL);
 	if (ret<=0) {
 #ifdef ERR_INJ_DEBUG
 		printk("Virtual address %lx is not existing.\n",virt_addr);
diff --git a/arch/x86/mm/mpx.c b/arch/x86/mm/mpx.c
index 8047687..e4f8009 100644
--- a/arch/x86/mm/mpx.c
+++ b/arch/x86/mm/mpx.c
@@ -544,10 +544,9 @@ static int mpx_resolve_fault(long __user *addr, int write)
 {
 	long gup_ret;
 	int nr_pages = 1;
-	int force = 0;
 
-	gup_ret = get_user_pages((unsigned long)addr, nr_pages, write,
-			force, NULL, NULL);
+	gup_ret = get_user_pages((unsigned long)addr, nr_pages,
+			write ? FOLL_WRITE : 0,	NULL, NULL);
 	/*
 	 * get_user_pages() returns number of pages gotten.
 	 * 0 means we failed to fault in and get anything,
diff --git a/drivers/gpu/drm/amd/amdgpu/amdgpu_ttm.c b/drivers/gpu/drm/amd/amdgpu/amdgpu_ttm.c
index 887483b..dcaf691 100644
--- a/drivers/gpu/drm/amd/amdgpu/amdgpu_ttm.c
+++ b/drivers/gpu/drm/amd/amdgpu/amdgpu_ttm.c
@@ -555,10 +555,13 @@ struct amdgpu_ttm_tt {
 int amdgpu_ttm_tt_get_user_pages(struct ttm_tt *ttm, struct page **pages)
 {
 	struct amdgpu_ttm_tt *gtt = (void *)ttm;
-	int write = !(gtt->userflags & AMDGPU_GEM_USERPTR_READONLY);
+	unsigned int flags = 0;
 	unsigned pinned = 0;
 	int r;
 
+	if (!(gtt->userflags & AMDGPU_GEM_USERPTR_READONLY))
+		flags |= FOLL_WRITE;
+
 	if (gtt->userflags & AMDGPU_GEM_USERPTR_ANONONLY) {
 		/* check that we only use anonymous memory
 		   to prevent problems with writeback */
@@ -581,7 +584,7 @@ int amdgpu_ttm_tt_get_user_pages(struct ttm_tt *ttm, struct page **pages)
 		list_add(&guptask.list, &gtt->guptasks);
 		spin_unlock(&gtt->guptasklock);
 
-		r = get_user_pages(userptr, num_pages, write, 0, p, NULL);
+		r = get_user_pages(userptr, num_pages, flags, p, NULL);
 
 		spin_lock(&gtt->guptasklock);
 		list_del(&guptask.list);
diff --git a/drivers/gpu/drm/radeon/radeon_ttm.c b/drivers/gpu/drm/radeon/radeon_ttm.c
index 4552682..3de5e6e 100644
--- a/drivers/gpu/drm/radeon/radeon_ttm.c
+++ b/drivers/gpu/drm/radeon/radeon_ttm.c
@@ -566,7 +566,8 @@ static int radeon_ttm_tt_pin_userptr(struct ttm_tt *ttm)
 		uint64_t userptr = gtt->userptr + pinned * PAGE_SIZE;
 		struct page **pages = ttm->pages + pinned;
 
-		r = get_user_pages(userptr, num_pages, write, 0, pages, NULL);
+		r = get_user_pages(userptr, num_pages, write ? FOLL_WRITE : 0,
+				   pages, NULL);
 		if (r < 0)
 			goto release_pages;
 
diff --git a/drivers/gpu/drm/via/via_dmablit.c b/drivers/gpu/drm/via/via_dmablit.c
index 7e2a12c..1a3ad76 100644
--- a/drivers/gpu/drm/via/via_dmablit.c
+++ b/drivers/gpu/drm/via/via_dmablit.c
@@ -241,8 +241,8 @@ via_lock_all_dma_pages(drm_via_sg_info_t *vsg,  drm_via_dmablit_t *xfer)
 	down_read(&current->mm->mmap_sem);
 	ret = get_user_pages((unsigned long)xfer->mem_addr,
 			     vsg->num_pages,
-			     (vsg->direction == DMA_FROM_DEVICE),
-			     0, vsg->pages, NULL);
+			     (vsg->direction == DMA_FROM_DEVICE) ? FOLL_WRITE : 0,
+			     vsg->pages, NULL);
 
 	up_read(&current->mm->mmap_sem);
 	if (ret != vsg->num_pages) {
diff --git a/drivers/infiniband/core/umem.c b/drivers/infiniband/core/umem.c
index c68746c..224ad27 100644
--- a/drivers/infiniband/core/umem.c
+++ b/drivers/infiniband/core/umem.c
@@ -94,6 +94,7 @@ struct ib_umem *ib_umem_get(struct ib_ucontext *context, unsigned long addr,
 	unsigned long dma_attrs = 0;
 	struct scatterlist *sg, *sg_list_start;
 	int need_release = 0;
+	unsigned int gup_flags = FOLL_WRITE;
 
 	if (dmasync)
 		dma_attrs |= DMA_ATTR_WRITE_BARRIER;
@@ -183,6 +184,9 @@ struct ib_umem *ib_umem_get(struct ib_ucontext *context, unsigned long addr,
 	if (ret)
 		goto out;
 
+	if (!umem->writable)
+		gup_flags |= FOLL_FORCE;
+
 	need_release = 1;
 	sg_list_start = umem->sg_head.sgl;
 
@@ -190,7 +194,7 @@ struct ib_umem *ib_umem_get(struct ib_ucontext *context, unsigned long addr,
 		ret = get_user_pages(cur_base,
 				     min_t(unsigned long, npages,
 					   PAGE_SIZE / sizeof (struct page *)),
-				     1, !umem->writable, page_list, vma_list);
+				     gup_flags, page_list, vma_list);
 
 		if (ret < 0)
 			goto out;
diff --git a/drivers/infiniband/hw/mthca/mthca_memfree.c b/drivers/infiniband/hw/mthca/mthca_memfree.c
index 6c00d04..c6fe89d 100644
--- a/drivers/infiniband/hw/mthca/mthca_memfree.c
+++ b/drivers/infiniband/hw/mthca/mthca_memfree.c
@@ -472,7 +472,7 @@ int mthca_map_user_db(struct mthca_dev *dev, struct mthca_uar *uar,
 		goto out;
 	}
 
-	ret = get_user_pages(uaddr & PAGE_MASK, 1, 1, 0, pages, NULL);
+	ret = get_user_pages(uaddr & PAGE_MASK, 1, FOLL_WRITE, pages, NULL);
 	if (ret < 0)
 		goto out;
 
diff --git a/drivers/infiniband/hw/qib/qib_user_pages.c b/drivers/infiniband/hw/qib/qib_user_pages.c
index 2d2b94f..75f0862 100644
--- a/drivers/infiniband/hw/qib/qib_user_pages.c
+++ b/drivers/infiniband/hw/qib/qib_user_pages.c
@@ -67,7 +67,8 @@ static int __qib_get_user_pages(unsigned long start_page, size_t num_pages,
 
 	for (got = 0; got < num_pages; got += ret) {
 		ret = get_user_pages(start_page + got * PAGE_SIZE,
-				     num_pages - got, 1, 1,
+				     num_pages - got,
+				     FOLL_WRITE | FOLL_FORCE,
 				     p + got, NULL);
 		if (ret < 0)
 			goto bail_release;
diff --git a/drivers/infiniband/hw/usnic/usnic_uiom.c b/drivers/infiniband/hw/usnic/usnic_uiom.c
index a0b6ebe..1ccee6e 100644
--- a/drivers/infiniband/hw/usnic/usnic_uiom.c
+++ b/drivers/infiniband/hw/usnic/usnic_uiom.c
@@ -111,6 +111,7 @@ static int usnic_uiom_get_pages(unsigned long addr, size_t size, int writable,
 	int i;
 	int flags;
 	dma_addr_t pa;
+	unsigned int gup_flags;
 
 	if (!can_do_mlock())
 		return -EPERM;
@@ -135,6 +136,8 @@ static int usnic_uiom_get_pages(unsigned long addr, size_t size, int writable,
 
 	flags = IOMMU_READ | IOMMU_CACHE;
 	flags |= (writable) ? IOMMU_WRITE : 0;
+	gup_flags = FOLL_WRITE;
+	gup_flags |= (writable) ? 0 : FOLL_FORCE;
 	cur_base = addr & PAGE_MASK;
 	ret = 0;
 
@@ -142,7 +145,7 @@ static int usnic_uiom_get_pages(unsigned long addr, size_t size, int writable,
 		ret = get_user_pages(cur_base,
 					min_t(unsigned long, npages,
 					PAGE_SIZE / sizeof(struct page *)),
-					1, !writable, page_list, NULL);
+					gup_flags, page_list, NULL);
 
 		if (ret < 0)
 			goto out;
diff --git a/drivers/media/v4l2-core/videobuf-dma-sg.c b/drivers/media/v4l2-core/videobuf-dma-sg.c
index f300f06..1db0af6 100644
--- a/drivers/media/v4l2-core/videobuf-dma-sg.c
+++ b/drivers/media/v4l2-core/videobuf-dma-sg.c
@@ -156,6 +156,7 @@ static int videobuf_dma_init_user_locked(struct videobuf_dmabuf *dma,
 {
 	unsigned long first, last;
 	int err, rw = 0;
+	unsigned int flags = FOLL_FORCE;
 
 	dma->direction = direction;
 	switch (dma->direction) {
@@ -178,12 +179,14 @@ static int videobuf_dma_init_user_locked(struct videobuf_dmabuf *dma,
 	if (NULL == dma->pages)
 		return -ENOMEM;
 
+	if (rw == READ)
+		flags |= FOLL_WRITE;
+
 	dprintk(1, "init user [0x%lx+0x%lx => %d pages]\n",
 		data, size, dma->nr_pages);
 
 	err = get_user_pages(data & PAGE_MASK, dma->nr_pages,
-			     rw == READ, 1, /* force */
-			     dma->pages, NULL);
+			     flags, dma->pages, NULL);
 
 	if (err != dma->nr_pages) {
 		dma->nr_pages = (err >= 0) ? err : 0;
diff --git a/drivers/misc/mic/scif/scif_rma.c b/drivers/misc/mic/scif/scif_rma.c
index e0203b1..f806a44 100644
--- a/drivers/misc/mic/scif/scif_rma.c
+++ b/drivers/misc/mic/scif/scif_rma.c
@@ -1396,8 +1396,7 @@ int __scif_pin_pages(void *addr, size_t len, int *out_prot,
 		pinned_pages->nr_pages = get_user_pages(
 				(u64)addr,
 				nr_pages,
-				!!(prot & SCIF_PROT_WRITE),
-				0,
+				(prot & SCIF_PROT_WRITE) ? FOLL_WRITE : 0,
 				pinned_pages->pages,
 				NULL);
 		up_write(&mm->mmap_sem);
diff --git a/drivers/misc/sgi-gru/grufault.c b/drivers/misc/sgi-gru/grufault.c
index a2d97b9..6fb773d 100644
--- a/drivers/misc/sgi-gru/grufault.c
+++ b/drivers/misc/sgi-gru/grufault.c
@@ -198,7 +198,7 @@ static int non_atomic_pte_lookup(struct vm_area_struct *vma,
 #else
 	*pageshift = PAGE_SHIFT;
 #endif
-	if (get_user_pages(vaddr, 1, write, 0, &page, NULL) <= 0)
+	if (get_user_pages(vaddr, 1, write ? FOLL_WRITE : 0, &page, NULL) <= 0)
 		return -EFAULT;
 	*paddr = page_to_phys(page);
 	put_page(page);
diff --git a/drivers/platform/goldfish/goldfish_pipe.c b/drivers/platform/goldfish/goldfish_pipe.c
index 07462d7..1aba2c7 100644
--- a/drivers/platform/goldfish/goldfish_pipe.c
+++ b/drivers/platform/goldfish/goldfish_pipe.c
@@ -309,7 +309,8 @@ static ssize_t goldfish_pipe_read_write(struct file *filp, char __user *buffer,
 		 * much memory to the process.
 		 */
 		down_read(&current->mm->mmap_sem);
-		ret = get_user_pages(address, 1, !is_write, 0, &page, NULL);
+		ret = get_user_pages(address, 1, is_write ? 0 : FOLL_WRITE,
+				&page, NULL);
 		up_read(&current->mm->mmap_sem);
 		if (ret < 0)
 			break;
diff --git a/drivers/rapidio/devices/rio_mport_cdev.c b/drivers/rapidio/devices/rio_mport_cdev.c
index 436dfe8..9013a58 100644
--- a/drivers/rapidio/devices/rio_mport_cdev.c
+++ b/drivers/rapidio/devices/rio_mport_cdev.c
@@ -892,7 +892,8 @@ rio_dma_transfer(struct file *filp, u32 transfer_mode,
 		down_read(&current->mm->mmap_sem);
 		pinned = get_user_pages(
 				(unsigned long)xfer->loc_addr & PAGE_MASK,
-				nr_pages, dir == DMA_FROM_DEVICE, 0,
+				nr_pages,
+				dir == DMA_FROM_DEVICE ? FOLL_WRITE : 0,
 				page_list, NULL);
 		up_read(&current->mm->mmap_sem);
 
diff --git a/drivers/staging/vc04_services/interface/vchiq_arm/vchiq_2835_arm.c b/drivers/staging/vc04_services/interface/vchiq_arm/vchiq_2835_arm.c
index c29040f..1091b9f 100644
--- a/drivers/staging/vc04_services/interface/vchiq_arm/vchiq_2835_arm.c
+++ b/drivers/staging/vc04_services/interface/vchiq_arm/vchiq_2835_arm.c
@@ -423,8 +423,7 @@ create_pagelist(char __user *buf, size_t count, unsigned short type,
 		actual_pages = get_user_pages(task, task->mm,
 				          (unsigned long)buf & ~(PAGE_SIZE - 1),
 					  num_pages,
-					  (type == PAGELIST_READ) /*Write */ ,
-					  0 /*Force */ ,
+					  (type == PAGELIST_READ) ? FOLL_WRITE : 0,
 					  pages,
 					  NULL /*vmas */);
 		up_read(&task->mm->mmap_sem);
diff --git a/drivers/staging/vc04_services/interface/vchiq_arm/vchiq_arm.c b/drivers/staging/vc04_services/interface/vchiq_arm/vchiq_arm.c
index e11c0e0..7b6cd4d 100644
--- a/drivers/staging/vc04_services/interface/vchiq_arm/vchiq_arm.c
+++ b/drivers/staging/vc04_services/interface/vchiq_arm/vchiq_arm.c
@@ -1477,8 +1477,7 @@ dump_phys_mem(void *virt_addr, uint32_t num_bytes)
 		current->mm,              /* mm */
 		(unsigned long)virt_addr, /* start */
 		num_pages,                /* len */
-		0,                        /* write */
-		0,                        /* force */
+		0,                        /* gup_flags */
 		pages,                    /* pages (array of page pointers) */
 		NULL);                    /* vmas */
 	up_read(&current->mm->mmap_sem);
diff --git a/drivers/virt/fsl_hypervisor.c b/drivers/virt/fsl_hypervisor.c
index 60bdad3..150ce2a 100644
--- a/drivers/virt/fsl_hypervisor.c
+++ b/drivers/virt/fsl_hypervisor.c
@@ -245,8 +245,8 @@ static long ioctl_memcpy(struct fsl_hv_ioctl_memcpy __user *p)
 	/* Get the physical addresses of the source buffer */
 	down_read(&current->mm->mmap_sem);
 	num_pinned = get_user_pages(param.local_vaddr - lb_offset,
-		num_pages, (param.source == -1) ? READ : WRITE,
-		0, pages, NULL);
+		num_pages, (param.source == -1) ? 0 : FOLL_WRITE,
+		pages, NULL);
 	up_read(&current->mm->mmap_sem);
 
 	if (num_pinned != num_pages) {
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 5ff084f6..686a477 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -1279,7 +1279,7 @@ long get_user_pages_remote(struct task_struct *tsk, struct mm_struct *mm,
 			    int write, int force, struct page **pages,
 			    struct vm_area_struct **vmas);
 long get_user_pages(unsigned long start, unsigned long nr_pages,
-			    int write, int force, struct page **pages,
+			    unsigned int gup_flags, struct page **pages,
 			    struct vm_area_struct **vmas);
 long get_user_pages_locked(unsigned long start, unsigned long nr_pages,
 		    unsigned int gup_flags, struct page **pages, int *locked);
diff --git a/mm/gup.c b/mm/gup.c
index 7a0d033..dc91303 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -977,18 +977,12 @@ EXPORT_SYMBOL(get_user_pages_remote);
  * obviously don't pass FOLL_REMOTE in here.
  */
 long get_user_pages(unsigned long start, unsigned long nr_pages,
-		int write, int force, struct page **pages,
+		unsigned int gup_flags, struct page **pages,
 		struct vm_area_struct **vmas)
 {
-	unsigned int flags = FOLL_TOUCH;
-
-	if (write)
-		flags |= FOLL_WRITE;
-	if (force)
-		flags |= FOLL_FORCE;
-
 	return __get_user_pages_locked(current, current->mm, start, nr_pages,
-				       pages, vmas, NULL, false, flags);
+				       pages, vmas, NULL, false,
+				       gup_flags | FOLL_TOUCH);
 }
 EXPORT_SYMBOL(get_user_pages);
 
diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index ad1c96a..0b859af 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -850,7 +850,7 @@ static int lookup_node(unsigned long addr)
 	struct page *p;
 	int err;
 
-	err = get_user_pages(addr & PAGE_MASK, 1, 0, 0, &p, NULL);
+	err = get_user_pages(addr & PAGE_MASK, 1, 0, &p, NULL);
 	if (err >= 0) {
 		err = page_to_nid(p);
 		put_page(p);
diff --git a/mm/nommu.c b/mm/nommu.c
index 842cfdd..70cb844 100644
--- a/mm/nommu.c
+++ b/mm/nommu.c
@@ -160,18 +160,11 @@ long __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
  * - don't permit access to VMAs that don't support it, such as I/O mappings
  */
 long get_user_pages(unsigned long start, unsigned long nr_pages,
-		    int write, int force, struct page **pages,
+		    unsigned int gup_flags, struct page **pages,
 		    struct vm_area_struct **vmas)
 {
-	int flags = 0;
-
-	if (write)
-		flags |= FOLL_WRITE;
-	if (force)
-		flags |= FOLL_FORCE;
-
-	return __get_user_pages(current, current->mm, start, nr_pages, flags,
-				pages, vmas, NULL);
+	return __get_user_pages(current, current->mm, start, nr_pages,
+				gup_flags, pages, vmas, NULL);
 }
 EXPORT_SYMBOL(get_user_pages);
 
@@ -179,10 +172,7 @@ long get_user_pages_locked(unsigned long start, unsigned long nr_pages,
 			    unsigned int gup_flags, struct page **pages,
 			    int *locked)
 {
-	int write = gup_flags & FOLL_WRITE;
-	int force = gup_flags & FOLL_FORCE;
-
-	return get_user_pages(start, nr_pages, write, force, pages, NULL);
+	return get_user_pages(start, nr_pages, gup_flags, pages, NULL);
 }
 EXPORT_SYMBOL(get_user_pages_locked);
 
-- 
2.10.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
