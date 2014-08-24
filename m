Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f182.google.com (mail-we0-f182.google.com [74.125.82.182])
	by kanga.kvack.org (Postfix) with ESMTP id 0EAAB6B0035
	for <linux-mm@kvack.org>; Sun, 24 Aug 2014 03:59:42 -0400 (EDT)
Received: by mail-we0-f182.google.com with SMTP id k48so12105272wev.41
        for <linux-mm@kvack.org>; Sun, 24 Aug 2014 00:59:42 -0700 (PDT)
Received: from jenni1.inet.fi (mta-out1.inet.fi. [62.71.2.232])
        by mx.google.com with ESMTP id po3si9550164wjc.132.2014.08.24.00.59.41
        for <linux-mm@kvack.org>;
        Sun, 24 Aug 2014 00:59:41 -0700 (PDT)
Date: Sun, 24 Aug 2014 10:59:24 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH v3] mm: softdirty: enable write notifications on VMAs
 after VM_SOFTDIRTY cleared
Message-ID: <20140824075924.GA27392@node.dhcp.inet.fi>
References: <1408571182-28750-1-git-send-email-pfeiner@google.com>
 <1408844584-30380-1-git-send-email-pfeiner@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1408844584-30380-1-git-send-email-pfeiner@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Feiner <pfeiner@google.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Cyrill Gorcunov <gorcunov@openvz.org>, Pavel Emelyanov <xemul@parallels.com>, Jamie Liu <jamieliu@google.com>, Hugh Dickins <hughd@google.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Andrew Morton <akpm@linux-foundation.org>

