Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx103.postini.com [74.125.245.103])
	by kanga.kvack.org (Postfix) with SMTP id 0BA5C6B002B
	for <linux-mm@kvack.org>; Mon,  8 Oct 2012 09:44:53 -0400 (EDT)
Message-ID: <5072D8CC.6020705@hp.com>
Date: Mon, 08 Oct 2012 06:44:44 -0700
From: Don Morris <don.morris@hp.com>
MIME-Version: 1.0
Subject: Re: [PATCH 00/33] AutoNUMA27
References: <1349308275-2174-1-git-send-email-aarcange@redhat.com> <20121004113943.be7f92a0.akpm@linux-foundation.org> <m24nm8wly3.fsf@firstfloor.org> <1349481433.17632.62.camel@schen9-DESK> <m2zk40v4qy.fsf@firstfloor.org>
In-Reply-To: <m2zk40v4qy.fsf@firstfloor.org>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: Tim Chen <tim.c.chen@linux.intel.com>, Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <pzijlstr@redhat.com>, Ingo Molnar <mingo@elte.hu>, Mel Gorman <mel@csn.ul.ie>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Hillf Danton <dhillf@gmail.com>, Andrew Jones <drjones@redhat.com>, Dan Smith <danms@us.ibm.com>, Thomas Gleixner <tglx@linutronix.de>, Paul Turner <pjt@google.com>, Christoph Lameter <cl@linux.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>, Alex@linux.intel.com, Sh@linux.intel.com

On 10/05/2012 05:11 PM, Andi Kleen wrote:
> Tim Chen <tim.c.chen@linux.intel.com> writes:
>>>
>>
>> I remembered that 3 months ago when Alex tested the numa/sched patches
>> there were 20% regression on SpecJbb2005 due to the numa balancer.
> 
> 20% on anything sounds like a show stopper to me.
> 
> -Andi
> 

Much worse than that on an 8-way machine for a multi-node multi-threaded
process, from what I can tell. (Andrea's AutoNUMA microbenchmark is a
simple version of that). The contention on the page table lock
( &(&mm->page_table_lock)->rlock ) goes through the roof, with threads
constantly fighting to invalidate translations and re-fault them.

This is on a DL980 with Xeon E7-2870s @ 2.4 GHz, btw.

Running linux-next with no tweaks other than
kernel.sched_migration_cost_ns = 500000 gives:
numa01
8325.78
numa01_HARD_BIND
488.98

(The Hard Bind being a case where the threads are pre-bound to the
node set with their memory, so what should be a fairly "best case" for
comparison).

If the SchedNUMA scanning period is upped to 25000 ms (to keep repeated
invalidations from being triggered while the contention for the first
invalidation pass is still being fought over):
numa01
4272.93
numa01_HARD_BIND
498.98

Since this is a "big" process in the current SchedNUMA code and hence
much more likely to trip invalidations, forcing task_numa_big() to
always return false in order to avoid the frequent invalidations gives:
numa01
429.07
numa01_HARD_BIND
466.67

Finally, with SchedNUMA entirely disabled but the rest of linux-next
left intact:
numa01
1075.31
numa01_HARD_BIND
484.20

I didn't write down the lock contentions for comparison, but yes -
the contention does decrease similarly to the time decreases.

There are other microbenchmarks, but those suffice to show the
regression pattern. I mentioned this to the RedHat folks last
week, so I expect this is already being worked. It seemed pertinent
to bring up given the discussion about the current state of linux-next
though, just so folks know. From where I'm sitting, it looks to
me like the scan period is way too aggressive and there's too much
work potentially attempted during a "scan" (by which I mean the
hard tick driven choice to invalidate in order to set up potential
migration faults). The current code walks/invalidates the entire
virtual address space, skipping few vmas. For a very large 64-bit
process, that's going to be a *lot* of translations (or even vmas
if the address space is fragmented) to walk. That's a seriously
long path coming from the timer code. I would think capping the
number of translations to process per visit would help.

Hope this helps the discussion,
Don Morris

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
