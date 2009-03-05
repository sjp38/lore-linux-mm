Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id BC8286B00D4
	for <linux-mm@kvack.org>; Thu,  5 Mar 2009 17:59:40 -0500 (EST)
Date: Thu, 5 Mar 2009 22:59:21 +0000
From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [RFC] atomic highmem kmap page pinning
Message-ID: <20090305225921.GE918@n2100.arm.linux.org.uk>
References: <alpine.LFD.2.00.0903040014140.5511@xanadu.home> <20090304171429.c013013c.minchan.kim@barrios-desktop> <alpine.LFD.2.00.0903041101170.5511@xanadu.home> <20090305080717.f7832c63.minchan.kim@barrios-desktop> <alpine.LFD.2.00.0903042129140.5511@xanadu.home> <20090305132054.888396da.minchan.kim@barrios-desktop> <alpine.LFD.2.00.0903042350210.5511@xanadu.home> <28c262360903051423g1fbf5067i9835099d4bf324ae@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <28c262360903051423g1fbf5067i9835099d4bf324ae@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Nicolas Pitre <nico@cam.org>, lkml <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Fri, Mar 06, 2009 at 07:23:44AM +0900, Minchan Kim wrote:
> > +#ifdef ARCH_NEEDS_KMAP_HIGH_GET
> > +/**
> > + * kmap_high_get - pin a highmem page into memory
> > + * @page: &struct page to pin
> > + *
> > + * Returns the page's current virtual memory address, or NULL if no mapping
> > + * exists.  When and only when a non null address is returned then a
> > + * matching call to kunmap_high() is necessary.
> > + *
> > + * This can be called from any context.
> > + */
> > +void *kmap_high_get(struct page *page)
> > +{
> > +       unsigned long vaddr, flags;
> > +
> > +       spin_lock_kmap_any(flags);
> > +       vaddr = (unsigned long)page_address(page);
> > +       if (vaddr) {
> > +               BUG_ON(pkmap_count[PKMAP_NR(vaddr)] < 1);
> > +               pkmap_count[PKMAP_NR(vaddr)]++;
> > +       }
> > +       spin_unlock_kmap_any(flags);
> > +       return (void*) vaddr;
> > +}
> > +#endif
> 
> Let's add empty function for architecture of no ARCH_NEEDS_KMAP_HIGH_GET,

The reasoning being?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
