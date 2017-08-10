Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 92E756B0292
	for <linux-mm@kvack.org>; Thu, 10 Aug 2017 10:28:34 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id s21so897329oie.5
        for <linux-mm@kvack.org>; Thu, 10 Aug 2017 07:28:34 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id p70si5077508oie.487.2017.08.10.07.28.32
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 10 Aug 2017 07:28:33 -0700 (PDT)
Subject: Re: Re: [PATCH] oom_reaper: close race without using oom_lock
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20170807060243.GA32434@dhcp22.suse.cz>
	<201708080214.v782EoDD084315@www262.sakura.ne.jp>
	<20170810113400.GO23863@dhcp22.suse.cz>
	<201708102110.CAB48416.JSMFVHLOtOOFFQ@I-love.SAKURA.ne.jp>
	<20170810123601.GR23863@dhcp22.suse.cz>
In-Reply-To: <20170810123601.GR23863@dhcp22.suse.cz>
Message-Id: <201708102328.ACD34352.OHFOLJMQVSFOFt@I-love.SAKURA.ne.jp>
Date: Thu, 10 Aug 2017 23:28:14 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: linux-mm@kvack.org, hannes@cmpxchg.org, rientjes@google.com, linux-kernel@vger.kernel.org

Michal Hocko wrote:
> On Thu 10-08-17 21:10:30, Tetsuo Handa wrote:
> > Michal Hocko wrote:
> > > On Tue 08-08-17 11:14:50, Tetsuo Handa wrote:
> > > > Michal Hocko wrote:
> > > > > On Sat 05-08-17 10:02:55, Tetsuo Handa wrote:
> > > > > > Michal Hocko wrote:
> > > > > > > On Wed 26-07-17 20:33:21, Tetsuo Handa wrote:
> > > > > > > > My question is, how can users know it if somebody was OOM-killed needlessly
> > > > > > > > by allowing MMF_OOM_SKIP to race.
> > > > > > > 
> > > > > > > Is it really important to know that the race is due to MMF_OOM_SKIP?
> > > > > > 
> > > > > > Yes, it is really important. Needlessly selecting even one OOM victim is
> > > > > > a pain which is difficult to explain to and persuade some of customers.
> > > > > 
> > > > > How is this any different from a race with a task exiting an releasing
> > > > > some memory after we have crossed the point of no return and will kill
> > > > > something?
> > > > 
> > > > I'm not complaining about an exiting task releasing some memory after we have
> > > > crossed the point of no return.
> > > > 
> > > > What I'm saying is that we can postpone "the point of no return" if we ignore
> > > > MMF_OOM_SKIP for once (both this "oom_reaper: close race without using oom_lock"
> > > > thread and "mm, oom: task_will_free_mem(current) should ignore MMF_OOM_SKIP for
> > > > once." thread). These are race conditions we can avoid without crystal ball.
> > > 
> > > If those races are really that common than we can handle them even
> > > without "try once more" tricks. Really this is just an ugly hack. If you
> > > really care then make sure that we always try to allocate from memory
> > > reserves before going down the oom path. In other words, try to find a
> > > robust solution rather than tweaks around a problem.
> > 
> > Since your "mm, oom: allow oom reaper to race with exit_mmap" patch removes
> > oom_lock serialization from the OOM reaper, possibility of calling out_of_memory()
> > due to successful mutex_trylock(&oom_lock) would increase when the OOM reaper set
> > MMF_OOM_SKIP quickly.
> > 
> > What if task_is_oom_victim(current) became true and MMF_OOM_SKIP was set
> > on current->mm between after __gfp_pfmemalloc_flags() returned 0 and before
> > out_of_memory() is called (due to successful mutex_trylock(&oom_lock)) ?
> > 
> > Excuse me? Are you suggesting to try memory reserves before
> > task_is_oom_victim(current) becomes true?
> 
> No what I've tried to say is that if this really is a real problem,
> which I am not sure about, then the proper way to handle that is to
> attempt to allocate from memory reserves for an oom victim. I would be
> even willing to take the oom_lock back into the oom reaper path if the
> former turnes out to be awkward to implement. But all this assumes this
> is a _real_ problem.

Aren't we back to square one? My question is, how can users know it if
somebody was OOM-killed needlessly by allowing MMF_OOM_SKIP to race.

You don't want to call get_page_from_freelist() from out_of_memory(), do you?
But without passing a flag "whether get_page_from_freelist() with memory reserves
was already attempted if current thread is an OOM victim" to task_will_free_mem()
in out_of_memory() and a flag "whether get_page_from_freelist() without memory
reserves was already attempted if current thread is not an OOM victim" to
test_bit(MMF_OOM_SKIP) in oom_evaluate_task(), we won't be able to know
if somebody was OOM-killed needlessly by allowing MMF_OOM_SKIP to race.

Will you accept passing such flags (something like incomplete patch shown below) ?

--- a/include/linux/oom.h
+++ b/include/linux/oom.h
@@ -35,6 +35,8 @@ struct oom_control {
 	 */
 	const int order;
 
+	const bool reserves_tried;
+
 	/* Used by oom implementation, do not set */
 	unsigned long totalpages;
 	struct task_struct *chosen;
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -303,8 +303,10 @@ static int oom_evaluate_task(struct task_struct *task, void *arg)
 	 * any memory is quite low.
 	 */
 	if (!is_sysrq_oom(oc) && tsk_is_oom_victim(task)) {
-		if (test_bit(MMF_OOM_SKIP, &task->signal->oom_mm->flags))
+		if (test_bit(MMF_OOM_SKIP, &task->signal->oom_mm->flags)) {
+			WARN_ON(!oc->reserves_tried); // can't represent correctly
 			goto next;
+		}
 		goto abort;
 	}
 
@@ -762,7 +764,7 @@ static inline bool __task_will_free_mem(struct task_struct *task)
  * Caller has to make sure that task->mm is stable (hold task_lock or
  * it operates on the current).
  */
-static bool task_will_free_mem(struct task_struct *task)
+static bool task_will_free_mem(struct task_struct *task, const bool reserves_tried)
 {
 	struct mm_struct *mm = task->mm;
 	struct task_struct *p;
@@ -783,8 +785,10 @@ static bool task_will_free_mem(struct task_struct *task)
 	 * This task has already been drained by the oom reaper so there are
 	 * only small chances it will free some more
 	 */
-	if (test_bit(MMF_OOM_SKIP, &mm->flags))
+	if (test_bit(MMF_OOM_SKIP, &mm->flags)) {
+		WARN_ON(task == current && !reserves_tried);
 		return false;
+	}
 
 	if (atomic_read(&mm->mm_users) <= 1)
 		return true;
@@ -827,7 +831,7 @@ static void oom_kill_process(struct oom_control *oc, const char *message)
 	 * its children or threads, just set TIF_MEMDIE so it can die quickly
 	 */
 	task_lock(p);
-	if (task_will_free_mem(p)) {
+	if (task_will_free_mem(p, oc->reserves_tried)) {
 		mark_oom_victim(p);
 		wake_oom_reaper(p);
 		task_unlock(p);
@@ -1011,7 +1015,7 @@ bool out_of_memory(struct oom_control *oc)
 	 * select it.  The goal is to allow it to allocate so that it may
 	 * quickly exit and free its memory.
 	 */
-	if (task_will_free_mem(current)) {
+	if (task_will_free_mem(current, oc->reserves_tried)) {
 		mark_oom_victim(current);
 		wake_oom_reaper(current);
 		return true;
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3244,7 +3244,7 @@ void warn_alloc(gfp_t gfp_mask, nodemask_t *nodemask, const char *fmt, ...)
 }
 
 static inline struct page *
-__alloc_pages_may_oom(gfp_t gfp_mask, unsigned int order,
+__alloc_pages_may_oom(gfp_t gfp_mask, bool reserves_tried, unsigned int order,
 	const struct alloc_context *ac, unsigned long *did_some_progress)
 {
 	struct oom_control oc = {
@@ -3253,6 +3253,7 @@ void warn_alloc(gfp_t gfp_mask, nodemask_t *nodemask, const char *fmt, ...)
 		.memcg = NULL,
 		.gfp_mask = gfp_mask,
 		.order = order,
+		.reserves_tried = reserves_tried,
 	};
 	struct page *page;
 
@@ -3955,7 +3956,8 @@ bool gfp_pfmemalloc_allowed(gfp_t gfp_mask)
 		goto retry_cpuset;
 
 	/* Reclaim has failed us, start killing things */
-	page = __alloc_pages_may_oom(gfp_mask, order, ac, &did_some_progress);
+	page = __alloc_pages_may_oom(gfp_mask, alloc_flags == ALLOC_OOM,
+				     order, ac, &did_some_progress);
 	if (page)
 		goto got_pg;
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
