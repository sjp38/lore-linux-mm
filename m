Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 1540B60021D
	for <linux-mm@kvack.org>; Fri,  2 Oct 2009 14:37:45 -0400 (EDT)
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e33.co.us.ibm.com (8.14.3/8.13.1) with ESMTP id n92IZMpY003419
	for <linux-mm@kvack.org>; Fri, 2 Oct 2009 12:35:22 -0600
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n92IbZAF264666
	for <linux-mm@kvack.org>; Fri, 2 Oct 2009 12:37:37 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n92IbYYC032545
	for <linux-mm@kvack.org>; Fri, 2 Oct 2009 12:37:35 -0600
Date: Fri, 2 Oct 2009 13:37:33 -0500
From: Robert Jennings <rcj@linux.vnet.ibm.com>
Subject: Re: [PATCH 1/2] mm: add notifier in pageblock isolation for
	balloon drivers
Message-ID: <20091002183733.GB4908@austin.ibm.com>
References: <20091001195311.GA16667@austin.ibm.com> <20091002104425.GN21906@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20091002104425.GN21906@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Ingo Molnar <mingo@elte.hu>, Badari Pulavarty <pbadari@us.ibm.com>, Brian King <brking@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Martin Schwidefsky <schwidefsky@de.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@ozlabs.org
List-ID: <linux-mm.kvack.org>

