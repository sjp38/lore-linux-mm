Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx149.postini.com [74.125.245.149])
	by kanga.kvack.org (Postfix) with SMTP id 5187E6B005D
	for <linux-mm@kvack.org>; Tue,  8 Jan 2013 16:25:42 -0500 (EST)
Date: Tue, 8 Jan 2013 13:25:40 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm: remove redundant var retval in sys_brk
Message-Id: <20130108132540.e69c40f9.akpm@linux-foundation.org>
In-Reply-To: <1357352864-29258-1-git-send-email-yuanhan.liu@linux.intel.com>
References: <1357352864-29258-1-git-send-email-yuanhan.liu@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yuanhan Liu <yuanhan.liu@linux.intel.com>
Cc: linux-mm@kvack.org

On Sat,  5 Jan 2013 10:27:44 +0800
Yuanhan Liu <yuanhan.liu@linux.intel.com> wrote:

> There is only one possible return value of sys_brk, which is mm->brk no
> matter succeed or not.
> 
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Signed-off-by: Yuanhan Liu <yuanhan.liu@linux.intel.com>
> ---
>  mm/mmap.c |    5 ++---
>  1 files changed, 2 insertions(+), 3 deletions(-)
> 
> diff --git a/mm/mmap.c b/mm/mmap.c
> index f54b235..ae4093c 100644
> --- a/mm/mmap.c
> +++ b/mm/mmap.c
> @@ -251,7 +251,7 @@ static unsigned long do_brk(unsigned long addr, unsigned long len);
>  
>  SYSCALL_DEFINE1(brk, unsigned long, brk)
>  {
> -	unsigned long rlim, retval;
> +	unsigned long rlim;
>  	unsigned long newbrk, oldbrk;
>  	struct mm_struct *mm = current->mm;
>  	unsigned long min_brk;
> @@ -307,9 +307,8 @@ SYSCALL_DEFINE1(brk, unsigned long, brk)
>  set_brk:
>  	mm->brk = brk;
>  out:
> -	retval = mm->brk;
>  	up_write(&mm->mmap_sem);
> -	return retval;
> +	return mm->brk;
>  }

Moving the read outside the locked region opens the possibility that
this thread will pick up the results of modification by some other
thread.

Of course, if two threads are modifying brk at the same time then
that's a userspace problem which can still cuase inconsistent return
values, but I'm inclined to leave the code as-is just from a
quality-of-implementation POV: sys_brk() will reliably return the value
which *this thread* set.

The brk() syscall returns 0 on success, so I assume glibc is throwing
this value away anyway...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
