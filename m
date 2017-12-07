Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id 23DA26B025F
	for <linux-mm@kvack.org>; Thu,  7 Dec 2017 03:28:06 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id q3so4614589pgv.16
        for <linux-mm@kvack.org>; Thu, 07 Dec 2017 00:28:06 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id 43si3395703plc.469.2017.12.07.00.28.03
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 07 Dec 2017 00:28:03 -0800 (PST)
Date: Thu, 7 Dec 2017 09:28:01 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: Multiple oom_reaper BUGs: unmap_page_range racing with exit_mmap
Message-ID: <20171207082801.GB20234@dhcp22.suse.cz>
References: <alpine.DEB.2.10.1712052323170.119719@chino.kir.corp.google.com>
 <20171206090019.GE16386@dhcp22.suse.cz>
 <201712070720.vB77KlBQ009754@www262.sakura.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201712070720.vB77KlBQ009754@www262.sakura.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: David Rientjes <rientjes@google.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu 07-12-17 16:20:47, Tetsuo Handa wrote:
[...]
> int main(int argc, char *argv[])
> {
> 	int i;
> 	char *stack;
> 	if (fork() || fork() || setsid() == EOF || pipe(pipe_fd))
> 		_exit(0);
> 	stack = mmap(NULL, STACKSIZE * NUMTHREADS, PROT_WRITE | PROT_READ,
> 		     MAP_ANONYMOUS | MAP_PRIVATE, EOF, 0);
> 	for (i = 0; i < NUMTHREADS; i++)
> 		if (clone(memory_eater, stack + (i + 1) * STACKSIZE,
> 			  /*CLONE_THREAD | CLONE_SIGHAND | */CLONE_VM | CLONE_FS |
> 			  CLONE_FILES, NULL) == -1)
> 			break;

Hmm, so you are creating a separate process (from the signal point of
view) and I suspect it is one of those that holds the last reference to
the mm_struct which is released here and it has tsk_oom_victim = F

[...]
> [  113.273394] Freed by task 1377:
> [  113.276211]  kasan_slab_free+0x71/0xc0
> [  113.279093]  kmem_cache_free+0xaf/0x1e0
> [  113.281974]  remove_vma+0x9d/0xb0
> [  113.284734]  exit_mmap+0x179/0x250
> [  113.287651]  mmput+0x7d/0x1b0
> [  113.290456]  do_exit+0x408/0x1290
> [  113.293268]  do_group_exit+0x84/0x140
> [  113.296109]  get_signal+0x291/0x9b0
> [  113.298915]  do_signal+0x8e/0xa70
> [  113.301637]  exit_to_usermode_loop+0x71/0xb0
> [  113.304632]  do_syscall_64+0x343/0x390
> [  113.307349]  return_from_SYSCALL_64+0x0/0x75

[...]

> What we overlooked is the fact that "it is not always the process which
> got ->signal->oom_mm set, it is any thread which called mmput() which
> invoked __mmput() path". Therefore, below patch fixes oops in my case.
> If some unrelated kernel thread was holding mm_users ref, it is possible
> that we miss down_write()/up_write() synchronization.

Very well spotted! It could be any task in fact (e.g. somebody reading
from /proc/<pid> file which requires mm_struct).

oom_reaper		oom_victim		task
						mmget_not_zero
			exit_mmap
			  mmput
__oom_reap_task_mm				mmput
  						  __mmput
						    exit_mmap
						      remove_vma
  unmap_page_range

So we need a more robust test for the oom victim. Your suggestion is
basically what I came up with originally [1] and which was deemed
ineffective because we took the mmap_sem even for regular paths and
Kirill was afraid this adds some unnecessary cycles to the exit path
which is quite hot.

So I guess we have to do something else instead. We have to store the
oom flag to the mm struct as well. Something like the patch below.

[1] http://lkml.kernel.org/r/20170724072332.31903-1-mhocko@kernel.org
---
diff --git a/include/linux/oom.h b/include/linux/oom.h
index 27cd36b762b5..b7668b5d3e14 100644
--- a/include/linux/oom.h
+++ b/include/linux/oom.h
@@ -77,6 +77,11 @@ static inline bool tsk_is_oom_victim(struct task_struct * tsk)
 	return tsk->signal->oom_mm;
 }
 
+static inline bool mm_is_oom_victim(struct mm_struct *mm)
+{
+	return test_bit(MMF_OOM_VICTIM, &mm->flags);
+}
+
 /*
  * Checks whether a page fault on the given mm is still reliable.
  * This is no longer true if the oom reaper started to reap the
diff --git a/include/linux/sched/coredump.h b/include/linux/sched/coredump.h
index 9c8847395b5e..da673ca66e7a 100644
--- a/include/linux/sched/coredump.h
+++ b/include/linux/sched/coredump.h
@@ -68,8 +68,9 @@ static inline int get_dumpable(struct mm_struct *mm)
 #define MMF_RECALC_UPROBES	20	/* MMF_HAS_UPROBES can be wrong */
 #define MMF_OOM_SKIP		21	/* mm is of no interest for the OOM killer */
 #define MMF_UNSTABLE		22	/* mm is unstable for copy_from_user */
-#define MMF_HUGE_ZERO_PAGE	23      /* mm has ever used the global huge zero page */
-#define MMF_DISABLE_THP		24	/* disable THP for all VMAs */
+#define MMF_OOM_VICTIM		23	/* mm is the oom victim */
+#define MMF_HUGE_ZERO_PAGE	24      /* mm has ever used the global huge zero page */
+#define MMF_DISABLE_THP		25	/* disable THP for all VMAs */
 #define MMF_DISABLE_THP_MASK	(1 << MMF_DISABLE_THP)
 
 #define MMF_INIT_MASK		(MMF_DUMPABLE_MASK | MMF_DUMP_FILTER_MASK |\
diff --git a/mm/mmap.c b/mm/mmap.c
index 476e810cf100..d00a06248ef1 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -3005,7 +3005,7 @@ void exit_mmap(struct mm_struct *mm)
 	unmap_vmas(&tlb, vma, 0, -1);
 
 	set_bit(MMF_OOM_SKIP, &mm->flags);
-	if (unlikely(tsk_is_oom_victim(current))) {
+	if (unlikely(mm_is_oom_victim(mm))) {
 		/*
 		 * Wait for oom_reap_task() to stop working on this
 		 * mm. Because MMF_OOM_SKIP is already set before
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
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
