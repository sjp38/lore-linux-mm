Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 54DC26B0266
	for <linux-mm@kvack.org>; Mon,  9 Oct 2017 14:48:33 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id s185so13110745oif.3
        for <linux-mm@kvack.org>; Mon, 09 Oct 2017 11:48:33 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id p200si3723278oic.247.2017.10.09.11.48.32
        for <linux-mm@kvack.org>;
        Mon, 09 Oct 2017 11:48:32 -0700 (PDT)
Date: Mon, 9 Oct 2017 19:48:34 +0100
From: Will Deacon <will.deacon@arm.com>
Subject: Re: [PATCH v9 09/12] mm/kasan: kasan specific map populate function
Message-ID: <20171009184834.GE30828@arm.com>
References: <20170920201714.19817-1-pasha.tatashin@oracle.com>
 <20170920201714.19817-10-pasha.tatashin@oracle.com>
 <20171003144845.GD4931@leverpostej>
 <20171009171337.GE30085@arm.com>
 <CAOAebxtHHFvYn4WysMASe1GqvgKYPVyjJ572UM3Sef5sP0hi9A@mail.gmail.com>
 <20171009182217.GC30828@arm.com>
 <CAOAebxu1310eCrk88EC=Oaw3n90-9RuHZ1KBhPvLu_DyXBNZFQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAOAebxu1310eCrk88EC=Oaw3n90-9RuHZ1KBhPvLu_DyXBNZFQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Tatashin <pasha.tatashin@oracle.com>
Cc: Mark Rutland <mark.rutland@arm.com>, catalin.marinas@arm.com, linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org, kasan-dev@googlegroups.com, borntraeger@de.ibm.com, heiko.carstens@de.ibm.com, davem@davemloft.net, willy@infradead.org, mhocko@kernel.org, ard.biesheuvel@linaro.org, sam@ravnborg.org, mgorman@techsingularity.net, Steve Sistare <steven.sistare@oracle.com>, daniel.m.jordan@oracle.com, bob.picco@oracle.com

On Mon, Oct 09, 2017 at 02:42:32PM -0400, Pavel Tatashin wrote:
> Hi Will,
> 
> In addition to what Michal wrote:
> 
> > As an interim step, why not introduce something like
> > vmemmap_alloc_block_flags and make the page-table walking opt-out for
> > architectures that don't want it? Then we can just pass __GFP_ZERO from
> > our vmemmap_populate where necessary and other architectures can do the
> > page-table walking dance if they prefer.
> 
> I do not see the benefit, implementing this approach means that we
> would need to implement two table walks instead of one: one for x86,
> another for ARM, as these two architectures support kasan. Also, this
> would become a requirement for any future architecture that want to
> add kasan support to add this page table walk implementation.

We have two table walks even with your patch series applied afaict: one in
our definition of vmemmap_populate (arch/arm64/mm/mmu.c) and this one
in the core code.

> >> IMO, while I understand that it looks strange that we must walk page
> >> table after creating it, it is a better approach: more enclosed as it
> >> effects kasan only, and more universal as it is in common code.
> >
> > I don't buy the more universal aspect, but I appreciate it's subjective.
> > Frankly, I'd just sooner not have core code walking early page tables if
> > it can be avoided, and it doesn't look hard to avoid it in this case.
> > The fact that you're having to add pmd_large and pud_large, which are
> > otherwise unused in mm/, is an indication that this isn't quite right imo.
> 
>  28 +#define pmd_large(pmd)         pmd_sect(pmd)
>  29 +#define pud_large(pud)         pud_sect(pud)
> 
> it is just naming difference, ARM64 calls them pmd_sect, common mm and
> other arches call them
> pmd_large/pud_large. Even the ARM has these defines in
> 
> arm/include/asm/pgtable-3level.h
> arm/include/asm/pgtable-2level.h

My worry is that these are actually highly arch-specific, but will likely
grow more users in mm/ that assume things for all architectures that aren't
necessarily valid.

Will

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
