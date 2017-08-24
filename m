Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 768E2440846
	for <linux-mm@kvack.org>; Thu, 24 Aug 2017 13:52:53 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id 63so778621pgc.0
        for <linux-mm@kvack.org>; Thu, 24 Aug 2017 10:52:53 -0700 (PDT)
Received: from mail-pg0-x244.google.com (mail-pg0-x244.google.com. [2607:f8b0:400e:c05::244])
        by mx.google.com with ESMTPS id v43si3138150pgn.701.2017.08.24.10.52.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 24 Aug 2017 10:52:51 -0700 (PDT)
Received: by mail-pg0-x244.google.com with SMTP id a7so243617pgn.4
        for <linux-mm@kvack.org>; Thu, 24 Aug 2017 10:52:51 -0700 (PDT)
From: Eric Biggers <ebiggers3@gmail.com>
Subject: [PATCH] x86/mm: fix use-after-free of ldt_struct
Date: Thu, 24 Aug 2017 10:50:29 -0700
Message-Id: <20170824175029.76040-1-ebiggers3@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: x86@kernel.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Eric Biggers <ebiggers@google.com>, Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Borislav Petkov <bp@alien8.de>, Brian Gerst <brgerst@gmail.com>, Christoph Hellwig <hch@lst.de>, Dave Hansen <dave.hansen@linux.intel.com>, Denys Vlasenko <dvlasenk@redhat.com>, Dmitry Vyukov <dvyukov@google.com>, "H . Peter Anvin" <hpa@zytor.com>, Ingo Molnar <mingo@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Peter Zijlstra <peterz@infradead.org>, Rik van Riel <riel@redhat.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Thomas Gleixner <tglx@linutronix.de>, stable@vger.kernel.org

From: Eric Biggers <ebiggers@google.com>

Commit 39a0526fb3f7 ("x86/mm: Factor out LDT init from context init")
renamed init_new_context() to init_new_context_ldt() and added a new
init_new_context() which calls init_new_context_ldt().  However, the
error code of init_new_context_ldt() was ignored.  Consequently, if a
memory allocation in alloc_ldt_struct() failed during a fork(), the
->context.ldt of the new task remained the same as that of the old task
(due to the memcpy() in dup_mm()).  ldt_struct's are not intended to be
shared, so a use-after-free occurred after one task exited.

Fix the bug by making init_new_context() pass through the error code of
init_new_context_ldt().

This bug was found by syzkaller, which encountered the following splat:

    BUG: KASAN: use-after-free in free_ldt_struct.part.2+0x10a/0x150 arch/x86/kernel/ldt.c:116
    Read of size 4 at addr ffff88006d2cb7c8 by task kworker/u9:0/3710

    CPU: 1 PID: 3710 Comm: kworker/u9:0 Not tainted 4.13.0-rc4-next-20170811 #2
    Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Bochs 01/01/2011
    Call Trace:
     __dump_stack lib/dump_stack.c:16 [inline]
     dump_stack+0x194/0x257 lib/dump_stack.c:52
     print_address_description+0x73/0x250 mm/kasan/report.c:252
     kasan_report_error mm/kasan/report.c:351 [inline]
     kasan_report+0x24e/0x340 mm/kasan/report.c:409
     __asan_report_load4_noabort+0x14/0x20 mm/kasan/report.c:429
     free_ldt_struct.part.2+0x10a/0x150 arch/x86/kernel/ldt.c:116
     free_ldt_struct arch/x86/kernel/ldt.c:173 [inline]
     destroy_context_ldt+0x60/0x80 arch/x86/kernel/ldt.c:171
     destroy_context arch/x86/include/asm/mmu_context.h:157 [inline]
     __mmdrop+0xe9/0x530 kernel/fork.c:889
     mmdrop include/linux/sched/mm.h:42 [inline]
     exec_mmap fs/exec.c:1061 [inline]
     flush_old_exec+0x173c/0x1ff0 fs/exec.c:1291
     load_elf_binary+0x81f/0x4ba0 fs/binfmt_elf.c:855
     search_binary_handler+0x142/0x6b0 fs/exec.c:1652
     exec_binprm fs/exec.c:1694 [inline]
     do_execveat_common.isra.33+0x1746/0x22e0 fs/exec.c:1816
     do_execve+0x31/0x40 fs/exec.c:1860
     call_usermodehelper_exec_async+0x457/0x8f0 kernel/umh.c:100
     ret_from_fork+0x2a/0x40 arch/x86/entry/entry_64.S:431

    Allocated by task 3700:
     save_stack_trace+0x16/0x20 arch/x86/kernel/stacktrace.c:59
     save_stack+0x43/0xd0 mm/kasan/kasan.c:447
     set_track mm/kasan/kasan.c:459 [inline]
     kasan_kmalloc+0xad/0xe0 mm/kasan/kasan.c:551
     kmem_cache_alloc_trace+0x136/0x750 mm/slab.c:3627
     kmalloc include/linux/slab.h:493 [inline]
     alloc_ldt_struct+0x52/0x140 arch/x86/kernel/ldt.c:67
     write_ldt+0x7b7/0xab0 arch/x86/kernel/ldt.c:277
     sys_modify_ldt+0x1ef/0x240 arch/x86/kernel/ldt.c:307
     entry_SYSCALL_64_fastpath+0x1f/0xbe

    Freed by task 3700:
     save_stack_trace+0x16/0x20 arch/x86/kernel/stacktrace.c:59
     save_stack+0x43/0xd0 mm/kasan/kasan.c:447
     set_track mm/kasan/kasan.c:459 [inline]
     kasan_slab_free+0x71/0xc0 mm/kasan/kasan.c:524
     __cache_free mm/slab.c:3503 [inline]
     kfree+0xca/0x250 mm/slab.c:3820
     free_ldt_struct.part.2+0xdd/0x150 arch/x86/kernel/ldt.c:121
     free_ldt_struct arch/x86/kernel/ldt.c:173 [inline]
     destroy_context_ldt+0x60/0x80 arch/x86/kernel/ldt.c:171
     destroy_context arch/x86/include/asm/mmu_context.h:157 [inline]
     __mmdrop+0xe9/0x530 kernel/fork.c:889
     mmdrop include/linux/sched/mm.h:42 [inline]
     __mmput kernel/fork.c:916 [inline]
     mmput+0x541/0x6e0 kernel/fork.c:927
     copy_process.part.36+0x22e1/0x4af0 kernel/fork.c:1931
     copy_process kernel/fork.c:1546 [inline]
     _do_fork+0x1ef/0xfb0 kernel/fork.c:2025
     SYSC_clone kernel/fork.c:2135 [inline]
     SyS_clone+0x37/0x50 kernel/fork.c:2129
     do_syscall_64+0x26c/0x8c0 arch/x86/entry/common.c:287
     return_from_SYSCALL_64+0x0/0x7a

