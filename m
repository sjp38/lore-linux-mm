Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id 795816B0005
	for <linux-mm@kvack.org>; Thu, 11 Oct 2018 11:05:20 -0400 (EDT)
Received: by mail-wr1-f69.google.com with SMTP id f13-v6so5721643wrr.4
        for <linux-mm@kvack.org>; Thu, 11 Oct 2018 08:05:20 -0700 (PDT)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id c8si20839163wrx.184.2018.10.11.08.05.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 11 Oct 2018 08:05:17 -0700 (PDT)
Date: Thu, 11 Oct 2018 17:04:06 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 12/18] arch/tlb: Clean up simple architectures
Message-ID: <20181011150406.GL9848@hirez.programming.kicks-ass.net>
References: <20180926113623.863696043@infradead.org>
 <20180926114801.146189550@infradead.org>
 <C2D7FE5348E1B147BCA15975FBA23075012B09A59E@us01wembx1.internal.synopsys.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <C2D7FE5348E1B147BCA15975FBA23075012B09A59E@us01wembx1.internal.synopsys.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vineet Gupta <vineet.gupta1@synopsys.com>
Cc: "will.deacon@arm.com" <will.deacon@arm.com>, "aneesh.kumar@linux.vnet.ibm.com" <aneesh.kumar@linux.vnet.ibm.com>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "npiggin@gmail.com" <npiggin@gmail.com>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux@armlinux.org.uk" <linux@armlinux.org.uk>, "heiko.carstens@de.ibm.com" <heiko.carstens@de.ibm.com>, "riel@surriel.com" <riel@surriel.com>, Richard Henderson <rth@twiddle.net>, Mark Salter <msalter@redhat.com>, Richard Kuo <rkuo@codeaurora.org>, Michal Simek <monstr@monstr.eu>, Paul Burton <paul.burton@mips.com>, Greentime Hu <green.hu@gmail.com>, Ley Foon Tan <lftan@altera.com>, Jonas Bonn <jonas@southpole.se>, Helge Deller <deller@gmx.de>, "David S. Miller" <davem@davemloft.net>, Guan Xuetao <gxt@pku.edu.cn>, Max Filippov <jcmvbkbc@gmail.com>

On Wed, Oct 03, 2018 at 05:03:50PM +0000, Vineet Gupta wrote:
> On 09/26/2018 04:56 AM, Peter Zijlstra wrote:
> > There are generally two cases:
> >
> >  1) either the platform has an efficient flush_tlb_range() and
> >     asm-generic/tlb.h doesn't need any overrides at all.
> >
> >  2) or an architecture lacks an efficient flush_tlb_range() and
> >     we override tlb_end_vma() and tlb_flush().
> >
> > Convert all 'simple' architectures to one of these two forms.
> >

> > --- a/arch/arc/include/asm/tlb.h
> > +++ b/arch/arc/include/asm/tlb.h
> > @@ -9,29 +9,6 @@
> >  #ifndef _ASM_ARC_TLB_H
> >  #define _ASM_ARC_TLB_H
> >  
> > -#define tlb_flush(tlb)				\
> > -do {						\
> > -	if (tlb->fullmm)			\
> > -		flush_tlb_mm((tlb)->mm);	\
> > -} while (0)
> > -
> > -/*
> > - * This pair is called at time of munmap/exit to flush cache and TLB entries
> > - * for mappings being torn down.
> > - * 1) cache-flush part -implemented via tlb_start_vma( ) for VIPT aliasing D$
> > - * 2) tlb-flush part - implemted via tlb_end_vma( ) flushes the TLB range
> > - *
> > - * Note, read https://urldefense.proofpoint.com/v2/url?u=http-3A__lkml.org_lkml_2004_1_15_6&d=DwIBaQ&c=DPL6_X_6JkXFx7AXWqB0tg&r=c14YS-cH-kdhTOW89KozFhBtBJgs1zXscZojEZQ0THs&m=5jiyvgRek4SKK5DUWDBGufVcuLez5G-jJCh3K-ndHsg&s=7uAzzw_jdAXMfb07B-vGPh3V1vggbTAsB7xL6Kie47A&e=
> > - */
> > -
> > -#define tlb_end_vma(tlb, vma)						\
> > -do {									\
> > -	if (!tlb->fullmm)						\
> > -		flush_tlb_range(vma, vma->vm_start, vma->vm_end);	\
> > -} while (0)
> > -
> > -#define __tlb_remove_tlb_entry(tlb, ptep, address)
> > -
> >  #include <linux/pagemap.h>
> >  #include <asm-generic/tlb.h>
> 
> LGTM per discussion in an earlier thread. However given that for "simpler" arches
> the whole series doesn't apply can you please beef up the changelog so I don't go
> scratching my head 2 years down the line. It currently describes the hows of
> things but not exactly whys: shift_arg_pages missing tlb_start_vma,
> move_page_tables look dodgy, yady yadda ?

