Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 1CD8D6B0071
	for <linux-mm@kvack.org>; Tue, 23 Nov 2010 19:21:50 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id oAO0LlQG012090
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 24 Nov 2010 09:21:47 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id D76BE45DE7A
	for <linux-mm@kvack.org>; Wed, 24 Nov 2010 09:21:46 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id ACB7645DE7D
	for <linux-mm@kvack.org>; Wed, 24 Nov 2010 09:21:46 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 90E461DB8037
	for <linux-mm@kvack.org>; Wed, 24 Nov 2010 09:21:46 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 3F5981DB8040
	for <linux-mm@kvack.org>; Wed, 24 Nov 2010 09:21:46 +0900 (JST)
Date: Wed, 24 Nov 2010 09:15:57 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 2/4] alloc_contig_pages() find appropriate physical
 memory range
Message-Id: <20101124091557.2c59c88b.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <AANLkTinvmJNAXAKFbSZvhyPAbZsEW1eBY2YDkqvr5FF5@mail.gmail.com>
References: <20101119171033.a8d9dc8f.kamezawa.hiroyu@jp.fujitsu.com>
	<20101119171415.aa320cab.kamezawa.hiroyu@jp.fujitsu.com>
	<AANLkTinvmJNAXAKFbSZvhyPAbZsEW1eBY2YDkqvr5FF5@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Bob Liu <lliubbo@gmail.com>, fujita.tomonori@lab.ntt.co.jp, m.nazarewicz@samsung.com, pawel@osciak.com, andi.kleen@intel.com, felipe.contreras@gmail.com, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Mon, 22 Nov 2010 20:20:14 +0900
Minchan Kim <minchan.kim@gmail.com> wrote:

