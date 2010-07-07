Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 65A3E6B006A
	for <linux-mm@kvack.org>; Wed,  7 Jul 2010 04:56:03 -0400 (EDT)
Date: Wed, 7 Jul 2010 11:56:01 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [patch 071/149] ARM: 6166/1: Proper prefetch abort handling on
 pre-ARMv6
Message-ID: <20100707085601.GA18732@shutemov.name>
References: <20100701175144.GA2116@kroah.com>
 <20100701173212.785441106@clark.site>
 <20100701221420.GA10481@shutemov.name>
 <20100701221728.GA12187@suse.de>
 <20100701222541.GB10481@shutemov.name>
 <20100701224837.GA27389@flint.arm.linux.org.uk>
 <20100701225911.GC10481@shutemov.name>
 <20100701231207.GB27389@flint.arm.linux.org.uk>
 <20100706130618.GA14177@shutemov.name>
 <20100706225815.GA21834@flint.arm.linux.org.uk>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100706225815.GA21834@flint.arm.linux.org.uk>
Sender: owner-linux-mm@kvack.org
To: Russell King <rmk@arm.linux.org.uk>
Cc: linux-kernel@vger.kernel.org, alan@lxorguk.ukuu.org.uk, Anfei Zhou <anfei.zhou@gmail.com>, Alexander Shishkin <virtuoso@slind.org>, Siarhei Siamashka <siarhei.siamashka@nokia.com>, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, Jul 06, 2010 at 11:58:15PM +0100, Russell King wrote:
> On Tue, Jul 06, 2010 at 04:06:18PM +0300, Kirill A. Shutemov wrote:
> > I've investigated the issue. It's reproducible if you try to jump to
> > the megabyte next to section mapping.
> 
> Okay, this is specific to the way that OMAP sets up its mappings, which
> is why it doesn't appear everywhere.
> 
> > On ARM one Linux PGD entry contains two hardware entry. But there is error
> > in do_translation_fault(). It's always call pmd_none() check for the first
> > entry of two, not for the entry corresponded to address. So in case if we
> > try to jump the megabyte next to section mapping, we will have inifinity
> > loop of translation faults.
> 
> Okay, now that we know _why_ it happens, I'm satisfied that the fix
> previously committed will help this situation.
> 
> > diff --git a/arch/arm/mm/fault.c b/arch/arm/mm/fault.c
> > index 9634fe1..825b9da 100644
> > --- a/arch/arm/mm/fault.c
> > +++ b/arch/arm/mm/fault.c
> > @@ -406,7 +406,8 @@ do_translation_fault(unsigned long addr, unsigned int fsr,
> >         pmd_k = pmd_offset(pgd_k, addr);
> >         pmd   = pmd_offset(pgd, addr);
> >  
> > -       if (pmd_none(*pmd_k))
> > +       index = (addr >> SECTION_SHIFT) & 1;
> > +       if (pmd_none(pmd_k[index]))
> 
> I do think this is extremely obscure, and therefore requires a comment
> to help people understand what is going on here and why.  Leaving it
> in the commit log would be an invitation for this to be needlessly
> cut'n'pasted.

Ok, I'll fix it.

But it seems that the problem is more global. Potentially, any of
pmd_none() check may produce false results. I don't see an easy way to fix
it.

It's not so big problem since we don't have [super]section in userspace,
but I guess, we want to have huge pages support in the future.

Any ideas how to fix it in the right way?

Does Linux VM still expect one PTE table per page?

CC list modified. Removed persons who unlikely interested in ARM-specific
stuff. linux-arm-kernel and linux-mm added.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
