Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2DA266B0069
	for <linux-mm@kvack.org>; Sat, 10 Sep 2016 02:30:22 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id o7so153938910oif.0
        for <linux-mm@kvack.org>; Fri, 09 Sep 2016 23:30:22 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id v34si4666063otv.281.2016.09.09.23.30.20
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 09 Sep 2016 23:30:21 -0700 (PDT)
Subject: Re: [RFC 3/4] mm, oom: do not rely on TIF_MEMDIE for exit_oom_victim
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1472723464-22866-1-git-send-email-mhocko@kernel.org>
	<1472723464-22866-4-git-send-email-mhocko@kernel.org>
	<201609041050.BFG65134.OHVFQJOOSLMtFF@I-love.SAKURA.ne.jp>
	<20160909140851.GP4844@dhcp22.suse.cz>
In-Reply-To: <20160909140851.GP4844@dhcp22.suse.cz>
Message-Id: <201609101529.GCI12481.VOtOLHJQFOSMFF@I-love.SAKURA.ne.jp>
Date: Sat, 10 Sep 2016 15:29:34 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: linux-mm@kvack.org, rientjes@google.com, hannes@cmpxchg.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, oleg@redhat.com, viro@zeniv.linux.org.uk

Michal Hocko wrote:
> On Sun 04-09-16 10:50:02, Tetsuo Handa wrote:
> > Michal Hocko wrote:
> > > mark_oom_victim and exit_oom_victim are used for oom_killer_disable
> > > which should block as long as there any any oom victims alive. Up to now
> > > we have relied on TIF_MEMDIE task flag to count how many oom victim
> > > we have. This is not optimal because only one thread receives this flag
> > > at the time while the whole process (thread group) is killed and should
> > > die. As a result we do not thaw the whole thread group and so a multi
> > > threaded process can leave some threads behind in the fridge. We really
> > > want to thaw all the threads.
> > > 
> > > This is not all that easy because there is no reliable way to count
> > > threads in the process as the oom killer might race with copy_process.
> > 
> > What is wrong with racing with copy_process()? Threads doing copy_process()
> > are not frozen and thus we don't need to thaw such threads. Also, being
> > OOM-killed implies receiving SIGKILL. Thus, newly created thread will also
> > enter do_exit().
> 
> The problem is that we cannot rely on signal->nr_threads to know when
> the last one is passing exit to declare the whole group done and wake
> the waiter on the oom killer lock.

I don't think we need to rely on signal->nr_threads. Why can't we simply
do something like below (like error reporting in try_to_freeze_tasks()) ?

diff --git a/mm/oom_kill.c b/mm/oom_kill.c
index f284e92..8a1c008 100644
--- a/mm/oom_kill.c
+++ b/mm/oom_kill.c
@@ -419,12 +419,6 @@ static void dump_header(struct oom_control *oc, struct task_struct *p)
 		dump_tasks(oc->memcg, oc->nodemask);
 }
 
-/*
- * Number of OOM victims in flight
- */
-static atomic_t oom_victims = ATOMIC_INIT(0);
-static DECLARE_WAIT_QUEUE_HEAD(oom_victims_wait);
-
 static bool oom_killer_disabled __read_mostly;
 
 #define K(x) ((x) << (PAGE_SHIFT-10))
@@ -666,7 +660,6 @@ static void mark_oom_victim(struct task_struct *tsk)
 	 * that TIF_MEMDIE tasks should be ignored.
 	 */
 	__thaw_task(tsk);
