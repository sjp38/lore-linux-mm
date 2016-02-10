Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id E720D828E2
	for <linux-mm@kvack.org>; Wed, 10 Feb 2016 13:10:07 -0500 (EST)
Received: by mail-pa0-f52.google.com with SMTP id dk10so2213037pac.1
        for <linux-mm@kvack.org>; Wed, 10 Feb 2016 10:10:07 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id l4si6446663pfi.249.2016.02.10.10.10.05
        for <linux-mm@kvack.org>;
        Wed, 10 Feb 2016 10:10:05 -0800 (PST)
Subject: [PATCH 3/3] mm, gup: switch callers of get_user_pages() to not pass tsk/mm
From: Dave Hansen <dave@sr71.net>
Date: Wed, 10 Feb 2016 10:10:04 -0800
References: <20160210181000.886CDF18@viggo.jf.intel.com>
In-Reply-To: <20160210181000.886CDF18@viggo.jf.intel.com>
Message-Id: <20160210181004.D39F512D@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, x86@kernel.org, torvalds@linux-foundation.org, Dave Hansen <dave@sr71.net>, dave.hansen@linux.intel.com, srikar@linux.vnet.ibm.com, vbabka@suse.cz, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, aarcange@redhat.com, n-horiguchi@ah.jp.nec.com, jack@suse.cz


From: Dave Hansen <dave.hansen@linux.intel.com>

We will soon modify the vanilla get_user_pages() so it can no
longer be used on mm/tasks other than 'current/current->mm',
which is by far the most common way it is called.  For now,
we allow the old-style calls, but warn when they are used.
(implemented in previous patch)

This patch switches all callers of:

	get_user_pages()
	get_user_pages_unlocked()
	get_user_pages_locked()

to stop passing tsk/mm so they will no longer see the warnings.

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: jack@suse.cz
---

 b/arch/cris/arch-v32/drivers/cryptocop.c      |    8 ++------
 b/arch/ia64/kernel/err_inject.c               |    3 +--
 b/arch/mips/mm/gup.c                          |    3 +--
 b/arch/s390/mm/gup.c                          |    4 +---
 b/arch/sh/mm/gup.c                            |    2 +-
 b/arch/sparc/mm/gup.c                         |    2 +-
 b/arch/x86/mm/gup.c                           |    2 +-
 b/arch/x86/mm/mpx.c                           |    4 ++--
 b/drivers/gpu/drm/amd/amdgpu/amdgpu_ttm.c     |    3 +--
 b/drivers/gpu/drm/radeon/radeon_ttm.c         |    3 +--
 b/drivers/gpu/drm/via/via_dmablit.c           |    3 +--
 b/drivers/infiniband/core/umem.c              |    2 +-
 b/drivers/infiniband/hw/mthca/mthca_memfree.c |    3 +--
 b/drivers/infiniband/hw/qib/qib_user_pages.c  |    3 +--
 b/drivers/infiniband/hw/usnic/usnic_uiom.c    |    2 +-
 b/drivers/media/pci/ivtv/ivtv-udma.c          |    4 ++--
 b/drivers/media/pci/ivtv/ivtv-yuv.c           |   10 ++++------
 b/drivers/media/v4l2-core/videobuf-dma-sg.c   |    3 +--
 b/drivers/misc/mic/scif/scif_rma.c            |    2 --
 b/drivers/misc/sgi-gru/grufault.c             |    3 +--
 b/drivers/scsi/st.c                           |    2 --
 b/drivers/video/fbdev/pvr2fb.c                |    4 ++--
 b/drivers/virt/fsl_hypervisor.c               |    5 ++---
 b/mm/frame_vector.c                           |    2 +-
 b/mm/gup.c                                    |    6 ++++--
 b/mm/ksm.c                                    |    2 +-
 b/mm/mempolicy.c                              |    6 +++---
 b/net/ceph/pagevec.c                          |    2 +-
 b/virt/kvm/kvm_main.c                         |   10 +++++-----
 29 files changed, 44 insertions(+), 64 deletions(-)

