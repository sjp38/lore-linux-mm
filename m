Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx180.postini.com [74.125.245.180])
	by kanga.kvack.org (Postfix) with SMTP id 2BAD16B004D
	for <linux-mm@kvack.org>; Fri,  9 Nov 2012 09:53:46 -0500 (EST)
Date: Fri, 9 Nov 2012 12:53:22 -0200
From: Rafael Aquini <aquini@redhat.com>
Subject: Re: [PATCH v11 3/7] mm: introduce a common interface for balloon
 pages mobility
Message-ID: <20121109145321.GB4308@optiplex.redhat.com>
References: <cover.1352256081.git.aquini@redhat.com>
 <4ea10ef1eb1544e12524c8ca7df20cf621395463.1352256087.git.aquini@redhat.com>
 <20121109121133.GP3886@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20121109121133.GP3886@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, virtualization@lists.linux-foundation.org, Rusty Russell <rusty@rustcorp.com.au>, "Michael S. Tsirkin" <mst@redhat.com>, Rik van Riel <riel@redhat.com>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Minchan Kim <minchan@kernel.org>, Peter Zijlstra <peterz@infradead.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>

On Fri, Nov 09, 2012 at 12:11:33PM +0000, Mel Gorman wrote:
> > +/*
> > + * balloon_page_insert - insert a page into the balloon's page list and make
> > + *		         the page->mapping assignment accordingly.
> > + * @page    : page to be assigned as a 'balloon page'
> > + * @mapping : allocated special 'balloon_mapping'
> > + * @head    : balloon's device page list head
> > + */
> > +static inline void balloon_page_insert(struct page *page,
> > +				       struct address_space *mapping,
> > +				       struct list_head *head)
> > +{
> > +	list_add(&page->lru, head);
> > +	/*
> > +	 * Make sure the page is already inserted on balloon's page list
> > +	 * before assigning its ->mapping.
> > +	 */
> > +	smp_wmb();
> > +	page->mapping = mapping;
> > +}
> > +
> 
> Elsewhere we have;
> 
> 	spin_lock_irqsave(&b_dev_info->pages_lock, flags);
> 	balloon_page_insert(page, b_dev_info->mapping, &b_dev_info->pages);
> 	spin_unlock_irqrestore(&b_dev_info->pages_lock, flags);
> 
> So this happens under an irq-safe lock. Why is a smp_wmb necessary?
> 
> > +
> > +/*
> > + * balloon_page_delete - clear the page->mapping and delete the page from
> > + *			 balloon's page list accordingly.
> > + * @page    : page to be released from balloon's page list
> > + */
> > +static inline void balloon_page_delete(struct page *page)
> > +{
> > +	page->mapping = NULL;
> > +	/*
> > +	 * Make sure page->mapping is cleared before we proceed with
> > +	 * balloon's page list deletion.
> > +	 */
> > +	smp_wmb();
> > +	list_del(&page->lru);
> > +}
> > +
> 
> Same thing on locking except this also appears to be under the page lock
> making the barrier seem even more unnecessary.
> 
> > +/*
> > + * __is_movable_balloon_page - helper to perform @page mapping->flags tests
> > + */
> > +static inline bool __is_movable_balloon_page(struct page *page)
> > +{
> > +	/*
> > +	 * we might attempt to read ->mapping concurrently to other
> > +	 * threads trying to write to it.
> > +	 */
> > +	struct address_space *mapping = ACCESS_ONCE(page->mapping);
> > +	smp_read_barrier_depends();
> > +	return mapping_balloon(mapping);
> > +}
> > +
> 
> What happens if this race occurs? I assume it's a racy check before you
> isolate the balloon in which case the barrier may be overkill.
>

You're 100% right. If, by any chance, we stumble across a balloon page
transitioning to non-balloon page (to be released by the driver), while scanning
pages for isolation, the racy checks at balloon_isolate_page() will catch that up 
and properly sort the situation out. 

> > +/*
> > + * balloon_page_movable - test page->mapping->flags to identify balloon pages
> > + *                     that can be moved by compaction/migration.
> > + *
> > + * This function is used at core compaction's page isolation scheme, therefore
> > + * most pages exposed to it are not enlisted as balloon pages and so, to avoid
> > + * undesired side effects like racing against __free_pages(), we cannot afford
> > + * holding the page locked while testing page->mapping->flags here.
> > + *
> > + * As we might return false positives in the case of a balloon page being just
> > + * released under us, the page->mapping->flags need to be re-tested later,
> > + * under the proper page lock, at the functions that will be coping with the
> > + * balloon page case.
> > + */
> > +static inline bool balloon_page_movable(struct page *page)
> > +{

 
> > +# support for memory balloon compaction
> > +config BALLOON_COMPACTION
> > +	bool "Allow for balloon memory compaction/migration"
> > +	select COMPACTION
> > +	depends on VIRTIO_BALLOON
> > +	help
> > +	  Memory fragmentation introduced by ballooning might reduce
> > +	  significantly the number of 2MB contiguous memory blocks that can be
> > +	  used within a guest, thus imposing performance penalties associated
> > +	  with the reduced number of transparent huge pages that could be used
> > +	  by the guest workload. Allowing the compaction & migration for memory
> > +	  pages enlisted as being part of memory balloon devices avoids the
> > +	  scenario aforementioned and helps improving memory defragmentation.
> > +
> 
> Rather than select COMPACTION, should it depend on it? Similarly as THP
> is the primary motivation, would it make more sense to depend on
> TRANSPARENT_HUGEPAGE?
> 
> Should it default y? It seems useful, why would someone support
> VIRTIO_BALLOON and *not* use this?
>
Good catch, will change it.
 
> 
> Ok, I did not spot any obvious problems in this. The barriers were the
> big issue for me really - they seem overkill. I think we've discussed
> this already but even though it was recent I cannot remember the
> conclusion. In a sense, it doesn't matter because it should have been
> described in the code anyway.
> 
> If you get the barrier issue sorted out then feel free to add
> 
> Acked-by: Mel Gorman <mel@csn.ul.ie>
> 

I believe we can drop the barriers stuff, as the locking scheme is now provinding
enough protection against collisions between isolation page scanning and
balloon_leak() page release (the major concern that has lead to the barriers
originally)

I'll refactor this patch with no barriers and ensure a better commentary on the
aforementioned locking scheme and resubmit, if it's OK to everyone

-- Rafael

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
