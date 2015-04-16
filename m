Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
	by kanga.kvack.org (Postfix) with ESMTP id BD1C06B0038
	for <linux-mm@kvack.org>; Thu, 16 Apr 2015 06:22:51 -0400 (EDT)
Received: by widdi4 with SMTP id di4so91675282wid.0
        for <linux-mm@kvack.org>; Thu, 16 Apr 2015 03:22:51 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id cz1si31192735wib.28.2015.04.16.03.22.49
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 16 Apr 2015 03:22:50 -0700 (PDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [RFC PATCH 0/4] TLB flush multiple pages with a single IPI v2
Date: Thu, 16 Apr 2015 11:22:42 +0100
Message-Id: <1429179766-26711-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Minchan Kim <minchan@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <andi@firstfloor.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

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

 arch/x86/Kconfig                |  1 +
 arch/x86/include/asm/tlbflush.h |  2 +
 arch/x86/mm/tlb.c               |  1 +
 include/linux/init_task.h       |  8 ++++
 include/linux/mm_types.h        |  1 +
 include/linux/rmap.h            |  3 ++
 include/linux/sched.h           | 15 +++++++
 include/trace/events/tlb.h      |  3 +-
 init/Kconfig                    |  8 ++++
 kernel/fork.c                   |  7 +++
 kernel/sched/core.c             |  3 ++
 mm/internal.h                   | 16 +++++++
 mm/migrate.c                    |  6 ++-
 mm/rmap.c                       | 99 ++++++++++++++++++++++++++++++++++++++++-
 mm/vmscan.c                     | 33 +++++++++++++-
 15 files changed, 201 insertions(+), 5 deletions(-)

-- 
2.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
