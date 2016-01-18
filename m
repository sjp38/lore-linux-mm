Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f47.google.com (mail-wm0-f47.google.com [74.125.82.47])
	by kanga.kvack.org (Postfix) with ESMTP id DF4D66B0005
	for <linux-mm@kvack.org>; Mon, 18 Jan 2016 10:20:24 -0500 (EST)
Received: by mail-wm0-f47.google.com with SMTP id n5so69103822wmn.0
        for <linux-mm@kvack.org>; Mon, 18 Jan 2016 07:20:24 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id k206si25953867wmf.37.2016.01.18.07.20.23
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 18 Jan 2016 07:20:23 -0800 (PST)
Subject: Re: [PATCH] mm, gup: introduce concept of "foreign" get_user_pages()
References: <20160115181114.A50C25D1@viggo.jf.intel.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <569D02AF.8050903@suse.cz>
Date: Mon, 18 Jan 2016 16:20:15 +0100
MIME-Version: 1.0
In-Reply-To: <20160115181114.A50C25D1@viggo.jf.intel.com>
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave@sr71.net>, linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, x86@kernel.org, dave.hansen@linux.intel.com, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, aarcange@redhat.com, n-horiguchi@ah.jp.nec.com, jack@suse.cz

On 01/15/2016 07:11 PM, Dave Hansen wrote:
> Just sending an update to this one patch instead of resending
> the entire series.
>
> Jan Kara suggested that we just change get_user_pages()'s
> prototype to remove tsk/mm instead of introducing a separate
> get_user_pages_current().  Also, we moved the "_foreign" in
> get_user_pages_foreign() to the end to be more consistent with
> the "_unlocked" version.

Thanks, and you could have blamed me too, not just Jan ;)

> This approach will break any new users of get_user_pages()
> which try to pass a tsk/mm, but Jan doesn't think these are
> frequent enough to be a concern.  This passes an allyesconfig
> on 4.4, at least.
>
> As always, any acks on this approach would be much appreciated.
> This is the largest swath of non-x86 code that protection keys
> touches, and I'm sure the x86 maintainers would appreciate
> seeing some acks from folks on it.

This is finally a thorough review attempt, sorry I didn't catch some of 
the stuff below earlier.

> ---
>
> From: Dave Hansen <dave.hansen@linux.intel.com>
>
> For protection keys, we need to understand whether protections
> should be enforced in software or not.  In general, we enforce
> protections when working on our own task, but not when on others.
> We call these "current" and "foreign" operations.
>
> This patch introduces a new get_user_pages() variant:
>
> 	get_user_pages_foreign()
>
> The plain get_user_pages() can no longer be used on mm/tasks
> other than 'current/current->mm', which is by far the most common
> way it is called.  Using it makes a few of the call sites look a
> bit nicer.
>
> get_user_pages_foreign() is a replacement for when
> get_user_pages() is called on non-current tsk/mm.
>
> This also switches get_user_pages_unlocked() over to be like
> get_user_pages() and not take a tsk/mm.  If someone wants the
> get_user_pages_unlocked() behavior with a non-current tsk/mm,
> they just have to use __get_user_pages_unlocked() directly.

Hmm, but your patch actually changes __get_user_pages_unlocked() to also 
not include the task and mm params and assume current and current->mm? 
Wouldn't it be more consistent if __get_user_unlocked() stayed as it is?
What you say above is true for {__}get_user_pages_locked.

> Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Cc: Andrea Arcangeli <aarcange@redhat.com>
> Cc: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
> Cc: vbabka@suse.cz
> Cc: jack@suse.cz
> ---
>
>   b/arch/cris/arch-v32/drivers/cryptocop.c        |    8 ---
>   b/arch/ia64/kernel/err_inject.c                 |    3 -
>   b/arch/mips/mm/gup.c                            |    3 -
>   b/arch/s390/mm/gup.c                            |    4 -
>   b/arch/sh/mm/gup.c                              |    2
>   b/arch/sparc/mm/gup.c                           |    2
>   b/arch/x86/mm/gup.c                             |    2
>   b/arch/x86/mm/mpx.c                             |    4 -
>   b/drivers/gpu/drm/amd/amdgpu/amdgpu_ttm.c       |    3 -
>   b/drivers/gpu/drm/i915/i915_gem_userptr.c       |    2
>   b/drivers/gpu/drm/radeon/radeon_ttm.c           |    3 -
>   b/drivers/gpu/drm/via/via_dmablit.c             |    3 -
>   b/drivers/infiniband/core/umem.c                |    2
>   b/drivers/infiniband/core/umem_odp.c            |    8 +--
>   b/drivers/infiniband/hw/mthca/mthca_memfree.c   |    3 -
>   b/drivers/infiniband/hw/qib/qib_user_pages.c    |    3 -
>   b/drivers/infiniband/hw/usnic/usnic_uiom.c      |    2
>   b/drivers/media/pci/ivtv/ivtv-udma.c            |    4 -
>   b/drivers/media/pci/ivtv/ivtv-yuv.c             |   10 +---
>   b/drivers/media/v4l2-core/videobuf-dma-sg.c     |    3 -
>   b/drivers/misc/mic/scif/scif_rma.c              |    2
>   b/drivers/misc/sgi-gru/grufault.c               |    3 -
>   b/drivers/scsi/st.c                             |    2
>   b/drivers/staging/rdma/hfi1/user_pages.c        |    3 -
>   b/drivers/staging/rdma/ipath/ipath_user_pages.c |    3 -
>   b/drivers/video/fbdev/pvr2fb.c                  |    4 -
>   b/drivers/virt/fsl_hypervisor.c                 |    5 --
>   b/fs/exec.c                                     |    8 ++-
>   b/include/linux/mm.h                            |   23 +++++-----
>   b/kernel/events/uprobes.c                       |    4 -
>   b/mm/frame_vector.c                             |    2
>   b/mm/gup.c                                      |   51 +++++++++++++++---------
>   b/mm/ksm.c                                      |    2
>   b/mm/memory.c                                   |    2
>   b/mm/mempolicy.c                                |    6 +-
>   b/mm/nommu.c                                    |   35 +++++++++-------
>   b/mm/process_vm_access.c                        |    6 +-
>   b/mm/util.c                                     |    4 -
>   b/net/ceph/pagevec.c                            |    2
>   b/security/tomoyo/domain.c                      |    9 +++-
>   b/virt/kvm/async_pf.c                           |    2
>   b/virt/kvm/kvm_main.c                           |   13 ++----
>   42 files changed, 135 insertions(+), 130 deletions(-)

