Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id D68E89003C7
	for <linux-mm@kvack.org>; Mon, 27 Jul 2015 03:02:09 -0400 (EDT)
Received: by wicgb10 with SMTP id gb10so97948922wic.1
        for <linux-mm@kvack.org>; Mon, 27 Jul 2015 00:02:09 -0700 (PDT)
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com. [209.85.212.182])
        by mx.google.com with ESMTPS id b19si12510238wiw.16.2015.07.27.00.02.07
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 Jul 2015 00:02:07 -0700 (PDT)
Received: by wicgb10 with SMTP id gb10so97947859wic.1
        for <linux-mm@kvack.org>; Mon, 27 Jul 2015 00:02:07 -0700 (PDT)
Date: Mon, 27 Jul 2015 10:02:04 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH V5 3/7] mm: Introduce VM_LOCKONFAULT
Message-ID: <20150727070204.GC11657@node.dhcp.inet.fi>
References: <1437773325-8623-1-git-send-email-emunson@akamai.com>
 <1437773325-8623-4-git-send-email-emunson@akamai.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1437773325-8623-4-git-send-email-emunson@akamai.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric B Munson <emunson@akamai.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, Vlastimil Babka <vbabka@suse.cz>, Jonathan Corbet <corbet@lwn.net>, linux-kernel@vger.kernel.org, dri-devel@lists.freedesktop.org, linux-mm@kvack.org, linux-api@vger.kernel.org

