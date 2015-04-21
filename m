Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com [209.85.212.169])
	by kanga.kvack.org (Postfix) with ESMTP id 40B75900015
	for <linux-mm@kvack.org>; Tue, 21 Apr 2015 06:41:27 -0400 (EDT)
Received: by wizk4 with SMTP id k4so133912401wiz.1
        for <linux-mm@kvack.org>; Tue, 21 Apr 2015 03:41:26 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id qs6si2475523wjc.68.2015.04.21.03.41.24
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 21 Apr 2015 03:41:24 -0700 (PDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [RFC PATCH 0/6] TLB flush multiple pages with a single IPI v3
Date: Tue, 21 Apr 2015 11:41:14 +0100
Message-Id: <1429612880-21415-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <andi@firstfloor.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

Changelog since V2
o Ensure TLBs are flushed before pages are freed		(mel)

Changelog since V1
o Structure and variable renaming				(hughd)
o Defer flushes even if the unmapping process is sleeping	(huged)
o Alternative sizing of structure				(peterz)
o Use GFP_KERNEL instead of GFP_ATOMIC, PF_MEMALLOC protects	(andi)
o Immediately flush dirty PTEs to avoid corruption		(mel)
o Further clarify docs on the required arch guarantees		(mel)

When unmapping pages it is necessary to flush the TLB. If that page was
accessed by another CPU then an IPI is used to flush the remote CPU. That
is a lot of IPIs if kswapd is scanning and unmapping >100K pages per second.

There already is a window between when a page is unmapped and when it is
TLB flushed. This series simply increases the window so multiple pages can
be flushed using a single IPI.

Patch 1 simply made the rest of the series easier to write as ftrace
	could identify all the senders of TLB flush IPIS.

Patch 2 collects a list of PFNs and sends one IPI to flush them all

Patch 3 uses more memory so further defer when the IPI gets sent

Patch 4 uses the same infrastructure as patch 2 to batch IPIs sent during
	page migration.

The performance impact is documented in the changelogs but in the optimistic
case on a 4-socket machine the full series reduces interrupts from 900K
interrupts/second to 60K interrupts/second.

 arch/x86/Kconfig                |   1 +
 arch/x86/include/asm/tlbflush.h |   2 +
 arch/x86/mm/tlb.c               |   1 +
 include/linux/init_task.h       |   8 +++
 include/linux/mm_types.h        |   1 +
 include/linux/rmap.h            |  13 ++--
 include/linux/sched.h           |  15 ++++
 include/trace/events/tlb.h      |   3 +-
 init/Kconfig                    |   8 +++
 kernel/fork.c                   |   7 ++
 kernel/sched/core.c             |   3 +
 mm/internal.h                   |  16 +++++
 mm/migrate.c                    |  27 +++++--
 mm/rmap.c                       | 151 ++++++++++++++++++++++++++++++++++++----
 mm/vmscan.c                     |  35 +++++++++-
 15 files changed, 267 insertions(+), 24 deletions(-)

-- 
2.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
