Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2248B6B02B4
	for <linux-mm@kvack.org>; Mon, 14 Aug 2017 16:28:47 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id k62so12214359oia.6
        for <linux-mm@kvack.org>; Mon, 14 Aug 2017 13:28:47 -0700 (PDT)
Received: from mail-it0-x231.google.com (mail-it0-x231.google.com. [2607:f8b0:4001:c0b::231])
        by mx.google.com with ESMTPS id f145si4995488oig.210.2017.08.14.13.28.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Aug 2017 13:28:46 -0700 (PDT)
Received: by mail-it0-x231.google.com with SMTP id 76so1056401ith.0
        for <linux-mm@kvack.org>; Mon, 14 Aug 2017 13:28:46 -0700 (PDT)
Date: Mon, 14 Aug 2017 14:28:44 -0600
From: Tycho Andersen <tycho@docker.com>
Subject: Re: [kernel-hardening] [PATCH v5 06/10] arm64/mm: Disable section
 mappings if XPFO is enabled
Message-ID: <20170814202844.f2ianjmwr3wl4bbh@smitten>
References: <20170809200755.11234-1-tycho@docker.com>
 <20170809200755.11234-7-tycho@docker.com>
 <f6a42032-d4e5-f488-3d55-1da4c8a4dbaf@redhat.com>
 <20170811211302.limmjv4rmq23b25b@smitten>
 <20170812111733.GA16374@remoulade>
 <20170814162219.h2lcmli677bx2lwh@smitten>
 <86105819-3ec6-e220-5ba3-787bbeecb6ba@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <86105819-3ec6-e220-5ba3-787bbeecb6ba@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laura Abbott <labbott@redhat.com>
Cc: Mark Rutland <mark.rutland@arm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-hardening@lists.openwall.com, Marco Benatto <marco.antonio.780@gmail.com>, Juerg Haefliger <juerg.haefliger@canonical.com>

On Mon, Aug 14, 2017 at 11:42:45AM -0700, Laura Abbott wrote:
> On 08/14/2017 09:22 AM, Tycho Andersen wrote:
> > On Sat, Aug 12, 2017 at 12:17:34PM +0100, Mark Rutland wrote:
> >> Hi,
> >>
> >> On Fri, Aug 11, 2017 at 03:13:02PM -0600, Tycho Andersen wrote:
> >>> On Fri, Aug 11, 2017 at 10:25:14AM -0700, Laura Abbott wrote:
> >>>> On 08/09/2017 01:07 PM, Tycho Andersen wrote:
> >>>>> @@ -190,7 +202,7 @@ static void init_pmd(pud_t *pud, unsigned long addr, unsigned long end,
> >>>>>  		next = pmd_addr_end(addr, end);
> >>>>>  
> >>>>>  		/* try section mapping first */
> >>>>> -		if (((addr | next | phys) & ~SECTION_MASK) == 0 &&
> >>>>> +		if (use_section_mapping(addr, next, phys) &&
> >>>>>  		    (flags & NO_BLOCK_MAPPINGS) == 0) {
> >>>>>  			pmd_set_huge(pmd, phys, prot);
> >>>>>  
> >>>>>
> >>>>
> >>>> There is already similar logic to disable section mappings for
> >>>> debug_pagealloc at the start of map_mem, can you take advantage
> >>>> of that?
> >>>
> >>> You're suggesting something like this instead? Seems to work fine.
> >>>
> >>> diff --git a/arch/arm64/mm/mmu.c b/arch/arm64/mm/mmu.c
> >>> index 38026b3ccb46..3b2c17bbbf12 100644
> >>> --- a/arch/arm64/mm/mmu.c
> >>> +++ b/arch/arm64/mm/mmu.c
> >>> @@ -434,6 +434,8 @@ static void __init map_mem(pgd_t *pgd)
> >>>  
> >>>  	if (debug_pagealloc_enabled())
> >>>  		flags = NO_BLOCK_MAPPINGS | NO_CONT_MAPPINGS;
> >>> +	if (IS_ENABLED(CONFIG_XPFO))
> >>> +		flags |= NO_BLOCK_MAPPINGS;
> >>>  
> >>
> >> IIUC, XPFO carves out individual pages just like DEBUG_PAGEALLOC, so you'll
> >> also need NO_CONT_MAPPINGS.
> > 
> > Yes, thanks!
> > 
> > Tycho
> > 
> 
> Setting NO_CONT_MAPPINGS fixes the TLB conflict aborts I was seeing
> on my machine.

Great, thanks for testing! I've also fixed the lookup_page_ext bug you
noted in the other thread.

Tycho

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