On Fri, Jul 24, 2015 at 05:28:41PM -0400, Eric B Munson wrote:
> The cost of faulting in all memory to be locked can be very high when
> working with large mappings.  If only portions of the mapping will be
> used this can incur a high penalty for locking.
> 
> For the example of a large file, this is the usage pattern for a large
> statical language model (probably applies to other statical or graphical
> models as well).  For the security example, any application transacting
> in data that cannot be swapped out (credit card data, medical records,
> etc).
> 
> This patch introduces the ability to request that pages are not
> pre-faulted, but are placed on the unevictable LRU when they are finally
> faulted in.  The VM_LOCKONFAULT flag will be used together with
> VM_LOCKED and has no effect when set without VM_LOCKED.  Setting the
> VM_LOCKONFAULT flag for a VMA will cause pages faulted into that VMA to
> be added to the unevictable LRU when they are faulted or if they are
> already present, but will not cause any missing pages to be faulted in.
> 
> Exposing this new lock state means that we cannot overload the meaning
> of the FOLL_POPULATE flag any longer.  Prior to this patch it was used
> to mean that the VMA for a fault was locked.  This means we need the
> new FOLL_MLOCK flag to communicate the locked state of a VMA.
> FOLL_POPULATE will now only control if the VMA should be populated and
> in the case of VM_LOCKONFAULT, it will not be set.
> 
> Signed-off-by: Eric B Munson <emunson@akamai.com>
> Cc: Michal Hocko <mhocko@suse.cz>
> Cc: Vlastimil Babka <vbabka@suse.cz>
> Cc: Jonathan Corbet <corbet@lwn.net>
> Cc: "Kirill A. Shutemov" <kirill@shutemov.name>
> Cc: linux-kernel@vger.kernel.org
> Cc: dri-devel@lists.freedesktop.org
> Cc: linux-mm@kvack.org
> Cc: linux-api@vger.kernel.org
> ---
>  drivers/gpu/drm/drm_vm.c |  8 +++++++-
>  fs/proc/task_mmu.c       |  1 +
>  include/linux/mm.h       |  2 ++
>  kernel/fork.c            |  2 +-
>  mm/debug.c               |  1 +
>  mm/gup.c                 | 10 ++++++++--
>  mm/huge_memory.c         |  2 +-
>  mm/hugetlb.c             |  4 ++--
>  mm/mlock.c               |  2 +-
>  mm/mmap.c                |  2 +-
>  mm/rmap.c                |  4 ++--
>  11 files changed, 27 insertions(+), 11 deletions(-)
> 
> diff --git a/drivers/gpu/drm/drm_vm.c b/drivers/gpu/drm/drm_vm.c
> index aab49ee..103a5f6 100644
> --- a/drivers/gpu/drm/drm_vm.c
> +++ b/drivers/gpu/drm/drm_vm.c
> @@ -699,9 +699,15 @@ int drm_vma_info(struct seq_file *m, void *data)
>  		   (void *)(unsigned long)virt_to_phys(high_memory));
>  
>  	list_for_each_entry(pt, &dev->vmalist, head) {
> +		char lock_flag = '-';
> +
>  		vma = pt->vma;
>  		if (!vma)
>  			continue;
> +		if (vma->vm_flags & VM_LOCKONFAULT)
> +			lock_flag = 'f';
> +		else if (vma->vm_flags & VM_LOCKED)
> +			lock_flag = 'l';
>  		seq_printf(m,
>  			   "\n%5d 0x%pK-0x%pK %c%c%c%c%c%c 0x%08lx000",
>  			   pt->pid,
> @@ -710,7 +716,7 @@ int drm_vma_info(struct seq_file *m, void *data)
>  			   vma->vm_flags & VM_WRITE ? 'w' : '-',
>  			   vma->vm_flags & VM_EXEC ? 'x' : '-',
>  			   vma->vm_flags & VM_MAYSHARE ? 's' : 'p',
> -			   vma->vm_flags & VM_LOCKED ? 'l' : '-',
> +			   lock_flag,
>  			   vma->vm_flags & VM_IO ? 'i' : '-',
>  			   vma->vm_pgoff);
>  
> diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
> index ca1e091..38d69fc 100644
> --- a/fs/proc/task_mmu.c
> +++ b/fs/proc/task_mmu.c
> @@ -579,6 +579,7 @@ static void show_smap_vma_flags(struct seq_file *m, struct vm_area_struct *vma)
>  #ifdef CONFIG_X86_INTEL_MPX
>  		[ilog2(VM_MPX)]		= "mp",
>  #endif
> +		[ilog2(VM_LOCKONFAULT)]	= "lf",
>  		[ilog2(VM_LOCKED)]	= "lo",
>  		[ilog2(VM_IO)]		= "io",
>  		[ilog2(VM_SEQ_READ)]	= "sr",
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 2e872f9..c2f3551 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -127,6 +127,7 @@ extern unsigned int kobjsize(const void *objp);
>  #define VM_PFNMAP	0x00000400	/* Page-ranges managed without "struct page", just pure PFN */
>  #define VM_DENYWRITE	0x00000800	/* ETXTBSY on write attempts.. */
>  
> +#define VM_LOCKONFAULT	0x00001000	/* Lock the pages covered when they are faulted in */
>  #define VM_LOCKED	0x00002000
>  #define VM_IO           0x00004000	/* Memory mapped I/O or similar */
>  
> @@ -2043,6 +2044,7 @@ static inline struct page *follow_page(struct vm_area_struct *vma,
>  #define FOLL_NUMA	0x200	/* force NUMA hinting page fault */
>  #define FOLL_MIGRATION	0x400	/* wait for page to replace migration entry */
>  #define FOLL_TRIED	0x800	/* a retry, previous pass started an IO */
> +#define FOLL_MLOCK	0x1000	/* lock present pages */
>  
>  typedef int (*pte_fn_t)(pte_t *pte, pgtable_t token, unsigned long addr,
>  			void *data);
> diff --git a/kernel/fork.c b/kernel/fork.c
> index dbd9b8d..a949228 100644
> --- a/kernel/fork.c
> +++ b/kernel/fork.c
> @@ -454,7 +454,7 @@ static int dup_mmap(struct mm_struct *mm, struct mm_struct *oldmm)
>  		tmp->vm_mm = mm;
>  		if (anon_vma_fork(tmp, mpnt))
>  			goto fail_nomem_anon_vma_fork;
> -		tmp->vm_flags &= ~VM_LOCKED;
> +		tmp->vm_flags &= ~(VM_LOCKED | VM_LOCKONFAULT);
>  		tmp->vm_next = tmp->vm_prev = NULL;
>  		file = tmp->vm_file;
>  		if (file) {
> diff --git a/mm/debug.c b/mm/debug.c
> index 76089dd..25176bb 100644
> --- a/mm/debug.c
> +++ b/mm/debug.c
> @@ -121,6 +121,7 @@ static const struct trace_print_flags vmaflags_names[] = {
>  	{VM_GROWSDOWN,			"growsdown"	},
>  	{VM_PFNMAP,			"pfnmap"	},
>  	{VM_DENYWRITE,			"denywrite"	},
> +	{VM_LOCKONFAULT,		"lockonfault"	},
>  	{VM_LOCKED,			"locked"	},
>  	{VM_IO,				"io"		},
>  	{VM_SEQ_READ,			"seqread"	},
> diff --git a/mm/gup.c b/mm/gup.c
> index 6297f6b..e632908 100644
> --- a/mm/gup.c
> +++ b/mm/gup.c
> @@ -92,7 +92,7 @@ retry:
>  		 */
>  		mark_page_accessed(page);
>  	}
> -	if ((flags & FOLL_POPULATE) && (vma->vm_flags & VM_LOCKED)) {
> +	if ((flags & FOLL_MLOCK) && (vma->vm_flags & VM_LOCKED)) {
>  		/*
>  		 * The preliminary mapping check is mainly to avoid the
>  		 * pointless overhead of lock_page on the ZERO_PAGE
> @@ -265,6 +265,9 @@ static int faultin_page(struct task_struct *tsk, struct vm_area_struct *vma,
>  	unsigned int fault_flags = 0;
>  	int ret;
>  
> +	/* mlock all present pages, but do not fault in new pages */
> +	if ((*flags & (FOLL_POPULATE | FOLL_MLOCK)) == FOLL_MLOCK)
> +		return -ENOENT;
>  	/* For mm_populate(), just skip the stack guard page. */
>  	if ((*flags & FOLL_POPULATE) &&
>  			(stack_guard_page_start(vma, address) ||
> @@ -850,7 +853,10 @@ long populate_vma_page_range(struct vm_area_struct *vma,
>  	VM_BUG_ON_VMA(end   > vma->vm_end, vma);
>  	VM_BUG_ON_MM(!rwsem_is_locked(&mm->mmap_sem), mm);
>  
> -	gup_flags = FOLL_TOUCH | FOLL_POPULATE;
> +	gup_flags = FOLL_TOUCH | FOLL_MLOCK;
> +	if ((vma->vm_flags & (VM_LOCKED | VM_LOCKONFAULT)) == VM_LOCKED)
> +		gup_flags |= FOLL_POPULATE;
> +
>  	/*
>  	 * We want to touch writable mappings with a write fault in order
>  	 * to break COW, except for shared mappings because these don't COW
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index c107094..5e22d90 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -1238,7 +1238,7 @@ struct page *follow_trans_huge_pmd(struct vm_area_struct *vma,
>  					  pmd, _pmd,  1))
>  			update_mmu_cache_pmd(vma, addr, pmd);
>  	}
> -	if ((flags & FOLL_POPULATE) && (vma->vm_flags & VM_LOCKED)) {
> +	if ((flags & FOLL_MLOCK) && (vma->vm_flags & VM_LOCKED )) {
							     ^^^
Space befor ')'.

Otherwise:

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
