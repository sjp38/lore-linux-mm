Date: Tue, 26 Apr 2005 23:23:30 -0700
From: Chris Wright <chrisw@osdl.org>
Subject: Re: rlimit_as-checking-fix.patch
Message-ID: <20050427062330.GN493@shell0.pdx.osdl.net>
References: <20050425195556.092d0579.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20050425195556.092d0579.akpm@osdl.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Hugh Dickins <hugh@veritas.com>, Chris Wright <chrisw@osdl.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

* Andrew Morton (akpm@osdl.org) wrote:
> review, please?
> 
> Address bug #4508: there's potential for wraparound in the various places
> where we perform RLIMIT_AS checking.

Hrm, I suppose RLIMIT_MEMLOCK has same fundamental problem.

> (I'm a bit worried about acct_stack_growth().  Are we sure that vma->vm_mm is
> always equal to current->mm?  If not, then we're comapring some other
> process's total_vm with the calling process's rlimits).

No, get_user_pages() looks like an offender here.  Fine for all cases
but ptrace.  In some odd way, it makes sense to compare against caller rlimits
for ptrace.  Real problem would be accounting to wrong mm->total_vm.

> Signed-off-by: Andrew Morton <akpm@osdl.org>
> ---
> 
>  include/linux/mm.h |    1 +
>  mm/mmap.c          |   24 +++++++++++++++++++-----
>  mm/mremap.c        |    6 +++---
>  3 files changed, 23 insertions(+), 8 deletions(-)
> 
> diff -puN mm/mmap.c~rlimit_as-checking-fix mm/mmap.c
> --- 25/mm/mmap.c~rlimit_as-checking-fix	2005-04-25 19:54:35.685820728 -0700
> +++ 25-akpm/mm/mmap.c	2005-04-25 19:54:41.867880912 -0700
> @@ -1009,8 +1009,7 @@ munmap_back:
>  	}
>  
>  	/* Check against address space limit. */
> -	if ((mm->total_vm << PAGE_SHIFT) + len
> -	    > current->signal->rlim[RLIMIT_AS].rlim_cur)
> +	if (!may_expand_vm(mm, len))
>  		return -ENOMEM;
>  
>  	if (accountable && (!(flags & MAP_NORESERVE) ||
> @@ -1421,7 +1420,7 @@ static int acct_stack_growth(struct vm_a
>  	struct rlimit *rlim = current->signal->rlim;
>  
>  	/* address space limit tests */
> -	if (mm->total_vm + grow > rlim[RLIMIT_AS].rlim_cur >> PAGE_SHIFT)
> +	if (!may_expand_vm(mm, grow))

Here grow is already in pages.

>  		return -ENOMEM;
>  
>  	/* Stack limit test */
> @@ -1848,8 +1847,7 @@ unsigned long do_brk(unsigned long addr,
>  	}
>  
>  	/* Check against address space limits *after* clearing old maps... */
> -	if ((mm->total_vm << PAGE_SHIFT) + len
> -	    > current->signal->rlim[RLIMIT_AS].rlim_cur)
> +	if (!may_expand_vm(mm, len))
>  		return -ENOMEM;
>  
>  	if (mm->map_count > sysctl_max_map_count)
> @@ -2019,3 +2017,19 @@ struct vm_area_struct *copy_vma(struct v
>  	}
>  	return new_vma;
>  }
> +
> +/*
> + * Return true if the calling process may expand its vm space by the passed
> + * number of bytes.
> + */
> +int may_expand_vm(struct mm_struct *mm, unsigned long nbytes)
> +{
> +	unsigned long cur = current->mm->total_vm;	/* pages */

I guess you meant simply mm->total_vm not current->mm->total_vm?

> +	unsigned long lim;
> +
> +	lim = current->signal->rlim[RLIMIT_AS].rlim_cur >> PAGE_SHIFT;
> +
> +	if (cur + nbytes > lim)

I think there's a missing shift on nbytes to become a page count as well?

> +		return 0;
> +	return 1;
> +}
> diff -puN mm/mremap.c~rlimit_as-checking-fix mm/mremap.c
> --- 25/mm/mremap.c~rlimit_as-checking-fix	2005-04-25 19:54:35.685820728 -0700
> +++ 25-akpm/mm/mremap.c	2005-04-25 19:54:41.868880760 -0700
> @@ -347,10 +347,10 @@ unsigned long do_mremap(unsigned long ad
>  		if (locked > lock_limit && !capable(CAP_IPC_LOCK))
>  			goto out;
>  	}
> -	ret = -ENOMEM;
> -	if ((current->mm->total_vm << PAGE_SHIFT) + (new_len - old_len)
> -	    > current->signal->rlim[RLIMIT_AS].rlim_cur)
> +	if (!may_expand_vm(current->mm, new_len - old_len)) {
> +		ret = -ENOMEM;
>  		goto out;
> +	}
>  
>  	if (vma->vm_flags & VM_ACCOUNT) {
>  		charged = (new_len - old_len) >> PAGE_SHIFT;
> diff -puN include/linux/mm.h~rlimit_as-checking-fix include/linux/mm.h
> --- 25/include/linux/mm.h~rlimit_as-checking-fix	2005-04-25 19:54:35.686820576 -0700
> +++ 25-akpm/include/linux/mm.h	2005-04-25 19:54:41.869880608 -0700
> @@ -726,6 +726,7 @@ extern void __vma_link_rb(struct mm_stru
>  extern struct vm_area_struct *copy_vma(struct vm_area_struct **,
>  	unsigned long addr, unsigned long len, pgoff_t pgoff);
>  extern void exit_mmap(struct mm_struct *);
> +extern int may_expand_vm(struct mm_struct *mm, unsigned long nbytes);
>  
>  extern unsigned long get_unmapped_area(struct file *, unsigned long, unsigned long, unsigned long, unsigned long);
>  
> _

-- 
Linux Security Modules     http://lsm.immunix.org     http://lsm.bkbits.net
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
