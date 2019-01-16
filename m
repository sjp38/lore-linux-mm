Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2A1078E0002
	for <linux-mm@kvack.org>; Wed, 16 Jan 2019 09:20:23 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id u17so3932436pgn.17
        for <linux-mm@kvack.org>; Wed, 16 Jan 2019 06:20:23 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id k135si6030958pgc.574.2019.01.16.06.20.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 16 Jan 2019 06:20:21 -0800 (PST)
Date: Wed, 16 Jan 2019 06:20:14 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH V2] mm: Introduce GFP_PGTABLE
Message-ID: <20190116142014.GJ6310@bombadil.infradead.org>
References: <1547619692-7946-1-git-send-email-anshuman.khandual@arm.com>
 <20190116065703.GE24149@dhcp22.suse.cz>
 <20190116123018.GF6310@bombadil.infradead.org>
 <07d6a264-dccd-78ab-e8a9-2410bbef7b97@arm.com>
 <20190116131827.GH6310@bombadil.infradead.org>
 <521d8511-4c87-49c6-de03-67a71d5bacca@c-s.fr>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <521d8511-4c87-49c6-de03-67a71d5bacca@c-s.fr>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christophe Leroy <christophe.leroy@c-s.fr>
Cc: Anshuman Khandual <anshuman.khandual@arm.com>, mark.rutland@arm.com, linux-sh@vger.kernel.org, peterz@infradead.org, catalin.marinas@arm.com, dave.hansen@linux.intel.com, will.deacon@arm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-riscv@lists.infradead.org, kvmarm@lists.cs.columbia.edu, linux@armlinux.org.uk, mingo@redhat.com, vbabka@suse.cz, rientjes@google.com, palmer@sifive.com, greentime@andestech.com, marc.zyngier@arm.com, rppt@linux.vnet.ibm.com, shakeelb@google.com, kirill@shutemov.name, tglx@linutronix.de, Michal Hocko <mhocko@kernel.org>, linux-arm-kernel@lists.infradead.org, ard.biesheuvel@linaro.org, robin.murphy@arm.com, steve.capper@arm.com, christoffer.dall@arm.com, james.morse@arm.com, aneesh.kumar@linux.ibm.com, akpm@linux-foundation.org, linuxppc-dev@lists.ozlabs.org

On Wed, Jan 16, 2019 at 02:47:16PM +0100, Christophe Leroy wrote:
> Le 16/01/2019 à 14:18, Matthew Wilcox a écrit :
> > I disagree with your objective.  Making more code common is a great idea,
> > but this patch is too unambitious.  We should be heading towards one or
> > two page table allocation functions instead of having every architecture do
> > its own thing.
> > 
> > So start there.  Move the x86 function into common code and convert one
> > other architecture to use it too.
> 
> Are we talking about pte_alloc_one_kernel() and pte_alloc_one() ?
> 
> I'm not sure x86 function is the best common one, as it seems to allocate a
> multiple of PAGE_SIZE only.

And that's the common case.  Most architectures use a single page for at
least one level of the pte/pmd/pud/p4d/pgd hierarchy.  Some use multiple
pages and some use a fraction of a page.

> Some arches like powerpc use pagetables which are smaller than a page, for
> instance powerpc 8xx uses 4k pagetables even with 16k pages, which means a
> single page can be used by 4 pagetables.

Those can be added later.  Note I said "one or two", and that's what I
had in mind; I think we want one function that allocates just a page
and another that allocates a page fragment.  Then we can have a good
discussion about what method we use; s390 and ppc use different techniques
today and there's really no good reason for that.
