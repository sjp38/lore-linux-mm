Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 5014B6B0038
	for <linux-mm@kvack.org>; Fri, 27 Nov 2015 06:29:53 -0500 (EST)
Received: by pacdm15 with SMTP id dm15so113076366pac.3
        for <linux-mm@kvack.org>; Fri, 27 Nov 2015 03:29:53 -0800 (PST)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id n88si4011417pfb.56.2015.11.27.03.29.51
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 27 Nov 2015 03:29:52 -0800 (PST)
Subject: Re: [RFC PATCH] mm, oom: introduce oom reaper
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <1448467018-20603-1-git-send-email-mhocko@kernel.org>
	<20151125200806.GA13388@cmpxchg.org>
	<20151126110849.GC7953@dhcp22.suse.cz>
	<201511270024.DFJ57385.OFtJQSMOFFLOHV@I-love.SAKURA.ne.jp>
	<20151126163456.GM7953@dhcp22.suse.cz>
In-Reply-To: <20151126163456.GM7953@dhcp22.suse.cz>
Message-Id: <201511272029.GGG73445.tOOLJQFHOMVFSF@I-love.SAKURA.ne.jp>
Date: Fri, 27 Nov 2015 20:29:39 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org
Cc: hannes@cmpxchg.org, linux-mm@kvack.org, akpm@linux-foundation.org, torvalds@linux-foundation.org, mgorman@suse.de, rientjes@google.com, riel@redhat.com, hughd@google.com, oleg@redhat.com, andrea@kernel.org, linux-kernel@vger.kernel.org

