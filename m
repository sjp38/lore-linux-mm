Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx189.postini.com [74.125.245.189])
	by kanga.kvack.org (Postfix) with SMTP id 7BD9E6B0044
	for <linux-mm@kvack.org>; Fri, 16 Mar 2012 14:25:45 -0400 (EDT)
Date: Fri, 16 Mar 2012 19:25:11 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [RFC] AutoNUMA alpha6
Message-ID: <20120316182511.GJ24602@redhat.com>
References: <20120316144028.036474157@chello.nl>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120316144028.036474157@chello.nl>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Dan Smith <danms@us.ibm.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, Mar 16, 2012 at 03:40:28PM +0100, Peter Zijlstra wrote:
> And a few numbers...

Could you try my two trivial benchmarks I sent on lkml too? That
should take less time than the effort you did to add those performance
numbers to perf. I use those benchmarks as a regression test for my
code. They exercise a more complex scenario than "sleep 2" so
supposedly the results will be more interesting.

You find both programs in this link:

http://lists.openwall.net/linux-kernel/2012/01/27/9

These are my results.

http://www.kernel.org/pub/linux/kernel/people/andrea/autonuma/autonuma_bench-20120126.pdf

I happened to have released the autonuma source yesterday on my git
tree:

http://git.kernel.org/?p=linux/kernel/git/andrea/aa.git;a=shortlog;h=refs/heads/autonuma

git clone --reference linux -b autonuma git://git.kernel.org/pub/scm/linux/kernel/git/andrea/aa.git

http://git.kernel.org/?p=linux/kernel/git/andrea/aa.git;a=patch;h=30ed50adf6cfe85f7feb12c4279359ec52f5f2cd;hp=c03cf0621ed5941f7a9c1e0a343d4df30dbfb7a1

It's a big monlithic patch, but I'll split it.

THP native migration isn't complete yet so it degrades more than it
should when comparing THP autonuma vs hard bind THP. But that can be
done later and it'll benefit move_pages or any other userland hard
binding too, not just the autonuma kernel side. I guess you need this
feature too.

The scanning rate must be tuned, it's possibly too fast as default
because all my benchmarks tends to be short lived. There's already
lots of tuning available in /sys/kernel/mm/autonuma .

There's lots of other tuning to facilitate testing the different
algorithms. By default the numa balancing decisions will keep the
process stuck in its own node, unless there's an idle cpu, but there's
a model to let it escape the node for load balancing/fairness reasons
(to be closer to the stock scheduler) by setting load_balance_strict
to zero (default is 1).

There's also a knuma_scand/working_set tweak to scan the working set
and not all memory (so only care about what's hot, if the app has a
ton of memory that isn't using in some node, that won't be accounted
anymore in the memory migration and CPU migration decisions).

There's no syscall or hint userland can give.

The migration doesn't happen during page fault. There's proper
knuma_migrated daemon per node. The daemon has per-node array of
page-lists. Then knuma_migrated0 is waken with some hysteresis, and
will pick pages that wants to go from node1 to node0, from node 2 to
node0 etc.. and it'll pick them in round robin fascion across all
nodes. That stops when the node0 is out of memory and the cache would
be shrunk or in most cases when there aren't more pages to
migrate. One of the missing features is to start balancing cache
around but I'll add that later and I've already reserved one slot in
the pgdat for that. All other numa_migratedN also runs, so we're
guaranteed to make progress when process A going from node0 to node1,
and process B going from node1 to node0.

All memory that isn't shared is migrated, that includes mapped
pagecache.

The basic logic is scheduler following the memory and memory following
CPU, until things converge.

I'm skeptical in general that any NUMA hinting syscall will be used by
anything except qemu and that's what motivated my design. Hopefully in
the future CPU vendors will provide us a better way to track memory
locality than what I'm doing right now in software. The cost is almost
unmeasurable (even if you disable the pmd mode). I'm afraid with virt
the cost could be higher because of the vmexists but virt is long
lived and a slower scanning rate for the memory layout info should be
ok.

Here also huge amount of improvements are possible. Hopefully it's not
too intrusive either.

I also wrote a threaded userland tool that can render visually at
>20frames per sec the status of the memory and shows the memory
migration (the ones I found were on python and with >8G of ram they
just can't deliver). I was going to try to make it per-process instead
of global before releasing it, that may give another speedup (or
slowdown I don't know for sure). It'll help explain what the code does
and see it in action. But for us echo 1 >/sys/kernel/mm/autonuma/debug
may be enough. Still the visual thing is cool and if done generically
it would be interesting. Ideally once it goes per process it should
show which CPU the process is running on too, not just where the
process memory is.

 arch/x86/include/asm/paravirt.h      |    2 -
 arch/x86/include/asm/pgtable.h       |   51 ++-
 arch/x86/include/asm/pgtable_types.h |   22 +-
 arch/x86/kernel/cpu/amd.c            |    4 +-
 arch/x86/kernel/cpu/common.c         |    4 +-
 arch/x86/kernel/setup_percpu.c       |    1 +
 arch/x86/mm/gup.c                    |    2 +-
 arch/x86/mm/numa.c                   |    9 +-
 fs/exec.c                            |    3 +
 include/asm-generic/pgtable.h        |   13 +
 include/linux/autonuma.h             |   41 +
 include/linux/autonuma_flags.h       |   62 ++
 include/linux/autonuma_sched.h       |   61 ++
 include/linux/autonuma_types.h       |   54 ++
 include/linux/huge_mm.h              |    7 +-
 include/linux/kthread.h              |    1 +
 include/linux/mm_types.h             |   29 +
 include/linux/mmzone.h               |    6 +
 include/linux/sched.h                |    4 +
 kernel/exit.c                        |    1 +
 kernel/fork.c                        |   36 +-
 kernel/kthread.c                     |   23 +
 kernel/sched/Makefile                |    3 +-
 kernel/sched/core.c                  |   13 +-
 kernel/sched/fair.c                  |   55 ++-
 kernel/sched/numa.c                  |  322 ++++++++
 kernel/sched/sched.h                 |   12 +
 mm/Kconfig                           |   13 +
 mm/Makefile                          |    1 +
 mm/autonuma.c                        | 1465 ++++++++++++++++++++++++++++++++++
 mm/huge_memory.c                     |   32 +-
 mm/memcontrol.c                      |    2 +-
 mm/memory.c                          |   36 +-
 mm/mempolicy.c                       |   15 +-
 mm/mmu_context.c                     |    2 +
 mm/page_alloc.c                      |   19 +
 36 files changed, 2376 insertions(+), 50 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
