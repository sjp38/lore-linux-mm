Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f170.google.com (mail-ie0-f170.google.com [209.85.223.170])
	by kanga.kvack.org (Postfix) with ESMTP id 695AE6B0038
	for <linux-mm@kvack.org>; Fri, 12 Dec 2014 14:51:19 -0500 (EST)
Received: by mail-ie0-f170.google.com with SMTP id rd18so7600301iec.15
        for <linux-mm@kvack.org>; Fri, 12 Dec 2014 11:51:19 -0800 (PST)
Received: from mail-ie0-x235.google.com (mail-ie0-x235.google.com. [2607:f8b0:4001:c03::235])
        by mx.google.com with ESMTPS id qr7si1711052igb.16.2014.12.12.11.51.17
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 12 Dec 2014 11:51:18 -0800 (PST)
Received: by mail-ie0-f181.google.com with SMTP id tp5so7523763ieb.40
        for <linux-mm@kvack.org>; Fri, 12 Dec 2014 11:51:17 -0800 (PST)
Date: Fri, 12 Dec 2014 12:51:12 -0700
From: Bjorn Helgaas <bhelgaas@google.com>
Subject: Re: [RFC PATCH] Add user-space support for resetting mm->hiwater_rss
 (peak RSS)
Message-ID: <20141212195112.GA7133@google.com>
References: <1418223544-11382-1-git-send-email-petrcermak@chromium.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1418223544-11382-1-git-send-email-petrcermak@chromium.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Petr Cermak <petrcermak@chromium.org>
Cc: linux-kernel@vger.kernel.org, Primiano Tucci <primiano@chromium.org>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org

[+cc akpm, linux-mm]

