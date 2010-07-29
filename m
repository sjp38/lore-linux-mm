Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 3F7A26B02A4
	for <linux-mm@kvack.org>; Thu, 29 Jul 2010 12:19:07 -0400 (EDT)
Received: by pvc30 with SMTP id 30so194716pvc.14
        for <linux-mm@kvack.org>; Thu, 29 Jul 2010 09:19:05 -0700 (PDT)
Date: Fri, 30 Jul 2010 01:18:56 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [PATCH] Tight check of pfn_valid on sparsemem - v4
Message-ID: <20100729161856.GA16420@barrios-desktop>
References: <pfn.valid.v4.reply.2@mdm.bga.com>
 <20100727171351.98d5fb60.kamezawa.hiroyu@jp.fujitsu.com>
 <AANLkTikCsGHshU8v86SQiuO+UZBCbdjOKN=GyJFPb7rY@mail.gmail.com>
 <alpine.DEB.2.00.1007270929290.28648@router.home>
 <AANLkTinXmkaX38pLjSBCRUS-c84GqpUE7xJQFDDHDLCC@mail.gmail.com>
 <alpine.DEB.2.00.1007281005440.21717@router.home>
 <20100728155617.GA5401@barrios-desktop>
 <alpine.DEB.2.00.1007281158150.21717@router.home>
 <20100728225756.GA6108@barrios-desktop>
 <alpine.DEB.2.00.1007291038100.16510@router.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1007291038100.16510@router.home>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Milton Miller <miltonm@bga.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Russell King <linux@arm.linux.org.uk>, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>, Kukjin Kim <kgene.kim@samsung.com>
List-ID: <linux-mm.kvack.org>

On Thu, Jul 29, 2010 at 10:46:13AM -0500, Christoph Lameter wrote:
> On Thu, 29 Jul 2010, Minchan Kim wrote:
> 
> > On Wed, Jul 28, 2010 at 12:02:16PM -0500, Christoph Lameter wrote:
> > > On Thu, 29 Jul 2010, Minchan Kim wrote:
> > > > invalid memmap pages will be freed by free_memmap and will be used
> > > > on any place. How do we make sure it has PG_reserved?
> > >
> > > Not present memmap pages make pfn_valid fail already since there is no
> > > entry for the page table (vmemmap) or blocks are missing in the sparsemem
> > > tables.
> > >
> > > > Maybe I don't understand your point.
> > >
> > > I thought we are worrying about holes in the memmap blocks containing page
> > > structs. Some page structs point to valid pages and some are not. The
> > > invalid page structs need to be marked consistently to allow the check.
> >
> > The thing is that memmap pages which contains struct page array on hole will be
> > freed by free_memmap in ARM. Please loot at arch/arm/mm/init.c.
> > And it will be used by page allocator as free pages.
> 
> Arg thats the solution to the mystery. freememmap() is arm specific hack!
> 
> Sparsemem allows you to properly handle holes already and then pfn_valid
> will work correctly.
> 
> Why are the ways to manage holes in the core not used by arm?

I did use ARCH_HAS_HOLES_MEMORYMODEL.
It is used by only ARM now. 
If you disable the config, it doesn't affect the core. 

> 
> sparsemem does a table lookup to determine valid and invalid sections of
> the memmp.
> 
The thing is valid section also have a invalid memmap. 
Maybe my description isn't enough. 
Please look at description and following URL. 

We already confirmed this problem. 
http://www.spinics.net/lists/arm-kernel/msg92918.html

== CUT HERE ==

Kukjin reported oops happen while he change min_free_kbytes
http://www.spinics.net/lists/arm-kernel/msg92894.html
It happen by memory map on sparsemem.

The system has a memory map following as.
     section 0             section 1              section 2
     0x20000000-0x25000000, 0x40000000-0x50000000, 0x50000000-0x58000000
     SECTION_SIZE_BITS 28(256M)

     It means section 0 is an incompletely filled section.
     Nontheless, current pfn_valid of sparsemem checks pfn loosely.
     It checks only mem_section's validation but ARM can free mem_map on hole
     to save memory space. So in above case, pfn on 0x25000000 can pass pfn_valid's
     validation check. It's not what we want.




-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
