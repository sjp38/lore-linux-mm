Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 405456B007E
	for <linux-mm@kvack.org>; Tue,  7 Jun 2016 10:30:39 -0400 (EDT)
Received: by mail-it0-f72.google.com with SMTP id h144so178907334ita.1
        for <linux-mm@kvack.org>; Tue, 07 Jun 2016 07:30:39 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id h194si35230458pfe.82.2016.06.07.07.30.35
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 07 Jun 2016 07:30:38 -0700 (PDT)
Subject: Re: [PATCH 0/10 -v3] Handle oom bypass more gracefully
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1464945404-30157-1-git-send-email-mhocko@kernel.org>
	<201606032100.AIH12958.HMOOOFLJSFQtVF@I-love.SAKURA.ne.jp>
	<20160603122030.GG20676@dhcp22.suse.cz>
	<201606040017.HDI52680.LFFOVMJQOFSOHt@I-love.SAKURA.ne.jp>
	<20160606083651.GE11895@dhcp22.suse.cz>
In-Reply-To: <20160606083651.GE11895@dhcp22.suse.cz>
Message-Id: <201606072330.AHH81886.OOMVHFOFLtFSQJ@I-love.SAKURA.ne.jp>
Date: Tue, 7 Jun 2016 23:30:20 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: linux-mm@kvack.org, rientjes@google.com, oleg@redhat.com, vdavydov@parallels.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org

Michal Hocko wrote:
> > To be honest, I don't think we need to apply this pile.
> 
> So you do not think that the current pile is making the code easier to
> understand and more robust as well as the semantic more consistent?

Right. It is getting too complicated for me to understand.

Below patch on top of 4.7-rc2 will do the job and can do for
CONFIG_MMU=n kernels as well.

----------
 include/linux/sched.h |    2 ++
 mm/memcontrol.c       |    4 +++-
 mm/oom_kill.c         |   17 ++++++++++++++---

 3 files changed, 19 insertions(+), 4 deletions(-)
