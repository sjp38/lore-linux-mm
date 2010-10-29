Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id CE7038D0030
	for <linux-mm@kvack.org>; Fri, 29 Oct 2010 00:06:28 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o9T46QQY006384
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 29 Oct 2010 13:06:26 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id CEA3645DE55
	for <linux-mm@kvack.org>; Fri, 29 Oct 2010 13:06:25 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id B03E245DE51
	for <linux-mm@kvack.org>; Fri, 29 Oct 2010 13:06:25 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 9A9151DB803A
	for <linux-mm@kvack.org>; Fri, 29 Oct 2010 13:06:25 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.249.87.103])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 43880E08001
	for <linux-mm@kvack.org>; Fri, 29 Oct 2010 13:06:22 +0900 (JST)
Date: Fri, 29 Oct 2010 13:00:49 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 2/3] a help function for find physically contiguous
 block.
Message-Id: <20101029130049.5818fbce.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <AANLkTikffUvWeD9Pgt_wSug_MjXo1vxr61KhUcdtHxLk@mail.gmail.com>
References: <20101026190042.57f30338.kamezawa.hiroyu@jp.fujitsu.com>
	<20101026190458.4e1c0d98.kamezawa.hiroyu@jp.fujitsu.com>
	<AANLkTikffUvWeD9Pgt_wSug_MjXo1vxr61KhUcdtHxLk@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: Bob Liu <lliubbo@gmail.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>, andi.kleen@intel.com, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, fujita.tomonori@lab.ntt.co.jp, felipe.contreras@gmail.com
List-ID: <linux-mm.kvack.org>

Thank you for review.

On Fri, 29 Oct 2010 11:53:18 +0800
Bob Liu <lliubbo@gmail.com> wrote:

> On Tue, Oct 26, 2010 at 6:04 PM, KAMEZAWA Hiroyuki
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
> > After isolation, free memory within this area will never be allocated.
> > But some pages will remain as "Used/LRU" pages. They should be dropped by
> > page reclaim or migration.
> >
> > Changelog:
> > A - zone is added to the argument.
> > A - fixed a case that zones are not in linear.
> > A - added zone->lock.
> >
> >
> > Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > ---
> > A mm/page_isolation.c | A 148 ++++++++++++++++++++++++++++++++++++++++++++++++++++
> > A 1 file changed, 148 insertions(+)
> >
> > Index: mmotm-1024/mm/page_isolation.c
> > ===================================================================
> > --- mmotm-1024.orig/mm/page_isolation.c
> > +++ mmotm-1024/mm/page_isolation.c
> > @@ -7,6 +7,7 @@
> > A #include <linux/pageblock-flags.h>
> > A #include <linux/memcontrol.h>
> > A #include <linux/migrate.h>
> > +#include <linux/memory_hotplug.h>
> > A #include <linux/mm_inline.h>
> > A #include "internal.h"
> >
> > @@ -250,3 +251,150 @@ int do_migrate_range(unsigned long start
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
> > + A  A  A  int align_order;
> > + A  A  A  unsigned long align_mask;
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
> > + A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  else if (PageBuddy(p)) {
> 
> just else is okay?
> 
yes.


> > + A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  int order = page_order(p);
> > + A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  pos += (1 << order);
> > + A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  }
> > + A  A  A  A  A  A  A  A  A  A  A  } else if (PageLRU(p)) {
> > + A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  pos++;
> > + A  A  A  A  A  A  A  A  A  A  A  } else
> > + A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  break;
> > + A  A  A  A  A  A  A  }
> > + A  A  A  A  A  A  A  spin_unlock_irq(&z->lock);
> > + A  A  A  A  A  A  A  if ((pos == pfn + pages) &&
> > + A  A  A  A  A  A  A  A  A  A  A  !start_isolate_page_range(pfn, pfn + pages))
> > + A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  return pfn;
> > + A  A  A  A  A  A  A  if (pos & ((1 << align_order) - 1))
> > + A  A  A  A  A  A  A  A  A  A  A  pfn = ALIGN(pos, (1 << align_order));
> > + A  A  A  A  A  A  A  else
> > + A  A  A  A  A  A  A  A  A  A  A  pfn = pos + (1 << align_order);
> 
> pfn has changed here, then why the for loop still need pfn += (1 <<
> align_order))?
> or maybe I missed something.
> 
you'r right. I'll fix.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