> On Fri, Nov 19, 2010 at 5:14 PM, KAMEZAWA Hiroyuki
> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> >
> > Unlike memory hotplug, at an allocation of contigous memory range, address
> > may not be a problem. IOW, if a requester of memory wants to allocate 100M of
> > of contigous memory, placement of allocated memory may not be a problem.
> > So, "finding a range of memory which seems to be MOVABLE" is required.
> >
> > This patch adds a functon to isolate a length of memory within [start, end).
> > This function returns a pfn which is 1st page of isolated contigous chunk
> > of given length within [start, end).
> >
> > If no_search=true is passed as argument, start address is always same to
> > the specified "base" addresss.
> >
> > After isolation, free memory within this area will never be allocated.
> > But some pages will remain as "Used/LRU" pages. They should be dropped by
> > page reclaim or migration.
> >
> > Changelog: 2010-11-17
> > A - fixed some conding style (if-then-else)
> >
> > Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > ---
> > A mm/page_isolation.c | A 146 ++++++++++++++++++++++++++++++++++++++++++++++++++++
> > A 1 file changed, 146 insertions(+)
> >
> > Index: mmotm-1117/mm/page_isolation.c
> > ===================================================================
> > --- mmotm-1117.orig/mm/page_isolation.c
> > +++ mmotm-1117/mm/page_isolation.c
> > @@ -7,6 +7,7 @@
> > A #include <linux/pageblock-flags.h>
> > A #include <linux/memcontrol.h>
> > A #include <linux/migrate.h>
> > +#include <linux/memory_hotplug.h>
> > A #include <linux/mm_inline.h>
> > A #include "internal.h"
> >
> > @@ -250,3 +251,148 @@ int do_migrate_range(unsigned long start
> > A out:
> > A  A  A  A return ret;
> > A }
> > +
> > +/*
> > + * Functions for getting contiguous MOVABLE pages in a zone.
> > + */
> > +struct page_range {
> > + A  A  A  unsigned long base; /* Base address of searching contigouous block */
> > + A  A  A  unsigned long end;
> > + A  A  A  unsigned long pages;/* Length of contiguous block */
> 
> Nitpick.
> You used nr_pages in other place.
> I hope you use the name consistent.
> 
Sure, I'll fix it.

> > + A  A  A  int align_order;
> > + A  A  A  unsigned long align_mask;
> 
> Does we really need this field 'align_mask'?

No.

> We can get always from align_order.
> 

Always  writes ((1 << align_order) -1) ? Hmm.


> > +};
> > +
> > +int __get_contig_block(unsigned long pfn, unsigned long nr_pages, void *arg)
> > +{
> > + A  A  A  struct page_range *blockinfo = arg;
> > + A  A  A  unsigned long end;
> > +
> > + A  A  A  end = pfn + nr_pages;
> > + A  A  A  pfn = ALIGN(pfn, 1 << blockinfo->align_order);
> > + A  A  A  end = end & ~(MAX_ORDER_NR_PAGES - 1);
> > +
> > + A  A  A  if (end < pfn)
> > + A  A  A  A  A  A  A  return 0;
> > + A  A  A  if (end - pfn >= blockinfo->pages) {
> > + A  A  A  A  A  A  A  blockinfo->base = pfn;
> > + A  A  A  A  A  A  A  blockinfo->end = end;
> > + A  A  A  A  A  A  A  return 1;
> > + A  A  A  }
> > + A  A  A  return 0;
> > +}
> > +
> > +static void __trim_zone(struct zone *zone, struct page_range *range)
> > +{
> > + A  A  A  unsigned long pfn;
> > + A  A  A  /*
> > + A  A  A  A * skip pages which dones'nt under the zone.
> 
> typo dones'nt -> doesn't :)
> 
will fix.

> > + A  A  A  A * There are some archs which zones are not in linear layout.
> > + A  A  A  A */
> > + A  A  A  if (page_zone(pfn_to_page(range->base)) != zone) {
> > + A  A  A  A  A  A  A  for (pfn = range->base;
> > + A  A  A  A  A  A  A  A  A  A  A  pfn < range->end;
> > + A  A  A  A  A  A  A  A  A  A  A  pfn += MAX_ORDER_NR_PAGES) {
> > + A  A  A  A  A  A  A  A  A  A  A  if (page_zone(pfn_to_page(pfn)) == zone)
> > + A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  break;
> > + A  A  A  A  A  A  A  }
> > + A  A  A  A  A  A  A  range->base = min(pfn, range->end);
> > + A  A  A  }
> > + A  A  A  /* Here, range-> base is in the zone if range->base != range->end */
> > + A  A  A  for (pfn = range->base;
> > + A  A  A  A  A  A pfn < range->end;
> > + A  A  A  A  A  A pfn += MAX_ORDER_NR_PAGES) {
> > + A  A  A  A  A  A  A  if (zone != page_zone(pfn_to_page(pfn))) {
> > + A  A  A  A  A  A  A  A  A  A  A  pfn = pfn - MAX_ORDER_NR_PAGES;
> > + A  A  A  A  A  A  A  A  A  A  A  break;
> > + A  A  A  A  A  A  A  }
> > + A  A  A  }
> > + A  A  A  range->end = min(pfn, range->end);
> > + A  A  A  return;
> 
> Remove return
> 
Ah, ok.

> > +}
> > +
> > +/*
> > + * This function is for finding a contiguous memory block which has length
> > + * of pages and MOVABLE. If it finds, make the range of pages as ISOLATED
> > + * and return the first page's pfn.
> > + * This checks all pages in the returned range is free of Pg_LRU. To reduce
> > + * the risk of false-positive testing, lru_add_drain_all() should be called
> > + * before this function to reduce pages on pagevec for zones.
> > + */
> > +
> > +static unsigned long find_contig_block(unsigned long base,
> > + A  A  A  A  A  A  A  unsigned long end, unsigned long pages,
> > + A  A  A  A  A  A  A  int align_order, struct zone *zone)
> > +{
> > + A  A  A  unsigned long pfn, pos;
> > + A  A  A  struct page_range blockinfo;
> > + A  A  A  int ret;
> > +
> > + A  A  A  VM_BUG_ON(pages & (MAX_ORDER_NR_PAGES - 1));
> > + A  A  A  VM_BUG_ON(base & ((1 << align_order) - 1));
> > +retry:
> > + A  A  A  blockinfo.base = base;
> > + A  A  A  blockinfo.end = end;
> > + A  A  A  blockinfo.pages = pages;
> > + A  A  A  blockinfo.align_order = align_order;
> > + A  A  A  blockinfo.align_mask = (1 << align_order) - 1;
> 
> We don't need this.
> 
mask ?

> > + A  A  A  /*
> > + A  A  A  A * At first, check physical page layout and skip memory holes.
> > + A  A  A  A */
> > + A  A  A  ret = walk_system_ram_range(base, end - base, &blockinfo,
> > + A  A  A  A  A  A  A  __get_contig_block);
> > + A  A  A  if (!ret)
> > + A  A  A  A  A  A  A  return 0;
> > + A  A  A  /* check contiguous pages in a zone */
> > + A  A  A  __trim_zone(zone, &blockinfo);
> > +
> > + A  A  A  /*
> > + A  A  A  A * Ok, we found contiguous memory chunk of size. Isolate it.
> > + A  A  A  A * We just search MAX_ORDER aligned range.
> > + A  A  A  A */
> > + A  A  A  for (pfn = blockinfo.base; pfn + pages <= blockinfo.end;
> > + A  A  A  A  A  A pfn += (1 << align_order)) {
> > + A  A  A  A  A  A  A  struct zone *z = page_zone(pfn_to_page(pfn));
> > + A  A  A  A  A  A  A  if (z != zone)
> > + A  A  A  A  A  A  A  A  A  A  A  continue;
> 
> Could we make sure pass __trim_zone is to satisfy whole pfn in zone
> what we want.
> Repeated the zone check is rather annoying.
> I mean let's __get_contig_block or __trim_zone already does check zone
> so that we remove the zone check in here.

Ah, yes. I'll remove this.

> 
> > +
> > + A  A  A  A  A  A  A  spin_lock_irq(&z->lock);
> > + A  A  A  A  A  A  A  pos = pfn;
> > + A  A  A  A  A  A  A  /*
> > + A  A  A  A  A  A  A  A * Check the range only contains free pages or LRU pages.
> > + A  A  A  A  A  A  A  A */
> > + A  A  A  A  A  A  A  while (pos < pfn + pages) {
> > + A  A  A  A  A  A  A  A  A  A  A  struct page *p;
> > +
> > + A  A  A  A  A  A  A  A  A  A  A  if (!pfn_valid_within(pos))
> > + A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  break;
> > + A  A  A  A  A  A  A  A  A  A  A  p = pfn_to_page(pos);
> > + A  A  A  A  A  A  A  A  A  A  A  if (PageReserved(p))
> > + A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  break;
> > + A  A  A  A  A  A  A  A  A  A  A  if (!page_count(p)) {
> > + A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  if (!PageBuddy(p))
> > + A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  pos++;
> > + A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  else
> > + A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  pos += (1 << page_order(p));
> > + A  A  A  A  A  A  A  A  A  A  A  } else if (PageLRU(p)) {
> 
> Could we check get_pageblock_migratetype(page) == MIGRATE_MOVABLE in
> here and early bail out?
> 

I'm not sure that's very good. pageblock-type can be fragmented and even
if pageblock-type is not MIGRATABLE, all pages in pageblock may be free.
Because PageLRU() is checked, all required 'quick' check is done,  I think.


> > + A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  pos++;
> > + A  A  A  A  A  A  A  A  A  A  A  } else
> > + A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  break;
> > + A  A  A  A  A  A  A  }
> > + A  A  A  A  A  A  A  spin_unlock_irq(&z->lock);
> > + A  A  A  A  A  A  A  if ((pos == pfn + pages)) {
> > + A  A  A  A  A  A  A  A  A  A  A  if (!start_isolate_page_range(pfn, pfn + pages))
> > + A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  return pfn;
> > + A  A  A  A  A  A  A  } else/* the chunk including "pos" should be skipped */
> > + A  A  A  A  A  A  A  A  A  A  A  pfn = pos & ~((1 << align_order) - 1);
> > + A  A  A  A  A  A  A  cond_resched();
> > + A  A  A  }
> > +
> > + A  A  A  /* failed */
> > + A  A  A  if (blockinfo.end + pages <= end) {
> > + A  A  A  A  A  A  A  /* Move base address and find the next block of RAM. */
> > + A  A  A  A  A  A  A  base = blockinfo.end;
> > + A  A  A  A  A  A  A  goto retry;
> > + A  A  A  }
> > + A  A  A  return 0;
> 
> If the base is 0, isn't it impossible return pfn 0?
> x86 in FLAT isn't impossible but I think some architecture might be possible.
> Just guessing.
> 
> How about returning negative value and return first page pfn and last
> page pfn as out parameter base, end?
> 

Hmm, will add a check.

Thanks,
-Kame


> > +}
> >
> >
> 
> 
> 
> -- 
> Kind regards,
> Minchan Kim
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