diff -puN arch/cris/arch-v32/drivers/cryptocop.c~get_current_user_pages arch/cris/arch-v32/drivers/cryptocop.c
--- a/arch/cris/arch-v32/drivers/cryptocop.c~get_current_user_pages	2016-02-10 10:09:01.334331735 -0800
+++ b/arch/cris/arch-v32/drivers/cryptocop.c	2016-02-10 10:09:01.385334082 -0800
@@ -2719,9 +2719,7 @@ static int cryptocop_ioctl_process(struc
 	/* Acquire the mm page semaphore. */
 	down_read(&current->mm->mmap_sem);
 
-	err = get_user_pages(current,
-			     current->mm,
-			     (unsigned long int)(oper.indata + prev_ix),
+	err = get_user_pages((unsigned long int)(oper.indata + prev_ix),
 			     noinpages,
 			     0,  /* read access only for in data */
 			     0, /* no force */
@@ -2736,9 +2734,7 @@ static int cryptocop_ioctl_process(struc
 	}
 	noinpages = err;
 	if (oper.do_cipher){
-		err = get_user_pages(current,
-				     current->mm,
-				     (unsigned long int)oper.cipher_outdata,
+		err = get_user_pages((unsigned long int)oper.cipher_outdata,
 				     nooutpages,
 				     1, /* write access for out data */
 				     0, /* no force */
diff -puN arch/ia64/kernel/err_inject.c~get_current_user_pages arch/ia64/kernel/err_inject.c
--- a/arch/ia64/kernel/err_inject.c~get_current_user_pages	2016-02-10 10:09:01.336331827 -0800
+++ b/arch/ia64/kernel/err_inject.c	2016-02-10 10:09:01.386334128 -0800
@@ -142,8 +142,7 @@ store_virtual_to_phys(struct device *dev
 	u64 virt_addr=simple_strtoull(buf, NULL, 16);
 	int ret;
 
-        ret = get_user_pages(current, current->mm, virt_addr,
-                        1, VM_READ, 0, NULL, NULL);
+	ret = get_user_pages(virt_addr, 1, VM_READ, 0, NULL, NULL);
 	if (ret<=0) {
 #ifdef ERR_INJ_DEBUG
 		printk("Virtual address %lx is not existing.\n",virt_addr);
diff -puN arch/mips/mm/gup.c~get_current_user_pages arch/mips/mm/gup.c
--- a/arch/mips/mm/gup.c~get_current_user_pages	2016-02-10 10:09:01.337331873 -0800
+++ b/arch/mips/mm/gup.c	2016-02-10 10:09:01.386334128 -0800
@@ -286,8 +286,7 @@ slow_irqon:
 	start += nr << PAGE_SHIFT;
 	pages += nr;
 
-	ret = get_user_pages_unlocked(current, mm, start,
-				      (end - start) >> PAGE_SHIFT,
+	ret = get_user_pages_unlocked(start, (end - start) >> PAGE_SHIFT,
 				      write, 0, pages);
 
 	/* Have to be a bit careful with return values */
diff -puN arch/s390/mm/gup.c~get_current_user_pages arch/s390/mm/gup.c
--- a/arch/s390/mm/gup.c~get_current_user_pages	2016-02-10 10:09:01.339331965 -0800
+++ b/arch/s390/mm/gup.c	2016-02-10 10:09:01.387334174 -0800
@@ -210,7 +210,6 @@ int __get_user_pages_fast(unsigned long
 int get_user_pages_fast(unsigned long start, int nr_pages, int write,
 			struct page **pages)
 {
-	struct mm_struct *mm = current->mm;
 	int nr, ret;
 
 	might_sleep();
@@ -222,8 +221,7 @@ int get_user_pages_fast(unsigned long st
 	/* Try to get the remaining pages with get_user_pages */
 	start += nr << PAGE_SHIFT;
 	pages += nr;
-	ret = get_user_pages_unlocked(current, mm, start,
-			     nr_pages - nr, write, 0, pages);
+	ret = get_user_pages_unlocked(start, nr_pages - nr, write, 0, pages);
 	/* Have to be a bit careful with return values */
 	if (nr > 0)
 		ret = (ret < 0) ? nr : ret + nr;
diff -puN arch/sh/mm/gup.c~get_current_user_pages arch/sh/mm/gup.c
--- a/arch/sh/mm/gup.c~get_current_user_pages	2016-02-10 10:09:01.340332011 -0800
+++ b/arch/sh/mm/gup.c	2016-02-10 10:09:01.387334174 -0800
@@ -257,7 +257,7 @@ slow_irqon:
 		start += nr << PAGE_SHIFT;
 		pages += nr;
 
-		ret = get_user_pages_unlocked(current, mm, start,
+		ret = get_user_pages_unlocked(start,
 			(end - start) >> PAGE_SHIFT, write, 0, pages);
 
 		/* Have to be a bit careful with return values */
diff -puN arch/sparc/mm/gup.c~get_current_user_pages arch/sparc/mm/gup.c
--- a/arch/sparc/mm/gup.c~get_current_user_pages	2016-02-10 10:09:01.342332103 -0800
+++ b/arch/sparc/mm/gup.c	2016-02-10 10:09:01.387334174 -0800
@@ -237,7 +237,7 @@ slow:
 		start += nr << PAGE_SHIFT;
 		pages += nr;
 
-		ret = get_user_pages_unlocked(current, mm, start,
+		ret = get_user_pages_unlocked(start,
 			(end - start) >> PAGE_SHIFT, write, 0, pages);
 
 		/* Have to be a bit careful with return values */
diff -puN arch/x86/mm/gup.c~get_current_user_pages arch/x86/mm/gup.c
--- a/arch/x86/mm/gup.c~get_current_user_pages	2016-02-10 10:09:01.344332195 -0800
+++ b/arch/x86/mm/gup.c	2016-02-10 10:09:01.387334174 -0800
@@ -422,7 +422,7 @@ slow_irqon:
 		start += nr << PAGE_SHIFT;
 		pages += nr;
 
-		ret = get_user_pages_unlocked(current, mm, start,
+		ret = get_user_pages_unlocked(start,
 					      (end - start) >> PAGE_SHIFT,
 					      write, 0, pages);
 
diff -puN arch/x86/mm/mpx.c~get_current_user_pages arch/x86/mm/mpx.c
--- a/arch/x86/mm/mpx.c~get_current_user_pages	2016-02-10 10:09:01.345332241 -0800
+++ b/arch/x86/mm/mpx.c	2016-02-10 10:09:01.388334220 -0800
@@ -546,8 +546,8 @@ static int mpx_resolve_fault(long __user
 	int nr_pages = 1;
 	int force = 0;
 
-	gup_ret = get_user_pages(current, current->mm, (unsigned long)addr,
-				 nr_pages, write, force, NULL, NULL);
+	gup_ret = get_user_pages((unsigned long)addr, nr_pages, write,
+			force, NULL, NULL);
 	/*
 	 * get_user_pages() returns number of pages gotten.
 	 * 0 means we failed to fault in and get anything,
diff -puN drivers/gpu/drm/amd/amdgpu/amdgpu_ttm.c~get_current_user_pages drivers/gpu/drm/amd/amdgpu/amdgpu_ttm.c
--- a/drivers/gpu/drm/amd/amdgpu/amdgpu_ttm.c~get_current_user_pages	2016-02-10 10:09:01.347332333 -0800
+++ b/drivers/gpu/drm/amd/amdgpu/amdgpu_ttm.c	2016-02-10 10:09:01.389334266 -0800
@@ -518,8 +518,7 @@ static int amdgpu_ttm_tt_pin_userptr(str
 		uint64_t userptr = gtt->userptr + pinned * PAGE_SIZE;
 		struct page **pages = ttm->pages + pinned;
 
-		r = get_user_pages(current, current->mm, userptr, num_pages,
-				   write, 0, pages, NULL);
+		r = get_user_pages(userptr, num_pages, write, 0, pages, NULL);
 		if (r < 0)
 			goto release_pages;
 
diff -puN drivers/gpu/drm/radeon/radeon_ttm.c~get_current_user_pages drivers/gpu/drm/radeon/radeon_ttm.c
--- a/drivers/gpu/drm/radeon/radeon_ttm.c~get_current_user_pages	2016-02-10 10:09:01.349332425 -0800
+++ b/drivers/gpu/drm/radeon/radeon_ttm.c	2016-02-10 10:09:01.389334266 -0800
@@ -554,8 +554,7 @@ static int radeon_ttm_tt_pin_userptr(str
 		uint64_t userptr = gtt->userptr + pinned * PAGE_SIZE;
 		struct page **pages = ttm->pages + pinned;
 
-		r = get_user_pages(current, current->mm, userptr, num_pages,
-				   write, 0, pages, NULL);
+		r = get_user_pages(userptr, num_pages, write, 0, pages, NULL);
 		if (r < 0)
 			goto release_pages;
 
diff -puN drivers/gpu/drm/via/via_dmablit.c~get_current_user_pages drivers/gpu/drm/via/via_dmablit.c
--- a/drivers/gpu/drm/via/via_dmablit.c~get_current_user_pages	2016-02-10 10:09:01.350332471 -0800
+++ b/drivers/gpu/drm/via/via_dmablit.c	2016-02-10 10:09:01.389334266 -0800
@@ -239,8 +239,7 @@ via_lock_all_dma_pages(drm_via_sg_info_t
 	if (NULL == vsg->pages)
 		return -ENOMEM;
 	down_read(&current->mm->mmap_sem);
-	ret = get_user_pages(current, current->mm,
-			     (unsigned long)xfer->mem_addr,
+	ret = get_user_pages((unsigned long)xfer->mem_addr,
 			     vsg->num_pages,
 			     (vsg->direction == DMA_FROM_DEVICE),
 			     0, vsg->pages, NULL);
diff -puN drivers/infiniband/core/umem.c~get_current_user_pages drivers/infiniband/core/umem.c
--- a/drivers/infiniband/core/umem.c~get_current_user_pages	2016-02-10 10:09:01.352332563 -0800
+++ b/drivers/infiniband/core/umem.c	2016-02-10 10:09:01.390334312 -0800
@@ -188,7 +188,7 @@ struct ib_umem *ib_umem_get(struct ib_uc
 	sg_list_start = umem->sg_head.sgl;
 
 	while (npages) {
-		ret = get_user_pages(current, current->mm, cur_base,
+		ret = get_user_pages(cur_base,
 				     min_t(unsigned long, npages,
 					   PAGE_SIZE / sizeof (struct page *)),
 				     1, !umem->writable, page_list, vma_list);
diff -puN drivers/infiniband/hw/mthca/mthca_memfree.c~get_current_user_pages drivers/infiniband/hw/mthca/mthca_memfree.c
--- a/drivers/infiniband/hw/mthca/mthca_memfree.c~get_current_user_pages	2016-02-10 10:09:01.354332655 -0800
+++ b/drivers/infiniband/hw/mthca/mthca_memfree.c	2016-02-10 10:09:01.390334312 -0800
@@ -472,8 +472,7 @@ int mthca_map_user_db(struct mthca_dev *
 		goto out;
 	}
 
-	ret = get_user_pages(current, current->mm, uaddr & PAGE_MASK, 1, 1, 0,
-			     pages, NULL);
+	ret = get_user_pages(uaddr & PAGE_MASK, 1, 1, 0, pages, NULL);
 	if (ret < 0)
 		goto out;
 
diff -puN drivers/infiniband/hw/qib/qib_user_pages.c~get_current_user_pages drivers/infiniband/hw/qib/qib_user_pages.c
--- a/drivers/infiniband/hw/qib/qib_user_pages.c~get_current_user_pages	2016-02-10 10:09:01.355332701 -0800
+++ b/drivers/infiniband/hw/qib/qib_user_pages.c	2016-02-10 10:09:01.391334358 -0800
@@ -66,8 +66,7 @@ static int __qib_get_user_pages(unsigned
 	}
 
 	for (got = 0; got < num_pages; got += ret) {
-		ret = get_user_pages(current, current->mm,
-				     start_page + got * PAGE_SIZE,
+		ret = get_user_pages(start_page + got * PAGE_SIZE,
 				     num_pages - got, 1, 1,
 				     p + got, NULL);
 		if (ret < 0)
diff -puN drivers/infiniband/hw/usnic/usnic_uiom.c~get_current_user_pages drivers/infiniband/hw/usnic/usnic_uiom.c
--- a/drivers/infiniband/hw/usnic/usnic_uiom.c~get_current_user_pages	2016-02-10 10:09:01.357332793 -0800
+++ b/drivers/infiniband/hw/usnic/usnic_uiom.c	2016-02-10 10:09:01.391334358 -0800
@@ -144,7 +144,7 @@ static int usnic_uiom_get_pages(unsigned
 	ret = 0;
 
 	while (npages) {
-		ret = get_user_pages(current, current->mm, cur_base,
+		ret = get_user_pages(cur_base,
 					min_t(unsigned long, npages,
 					PAGE_SIZE / sizeof(struct page *)),
 					1, !writable, page_list, NULL);
diff -puN drivers/media/pci/ivtv/ivtv-udma.c~get_current_user_pages drivers/media/pci/ivtv/ivtv-udma.c
--- a/drivers/media/pci/ivtv/ivtv-udma.c~get_current_user_pages	2016-02-10 10:09:01.359332885 -0800
+++ b/drivers/media/pci/ivtv/ivtv-udma.c	2016-02-10 10:09:01.391334358 -0800
@@ -124,8 +124,8 @@ int ivtv_udma_setup(struct ivtv *itv, un
 	}
 
 	/* Get user pages for DMA Xfer */
-	err = get_user_pages_unlocked(current, current->mm,
-			user_dma.uaddr, user_dma.page_count, 0, 1, dma->map);
+	err = get_user_pages_unlocked(user_dma.uaddr, user_dma.page_count, 0,
+			1, dma->map);
 
 	if (user_dma.page_count != err) {
 		IVTV_DEBUG_WARN("failed to map user pages, returned %d instead of %d\n",
diff -puN drivers/media/pci/ivtv/ivtv-yuv.c~get_current_user_pages drivers/media/pci/ivtv/ivtv-yuv.c
--- a/drivers/media/pci/ivtv/ivtv-yuv.c~get_current_user_pages	2016-02-10 10:09:01.361332977 -0800
+++ b/drivers/media/pci/ivtv/ivtv-yuv.c	2016-02-10 10:09:01.392334404 -0800
@@ -75,14 +75,12 @@ static int ivtv_yuv_prep_user_dma(struct
 	ivtv_udma_get_page_info (&uv_dma, (unsigned long)args->uv_source, 360 * uv_decode_height);
 
 	/* Get user pages for DMA Xfer */
-	y_pages = get_user_pages_unlocked(current, current->mm,
-				y_dma.uaddr, y_dma.page_count, 0, 1,
-				&dma->map[0]);
+	y_pages = get_user_pages_unlocked(y_dma.uaddr,
+			y_dma.page_count, 0, 1, &dma->map[0]);
 	uv_pages = 0; /* silence gcc. value is set and consumed only if: */
 	if (y_pages == y_dma.page_count) {
-		uv_pages = get_user_pages_unlocked(current, current->mm,
-					uv_dma.uaddr, uv_dma.page_count, 0, 1,
-					&dma->map[y_pages]);
+		uv_pages = get_user_pages_unlocked(uv_dma.uaddr,
+				uv_dma.page_count, 0, 1, &dma->map[y_pages]);
 	}
 
 	if (y_pages != y_dma.page_count || uv_pages != uv_dma.page_count) {
diff -puN drivers/media/v4l2-core/videobuf-dma-sg.c~get_current_user_pages drivers/media/v4l2-core/videobuf-dma-sg.c
--- a/drivers/media/v4l2-core/videobuf-dma-sg.c~get_current_user_pages	2016-02-10 10:09:01.362333023 -0800
+++ b/drivers/media/v4l2-core/videobuf-dma-sg.c	2016-02-10 10:09:01.392334404 -0800
@@ -181,8 +181,7 @@ static int videobuf_dma_init_user_locked
 	dprintk(1, "init user [0x%lx+0x%lx => %d pages]\n",
 		data, size, dma->nr_pages);
 
-	err = get_user_pages(current, current->mm,
-			     data & PAGE_MASK, dma->nr_pages,
+	err = get_user_pages(data & PAGE_MASK, dma->nr_pages,
 			     rw == READ, 1, /* force */
 			     dma->pages, NULL);
 
diff -puN drivers/misc/mic/scif/scif_rma.c~get_current_user_pages drivers/misc/mic/scif/scif_rma.c
--- a/drivers/misc/mic/scif/scif_rma.c~get_current_user_pages	2016-02-10 10:09:01.364333115 -0800
+++ b/drivers/misc/mic/scif/scif_rma.c	2016-02-10 10:09:01.393334450 -0800
@@ -1394,8 +1394,6 @@ retry:
 		}
 
 		pinned_pages->nr_pages = get_user_pages(
-				current,
-				mm,
 				(u64)addr,
 				nr_pages,
 				!!(prot & SCIF_PROT_WRITE),
diff -puN drivers/misc/sgi-gru/grufault.c~get_current_user_pages drivers/misc/sgi-gru/grufault.c
--- a/drivers/misc/sgi-gru/grufault.c~get_current_user_pages	2016-02-10 10:09:01.366333207 -0800
+++ b/drivers/misc/sgi-gru/grufault.c	2016-02-10 10:09:01.393334450 -0800
@@ -198,8 +198,7 @@ static int non_atomic_pte_lookup(struct
 #else
 	*pageshift = PAGE_SHIFT;
 #endif
-	if (get_user_pages
-	    (current, current->mm, vaddr, 1, write, 0, &page, NULL) <= 0)
+	if (get_user_pages(vaddr, 1, write, 0, &page, NULL) <= 0)
 		return -EFAULT;
 	*paddr = page_to_phys(page);
 	put_page(page);
diff -puN drivers/scsi/st.c~get_current_user_pages drivers/scsi/st.c
--- a/drivers/scsi/st.c~get_current_user_pages	2016-02-10 10:09:01.367333253 -0800
+++ b/drivers/scsi/st.c	2016-02-10 10:09:01.395334542 -0800
@@ -4817,8 +4817,6 @@ static int sgl_map_user_pages(struct st_
         /* Try to fault in all of the necessary pages */
         /* rw==READ means read from drive, write into memory area */
 	res = get_user_pages_unlocked(
-		current,
-		current->mm,
 		uaddr,
 		nr_pages,
 		rw == READ,
diff -puN drivers/video/fbdev/pvr2fb.c~get_current_user_pages drivers/video/fbdev/pvr2fb.c
--- a/drivers/video/fbdev/pvr2fb.c~get_current_user_pages	2016-02-10 10:09:01.369333345 -0800
+++ b/drivers/video/fbdev/pvr2fb.c	2016-02-10 10:09:01.395334542 -0800
@@ -686,8 +686,8 @@ static ssize_t pvr2fb_write(struct fb_in
 	if (!pages)
 		return -ENOMEM;
 
-	ret = get_user_pages_unlocked(current, current->mm, (unsigned long)buf,
-				      nr_pages, WRITE, 0, pages);
+	ret = get_user_pages_unlocked((unsigned long)buf, nr_pages, WRITE,
+			0, pages);
 
 	if (ret < nr_pages) {
 		nr_pages = ret;
diff -puN drivers/virt/fsl_hypervisor.c~get_current_user_pages drivers/virt/fsl_hypervisor.c
--- a/drivers/virt/fsl_hypervisor.c~get_current_user_pages	2016-02-10 10:09:01.371333437 -0800
+++ b/drivers/virt/fsl_hypervisor.c	2016-02-10 10:09:01.396334588 -0800
@@ -244,9 +244,8 @@ static long ioctl_memcpy(struct fsl_hv_i
 
 	/* Get the physical addresses of the source buffer */
 	down_read(&current->mm->mmap_sem);
-	num_pinned = get_user_pages(current, current->mm,
-		param.local_vaddr - lb_offset, num_pages,
-		(param.source == -1) ? READ : WRITE,
+	num_pinned = get_user_pages(param.local_vaddr - lb_offset,
+		num_pages, (param.source == -1) ? READ : WRITE,
 		0, pages, NULL);
 	up_read(&current->mm->mmap_sem);
 
diff -puN mm/frame_vector.c~get_current_user_pages mm/frame_vector.c
--- a/mm/frame_vector.c~get_current_user_pages	2016-02-10 10:09:01.373333529 -0800
+++ b/mm/frame_vector.c	2016-02-10 10:09:01.396334588 -0800
@@ -58,7 +58,7 @@ int get_vaddr_frames(unsigned long start
 	if (!(vma->vm_flags & (VM_IO | VM_PFNMAP))) {
 		vec->got_ref = true;
 		vec->is_pfns = false;
-		ret = get_user_pages_locked(current, mm, start, nr_frames,
+		ret = get_user_pages_locked(start, nr_frames,
 			write, force, (struct page **)(vec->ptrs), &locked);
 		goto out;
 	}
diff -puN mm/gup.c~get_current_user_pages mm/gup.c
--- a/mm/gup.c~get_current_user_pages	2016-02-10 10:09:01.374333576 -0800
+++ b/mm/gup.c	2016-02-10 10:09:01.397334634 -0800
@@ -936,8 +936,10 @@ long get_user_pages_remote(struct task_s
 EXPORT_SYMBOL(get_user_pages_remote);
 
 /*
- * This is the same as get_user_pages_remote() for the time
- * being.
+ * This is the same as get_user_pages_remote(), just with a
+ * less-flexible calling convention where we assume that the task
+ * and mm being operated on are the current task's.  We also
+ * obviously don't pass FOLL_REMOTE in here.
  */
 long get_user_pages6(unsigned long start, unsigned long nr_pages,
 		int write, int force, struct page **pages,
diff -puN mm/ksm.c~get_current_user_pages mm/ksm.c
--- a/mm/ksm.c~get_current_user_pages	2016-02-10 10:09:01.376333668 -0800
+++ b/mm/ksm.c	2016-02-10 10:09:01.397334634 -0800
@@ -352,7 +352,7 @@ static inline bool ksm_test_exit(struct
 /*
  * We use break_ksm to break COW on a ksm page: it's a stripped down
  *
- *	if (get_user_pages(current, mm, addr, 1, 1, 1, &page, NULL) == 1)
+ *	if (get_user_pages(addr, 1, 1, 1, &page, NULL) == 1)
  *		put_page(page);
  *
  * but taking great care only to touch a ksm page, in a VM_MERGEABLE vma,
diff -puN mm/mempolicy.c~get_current_user_pages mm/mempolicy.c
--- a/mm/mempolicy.c~get_current_user_pages	2016-02-10 10:09:01.378333760 -0800
+++ b/mm/mempolicy.c	2016-02-10 10:09:01.398334680 -0800
@@ -844,12 +844,12 @@ static void get_policy_nodemask(struct m
 	}
 }
 
-static int lookup_node(struct mm_struct *mm, unsigned long addr)
+static int lookup_node(unsigned long addr)
 {
 	struct page *p;
 	int err;
 
-	err = get_user_pages(current, mm, addr & PAGE_MASK, 1, 0, 0, &p, NULL);
+	err = get_user_pages(addr & PAGE_MASK, 1, 0, 0, &p, NULL);
 	if (err >= 0) {
 		err = page_to_nid(p);
 		put_page(p);
@@ -904,7 +904,7 @@ static long do_get_mempolicy(int *policy
 
 	if (flags & MPOL_F_NODE) {
 		if (flags & MPOL_F_ADDR) {
-			err = lookup_node(mm, addr);
+			err = lookup_node(addr);
 			if (err < 0)
 				goto out;
 			*policy = err;
diff -puN net/ceph/pagevec.c~get_current_user_pages net/ceph/pagevec.c
--- a/net/ceph/pagevec.c~get_current_user_pages	2016-02-10 10:09:01.379333806 -0800
+++ b/net/ceph/pagevec.c	2016-02-10 10:09:01.399334726 -0800
@@ -24,7 +24,7 @@ struct page **ceph_get_direct_page_vecto
 		return ERR_PTR(-ENOMEM);
 
 	while (got < num_pages) {
-		rc = get_user_pages_unlocked(current, current->mm,
+		rc = get_user_pages_unlocked(
 		    (unsigned long)data + ((unsigned long)got * PAGE_SIZE),
 		    num_pages - got, write_page, 0, pages + got);
 		if (rc < 0)
diff -puN virt/kvm/kvm_main.c~get_current_user_pages virt/kvm/kvm_main.c
--- a/virt/kvm/kvm_main.c~get_current_user_pages	2016-02-10 10:09:01.381333898 -0800
+++ b/virt/kvm/kvm_main.c	2016-02-10 10:09:01.400334772 -0800
@@ -1264,15 +1264,16 @@ unsigned long kvm_vcpu_gfn_to_hva_prot(s
 	return gfn_to_hva_memslot_prot(slot, gfn, writable);
 }
 
-static int get_user_page_nowait(struct task_struct *tsk, struct mm_struct *mm,
-	unsigned long start, int write, struct page **page)
+static int get_user_page_nowait(unsigned long start, int write,
+		struct page **page)
 {
 	int flags = FOLL_TOUCH | FOLL_NOWAIT | FOLL_HWPOISON | FOLL_GET;
 
 	if (write)
 		flags |= FOLL_WRITE;
 
-	return __get_user_pages(tsk, mm, start, 1, flags, page, NULL, NULL);
+	return __get_user_pages(current, current->mm, start, 1, flags, page,
+			NULL, NULL);
 }
 
 static inline int check_user_page_hwpoison(unsigned long addr)
@@ -1334,8 +1335,7 @@ static int hva_to_pfn_slow(unsigned long
 
 	if (async) {
 		down_read(&current->mm->mmap_sem);
-		npages = get_user_page_nowait(current, current->mm,
-					      addr, write_fault, page);
+		npages = get_user_page_nowait(addr, write_fault, page);
 		up_read(&current->mm->mmap_sem);
 	} else
 		npages = __get_user_pages_unlocked(current, current->mm, addr, 1,
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
