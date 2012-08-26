Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx124.postini.com [74.125.245.124])
	by kanga.kvack.org (Postfix) with SMTP id F364D6B0078
	for <linux-mm@kvack.org>; Sun, 26 Aug 2012 06:12:14 -0400 (EDT)
From: Haggai Eran <haggaie@mellanox.com>
Subject: [PATCH 0/3] Enable clients to schedule in mmu_notifier methods
Date: Sun, 26 Aug 2012 13:11:36 +0300
Message-Id: <1345975899-2236-1-git-send-email-haggaie@mellanox.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrea Arcangeli <aarcange@redhat.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Sagi Grimberg <sagig@mellanox.com>, Or Gerlitz <ogerlitz@mellanox.com>, Haggai Eran <haggaie@mellanox.com>

The following short patch series completes the support for allowing clients to
sleep in mmu notifiers (specifically in invalidate_page and
invalidate_range_start/end), adding on the work done by Andrea Arcangeli and
Sagi Grimberg in http://marc.info/?l=linux-mm&m=133113297028676&w=3

This patchset is a preliminary step towards on-demand paging design to be
added to the Infiniband stack. Our goal is to avoid pinning pages in
memory regions registered for IB communication, so we need to get
notifications for invalidations on such memory regions, and stop the hardware
from continuing its access to the invalidated pages. The hardware operation
that flushes the page tables can block, so we need to sleep until the hardware
is guaranteed not to access these pages anymore.

The first patch moves the mentioned notifier functions out of the PTL, and the
other two patches prevent notifiers from sleeping between calls to
tlb_gather_mmu and tlb_flush_mmu. I believe that Peter Zijlstra
made a comment saying that patch 2 isn't needed anymore. For the same reason
patch 3 would no longer be necessary. Let's discuss this now...

Regards,
Haggai Eran

Sagi Grimberg (3):
  mm: Move all mmu notifier invocations to be done outside the PT lock
  mm: Move the tlb flushing into free_pgtables
  mm: Move the tlb flushing inside of unmap vmas

 include/linux/mmu_notifier.h | 48 --------------------------------------------
 mm/filemap_xip.c             |  4 +++-
 mm/huge_memory.c             | 32 +++++++++++++++++++++++------
 mm/hugetlb.c                 | 15 ++++++++------
 mm/memory.c                  | 25 +++++++++++++----------
 mm/mmap.c                    |  7 -------
 mm/rmap.c                    | 27 ++++++++++++++++++-------
 7 files changed, 72 insertions(+), 86 deletions(-)

-- 
1.7.11.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
