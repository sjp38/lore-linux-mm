Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f199.google.com (mail-ig0-f199.google.com [209.85.213.199])
	by kanga.kvack.org (Postfix) with ESMTP id 615C76B007E
	for <linux-mm@kvack.org>; Sat, 28 May 2016 08:22:23 -0400 (EDT)
Received: by mail-ig0-f199.google.com with SMTP id i11so19483533igh.0
        for <linux-mm@kvack.org>; Sat, 28 May 2016 05:22:23 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id t84si16841109oig.52.2016.05.28.05.22.21
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Sat, 28 May 2016 05:22:22 -0700 (PDT)
Subject: Re: [RFC PATCH] mm, oom_reaper: do not attempt to reap a task more than twice
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <201605271931.AGD82810.QFOFOOFLMVtHSJ@I-love.SAKURA.ne.jp>
	<20160527122308.GJ27686@dhcp22.suse.cz>
	<201605272218.JID39544.tFOQHJOMVFLOSF@I-love.SAKURA.ne.jp>
	<20160527133502.GN27686@dhcp22.suse.cz>
	<201605280124.EJB71319.SHOtOVFFFQMOJL@I-love.SAKURA.ne.jp>
In-Reply-To: <201605280124.EJB71319.SHOtOVFFFQMOJL@I-love.SAKURA.ne.jp>
Message-Id: <201605282122.HAD09894.SFOFHtOVJLOQMF@I-love.SAKURA.ne.jp>
Date: Sat, 28 May 2016 21:22:08 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: linux-mm@kvack.org, rientjes@google.com, akpm@linux-foundation.org, oleg@redhat.com, vdavydov@parallels.com

Tetsuo Handa wrote:
> Michal Hocko wrote:
> > We could very well do 
> > diff --git a/mm/oom_kill.c b/mm/oom_kill.c
> > index bcb6d3b26c94..d9017b8c7300 100644
> > --- a/mm/oom_kill.c
> > +++ b/mm/oom_kill.c
> > @@ -813,6 +813,7 @@ void oom_kill_process(struct oom_control *oc, struct task_struct *p,
> >  			 * memory might be still used.
> >  			 */
> >  			can_oom_reap = false;
> > +			set_bit(MMF_OOM_REAPED, mm->flags);
> >  			continue;
> >  		}
> >  		if (p->signal->oom_score_adj == OOM_ADJUST_MIN)
> > 
> > with the same result. If you _really_ think that this would make a
> > difference I could live with that. But I am highly skeptical this
> > matters all that much.

Usage of set_bit() above and below are both wrong. The mm used by
kernel thread via use_mm() will become OOM reapable after unuse_mm().
Thus, setting MMF_OOM_REAPED is a mistake as with MMF_OOM_KILLED
( http://lkml.kernel.org/r/201603152015.JAE86937.VFOLtQFOFJOSHM@I-love.SAKURA.ne.jp ).

> I think the lines needed for the guarantee are something like
> 
> 	rcu_read_lock();
> 	for_each_process(p) {
> 		if (!process_shares_mm(p, mm))
> 			continue;
> 		if (same_thread_group(p, victim))
> 			continue;
> 		/*
> 		 * It is not safe to reap memory used by global init or
> 		 * kernel threads.
> 		 */
> 		if (unlikely(p->flags & PF_KTHREAD) || is_global_init(p)) {
> 			set_bit(MMF_OOM_REAPED, mm->flags);
> 			continue;
> 		}
> 		/*
> 		 * Memory used by OOM_SCORE_ADJ_MIN is still OOM reapable
> 		 * if they are already killed or exiting. Just don't
> 		 * send SIGKILL.
> 		 */
> 		if (p->signal->oom_score_adj == OOM_SCORE_ADJ_MIN)
> 			continue;
> 
> 		do_send_sig_info(SIGKILL, SEND_SIG_FORCED, p, true);
> 	}
> 	rcu_read_unlock();
> 
> 	wake_oom_reaper(victim);
> 
> but doing set_bit(MMF_OOM_REAPED, mm->flags) here makes sense?



I also realized that my

	if (task_is_reapable(current))
		return true;

is wrong. task_is_reapable() depends on all threads using current->mm are
dying or exiting, but select_bad_process() (which is needed for calling
mark_oom_victim() from oom_kill_process() after oom_badness() > 0 by
oom_scan_process_thread() returning OOM_SCAN_OK) depends on there is no
TIF_MEMDIE thread.

If there is a TIF_MEMDIE thread, current thread which will (as of Linux 4.6)
be able to get TIF_MEMDIE by

  fatal_signal_pending(current) || ((current->flags & PF_EXITING) && !(current->signal->flags & SIGNAL_GROUP_COREDUMP))

condition will fail to get TIF_MEMDIE because oom_scan_process_thread() will
return OOM_SCAN_ABORT. The logic of setting TIF_MEMDIE to only one thread

	/*
	 * Kill all user processes sharing victim->mm in other thread groups, if
	 * any.  They don't get access to memory reserves, though, to avoid
	 * depletion of all memory.  This prevents mm->mmap_sem livelock when an
	 * oom killed thread cannot exit because it requires the semaphore and
	 * its contended by another thread trying to allocate memory itself.
	 * That thread will now get access to memory reserves since it has a
	 * pending fatal signal.
	 */

does not allow the shortcuts to require that current->mm is reapable.

It seems to me that your "[PATCH 6/6] mm, oom: fortify task_will_free_mem"
expects that current->mm is reapable as well as my patch.
If so, [PATCH 6/6] will not work.

+static inline bool task_will_free_mem(struct task_struct *task)
+{
(...snipped...)
+		rcu_read_lock();
+		for_each_process(p) {
+			bool vfork;
+
+			/*
+			 * skip over vforked tasks because they are mostly
+			 * independent and will drop the mm soon
+			 */
+			task_lock(p);
+			vfork = p->vfork_done;
+			task_unlock(p);
+			if (vfork)
+				continue;
+
+			ret = __task_will_free_mem(p);
+			if (!ret)
+				break;
+		}
+		rcu_read_unlock();
(...snipped...)
+}

@@ -945,14 +894,10 @@ bool out_of_memory(struct oom_control *oc)
 	 * If current has a pending SIGKILL or is exiting, then automatically
 	 * select it.  The goal is to allow it to allocate so that it may
 	 * quickly exit and free its memory.
-	 *
-	 * But don't select if current has already released its mm and cleared
-	 * TIF_MEMDIE flag at exit_mm(), otherwise an OOM livelock may occur.
 	 */
-	if (current->mm &&
-	    (fatal_signal_pending(current) || task_will_free_mem(current))) {
+	if (task_will_free_mem(current)) {
 		mark_oom_victim(current);
-		try_oom_reaper(current);
+		wake_oom_reaper(current);
 		return true;
 	}
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
