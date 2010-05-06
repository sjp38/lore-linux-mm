Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 0BDE36B02B2
	for <linux-mm@kvack.org>; Thu,  6 May 2010 11:33:14 -0400 (EDT)
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH 0/2] Fix migration races in rmap_walk() V6
Date: Thu,  6 May 2010 16:33:05 +0100
Message-Id: <1273159987-10167-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux.com>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

Patch 1 of this series is the biggest change. Instead of the trylock+retry
logic, it finds the "root" anon_vma and locks all anon_vmas encountered. As
long as walkers taking multiple locks use the same order, there is no
deadlock. Stress-tests based on compaction have been running a while with
these patches applied without problems.

Changelog since V5
  o Have rmap_walk take anon_vma locks in order starting from the "root"
  o Ensure that mm_take_all_locks locks VMAs in the same order

Changelog since V4
  o Switch back anon_vma locking to put bulk of locking in rmap_walk
  o Fix anon_vma lock ordering in exec vs migration race

Changelog since V3
  o Rediff against the latest upstream tree
  o Improve the patch changelog a little (thanks Peterz)

Changelog since V2
  o Drop fork changes
  o Avoid pages in temporary stacks during exec instead of migration pte
    lazy cleanup
  o Drop locking-related patch and replace with Rik's

Changelog since V1
  o Handle the execve race
  o Be sure that rmap_walk() releases the correct VMA lock
  o Hold the anon_vma lock for the address lookup and the page remap
  o Add reviewed-bys

Broadly speaking, migration works by locking a page, unmapping it, putting
a migration PTE in place that looks like a swap entry, copying the page and
remapping the page removing the old migration PTE before unlocking the page.
If a fault occurs, the faulting process waits until migration completes.

The problem is that there are some races that either allow migration PTEs
to be left left behind. Migration still completes and the page is unlocked
but later a fault will call migration_entry_to_page() and BUG() because the
page is not locked. It's not possible to just clean up the migration PTE
because the page it points to has been potentially freed and reused. This
series aims to close the races.

Patch 1 of this series is about the of locking of anon_vma in migration versus
vma_adjust. While I am not aware of any reproduction cases, it is potentially
racy. This patch is an alternative to Rik's "heavy lock" approach posted
at http://lkml.org/lkml/2010/5/3/155. With the patch, rmap_walk finds the
"root" anon_vma and starts locking from there, locking each new anon_vma
as it finds it. As long as the order is preserved, there is no deadlock.
In vma_adjust, the anon_vma locks are acquired under similar conditions
to 2.6.33 so that walkers will block until VMA changes are complete. The
rmap_walk changes potentially slows down migration and aspects of page
reclaim a little but they are the less important path.

Patch 2 of this series addresses the swapops bug reported that is a race
between migration and execve where pages get migrated from the temporary
stack before it is moved. To avoid migration PTEs being left behind,
a temporary VMA is put in place so that a migration PTE in either the
temporary stack or the relocated stack can be found.

The reproduction case for the races was as follows;

1. Run kernel compilation in a loop
2. Start four processes, each of which creates one mapping. The three stress
   different aspects of the problem. The operations they undertake are;
	a) Forks a hundred children, each of which faults the mapping
		Purpose: stress tests migration pte removal
	b) Forks a hundred children, each which punches a hole in the mapping
	   and faults what remains
		Purpose: stress test VMA manipulations during migration
	c) Forks a hundred children, each of which execs and calls echo
		Purpose: stress test the execve race
	d) Size the mapping to be 1.5 times physical memory. Constantly
	   memset it
		Purpose: stress swapping
3. Constantly compact memory using /proc/sys/vm/compact_memory so migration
   is active all the time. In theory, you could also force this using
   sys_move_pages or memory hot-remove but it'd be nowhere near as easy
   to test.

Compaction is the easiest way to trigger these bugs which is not going to
be in 2.6.34 but in theory the problem also affects memory hot-remove.

There were some concerns with patch 2 that performance would be impacted. To
check if this was the case I ran kernbench, aim9 and sysbench. AIM9 in
particular was of interest as it has an exec microbenchmark.

             kernbench-vanilla    fixraces-v5r1
Elapsed mean     103.40 ( 0.00%)   103.35 ( 0.05%)
Elapsed stddev     0.09 ( 0.00%)     0.13 (-55.72%)
User    mean     313.50 ( 0.00%)   313.15 ( 0.11%)
User    stddev     0.61 ( 0.00%)     0.20 (66.70%)
System  mean      55.50 ( 0.00%)    55.85 (-0.64%)
System  stddev     0.48 ( 0.00%)     0.15 (68.98%)
CPU     mean     356.25 ( 0.00%)   356.50 (-0.07%)
CPU     stddev     0.43 ( 0.00%)     0.50 (-15.47%)

Nothing special there and kernbench is fork+exec heavy. The patched kernel
is slightly faster on wall time but it's well within the noise. System time
is slightly slower but again, it's within the noise.

AIM9
                  aim9-vanilla    fixraces-v5r1
creat-clo     116813.86 ( 0.00%)  117980.34 ( 0.99%)
page_test     270923.33 ( 0.00%)  268668.56 (-0.84%)
brk_test     2551558.07 ( 0.00%) 2649450.00 ( 3.69%)
signal_test   279866.67 ( 0.00%)  279533.33 (-0.12%)
exec_test        226.67 ( 0.00%)     232.67 ( 2.58%)
fork_test       4261.91 ( 0.00%)    4110.98 (-3.67%)
link_test      53534.78 ( 0.00%)   54076.49 ( 1.00%)

So, here exec and fork aren't showing up major worries. exec is faster but
these tests can be so sensitive to starting conditions that I tend not to
read much into them unless there are major differences.

SYSBENCH
              sysbench-vanilla    fixraces-v5r1
           1 14177.73 ( 0.00%) 14218.41 ( 0.29%)
           2 27647.23 ( 0.00%) 27774.14 ( 0.46%)
           3 31395.69 ( 0.00%) 31499.95 ( 0.33%)
           4 49866.54 ( 0.00%) 49713.49 (-0.31%)
           5 49919.58 ( 0.00%) 49524.21 (-0.80%)
           6 49532.97 ( 0.00%) 49397.60 (-0.27%)
           7 49465.79 ( 0.00%) 49384.14 (-0.17%)
           8 49483.33 ( 0.00%) 49186.49 (-0.60%)

These figures also show no differences worth talking about.

While the extra allocation in patch 2 would appear to slow down exec somewhat,
it's not by any amount that matters. As it is in exec, it means that anon_vmas
have likely been freed very recently so the allocation will be cache-hot and
cpu-local. It is possible to special-case migration to avoid migrating pages
in the temporary stack, but fixing it in exec is a more maintainable approach.

 fs/exec.c            |   37 ++++++++++++++++++++--
 include/linux/rmap.h |    2 +
 mm/ksm.c             |   20 ++++++++++--
 mm/mmap.c            |   14 +++++++-
 mm/rmap.c            |   81 +++++++++++++++++++++++++++++++++++++++++++++-----
 5 files changed, 137 insertions(+), 17 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
