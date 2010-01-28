Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id F09DB6004A8
	for <linux-mm@kvack.org>; Thu, 28 Jan 2010 14:56:39 -0500 (EST)
Message-Id: <20100128195627.373584000@alcatraz.americas.sgi.com>
Date: Thu, 28 Jan 2010 13:56:27 -0600
From: Robin Holt <holt@sgi.com>
Subject: [RFP 0/3] Make mmu_notifier_invalidate_range_start able to sleep.
Sender: owner-linux-mm@kvack.org
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This proposed set of patches is three parts.  The first changes
mmu_notifiers over to using srcu instead of rcu, the second move the
tlb_gather_mmu after the mmu_notifier_invalidate_range_start, and the
last allows the truncate call to zap_page_range work in an atomic context.

The atomic context is accomplished by unlocking the i_mmap_lock and then
making a second call into mmu_notifier_invalidate_range_start().

Signed-off-by: Robin Holt <holt@sgi.com>
Cc: Jack Steiner <steiner@sgi.com>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-mm@kvack.org

---

 include/linux/mm.h           |    2 -
 include/linux/mmu_notifier.h |   20 +++++++-----
 include/linux/srcu.h         |    2 +
 mm/fremap.c                  |    2 -
 mm/hugetlb.c                 |    2 -
 mm/memory.c                  |   36 ++++++++++++++++------
 mm/mmap.c                    |    6 +--
 mm/mmu_notifier.c            |   69 ++++++++++++++++++++++++++-----------------
 mm/mprotect.c                |    2 -
 mm/mremap.c                  |    2 -
 10 files changed, 90 insertions(+), 53 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
