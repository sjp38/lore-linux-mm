Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 007666B0033
	for <linux-mm@kvack.org>; Sun, 10 Dec 2017 04:51:39 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id l33so8680650wrl.5
        for <linux-mm@kvack.org>; Sun, 10 Dec 2017 01:51:39 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n17sor5571608wrg.29.2017.12.10.01.51.38
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 10 Dec 2017 01:51:38 -0800 (PST)
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH] mm, oom_reaper: fix memory corruption
Date: Sun, 10 Dec 2017 10:51:30 +0100
Message-Id: <20171210095130.17110-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrea Argangeli <andrea@kernel.org>, David Rientjes <rientjes@google.com>, Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>, Stable tree <stable@vger.kernel.org>

From: Michal Hocko <mhocko@suse.com>

David Rientjes has reported the following memory corruption while the
oom reaper tries to unmap the victims address space
BUG: Bad page map in process oom_reaper  pte:6353826300000000 pmd:00000000
addr:00007f50cab1d000 vm_flags:08100073 anon_vma:ffff9eea335603f0 mapping:          (null) index:7f50cab1d
file:          (null) fault:          (null) mmap:          (null) readpage:          (null)
CPU: 2 PID: 1001 Comm: oom_reaper
Call Trace:
 [<ffffffffa4bd967d>] dump_stack+0x4d/0x70
 [<ffffffffa4a03558>] unmap_page_range+0x1068/0x1130
 [<ffffffffa4a2e07f>] __oom_reap_task_mm+0xd5/0x16b
 [<ffffffffa4a2e226>] oom_reaper+0xff/0x14c
 [<ffffffffa48d6ad1>] kthread+0xc1/0xe0

Tetsuo Handa has noticed that the synchronization inside exit_mmap is
insufficient. We only synchronize with the oom reaper if tsk_is_oom_victim
which is not true if the final __mmput is called from a different context
than the oom victim exit path. This can trivially happen from context of
any task which has grabbed mm reference (e.g. to read /proc/<pid>/ file
which requires mm etc.). The race would look like this

oom_reaper		oom_victim		task
						mmget_not_zero
			do_exit
			  mmput
__oom_reap_task_mm				mmput
  						  __mmput
						    exit_mmap
						      remove_vma
  unmap_page_range

Fix this issue by providing a new mm_is_oom_victim() helper which operates
on the mm struct rather than a task. Any context which operates on a remote
mm struct should use this helper in place of tsk_is_oom_victim. The flag is
set in mark_oom_victim and never cleared so it is stable in the exit_mmap
path.

Changes since v1
- set MMF_OOM_SKIP in exit_mmap only for the oom mm as suggested by
  Tetsuo because there is no reason to set the flag unless we are
  synchronizing with the oom reaper.
- do not modify values of other MMF_ flags and add MMF_OOM_VICTIM
  as the last one as requested by David Rientjes because they have
  "automated tools that look at specific bits in mm->flags and it would
  be nice to not have them be inconsistent between kernel versions.
  Not absolutely required, but nice to avoid"

Reported-by: David Rientjes <rientjes@google.com>
Debugged-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Fixes: 212925802454 ("mm: oom: let oom_reap_task and exit_mmap run concurrently")
Cc: stable # 4.14
Acked-by: David Rientjes <rientjes@google.com>
Signed-off-by: Michal Hocko <mhocko@suse.com>
---

Hi,
this patch fixes issue reported by David [1][2].

[1] http://lkml.kernel.org/r/alpine.DEB.2.10.1712051824050.91099@chino.kir.corp.google.com
[2] http://lkml.kernel.org/r/alpine.DEB.2.10.1712071315570.135101@chino.kir.corp.google.com

 include/linux/oom.h            |  9 +++++++++
 include/linux/sched/coredump.h |  1 +
 mm/mmap.c                      | 10 +++++-----
 mm/oom_kill.c                  |  4 +++-
 4 files changed, 18 insertions(+), 6 deletions(-)

