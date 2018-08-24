Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id ADCDA6B300B
	for <linux-mm@kvack.org>; Fri, 24 Aug 2018 09:55:01 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id w19-v6so4099560pfa.14
        for <linux-mm@kvack.org>; Fri, 24 Aug 2018 06:55:01 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id g188-v6sor2367304pfc.11.2018.08.24.06.55.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 24 Aug 2018 06:55:00 -0700 (PDT)
Date: Fri, 24 Aug 2018 06:54:58 -0700
From: Guenter Roeck <linux@roeck-us.net>
Subject: Re: [RFC PATCH 2/2] mm: mmu_notifier fix for tlb_end_vma (build
 failures)
Message-ID: <20180824135458.GA30345@roeck-us.net>
References: <20180823084709.19717-1-npiggin@gmail.com>
 <20180823084709.19717-3-npiggin@gmail.com>
 <20180824130722.GA31409@roeck-us.net>
 <20180824131026.GB11868@brain-police>
 <20180824132419.GA9983@roeck-us.net>
 <20180824133427.GC11868@brain-police>
 <20180824135048.GF11868@brain-police>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20180824135048.GF11868@brain-police>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Will Deacon <will.deacon@arm.com>
Cc: Nicholas Piggin <npiggin@gmail.com>, Peter Zijlstra <peterz@infradead.org>, torvalds@linux-foundation.org, luto@kernel.org, x86@kernel.org, bp@alien8.de, riel@surriel.com, jannh@google.com, ascannell@google.com, dave.hansen@intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, David Miller <davem@davemloft.net>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Michael Ellerman <mpe@ellerman.id.au>, linux-arch@vger.kernel.org, Palmer Dabbelt <palmer@sifive.com>, linux-riscv@lists.infradead.org

On Fri, Aug 24, 2018 at 02:50:48PM +0100, Will Deacon wrote:
> > 
> > Sorry, I was a bit quick of the mark there. You'll need a forward
> > declaration for the paramater type. Here it is with a commit message,
> > although still untested because I haven't got round to setting up a riscv
> > toolchain yet.
> > 

Still doesn't work.

CC      mm/memory.o
In file included from ./arch/riscv/include/asm/pgtable.h:26:0,
                 from ./include/linux/memremap.h:7,
		 from ./include/linux/mm.h:27,
		 from arch/riscv/mm/fault.c:23:
./arch/riscv/include/asm/tlb.h: In function a??tlb_flusha??:
./arch/riscv/include/asm/tlb.h:21:18: error:
	dereferencing pointer to incomplete type a??struct mmu_gathera?? flush_tlb_mm(tlb->mm);

Problem is that struct mmu_gather is dereferenced in tlb_flush().

Guenter

> > Will
> > 
> > --->8
> > 
> > From adb9be33d68320edcda80d540a97a647792894d2 Mon Sep 17 00:00:00 2001
> > From: Will Deacon <will.deacon@arm.com>
> > Date: Fri, 24 Aug 2018 14:33:48 +0100
> > Subject: [PATCH] riscv: tlb: Provide definition of tlb_flush() before
> >  including tlb.h
> > 
> > As of commit fd1102f0aade ("mm: mmu_notifier fix for tlb_end_vma"),
> > asm-generic/tlb.h now calls tlb_flush() from a static inline function,
> > so we need to make sure that it's declared before #including the
> > asm-generic header in the arch header.
> > 
> > Since tlb_flush() is a one-liner for riscv, we can define it before
> > including asm-generic/tlb.h as long as we provide a forward declaration
> > of struct mmu_gather.
> > 
> > Reported-by: Guenter Roeck <linux@roeck-us.net>
> > Signed-off-by: Will Deacon <will.deacon@arm.com>
> > ---
> >  arch/riscv/include/asm/tlb.h | 4 +++-
> >  1 file changed, 3 insertions(+), 1 deletion(-)
> > 
> > diff --git a/arch/riscv/include/asm/tlb.h b/arch/riscv/include/asm/tlb.h
> > index c229509288ea..a3d1380ad970 100644
> > --- a/arch/riscv/include/asm/tlb.h
> > +++ b/arch/riscv/include/asm/tlb.h
> > @@ -14,11 +14,13 @@
> >  #ifndef _ASM_RISCV_TLB_H
> >  #define _ASM_RISCV_TLB_H
> >  
> > -#include <asm-generic/tlb.h>
> > +struct mmu_gather;
> >  
> >  static inline void tlb_flush(struct mmu_gather *tlb)
> >  {
> >  	flush_tlb_mm(tlb->mm);
> 
> Bah, didn't spot the dereference so this won't work either. You basically
> just need to copy what I did for arm64 in d475fac95779.
> 
> Will