Michal Hocko wrote:
> > > +	for (vma = mm->mmap ; vma; vma = vma->vm_next) {
> > > +		if (is_vm_hugetlb_page(vma))
> > > +			continue;
> > > +
> > > +		/*
> > > +		 * Only anonymous pages have a good chance to be dropped
> > > +		 * without additional steps which we cannot afford as we
> > > +		 * are OOM already.
> > > +		 */
> > > +		if (vma_is_anonymous(vma) || !(vma->vm_flags & VM_SHARED))
> > > +			unmap_page_range(&tlb, vma, vma->vm_start, vma->vm_end,
> > > +					 &details);
> > 
> > How do you plan to make sure that reclaimed pages are used by
> > fatal_signal_pending() tasks?
> > http://lkml.kernel.org/r/201509242050.EHE95837.FVFOOtMQHLJOFS@I-love.SAKURA.ne.jp
> > http://lkml.kernel.org/r/201510121543.EJF21858.LtJFHOOOSQVMFF@I-love.SAKURA.ne.jp
> 
> Well the wake_oom_reaper is responsible to hand over mm of the OOM
> victim and as such it should be a killed process.  I guess you mean that
> the mm might be shared with another process which is hidden from the OOM
> killer, right?

Right, but that is not what I wanted to say here. What I wanted to say
here is, there can be other tasks that are looping inside
__alloc_pages_slowpath(). I'm worrying that without a mechanism for
priority allocating (e.g. "[PATCH] mm/page_alloc: Favor kthread and dying
threads over normal threads" at
http://lkml.kernel.org/r/201509102318.GHG18789.OHMSLFJOQFOtFV@I-love.SAKURA.ne.jp ),
many !fatal_signal_pending() tasks could steal all reclaimed pages before
a few fatal_signal_pending() tasks acquire them. Since oom_kill_process()
tries to kill child tasks, reaping the child task could reclaim only a few
pages. Since I think that the purpose of reclaiming OOM victim's mm pages
implies help fatal_signal_pending() tasks which are blocking TIF_MEMDIE
tasks to terminate more quickly so that TIF_MEMDIE tasks can also terminate,
I think that priority allocating is needed.

>                Well I think this is not something to care about at this
> layer. We shouldn't select a tasks which can lead to this situation in
> the first place. Such an oom victim is basically selected incorrectly. I
> think we can handle that by a flag in mm_struct.

You mean updating select_bad_process() and oom_kill_process() not to select
an OOM victim with mm shared by unkillable tasks?

> > > +		if (!mm) {
> > > +			freezable_schedule();
> > > +			finish_wait(&oom_reaper_wait, &wait);
> > > +		} else {
> > > +			finish_wait(&oom_reaper_wait, &wait);
> > > +			oom_reap_vmas(mm);
> > > +			WRITE_ONCE(mm_to_reap, NULL);
> > > +		}
> > > +	}
> > > +
> > > +	return 0;
> > > +}
> > > +
> > > +static void wake_oom_reaper(struct mm_struct *mm)
> > > +{
> > > +	struct mm_struct *old_mm;
> > > +
> > > +	if (!oom_reaper_th)
> > > +		return;
> > > +
> > > +	/*
> > > +	 * Make sure that only a single mm is ever queued for the reaper
> > > +	 * because multiple are not necessary and the operation might be
> > > +	 * disruptive so better reduce it to the bare minimum.
> > > +	 */
> > > +	old_mm = cmpxchg(&mm_to_reap, NULL, mm);
> > 
> > I think we should not skip queuing next OOM victim, for it is possible
> > that first OOM victim is chosen by one memory cgroup OOM, and next OOM
> > victim is chosen by another memory cgroup OOM or system wide OOM before
> > oom_reap_vmas() for first OOM victim completes.
> 

I forgot that currently a global OOM will not choose next OOM victim
when a memcg OOM chose first victim. Thus, currently possible cases
will be limited to "first OOM victim is chosen by memcg1 OOM, then
next OOM victim is chosen by memcg2 OOM before oom_reap_vmas() for
first OOM victim completes".

> Does that matter though. Be it a memcg OOM or a global OOM victim, we
> will still release a memory which should help the global case which we
> care about the most. Memcg OOM killer handling is easier because we do
> not hold any locks while waiting for the OOM to be handled.
> 

Why easier? Memcg OOM is triggered when current thread triggered a page
fault, right? I don't know whether current thread really holds no locks
when a page fault is triggered. But mem_cgroup_out_of_memory() choose
an OOM victim which can be different from current thread. Therefore,
I think problems caused by invisible dependency exist for memcg OOM.

> > To handle such case, we would need to do something like
> > 
> >  struct mm_struct {
> >      (...snipped...)
> > +    struct list_head *memdie; /* Set to non-NULL when chosen by OOM killer */
> >  }
> > 
> > and add to a list of OOM victims.
> 
> I really wanted to prevent from additional memory footprint for a highly
> unlikely case. Why should everybody pay for a case which is rarely hit?
> 
> Also if this turns out to be a real problem then it can be added on top
> of the existing code. I would really like this to be as easy as
> possible.

The sequences I think we could hit is,

  (1) a memcg1 OOM is invoked and a task in memcg1 is chosen as first OOM
      victim.

  (2) wake_oom_reaper() passes first victim's mm to oom_reaper().

  (3) oom_reaper() starts reclaiming first victim's mm.

  (4) a memcg2 OOM is invoked and a task in memcg2 is chosen as second
      OOM victim.

  (5) wake_oom_reaper() does not pass second victim's mm to oom_reaper()
      because mm_to_reap holds first victim's mm.

  (6) oom_reaper() finishes reclaiming first victim's mm, and sets
      mm_to_reap = NULL.

  (7) Second victim's mm (chosen at step (4)) is not passed to oom_reaper()
      because wake_oom_reaper() is not called again.

Invisible dependency problem in first victim's mm can prevent second
victim's mm from reaping. This is an unexpected thing for second victim.
If oom_reaper() scans like kmallocwd() does, any victim's mm will be
reaped, as well as doing different things like emitting warning messages,
choosing next OOM victims and eventually calling panic(). Therefore, I wrote

  So, I thought that a dedicated kernel thread makes it easy to call memory
  unmapping code periodically again and again.

at http://lkml.kernel.org/r/201510022206.BHF13585.MSOHOFFLQtVOJF@I-love.SAKURA.ne.jp .

> > 
> > >  	/*
> > >  	 * Make sure that the task is woken up from uninterruptible sleep
> > >  	 * if it is frozen because OOM killer wouldn't be able to free
> > > @@ -767,3 +879,22 @@ void pagefault_out_of_memory(void)
> > >  
> > >  	mutex_unlock(&oom_lock);
> > >  }
> > > +
> > > +static int __init oom_init(void)
> > > +{
> > > +	oom_reaper_th = kthread_run(oom_reaper, NULL, "oom_reaper");
> > > +	if (IS_ERR(oom_reaper_th)) {
> > > +		pr_err("Unable to start OOM reaper %ld. Continuing regardless\n",
> > > +				PTR_ERR(oom_reaper_th));
> > 
> > BUG_ON(IS_ERR(oom_reaper_th)) or panic() should be OK.
> > Continuing with IS_ERR(oom_reaper_th) is not handled by wake_oom_reaper().
> 
> Yes, but we can live without this kernel thread, right? I do not think
> this will ever happen but why should we panic the system?

I do not think this will ever happen. Only for documentation purpose.

oom_init() is called before the global init process in userspace is
started. Therefore, if kthread_run() fails, the global init process
unlikely be able to start. Since you did not check for failure for

  vmstat_wq = alloc_workqueue("vmstat", WQ_FREEZABLE|WQ_MEM_RECLAIM, 0);

case while you checked for failure for

  oom_reaper_th = kthread_run(oom_reaper, NULL, "oom_reaper");

case, I think that BUG_ON() or panic() should be OK if you check for
failure.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
