Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 53E9B6B0087
	for <linux-mm@kvack.org>; Tue, 23 Nov 2010 19:25:51 -0500 (EST)
Received: from m4.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id oAO0PmRN023289
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 24 Nov 2010 09:25:48 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 02AAB45DE6F
	for <linux-mm@kvack.org>; Wed, 24 Nov 2010 09:25:48 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id C746445DE60
	for <linux-mm@kvack.org>; Wed, 24 Nov 2010 09:25:47 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 9E5D11DB8037
	for <linux-mm@kvack.org>; Wed, 24 Nov 2010 09:25:47 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 339961DB8042
	for <linux-mm@kvack.org>; Wed, 24 Nov 2010 09:25:47 +0900 (JST)
Date: Wed, 24 Nov 2010 09:20:03 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 3/4] alloc_contig_pages() allocate big chunk memory
 using migration
Message-Id: <20101124092003.145e0c13.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <AANLkTi=E=b7X1Un7Bp_eSAFrFjOPsYpBO-Ba1aeTrrjr@mail.gmail.com>
References: <20101119171033.a8d9dc8f.kamezawa.hiroyu@jp.fujitsu.com>
	<20101119171528.32674ef4.kamezawa.hiroyu@jp.fujitsu.com>
	<AANLkTi=E=b7X1Un7Bp_eSAFrFjOPsYpBO-Ba1aeTrrjr@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Bob Liu <lliubbo@gmail.com>, fujita.tomonori@lab.ntt.co.jp, m.nazarewicz@samsung.com, pawel@osciak.com, andi.kleen@intel.com, felipe.contreras@gmail.com, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "kosaki.motohiro@jp.fujitsu.com" <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Mon, 22 Nov 2010 20:44:03 +0900
Minchan Kim <minchan.kim@gmail.com> wrote:

> On Fri, Nov 19, 2010 at 5:15 PM, KAMEZAWA Hiroyuki
> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> >
> > Add an function to allocate contiguous memory larger than MAX_ORDER.
> > The main difference between usual page allocator is that this uses
> > memory offline technique (Isolate pages and migrate remaining pages.).
> >
> > I think this is not 100% solution because we can't avoid fragmentation,
> > but we have kernelcore= boot option and can create MOVABLE zone. That
> > helps us to allow allocate a contiguous range on demand.
> 
> And later we can use compaction and reclaim, too.
> So I think this approach is the way we have to go.
> 
> >
> > The new function is
> >
> > A alloc_contig_pages(base, end, nr_pages, alignment)
> >
> > This function will allocate contiguous pages of nr_pages from the range
> > [base, end). If [base, end) is bigger than nr_pages, some pfn which
> > meats alignment will be allocated. If alignment is smaller than MAX_ORDER,
> 
> type meet
> 
will fix.

> > it will be raised to be MAX_ORDER.
> >
> > __alloc_contig_pages() has much more arguments.
> >
> >
> > Some drivers allocates contig pages by bootmem or hiding some memory
> > from the kernel at boot. But if contig pages are necessary only in some
> > situation, kernelcore= boot option and using page migration is a choice.
> >
> > Changelog: 2010-11-19
> > A - removed no_search
> > A - removed some drain_ functions because they are heavy.
> > A - check -ENOMEM case
> >
> > Changelog: 2010-10-26
> > A - support gfp_t
> > A - support zonelist/nodemask
> > A - support [base, end)
> > A - support alignment
> >
> > Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > ---
> > A include/linux/page-isolation.h | A  15 ++
> > A mm/page_alloc.c A  A  A  A  A  A  A  A | A  29 ++++
> > A mm/page_isolation.c A  A  A  A  A  A | A 242 +++++++++++++++++++++++++++++++++++++++++
> > A 3 files changed, 286 insertions(+)
> >
> > Index: mmotm-1117/mm/page_isolation.c
> > ===================================================================
> > --- mmotm-1117.orig/mm/page_isolation.c
> > +++ mmotm-1117/mm/page_isolation.c
> > @@ -5,6 +5,7 @@
> > A #include <linux/mm.h>
> > A #include <linux/page-isolation.h>
> > A #include <linux/pageblock-flags.h>
> > +#include <linux/swap.h>
> > A #include <linux/memcontrol.h>
> > A #include <linux/migrate.h>
> > A #include <linux/memory_hotplug.h>
> > @@ -396,3 +397,244 @@ retry:
> > A  A  A  A }
> > A  A  A  A return 0;
> > A }
> > +
> > +/*
> > + * Comparing caller specified [user_start, user_end) with physical memory layout
> > + * [phys_start, phys_end). If no intersection is longer than nr_pages, return 1.
> > + * If there is an intersection, return 0 and fill range in [*start, *end)
> 
> I understand the goal of function.
> But comment is rather awkward.
> 

ok, I will rewrite.

> > + */
> > +static int
> > +__calc_search_range(unsigned long user_start, unsigned long user_end,
> 
> Personally, I don't like the function name.
> How about "__adjust_search_range"?
> But I am not against this name strongly. :)
> 
I will rename this.


