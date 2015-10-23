Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f171.google.com (mail-io0-f171.google.com [209.85.223.171])
	by kanga.kvack.org (Postfix) with ESMTP id EB80082F64
	for <linux-mm@kvack.org>; Fri, 23 Oct 2015 08:25:25 -0400 (EDT)
Received: by ioll68 with SMTP id l68so122885834iol.3
        for <linux-mm@kvack.org>; Fri, 23 Oct 2015 05:25:25 -0700 (PDT)
Received: from www262.sakura.ne.jp (www262.sakura.ne.jp. [2001:e42:101:1:202:181:97:72])
        by mx.google.com with ESMTPS id h31si15443719ioi.167.2015.10.23.05.25.24
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 23 Oct 2015 05:25:25 -0700 (PDT)
Subject: Re: [PATCH] mm,vmscan: Use accurate values for zone_reclaimable() checks
From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
References: <20151022154922.GG26854@dhcp22.suse.cz>
	<20151022184226.GA19289@mtj.duckdns.org>
	<20151023083316.GB2410@dhcp22.suse.cz>
	<20151023103630.GA4170@mtj.duckdns.org>
	<20151023111145.GH2410@dhcp22.suse.cz>
In-Reply-To: <20151023111145.GH2410@dhcp22.suse.cz>
Message-Id: <201510232125.DAG82381.LMJtOQFOHVOSFF@I-love.SAKURA.ne.jp>
Date: Fri, 23 Oct 2015 21:25:11 +0900
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mhocko@kernel.org, htejun@gmail.com
Cc: cl@linux.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, torvalds@linux-foundation.org, rientjes@google.com, oleg@redhat.com, kwalker@redhat.com, akpm@linux-foundation.org, hannes@cmpxchg.org, vdavydov@parallels.com, skozina@redhat.com, mgorman@suse.de, riel@redhat.com

Michal Hocko wrote:
> On Fri 23-10-15 19:36:30, Tejun Heo wrote:
> > Hello, Michal.
> > 
> > On Fri, Oct 23, 2015 at 10:33:16AM +0200, Michal Hocko wrote:
> > > Ohh, OK I can see wq_worker_sleeping now. I've missed your point in
> > > other email, sorry about that. But now I am wondering whether this
> > > is an intended behavior. The documentation says:
> > 
> > This is.
> > 
> > >   WQ_MEM_RECLAIM
> > > 
> > >         All wq which might be used in the memory reclaim paths _MUST_
> > >         have this flag set.  The wq is guaranteed to have at least one
> > >         execution context regardless of memory pressure.
> > > 
> > > Which doesn't seem to be true currently, right? Now I can see your patch
> > 
> > It is true.
> > 
> > > to introduce WQ_IMMEDIATE but I am wondering which WQ_MEM_RECLAIM users
> > > could do without WQ_IMMEDIATE? I mean all current workers might be
> > > looping in the page allocator and it seems possible that WQ_MEM_RECLAIM
> > > work items might be waiting behind them so they cannot help to relieve
> > > the memory pressure. This doesn't sound right to me. Or I am completely
> > > confused and still fail to understand what is WQ_MEM_RECLAIM supposed to
> > > be used for.
> > 
> > It guarantees that there always is enough execution resource to
> > execute a work item from that workqueue. 
> 
> OK, strictly speaking the rescuer is there but it is kind of pointless
> if it doesn't fire up and do a work.
> 
> > The problem here is not lack
> > of execution resource but concurrency management misunderstanding the
> > situation. 
> 
> And this sounds like a bug to me.
> 
> > This also can be fixed by teaching concurrency management
> > to be a bit smarter - e.g. if a work item is burning a lot of CPU
> > cycles continuously or pool hasn't finished a work item over a certain
> > amount of time, automatically ignore the in-flight work item for the
> > purpose of concurrency management; however, this sort of inter-work
> > item busy waits are so extremely rare and undesirable that I'm not
> > sure the added complexity would be worthwhile.
> 
> Don't we have some IO related paths which would suffer from the same
> problem. I haven't checked all the WQ_MEM_RECLAIM users but from the
> name I would expect they _do_ participate in the reclaim and so they
> should be able to make a progress. Now if your new IMMEDIATE flag will
> guarantee that then I would argue that it should be implicit for
> WQ_MEM_RECLAIM otherwise we always risk a similar situation. What would
> be a counter argument for doing that?

WQ_MEM_RECLAIM only guarantees that a "struct task_struct" is preallocated
in order to avoid failing to allocate it on demand due to a GFP_KERNEL
allocation? Is this correct?

WQ_CPU_INTENSIVE only guarantees that work items don't participate in
concurrency management in order to avoid failing to wake up a "struct
task_struct" which will process the work items? Is this correct?

Is Michal's question "does it make sense to use WQ_MEM_RECLAIM without
WQ_CPU_INTENSIVE"? In other words, any "struct task_struct" which calls
rescuer_thread() must imply WQ_CPU_INTENSIVE in order to avoid failing to
wake up due to being participated in concurrency management?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
