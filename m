Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 727216B02A4
	for <linux-mm@kvack.org>; Wed, 11 Aug 2010 11:31:44 -0400 (EDT)
Received: from d01relay01.pok.ibm.com (d01relay01.pok.ibm.com [9.56.227.233])
	by e4.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id o7BFH6xG019026
	for <linux-mm@kvack.org>; Wed, 11 Aug 2010 11:17:06 -0400
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay01.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o7BFVbT0367240
	for <linux-mm@kvack.org>; Wed, 11 Aug 2010 11:31:39 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id o7BFVWJv013469
	for <linux-mm@kvack.org>; Wed, 11 Aug 2010 12:31:34 -0300
Subject: Re: [PATCH] Tight check of pfn_valid on sparsemem - v4
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <20100731103849.GH23886@n2100.arm.linux.org.uk>
References: <alpine.DEB.2.00.1007281158150.21717@router.home>
	 <20100728225756.GA6108@barrios-desktop>
	 <alpine.DEB.2.00.1007291038100.16510@router.home>
	 <20100729161856.GA16420@barrios-desktop>
	 <alpine.DEB.2.00.1007291132210.17734@router.home>
	 <20100729170313.GB16420@barrios-desktop>
	 <alpine.DEB.2.00.1007291222410.17734@router.home>
	 <20100729183320.GH18923@n2100.arm.linux.org.uk>
	 <1280436919.16922.11246.camel@nimitz>
	 <AANLkTi=DpH=vmUK84KhvOMgP=KL+YxXD0UhiJE+VRJyg@mail.gmail.com>
	 <20100731103849.GH23886@n2100.arm.linux.org.uk>
Content-Type: text/plain; charset="ANSI_X3.4-1968"
Date: Wed, 11 Aug 2010 08:31:29 -0700
Message-ID: <1281540689.6988.50.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Cc: Minchan Kim <minchan.kim@gmail.com>, Christoph Lameter <cl@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Milton Miller <miltonm@bga.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>, Kukjin Kim <kgene.kim@samsung.com>
List-ID: <linux-mm.kvack.org>

On Sat, 2010-07-31 at 11:38 +0100, Russell King - ARM Linux wrote:
> On Fri, Jul 30, 2010 at 06:32:04PM +0900, Minchan Kim wrote:
> > On Fri, Jul 30, 2010 at 5:55 AM, Dave Hansen <dave@linux.vnet.ibm.com> wrote:
> > > If you free up parts of the mem_map[] array, how does the buddy
> > > allocator still work?  I thought we required at 'struct page's to be
> > > contiguous and present for at least 2^MAX_ORDER-1 pages in one go.
> 
> (Dave, I don't seem to have your mail to reply to.)
> 
> What you say is correct, and memory banks as a rule of thumb tend to be
> powers of two.
> 
> We do have the ability to change MAX_ORDER (which we need to do for some
> platforms where there's only 1MB of DMA-able memory.)
> 
> However, in the case of two 512KB banks, the buddy allocator won't try
> to satisfy a 1MB request as it'll only have two separate 2x512K free
> 'pages' to deal with, and 0x1M free 'pages'.

Right, it won't try to _coalesce_ those pages, but it will go trying to
look for the freed page's buddy in the empty area.  This is probably a
pretty rare issue, but I think it's real.  Take a look at
__free_one_page():

...
        while (order < MAX_ORDER-1) {
                buddy = __page_find_buddy(page, page_idx, order);
                if (!page_is_buddy(page, buddy, order))
                        break;

We look at the page, and the order of the page that just got freed.  We
go looking to see whether the page's buddy at this order is in the buddy
system, and _that_ tells us whether a coalesce can be done.  However, we
do this with some funky math on the original page's 'struct page *':

static inline struct page *
__page_find_buddy(struct page *page, unsigned long page_idx, unsigned int order)
{
        unsigned long buddy_idx = page_idx ^ (1 << order);

        return page + (buddy_idx - page_idx);
}

That relies on all 'struct pages' within the current 2^MAX_ORDER to be
virtually contiguous.  If you free up section_mem_map[] 'struct page'
blocks within the MAX_ORDER, the free'd page's buddy's 'struct page'
might fall in the area that got freed.  In that case, you'll get an
effectively random PageBuddy() value, and might mistakenly coalesce the
page.

In practice with a 1MB MAX_ORDER and 512KB banks, it'll only happen if
you free the page representing the entire 512KB bank, and if the memory
for the other half 'struct page' has already gotten reused.  That's
probably why you've never seen it.

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
