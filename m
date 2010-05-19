Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id E7556600385
	for <linux-mm@kvack.org>; Wed, 19 May 2010 11:22:01 -0400 (EDT)
Date: Wed, 19 May 2010 10:21:24 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [RESEND -v2][PATCH 3/3] mem-hotplug: fix potential race while
 building zonelist for new populated zone
In-Reply-To: <4BF35FA1.5060205@linux.intel.com>
Message-ID: <alpine.DEB.2.00.1005191021120.4592@router.home>
References: <4BF0FC4C.4060306@linux.intel.com> <alpine.DEB.2.00.1005171108070.20764@router.home> <20100518021923.GA6595@localhost> <4BF257BA.7020507@linux.intel.com> <alpine.DEB.2.00.1005180853400.15028@router.home> <4BF35FA1.5060205@linux.intel.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Haicheng Li <haicheng.li@linux.intel.com>
Cc: Wu Fengguang <fengguang.wu@intel.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Andi Kleen <andi@firstfloor.org>, Mel Gorman <mel@csn.ul.ie>, Tejun Heo <tj@kernel.org>
List-ID: <linux-mm.kvack.org>


Looks good on its own....

On Wed, 19 May 2010, Haicheng Li wrote:

> Christoph Lameter wrote:
> > On Tue, 18 May 2010, Haicheng Li wrote:
> >
> > > +extern struct mutex zonelists_pageset_mutex;
> >
> > The mutext is used for multiple serializations having to do with zones.
> > "pageset" suggests its only for pagesets.
>
> hmm yes, "pageset" sounds a little bit confusing.
>
> > So
> >
> > 	zones_mutex?
> >
> > or
> >
> > 	zonelists_mutex?
>
> I prefer zonelists_mutex.
>
> Christoph, how about below patch? Thanks.
>
> ---
> From 3ccfd04d6ae9127bf0f5472db0b266e7b3f158bd Mon Sep 17 00:00:00 2001
> From: Haicheng Li <haicheng.li@linux.intel.com>
> Date: Wed, 19 May 2010 11:07:21 +0800
> Subject: [PATCH] mem-hotplug: fix potential race while building zonelist for
> new populated zone
>
> Add global mutex zonelists_mutex to fix the possible race:
>
>     CPU0                                  CPU1                    CPU2
> (1) zone->present_pages += online_pages;
> (2)                                       build_all_zonelists();
> (3)
> alloc_page();
> (4)                                                               free_page();
> (5) build_all_zonelists();
> (6)   __build_all_zonelists();
> (7)     zone->pageset = alloc_percpu();
>
> In step (3,4), zone->pageset still points to boot_pageset, so bad
> things may happen if 2+ nodes are in this state. Even if only 1 node
> is accessing the boot_pageset, (3) may still consume too much memory
> to fail the memory allocations in step (7).
>
> Besides, atomic operation ensures alloc_percpu() in step (7) will never fail
> since there is a new fresh memory block added in step(6).
>
> Signed-off-by: Haicheng Li <haicheng.li@linux.intel.com>
> Signed-off-by: Wu Fengguang <fengguang.wu@intel.com>
> Reviewed-by: Andi Kleen <andi.kleen@intel.com>
> ---
>  include/linux/mmzone.h |    1 +
>  mm/memory_hotplug.c    |   11 +++--------
>  mm/page_alloc.c        |   15 ++++++++++++++-
>  3 files changed, 18 insertions(+), 9 deletions(-)
>
> diff --git a/include/linux/mmzone.h b/include/linux/mmzone.h
> index dbbcd50..4d87baa 100644
> --- a/include/linux/mmzone.h
> +++ b/include/linux/mmzone.h
> @@ -641,6 +641,7 @@ typedef struct pglist_data {
>
>  #include <linux/memory_hotplug.h>
>
> +extern struct mutex zonelists_mutex;
>  void get_zone_counts(unsigned long *active, unsigned long *inactive,
>  			unsigned long *free);
>  void build_all_zonelists(void *data);
> diff --git a/mm/memory_hotplug.c b/mm/memory_hotplug.c
> index b564b6a..bc4a942 100644
> --- a/mm/memory_hotplug.c
> +++ b/mm/memory_hotplug.c
> @@ -389,11 +389,6 @@ int online_pages(unsigned long pfn, unsigned long
> nr_pages)
>  	int nid;
>  	int ret;
>  	struct memory_notify arg;
> -	/*
> -	 * mutex to protect zone->pageset when it's still shared
> -	 * in onlined_pages()
> -	 */
> -	static DEFINE_MUTEX(zone_pageset_mutex);
>
>  	arg.start_pfn = pfn;
>  	arg.nr_pages = nr_pages;
> @@ -420,14 +415,14 @@ int online_pages(unsigned long pfn, unsigned long
> nr_pages)
>  	 * This means the page allocator ignores this zone.
>  	 * So, zonelist must be updated after online.
>  	 */
> -	mutex_lock(&zone_pageset_mutex);
> +	mutex_lock(&zonelists_mutex);
>  	if (!populated_zone(zone))
>  		need_zonelists_rebuild = 1;
>
>  	ret = walk_system_ram_range(pfn, nr_pages, &onlined_pages,
>  		online_pages_range);
>  	if (ret) {
> -		mutex_unlock(&zone_pageset_mutex);
> +		mutex_unlock(&zonelists_mutex);
>  		printk(KERN_DEBUG "online_pages %lx at %lx failed\n",
>  			nr_pages, pfn);
>  		memory_notify(MEM_CANCEL_ONLINE, &arg);
> @@ -441,7 +436,7 @@ int online_pages(unsigned long pfn, unsigned long
> nr_pages)
>  	else
>  		zone_pcp_update(zone);
>
> -	mutex_unlock(&zone_pageset_mutex);
> +	mutex_unlock(&zonelists_mutex);
>  	setup_per_zone_wmarks();
>  	calculate_zone_inactive_ratio(zone);
>  	if (onlined_pages) {
> diff --git a/mm/page_alloc.c b/mm/page_alloc.c
> index 72c1211..c8e6146 100644
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -2434,8 +2434,11 @@ int numa_zonelist_order_handler(ctl_table *table, int
> write,
>  			strncpy((char*)table->data, saved_string,
>  				NUMA_ZONELIST_ORDER_LEN);
>  			user_zonelist_order = oldval;
> -		} else if (oldval != user_zonelist_order)
> +		} else if (oldval != user_zonelist_order) {
> +			mutex_lock(&zonelists_mutex);
>  			build_all_zonelists(NULL);
> +			mutex_unlock(&zonelists_mutex);
> +		}
>  	}
>  out:
>  	mutex_unlock(&zl_order_mutex);
> @@ -2778,6 +2781,12 @@ static void setup_pageset(struct per_cpu_pageset *p,
> unsigned long batch);
>  static DEFINE_PER_CPU(struct per_cpu_pageset, boot_pageset);
>  static void setup_zone_pageset(struct zone *zone);
>
> +/*
> + * Global mutex to protect against size modification of zonelists
> + * as well as to serialize pageset setup for the new populated zone.
> + */
> +DEFINE_MUTEX(zonelists_mutex);
> +
>  /* return values int ....just for stop_machine() */
>  static __init_refok int __build_all_zonelists(void *data)
>  {
> @@ -2821,6 +2830,10 @@ static __init_refok int __build_all_zonelists(void
> *data)
>  	return 0;
>  }
>
> +/*
> + * Called with zonelists_mutex held always
> + * unless system_state == SYSTEM_BOOTING.
> + */
>  void build_all_zonelists(void *data)
>  {
>  	set_zonelist_order();
>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
