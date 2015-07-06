Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id B4BE92802AF
	for <linux-mm@kvack.org>; Mon,  6 Jul 2015 09:40:03 -0400 (EDT)
Received: by wiclp1 with SMTP id lp1so21570725wic.0
        for <linux-mm@kvack.org>; Mon, 06 Jul 2015 06:40:03 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id gk19si30260799wjc.187.2015.07.06.06.40.01
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 06 Jul 2015 06:40:02 -0700 (PDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [PATCH 0/4] TLB flush multiple pages per IPI v7
Date: Mon,  6 Jul 2015 14:39:52 +0100
Message-Id: <1436189996-7220-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Ingo Molnar <mingo@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

This is hopefully the final version that was agreed on. Ingo, you had sent
an ack but I had to add a new arch helper after that for accounting purposes
and there was a new patch added for the swap cluster suggestion. With the
changes I did not include the ack just in case it was no longer valid.

Changelog since V6
o Rebase to v4.2-rc1
o Fix TLB flush counter accounting
o Drop dynamic allocation patch, no benefit and very messy
o Drop targetting flushing, expected to be of dubious merit
o Increase swap cluster max

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

Patch 4 increases SWAP_CLUSTER_MAX to further batch flushes

The performance impact is documented in the changelogs but in the optimistic
case on a 4-socket machine the full series reduces interrupts from 900K
interrupts/second to 60K interrupts/second.

 arch/x86/Kconfig                |   1 +
 arch/x86/include/asm/tlbflush.h |   6 +++
 arch/x86/mm/tlb.c               |   1 +
 include/linux/mm_types.h        |   1 +
 include/linux/rmap.h            |   3 ++
 include/linux/sched.h           |  23 ++++++++
 include/linux/swap.h            |   2 +-
 include/trace/events/tlb.h      |   3 +-
 init/Kconfig                    |  10 ++++
 mm/internal.h                   |  15 ++++++
 mm/rmap.c                       | 117 +++++++++++++++++++++++++++++++++++++++-
 mm/vmscan.c                     |  30 ++++++++++-
 12 files changed, 207 insertions(+), 5 deletions(-)

-- 
2.3.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
