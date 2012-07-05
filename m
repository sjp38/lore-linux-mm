Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx173.postini.com [74.125.245.173])
	by kanga.kvack.org (Postfix) with SMTP id B5ACB6B0070
	for <linux-mm@kvack.org>; Thu,  5 Jul 2012 19:00:09 -0400 (EDT)
Date: Fri, 6 Jul 2012 00:59:35 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 13/40] autonuma: CPU follow memory algorithm
Message-ID: <20120705225935.GS25422@redhat.com>
References: <1340888180-15355-1-git-send-email-aarcange@redhat.com>
 <1340888180-15355-14-git-send-email-aarcange@redhat.com>
 <1340895238.28750.49.camel@twins>
 <CAJd=RBA+FPgB9iq07YG0Pd=tN65SGK1ifmj98tomBDbYeKOE-Q@mail.gmail.com>
 <20120629125517.GD32637@gmail.com>
 <4FEDDD0C.60609@redhat.com>
 <1340995986.28750.114.camel@twins>
 <CAPQyPG4R34bi0fXHBspSpR1+gDLj2PGYpPXNLPTTTBmrRL=m4g@mail.gmail.com>
 <4FF5D7CA.5020301@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4FF5D7CA.5020301@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Nai Xia <nai.xia@gmail.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, dlaor@redhat.com, Ingo Molnar <mingo@kernel.org>, Hillf Danton <dhillf@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dan Smith <danms@us.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Johannes Weiner <hannes@cmpxchg.org>, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>, Christoph Lameter <cl@linux.com>, Alex Shi <alex.shi@intel.com>, Mauricio Faria de Oliveira <mauricfo@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Don Morris <don.morris@hp.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>

Hi Rik,

On Thu, Jul 05, 2012 at 02:07:06PM -0400, Rik van Riel wrote:
> Once the first thread gets a NUMA pagefault on a
> particular page, the page is made present in the
> page tables and NO OTHER THREAD will get NUMA
> page faults.

Oh this is a great question, thanks for raising it.

> That means when trying to compare the weighting
> of NUMA accesses between different threads in a
> 10 second interval, we only know THE FIRST FAULT.

The task_autonuma statistics don't include only the first fault every
10sec, by the time we compare stuff in the scheduler we have a trail
of fault history that decay with an exponential backoff (that can be
tuned to decay slower, right now it goes down pretty aggressively with
a shift right).

static void cpu_follow_memory_pass(struct task_struct *p,
				   struct task_autonuma *task_autonuma,
				   unsigned long *task_numa_fault)
{
	int nid;
	for_each_node(nid)
		task_numa_fault[nid] >>= 1;
	task_autonuma->task_numa_fault_tot >>= 1;
}

So depending on which thread is the first at every pass, that
information will accumulate fine over mutliple task_autonuma
structures if it's a huge amounts.

> We have no information on whether any other threads
> tried to access the same page, because we do not
> get faults more frequently.

If all threads access the same pages and there is false sharing, the
last_nid logic will eventually trigger. You're right maybe two three
passes in a row it's the same thread getting to the same page first,
but eventually another thread will get there and the last_nid will
change. The more nodes and the more threads, the less likely it's the
same getting there first.

The moment another thread in a different node access the page, any
pending migration is aborted if it's still in the page_autonuma LRU
and the autonuma_last_nid will have to be reconfirmed then before we
migrate it anywhere again.

> Not only do we not get use frequency information,
> we may not get the information on which threads use
> which memory, at all.
> 
> Somehow Andrea's code still seems to work.

It works when the process fits in the node because we use the
mm_autonuma statistics when comparing the percentage of memory
utilization per node (so called w_other/w_nid/w_cpu_nid) of threads
belonging to different processes. This alone solves all false sharing
if the process fits in the node. So that above issue becomes
irrelevant (we already convered without using task_autonuma).

Now if the process doesn't fit in the node, if there is false sharing,
that will be accounted with a smaller factor, and it will be accounted
for in its original memory location thanks to the last_nid logic. The
memory will not be migrated because of the last_nid logic
(statistically speaking).

Some spillover will definitely materialize but it won't be significant
as long as the NUMA trashing is not enormous. If the NUMA thrasing is
unlimted, well that workload is impossible to optimize and it's
impossible to converge anywhere and the best would be to do
MADV_INTERLEAVE.

But note that we're only talking about memory with page_mapcount=1
here, shared memory will never generate a single migration spillovers
or numa hinting page fault.

> How much sense does the following code still make,
> considering we may never get all the info on which
> threads use which memory?

It is required to handle the case of threads that have local memory
and the threads don't fit in a single node. That is the only case we
can perfectly coverge that involves more threads than CPUs in the
node.

This scenario is optimally optimized thanks to the mm = p->mm code
below.

There can be false sharing too as long as there is some local memory
too to converge (it may be impossible to converge on the false shared
regions even if we would account them more aggressively).

I don't exclude the reduced accounting of false shared memory that you
are asking about, may actually be beneficial. The more threads are
involved in the false sharing the more the accounting of the false
sharing regions will be reduced, and that may help to converge without
mistakes. The more threads are involved in the false sharing, the more
likely it's impossible to converge on the false shared memory.

Last but not the least, this is what the hardware gives us, it looks
good enough info to me, but I'm just trying to live with the only
information we can collect from the hardware efficiently.

> 
> +			/*
> +			 * Generate the w_nid/w_cpu_nid from the
> +			 * pre-computed mm/task_numa_weight[] and
> +			 * compute w_other using the w_m/w_t info
> +			 * collected from the other process.
> +			 */
> +			if (mm == p->mm) {
> +				if (w_t > w_t_t)
> +					w_t_t = w_t;
> +				w_other = w_t*AUTONUMA_BALANCE_SCALE/w_t_t;
> +				w_nid = task_numa_weight[nid];
> +				w_cpu_nid = task_numa_weight[cpu_nid];
> +				w_type = W_TYPE_THREAD;
> 
> Andrea, what is the real reason your code works?

Tried to explain above, but it's getting too long again, I wouldn't
know which part to drop though. If it's too messy ignore and I'll try
again later.

PS. this stuff isn't fixed in stone, I'm not saying this is the best
data collection or the best way to compute the data, I believe it's
closer to the absolute minimum amount of info and minimum computations
on the data required to perform as the hard bindings in the majority
of workloads.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
