Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id E560A6B0169
	for <linux-mm@kvack.org>; Fri,  5 Aug 2011 04:47:47 -0400 (EDT)
Date: Fri, 5 Aug 2011 09:47:42 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH] ARM: sparsemem: Enable CONFIG_HOLES_IN_ZONE config
 option for SparseMem and HAS_HOLES_MEMORYMODEL for linux-3.0.
Message-ID: <20110805084742.GU19099@suse.de>
References: <CAFPAmTQByL0YJT8Lvar1Oe+3Q1EREvqPA_GP=hHApJDz5dSOzQ@mail.gmail.com>
 <20110803110555.GD19099@suse.de>
 <CAFPAmTR79S3AVXrAFL5bMkhs2droL8THUCCPY23Ar5x_oftheQ@mail.gmail.com>
 <20110803132839.GG19099@suse.de>
 <CAFPAmTS2JEVk3tWhJN034dUmaxLujswmmsqGABGYEV=N3v0Ehw@mail.gmail.com>
 <20110804100928.GN19099@suse.de>
 <CAFPAmTQir8HnP2=WwPGSaWFu=hBS9=xT88f+XFFx5Hdf6zvGTA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <CAFPAmTQir8HnP2=WwPGSaWFu=hBS9=xT88f+XFFx5Hdf6zvGTA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kautuk Consul <consul.kautuk@gmail.com>
Cc: Russell King <rmk@arm.linux.org.uk>, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org

On Fri, Aug 05, 2011 at 11:27:21AM +0530, Kautuk Consul wrote:
> Hi Mel,
> 
> Please find my comments inline to the email below.
> 
> 2 general questions:
> i)    If an email chain such as this leads to another kernel patch for
> the same problem, do I need to
>       create a new email chain for that ?

Yes. I believe it's easier on the maintainer if a new thread is started
with the new patch leader summarising relevant information from the
discussion. A happy maintainer makes the day easier.

> ii)  Sorry about my formatting problems. However, text such as
> backtraces and logs tend to wrap
>       irrespective of whatever gmail settings/browser I try. Any
> pointers here ?
> 

I don't use gmail so I do not have any suggestions other than using a
different mailer. There are no suggestions in
Documentation/email-clients.txt on how to deal with gmail.

> On Thu, Aug 4, 2011 at 3:39 PM, Mel Gorman <mgorman@suse.de> wrote:
> > On Thu, Aug 04, 2011 at 03:06:39PM +0530, Kautuk Consul wrote:
> >> Hi Mel,
> >>
> >> My ARM system has 2 memory banks which have the following 2 PFN ranges:
> >> 60000-62000 and 70000-7ce00.
> >>
> >> My SECTION_SIZE_BITS is #defined to 23.
> >>
> >
> > So bank 0 is 4 sections and bank 1 is 26 sections with the last section
> > incomplete.
> >
> >> I am altering the ranges via the following kind of pseudo-code in the
> >> arch/arm/mach-*/mach-*.c file:
> >> meminfo->bank[0].size -= (1 << 20)
> >> meminfo->bank[1].size -= (1 << 20)
> >>
> >
> > Why are you taking 1M off each bank? I could understand aligning the
> > banks to a section size at least.
> 
> The reason I am doing this is that one of our embedded boards actually
> has this problem, due
> to which we see this kernel crash. I am merely reproducing this
> problem by performing this step.
> 

Ah, that makes sense.

> >> <SNIP>
> >> The reason why we cannot expect the 0x61fff end_page->flags to contain
> >> a valid zone number is:
> >> memmap_init_zone() initializes the zone number of all pages for a zone
> >> via the set_page_links() inline function.
> >> For the end_page (whose PFN is 0x61fff), set_page_links() cannot be
> >> possibly called, as the zones are simply not aware of of PFNs above
> >> 0x61f00 and below 0x70000.
> >>
> >
> > Can you ensure that the ranges passed into free_area_init_node()
> > are MAX_ORDER aligned as this would initialise the struct pages. You
> > may have already seen that care is taken when freeing memmap that it
> > is aligned to MAX_ORDER in free_unused_memmap() in ARM.
> >
> 
> Will this work ? My doubt arises from the fact that there is only one
> zone on the entire
> system which contains both memory banks.

