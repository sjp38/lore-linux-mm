Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 54A766B0033
	for <linux-mm@kvack.org>; Thu,  7 Dec 2017 16:55:11 -0500 (EST)
Received: by mail-it0-f69.google.com with SMTP id b11so467268itj.0
        for <linux-mm@kvack.org>; Thu, 07 Dec 2017 13:55:11 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t134sor77523itf.23.2017.12.07.13.55.09
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 07 Dec 2017 13:55:09 -0800 (PST)
Date: Thu, 7 Dec 2017 13:55:07 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: Multiple oom_reaper BUGs: unmap_page_range racing with
 exit_mmap
In-Reply-To: <20171207163003.GM20234@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.10.1712071352480.135101@chino.kir.corp.google.com>
References: <alpine.DEB.2.10.1712051824050.91099@chino.kir.corp.google.com> <20171207113548.GG20234@dhcp22.suse.cz> <201712080044.BID56711.FFVOLMStJOQHOF@I-love.SAKURA.ne.jp> <20171207163003.GM20234@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>, akpm@linux-foundation.org, aarcange@redhat.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Thu, 7 Dec 2017, Michal Hocko wrote:

> yes. I will fold the following in if this turned out to really address
> David's issue. But I suspect this will be the case considering the NULL
> pmd in the report which would suggest racing with free_pgtable...
> 

I'm backporting and testing the following patch against Linus's tree.  To 
clarify an earlier point, we don't actually have any change from upstream 
code that allows for free_pgtables() before the 
set_bit(MMF_OOM_SKIP);down_write();up_write() cycle.

diff --git a/include/linux/oom.h b/include/linux/oom.h
--- a/include/linux/oom.h
+++ b/include/linux/oom.h
@@ -66,6 +66,15 @@ static inline bool tsk_is_oom_victim(struct task_struct * tsk)
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
--- a/include/linux/sched/coredump.h
+++ b/include/linux/sched/coredump.h
@@ -71,6 +71,7 @@ static inline int get_dumpable(struct mm_struct *mm)
 #define MMF_HUGE_ZERO_PAGE	23      /* mm has ever used the global huge zero page */
 #define MMF_DISABLE_THP		24	/* disable THP for all VMAs */
 #define MMF_DISABLE_THP_MASK	(1 << MMF_DISABLE_THP)
+#define MMF_OOM_VICTIM		25	/* mm is the oom victim */
 
 #define MMF_INIT_MASK		(MMF_DUMPABLE_MASK | MMF_DUMP_FILTER_MASK |\
 				 MMF_DISABLE_THP_MASK)
diff --git a/mm/mmap.c b/mm/mmap.c
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -3019,20 +3019,20 @@ void exit_mmap(struct mm_struct *mm)
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
+		 * mm_is_oom_victim() cannot be set from under us
 		 * either because current->mm is already set to NULL
 		 * under task_lock before calling mmput and oom_mm is
 		 * set not NULL by the OOM killer only if current->mm
 		 * is found not NULL while holding the task_lock.
 		 */
+		set_bit(MMF_OOM_SKIP, &mm->flags);
 		down_write(&mm->mmap_sem);
 		up_write(&mm->mmap_sem);
 	}
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -683,8 +683,10 @@ static void mark_oom_victim(struct task_struct *tsk)
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
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
