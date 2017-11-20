Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id B0F646B0069
	for <linux-mm@kvack.org>; Mon, 20 Nov 2017 11:04:25 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id w95so6283119wrc.20
        for <linux-mm@kvack.org>; Mon, 20 Nov 2017 08:04:25 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o1si88048eda.317.2017.11.20.08.04.23
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 20 Nov 2017 08:04:24 -0800 (PST)
Date: Mon, 20 Nov 2017 17:04:22 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: [PATCH] arch, mm: introduce arch_tlb_gather_mmu_lazy
Message-ID: <20171120160422.5ieustt5ovbyelyx@dhcp22.suse.cz>
References: <20171107095453.179940-1-wangnan0@huawei.com>
 <20171110001933.GA12421@bbox>
 <20171110101529.op6yaxtdke2p4bsh@dhcp22.suse.cz>
 <20171110122635.q26xdxytgdfjy5q3@dhcp22.suse.cz>
 <20171115173332.GL19071@arm.com>
 <20171116092042.esxqtnfxdrozfwey@dhcp22.suse.cz>
 <20171120142444.GA32488@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171120142444.GA32488@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Will Deacon <will.deacon@arm.com>
Cc: Minchan Kim <minchan@kernel.org>, Wang Nan <wangnan0@huawei.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Bob Liu <liubo95@huawei.com>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Ingo Molnar <mingo@kernel.org>, Roman Gushchin <guro@fb.com>, Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, Andrea Arcangeli <aarcange@redhat.com>

On Mon 20-11-17 14:24:44, Will Deacon wrote:
> On Thu, Nov 16, 2017 at 10:20:42AM +0100, Michal Hocko wrote:
> > On Wed 15-11-17 17:33:32, Will Deacon wrote:
[...]
> > > > diff --git a/arch/arm64/include/asm/tlb.h b/arch/arm64/include/asm/tlb.h
> > > > index ffdaea7954bb..7adde19b2bcc 100644
> > > > --- a/arch/arm64/include/asm/tlb.h
> > > > +++ b/arch/arm64/include/asm/tlb.h
> > > > @@ -43,7 +43,7 @@ static inline void tlb_flush(struct mmu_gather *tlb)
> > > >  	 * The ASID allocator will either invalidate the ASID or mark
> > > >  	 * it as used.
> > > >  	 */
> > > > -	if (tlb->fullmm)
> > > > +	if (tlb->lazy)
> > > >  		return;
> > > 
> > > This looks like the right idea, but I'd rather make this check:
> > > 
> > > 	if (tlb->fullmm && tlb->lazy)
> > > 
> > > since the optimisation doesn't work for anything than tearing down the
> > > entire address space.
> > 
> > OK, that makes sense.
> > 
> > > Alternatively, I could actually go check MMF_UNSTABLE in tlb->mm, which
> > > would save you having to add an extra flag in the first place, e.g.:
> > > 
> > > 	if (tlb->fullmm && !test_bit(MMF_UNSTABLE, &tlb->mm->flags))
> > > 
> > > which is a nice one-liner.
> > 
> > But that would make it oom_reaper specific. What about the softdirty
> > case Minchan has mentioned earlier?
> 
> We don't (yet) support that on arm64, so we're ok for now. If we do grow
> support for it, then I agree that we want a flag to identify the case where
> the address space is going away and only elide the invalidation then.

What do you think about the following patch instead? I have to confess
I do not really understand the fullmm semantic so I might introduce some
duplication by this flag. If you think this is a good idea, I will post
it in a separate thread.
---
