Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 736BE6B0005
	for <linux-mm@kvack.org>; Fri, 24 Jun 2016 08:04:57 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id a66so16305126wme.1
        for <linux-mm@kvack.org>; Fri, 24 Jun 2016 05:04:57 -0700 (PDT)
Received: from mail-wm0-f48.google.com (mail-wm0-f48.google.com. [74.125.82.48])
        by mx.google.com with ESMTPS id 194si3844292wmh.122.2016.06.24.05.04.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 Jun 2016 05:04:56 -0700 (PDT)
Received: by mail-wm0-f48.google.com with SMTP id f126so19838709wma.1
        for <linux-mm@kvack.org>; Fri, 24 Jun 2016 05:04:56 -0700 (PDT)
Date: Fri, 24 Jun 2016 14:04:54 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH v2] mm, oom: don't set TIF_MEMDIE on a mm-less thread.
Message-ID: <20160624120454.GB20203@dhcp22.suse.cz>
References: <1466697527-7365-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
 <201606240124.FEI12978.OFQOSMJtOHFFLV@I-love.SAKURA.ne.jp>
 <20160624095439.GA20203@dhcp22.suse.cz>
 <201606241956.IDD09840.FSFOOVMJOHQLtF@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201606241956.IDD09840.FSFOOVMJOHQLtF@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, oleg@redhat.com, vdavydov@virtuozzo.com, rientjes@google.com

On Fri 24-06-16 19:56:43, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > On Fri 24-06-16 01:24:46, Tetsuo Handa wrote:
> > > I missed that victim != p case needs to use get_task_struct(). Patch updated.
> > > ----------------------------------------
> > > >From 1819ec63b27df2d544f66482439e754d084cebed Mon Sep 17 00:00:00 2001
> > > From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> > > Date: Fri, 24 Jun 2016 01:16:02 +0900
> > > Subject: [PATCH v2] mm, oom: don't set TIF_MEMDIE on a mm-less thread.
> > > 
> > > Patch "mm, oom: fortify task_will_free_mem" removed p->mm != NULL test for
> > > shortcut path in oom_kill_process(). But since commit f44666b04605d1c7
> > > ("mm,oom: speed up select_bad_process() loop") changed to iterate using
> > > thread group leaders, the possibility of p->mm == NULL has increased
> > > compared to when commit 83363b917a2982dd ("oom: make sure that TIF_MEMDIE
> > > is set under task_lock") was proposed. On CONFIG_MMU=n kernels, nothing
> > > will clear TIF_MEMDIE and the system can OOM livelock if TIF_MEMDIE was
> > > by error set to a mm-less thread group leader.
> > > 
> > > Let's do steps for regular path except printing OOM killer messages and
> > > sending SIGKILL.
> > 
> > I fully agree with Oleg. It would be much better to encapsulate this
> > into mark_oom_victim and guard it by ifdef NOMMU as this is nommu
> > specific with a big fat warning why we need it.
> 
> OK. But before doing so, which one ((A) or (B) shown below) do you prefer?
> 
> 
> (A) Don't use task_will_free_mem(p) shortcut in oom_kill_process() if CONFIG_MMU=n.
> 
>     Since task_will_free_mem(p) == true where p is the largest memory consumer
>     (with oom_score_adj taken into account) is not exiting smoothly, as with
>     commit 6a618957ad17d8f4 ("mm: oom_kill: don't ignore oom score on exiting
>     tasks") thought, it can be a sign of something bad (possibly OOM livelock) is
>     happening. Thus, print the OOM killer messages anyway although all tasks
>     which will be OOM killed are already killed/exiting (unless p has OOM killable
>     children). This will help giving administrator a hint when the kernel hit
>     OOM livelock.
[...]
> (B) Check mm in mark_oom_victim() if CONFIG_MMU=n.
> 
>     Since mark_oom_victim() is also called from current->mm && task_will_free_mem(current)
>     shortcut in out_of_memory(), mark_oom_victim(current) needs to set TIF_MEMDIE on current
>     if current->mm != NULL.

I think you are overcomplicating this. Why cannot we simply do the
following?
---
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 4c21f744daa6..97be9324a58b 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -671,6 +671,22 @@ void mark_oom_victim(struct task_struct *tsk)
 	/* OOM killer might race with memcg OOM */
 	if (test_and_set_tsk_thread_flag(tsk, TIF_MEMDIE))
 		return;
+#ifndef CONFIG_MMU
+	/*
+	 * we shouldn't risk setting TIF_MEMDIE on a task which has passed its
+	 * exit_mm task->mm = NULL and exit_oom_victim otherwise it could
+	 * theoretically keep its TIF_MEMDIE for ever while waiting for a parent
+	 * to get it out of zombie state. MMU doesn't have this problem because
+	 * it has the oom_reaper to clear the flag asynchronously.
+	 */
+	task_lock(tsk);
+	if (!tsk->mm) {
+		clear_tsk_thread_flag(tsk, TIF_MEMDIE);
+		task_unlock(tsk);
+		return;
+	}
+	taks_unlock(tsk);
+#endif
 	atomic_inc(&tsk->signal->oom_victims);
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
