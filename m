Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 960DC6B2BA6
	for <linux-mm@kvack.org>; Thu, 23 Aug 2018 15:15:50 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id m185-v6so6151607itm.1
        for <linux-mm@kvack.org>; Thu, 23 Aug 2018 12:15:50 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 73-v6sor480574iti.148.2018.08.23.12.15.49
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 23 Aug 2018 12:15:49 -0700 (PDT)
MIME-Version: 1.0
References: <20180823084709.19717-1-npiggin@gmail.com>
In-Reply-To: <20180823084709.19717-1-npiggin@gmail.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Thu, 23 Aug 2018 12:15:37 -0700
Message-ID: <CA+55aFxaiv3SMvFUSEnd_p6nuGttUnv2_O3v_G2zCnnc0pV2pA@mail.gmail.com>
Subject: Re: [RFC PATCH 0/2] minor mmu_gather patches
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nick Piggin <npiggin@gmail.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Andrew Lutomirski <luto@kernel.org>, the arch/x86 maintainers <x86@kernel.org>, Borislav Petkov <bp@alien8.de>, Will Deacon <will.deacon@arm.com>, Rik van Riel <riel@surriel.com>, Jann Horn <jannh@google.com>, Adin Scannell <ascannell@google.com>, Dave Hansen <dave.hansen@intel.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, David Miller <davem@davemloft.net>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Michael Ellerman <mpe@ellerman.id.au>, linux-arch <linux-arch@vger.kernel.org>

On Thu, Aug 23, 2018 at 1:47 AM Nicholas Piggin <npiggin@gmail.com> wrote:
>
> These are split from some patches I posted a while back, I was going
> to take a look and revive the series again after your fixes go in,
> but having another look, it may be that your "[PATCH 3/4] mm/tlb,
> x86/mm: Support invalidating TLB caches for RCU_TABLE_FREE" becomes
> easier after my patch 1.
>
> And I'm not convinced patch 2 is not a real bug at least for ARM64,
> so it may be possible to squeeze it in if it's reviewed very
> carefully (I need to actually reproduce and trace it).
>
> So not signed off by yet, but if you think it might be worth doing
> these with your changes, it could be a slightly cleaner end result?

Actually, you did have sign-offs, and yes, that patch 1/2 does
actually clean up and simplify the HAVE_RCU_TABLE_INVALIDATE fix, so I
decided to mix these in with PeterZ's series.

And since it turns out that patch doesn't apparently matter for
correctness and doesn't need to be backported to stable, I put it at
the end of the series together with the x86 cleanup patch to avoid the
unnecessary RCU-delayed freeing entirely for the non-PV case.

So right now my "tlb-fixes" branch looks like this:

    x86/mm/tlb: Revert the recent lazy TLB patches
 *  mm: move tlb_table_flush to tlb_flush_mmu_free
 *  mm/tlb: Remove tlb_remove_table() non-concurrent condition
 *  mm/tlb, x86/mm: Support invalidating TLB caches for RCU_TABLE_FREE
    mm: mmu_notifier fix for tlb_end_vma
    x86/mm: Only use tlb_remove_table() for paravirt

where the three starred patches are marked for stable.

The initial revert is for this merge window only, and the two last
patches are cleanups and fixes but shouldn't matter for correctness in
stable.

PeterZ - your "mm/tlb, x86/mm: Support invalidating TLB caches for
RCU_TABLE_FREE" patch looks exactly the same, but it now no longer has
the split of tlb_flush_mmu_tlbonly(), since with Nick's patch to move
the call to tlb_table_flush(tlb) into tlb_flush_mmu_free, there's no
need for the separate double-underscore version.

I hope nothing I did screwed things up. It all looks sane to me.
Famous last words.

I'll do a few more test builds and boots, but I think I'm going to
merge it in this cleaned-up and re-ordered form.

                     Linus
