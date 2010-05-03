Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 5C192600794
	for <linux-mm@kvack.org>; Mon,  3 May 2010 12:20:09 -0400 (EDT)
Date: Mon, 3 May 2010 12:17:43 -0400
From: Rik van Riel <riel@redhat.com>
Subject: [PATCH 0/2] Fix migration races in rmap_walk() V4
Message-ID: <20100503121743.653e5ecc@annuminas.surriel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: torvalds@linux-foundation.org, Mel Gorman <mel@csn.ul.ie>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, Christoph Lameter <cl@linux.com>
List-ID: <linux-mm.kvack.org>

Andrew, I'm posting this version since Mel is out today and Andrea and I
would really like to get this fixed before 2.6.34 :)

Here is Mel's 0/2 text, plus my changelog update:

The sloppy cleanup of migration PTEs in V2 was to no ones liking, the fork()
change was unnecessary and Rik devised a locking scheme for anon_vma that
was more robust for transparent hugepage support than was purposed in V2.

Andrew, patch one of this series is about the correctness of locking of
anon_vma with respect to migration. While I am not aware of any reproduction
cases, it is potentially racy. Rik will probably release another versions
so I'm not expecting this one to be picked up but I'm including it for
completeness.

Patch two of this series addresses the swapops bug reported that is a race
between migration due to compaction and execve where pages get migrated from
the temporary stack before it is moved. Technically, it would be best if the
anon_vma lock was held while the temporary stack is moved but it would make
exec significantly more complex, particularly in move_page_tables to handle
a corner case in migration. I don't think adding complexity is justified. If
there are no objections, please pick it up and place it between the patches

	mmmigration-allow-the-migration-of-pageswapcache-pages.patch
	mm-allow-config_migration-to-be-set-without-config_numa-or-memory-hot-remove.patch

Unfortunately, I'll be offline for a few days but should be back online
Tuesday.

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

Patch 1 notes that with the anon_vma changes, taking one lock is not
	necessarily enough to guard against changes in all VMAs on a list.
	It introduces a new lock to allow taking the locks on all anon_vmas
	to exclude migration from VMA changes.

Patch 2 notes that while a VMA is moved under the anon_vma lock, the page
	tables are not similarly protected. To avoid migration PTEs being left
	behind, pages within a temporary stack are simply not migrated.

The reproduction case was as follows;

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

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
