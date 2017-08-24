Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 21CFA2806E4
	for <linux-mm@kvack.org>; Thu, 24 Aug 2017 02:23:28 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id w14so2613062wrc.3
        for <linux-mm@kvack.org>; Wed, 23 Aug 2017 23:23:28 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id d18si2753331wrg.272.2017.08.23.23.23.26
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 23 Aug 2017 23:23:26 -0700 (PDT)
Date: Thu, 24 Aug 2017 08:23:23 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: +
 fork-fix-incorrect-fput-of-exe_file-causing-use-after-free.patch added to
 -mm tree
Message-ID: <20170824062323.GB29811@dhcp22.suse.cz>
References: <599df6ce.5uMYbFyhgGY+BGEb%akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <599df6ce.5uMYbFyhgGY+BGEb%akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: ebiggers@google.com, dvyukov@google.com, koct9i@gmail.com, mingo@kernel.org, oleg@redhat.com, peterz@infradead.org, stable@vger.kernel.org, vbabka@suse.cz, mm-commits@vger.kernel.org, linux-mm@kvack.org

I do not see this email neither on lkml nor linux-mm mailing lists.
Strange

On Wed 23-08-17 14:42:38, Andrew Morton wrote:
> From: Eric Biggers <ebiggers@google.com>
> Subject: fork: fix incorrect fput of ->exe_file causing use-after-free
> 
> 7c051267931a ("mm, fork: make dup_mmap wait for mmap_sem for write
> killable") made it possible to kill a forking task while it is waiting to
> acquire its ->mmap_sem for write, in dup_mmap().  However, it was
> overlooked that this introduced an new error path before a reference is
> taken on the mm_struct's ->exe_file.  Since the ->exe_file of the new
> mm_struct was already set to the old ->exe_file by the memcpy() in
> dup_mm(), it was possible for the mmput() in the error path of dup_mm() to
> drop a reference to ->exe_file which was never taken.  This caused the
> struct file to later be freed prematurely.

Very well spotted!

> Fix it by updating mm_init() to NULL out the ->exe_file, in the same place
> it clears other things like the list of mmaps.

We do set the proper exec_file both when initializing bprm
(flush_old_exec) and dup_mmap so I guess this is correct. It is also
true that it is really fragile to keep a stale pointer we do not have a
reference to while the common mmput path will drop a reference. So this
looks like the proper way to go.

> 
> This bug was found by syzkaller.  It can be reproduced using the
> following C program:
> 
>     #define _GNU_SOURCE
>     #include <pthread.h>
>     #include <stdlib.h>
>     #include <sys/mman.h>
>     #include <sys/syscall.h>
>     #include <sys/wait.h>
>     #include <unistd.h>
> 
>     static void *mmap_thread(void *_arg)
>     {
>         for (;;) {
>             mmap(NULL, 0x1000000, PROT_READ,
>                  MAP_POPULATE|MAP_ANONYMOUS|MAP_PRIVATE, -1, 0);
>         }
>     }
> 
>     static void *fork_thread(void *_arg)
>     {
>         usleep(rand() % 10000);
>         fork();
>     }
> 
>     int main(void)
>     {
>         fork();
>         fork();
>         fork();
>         for (;;) {
>             if (fork() == 0) {
>                 pthread_t t;
> 
>                 pthread_create(&t, NULL, mmap_thread, NULL);
>                 pthread_create(&t, NULL, fork_thread, NULL);
>                 usleep(rand() % 10000);
>                 syscall(__NR_exit_group, 0);
>             }
>             wait(NULL);
>         }
>     }
> 
> No special kernel config options are needed.  It usually causes a NULL
> pointer dereference in __remove_shared_vm_struct() during exit, or in
> dup_mmap() (which is usually inlined into copy_process()) during fork. 
> Both are due to a vm_area_struct's ->vm_file being used after it's already
> been freed.
> 
> Google Bug Id: 64772007

Same here, do we need an internal reference?

> Link: http://lkml.kernel.org/r/20170823211408.31198-1-ebiggers3@gmail.com
> Fixes: 7c051267931a ("mm, fork: make dup_mmap wait for mmap_sem for write killable")
> Signed-off-by: Eric Biggers <ebiggers@google.com>
> Cc: Dmitry Vyukov <dvyukov@google.com>
> Cc: Ingo Molnar <mingo@kernel.org>
> Cc: Konstantin Khlebnikov <koct9i@gmail.com>
> Cc: Michal Hocko <mhocko@suse.com>
> Cc: Oleg Nesterov <oleg@redhat.com>
> Cc: Peter Zijlstra <peterz@infradead.org>
> Cc: Vlastimil Babka <vbabka@suse.cz>
> Cc: <stable@vger.kernel.org>	[v4.7+]
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
> 
>  kernel/fork.c |    1 +
>  1 file changed, 1 insertion(+)
> 
> diff -puN kernel/fork.c~fork-fix-incorrect-fput-of-exe_file-causing-use-after-free kernel/fork.c
> --- a/kernel/fork.c~fork-fix-incorrect-fput-of-exe_file-causing-use-after-free
> +++ a/kernel/fork.c
> @@ -806,6 +806,7 @@ static struct mm_struct *mm_init(struct
>  	mm_init_cpumask(mm);
>  	mm_init_aio(mm);
>  	mm_init_owner(mm, p);
> +	RCU_INIT_POINTER(mm->exe_file, NULL);
>  	mmu_notifier_mm_init(mm);
>  	init_tlb_flush_pending(mm);
>  #if defined(CONFIG_TRANSPARENT_HUGEPAGE) && !USE_SPLIT_PMD_PTLOCKS
> _
> 
> Patches currently in -mm which might be from ebiggers@google.com are
> 
> mm-madvise-fix-freeing-of-locked-page-with-madv_free.patch
> fork-fix-incorrect-fput-of-exe_file-causing-use-after-free.patch
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
