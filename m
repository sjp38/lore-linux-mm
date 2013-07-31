Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx149.postini.com [74.125.245.149])
	by kanga.kvack.org (Postfix) with SMTP id 53BC86B0031
	for <linux-mm@kvack.org>; Wed, 31 Jul 2013 11:09:28 -0400 (EDT)
Date: Wed, 31 Jul 2013 17:09:23 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [RFC PATCH 00/10] Improve numa scheduling by consolidating tasks
Message-ID: <20130731150923.GC3008@twins.programming.kicks-ass.net>
References: <1375170505-5967-1-git-send-email-srikar@linux.vnet.ibm.com>
 <20130730081755.GF3008@twins.programming.kicks-ass.net>
 <20130730082001.GG3008@twins.programming.kicks-ass.net>
 <20130730090345.GA22201@linux.vnet.ibm.com>
 <20130730091021.GM3008@twins.programming.kicks-ass.net>
 <20130730094650.GB28656@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130730094650.GB28656@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Mel Gorman <mgorman@suse.de>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Preeti U Murthy <preeti@linux.vnet.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>

On Tue, Jul 30, 2013 at 03:16:50PM +0530, Srikar Dronamraju wrote:
> I am not against fault and fault based handling is very much needed. 
> I have listed that this approach is complementary to numa faults that
> Mel is proposing. 
> 
> Right now I think if we can first get the tasks to consolidate on nodes
> and then use the numa faults to place the tasks, then we would be able
> to have a very good solution. 
> 
> Plain fault information is actually causing confusion in enough number
> of cases esp if the initial set of pages is all consolidated into fewer
> set of nodes. With plain fault information, memory follows cpu, cpu
> follows memory are conflicting with each other. memory wants to move to
> nodes where the tasks are currently running and the tasks are planning
> to move nodes where the current memory is around.

Since task weights are a completely random measure the above story
completely fails to make any sense. If you can collate on an arbitrary
number, why can't you collate on faults?

The fact that the placement policies so far have not had inter-task
relations doesn't mean its not possible.

> Also most of the consolidation that I have proposed is pretty
> conservative or either done at idle balance time. This would not affect
> the numa faulting in any way. When I run with my patches (along with
> some debug code), the consolidation happens pretty pretty quickly.
> Once consolidation has happened, numa faults would be of immense value.

And also completely broken in various 'fun' ways. You're far too fond of
nr_running for one.

Also, afaict it never does anything if the machine is overloaded and we
never hit the !nr_running case in rebalance_domains.

> Here is how I am looking at the solution.
> 
> 1. Till the initial scan delay, allow tasks to consolidate

I would really want to not change regular balance behaviour for now;
you're also adding far too many atomic operations to the scheduler fast
path, that's going to make people terribly unhappy.

> 2. After the first scan delay to the next scan delay, account numa
>    faults, allow memory to move. But dont use numa faults as yet to
>    drive scheduling decisions. Here also task continue to consolidate.
> 
> 	This will lead to tasks and memory moving to specific nodes and
> 	leading to consolidation.

This is just plain silly, once you have fault information you'd better
use it to move tasks towards where the memory is, doing anything else
is, like said, silly.

> 3. After the second scan delay, continue to account numa faults and
> allow numa faults to drive scheduling decisions.
> 
> Should we use also use task weights at stage 3 or just numa faults or
> which one should get more preference is something that I am not clear at
> this time. At this time, I would think we would need to factor in both
> of them.
> 
> I think this approach would mean tasks get consolidated but the inter
> process, inter task relations that you are looking for also remain
> strong.
> 
> Is this a acceptable solution?

No, again, task weight is a completely random number unrelated to
anything we want to do. Furthermore we simply cannot add mm wide atomics
to the scheduler hot paths.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
