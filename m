Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f54.google.com (mail-wg0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id 2B5DA6B006C
	for <linux-mm@kvack.org>; Wed, 15 Apr 2015 06:43:03 -0400 (EDT)
Received: by wgin8 with SMTP id n8so42057223wgi.0
        for <linux-mm@kvack.org>; Wed, 15 Apr 2015 03:43:02 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id qr6si7390418wjc.114.2015.04.15.03.43.00
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 15 Apr 2015 03:43:00 -0700 (PDT)
From: Mel Gorman <mgorman@suse.de>
Subject: [RFC PATCH 0/4] TLB flush multiple pages with a single IPI
Date: Wed, 15 Apr 2015 11:42:52 +0100
Message-Id: <1429094576-5877-1-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Dave Hansen <dave.hansen@intel.com>, Andi Kleen <andi@firstfloor.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>

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

Last minute note: It occured to me just before sending that a TLB flush
	cannot be batched if the PTE was dirty at unmap time as the page
	lock is released before the TLB flush occurs. That allows IO to
	be started in parallel while writes can still take place through a
	cached entry. I decided not to delay the series as it's RFC and I
	want to see if there is interest in this. Note however that there
	is a difficult-to-hit potential corruption race here.

 arch/x86/Kconfig                |  1 +
 arch/x86/include/asm/tlbflush.h |  2 +
 arch/x86/mm/tlb.c               |  1 +
 include/linux/init_task.h       |  8 ++++
 include/linux/mm_types.h        |  1 +
 include/linux/rmap.h            |  3 ++
 include/linux/sched.h           | 20 ++++++++++
 include/trace/events/tlb.h      |  3 +-
 init/Kconfig                    |  5 +++
 kernel/fork.c                   |  5 +++
 kernel/sched/core.c             |  3 ++
 mm/internal.h                   | 16 ++++++++
 mm/migrate.c                    |  8 +++-
 mm/rmap.c                       | 85 ++++++++++++++++++++++++++++++++++++++++-
 mm/vmscan.c                     | 29 +++++++++++++-
 15 files changed, 186 insertions(+), 4 deletions(-)

-- 
2.1.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
