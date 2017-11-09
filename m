Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 38459440CD7
	for <linux-mm@kvack.org>; Thu,  9 Nov 2017 05:49:24 -0500 (EST)
Received: by mail-it0-f71.google.com with SMTP id h64so8605021itb.6
        for <linux-mm@kvack.org>; Thu, 09 Nov 2017 02:49:24 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id x63si6455257ite.123.2017.11.09.02.49.21
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 09 Nov 2017 02:49:22 -0800 (PST)
Subject: Re: [PATCH 5/5] nommu,oom: Set MMF_OOM_SKIP without waiting for termination.
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1510138908-6265-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
	<1510138908-6265-5-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
	<20171108162427.3hstwbagywwjrh44@dhcp22.suse.cz>
In-Reply-To: <20171108162427.3hstwbagywwjrh44@dhcp22.suse.cz>
Message-Id: <201711091949.BDB73475.OSHFOMQtLFOFVJ@I-love.SAKURA.ne.jp>
Date: Thu, 9 Nov 2017 19:49:16 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.com
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, mgorman@techsingularity.net

Michal Hocko wrote:
> On Wed 08-11-17 20:01:48, Tetsuo Handa wrote:
> > Commit 212925802454672e ("mm: oom: let oom_reap_task and exit_mmap run
> > concurrently") moved the location of setting MMF_OOM_SKIP from __mmput()
> > in kernel/fork.c (which is used by both MMU and !MMU) to exit_mm() in
> > mm/mmap.c (which is used by MMU only). As a result, that commit required
> > OOM victims in !MMU kernels to disappear from the task list in order to
> > reenable the OOM killer, for !MMU kernels can no longer set MMF_OOM_SKIP
> > (unless the OOM victim's mm is shared with global init process).
> 
> nack withtout demonstrating that the problem is real. It is true it
> removes some lines but this is mostly this...

Then, it is impossible unless somebody volunteers proving it.
I'm not a nommu kernel user.

>  
> > While it would be possible to restore MMF_OOM_SKIP in __mmput() for !MMU
> > kernels, let's forget about possibility of OOM livelock for !MMU kernels
> > caused by failing to set MMF_OOM_SKIP, by setting MMF_OOM_SKIP at
> > oom_kill_process(), for the invocation of the OOM killer is a rare event
> > for !MMU systems from the beginning. By doing so, we can get rid of
> > special treatment for !MMU case in commit cd04ae1e2dc8e365 ("mm, oom:
> > do not rely on TIF_MEMDIE for memory reserves access"). And "mm,oom:
> > Use ALLOC_OOM for OOM victim's last second allocation." will allow the
> > OOM victim to try ALLOC_OOM (instead of ALLOC_NO_WATERMARKS) allocation
> > before killing more OOM victims.
> ...
> >  static bool oom_reserves_allowed(struct task_struct *tsk)
> >  {
> > -	if (!tsk_is_oom_victim(tsk))
> > -		return false;
> > -
> > -	/*
> > -	 * !MMU doesn't have oom reaper so give access to memory reserves
> > -	 * only to the thread with TIF_MEMDIE set
> > -	 */
> > -	if (!IS_ENABLED(CONFIG_MMU) && !test_thread_flag(TIF_MEMDIE))
> > -		return false;
> > -
> > -	return true;
> > +	return tsk_is_oom_victim(tsk);
> >  }
> 
> and the respective ALLOC_OOM change for nommu. The sole purpose of the
> code was to prevent from potential problem pointed out by _you_ that
> nommu doesn't have the oom reaper and as such we cannot rely on partial
> oom reserves. So I am quite surprised that you no longer insist on
> the nommu theoretical issue. AFAIR you insisted hard back then. I am not
> really sure what has changed since then. I would love to ack a patch
> which removes the conditional oom reserves handling with an explanation
> why it is not a problem anymore.

Because this patch changes to guarantee that MMF_OOM_SKIP is set, based on
an assumption that OOM lockup for !MMU kernel is a theoretical issue and
invocation of the OOM killer is a rare event for !MMU systems.

> 
> On Wed 08-11-17 20:01:48, Tetsuo Handa wrote:
> [...]
> > @@ -829,7 +831,7 @@ static void oom_kill_process(struct oom_control *oc, const char *message)
> >  	unsigned int victim_points = 0;
> >  	static DEFINE_RATELIMIT_STATE(oom_rs, DEFAULT_RATELIMIT_INTERVAL,
> >  					      DEFAULT_RATELIMIT_BURST);
> > -	bool can_oom_reap = true;
> > +	bool can_oom_reap = IS_ENABLED(CONFIG_MMU);
> >  
> >  	/*
> >  	 * If the task is already exiting, don't alarm the sysadmin or kill
> > @@ -929,7 +931,6 @@ static void oom_kill_process(struct oom_control *oc, const char *message)
> >  			continue;
> >  		if (is_global_init(p)) {
> >  			can_oom_reap = false;
> > -			set_bit(MMF_OOM_SKIP, &mm->flags);
> >  			pr_info("oom killer %d (%s) has mm pinned by %d (%s)\n",
> >  					task_pid_nr(victim), victim->comm,
> >  					task_pid_nr(p), p->comm);
> > @@ -947,6 +948,8 @@ static void oom_kill_process(struct oom_control *oc, const char *message)
> >  
> >  	if (can_oom_reap)
> >  		wake_oom_reaper(victim);
> > +	else
> > +		set_bit(MMF_OOM_SKIP, &mm->flags);
> >  
> >  	mmdrop(mm);
> >  	put_task_struct(victim);
> 
> Also this looks completely broken. nommu kernels lose the premature oom
> killing protection almost completely (they simply rely on the sleep
> before dropping the oom_lock).
> 

If you are worrying that setting MMF_OOM_SKIP immediately might cause
premature OOM killing), what we would afford is timeout-based approach
shown below, for it will be a waste of resource to add the OOM reaper kernel
thread which does nothing but setting MMF_OOM_SKIP.

---
 include/linux/mm_types.h |  3 +++
 mm/internal.h            |  9 ---------
 mm/oom_kill.c            | 16 +++++++++++++++-
 mm/page_alloc.c          | 12 +-----------
 4 files changed, 19 insertions(+), 21 deletions(-)

diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index cfd0ac4..ad60b33 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -501,6 +501,9 @@ struct mm_struct {
 	atomic_long_t hugetlb_usage;
 #endif
 	struct work_struct async_put_work;
+#ifndef CONFIG_MMU
+	unsigned long oom_victim_start;
+#endif
 
 #if IS_ENABLED(CONFIG_HMM)
 	/* HMM needs to track a few things per mm */
diff --git a/mm/internal.h b/mm/internal.h
index e6bd351..f0eb8d9 100644
--- a/mm/internal.h
+++ b/mm/internal.h
@@ -481,16 +481,7 @@ unsigned long reclaim_clean_pages_from_list(struct zone *zone,
 /* Mask to get the watermark bits */
 #define ALLOC_WMARK_MASK	(ALLOC_NO_WATERMARKS-1)
 
-/*
- * Only MMU archs have async oom victim reclaim - aka oom_reaper so we
- * cannot assume a reduced access to memory reserves is sufficient for
- * !MMU
- */
-#ifdef CONFIG_MMU
 #define ALLOC_OOM		0x08
-#else
-#define ALLOC_OOM		ALLOC_NO_WATERMARKS
-#endif
 
 #define ALLOC_HARDER		0x10 /* try to alloc harder */
 #define ALLOC_HIGH		0x20 /* __GFP_HIGH set */
diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index 1472917..f277619 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -324,7 +324,13 @@ static int oom_evaluate_task(struct task_struct *task, void *arg)
 	 * any memory is quite low.
 	 */
 	if (!is_sysrq_oom(oc) && tsk_is_oom_victim(task)) {
-		if (test_bit(MMF_OOM_SKIP, &task->signal->oom_mm->flags))
+		struct mm_struct *mm = task->signal->oom_mm;
+
+#ifndef CONFIG_MMU
+		if (time_after(jiffies, mm->oom_victim_start + HZ))
+			set_bit(MMF_OOM_SKIP, &mm->flags);
+#endif
+		if (test_bit(MMF_OOM_SKIP, &mm->flags))
 			goto next;
 		goto abort;
 	}
@@ -671,6 +677,9 @@ static void mark_oom_victim(struct task_struct *tsk)
 	/* oom_mm is bound to the signal struct life time. */
 	if (!cmpxchg(&tsk->signal->oom_mm, NULL, mm))
 		mmgrab(tsk->signal->oom_mm);
+#ifndef CONFIG_MMU
+	mm->oom_victim_start = jiffies;
+#endif
 
 	/*
 	 * Make sure that the task is woken up from uninterruptible sleep
@@ -791,6 +800,11 @@ static bool task_will_free_mem(struct task_struct *task)
 	 * This task has already been drained by the oom reaper so there are
 	 * only small chances it will free some more
 	 */
+#ifndef CONFIG_MMU
+	if (tsk_is_oom_victim(task) &&
+	    time_after(jiffies, mm->oom_victim_start + HZ))
+		set_bit(MMF_OOM_SKIP, &mm->flags);
+#endif
 	if (test_bit(MMF_OOM_SKIP, &mm->flags))
 		return false;
 
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index fbbc95a..ff435f7 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3711,17 +3711,7 @@ static void wake_all_kswapds(unsigned int order, const struct alloc_context *ac)
 
 static bool oom_reserves_allowed(struct task_struct *tsk)
 {
-	if (!tsk_is_oom_victim(tsk))
-		return false;
-
-	/*
-	 * !MMU doesn't have oom reaper so give access to memory reserves
-	 * only to the thread with TIF_MEMDIE set
-	 */
-	if (!IS_ENABLED(CONFIG_MMU) && !test_thread_flag(TIF_MEMDIE))
-		return false;
-
-	return true;
+	return tsk_is_oom_victim(tsk);
 }
 
 /*
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
