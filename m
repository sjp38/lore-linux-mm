Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id ACDB96B004D
	for <linux-mm@kvack.org>; Thu,  8 Oct 2009 20:50:11 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n990o7vb013558
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 9 Oct 2009 09:50:07 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id C0CE845DE54
	for <linux-mm@kvack.org>; Fri,  9 Oct 2009 09:50:06 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 88E6845DE51
	for <linux-mm@kvack.org>; Fri,  9 Oct 2009 09:50:06 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 60AD31DB8045
	for <linux-mm@kvack.org>; Fri,  9 Oct 2009 09:50:06 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id EBEE31DB8041
	for <linux-mm@kvack.org>; Fri,  9 Oct 2009 09:50:05 +0900 (JST)
Date: Fri, 9 Oct 2009 09:47:40 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 1/2][v2] mm: add notifier in pageblock isolation for
 balloon drivers
Message-Id: <20091009094740.fe84e46a.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20091002184458.GC4908@austin.ibm.com>
References: <20091002184458.GC4908@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Robert Jennings <rcj@linux.vnet.ibm.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Ingo Molnar <mingo@elte.hu>, Badari Pulavarty <pbadari@us.ibm.com>, Brian King <brking@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Martin Schwidefsky <schwidefsky@de.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@ozlabs.org
List-ID: <linux-mm.kvack.org>

On Fri, 2 Oct 2009 13:44:58 -0500
Robert Jennings <rcj@linux.vnet.ibm.com> wrote:

> Memory balloon drivers can allocate a large amount of memory which
> is not movable but could be freed to accomodate memory hotplug remove.
> 
> Prior to calling the memory hotplug notifier chain the memory in the
> pageblock is isolated.  If the migrate type is not MIGRATE_MOVABLE the
> isolation will not proceed, causing the memory removal for that page
> range to fail.
> 
> Rather than failing pageblock isolation if the the migrateteype is not
> MIGRATE_MOVABLE, this patch checks if all of the pages in the pageblock
> are owned by a registered balloon driver (or other entity) using a
> notifier chain.  If all of the non-movable pages are owned by a balloon,
> they can be freed later through the memory notifier chain and the range
> can still be isolated in set_migratetype_isolate().
> 
> Signed-off-by: Robert Jennings <rcj@linux.vnet.ibm.com>
> 
> ---
>  drivers/base/memory.c  |   19 +++++++++++++++++++
>  include/linux/memory.h |   26 ++++++++++++++++++++++++++
>  mm/page_alloc.c        |   45 ++++++++++++++++++++++++++++++++++++++-------
>  3 files changed, 83 insertions(+), 7 deletions(-)
> 
> Index: b/drivers/base/memory.c
> ===================================================================
> --- a/drivers/base/memory.c
> +++ b/drivers/base/memory.c
> @@ -63,6 +63,20 @@ void unregister_memory_notifier(struct n
>  }
>  EXPORT_SYMBOL(unregister_memory_notifier);
>  
> +static BLOCKING_NOTIFIER_HEAD(memory_isolate_chain);
> +

IIUC, this notifier is called under zone->lock.
please ATOMIC_NOTIFIER_HEAD().




> +int register_memory_isolate_notifier(struct notifier_block *nb)
> +{
> +	return blocking_notifier_chain_register(&memory_isolate_chain, nb);
> +}
> +EXPORT_SYMBOL(register_memory_isolate_notifier);
> +
> +void unregister_memory_isolate_notifier(struct notifier_block *nb)
> +{
> +	blocking_notifier_chain_unregister(&memory_isolate_chain, nb);
> +}
> +EXPORT_SYMBOL(unregister_memory_isolate_notifier);
> +
>  /*
>   * register_memory - Setup a sysfs device for a memory block
>   */
> @@ -157,6 +171,11 @@ int memory_notify(unsigned long val, voi
>  	return blocking_notifier_call_chain(&memory_chain, val, v);
>  }
>  
> +int memory_isolate_notify(unsigned long val, void *v)
> +{
> +	return blocking_notifier_call_chain(&memory_isolate_chain, val, v);
> +}
> +
>  /*
>   * MEMORY_HOTPLUG depends on SPARSEMEM in mm/Kconfig, so it is
>   * OK to have direct references to sparsemem variables in here.
> Index: b/include/linux/memory.h
> ===================================================================
> --- a/include/linux/memory.h
> +++ b/include/linux/memory.h
> @@ -50,6 +50,18 @@ struct memory_notify {
>  	int status_change_nid;
>  };
>  
> +/*
> + * During pageblock isolation, count the number of pages in the
> + * range [start_pfn, start_pfn + nr_pages)
> + */
> +#define MEM_ISOLATE_COUNT	(1<<0)
> +
> +struct memory_isolate_notify {
> +	unsigned long start_pfn;
> +	unsigned int nr_pages;
> +	unsigned int pages_found;
> +};

Could you add commentary for each field ?

