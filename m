Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id CECEB6B01EE
	for <linux-mm@kvack.org>; Mon, 26 Apr 2010 18:37:47 -0400 (EDT)
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH 0/2] Fix migration races in rmap_walk()
Date: Mon, 26 Apr 2010 23:37:56 +0100
Message-Id: <1272321478-28481-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>
Cc: Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

After digging around a lot, I believe the following two patches are the
best way to close the race that allows a migration PTE to be left behind
triggering a BUG check in migration_entry_to_page().

Patch one alters has fork() wait for migration to complete. Patch two has
vma_adjust() acquire the anon_vma lock it is aware of and makes rmap_walk()
aware that different VMAs can be encountered during the walk.

I dropped the use of the seq counter because there were still races in
place. For example, while the seq counter would catch when vma_adjust()
and rmap_walk() were looking at the same VMA, there was still insufficient
protection on the VMA list being modified.

The reproduction case was as follows;

1. Run kernel compilation in a loop
2. Start two processes that repeatedly fork()ed and manipulated mappings
3. Constantly compact memory using /proc/sys/vm/compact_memory
4. Optionally add/remove swap

With these two patches applied, I was unable to trigger the bug check
in migration_entry_to_page() but it would be really helpful if Rik could
comment on the anon_vma locking requirements and whether patch 2 is 100%
safe or not.  The tests have only been running 8 hours but I'm posting now
anyway and will see how it survives running for a few days.

The other issues raised about expand_downwards will need to be re-examined to
see if they still exist and transparent hugepage support will need further
thinking to see if split_huge_page() can deal with these situations.

 mm/ksm.c    |   13 +++++++++++++
 mm/memory.c |   25 ++++++++++++++++---------
 mm/mmap.c   |    6 ++++++
 mm/rmap.c   |   23 ++++++++++++++++++++---
 4 files changed, 55 insertions(+), 12 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
