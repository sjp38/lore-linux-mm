Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 798E16B0038
	for <linux-mm@kvack.org>; Mon, 23 Jan 2017 11:29:23 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id r144so19334372wme.0
        for <linux-mm@kvack.org>; Mon, 23 Jan 2017 08:29:23 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f42si19367878wrf.268.2017.01.23.08.29.21
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 23 Jan 2017 08:29:22 -0800 (PST)
Date: Mon, 23 Jan 2017 17:29:20 +0100
From: Petr Mladek <pmladek@suse.com>
Subject: Re: [PATCH 3/4] mm, page_alloc: Drain per-cpu pages from workqueue
 context
Message-ID: <20170123162841.GA6620@pathway.suse.cz>
References: <20170117092954.15413-1-mgorman@techsingularity.net>
 <20170117092954.15413-4-mgorman@techsingularity.net>
 <06c39883-eff5-1412-a148-b063aa7bcc5f@suse.cz>
 <20170120152606.w3hb53m2w6thzsqq@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170120152606.w3hb53m2w6thzsqq@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Hillf Danton <hillf.zj@alibaba-inc.com>, Jesper Dangaard Brouer <brouer@redhat.com>, Tejun Heo <tj@kernel.org>

On Fri 2017-01-20 15:26:06, Mel Gorman wrote:
> On Fri, Jan 20, 2017 at 03:26:05PM +0100, Vlastimil Babka wrote:
> > > @@ -2392,8 +2404,24 @@ void drain_all_pages(struct zone *zone)
> > >  		else
> > >  			cpumask_clear_cpu(cpu, &cpus_with_pcps);
> > >  	}
> > > -	on_each_cpu_mask(&cpus_with_pcps, (smp_call_func_t) drain_local_pages,
> > > -								zone, 1);
> > > +
> > > +	if (works) {
> > > +		for_each_cpu(cpu, &cpus_with_pcps) {
> > > +			struct work_struct *work = per_cpu_ptr(works, cpu);
> > > +			INIT_WORK(work, drain_local_pages_wq);
> > > +			schedule_work_on(cpu, work);
> > 
> > This translates to queue_work_on(), which has the comment of "We queue
> > the work to a specific CPU, the caller must ensure it can't go away.",
> > so is this safe? lru_add_drain_all() uses get_online_cpus() around this.
> > 
> 
> get_online_cpus() would be required.
> 
> > schedule_work_on() also uses the generic system_wq, while lru drain has
> > its own workqueue with WQ_MEM_RECLAIM so it seems that would be useful
> > here as well?
> > 
> 
> I would be reluctant to introduce a dedicated queue unless there was a
> definite case where an OOM occurred because pages were pinned on per-cpu
> lists and couldn't be drained because the buddy allocator was depleted.
> As it was, I thought the fallback case was excessively paranoid.

I guess that you know it but it is not clear from the above paragraph.

WQ_MEM_RECLAIM makes sure that there is a rescue worker available.
It is used when all workers are busy (blocked by an allocation
request) and new worker (kthread) cannot be forked because
the fork would need an allocation as well.

The fallback below solves the situation when struct work cannot
be allocated. But it does not solve the situation when there is
no worker to actually proceed the work. I am not sure if this
is relevant for drain_all_pages().

Best Regards,
Petr

> > > +		}
> > > +		for_each_cpu(cpu, &cpus_with_pcps)
> > > +			flush_work(per_cpu_ptr(works, cpu));
> > > +	} else {
> > > +		for_each_cpu(cpu, &cpus_with_pcps) {
> > > +			struct work_struct work;
> > > +
> > > +			INIT_WORK(&work, drain_local_pages_wq);
> > > +			schedule_work_on(cpu, &work);
> > > +			flush_work(&work);
> > 
> > Totally out of scope, but I wonder if schedule_on_each_cpu() could use
> > the same fallback that's here?
> > 
> 
> I'm not aware of a case where it really has been a problem. I only considered
> it here as the likely caller is in a context that is failing allocations.
> 
> -- 
> Mel Gorman
> SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
