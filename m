Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f44.google.com (mail-wg0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id 5BBBF900015
	for <linux-mm@kvack.org>; Tue,  9 Jun 2015 13:40:05 -0400 (EDT)
Received: by wgez8 with SMTP id z8so18808150wge.0
        for <linux-mm@kvack.org>; Tue, 09 Jun 2015 10:40:05 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id cb3si12584909wjc.44.2015.06.09.10.32.03
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 09 Jun 2015 10:32:04 -0700 (PDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 0/3] TLB flush multiple pages per IPI v6
Date: Tue,  9 Jun 2015 18:31:54 +0100
Message-Id: <1433871118-15207-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <andi@firstfloor.org>, H Peter Anvin <hpa@zytor.com>, Ingo Molnar <mingo@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

Changelog since V5
o Split series to first do a full TLB flush and then targetting flushing

Changelog since V4
o Rebase to 4.1-rc6

Changelog since V3
o Drop batching of TLB flush from migration
o Redo how larger batching is managed
o Batch TLB flushes when writable entries exist

When unmapping pages it is necessary to flush the TLB. If that page was
accessed by another CPU then an IPI is used to flush the remote CPU. That
is a lot of IPIs if kswapd is scanning and unmapping >100K pages per second.

There already is a window between when a page is unmapped and when it is
TLB flushed. This series ses the window so multiple pages can be flushed
using a single IPI. This should be safe or the kernel is hosed already.

Patch 1 simply made the rest of the series easier to write as ftrace
	could identify all the senders of TLB flush IPIS.

Patch 2 tracks what CPUs potentially map a PFN and then sends an IPI
	to flush the entire TLB.

Patch 3 tracks when there potentially are writable TLB entries that
	need to be batched differently

Patch 4 notes that a full TLB flush could clear active entries and
	incur a penalty in the near future while the TLB is being
	refilled. The IPI flushes just the individual PFNs which
	incurs a direct cost to avoid an indirect cost.

The performance impact is documented in the changelogs but in the optimistic
case on a 4-socket machine the full series reduces interrupts from 900K
interrupts/second to 60K interrupts/second.

 arch/x86/Kconfig                |   1 +
 arch/x86/include/asm/tlbflush.h |   2 +
 arch/x86/mm/tlb.c               |   1 +
 include/linux/mm_types.h        |   1 +
 include/linux/rmap.h            |   3 +
 include/linux/sched.h           |  31 +++++++++++
 include/trace/events/tlb.h      |   3 +-
 init/Kconfig                    |   8 +++
 kernel/fork.c                   |   5 ++
 kernel/sched/core.c             |   3 +
 mm/internal.h                   |  15 +++++
 mm/rmap.c                       | 118 +++++++++++++++++++++++++++++++++++++++-
 mm/vmscan.c                     |  33 ++++++++++-
 13 files changed, 220 insertions(+), 4 deletions(-)

-- 
2.3.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
