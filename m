Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 4107F6B0292
	for <linux-mm@kvack.org>; Mon, 14 Aug 2017 12:22:22 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id c80so4109723oig.7
        for <linux-mm@kvack.org>; Mon, 14 Aug 2017 09:22:22 -0700 (PDT)
Received: from mail-io0-x22d.google.com (mail-io0-x22d.google.com. [2607:f8b0:4001:c06::22d])
        by mx.google.com with ESMTPS id r82si4766967oib.406.2017.08.14.09.22.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Aug 2017 09:22:20 -0700 (PDT)
Received: by mail-io0-x22d.google.com with SMTP id c74so39980045iod.4
        for <linux-mm@kvack.org>; Mon, 14 Aug 2017 09:22:20 -0700 (PDT)
Date: Mon, 14 Aug 2017 10:22:19 -0600
From: Tycho Andersen <tycho@docker.com>
Subject: Re: [kernel-hardening] [PATCH v5 06/10] arm64/mm: Disable section
 mappings if XPFO is enabled
Message-ID: <20170814162219.h2lcmli677bx2lwh@smitten>
References: <20170809200755.11234-1-tycho@docker.com>
 <20170809200755.11234-7-tycho@docker.com>
 <f6a42032-d4e5-f488-3d55-1da4c8a4dbaf@redhat.com>
 <20170811211302.limmjv4rmq23b25b@smitten>
 <20170812111733.GA16374@remoulade>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170812111733.GA16374@remoulade>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mark Rutland <mark.rutland@arm.com>
Cc: Laura Abbott <labbott@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-hardening@lists.openwall.com, Marco Benatto <marco.antonio.780@gmail.com>, Juerg Haefliger <juerg.haefliger@canonical.com>

On Sat, Aug 12, 2017 at 12:17:34PM +0100, Mark Rutland wrote:
> Hi,
> 
> On Fri, Aug 11, 2017 at 03:13:02PM -0600, Tycho Andersen wrote:
> > On Fri, Aug 11, 2017 at 10:25:14AM -0700, Laura Abbott wrote:
> > > On 08/09/2017 01:07 PM, Tycho Andersen wrote:
> > > > @@ -190,7 +202,7 @@ static void init_pmd(pud_t *pud, unsigned long addr, unsigned long end,
> > > >  		next = pmd_addr_end(addr, end);
> > > >  
> > > >  		/* try section mapping first */
> > > > -		if (((addr | next | phys) & ~SECTION_MASK) == 0 &&
> > > > +		if (use_section_mapping(addr, next, phys) &&
> > > >  		    (flags & NO_BLOCK_MAPPINGS) == 0) {
> > > >  			pmd_set_huge(pmd, phys, prot);
> > > >  
> > > > 
> > > 
> > > There is already similar logic to disable section mappings for
> > > debug_pagealloc at the start of map_mem, can you take advantage
> > > of that?
> > 
> > You're suggesting something like this instead? Seems to work fine.
> > 
> > diff --git a/arch/arm64/mm/mmu.c b/arch/arm64/mm/mmu.c
> > index 38026b3ccb46..3b2c17bbbf12 100644
> > --- a/arch/arm64/mm/mmu.c
> > +++ b/arch/arm64/mm/mmu.c
> > @@ -434,6 +434,8 @@ static void __init map_mem(pgd_t *pgd)
> >  
> >  	if (debug_pagealloc_enabled())
> >  		flags = NO_BLOCK_MAPPINGS | NO_CONT_MAPPINGS;
> > +	if (IS_ENABLED(CONFIG_XPFO))
> > +		flags |= NO_BLOCK_MAPPINGS;
> >  
> 
> IIUC, XPFO carves out individual pages just like DEBUG_PAGEALLOC, so you'll
> also need NO_CONT_MAPPINGS.

Yes, thanks!

Tycho

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
