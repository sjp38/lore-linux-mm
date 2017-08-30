Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 339156B04A4
	for <linux-mm@kvack.org>; Tue, 29 Aug 2017 23:34:56 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id 63so2259223ioe.1
        for <linux-mm@kvack.org>; Tue, 29 Aug 2017 20:34:56 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 89sor2184050ioi.0.2017.08.29.20.34.54
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 29 Aug 2017 20:34:54 -0700 (PDT)
From: Eric Biggers <ebiggers3@gmail.com>
Subject: [PATCH] mm, uprobes: fix multiple free of ->uprobes_state.xol_area
Date: Tue, 29 Aug 2017 22:33:03 -0500
Message-Id: <20170830033303.17927-1-ebiggers3@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Oleg Nesterov <oleg@redhat.com>, Eric Biggers <ebiggers@google.com>, Alexander Shishkin <alexander.shishkin@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Arnaldo Carvalho de Melo <acme@kernel.org>, Dmitry Vyukov <dvyukov@google.com>, Ingo Molnar <mingo@kernel.org>, Konstantin Khlebnikov <koct9i@gmail.com>, Mark Rutland <mark.rutland@arm.com>, Michal Hocko <mhocko@suse.com>, Peter Zijlstra <peterz@infradead.org>, Vlastimil Babka <vbabka@suse.cz>, stable@vger.kernel.org

From: Eric Biggers <ebiggers@google.com>

Commit 7c051267931a ("mm, fork: make dup_mmap wait for mmap_sem for
write killable") made it possible to kill a forking task while it is
waiting to acquire its ->mmap_sem for write, in dup_mmap().

However, it was overlooked that this introduced an new error path before
the new mm_struct's ->uprobes_state.xol_area has been set to NULL after
being copied from the old mm_struct by the memcpy in dup_mm().  For a
task that has previously hit a uprobe tracepoint, this resulted in the
'struct xol_area' being freed multiple times if the task was killed at
just the right time while forking.

Fix it by setting ->uprobes_state.xol_area to NULL in mm_init() rather
than in uprobe_dup_mmap().

With CONFIG_UPROBE_EVENTS=y, the bug can be reproduced by the same C
program given by commit 2b7e8665b4ff ("fork: fix incorrect fput of
->exe_file causing use-after-free"), provided that a uprobe tracepoint
has been set on the fork_thread() function.  For example:

    $ gcc reproducer.c -o reproducer -lpthread
    $ nm reproducer | grep fork_thread
    0000000000400719 t fork_thread
    $ echo "p $PWD/reproducer:0x719" > /sys/kernel/debug/tracing/uprobe_events
    $ echo 1 > /sys/kernel/debug/tracing/events/uprobes/enable
    $ ./reproducer

Here is the use-after-free reported by KASAN:

    BUG: KASAN: use-after-free in uprobe_clear_state+0x1c4/0x200
    Read of size 8 at addr ffff8800320a8b88 by task reproducer/198

    CPU: 1 PID: 198 Comm: reproducer Not tainted 4.13.0-rc7-00015-g36fde05f3fb5 #255
    Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.10.2-20170228_101828-anatol 04/01/2014
    Call Trace:
     dump_stack+0xdb/0x185
     print_address_description+0x7e/0x290
     kasan_report+0x23b/0x350
     __asan_report_load8_noabort+0x19/0x20
     uprobe_clear_state+0x1c4/0x200
     mmput+0xd6/0x360
     do_exit+0x740/0x1670
     do_group_exit+0x13f/0x380
     get_signal+0x597/0x17d0
     do_signal+0x99/0x1df0
     exit_to_usermode_loop+0x166/0x1e0
     syscall_return_slowpath+0x258/0x2c0
     entry_SYSCALL_64_fastpath+0xbc/0xbe

    ...

    Allocated by task 199:
     save_stack_trace+0x1b/0x20
     kasan_kmalloc+0xfc/0x180
     kmem_cache_alloc_trace+0xf3/0x330
     __create_xol_area+0x10f/0x780
     uprobe_notify_resume+0x1674/0x2210
     exit_to_usermode_loop+0x150/0x1e0
     prepare_exit_to_usermode+0x14b/0x180
     retint_user+0x8/0x20

    Freed by task 199:
     save_stack_trace+0x1b/0x20
     kasan_slab_free+0xa8/0x1a0
     kfree+0xba/0x210
     uprobe_clear_state+0x151/0x200
     mmput+0xd6/0x360
     copy_process.part.8+0x605f/0x65d0
     _do_fork+0x1a5/0xbd0
     SyS_clone+0x19/0x20
     do_syscall_64+0x22f/0x660
     return_from_SYSCALL_64+0x0/0x7a

Note: without KASAN, you may instead see a "Bad page state" message, or
simply a general protection fault.

Fixes: 7c051267931a ("mm, fork: make dup_mmap wait for mmap_sem for write killable")
Reported-by: Oleg Nesterov <oleg@redhat.com>
Cc: Alexander Shishkin <alexander.shishkin@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Arnaldo Carvalho de Melo <acme@kernel.org>
Cc: Dmitry Vyukov <dvyukov@google.com>
Cc: Ingo Molnar <mingo@kernel.org>
Cc: Konstantin Khlebnikov <koct9i@gmail.com>
Cc: Mark Rutland <mark.rutland@arm.com>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Vlastimil Babka <vbabka@suse.cz>
Cc: <stable@vger.kernel.org>    [v4.7+]
Signed-off-by: Eric Biggers <ebiggers@google.com>
---
 kernel/events/uprobes.c | 2 --
 kernel/fork.c           | 8 ++++++++
 2 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/kernel/events/uprobes.c b/kernel/events/uprobes.c
index 0e137f98a50c..267f6ef91d97 100644
--- a/kernel/events/uprobes.c
+++ b/kernel/events/uprobes.c
@@ -1262,8 +1262,6 @@ void uprobe_end_dup_mmap(void)
 
 void uprobe_dup_mmap(struct mm_struct *oldmm, struct mm_struct *newmm)
 {
-	newmm->uprobes_state.xol_area = NULL;
-
 	if (test_bit(MMF_HAS_UPROBES, &oldmm->flags)) {
 		set_bit(MMF_HAS_UPROBES, &newmm->flags);
 		/* unconditionally, dup_mmap() skips VM_DONTCOPY vmas */
diff --git a/kernel/fork.c b/kernel/fork.c
index cbbea277b3fb..b7e9e57b71ea 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -785,6 +785,13 @@ static void mm_init_owner(struct mm_struct *mm, struct task_struct *p)
 #endif
 }
 
+static void mm_init_uprobes_state(struct mm_struct *mm)
+{
+#ifdef CONFIG_UPROBES
+	mm->uprobes_state.xol_area = NULL;
+#endif
+}
+
 static struct mm_struct *mm_init(struct mm_struct *mm, struct task_struct *p,
 	struct user_namespace *user_ns)
 {
@@ -812,6 +819,7 @@ static struct mm_struct *mm_init(struct mm_struct *mm, struct task_struct *p,
 #if defined(CONFIG_TRANSPARENT_HUGEPAGE) && !USE_SPLIT_PMD_PTLOCKS
 	mm->pmd_huge_pte = NULL;
 #endif
+	mm_init_uprobes_state(mm);
 
 	if (current->mm) {
 		mm->flags = current->mm->flags & MMF_INIT_MASK;
-- 
2.14.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