* Mel Gorman (mel@csn.ul.ie) wrote:
> On Thu, Oct 01, 2009 at 02:53:11PM -0500, Robert Jennings wrote:
> > Memory balloon drivers can allocate a large amount of memory which
> > is not movable but could be freed to accommodate memory hotplug remove.
> > 
> > Prior to calling the memory hotplug notifier chain the memory in the
> > pageblock is isolated.  If the migrate type is not MIGRATE_MOVABLE the
> > isolation will not proceed, causing the memory removal for that page
> > range to fail.
> > 
> > Rather than immediately failing pageblock isolation if the the
> > migrateteype is not MIGRATE_MOVABLE, this patch checks if all of the
> > pages in the pageblock are owned by a registered balloon driver using a
> > notifier chain.  If all of the non-movable pages are owned by a balloon,
> > they can be freed later through the memory notifier chain and the range
> > can still be isolated in set_migratetype_isolate().
> > 
> > Signed-off-by: Robert Jennings <rcj@linux.vnet.ibm.com>
> > 
> > ---
> >  drivers/base/memory.c  |   19 +++++++++++++++++++
> >  include/linux/memory.h |   22 ++++++++++++++++++++++
> >  mm/page_alloc.c        |   49 +++++++++++++++++++++++++++++++++++++++++--------
> >  3 files changed, 82 insertions(+), 8 deletions(-)
> > 
> > Index: b/drivers/base/memory.c
> > ===================================================================
> > --- a/drivers/base/memory.c
> > +++ b/drivers/base/memory.c
> > @@ -63,6 +63,20 @@ void unregister_memory_notifier(struct n
> >  }
> >  EXPORT_SYMBOL(unregister_memory_notifier);
> >  
> > +static BLOCKING_NOTIFIER_HEAD(memory_isolate_chain);
> > +
> > +int register_memory_isolate_notifier(struct notifier_block *nb)
> > +{
> > +	return blocking_notifier_chain_register(&memory_isolate_chain, nb);
> > +}
> > +EXPORT_SYMBOL(register_memory_isolate_notifier);
> > +
> > +void unregister_memory_isolate_notifier(struct notifier_block *nb)
> > +{
> > +	blocking_notifier_chain_unregister(&memory_isolate_chain, nb);
> > +}
> > +EXPORT_SYMBOL(unregister_memory_isolate_notifier);
> > +
> >  /*
> >   * register_memory - Setup a sysfs device for a memory block
> >   */
> > @@ -157,6 +171,11 @@ int memory_notify(unsigned long val, voi
> >  	return blocking_notifier_call_chain(&memory_chain, val, v);
> >  }
> >  
> > +int memory_isolate_notify(unsigned long val, void *v)
> > +{
> > +	return blocking_notifier_call_chain(&memory_isolate_chain, val, v);
> > +}
> > +
> >  /*
> >   * MEMORY_HOTPLUG depends on SPARSEMEM in mm/Kconfig, so it is
> >   * OK to have direct references to sparsemem variables in here.
> > Index: b/include/linux/memory.h
> > ===================================================================
> > --- a/include/linux/memory.h
> > +++ b/include/linux/memory.h
> > @@ -50,6 +50,14 @@ struct memory_notify {
> >  	int status_change_nid;
> >  };
> >  
> > +#define MEM_ISOLATE_COUNT	(1<<0)
> > +
> 
> This needs a comment explaining that that this is an action to count the
> number of pages within a range that have been isolated within a range of
> pages and not a default value for "nr_pages" in the next structure.

I'll provide a clear explanation for this.

> > +struct memory_isolate_notify {
> > +	unsigned long start_addr;
> > +	unsigned int nr_pages;
> > +	unsigned int pages_found;
> > +};
> 
> Is there any particular reason you used virtual address of the mapped
> page instead of PFN? I am guessing at this point that the balloon driver
> is based on addresses but the code that populates the structure more
> commonly deals with PFNs. Outside of debugging code, page_address is
> rarely used in mm/page_alloc.c .
> 
> It's picky but it feels more natural to me to have the structure have
> start_pfn and nr_pages or start_addr and end_addr but not a mix of both.

Changing this to use start_pfn and nr_pages, this will also match
struct memory_notify.  Thanks for the review of this patch.

> > +
> >  struct notifier_block;
> >  struct mem_section;
> >  
> > @@ -76,14 +84,28 @@ static inline int memory_notify(unsigned
> >  {
> >  	return 0;
> >  }
> > +static inline int register_memory_isolate_notifier(struct notifier_block *nb)
> > +{
> > +	return 0;
> > +}
> > +static inline void unregister_memory_isolate_notifier(struct notifier_block *nb)
> > +{
> > +}
> > +static inline int memory_isolate_notify(unsigned long val, void *v)
> > +{
> > +	return 0;
> > +}
> >  #else
> >  extern int register_memory_notifier(struct notifier_block *nb);
> >  extern void unregister_memory_notifier(struct notifier_block *nb);
> > +extern int register_memory_isolate_notifier(struct notifier_block *nb);
> > +extern void unregister_memory_isolate_notifier(struct notifier_block *nb);
> >  extern int register_new_memory(int, struct mem_section *);
> >  extern int unregister_memory_section(struct mem_section *);
> >  extern int memory_dev_init(void);
> >  extern int remove_memory_block(unsigned long, struct mem_section *, int);
> >  extern int memory_notify(unsigned long val, void *v);
> > +extern int memory_isolate_notify(unsigned long val, void *v);
> >  extern struct memory_block *find_memory_block(struct mem_section *);
> >  #define CONFIG_MEM_BLOCK_SIZE	(PAGES_PER_SECTION<<PAGE_SHIFT)
> >  enum mem_add_context { BOOT, HOTPLUG };
> > Index: b/mm/page_alloc.c
> > ===================================================================
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -48,6 +48,7 @@
> >  #include <linux/page_cgroup.h>
> >  #include <linux/debugobjects.h>
> >  #include <linux/kmemleak.h>
> > +#include <linux/memory.h>
> >  #include <trace/events/kmem.h>
> >  
> >  #include <asm/tlbflush.h>
> > @@ -4985,23 +4986,55 @@ void set_pageblock_flags_group(struct pa
> >  int set_migratetype_isolate(struct page *page)
> >  {
> >  	struct zone *zone;
> > -	unsigned long flags;
> > +	unsigned long flags, pfn, iter;
> > +	long immobile = 0;
> 
> So, the count in the structure is unsigned long, but long here. Why the
> difference in types?

No good reason, both will be unsigned long when I repost the patch.

> > +	struct memory_isolate_notify arg;
> > +	int notifier_ret;
> >  	int ret = -EBUSY;
> >  	int zone_idx;
> >  
> >  	zone = page_zone(page);
> >  	zone_idx = zone_idx(zone);
> > +
> > +	pfn = page_to_pfn(page);
> > +	arg.start_addr = (unsigned long)page_address(page);
> > +	arg.nr_pages = pageblock_nr_pages;
> > +	arg.pages_found = 0;
> > +
> >  	spin_lock_irqsave(&zone->lock, flags);
> >  	/*
> >  	 * In future, more migrate types will be able to be isolation target.
> >  	 */
> > -	if (get_pageblock_migratetype(page) != MIGRATE_MOVABLE &&
> > -	    zone_idx != ZONE_MOVABLE)
> > -		goto out;
> > -	set_pageblock_migratetype(page, MIGRATE_ISOLATE);
> > -	move_freepages_block(zone, page, MIGRATE_ISOLATE);
> > -	ret = 0;
> > -out:
> > +	do {
> > +		if (get_pageblock_migratetype(page) == MIGRATE_MOVABLE &&
> > +		    zone_idx == ZONE_MOVABLE) {
> 
> So, this condition requires the zone be MOVABLE and the migrate type
> be movable. That prevents MIGRATE_RESERVE regions in ZONE_MOVABLE being
> off-lined even though they can likely be off-lined. It also prevents
> MIGRATE_MOVABLE sections in other zones being off-lined.
> 
> Did you mean || here instead of && ?
> 
> Might want to expand the comment explaining this condition instead of
> leaving it in the old location which is confusing.

I will fix the logic and clean up the comments here.

> > +			ret = 0;
> > +			break;
> > +		}
> 
> Why do you wrap all this in a do {} while(0)  instead of preserving the
> out: label and using goto?

I've put this back to how it was.

> > +
> > +		/*
> > +		 * If all of the pages in a zone are used by a balloon,
> > +		 * the range can be still be isolated.  The balloon will
> > +		 * free these pages from the memory notifier chain.
> > +		 */
> > +		notifier_ret = memory_isolate_notify(MEM_ISOLATE_COUNT, &arg);
> > +		notifier_ret = notifier_to_errno(ret);
> > +		if (notifier_ret || !arg.pages_found)
> > +			break;
> > +
> > +		for (iter = pfn; iter < (pfn + pageblock_nr_pages); iter++)
> > +			if (page_count(pfn_to_page(iter)))
> > +				immobile++;
> > +
> > +		if (arg.pages_found == immobile)
> 
> and here you compare a signed with an unsigned type. Probably harmless
> but why do it?

This is corrected by making both variables unsigned longs.

> > +			ret = 0;
> > +	} while (0);
> > +
> 
> So the out label would go here and you'd get rid of the do {} while(0)
> loop.

Fixed.

> > +	if (!ret) {
> > +		set_pageblock_migratetype(page, MIGRATE_ISOLATE);
> > +		move_freepages_block(zone, page, MIGRATE_ISOLATE);
> > +	}
> > +
> >  	spin_unlock_irqrestore(&zone->lock, flags);
> >  	if (!ret)
> >  		drain_all_pages();

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
