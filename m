Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id A269F8E0002
	for <linux-mm@kvack.org>; Wed, 16 Jan 2019 08:36:48 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id y35so2399370edb.5
        for <linux-mm@kvack.org>; Wed, 16 Jan 2019 05:36:48 -0800 (PST)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id i19si1686848edr.271.2019.01.16.05.36.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 16 Jan 2019 05:36:47 -0800 (PST)
Date: Wed, 16 Jan 2019 14:36:45 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH V2] mm: Introduce GFP_PGTABLE
Message-ID: <20190116133645.GO24149@dhcp22.suse.cz>
References: <1547619692-7946-1-git-send-email-anshuman.khandual@arm.com>
 <20190116065703.GE24149@dhcp22.suse.cz>
 <20190116123018.GF6310@bombadil.infradead.org>
 <20190116124431.GK24149@dhcp22.suse.cz>
 <d074a7aa-9582-b95a-dce0-d95ac3d3c949@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <d074a7aa-9582-b95a-dce0-d95ac3d3c949@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <anshuman.khandual@arm.com>
Cc: Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-arm-kernel@lists.infradead.org, linux-sh@vger.kernel.org, kvmarm@lists.cs.columbia.edu, linux-riscv@lists.infradead.org, linux@armlinux.org.uk, catalin.marinas@arm.com, will.deacon@arm.com, mpe@ellerman.id.au, tglx@linutronix.de, mingo@redhat.com, dave.hansen@linux.intel.com, peterz@infradead.org, christoffer.dall@arm.com, marc.zyngier@arm.com, kirill@shutemov.name, rppt@linux.vnet.ibm.com, ard.biesheuvel@linaro.org, mark.rutland@arm.com, steve.capper@arm.com, james.morse@arm.com, robin.murphy@arm.com, aneesh.kumar@linux.ibm.com, vbabka@suse.cz, shakeelb@google.com, rientjes@google.com, palmer@sifive.com, greentime@andestech.com

On Wed 16-01-19 18:57:13, Anshuman Khandual wrote:
> 
> 
> On 01/16/2019 06:14 PM, Michal Hocko wrote:
> > On Wed 16-01-19 04:30:18, Matthew Wilcox wrote:
> >> On Wed, Jan 16, 2019 at 07:57:03AM +0100, Michal Hocko wrote:
> >>> On Wed 16-01-19 11:51:32, Anshuman Khandual wrote:
> >>>> All architectures have been defining their own PGALLOC_GFP as (GFP_KERNEL |
> >>>> __GFP_ZERO) and using it for allocating page table pages. This causes some
> >>>> code duplication which can be easily avoided. GFP_KERNEL allocated and
> >>>> cleared out pages (__GFP_ZERO) are required for page tables on any given
> >>>> architecture. This creates a new generic GFP flag flag which can be used
> >>>> for any page table page allocation. Does not cause any functional change.
> >>>>
> >>>> GFP_PGTABLE is being added into include/asm-generic/pgtable.h which is the
> >>>> generic page tabe header just to prevent it's potential misuse as a general
> >>>> allocation flag if included in include/linux/gfp.h.
> >>>
> >>> I haven't reviewed the patch yet but I am wondering whether this is
> >>> really worth it without going all the way down to unify the common code
> >>> and remove much more code duplication. Or is this not possible for some
> >>> reason?
> >>
> >> Exactly what I suggested doing in response to v1.
> >>
> >> Also, the approach taken here is crazy.  x86 has a feature that no other
> >> architecture has bothered to implement yet -- accounting page tables
> >> to the process.  Yet instead of spreading that goodness to all other
> >> architectures, Anshuman has gone to more effort to avoid doing that.
> > 
> > Yes, I believe the only reason this is x86 only is that each arch would
> > have to be tweaked separately. So a cleanup in _that_ regard would be
> > helpful. There is no real reason to have ptes accounted only for x86.
> > There might be some exceptions but well, our asm-generic allows to opt
> > in for generic implementation or override it with a special one. The
> > later should be an exception rather than the rule.
> 
> Fair enough. So we seem to have agreement over __GFP_ACCOUNT for user page
> tables but not for the kernel. But should we accommodate __GFP_RETRY_MAYFAIL
> or drop them altogether (including multi order allocation requests) ?

__GFP_RETRY_MAYFAIL is a leftover from __GFP_REPEAT times and from my
recollection it was pointless there. Or do we have any pte allocations
which are costly high order or that would rather fail than OOM kill and
retry.

Really there is no reason to preserve some code just because it is
written that way.

Anyway, as Mathew already pointed out. There is no real reason to
convert all arches at once. If you carve out a common implementation and
make it arch generic then you can go once arch at the time a reuse the
generic implementation. If there are still some arches which differ only
by __GFP_RETRY_MAYFAIL then talk to respective maintainers and ask them
what is the underlying reason.

See how that is a completely different and much more efficient way than
trying to make GFP_PGTABLE special and keep the code around?

-- 
Michal Hocko
SUSE Labs
