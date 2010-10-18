Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id BBDF86B0131
	for <linux-mm@kvack.org>; Sun, 17 Oct 2010 20:34:40 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp ([10.0.50.71])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o9I0Ybl6019600
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Mon, 18 Oct 2010 09:34:38 +0900
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id B896D45DE4E
	for <linux-mm@kvack.org>; Mon, 18 Oct 2010 09:34:37 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 93F5545DE4F
	for <linux-mm@kvack.org>; Mon, 18 Oct 2010 09:34:37 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 78EF71DB804C
	for <linux-mm@kvack.org>; Mon, 18 Oct 2010 09:34:37 +0900 (JST)
Received: from m105.s.css.fujitsu.com (m105.s.css.fujitsu.com [10.249.87.105])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 247511DB804D
	for <linux-mm@kvack.org>; Mon, 18 Oct 2010 09:34:37 +0900 (JST)
Date: Mon, 18 Oct 2010 09:29:20 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 2/3] find a contiguous range.
Message-Id: <20101018092920.b039f6ae.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <AANLkTikCZBLufoL7pH8LKSRZRzOeH0z508PwJ5KwyE-5@mail.gmail.com>
References: <20101013121527.8ec6a769.kamezawa.hiroyu@jp.fujitsu.com>
	<20101013121738.933ff002.kamezawa.hiroyu@jp.fujitsu.com>
	<AANLkTikCZBLufoL7pH8LKSRZRzOeH0z508PwJ5KwyE-5@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Sun, 17 Oct 2010 12:18:48 +0900
Minchan Kim <minchan.kim@gmail.com> wrote:

> Hi Kame,
> Sorry for the late review.
> 
> On Wed, Oct 13, 2010 at 12:17 PM, KAMEZAWA Hiroyuki
> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> >
> > Unlike memory hotplug, at an allocation of contigous memory range, address
> > may not be a problem. IOW, if a requester of memory wants to allocate 100M of
> > of contigous memory, placement of allocated memory may not be a problem.
> > So, "finding a range of memory which seems to be MOVABLE" is required.
> >
> > This patch adds a functon to isolate a length of memory within [start, end).
> 
> Typo
> function
> 
> > This function returns a pfn which is 1st page of isolated contigous chunk
> 
> Typo
> contiguous
> 
I'll use aspell...


> > of given length within [start, end).
> >
> > If no_search=true is passed as argument, start address is always same to
> 
> I don't like no_search argument name. It would be better to show not
> the implement but context.
> How about "bool strict" or "ALLOC_FIXED"?

Hmm, ok. 

> > the specified "base" addresss.
> Typo
> address,
> Let's add following description.
> "Some devices want to bind memory to some memory bank. In this case,
> no_search and base address fix
> can be helpful."

Then, do you need "end" address for search ?


> 
> >
> > After isolation, free memory within this area will never be allocated.
> > But some pages will remain as "Used/LRU" pages. They should be dropped by
> > page reclaim or migration.
> 
> At first I saw the above description, I got confused. How about this?

> After it isolates some pages in the range, the part of some pages are
> freed but others could be used processes now.
> Next patch[3/3] try to move or reclaim used pages by page
> migration/reclaim for obtaining big contiguous page.
> 

will consider some.


