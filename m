Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 9F1506B004D
	for <linux-mm@kvack.org>; Fri,  9 Oct 2009 10:43:27 -0400 (EDT)
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e31.co.us.ibm.com (8.14.3/8.13.1) with ESMTP id n99EatMG024697
	for <linux-mm@kvack.org>; Fri, 9 Oct 2009 08:36:55 -0600
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n99EhKpL198242
	for <linux-mm@kvack.org>; Fri, 9 Oct 2009 08:43:20 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n99EhHWx013790
	for <linux-mm@kvack.org>; Fri, 9 Oct 2009 08:43:19 -0600
Date: Fri, 9 Oct 2009 09:43:16 -0500
From: Robert Jennings <rcj@linux.vnet.ibm.com>
Subject: Re: [PATCH 1/2][v2] mm: add notifier in pageblock isolation for
	balloon drivers
Message-ID: <20091009144316.GB11543@austin.ibm.com>
References: <20091002184458.GC4908@austin.ibm.com> <20091009112136.GB24845@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20091009112136.GB24845@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Ingo Molnar <mingo@elte.hu>, Badari Pulavarty <pbadari@us.ibm.com>, Brian King <brking@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Martin Schwidefsky <schwidefsky@de.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@ozlabs.org
List-ID: <linux-mm.kvack.org>

* Mel Gorman (mel@csn.ul.ie) wrote:
> On Fri, Oct 02, 2009 at 01:44:58PM -0500, Robert Jennings wrote:
> > Memory balloon drivers can allocate a large amount of memory which
> > is not movable but could be freed to accomodate memory hotplug remove.
> > 
> > Prior to calling the memory hotplug notifier chain the memory in the
> > pageblock is isolated.  If the migrate type is not MIGRATE_MOVABLE the
> > isolation will not proceed, causing the memory removal for that page
> > range to fail.
> > 
> > Rather than failing pageblock isolation if the the migrateteype is not
> 
> s/the the migrateteype/the migratetype/
> 
> > MIGRATE_MOVABLE, this patch checks if all of the pages in the pageblock
> > are owned by a registered balloon driver (or other entity) using a
> > notifier chain.  If all of the non-movable pages are owned by a balloon,
> > they can be freed later through the memory notifier chain and the range
> > can still be isolated in set_migratetype_isolate().
> > 
> > Signed-off-by: Robert Jennings <rcj@linux.vnet.ibm.com>
> > 
> > ---
> >  drivers/base/memory.c  |   19 +++++++++++++++++++
> >  include/linux/memory.h |   26 ++++++++++++++++++++++++++
> >  mm/page_alloc.c        |   45 ++++++++++++++++++++++++++++++++++++++-------
> >  3 files changed, 83 insertions(+), 7 deletions(-)
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
> > @@ -50,6 +50,18 @@ struct memory_notify {
> >  	int status_change_nid;
> >  };
> >  
> > +/*
> > + * During pageblock isolation, count the number of pages in the
> > + * range [start_pfn, start_pfn + nr_pages)
> > + */
> > 
> 
> The comment could have been slightly better. The count of pages in the
> range is nr_pages - memory_holes but what you're counting is the number
> of pages owned by the balloon driver in the notification chain.

Right, it is misleading.  I'll fix this.

