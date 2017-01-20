Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f200.google.com (mail-wj0-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id A5F8E6B0033
	for <linux-mm@kvack.org>; Fri, 20 Jan 2017 10:26:08 -0500 (EST)
Received: by mail-wj0-f200.google.com with SMTP id yr2so15646409wjc.4
        for <linux-mm@kvack.org>; Fri, 20 Jan 2017 07:26:08 -0800 (PST)
Received: from outbound-smtp02.blacknight.com (outbound-smtp02.blacknight.com. [81.17.249.8])
        by mx.google.com with ESMTPS id g200si3804466wmd.121.2017.01.20.07.26.06
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 20 Jan 2017 07:26:07 -0800 (PST)
Received: from mail.blacknight.com (pemlinmail01.blacknight.ie [81.17.254.10])
	by outbound-smtp02.blacknight.com (Postfix) with ESMTPS id B002E9921E
	for <linux-mm@kvack.org>; Fri, 20 Jan 2017 15:26:06 +0000 (UTC)
Date: Fri, 20 Jan 2017 15:26:06 +0000
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 3/4] mm, page_alloc: Drain per-cpu pages from workqueue
 context
Message-ID: <20170120152606.w3hb53m2w6thzsqq@techsingularity.net>
References: <20170117092954.15413-1-mgorman@techsingularity.net>
 <20170117092954.15413-4-mgorman@techsingularity.net>
 <06c39883-eff5-1412-a148-b063aa7bcc5f@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <06c39883-eff5-1412-a148-b063aa7bcc5f@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Hillf Danton <hillf.zj@alibaba-inc.com>, Jesper Dangaard Brouer <brouer@redhat.com>, Petr Mladek <pmladek@suse.cz>

On Fri, Jan 20, 2017 at 03:26:05PM +0100, Vlastimil Babka wrote:
> > @@ -2392,8 +2404,24 @@ void drain_all_pages(struct zone *zone)
> >  		else
> >  			cpumask_clear_cpu(cpu, &cpus_with_pcps);
> >  	}
> > -	on_each_cpu_mask(&cpus_with_pcps, (smp_call_func_t) drain_local_pages,
> > -								zone, 1);
> > +
> > +	if (works) {
> > +		for_each_cpu(cpu, &cpus_with_pcps) {
> > +			struct work_struct *work = per_cpu_ptr(works, cpu);
> > +			INIT_WORK(work, drain_local_pages_wq);
> > +			schedule_work_on(cpu, work);
> 
> This translates to queue_work_on(), which has the comment of "We queue
> the work to a specific CPU, the caller must ensure it can't go away.",
> so is this safe? lru_add_drain_all() uses get_online_cpus() around this.
> 

get_online_cpus() would be required.

> schedule_work_on() also uses the generic system_wq, while lru drain has
> its own workqueue with WQ_MEM_RECLAIM so it seems that would be useful
> here as well?
> 

I would be reluctant to introduce a dedicated queue unless there was a
definite case where an OOM occurred because pages were pinned on per-cpu
lists and couldn't be drained because the buddy allocator was depleted.
As it was, I thought the fallback case was excessively paranoid.

> > +		}
> > +		for_each_cpu(cpu, &cpus_with_pcps)
> > +			flush_work(per_cpu_ptr(works, cpu));
> > +	} else {
> > +		for_each_cpu(cpu, &cpus_with_pcps) {
> > +			struct work_struct work;
> > +
> > +			INIT_WORK(&work, drain_local_pages_wq);
> > +			schedule_work_on(cpu, &work);
> > +			flush_work(&work);
> 
> Totally out of scope, but I wonder if schedule_on_each_cpu() could use
> the same fallback that's here?
> 

I'm not aware of a case where it really has been a problem. I only considered
it here as the likely caller is in a context that is failing allocations.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
