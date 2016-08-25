Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 0331083093
	for <linux-mm@kvack.org>; Thu, 25 Aug 2016 06:03:44 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id k135so28604463lfb.2
        for <linux-mm@kvack.org>; Thu, 25 Aug 2016 03:03:43 -0700 (PDT)
Received: from mail-wm0-f66.google.com (mail-wm0-f66.google.com. [74.125.82.66])
        by mx.google.com with ESMTPS id a1si12997473wjm.175.2016.08.25.03.03.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 25 Aug 2016 03:03:37 -0700 (PDT)
Received: by mail-wm0-f66.google.com with SMTP id i138so6636450wmf.3
        for <linux-mm@kvack.org>; Thu, 25 Aug 2016 03:03:37 -0700 (PDT)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH v2 8/9] mm: make sure that kthreads will not refault oom reaped memory
Date: Thu, 25 Aug 2016 12:03:13 +0200
Message-Id: <1472119394-11342-9-git-send-email-mhocko@kernel.org>
In-Reply-To: <1472119394-11342-1-git-send-email-mhocko@kernel.org>
References: <1472119394-11342-1-git-send-email-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, Oleg Nesterov <oleg@redhat.com>, David Rientjes <rientjes@google.com>, Vladimir Davydov <vdavydov@parallels.com>, Michal Hocko <mhocko@suse.com>

From: Michal Hocko <mhocko@suse.com>

There are only few use_mm() users in the kernel right now. Most
of them write to the target memory but vhost driver relies on
copy_from_user/get_user from a kernel thread context. This makes it
impossible to reap the memory of an oom victim which shares the mm with
the vhost kernel thread because it could see a zero page unexpectedly
and theoretically make an incorrect decision visible outside of the
killed task context.

To quote Michael S. Tsirkin:
: Getting an error from __get_user and friends is handled gracefully.
: Getting zero instead of a real value will cause userspace
: memory corruption.

The vhost kernel thread is bound to an open fd of the vhost device which
is not tight to the mm owner life cycle in general. The device fd can be
inherited or passed over to another process which means that we really
have to be careful about unexpected memory corruption because unlike for
normal oom victims the result will be visible outside of the oom victim
context.

Make sure that no kthread context (users of use_mm) can ever see
corrupted data because of the oom reaper and hook into the page fault
path by checking MMF_UNSTABLE mm flag. __oom_reap_task_mm will set the
flag before it starts unmapping the address space while the flag is
checked after the page fault has been handled. If the flag is set
then SIGBUS is triggered so any g-u-p user will get a error code.

Regular tasks do not need this protection because all which share the mm
are killed when the mm is reaped and so the corruption will not outlive
them.

This patch shouldn't have any visible effect at this moment because the
OOM killer doesn't invoke oom reaper for tasks with mm shared with
kthreads yet.

Acked-by: "Michael S. Tsirkin" <mst@redhat.com>
Signed-off-by: Michal Hocko <mhocko@suse.com>
---
 include/linux/sched.h |  1 +
 mm/memory.c           | 13 +++++++++++++
 mm/oom_kill.c         |  8 ++++++++
 3 files changed, 22 insertions(+)

diff --git a/include/linux/sched.h b/include/linux/sched.h
index eda579f3283a..63acaf9cc51c 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -522,6 +522,7 @@ static inline int get_dumpable(struct mm_struct *mm)
 #define MMF_HAS_UPROBES		19	/* has uprobes */
 #define MMF_RECALC_UPROBES	20	/* MMF_HAS_UPROBES can be wrong */
 #define MMF_OOM_SKIP		21	/* mm is of no interest for the OOM killer */
+#define MMF_UNSTABLE		22	/* mm is unstable for copy_from_user */
 
 #define MMF_INIT_MASK		(MMF_DUMPABLE_MASK | MMF_DUMP_FILTER_MASK)
 
diff --git a/mm/memory.c b/mm/memory.c
index 83be99d9d8a1..020226b4114b 100644
--- a/mm/memory.c
+++ b/mm/memory.c
@@ -3656,6 +3656,19 @@ int handle_mm_fault(struct vm_area_struct *vma, unsigned long address,
                         mem_cgroup_oom_synchronize(false);
 	}
 
+	/*
+	 * This mm has been already reaped by the oom reaper and so the
+	 * refault cannot be trusted in general. Anonymous refaults would
+	 * lose data and give a zero page instead e.g. This is especially
+	 * problem for use_mm() because regular tasks will just die and
+	 * the corrupted data will not be visible anywhere while kthread
+	 * will outlive the oom victim and potentially propagate the date
+	 * further.
+	 */
+	if (unlikely((current->flags & PF_KTHREAD) && !(ret & VM_FAULT_ERROR)
+				&& test_bit(MMF_UNSTABLE, &vma->vm_mm->flags)))
+		ret = VM_FAULT_SIGBUS;
+
 	return ret;
 }
 EXPORT_SYMBOL_GPL(handle_mm_fault);
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 3b990544db6d..5a3ba96c8338 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -495,6 +495,14 @@ static bool __oom_reap_task_mm(struct task_struct *tsk, struct mm_struct *mm)
 		goto unlock_oom;
 	}
 
+	/*
+	 * Tell all users of get_user/copy_from_user etc... that the content
+	 * is no longer stable. No barriers really needed because unmapping
+	 * should imply barriers already and the reader would hit a page fault
+	 * if it stumbled over a reaped memory.
+	 */
+	set_bit(MMF_UNSTABLE, &mm->flags);
+
 	tlb_gather_mmu(&tlb, mm, 0, -1);
 	for (vma = mm->mmap ; vma; vma = vma->vm_next) {
 		if (is_vm_hugetlb_page(vma))
-- 
2.8.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