-	atomic_inc(&oom_victims);
 }
 
 /**
@@ -675,9 +668,6 @@ static void mark_oom_victim(struct task_struct *tsk)
 void exit_oom_victim(void)
 {
 	clear_thread_flag(TIF_MEMDIE);
-
-	if (!atomic_dec_return(&oom_victims))
-		wake_up_all(&oom_victims_wait);
 }
 
 /**
@@ -705,8 +695,6 @@ void oom_killer_enable(void)
  */
 bool oom_killer_disable(signed long timeout)
 {
-	signed long ret;
-
 	/*
 	 * Make sure to not race with an ongoing OOM killer. Check that the
 	 * current is not killed (possibly due to sharing the victim's memory).
@@ -716,14 +704,37 @@ bool oom_killer_disable(signed long timeout)
 	oom_killer_disabled = true;
 	mutex_unlock(&oom_lock);
 
-	ret = wait_event_interruptible_timeout(oom_victims_wait,
-			!atomic_read(&oom_victims), timeout);
-	if (ret <= 0) {
-		oom_killer_enable();
-		return false;
-	}
+	/*
+	 * Wait until all thawed threads reach final schedule() in do_exit()
+	 * in order to make sure that OOM victims no longer try to trigger I/O.
+	 *
+	 * Since freezing_slow_path(p) returns false if TIF_MEMDIE is set, we
+	 * need to check TASK_DEAD if TIF_MEMDIE is set.
+	 */
+	while (timeout > 0) {
+		struct task_struct *g, *p;
+		bool busy = false;
 
-	return true;
+		read_lock(&tasklist_lock);
+		for_each_process_thread(g, p) {
+			if (freezer_should_skip(p) || frozen(p) || p == current)
+				continue;
+			if (freezing(p) ||
+			    (p->state != TASK_DEAD &&
+			     test_tsk_thread_flag(p, TIF_MEMDIE))) {
+				busy = true;
+				goto out;
+			}
+		}
+out:
+		read_unlock(&tasklist_lock);
+		if (!busy)
+			return true;
+		schedule_timeout_killable(HZ / 10);
+		timeout -= HZ / 10;
+	}
+	oom_killer_enable();
+	return false;
 }
 
 static inline bool __task_will_free_mem(struct task_struct *task)

> 
> > > So marking all threads with TIF_MEMDIE and increment oom_victims
> > > accordingly is not safe. Also TIF_MEMDIE flag should just die so
> > > we should better come up with a different approach.
> > > 
> > > All we need to guarantee is that exit_oom_victim is called at the time
> > > when no further access to (possibly suspended) devices or generate other
> > > IO (which would clobber suspended image and only once per process)
> > > is possible. It seems we can rely on exit_notify for that because we
> > > already have to detect the last thread to do a cleanup. Let's propagate
> > > that information up to do_exit and only call exit_oom_victim for such
> > > a thread. With this in place we can safely increment oom_victims only
> > > once per thread group and thaw all the threads from the process.
> > > freezing_slow_path can also rely on tsk_is_oom_victim as well now.
> > 
> > If marking all threads which belong to tsk thread group with TIF_MEMDIE
> > is not safe (due to possible race with copy_process()), how can
> > 
> > 	rcu_read_lock();
> > 	for_each_thread(tsk, t)
> > 		__thaw_task(t);
> > 	rcu_read_unlock();
> > 
> > in mark_oom_victim() guarantee that all threads which belong to tsk
> > thread group are thawed?
> 
> Because all the frozen thread already have to be hashed and those which
> are in the middle of copy process will be tsk_is_oom_victim and so the
> freezer will skip them.

Is it true for clone(CLONE_VM && !CLONE_SIGHAND) case?
tsk_is_oom_victim() is a per signal check but we don't call mark_oom_victim()
on each thread group sharing the victim's memory.

> > Unless all threads which belong to tsk thread group in __refrigerator()
> > are guaranteed to be thawed, they might fail to leave __refrigerator()
> > in order to enter do_exit() which means that exit_oom_victim() won't be
> > called.
> > 
> > Do we want to thaw OOM victims from the beginning? If the freezer
> > depends on CONFIG_MMU=y , we don't need to thaw OOM victims.
> 
> We want to thaw them, at least at this stage, because the task might be
> sitting on a memory which is not reclaimable by the oom reaper (e.g.
> different buffers of file descriptors etc.).

If you worry about tasks which are sitting on a memory which is not
reclaimable by the oom reaper, why you don't worry about tasks which
share mm and do not share signal (i.e. clone(CLONE_VM && !CLONE_SIGHAND)
tasks) ? Thawing only tasks which share signal is a halfway job.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