That is a common situation. It's why present_pages and spanned_pages
in a zone can differ. As long as valid memmap is MAX_ORDER-aligned, it's
fine.

> The crash arises at the PFN 0x61fff, which will not be covered by such
> a check, as this function

No, it won't be covered by the range check. However, the memmap will be
initialised so even though the page is outside a valid bank of memory,
it'll still resolve to the correct zone. The struct page will be marked
Reserved so it'll never be used.

> will try to act on the entire zone, which is the PFN range:
> 60000-7cd00, including the holes within as
> all of this RAM falls into the same node and zone.
> ( Please correct me if I am wrong about this. )
> 
> I tried aligning the end parameter in the memory_present() function
> which is called separately
> for each memory bank.
> I tried the following change in memory_present() as well as
> mminit_validate_memodel_limits():
> end &= ~(pageblock_nr_pages-1);
> But, in this case, the board simply does not boot up. I think that
> will then require some change in the
> arch/arm code which I think would be an arch-specific solution to a
> possibly generic problem.
> 

I do not believe this is a generic problem. Machines have
holes in the zone all the time and this bug does not trigger.
mminit_validate_memodel_limits() is the wrong place to make a change.
Look more towards where free_area_init_node() gets called to initialise
memmap.

> >> The (end >= zone->zone_start_pfn + zone->spanned_pages) in
> >> move_freepages_block() does not stop this crash from happening as both
> >> our memory banks are in the same zone and the empty space within them
> >> is accomodated into this zone via the CONFIG_SPARSEMEM
> >> config option.
> >>
> >> When we enable CONFIG_HOLES_IN_ZONE we survive this BUG_ON as well as
> >> any other BUG_ONs in the loop in move_freepages() as then the
> >> pfn_valid_within()/pfn_valid() function takes care of this
> >> functionality, especially in the case where the newly introduced
> >> CONFIG_HAVE_ARCH_PFN_VALID is
> >> enabled.
> >>
> >
> > This is an expensive option in terms of performance. If Russell
> > wants to pick it up, I won't object but I would strongly suggest that
> > you solve this problem by ensuring that memmap is initialised on a
> > MAX_ORDER-aligned boundaries as it'll perform better.
> >
> 
> I couldn't really locate a method in the kernel wherein we can
> validate a pageblock(1024 pages for my
> platform) with respect to the memory banks on that system.
> 

I suspect what you're looking for is somewhere in arch/arm/mm/init.c .
I'm afraid I didn't dig through the ARM memory initialisation
code to see where it could be done but if it was me, I'd be looking at
how free_area_init_node() is called.

> How about this :
> We implement an arch_is_valid_pageblock() function, controlled by a
> new config option
> CONFIG_ARCH_HAVE IS_VALID_PAGEBLOCK.
> This arch function will simply check whether this pageblock is valid
> or not, in terms of arch-specific
> memory banks or by using the memblock APIs depending on CONFIG_HAVE_MEMBLOCK.
> We can modify the memmap_init_zone() function so that an outer loop
> works in measures of
> pageblocks thus enabling us to avoid invalid pageblocks.

That seems like massive overkill for what should be an alignment problem
when initialisating memmap. It's adding complexity that is similar to
HOLES_IN_ZONE with very little gain.

When it gets down to it, I'd even prefer deleting the BUG_ON as
the PageBuddy check over such a solution. However, the BUG_ON is
there because alignment to MAX_ORDER is expected so it is a valid
sanity check. There would need to be good evidence that initialising
memmap to MAX_ORDER alignment was somehow impossible.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
