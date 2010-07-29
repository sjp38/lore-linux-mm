Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 14A546B02A4
	for <linux-mm@kvack.org>; Thu, 29 Jul 2010 11:46:17 -0400 (EDT)
Date: Thu, 29 Jul 2010 10:46:13 -0500 (CDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH] Tight check of pfn_valid on sparsemem - v4
In-Reply-To: <20100728225756.GA6108@barrios-desktop>
Message-ID: <alpine.DEB.2.00.1007291038100.16510@router.home>
References: <pfn.valid.v4.reply.1@mdm.bga.com> <AANLkTimtTVvorrR9pDVTyPKj0HbYOYY3aR7B-QWGhTei@mail.gmail.com> <pfn.valid.v4.reply.2@mdm.bga.com> <20100727171351.98d5fb60.kamezawa.hiroyu@jp.fujitsu.com> <AANLkTikCsGHshU8v86SQiuO+UZBCbdjOKN=GyJFPb7rY@mail.gmail.com>
 <alpine.DEB.2.00.1007270929290.28648@router.home> <AANLkTinXmkaX38pLjSBCRUS-c84GqpUE7xJQFDDHDLCC@mail.gmail.com> <alpine.DEB.2.00.1007281005440.21717@router.home> <20100728155617.GA5401@barrios-desktop> <alpine.DEB.2.00.1007281158150.21717@router.home>
 <20100728225756.GA6108@barrios-desktop>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Milton Miller <miltonm@bga.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Russell King <linux@arm.linux.org.uk>, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>, Kukjin Kim <kgene.kim@samsung.com>
List-ID: <linux-mm.kvack.org>

On Thu, 29 Jul 2010, Minchan Kim wrote:

> On Wed, Jul 28, 2010 at 12:02:16PM -0500, Christoph Lameter wrote:
> > On Thu, 29 Jul 2010, Minchan Kim wrote:
> > > invalid memmap pages will be freed by free_memmap and will be used
> > > on any place. How do we make sure it has PG_reserved?
> >
> > Not present memmap pages make pfn_valid fail already since there is no
> > entry for the page table (vmemmap) or blocks are missing in the sparsemem
> > tables.
> >
> > > Maybe I don't understand your point.
> >
> > I thought we are worrying about holes in the memmap blocks containing page
> > structs. Some page structs point to valid pages and some are not. The
> > invalid page structs need to be marked consistently to allow the check.
>
> The thing is that memmap pages which contains struct page array on hole will be
> freed by free_memmap in ARM. Please loot at arch/arm/mm/init.c.
> And it will be used by page allocator as free pages.

Arg thats the solution to the mystery. freememmap() is arm specific hack!

Sparsemem allows you to properly handle holes already and then pfn_valid
will work correctly.

Why are the ways to manage holes in the core not used by arm?

sparsemem does a table lookup to determine valid and invalid sections of
the memmp.

from include/linux/mmzone.h:

static inline int pfn_valid(unsigned long pfn)
{
        if (pfn_to_section_nr(pfn) >= NR_MEM_SECTIONS)
                return 0;
        return valid_section(__nr_to_section(pfn_to_section_nr(pfn)));
}


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
