Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id B29086B01F3
	for <linux-mm@kvack.org>; Tue, 27 Apr 2010 17:30:58 -0400 (EDT)
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH 0/3] Fix migration races in rmap_walk() V2
Date: Tue, 27 Apr 2010 22:30:49 +0100
Message-Id: <1272403852-10479-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
Cc: Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

After V1, it was clear that execve was still racing but eventually died
in an exec-related race. An additional part of the test was created that
hammers exec() to reproduce typically within 10 minutes rather than several
hours.  The problem was that the VMA is moved under lock but not the page
tables. Migration fails to remove the migration PTE from its new location and
a BUG is later triggered. The third patch in this series is a candidate fix.

Changelog since V1
  o Handle the execve race
  o Be sure that rmap_walk() releases the correct VMA lock
  o Hold the anon_vma lock for the address lookup and the page remap
  o Add reviewed-bys

There are a number of races between migration and other operations that mean a
migration PTE can be left behind. Broadly speaking, migration works by locking
a page, unmapping it, putting a migration PTE in place that looks like a swap
entry, copying the page and remapping the page removing the old migration PTE.
If a fault occurs, the faulting process waits until migration completes.

The problem is that there are some races that either allow migration PTEs to
be copied or a migration PTE to be left behind. Migration still completes and
the page is unlocked but later a fault will call migration_entry_to_page()
and BUG() because the page is not locked. This series aims to close some
of these races.

Patch 1 alters fork() to restart page table copying when a migration PTE is
	encountered.

Patch 2 has vma_adjust() acquire the anon_vma lock and makes rmap_walk()
	aware that VMAs on the chain may have different anon_vma locks that
	also need to be acquired.

Patch 3 notes that while a VMA is moved under the anon_vma lock, the page
	tables are not similarly protected. Where migration PTEs are
	encountered, they are cleaned up.

The reproduction case was as follows;

1. Run kernel compilation in a loop
2. Start three processes, each of which creates one mapping. The three stress
   different aspects of the problem. The operations they undertake are;
	a) Forks a hundred children, each of which faults the mapping
		Purpose: stress tests migration pte removal
	b) Forks a hundred children, each which punches a hole in the mapping
	   and faults what remains
		Purpose: stress test VMA manipulations during migration
	c) Forks a hundren children, each of which execs and calls echo
		Purpose: stress test the execve race
3. Constantly compact memory using /proc/sys/vm/compact_memory so migration
   is active all the time. In theory, you could also force this using
   sys_move_pages or memory hot-remove but it'd be nowhere near as easy
   to test.

At the time of sending, it has been running several hours without problems
with a workload that would fail within a few minutes without the patches.

 include/linux/migrate.h |    7 +++++++
 mm/ksm.c                |   22 ++++++++++++++++++++--
 mm/memory.c             |   25 +++++++++++++++----------
 mm/migrate.c            |    2 +-
 mm/mmap.c               |    6 ++++++
 mm/mremap.c             |   29 +++++++++++++++++++++++++++++
 mm/rmap.c               |   28 +++++++++++++++++++++++-----
 7 files changed, 101 insertions(+), 18 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
