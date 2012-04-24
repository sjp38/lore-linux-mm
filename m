Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx201.postini.com [74.125.245.201])
	by kanga.kvack.org (Postfix) with SMTP id 1F51B6B0044
	for <linux-mm@kvack.org>; Tue, 24 Apr 2012 15:02:11 -0400 (EDT)
Received: by iajr24 with SMTP id r24so1943847iaj.14
        for <linux-mm@kvack.org>; Tue, 24 Apr 2012 12:02:10 -0700 (PDT)
Date: Tue, 24 Apr 2012 12:01:52 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH] Fix overflow in vma length when copying mmap on clone
In-Reply-To: <1335289853-2923-1-git-send-email-siddhesh.poyarekar@gmail.com>
Message-ID: <alpine.LSU.2.00.1204241148390.18455@eggly.anvils>
References: <1335289853-2923-1-git-send-email-siddhesh.poyarekar@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Siddhesh Poyarekar <siddhesh.poyarekar@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Oleg Nesterov <oleg@redhat.com>, Jens Axboe <axboe@kernel.dk>, Peter Zijlstra <a.p.zijlstra@chello.nl>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, 24 Apr 2012, Siddhesh Poyarekar wrote:
> The vma length in dup_mmap is calculated and stored in a unsigned int,
> which is insufficient and hence overflows for very large maps (beyond
> 16TB). The following program demonstrates this:
> 
> \#include <stdio.h>
> \#include <unistd.h>
> \#include <sys/mman.h>
> 
> \#define GIG 1024 * 1024 * 1024L
> \#define EXTENT 16393
> 
> int main(void)
> {
>         int i, r;
>         void *m;
>         char buf[1024];
> 
>         for (i = 0; i < EXTENT; i++) {
>                 m = mmap(NULL, (size_t) 1 * 1024 * 1024 * 1024L,
>                          PROT_READ | PROT_WRITE, MAP_PRIVATE | MAP_ANONYMOUS, 0, 0);
> 
>                 if (m == (void *)-1)
>                         printf("MMAP Failed: %d\n", m);
>                 else
>                         printf("%d : MMAP returned %p\n", i, m);
> 
>                 r = fork();
> 
>                 if (r == 0) {
>                         printf("%d: successed\n", i);
>                         return 0;
>                 } else if (r < 0)
>                         printf("FORK Failed: %d\n", r);
>                 else if (r > 0)
>                         wait(NULL);
>         }
>         return 0;
> }
> 
> This trivial patch increases the storage size of the result to
> unsigned long, which should be sufficient for storing the difference
> between addresses.
> 
> Signed-off-by: Siddhesh Poyarekar <siddhesh.poyarekar@gmail.com>

Good catch, thank you, remarkable that's survived for so long.
For the patch,

Acked-by: Hugh Dickins <hughd@google.com>
Cc: stable@vger.kernel.org

But I didn't (try very hard to) work out what your demo program shows
- though I am amused by your sense of humour in using %d for a pointer
there!  I wonder what setting of /proc/sys/vm/overcommit_memory is
needed for it to behave as you intend?

Personally, I wouldn't bother with the demo and describing it more fully,
I'd just be glad to get that fix in at last.

> ---
>  kernel/fork.c |    3 ++-
>  1 files changed, 2 insertions(+), 1 deletions(-)
> 
> diff --git a/kernel/fork.c b/kernel/fork.c
> index b9372a0..7acaee1 100644
> --- a/kernel/fork.c
> +++ b/kernel/fork.c
> @@ -355,7 +355,8 @@ static int dup_mmap(struct mm_struct *mm, struct mm_struct *oldmm)
>  		}
>  		charge = 0;
>  		if (mpnt->vm_flags & VM_ACCOUNT) {
> -			unsigned int len = (mpnt->vm_end - mpnt->vm_start) >> PAGE_SHIFT;
> +			unsigned long len;
> +			len = (mpnt->vm_end - mpnt->vm_start) >> PAGE_SHIFT;
>  			if (security_vm_enough_memory_mm(oldmm, len)) /* sic */
>  				goto fail_nomem;
>  			charge = len;
> -- 
> 1.7.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
