Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id C3C526B0038
	for <linux-mm@kvack.org>; Wed, 12 Aug 2015 05:42:45 -0400 (EDT)
Received: by wicja10 with SMTP id ja10so19914913wic.1
        for <linux-mm@kvack.org>; Wed, 12 Aug 2015 02:42:45 -0700 (PDT)
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com. [209.85.212.173])
        by mx.google.com with ESMTPS id u10si10505023wiv.111.2015.08.12.02.42.42
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Aug 2015 02:42:43 -0700 (PDT)
Received: by wicne3 with SMTP id ne3so210579101wic.1
        for <linux-mm@kvack.org>; Wed, 12 Aug 2015 02:42:42 -0700 (PDT)
Date: Wed, 12 Aug 2015 11:42:41 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v7 1/6] mm: mlock: Refactor mlock, munlock, and
 munlockall code
Message-ID: <20150812094241.GC14940@dhcp22.suse.cz>
References: <1439097776-27695-1-git-send-email-emunson@akamai.com>
 <1439097776-27695-2-git-send-email-emunson@akamai.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1439097776-27695-2-git-send-email-emunson@akamai.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Eric B Munson <emunson@akamai.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sun 09-08-15 01:22:51, Eric B Munson wrote:
> Extending the mlock system call is very difficult because it currently
> does not take a flags argument.  A later patch in this set will extend
> mlock to support a middle ground between pages that are locked and
> faulted in immediately and unlocked pages.  To pave the way for the new
> system call, the code needs some reorganization so that all the actual
> entry point handles is checking input and translating to VMA flags.

OK, I find the reorganized code more readable.

> Signed-off-by: Eric B Munson <emunson@akamai.com>
> Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Acked-by: Vlastimil Babka <vbabka@suse.cz>
> Cc: Michal Hocko <mhocko@suse.cz>
> Cc: Vlastimil Babka <vbabka@suse.cz>
> Cc: "Kirill A. Shutemov" <kirill@shutemov.name>
> Cc: linux-mm@kvack.org
> Cc: linux-kernel@vger.kernel.org

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  mm/mlock.c | 30 +++++++++++++++++-------------
>  1 file changed, 17 insertions(+), 13 deletions(-)
> 
> diff --git a/mm/mlock.c b/mm/mlock.c
> index 6fd2cf1..5692ee5 100644
> --- a/mm/mlock.c
> +++ b/mm/mlock.c
> @@ -553,7 +553,8 @@ out:
>  	return ret;
>  }
>  
> -static int do_mlock(unsigned long start, size_t len, int on)
> +static int apply_vma_lock_flags(unsigned long start, size_t len,
> +				vm_flags_t flags)
>  {
>  	unsigned long nstart, end, tmp;
>  	struct vm_area_struct * vma, * prev;
> @@ -575,14 +576,11 @@ static int do_mlock(unsigned long start, size_t len, int on)
>  		prev = vma;
>  
>  	for (nstart = start ; ; ) {
> -		vm_flags_t newflags;
> -
> -		/* Here we know that  vma->vm_start <= nstart < vma->vm_end. */
> +		vm_flags_t newflags = vma->vm_flags & ~VM_LOCKED;
>  
> -		newflags = vma->vm_flags & ~VM_LOCKED;
> -		if (on)
> -			newflags |= VM_LOCKED;
> +		newflags |= flags;
>  
> +		/* Here we know that  vma->vm_start <= nstart < vma->vm_end. */
>  		tmp = vma->vm_end;
>  		if (tmp > end)
>  			tmp = end;
> @@ -604,7 +602,7 @@ static int do_mlock(unsigned long start, size_t len, int on)
>  	return error;
>  }
>  
> -SYSCALL_DEFINE2(mlock, unsigned long, start, size_t, len)
> +static int do_mlock(unsigned long start, size_t len, vm_flags_t flags)
>  {
>  	unsigned long locked;
>  	unsigned long lock_limit;
> @@ -628,7 +626,7 @@ SYSCALL_DEFINE2(mlock, unsigned long, start, size_t, len)
>  
>  	/* check against resource limits */
>  	if ((locked <= lock_limit) || capable(CAP_IPC_LOCK))
> -		error = do_mlock(start, len, 1);
> +		error = apply_vma_lock_flags(start, len, flags);
>  
>  	up_write(&current->mm->mmap_sem);
>  	if (error)
> @@ -640,6 +638,11 @@ SYSCALL_DEFINE2(mlock, unsigned long, start, size_t, len)
>  	return 0;
>  }
>  
> +SYSCALL_DEFINE2(mlock, unsigned long, start, size_t, len)
> +{
> +	return do_mlock(start, len, VM_LOCKED);
> +}
> +
>  SYSCALL_DEFINE2(munlock, unsigned long, start, size_t, len)
>  {
>  	int ret;
> @@ -648,13 +651,13 @@ SYSCALL_DEFINE2(munlock, unsigned long, start, size_t, len)
>  	start &= PAGE_MASK;
>  
>  	down_write(&current->mm->mmap_sem);
> -	ret = do_mlock(start, len, 0);
> +	ret = apply_vma_lock_flags(start, len, 0);
>  	up_write(&current->mm->mmap_sem);
>  
>  	return ret;
>  }
>  
> -static int do_mlockall(int flags)
> +static int apply_mlockall_flags(int flags)
>  {
>  	struct vm_area_struct * vma, * prev = NULL;
>  
> @@ -662,6 +665,7 @@ static int do_mlockall(int flags)
>  		current->mm->def_flags |= VM_LOCKED;
>  	else
>  		current->mm->def_flags &= ~VM_LOCKED;
> +
>  	if (flags == MCL_FUTURE)
>  		goto out;
>  
> @@ -703,7 +707,7 @@ SYSCALL_DEFINE1(mlockall, int, flags)
>  
>  	if (!(flags & MCL_CURRENT) || (current->mm->total_vm <= lock_limit) ||
>  	    capable(CAP_IPC_LOCK))
> -		ret = do_mlockall(flags);
> +		ret = apply_mlockall_flags(flags);
>  	up_write(&current->mm->mmap_sem);
>  	if (!ret && (flags & MCL_CURRENT))
>  		mm_populate(0, TASK_SIZE);
> @@ -716,7 +720,7 @@ SYSCALL_DEFINE0(munlockall)
>  	int ret;
>  
>  	down_write(&current->mm->mmap_sem);
> -	ret = do_mlockall(0);
> +	ret = apply_mlockall_flags(0);
>  	up_write(&current->mm->mmap_sem);
>  	return ret;
>  }
> -- 
> 1.9.1

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
