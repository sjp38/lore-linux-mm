Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id 17586828E1
	for <linux-mm@kvack.org>; Fri, 24 Jun 2016 06:56:54 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id ao6so193250625pac.2
        for <linux-mm@kvack.org>; Fri, 24 Jun 2016 03:56:54 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id i8si6260224paw.129.2016.06.24.03.56.52
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 24 Jun 2016 03:56:53 -0700 (PDT)
Subject: Re: [PATCH v2] mm, oom: don't set TIF_MEMDIE on a mm-less thread.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1466697527-7365-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
	<201606240124.FEI12978.OFQOSMJtOHFFLV@I-love.SAKURA.ne.jp>
	<20160624095439.GA20203@dhcp22.suse.cz>
In-Reply-To: <20160624095439.GA20203@dhcp22.suse.cz>
Message-Id: <201606241956.IDD09840.FSFOOVMJOHQLtF@I-love.SAKURA.ne.jp>
Date: Fri, 24 Jun 2016 19:56:43 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: linux-mm@kvack.org, oleg@redhat.com, vdavydov@virtuozzo.com, rientjes@google.com

Michal Hocko wrote:
> On Fri 24-06-16 01:24:46, Tetsuo Handa wrote:
> > I missed that victim != p case needs to use get_task_struct(). Patch updated.
> > ----------------------------------------
> > >From 1819ec63b27df2d544f66482439e754d084cebed Mon Sep 17 00:00:00 2001
> > From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> > Date: Fri, 24 Jun 2016 01:16:02 +0900
> > Subject: [PATCH v2] mm, oom: don't set TIF_MEMDIE on a mm-less thread.
> > 
> > Patch "mm, oom: fortify task_will_free_mem" removed p->mm != NULL test for
> > shortcut path in oom_kill_process(). But since commit f44666b04605d1c7
> > ("mm,oom: speed up select_bad_process() loop") changed to iterate using
> > thread group leaders, the possibility of p->mm == NULL has increased
> > compared to when commit 83363b917a2982dd ("oom: make sure that TIF_MEMDIE
> > is set under task_lock") was proposed. On CONFIG_MMU=n kernels, nothing
> > will clear TIF_MEMDIE and the system can OOM livelock if TIF_MEMDIE was
> > by error set to a mm-less thread group leader.
> > 
> > Let's do steps for regular path except printing OOM killer messages and
> > sending SIGKILL.
> 
> I fully agree with Oleg. It would be much better to encapsulate this
> into mark_oom_victim and guard it by ifdef NOMMU as this is nommu
> specific with a big fat warning why we need it.

OK. But before doing so, which one ((A) or (B) shown below) do you prefer?


(A) Don't use task_will_free_mem(p) shortcut in oom_kill_process() if CONFIG_MMU=n.

    Since task_will_free_mem(p) == true where p is the largest memory consumer
    (with oom_score_adj taken into account) is not exiting smoothly, as with
    commit 6a618957ad17d8f4 ("mm: oom_kill: don't ignore oom score on exiting
    tasks") thought, it can be a sign of something bad (possibly OOM livelock) is
    happening. Thus, print the OOM killer messages anyway although all tasks
    which will be OOM killed are already killed/exiting (unless p has OOM killable
    children). This will help giving administrator a hint when the kernel hit
    OOM livelock.

----------
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 4c21f74..e7d38f62 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -834,6 +834,7 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
 					      DEFAULT_RATELIMIT_BURST);
 	bool can_oom_reap = true;
 
+#ifdef CONFIG_MMU
 	/*
 	 * If the task is already exiting, don't alarm the sysadmin or kill
 	 * its children or threads, just set TIF_MEMDIE so it can die quickly
@@ -844,6 +845,7 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
 		put_task_struct(p);
 		return;
 	}
+#endif
 
 	if (__ratelimit(&oom_rs))
 		dump_header(oc, p);
----------

(B) Check mm in mark_oom_victim() if CONFIG_MMU=n.

    Since mark_oom_victim() is also called from current->mm && task_will_free_mem(current)
    shortcut in out_of_memory(), mark_oom_victim(current) needs to set TIF_MEMDIE on current
    if current->mm != NULL.

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 4c21f74..bf45666 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -668,9 +668,29 @@ subsys_initcall(oom_init)
 void mark_oom_victim(struct task_struct *tsk)
 {
 	WARN_ON(oom_killer_disabled);
+#ifdef CONFIG_MMU
 	/* OOM killer might race with memcg OOM */
 	if (test_and_set_tsk_thread_flag(tsk, TIF_MEMDIE))
 		return;
+#else
+	/*
+	 * Make sure that we set TIF_MEMDIE on a thread with mm in order to
+	 * reduce possibility of hitting OOM livelock.
+	 */
+	task_lock(tsk);
+	if (!tsk->mm) {
+		task_unlock(tsk);
+		tsk = find_lock_task_mm(tsk);
+		if (!tsk)
+			return;
+	}
+	/* OOM killer might race with memcg OOM */
+	if (test_and_set_tsk_thread_flag(tsk, TIF_MEMDIE)) {
+		task_unlock(tsk);
+		return;
+	}
+	task_unlock(tsk);
+#endif
 	atomic_inc(&tsk->signal->oom_victims);
 	/*
 	 * Make sure that the task is woken up from uninterruptible sleep

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