> +
>  struct notifier_block;
>  struct mem_section;
>  
> @@ -76,14 +88,28 @@ static inline int memory_notify(unsigned
>  {
>  	return 0;
>  }
> +static inline int register_memory_isolate_notifier(struct notifier_block *nb)
> +{
> +	return 0;
> +}
> +static inline void unregister_memory_isolate_notifier(struct notifier_block *nb)
> +{
> +}
> +static inline int memory_isolate_notify(unsigned long val, void *v)
> +{
> +	return 0;
> +}
>  #else
>  extern int register_memory_notifier(struct notifier_block *nb);
>  extern void unregister_memory_notifier(struct notifier_block *nb);
> +extern int register_memory_isolate_notifier(struct notifier_block *nb);
> +extern void unregister_memory_isolate_notifier(struct notifier_block *nb);
>  extern int register_new_memory(int, struct mem_section *);
>  extern int unregister_memory_section(struct mem_section *);
>  extern int memory_dev_init(void);
>  extern int remove_memory_block(unsigned long, struct mem_section *, int);
>  extern int memory_notify(unsigned long val, void *v);
> +extern int memory_isolate_notify(unsigned long val, void *v);
>  extern struct memory_block *find_memory_block(struct mem_section *);
>  #define CONFIG_MEM_BLOCK_SIZE	(PAGES_PER_SECTION<<PAGE_SHIFT)
>  enum mem_add_context { BOOT, HOTPLUG };
> Index: b/mm/page_alloc.c
> ===================================================================
> --- a/mm/page_alloc.c
> +++ b/mm/page_alloc.c
> @@ -48,6 +48,7 @@
>  #include <linux/page_cgroup.h>
>  #include <linux/debugobjects.h>
>  #include <linux/kmemleak.h>
> +#include <linux/memory.h>
>  #include <trace/events/kmem.h>
>  
>  #include <asm/tlbflush.h>
> @@ -4985,23 +4986,53 @@ void set_pageblock_flags_group(struct pa
>  int set_migratetype_isolate(struct page *page)
>  {
>  	struct zone *zone;
> -	unsigned long flags;
> +	unsigned long flags, pfn, iter;
> +	unsigned long immobile = 0;
> +	struct memory_isolate_notify arg;
> +	int notifier_ret;
>  	int ret = -EBUSY;
>  	int zone_idx;
>  
>  	zone = page_zone(page);
>  	zone_idx = zone_idx(zone);
> +
>  	spin_lock_irqsave(&zone->lock, flags);
> +	if (get_pageblock_migratetype(page) == MIGRATE_MOVABLE ||
> +	    zone_idx == ZONE_MOVABLE) {
> +		ret = 0;
> +		goto out;
> +	}
> +
> +	pfn = page_to_pfn(page);
> +	arg.start_pfn = pfn;
> +	arg.nr_pages = pageblock_nr_pages;
> +	arg.pages_found = 0;
> +
>  	/*
> -	 * In future, more migrate types will be able to be isolation target.
> +	 * The pageblock can be isolated even if the migrate type is
> +	 * not *_MOVABLE.  The memory isolation notifier chain counts
> +	 * the number of pages in this pageblock that can be freed later
> +	 * through the memory notifier chain.  If all of the pages are
> +	 * accounted for, isolation can continue.
>  	 */

Could add explanation like this ?
==
  Later, for example, when memory hotplug notifier runs, these pages reported as
  "can be isoalted" should be isolated(freed) by callbacks.
==



> -	if (get_pageblock_migratetype(page) != MIGRATE_MOVABLE &&
> -	    zone_idx != ZONE_MOVABLE)
> +	notifier_ret = memory_isolate_notify(MEM_ISOLATE_COUNT, &arg);
> +	notifier_ret = notifier_to_errno(notifier_ret);
> +       	if (notifier_ret || !arg.pages_found)
>  		goto out;
> -	set_pageblock_migratetype(page, MIGRATE_ISOLATE);
> -	move_freepages_block(zone, page, MIGRATE_ISOLATE);
> -	ret = 0;
> +
> +	for (iter = pfn; iter < (pfn + pageblock_nr_pages); iter++)
> +		if (page_count(pfn_to_page(iter)))
> +			immobile++;
> +
> +	if (arg.pages_found == immobile)
> +		ret = 0;
> +

I can't understand this part. Does this mean all pages under this pageblock
are used by balloon driver ?
IOW, memory is hotpluggable only when all pages under this pageblock is used
by balloon ?


Hmm. Can't we do this kind of check..?
==
     for (iter = pfn; iter < (pfn + pageblock_nr_pages); iter++) {
	page = pfn_to_page(iter);
	if (!page_count(page) || PageLRU(page)) // This page is movable.
		continue;
	immobile++
     }
==
Then, if a page is luckyly on LRU, we have more chances.
(This check can fail if a page is on percpu pagevec etc...)

Thanks,
-Kame

>  out:
> +	if (!ret) {
> +		set_pageblock_migratetype(page, MIGRATE_ISOLATE);
> +		move_freepages_block(zone, page, MIGRATE_ISOLATE);
> +	}
> +
>  	spin_unlock_irqrestore(&zone->lock, flags);
>  	if (!ret)
>  		drain_all_pages();
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
