Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f176.google.com (mail-pf0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id 880A46B0005
	for <linux-mm@kvack.org>; Sun, 28 Feb 2016 20:26:33 -0500 (EST)
Received: by mail-pf0-f176.google.com with SMTP id w128so37261988pfb.2
        for <linux-mm@kvack.org>; Sun, 28 Feb 2016 17:26:33 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id o70si7768320pfj.105.2016.02.28.17.26.32
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sun, 28 Feb 2016 17:26:32 -0800 (PST)
Subject: Re: [PATCH 6/5] oom, oom_reaper: disable oom_reaper for oom_kill_allocating_task
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1454505240-23446-6-git-send-email-mhocko@kernel.org>
	<20160217094855.GC29196@dhcp22.suse.cz>
	<20160219183419.GA30059@dhcp22.suse.cz>
	<201602201132.EFG90182.FOVtSOJHFOLFQM@I-love.SAKURA.ne.jp>
	<20160222094105.GD17938@dhcp22.suse.cz>
In-Reply-To: <20160222094105.GD17938@dhcp22.suse.cz>
Message-Id: <201602291026.CJB64059.FtSLOOFFJHMOQV@I-love.SAKURA.ne.jp>
Date: Mon, 29 Feb 2016 10:26:25 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: rientjes@google.com, linux-mm@kvack.org

Michal Hocko wrote:
> > Moreover, why don't you do like
> > 
> >   struct mm_struct {
> >   	(...snipped...)
> >   	struct list_head oom_reaper_list;
> >   	(...snipped...)
> >   }
> 
> Because we would need to search all tasks sharing the same mm in order
> to exit_oom_victim.

We should clear TIF_MEMDIE eventually in case reaping this mm was not sufficient.
But I'm not sure whether clearing TIF_MEMDIE immediately after reaping completed
is preferable. Clearing TIF_MEMDIE some time later might be better.

For example,

	mutex_lock(&oom_lock);
	exit_oom_victim(tsk);
	mutex_unlock(&oom_lock);

will avoid race between ongoing select_bad_process() from out_of_memory()
and oom_reap_task().

For example,

	mutex_lock(&oom_lock);
	msleep(100);
	exit_oom_victim(tsk);
	mutex_unlock(&oom_lock);

would make more unlikely to OOM-kill next victim by giving some time to
allow get_page_from_freelist() to succeed.

> 
> > than
> > 
> >   struct task_struct {
> >   	(...snipped...)
> >   	struct list_head oom_reaper_list;
> >   	(...snipped...)
> >   }
> > 
> > so that we can update all ->oom_score_adj using this mm_struct for handling
> > crazy combo ( http://lkml.kernel.org/r/20160204163113.GF14425@dhcp22.suse.cz ) ?
> 
> I find it much easier to to simply skip over tasks with MMF_OOM_KILLED
> when already selecting a victim. We won't need oom_score_adj games at
> all. This needs a deeper evaluation though. I didn't get to it yet,
> but the point of having MMF flag which is not oom_reaper specific
> was to have it reusable in other contexts as well.

I think below patch can handle crazy combo without using MMF flag.

----------
>From 47c4bba988eae2f761894c679e6f57668d4cacd3 Mon Sep 17 00:00:00 2001
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Date: Mon, 29 Feb 2016 09:57:30 +0900
Subject: [PATCH 1/2] mm,oom: Mark OOM-killed processes as no longer
 OOM-unkillable.

Since OOM_SCORE_ADJ_MIN means that the OOM killer must not send SIGKILL
on that process, changing oom_score_adj to OOM_SCORE_ADJ_MIN as soon as
SIGKILL was sent on that process should be OK. This will also solve a
problem that SysRq-f chooses the same process forever.

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
---
 mm/oom_kill.c | 6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 5d5eca9..f5dddc3 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -497,7 +497,6 @@ static bool __oom_reap_task(struct task_struct *tsk)
 	 * improvements. This also means that selecting this task doesn't
 	 * make any sense.
 	 */
-	tsk->signal->oom_score_adj = OOM_SCORE_ADJ_MIN;
 	exit_oom_victim(tsk);
 out:
 	mmput(mm);
@@ -775,8 +774,6 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
 	for_each_process(p) {
 		if (!process_shares_mm(p, mm))
 			continue;
-		if (same_thread_group(p, victim))
-			continue;
 		if (unlikely(p->flags & PF_KTHREAD) || is_global_init(p) ||
 		    p->signal->oom_score_adj == OOM_SCORE_ADJ_MIN) {
 			/*
@@ -788,6 +785,9 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
 			continue;
 		}
 		do_send_sig_info(SIGKILL, SEND_SIG_FORCED, p, true);
+		task_lock(p);
+		p->signal->oom_score_adj = OOM_SCORE_ADJ_MIN;
+		task_unlock(p);
 	}
 	rcu_read_unlock();
 
----------

Regarding oom_kill_allocating_task = 1 case, we can do below if we want to
OOM-kill current before trying to OOM-kill children of current.

----------
>From b0f38de7f07328bca65c5d4b0361d5f73283a6e4 Mon Sep 17 00:00:00 2001
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Date: Mon, 29 Feb 2016 10:03:13 +0900
Subject: [PATCH 2/2] mm,oom: Don't try to OOM-kill children if
 oom_kill_allocating_task = 1.

Trying to OOM-kill children of current can cause killing more than
needed if OOM-killed children can not release memory immediately
because current does not wait for OOM-killed children to release memory.
oom_kill_allocating_task = 1 should try to OOM-kill current first.

Signed-off-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
---
 mm/oom_kill.c | 13 +++++++++++--
 1 file changed, 11 insertions(+), 2 deletions(-)

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index f5dddc3..9098d48 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -682,6 +682,13 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
 	static DEFINE_RATELIMIT_STATE(oom_rs, DEFAULT_RATELIMIT_INTERVAL,
 					      DEFAULT_RATELIMIT_BURST);
 	bool can_oom_reap;
+	const bool kill_current = !p;
+	
+	if (kill_current) {
+		p = current;
+		victim = p;
+		get_task_struct(p);
+	}
 
 	/*
 	 * If the task is already exiting, don't alarm the sysadmin or kill
@@ -702,6 +709,8 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
 	pr_err("%s: Kill process %d (%s) score %u or sacrifice child\n",
 		message, task_pid_nr(p), p->comm, points);
 
+	if (kill_current)
+		goto kill;
 	/*
 	 * If any of p's children has a different mm and is eligible for kill,
 	 * the one with the highest oom_badness() score is sacrificed for its
@@ -730,6 +739,7 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
 	}
 	read_unlock(&tasklist_lock);
 
+kill:
 	p = find_lock_task_mm(victim);
 	if (!p) {
 		put_task_struct(victim);
@@ -889,8 +899,7 @@ bool out_of_memory(struct oom_control *oc)
 	if (sysctl_oom_kill_allocating_task && current->mm &&
 	    !oom_unkillable_task(current, NULL, oc->nodemask) &&
 	    current->signal->oom_score_adj != OOM_SCORE_ADJ_MIN) {
-		get_task_struct(current);
-		oom_kill_process(oc, current, 0, totalpages, NULL,
+		oom_kill_process(oc, NULL, 0, totalpages, NULL,
 				 "Out of memory (oom_kill_allocating_task)");
 		return true;
 	}
----------

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