On Sat, Aug 23, 2014 at 09:43:04PM -0400, Peter Feiner wrote:
> For VMAs that don't want write notifications, PTEs created for read
> faults have their write bit set. If the read fault happens after
> VM_SOFTDIRTY is cleared, then the PTE's softdirty bit will remain
> clear after subsequent writes.
> 
> Here's a simple code snippet to demonstrate the bug:
> 
>   char* m = mmap(NULL, getpagesize(), PROT_READ | PROT_WRITE,
>                  MAP_ANONYMOUS | MAP_SHARED, -1, 0);
>   system("echo 4 > /proc/$PPID/clear_refs"); /* clear VM_SOFTDIRTY */
>   assert(*m == '\0');     /* new PTE allows write access */
>   assert(!soft_dirty(x));
>   *m = 'x';               /* should dirty the page */
>   assert(soft_dirty(x));  /* fails */
> 
> With this patch, write notifications are enabled when VM_SOFTDIRTY is
> cleared. Furthermore, to avoid unnecessary faults, write
> notifications are disabled when VM_SOFTDIRTY is reset.
> 
> As a side effect of enabling and disabling write notifications with
> care, this patch fixes a bug in mprotect where vm_page_prot bits set
> by drivers were zapped on mprotect. An analogous bug was fixed in mmap
> by c9d0bf241451a3ab7d02e1652c22b80cd7d93e8f.
> 
> ---
> 
> v1 -> v2: Instead of checking VM_SOFTDIRTY in the fault handler,
>           enable write notifications on vm_page_prot when we clear
>           VM_SOFTDIRTY.
> 
> v2 -> v3: * Grab the mmap_sem in write mode if any VMAs have
>             VM_SOFTDIRTY set. This involved refactoring clear_refs_write
>             to make it less unwieldy.
> 
>           * In mprotect, don't inadvertently disable write notifications on VMAs
>             that have had VM_SOFTDIRTY cleared
> 
>           * The mprotect fix and mmap cleanup that comprised the
>             second and third patches in v2 were swallowed by the main
>             patch because of vm_page_prot corner case handling.
> ---
>  fs/proc/task_mmu.c | 113 +++++++++++++++++++++++++++++++++--------------------
>  include/linux/mm.h |  14 +++++++
>  mm/mmap.c          |  24 +++++-------
>  mm/mprotect.c      |   6 +--
>  4 files changed, 97 insertions(+), 60 deletions(-)
> 
> diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
> index dfc791c..f5e75c6 100644
> --- a/fs/proc/task_mmu.c
> +++ b/fs/proc/task_mmu.c
> @@ -785,13 +785,80 @@ static int clear_refs_pte_range(pmd_t *pmd, unsigned long addr,
>  	return 0;
>  }
>  
> +static int clear_refs(struct mm_struct *mm, enum clear_refs_types type,
> +                      int write)
> +{
> +	int r = 0;
> +	struct vm_area_struct *vma;
> +	struct clear_refs_private cp = {
> +		.type = type,
> +	};
> +	struct mm_walk clear_refs_walk = {
> +		.pmd_entry = clear_refs_pte_range,
> +		.mm = mm,
> +		.private = &cp,
> +	};
> +
> +	if (write)
> +		down_write(&mm->mmap_sem);
> +	else
> +		down_read(&mm->mmap_sem);
> +
> +	if (type == CLEAR_REFS_SOFT_DIRTY)
> +		mmu_notifier_invalidate_range_start(mm, 0, -1);
> +
> +	for (vma = mm->mmap; vma; vma = vma->vm_next) {
> +		cp.vma = vma;
> +		if (is_vm_hugetlb_page(vma))
> +			continue;
> +		/*
> +		 * Writing 1 to /proc/pid/clear_refs affects all pages.
> +		 *
> +		 * Writing 2 to /proc/pid/clear_refs only affects
> +		 * Anonymous pages.
> +		 *
> +		 * Writing 3 to /proc/pid/clear_refs only affects file
> +		 * mapped pages.
> +		 *
> +		 * Writing 4 to /proc/pid/clear_refs affects all pages.
> +		 */
> +		if (type == CLEAR_REFS_ANON && vma->vm_file)
> +			continue;
> +		if (type == CLEAR_REFS_MAPPED && !vma->vm_file)
> +			continue;
> +		if (type == CLEAR_REFS_SOFT_DIRTY &&
> +		    (vma->vm_flags & VM_SOFTDIRTY)) {
> +			if (!write) {
> +				r = -EAGAIN;
> +				break;
> +			}
> +			vma->vm_flags &= ~VM_SOFTDIRTY;
> +			vma_enable_writenotify(vma);
> +		}
> +		walk_page_range(vma->vm_start, vma->vm_end,
> +				&clear_refs_walk);
> +	}
> +
> +	if (type == CLEAR_REFS_SOFT_DIRTY)
> +		mmu_notifier_invalidate_range_end(mm, 0, -1);
> +
> +	if (!r)
> +		flush_tlb_mm(mm);
> +
> +	if (write)
> +		up_write(&mm->mmap_sem);
> +	else
> +		up_read(&mm->mmap_sem);
> +
> +	return r;
> +}
> +
>  static ssize_t clear_refs_write(struct file *file, const char __user *buf,
>  				size_t count, loff_t *ppos)
>  {
>  	struct task_struct *task;
>  	char buffer[PROC_NUMBUF];
>  	struct mm_struct *mm;
> -	struct vm_area_struct *vma;
>  	enum clear_refs_types type;
>  	int itype;
>  	int rv;
> @@ -820,47 +887,9 @@ static ssize_t clear_refs_write(struct file *file, const char __user *buf,
>  		return -ESRCH;
>  	mm = get_task_mm(task);
>  	if (mm) {
> -		struct clear_refs_private cp = {
> -			.type = type,
> -		};
> -		struct mm_walk clear_refs_walk = {
> -			.pmd_entry = clear_refs_pte_range,
> -			.mm = mm,
> -			.private = &cp,
> -		};
> -		down_read(&mm->mmap_sem);
> -		if (type == CLEAR_REFS_SOFT_DIRTY)
> -			mmu_notifier_invalidate_range_start(mm, 0, -1);
> -		for (vma = mm->mmap; vma; vma = vma->vm_next) {
> -			cp.vma = vma;
> -			if (is_vm_hugetlb_page(vma))
> -				continue;
> -			/*
> -			 * Writing 1 to /proc/pid/clear_refs affects all pages.
> -			 *
> -			 * Writing 2 to /proc/pid/clear_refs only affects
> -			 * Anonymous pages.
> -			 *
> -			 * Writing 3 to /proc/pid/clear_refs only affects file
> -			 * mapped pages.
> -			 *
> -			 * Writing 4 to /proc/pid/clear_refs affects all pages.
> -			 */
> -			if (type == CLEAR_REFS_ANON && vma->vm_file)
> -				continue;
> -			if (type == CLEAR_REFS_MAPPED && !vma->vm_file)
> -				continue;
> -			if (type == CLEAR_REFS_SOFT_DIRTY) {
> -				if (vma->vm_flags & VM_SOFTDIRTY)
> -					vma->vm_flags &= ~VM_SOFTDIRTY;
> -			}
> -			walk_page_range(vma->vm_start, vma->vm_end,
> -					&clear_refs_walk);
> -		}
> -		if (type == CLEAR_REFS_SOFT_DIRTY)
> -			mmu_notifier_invalidate_range_end(mm, 0, -1);
> -		flush_tlb_mm(mm);
> -		up_read(&mm->mmap_sem);
> +		rv = clear_refs(mm, type, 0);
> +		if (rv)
> +			clear_refs(mm, type, 1);
>  		mmput(mm);
>  	}
>  	put_task_struct(task);
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 8981cc8..7979b79 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -1946,6 +1946,20 @@ static inline pgprot_t vm_get_page_prot(unsigned long vm_flags)
>  }
>  #endif
>  
> +/* Enable write notifications without blowing away special flags. */
> +static inline void vma_enable_writenotify(struct vm_area_struct *vma)
> +{
> +	pgprot_t newprot = vm_get_page_prot(vma->vm_flags & ~VM_SHARED);
> +	vma->vm_page_prot = pgprot_modify(vma->vm_page_prot, newprot);
> +}
> +
> +/* Disable write notifications without blowing away special flags. */
> +static inline void vma_disable_writenotify(struct vm_area_struct *vma)
> +{
> +	pgprot_t newprot = vm_get_page_prot(vma->vm_flags);
> +	vma->vm_page_prot = pgprot_modify(vma->vm_page_prot, newprot);
> +}
> +
>  #ifdef CONFIG_NUMA_BALANCING
>  unsigned long change_prot_numa(struct vm_area_struct *vma,
>  			unsigned long start, unsigned long end);
> diff --git a/mm/mmap.c b/mm/mmap.c
> index c1f2ea4..1b61fbc 100644
> --- a/mm/mmap.c
> +++ b/mm/mmap.c
> @@ -1470,6 +1470,10 @@ int vma_wants_writenotify(struct vm_area_struct *vma)
>  	if (vma->vm_ops && vma->vm_ops->page_mkwrite)
>  		return 1;
>  
> +	/* Do we need to track softdirty? */
> +	if (!(vm_flags & VM_SOFTDIRTY))

This will give false-positive if CONFIG_MEM_SOFT_DIRTY is disabled, since
VM_SOFTDIRTY is 0 in this case:

	if (IS_ENABLED(CONFIG_MEM_SOFT_DIRTY) && !(vm_flags & VM_SOFTDIRTY))

Otherwise looks good to me.

Suggested-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Reviewed-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

> +		return 1;
> +
>  	/* The open routine did something to the protections already? */
>  	if (pgprot_val(vma->vm_page_prot) !=
>  	    pgprot_val(vm_get_page_prot(vm_flags)))
> @@ -1610,21 +1614,6 @@ munmap_back:
>  			goto free_vma;
>  	}
>  
> -	if (vma_wants_writenotify(vma)) {
> -		pgprot_t pprot = vma->vm_page_prot;
> -
> -		/* Can vma->vm_page_prot have changed??
> -		 *
> -		 * Answer: Yes, drivers may have changed it in their
> -		 *         f_op->mmap method.
> -		 *
> -		 * Ensures that vmas marked as uncached stay that way.
> -		 */
> -		vma->vm_page_prot = vm_get_page_prot(vm_flags & ~VM_SHARED);
> -		if (pgprot_val(pprot) == pgprot_val(pgprot_noncached(pprot)))
> -			vma->vm_page_prot = pgprot_noncached(vma->vm_page_prot);
> -	}
> -
>  	vma_link(mm, vma, prev, rb_link, rb_parent);
>  	/* Once vma denies write, undo our temporary denial count */
>  	if (file) {
> @@ -1658,6 +1647,11 @@ out:
>  	 */
>  	vma->vm_flags |= VM_SOFTDIRTY;
>  
> +	if (vma_wants_writenotify(vma))
> +		vma_enable_writenotify(vma);
> +	else
> +		vma_disable_writenotify(vma);
> +
>  	return addr;
>  
>  unmap_and_free_vma:
> diff --git a/mm/mprotect.c b/mm/mprotect.c
> index c43d557..2dea043 100644
> --- a/mm/mprotect.c
> +++ b/mm/mprotect.c
> @@ -320,12 +320,12 @@ success:
>  	 * held in write mode.
>  	 */
>  	vma->vm_flags = newflags;
> -	vma->vm_page_prot = pgprot_modify(vma->vm_page_prot,
> -					  vm_get_page_prot(newflags));
>  
>  	if (vma_wants_writenotify(vma)) {
> -		vma->vm_page_prot = vm_get_page_prot(newflags & ~VM_SHARED);
> +		vma_enable_writenotify(vma);
>  		dirty_accountable = 1;
> +	} else {
> +		vma_disable_writenotify(vma);
>  	}
>  
>  	change_protection(vma, start, end, vma->vm_page_prot,
> -- 
> 2.1.0.rc2.206.gedb03e5
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
