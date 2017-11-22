Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 5781D6B02AC
	for <linux-mm@kvack.org>; Wed, 22 Nov 2017 14:30:52 -0500 (EST)
Received: by mail-oi0-f69.google.com with SMTP id r190so7970469oie.14
        for <linux-mm@kvack.org>; Wed, 22 Nov 2017 11:30:52 -0800 (PST)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id v74si6437991oia.545.2017.11.22.11.30.51
        for <linux-mm@kvack.org>;
        Wed, 22 Nov 2017 11:30:51 -0800 (PST)
Date: Wed, 22 Nov 2017 19:30:50 +0000
From: Will Deacon <will.deacon@arm.com>
Subject: Re: [PATCH] arch, mm: introduce arch_tlb_gather_mmu_lazy
Message-ID: <20171122193049.GI22648@arm.com>
References: <20171107095453.179940-1-wangnan0@huawei.com>
 <20171110001933.GA12421@bbox>
 <20171110101529.op6yaxtdke2p4bsh@dhcp22.suse.cz>
 <20171110122635.q26xdxytgdfjy5q3@dhcp22.suse.cz>
 <20171115173332.GL19071@arm.com>
 <20171116092042.esxqtnfxdrozfwey@dhcp22.suse.cz>
 <20171120142444.GA32488@arm.com>
 <20171120160422.5ieustt5ovbyelyx@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171120160422.5ieustt5ovbyelyx@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Minchan Kim <minchan@kernel.org>, Wang Nan <wangnan0@huawei.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Bob Liu <liubo95@huawei.com>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Ingo Molnar <mingo@kernel.org>, Roman Gushchin <guro@fb.com>, Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, Andrea Arcangeli <aarcange@redhat.com>

Hi Michal,

On Mon, Nov 20, 2017 at 05:04:22PM +0100, Michal Hocko wrote:
> On Mon 20-11-17 14:24:44, Will Deacon wrote:
> > On Thu, Nov 16, 2017 at 10:20:42AM +0100, Michal Hocko wrote:
> > > On Wed 15-11-17 17:33:32, Will Deacon wrote:
> [...]
> > > > > diff --git a/arch/arm64/include/asm/tlb.h b/arch/arm64/include/asm/tlb.h
> > > > > index ffdaea7954bb..7adde19b2bcc 100644
> > > > > --- a/arch/arm64/include/asm/tlb.h
> > > > > +++ b/arch/arm64/include/asm/tlb.h
> > > > > @@ -43,7 +43,7 @@ static inline void tlb_flush(struct mmu_gather *tlb)
> > > > >  	 * The ASID allocator will either invalidate the ASID or mark
> > > > >  	 * it as used.
> > > > >  	 */
> > > > > -	if (tlb->fullmm)
> > > > > +	if (tlb->lazy)
> > > > >  		return;
> > > > 
> > > > This looks like the right idea, but I'd rather make this check:
> > > > 
> > > > 	if (tlb->fullmm && tlb->lazy)
> > > > 
> > > > since the optimisation doesn't work for anything than tearing down the
> > > > entire address space.
> > > 
> > > OK, that makes sense.
> > > 
> > > > Alternatively, I could actually go check MMF_UNSTABLE in tlb->mm, which
> > > > would save you having to add an extra flag in the first place, e.g.:
> > > > 
> > > > 	if (tlb->fullmm && !test_bit(MMF_UNSTABLE, &tlb->mm->flags))
> > > > 
> > > > which is a nice one-liner.
> > > 
> > > But that would make it oom_reaper specific. What about the softdirty
> > > case Minchan has mentioned earlier?
> > 
> > We don't (yet) support that on arm64, so we're ok for now. If we do grow
> > support for it, then I agree that we want a flag to identify the case where
> > the address space is going away and only elide the invalidation then.
> 
> What do you think about the following patch instead? I have to confess
> I do not really understand the fullmm semantic so I might introduce some
> duplication by this flag. If you think this is a good idea, I will post
> it in a separate thread.


Please do! My only suggestion would be s/lazy/exit/, since I don't think the
optimisation works in any other situation than the address space going away
for good.

Will

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
