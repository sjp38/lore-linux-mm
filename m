Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 6C76F6B0169
	for <linux-mm@kvack.org>; Thu,  4 Aug 2011 06:09:36 -0400 (EDT)
Date: Thu, 4 Aug 2011 11:09:28 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH] ARM: sparsemem: Enable CONFIG_HOLES_IN_ZONE config
 option for SparseMem and HAS_HOLES_MEMORYMODEL for linux-3.0.
Message-ID: <20110804100928.GN19099@suse.de>
References: <CAFPAmTQByL0YJT8Lvar1Oe+3Q1EREvqPA_GP=hHApJDz5dSOzQ@mail.gmail.com>
 <20110803110555.GD19099@suse.de>
 <CAFPAmTR79S3AVXrAFL5bMkhs2droL8THUCCPY23Ar5x_oftheQ@mail.gmail.com>
 <20110803132839.GG19099@suse.de>
 <CAFPAmTS2JEVk3tWhJN034dUmaxLujswmmsqGABGYEV=N3v0Ehw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <CAFPAmTS2JEVk3tWhJN034dUmaxLujswmmsqGABGYEV=N3v0Ehw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kautuk Consul <consul.kautuk@gmail.com>
Cc: Russell King <rmk@arm.linux.org.uk>, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org

On Thu, Aug 04, 2011 at 03:06:39PM +0530, Kautuk Consul wrote:
> Hi Mel,
> 
> My ARM system has 2 memory banks which have the following 2 PFN ranges:
> 60000-62000 and 70000-7ce00.
> 
> My SECTION_SIZE_BITS is #defined to 23.
> 

So bank 0 is 4 sections and bank 1 is 26 sections with the last section
incomplete.

> I am altering the ranges via the following kind of pseudo-code in the
> arch/arm/mach-*/mach-*.c file:
> meminfo->bank[0].size -= (1 << 20)
> meminfo->bank[1].size -= (1 << 20)
> 

Why are you taking 1M off each bank? I could understand aligning the
banks to a section size at least.

That said, there is an assumption that pages within a MAX_ORDER-aligned
block. If you are taking 1M off the end of bank 0, it is no longer
MAX_ORDER aligned. This is the assumption move_freepages_block()
is falling foul of. The problem can be avoided by ensuring that memmap
is valid within MAX_ORDER-aligned ranges.

> After altering the size of both memory banks, the PFN ranges now
> visible to the kernel are:
> 60000-61f00 and 70000-7cd00.
> 
> There is only one node and one ZONE_NORMAL zone on the system and this
> zone accounts for both memory banks as CONFIG_SPARSEMEM
> is enabled in the kernel.
> 

Ok.

> I put some printks in the move_freeblockpages() function, compiled the
> kernel and then ran the following commands:
> ifconfig eth0 107.109.39.102 up
> mount /dev/sda1 /mnt   # Mounted the USB pen drive
> mount -t nfs -o nolock 107.109.39.103:/home/kautuk nfsmnt   # NFS
> mounted an NFS share
> cp test_huge_file nfsmnt/
> 
> I got the following output:
> #> cp test_huge nfsmnt/
> ------------------------------------------------------------move_freepages_block_start----------------------------------------
> kc: The page=c068a000 start_pfn=7c400 start_page=c0686000
> end_page=c068dfe0 end_pfn=7c7ff
> page_zone(start_page)=c048107c page_zone(end_page)=c048107c
> page_zonenum(end_page) = 0
> ------------------------------------------------------------move_freepages_block_end----------------------------------------
> ------------------------------------------------------------move_freepages_block_start----------------------------------------
> kc: The page=c0652000 start_pfn=7a800 start_page=c064e000
> end_page=c0655fe0 end_pfn=7abff
> page_zone(start_page)=c048107c page_zone(end_page)=c048107c
> page_zonenum(end_page) = 0
> ------------------------------------------------------------move_freepages_block_end----------------------------------------
> ------------------------------------------------------------move_freepages_block_start----------------------------------------
> kc: The page=c065a000 start_pfn=7ac00 start_page=c0656000
> end_page=c065dfe0 end_pfn=7afff
> page_zone(start_page)=c048107c page_zone(end_page)=c048107c
> page_zonenum(end_page) = 0
> ------------------------------------------------------------move_freepages_block_end----------------------------------------
> ------------------------------------------------------------move_freepages_block_start----------------------------------------
> kc: The page=c0695000 start_pfn=7c800 start_page=c068e000
> end_page=c0695fe0 end_pfn=7cbff
> page_zone(start_page)=c048107c page_zone(end_page)=c048107c
> page_zonenum(end_page) = 0
> ------------------------------------------------------------move_freepages_block_end----------------------------------------
> ------------------------------------------------------------move_freepages_block_start----------------------------------------
> kc: The page=c04f7c00 start_pfn=61c00 start_page=c04f6000
> end_page=c04fdfe0 end_pfn=61fff
> page_zone(start_page)=c048107c page_zone(end_page)=c0481358
> page_zonenum(end_page) = 1
> ------------------------------------------------------------move_freepages_block_end----------------------------------------
> kernel BUG at mm/page_alloc.c:849!
> Unable to handle kernel NULL pointer dereference at virtual address 00000000
> pgd = ce9fc000
> [00000000] *pgd=7ca5a031, *pte=00000000, *ppte=00000000
> 
> As per the last line, we can clearly see that the
> page_zone(start_page)=c048107c and page_zone(end_page)=c0481358,
> which are not equal to each other.
> Since they do not match, the code in move_freepages() bugchecks
> because of the following BUG_ON() check:
> page_zone(start_page) != page_zone(end_page)

> The reason for this that the page_zonenum(end_page) is equal to 1 and
> this is different from the page_zonenum(start_page) which is 0.
> 

Because the MAX_ORDER alignment is gone.

> On checking the code within page_zonenum(), I see that this code tries
> to retrieve the zone number from the end_page->flags.
> 

Yes. In the majority of cases a pages node and zone is stored in the
page->flags.

> The reason why we cannot expect the 0x61fff end_page->flags to contain
> a valid zone number is:
> memmap_init_zone() initializes the zone number of all pages for a zone
> via the set_page_links() inline function.
> For the end_page (whose PFN is 0x61fff), set_page_links() cannot be
> possibly called, as the zones are simply not aware of of PFNs above
> 0x61f00 and below 0x70000.
> 

Can you ensure that the ranges passed into free_area_init_node()
are MAX_ORDER aligned as this would initialise the struct pages. You
may have already seen that care is taken when freeing memmap that it
is aligned to MAX_ORDER in free_unused_memmap() in ARM.

> The (end >= zone->zone_start_pfn + zone->spanned_pages) in
> move_freepages_block() does not stop this crash from happening as both
> our memory banks are in the same zone and the empty space within them
> is accomodated into this zone via the CONFIG_SPARSEMEM
> config option.
> 
> When we enable CONFIG_HOLES_IN_ZONE we survive this BUG_ON as well as
> any other BUG_ONs in the loop in move_freepages() as then the
> pfn_valid_within()/pfn_valid() function takes care of this
> functionality, especially in the case where the newly introduced
> CONFIG_HAVE_ARCH_PFN_VALID is
> enabled.
> 

This is an expensive option in terms of performance. If Russell
wants to pick it up, I won't object but I would strongly suggest that
you solve this problem by ensuring that memmap is initialised on a
MAX_ORDER-aligned boundaries as it'll perform better.

Thanks.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
