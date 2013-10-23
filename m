Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 9E1D36B00DC
	for <linux-mm@kvack.org>; Wed, 23 Oct 2013 05:46:14 -0400 (EDT)
Received: by mail-pa0-f54.google.com with SMTP id kx10so905562pab.27
        for <linux-mm@kvack.org>; Wed, 23 Oct 2013 02:46:14 -0700 (PDT)
Received: from psmtp.com ([74.125.245.128])
        by mx.google.com with SMTP id js8si1510845pbc.104.2013.10.23.02.46.12
        for <linux-mm@kvack.org>;
        Wed, 23 Oct 2013 02:46:13 -0700 (PDT)
Message-ID: <52679ADD.3080202@suse.cz>
Date: Wed, 23 Oct 2013 11:46:05 +0200
From: Vlastimil Babka <vbabka@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH 2/3] mm/mlock: prepare params outside critical region
References: <1382057438-3306-1-git-send-email-davidlohr@hp.com> <1382057438-3306-3-git-send-email-davidlohr@hp.com>
In-Reply-To: <1382057438-3306-3-git-send-email-davidlohr@hp.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Davidlohr Bueso <davidlohr@hp.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>
Cc: Ingo Molnar <mingo@kernel.org>, Michel Lespinasse <walken@google.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, Tim Chen <tim.c.chen@linux.intel.com>, aswin@hp.com, linux-mm <linux-mm@kvack.org>, linux-kernel@vger.kernel.org

On 10/18/2013 02:50 AM, Davidlohr Bueso wrote:
> All mlock related syscalls prepare lock limits, lengths and
> start parameters with the mmap_sem held. Move this logic
> outside of the critical region. For the case of mlock, continue
> incrementing the amount already locked by mm->locked_vm with
> the rwsem taken.
> 
> Signed-off-by: Davidlohr Bueso <davidlohr@hp.com>
> Cc: Michel Lespinasse <walken@google.com>
> Cc: Vlastimil Babka <vbabka@suse.cz>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

> ---
>  mm/mlock.c | 18 +++++++++++-------
>  1 file changed, 11 insertions(+), 7 deletions(-)
> 
> diff --git a/mm/mlock.c b/mm/mlock.c
> index d480cd6..aa7de13 100644
> --- a/mm/mlock.c
> +++ b/mm/mlock.c
> @@ -689,19 +689,21 @@ SYSCALL_DEFINE2(mlock, unsigned long, start, size_t, len)
>  
>  	lru_add_drain_all();	/* flush pagevec */
>  
> -	down_write(&current->mm->mmap_sem);
>  	len = PAGE_ALIGN(len + (start & ~PAGE_MASK));
>  	start &= PAGE_MASK;
>  
> -	locked = len >> PAGE_SHIFT;
> -	locked += current->mm->locked_vm;
> -
>  	lock_limit = rlimit(RLIMIT_MEMLOCK);
>  	lock_limit >>= PAGE_SHIFT;
> +	locked = len >> PAGE_SHIFT;
> +
> +	down_write(&current->mm->mmap_sem);
> +
> +	locked += current->mm->locked_vm;
>  
>  	/* check against resource limits */
>  	if ((locked <= lock_limit) || capable(CAP_IPC_LOCK))
>  		error = do_mlock(start, len, 1);
> +
>  	up_write(&current->mm->mmap_sem);
>  	if (!error)
>  		error = __mm_populate(start, len, 0);
> @@ -712,11 +714,13 @@ SYSCALL_DEFINE2(munlock, unsigned long, start, size_t, len)
>  {
>  	int ret;
>  
> -	down_write(&current->mm->mmap_sem);
>  	len = PAGE_ALIGN(len + (start & ~PAGE_MASK));
>  	start &= PAGE_MASK;
> +
> +	down_write(&current->mm->mmap_sem);
>  	ret = do_mlock(start, len, 0);
>  	up_write(&current->mm->mmap_sem);
> +
>  	return ret;
>  }
>  
> @@ -761,12 +765,12 @@ SYSCALL_DEFINE1(mlockall, int, flags)
>  	if (flags & MCL_CURRENT)
>  		lru_add_drain_all();	/* flush pagevec */
>  
> -	down_write(&current->mm->mmap_sem);
> -
>  	lock_limit = rlimit(RLIMIT_MEMLOCK);
>  	lock_limit >>= PAGE_SHIFT;
>  
>  	ret = -ENOMEM;
> +	down_write(&current->mm->mmap_sem);
> +
>  	if (!(flags & MCL_CURRENT) || (current->mm->total_vm <= lock_limit) ||
>  	    capable(CAP_IPC_LOCK))
>  		ret = do_mlockall(flags);
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
