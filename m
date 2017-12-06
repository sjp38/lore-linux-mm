Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 3C5D26B0329
	for <linux-mm@kvack.org>; Tue,  5 Dec 2017 21:58:11 -0500 (EST)
Received: by mail-io0-f197.google.com with SMTP id n42so908917ioe.12
        for <linux-mm@kvack.org>; Tue, 05 Dec 2017 18:58:11 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id r194sor1063035itr.62.2017.12.05.18.58.10
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 05 Dec 2017 18:58:10 -0800 (PST)
Date: Tue, 5 Dec 2017 18:58:08 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: Multiple oom_reaper BUGs: unmap_page_range racing with
 exit_mmap
In-Reply-To: <alpine.DEB.2.10.1712051824050.91099@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.10.1712051857450.98120@chino.kir.corp.google.com>
References: <alpine.DEB.2.10.1712051824050.91099@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.com>, Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, Andrea Arcangeli <aarcange@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, 5 Dec 2017, David Rientjes wrote:

> One way to solve the issue is to have two mm flags: one to indicate the mm 
> is entering unmap_vmas(): set the flag, do down_write(&mm->mmap_sem); 
> up_write(&mm->mmap_sem), then unmap_vmas().  The oom reaper needs this 
> flag clear, not MMF_OOM_SKIP, while holding down_read(&mm->mmap_sem) to be 
> allowed to call unmap_page_range().  The oom killer will still defer 
> selecting this victim for MMF_OOM_SKIP after unmap_vmas() returns.
> 
> The result of that change would be that we do not oom reap from any mm 
> entering unmap_vmas(): we let unmap_vmas() do the work itself and avoid 
> racing with it.
> 

I think we need something like the following?

diff --git a/include/linux/sched/coredump.h b/include/linux/sched/coredump.h
--- a/include/linux/sched/coredump.h
+++ b/include/linux/sched/coredump.h
@@ -70,6 +70,7 @@ static inline int get_dumpable(struct mm_struct *mm)
 #define MMF_UNSTABLE		22	/* mm is unstable for copy_from_user */
 #define MMF_HUGE_ZERO_PAGE	23      /* mm has ever used the global huge zero page */
 #define MMF_DISABLE_THP		24	/* disable THP for all VMAs */
+#define MMF_REAPING		25	/* mm is undergoing reaping */
 #define MMF_DISABLE_THP_MASK	(1 << MMF_DISABLE_THP)
 
 #define MMF_INIT_MASK		(MMF_DUMPABLE_MASK | MMF_DUMP_FILTER_MASK |\
diff --git a/mm/mmap.c b/mm/mmap.c
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -3014,16 +3014,11 @@ void exit_mmap(struct mm_struct *mm)
 
 	lru_add_drain();
 	flush_cache_mm(mm);
-	tlb_gather_mmu(&tlb, mm, 0, -1);
-	/* update_hiwater_rss(mm) here? but nobody should be looking */
-	/* Use -1 here to ensure all VMAs in the mm are unmapped */
-	unmap_vmas(&tlb, vma, 0, -1);
-
-	set_bit(MMF_OOM_SKIP, &mm->flags);
+	set_bit(MMF_REAPING, &mm->flags);
 	if (unlikely(tsk_is_oom_victim(current))) {
 		/*
 		 * Wait for oom_reap_task() to stop working on this
-		 * mm. Because MMF_OOM_SKIP is already set before
+		 * mm. Because MMF_REAPING is already set before
 		 * calling down_read(), oom_reap_task() will not run
 		 * on this "mm" post up_write().
 		 *
@@ -3036,6 +3031,11 @@ void exit_mmap(struct mm_struct *mm)
 		down_write(&mm->mmap_sem);
 		up_write(&mm->mmap_sem);
 	}
+	tlb_gather_mmu(&tlb, mm, 0, -1);
+	/* update_hiwater_rss(mm) here? but nobody should be looking */
+	/* Use -1 here to ensure all VMAs in the mm are unmapped */
+	unmap_vmas(&tlb, vma, 0, -1);
+	set_bit(MMF_OOM_SKIP, &mm->flags);
 	free_pgtables(&tlb, vma, FIRST_USER_ADDRESS, USER_PGTABLES_CEILING);
 	tlb_finish_mmu(&tlb, 0, -1);
 
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -529,12 +529,12 @@ static bool __oom_reap_task_mm(struct task_struct *tsk, struct mm_struct *mm)
 	}
 
 	/*
-	 * MMF_OOM_SKIP is set by exit_mmap when the OOM reaper can't
-	 * work on the mm anymore. The check for MMF_OOM_SKIP must run
+	 * MMF_REAPING is set by exit_mmap when the OOM reaper can't
+	 * work on the mm anymore. The check for MMF_REAPING must run
 	 * under mmap_sem for reading because it serializes against the
 	 * down_write();up_write() cycle in exit_mmap().
 	 */
-	if (test_bit(MMF_OOM_SKIP, &mm->flags)) {
+	if (test_bit(MMF_REAPING, &mm->flags)) {
 		up_read(&mm->mmap_sem);
 		trace_skip_task_reaping(tsk->pid);
 		goto unlock_oom;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
