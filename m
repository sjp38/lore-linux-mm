Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 5310E5F0047
	for <linux-mm@kvack.org>; Sun, 17 Oct 2010 20:40:55 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o9I0eq7A025430
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 18 Oct 2010 09:40:52 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 8FEFF45DE4E
	for <linux-mm@kvack.org>; Mon, 18 Oct 2010 09:40:52 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 6D72945DE4D
	for <linux-mm@kvack.org>; Mon, 18 Oct 2010 09:40:52 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 55AFA1DB8041
	for <linux-mm@kvack.org>; Mon, 18 Oct 2010 09:40:52 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 05DFC1DB804A
	for <linux-mm@kvack.org>; Mon, 18 Oct 2010 09:40:49 +0900 (JST)
Date: Mon, 18 Oct 2010 09:35:33 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 3/3] alloc contig pages with migration.
Message-Id: <20101018093533.abd4c8ee.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <AANLkTingNmxT6ww_VB_K=rjsgR+dHANLnyNkwV1Myvnk@mail.gmail.com>
References: <20101013121527.8ec6a769.kamezawa.hiroyu@jp.fujitsu.com>
	<20101013121829.c3320944.kamezawa.hiroyu@jp.fujitsu.com>
	<AANLkTingNmxT6ww_VB_K=rjsgR+dHANLnyNkwV1Myvnk@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Sun, 17 Oct 2010 13:05:22 +0900
Minchan Kim <minchan.kim@gmail.com> wrote:

> On Wed, Oct 13, 2010 at 12:18 PM, KAMEZAWA Hiroyuki
> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> >
> > Add an function to allocate contigous memory larger than MAX_ORDER.
> > The main difference between usual page allocater is that this uses
> > memory offline techiqueue (Isoalte pages and migrate remaining pages.).
> >
> > I think this is not 100% solution because we can't avoid fragmentation,
> > but we have kernelcore= boot option and can create MOVABLE zone. That
> > helps us to allow allocate a contigous range on demand.
> >
> > Maybe drivers can alloc contig pages by bootmem or hiding some memory
> > from the kernel at boot. But if contig pages are necessary only in some
> > situation, kernelcore= boot option and using page migration is a choice.
> >
> > Anyway, to allocate a contiguous chunk larger than MAX_ORDER, we need to
> > add an overlay allocator on buddy allocator. This can be a 1st step.
> >
> > Note:
> > This function is heavy if there are tons of memory requesters. So, maybe
> > not good for 1GB pages for x86's usual use. It will requires some other
> > tricks than migration.
> 
> I got found many typos but I don't pointed out each by each. :)
> Please, correct typos in next version.
> 
Sorry.

