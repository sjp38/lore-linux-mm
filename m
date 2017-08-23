Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 5575C6B04A5
	for <linux-mm@kvack.org>; Wed, 23 Aug 2017 17:15:57 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id b8so14722597pgn.10
        for <linux-mm@kvack.org>; Wed, 23 Aug 2017 14:15:57 -0700 (PDT)
Received: from mail-pg0-x244.google.com (mail-pg0-x244.google.com. [2607:f8b0:400e:c05::244])
        by mx.google.com with ESMTPS id j6si1600310pfc.471.2017.08.23.14.15.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 23 Aug 2017 14:15:56 -0700 (PDT)
Received: by mail-pg0-x244.google.com with SMTP id 189so820028pgj.0
        for <linux-mm@kvack.org>; Wed, 23 Aug 2017 14:15:55 -0700 (PDT)
From: Eric Biggers <ebiggers3@gmail.com>
Subject: [PATCH] fork: fix incorrect fput of ->exe_file causing use-after-free
Date: Wed, 23 Aug 2017 14:14:08 -0700
Message-Id: <20170823211408.31198-1-ebiggers3@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Dmitry Vyukov <dvyukov@google.com>, Ingo Molnar <mingo@kernel.org>, Konstantin Khlebnikov <koct9i@gmail.com>, Michal Hocko <mhocko@suse.com>, Oleg Nesterov <oleg@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Vlastimil Babka <vbabka@suse.cz>, stable@vger.kernel.org, Eric Biggers <ebiggers@google.com>

From: Eric Biggers <ebiggers@google.com>

Commit 7c051267931a ("mm, fork: make dup_mmap wait for mmap_sem for
write killable") made it possible to kill a forking task while it is
waiting to acquire its ->mmap_sem for write, in dup_mmap().  However, it
was overlooked that this introduced an new error path before a reference
is taken on the mm_struct's ->exe_file.  Since the ->exe_file of the new
mm_struct was already set to the old ->exe_file by the memcpy() in
dup_mm(), it was possible for the mmput() in the error path of dup_mm()
to drop a reference to ->exe_file which was never taken.  This caused
the struct file to later be freed prematurely.

Fix it by updating mm_init() to NULL out the ->exe_file, in the same
place it clears other things like the list of mmaps.

This bug was found by syzkaller.  It can be reproduced using the
following C program:

    #define _GNU_SOURCE
    #include <pthread.h>
    #include <stdlib.h>
    #include <sys/mman.h>
    #include <sys/syscall.h>
    #include <sys/wait.h>
    #include <unistd.h>

    static void *mmap_thread(void *_arg)
    {
        for (;;) {
            mmap(NULL, 0x1000000, PROT_READ,
                 MAP_POPULATE|MAP_ANONYMOUS|MAP_PRIVATE, -1, 0);
        }
    }

    static void *fork_thread(void *_arg)
    {
        usleep(rand() % 10000);
        fork();
    }

    int main(void)
    {
        fork();
        fork();
        fork();
        for (;;) {
            if (fork() == 0) {
                pthread_t t;

                pthread_create(&t, NULL, mmap_thread, NULL);
                pthread_create(&t, NULL, fork_thread, NULL);
                usleep(rand() % 10000);
                syscall(__NR_exit_group, 0);
            }
            wait(NULL);
        }
    }

No special kernel config options are needed.  It usually causes a NULL
pointer dereference in __remove_shared_vm_struct() during exit, or in
dup_mmap() (which is usually inlined into copy_process()) during fork.
Both are due to a vm_area_struct's ->vm_file being used after it's
already been freed.

Fixes: 7c051267931a ("mm, fork: make dup_mmap wait for mmap_sem for write killable")
Google-Bug-Id: 64772007
Cc: Dmitry Vyukov <dvyukov@google.com>
Cc: Ingo Molnar <mingo@kernel.org>
Cc: Konstantin Khlebnikov <koct9i@gmail.com>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Oleg Nesterov <oleg@redhat.com>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Vlastimil Babka <vbabka@suse.cz>
Cc: stable@vger.kernel.org # v4.7+
Signed-off-by: Eric Biggers <ebiggers@google.com>
---
 kernel/fork.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/kernel/fork.c b/kernel/fork.c
index e075b7780421..cbbea277b3fb 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -806,6 +806,7 @@ static struct mm_struct *mm_init(struct mm_struct *mm, struct task_struct *p,
 	mm_init_cpumask(mm);
 	mm_init_aio(mm);
 	mm_init_owner(mm, p);
+	RCU_INIT_POINTER(mm->exe_file, NULL);
 	mmu_notifier_mm_init(mm);
 	init_tlb_flush_pending(mm);
 #if defined(CONFIG_TRANSPARENT_HUGEPAGE) && !USE_SPLIT_PMD_PTLOCKS
-- 
2.14.1.342.g6490525c54-goog

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
