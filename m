Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 323F58D0039
	for <linux-mm@kvack.org>; Tue, 22 Feb 2011 20:52:37 -0500 (EST)
From: Andi Kleen <andi@firstfloor.org>
Subject: Fix NUMA problems in transparent hugepages v2
Date: Tue, 22 Feb 2011 17:51:54 -0800
Message-Id: <1298425922-23630-1-git-send-email-andi@firstfloor.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

v2: I dropped the controversal KSM changes and fixed
the interleaving bug. Now it's purely for transparent huge pages.

The current transparent hugepages daemon can mess up local
memory affinity on NUMA systems. When it copies memory to a 
huge page it does not necessarily keep it on the same
node as the local allocations.

While fixing this I also found some more related issues:
- The NUMA policy interleaving for THP was using the small
page size, not the large parse size.
- THP copies also did not preserve the local node
- The accounting for local/remote allocations in the daemon
was misleading.
- There were no VM statistics counters for THP, which made it 
impossible to analyze.
 
At least some of the bug fixes are 2.6.38 candidates IMHO
because some of the NUMA problems are pretty bad. In some workloads
this can cause performance problems. 

What can be delayed are GFP_OTHERNODE and the statistics changes.

Git tree:

  git://git.kernel.org/pub/scm/linux/kernel/git/ak/linux-misc-2.6.git thp-numa

Andi Kleen (8):
      Fix interleaving for transparent hugepages v2
      Change alloc_pages_vma to pass down the policy node for local policy
      Add alloc_page_vma_node
      Preserve original node for transparent huge page copies
      Use correct numa policy node for transparent hugepages
      Add __GFP_OTHER_NODE flag
      Use GFP_OTHER_NODE for transparent huge pages
      Add VM counters for transparent hugepages

 include/linux/gfp.h    |   13 ++++++++---
 include/linux/vmstat.h |   11 ++++++++-
 mm/huge_memory.c       |   49 +++++++++++++++++++++++++++++++++--------------
 mm/mempolicy.c         |   16 +++++++-------
 mm/page_alloc.c        |    2 +-
 mm/vmstat.c            |   17 ++++++++++++++-
 6 files changed, 76 insertions(+), 32 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
