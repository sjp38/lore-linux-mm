Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id D6F566B0005
	for <linux-mm@kvack.org>; Mon,  1 Aug 2016 06:47:02 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id n69so296524388ion.0
        for <linux-mm@kvack.org>; Mon, 01 Aug 2016 03:47:02 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id k193si18731738oih.173.2016.08.01.03.47.00
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 01 Aug 2016 03:47:01 -0700 (PDT)
Subject: Re: [PATCH 08/10] exit, oom: postpone exit_oom_victim to later
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1469734954-31247-1-git-send-email-mhocko@kernel.org>
	<1469734954-31247-9-git-send-email-mhocko@kernel.org>
	<201607301720.GHG43737.JLVtHOOSQOFFMF@I-love.SAKURA.ne.jp>
	<20160731093530.GB22397@dhcp22.suse.cz>
In-Reply-To: <20160731093530.GB22397@dhcp22.suse.cz>
Message-Id: <201608011946.JAI56255.HJLOtSMFOFOVQF@I-love.SAKURA.ne.jp>
Date: Mon, 1 Aug 2016 19:46:48 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, oleg@redhat.com, rientjes@google.com, vdavydov@parallels.com

Michal Hocko wrote:
> On Sat 30-07-16 17:20:30, Tetsuo Handa wrote:
> > Michal Hocko wrote:
> > > From: Michal Hocko <mhocko@suse.com>
> > > 
> > > exit_oom_victim was called after mmput because it is expected that
> > > address space of the victim would get released by that time and there is
> > > no reason to hold off the oom killer from selecting another task should
> > > that be insufficient to handle the oom situation. In order to catch
> > > post exit_mm() allocations we used to check for PF_EXITING but this
> > > got removed by 6a618957ad17 ("mm: oom_kill: don't ignore oom score on
> > > exiting tasks") because this check was lockup prone.
> > > 
> > > It seems that we have all needed pieces ready now and can finally
> > > fix this properly (at least for CONFIG_MMU cases where we have the
> > > oom_reaper).  Since "oom: keep mm of the killed task available" we have
> > > a reliable way to ignore oom victims which are no longer interesting
> > > because they either were reaped and do not sit on a lot of memory or
> > > they are not reapable for some reason and it is safer to ignore them
> > > and move on to another victim. That means that we can safely postpone
> > > exit_oom_victim to closer to the final schedule.
> > 
> > I don't like this patch. The advantage of this patch will be that we can
> > avoid selecting next OOM victim when only OOM victims need to allocate
> > memory after they left exit_mm().
> 
> Not really as we do not rely on TIF_MEMDIE nor signal->oom_victims to
> block new oom victim selection anymore.

I meant "whether out_of_memory() is called or not (when OOM victims need
to allocate memory after they left exit_mm())".

I did not mean "whether out_of_memory() selects next OOM victim or not"
because "whether MMF_OOM_SKIP on signal->oom_mm is set or not" depends
on "whether out_of_memory() is called before MMF_OOM_SKIP is set on
signal->oom_mm" which depends on timing.

> 
> > But the disadvantage of this patch will
> > be that we increase the possibility of depleting 100% of memory reserves
> > by allowing them to allocate using ALLOC_NO_WATERMARKS after they left
> > exit_mm().
> 
> I think this is a separate problem. As the current code stands we can
> already deplete memory reserves. The large number of threads might be
> sitting in an allocation loop before they bail out to handle the
> SIGKILL. Exit path shouldn't add too much on top of that. If we want to
> be reliable in not consuming all the reserves we would have to employ
> some form of throttling and that is out of scope of this patch.

I'm suggesting such throttling by allowing fatal_signal_pending() or
PF_EXITING threads access to only some portion of memory reserves.

> 
> > It is possible that a user creates a process with 10000 threads
> > and let that process be OOM-killed. Then, this patch allows 10000 threads
> > to start consuming memory reserves after they left exit_mm(). OOM victims
> > are not the only threads who need to allocate memory for termination. Non
> > OOM victims might need to allocate memory at exit_task_work() in order to
> > allow OOM victims to make forward progress.
> 
> this might be possible but unlike the regular exiting tasks we do
> reclaim oom victim's memory in the background. So while they can consume
> memory reserves we should also give some (and arguably much more) memory
> back. The reserves are there to expedite the exit.

Background reclaim does not occur on CONFIG_MMU=n kernels. But this patch
also affects CONFIG_MMU=n kernels. If a process with two threads was
OOM-killed and one thread consumed too much memory after it left exit_mm()
before the other thread sets MMF_OOM_SKIP on their mm by returning from
exit_aio() etc. in __mmput() from mmput() from exit_mm(), this patch
introduces a new possibility to OOM livelock. I think it is wild to assume
that "CONFIG_MMU=n kernels can OOM livelock even without this patch. Thus,
let's apply this patch even though this patch might break the balance of
OOM handling in CONFIG_MMU=n kernels."

