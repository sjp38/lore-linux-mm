Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f44.google.com (mail-pa0-f44.google.com [209.85.220.44])
	by kanga.kvack.org (Postfix) with ESMTP id D5440828DF
	for <linux-mm@kvack.org>; Fri, 29 Jan 2016 13:16:53 -0500 (EST)
Received: by mail-pa0-f44.google.com with SMTP id uo6so45838909pac.1
        for <linux-mm@kvack.org>; Fri, 29 Jan 2016 10:16:53 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id e82si25633127pfb.126.2016.01.29.10.16.45
        for <linux-mm@kvack.org>;
        Fri, 29 Jan 2016 10:16:45 -0800 (PST)
Subject: [PATCH 01/31] mm, gup: introduce concept of "foreign" get_user_pages()
From: Dave Hansen <dave@sr71.net>
Date: Fri, 29 Jan 2016 10:16:44 -0800
References: <20160129181642.98E7D468@viggo.jf.intel.com>
In-Reply-To: <20160129181642.98E7D468@viggo.jf.intel.com>
Message-Id: <20160129181644.74134A5D@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, x86@kernel.org, torvalds@linux-foundation.org, Dave Hansen <dave@sr71.net>, dave.hansen@linux.intel.com, srikar@linux.vnet.ibm.com, vbabka@suse.cz, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, aarcange@redhat.com, n-horiguchi@ah.jp.nec.com, jack@suse.cz


OK, so I've fixed up my build process to _actually_ build the
nommu code.

One of Vlastimil's comments made me go dig back in to the uprobes
code's use of get_user_pages().  I decided to change both of them
to be "foreign" accesses.

This also fixes the nommu breakage that Vlastimil noted last time.

Srikar, I'd appreciate if you can have a look at the uprobes.c
modifications, especially the comment.  I don't think this will
change any behavior, but I want to make sure the comment is
accurate.

---

From: Dave Hansen <dave.hansen@linux.intel.com>

For protection keys, we need to understand whether protections
should be enforced in software or not.  In general, we enforce
protections when working on our own task, but not when on others.
We call these "current" and "foreign" operations.

This patch introduces a new get_user_pages() variant:

	get_user_pages_foreign()

We modify the vanilla get_user_pages() so it can no longer be
used on mm/tasks other than 'current/current->mm', which is by
far the most common way it is called.  Using it makes a few of
the call sites look a bit nicer.

In other words, get_user_pages_foreign() is a replacement for
when get_user_pages() is called on non-current tsk/mm.

This also switches get_user_pages_(un)locked() over to be like
get_user_pages() and not take a tsk/mm.  There is no
get_user_pages_foreign_(un)locked().  If someone wants that
behavior they just have to use "__" variant and pass in
FOLL_FOREIGN explicitly.

The uprobes is_trap_at_addr() location holds mmap_sem and
calls get_user_pages(current->mm) on an instruction address.  This
makes it a pretty unique gup caller.  Being an instruction access
and also really originating from the kernel (vs. the app), I opted
to consider this a 'foreign' access where protection keys will not
be enforced.

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
Acked-by: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Acked-by: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Cc: jack@suse.cz
---

 b/arch/cris/arch-v32/drivers/cryptocop.c        |    8 ---
 b/arch/ia64/kernel/err_inject.c                 |    3 -
 b/arch/mips/mm/gup.c                            |    3 -
 b/arch/s390/mm/gup.c                            |    4 -
 b/arch/sh/mm/gup.c                              |    2 
 b/arch/sparc/mm/gup.c                           |    2 
 b/arch/x86/mm/gup.c                             |    2 
 b/arch/x86/mm/mpx.c                             |    4 -
 b/drivers/gpu/drm/amd/amdgpu/amdgpu_ttm.c       |    3 -
 b/drivers/gpu/drm/etnaviv/etnaviv_gem.c         |    2 
 b/drivers/gpu/drm/i915/i915_gem_userptr.c       |    2 
 b/drivers/gpu/drm/radeon/radeon_ttm.c           |    3 -
 b/drivers/gpu/drm/via/via_dmablit.c             |    3 -
 b/drivers/infiniband/core/umem.c                |    2 
 b/drivers/infiniband/core/umem_odp.c            |    8 +--
 b/drivers/infiniband/hw/mthca/mthca_memfree.c   |    3 -
 b/drivers/infiniband/hw/qib/qib_user_pages.c    |    3 -
 b/drivers/infiniband/hw/usnic/usnic_uiom.c      |    2 
 b/drivers/media/pci/ivtv/ivtv-udma.c            |    4 -
 b/drivers/media/pci/ivtv/ivtv-yuv.c             |   10 +---
 b/drivers/media/v4l2-core/videobuf-dma-sg.c     |    3 -
 b/drivers/misc/mic/scif/scif_rma.c              |    2 
 b/drivers/misc/sgi-gru/grufault.c               |    3 -
 b/drivers/scsi/st.c                             |    2 
 b/drivers/staging/rdma/ipath/ipath_user_pages.c |    3 -
 b/drivers/video/fbdev/pvr2fb.c                  |    4 -
 b/drivers/virt/fsl_hypervisor.c                 |    5 --
 b/fs/exec.c                                     |    8 ++-
 b/include/linux/mm.h                            |   21 +++++----
 b/kernel/events/uprobes.c                       |   10 +++-
 b/mm/frame_vector.c                             |    2 
 b/mm/gup.c                                      |   52 +++++++++++++++---------
 b/mm/ksm.c                                      |    2 
 b/mm/memory.c                                   |    2 
 b/mm/mempolicy.c                                |    6 +-
 b/mm/nommu.c                                    |   30 ++++++++-----
 b/mm/process_vm_access.c                        |   11 +++--
 b/mm/util.c                                     |    4 -
 b/net/ceph/pagevec.c                            |    2 
 b/security/tomoyo/domain.c                      |    9 +++-
 b/virt/kvm/async_pf.c                           |    7 ++-
 b/virt/kvm/kvm_main.c                           |   10 ++--
 42 files changed, 148 insertions(+), 123 deletions(-)

