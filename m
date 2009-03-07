Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 9B69E6B0098
	for <linux-mm@kvack.org>; Sat,  7 Mar 2009 17:28:08 -0500 (EST)
MIME-version: 1.0
Content-type: multipart/mixed; boundary="Boundary_(ID_RmyCTKauB8SMf2Y07KcbGA)"
Received: from xanadu.home ([66.131.194.97]) by VL-MO-MR005.ip.videotron.ca
 (Sun Java(tm) System Messaging Server 6.3-4.01 (built Aug  3 2007; 32bit))
 with ESMTP id <0KG500DHMQD9SBR0@VL-MO-MR005.ip.videotron.ca> for
 linux-mm@kvack.org; Sat, 07 Mar 2009 17:27:09 -0500 (EST)
Date: Sat, 07 Mar 2009 17:28:06 -0500 (EST)
From: Nicolas Pitre <nico@cam.org>
Subject: Re: [RFC] atomic highmem kmap page pinning
In-reply-to: <28c262360903051514n53e54df8x935aa398e16795ce@mail.gmail.com>
Message-id: <alpine.LFD.2.00.0903071721040.30483@xanadu.home>
References: <alpine.LFD.2.00.0903040014140.5511@xanadu.home>
 <20090304171429.c013013c.minchan.kim@barrios-desktop>
 <alpine.LFD.2.00.0903041101170.5511@xanadu.home>
 <20090305080717.f7832c63.minchan.kim@barrios-desktop>
 <alpine.LFD.2.00.0903042129140.5511@xanadu.home>
 <20090305132054.888396da.minchan.kim@barrios-desktop>
 <alpine.LFD.2.00.0903042350210.5511@xanadu.home>
 <28c262360903051423g1fbf5067i9835099d4bf324ae@mail.gmail.com>
 <20090305225921.GE918@n2100.arm.linux.org.uk>
 <28c262360903051514n53e54df8x935aa398e16795ce@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Russell King - ARM Linux <linux@arm.linux.org.uk>, lkml <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

--Boundary_(ID_RmyCTKauB8SMf2Y07KcbGA)
Content-type: TEXT/PLAIN; charset=UTF-8
Content-transfer-encoding: 8BIT

On Fri, 6 Mar 2009, Minchan Kim wrote:

> On Fri, Mar 6, 2009 at 7:59 AM, Russell King - ARM Linux
> <linux@arm.linux.org.uk> wrote:
> > On Fri, Mar 06, 2009 at 07:23:44AM +0900, Minchan Kim wrote:
> >> > +#ifdef ARCH_NEEDS_KMAP_HIGH_GET
> >> > +/**
> >> > + * kmap_high_get - pin a highmem page into memory
> >> > + * @page: &struct page to pin
> >> > + *
> >> > + * Returns the page's current virtual memory address, or NULL if no mapping
> >> > + * exists. A When and only when a non null address is returned then a
> >> > + * matching call to kunmap_high() is necessary.
> >> > + *
> >> > + * This can be called from any context.
> >> > + */
> >> > +void *kmap_high_get(struct page *page)
> >> > +{
> >> > + A  A  A  unsigned long vaddr, flags;
> >> > +
> >> > + A  A  A  spin_lock_kmap_any(flags);
> >> > + A  A  A  vaddr = (unsigned long)page_address(page);
> >> > + A  A  A  if (vaddr) {
> >> > + A  A  A  A  A  A  A  BUG_ON(pkmap_count[PKMAP_NR(vaddr)] < 1);
> >> > + A  A  A  A  A  A  A  pkmap_count[PKMAP_NR(vaddr)]++;
> >> > + A  A  A  }
> >> > + A  A  A  spin_unlock_kmap_any(flags);
> >> > + A  A  A  return (void*) vaddr;
> >> > +}
> >> > +#endif
> >>
> >> Let's add empty function for architecture of no ARCH_NEEDS_KMAP_HIGH_GET,
> >
> > The reasoning being?
> 
> I thought it can be used in common arm function.
> so, for VIVT, it can be work but for VIPT, it can be nulled as
> preventing compile error.

The issue is not about VIVT vs VIPT, but rather about the fact that IO 
transactions don't snoop the cache.  So this is needed even for current 
VIPT implementations.

> But, I don't know where we use kmap_high_get since I didn't see any
> patch which use it.
> If it is only used architecture specific place,  pz, forgot my comment.

Yes, that's the case.  And it is much preferable to have a compilation 
error than providing an empty stub to silently mask out misuses.


Nicolas

--Boundary_(ID_RmyCTKauB8SMf2Y07KcbGA)--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
