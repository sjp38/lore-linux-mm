Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 8A0D16B0055
	for <linux-mm@kvack.org>; Wed, 27 May 2009 07:12:23 -0400 (EDT)
From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH 0/2] Fixes for hugetlbfs-related problems on shared memory
Date: Wed, 27 May 2009 12:12:27 +0100
Message-Id: <1243422749-6256-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, stable@kernel.org, Linux Memory Management List <linux-mm@kvack.org>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, starlight@binnacle.cx, Eric B Munson <ebmunson@us.ibm.com>, Adam Litke <agl@us.ibm.com>, Andy Whitcroft <apw@canonical.com>, wli@movementarian.org
List-ID: <linux-mm.kvack.org>

The following two patches are required to fix problems reported by
starlight@binnacle.cx. The tests cases both involve two processes interacting
with shared memory segments backed by hugetlbfs.

Patch 1 fixes an x86-specific problem where regions sharing page tables
are not being reference counted properly. The page tables get freed early
resulting in bad PMD messages printed to the kernel log and the hugetlb
counters getting corrupted. Strictly speaking, this affects mainline but
the problem is masked by UNEVITABLE_LRU as it never leaves VM_LOCKED set for
hugetlbfs-backed mapping. This does affect the stable branch of 2.6.27 and
distributions based on that kernel such as SLES 11. This patch is required
for 2.6.27-stable and while it is optional for mainline, it should be merged
so that the stable branch does not contain patches that are not in mainline.

Patch 2 fixes a general hugetlbfs problem where it is using VM_SHARED instead
of VM_MAYSHARE to detect if the mapping was MAP_SHARED or MAP_PRIVATE. This
causes hugetlbfs to attempt reserving more pages than is required for
MAP_SHARED and mmap() fails when it should succeed. This patch is needed
for 2.6.30 and -stable. It rejects against 2.6.27.24 but the reject is
trivially resolved by changing the last VM_SHARED in hugetlb_reserve_pages()
to VM_MAYSHARE.

Starlight, if you are still watching, can you reconfirm that this patches
fix the problems you were having?

 arch/x86/mm/hugetlbpage.c |    6 +++++-
 mm/hugetlb.c              |   26 +++++++++++++-------------
 2 files changed, 18 insertions(+), 14 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
