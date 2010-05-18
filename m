Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 15F846B01D0
	for <linux-mm@kvack.org>; Mon, 17 May 2010 22:19:28 -0400 (EDT)
Date: Tue, 18 May 2010 10:19:23 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 3/3] mem-hotplug: fix potential race while building
 zonelist for new populated zone
Message-ID: <20100518021923.GA6595@localhost>
References: <4BF0FC4C.4060306@linux.intel.com>
 <alpine.DEB.2.00.1005171108070.20764@router.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1005171108070.20764@router.home>
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux.com>
Cc: Haicheng Li <haicheng.li@linux.intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Andi Kleen <andi@firstfloor.org>, Mel Gorman <mel@csn.ul.ie>, Tejun Heo <tj@kernel.org>
List-ID: <linux-mm.kvack.org>

On Tue, May 18, 2010 at 12:09:31AM +0800, Christoph Lameter wrote:
> On Mon, 17 May 2010, Haicheng Li wrote:
> 
> > diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> > index 72c1211..0729a82 100644
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -2783,6 +2783,20 @@ static __init_refok int __build_all_zonelists(void
> > *data)
> >  {
> >  	int nid;
> >  	int cpu;
> > +#ifdef CONFIG_MEMORY_HOTPLUG
> > +	struct zone_online_info *new = (struct zone_online_info *)data;
> > +
> > +	/*
> > +	 * Populate the new zone before build zonelists, which could
> > +	 * happen only when onlining a new node after system is booted.
> > +	 */
> > +	if (new) {
> > +		/* We are expecting a new memory block here. */
> > +		WARN_ON(!new->onlined_pages);
> > +		new->zone->present_pages += new->onlined_pages;
> > +		new->zone->zone_pgdat->node_present_pages +=
> > new->onlined_pages;
> > +	}
> > +#endif
> 
> 
> Building a zonelist now has the potential side effect of changes to the
> size of the zone?

Yeah, this sounds a bit hacky.

> Can we have a global mutex that protects against size modification of
> zonelists instead? And it could also serialize the pageset setup?

Good suggestion. We could make zone_pageset_mutex a global mutex and
take it in all the functions that call build_all_zonelists() --
currently only online_pages() and numa_zonelist_order_handler().

This can equally fix the possible race:

    CPU0                                    CPU1                            CPU2
(1) zone->present_pages += online_pages;
(2)                                         build_all_zonelists();
(3)                                                                 alloc_page();
(4)                                                                 free_page();
(5) build_all_zonelists();
(6)   __build_all_zonelists();
(7)     zone->pageset = alloc_percpu();

In step (3,4), zone->pageset still points to boot_pageset, so bad
things may happen if 2+ nodes are in this state. Even if only 1 node
is accessing the boot_pageset, (3) may still consume too much memory
to fail the memory allocations in step (7).

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
