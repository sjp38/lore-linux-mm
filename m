Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f45.google.com (mail-wm0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id 4550E6B0254
	for <linux-mm@kvack.org>; Fri, 27 Nov 2015 07:35:29 -0500 (EST)
Received: by wmec201 with SMTP id c201so56797362wme.1
        for <linux-mm@kvack.org>; Fri, 27 Nov 2015 04:35:28 -0800 (PST)
Received: from mail-wm0-f43.google.com (mail-wm0-f43.google.com. [74.125.82.43])
        by mx.google.com with ESMTPS id ko8si48087614wjb.26.2015.11.27.04.35.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 27 Nov 2015 04:35:27 -0800 (PST)
Received: by wmec201 with SMTP id c201so56796768wme.1
        for <linux-mm@kvack.org>; Fri, 27 Nov 2015 04:35:27 -0800 (PST)
Date: Fri, 27 Nov 2015 13:35:25 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [RFC PATCH] mm, oom: introduce oom reaper
Message-ID: <20151127123525.GG2493@dhcp22.suse.cz>
References: <1448467018-20603-1-git-send-email-mhocko@kernel.org>
 <20151125200806.GA13388@cmpxchg.org>
 <20151126110849.GC7953@dhcp22.suse.cz>
 <201511270024.DFJ57385.OFtJQSMOFFLOHV@I-love.SAKURA.ne.jp>
 <20151126163456.GM7953@dhcp22.suse.cz>
 <201511272029.GGG73445.tOOLJQFHOMVFSF@I-love.SAKURA.ne.jp>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <201511272029.GGG73445.tOOLJQFHOMVFSF@I-love.SAKURA.ne.jp>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Cc: hannes@cmpxchg.org, linux-mm@kvack.org, akpm@linux-foundation.org, torvalds@linux-foundation.org, mgorman@suse.de, rientjes@google.com, riel@redhat.com, hughd@google.com, oleg@redhat.com, andrea@kernel.org, linux-kernel@vger.kernel.org

On Fri 27-11-15 20:29:39, Tetsuo Handa wrote:
> Michal Hocko wrote:
> > > > +	for (vma = mm->mmap ; vma; vma = vma->vm_next) {
> > > > +		if (is_vm_hugetlb_page(vma))
> > > > +			continue;
> > > > +
> > > > +		/*
> > > > +		 * Only anonymous pages have a good chance to be dropped
> > > > +		 * without additional steps which we cannot afford as we
> > > > +		 * are OOM already.
> > > > +		 */
> > > > +		if (vma_is_anonymous(vma) || !(vma->vm_flags & VM_SHARED))
> > > > +			unmap_page_range(&tlb, vma, vma->vm_start, vma->vm_end,
> > > > +					 &details);
> > > 
> > > How do you plan to make sure that reclaimed pages are used by
> > > fatal_signal_pending() tasks?
> > > http://lkml.kernel.org/r/201509242050.EHE95837.FVFOOtMQHLJOFS@I-love.SAKURA.ne.jp
> > > http://lkml.kernel.org/r/201510121543.EJF21858.LtJFHOOOSQVMFF@I-love.SAKURA.ne.jp
> > 
> > Well the wake_oom_reaper is responsible to hand over mm of the OOM
> > victim and as such it should be a killed process.  I guess you mean that
> > the mm might be shared with another process which is hidden from the OOM
> > killer, right?
> 
> Right, but that is not what I wanted to say here. What I wanted to say
> here is, there can be other tasks that are looping inside
> __alloc_pages_slowpath(). I'm worrying that without a mechanism for
> priority allocating (e.g. "[PATCH] mm/page_alloc: Favor kthread and dying
> threads over normal threads" at
> http://lkml.kernel.org/r/201509102318.GHG18789.OHMSLFJOQFOtFV@I-love.SAKURA.ne.jp ),
> many !fatal_signal_pending() tasks could steal all reclaimed pages before
> a few fatal_signal_pending() tasks acquire them.

I fail to see how is this directly related to the patch though. Yes,
this is something that might happen also during regular direct reclaim
without OOM killer. Higher priority or just luckier tasks might
piggyback on reclaimers. This is not something this patch aims for.

> Since oom_kill_process()
> tries to kill child tasks, reaping the child task could reclaim only a few
> pages. Since I think that the purpose of reclaiming OOM victim's mm pages
> implies help fatal_signal_pending() tasks which are blocking TIF_MEMDIE
> tasks to terminate more quickly so that TIF_MEMDIE tasks can also terminate,
> I think that priority allocating is needed.

The purpose of this patch is to pro-actively free some memory. It is not
targeted for the OOM victims because that would require much more
changes and I believe we should start somewhere and improve from there.
I can imagine that we can help OOM victims better - e.g. by creating an
OOM memory reserve - something that Johannes was proposing few months
back.

> >                Well I think this is not something to care about at this
> > layer. We shouldn't select a tasks which can lead to this situation in
> > the first place. Such an oom victim is basically selected incorrectly. I
> > think we can handle that by a flag in mm_struct.
> 
> You mean updating select_bad_process() and oom_kill_process() not to select
> an OOM victim with mm shared by unkillable tasks?

See the follow up email.

[...]
> > Does that matter though. Be it a memcg OOM or a global OOM victim, we
> > will still release a memory which should help the global case which we
> > care about the most. Memcg OOM killer handling is easier because we do
> > not hold any locks while waiting for the OOM to be handled.
> > 
> 
> Why easier? Memcg OOM is triggered when current thread triggered a page
> fault, right? I don't know whether current thread really holds no locks
> when a page fault is triggered. But mem_cgroup_out_of_memory() choose
> an OOM victim which can be different from current thread. Therefore,
> I think problems caused by invisible dependency exist for memcg OOM.

memcg charge doesn't loop endless like the page allocation. We simply
fail with ENOMEM. It is true that the victim might be blocked and not
reacting on SIGKILL but that waiting cannot wait on the memcg oom path
because of the above. Sure the victim might depend on a page allocation
looping because of the global OOM but then this is reduced to the global
case.

> > > To handle such case, we would need to do something like
> > > 
> > >  struct mm_struct {
> > >      (...snipped...)
> > > +    struct list_head *memdie; /* Set to non-NULL when chosen by OOM killer */
> > >  }
> > > 
> > > and add to a list of OOM victims.
> > 
> > I really wanted to prevent from additional memory footprint for a highly
> > unlikely case. Why should everybody pay for a case which is rarely hit?
> > 
> > Also if this turns out to be a real problem then it can be added on top
> > of the existing code. I would really like this to be as easy as
> > possible.
> 
> The sequences I think we could hit is,
> 
>   (1) a memcg1 OOM is invoked and a task in memcg1 is chosen as first OOM
>       victim.
> 
>   (2) wake_oom_reaper() passes first victim's mm to oom_reaper().
> 
>   (3) oom_reaper() starts reclaiming first victim's mm.
> 
>   (4) a memcg2 OOM is invoked and a task in memcg2 is chosen as second
>       OOM victim.
> 
>   (5) wake_oom_reaper() does not pass second victim's mm to oom_reaper()
>       because mm_to_reap holds first victim's mm.
> 
>   (6) oom_reaper() finishes reclaiming first victim's mm, and sets
>       mm_to_reap = NULL.
> 
>   (7) Second victim's mm (chosen at step (4)) is not passed to oom_reaper()
>       because wake_oom_reaper() is not called again.
> 
> Invisible dependency problem in first victim's mm can prevent second
> victim's mm from reaping. This is an unexpected thing for second victim.
> If oom_reaper() scans like kmallocwd() does, any victim's mm will be
> reaped, as well as doing different things like emitting warning messages,
> choosing next OOM victims and eventually calling panic(). Therefore, I wrote

As I've said I am not really worried about the memcg case. At least not
now with this RFC. Extending the current mechanism to a queue seems like
an implementation detail to me. Is this really something that is so
important to have from the very beginning? I mean, don't get me wrong,
but I would really like to make the basic case - the global OOM killer
right and only build additional changes on top.

[...]
> > > > +static int __init oom_init(void)
> > > > +{
> > > > +	oom_reaper_th = kthread_run(oom_reaper, NULL, "oom_reaper");
> > > > +	if (IS_ERR(oom_reaper_th)) {
> > > > +		pr_err("Unable to start OOM reaper %ld. Continuing regardless\n",
> > > > +				PTR_ERR(oom_reaper_th));
> > > 
> > > BUG_ON(IS_ERR(oom_reaper_th)) or panic() should be OK.
> > > Continuing with IS_ERR(oom_reaper_th) is not handled by wake_oom_reaper().
> > 
> > Yes, but we can live without this kernel thread, right? I do not think
> > this will ever happen but why should we panic the system?
> 
> I do not think this will ever happen. Only for documentation purpose.

I do not think we add BUG_ONs for documentation purposes. The code and
the message sounds like a sufficient documentation that this is not
really a critical part of the system.

Thanks!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
