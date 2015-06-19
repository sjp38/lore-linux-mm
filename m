Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f172.google.com (mail-ob0-f172.google.com [209.85.214.172])
	by kanga.kvack.org (Postfix) with ESMTP id 07B726B0089
	for <linux-mm@kvack.org>; Fri, 19 Jun 2015 07:30:23 -0400 (EDT)
Received: by obbgp2 with SMTP id gp2so72409907obb.2
        for <linux-mm@kvack.org>; Fri, 19 Jun 2015 04:30:22 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id wy9si6710465oeb.105.2015.06.19.04.30.21
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 19 Jun 2015 04:30:21 -0700 (PDT)
Subject: Re: [RFC -v2] panic_on_oom_timeout
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20150617121104.GD25056@dhcp22.suse.cz>
	<201506172131.EFE12444.JMLFOSVOHFOtFQ@I-love.SAKURA.ne.jp>
	<20150617125127.GF25056@dhcp22.suse.cz>
	<201506172259.EAI00575.OFQtVFFSHMOLJO@I-love.SAKURA.ne.jp>
	<20150617154159.GJ25056@dhcp22.suse.cz>
In-Reply-To: <20150617154159.GJ25056@dhcp22.suse.cz>
Message-Id: <201506192030.CAH00597.FQVOtFFLOJMHOS@I-love.SAKURA.ne.jp>
Date: Fri, 19 Jun 2015 20:30:10 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.cz
Cc: linux-mm@kvack.org, rientjes@google.com, hannes@cmpxchg.org, tj@kernel.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org

Michal Hocko wrote:
> On Wed 17-06-15 22:59:54, Tetsuo Handa wrote:
> > Michal Hocko wrote:
> [...]
> > > But you have a point that we could have
> > > - constrained OOM which elevates oom_victims
> > > - global OOM killer strikes but wouldn't start the timer
> > > 
> > > This is certainly possible and timer_pending(&panic_on_oom) replacing
> > > oom_victims check should help here. I will think about this some more.
> > 
> > Yes, please.
> 
> Fixed in my local version. I will post the new version of the patch
> after we settle with the approach.
> 

I'd like to see now, for it looks to me that it is very difficult to expire
your timeout with reasonable precision.

I think that you changed

	/*
	 * Only schedule the delayed panic_on_oom when this is
	 * the first OOM triggered. oom_lock will protect us
	 * from races
	 */
	if (atomic_read(&oom_victims))
		return;

to something like

	/*
	 * Schedule the delayed panic_on_oom if timer is not active.
	 * oom_lock will protect us from races.
	 */
	if (timer_pending(&panic_on_oom_timer))
		return;

. But such change alone sounds far from sufficient.

We are trying to activate panic_on_oom_timer timer only when
sysctl_panic_on_oom == 1 and global OOM occurred because you add
this block after

	if (likely(!sysctl_panic_on_oom))
		return;
	if (sysctl_panic_on_oom != 2) {
		/*
		 * panic_on_oom == 1 only affects CONSTRAINT_NONE, the kernel
		 * does not panic for cpuset, mempolicy, or memcg allocation
		 * failures.
		*/
		if (constraint != CONSTRAINT_NONE)
			return;
	}

check. That part is fine.

But oom_victims is incremented via mark_oom_victim() for both global OOM
and non-global OOM, isn't it? Then, I think that more difficult part is
exit_oom_victim().

We can hit a sequence like

  (1) Task1 in memcg1 hits memcg OOM.
  (2) Task1 gets TIF_MEMDIE and increments oom_victims.
  (3) Task2 hits global OOM.
  (4) Task2 activates 10 seconds of timeout.
  (5) Task2 gets TIF_MEMDIE and increments oom_victims.
  (6) Task2 remained unkillable for 1 second since (5).
  (7) Task2 calls exit_oom_victim().
  (8) Task2 drops TIF_MEMDIE and decrements oom_victims.
  (9) panic_on_oom_timer is not deactivated because oom_vctims > 0.
  (10) Task1 remains unkillable for 10 seconds since (2).
  (11) panic_on_oom_timer expires and the system will panic while
       the system is no longer under global OOM.

if we deactivate panic_on_oom_timer like

 void exit_oom_victim(void)
 {
 	clear_thread_flag(TIF_MEMDIE);
 
-	if (!atomic_dec_return(&oom_victims))
+	if (!atomic_dec_return(&oom_victims)) {
+		del_timer(&panic_on_oom_timer);
 		wake_up_all(&oom_victims_wait);
+	}
 }