> > +#define MEM_ISOLATE_COUNT	(1<<0)
> > +
> > +struct memory_isolate_notify {
> > +	unsigned long start_pfn;
> > +	unsigned int nr_pages;
> > +	unsigned int pages_found;
> > +};
> > +
> >  struct notifier_block;
> >  struct mem_section;
> >  
> > @@ -76,14 +88,28 @@ static inline int memory_notify(unsigned
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
> > @@ -4985,23 +4986,53 @@ void set_pageblock_flags_group(struct pa
> >  int set_migratetype_isolate(struct page *page)
> >  {
> >  	struct zone *zone;
> > -	unsigned long flags;
> > +	unsigned long flags, pfn, iter;
> > +	unsigned long immobile = 0;
> > +	struct memory_isolate_notify arg;
> > +	int notifier_ret;
> >  	int ret = -EBUSY;
> >  	int zone_idx;
> >  
> >  	zone = page_zone(page);
> >  	zone_idx = zone_idx(zone);
> > +
> >  	spin_lock_irqsave(&zone->lock, flags);
> > +	if (get_pageblock_migratetype(page) == MIGRATE_MOVABLE ||
> > +	    zone_idx == ZONE_MOVABLE) {
> > +		ret = 0;
> > +		goto out;
> > +	}
> > +
> > +	pfn = page_to_pfn(page);
> > +	arg.start_pfn = pfn;
> > +	arg.nr_pages = pageblock_nr_pages;
> > +	arg.pages_found = 0;
> > +
> >  	/*
> > -	 * In future, more migrate types will be able to be isolation target.
> > +	 * The pageblock can be isolated even if the migrate type is
> > +	 * not *_MOVABLE.  The memory isolation notifier chain counts
> > +	 * the number of pages in this pageblock that can be freed later
> > +	 * through the memory notifier chain.  If all of the pages are
> > +	 * accounted for, isolation can continue.
> 
> This comment could have been clearer as well
> 
> * It may be possible to isolate a pageblock even if the migratetype is
> * not MIGRATE_MOVABLE. The memory isolation notifier chain is used by
> * balloon drivers to return the number of pages in a range that are held
> * by the balloon driver to shrink memory. If all the pages are accounted
> * for by balloons or are free, isolation can continue

 * It may be possible to isolate a pageblock even if the migratetype is
 * not MIGRATE_MOVABLE. The memory isolation notifier chain is used by
 * balloon drivers to return the number of pages in a range that are held
 * by the balloon driver to shrink memory. If all the pages are accounted
 * for by balloons, are free, or on the LRU, isolation can continue.
 * Later, for example, when memory hotplug notifier runs, these pages
 * reported as "can be isolated" should be isolated(freed) by the balloon
 * driver through the memory notifier chain.

> >  	 */
> > -	if (get_pageblock_migratetype(page) != MIGRATE_MOVABLE &&
> > -	    zone_idx != ZONE_MOVABLE)
> > +	notifier_ret = memory_isolate_notify(MEM_ISOLATE_COUNT, &arg);
> > +	notifier_ret = notifier_to_errno(notifier_ret);
> > +       	if (notifier_ret || !arg.pages_found)
> >  		goto out;
> > -	set_pageblock_migratetype(page, MIGRATE_ISOLATE);
> > -	move_freepages_block(zone, page, MIGRATE_ISOLATE);
> > -	ret = 0;
> > +
> > +	for (iter = pfn; iter < (pfn + pageblock_nr_pages); iter++)
> > +		if (page_count(pfn_to_page(iter)))
> > +			immobile++;
> > +
> 
> This part here is not safe when CONFIG_HOLES_IN_ZONE is set. You need to
> make it something like
> 
> for (iter = pfn; iter < (pfn + pageblock_nr_pages); iter++) {
> 	if (!pfn_valid_within(pfn))
> 		continue;
> 
> 	if (page_count(pfn_to_page(iter)))
> 		immobile++;
> }
> 
> You shouldn't need to run pfn_valid() as you're always starting from a valid
> page and never going outside MAX_ORDER_NR_PAGES in this iterator.
> 

I will make this change.

> > +	if (arg.pages_found == immobile)
> > +		ret = 0;
> > +
> 
> Ok, so if all pages in a range that are in use match the count returned
> by the balloon, then it's ok to isolate.

Correct. 

> >  out:
> > +	if (!ret) {
> > +		set_pageblock_migratetype(page, MIGRATE_ISOLATE);
> > +		move_freepages_block(zone, page, MIGRATE_ISOLATE);
> > +	}
> > +
> >  	spin_unlock_irqrestore(&zone->lock, flags);
> >  	if (!ret)
> >  		drain_all_pages();
> > 
> 
> The patch looks more or less sane. It would be nice to have a follow-on patch
> that clarified some details but it's not necessary. The pfn_valid_within()
> should be done as a follow-on patch. I haven't actually tested this but
> otherwise it looks ok. Once the pfn_valid_within() is sorted out, it has
> my Ack.

I'll be sending out a new revision of this patch rather than a
follow-on due to other changes (change from BLOCKING_NOTIFIER_HEAD to
ATOMIC_NOTIFIER_HEAD) and I will include changes discussed here.  Thank
you for the review.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