diff --git a/include/linux/sched.h b/include/linux/sched.h
index 6e42ada..6865f91 100644
--- a/include/linux/sched.h
+++ b/include/linux/sched.h
@@ -799,6 +799,7 @@ struct signal_struct {
 	 * oom
 	 */
 	bool oom_flag_origin;
+	bool oom_killed; /* Already chosen by the OOM killer */
 	short oom_score_adj;		/* OOM kill score adjustment */
 	short oom_score_adj_min;	/* OOM kill score adjustment min value.
 					 * Only settable by CAP_SYS_RESOURCE. */
@@ -1545,6 +1546,7 @@ struct task_struct {
 	/* unserialized, strictly 'current' */
 	unsigned in_execve:1; /* bit to tell LSMs we're in execve */
 	unsigned in_iowait:1;
+	unsigned oom_shortcut_done:1;
 #ifdef CONFIG_MEMCG
 	unsigned memcg_may_oom:1;
 #ifndef CONFIG_SLOB
diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 58c69c9..425fede 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1275,7 +1275,9 @@ static bool mem_cgroup_out_of_memory(struct mem_cgroup *memcg, gfp_t gfp_mask,
 	 * select it.  The goal is to allow it to allocate so that it may
 	 * quickly exit and free its memory.
 	 */
-	if (fatal_signal_pending(current) || task_will_free_mem(current)) {
+	if ((fatal_signal_pending(current) || task_will_free_mem(current)) &&
+	    !current->oom_shortcut_done) {
+		current->oom_shortcut_done = 1;
 		mark_oom_victim(current);
 		try_oom_reaper(current);
 		goto unlock;
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index acbc432..a495ed0 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -50,6 +50,11 @@ int sysctl_oom_dump_tasks = 1;
 
 DEFINE_MUTEX(oom_lock);
 
+static void oomkiller_reset(unsigned long arg)
+{
+}
+static DEFINE_TIMER(oomkiller_victim_wait_timer, oomkiller_reset, 0, 0);
+
 #ifdef CONFIG_NUMA
 /**
  * has_intersects_mems_allowed() - check task eligiblity for kill
@@ -179,7 +184,7 @@ unsigned long oom_badness(struct task_struct *p, struct mem_cgroup *memcg,
 	 * unkillable or have been already oom reaped.
 	 */
 	adj = (long)p->signal->oom_score_adj;
-	if (adj == OOM_SCORE_ADJ_MIN ||
+	if (adj == OOM_SCORE_ADJ_MIN || p->signal->oom_killed ||
 			test_bit(MMF_OOM_REAPED, &p->mm->flags)) {
 		task_unlock(p);
 		return 0;
@@ -284,7 +289,8 @@ enum oom_scan_t oom_scan_process_thread(struct oom_control *oc,
 	 * Don't allow any other task to have access to the reserves.
 	 */
 	if (!is_sysrq_oom(oc) && atomic_read(&task->signal->oom_victims))
-		return OOM_SCAN_ABORT;
+		return timer_pending(&oomkiller_victim_wait_timer) ?
+			OOM_SCAN_ABORT : OOM_SCAN_CONTINUE;
 
 	/*
 	 * If task is allocating a lot of memory and has been marked to be
@@ -678,6 +684,8 @@ void mark_oom_victim(struct task_struct *tsk)
 	if (test_and_set_tsk_thread_flag(tsk, TIF_MEMDIE))
 		return;
 	atomic_inc(&tsk->signal->oom_victims);
+	mod_timer(&oomkiller_victim_wait_timer, jiffies + 3 * HZ);
+	tsk->signal->oom_killed = true;
 	/*
 	 * Make sure that the task is woken up from uninterruptible sleep
 	 * if it is frozen because OOM killer wouldn't be able to free
@@ -856,6 +864,7 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
 			continue;
 		}
 		do_send_sig_info(SIGKILL, SEND_SIG_FORCED, p, true);
+		p->signal->oom_killed = true;
 	}
 	rcu_read_unlock();
 
@@ -940,7 +949,9 @@ bool out_of_memory(struct oom_control *oc)
 	 * TIF_MEMDIE flag at exit_mm(), otherwise an OOM livelock may occur.
 	 */
 	if (current->mm &&
-	    (fatal_signal_pending(current) || task_will_free_mem(current))) {
+	    (fatal_signal_pending(current) || task_will_free_mem(current)) &&
+	    !current->oom_shortcut_done) {
+		current->oom_shortcut_done = 1;
 		mark_oom_victim(current);
 		try_oom_reaper(current);
 		return true;
----------

> 
> > What is missing for
> > handling subtle and unlikely issues is "eligibility check for not to select
> > the same victim forever" (i.e. always set MMF_OOM_REAPED or OOM_SCORE_ADJ_MIN,
> > and check them before exercising the shortcuts).
> 
> Which is a hard problem as we do not have enough context for that. Most
> situations are covered now because we are much less optimistic when
> bypassing the oom killer and basically most sane situations are oom
> reapable.

What is wrong with above patch? How much difference is there compared to
calling schedule_timeout_killable(HZ) in oom_kill_process() before
releasing oom_lock and later checking MMF_OOM_REAPED after re-taking
oom_lock when we can't wake up the OOM reaper?

> 
> > Current 4.7-rc1 code will be sufficient (and sometimes even better than
> > involving user visible changes / selecting next OOM victim without delay)
> > if we started with "decision by timer" (e.g.
> > http://lkml.kernel.org/r/201601072026.JCJ95845.LHQOFOOSMFtVFJ@I-love.SAKURA.ne.jp )
> > approach.
> > 
> > As long as you insist on "decision by feedback from the OOM reaper",
> > we have to guarantee that the OOM reaper is always invoked in order to
> > handle subtle and unlikely cases.
> 
> And I still believe that a decision based by a feedback is a better
> solution than a timeout. So I am pretty much for exploring that way
> until we really find out we cannot really go forward any longer.

I'm OK with "a decision based by a feedback" but you don't like waking up
the OOM reaper ("invoking the oom reaper just to find out what we know
already and it is unlikely to change after oom_kill_process just doesn't
make much sense."). So what feedback mechanisms are possible other than
timeout like above patch?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