diff --git a/include/linux/oom.h b/include/linux/oom.h
index 27cd36b762b5..c4139e79771d 100644
--- a/include/linux/oom.h
+++ b/include/linux/oom.h
@@ -77,6 +77,15 @@ static inline bool tsk_is_oom_victim(struct task_struct * tsk)
 	return tsk->signal->oom_mm;
 }
 
+/*
+ * Use this helper if tsk->mm != mm and the victim mm needs a special
+ * handling. This is guaranteed to stay true after once set.
+ */
+static inline bool mm_is_oom_victim(struct mm_struct *mm)
+{
+	return test_bit(MMF_OOM_VICTIM, &mm->flags);
+}
+
 /*
  * Checks whether a page fault on the given mm is still reliable.
  * This is no longer true if the oom reaper started to reap the
diff --git a/include/linux/sched/coredump.h b/include/linux/sched/coredump.h
index 9c8847395b5e..ec912d01126f 100644
--- a/include/linux/sched/coredump.h
+++ b/include/linux/sched/coredump.h
@@ -70,6 +70,7 @@ static inline int get_dumpable(struct mm_struct *mm)
 #define MMF_UNSTABLE		22	/* mm is unstable for copy_from_user */
 #define MMF_HUGE_ZERO_PAGE	23      /* mm has ever used the global huge zero page */
 #define MMF_DISABLE_THP		24	/* disable THP for all VMAs */
+#define MMF_OOM_VICTIM		25	/* mm is the oom victim */
 #define MMF_DISABLE_THP_MASK	(1 << MMF_DISABLE_THP)
 
 #define MMF_INIT_MASK		(MMF_DUMPABLE_MASK | MMF_DUMP_FILTER_MASK |\
diff --git a/mm/mmap.c b/mm/mmap.c
index 476e810cf100..0de87a376aaa 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -3004,20 +3004,20 @@ void exit_mmap(struct mm_struct *mm)
 	/* Use -1 here to ensure all VMAs in the mm are unmapped */
 	unmap_vmas(&tlb, vma, 0, -1);
 
-	set_bit(MMF_OOM_SKIP, &mm->flags);
-	if (unlikely(tsk_is_oom_victim(current))) {
+	if (unlikely(mm_is_oom_victim(mm))) {
 		/*
 		 * Wait for oom_reap_task() to stop working on this
 		 * mm. Because MMF_OOM_SKIP is already set before
 		 * calling down_read(), oom_reap_task() will not run
 		 * on this "mm" post up_write().
 		 *
-		 * tsk_is_oom_victim() cannot be set from under us
-		 * either because current->mm is already set to NULL
+		 * mm_is_oom_victim() cannot be set from under us
+		 * either because victim->mm is already set to NULL
 		 * under task_lock before calling mmput and oom_mm is
-		 * set not NULL by the OOM killer only if current->mm
+		 * set not NULL by the OOM killer only if victim->mm
 		 * is found not NULL while holding the task_lock.
 		 */
+		set_bit(MMF_OOM_SKIP, &mm->flags);
 		down_write(&mm->mmap_sem);
 		up_write(&mm->mmap_sem);
 	}
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 3b0d0fed8480..e4d290b6804b 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -666,8 +666,10 @@ static void mark_oom_victim(struct task_struct *tsk)
 		return;
 
 	/* oom_mm is bound to the signal struct life time. */
-	if (!cmpxchg(&tsk->signal->oom_mm, NULL, mm))
+	if (!cmpxchg(&tsk->signal->oom_mm, NULL, mm)) {
 		mmgrab(tsk->signal->oom_mm);
+		set_bit(MMF_OOM_VICTIM, &mm->flags);
+	}
 
 	/*
 	 * Make sure that the task is woken up from uninterruptible sleep
-- 
2.15.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
