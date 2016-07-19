Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f198.google.com (mail-ob0-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 73BD66B0005
	for <linux-mm@kvack.org>; Tue, 19 Jul 2016 07:17:50 -0400 (EDT)
Received: by mail-ob0-f198.google.com with SMTP id d1so26435172obv.3
        for <linux-mm@kvack.org>; Tue, 19 Jul 2016 04:17:50 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id g28si8545932ioi.148.2016.07.19.04.17.49
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 19 Jul 2016 04:17:49 -0700 (PDT)
Subject: Re: [PATCH] mm, oom: fix for hiding mm which is shared with kthread or global init
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1468647004-5721-1-git-send-email-penguin-kernel@I-love.SAKURA.ne.jp>
	<20160718071825.GB22671@dhcp22.suse.cz>
	<201607190630.DIH34854.HFOOQFLOJMVFSt@I-love.SAKURA.ne.jp>
	<20160719064048.GA9486@dhcp22.suse.cz>
	<20160719093739.GE9486@dhcp22.suse.cz>
In-Reply-To: <20160719093739.GE9486@dhcp22.suse.cz>
Message-Id: <201607191936.BEJ82340.OHFOtOFFSQMJVL@I-love.SAKURA.ne.jp>
Date: Tue, 19 Jul 2016 19:36:40 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@suse.cz
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, oleg@redhat.com, vdavydov@virtuozzo.com, rientjes@google.com

Michal Hocko wrote:
> On Tue 19-07-16 08:40:48, Michal Hocko wrote:
> > On Tue 19-07-16 06:30:42, Tetsuo Handa wrote:
> > > Michal Hocko wrote:
> > > > I really do not think that this unlikely case really has to be handled
> > > > now. We are very likely going to move to a different model of oom victim
> > > > detection soon. So let's do not add new hacks. exit_oom_victim from
> > > > oom_kill_process just looks like sand in eyes.
> > > 
> > > Then, please revert "mm, oom: hide mm which is shared with kthread or global init"
> > > ( http://lkml.kernel.org/r/1466426628-15074-11-git-send-email-mhocko@kernel.org ).
> > > I don't like that patch because it is doing pointless find_lock_task_mm() test
> > > and is telling a lie because it does not guarantee that we won't hit OOM livelock.
> > 
> > The above patch doesn't make the situation worse wrt livelock. I
> > consider it an improvement. It adds find_lock_task_mm into
> > oom_scan_process_thread but that can hardly be worse than just the
> > task->signal->oom_victims check because we can catch MMF_OOM_REAPED. If
> > we are mm loss, which is a less likely case, then we behave the same as
> > with the previous implementation.
> > 
> > So I do not really see a reason to revert that patch for now.
> 
> And that being said. If you strongly disagree with the wording then what
> about the following:
> "
>     In order to help a forward progress for the OOM killer, make sure that
>     this really rare cases will not get into the way and hide the mm from the
>     oom killer by setting MMF_OOM_REAPED flag for it.  oom_scan_process_thread
>     will ignore any TIF_MEMDIE task if it has MMF_OOM_REAPED flag set to catch
>     these oom victims.
>     
>     After this patch we should guarantee a forward progress for the OOM killer
>     even when the selected victim is sharing memory with a kernel thread or
>     global init as long as the victims mm is still alive.
> "

No, I don't like "as long as the victims mm is still alive" exception.

If you don't like exit_oom_victim() from oom_kill_process(), what about
alternative shown below?

 	if (!is_sysrq_oom(oc) && atomic_read(&task->signal->oom_victims)) {
 		struct task_struct *p = find_lock_task_mm(task);
 		enum oom_scan_t ret = OOM_SCAN_ABORT;
 
 		if (p) {
 			if (test_bit(MMF_OOM_REAPED, &p->mm->flags))
 				ret = OOM_SCAN_CONTINUE;
 			task_unlock(p);
+#ifdef CONFIG_MMU
+		} else {
+			/*
+			 * MMF_OOM_REAPED was set at oom_kill_process() without
+			 * waking up the OOM reaper, but this thread group lost
+			 * its mm. Therefore, pretend as if the OOM reaper lost
+			 * its mm (i.e. select next OOM victim).
+			 * But be sure to prevent CONFIG_MMU=n from acting
+			 * as if exit_oom_victim() in exit_mm() has moved from
+			 * after mmput() to before mmput().
+			 */
+			ret = OOM_SCAN_CONTINUE;
+#endif
 		}
 		return ret;
 	}

By using this alternative, we can really guarantee a forward progress for
the OOM killer even when the selected victim is sharing memory with a kernel
thread or global init. No "as long as the victims mm is still alive" exception.

Also, this alternative (when combined with removal of MMF_OOM_NOT_REAPABLE) has
a bonus that we no longer need to call exit_oom_victim() from the OOM reaper
because the OOM killer can move on to next OOM victim after the OOM reaper
set MMF_OOM_REAPED to that mm. That is, we can immediately disallow
exit_oom_victim() on remote thread and apply oom_killer_disable() timeout
patch and revert "oom, suspend: fix oom_reaper vs. oom_killer_disable race".

If we remember victim's mm via your "oom: keep mm of the killed task available"
or my "mm,oom: Use list of mm_struct used by OOM victims.", we can force the
OOM reaper to try to reap by intervening to regular __mmput() from mmput() from
exit_mm() by purposely taking a reference on mm->mm_users. Then, we can always
try to reclaim some memory using the OOM reaper before risking exit_aio() from
__mmput() from mmput() from exit_mm() to stall, for we can keep the OOM killer
waiting until MMF_OOM_REAPED is set using your or my patch.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
