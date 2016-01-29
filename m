Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f176.google.com (mail-yk0-f176.google.com [209.85.160.176])
	by kanga.kvack.org (Postfix) with ESMTP id 4BA296B0254
	for <linux-mm@kvack.org>; Fri, 29 Jan 2016 06:09:43 -0500 (EST)
Received: by mail-yk0-f176.google.com with SMTP id r207so21075869ykd.2
        for <linux-mm@kvack.org>; Fri, 29 Jan 2016 03:09:43 -0800 (PST)
Received: from mail-yk0-x22f.google.com (mail-yk0-x22f.google.com. [2607:f8b0:4002:c07::22f])
        by mx.google.com with ESMTPS id m123si5932844ywe.321.2016.01.29.03.09.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 Jan 2016 03:09:42 -0800 (PST)
Received: by mail-yk0-x22f.google.com with SMTP id k129so64939863yke.0
        for <linux-mm@kvack.org>; Fri, 29 Jan 2016 03:09:42 -0800 (PST)
Date: Fri, 29 Jan 2016 06:09:41 -0500
From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH] workqueue: warn if memory reclaim tries to flush
 !WQ_MEM_RECLAIM workqueue
Message-ID: <20160129110941.GK32380@htj.duckdns.org>
References: <20151203002810.GJ19878@mtj.duckdns.org>
 <20151203093350.GP17308@twins.programming.kicks-ass.net>
 <20151203100018.GO11639@twins.programming.kicks-ass.net>
 <20151203144811.GA27463@mtj.duckdns.org>
 <20151203150442.GR17308@twins.programming.kicks-ass.net>
 <20151203150604.GC27463@mtj.duckdns.org>
 <20151203192616.GJ27463@mtj.duckdns.org>
 <20160126173843.GA11115@ulmo.nvidia.com>
 <20160128101210.GC6357@twins.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160128101210.GC6357@twins.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Thierry Reding <thierry.reding@gmail.com>, Ulrich Obergfell <uobergfe@redhat.com>, Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, kernel-team@fb.com, Jon Hunter <jonathanh@nvidia.com>, linux-tegra@vger.kernel.org, rmk+kernel@arm.linux.org.uk, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org

Hello, Peter.

On Thu, Jan 28, 2016 at 11:12:10AM +0100, Peter Zijlstra wrote:
> On Tue, Jan 26, 2016 at 06:38:43PM +0100, Thierry Reding wrote:
> > > Task or work item involved in memory reclaim trying to flush a
> > > non-WQ_MEM_RECLAIM workqueue or one of its work items can lead to
> > > deadlock.  Trigger WARN_ONCE() if such conditions are detected.
> > I've started noticing the following during boot on some of the devices I
> > work with:
> > 
> > [    4.723705] WARNING: CPU: 0 PID: 6 at kernel/workqueue.c:2361 check_flush_dependency+0x138/0x144()
> > [    4.736818] workqueue: WQ_MEM_RECLAIM deferwq:deferred_probe_work_func is flushing !WQ_MEM_RECLAIM events:lru_add_drain_per_cpu
...
> Right, also, I think it makes sense to do lru_add_drain_all() from a
> WQ_MEM_RECLAIM workqueue, it is, after all, aiding in getting memory
> freed.
> 
> Does something like the below cure things?
> 
> TJ does this make sense to you?

The problem here is that deferwq which has nothing to do with memory
reclaim is marked with WQ_MEM_RECLAIM because it was created the old
create_singlethread_workqueue() which doesn't distinguish workqueues
which may be used on mem reclaim path and thus has to mark all as
needing forward progress guarantee.  I posted a patch to disable
disable flush dependency checks on those workqueues and there's a
outreachy project to weed out the users of the old interface, so
hopefully this won't be an issue soon.

As for whether lru drain should have WQ_MEM_RECLAIM, I'm not sure.
Cc'ing linux-mm.  The rule here is that any workquee which is depended
upon during memory reclaim should have WQ_MEM_RECLAIM set.  IOW, if a
work item failing to start execution under memory pressure can prevent
memory from being reclaimed, it should be scheduled on a
WQ_MEM_RECLAIM workqueue.  Would this be the case for
lru_add_drain_per_cpu()?

Thanks.

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
