Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id B614A6B02A4
	for <linux-mm@kvack.org>; Tue, 20 Jul 2010 11:57:49 -0400 (EDT)
Received: by pwi8 with SMTP id 8so2630497pwi.14
        for <linux-mm@kvack.org>; Tue, 20 Jul 2010 08:57:48 -0700 (PDT)
Date: Wed, 21 Jul 2010 00:57:32 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [PATCH] Tight check of pfn_valid on sparsemem - v2
Message-ID: <20100720155732.GA1940@barrios-desktop>
References: <1279448311-29788-1-git-send-email-minchan.kim@gmail.com>
 <20100720101557.GD16031@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100720101557.GD16031@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Russell King <linux@arm.linux.org.uk>, Mel Gorman <mel@csn.ul.ie>, linux-mm <linux-mm@kvack.org>, linux-arm-kernel <linux-arm-kernel@lists.infradead.org>, LKML <linux-kernel@vger.kernel.org>, Kukjin Kim <kgene.kim@samsung.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Tue, Jul 20, 2010 at 12:15:58PM +0200, Johannes Weiner wrote:
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
> > to save memory space. So in above case, pfn on 0x25000000 can pass pfn_valid's 
> > validation check. It's not what we want.
> >
> > We can match section size to smallest valid size.(ex, above case, 16M)
> > But Russell doesn't like it due to mem_section's memory overhead with different
> > configuration(ex, 512K section).
> >
> > I tried to add valid pfn range in mem_section but everyone doesn't like it 
> > due to size overhead. This patch is suggested by KAMEZAWA-san. 
> > I just fixed compile error and change some naming.
> 
> I did not like it, because it messes up the whole concept of a
> section.

Yes. but ARM already have broken it.
So we can't ignore it. 

> 
> But most importantly, we already have a crutch for ARM in place,
> namely memmap_valid_within().  Looking at Kukjin's bug report,
> wouldn't it be enough to use that check in
> setup_zone_migrate_reserve()?

I did it.
But I think it's not a fundamental solution.
It would make new bad rule which whole pfn walker should call 
memmap_valid_within. 

I just greped "grep -nRH 'start_pfn' mm/'.
If we add it in setup_zone_migration_reserve, look at kmemleak(kmemleak_scan)
compaction(isolate_migratepages) and so on. I am not sure how many there are.
I doubt they have a same problem in setup_zone_migrate_pages.
Should we add memmap_valid_within whenever whole pfn walker does?

> 
> Your approach makes every pfn_valid() more expensive, although the
> extensive checks are not not needed everywhere (check the comment
> above memmap_valid_within): vm_normal_page() for example can probably
> assume that a PTE won't point to a hole within the memory map.

I agree. But I think it's trade-off of architecture have memmap hole.
They want to use such model which don't meet sparsemem's disign
so that it's cost they have to pay.
In fact, All we mm guys don't want to use such model, but ARM has been 
used such model, so we can't ignore them. So I want to care them but doesn't
affect non-hole architecure of memmap. 
In terms of such point, this patch doesn't have a overhead 
in non-hole architecture and it doesn't make new rule as I said above.
Also, hole architecture developers don't need to override pfn_valid to detect
hole pfn range. 

> 
> OTOH, if the ARM people do not care, we could probably go with your
> approach, encode it all into pfn_valid(), and also get rid of
> memmap_valid_within() completely.  But I would prefer doing a bugfix
> first and such a conceptual change in a different patch, would you
> agree?

Hmm, I am not sure. memmap_valid_within problem can happen in only sparemem?
AFAIR, the problem can happen in punched hole(not either side hole) of FLATMEM?
If it is right, maybe we should expand this patch 
to CONFIG_ARCH_HAS_HOLES_MEMORYMODEL not CONFIG_SPARSEMEM.

And I think this patch just checks validation of memmap not page's itself 
validiation. If one page in memmap has mixed(valid or non-valid) struct page 
descriptors,  it can't  identify it. So pfn walker need to check PageReserved 
in addition to pfn_valid. But as I review above example, some cases
doesn't check it. but it's a another story we have to fix. 

Thanks for careful review, Hannes. :)

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
