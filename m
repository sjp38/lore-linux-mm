Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 791F46B02D8
	for <linux-mm@kvack.org>; Wed, 20 Sep 2017 18:47:43 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id 93so6843544iol.2
        for <linux-mm@kvack.org>; Wed, 20 Sep 2017 15:47:43 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id p185sor8287oih.126.2017.09.20.15.47.42
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 20 Sep 2017 15:47:42 -0700 (PDT)
Date: Wed, 20 Sep 2017 16:47:39 -0600
From: Tycho Andersen <tycho@docker.com>
Subject: Re: [PATCH v5 03/10] swiotlb: Map the buffer if it was unmapped by
 XPFO
Message-ID: <20170920224739.3kgzmntabmkedohw@smitten>
References: <20170809200755.11234-1-tycho@docker.com>
 <20170809200755.11234-4-tycho@docker.com>
 <5877eed8-0e8e-0dec-fdc7-de01bdbdafa8@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5877eed8-0e8e-0dec-fdc7-de01bdbdafa8@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@intel.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-hardening@lists.openwall.com, Marco Benatto <marco.antonio.780@gmail.com>, Juerg Haefliger <juerg.haefliger@canonical.com>, Juerg Haefliger <juerg.haefliger@hpe.com>

On Wed, Sep 20, 2017 at 09:19:56AM -0700, Dave Hansen wrote:
> On 08/09/2017 01:07 PM, Tycho Andersen wrote:
> > --- a/lib/swiotlb.c
> > +++ b/lib/swiotlb.c
> > @@ -420,8 +420,9 @@ static void swiotlb_bounce(phys_addr_t orig_addr, phys_addr_t tlb_addr,
> >  {
> >  	unsigned long pfn = PFN_DOWN(orig_addr);
> >  	unsigned char *vaddr = phys_to_virt(tlb_addr);
> > +	struct page *page = pfn_to_page(pfn);
> >  
> > -	if (PageHighMem(pfn_to_page(pfn))) {
> > +	if (PageHighMem(page) || xpfo_page_is_unmapped(page)) {
> >  		/* The buffer does not have a mapping.  Map it in and copy */
> >  		unsigned int offset = orig_addr & ~PAGE_MASK;
> >  		char *buffer;
> 
> This is a little scary.  I wonder how many more of these are in the
> kernel, like:

I don't know, but I assume several :)

> > static inline void *skcipher_map(struct scatter_walk *walk)
> > {
> >         struct page *page = scatterwalk_page(walk);
> > 
> >         return (PageHighMem(page) ? kmap_atomic(page) : page_address(page)) +
> >                offset_in_page(walk->offset);
> > }
> 
> Is there any better way to catch these?  Like, can we add some debugging
> to check for XPFO pages in __va()?

Yes, and perhaps also a debugging check in PageHighMem? Would __va
have caught either of the two cases you've pointed out?

Tycho

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
