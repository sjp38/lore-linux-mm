Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f41.google.com (mail-oi0-f41.google.com [209.85.218.41])
	by kanga.kvack.org (Postfix) with ESMTP id 276936B0255
	for <linux-mm@kvack.org>; Mon, 14 Dec 2015 10:00:02 -0500 (EST)
Received: by oiai186 with SMTP id i186so25113787oia.2
        for <linux-mm@kvack.org>; Mon, 14 Dec 2015 07:00:02 -0800 (PST)
Received: from userp1040.oracle.com (userp1040.oracle.com. [156.151.31.81])
        by mx.google.com with ESMTPS id hl3si10403147obb.24.2015.12.14.07.00.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Dec 2015 07:00:01 -0800 (PST)
Date: Mon, 14 Dec 2015 15:51:26 +0100
From: Quentin Casasnovas <quentin.casasnovas@oracle.com>
Subject: Re: [RFC 1/2] [RFC] mm: Account anon mappings as RLIMIT_DATA
Message-ID: <20151214145126.GC3604@chrystal.uk.oracle.com>
References: <20151213201646.839778758@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151213201646.839778758@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Cyrill Gorcunov <gorcunov@gmail.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Quentin Casasnovas <quentin.casasnovas@oracle.com>, Vegard Nossum <vegard.nossum@oracle.com>, Linus Torvalds <torvalds@linux-foundation.org>, Willy Tarreau <w@1wt.eu>, Andy Lutomirski <luto@amacapital.net>, Kees Cook <keescook@google.com>, Vladimir Davydov <vdavydov@virtuozzo.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Pavel Emelyanov <xemul@virtuozzo.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Cyrill Gorcunov <gorcunov@openvz.org>

