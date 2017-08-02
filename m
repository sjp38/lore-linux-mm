Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 494A26B0548
	for <linux-mm@kvack.org>; Wed,  2 Aug 2017 03:18:45 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id 16so41742265pgg.8
        for <linux-mm@kvack.org>; Wed, 02 Aug 2017 00:18:45 -0700 (PDT)
Received: from EX13-EDG-OU-002.vmware.com (ex13-edg-ou-002.vmware.com. [208.91.0.190])
        by mx.google.com with ESMTPS id 67si4838020pfv.603.2017.08.02.00.18.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 02 Aug 2017 00:18:43 -0700 (PDT)
From: Nadav Amit <namit@vmware.com>
Subject: [PATCH v6 0/7] fixes of TLB batching races
Date: Tue, 1 Aug 2017 17:08:11 -0700
Message-ID: <20170802000818.4760-1-namit@vmware.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: nadav.amit@gmail.com, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, Nadav Amit <namit@vmware.com>

It turns out that Linux TLB batching mechanism suffers from various races.
Races that are caused due to batching during reclamation were recently
handled by Mel and this patch-set deals with others. The more fundamental
issue is that concurrent updates of the page-tables allow for TLB flushes
to be batched on one core, while another core changes the page-tables.
This other core may assume a PTE change does not require a flush based on
the updated PTE value, while it is unaware that TLB flushes are still
pending.

This behavior affects KSM (which may result in memory corruption) and
MADV_FREE and MADV_DONTNEED (which may result in incorrect behavior). A
proof-of-concept can easily produce the wrong behavior of MADV_DONTNEED.
Memory corruption in KSM is harder to produce in practice, but was observed
by hacking the kernel and adding a delay before flushing and replacing the
KSM page.

Finally, there is also one memory barrier missing, which may affect
architectures with weak memory model.

v5 -> v6:
* Combining with Minchan Kim's patch set, adding ack's (Andrew)
* Minor: missing header, typos (Nadav)
* Renaming arch_generic_tlb_finish_mmu (Mel)

Michnan's v1 -> v2 (combined):
* TLB batching API separation core part from arch specific one (Mel)
* introduce mm_tlb_flush_nested (Mel)

v4 -> v5:
* Fixing embarrassing build mistake (0day)

v3 -> v4:
* Change function names to indicate they inc/dec and not set/clear
  (Sergey)
* Avoid additional barriers, and instead revert the patch that accessed
  mm_tlb_flush_pending without a lock (Mel)

v2 -> v3:
* Do not init tlb_flush_pending if it is not defined without (Sergey)
* Internalize memory barriers to mm_tlb_flush_pending (Minchan) 

v1 -> v2:
* Explain the implications of the implications of the race (Andrew)
* Mark the patch that address the race as stable (Andrew)
* Add another patch to clean the use of barriers (Andrew)

Minchan Kim (4):
  mm: refactoring TLB gathering API
  mm: make tlb_flush_pending global
  mm: fix MADV_[FREE|DONTNEED] TLB flush miss problem
  mm: fix KSM data corruption

Nadav Amit (3):
  mm: migrate: prevent racy access to tlb_flush_pending
  mm: migrate: fix barriers around tlb_flush_pending
  Revert "mm: numa: defer TLB flush for THP migration as long as
    possible"

 arch/arm/include/asm/tlb.h  | 11 ++++++--
 arch/ia64/include/asm/tlb.h |  8 ++++--
 arch/s390/include/asm/tlb.h | 17 +++++++-----
 arch/sh/include/asm/tlb.h   |  8 +++---
 arch/um/include/asm/tlb.h   | 13 ++++++---
 fs/proc/task_mmu.c          |  7 +++--
 include/asm-generic/tlb.h   |  7 ++---
 include/linux/mm_types.h    | 64 +++++++++++++++++++++++++++------------------
 kernel/fork.c               |  2 +-
 mm/debug.c                  |  4 +--
 mm/huge_memory.c            |  7 +++++
 mm/ksm.c                    |  3 ++-
 mm/memory.c                 | 41 ++++++++++++++++++++++++-----
 mm/migrate.c                |  6 -----
 mm/mprotect.c               |  4 +--
 15 files changed, 135 insertions(+), 67 deletions(-)

-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
