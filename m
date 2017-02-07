Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id BD9AD6B0069
	for <linux-mm@kvack.org>; Tue,  7 Feb 2017 06:43:31 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id a15so2666751wrc.3
        for <linux-mm@kvack.org>; Tue, 07 Feb 2017 03:43:31 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id e68si11854479wmd.118.2017.02.07.03.43.30
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 07 Feb 2017 03:43:30 -0800 (PST)
Date: Tue, 7 Feb 2017 12:43:27 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: mm: deadlock between get_online_cpus/pcpu_alloc
Message-ID: <20170207114327.GI5065@dhcp22.suse.cz>
References: <c7658ace-23ae-227a-2ea9-7e6bd1c8c761@suse.cz>
 <CACT4Y+ZT+_L3deDUcmBkr_Pr3KdCdLv6ON=2QHbK5YnBxJfLDg@mail.gmail.com>
 <CACT4Y+Z-juavN8s+5sc-PB0rbqy4zmsRpc6qZBg3C7z3topLTw@mail.gmail.com>
 <20170206220530.apvuknbagaf2rdlw@techsingularity.net>
 <20170207084855.GC5065@dhcp22.suse.cz>
 <20170207094300.cuxfqi35wflk5nr5@techsingularity.net>
 <2cdef192-1939-d692-1224-8ff7d7ff7203@suse.cz>
 <20170207102809.awh22urqmfrav5r6@techsingularity.net>
 <20170207103552.GH5065@dhcp22.suse.cz>
 <20170207113435.6xthczxt2cx23r4t@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170207113435.6xthczxt2cx23r4t@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Vlastimil Babka <vbabka@suse.cz>, Dmitry Vyukov <dvyukov@google.com>, Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <peterz@infradead.org>, syzkaller <syzkaller@googlegroups.com>, Andrew Morton <akpm@linux-foundation.org>

On Tue 07-02-17 11:34:35, Mel Gorman wrote:
> On Tue, Feb 07, 2017 at 11:35:52AM +0100, Michal Hocko wrote:
> > On Tue 07-02-17 10:28:09, Mel Gorman wrote:
> > > On Tue, Feb 07, 2017 at 10:49:28AM +0100, Vlastimil Babka wrote:
> > > > On 02/07/2017 10:43 AM, Mel Gorman wrote:
> > > > > If I'm reading this right, a hot-remove will set the pool POOL_DISASSOCIATED
> > > > > and unbound. A workqueue queued for draining get migrated during hot-remove
> > > > > and a drain operation will execute twice on a CPU -- one for what was
> > > > > queued and a second time for the CPU it was migrated from. It should still
> > > > > work with flush_work which doesn't appear to block forever if an item
> > > > > got migrated to another workqueue. The actual drain workqueue function is
> > > > > using the CPU ID it's currently running on so it shouldn't get confused.
> > > > 
> > > > Is the worker that will process this migrated workqueue also guaranteed
> > > > to be pinned to a cpu for the whole work, though? drain_local_pages()
> > > > needs that guarantee.
> > > > 
> > > 
> > > It should be by running on a workqueue handler bound to that CPU (queued
> > > on wq->cpu_pwqs in __queue_work)
> > 
> > Are you sure? The comment in kernel/workqueue.c says
> >          * While DISASSOCIATED, the cpu may be offline and all workers have
> >          * %WORKER_UNBOUND set and concurrency management disabled, and may
> >          * be executing on any CPU.  The pool behaves as an unbound one.
> > 
> > I might be misreadig but an unbound pool can be handled by workers which
> > are not pinned on any cpu AFAIU.
> 
> Right. The unbind operation can set a mask that is any allowable CPU and
> the final process_work is not done in a context that prevents
> preemption.
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 3b93879990fd..7af165d308c4 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -2342,7 +2342,14 @@ void drain_local_pages(struct zone *zone)
>  
>  static void drain_local_pages_wq(struct work_struct *work)
>  {
> +	/*
> +	 * Ordinarily a drain operation is bound to a CPU but may be unbound
> +	 * after a CPU hotplug operation so it's necessary to disable
> +	 * preemption for the drain to stabilise the CPU ID.
> +	 */
> +	preempt_disable();
>  	drain_local_pages(NULL);
> +	preempt_enable_no_resched();
>  }
>  
>  /*
[...]
> @@ -6711,7 +6714,16 @@ static int page_alloc_cpu_dead(unsigned int cpu)
>  {
>  
>  	lru_add_drain_cpu(cpu);
> +
> +	/*
> +	 * A per-cpu drain via a workqueue from drain_all_pages can be
> +	 * rescheduled onto an unrelated CPU. That allows the hotplug
> +	 * operation and the drain to potentially race on the same
> +	 * CPU. Serialise hotplug versus drain using pcpu_drain_mutex
> +	 */
> +	mutex_lock(&pcpu_drain_mutex);
>  	drain_pages(cpu);
> +	mutex_unlock(&pcpu_drain_mutex);

You cannot put sleepable lock inside the preempt disbaled section...
We can make it a spinlock right?

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