> >
> > TODO:
> > A - allows the caller to specify the migration target pages.
> > A - reduce the number of lru_add_drain_all()..etc...system wide heavy calls.
> > A - Pass gfp_t for some purpose...
> >
> > Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > ---
> > A include/linux/page-isolation.h | A  A 8 ++
> > A mm/page_alloc.c A  A  A  A  A  A  A  A | A  29 ++++++++
> > A mm/page_isolation.c A  A  A  A  A  A | A 136 +++++++++++++++++++++++++++++++++++++++++
> > A 3 files changed, 173 insertions(+)
> >
> > Index: mmotm-1008/mm/page_isolation.c
> > ===================================================================
> > --- mmotm-1008.orig/mm/page_isolation.c
> > +++ mmotm-1008/mm/page_isolation.c
> > @@ -7,6 +7,7 @@
> > A #include <linux/mm.h>
> > A #include <linux/page-isolation.h>
> > A #include <linux/pageblock-flags.h>
> > +#include <linux/swap.h>
> > A #include <linux/memcontrol.h>
> > A #include <linux/migrate.h>
> > A #include <linux/memory_hotplug.h>
> > @@ -384,3 +385,138 @@ retry:
> > A  A  A  A }
> > A  A  A  A return 0;
> > A }
> > +
> > +/**
> > + * alloc_contig_pages - allocate a contigous physical pages
> > + * @hint: A  A  A the base address of searching free space(in pfn)
> > + * @size: A  A  A size of requested area (in # of pages)
> 
> Could you add _range_ which can be specified by user into your TODO list?
> Maybe some embedded system have a requirement to allocate contiguous
> pages in some bank.
> so guys try to allocate pages in some base address and if it fails, he
> can try to next offset in same bank.
> But it's very annoying. So let's add feature that user can specify
> _range_ where user want to allocate.

Add [start, end) to the argument.

> 
> > + * @node: A  A  A  the node from which memory is allocated. "-1" means anywhere.
> > + * @no_search: if true, "hint" is not a hint, requirement.
> 
> As I said previous, how about "strict" or "ALLOC_FIXED" like MAP_FIXED?
> 

If "range" is an argument, ALLOC_FIXED is not necessary. I'll add "range".

> > + *
> > + * Search an area of @size in the physical memory map and checks wheter
> 
> Typo
> whether
> 
> > + * we can create a contigous free space. If it seems possible, try to
> > + * create contigous space with page migration. If no_search==true, we just try
> > + * to allocate [hint, hint+size) range of pages as contigous block.
> > + *
> > + * Returns a page of the beginning of contiguous block. At failure, NULL
> > + * is returned. Each page in the area is set to page_count() = 1. Because
> 
> Why do you mention page_count() = 1?
> Do users of this function have to know it?

A user can free any page within the range for his purpose.


> > + * this function does page migration, this function is very heavy and
> 
> Nitpick.
> page migration is implementation, too. Do we need to mention it in here?
> We might add page reclaim/or new feature in future or page migration
> might be very light function although it is not a easy. :)
> Let's not show the implementation for users.
> 

ok.



> > + * sleeps some time. Caller must be aware that "NULL returned" is not a
> > + * special case.
> 
> I think this information is enough to users.
> 
> > + *
> > + * Now, returned range is aligned to MAX_ORDER. (So "hint" must be aligned
> > + * if no_search==true.)
> 
> Couldn't we add handling of this exception?
> If (hint != MAX_ORDER_ALIGH(hint) && no_search == true)
>     return 0 or WARN_ON?
> 

I'll add "alignment" argument. (for 1G hugepage.)
and add the check.



> > + */
> > +
> > +#define MIGRATION_RETRY A  A  A  A (5)
> > +struct page *alloc_contig_pages(unsigned long hint, unsigned long size,
> > + A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  int node, bool no_search)
> > +{
> > + A  A  A  unsigned long base, found, end, pages, start;
> > + A  A  A  struct page *ret = NULL;
> > + A  A  A  int migration_failed;
> > + A  A  A  struct zone *zone;
> > +
> > + A  A  A  hint = MAX_ORDER_ALIGN(hint);
> > + A  A  A  /*
> > + A  A  A  A * request size should be aligned to pageblock_order..but use
> > + A  A  A  A * MAX_ORDER here for avoiding messy checks.
> > + A  A  A  A */
> > + A  A  A  pages = MAX_ORDER_ALIGN(size);
> > + A  A  A  found = 0;
> > +retry:
> > + A  A  A  for_each_populated_zone(zone) {
> > + A  A  A  A  A  A  A  unsigned long zone_end_pfn;
> > +
> > + A  A  A  A  A  A  A  if (node >= 0 && node != zone_to_nid(zone))
> > + A  A  A  A  A  A  A  A  A  A  A  continue;
> > + A  A  A  A  A  A  A  if (zone->present_pages < pages)
> > + A  A  A  A  A  A  A  A  A  A  A  continue;
> > + A  A  A  A  A  A  A  base = MAX_ORDER_ALIGN(zone->zone_start_pfn);
> > + A  A  A  A  A  A  A  base = max(base, hint);
> > + A  A  A  A  A  A  A  zone_end_pfn = zone->zone_start_pfn + zone->spanned_pages;
> > + A  A  A  A  A  A  A  if (base + pages > zone_end_pfn)
> > + A  A  A  A  A  A  A  A  A  A  A  continue;
> > + A  A  A  A  A  A  A  found = find_contig_block(base, zone_end_pfn, pages, no_search);
> > + A  A  A  A  A  A  A  /* Next try will see the next block. */
> > + A  A  A  A  A  A  A  hint = base + MAX_ORDER_NR_PAGES;
> > + A  A  A  A  A  A  A  if (found)
> > + A  A  A  A  A  A  A  A  A  A  A  break;
> > + A  A  A  }
> > +
> > + A  A  A  if (!found)
> > + A  A  A  A  A  A  A  return NULL;
> > +
> > + A  A  A  if (no_search && found != hint)
> 
> You increased hint before "break".
> So if the no_search is true, this condition (found != hint) is always true.
> 
Ah...yes.

> 
> > + A  A  A  A  A  A  A  return NULL;
> > +
> > + A  A  A  /*
> > + A  A  A  A * Ok, here, we have contiguous pageblock marked as "isolated"
> > + A  A  A  A * try migration.
> > + A  A  A  A *
> > + A  A  A  A * FIXME: permanent migration_failure detection logic is required.
> > + A  A  A  A */
> > + A  A  A  lru_add_drain_all();
> > + A  A  A  flush_scheduled_work();
> > + A  A  A  drain_all_pages();
> > +
> > + A  A  A  end = found + pages;
> > + A  A  A  /*
> > + A  A  A  A * scan_lru_pages() finds the next PG_lru page in the range
> > + A  A  A  A * scan_lru_pages() returns 0 when it reaches the end.
> > + A  A  A  A */
> > + A  A  A  for (start = scan_lru_pages(found, end), migration_failed = 0;
> > + A  A  A  A  A  A start && start < end;
> > + A  A  A  A  A  A start = scan_lru_pages(start, end)) {
> > + A  A  A  A  A  A  A  if (do_migrate_range(start, end)) {
> > + A  A  A  A  A  A  A  A  A  A  A  /* it's better to try another block ? */
> > + A  A  A  A  A  A  A  A  A  A  A  if (++migration_failed >= MIGRATION_RETRY)
> > + A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  break;
> > + A  A  A  A  A  A  A  A  A  A  A  /* take a rest and synchronize LRU etc. */
> > + A  A  A  A  A  A  A  A  A  A  A  lru_add_drain_all();
> > + A  A  A  A  A  A  A  A  A  A  A  flush_scheduled_work();
> > + A  A  A  A  A  A  A  A  A  A  A  cond_resched();
> > + A  A  A  A  A  A  A  A  A  A  A  drain_all_pages();
> > + A  A  A  A  A  A  A  } else /* reset migration_failure counter */
> > + A  A  A  A  A  A  A  A  A  A  A  migration_failed = 0;
> > + A  A  A  }
> > +
> > + A  A  A  lru_add_drain_all();
> > + A  A  A  flush_scheduled_work();
> > + A  A  A  drain_all_pages();
> 
> Hmm.. as you mentioned, It would be better to remove many flush lru/per-cpu.
> But in embedded system, it couldn't be a big overhead.
> 

I'll drop flush_scheduled_work().


> > + A  A  A  /* Check all pages are isolated */
> > + A  A  A  if (test_pages_isolated(found, end)) {
> > + A  A  A  A  A  A  A  undo_isolate_page_range(found, pages);
> > + A  A  A  A  A  A  A  /*
> > + A  A  A  A  A  A  A  A * We failed at [start...end) migration.
> > + A  A  A  A  A  A  A  A * FIXME: there may be better restaring point.
> > + A  A  A  A  A  A  A  A */
> > + A  A  A  A  A  A  A  hint = MAX_ORDER_ALIGN(end + 1);
> > + A  A  A  A  A  A  A  goto retry; /* goto next chunk */
> > + A  A  A  }
> > + A  A  A  /*
> > + A  A  A  A * Ok, here, [found...found+pages) memory are isolated.
> > + A  A  A  A * All pages in the range will be moved into the list with
> > + A  A  A  A * page_count(page)=1.
> > + A  A  A  A */
> > + A  A  A  ret = pfn_to_page(found);
> > + A  A  A  alloc_contig_freed_pages(found, found + pages);
> > + A  A  A  /* unset ISOLATE */
> > + A  A  A  undo_isolate_page_range(found, pages);
> > + A  A  A  /* Free unnecessary pages in tail */
> > + A  A  A  for (start = found + size; start < found + pages; start++)
> > + A  A  A  A  A  A  A  __free_page(pfn_to_page(start));
> > + A  A  A  return ret;
> > +
> > +}
> 
> Thanks for the good patches, Kame.
> 

Thank you for advices.

-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
