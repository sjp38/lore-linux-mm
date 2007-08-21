Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e2.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l7LMQec4028992
	for <linux-mm@kvack.org>; Tue, 21 Aug 2007 18:26:40 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l7LMQeT8489248
	for <linux-mm@kvack.org>; Tue, 21 Aug 2007 18:26:40 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l7LMQdY7012302
	for <linux-mm@kvack.org>; Tue, 21 Aug 2007 18:26:40 -0400
Subject: Re: [RFC][PATCH 9/9] pagemap: export swap ptes
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <20070821214944.GL30556@waste.org>
References: <20070821204248.0F506A29@kernel>
	 <20070821204259.1F6E8A44@kernel>  <20070821214944.GL30556@waste.org>
Content-Type: text/plain
Date: Tue, 21 Aug 2007 15:26:38 -0700
Message-Id: <1187735198.16177.117.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Matt Mackall <mpm@selenic.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 2007-08-21 at 16:49 -0500, Matt Mackall wrote:
> On Tue, Aug 21, 2007 at 01:42:59PM -0700, Dave Hansen wrote:
> > 
> > In addition to understanding which physical pages are
> > used by a process, it would also be very nice to
> > enumerate how much swap space a process is using.
> > 
> > This patch enables /proc/<pid>/pagemap to display
> > swap ptes.  In the process, it also changes the
> > constant that we used to indicate non-present ptes
> > before.
> 
> Nice. Can you update the doc comment on pagemap_read to match? 

Sure.

> > +unsigned long swap_pte_to_pagemap_entry(pte_t pte)
> > +{
> > +	unsigned long ret = 0;
> 
> Unused assignment?

Yep.  I'll kill that.

> > +	swp_entry_t entry = pte_to_swp_entry(pte);
> > +	unsigned long offset;
> > +	unsigned long swap_file_nr;
> > +
> > +	offset = swp_offset(entry);
> > +	swap_file_nr = swp_type(entry);
> > +	ret = PM_SWAP | swap_file_nr | (offset << MAX_SWAPFILES_SHIFT);
> > +	return ret;
> 
> How about just return <expression>?

I had intended to put some debugging in there, but I'll take it out for
now.

> This is a little problematic as we've added another not very visible
> magic number to the mix. We're also not masking off swp_offset to
> avoid colliding with our reserved bits. And we're also unpacking an
> arch-independent value (swp_entry_t) just to repack it in more or less
> the same shape? Or are we reversing the fields?

I did it that way because swp_entry_t is implemented as an opaque type,
and we don't have any real guarantees that it will stay in its current
format, or that it will truly _stay_ arch independent, or not change
format.  All we know is that running swp_offset/type() on it will get us
the offset and swap file.

> >  static int pagemap_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end,
> >  			     void *private)
> >  {
> > @@ -549,7 +570,9 @@ static int pagemap_pte_range(pmd_t *pmd,
> >  	pte = pte_offset_map(pmd, addr);
> >  	for (; addr != end; pte++, addr += PAGE_SIZE) {
> >  		unsigned long pfn = PM_NOT_PRESENT;
> > -		if (pte_present(*pte))
> > +		if (is_swap_pte(*pte))
> 
> Hmm, unlikely?

I tend to reserve unlikely()s for performance critical regions of code
or in other cases where I know the compiler is being really stupid.  I
don't think this one is horribly performance critical.  This whole
little section of code looks to me to be ~22 bytes on i386.  It'll fit
in a cacheline. :)

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