[...]

> --- a/kernel/events/uprobes.c~get_current_user_pages	2016-01-15 09:45:42.110046066 -0800
> +++ b/kernel/events/uprobes.c	2016-01-15 09:45:42.152047953 -0800
> @@ -298,7 +298,7 @@ int uprobe_write_opcode(struct mm_struct
>
>   retry:
>   	/* Read the page with vaddr into memory */
> -	ret = get_user_pages(NULL, mm, vaddr, 1, 0, 1, &old_page, &vma);
> +	ret = get_user_pages_foreign(NULL, mm, vaddr, 1, 0, 1, &old_page, &vma);
>   	if (ret <= 0)
>   		return ret;
>
> @@ -1699,7 +1699,7 @@ static int is_trap_at_addr(struct mm_str
>   	if (likely(result == 0))
>   		goto out;
>
> -	result = get_user_pages(NULL, mm, vaddr, 1, 0, 1, &page, NULL);
> +	result = get_user_pages(vaddr, 1, 0, 1, &page, NULL);

Yeah it seems that mm here is current->mm, and using current task 
instead of NULL affects AFAICS just the min/maj fault counting, but 
isn't it still a subtle and unintended functional change?

[...]

> -__always_inline long __get_user_pages_unlocked(struct task_struct *tsk, struct mm_struct *mm,
> -					       unsigned long start, unsigned long nr_pages,
> +__always_inline long __get_user_pages_unlocked(unsigned long start, unsigned long nr_pages,
>   					       int write, int force, struct page **pages,
>   					       unsigned int gup_flags)

This is the IMHO unneeded inconsistency what I mentioned above...

> diff -puN mm/process_vm_access.c~get_current_user_pages mm/process_vm_access.c
> --- a/mm/process_vm_access.c~get_current_user_pages	2016-01-15 09:45:42.120046515 -0800
> +++ b/mm/process_vm_access.c	2016-01-15 09:45:42.157048177 -0800
> @@ -99,8 +99,10 @@ static int process_vm_rw_single_vec(unsi
>   		size_t bytes;
>
>   		/* Get the pages we're interested in */
> -		pages = get_user_pages_unlocked(task, mm, pa, pages,
> -						vm_write, 0, process_pages);
> +		down_read(&mm->mmap_sem);
> +		pages = get_user_pages_foreign(task, mm, pa, pages, vm_write,
> +						0, process_pages, NULL);
> +		up_read(&mm->mmap_sem);

You could have simply used __get_user_pages_unlocked() if it wasn't changed.

> @@ -80,7 +80,7 @@ static void async_pf_execute(struct work
>
>   	might_sleep();
>
> -	get_user_pages_unlocked(NULL, mm, addr, 1, 1, 0, NULL);
> +	get_user_pages_unlocked(addr, 1, 1, 0, NULL);

This seems to get mm from some structure where struct work is embedded, 
are you sure it's current->mm? I think it's another place for 
__get_user_pages_unlocked().

>   static inline int check_user_page_hwpoison(unsigned long addr)
> @@ -1344,12 +1345,10 @@ static int hva_to_pfn_slow(unsigned long
>
>   	if (async) {
>   		down_read(&current->mm->mmap_sem);
> -		npages = get_user_page_nowait(current, current->mm,
> -					      addr, write_fault, page);
> +		npages = get_user_page_nowait(addr, write_fault, page);
>   		up_read(&current->mm->mmap_sem);
>   	} else
> -		npages = __get_user_pages_unlocked(current, current->mm, addr, 1,
> -						   write_fault, 0, page,
> +		npages = __get_user_pages_unlocked(addr, 1, write_fault, 0, page,
>   						   FOLL_TOUCH|FOLL_HWPOISON);
>   	if (npages != 1)
>   		return npages;

If you change __get_user_pages_unlocked() as I suggested, you could use 
get_user_pages_unlocked() here?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