On Wed, Dec 10, 2014 at 02:59:04PM +0000, Petr Cermak wrote:
> Being able to reset mm->hiwater_rss (resident set size high water mark) from
> user space would enable fine grained iterative memory profiling. I propose a
> very short patch for doing so below. I would like to get some feedback on the
> user-space interface to do this. Would it be best to:
> 
>   1. Add an extra value to /proc/PID/clear_refs to reset VmHWM? (The proposed
>      patch uses this approach.)
> 
>   2. Add a new write-only pseudo-file for this purpose (e.g.,
>      /proc/pid/reset_hwm)?
> 
> The driving use-case for this would be getting the peak RSS value, which can be
> retrieved from the VmHWM field in /proc/pid/status, per benchmark iteration or
> test scenario.
> 
> Signed-off-by: Petr Cermak <petrcermak@chromium.org>
> ---
>  Documentation/filesystems/proc.txt |   3 ++
>  fs/proc/task_mmu.c                 | 106 +++++++++++++++++++++----------------
>  include/linux/mm.h                 |   5 ++
>  3 files changed, 68 insertions(+), 46 deletions(-)
> 
> diff --git a/Documentation/filesystems/proc.txt b/Documentation/filesystems/proc.txt
> index eb8a10e..2c277e9 100644
> --- a/Documentation/filesystems/proc.txt
> +++ b/Documentation/filesystems/proc.txt
> @@ -488,6 +488,9 @@ To clear the bits for the file mapped pages associated with the process
>  To clear the soft-dirty bit
>      > echo 4 > /proc/PID/clear_refs
>  
> +To reset the peak resident set size ("high water mark")
> +    > echo 5 > /proc/PID/clear_refs
> +
>  Any other value written to /proc/PID/clear_refs will have no effect.
>  
>  The /proc/pid/pagemap gives the PFN, which can be used to find the pageflags
> diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
> index 4e0388c..86b23b2 100644
> --- a/fs/proc/task_mmu.c
> +++ b/fs/proc/task_mmu.c
> @@ -712,6 +712,7 @@ enum clear_refs_types {
>  	CLEAR_REFS_ANON,
>  	CLEAR_REFS_MAPPED,
>  	CLEAR_REFS_SOFT_DIRTY,
> +	CLEAR_REFS_MM_HIWATER_RSS,
>  	CLEAR_REFS_LAST,
>  };
>  
> @@ -818,56 +819,69 @@ static ssize_t clear_refs_write(struct file *file, const char __user *buf,
>  		return -ESRCH;
>  	mm = get_task_mm(task);
>  	if (mm) {
> -		struct clear_refs_private cp = {
> -			.type = type,
> -		};

This function suffers from excessive indentation, even before your patch.
In the "!mm" case, all we do is put the task struct and return, so I think
you should add a preliminary patch that does nothing but change this, e.g.,

	if (!mm) {
		put_task_struct(task);
		return count;
	}

	down_read(&mm->mmap_sem);
	...

You'll have to rework the declarations a bit, and maybe you want a goto
instead of a return, so the put_task_struct() isn't duplicated.  The point
is that this will remove a level of indentation for the main body of the
function.

So it'd be nice to fix that with an initial patch that does nothing but fix
the style.  Then the follow-on patch that adds your functionality will be
much smaller and easier to review.  You're doing a simple thing, and the
patch should look simple :)

Bjorn

> -		struct mm_walk clear_refs_walk = {
> -			.pmd_entry = clear_refs_pte_range,
> -			.mm = mm,
> -			.private = &cp,
> -		};
> -		down_read(&mm->mmap_sem);
> -		if (type == CLEAR_REFS_SOFT_DIRTY) {
> -			for (vma = mm->mmap; vma; vma = vma->vm_next) {
> -				if (!(vma->vm_flags & VM_SOFTDIRTY))
> -					continue;
> -				up_read(&mm->mmap_sem);
> -				down_write(&mm->mmap_sem);
> +		if (type == CLEAR_REFS_MM_HIWATER_RSS) {
> +			/*
> +			 * Writing 5 to /proc/pid/clear_refs resets the peak
> +			 * resident set size.
> +			 */
> +			down_write(&mm->mmap_sem);
> +			reset_mm_hiwater_rss(mm);
> +			up_write(&mm->mmap_sem);
> +		} else {
> +			struct clear_refs_private cp = {
> +				.type = type,
> +			};
> +			struct mm_walk clear_refs_walk = {
> +				.pmd_entry = clear_refs_pte_range,
> +				.mm = mm,
> +				.private = &cp,
> +			};
> +			down_read(&mm->mmap_sem);
> +			if (type == CLEAR_REFS_SOFT_DIRTY) {
>  				for (vma = mm->mmap; vma; vma = vma->vm_next) {
> -					vma->vm_flags &= ~VM_SOFTDIRTY;
> -					vma_set_page_prot(vma);
> +					if (!(vma->vm_flags & VM_SOFTDIRTY))
> +						continue;
> +					up_read(&mm->mmap_sem);
> +					down_write(&mm->mmap_sem);
> +					for (vma = mm->mmap; vma;
> +					     vma = vma->vm_next) {
> +						vma->vm_flags &= ~VM_SOFTDIRTY;
> +						vma_set_page_prot(vma);
> +					}
> +					downgrade_write(&mm->mmap_sem);
> +					break;
>  				}
> -				downgrade_write(&mm->mmap_sem);
> -				break;
> +				mmu_notifier_invalidate_range_start(mm, 0, -1);
>  			}
> -			mmu_notifier_invalidate_range_start(mm, 0, -1);
> -		}
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
> -			walk_page_range(vma->vm_start, vma->vm_end,
> -					&clear_refs_walk);
> +			for (vma = mm->mmap; vma; vma = vma->vm_next) {
> +				cp.vma = vma;
> +				if (is_vm_hugetlb_page(vma))
> +					continue;
> +				/*
> +				 * Writing 1 to /proc/pid/clear_refs affects all
> +				 * pages.
> +				 *
> +				 * Writing 2 to /proc/pid/clear_refs only
> +				 * affects Anonymous pages.
> +				 *
> +				 * Writing 3 to /proc/pid/clear_refs only
> +				 * affects file mapped pages.
> +				 *
> +				 * Writing 4 to /proc/pid/clear_refs affects all
> +				 * pages.
> +				 */
> +				if (type == CLEAR_REFS_ANON && vma->vm_file)
> +					continue;
> +				if (type == CLEAR_REFS_MAPPED && !vma->vm_file)
> +					continue;
> +				walk_page_range(vma->vm_start, vma->vm_end,
> +						&clear_refs_walk);
> +			}
> +			if (type == CLEAR_REFS_SOFT_DIRTY)
> +				mmu_notifier_invalidate_range_end(mm, 0, -1);
> +			flush_tlb_mm(mm);
> +			up_read(&mm->mmap_sem);
>  		}
> -		if (type == CLEAR_REFS_SOFT_DIRTY)
> -			mmu_notifier_invalidate_range_end(mm, 0, -1);
> -		flush_tlb_mm(mm);
> -		up_read(&mm->mmap_sem);
>  		mmput(mm);
>  	}
>  	put_task_struct(task);
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index b464611..8a51ef4 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -1350,6 +1350,11 @@ static inline void update_hiwater_vm(struct mm_struct *mm)
>  		mm->hiwater_vm = mm->total_vm;
>  }
>  
> +static inline void reset_mm_hiwater_rss(struct mm_struct *mm)
> +{
> +	mm->hiwater_rss = get_mm_rss(mm);
> +}
> +
>  static inline void setmax_mm_hiwater_rss(unsigned long *maxrss,
>  					 struct mm_struct *mm)
>  {
> -- 
> 2.2.0.rc0.207.ga3a616c
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
