Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 7EDC56B026D
	for <linux-mm@kvack.org>; Tue, 12 Jun 2018 03:16:40 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id 39-v6so2114241ple.6
        for <linux-mm@kvack.org>; Tue, 12 Jun 2018 00:16:40 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k20-v6sor64702pfi.100.2018.06.12.00.16.39
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 12 Jun 2018 00:16:39 -0700 (PDT)
From: Nicholas Piggin <npiggin@gmail.com>
Subject: [RFC PATCH 0/3] couple of TLB flush optimisations
Date: Tue, 12 Jun 2018 17:16:18 +1000
Message-Id: <20180612071621.26775-1-npiggin@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Nicholas Piggin <npiggin@gmail.com>, linuxppc-dev@lists.ozlabs.org, linux-arch@vger.kernel.org, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@techsingularity.net>, Nadav Amit <nadav.amit@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>

I'm just looking around TLB flushing and noticed a few issues with
the core code. The first one seems pretty straightforward, unless I
missed something, but the TLB flush pattern after the revert seems
okay.

The second one might be a bit more interesting for other architectures
and the big comment in include/asm-generic/tlb.h and linked mail from
Linus gives some good context.

I suspect mmu notifiers should use this precise TLB range too, because
I don't see how they could care about the page table structure under
the mapping. Although I only use it in powerpc so far.

Comments?

Thanks,
Nick

Nicholas Piggin (3):
  Revert "mm: always flush VMA ranges affected by zap_page_range"
  mm: mmu_gather track of invalidated TLB ranges explicitly for more
    precise flushing
  powerpc/64s/radix: optimise TLB flush with precise TLB ranges in
    mmu_gather

 arch/powerpc/mm/tlb-radix.c |  7 +++++--
 include/asm-generic/tlb.h   | 27 +++++++++++++++++++++++++--
 mm/memory.c                 | 18 ++++--------------
 3 files changed, 34 insertions(+), 18 deletions(-)

-- 
2.17.0
