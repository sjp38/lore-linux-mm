Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 300006B0292
	for <linux-mm@kvack.org>; Thu, 15 Jun 2017 07:32:48 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id w207so11626663itc.1
        for <linux-mm@kvack.org>; Thu, 15 Jun 2017 04:32:48 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id w75si213592itc.56.2017.06.15.04.32.46
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 15 Jun 2017 04:32:47 -0700 (PDT)
Subject: Re: [patch] mm, oom: prevent additional oom kills before memory is freed
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <alpine.DEB.2.10.1706141632100.93071@chino.kir.corp.google.com>
	<20170615103909.GG1486@dhcp22.suse.cz>
	<201706151953.HFH78657.tFFLOOOQHSMVFJ@I-love.SAKURA.ne.jp>
	<20170615110119.GI1486@dhcp22.suse.cz>
In-Reply-To: <20170615110119.GI1486@dhcp22.suse.cz>
Message-Id: <201706152032.BFE21313.MSHQOtLVFFJOOF@I-love.SAKURA.ne.jp>
Date: Thu, 15 Jun 2017 20:32:39 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: rientjes@google.com, akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Michal Hocko wrote:
> On Thu 15-06-17 19:53:24, Tetsuo Handa wrote:
> > Michal Hocko wrote:
> > > On Wed 14-06-17 16:43:03, David Rientjes wrote:
> > > > If mm->mm_users is not incremented because it is already zero by the oom
> > > > reaper, meaning the final refcount has been dropped, do not set
> > > > MMF_OOM_SKIP prematurely.
> > > > 
> > > > __mmput() may not have had a chance to do exit_mmap() yet, so memory from
> > > > a previous oom victim is still mapped.
> > > 
> > > true and do we have a _guarantee_ it will do it? E.g. can somebody block
> > > exit_aio from completing? Or can somebody hold mmap_sem and thus block
> > > ksm_exit resp. khugepaged_exit from completing? The reason why I was
> > > conservative and set such a mm as MMF_OOM_SKIP was because I couldn't
> > > give a definitive answer to those questions. And we really _want_ to
> > > have a guarantee of a forward progress here. Killing an additional
> > > proecess is a price to pay and if that doesn't trigger normall it sounds
> > > like a reasonable compromise to me.
> > 
> > Right. If you want this patch, __oom_reap_task_mm() must not return true without
> > setting MMF_OOM_SKIP (in other words, return false if __oom_reap_task_mm()
> > does not set MMF_OOM_SKIP). The most important role of the OOM reaper is to
> > guarantee that the OOM killer is re-enabled within finite time, for __mmput()
> > cannot guarantee that MMF_OOM_SKIP is set within finite time.
> 
> An alternative would be to allow reaping and exit_mmap race. The unmap
> part should just work I guess. We just have to be careful to not race
> with free_pgtables and that shouldn't be too hard to implement (e.g.
> (ab)use mmap_sem for write there). I haven't thought that through
> completely though so I might miss something of course.

I think below one is simpler.

 mm/oom_kill.c | 31 ++++++++++++-------------------
 1 file changed, 12 insertions(+), 19 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 0e2c925..c63f514 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -466,11 +466,10 @@ bool process_shares_mm(struct task_struct *p, struct mm_struct *mm)
 static struct task_struct *oom_reaper_list;
 static DEFINE_SPINLOCK(oom_reaper_lock);
 
-static bool __oom_reap_task_mm(struct task_struct *tsk, struct mm_struct *mm)
+static void __oom_reap_task_mm(struct task_struct *tsk, struct mm_struct *mm)
 {
 	struct mmu_gather tlb;
 	struct vm_area_struct *vma;
-	bool ret = true;
 
 	/*
 	 * We have to make sure to not race with the victim exit path
@@ -488,10 +487,8 @@ static bool __oom_reap_task_mm(struct task_struct *tsk, struct mm_struct *mm)
 	 */
 	mutex_lock(&oom_lock);
 
-	if (!down_read_trylock(&mm->mmap_sem)) {
-		ret = false;
+	if (!down_read_trylock(&mm->mmap_sem))
 		goto unlock_oom;
-	}
 
 	/*
 	 * increase mm_users only after we know we will reap something so
@@ -531,6 +528,7 @@ static bool __oom_reap_task_mm(struct task_struct *tsk, struct mm_struct *mm)
 					 NULL);
 	}
 	tlb_finish_mmu(&tlb, 0, -1);
+	set_bit(MMF_OOM_SKIP, &mm->flags);
 	pr_info("oom_reaper: reaped process %d (%s), now anon-rss:%lukB, file-rss:%lukB, shmem-rss:%lukB\n",
 			task_pid_nr(tsk), tsk->comm,
 			K(get_mm_counter(mm, MM_ANONPAGES)),
@@ -546,7 +544,6 @@ static bool __oom_reap_task_mm(struct task_struct *tsk, struct mm_struct *mm)
 	mmput_async(mm);
 unlock_oom:
 	mutex_unlock(&oom_lock);
-	return ret;
 }
 
 #define MAX_OOM_REAP_RETRIES 10
@@ -556,25 +553,21 @@ static void oom_reap_task(struct task_struct *tsk)
 	struct mm_struct *mm = tsk->signal->oom_mm;
 
 	/* Retry the down_read_trylock(mmap_sem) a few times */
-	while (attempts++ < MAX_OOM_REAP_RETRIES && !__oom_reap_task_mm(tsk, mm))
+	while (__oom_reap_task_mm(tsk, mm), !test_bit(MMF_OOM_SKIP, &mm->flags)
+	       && attempts++ < MAX_OOM_REAP_RETRIES)
 		schedule_timeout_idle(HZ/10);
 
-	if (attempts <= MAX_OOM_REAP_RETRIES)
-		goto done;
-
-
-	pr_info("oom_reaper: unable to reap pid:%d (%s)\n",
-		task_pid_nr(tsk), tsk->comm);
-	debug_show_all_locks();
-
-done:
-	tsk->oom_reaper_list = NULL;
-
 	/*
 	 * Hide this mm from OOM killer because it has been either reaped or
 	 * somebody can't call up_write(mmap_sem).
 	 */
-	set_bit(MMF_OOM_SKIP, &mm->flags);
+	if (!test_and_set_bit(MMF_OOM_SKIP, &mm->flags)) {
+		pr_info("oom_reaper: unable to reap pid:%d (%s)\n",
+			task_pid_nr(tsk), tsk->comm);
+		debug_show_all_locks();
+	}
+
+	tsk->oom_reaper_list = NULL;
 
 	/* Drop a reference taken by wake_oom_reaper */
 	put_task_struct(tsk);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
