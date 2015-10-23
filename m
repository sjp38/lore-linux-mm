Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f170.google.com (mail-ig0-f170.google.com [209.85.213.170])
	by kanga.kvack.org (Postfix) with ESMTP id C84746B0038
	for <linux-mm@kvack.org>; Thu, 22 Oct 2015 20:49:40 -0400 (EDT)
Received: by igbni9 with SMTP id ni9so25399385igb.1
        for <linux-mm@kvack.org>; Thu, 22 Oct 2015 17:49:40 -0700 (PDT)
Received: from blackbird.sr71.net (www.sr71.net. [198.145.64.142])
        by mx.google.com with ESMTP id q14si13516639ioi.12.2015.10.22.17.49.38
        for <linux-mm@kvack.org>;
        Thu, 22 Oct 2015 17:49:38 -0700 (PDT)
Subject: Re: [PATCH 15/25] x86, pkeys: check VMAs and PTEs for protection keys
References: <20150928191817.035A64E2@viggo.jf.intel.com>
 <20150928191823.CAE64CF3@viggo.jf.intel.com>
 <20151022205746.GA3045@gmail.com> <562953BC.9070003@sr71.net>
 <20151022222515.GA3511@gmail.com>
From: Dave Hansen <dave@sr71.net>
Message-ID: <56298420.303@sr71.net>
Date: Thu, 22 Oct 2015 17:49:36 -0700
MIME-Version: 1.0
In-Reply-To: <20151022222515.GA3511@gmail.com>
Content-Type: multipart/mixed;
 boundary="------------010102080708010602030104"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jerome Glisse <j.glisse@gmail.com>
Cc: borntraeger@de.ibm.com, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, dave.hansen@linux.intel.com

This is a multi-part message in MIME format.
--------------010102080708010602030104
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit

On 10/22/2015 03:25 PM, Jerome Glisse wrote:
> On Thu, Oct 22, 2015 at 02:23:08PM -0700, Dave Hansen wrote:
...
>> Can you give an example of where a process might be doing a gup and it
>> is completely separate from the CPU context that it's being executed under?
> 
> In drivers/iommu/amd_iommu_v2.c thought this is on AMD platform. I also
> believe that in infiniband one can have GUP call from workqueue that can
> run at any time. In GPU driver we also use GUP thought at this point we
> do not allow another process from accessing a buffer that is populated
> by GUP from another process.

>From quick grepping, there are only a couple of callers that do
get_user_pages() on something that isn't current->mm.

We can fairly easily introduce something new, like

	get_foreign_user_pages()

That sets a flag to tell us to ignore the current PKRU state.

I've attached a patch that at creates a variant of get_user_pages() for
when you're going after another process's mm.  This even makes a few of
the gup call sites look nicer because they're not passing 'current,
current->mm'.

>>> So as first i would just allow GUP to always work and then come up with
>>> syscall to allow to set pkey on device file. This obviously is a lot more
>>> work as you need to go over all device driver using GUP.
>>
>> I wouldn't be opposed to adding some context to the thread (like
>> pagefault_disable()) that indicates whether we should enforce protection
>> keys.  If we are in some asynchronous context, disassociated from the
>> running CPU's protection keys, we could set a flag.
> 
> I was simply thinking of having a global set of pkeys against the process
> mm struct which would be the default global setting for all device GUP
> access. This global set could be override by userspace on a per device
> basis allowing some device to have more access than others.

For now, I think leaving it permissive by default is probably OK.  A
device's access to memory is permissive after a gup anyway.

As you note, doing this is going to require another whole set of user
interfaces, so I'd rather revisit it later once we have a more concrete
need for it.

1. Store a common PKRU value somewhere and activate when servicing work
   outside of the context of the actual process.  Set this PKRU value
   with input from userspace and new user APIs.
2. When work is queued, copy the PKRU value and use it while servicing
   the work.
3. Do all out-of-context work with PKRU=0, or by disabling the PKRU
   checks conditionally.

>> I'd really appreciate if you could point to some concrete examples here
>> which could actually cause a problem, like workqueues doing gups.
> 
> Well i could grep for all current user of GUP, but i can tell you that this
> is gonna be the model for GPU thread ie a kernel workqueue gonna handle
> page fault on behalf of GPU and will perform equivalent of GUP. Also apply
> for infiniband ODP thing which is upstream.