diff -puN arch/cris/arch-v32/drivers/cryptocop.c~get_current_user_pages arch/cris/arch-v32/drivers/cryptocop.c
--- a/arch/cris/arch-v32/drivers/cryptocop.c~get_current_user_pages	2016-01-28 15:52:15.767193346 -0800
+++ b/arch/cris/arch-v32/drivers/cryptocop.c	2016-01-28 15:52:15.839196647 -0800
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
--- a/arch/ia64/kernel/err_inject.c~get_current_user_pages	2016-01-28 15:52:15.769193438 -0800
+++ b/arch/ia64/kernel/err_inject.c	2016-01-28 15:52:15.840196693 -0800
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
--- a/arch/mips/mm/gup.c~get_current_user_pages	2016-01-28 15:52:15.770193483 -0800
+++ b/arch/mips/mm/gup.c	2016-01-28 15:52:15.840196693 -0800
@@ -286,8 +286,7 @@ slow_irqon:
 	start += nr << PAGE_SHIFT;
 	pages += nr;
 
-	ret = get_user_pages_unlocked(current, mm, start,
-				      (end - start) >> PAGE_SHIFT,
+	ret = get_user_pages_unlocked(start, (end - start) >> PAGE_SHIFT,
 				      write, 0, pages);
 
 	/* Have to be a bit careful with return values */
diff -puN arch/s390/mm/gup.c~get_current_user_pages arch/s390/mm/gup.c
--- a/arch/s390/mm/gup.c~get_current_user_pages	2016-01-28 15:52:15.772193575 -0800
+++ b/arch/s390/mm/gup.c	2016-01-28 15:52:15.840196693 -0800
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
--- a/arch/sh/mm/gup.c~get_current_user_pages	2016-01-28 15:52:15.773193621 -0800
+++ b/arch/sh/mm/gup.c	2016-01-28 15:52:15.841196739 -0800
@@ -257,7 +257,7 @@ slow_irqon:
 		start += nr << PAGE_SHIFT;
 		pages += nr;
 
-		ret = get_user_pages_unlocked(current, mm, start,
+		ret = get_user_pages_unlocked(start,
 			(end - start) >> PAGE_SHIFT, write, 0, pages);
 
 		/* Have to be a bit careful with return values */
diff -puN arch/sparc/mm/gup.c~get_current_user_pages arch/sparc/mm/gup.c
--- a/arch/sparc/mm/gup.c~get_current_user_pages	2016-01-28 15:52:15.775193713 -0800
+++ b/arch/sparc/mm/gup.c	2016-01-28 15:52:15.841196739 -0800
@@ -237,7 +237,7 @@ slow:
 		start += nr << PAGE_SHIFT;
 		pages += nr;
 
-		ret = get_user_pages_unlocked(current, mm, start,
+		ret = get_user_pages_unlocked(start,
 			(end - start) >> PAGE_SHIFT, write, 0, pages);
 
 		/* Have to be a bit careful with return values */
diff -puN arch/x86/mm/gup.c~get_current_user_pages arch/x86/mm/gup.c
--- a/arch/x86/mm/gup.c~get_current_user_pages	2016-01-28 15:52:15.777193804 -0800
+++ b/arch/x86/mm/gup.c	2016-01-28 15:52:15.841196739 -0800
@@ -422,7 +422,7 @@ slow_irqon:
 		start += nr << PAGE_SHIFT;
 		pages += nr;
 
-		ret = get_user_pages_unlocked(current, mm, start,
+		ret = get_user_pages_unlocked(start,
 					      (end - start) >> PAGE_SHIFT,
 					      write, 0, pages);
 
diff -puN arch/x86/mm/mpx.c~get_current_user_pages arch/x86/mm/mpx.c
--- a/arch/x86/mm/mpx.c~get_current_user_pages	2016-01-28 15:52:15.778193850 -0800
+++ b/arch/x86/mm/mpx.c	2016-01-28 15:52:15.842196785 -0800
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
--- a/drivers/gpu/drm/amd/amdgpu/amdgpu_ttm.c~get_current_user_pages	2016-01-28 15:52:15.780193942 -0800
+++ b/drivers/gpu/drm/amd/amdgpu/amdgpu_ttm.c	2016-01-28 15:52:15.842196785 -0800
@@ -518,8 +518,7 @@ static int amdgpu_ttm_tt_pin_userptr(str
 		uint64_t userptr = gtt->userptr + pinned * PAGE_SIZE;
 		struct page **pages = ttm->pages + pinned;
 
-		r = get_user_pages(current, current->mm, userptr, num_pages,
-				   write, 0, pages, NULL);
+		r = get_user_pages(userptr, num_pages, write, 0, pages, NULL);
 		if (r < 0)
 			goto release_pages;
 
diff -puN drivers/gpu/drm/etnaviv/etnaviv_gem.c~get_current_user_pages drivers/gpu/drm/etnaviv/etnaviv_gem.c
--- a/drivers/gpu/drm/etnaviv/etnaviv_gem.c~get_current_user_pages	2016-01-28 15:52:15.781193988 -0800
+++ b/drivers/gpu/drm/etnaviv/etnaviv_gem.c	2016-01-28 15:52:15.861197656 -0800
@@ -738,7 +738,7 @@ static struct page **etnaviv_gem_userptr
 
 	down_read(&mm->mmap_sem);
 	while (pinned < npages) {
-		ret = get_user_pages(task, mm, ptr, npages - pinned,
+		ret = get_user_pages_foreign(task, mm, ptr, npages - pinned,
 				     !etnaviv_obj->userptr.ro, 0,
 				     pvec + pinned, NULL);
 		if (ret < 0)
diff -puN drivers/gpu/drm/i915/i915_gem_userptr.c~get_current_user_pages drivers/gpu/drm/i915/i915_gem_userptr.c
--- a/drivers/gpu/drm/i915/i915_gem_userptr.c~get_current_user_pages	2016-01-28 15:52:15.783194080 -0800
+++ b/drivers/gpu/drm/i915/i915_gem_userptr.c	2016-01-28 15:52:15.843196830 -0800
@@ -584,7 +584,7 @@ __i915_gem_userptr_get_pages_worker(stru
 
 		down_read(&mm->mmap_sem);
 		while (pinned < npages) {
-			ret = get_user_pages(work->task, mm,
+			ret = get_user_pages_foreign(work->task, mm,
 					     obj->userptr.ptr + pinned * PAGE_SIZE,
 					     npages - pinned,
 					     !obj->userptr.read_only, 0,
diff -puN drivers/gpu/drm/radeon/radeon_ttm.c~get_current_user_pages drivers/gpu/drm/radeon/radeon_ttm.c
--- a/drivers/gpu/drm/radeon/radeon_ttm.c~get_current_user_pages	2016-01-28 15:52:15.785194171 -0800
+++ b/drivers/gpu/drm/radeon/radeon_ttm.c	2016-01-28 15:52:15.843196830 -0800
@@ -554,8 +554,7 @@ static int radeon_ttm_tt_pin_userptr(str
 		uint64_t userptr = gtt->userptr + pinned * PAGE_SIZE;
 		struct page **pages = ttm->pages + pinned;
 
-		r = get_user_pages(current, current->mm, userptr, num_pages,
-				   write, 0, pages, NULL);
+		r = get_user_pages(userptr, num_pages, write, 0, pages, NULL);
 		if (r < 0)
 			goto release_pages;
 
diff -puN drivers/gpu/drm/via/via_dmablit.c~get_current_user_pages drivers/gpu/drm/via/via_dmablit.c
--- a/drivers/gpu/drm/via/via_dmablit.c~get_current_user_pages	2016-01-28 15:52:15.786194217 -0800
+++ b/drivers/gpu/drm/via/via_dmablit.c	2016-01-28 15:52:15.844196876 -0800
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
--- a/drivers/infiniband/core/umem.c~get_current_user_pages	2016-01-28 15:52:15.788194309 -0800
+++ b/drivers/infiniband/core/umem.c	2016-01-28 15:52:15.844196876 -0800
@@ -188,7 +188,7 @@ struct ib_umem *ib_umem_get(struct ib_uc
 	sg_list_start = umem->sg_head.sgl;
 
 	while (npages) {
-		ret = get_user_pages(current, current->mm, cur_base,
+		ret = get_user_pages(cur_base,
 				     min_t(unsigned long, npages,
 					   PAGE_SIZE / sizeof (struct page *)),
 				     1, !umem->writable, page_list, vma_list);
diff -puN drivers/infiniband/core/umem_odp.c~get_current_user_pages drivers/infiniband/core/umem_odp.c
--- a/drivers/infiniband/core/umem_odp.c~get_current_user_pages	2016-01-28 15:52:15.790194400 -0800
+++ b/drivers/infiniband/core/umem_odp.c	2016-01-28 15:52:15.844196876 -0800
@@ -572,10 +572,10 @@ int ib_umem_odp_map_dma_pages(struct ib_
 		 * complex (and doesn't gain us much performance in most use
 		 * cases).
 		 */
-		npages = get_user_pages(owning_process, owning_mm, user_virt,
-					gup_num_pages,
-					access_mask & ODP_WRITE_ALLOWED_BIT, 0,
-					local_page_list, NULL);
+		npages = get_user_pages_foreign(owning_process, owning_mm,
+				user_virt, gup_num_pages,
+				access_mask & ODP_WRITE_ALLOWED_BIT,
+				0, local_page_list, NULL);
 		up_read(&owning_mm->mmap_sem);
 
 		if (npages < 0)
diff -puN drivers/infiniband/hw/mthca/mthca_memfree.c~get_current_user_pages drivers/infiniband/hw/mthca/mthca_memfree.c
--- a/drivers/infiniband/hw/mthca/mthca_memfree.c~get_current_user_pages	2016-01-28 15:52:15.791194446 -0800
+++ b/drivers/infiniband/hw/mthca/mthca_memfree.c	2016-01-28 15:52:15.845196922 -0800
@@ -472,8 +472,7 @@ int mthca_map_user_db(struct mthca_dev *
 		goto out;
 	}
 
-	ret = get_user_pages(current, current->mm, uaddr & PAGE_MASK, 1, 1, 0,
-			     pages, NULL);
+	ret = get_user_pages(uaddr & PAGE_MASK, 1, 1, 0, pages, NULL);
 	if (ret < 0)
 		goto out;
 
diff -puN drivers/infiniband/hw/qib/qib_user_pages.c~get_current_user_pages drivers/infiniband/hw/qib/qib_user_pages.c
--- a/drivers/infiniband/hw/qib/qib_user_pages.c~get_current_user_pages	2016-01-28 15:52:15.793194538 -0800
+++ b/drivers/infiniband/hw/qib/qib_user_pages.c	2016-01-28 15:52:15.845196922 -0800
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
--- a/drivers/infiniband/hw/usnic/usnic_uiom.c~get_current_user_pages	2016-01-28 15:52:15.795194630 -0800
+++ b/drivers/infiniband/hw/usnic/usnic_uiom.c	2016-01-28 15:52:15.845196922 -0800
@@ -144,7 +144,7 @@ static int usnic_uiom_get_pages(unsigned
 	ret = 0;
 
 	while (npages) {
-		ret = get_user_pages(current, current->mm, cur_base,
+		ret = get_user_pages(cur_base,
 					min_t(unsigned long, npages,
 					PAGE_SIZE / sizeof(struct page *)),
 					1, !writable, page_list, NULL);
diff -puN drivers/media/pci/ivtv/ivtv-udma.c~get_current_user_pages drivers/media/pci/ivtv/ivtv-udma.c
--- a/drivers/media/pci/ivtv/ivtv-udma.c~get_current_user_pages	2016-01-28 15:52:15.796194675 -0800
+++ b/drivers/media/pci/ivtv/ivtv-udma.c	2016-01-28 15:52:15.846196968 -0800
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
--- a/drivers/media/pci/ivtv/ivtv-yuv.c~get_current_user_pages	2016-01-28 15:52:15.798194767 -0800
+++ b/drivers/media/pci/ivtv/ivtv-yuv.c	2016-01-28 15:52:15.846196968 -0800
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
--- a/drivers/media/v4l2-core/videobuf-dma-sg.c~get_current_user_pages	2016-01-28 15:52:15.800194859 -0800
+++ b/drivers/media/v4l2-core/videobuf-dma-sg.c	2016-01-28 15:52:15.847197014 -0800
@@ -181,8 +181,7 @@ static int videobuf_dma_init_user_locked
 	dprintk(1, "init user [0x%lx+0x%lx => %d pages]\n",
 		data, size, dma->nr_pages);
 
-	err = get_user_pages(current, current->mm,
-			     data & PAGE_MASK, dma->nr_pages,
+	err = get_user_pages(data & PAGE_MASK, dma->nr_pages,
 			     rw == READ, 1, /* force */
 			     dma->pages, NULL);
 
diff -puN drivers/misc/mic/scif/scif_rma.c~get_current_user_pages drivers/misc/mic/scif/scif_rma.c
--- a/drivers/misc/mic/scif/scif_rma.c~get_current_user_pages	2016-01-28 15:52:15.801194905 -0800
+++ b/drivers/misc/mic/scif/scif_rma.c	2016-01-28 15:52:15.847197014 -0800
@@ -1394,8 +1394,6 @@ retry:
 		}
 
 		pinned_pages->nr_pages = get_user_pages(
-				current,
-				mm,
 				(u64)addr,
 				nr_pages,
 				!!(prot & SCIF_PROT_WRITE),
diff -puN drivers/misc/sgi-gru/grufault.c~get_current_user_pages drivers/misc/sgi-gru/grufault.c
--- a/drivers/misc/sgi-gru/grufault.c~get_current_user_pages	2016-01-28 15:52:15.803194997 -0800
+++ b/drivers/misc/sgi-gru/grufault.c	2016-01-28 15:52:15.848197060 -0800
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
--- a/drivers/scsi/st.c~get_current_user_pages	2016-01-28 15:52:15.805195088 -0800
+++ b/drivers/scsi/st.c	2016-01-28 15:52:15.849197105 -0800
@@ -4817,8 +4817,6 @@ static int sgl_map_user_pages(struct st_
         /* Try to fault in all of the necessary pages */
         /* rw==READ means read from drive, write into memory area */
 	res = get_user_pages_unlocked(
-		current,
-		current->mm,
 		uaddr,
 		nr_pages,
 		rw == READ,
diff -puN drivers/staging/rdma/ipath/ipath_user_pages.c~get_current_user_pages drivers/staging/rdma/ipath/ipath_user_pages.c
--- a/drivers/staging/rdma/ipath/ipath_user_pages.c~get_current_user_pages	2016-01-28 15:52:15.806195134 -0800
+++ b/drivers/staging/rdma/ipath/ipath_user_pages.c	2016-01-28 15:52:15.850197151 -0800
@@ -70,8 +70,7 @@ static int __ipath_get_user_pages(unsign
 		   (unsigned long) num_pages, start_page);
 
 	for (got = 0; got < num_pages; got += ret) {
-		ret = get_user_pages(current, current->mm,
-				     start_page + got * PAGE_SIZE,
+		ret = get_user_pages(start_page + got * PAGE_SIZE,
 				     num_pages - got, 1, 1,
 				     p + got, NULL);
 		if (ret < 0)
diff -puN drivers/video/fbdev/pvr2fb.c~get_current_user_pages drivers/video/fbdev/pvr2fb.c
--- a/drivers/video/fbdev/pvr2fb.c~get_current_user_pages	2016-01-28 15:52:15.808195226 -0800
+++ b/drivers/video/fbdev/pvr2fb.c	2016-01-28 15:52:15.850197151 -0800
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
--- a/drivers/virt/fsl_hypervisor.c~get_current_user_pages	2016-01-28 15:52:15.810195317 -0800
+++ b/drivers/virt/fsl_hypervisor.c	2016-01-28 15:52:15.851197197 -0800
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
 
diff -puN fs/exec.c~get_current_user_pages fs/exec.c
--- a/fs/exec.c~get_current_user_pages	2016-01-28 15:52:15.811195363 -0800
+++ b/fs/exec.c	2016-01-28 15:52:15.851197197 -0800
@@ -198,8 +198,12 @@ static struct page *get_arg_page(struct
 			return NULL;
 	}
 #endif
-	ret = get_user_pages(current, bprm->mm, pos,
-			1, write, 1, &page, NULL);
+	/*
+	 * We are doing an exec().  'current' is the process
+	 * doing the exec and bprm->mm is the new process's mm.
+	 */
+	ret = get_user_pages_foreign(current, bprm->mm, pos, 1, write,
+			1, &page, NULL);
 	if (ret <= 0)
 		return NULL;
 
diff -puN include/linux/mm.h~get_current_user_pages include/linux/mm.h
--- a/include/linux/mm.h~get_current_user_pages	2016-01-28 15:52:15.813195455 -0800
+++ b/include/linux/mm.h	2016-01-28 15:52:15.852197243 -0800
@@ -1223,20 +1223,20 @@ long __get_user_pages(struct task_struct
 		      unsigned long start, unsigned long nr_pages,
 		      unsigned int foll_flags, struct page **pages,
 		      struct vm_area_struct **vmas, int *nonblocking);
-long get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
-		    unsigned long start, unsigned long nr_pages,
-		    int write, int force, struct page **pages,
-		    struct vm_area_struct **vmas);
-long get_user_pages_locked(struct task_struct *tsk, struct mm_struct *mm,
-		    unsigned long start, unsigned long nr_pages,
-		    int write, int force, struct page **pages,
-		    int *locked);
+long get_user_pages_foreign(struct task_struct *tsk, struct mm_struct *mm,
+			    unsigned long start, unsigned long nr_pages,
+			    int write, int force, struct page **pages,
+			    struct vm_area_struct **vmas);
+long get_user_pages(unsigned long start, unsigned long nr_pages,
+			    int write, int force, struct page **pages,
+			    struct vm_area_struct **vmas);
+long get_user_pages_locked(unsigned long start, unsigned long nr_pages,
+		    int write, int force, struct page **pages, int *locked);
 long __get_user_pages_unlocked(struct task_struct *tsk, struct mm_struct *mm,
 			       unsigned long start, unsigned long nr_pages,
 			       int write, int force, struct page **pages,
 			       unsigned int gup_flags);
-long get_user_pages_unlocked(struct task_struct *tsk, struct mm_struct *mm,
-		    unsigned long start, unsigned long nr_pages,
+long get_user_pages_unlocked(unsigned long start, unsigned long nr_pages,
 		    int write, int force, struct page **pages);
 int get_user_pages_fast(unsigned long start, int nr_pages, int write,
 			struct page **pages);
@@ -2167,6 +2167,7 @@ static inline struct page *follow_page(s
 #define FOLL_MIGRATION	0x400	/* wait for page to replace migration entry */
 #define FOLL_TRIED	0x800	/* a retry, previous pass started an IO */
 #define FOLL_MLOCK	0x1000	/* lock present pages */
+#define FOLL_FOREIGN	0x2000	/* we are working on non-current tsk/mm */
 
 typedef int (*pte_fn_t)(pte_t *pte, pgtable_t token, unsigned long addr,
 			void *data);
diff -puN kernel/events/uprobes.c~get_current_user_pages kernel/events/uprobes.c
--- a/kernel/events/uprobes.c~get_current_user_pages	2016-01-28 15:52:15.815195547 -0800
+++ b/kernel/events/uprobes.c	2016-01-28 15:52:15.853197289 -0800
@@ -299,7 +299,7 @@ int uprobe_write_opcode(struct mm_struct
 
 retry:
 	/* Read the page with vaddr into memory */
-	ret = get_user_pages(NULL, mm, vaddr, 1, 0, 1, &old_page, &vma);
+	ret = get_user_pages_foreign(NULL, mm, vaddr, 1, 0, 1, &old_page, &vma);
 	if (ret <= 0)
 		return ret;
 
@@ -1700,7 +1700,13 @@ static int is_trap_at_addr(struct mm_str
 	if (likely(result == 0))
 		goto out;
 
-	result = get_user_pages(NULL, mm, vaddr, 1, 0, 1, &page, NULL);
+	/*
+	 * The NULL 'tsk' here ensures that any faults that occur here
+	 * will not be accounted to the task.  'mm' *is* current->mm,
+	 * but we treat this as a 'foreign' access since it is
+	 * essentially a kernel access to the memory.
+	 */
+	result = get_user_pages_foreign(NULL, mm, vaddr, 1, 0, 1, &page, NULL);
 	if (result < 0)
 		return result;
 
diff -puN mm/frame_vector.c~get_current_user_pages mm/frame_vector.c
--- a/mm/frame_vector.c~get_current_user_pages	2016-01-28 15:52:15.816195592 -0800
+++ b/mm/frame_vector.c	2016-01-28 15:52:15.853197289 -0800
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
--- a/mm/gup.c~get_current_user_pages	2016-01-28 15:52:15.818195684 -0800
+++ b/mm/gup.c	2016-01-28 15:52:15.854197335 -0800
@@ -797,7 +797,7 @@ static __always_inline long __get_user_p
  *
  *      down_read(&mm->mmap_sem);
  *      do_something()
- *      get_user_pages(tsk, mm, ..., pages, NULL);
+ *      get_user_pages(..., pages, NULL);
  *      up_read(&mm->mmap_sem);
  *
  *  to:
@@ -809,13 +809,13 @@ static __always_inline long __get_user_p
  *      if (locked)
  *          up_read(&mm->mmap_sem);
  */
-long get_user_pages_locked(struct task_struct *tsk, struct mm_struct *mm,
-			   unsigned long start, unsigned long nr_pages,
+long get_user_pages_locked(unsigned long start, unsigned long nr_pages,
 			   int write, int force, struct page **pages,
 			   int *locked)
 {
-	return __get_user_pages_locked(tsk, mm, start, nr_pages, write, force,
-				       pages, NULL, locked, true, FOLL_TOUCH);
+	return __get_user_pages_locked(current, current->mm, start, nr_pages,
+				       write, force, pages, NULL, locked, true,
+				       FOLL_TOUCH);
 }
 EXPORT_SYMBOL(get_user_pages_locked);
 
@@ -849,7 +849,7 @@ EXPORT_SYMBOL(__get_user_pages_unlocked)
  * get_user_pages_unlocked() is suitable to replace the form:
  *
  *      down_read(&mm->mmap_sem);
- *      get_user_pages(tsk, mm, ..., pages, NULL);
+ *      get_user_pages(..., pages, NULL);
  *      up_read(&mm->mmap_sem);
  *
  *  with:
@@ -862,17 +862,16 @@ EXPORT_SYMBOL(__get_user_pages_unlocked)
  * or if "force" shall be set to 1 (get_user_pages_fast misses the
  * "force" parameter).
  */
-long get_user_pages_unlocked(struct task_struct *tsk, struct mm_struct *mm,
-			     unsigned long start, unsigned long nr_pages,
+long get_user_pages_unlocked(unsigned long start, unsigned long nr_pages,
 			     int write, int force, struct page **pages)
 {
-	return __get_user_pages_unlocked(tsk, mm, start, nr_pages, write,
-					 force, pages, FOLL_TOUCH);
+	return __get_user_pages_unlocked(current, current->mm, start, nr_pages,
+					 write, force, pages, FOLL_TOUCH);
 }
 EXPORT_SYMBOL(get_user_pages_unlocked);
 
 /*
- * get_user_pages() - pin user pages in memory
+ * get_user_pages_foreign() - pin user pages in memory
  * @tsk:	the task_struct to use for page fault accounting, or
  *		NULL if faults are not to be recorded.
  * @mm:		mm_struct of target mm
@@ -926,12 +925,30 @@ EXPORT_SYMBOL(get_user_pages_unlocked);
  * should use get_user_pages because it cannot pass
  * FAULT_FLAG_ALLOW_RETRY to handle_mm_fault.
  */
-long get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
-		unsigned long start, unsigned long nr_pages, int write,
-		int force, struct page **pages, struct vm_area_struct **vmas)
+long get_user_pages_foreign(struct task_struct *tsk, struct mm_struct *mm,
+		unsigned long start, unsigned long nr_pages,
+		int write, int force, struct page **pages,
+		struct vm_area_struct **vmas)
 {
 	return __get_user_pages_locked(tsk, mm, start, nr_pages, write, force,
-				       pages, vmas, NULL, false, FOLL_TOUCH);
+				       pages, vmas, NULL, false,
+				       FOLL_TOUCH | FOLL_FOREIGN);
+}
+EXPORT_SYMBOL(get_user_pages_foreign);
+
+/*
+ * This is the same as get_user_pages_foreign(), just with a
+ * less-flexible calling convention where we assume that the task
+ * and mm being operated on are the current task's.  We also
+ * obviously don't pass FOLL_FOREIGN in here.
+ */
+long get_user_pages(unsigned long start, unsigned long nr_pages,
+		int write, int force, struct page **pages,
+		struct vm_area_struct **vmas)
+{
+	return __get_user_pages_locked(current, current->mm, start, nr_pages,
+				       write, force, pages, vmas, NULL, false,
+				       FOLL_TOUCH);
 }
 EXPORT_SYMBOL(get_user_pages);
 
@@ -1441,7 +1458,6 @@ int __get_user_pages_fast(unsigned long
 int get_user_pages_fast(unsigned long start, int nr_pages, int write,
 			struct page **pages)
 {
-	struct mm_struct *mm = current->mm;
 	int nr, ret;
 
 	start &= PAGE_MASK;
@@ -1453,8 +1469,8 @@ int get_user_pages_fast(unsigned long st
 		start += nr << PAGE_SHIFT;
 		pages += nr;
 
-		ret = get_user_pages_unlocked(current, mm, start,
-					      nr_pages - nr, write, 0, pages);
+		ret = get_user_pages_unlocked(start, nr_pages - nr, write, 0,
+					      pages);
 
 		/* Have to be a bit careful with return values */
 		if (nr > 0) {
diff -puN mm/ksm.c~get_current_user_pages mm/ksm.c
--- a/mm/ksm.c~get_current_user_pages	2016-01-28 15:52:15.820195776 -0800
+++ b/mm/ksm.c	2016-01-28 15:52:15.855197380 -0800
@@ -352,7 +352,7 @@ static inline bool ksm_test_exit(struct
 /*
  * We use break_ksm to break COW on a ksm page: it's a stripped down
  *
- *	if (get_user_pages(current, mm, addr, 1, 1, 1, &page, NULL) == 1)
+ *	if (get_user_pages(addr, 1, 1, 1, &page, NULL) == 1)
  *		put_page(page);
  *
  * but taking great care only to touch a ksm page, in a VM_MERGEABLE vma,
diff -puN mm/memory.c~get_current_user_pages mm/memory.c
--- a/mm/memory.c~get_current_user_pages	2016-01-28 15:52:15.821195822 -0800
+++ b/mm/memory.c	2016-01-28 15:52:15.856197426 -0800
@@ -3664,7 +3664,7 @@ static int __access_remote_vm(struct tas
 		void *maddr;
 		struct page *page = NULL;
 
-		ret = get_user_pages(tsk, mm, addr, 1,
+		ret = get_user_pages_foreign(tsk, mm, addr, 1,
 				write, 1, &page, &vma);
 		if (ret <= 0) {
 #ifndef CONFIG_HAVE_IOREMAP_PROT
diff -puN mm/mempolicy.c~get_current_user_pages mm/mempolicy.c
--- a/mm/mempolicy.c~get_current_user_pages	2016-01-28 15:52:15.823195913 -0800
+++ b/mm/mempolicy.c	2016-01-28 15:52:15.857197472 -0800
@@ -848,12 +848,12 @@ static void get_policy_nodemask(struct m
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
@@ -908,7 +908,7 @@ static long do_get_mempolicy(int *policy
 
 	if (flags & MPOL_F_NODE) {
 		if (flags & MPOL_F_ADDR) {
-			err = lookup_node(mm, addr);
+			err = lookup_node(addr);
 			if (err < 0)
 				goto out;
 			*policy = err;
diff -puN mm/nommu.c~get_current_user_pages mm/nommu.c
--- a/mm/nommu.c~get_current_user_pages	2016-01-28 15:52:15.825196005 -0800
+++ b/mm/nommu.c	2016-01-28 15:52:15.857197472 -0800
@@ -182,7 +182,7 @@ finish_or_fault:
  *   slab page or a secondary page from a compound page
  * - don't permit access to VMAs that don't support it, such as I/O mappings
  */
-long get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
+long get_user_pages_foreign(struct task_struct *tsk, struct mm_struct *mm,
 		    unsigned long start, unsigned long nr_pages,
 		    int write, int force, struct page **pages,
 		    struct vm_area_struct **vmas)
@@ -197,18 +197,25 @@ long get_user_pages(struct task_struct *
 	return __get_user_pages(tsk, mm, start, nr_pages, flags, pages, vmas,
 				NULL);
 }
-EXPORT_SYMBOL(get_user_pages);
+EXPORT_SYMBOL(get_user_pages_foreign);
 
-long get_user_pages_locked(struct task_struct *tsk, struct mm_struct *mm,
-			   unsigned long start, unsigned long nr_pages,
+long get_user_pages_locked(unsigned long start, unsigned long nr_pages,
 			   int write, int force, struct page **pages,
 			   int *locked)
 {
-	return get_user_pages(tsk, mm, start, nr_pages, write, force,
-			      pages, NULL);
+	return get_user_pages(start, nr_pages, write, force, pages, NULL);
 }
 EXPORT_SYMBOL(get_user_pages_locked);
 
+long get_user_pages(unsigned long start, unsigned long nr_pages,
+		    int write, int force, struct page **pages,
+		    struct vm_area_struct **vmas)
+{
+	return get_user_pages_foreign(current, current->mm, start, nr_pages,
+				      write, force, pages, vmas);
+}
+EXPORT_SYMBOL(get_user_pages);
+
 long __get_user_pages_unlocked(struct task_struct *tsk, struct mm_struct *mm,
 			       unsigned long start, unsigned long nr_pages,
 			       int write, int force, struct page **pages,
@@ -216,19 +223,18 @@ long __get_user_pages_unlocked(struct ta
 {
 	long ret;
 	down_read(&mm->mmap_sem);
-	ret = get_user_pages(tsk, mm, start, nr_pages, write, force,
-			     pages, NULL);
+	ret = __get_user_pages(tsk, mm, start, nr_pages, gup_flags, pages,
+			NULL, NULL);
 	up_read(&mm->mmap_sem);
 	return ret;
 }
 EXPORT_SYMBOL(__get_user_pages_unlocked);
 
-long get_user_pages_unlocked(struct task_struct *tsk, struct mm_struct *mm,
-			     unsigned long start, unsigned long nr_pages,
+long get_user_pages_unlocked(unsigned long start, unsigned long nr_pages,
 			     int write, int force, struct page **pages)
 {
-	return __get_user_pages_unlocked(tsk, mm, start, nr_pages, write,
-					 force, pages, 0);
+	return __get_user_pages_unlocked(current, current->mm, start, nr_pages,
+					 write, force, pages, 0);
 }
 EXPORT_SYMBOL(get_user_pages_unlocked);
 
diff -puN mm/process_vm_access.c~get_current_user_pages mm/process_vm_access.c
--- a/mm/process_vm_access.c~get_current_user_pages	2016-01-28 15:52:15.827196097 -0800
+++ b/mm/process_vm_access.c	2016-01-28 15:52:15.858197518 -0800
@@ -98,9 +98,14 @@ static int process_vm_rw_single_vec(unsi
 		int pages = min(nr_pages, max_pages_per_loop);
 		size_t bytes;
 
-		/* Get the pages we're interested in */
-		pages = get_user_pages_unlocked(task, mm, pa, pages,
-						vm_write, 0, process_pages);
+		/*
+		 * Get the pages we're interested in.  We must
+		 * add FOLL_FOREIGN because task/mm might not
+		 * current/current->mm
+		 */
+		pages = __get_user_pages_unlocked(task, mm, pa, pages,
+						  vm_write, 0, process_pages,
+						  FOLL_FOREIGN);
 		if (pages <= 0)
 			return -EFAULT;
 
diff -puN mm/util.c~get_current_user_pages mm/util.c
--- a/mm/util.c~get_current_user_pages	2016-01-28 15:52:15.828196143 -0800
+++ b/mm/util.c	2016-01-28 15:52:15.858197518 -0800
@@ -308,9 +308,7 @@ EXPORT_SYMBOL_GPL(__get_user_pages_fast)
 int __weak get_user_pages_fast(unsigned long start,
 				int nr_pages, int write, struct page **pages)
 {
-	struct mm_struct *mm = current->mm;
-	return get_user_pages_unlocked(current, mm, start, nr_pages,
-				       write, 0, pages);
+	return get_user_pages_unlocked(start, nr_pages, write, 0, pages);
 }
 EXPORT_SYMBOL_GPL(get_user_pages_fast);
 
diff -puN net/ceph/pagevec.c~get_current_user_pages net/ceph/pagevec.c
--- a/net/ceph/pagevec.c~get_current_user_pages	2016-01-28 15:52:15.830196234 -0800
+++ b/net/ceph/pagevec.c	2016-01-28 15:52:15.858197518 -0800
@@ -24,7 +24,7 @@ struct page **ceph_get_direct_page_vecto
 		return ERR_PTR(-ENOMEM);
 
 	while (got < num_pages) {
-		rc = get_user_pages_unlocked(current, current->mm,
+		rc = get_user_pages_unlocked(
 		    (unsigned long)data + ((unsigned long)got * PAGE_SIZE),
 		    num_pages - got, write_page, 0, pages + got);
 		if (rc < 0)
diff -puN security/tomoyo/domain.c~get_current_user_pages security/tomoyo/domain.c
--- a/security/tomoyo/domain.c~get_current_user_pages	2016-01-28 15:52:15.832196326 -0800
+++ b/security/tomoyo/domain.c	2016-01-28 15:52:15.859197564 -0800
@@ -874,7 +874,14 @@ bool tomoyo_dump_page(struct linux_binpr
 	}
 	/* Same with get_arg_page(bprm, pos, 0) in fs/exec.c */
 #ifdef CONFIG_MMU
-	if (get_user_pages(current, bprm->mm, pos, 1, 0, 1, &page, NULL) <= 0)
+	/*
+	 * This is called at execve() time in order to dig around
+	 * in the argv/environment of the new proceess
+	 * (represented by bprm).  'current' is the process doing
+	 * the execve().
+	 */
+	if (get_user_pages_foreign(current, bprm->mm, pos, 1,
+				0, 1, &page, NULL) <= 0)
 		return false;
 #else
 	page = bprm->page[pos / PAGE_SIZE];
diff -puN virt/kvm/async_pf.c~get_current_user_pages virt/kvm/async_pf.c
--- a/virt/kvm/async_pf.c~get_current_user_pages	2016-01-28 15:52:15.833196372 -0800
+++ b/virt/kvm/async_pf.c	2016-01-28 15:52:15.859197564 -0800
@@ -79,7 +79,12 @@ static void async_pf_execute(struct work
 
 	might_sleep();
 
-	get_user_pages_unlocked(NULL, mm, addr, 1, 1, 0, NULL);
+	/*
+	 * This work is run asynchromously to the task which owns
+	 * mm and might be done in another context, so we must
+	 * use FOLL_FOREIGN.
+	 */
+	__get_user_pages_unlocked(NULL, mm, addr, 1, 1, 0, NULL, FOLL_FOREIGN);
 	kvm_async_page_present_sync(vcpu, apf);
 
 	spin_lock(&vcpu->async_pf.lock);
diff -puN virt/kvm/kvm_main.c~get_current_user_pages virt/kvm/kvm_main.c
--- a/virt/kvm/kvm_main.c~get_current_user_pages	2016-01-28 15:52:15.835196463 -0800
+++ b/virt/kvm/kvm_main.c	2016-01-28 15:52:15.860197610 -0800
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
