Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx203.postini.com [74.125.245.203])
	by kanga.kvack.org (Postfix) with SMTP id 167956B004D
	for <linux-mm@kvack.org>; Fri, 16 Mar 2012 10:53:02 -0400 (EDT)
Message-Id: <20120316144028.036474157@chello.nl>
Date: Fri, 16 Mar 2012 15:40:28 +0100
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [RFC][PATCH 00/26] sched/numa
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Dan Smith <danms@us.ibm.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org


Hi All,

While the current scheduler has knowledge of the machine topology, including
NUMA (although there's room for improvement there as well [1]), it is
completely insensitive to which nodes a task's memory actually is on.

Current upstream task memory allocation prefers to use the node the task is
currently running on (unless explicitly told otherwise, see
mbind()/set_mempolicy()), and with the scheduler free to move the task about at
will, the task's memory can end up being spread all over the machine's nodes.

While the scheduler does a reasonable job of keeping short running tasks on a
single node (by means of simply not doing the cross-node migration very often),
it completely blows for long-running processes with a large memory footprint.

This patch-set aims at improving this situation. It does so by assigning a
preferred, or home, node to every process/thread_group. Memory allocation is
then directed by this preference instead of the node the task might actually be
running on momentarily. The load-balancer is also modified to prefer running
the task on its home-node, although not at the cost of letting CPUs go idle or
at the cost of execution fairness.

On top of this a new NUMA balancer is introduced, which can change a process'
home-node the hard way. This heavy process migration is driven by two factors:
either tasks are running away from their home-node, or memory is being
allocated away from the home-node. In either case, it tries to move processes
around to make the 'problem' go away.

The home-node migration handles both cpu and memory (anonymous only for now) in
an integrated fashion. The memory migration uses migrate-on-fault to avoid
doing a lot of work from the actual numa balancer kernl thread and only
migrates the active memory.

For processes that have more tasks than would fit on a node and which want to
split their activity in a useful fashion, the patch-set introduces two new
syscalls: sys_numa_tbind()/sys_numa_mbind(). These syscalls can be used to
create {thread}x{vma} groups which are then scheduled as a unit instead of the
entire process.

That said, its still early days and there's lots of improvements to make.

On to the actual patches...

The first two are generic cleanups:

  [01/26] mm, mpol: Re-implement check_*_range() using walk_page_range()
  [02/26] mm, mpol: Remove NUMA_INTERLEAVE_HIT

The second set is a rework of Lee Schermerhorn's Migrate-on-Fault patches [2]:

  [03/26] mm, mpol: add MPOL_MF_LAZY ...
  [04/26] mm, mpol: add MPOL_MF_NOOP
  [05/26] mm, mpol: Check for misplaced page
  [06/26] mm: Migrate misplaced page
  [07/26] mm: Handle misplaced anon pages
  [08/26] mm, mpol: Simplify do_mbind()

The third set implements the basic numa balancing:

  [09/26] sched, mm: Introduce tsk_home_node()
  [10/26] mm, mpol: Make mempolicy home-node aware
  [11/26] mm, mpol: Lazy migrate a process/vma
  [12/26] sched, mm: sched_{fork,exec} node assignment
  [13/26] sched: Implement home-node awareness
  [14/26] sched, numa: Numa balancer
  [15/26] sched, numa: Implement hotplug hooks
  [16/26] sched, numa: Abstract the numa_entity

The next three patches are a band-aid, Lai Jiangshan (and Paul McKenney) are
doing a proper implementation.. the reverts are me being lazy about fwd porting
my call_srcu() implementation.

  [17/26] srcu: revert1
  [18/26] srcu: revert2
  [19/26] srcu: Implement call_srcu()

The last bits implement the new syscalls:

  [20/26] mm, mpol: Introduce vma_dup_policy()
  [21/26] mm, mpol: Introduce vma_put_policy()
  [22/26] mm, mpol: Split and explose some mempolicy functions
  [23/26] sched, numa: Introduce sys_numa_{t,m}bind()
  [24/26] mm, mpol: Implement numa_group RSS accounting
  [25/26] sched, numa: Only migrate long-running entities
  [26/26] sched, numa: A few debug bits


And a few numbers...

On my WSM-EP (2 nodes, 6 cores/node, 2 thread/core), running 48 stream
benchmarks [3] (modified to use ~230MB and run long).

Without these patches it degrades into 50-50 local/remote memory accesses:

 Performance counter stats for 'sleep 2':

       259,668,750 r01b7@500b:u 		[100.00%]
       262,170,142 r01b7@200b:u                                                

       2.010446121 seconds time elapsed

With the patches there's a significant improvement in locality:

 Performance counter stats for 'sleep 2':

       496,860,345 r01b7@500b:u 		[100.00%]
        78,292,565 r01b7@200b:u                                                

       2.010707488 seconds time elapsed

(the perf events are a bit magical and not supported in an actual perf
 release -- but the first one is L3 misses to local dram, the second is
 L3 misses to remote dram)

If you look at those numbers you can also see that the sum is greater in the
second case, this means that we can service L3 misses at a higher rate, which
translates into a performance gain.

These numbers also show that while there's a marked improvement, there's still
some gain to be had. The current numa balancer is still somewhat fickle.

 ~ Peter


[1] - http://marc.info/?l=linux-kernel&m=130218515520540
      now that we have SD_OVERLAP it should be fairly easy to do.

[2] - http://markmail.org/message/mdwbcitql5ka4uws

[3] - https://asc.llnl.gov/computing_resources/purple/archive/benchmarks/memory/stream.tar 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
