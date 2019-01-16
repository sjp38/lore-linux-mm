Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f197.google.com (mail-pl1-f197.google.com [209.85.214.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6781F8E0002
	for <linux-mm@kvack.org>; Wed, 16 Jan 2019 08:18:33 -0500 (EST)
Received: by mail-pl1-f197.google.com with SMTP id c14so3778661pls.21
        for <linux-mm@kvack.org>; Wed, 16 Jan 2019 05:18:33 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id b8si5774960pgi.575.2019.01.16.05.18.31
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 16 Jan 2019 05:18:31 -0800 (PST)
Date: Wed, 16 Jan 2019 05:18:27 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH V2] mm: Introduce GFP_PGTABLE
Message-ID: <20190116131827.GH6310@bombadil.infradead.org>
References: <1547619692-7946-1-git-send-email-anshuman.khandual@arm.com>
 <20190116065703.GE24149@dhcp22.suse.cz>
 <20190116123018.GF6310@bombadil.infradead.org>
 <07d6a264-dccd-78ab-e8a9-2410bbef7b97@arm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <07d6a264-dccd-78ab-e8a9-2410bbef7b97@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <anshuman.khandual@arm.com>
Cc: Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-arm-kernel@lists.infradead.org, linux-sh@vger.kernel.org, kvmarm@lists.cs.columbia.edu, linux-riscv@lists.infradead.org, linux@armlinux.org.uk, catalin.marinas@arm.com, will.deacon@arm.com, mpe@ellerman.id.au, tglx@linutronix.de, mingo@redhat.com, dave.hansen@linux.intel.com, peterz@infradead.org, christoffer.dall@arm.com, marc.zyngier@arm.com, kirill@shutemov.name, rppt@linux.vnet.ibm.com, ard.biesheuvel@linaro.org, mark.rutland@arm.com, steve.capper@arm.com, james.morse@arm.com, robin.murphy@arm.com, aneesh.kumar@linux.ibm.com, vbabka@suse.cz, shakeelb@google.com, rientjes@google.com, palmer@sifive.com, greentime@andestech.com

On Wed, Jan 16, 2019 at 06:42:22PM +0530, Anshuman Khandual wrote:
> On 01/16/2019 06:00 PM, Matthew Wilcox wrote:
> > On Wed, Jan 16, 2019 at 07:57:03AM +0100, Michal Hocko wrote:
> >> On Wed 16-01-19 11:51:32, Anshuman Khandual wrote:
> >>> All architectures have been defining their own PGALLOC_GFP as (GFP_KERNEL |
> >>> __GFP_ZERO) and using it for allocating page table pages. This causes some
> >>> code duplication which can be easily avoided. GFP_KERNEL allocated and
> >>> cleared out pages (__GFP_ZERO) are required for page tables on any given
> >>> architecture. This creates a new generic GFP flag flag which can be used
> >>> for any page table page allocation. Does not cause any functional change.
> >>>
> >>> GFP_PGTABLE is being added into include/asm-generic/pgtable.h which is the
> >>> generic page tabe header just to prevent it's potential misuse as a general
> >>> allocation flag if included in include/linux/gfp.h.
> >>
> >> I haven't reviewed the patch yet but I am wondering whether this is
> >> really worth it without going all the way down to unify the common code
> >> and remove much more code duplication. Or is this not possible for some
> >> reason?
> > 
> > Exactly what I suggested doing in response to v1.
> > 
> > Also, the approach taken here is crazy.  x86 has a feature that no other
> > architecture has bothered to implement yet -- accounting page tables
> > to the process.  Yet instead of spreading that goodness to all other
> > architectures, Anshuman has gone to more effort to avoid doing that.
> 
> The basic objective for this patch is to create a common minimum allocation
> flag that can be used by architectures but that still allows archs to add
> on additional constraints if they see fit. This patch does not intend to
> change functionality for any arch.

I disagree with your objective.  Making more code common is a great idea,
but this patch is too unambitious.  We should be heading towards one or
two page table allocation functions instead of having every architecture do
its own thing.

So start there.  Move the x86 function into common code and convert one
other architecture to use it too.
