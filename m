Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 082AF6B024D
	for <linux-mm@kvack.org>; Tue, 20 Jul 2010 08:49:42 -0400 (EDT)
Received: from epmmp1 (mailout1.samsung.com [203.254.224.24])
 by mailout1.samsung.com
 (Sun Java(tm) System Messaging Server 7u3-15.01 64bit (built Feb 12 2010))
 with ESMTP id <0L5U00CPHWYS4AB0@mailout1.samsung.com> for linux-mm@kvack.org;
 Tue, 20 Jul 2010 21:49:40 +0900 (KST)
Received: from kgenekim ([12.23.103.96])
 by mmp1.samsung.com (iPlanet Messaging Server 5.2 Patch 2 (built Jul 14 2004))
 with ESMTPA id <0L5U00AONWYSTC@mmp1.samsung.com> for linux-mm@kvack.org; Tue,
 20 Jul 2010 21:49:40 +0900 (KST)
Date: Tue, 20 Jul 2010 21:49:45 +0900
From: Kukjin Kim <kgene.kim@samsung.com>
Subject: RE: [PATCH] Tight check of pfn_valid on sparsemem - v2
In-reply-to: <20100720101557.GD16031@cmpxchg.org>
Message-id: <004201cb280a$0b15e780$2141b680$%kim@samsung.com>
MIME-version: 1.0
Content-type: text/plain; charset=US-ASCII
Content-language: ko
Content-transfer-encoding: 7BIT
References: <1279448311-29788-1-git-send-email-minchan.kim@gmail.com>
 <20100720101557.GD16031@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
To: 'Johannes Weiner' <hannes@cmpxchg.org>, 'Minchan Kim' <minchan.kim@gmail.com>
Cc: 'Andrew Morton' <akpm@linux-foundation.org>, 'Russell King' <linux@arm.linux.org.uk>, 'Mel Gorman' <mel@csn.ul.ie>, 'linux-mm' <linux-mm@kvack.org>, 'linux-arm-kernel' <linux-arm-kernel@lists.infradead.org>, 'LKML' <linux-kernel@vger.kernel.org>, 'KAMEZAWA Hiroyuki' <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Johannes Weiner wrote:
> 
> Hi,
> 
> On Sun, Jul 18, 2010 at 07:18:31PM +0900, Minchan Kim wrote:
> > Kukjin reported oops happen while he change min_free_kbytes
> > http://www.spinics.net/lists/arm-kernel/msg92894.html
> > It happen by memory map on sparsemem.
> >
> > The system has a memory map following as.
> >      section 0             section 1              section 2
> > 0x20000000-0x25000000, 0x40000000-0x50000000, 0x50000000-0x58000000
> > SECTION_SIZE_BITS 28(256M)
> >
> > It means section 0 is an incompletely filled section.
> > Nontheless, current pfn_valid of sparsemem checks pfn loosely.
> > It checks only mem_section's validation but ARM can free mem_map on hole
> > to save memory space. So in above case, pfn on 0x25000000 can pass
> pfn_valid's
> > validation check. It's not what we want.
> >
> > We can match section size to smallest valid size.(ex, above case, 16M)
> > But Russell doesn't like it due to mem_section's memory overhead with
different
> > configuration(ex, 512K section).
> >
> > I tried to add valid pfn range in mem_section but everyone doesn't like
it
> > due to size overhead. This patch is suggested by KAMEZAWA-san.
> > I just fixed compile error and change some naming.
> 
> I did not like it, because it messes up the whole concept of a
> section.
> 
> But most importantly, we already have a crutch for ARM in place,
> namely memmap_valid_within().  Looking at Kukjin's bug report,
> wouldn't it be enough to use that check in
> setup_zone_migrate_reserve()?
> 
> Your approach makes every pfn_valid() more expensive, although the
> extensive checks are not not needed everywhere (check the comment
> above memmap_valid_within): vm_normal_page() for example can probably
> assume that a PTE won't point to a hole within the memory map.
> 
> OTOH, if the ARM people do not care, we could probably go with your
> approach, encode it all into pfn_valid(), and also get rid of
> memmap_valid_within() completely.  But I would prefer doing a bugfix
> first and such a conceptual change in a different patch, would you
> agree?
> 
> Kukjin, does the appended patch also fix your problem?
> 
Yes, did not happen problem with your patch.

But already Minchan requested test on the board with same patch.

And you can find it in following thread about that.
http://lists.infradead.org/pipermail/linux-arm-kernel/2010-July/020199.html

I'm not sure which approach is better to us right now.

Hmm...

Thanks.

Best regards,
Kgene.
--
Kukjin Kim <kgene.kim@samsung.com>, Senior Engineer,
SW Solution Development Team, Samsung Electronics Co., Ltd.

> 	Hannes
> 
> ---
> From: Johannes Weiner <hannes@cmpxchg.org>
> Subject: mm: check mem_map backing in setup_zone_migrate_reserve
> 
> Kukjin encountered kernel oopsen when changing
> /proc/sys/vm/min_free_kbytes.  The problem is that his sparse memory
> layout on ARM is the following:
> 
>      section 0             section 1              section 2
> 0x20000000-0x25000000, 0x40000000-0x50000000, 0x50000000-0x58000000
> SECTION_SIZE_BITS 28(256M)
> 
> where there is a memory hole at the end of section 0.
> 
> Since section 0 has _some_ memory, pfn_valid() will return true for
> all PFNs in this section.  But ARM releases the mem_map pages of this
> hole and pfn_valid() alone is not enough anymore to ensure there is a
> valid page struct behind a PFN.
> 
> We acknowledged that ARM does this already and have a function to
> double-check for mem_map in cases where we do PFN range walks (as
> opposed to coming from a page table entry, which should not point to a
> memory hole in the first place e.g.).
> 
> setup_zone_migrate_reserve() contains one such range walk which does
> not have the extra check and was also the cause of the oopsen Kukjin
> encountered.
> 
> This patch adds the needed memmap_valid_within() check.
> 
> Reported-by: Kukjin Kim <kgene.kim@samsung.com>
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> ---
> 
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 0b0b629..cb6d6d3 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -3168,6 +3168,10 @@ static void setup_zone_migrate_reserve(struct zone
> *zone)
>  			continue;
>  		page = pfn_to_page(pfn);
> 
> +		/* Watch out for holes in the memory map */
> +		if (!memmap_valid_within(pfn, page, zone))
> +			continue;
> +
>  		/* Watch out for overlapping nodes */
>  		if (page_to_nid(page) != zone_to_nid(zone))
>  			continue;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
