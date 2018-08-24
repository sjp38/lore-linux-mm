Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 53C8C6B2FD7
	for <linux-mm@kvack.org>; Fri, 24 Aug 2018 09:10:36 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id z25-v6so7029404iog.17
        for <linux-mm@kvack.org>; Fri, 24 Aug 2018 06:10:36 -0700 (PDT)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id o203-v6si5287943oif.198.2018.08.24.06.10.35
        for <linux-mm@kvack.org>;
        Fri, 24 Aug 2018 06:10:35 -0700 (PDT)
Date: Fri, 24 Aug 2018 14:10:27 +0100
From: Will Deacon <will.deacon@arm.com>
Subject: Re: [RFC PATCH 2/2] mm: mmu_notifier fix for tlb_end_vma (build
 failures)
Message-ID: <20180824131026.GB11868@brain-police>
References: <20180823084709.19717-1-npiggin@gmail.com>
 <20180823084709.19717-3-npiggin@gmail.com>
 <20180824130722.GA31409@roeck-us.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180824130722.GA31409@roeck-us.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Guenter Roeck <linux@roeck-us.net>
Cc: Nicholas Piggin <npiggin@gmail.com>, Peter Zijlstra <peterz@infradead.org>, torvalds@linux-foundation.org, luto@kernel.org, x86@kernel.org, bp@alien8.de, riel@surriel.com, jannh@google.com, ascannell@google.com, dave.hansen@intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, David Miller <davem@davemloft.net>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Michael Ellerman <mpe@ellerman.id.au>, linux-arch@vger.kernel.org, Palmer Dabbelt <palmer@sifive.com>, linux-riscv@lists.infradead.org

On Fri, Aug 24, 2018 at 06:07:22AM -0700, Guenter Roeck wrote:
> On Thu, Aug 23, 2018 at 06:47:09PM +1000, Nicholas Piggin wrote:
> > The generic tlb_end_vma does not call invalidate_range mmu notifier,
> > and it resets resets the mmu_gather range, which means the notifier
> > won't be called on part of the range in case of an unmap that spans
> > multiple vmas.
> > 
> > ARM64 seems to be the only arch I could see that has notifiers and
> > uses the generic tlb_end_vma. I have not actually tested it.
> > 
> > Signed-off-by: Nicholas Piggin <npiggin@gmail.com>
> > Acked-by: Will Deacon <will.deacon@arm.com>
> 
> This patch breaks riscv builds in mainline.

Looks very similar to the breakage we hit on arm64. diff below should fix
it.

Will

--->*

diff --git a/arch/riscv/include/asm/tlb.h b/arch/riscv/include/asm/tlb.h
index c229509288ea..5017060be63c 100644
--- a/arch/riscv/include/asm/tlb.h
+++ b/arch/riscv/include/asm/tlb.h
@@ -14,11 +14,11 @@
 #ifndef _ASM_RISCV_TLB_H
 #define _ASM_RISCV_TLB_H
 
-#include <asm-generic/tlb.h>
-
 static inline void tlb_flush(struct mmu_gather *tlb)
 {
 	flush_tlb_mm(tlb->mm);
 }
 
+#include <asm-generic/tlb.h>
+
 #endif /* _ASM_RISCV_TLB_H */
