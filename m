Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 29A6D6B2FE9
	for <linux-mm@kvack.org>; Fri, 24 Aug 2018 09:24:22 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id 191-v6so3138366pgb.23
        for <linux-mm@kvack.org>; Fri, 24 Aug 2018 06:24:22 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k5-v6sor2281277plt.105.2018.08.24.06.24.21
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 24 Aug 2018 06:24:21 -0700 (PDT)
Date: Fri, 24 Aug 2018 06:24:19 -0700
From: Guenter Roeck <linux@roeck-us.net>
Subject: Re: [RFC PATCH 2/2] mm: mmu_notifier fix for tlb_end_vma (build
 failures)
Message-ID: <20180824132419.GA9983@roeck-us.net>
References: <20180823084709.19717-1-npiggin@gmail.com>
 <20180823084709.19717-3-npiggin@gmail.com>
 <20180824130722.GA31409@roeck-us.net>
 <20180824131026.GB11868@brain-police>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20180824131026.GB11868@brain-police>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Will Deacon <will.deacon@arm.com>
Cc: Nicholas Piggin <npiggin@gmail.com>, Peter Zijlstra <peterz@infradead.org>, torvalds@linux-foundation.org, luto@kernel.org, x86@kernel.org, bp@alien8.de, riel@surriel.com, jannh@google.com, ascannell@google.com, dave.hansen@intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, David Miller <davem@davemloft.net>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Michael Ellerman <mpe@ellerman.id.au>, linux-arch@vger.kernel.org, Palmer Dabbelt <palmer@sifive.com>, linux-riscv@lists.infradead.org

On Fri, Aug 24, 2018 at 02:10:27PM +0100, Will Deacon wrote:
> On Fri, Aug 24, 2018 at 06:07:22AM -0700, Guenter Roeck wrote:
> > On Thu, Aug 23, 2018 at 06:47:09PM +1000, Nicholas Piggin wrote:
> > > The generic tlb_end_vma does not call invalidate_range mmu notifier,
> > > and it resets resets the mmu_gather range, which means the notifier
> > > won't be called on part of the range in case of an unmap that spans
> > > multiple vmas.
> > > 
> > > ARM64 seems to be the only arch I could see that has notifiers and
> > > uses the generic tlb_end_vma. I have not actually tested it.
> > > 
> > > Signed-off-by: Nicholas Piggin <npiggin@gmail.com>
> > > Acked-by: Will Deacon <will.deacon@arm.com>
> > 
> > This patch breaks riscv builds in mainline.
> 
> Looks very similar to the breakage we hit on arm64. diff below should fix
> it.
> 

Unfortunately it doesn't.

In file included from ./arch/riscv/include/asm/pgtable.h:26:0,
                 from ./include/linux/memremap.h:7,
                 from ./include/linux/mm.h:27,
                 from arch/riscv/mm/fault.c:23:
./arch/riscv/include/asm/tlb.h: In function a??tlb_flusha??:
./arch/riscv/include/asm/tlb.h:19:18: error: dereferencing pointer to incomplete type a??struct mmu_gathera??
  flush_tlb_mm(tlb->mm);
                  ^
./arch/riscv/include/asm/tlbflush.h:58:35: note: in definition of macro a??flush_tlb_mma??
  sbi_remote_sfence_vma(mm_cpumask(mm)->bits, 0, -1)

Note that reverting the offending patch does fix the problem,
so there is no secondary problem lurking around.

Guenter
