Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id A094D6B0273
	for <linux-mm@kvack.org>; Tue, 12 Jun 2018 03:16:54 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id t17-v6so13564528ply.13
        for <linux-mm@kvack.org>; Tue, 12 Jun 2018 00:16:54 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id a85-v6sor67321pfe.47.2018.06.12.00.16.53
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 12 Jun 2018 00:16:53 -0700 (PDT)
From: Nicholas Piggin <npiggin@gmail.com>
Subject: [RFC PATCH 3/3] powerpc/64s/radix: optimise TLB flush with precise TLB ranges in mmu_gather
Date: Tue, 12 Jun 2018 17:16:21 +1000
Message-Id: <20180612071621.26775-4-npiggin@gmail.com>
In-Reply-To: <20180612071621.26775-1-npiggin@gmail.com>
References: <20180612071621.26775-1-npiggin@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Nicholas Piggin <npiggin@gmail.com>, linuxppc-dev@lists.ozlabs.org, linux-arch@vger.kernel.org, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Minchan Kim <minchan@kernel.org>, Mel Gorman <mgorman@techsingularity.net>, Nadav Amit <nadav.amit@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>

Use the page_start and page_end fields of mmu_gather to implement more
precise TLB flushing. (start, end) covers the entire TLB and page
table range that has been invalidated, for architectures that do not
have explicit page walk cache management. page_start and page_end are
just for ranges that may have TLB entries.

A tlb_flush may have no pages in this range, but still requires PWC
to be flushed. That is handled properly.

This brings the number of tlbiel instructions required by a kernel
compile from 33M to 25M, most avoided from exec->shift_arg_pages.

Signed-off-by: Nicholas Piggin <npiggin@gmail.com>
---
 arch/powerpc/mm/tlb-radix.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/arch/powerpc/mm/tlb-radix.c b/arch/powerpc/mm/tlb-radix.c
index 67a6e86d3e7e..06452ad701cf 100644
--- a/arch/powerpc/mm/tlb-radix.c
+++ b/arch/powerpc/mm/tlb-radix.c
@@ -853,8 +853,11 @@ void radix__tlb_flush(struct mmu_gather *tlb)
 		else
 			radix__flush_all_mm(mm);
 	} else {
-		unsigned long start = tlb->start;
-		unsigned long end = tlb->end;
+		unsigned long start = tlb->page_start;
+		unsigned long end = tlb->page_end;
+
+		if (end < start)
+			end = start;
 
 		if (!tlb->need_flush_all)
 			radix__flush_tlb_range_psize(mm, start, end, psize);
-- 
2.17.0
