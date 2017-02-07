Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 1C9BE6B025E
	for <linux-mm@kvack.org>; Tue,  7 Feb 2017 08:48:21 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id q124so25495954wmg.2
        for <linux-mm@kvack.org>; Tue, 07 Feb 2017 05:48:21 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id v11si12271223wmg.13.2017.02.07.05.48.19
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 07 Feb 2017 05:48:19 -0800 (PST)
Date: Tue, 7 Feb 2017 14:48:18 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: mm: deadlock between get_online_cpus/pcpu_alloc
Message-ID: <20170207134818.GQ5065@dhcp22.suse.cz>
References: <CACT4Y+Z-juavN8s+5sc-PB0rbqy4zmsRpc6qZBg3C7z3topLTw@mail.gmail.com>
 <20170206220530.apvuknbagaf2rdlw@techsingularity.net>
 <20170207084855.GC5065@dhcp22.suse.cz>
 <20170207094300.cuxfqi35wflk5nr5@techsingularity.net>
 <2cdef192-1939-d692-1224-8ff7d7ff7203@suse.cz>
 <20170207102809.awh22urqmfrav5r6@techsingularity.net>
 <20170207103552.GH5065@dhcp22.suse.cz>
 <20170207113435.6xthczxt2cx23r4t@techsingularity.net>
 <20170207114327.GI5065@dhcp22.suse.cz>
 <20170207130350.njwuiq3uh6vhj5t2@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170207130350.njwuiq3uh6vhj5t2@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Vlastimil Babka <vbabka@suse.cz>, Dmitry Vyukov <dvyukov@google.com>, Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <peterz@infradead.org>, syzkaller <syzkaller@googlegroups.com>, Andrew Morton <akpm@linux-foundation.org>

On Tue 07-02-17 13:03:50, Mel Gorman wrote:
> On Tue, Feb 07, 2017 at 12:43:27PM +0100, Michal Hocko wrote:
> > > Right. The unbind operation can set a mask that is any allowable CPU and
> > > the final process_work is not done in a context that prevents
> > > preemption.
> > > 
> > > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > > index 3b93879990fd..7af165d308c4 100644
> > > --- a/mm/page_alloc.c
> > > +++ b/mm/page_alloc.c
> > > @@ -2342,7 +2342,14 @@ void drain_local_pages(struct zone *zone)
> > >  
> > >  static void drain_local_pages_wq(struct work_struct *work)
> > >  {
> > > +	/*
> > > +	 * Ordinarily a drain operation is bound to a CPU but may be unbound
> > > +	 * after a CPU hotplug operation so it's necessary to disable
> > > +	 * preemption for the drain to stabilise the CPU ID.
> > > +	 */
> > > +	preempt_disable();
> > >  	drain_local_pages(NULL);
> > > +	preempt_enable_no_resched();
> > >  }
> > >  
> > >  /*
> > [...]
> > > @@ -6711,7 +6714,16 @@ static int page_alloc_cpu_dead(unsigned int cpu)
> > >  {
> > >  
> > >  	lru_add_drain_cpu(cpu);
> > > +
> > > +	/*
> > > +	 * A per-cpu drain via a workqueue from drain_all_pages can be
> > > +	 * rescheduled onto an unrelated CPU. That allows the hotplug
> > > +	 * operation and the drain to potentially race on the same
> > > +	 * CPU. Serialise hotplug versus drain using pcpu_drain_mutex
> > > +	 */
> > > +	mutex_lock(&pcpu_drain_mutex);
> > >  	drain_pages(cpu);
> > > +	mutex_unlock(&pcpu_drain_mutex);
> > 
> > You cannot put sleepable lock inside the preempt disbaled section...
> > We can make it a spinlock right?
> > 
> 
> The CPU down callback can hold a mutex and at least he SLUB callback
> already does so. That gives
> 
> page_alloc_cpu_dead
>   mutex_lock
>     drain_pages
>   mutex_unlock
> 
> drain_all_pages
>   mutex_lock
>     queue workqueue
>       drain_local_pages_wq
>         preempt_disable
>         drain_local_pages
>         drain_pages
>         preempt_enable
>    flush queues
>  mutex_unlock
> 
> I must be blind or maybe it's rushing between multiple concerns but which
> sleepable lock is of concern?

I thought the cpu hotplug callback was non-preemptible. This is not the
case as mentioned in other reply. The pcpu_drain_mutex in the hotplug
callback is alright. Sorry about the confusion! I am still wondering
whether the lock is really needed. See the other reply.

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