--------------010102080708010602030104
Content-Type: text/x-patch;
 name="get_current_user_pages.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="get_current_user_pages.patch"



---

 b/arch/x86/mm/mpx.c                           |    4 +-
 b/drivers/gpu/drm/amd/amdgpu/amdgpu_ttm.c     |    4 +-
 b/drivers/gpu/drm/i915/i915_gem_userptr.c     |    2 -
 b/drivers/gpu/drm/radeon/radeon_ttm.c         |    4 +-
 b/drivers/gpu/drm/via/via_dmablit.c           |    3 --
 b/drivers/infiniband/core/umem.c              |    2 -
 b/drivers/infiniband/core/umem_odp.c          |    8 ++---
 b/drivers/infiniband/hw/mthca/mthca_memfree.c |    3 --
 b/drivers/infiniband/hw/qib/qib_user_pages.c  |    3 --
 b/drivers/infiniband/hw/usnic/usnic_uiom.c    |    2 -
 b/drivers/media/pci/ivtv/ivtv-yuv.c           |    8 ++---
 b/drivers/media/v4l2-core/videobuf-dma-sg.c   |    3 --
 b/drivers/virt/fsl_hypervisor.c               |    5 +--
 b/fs/exec.c                                   |    8 ++++-
 b/include/linux/mm.h                          |   14 +++++----
 b/mm/frame_vector.c                           |    2 -
 b/mm/gup.c                                    |   39 ++++++++++++++++++++------
 b/mm/mempolicy.c                              |    6 ++--
 b/security/tomoyo/domain.c                    |    9 +++++-
 19 files changed, 79 insertions(+), 50 deletions(-)

diff -puN mm/gup.c~get_current_user_pages mm/gup.c
--- a/mm/gup.c~get_current_user_pages	2015-10-22 16:03:24.957026355 -0700
+++ b/mm/gup.c	2015-10-22 16:46:58.181109179 -0700
@@ -752,11 +752,12 @@ EXPORT_SYMBOL(get_user_pages_locked);
  * according to the parameters "pages", "write", "force"
  * respectively.
  */