Also, where is the guarantee that memory reclaimed by the OOM reaper is
used for terminating exiting threads? Since we do not prefer
fatal_signal_pending() or PF_EXITING threads over !fatal_signal_pending()
nor !PF_EXITING threads, it is possible that all memory reclaimed by the
OOM reaper is depleted by !fatal_signal_pending() nor !PF_EXITING threads.
Yes, the OOM reaper will allow the OOM killer to select next OOM victim.
But the intention of this patch is to avoid calling out_of_memory() by
allowing OOM victims access to memory reserves, isn't it?
We after all need to call out_of_memory() regardless of whether we prefer
TIF_MEMDIE (or signal->oom_mm != NULL) threads over !TIF_MEMDIE (or
signal->oom_mm == NULL) threads.

So, it is not clear to me that this patch is an improvement.

> 
> > I think that allocations from
> > do_exit() are important for terminating cleanly (from the point of view of
> > filesystem integrity and kernel object management) and such allocations
> > should not be given up simply because ALLOC_NO_WATERMARKS allocations
> > failed.
> 
> We are talking about a fatal condition when OOM killer forcefully kills
> a task. Chances are that the userspace leaves so much state behind that
> a manual cleanup would be necessary anyway. Depleting the memory
> reserves is not nice but I really believe that this particular patch
> doesn't make the situation really much worse than before.

I'm not talking about inconsistency in userspace programs. I'm talking
about inconsistency of objects managed by kernel (e.g. failing to drop
references) caused by allocation failures.

>  
> > > There is possible advantages of this because we are reducing chances
> > > of further interference of the oom victim with the rest of the system
> > > after oom_killer_disable(). Strictly speaking this is possible right
> > > now because there are indeed allocations possible past exit_mm() and
> > > who knows whether some of them can trigger IO. I haven't seen this in
> > > practice though.
> > 
> > I don't know which I/O oom_killer_disable() must act as a hard barrier.
> 
> Any allocation that could trigger the IO can corrupt the hibernation
> image or access the half suspended device. The whole point of
> oom_killer_disable is to prevent anything like that to happen.

That's a puzzling answer. What I/O? If fs writeback done by a GFP_FS
allocation issued by userspace processes between after returning from
exit_mm() and reaching final schedule() in do_exit() is problematic, why
fs writeback issued by a GFP_FS allocation done by kernel threads after
returning from oom_killer_disable() is not problematic? I think any I/O
which userspace processes can do is also doable by kernel threads.
Where is the guarantee that kernel threads which do I/O which
oom_killer_disable() acts as a hard barrier do not corrupt the hibernation
image or access the half suspended device?

> 
> > But safer way is to get rid of TIF_MEMDIE's triple meanings. The first
> > one which prevents the OOM killer from selecting next OOM victim was
> > removed by replacing TIF_MEMDIE test in oom_scan_process_thread() with
> > tsk_is_oom_victim(). The second one which allows the OOM victims to
> > deplete 100% of memory reserves wants some changes in order not to
> > block memory allocations by non OOM victims (e.g. GFP_ATOMIC allocations
> > by interrupt handlers, GFP_NOIO / GFP_NOFS allocations by subsystems
> > which are needed for making forward progress of threads in do_exit())
> > by consuming too much of memory reserves. The third one which blocks
> > oom_killer_disable() can be removed by replacing TIF_MEMDIE test in
> > exit_oom_victim() with PFA_OOM_WAITING test like below patch.
> 
> I plan to remove TIF_MEMDIE dependency for this as well but I would like
> to finish this pile first. We actually do not need any flag for that. We
> just need to detect last exiting thread and tsk_is_oom_victim. I have
> some preliminary code for that.

Please show me the preliminary code. How do you expedite termination of
exiting threads? If you simply remove test_thread_flag(TIF_MEMDIE) in
gfp_to_alloc_flags(), there is a risk of failing to escape from current
allocation request loop (if you also remove

	/* Avoid allocations with no watermarks from looping endlessly */
	if (test_thread_flag(TIF_MEMDIE) && !(gfp_mask & __GFP_NOFAIL))
		goto nopage;

) especially for CONFIG_MMU=n kernels, or hitting problems due to
allocation failure (if you don't remove

	/* Avoid allocations with no watermarks from looping endlessly */
	if (test_thread_flag(TIF_MEMDIE) && !(gfp_mask & __GFP_NOFAIL))
		goto nopage;

) due to not allowing access to memory reserves.

On the other hand, if you simply replace test_thread_flag(TIF_MEMDIE) in
gfp_to_alloc_flags() with signal->oom_mm != NULL, it might increase
possibility of depleting memory reserves.

> 
> > (If
> > oom_killer_disable() were specific to CONFIG_MMU=y kernels, I think
> > that not thawing OOM victims will be simpler because the OOM reaper
> > can reclaim memory without thawing OOM victims.)
> 
> Well I do not think keeping an oom victim inside the fridge is a good
> idea. The task might be not sitting on any reclaimable memory but it
> still might consume resources which are bound to its life time (open
> files and their buffers etc.).

Then, I do not think keeping !TIF_MEMDIE OOM victims (sharing TIF_MEMDIE
OOM victim's memory) inside the fridge is a good idea. There might be
resources (e.g. open files) which will not be released unless all threads
sharing TIF_MEMDIE OOM victim's memory terminate.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