Right you are. Thanks for pointing out the somewhat sparse Changelog;
typically I end up kicking myself a few years down the line.

I think I will in fact change the implementation a little and provide a
symbol/Kconfig to switch the default implementation between
flush_tlb_vma() and flush_tlb_mm().

That avoids some of the repetition. But see here a preview of the new
Changelog, does that clarify things enough?

---
Subject: arch/tlb: Clean up simple architectures
From: Peter Zijlstra <peterz@infradead.org>
Date: Tue Sep 4 17:04:07 CEST 2018

The generic mmu_gather implementation is geared towards range tracking
and provided the architecture provides a fairly efficient
flush_tlb_range() implementation (or provides a custom tlb_flush()
implementation) things will work well.

The one case this doesn't cover well is where there is no (efficient)
range invalidate at all. In this case we can select
MMU_GATHER_NO_RANGE.

So this reduces to two cases:

 1) either the platform has an efficient flush_tlb_range() and
    asm-generic/tlb.h doesn't need any overrides at all.

 2) or an architecture lacks an efficient flush_tlb_range() and
    we need to select MMU_GATHER_NO_RANGE.

Convert all 'simple' architectures to one of these two forms.

alpha:	    has no range invalidate -> 2
arc:	    already used flush_tlb_range() -> 1
c6x:	    has no range invalidate -> 2
hexagon:    has an efficient flush_tlb_range() -> 1
            (flush_tlb_mm() is in fact a full range invalidate,
	     so no need to shoot down everything)
m68k:	    has inefficient flush_tlb_range() -> 2
microblaze: has no flush_tlb_range() -> 2
mips:	    has efficient flush_tlb_range() -> 1
	    (even though it currently seems to use flush_tlb_mm())
nds32:	    already uses flush_tlb_range() -> 1
nios2:	    has inefficient flush_tlb_range() -> 2
	    (no limit on range iteration)
openrisc:   has inefficient flush_tlb_range() -> 2
	    (no limit on range iteration)
parisc:	    already uses flush_tlb_range() -> 1
sparc32:    already uses flush_tlb_range() -> 1
unicore32:  has inefficient flush_tlb_range() -> 2
	    (no limit on range iteration)
xtensa:	    has efficient flush_tlb_range() -> 1

Note this also fixes a bug in the existing code for a number
platforms. Those platforms that did:

  tlb_end_vma() -> if (!fullmm) flush_tlb_*()
  tlb_flush -> if (full_mm) flush_tlb_mm()

missed the case of shift_arg_pages(), which doesn't have @fullmm set,
nor calls into tlb_*vma(), but still frees page-tables and thus needs
an invalidate. The new code handles this by detecting a non-empty
range, and either issuing the matching range invalidate or a full
invalidate, depending on the capabilities.

Cc: Nick Piggin <npiggin@gmail.com>
Cc: "David S. Miller" <davem@davemloft.net>
Cc: Michal Simek <monstr@monstr.eu>
Cc: Helge Deller <deller@gmx.de>
Cc: Greentime Hu <green.hu@gmail.com>
Cc: Richard Henderson <rth@twiddle.net>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: Will Deacon <will.deacon@arm.com>
Cc: Ley Foon Tan <lftan@altera.com>
Cc: Jonas Bonn <jonas@southpole.se>
Cc: Mark Salter <msalter@redhat.com>
Cc: Richard Kuo <rkuo@codeaurora.org
Cc: Vineet Gupta <vgupta@synopsys.com>
Cc: Paul Burton <paul.burton@mips.com>
Cc: Max Filippov <jcmvbkbc@gmail.com>
Cc: Guan Xuetao <gxt@pku.edu.cn>
Signed-off-by: Peter Zijlstra (Intel) <peterz@infradead.org>
