Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com [209.85.212.170])
	by kanga.kvack.org (Postfix) with ESMTP id 0EF766B0032
	for <linux-mm@kvack.org>; Sat, 25 Apr 2015 13:45:47 -0400 (EDT)
Received: by widdi4 with SMTP id di4so50687711wid.0
        for <linux-mm@kvack.org>; Sat, 25 Apr 2015 10:45:46 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p8si25337679wjx.82.2015.04.25.10.45.44
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sat, 25 Apr 2015 10:45:45 -0700 (PDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 0/3] TLB flush multiple pages per IPI v4
Date: Sat, 25 Apr 2015 18:45:39 +0100
Message-Id: <1429983942-4308-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <andi@firstfloor.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

The big change here is that I dropped the patch that batches TLB flushes
from migration context. After V3, I realised that there are non-trivial
corner cases there that deserve treatment in their own series. It did not
help that I could not find a workload that was both migration and IPI
intensive. The common case for IPIs during reclaim is kswapd unmapping
pages which guarantees IPIs. In migration, at least some of the pages
being migrated will belong to the process itself.

The main issue is that migration cannot have any cached TLB entries after
migration completes. Once the migration PTE is removed then writes can happen
to that new page. The old TLB entry could see stale reads until it's flushed
which is different to the reclaim case. This is difficult to get around. We
cannot just unmap in advance because then there are no migration entries
to restore and there would be minor faults post-migration. We can't batch
restore the migration entries because the page lock must be held during
migration or BUG_ONs get triggered. Batching TLB flushes safely requires
a major rethink of how migration works so lets deal with reclaim first on
its own, preferably in the context of a workload that is both migration
and IPI intensive.

The patch that increased the batching size was also removed because there
is no advantage when TLBs are flushed before freeing the page. To increase
batching we would have to alter how many pages are isolated from the LRU
which would be a different patch series.

Most reviewed-bys had to be dropped as the patches changed too much to
preserve them.

Changelog since V3
o Drop batching of TLB flush from migration
o Redo how larger batching is managed
o Batch TLB flushes when writable entries exist

When unmapping pages it is necessary to flush the TLB. If that page was
accessed by another CPU then an IPI is used to flush the remote CPU. That
is a lot of IPIs if kswapd is scanning and unmapping >100K pages per second.

There already is a window between when a page is unmapped and when it is
TLB flushed. This series simply increases the window so multiple pages can
be flushed using a single IPI.

Patch 1 simply made the rest of the series easier to write as ftrace
	could identify all the senders of TLB flush IPIS.

Patch 2 collects a list of PFNs and sends one IPI to flush them all

Patch 3 tracks when there potentially are writable TLB entries that
	need to be batched differently

The performance impact is documented in the changelogs but in the optimistic
case on a 4-socket machine the full series reduces interrupts from 900K
interrupts/second to 60K interrupts/second.

 arch/x86/Kconfig                |   1 +
 arch/x86/include/asm/tlbflush.h |   2 +
 arch/x86/mm/tlb.c               |   1 +
 include/linux/init_task.h       |   8 +++
 include/linux/mm_types.h        |   1 +
 include/linux/rmap.h            |   3 +
 include/linux/sched.h           |  15 +++++
 include/trace/events/tlb.h      |   3 +-
 init/Kconfig                    |   8 +++
 kernel/fork.c                   |   5 ++
 kernel/sched/core.c             |   3 +
 mm/internal.h                   |  15 +++++
 mm/rmap.c                       | 119 +++++++++++++++++++++++++++++++++++++++-
 mm/vmscan.c                     |  45 ++++++++++++++-
 14 files changed, 224 insertions(+), 5 deletions(-)

-- 
2.3.5

Mel Gorman (3):
  x86, mm: Trace when an IPI is about to be sent
  mm: Send one IPI per CPU to TLB flush multiple pages that were
    recently unmapped
  mm: Defer flush of writable TLB entries

 arch/x86/Kconfig                |   1 +
 arch/x86/include/asm/tlbflush.h |   2 +
 arch/x86/mm/tlb.c               |   1 +
 include/linux/init_task.h       |   8 +++
 include/linux/mm_types.h        |   1 +
 include/linux/rmap.h            |   3 +
 include/linux/sched.h           |  15 +++++
 include/trace/events/tlb.h      |   3 +-
 init/Kconfig                    |   8 +++
 kernel/fork.c                   |   5 ++
 kernel/sched/core.c             |   3 +
 mm/internal.h                   |  15 +++++
 mm/rmap.c                       | 119 +++++++++++++++++++++++++++++++++++++++-
 mm/vmscan.c                     |  30 +++++++++-
 14 files changed, 210 insertions(+), 4 deletions(-)

-- 
2.3.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