Here is a C reproducer:

    #include <asm/ldt.h>
    #include <pthread.h>
    #include <signal.h>
    #include <stdlib.h>
    #include <sys/syscall.h>
    #include <sys/wait.h>
    #include <unistd.h>

    static void *fork_thread(void *_arg)
    {
        fork();
    }

    int main(void)
    {
        struct user_desc desc = { .entry_number = 8191 };

        syscall(__NR_modify_ldt, 1, &desc, sizeof(desc));

        for (;;) {
            if (fork() == 0) {
                pthread_t t;

                srand(getpid());
                pthread_create(&t, NULL, fork_thread, NULL);
                usleep(rand() % 10000);
                syscall(__NR_exit_group, 0);
            }
            wait(NULL);
        }
    }

Note: the reproducer takes advantage of the fact that alloc_ldt_struct()
may use vmalloc to allocate a large ->entries array, and after
commit 5d17a73a2ebe ("vmalloc: back off when the current task is
killed") it is possible for userspace to fail a task's vmalloc by
sending a fatal signal, e.g. via exit_group().  It would be more
difficult to reproduce this bug on kernels without that commit.

This bug only affected kernels with CONFIG_MODIFY_LDT_SYSCALL=y.

Fixes: 39a0526fb3f7 ("x86/mm: Factor out LDT init from context init")
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Andy Lutomirski <luto@amacapital.net>
Cc: Borislav Petkov <bp@alien8.de>
Cc: Brian Gerst <brgerst@gmail.com>
Cc: Christoph Hellwig <hch@lst.de>
Cc: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Denys Vlasenko <dvlasenk@redhat.com>
Cc: Dmitry Vyukov <dvyukov@google.com>
Cc: H. Peter Anvin <hpa@zytor.com>
Cc: Ingo Molnar <mingo@kernel.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Rik van Riel <riel@redhat.com>
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: <stable@vger.kernel.org>    [v4.6+]
Signed-off-by: Eric Biggers <ebiggers@google.com>
---
 arch/x86/include/asm/mmu_context.h | 4 +---
 1 file changed, 1 insertion(+), 3 deletions(-)

diff --git a/arch/x86/include/asm/mmu_context.h b/arch/x86/include/asm/mmu_context.h
index d25d9f4abb15..7ae318c340d9 100644
--- a/arch/x86/include/asm/mmu_context.h
+++ b/arch/x86/include/asm/mmu_context.h
@@ -148,9 +148,7 @@ static inline int init_new_context(struct task_struct *tsk,
 		mm->context.execute_only_pkey = -1;
 	}
 	#endif
-	init_new_context_ldt(tsk, mm);
-
-	return 0;
+	return init_new_context_ldt(tsk, mm);
 }
 static inline void destroy_context(struct mm_struct *mm)
 {
-- 
2.14.1.342.g6490525c54-goog

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
