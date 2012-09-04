Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx164.postini.com [74.125.245.164])
	by kanga.kvack.org (Postfix) with SMTP id 1A86A6B0062
	for <linux-mm@kvack.org>; Tue,  4 Sep 2012 04:41:59 -0400 (EDT)
From: Haggai Eran <haggaie@mellanox.com>
Subject: [PATCH V1 0/2] Enable clients to schedule in mmu_notifier methods
Date: Tue,  4 Sep 2012 11:41:19 +0300
Message-Id: <1346748081-1652-1-git-send-email-haggaie@mellanox.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrea Arcangeli <aarcange@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>, Haggai Eran <haggaie@mellanox.com>, Shachar Raindel <raindel@mellanox.com>, Sagi Grimberg <sagig@mellanox.com>, Or Gerlitz <ogerlitz@mellanox.com>

> The following short patch series completes the support for allowing clients to
> sleep in mmu notifiers (specifically in invalidate_page and
> invalidate_range_start/end), adding on the work done by Andrea Arcangeli and
> Sagi Grimberg in http://marc.info/?l=linux-mm&m=133113297028676&w=3
>
> This patchset is a preliminary step towards on-demand paging design to be
> added to the Infiniband stack. Our goal is to avoid pinning pages in
> memory regions registered for IB communication, so we need to get
> notifications for invalidations on such memory regions, and stop the hardware
> from continuing its access to the invalidated pages. The hardware operation
> that flushes the page tables can block, so we need to sleep until the hardware
> is guaranteed not to access these pages anymore.

The first patch moves the mentioned notifier functions out of the PTL, and the
second patch changes the change_pte notification to stop calling
invalidate_page as a default.

Regards,
Haggai Eran

Changes from V0:
- Fixed a bug in patch 1 that prevented compilation without MMU notifiers.
- Dropped the patches 2 and 3 that were moving tlb_gather_mmu calls.
- Added a patch to handle invalidate_page being called from change_pte.

Haggai Eran (1):
  mm: Wrap calls to set_pte_at_notify with invalidate_range_start and
    invalidate_range_end

Sagi Grimberg (1):
  mm: Move all mmu notifier invocations to be done outside the PT lock

 include/linux/mmu_notifier.h | 47 --------------------------------------------
 kernel/events/uprobes.c      |  2 ++
 mm/filemap_xip.c             |  4 +++-
 mm/huge_memory.c             | 32 ++++++++++++++++++++++++------
 mm/hugetlb.c                 | 15 ++++++++------
 mm/ksm.c                     | 13 ++++++++++--
 mm/memory.c                  |  9 ++++++++-
 mm/mmu_notifier.c            |  6 ------
 mm/rmap.c                    | 27 ++++++++++++++++++-------
 9 files changed, 79 insertions(+), 76 deletions(-)

-- 
1.7.11.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
