Date: Wed, 30 Jul 2008 12:16:52 +0900
From: Yasunori Goto <y-goto@jp.fujitsu.com>
Subject: Re: memory hotplug: hot-remove fails on lowest chunk in ZONE_MOVABLE
In-Reply-To: <1217347653.4829.17.camel@localhost.localdomain>
References: <20080723105318.81BC.E1E9C6FF@jp.fujitsu.com> <1217347653.4829.17.camel@localhost.localdomain>
Message-Id: <20080730110444.27DE.E1E9C6FF@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Gerald Schaefer <gerald.schaefer@de.ibm.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Dave Hansen <haveblue@us.ibm.com>, Andy Whitcroft <apw@shadowen.org>, Christoph Lameter <cl@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, Peter Zijlstra <peterz@infradead.org>
List-ID: <linux-mm.kvack.org>

> On Wed, 2008-07-23 at 11:48 +0900, Yasunori Goto wrote:
> > > Memory hot-remove of the lowest memory chunk in ZONE_MOVABLE will fail
> > > because of some reserved pages at the beginning of each zone
> > > (MIGRATE_RESERVED).
> > > 
> > I believe you are right. Current hot-remove code is NOT perfect.
> > You may remove some sections, but may not other sections,
> > because there are some un-removable pages by some reasons
> > (not only MIGRATE_RESERVED).
> > 
> > I think MIGRATE_RESERVED pages should be move to MIGRATE_MOVABLE when 
> > those pages must be removed, and should recalculate MIGRATE_RESERVED pages.
> 
> Hi,
> 
> Would it be an option to set pages_min to 0 for ZONE_MOVABLE in
> setup_per_zone_pages_min()? This would avoid the MIGRATE_RESERVED vs.
> MIGRATE_MOVABLE conflict on memory hot-remove. If I understand it
> correctly, the kernel wouldn't be able to use the reserved pages in
> ZONE_MOVABLE for __GFP_HIGH and PF_MEMALLOC allocations anyway, right?
> 
> At the moment, ZONE_MOVABLE pages will also account for the lowmem_pages
> calculation in setup_per_zone_pages_min(). The recalculation will then
> redistribute and reduce the amount of reserved pages for the other zones.
> Won't this effectively reduce the amount of reserved min_free_kbytes memory
> that is available to the kernel, even getting worse the more memory is
> added to ZONE_MOVABLE?
> 
> With the following patch, ZONE_MOVABLE will be skipped for the
> lowmem_pages calculation, just like it is already done for highmem.
> It will also set pages_min to 0 for ZONE_MOVABLE. But I have an uneasy
> feeling about this, because I may be missing side effects from this.
> Any opinions?

Well, I didn't mean changing pages_min value. There may be side effect as
you are saying.
I meant if some pages were MIGRATE_RESERVE attribute when hot-remove are
-executing-, their attribute should be changed.

For example, how is like following dummy code?  Is it impossible?
(Not only here, some places will have to be modified..)

Thanks.

---
 mm/page_alloc.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

Index: current/mm/page_alloc.c
===================================================================
--- current.orig/mm/page_alloc.c        2008-07-29 22:17:54.000000000 +0900
+++ current/mm/page_alloc.c     2008-07-30 12:04:03.000000000 +0900
@@ -4828,7 +4828,9 @@ int set_migratetype_isolate(struct page
        /*
         * In future, more migrate types will be able to be isolation target.
         */
-       if (get_pageblock_migratetype(page) != MIGRATE_MOVABLE)
+       if ((get_pageblock_migratetype(page) != MIGRATE_MOVABLE) ||
+           !((removing section is the last section on the zone) &&
+             get_pageblock_migratetype(page) == MIGRATE_RESREVE))
                goto out;
        set_pageblock_migratetype(page, MIGRATE_ISOLATE);
        move_freepages_block(zone, page, MIGRATE_ISOLATE);


-- 
Yasunori Goto 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
