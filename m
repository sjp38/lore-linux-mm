Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 6AAB06B0005
	for <linux-mm@kvack.org>; Mon,  1 Aug 2016 07:33:07 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id 1so80348340wmz.2
        for <linux-mm@kvack.org>; Mon, 01 Aug 2016 04:33:07 -0700 (PDT)
Received: from mail-wm0-f42.google.com (mail-wm0-f42.google.com. [74.125.82.42])
        by mx.google.com with ESMTPS id 69si15476816wme.0.2016.08.01.04.33.05
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 Aug 2016 04:33:05 -0700 (PDT)
Received: by mail-wm0-f42.google.com with SMTP id f65so366185502wmi.0
        for <linux-mm@kvack.org>; Mon, 01 Aug 2016 04:33:05 -0700 (PDT)
Date: Mon, 1 Aug 2016 13:33:04 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH 08/10] exit, oom: postpone exit_oom_victim to later
Message-ID: <20160801113304.GD13544@dhcp22.suse.cz>
References: <1469734954-31247-1-git-send-email-mhocko@kernel.org>
 <1469734954-31247-9-git-send-email-mhocko@kernel.org>
 <201607301720.GHG43737.JLVtHOOSQOFFMF@I-love.SAKURA.ne.jp>
 <20160731093530.GB22397@dhcp22.suse.cz>
 <201608011946.JAI56255.HJLOtSMFOFOVQF@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201608011946.JAI56255.HJLOtSMFOFOVQF@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, oleg@redhat.com, rientjes@google.com, vdavydov@parallels.com

On Mon 01-08-16 19:46:48, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > On Sat 30-07-16 17:20:30, Tetsuo Handa wrote:
[...]
> > > But the disadvantage of this patch will
> > > be that we increase the possibility of depleting 100% of memory reserves
> > > by allowing them to allocate using ALLOC_NO_WATERMARKS after they left
> > > exit_mm().
> > 
> > I think this is a separate problem. As the current code stands we can
> > already deplete memory reserves. The large number of threads might be
> > sitting in an allocation loop before they bail out to handle the
> > SIGKILL. Exit path shouldn't add too much on top of that. If we want to
> > be reliable in not consuming all the reserves we would have to employ
> > some form of throttling and that is out of scope of this patch.
> 
> I'm suggesting such throttling by allowing fatal_signal_pending() or
> PF_EXITING threads access to only some portion of memory reserves.

Which is completely out of scope of this patch and this patchseries as
well.

> > > It is possible that a user creates a process with 10000 threads
> > > and let that process be OOM-killed. Then, this patch allows 10000 threads
> > > to start consuming memory reserves after they left exit_mm(). OOM victims
> > > are not the only threads who need to allocate memory for termination. Non
> > > OOM victims might need to allocate memory at exit_task_work() in order to
> > > allow OOM victims to make forward progress.
> > 
> > this might be possible but unlike the regular exiting tasks we do
> > reclaim oom victim's memory in the background. So while they can consume
> > memory reserves we should also give some (and arguably much more) memory
> > back. The reserves are there to expedite the exit.
> 
> Background reclaim does not occur on CONFIG_MMU=n kernels. But this patch
> also affects CONFIG_MMU=n kernels. If a process with two threads was
> OOM-killed and one thread consumed too much memory after it left exit_mm()
> before the other thread sets MMF_OOM_SKIP on their mm by returning from
> exit_aio() etc. in __mmput() from mmput() from exit_mm(), this patch
> introduces a new possibility to OOM livelock. I think it is wild to assume
> that "CONFIG_MMU=n kernels can OOM livelock even without this patch. Thus,
> let's apply this patch even though this patch might break the balance of
> OOM handling in CONFIG_MMU=n kernels."

As I've said if you have strong doubts about the patch I can drop it for
now. I do agree that nommu really matters here, though.

> Also, where is the guarantee that memory reclaimed by the OOM reaper is
> used for terminating exiting threads?

As the oom reaper replenishes the memory the oom victim should be able
to consume that memory in favor of other processes exactly because it
has access to memory reserves which others are not.

> Since we do not prefer
> fatal_signal_pending() or PF_EXITING threads over !fatal_signal_pending()
> nor !PF_EXITING threads, it is possible that all memory reclaimed by the
> OOM reaper is depleted by !fatal_signal_pending() nor !PF_EXITING threads.
> Yes, the OOM reaper will allow the OOM killer to select next OOM victim.
> But the intention of this patch is to avoid calling out_of_memory() by
> allowing OOM victims access to memory reserves, isn't it?

Yes and also to postpone the oom_killer_disbale to later.

> We after all need to call out_of_memory() regardless of whether we prefer
> TIF_MEMDIE (or signal->oom_mm != NULL) threads over !TIF_MEMDIE (or
> signal->oom_mm == NULL) threads.
> 
> So, it is not clear to me that this patch is an improvement.

It might fit in better with other TIF_MEMDIE related changes so I do not
care if it is dropped now.