.

On the other hand, we can hit a sequence like

  (1) Task1 in memcg1 hits memcg OOM.
  (2) Task1 gets TIF_MEMDIE and increments oom_victims.
  (3) Task2 hits system OOM.
  (4) Task2 activates 10 seconds of timeout.
  (5) Task2 gets TIF_MEMDIE and increments oom_victims.
  (6) Task1 remained unkillable for 9 seconds since (2).
  (7) Task1 calls exit_oom_victim().
  (8) Task1 drops TIF_MEMDIE and decrements oom_victims.
  (9) panic_on_oom_timer is deactivated.
  (10) Task3 hits system OOM.
  (11) Task3 again activates 10 seconds of timeout.
  (12) Task2 remains unkillable for 19 seconds since (5).
  (13) panic_on_oom_timer expires and the system will panic, but
       the expected timeout is 10 seconds while actual timeout is
       19 seconds.

if we deactivate panic_on_oom_timer like

 void exit_oom_victim(void)
 {
 	clear_thread_flag(TIF_MEMDIE);
 
+	del_timer(&panic_on_oom_timer);
	if (!atomic_dec_return(&oom_victims))
 		wake_up_all(&oom_victims_wait);
 }

.

If we want to avoid premature or over-delayed timeout, I think we need to
update timeout at exit_oom_victim() by doing something like

 void exit_oom_victim(void)
 {
 	clear_thread_flag(TIF_MEMDIE);
 
+	/*
+	 * If current thread got TIF_MEMDIE due to global OOM, we need to
+	 * update panic_on_oom_timer to "jiffies till the nearest timeout
+	 * of all threads which got TIF_MEMDIE due to global OOM" and
+	 * delete panic_on_oom_timer if "there is no more threads which
+	 * got TIF_MEMDIE due to global OOM".
+	 */
+	if (/* Was I OOM-killed due to global OOM? */) {
+		mutex_lock(&oom_lock); /* oom_lock needed for avoiding race. */
+		if (/* Am I the last thread ? */) {
+			del_timer(&panic_on_oom_timer);
+		else
+			mod_timer(&panic_on_oom_timer,
+				  /* jiffies of the nearest timeout */);
+		mutex_unlock(&oom_lock);
+	}
 	if (!atomic_dec_return(&oom_victims))
 		wake_up_all(&oom_victims_wait);
 }

but we don't have hint for finding global OOM victims from all TIF_MEMDIE
threads and when is the nearest timeout among all global OOM victims. We
need to keep track of per global OOM victim's timeout (e.g.
"struct task_struct"->memdie_start ) ?

Moreover, mark_oom_victim(current) at

        if (current->mm &&
            (fatal_signal_pending(current) || task_will_free_mem(current))) {
                mark_oom_victim(current);
                goto out;
        }

lacks information for "Was I OOM-killed due to global OOM?". We need to keep
track of per mm timeout (e.g. "struct mm_struct"->memdie_start ) so that
we can recalculate the nearest timeout among all global OOM victims?



Well, do we really need to set TIF_MEMDIE to non-global OOM victims?
I'm wondering how {memcg,cpuset,mempolicy} OOM stall can occur because
there is enough memory (unless global OOM runs concurrently) for any
operations (e.g. XFS filesystem's writeback, workqueue) which non-global
OOM victims might depend on to make forward progress.

  > > The reason would depend on
  > > 
  > >  (a) whether {memcg,cpuset,mempolicy} OOM stall is possible
  > >
  > >  (b) what {memcg,cpuset,mempolicy} users want to do when (a) is possible
  > >      and {memcg,cpuset,mempolicy} OOM stall occurred
  > 
  > The system as such is still usable. And an administrator might
  > intervene. E.g. enlarge the memcg limit or relax the numa restrictions
  > for the same purpose.

If we set TIF_MEMDIE to only global OOM victims, the problem of "when to call
del_timer(&panic_on_oom_timer) at exit_oom_victim()" will go away.



By the way, I think we can replace

  if (!atomic_dec_return(&oom_victims))

with

  if (atomic_dec_and_test(&oom_victims))

. But this logic puzzles me. The number of threads that are killed by
the OOM killer can be larger than value of oom_victims. This means that
there might be fatal_signal_pending() threads even after oom_victims drops
to 0. Why waiting for only TIF_MEMDIE threads at oom_killer_disable() is
considered sufficient?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
