Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx189.postini.com [74.125.245.189])
	by kanga.kvack.org (Postfix) with SMTP id C6EB46B0031
	for <linux-mm@kvack.org>; Wed, 31 Jul 2013 14:06:47 -0400 (EDT)
Received: from /spool/local
	by e39.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srikar@linux.vnet.ibm.com>;
	Wed, 31 Jul 2013 12:06:47 -0600
Received: from d01relay06.pok.ibm.com (d01relay06.pok.ibm.com [9.56.227.116])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id BF0666E8040
	for <linux-mm@kvack.org>; Wed, 31 Jul 2013 14:06:39 -0400 (EDT)
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d01relay06.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r6VI6ihX34341056
	for <linux-mm@kvack.org>; Wed, 31 Jul 2013 14:06:44 -0400
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r6VI6eC8015290
	for <linux-mm@kvack.org>; Wed, 31 Jul 2013 12:06:41 -0600
Date: Wed, 31 Jul 2013 23:36:35 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: Re: [RFC PATCH 00/10] Improve numa scheduling by consolidating tasks
Message-ID: <20130731180635.GE4880@linux.vnet.ibm.com>
Reply-To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
References: <1375170505-5967-1-git-send-email-srikar@linux.vnet.ibm.com>
 <20130730081755.GF3008@twins.programming.kicks-ass.net>
 <20130730082001.GG3008@twins.programming.kicks-ass.net>
 <20130730090345.GA22201@linux.vnet.ibm.com>
 <20130730091021.GM3008@twins.programming.kicks-ass.net>
 <20130730094650.GB28656@linux.vnet.ibm.com>
 <20130731150923.GC3008@twins.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20130731150923.GC3008@twins.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Mel Gorman <mgorman@suse.de>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Preeti U Murthy <preeti@linux.vnet.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>

* Peter Zijlstra <peterz@infradead.org> [2013-07-31 17:09:23]:

> On Tue, Jul 30, 2013 at 03:16:50PM +0530, Srikar Dronamraju wrote:
> > I am not against fault and fault based handling is very much needed. 
> > I have listed that this approach is complementary to numa faults that
> > Mel is proposing. 
> > 
> > Right now I think if we can first get the tasks to consolidate on nodes
> > and then use the numa faults to place the tasks, then we would be able
> > to have a very good solution. 
> > 
> > Plain fault information is actually causing confusion in enough number
> > of cases esp if the initial set of pages is all consolidated into fewer
> > set of nodes. With plain fault information, memory follows cpu, cpu
> > follows memory are conflicting with each other. memory wants to move to
> > nodes where the tasks are currently running and the tasks are planning
> > to move nodes where the current memory is around.
> 
> Since task weights are a completely random measure the above story
> completely fails to make any sense. If you can collate on an arbitrary
> number, why can't you collate on faults?

Since task weights contribute to cpu load and we would want to keep the
loads balanced, and make sure that we dont do excessive consolidation
where we end up being imbalanced across cpus/nodes. So for example,
numa02 case, (single process running across all nodes), we dont want
tasks to consolidate or make the system imbalanced. So I thought task
weights would give me hints to say we should consolidating or we should
back off from consolidation. How do I derive hints to stop consolidation
based on numa faults.

> 
> The fact that the placement policies so far have not had inter-task
> relations doesn't mean its not possible.
> 

Do you have ideas that I can try out that could help build these
inter-task relations?

> > Also most of the consolidation that I have proposed is pretty
> > conservative or either done at idle balance time. This would not affect
> > the numa faulting in any way. When I run with my patches (along with
> > some debug code), the consolidation happens pretty pretty quickly.
> > Once consolidation has happened, numa faults would be of immense value.
> 
> And also completely broken in various 'fun' ways. You're far too fond of
> nr_running for one.

Yeah I too feel, I am too attached to nr_running.
> 
> Also, afaict it never does anything if the machine is overloaded and we
> never hit the !nr_running case in rebalance_domains.

Actually not, in most of my testing, cpu utilization is close to 100%.
And I have find_numa_queue, preferred_node logic that should kick in. 
My idea is we could achieve consolidation much easier in a overloaded
case since we dont actually have to do active migration. Futher there
are hints at task wake up time.

If we can further make the load balancer super intelligent that it
schedules the right task on the right cpu/node, will we need to
do migrate cpus on faults? Arent we making the code complicated by
introducing too many more points where we do pseudo load balancing?


> 
> > Here is how I am looking at the solution.
> > 
> > 1. Till the initial scan delay, allow tasks to consolidate
> 
> I would really want to not change regular balance behaviour for now;
> you're also adding far too many atomic operations to the scheduler fast
> path, that's going to make people terribly unhappy.
> 
> > 2. After the first scan delay to the next scan delay, account numa
> >    faults, allow memory to move. But dont use numa faults as yet to
> >    drive scheduling decisions. Here also task continue to consolidate.
> > 
> > 	This will lead to tasks and memory moving to specific nodes and
> > 	leading to consolidation.
> 
> This is just plain silly, once you have fault information you'd better
> use it to move tasks towards where the memory is, doing anything else
> is, like said, silly.
> 
> > 3. After the second scan delay, continue to account numa faults and
> > allow numa faults to drive scheduling decisions.
> > 
> > Should we use also use task weights at stage 3 or just numa faults or
> > which one should get more preference is something that I am not clear at
> > this time. At this time, I would think we would need to factor in both
> > of them.
> > 
> > I think this approach would mean tasks get consolidated but the inter
> > process, inter task relations that you are looking for also remain
> > strong.
> > 
> > Is this a acceptable solution?
> 
> No, again, task weight is a completely random number unrelated to
> anything we want to do. Furthermore we simply cannot add mm wide atomics
> to the scheduler hot paths.
> 

How do I maintain a per-mm per node data?

-- 
Thanks and Regards
Srikar Dronamraju

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
