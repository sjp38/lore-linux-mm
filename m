Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 9DCB86B007E
	for <linux-mm@kvack.org>; Wed, 18 May 2016 09:30:24 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id u185so81750813oie.3
        for <linux-mm@kvack.org>; Wed, 18 May 2016 06:30:24 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [202.181.97.72])
        by mx.google.com with ESMTPS id y8si3478742oei.13.2016.05.18.06.30.22
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 18 May 2016 06:30:22 -0700 (PDT)
Subject: [PATCH v3] mm,oom: speed up select_bad_process() loop.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1463574024-8372-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
	<20160518125138.GH21654@dhcp22.suse.cz>
In-Reply-To: <20160518125138.GH21654@dhcp22.suse.cz>
Message-Id: <201605182230.IDC73435.MVSOHLFOQFOJtF@I-love.SAKURA.ne.jp>
Date: Wed, 18 May 2016 22:30:14 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: akpm@linux-foundation.org, rientjes@google.com, linux-mm@kvack.org, oleg@redhat.com

Michal Hocko wrote:
> On Wed 18-05-16 21:20:24, Tetsuo Handa wrote:
> > Since commit 3a5dda7a17cf3706 ("oom: prevent unnecessary oom kills or
> > kernel panics"), select_bad_process() is using for_each_process_thread().
> > 
> > Since oom_unkillable_task() scans all threads in the caller's thread group
> > and oom_task_origin() scans signal_struct of the caller's thread group, we
> > don't need to call oom_unkillable_task() and oom_task_origin() on each
> > thread. Also, since !mm test will be done later at oom_badness(), we don't
> > need to do !mm test on each thread. Therefore, we only need to do
> > TIF_MEMDIE test on each thread.
> > 
> > If we track number of TIF_MEMDIE threads inside signal_struct, we don't
> > need to do TIF_MEMDIE test on each thread. This will allow
> > select_bad_process() to use for_each_process().
> 
> I am wondering whether signal_struct is the best way forward. The oom
> killing is more about mm_struct than anything else. We can record that
> the mm was oom killed in mm->flags (similar to MMF_OOM_REAPED). I guess
> this would require more work at this stage so maybe starting with signal
> struct is not that bad afterall. Just thinking...

Even if you call p->signal->oom_score_adj == OOM_SCORE_ADJ_MIN case a bug,
(p->flags & PF_KTHREAD) || is_global_init(p) case is still possible. Thus,
I think we can't mark the mm was oom killed in mm->flags.

> 
> > This patch adds a counter to signal_struct for tracking how many
> > TIF_MEMDIE threads are in a given thread group, and check it at
> > oom_scan_process_thread() so that select_bad_process() can use
> > for_each_process() rather than for_each_process_thread().
> 
> In general I do agree that for_each_process is preferable. I guess you
> are missing one case here, though (or maybe just forgot to refresh the
> patch because the changelog mentions !mm test):

Oops, I forgot to delete that test. Thanks.
----------------------------------------
>From d770bd777e628e9d1ae250249433cf576aae8961 Mon Sep 17 00:00:00 2001
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Date: Wed, 18 May 2016 22:17:47 +0900
Subject: [PATCH v3] mm,oom: speed up select_bad_process() loop.

Since commit 3a5dda7a17cf3706 ("oom: prevent unnecessary oom kills or
kernel panics"), select_bad_process() is using for_each_process_thread().

Since oom_unkillable_task() scans all threads in the caller's thread group
and oom_task_origin() scans signal_struct of the caller's thread group, we
don't need to call oom_unkillable_task() and oom_task_origin() on each
thread. Also, since !mm test will be done later at oom_badness(), we don't
need to do !mm test on each thread. Therefore, we only need to do
TIF_MEMDIE test on each thread.

If we track number of TIF_MEMDIE threads inside signal_struct, we don't
need to do TIF_MEMDIE test on each thread. This will allow
select_bad_process() to use for_each_process().

This patch adds a counter to signal_struct for tracking how many
TIF_MEMDIE threads are in a given thread group, and check it at
oom_scan_process_thread() so that select_bad_process() can use
for_each_process() rather than for_each_process_thread().

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: David Rientjes <rientjes@google.com>
Cc: Oleg Nesterov <oleg@redhat.com>
---
 include/linux/sched.h |  1 +
 mm/oom_kill.c         | 14 ++++++--------
 2 files changed, 7 insertions(+), 8 deletions(-)

diff --git a/include/linux/sched.h b/include/linux/sched.h
index 870a700..1589f8e 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -794,6 +794,7 @@ struct signal_struct {
 	struct tty_audit_buf *tty_audit_buf;
 #endif
 
+	atomic_t oom_victims; /* # of TIF_MEDIE threads in this thread group */
 	/*
 	 * Thread is the potential origin of an oom condition; kill first on
 	 * oom
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index c0e37dd..8e151d0 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -283,12 +283,8 @@ enum oom_scan_t oom_scan_process_thread(struct oom_control *oc,
 	 * This task already has access to memory reserves and is being killed.
 	 * Don't allow any other task to have access to the reserves.
 	 */
-	if (test_tsk_thread_flag(task, TIF_MEMDIE)) {
-		if (!is_sysrq_oom(oc))
-			return OOM_SCAN_ABORT;
-	}
-	if (!task->mm)
-		return OOM_SCAN_CONTINUE;
+	if (!is_sysrq_oom(oc) && atomic_read(&task->signal->oom_victims))
+		return OOM_SCAN_ABORT;
 
 	/*
 	 * If task is allocating a lot of memory and has been marked to be
@@ -307,12 +303,12 @@ enum oom_scan_t oom_scan_process_thread(struct oom_control *oc,
 static struct task_struct *select_bad_process(struct oom_control *oc,
 		unsigned int *ppoints, unsigned long totalpages)
 {
-	struct task_struct *g, *p;
+	struct task_struct *p;
 	struct task_struct *chosen = NULL;
 	unsigned long chosen_points = 0;
 
 	rcu_read_lock();
-	for_each_process_thread(g, p) {
+	for_each_process(p) {
 		unsigned int points;
 
 		switch (oom_scan_process_thread(oc, p, totalpages)) {
@@ -673,6 +669,7 @@ void mark_oom_victim(struct task_struct *tsk)
 	/* OOM killer might race with memcg OOM */
 	if (test_and_set_tsk_thread_flag(tsk, TIF_MEMDIE))
 		return;
+	atomic_inc(&tsk->signal->oom_victims);
 	/*
 	 * Make sure that the task is woken up from uninterruptible sleep
 	 * if it is frozen because OOM killer wouldn't be able to free
@@ -690,6 +687,7 @@ void exit_oom_victim(struct task_struct *tsk)
 {
 	if (!test_and_clear_tsk_thread_flag(tsk, TIF_MEMDIE))
 		return;
+	atomic_dec(&tsk->signal->oom_victims);
 
 	if (!atomic_dec_return(&oom_victims))
 		wake_up_all(&oom_victims_wait);
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
