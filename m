Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id D20AF6B0038
	for <linux-mm@kvack.org>; Mon, 23 Jan 2017 11:50:46 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id d140so19537401wmd.4
        for <linux-mm@kvack.org>; Mon, 23 Jan 2017 08:50:46 -0800 (PST)
Received: from outbound-smtp05.blacknight.com (outbound-smtp05.blacknight.com. [81.17.249.38])
        by mx.google.com with ESMTPS id a40si19420560wrc.296.2017.01.23.08.50.45
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 23 Jan 2017 08:50:45 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail06.blacknight.ie [81.17.255.152])
	by outbound-smtp05.blacknight.com (Postfix) with ESMTPS id 250A621005A
	for <linux-mm@kvack.org>; Mon, 23 Jan 2017 16:50:45 +0000 (UTC)
Date: Mon, 23 Jan 2017 16:50:42 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 3/4] mm, page_alloc: Drain per-cpu pages from workqueue
 context
Message-ID: <20170123165042.xh6uneeisa4w4sdo@techsingularity.net>
References: <20170117092954.15413-1-mgorman@techsingularity.net>
 <20170117092954.15413-4-mgorman@techsingularity.net>
 <06c39883-eff5-1412-a148-b063aa7bcc5f@suse.cz>
 <20170120152606.w3hb53m2w6thzsqq@techsingularity.net>
 <20170123162841.GA6620@pathway.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20170123162841.GA6620@pathway.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Petr Mladek <pmladek@suse.com>
Cc: Vlastimil Babka <vbabka@suse.cz>, Andrew Morton <akpm@linux-foundation.org>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Hillf Danton <hillf.zj@alibaba-inc.com>, Jesper Dangaard Brouer <brouer@redhat.com>, Tejun Heo <tj@kernel.org>

On Mon, Jan 23, 2017 at 05:29:20PM +0100, Petr Mladek wrote:
> On Fri 2017-01-20 15:26:06, Mel Gorman wrote:
> > On Fri, Jan 20, 2017 at 03:26:05PM +0100, Vlastimil Babka wrote:
> > > > @@ -2392,8 +2404,24 @@ void drain_all_pages(struct zone *zone)
> > > >  		else
> > > >  			cpumask_clear_cpu(cpu, &cpus_with_pcps);
> > > >  	}
> > > > -	on_each_cpu_mask(&cpus_with_pcps, (smp_call_func_t) drain_local_pages,
> > > > -								zone, 1);
> > > > +
> > > > +	if (works) {
> > > > +		for_each_cpu(cpu, &cpus_with_pcps) {
> > > > +			struct work_struct *work = per_cpu_ptr(works, cpu);
> > > > +			INIT_WORK(work, drain_local_pages_wq);
> > > > +			schedule_work_on(cpu, work);
> > > 
> > > This translates to queue_work_on(), which has the comment of "We queue
> > > the work to a specific CPU, the caller must ensure it can't go away.",
> > > so is this safe? lru_add_drain_all() uses get_online_cpus() around this.
> > > 
> > 
> > get_online_cpus() would be required.
> > 
> > > schedule_work_on() also uses the generic system_wq, while lru drain has
> > > its own workqueue with WQ_MEM_RECLAIM so it seems that would be useful
> > > here as well?
> > > 
> > 
> > I would be reluctant to introduce a dedicated queue unless there was a
> > definite case where an OOM occurred because pages were pinned on per-cpu
> > lists and couldn't be drained because the buddy allocator was depleted.
> > As it was, I thought the fallback case was excessively paranoid.
> 
> I guess that you know it but it is not clear from the above paragraph.
> 
> WQ_MEM_RECLAIM makes sure that there is a rescue worker available.
> It is used when all workers are busy (blocked by an allocation
> request) and new worker (kthread) cannot be forked because
> the fork would need an allocation as well.
> 
> The fallback below solves the situation when struct work cannot
> be allocated. But it does not solve the situation when there is
> no worker to actually proceed the work. I am not sure if this
> is relevant for drain_all_pages().
> 

I'm aware of the situation but in itself, I still don't think it justifies
a dedicated workqueue. The main call for drain_all_pages under reclaim
pressure is dubious because it's easy to trigger. For example, two contenders
for memory that are doing a streaming read or large amounts of anonymous
faults. Reclaim can be making progress but the two are racing with each
other to keep the watermarks above min and draining frequently. The IPIs
for a fairly normal situation are bad enough and even the workqueue work
isn't particularly welcome.

It would make more sense overall to move the unreserve and drain logic
into the nearly-oom path but it would likely be overkill. I'd only want
to look into that or a dedicated workqueue if there is a case of an OOM
triggered when a large number of CPUs had per-cpu pages available.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
