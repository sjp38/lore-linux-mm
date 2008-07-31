Date: Thu, 31 Jul 2008 14:22:13 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: memory hotplug: hot-remove fails on lowest chunk in ZONE_MOVABLE
Message-ID: <20080731132213.GF1704@csn.ul.ie>
References: <20080723105318.81BC.E1E9C6FF@jp.fujitsu.com> <1217347653.4829.17.camel@localhost.localdomain> <20080730110444.27DE.E1E9C6FF@jp.fujitsu.com> <1217420161.4545.10.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <1217420161.4545.10.camel@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Gerald Schaefer <gerald.schaefer@de.ibm.com>
Cc: Yasunori Goto <y-goto@jp.fujitsu.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Dave Hansen <haveblue@us.ibm.com>, Andy Whitcroft <apw@shadowen.org>, Christoph Lameter <cl@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, Peter Zijlstra <peterz@infradead.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On (30/07/08 14:16), Gerald Schaefer didst pronounce:
> On Wed, 2008-07-30 at 12:16 +0900, Yasunori Goto wrote:
> > Well, I didn't mean changing pages_min value. There may be side effect as
> > you are saying.
> > I meant if some pages were MIGRATE_RESERVE attribute when hot-remove are
> > -executing-, their attribute should be changed.
> > 
> > For example, how is like following dummy code?  Is it impossible?
> > (Not only here, some places will have to be modified..)
> 
> Right, this should be possible. I was somewhat wandering from the subject,
> because I noticed that there may be a bigger problem with MIGRATE_RESERVE
> pages in ZONE_MOVABLE, and that we may not want to have them in the first
> place.
> 

MIGRATE_RESERVE is of large importance to ZONE_DMA32 and ZONE_NORMAL, to
a much lesser extent to ZONE_HIGHMEM and almost irrevelant to
ZONE_MOVABLE. However, nothing about MIGRATE_RESERVE should prevent the
hot-remove of the section. If the section is totally free, it is
considered removable according to is_mem_section_removable(). If other
parts of memory hot-remove are deliberately ignoring the RESERVE
sections, they should stop that.

I haven't read the whole thread, but in your original mail, you say that
ZONE_MOVABLE is populated by memory hot-add. Are there really PageReserved()
pages there? If so, is there any chance or other management structures
are being allocated within the section you are hot-adding? If so and they
are not getting freed, that might be why hot-remove is failing. If they
are not PageReserved() pages and this is an -mm kernel, I would enable
CONFIG_PAGE_OWNER and see who really reallocated those problem pages that
are not freeing.

> The more memory we add to ZONE_MOVABLE, the less reserved pages will
> remain to the other zones. In setup_per_zone_pages_min(), min_free_kbytes
> will be redistributed to a zone where the kernel cannot make any use of
> it, effectively reducing the available min_free_kbytes. 

I'm not sure what you mean by "available min_free_kbytes". The overall value
for min_free_kbytes should be approximately the same whether the zone exists
or not. However, you're right in that the distribution of minimum free pages
changes with ZONE_MOVABLE because the zones are different sizes now. This
affects reclaim, not memory hot-remove.

> This just doesn't
> sound right. I believe that a similar situation is the reason why highmem
> pages are skipped in the calculation and I think that we need that for
> ZONE_MOVABLE too. Any thoughts on that problem?
> 

is_highmem(ZONE_MOVABLE) should be returning true if the zone is really
part of himem.

> Setting pages_min to 0 for ZONE_MOVABLE, while not capping pages_low
> and pages_high, could be an option. I don't have a sufficient memory
> managment overview to tell if that has negative side effects, maybe
> someone with a deeper insight could comment on that.
> 

pages_min of 0 means the other values would be 0 as well. This means that
kswapd may never be woken up to free pages within that zone and lead to
poor utilisation of the zone as allocators fallback to other zones to
avoid direct reclaim. I don't think that is your intention nor will it
help memory hot-remove.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
