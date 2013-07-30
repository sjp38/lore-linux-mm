Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx112.postini.com [74.125.245.112])
	by kanga.kvack.org (Postfix) with SMTP id 1E0F76B0031
	for <linux-mm@kvack.org>; Tue, 30 Jul 2013 05:47:02 -0400 (EDT)
Received: from /spool/local
	by e37.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srikar@linux.vnet.ibm.com>;
	Tue, 30 Jul 2013 03:47:01 -0600
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id 2CFCF3E40040
	for <linux-mm@kvack.org>; Tue, 30 Jul 2013 03:46:36 -0600 (MDT)
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r6U9kwxO163094
	for <linux-mm@kvack.org>; Tue, 30 Jul 2013 03:46:58 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r6U9kv1K003214
	for <linux-mm@kvack.org>; Tue, 30 Jul 2013 03:46:58 -0600
Date: Tue, 30 Jul 2013 15:16:50 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: Re: [RFC PATCH 00/10] Improve numa scheduling by consolidating tasks
Message-ID: <20130730094650.GB28656@linux.vnet.ibm.com>
Reply-To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
References: <1375170505-5967-1-git-send-email-srikar@linux.vnet.ibm.com>
 <20130730081755.GF3008@twins.programming.kicks-ass.net>
 <20130730082001.GG3008@twins.programming.kicks-ass.net>
 <20130730090345.GA22201@linux.vnet.ibm.com>
 <20130730091021.GM3008@twins.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20130730091021.GM3008@twins.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Mel Gorman <mgorman@suse.de>, Ingo Molnar <mingo@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Preeti U Murthy <preeti@linux.vnet.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>

* Peter Zijlstra <peterz@infradead.org> [2013-07-30 11:10:21]:

> On Tue, Jul 30, 2013 at 02:33:45PM +0530, Srikar Dronamraju wrote:
> > * Peter Zijlstra <peterz@infradead.org> [2013-07-30 10:20:01]:
> > 
> > > On Tue, Jul 30, 2013 at 10:17:55AM +0200, Peter Zijlstra wrote:
> > > > On Tue, Jul 30, 2013 at 01:18:15PM +0530, Srikar Dronamraju wrote:
> > > > > Here is an approach that looks to consolidate workloads across nodes.
> > > > > This results in much improved performance. Again I would assume this work
> > > > > is complementary to Mel's work with numa faulting.
> > > > 
> > > > I highly dislike the use of task weights here. It seems completely
> > > > unrelated to the problem at hand.
> > > 
> > > I also don't particularly like the fact that it's purely process based.
> > > The faults information we have gives much richer task relations.
> > > 
> > 
> > With just pure fault information based approach, I am not seeing any
> > major improvement in tasks/memory consolidation. I still see memory
> > spread across different nodes and tasks getting ping-ponged to different
> > nodes. And if there are multiple unrelated processes, then we see a mix
> > of tasks of different processes in each of the node.
> 
> The fault thing isn't finished. Mel explicitly said it doesn't yet have
> inter-task relations. And you run everything in a VM which is like a big
> nasty mangler for anything sane.
> 

I am not against fault and fault based handling is very much needed. 
I have listed that this approach is complementary to numa faults that
Mel is proposing. 

Right now I think if we can first get the tasks to consolidate on nodes
and then use the numa faults to place the tasks, then we would be able
to have a very good solution. 

Plain fault information is actually causing confusion in enough number
of cases esp if the initial set of pages is all consolidated into fewer
set of nodes. With plain fault information, memory follows cpu, cpu
follows memory are conflicting with each other. memory wants to move to
nodes where the tasks are currently running and the tasks are planning
to move nodes where the current memory is around.

Also most of the consolidation that I have proposed is pretty
conservative or either done at idle balance time. This would not affect
the numa faulting in any way. When I run with my patches (along with
some debug code), the consolidation happens pretty pretty quickly.
Once consolidation has happened, numa faults would be of immense value.

Here is how I am looking at the solution.

1. Till the initial scan delay, allow tasks to consolidate

2. After the first scan delay to the next scan delay, account numa
   faults, allow memory to move. But dont use numa faults as yet to
   drive scheduling decisions. Here also task continue to consolidate.

	This will lead to tasks and memory moving to specific nodes and
	leading to consolidation.
	
3. After the second scan delay, continue to account numa faults and
allow numa faults to drive scheduling decisions.

Should we use also use task weights at stage 3 or just numa faults or
which one should get more preference is something that I am not clear at
this time. At this time, I would think we would need to factor in both
of them.

I think this approach would mean tasks get consolidated but the inter
process, inter task relations that you are looking for also remain
strong.

Is this a acceptable solution?

-- 
Thanks and Regards
Srikar




-- 
Thanks and Regards
Srikar Dronamraju

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
