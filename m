Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f45.google.com (mail-wg0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id 5546D6B0032
	for <linux-mm@kvack.org>; Mon,  8 Jun 2015 08:51:00 -0400 (EDT)
Received: by wgv5 with SMTP id 5so102579596wgv.1
        for <linux-mm@kvack.org>; Mon, 08 Jun 2015 05:50:59 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id wo1si4931339wjc.207.2015.06.08.05.50.58
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 08 Jun 2015 05:50:58 -0700 (PDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 0/3] TLB flush multiple pages per IPI v5
Date: Mon,  8 Jun 2015 13:50:51 +0100
Message-Id: <1433767854-24408-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <andi@firstfloor.org>, H Peter Anvin <hpa@zytor.com>, Ingo Molnar <mingo@kernel.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

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
TLB flushed. This series simply increases the window so multiple pages
can be flushed using a single IPI. This *should* be safe or the kernel is
hosed already but I've cc'd the x86 maintainers and some of the Intel folk
for comment.

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
 mm/vmscan.c                     |  30 +++++++++-
 14 files changed, 210 insertions(+), 4 deletions(-)

-- 
2.3.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
