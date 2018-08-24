Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 3BD5E6B2FE5
	for <linux-mm@kvack.org>; Fri, 24 Aug 2018 09:50:58 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id 20-v6so7593145ois.21
        for <linux-mm@kvack.org>; Fri, 24 Aug 2018 06:50:58 -0700 (PDT)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id y9-v6si5624852oia.191.2018.08.24.06.50.56
        for <linux-mm@kvack.org>;
        Fri, 24 Aug 2018 06:50:57 -0700 (PDT)
Date: Fri, 24 Aug 2018 14:50:48 +0100
From: Will Deacon <will.deacon@arm.com>
Subject: Re: [RFC PATCH 2/2] mm: mmu_notifier fix for tlb_end_vma (build
 failures)
Message-ID: <20180824135048.GF11868@brain-police>
References: <20180823084709.19717-1-npiggin@gmail.com>
 <20180823084709.19717-3-npiggin@gmail.com>
 <20180824130722.GA31409@roeck-us.net>
 <20180824131026.GB11868@brain-police>
 <20180824132419.GA9983@roeck-us.net>
 <20180824133427.GC11868@brain-police>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20180824133427.GC11868@brain-police>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Guenter Roeck <linux@roeck-us.net>
Cc: Nicholas Piggin <npiggin@gmail.com>, Peter Zijlstra <peterz@infradead.org>, torvalds@linux-foundation.org, luto@kernel.org, x86@kernel.org, bp@alien8.de, riel@surriel.com, jannh@google.com, ascannell@google.com, dave.hansen@intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, David Miller <davem@davemloft.net>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Michael Ellerman <mpe@ellerman.id.au>, linux-arch@vger.kernel.org, Palmer Dabbelt <palmer@sifive.com>, linux-riscv@lists.infradead.org

On Fri, Aug 24, 2018 at 02:34:27PM +0100, Will Deacon wrote:
> On Fri, Aug 24, 2018 at 06:24:19AM -0700, Guenter Roeck wrote:
> > On Fri, Aug 24, 2018 at 02:10:27PM +0100, Will Deacon wrote:
> > > On Fri, Aug 24, 2018 at 06:07:22AM -0700, Guenter Roeck wrote:
> > > > On Thu, Aug 23, 2018 at 06:47:09PM +1000, Nicholas Piggin wrote:
> > > > > The generic tlb_end_vma does not call invalidate_range mmu notifier,
> > > > > and it resets resets the mmu_gather range, which means the notifier
> > > > > won't be called on part of the range in case of an unmap that spans
> > > > > multiple vmas.
> > > > > 
> > > > > ARM64 seems to be the only arch I could see that has notifiers and
> > > > > uses the generic tlb_end_vma. I have not actually tested it.
> > > > > 
> > > > > Signed-off-by: Nicholas Piggin <npiggin@gmail.com>
> > > > > Acked-by: Will Deacon <will.deacon@arm.com>
> > > > 
> > > > This patch breaks riscv builds in mainline.
> > > 
> > > Looks very similar to the breakage we hit on arm64. diff below should fix
> > > it.
> > > 
> > 
> > Unfortunately it doesn't.
> > 
> > In file included from ./arch/riscv/include/asm/pgtable.h:26:0,
> >                  from ./include/linux/memremap.h:7,
> >                  from ./include/linux/mm.h:27,
> >                  from arch/riscv/mm/fault.c:23:
> > ./arch/riscv/include/asm/tlb.h: In function a??tlb_flusha??:
> > ./arch/riscv/include/asm/tlb.h:19:18: error: dereferencing pointer to incomplete type a??struct mmu_gathera??
> >   flush_tlb_mm(tlb->mm);
> >                   ^
> 
> Sorry, I was a bit quick of the mark there. You'll need a forward
> declaration for the paramater type. Here it is with a commit message,
> although still untested because I haven't got round to setting up a riscv
> toolchain yet.
> 
> Will
> 
> --->8
> 
> From adb9be33d68320edcda80d540a97a647792894d2 Mon Sep 17 00:00:00 2001
> From: Will Deacon <will.deacon@arm.com>
> Date: Fri, 24 Aug 2018 14:33:48 +0100
> Subject: [PATCH] riscv: tlb: Provide definition of tlb_flush() before
>  including tlb.h
> 
> As of commit fd1102f0aade ("mm: mmu_notifier fix for tlb_end_vma"),
> asm-generic/tlb.h now calls tlb_flush() from a static inline function,
> so we need to make sure that it's declared before #including the
> asm-generic header in the arch header.
> 
> Since tlb_flush() is a one-liner for riscv, we can define it before
> including asm-generic/tlb.h as long as we provide a forward declaration
> of struct mmu_gather.
> 
> Reported-by: Guenter Roeck <linux@roeck-us.net>
> Signed-off-by: Will Deacon <will.deacon@arm.com>
> ---
>  arch/riscv/include/asm/tlb.h | 4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)
> 
> diff --git a/arch/riscv/include/asm/tlb.h b/arch/riscv/include/asm/tlb.h
> index c229509288ea..a3d1380ad970 100644
> --- a/arch/riscv/include/asm/tlb.h
> +++ b/arch/riscv/include/asm/tlb.h
> @@ -14,11 +14,13 @@
>  #ifndef _ASM_RISCV_TLB_H
>  #define _ASM_RISCV_TLB_H
>  
> -#include <asm-generic/tlb.h>
> +struct mmu_gather;
>  
>  static inline void tlb_flush(struct mmu_gather *tlb)
>  {
>  	flush_tlb_mm(tlb->mm);

Bah, didn't spot the dereference so this won't work either. You basically
just need to copy what I did for arm64 in d475fac95779.

Will
