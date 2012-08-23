Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx152.postini.com [74.125.245.152])
	by kanga.kvack.org (Postfix) with SMTP id 0F7E16B005D
	for <linux-mm@kvack.org>; Thu, 23 Aug 2012 14:01:49 -0400 (EDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH] mmu notifier srcu
Date: Thu, 23 Aug 2012 20:01:14 +0200
Message-Id: <1345744875-26224-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>, Sagi Grimberg <sagig@mellanox.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Haggai Eran <haggaie@mellanox.com>

Hi Andrew,

Now that the i_mmap_mutex and anon_vma.lock are mutexes, it's easier
to allow all mmu notifier methods to schedule. This is the first patch
that is required to allow that. Others will follow shortly.

This has been updated compared to previous versions, according to
Peter's suggestion to make the srcu global to save per-cpu memory
(originally there was a srcu object in every mmu notifier
structure). This slightly increases contention in the
mmu_notifier_unregister or exit_mmap paths. But that's by far not a
concern for KVM and hopefully for all other mmu notifier users.

Sagi Grimberg (1):
  mm: mmu_notifier: have mmu_notifiers use a global SRCU so they may
    safely schedule

 include/linux/mmu_notifier.h |    1 +
 mm/mmu_notifier.c            |   73 +++++++++++++++++++++++++++--------------
 2 files changed, 49 insertions(+), 25 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