-__always_inline long __get_user_pages_unlocked(struct task_struct *tsk, struct mm_struct *mm,
-					       unsigned long start, unsigned long nr_pages,
+__always_inline long __get_user_pages_unlocked(unsigned long start, unsigned long nr_pages,
 					       int write, int force, struct page **pages,
 					       unsigned int gup_flags)
 {
+	struct task_struct *tsk = curent;
+	struct mm_struct *mm = tsk->mm
 	long ret;
 	int locked = 1;
 	down_read(&mm->mmap_sem);
@@ -795,7 +796,7 @@ long get_user_pages_unlocked(struct task
 EXPORT_SYMBOL(get_user_pages_unlocked);
 
 /*
- * get_user_pages() - pin user pages in memory
+ * get_foreign_user_pages() - pin user pages in memory
  * @tsk:	the task_struct to use for page fault accounting, or
  *		NULL if faults are not to be recorded.
  * @mm:		mm_struct of target mm
@@ -849,14 +850,34 @@ EXPORT_SYMBOL(get_user_pages_unlocked);
  * should use get_user_pages because it cannot pass
  * FAULT_FLAG_ALLOW_RETRY to handle_mm_fault.
  */
-long get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
-		unsigned long start, unsigned long nr_pages, int write,
-		int force, struct page **pages, struct vm_area_struct **vmas)
+long get_foreign_user_pages(struct task_struct *tsk, struct mm_struct *mm,
+		unsigned long start, unsigned long nr_pages,
+		int write, int force, struct page **pages,
+		struct vm_area_struct **vmas)
 {
-	return __get_user_pages_locked(tsk, mm, start, nr_pages, write, force,
-				       pages, vmas, NULL, false, FOLL_TOUCH);
+	/* disable protection key checks */
+	ret = __get_user_pages_locked(tsk, mm,
+				      start, nr_pages, write, force,
+				      pages, vmas, NULL, false, FOLL_TOUCH);
+	/* enable protection key checks */
+	return ret;
+}
+EXPORT_SYMBOL(get_current_user_pages);
+
+/*
+ * This is exactly the same as get_foreign_user_pages(), just
+ * with a less-flexible calling convention where we assume that
+ * the task and mm being operated on are the current task's.
+ */
+long get_current_user_pages(unsigned long start, unsigned long nr_pages,
+		int write, int force, struct page **pages,
+		struct vm_area_struct **vmas)
+{
+	return get_foreign_user_pages(current, current->mm,
+				      start, nr_pages, write, force,
+				      pages, vmas, NULL, false, FOLL_TOUCH);
 }
-EXPORT_SYMBOL(get_user_pages);
+EXPORT_SYMBOL(get_current_user_pages);
 
 /**
  * populate_vma_page_range() -  populate a range of pages in the vma.
diff -puN arch/x86/mm/mpx.c~get_current_user_pages arch/x86/mm/mpx.c
--- a/arch/x86/mm/mpx.c~get_current_user_pages	2015-10-22 16:04:18.711461016 -0700
+++ b/arch/x86/mm/mpx.c	2015-10-22 16:04:33.661138119 -0700
@@ -546,8 +546,8 @@ static int mpx_resolve_fault(long __user
 	int nr_pages = 1;
 	int force = 0;
 
-	gup_ret = get_user_pages(current, current->mm, (unsigned long)addr,
-				 nr_pages, write, force, NULL, NULL);
+	gup_ret = get_current_user_pages((unsigned long)addr, nr_pages, write,
+			force, NULL, NULL);
 	/*
 	 * get_user_pages() returns number of pages gotten.
 	 * 0 means we failed to fault in and get anything,
diff -puN drivers/gpu/drm/amd/amdgpu/amdgpu_ttm.c~get_current_user_pages drivers/gpu/drm/amd/amdgpu/amdgpu_ttm.c
--- a/drivers/gpu/drm/amd/amdgpu/amdgpu_ttm.c~get_current_user_pages	2015-10-22 16:04:35.800235003 -0700
+++ b/drivers/gpu/drm/amd/amdgpu/amdgpu_ttm.c	2015-10-22 16:04:52.116974022 -0700
@@ -518,8 +518,8 @@ static int amdgpu_ttm_tt_pin_userptr(str
 		uint64_t userptr = gtt->userptr + pinned * PAGE_SIZE;
 		struct page **pages = ttm->pages + pinned;
 
-		r = get_user_pages(current, current->mm, userptr, num_pages,
-				   write, 0, pages, NULL);
+		r = get_current_user_pages(userptr, num_pages, write, 0, pages,
+				NULL);
 		if (r < 0)
 			goto release_pages;
 
diff -puN drivers/gpu/drm/radeon/radeon_ttm.c~get_current_user_pages drivers/gpu/drm/radeon/radeon_ttm.c
--- a/drivers/gpu/drm/radeon/radeon_ttm.c~get_current_user_pages	2015-10-22 16:04:53.241024932 -0700
+++ b/drivers/gpu/drm/radeon/radeon_ttm.c	2015-10-22 16:05:04.892552652 -0700
@@ -554,8 +554,8 @@ static int radeon_ttm_tt_pin_userptr(str
 		uint64_t userptr = gtt->userptr + pinned * PAGE_SIZE;
 		struct page **pages = ttm->pages + pinned;
 
-		r = get_user_pages(current, current->mm, userptr, num_pages,
-				   write, 0, pages, NULL);
+		r = get_current_user_pages(userptr, num_pages, write, 0, pages,
+				NULL);
 		if (r < 0)
 			goto release_pages;
 
diff -puN drivers/gpu/drm/via/via_dmablit.c~get_current_user_pages drivers/gpu/drm/via/via_dmablit.c
--- a/drivers/gpu/drm/via/via_dmablit.c~get_current_user_pages	2015-10-22 16:05:05.882597493 -0700
+++ b/drivers/gpu/drm/via/via_dmablit.c	2015-10-22 16:05:15.053012839 -0700
@@ -239,8 +239,7 @@ via_lock_all_dma_pages(drm_via_sg_info_t
 	if (NULL == vsg->pages)
 		return -ENOMEM;
 	down_read(&current->mm->mmap_sem);
-	ret = get_user_pages(current, current->mm,
-			     (unsigned long)xfer->mem_addr,
+	ret = get_current_user_pages((unsigned long)xfer->mem_addr,
 			     vsg->num_pages,
 			     (vsg->direction == DMA_FROM_DEVICE),
 			     0, vsg->pages, NULL);
diff -puN drivers/infiniband/core/umem.c~get_current_user_pages drivers/infiniband/core/umem.c
--- a/drivers/infiniband/core/umem.c~get_current_user_pages	2015-10-22 16:05:15.898051112 -0700
+++ b/drivers/infiniband/core/umem.c	2015-10-22 16:05:24.188426599 -0700
@@ -188,7 +188,7 @@ struct ib_umem *ib_umem_get(struct ib_uc
 	sg_list_start = umem->sg_head.sgl;
 
 	while (npages) {
-		ret = get_user_pages(current, current->mm, cur_base,
+		ret = get_current_user_pages(cur_base,
 				     min_t(unsigned long, npages,
 					   PAGE_SIZE / sizeof (struct page *)),
 				     1, !umem->writable, page_list, vma_list);
diff -puN drivers/infiniband/hw/mthca/mthca_memfree.c~get_current_user_pages drivers/infiniband/hw/mthca/mthca_memfree.c
--- a/drivers/infiniband/hw/mthca/mthca_memfree.c~get_current_user_pages	2015-10-22 16:05:25.008463740 -0700
+++ b/drivers/infiniband/hw/mthca/mthca_memfree.c	2015-10-22 16:05:36.492983894 -0700
@@ -472,8 +472,7 @@ int mthca_map_user_db(struct mthca_dev *
 		goto out;
 	}
 
-	ret = get_user_pages(current, current->mm, uaddr & PAGE_MASK, 1, 1, 0,
-			     pages, NULL);
+	ret = get_current_user_pages(uaddr & PAGE_MASK, 1, 1, 0, pages, NULL);
 	if (ret < 0)
 		goto out;
 
diff -puN drivers/infiniband/hw/qib/qib_user_pages.c~get_current_user_pages drivers/infiniband/hw/qib/qib_user_pages.c
--- a/drivers/infiniband/hw/qib/qib_user_pages.c~get_current_user_pages	2015-10-22 16:05:37.424026063 -0700
+++ b/drivers/infiniband/hw/qib/qib_user_pages.c	2015-10-22 16:05:47.924501648 -0700
@@ -66,8 +66,7 @@ static int __qib_get_user_pages(unsigned
 	}
 
 	for (got = 0; got < num_pages; got += ret) {
-		ret = get_user_pages(current, current->mm,
-				     start_page + got * PAGE_SIZE,
+		ret = get_current_user_pages(start_page + got * PAGE_SIZE,
 				     num_pages - got, 1, 1,
 				     p + got, NULL);
 		if (ret < 0)
diff -puN drivers/infiniband/hw/usnic/usnic_uiom.c~get_current_user_pages drivers/infiniband/hw/usnic/usnic_uiom.c
--- a/drivers/infiniband/hw/usnic/usnic_uiom.c~get_current_user_pages	2015-10-22 16:05:49.341565829 -0700
+++ b/drivers/infiniband/hw/usnic/usnic_uiom.c	2015-10-22 16:06:04.868269060 -0700
@@ -144,7 +144,7 @@ static int usnic_uiom_get_pages(unsigned
 	ret = 0;
 
 	while (npages) {
-		ret = get_user_pages(current, current->mm, cur_base,
+		ret = get_current_user_pages(cur_base,
 					min_t(unsigned long, npages,
 					PAGE_SIZE / sizeof(struct page *)),
 					1, !writable, page_list, NULL);
diff -puN drivers/media/pci/ivtv/ivtv-yuv.c~get_current_user_pages drivers/media/pci/ivtv/ivtv-yuv.c
--- a/drivers/media/pci/ivtv/ivtv-yuv.c~get_current_user_pages	2015-10-22 16:06:05.723307787 -0700
+++ b/drivers/media/pci/ivtv/ivtv-yuv.c	2015-10-22 16:06:43.060998869 -0700
@@ -76,12 +76,12 @@ static int ivtv_yuv_prep_user_dma(struct
 
 	/* Get user pages for DMA Xfer */
 	down_read(&current->mm->mmap_sem);
-	y_pages = get_user_pages(current, current->mm, y_dma.uaddr, y_dma.page_count, 0, 1, &dma->map[0], NULL);
+	y_pages = get_current_user_pages(y_dma.uaddr, y_dma.page_count, 0, 1, &dma->map[0], NULL);
 	uv_pages = 0; /* silence gcc. value is set and consumed only if: */
 	if (y_pages == y_dma.page_count) {
-		uv_pages = get_user_pages(current, current->mm,
-					  uv_dma.uaddr, uv_dma.page_count, 0, 1,
-					  &dma->map[y_pages], NULL);
+		uv_pages = get_current_user_pages(uv_dma.uaddr,
+				uv_dma.page_count, 0, 1,
+				&dma->map[y_pages], NULL);
 	}
 	up_read(&current->mm->mmap_sem);
 
diff -puN drivers/media/v4l2-core/videobuf-dma-sg.c~get_current_user_pages drivers/media/v4l2-core/videobuf-dma-sg.c
--- a/drivers/media/v4l2-core/videobuf-dma-sg.c~get_current_user_pages	2015-10-22 16:06:43.743029759 -0700
+++ b/drivers/media/v4l2-core/videobuf-dma-sg.c	2015-10-22 16:06:53.716481470 -0700
@@ -181,8 +181,7 @@ static int videobuf_dma_init_user_locked
 	dprintk(1, "init user [0x%lx+0x%lx => %d pages]\n",
 		data, size, dma->nr_pages);
 
-	err = get_user_pages(current, current->mm,
-			     data & PAGE_MASK, dma->nr_pages,
+	err = get_current_user_pages(data & PAGE_MASK, dma->nr_pages,
 			     rw == READ, 1, /* force */
 			     dma->pages, NULL);
 
diff -puN drivers/virt/fsl_hypervisor.c~get_current_user_pages drivers/virt/fsl_hypervisor.c
--- a/drivers/virt/fsl_hypervisor.c~get_current_user_pages	2015-10-22 16:06:55.280552310 -0700
+++ b/drivers/virt/fsl_hypervisor.c	2015-10-22 16:07:09.261185511 -0700
@@ -244,9 +244,8 @@ static long ioctl_memcpy(struct fsl_hv_i
 
 	/* Get the physical addresses of the source buffer */
 	down_read(&current->mm->mmap_sem);
-	num_pinned = get_user_pages(current, current->mm,
-		param.local_vaddr - lb_offset, num_pages,
-		(param.source == -1) ? READ : WRITE,
+	num_pinned = get_current_user_pages(param.local_vaddr - lb_offset,
+		num_pages, (param.source == -1) ? READ : WRITE,
 		0, pages, NULL);
 	up_read(&current->mm->mmap_sem);
 
diff -puN fs/exec.c~get_current_user_pages fs/exec.c
--- a/fs/exec.c~get_current_user_pages	2015-10-22 16:07:10.134225053 -0700
+++ b/fs/exec.c	2015-10-22 16:35:11.763231100 -0700
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
+	ret = get_foreign_user_pages(current, bprm->mm, pos, 1, write,
+			1, &page, NULL);
 	if (ret <= 0)
 		return NULL;
 
diff -puN mm/mempolicy.c~get_current_user_pages mm/mempolicy.c
--- a/mm/mempolicy.c~get_current_user_pages	2015-10-22 16:07:19.296640031 -0700
+++ b/mm/mempolicy.c	2015-10-22 16:08:04.949707713 -0700
@@ -813,12 +813,12 @@ static void get_policy_nodemask(struct m
 	}
 }
 
-static int lookup_node(struct mm_struct *mm, unsigned long addr)
+static int lookup_node(unsigned long addr)
 {
 	struct page *p;
 	int err;
 
-	err = get_user_pages(current, mm, addr & PAGE_MASK, 1, 0, 0, &p, NULL);
+	err = get_current_user_pages(addr & PAGE_MASK, 1, 0, 0, &p, NULL);
 	if (err >= 0) {
 		err = page_to_nid(p);
 		put_page(p);
@@ -873,7 +873,7 @@ static long do_get_mempolicy(int *policy
 
 	if (flags & MPOL_F_NODE) {
 		if (flags & MPOL_F_ADDR) {
-			err = lookup_node(mm, addr);
+			err = lookup_node(addr);
 			if (err < 0)
 				goto out;
 			*policy = err;
diff -puN security/tomoyo/domain.c~get_current_user_pages security/tomoyo/domain.c
--- a/security/tomoyo/domain.c~get_current_user_pages	2015-10-22 16:08:06.037756992 -0700
+++ b/security/tomoyo/domain.c	2015-10-22 16:33:33.154780307 -0700
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
+	if (get_foreign_user_pages(current, bprm->mm, pos, 1, 
+				0, 1, &page, NULL) <= 0)
 		return false;
 #else
 	page = bprm->page[pos / PAGE_SIZE];
diff -puN include/linux/mm.h~get_current_user_pages include/linux/mm.h
--- a/include/linux/mm.h~get_current_user_pages	2015-10-22 16:35:32.799180621 -0700
+++ b/include/linux/mm.h	2015-10-22 16:43:06.235641368 -0700
@@ -1198,12 +1198,14 @@ long __get_user_pages(struct task_struct
 		      unsigned long start, unsigned long nr_pages,
 		      unsigned int foll_flags, struct page **pages,
 		      struct vm_area_struct **vmas, int *nonblocking);
-long get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
-		    unsigned long start, unsigned long nr_pages,
-		    int write, int force, struct page **pages,
-		    struct vm_area_struct **vmas);
-long get_user_pages_locked(struct task_struct *tsk, struct mm_struct *mm,
-		    unsigned long start, unsigned long nr_pages,
+long get_foreign_user_pages(struct task_struct *tsk, struct mm_struct *mm,
+			    unsigned long start, unsigned long nr_pages,
+			    int write, int force, struct page **pages,
+			    struct vm_area_struct **vmas);
+long get_current_user_pages(unsigned long start, unsigned long nr_pages,
+			    int write, int force, struct page **pages,
+			    struct vm_area_struct **vmas);
+long get_user_pages_locked(unsigned long start, unsigned long nr_pages,
 		    int write, int force, struct page **pages,
 		    int *locked);
 long __get_user_pages_unlocked(struct task_struct *tsk, struct mm_struct *mm,
diff -puN mm/frame_vector.c~get_current_user_pages mm/frame_vector.c
--- a/mm/frame_vector.c~get_current_user_pages	2015-10-22 16:37:35.449716063 -0700
+++ b/mm/frame_vector.c	2015-10-22 16:38:40.858667050 -0700
@@ -58,7 +58,7 @@ int get_vaddr_frames(unsigned long start
 	if (!(vma->vm_flags & (VM_IO | VM_PFNMAP))) {
 		vec->got_ref = true;
 		vec->is_pfns = false;
-		ret = get_user_pages_locked(current, mm, start, nr_frames,
+		ret = get_user_pages_locked(start, nr_frames,
 			write, force, (struct page **)(vec->ptrs), &locked);
 		goto out;
 	}
diff -puN drivers/infiniband/core/umem_odp.c~get_current_user_pages drivers/infiniband/core/umem_odp.c
--- a/drivers/infiniband/core/umem_odp.c~get_current_user_pages	2015-10-22 16:43:10.019812135 -0700
+++ b/drivers/infiniband/core/umem_odp.c	2015-10-22 16:45:02.802901881 -0700
@@ -572,10 +572,10 @@ int ib_umem_odp_map_dma_pages(struct ib_
 		 * complex (and doesn't gain us much performance in most use
 		 * cases).
 		 */
-		npages = get_user_pages(owning_process, owning_mm, user_virt,
-					gup_num_pages,
-					access_mask & ODP_WRITE_ALLOWED_BIT, 0,
-					local_page_list, NULL);
+		npages = get_foreign_user_pages(owning_process, owning_mm,
+				user_virt, gup_num_pages,
+				access_mask & ODP_WRITE_ALLOWED_BIT,
+				0, local_page_list, NULL);
 		up_read(&owning_mm->mmap_sem);
 
 		if (npages < 0)
diff -puN drivers/gpu/drm/i915/i915_gem_userptr.c~get_current_user_pages drivers/gpu/drm/i915/i915_gem_userptr.c
--- a/drivers/gpu/drm/i915/i915_gem_userptr.c~get_current_user_pages	2015-10-22 16:45:09.589208151 -0700
+++ b/drivers/gpu/drm/i915/i915_gem_userptr.c	2015-10-22 16:45:20.979722216 -0700
@@ -587,7 +587,7 @@ __i915_gem_userptr_get_pages_worker(stru
 
 		down_read(&mm->mmap_sem);
 		while (pinned < num_pages) {
-			ret = get_user_pages(work->task, mm,
+			ret = get_foreign_user_pages(work->task, mm,
 					     obj->userptr.ptr + pinned * PAGE_SIZE,
 					     num_pages - pinned,
 					     !obj->userptr.read_only, 0,
_

--------------010102080708010602030104--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
