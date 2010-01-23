Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 0C46E6B006A
	for <linux-mm@kvack.org>; Fri, 22 Jan 2010 23:04:00 -0500 (EST)
Date: Fri, 22 Jan 2010 20:03:48 -0800
From: Chris Frost <frost@CS.UCLA.EDU>
Subject: Re: [PATCH] mm/readahead.c: update the LRU positions of in-core
	pages, too
Message-ID: <20100123040348.GC30844@frostnet.net>
References: <20100120215536.GN27212@frostnet.net> <20100121054734.GC24236@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100121054734.GC24236@localhost>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Steve Dickson <steved@redhat.com>, David Howells <dhowells@redhat.com>, Xu Chenfeng <xcf@ustc.edu.cn>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Steve VanDeBogart <vandebo-lkml@nerdbox.net>
List-ID: <linux-mm.kvack.org>

On Thu, Jan 21, 2010 at 01:47:34PM +0800, Wu Fengguang wrote:
> On Wed, Jan 20, 2010 at 01:55:36PM -0800, Chris Frost wrote:
> > This patch changes readahead to move pages that are already in memory and
> > in the inactive list to the top of the list. This mirrors the behavior
> > of non-in-core pages. The position of pages already in the active list
> > remains unchanged.
>  
> This is good in general. 

Great!


> > @@ -170,19 +201,24 @@ __do_page_cache_readahead(struct address_space *mapping, struct file *filp,
> >  		rcu_read_lock();
> >  		page = radix_tree_lookup(&mapping->page_tree, page_offset);
> >  		rcu_read_unlock();
> > -		if (page)
> > -			continue;
> > -
> > -		page = page_cache_alloc_cold(mapping);
> > -		if (!page)
> > -			break;
> > -		page->index = page_offset;
> > -		list_add(&page->lru, &page_pool);
> > -		if (page_idx == nr_to_read - lookahead_size)
> > -			SetPageReadahead(page);
> > -		ret++;
> > +		if (page) {
> > +			page_cache_get(page);
> 
> This is racy - the page may have already be freed and possibly reused
> by others in the mean time.
> 
> If you do page_cache_get() on a random page, it may trigger bad_page()
> in the buddy page allocator, or the VM_BUG_ON() in put_page_testzero().

Thanks for catching these.


> 
> > +			if (!pagevec_add(&retain_vec, page))
> > +				retain_pages(&retain_vec);
> > +		} else {
> > +			page = page_cache_alloc_cold(mapping);
> > +			if (!page)
> > +				break;
> > +			page->index = page_offset;
> > +			list_add(&page->lru, &page_pool);
> > +			if (page_idx == nr_to_read - lookahead_size)
> > +				SetPageReadahead(page);
> > +			ret++;
> > +		}
> 
> Years ago I wrote a similar function, which can be called for both
> in-kernel-readahead (when it decides not to bring in new pages, but
> only retain existing pages) and fadvise-readahead (where it want to
> read new pages as well as retain existing pages).
> 
> For better chance of code reuse, would you rebase the patch on it?
> (You'll have to do some cleanups first.)

This sounds good; thanks. I've rebased my change on the below.
Fwiw, performance is unchanged. A few questions below.


> +/*
> + * Move pages in danger (of thrashing) to the head of inactive_list.
> + * Not expected to happen frequently.
> + */
> +static unsigned long rescue_pages(struct address_space *mapping,
> +				  struct file_ra_state *ra,
> +				  pgoff_t index, unsigned long nr_pages)
> +{
> +	struct page *grabbed_page;
> +	struct page *page;
> +	struct zone *zone;
> +	int pgrescue = 0;
> +
> +	dprintk("rescue_pages(ino=%lu, index=%lu, nr=%lu)\n",
> +			mapping->host->i_ino, index, nr_pages);
> +
> +	for(; nr_pages;) {
> +		grabbed_page = page = find_get_page(mapping, index);
> +		if (!page) {
> +			index++;
> +			nr_pages--;
> +			continue;
> +		}
> +
> +		zone = page_zone(page);
> +		spin_lock_irq(&zone->lru_lock);
> +
> +		if (!PageLRU(page)) {
> +			index++;
> +			nr_pages--;
> +			goto next_unlock;
> +		}
> +
> +		do {
> +			struct page *the_page = page;
> +			page = list_entry((page)->lru.prev, struct page, lru);
> +			index++;
> +			nr_pages--;
> +			ClearPageReadahead(the_page);
> +			if (!PageActive(the_page) &&
> +					!PageLocked(the_page) &&
> +					page_count(the_page) == 1) {

Why require the page count to be 1?


> +				list_move(&the_page->lru, &zone->inactive_list);

The LRU list manipulation interface has changed since this patch.
I believe we should replace the list_move() call with:
	del_page_from_lru_list(zone, the_page, LRU_INACTIVE_FILE);
	add_page_to_lru_list(zone, the_page, LRU_INACTIVE_FILE);
This moves the page to the top of the list, but also notifies mem_cgroup.
It also, I believe needlessly, decrements and then increments the zone
state for each move.


> +				pgrescue++;
> +			}
> +		} while (nr_pages &&
> +				page_mapping(page) == mapping &&
> +				page_index(page) == index);

Is it ok to not lock each page in this while loop? (Does the zone lock
protect all the reads and writes?)

Will the zone be the same for all pages seen inside a given run of this
while loop?

Do you think performance would be better if the code used a pagevec and
a call to find_get_pages_contig(), instead of the above find_get_page()
and this loop over the LRU list?


> +
> +next_unlock:
> +		spin_unlock_irq(&zone->lru_lock);
> +		page_cache_release(grabbed_page);
> +		cond_resched();
> +	}
> +
> +	ra_account(ra, RA_EVENT_READAHEAD_RESCUE, pgrescue);

I don't see ra_account() or relevant fields in struct file_ra_state in
the current kernel. I'll drop the ra_account() call?


> +	return pgrescue;
> +}

-- 
Chris Frost
http://www.frostnet.net/chris/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
