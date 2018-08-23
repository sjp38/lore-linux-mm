Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7DFEC6B2A5E
	for <linux-mm@kvack.org>; Thu, 23 Aug 2018 09:41:10 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id p11-v6so4793755oih.17
        for <linux-mm@kvack.org>; Thu, 23 Aug 2018 06:41:10 -0700 (PDT)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id o132-v6si3151107oih.401.2018.08.23.06.41.09
        for <linux-mm@kvack.org>;
        Thu, 23 Aug 2018 06:41:09 -0700 (PDT)
Date: Thu, 23 Aug 2018 14:41:05 +0100
From: Will Deacon <will.deacon@arm.com>
Subject: Re: [RFC PATCH 2/2] mm: mmu_notifier fix for tlb_end_vma
Message-ID: <20180823134104.GD1496@brain-police>
References: <20180823084709.19717-1-npiggin@gmail.com>
 <20180823084709.19717-3-npiggin@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180823084709.19717-3-npiggin@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nicholas Piggin <npiggin@gmail.com>
Cc: Peter Zijlstra <peterz@infradead.org>, torvalds@linux-foundation.org, luto@kernel.org, x86@kernel.org, bp@alien8.de, riel@surriel.com, jannh@google.com, ascannell@google.com, dave.hansen@intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, David Miller <davem@davemloft.net>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Michael Ellerman <mpe@ellerman.id.au>, linux-arch@vger.kernel.org

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
> ---
>  include/asm-generic/tlb.h | 17 +++++++++++++----
>  mm/memory.c               | 10 ----------
>  2 files changed, 13 insertions(+), 14 deletions(-)

I think we only use the notifiers in the KVM code, which appears to leave
the ->invalidate_range() callback empty, so that at least explains why we
haven't run into problems here.

But the change looks correct to me, so:

Acked-by: Will Deacon <will.deacon@arm.com>

Thanks,

Will