> >
> >
> > Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > ---
> > A mm/page_isolation.c | A 130 ++++++++++++++++++++++++++++++++++++++++++++++++++++
> > A 1 file changed, 130 insertions(+)
> >
> > Index: mmotm-1008/mm/page_isolation.c
> > ===================================================================
> > --- mmotm-1008.orig/mm/page_isolation.c
> > +++ mmotm-1008/mm/page_isolation.c
> > @@ -9,6 +9,7 @@
> > A #include <linux/pageblock-flags.h>
> > A #include <linux/memcontrol.h>
> > A #include <linux/migrate.h>
> > +#include <linux/memory_hotplug.h>
> > A #include <linux/mm_inline.h>
> > A #include "internal.h"
> >
> > @@ -254,3 +255,132 @@ out:
> > A  A  A  A return ret;
> > A }
> >
> > +/*
> > + * Functions for getting contiguous MOVABLE pages in a zone.
> > + */
> > +struct page_range {
> > + A  A  A  unsigned long base; /* Base address of searching contigouous block */
> 
> Typo contiguous.
> Please, specify that it's a pfn number.
> 
ok.

> > + A  A  A  unsigned long end;
> > + A  A  A  unsigned long pages;/* Length of contiguous block */
> > +};
> > +
> > +static inline unsigned long A MAX_ORDER_ALIGN(unsigned long x)
> > +{
> > + A  A  A  return ALIGN(x, MAX_ORDER_NR_PAGES);
> > +}
> > +
> > +static inline unsigned long MAX_ORDER_BASE(unsigned long x)
> > +{
> > + A  A  A  return x & ~(MAX_ORDER_NR_PAGES - 1);
> > +}
> > +
> > +int __get_contig_block(unsigned long pfn, unsigned long nr_pages, void *arg)
> > +{
> > + A  A  A  struct page_range *blockinfo = arg;
> > + A  A  A  unsigned long end;
> > +
> > + A  A  A  end = pfn + nr_pages;
> > + A  A  A  pfn = MAX_ORDER_ALIGN(pfn);
> > + A  A  A  end = MAX_ORDER_BASE(end);
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
> > +static void __trim_zone(struct page_range *range)
> 
> Hmm..
> I think this function name can't present enough meaning.
> Let's move description in body of function to the head.
> 
> /*
>  * In most case, each zone's [start_pfn, end_pfn) has no
>  * overlap between each other. But some arch allows it and
>  * we need to check it here. If it happens, range end is changed
>  * to only include pfns in a zone.
>  */

ok.

> 
> > +{
> > + A  A  A  struct zone *zone;
> > + A  A  A  unsigned long pfn;
> > + A  A  A  /*
> > + A  A  A  A * In most case, each zone's [start_pfn, end_pfn) has no
> > + A  A  A  A * overlap between each other. But some arch allows it and
> > + A  A  A  A * we need to check it here.
> > + A  A  A  A */
> > + A  A  A  for (pfn = range->base, zone = page_zone(pfn_to_page(pfn));
> > + A  A  A  A  A  A pfn < range->end;
> > + A  A  A  A  A  A pfn += MAX_ORDER_NR_PAGES) {
> > +
> > + A  A  A  A  A  A  A  if (zone != page_zone(pfn_to_page(pfn)))
> > + A  A  A  A  A  A  A  A  A  A  A  break;
> > + A  A  A  }
> > + A  A  A  range->end = min(pfn, range->end);
> > + A  A  A  return;
> 
> Unnecessary return.
> 
will remove.

> > +}
> > +
> > +/*
> > + * This function is for finding a contiguous memory block which has length
> > + * of pages and MOVABLE. If it finds, make the range of pages as ISOLATED
> > + * and return the first page's pfn.
> > + * If no_search==true, this function doesn't scan the range but tries to
> > + * isolate the range of memory.
> > + */
> > +
> > +static unsigned long find_contig_block(unsigned long base,
> > + A  A  A  A  A  A  A  unsigned long end, unsigned long pages, bool no_search)
> > +{
> > + A  A  A  unsigned long pfn, pos;
> > + A  A  A  struct page_range blockinfo;
> > + A  A  A  int ret;
> > +
> > + A  A  A  pages = MAX_ORDER_ALIGN(pages);
> > +retry:
> > + A  A  A  blockinfo.base = base;
> > + A  A  A  blockinfo.end = end;
> > + A  A  A  blockinfo.pages = pages;
> > + A  A  A  /*
> > + A  A  A  A * At first, check physical page layout and skip memory holes.
> > + A  A  A  A */
> > + A  A  A  ret = walk_system_ram_range(base, end - base, &blockinfo,
> > + A  A  A  A  A  A  A  __get_contig_block);
> > + A  A  A  if (!ret)
> > + A  A  A  A  A  A  A  return 0;
> > + A  A  A  /* check contiguous pages in a zone */
> > + A  A  A  __trim_zone(&blockinfo);
> > +
> > +
> > + A  A  A  /* Ok, we found contiguous memory chunk of size. Isolate it.*/
> > + A  A  A  for (pfn = blockinfo.base; pfn + pages < blockinfo.end;
> > + A  A  A  A  A  A pfn += MAX_ORDER_NR_PAGES) {
> > + A  A  A  A  A  A  A  /* If no_search==true, base addess should be same to 'base' */
> > + A  A  A  A  A  A  A  if (no_search && pfn != base)
> > + A  A  A  A  A  A  A  A  A  A  A  break;
> > + A  A  A  A  A  A  A  /* Better code is necessary here.. */
> > + A  A  A  A  A  A  A  for (pos = pfn; pos < pfn + pages; pos++) {
> > + A  A  A  A  A  A  A  A  A  A  A  struct page *p;
> > +
> > + A  A  A  A  A  A  A  A  A  A  A  if (!pfn_valid_within(pos))
> > + A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  break;
> > + A  A  A  A  A  A  A  A  A  A  A  p = pfn_to_page(pos);
> > + A  A  A  A  A  A  A  A  A  A  A  if (PageReserved(p))
> > + A  A  A  A  A  A  A  A  A  A  A  A  A  A  A  break;
> > + A  A  A  A  A  A  A  A  A  A  A  /* This may hit a page on per-cpu queue. */
> 
> Couldn't we drain per-cpu queue before this function?
> 
We can't guarantee it on SMP systems because we don't ISOLATE the range
at this point.


Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
