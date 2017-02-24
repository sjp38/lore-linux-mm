Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3352B6B038B
	for <linux-mm@kvack.org>; Fri, 24 Feb 2017 13:20:04 -0500 (EST)
Received: by mail-qk0-f200.google.com with SMTP id n186so24815819qkb.2
        for <linux-mm@kvack.org>; Fri, 24 Feb 2017 10:20:04 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id b28si6165674qta.263.2017.02.24.10.20.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 Feb 2017 10:20:03 -0800 (PST)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 1/3] userfaultfd: non-cooperative: rollback userfaultfd_exit
Date: Fri, 24 Feb 2017 19:19:55 +0100
Message-Id: <20170224181957.19736-2-aarcange@redhat.com>
In-Reply-To: <20170224181957.19736-1-aarcange@redhat.com>
References: <20170224181957.19736-1-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Michael Rapoport <RAPOPORT@il.ibm.com>, "Dr. David Alan Gilbert" <dgilbert@redhat.com>, Mike Kravetz <mike.kravetz@oracle.com>, Pavel Emelyanov <xemul@parallels.com>, Hillf Danton <hillf.zj@alibaba-inc.com>

I once reproduced this oops with the userfaultfd selftest, it's not
easily reproducible and it requires SLUB poisoning to reproduce.

general protection fault: 0000 [#1] SMP
Modules linked in:
CPU: 2 PID: 18421 Comm: userfaultfd Tainted: G               ------------ T 3.10.0+ #15
Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS rel-1.10.1-0-g8891697-prebuilt.qemu-project.org 04/01/2014
task: ffff8801f83b9440 ti: ffff8801f833c000 task.ti: ffff8801f833c000
RIP: 0010:[<ffffffff81451299>]  [<ffffffff81451299>] userfaultfd_exit+0x29/0xa0
RSP: 0018:ffff8801f833fe80  EFLAGS: 00010202
RAX: ffff8801f833ffd8 RBX: 6b6b6b6b6b6b6b6b RCX: ffff8801f83b9440
RDX: 0000000000000000 RSI: 0000000000000000 RDI: ffff8800baf18600
RBP: ffff8801f833fee8 R08: 0000000000000000 R09: 0000000000000001
R10: 0000000000000000 R11: ffffffff8127ceb3 R12: 0000000000000000
R13: ffff8800baf186b0 R14: ffff8801f83b99f8 R15: 00007faed746c700
FS:  0000000000000000(0000) GS:ffff88023fc80000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: 00007faf0966f028 CR3: 0000000001bc6000 CR4: 00000000000006e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Stack:
 ffffffff8127cec6 0000000000000001 0000000000000286 ffff8801f833fed0
 0000000000000286 ffff8801f83b99f8 ffff8800baf18600 ffff8800baf186b0
 ffff8801f83b99f8 ffff8801f83b99f8 ffff8801f833fee8 ffff8801f83b9440
Call Trace:
 [<ffffffff8127cec6>] ? do_exit+0x276/0xd10
 [<ffffffff8127cee7>] do_exit+0x297/0xd10
 [<ffffffff8137d113>] ? context_tracking_user_exit+0x13/0x20
 [<ffffffff8121c5ed>] ? syscall_trace_enter+0x13d/0x300
 [<ffffffff8127eda7>] SyS_exit+0x17/0x20
 [<ffffffff8183edeb>] tracesys+0xdd/0xe2
Code: 00 00 66 66 66 66 90 55 48 89 e5 41 54 53 48 83 ec 58 48 8b 1f 48 85 db 75 11 eb 73 66 0f 1f 44 00 00 48 8b 5b 10 48 85 db 74 64 <4c> 8b a3 b8 00 00 00 4d 85 e4 74 eb 41 f6 84 24 2c 01 00 00 80
RIP  [<ffffffff81451299>] userfaultfd_exit+0x29/0xa0
 RSP <ffff8801f833fe80>
---[ end trace 9fecd6dcb442846a ]---

In the debugger I located the "mm" pointer in the stack and walking
mm->mmap->vm_next through the end shows the vma->vm_next list is fully
consistent and it is null terminated list as expected. So this has to
be an SMP race condition where userfaultfd_exit was running while the
vma list was being modified by another CPU.

When userfaultfd_exit() run one of the ->vm_next pointers pointed to
SLAB_POISON (RBX is the vma pointer and is 0x6b6b..).

The reason is that it's not running in __mmput but while there are
still other threads running and it's not holding the mmap_sem (it
can't as it has to wait the even to be received by the manager). So
this is an use after free that was happening for all processes.

One more implementation problem aside from the race condition:
userfaultfd_exit has really to check a flag in mm->flags before
walking the vma or it's going to slowdown the exit() path for regular
tasks.

One more implementation problem: at that point signals can't be
delivered so it would also create a task in D state if the manager
doesn't read the event.

The major design issue: it overall looks superfluous as the manager
can check for -ENOSPC in the background transfer:

	if (mmget_not_zero(ctx->mm)) {
[..]
	} else {
		return -ENOSPC;
	}

It's safer to roll it back and re-introduce it later if at all.

Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>
---
 fs/userfaultfd.c                 | 28 ----------------------------
 include/linux/userfaultfd_k.h    |  6 ------
 include/uapi/linux/userfaultfd.h |  5 +----
 kernel/exit.c                    |  1 -
 4 files changed, 1 insertion(+), 39 deletions(-)

diff --git a/fs/userfaultfd.c b/fs/userfaultfd.c
index e6e0a61..52733a7 100644
--- a/fs/userfaultfd.c
+++ b/fs/userfaultfd.c
@@ -774,34 +774,6 @@ void userfaultfd_unmap_complete(struct mm_struct *mm, struct list_head *uf)
 	}
 }
 
