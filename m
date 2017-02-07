Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id BAFF96B0069
	for <linux-mm@kvack.org>; Tue,  7 Feb 2017 07:08:12 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id o16so2712494wra.2
        for <linux-mm@kvack.org>; Tue, 07 Feb 2017 04:08:12 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z39si4820735wrz.96.2017.02.07.04.08.11
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 07 Feb 2017 04:08:11 -0800 (PST)
Date: Tue, 7 Feb 2017 13:08:10 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: mm: deadlock between get_online_cpus/pcpu_alloc
Message-ID: <20170207120810.GK5065@dhcp22.suse.cz>
References: <CACT4Y+Z-juavN8s+5sc-PB0rbqy4zmsRpc6qZBg3C7z3topLTw@mail.gmail.com>
 <20170206220530.apvuknbagaf2rdlw@techsingularity.net>
 <20170207084855.GC5065@dhcp22.suse.cz>
 <20170207094300.cuxfqi35wflk5nr5@techsingularity.net>
 <2cdef192-1939-d692-1224-8ff7d7ff7203@suse.cz>
 <20170207102809.awh22urqmfrav5r6@techsingularity.net>
 <20170207103552.GH5065@dhcp22.suse.cz>
 <20170207113435.6xthczxt2cx23r4t@techsingularity.net>
 <20170207114327.GI5065@dhcp22.suse.cz>
 <2539ac25-7e15-f91f-83ba-10556eb0360b@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <2539ac25-7e15-f91f-83ba-10556eb0360b@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Mel Gorman <mgorman@techsingularity.net>, Dmitry Vyukov <dvyukov@google.com>, Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, Peter Zijlstra <peterz@infradead.org>, syzkaller <syzkaller@googlegroups.com>, Andrew Morton <akpm@linux-foundation.org>

On Tue 07-02-17 12:54:48, Vlastimil Babka wrote:
> On 02/07/2017 12:43 PM, Michal Hocko wrote:
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
> 
> Could we do flush_work() with a spinlock? Sounds bad too.

We surely cannot. I thought the lock would be gone in drain_all_pages,
we would deadlock with the lock there anyway... But it is true that we
would need a way to only allow one caller to get in. This is getting
messier and messier...

> Maybe we could just use the fact that the whole drain happens with disabled
> irq's and obtain the current cpu under that protection?

preempt_disable should be enough, no? The CPU callback is not called
from an IRQ context, right?
---
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 1ee49474207e..4a9a65479435 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2343,7 +2343,16 @@ void drain_local_pages(struct zone *zone)
 
 static void drain_local_pages_wq(struct work_struct *work)
 {
+	/*
+	 * drain_all_pages doesn't use proper cpu hotplug protection so
+	 * we can race with cpu offline when the WQ can move this from
+	 * a cpu pinned worker to an unbound one. We can operate on a different
+	 * cpu which is allright but we also have to make sure to not move to
+	 * a different one.
+	 */
+	preempt_disable();
 	drain_local_pages(NULL);
+	preempt_enable();
 }
 
 /*
@@ -2379,12 +2388,6 @@ void drain_all_pages(struct zone *zone)
 	}
 
 	/*
-	 * As this can be called from reclaim context, do not reenter reclaim.
-	 * An allocation failure can be handled, it's simply slower
-	 */
-	get_online_cpus();
-
-	/*
 	 * We don't care about racing with CPU hotplug event
 	 * as offline notification will cause the notified
 	 * cpu to drain that CPU pcps and on_each_cpu_mask
@@ -2423,7 +2426,6 @@ void drain_all_pages(struct zone *zone)
 	for_each_cpu(cpu, &cpus_with_pcps)
 		flush_work(per_cpu_ptr(&pcpu_drain, cpu));
 
-	put_online_cpus();
 	mutex_unlock(&pcpu_drain_mutex);
 }
 
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