> > + A  A  A  A  A  A  A  unsigned long nr_pages,
> > + A  A  A  A  A  A  A  unsigned long phys_start, unsigned long phys_end,
> > + A  A  A  A  A  A  A  unsigned long *start, unsigned long *end)
> > +{
> > + A  A  A  if ((user_start >= phys_end) || (user_end <= phys_start))
> > + A  A  A  A  A  A  A  return 1;
> > + A  A  A  if (user_start <= phys_start) {
> > + A  A  A  A  A  A  A  *start = phys_start;
> > + A  A  A  A  A  A  A  *end = min(user_end, phys_end);
> > + A  A  A  } else {
> > + A  A  A  A  A  A  A  *start = user_start;
> > + A  A  A  A  A  A  A  *end = min(user_end, phys_end);
> > + A  A  A  }
> > + A  A  A  if (*end - *start < nr_pages)
> > + A  A  A  A  A  A  A  return 1;
> > + A  A  A  return 0;
> > +}
> > +
> > +
> > +/**
> > + * __alloc_contig_pages - allocate a contiguous physical pages
> > + * @base: the lowest pfn which caller wants.
> > + * @end: A the highest pfn which caller wants.
> > + * @nr_pages: the length of a chunk of pages to be allocated.
> 
> the number of pages to be allocated.
> 
ok.

> > + * @align_order: alignment of start address of returned chunk in order.
> > + * A  Returned' page's order will be aligned to (1 << align_order).If smaller
> > + * A  than MAX_ORDER, it's raised to MAX_ORDER.
> > + * @node: allocate near memory to the node, If -1, current node is used.
> > + * @gfpflag: used to specify what zone the memory should be from.
> > + * @nodemask: allocate memory within the nodemask.
> > + *
> > + * Search a memory range [base, end) and allocates physically contiguous
> > + * pages. If end - base is larger than nr_pages, a chunk in [base, end) will
> > + * be allocated
> > + *
> > + * This returns a page of the beginning of contiguous block. At failure, NULL
> > + * is returned.
> > + *
> > + * Limitation: at allocation, nr_pages may be increased to be aligned to
> > + * MAX_ORDER before searching a range. So, even if there is a enough chunk
> > + * for nr_pages, it may not be able to be allocated. Extra tail pages of
> > + * allocated chunk is returned to buddy allocator before returning the caller.
> > + */
> > +
> > +#define MIGRATION_RETRY A  A  A  A (5)
> > +struct page *__alloc_contig_pages(unsigned long base, unsigned long end,
> > + A  A  A  A  A  A  A  A  A  A  A  unsigned long nr_pages, int align_order,
> > + A  A  A  A  A  A  A  A  A  A  A  int node, gfp_t gfpflag, nodemask_t *mask)
> > +{
> > + A  A  A  unsigned long found, aligned_pages, start;
> > + A  A  A  struct page *ret = NULL;
> > + A  A  A  int migration_failed;
> > + A  A  A  unsigned long align_mask;
> > + A  A  A  struct zoneref *z;
> > + A  A  A  struct zone *zone;
> > + A  A  A  struct zonelist *zonelist;
> > + A  A  A  enum zone_type highzone_idx = gfp_zone(gfpflag);
> > + A  A  A  unsigned long zone_start, zone_end, rs, re, pos;
> > +
> > + A  A  A  if (node == -1)
> > + A  A  A  A  A  A  A  node = numa_node_id();
> > +
> > + A  A  A  /* check unsupported flags */
> > + A  A  A  if (gfpflag & __GFP_NORETRY)
> > + A  A  A  A  A  A  A  return NULL;
> > + A  A  A  if ((gfpflag & (__GFP_WAIT | __GFP_IO | __GFP_FS)) !=
> > + A  A  A  A  A  A  A  (__GFP_WAIT | __GFP_IO | __GFP_FS))
> > + A  A  A  A  A  A  A  return NULL;
> 
> Why do we have to care about __GFP_IO|__GFP_FS?
> If you consider compaction/reclaim later, I am OK.
> 
because in page migration, we use GFP_HIGHUSER_MOVABLE now.


> > +
> > + A  A  A  if (gfpflag & __GFP_THISNODE)
> > + A  A  A  A  A  A  A  zonelist = &NODE_DATA(node)->node_zonelists[1];
> > + A  A  A  else
> > + A  A  A  A  A  A  A  zonelist = &NODE_DATA(node)->node_zonelists[0];
> > + A  A  A  /*
> > + A  A  A  A * Base/nr_page/end should be aligned to MAX_ORDER
> > + A  A  A  A */
> > + A  A  A  found = 0;
> > +
> > + A  A  A  if (align_order < MAX_ORDER)
> > + A  A  A  A  A  A  A  align_order = MAX_ORDER;
> > +
> > + A  A  A  align_mask = (1 << align_order) - 1;
> > + A  A  A  /*
> > + A  A  A  A * We allocates MAX_ORDER aligned pages and cut tail pages later.
> > + A  A  A  A */
> > + A  A  A  aligned_pages = ALIGN(nr_pages, (1 << MAX_ORDER));
> > + A  A  A  /*
> > + A  A  A  A * If end - base == nr_pages, we can't search range. base must be
> > + A  A  A  A * aligned.
> > + A  A  A  A */
> > + A  A  A  if ((end - base == nr_pages) && (base & align_mask))
> > + A  A  A  A  A  A  A  return NULL;
> > +
> > + A  A  A  base = ALIGN(base, (1 << align_order));
> > + A  A  A  if ((end <= base) || (end - base < aligned_pages))
> > + A  A  A  A  A  A  A  return NULL;
> > +
> > + A  A  A  /*
> > + A  A  A  A * searching contig memory range within [pos, end).
> > + A  A  A  A * pos is updated at migration failure to find next chunk in zone.
> > + A  A  A  A * pos is reset to the base at searching next zone.
> > + A  A  A  A * (see for_each_zone_zonelist_nodemask in mmzone.h)
> > + A  A  A  A *
> > + A  A  A  A * Note: we cannot assume zones/nodes are in linear memory layout.
> > + A  A  A  A */
> > + A  A  A  z = first_zones_zonelist(zonelist, highzone_idx, mask, &zone);
> > + A  A  A  pos = base;
> > +retry:
> > + A  A  A  if (!zone)
> > + A  A  A  A  A  A  A  return NULL;
> > +
> > + A  A  A  zone_start = ALIGN(zone->zone_start_pfn, 1 << align_order);
> > + A  A  A  zone_end = zone->zone_start_pfn + zone->spanned_pages;
> > +
> > + A  A  A  /* check [pos, end) is in this zone. */
> > + A  A  A  if ((pos >= end) ||
> > + A  A  A  A  A  A (__calc_search_range(pos, end, aligned_pages,
> > + A  A  A  A  A  A  A  A  A  A  A  zone_start, zone_end, &rs, &re))) {
> > +next_zone:
> > + A  A  A  A  A  A  A  /* go to the next zone */
> > + A  A  A  A  A  A  A  z = next_zones_zonelist(++z, highzone_idx, mask, &zone);
> > + A  A  A  A  A  A  A  /* reset the pos */
> > + A  A  A  A  A  A  A  pos = base;
> > + A  A  A  A  A  A  A  goto retry;
> > + A  A  A  }
> > + A  A  A  /* [pos, end) is trimmed to [rs, re) in this zone. */
> > + A  A  A  pos = rs;
> 
> The 'pos' doesn't used any more at below.
> 
Ah, yes. I'll check this was for what and remove this.

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