> > > I think that allocations from
> > > do_exit() are important for terminating cleanly (from the point of view of
> > > filesystem integrity and kernel object management) and such allocations
> > > should not be given up simply because ALLOC_NO_WATERMARKS allocations
> > > failed.
> > 
> > We are talking about a fatal condition when OOM killer forcefully kills
> > a task. Chances are that the userspace leaves so much state behind that
> > a manual cleanup would be necessary anyway. Depleting the memory
> > reserves is not nice but I really believe that this particular patch
> > doesn't make the situation really much worse than before.
> 
> I'm not talking about inconsistency in userspace programs. I'm talking
> about inconsistency of objects managed by kernel (e.g. failing to drop
> references) caused by allocation failures.

That would be a bug on its own, no?
 
> > > > There is possible advantages of this because we are reducing chances
> > > > of further interference of the oom victim with the rest of the system
> > > > after oom_killer_disable(). Strictly speaking this is possible right
> > > > now because there are indeed allocations possible past exit_mm() and
> > > > who knows whether some of them can trigger IO. I haven't seen this in
> > > > practice though.
> > > 
> > > I don't know which I/O oom_killer_disable() must act as a hard barrier.
> > 
> > Any allocation that could trigger the IO can corrupt the hibernation
> > image or access the half suspended device. The whole point of
> > oom_killer_disable is to prevent anything like that to happen.
> 
> That's a puzzling answer. What I/O? If fs writeback done by a GFP_FS
> allocation issued by userspace processes between after returning from
> exit_mm() and reaching final schedule() in do_exit() is problematic, why
> fs writeback issued by a GFP_FS allocation done by kernel threads after
> returning from oom_killer_disable() is not problematic? I think any I/O
> which userspace processes can do is also doable by kernel threads.
> Where is the guarantee that kernel threads which do I/O which
> oom_killer_disable() acts as a hard barrier do not corrupt the hibernation
> image or access the half suspended device?

This has been discussed several times already. I do not have a link
handy but it should be there in the archives. I am sorry and do not want
to be rude here but I guess this is only tangential to this particular
patch series so I would prefer not discussing PM consequences. PM
suspend is describe to expect no _user_ activity after oom_killer_disable.
If you are questioning that assumption then please do that in a separate
thread.

> > > But safer way is to get rid of TIF_MEMDIE's triple meanings. The first
> > > one which prevents the OOM killer from selecting next OOM victim was
> > > removed by replacing TIF_MEMDIE test in oom_scan_process_thread() with
> > > tsk_is_oom_victim(). The second one which allows the OOM victims to
> > > deplete 100% of memory reserves wants some changes in order not to
> > > block memory allocations by non OOM victims (e.g. GFP_ATOMIC allocations
> > > by interrupt handlers, GFP_NOIO / GFP_NOFS allocations by subsystems
> > > which are needed for making forward progress of threads in do_exit())
> > > by consuming too much of memory reserves. The third one which blocks
> > > oom_killer_disable() can be removed by replacing TIF_MEMDIE test in
> > > exit_oom_victim() with PFA_OOM_WAITING test like below patch.
> > 
> > I plan to remove TIF_MEMDIE dependency for this as well but I would like
> > to finish this pile first. We actually do not need any flag for that. We
> > just need to detect last exiting thread and tsk_is_oom_victim. I have
> > some preliminary code for that.
> 
> Please show me the preliminary code. How do you expedite termination of
> exiting threads? If you simply remove test_thread_flag(TIF_MEMDIE) in
> gfp_to_alloc_flags(), there is a risk of failing to escape from current
> allocation request loop (if you also remove
> 
> 	/* Avoid allocations with no watermarks from looping endlessly */
> 	if (test_thread_flag(TIF_MEMDIE) && !(gfp_mask & __GFP_NOFAIL))
> 		goto nopage;
> 
> ) especially for CONFIG_MMU=n kernels, or hitting problems due to
> allocation failure (if you don't remove
> 
> 	/* Avoid allocations with no watermarks from looping endlessly */
> 	if (test_thread_flag(TIF_MEMDIE) && !(gfp_mask & __GFP_NOFAIL))
> 		goto nopage;
> 
> ) due to not allowing access to memory reserves.
> 
> On the other hand, if you simply replace test_thread_flag(TIF_MEMDIE) in
> gfp_to_alloc_flags() with signal->oom_mm != NULL, it might increase
> possibility of depleting memory reserves.

I have planned to access to memory reserves in two stages.
tsk_is_oom_victim would get access to a portion of the memory reserves
(below try_harder) and full access after the oom reaper started reaping
the memory. The code is not ready yet, I need to think about it much
more and this is out of scope of this series.

> > > (If
> > > oom_killer_disable() were specific to CONFIG_MMU=y kernels, I think
> > > that not thawing OOM victims will be simpler because the OOM reaper
> > > can reclaim memory without thawing OOM victims.)
> > 
> > Well I do not think keeping an oom victim inside the fridge is a good
> > idea. The task might be not sitting on any reclaimable memory but it
> > still might consume resources which are bound to its life time (open
> > files and their buffers etc.).
> 
> Then, I do not think keeping !TIF_MEMDIE OOM victims (sharing TIF_MEMDIE
> OOM victim's memory) inside the fridge is a good idea. There might be
> resources (e.g. open files) which will not be released unless all threads
> sharing TIF_MEMDIE OOM victim's memory terminate.

Yes this is a part of the future changes which will not care about
TIF_MEMDIE at all and act always on the whole process groups. And as
such on all processes sharing the mm as well (after this series).
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
