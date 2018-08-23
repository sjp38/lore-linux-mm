Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5C8606B2CAB
	for <linux-mm@kvack.org>; Thu, 23 Aug 2018 19:42:30 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id f13-v6so4075778pgs.15
        for <linux-mm@kvack.org>; Thu, 23 Aug 2018 16:42:30 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u68-v6sor1888055pfd.13.2018.08.23.16.42.28
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 23 Aug 2018 16:42:29 -0700 (PDT)
Date: Fri, 24 Aug 2018 09:42:20 +1000
From: Nicholas Piggin <npiggin@gmail.com>
Subject: Re: [RFC PATCH 0/2] minor mmu_gather patches
Message-ID: <20180824094220.3ac18168@roar.ozlabs.ibm.com>
In-Reply-To: <20180823232704.GA4487@brain-police>
References: <20180823084709.19717-1-npiggin@gmail.com>
	<CA+55aFxaiv3SMvFUSEnd_p6nuGttUnv2_O3v_G2zCnnc0pV2pA@mail.gmail.com>
	<CA+55aFwEZftzAd9k-kjiaXonP2XeTDYshjY56jmd1CFBaXmGHA@mail.gmail.com>
	<20180823232704.GA4487@brain-police>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Will Deacon <will.deacon@arm.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Andrew Lutomirski <luto@kernel.org>, the arch/x86 maintainers <x86@kernel.org>, Borislav Petkov <bp@alien8.de>, Rik van Riel <riel@surriel.com>, Jann Horn <jannh@google.com>, Adin Scannell <ascannell@google.com>, Dave Hansen <dave.hansen@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, David Miller <davem@davemloft.net>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Michael Ellerman <mpe@ellerman.id.au>, linux-arch <linux-arch@vger.kernel.org>

On Fri, 24 Aug 2018 00:27:05 +0100
Will Deacon <will.deacon@arm.com> wrote:

> Hi Linus,
> 
> On Thu, Aug 23, 2018 at 12:37:58PM -0700, Linus Torvalds wrote:
> > On Thu, Aug 23, 2018 at 12:15 PM Linus Torvalds
> > <torvalds@linux-foundation.org> wrote:  
> > >
> > > So right now my "tlb-fixes" branch looks like this:
> > > [..]
> > >
> > > I'll do a few more test builds and boots, but I think I'm going to
> > > merge it in this cleaned-up and re-ordered form.  
> > 
> > In the meantime, I decided to push out that branch in case anybody
> > wants to look at it.
> > 
> > I may rebase it if I - or anybody else - find anything bad there, so
> > consider it non-stable, but I think it's in its final shape modulo
> > issues.  
> 
> Unfortunately, that branch doesn't build for arm64 because of Nick's patch
> moving tlb_flush_mmu_tlbonly() into tlb.h (which I acked!). It's a static
> inline which calls tlb_flush(), which in our case is also a static inline
> but one that is defined in our asm/tlb.h after including asm-generic/tlb.h.
> 
> Ah, just noticed you've pushed this to master! Please could you take the
> arm64 patch below on top, in order to fix the build?

Sorry yeah I had the sign offs but should have clear I hadn't fully
build tested them. It's reasonable for reviewers to assume basic
diligence was done and concentrate on the logic rather than build
trivialities. So that's my bad. Thanks for the fix.

Thanks,
Nick

> 
> Cheers,
> 
> Will
> 
> --->8  
> 
> From 48ea452db90a91ff2b62a94277daf565e715a126 Mon Sep 17 00:00:00 2001
> From: Will Deacon <will.deacon@arm.com>
> Date: Fri, 24 Aug 2018 00:23:04 +0100
> Subject: [PATCH] arm64: tlb: Provide forward declaration of tlb_flush() before
>  including tlb.h
> 
> As of commit fd1102f0aade ("mm: mmu_notifier fix for tlb_end_vma"),
> asm-generic/tlb.h now calls tlb_flush() from a static inline function,
> so we need to make sure that it's declared before #including the
> asm-generic header in the arch header.
> 
> Signed-off-by: Will Deacon <will.deacon@arm.com>
> ---
>  arch/arm64/include/asm/tlb.h | 2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/arch/arm64/include/asm/tlb.h b/arch/arm64/include/asm/tlb.h
> index 0ad1cf233470..a3233167be60 100644
> --- a/arch/arm64/include/asm/tlb.h
> +++ b/arch/arm64/include/asm/tlb.h
> @@ -33,6 +33,8 @@ static inline void __tlb_remove_table(void *_table)
>  #define tlb_remove_entry(tlb, entry)	tlb_remove_page(tlb, entry)
>  #endif /* CONFIG_HAVE_RCU_TABLE_FREE */
>  
> +static void tlb_flush(struct mmu_gather *tlb);
> +
>  #include <asm-generic/tlb.h>
>  
>  static inline void tlb_flush(struct mmu_gather *tlb)