-void userfaultfd_exit(struct mm_struct *mm)
-{
-	struct vm_area_struct *vma = mm->mmap;
-
-	/*
-	 * We can do the vma walk without locking because the caller
-	 * (exit_mm) knows it now has exclusive access
-	 */
-	while (vma) {
-		struct userfaultfd_ctx *ctx = vma->vm_userfaultfd_ctx.ctx;
-
-		if (ctx && (ctx->features & UFFD_FEATURE_EVENT_EXIT)) {
-			struct userfaultfd_wait_queue ewq;
-
-			userfaultfd_ctx_get(ctx);
-
-			msg_init(&ewq.msg);
-			ewq.msg.event = UFFD_EVENT_EXIT;
-
-			userfaultfd_event_wait_completion(ctx, &ewq);
-
-			ctx->features &= ~UFFD_FEATURE_EVENT_EXIT;
-		}
-
-		vma = vma->vm_next;
-	}
-}
-
 static int userfaultfd_release(struct inode *inode, struct file *file)
 {
 	struct userfaultfd_ctx *ctx = file->private_data;
diff --git a/include/linux/userfaultfd_k.h b/include/linux/userfaultfd_k.h
index 0468548..f2b79bf 100644
--- a/include/linux/userfaultfd_k.h
+++ b/include/linux/userfaultfd_k.h
@@ -72,8 +72,6 @@ extern int userfaultfd_unmap_prep(struct vm_area_struct *vma,
 extern void userfaultfd_unmap_complete(struct mm_struct *mm,
 				       struct list_head *uf);
 
-extern void userfaultfd_exit(struct mm_struct *mm);
-
 #else /* CONFIG_USERFAULTFD */
 
 /* mm helpers */
@@ -139,10 +137,6 @@ static inline void userfaultfd_unmap_complete(struct mm_struct *mm,
 {
 }
 
-static inline void userfaultfd_exit(struct mm_struct *mm)
-{
-}
-
 #endif /* CONFIG_USERFAULTFD */
 
 #endif /* _LINUX_USERFAULTFD_K_H */
diff --git a/include/uapi/linux/userfaultfd.h b/include/uapi/linux/userfaultfd.h
index c055947..3b05953 100644
--- a/include/uapi/linux/userfaultfd.h
+++ b/include/uapi/linux/userfaultfd.h
@@ -18,8 +18,7 @@
  * means the userland is reading).
  */
 #define UFFD_API ((__u64)0xAA)
-#define UFFD_API_FEATURES (UFFD_FEATURE_EVENT_EXIT |		\
-			   UFFD_FEATURE_EVENT_FORK |		\
+#define UFFD_API_FEATURES (UFFD_FEATURE_EVENT_FORK |		\
 			   UFFD_FEATURE_EVENT_REMAP |		\
 			   UFFD_FEATURE_EVENT_REMOVE |	\
 			   UFFD_FEATURE_EVENT_UNMAP |		\
@@ -113,7 +112,6 @@ struct uffd_msg {
 #define UFFD_EVENT_REMAP	0x14
 #define UFFD_EVENT_REMOVE	0x15
 #define UFFD_EVENT_UNMAP	0x16
-#define UFFD_EVENT_EXIT		0x17
 
 /* flags for UFFD_EVENT_PAGEFAULT */
 #define UFFD_PAGEFAULT_FLAG_WRITE	(1<<0)	/* If this was a write fault */
@@ -163,7 +161,6 @@ struct uffdio_api {
 #define UFFD_FEATURE_MISSING_HUGETLBFS		(1<<4)
 #define UFFD_FEATURE_MISSING_SHMEM		(1<<5)
 #define UFFD_FEATURE_EVENT_UNMAP		(1<<6)
-#define UFFD_FEATURE_EVENT_EXIT			(1<<7)
 	__u64 features;
 
 	__u64 ioctls;
diff --git a/kernel/exit.c b/kernel/exit.c
index d038f98..a2e2fba 100644
--- a/kernel/exit.c
+++ b/kernel/exit.c
@@ -519,7 +519,6 @@ static void exit_mm(struct task_struct *tsk)
 	enter_lazy_tlb(mm, current);
 	task_unlock(tsk);
 	mm_update_next_owner(mm);
-	userfaultfd_exit(mm);
 	mmput(mm);
 	if (test_thread_flag(TIF_MEMDIE))
 		exit_oom_victim();

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