On Sun, Dec 13, 2015 at 11:14:19PM +0300, Cyrill Gorcunov wrote:
> When inspecting a vague code inside prctl(PR_SET_MM_MEM)
> call (which testing the RLIMIT_DATA value to figure out
> if we're allowed to assign new @start_brk, @brk, @start_data,
> @end_data from mm_struct) it's been commited that RLIMIT_DATA
> in a form it's implemented now doesn't do anything useful
> because most of user-space libraries use mmap() syscall
> for dynamic memory allocations.
> 
> So Linus suggested to convert RLIMIT_DATA rlimit into something
> suitable for anonymous memory accounting. Here we introduce
> new @anon_vm member into mm descriptor which is updated
> on every vm_stat_account() call.
> 
> Tests for RLIMIT_DATA are done in three places:
>  - mmap_region: when user calls mmap() helper
>  - do_brk: for brk() helper
>  - vma_to_resize: when mremap() is used
> 
> The do_brk() is also used in vm_brk() which is called
> when the kernel loads Elf and aout files to execute.
> 
> Because test for limit is done in do_brk helper we
> no longer need to call check_data_rlimit here.
> 
> v2:
>  - update doc
>  - add may_expand_anon_vm helper
>  - call for RLIMIT_DATA test in mremap and do_brk
> 
> CC: Quentin Casasnovas <quentin.casasnovas@oracle.com>
> CC: Vegard Nossum <vegard.nossum@oracle.com>
> CC: Linus Torvalds <torvalds@linux-foundation.org>
> CC: Willy Tarreau <w@1wt.eu>
> CC: Andy Lutomirski <luto@amacapital.net>
> CC: Kees Cook <keescook@google.com>
> CC: Vladimir Davydov <vdavydov@virtuozzo.com>
> CC: Konstantin Khlebnikov <koct9i@gmail.com>
> CC: Pavel Emelyanov <xemul@virtuozzo.com>
> CC: Vladimir Davydov <vdavydov@virtuozzo.com>
> CC: Peter Zijlstra <a.p.zijlstra@chello.nl>
> Signed-off-by: Cyrill Gorcunov <gorcunov@openvz.org>
> ---
>  Documentation/filesystems/proc.txt |    1 
>  fs/proc/task_mmu.c                 |    2 +
>  include/linux/mm_types.h           |    1 
>  mm/mmap.c                          |   46 ++++++++++++++++++++++---------------
>  mm/mremap.c                        |    5 ++++
>  5 files changed, 37 insertions(+), 18 deletions(-)
> 
> Index: linux-ml.git/Documentation/filesystems/proc.txt
> ===================================================================
> --- linux-ml.git.orig/Documentation/filesystems/proc.txt
> +++ linux-ml.git/Documentation/filesystems/proc.txt
> @@ -233,6 +233,7 @@ Table 1-2: Contents of the status files
>   VmHWM                       peak resident set size ("high water mark")
>   VmRSS                       size of memory portions
>   VmData                      size of data, stack, and text segments
> + VmAnon                      size of anonymous private memory (not file backended)
>   VmStk                       size of data, stack, and text segments
>   VmExe                       size of text segment
>   VmLib                       size of shared library code
> Index: linux-ml.git/fs/proc/task_mmu.c
> ===================================================================
> --- linux-ml.git.orig/fs/proc/task_mmu.c
> +++ linux-ml.git/fs/proc/task_mmu.c
> @@ -53,6 +53,7 @@ void task_mem(struct seq_file *m, struct
>  		"VmHWM:\t%8lu kB\n"
>  		"VmRSS:\t%8lu kB\n"
>  		"VmData:\t%8lu kB\n"
> +		"VmAnon:\t%8lu kB\n"
>  		"VmStk:\t%8lu kB\n"
>  		"VmExe:\t%8lu kB\n"
>  		"VmLib:\t%8lu kB\n"
> @@ -66,6 +67,7 @@ void task_mem(struct seq_file *m, struct
>  		hiwater_rss << (PAGE_SHIFT-10),
>  		total_rss << (PAGE_SHIFT-10),
>  		data << (PAGE_SHIFT-10),
> +		mm->anon_vm << (PAGE_SHIFT-10),
>  		mm->stack_vm << (PAGE_SHIFT-10), text, lib,
>  		ptes >> 10,
>  		pmds >> 10,
> Index: linux-ml.git/include/linux/mm_types.h
> ===================================================================
> --- linux-ml.git.orig/include/linux/mm_types.h
> +++ linux-ml.git/include/linux/mm_types.h
> @@ -429,6 +429,7 @@ struct mm_struct {
>  	unsigned long shared_vm;	/* Shared pages (files) */
>  	unsigned long exec_vm;		/* VM_EXEC & ~VM_WRITE */
>  	unsigned long stack_vm;		/* VM_GROWSUP/DOWN */
> +	unsigned long anon_vm;		/* Anonymous pages mapped */
>  	unsigned long def_flags;
>  	unsigned long start_code, end_code, start_data, end_data;
>  	unsigned long start_brk, brk, start_stack;
> Index: linux-ml.git/mm/mmap.c
> ===================================================================
> --- linux-ml.git.orig/mm/mmap.c
> +++ linux-ml.git/mm/mmap.c
> @@ -309,16 +309,6 @@ SYSCALL_DEFINE1(brk, unsigned long, brk)
>  	if (brk < min_brk)
>  		goto out;
>  
> -	/*
> -	 * Check against rlimit here. If this check is done later after the test
> -	 * of oldbrk with newbrk then it can escape the test and let the data
> -	 * segment grow beyond its set limit the in case where the limit is
> -	 * not page aligned -Ram Gupta
> -	 */
> -	if (check_data_rlimit(rlimit(RLIMIT_DATA), brk, mm->start_brk,
> -			      mm->end_data, mm->start_data))
> -		goto out;
> -
>  	newbrk = PAGE_ALIGN(brk);
>  	oldbrk = PAGE_ALIGN(mm->brk);
>  	if (oldbrk == newbrk)
> @@ -1223,6 +1213,9 @@ void vm_stat_account(struct mm_struct *m
>  			mm->exec_vm += pages;
>  	} else if (flags & stack_flags)
>  		mm->stack_vm += pages;
> +
> +	if (anon_accountable_mapping(file, flags))
> +		mm->anon_vm += pages;
>  }
>  #endif /* CONFIG_PROC_FS */
>  
> @@ -1578,6 +1571,14 @@ unsigned long mmap_region(struct file *f
>  	}
>  
>  	/*
> +	 * For anon mappings make sure we don't exceed the limit.
> +	 */
> +	if (anon_accountable_mapping(file, vm_flags)) {
> +		if (!may_expand_anon_vm(mm, len >> PAGE_SHIFT))
> +			return -ENOMEM;
> +	}
> +
> +	/*
>  	 * Can we just expand an old mapping?
>  	 */
>  	vma = vma_merge(mm, prev, addr, addr + len, vm_flags,
> @@ -2760,7 +2761,8 @@ static unsigned long do_brk(unsigned lon
>  	}
>  
>  	/* Check against address space limits *after* clearing old maps... */
> -	if (!may_expand_vm(mm, len >> PAGE_SHIFT))
> +	if (!may_expand_vm(mm, len >> PAGE_SHIFT) ||
> +	    !may_expand_anon_vm(mm, len >> PAGE_SHIFT))
>  		return -ENOMEM;
>  
>  	if (mm->map_count > sysctl_max_map_count)
> @@ -2795,6 +2797,7 @@ static unsigned long do_brk(unsigned lon
>  out:
>  	perf_event_mmap(vma);
>  	mm->total_vm += len >> PAGE_SHIFT;
> +	mm->anon_vm += len >> PAGE_SHIFT;
>  	if (flags & VM_LOCKED)
>  		mm->locked_vm += (len >> PAGE_SHIFT);
>  	vma->vm_flags |= VM_SOFTDIRTY;
> @@ -2982,20 +2985,27 @@ out:
>  	return NULL;
>  }
>  
> +static inline int __may_expand_vm(unsigned int limit,
> +				  unsigned long cur,
> +				  unsigned long npages)
> +{
> +	unsigned long lim = rlimit(limit) >> PAGE_SHIFT;
> +
> +	return ((cur + npages) > lim) ? 0 : 1;
> +}
> +
>  /*
>   * Return true if the calling process may expand its vm space by the passed
>   * number of pages
>   */
>  int may_expand_vm(struct mm_struct *mm, unsigned long npages)
>  {
> -	unsigned long cur = mm->total_vm;	/* pages */
> -	unsigned long lim;
> -
> -	lim = rlimit(RLIMIT_AS) >> PAGE_SHIFT;
> +	return __may_expand_vm(RLIMIT_AS, mm->total_vm, npages);
> +}
>  
> -	if (cur + npages > lim)
> -		return 0;
> -	return 1;
> +int may_expand_anon_vm(struct mm_struct *mm, unsigned long npages)
> +{
> +	return __may_expand_vm(RLIMIT_DATA, mm->anon_vm, npages);
>  }
>

Do we want to fold may_expand_anon_vm() into may_expand_vm() (potentially
passing it the flags/struct file if needed) so there is just one such
helper function?  Rationale being that it then gets hard to see what
restricts what, and it's easy to miss one place.

For example, I couldn't find anything preventing a user to
mmap(MAP_GROWSDOWN) and uses that as a base to get pages that would not be
accounted for in your patch (making it a poor-man mremap()).

I only had a quick look so apologies if this is handled and I missed it :)

Quentin

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
