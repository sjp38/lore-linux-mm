Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 71CBC6B2FD0
	for <linux-mm@kvack.org>; Fri, 24 Aug 2018 09:07:25 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id w19-v6so4023435pfa.14
        for <linux-mm@kvack.org>; Fri, 24 Aug 2018 06:07:25 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p1-v6sor1066331pgg.51.2018.08.24.06.07.24
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 24 Aug 2018 06:07:24 -0700 (PDT)
Date: Fri, 24 Aug 2018 06:07:22 -0700
From: Guenter Roeck <linux@roeck-us.net>
Subject: Re: [RFC PATCH 2/2] mm: mmu_notifier fix for tlb_end_vma (build
 failures)
Message-ID: <20180824130722.GA31409@roeck-us.net>
References: <20180823084709.19717-1-npiggin@gmail.com>
 <20180823084709.19717-3-npiggin@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180823084709.19717-3-npiggin@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nicholas Piggin <npiggin@gmail.com>
Cc: Peter Zijlstra <peterz@infradead.org>, torvalds@linux-foundation.org, luto@kernel.org, x86@kernel.org, bp@alien8.de, will.deacon@arm.com, riel@surriel.com, jannh@google.com, ascannell@google.com, dave.hansen@intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, David Miller <davem@davemloft.net>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Michael Ellerman <mpe@ellerman.id.au>, linux-arch@vger.kernel.org, Palmer Dabbelt <palmer@sifive.com>, linux-riscv@lists.infradead.org

On Thu, Aug 23, 2018 at 06:47:09PM +1000, Nicholas Piggin wrote:
> The generic tlb_end_vma does not call invalidate_range mmu notifier,
> and it resets resets the mmu_gather range, which means the notifier
> won't be called on part of the range in case of an unmap that spans
> multiple vmas.
> 
> ARM64 seems to be the only arch I could see that has notifiers and
> uses the generic tlb_end_vma. I have not actually tested it.
> 
> Signed-off-by: Nicholas Piggin <npiggin@gmail.com>
> Acked-by: Will Deacon <will.deacon@arm.com>

This patch breaks riscv builds in mainline.

Building riscv:defconfig ... failed
--------------
Error log:
In file included from riscv/include/asm/tlb.h:17:0,
                 from arch/riscv/include/asm/pgalloc.h:19,
                 from riscv/mm/fault.c:30:
include/asm-generic/tlb.h: In function 'tlb_flush_mmu_tlbonly':
include/asm-generic/tlb.h:147:2: error: implicit declaration of function 'tlb_flush'

In file included from arch/riscv/include/asm/pgalloc.h:19:0,
		from arch/riscv/mm/fault.c:30:
arch/riscv/include/asm/tlb.h: At top level:
arch/riscv/include/asm/tlb.h:19:20: warning: conflicting types for 'tlb_flush'

Guenter
