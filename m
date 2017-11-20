Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 959A26B0038
	for <linux-mm@kvack.org>; Mon, 20 Nov 2017 09:24:47 -0500 (EST)
Received: by mail-oi0-f70.google.com with SMTP id a75so4659346oib.13
        for <linux-mm@kvack.org>; Mon, 20 Nov 2017 06:24:47 -0800 (PST)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id v47si3991764otv.143.2017.11.20.06.24.45
        for <linux-mm@kvack.org>;
        Mon, 20 Nov 2017 06:24:46 -0800 (PST)
Date: Mon, 20 Nov 2017 14:24:44 +0000
From: Will Deacon <will.deacon@arm.com>
Subject: Re: [PATCH] arch, mm: introduce arch_tlb_gather_mmu_lazy (was: Re:
 [RESEND PATCH] mm, oom_reaper: gather each vma to prevent) leaking TLB entry
Message-ID: <20171120142444.GA32488@arm.com>
References: <20171107095453.179940-1-wangnan0@huawei.com>
 <20171110001933.GA12421@bbox>
 <20171110101529.op6yaxtdke2p4bsh@dhcp22.suse.cz>
 <20171110122635.q26xdxytgdfjy5q3@dhcp22.suse.cz>
 <20171115173332.GL19071@arm.com>
 <20171116092042.esxqtnfxdrozfwey@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171116092042.esxqtnfxdrozfwey@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Minchan Kim <minchan@kernel.org>, Wang Nan <wangnan0@huawei.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Bob Liu <liubo95@huawei.com>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Ingo Molnar <mingo@kernel.org>, Roman Gushchin <guro@fb.com>, Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, Andrea Arcangeli <aarcange@redhat.com>

On Thu, Nov 16, 2017 at 10:20:42AM +0100, Michal Hocko wrote:
> On Wed 15-11-17 17:33:32, Will Deacon wrote:
> > Hi Michal,
> > 
> > On Fri, Nov 10, 2017 at 01:26:35PM +0100, Michal Hocko wrote:
> > > From 7f0fcd2cab379ddac5611b2a520cdca8a77a235b Mon Sep 17 00:00:00 2001
> > > From: Michal Hocko <mhocko@suse.com>
> > > Date: Fri, 10 Nov 2017 11:27:17 +0100
> > > Subject: [PATCH] arch, mm: introduce arch_tlb_gather_mmu_lazy
> > > 
> > > 5a7862e83000 ("arm64: tlbflush: avoid flushing when fullmm == 1") has
> > > introduced an optimization to not flush tlb when we are tearing the
> > > whole address space down. Will goes on to explain
> > > 
> > > : Basically, we tag each address space with an ASID (PCID on x86) which
> > > : is resident in the TLB. This means we can elide TLB invalidation when
> > > : pulling down a full mm because we won't ever assign that ASID to
> > > : another mm without doing TLB invalidation elsewhere (which actually
> > > : just nukes the whole TLB).
> > > 
> > > This all is nice but tlb_gather users are not aware of that and this can
> > > actually cause some real problems. E.g. the oom_reaper tries to reap the
> > > whole address space but it might race with threads accessing the memory [1].
> > > It is possible that soft-dirty handling might suffer from the same
> > > problem [2].
> > > 
> > > Introduce an explicit lazy variant tlb_gather_mmu_lazy which allows the
> > > behavior arm64 implements for the fullmm case and replace it by an
> > > explicit lazy flag in the mmu_gather structure. exit_mmap path is then
> > > turned into the explicit lazy variant. Other architectures simply ignore
> > > the flag.
> > > 
> > > [1] http://lkml.kernel.org/r/20171106033651.172368-1-wangnan0@huawei.com
> > > [2] http://lkml.kernel.org/r/20171110001933.GA12421@bbox
> > > Signed-off-by: Michal Hocko <mhocko@suse.com>
> > > ---
> > >  arch/arm/include/asm/tlb.h   |  3 ++-
> > >  arch/arm64/include/asm/tlb.h |  2 +-
> > >  arch/ia64/include/asm/tlb.h  |  3 ++-
> > >  arch/s390/include/asm/tlb.h  |  3 ++-
> > >  arch/sh/include/asm/tlb.h    |  2 +-
> > >  arch/um/include/asm/tlb.h    |  2 +-
> > >  include/asm-generic/tlb.h    |  6 ++++--
> > >  include/linux/mm_types.h     |  2 ++
> > >  mm/memory.c                  | 17 +++++++++++++++--
> > >  mm/mmap.c                    |  2 +-
> > >  10 files changed, 31 insertions(+), 11 deletions(-)
> > > 
> > > diff --git a/arch/arm/include/asm/tlb.h b/arch/arm/include/asm/tlb.h
> > > index d5562f9ce600..fe9042aee8e9 100644
> > > --- a/arch/arm/include/asm/tlb.h
> > > +++ b/arch/arm/include/asm/tlb.h
> > > @@ -149,7 +149,8 @@ static inline void tlb_flush_mmu(struct mmu_gather *tlb)
> > >  
> > >  static inline void
> > >  arch_tlb_gather_mmu(struct mmu_gather *tlb, struct mm_struct *mm,
> > > -			unsigned long start, unsigned long end)
> > > +			unsigned long start, unsigned long end,
> > > +			bool lazy)
> > >  {
> > >  	tlb->mm = mm;
> > >  	tlb->fullmm = !(start | (end+1));
> > > diff --git a/arch/arm64/include/asm/tlb.h b/arch/arm64/include/asm/tlb.h
> > > index ffdaea7954bb..7adde19b2bcc 100644
> > > --- a/arch/arm64/include/asm/tlb.h
> > > +++ b/arch/arm64/include/asm/tlb.h
> > > @@ -43,7 +43,7 @@ static inline void tlb_flush(struct mmu_gather *tlb)
> > >  	 * The ASID allocator will either invalidate the ASID or mark
> > >  	 * it as used.
> > >  	 */
> > > -	if (tlb->fullmm)
> > > +	if (tlb->lazy)
> > >  		return;
> > 
> > This looks like the right idea, but I'd rather make this check:
> > 
> > 	if (tlb->fullmm && tlb->lazy)
> > 
> > since the optimisation doesn't work for anything than tearing down the
> > entire address space.
> 
> OK, that makes sense.
> 
> > Alternatively, I could actually go check MMF_UNSTABLE in tlb->mm, which
> > would save you having to add an extra flag in the first place, e.g.:
> > 
> > 	if (tlb->fullmm && !test_bit(MMF_UNSTABLE, &tlb->mm->flags))
> > 
> > which is a nice one-liner.
> 
> But that would make it oom_reaper specific. What about the softdirty
> case Minchan has mentioned earlier?

We don't (yet) support that on arm64, so we're ok for now. If we do grow
support for it, then I agree that we want a flag to identify the case where
the address space is going away and only elide the invalidation then.

Will

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
