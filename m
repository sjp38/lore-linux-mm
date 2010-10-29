Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 8E5128D0030
	for <linux-mm@kvack.org>; Fri, 29 Oct 2010 00:08:29 -0400 (EDT)
Received: from m6.gw.fujitsu.co.jp ([10.0.50.76])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o9T48Qh5017422
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 29 Oct 2010 13:08:26 +0900
Received: from smail (m6 [127.0.0.1])
	by outgoing.m6.gw.fujitsu.co.jp (Postfix) with ESMTP id DBBDE45DE50
	for <linux-mm@kvack.org>; Fri, 29 Oct 2010 13:08:25 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (s6.gw.fujitsu.co.jp [10.0.50.96])
	by m6.gw.fujitsu.co.jp (Postfix) with ESMTP id BC0D645DE4F
	for <linux-mm@kvack.org>; Fri, 29 Oct 2010 13:08:25 +0900 (JST)
Received: from s6.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 90186E38008
	for <linux-mm@kvack.org>; Fri, 29 Oct 2010 13:08:25 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s6.gw.fujitsu.co.jp (Postfix) with ESMTP id 35C841DB8014
	for <linux-mm@kvack.org>; Fri, 29 Oct 2010 13:08:22 +0900 (JST)
Date: Fri, 29 Oct 2010 13:02:51 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC][PATCH 3/3] a big contig memory allocator
Message-Id: <20101029130251.f82f6925.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <AANLkTik-d4-6xN6BFYNcAOyR3P7uJDB-0ucr6Uks3AXv@mail.gmail.com>
References: <20101026190042.57f30338.kamezawa.hiroyu@jp.fujitsu.com>
	<20101026190809.4869b4f0.kamezawa.hiroyu@jp.fujitsu.com>
	<AANLkTik-d4-6xN6BFYNcAOyR3P7uJDB-0ucr6Uks3AXv@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: Bob Liu <lliubbo@gmail.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "minchan.kim@gmail.com" <minchan.kim@gmail.com>, andi.kleen@intel.com, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, fujita.tomonori@lab.ntt.co.jp, felipe.contreras@gmail.com
List-ID: <linux-mm.kvack.org>

On Fri, 29 Oct 2010 11:55:10 +0800
Bob Liu <lliubbo@gmail.com> wrote:

> On Tue, Oct 26, 2010 at 6:08 PM, KAMEZAWA Hiroyuki
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
> >
> > The new function is
> >
> > A alloc_contig_pages(base, end, nr_pages, alignment)
> >
> > This function will allocate contiguous pages of nr_pages from the range
> > [base, end). If [base, end) is bigger than nr_pages, some pfn which
> > meats alignment will be allocated. If alignment is smaller than MAX_ORDER,
> > it will be raised to be MAX_ORDER.
> >
> > __alloc_contig_pages() has much more arguments.
> >
> > Some drivers allocates contig pages by bootmem or hiding some memory
> > from the kernel at boot. But if contig pages are necessary only in some
> > situation, kernelcore= boot option and using page migration is a choice.
> >
> > Note: I'm not 100% sure __GFP_HARDWALL check is required or not..
> >
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
> > A mm/page_isolation.c A  A  A  A  A  A | A 239 +++++++++++++++++++++++++++++++++++++++++
> > A 3 files changed, 283 insertions(+)
> >
> > Index: mmotm-1024/mm/page_isolation.c
> > ===================================================================
> > --- mmotm-1024.orig/mm/page_isolation.c
> > +++ mmotm-1024/mm/page_isolation.c
> > @@ -5,6 +5,7 @@
> > A #include <linux/mm.h>
> > A #include <linux/page-isolation.h>
> > A #include <linux/pageblock-flags.h>
> > +#include <linux/swap.h>
> > A #include <linux/memcontrol.h>
> > A #include <linux/migrate.h>
> > A #include <linux/memory_hotplug.h>
> > @@ -398,3 +399,241 @@ retry:
> > A  A  A  A }
> > A  A  A  A return 0;
> > A }
> > +
> > +/*
> > + * Comparing user specified [user_start, user_end) with physical memory layout
> > + * [phys_start, phys_end). If no intersection of length nr_pages, return 1.
> > + * If there is an intersection, return 0 and fill range in [*start, *end)
> > + */
> > +static int
> > +__calc_search_range(unsigned long user_start, unsigned long user_end,
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
> > + A  A  A  bool no_search = false;
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
> > + A  A  A  if ((gfpflag & (__GFP_WAIT | __GFP_IO | __GFP_FS | __GFP_HARDWALL)) !=
> > + A  A  A  A  A  A  A  (__GFP_WAIT | __GFP_IO | __GFP_FS | __GFP_HARDWALL))
> > + A  A  A  A  A  A  A  return NULL;
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
> > + A  A  A  if (end - base == nr_pages)
> > + A  A  A  A  A  A  A  no_search = true;
> 
> no_search is not used ?
> 
Ah, yes. I wanted to remove this and I missed this one.
But I have to do check again whether no_search check is required or not..

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
