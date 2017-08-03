Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 1E35D6B064B
	for <linux-mm@kvack.org>; Wed,  2 Aug 2017 21:40:03 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id z19so12537oia.13
        for <linux-mm@kvack.org>; Wed, 02 Aug 2017 18:40:03 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id w132si22073794oib.514.2017.08.02.18.40.00
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 02 Aug 2017 18:40:01 -0700 (PDT)
Subject: Re: [PATCH 1/2] mm, oom: do not rely on TIF_MEMDIE for memory reserves access
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20170727090357.3205-1-mhocko@kernel.org>
	<20170727090357.3205-2-mhocko@kernel.org>
	<201708020030.ACB04683.JLHMFVOSFFOtOQ@I-love.SAKURA.ne.jp>
	<20170801165242.GA15518@dhcp22.suse.cz>
In-Reply-To: <20170801165242.GA15518@dhcp22.suse.cz>
Message-Id: <201708031039.GDG05288.OQJOHtLVFMSFFO@I-love.SAKURA.ne.jp>
Date: Thu, 3 Aug 2017 10:39:42 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: akpm@linux-foundation.org, rientjes@google.com, hannes@cmpxchg.org, guro@fb.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Michal Hocko wrote:
> On Wed 02-08-17 00:30:33, Tetsuo Handa wrote:
> > > @@ -3603,6 +3612,22 @@ gfp_to_alloc_flags(gfp_t gfp_mask)
> > >  	return alloc_flags;
> > >  }
> > >  
> > > +static bool oom_reserves_allowed(struct task_struct *tsk)
> > > +{
> > > +	if (!tsk_is_oom_victim(tsk))
> > > +		return false;
> > > +
> > > +	/*
> > > +	 * !MMU doesn't have oom reaper so we shouldn't risk the memory reserves
> > > +	 * depletion and shouldn't give access to memory reserves passed the
> > > +	 * exit_mm
> > > +	 */
> > > +	if (!IS_ENABLED(CONFIG_MMU) && !tsk->mm)
> > > +		return false;
> > 
> > Branching based on CONFIG_MMU is ugly. I suggest timeout based next OOM
> > victim selection if CONFIG_MMU=n.
> 
> I suggest we do not argue about nommu without actually optimizing for or
> fixing nommu which we are not here. I am even not sure memory reserves
> can ever be depleted for that config.

I don't think memory reserves can deplete for CONFIG_MMU=n environment.
But the reason the OOM reaper was introduced is not limited to handling
depletion of memory reserves. The OOM reaper was introduced because
OOM victims might get stuck indirectly waiting for other threads doing
memory allocation. You said

  > Yes, exit_aio is the only blocking call I know of currently. But I would
  > like this to be as robust as possible and so I do not want to rely on
  > the current implementation. This can change in future and I can
  > guarantee that nobody will think about the oom path when adding
  > something to the final __mmput path.

at http://lkml.kernel.org/r/20170726054533.GA960@dhcp22.suse.cz , but
how can you guarantee that nobody will think about the oom path
when adding something to the final __mmput() path without thinking
about possibility of getting stuck waiting for memory allocation in
CONFIG_MMU=n environment? As long as possibility of getting stuck remains,
you should not assume that something you don't want will not happen.
It's time to make CONFIG_MMU=n kernels treatable like CONFIG_MMU=y kernels.

If it is technically impossible (or is not worthwhile) to implement
the OOM reaper for CONFIG_MMU=n kernels, I'm fine with timeout based
approach like shown below. Then, we no longer need to use branching
based on CONFIG_MMU.

 include/linux/mm_types.h |  3 +++
 mm/oom_kill.c            | 20 +++++++++++++++-----
 2 files changed, 18 insertions(+), 5 deletions(-)

diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 7f384bb..374a2ae 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -504,6 +504,9 @@ struct mm_struct {
 	atomic_long_t hugetlb_usage;
 #endif
 	struct work_struct async_put_work;
+#ifndef CONFIG_MMU
+	unsigned long oom_victim_wait_timer;
+#endif
 } __randomize_layout;
 
 extern struct mm_struct init_mm;
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 9e8b4f0..dd6239d 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -53,6 +53,17 @@
 
 DEFINE_MUTEX(oom_lock);
 
+static bool should_ignore_this_mm(struct mm_struct *mm)
+{
+#ifndef CONFIG_MMU
+	if (!mm->oom_victim_wait_timer)
+		mm->oom_victim_wait_timer = jiffies;
+	else if (time_after(jiffies, mm->oom_victim_wait_timer + HZ))
+		return true;
+#endif
+	return test_bit(MMF_OOM_SKIP, &mm->flags);
+};
+
 #ifdef CONFIG_NUMA
 /**
  * has_intersects_mems_allowed() - check task eligiblity for kill
@@ -188,9 +199,8 @@ unsigned long oom_badness(struct task_struct *p, struct mem_cgroup *memcg,
 	 * the middle of vfork
 	 */
 	adj = (long)p->signal->oom_score_adj;
-	if (adj == OOM_SCORE_ADJ_MIN ||
-			test_bit(MMF_OOM_SKIP, &p->mm->flags) ||
-			in_vfork(p)) {
+	if (adj == OOM_SCORE_ADJ_MIN || should_ignore_this_mm(p->mm) ||
+	    in_vfork(p)) {
 		task_unlock(p);
 		return 0;
 	}
@@ -303,7 +313,7 @@ static int oom_evaluate_task(struct task_struct *task, void *arg)
 	 * any memory is quite low.
 	 */
 	if (!is_sysrq_oom(oc) && tsk_is_oom_victim(task)) {
-		if (test_bit(MMF_OOM_SKIP, &task->signal->oom_mm->flags))
+		if (should_ignore_this_mm(task->signal->oom_mm))
 			goto next;
 		goto abort;
 	}
@@ -783,7 +793,7 @@ static bool task_will_free_mem(struct task_struct *task)
 	 * This task has already been drained by the oom reaper so there are
 	 * only small chances it will free some more
 	 */
-	if (test_bit(MMF_OOM_SKIP, &mm->flags))
+	if (should_ignore_this_mm(mm))
 		return false;
 
 	if (atomic_read(&mm->mm_users) <= 1)
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
