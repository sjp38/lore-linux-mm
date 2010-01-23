Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 5E7896B0078
	for <linux-mm@kvack.org>; Sat, 23 Jan 2010 05:23:29 -0500 (EST)
Date: Sat, 23 Jan 2010 18:22:22 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH] mm/readahead.c: update the LRU positions of in-core
	pages, too
Message-ID: <20100123102222.GA6943@localhost>
References: <20100120215536.GN27212@frostnet.net> <20100121054734.GC24236@localhost> <20100123040348.GC30844@frostnet.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=gb2312
Content-Disposition: inline
In-Reply-To: <20100123040348.GC30844@frostnet.net>
Sender: owner-linux-mm@kvack.org
To: Chris Frost <frost@CS.UCLA.EDU>
Cc: Andrew Morton <akpm@linux-foundation.org>, Steve Dickson <steved@redhat.com>, David Howells <dhowells@redhat.com>, Xu Chenfeng <xcf@ustc.edu.cn>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Steve VanDeBogart <vandebo-lkml@nerdbox.net>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

Hi Chris,

> > +/*
> > + * Move pages in danger (of thrashing) to the head of inactive_list.
> > + * Not expected to happen frequently.
> > + */
> > +static unsigned long rescue_pages(struct address_space *mapping,
> > +				  struct file_ra_state *ra,
> > +				  pgoff_t index, unsigned long nr_pages)
> > +{
> > +	struct page *grabbed_page;
> > +	struct page *page;
> > +	struct zone *zone;
> > +	int pgrescue = 0;
> > +
> > +	dprintk("rescue_pages(ino=%lu, index=%lu, nr=%lu)\n",
> > +			mapping->host->i_ino, index, nr_pages);
> > +
> > +	for(; nr_pages;) {
> > +		grabbed_page = page = find_get_page(mapping, index);
> > +		if (!page) {
> > +			index++;
> > +			nr_pages--;
> > +			continue;
> > +		}
> > +
> > +		zone = page_zone(page);
> > +		spin_lock_irq(&zone->lru_lock);
> > +
> > +		if (!PageLRU(page)) {
> > +			index++;
> > +			nr_pages--;
> > +			goto next_unlock;
> > +		}
> > +
> > +		do {
> > +			struct page *the_page = page;
> > +			page = list_entry((page)->lru.prev, struct page, lru);
> > +			index++;
> > +			nr_pages--;
> > +			ClearPageReadahead(the_page);
> > +			if (!PageActive(the_page) &&
> > +					!PageLocked(the_page) &&
> > +					page_count(the_page) == 1) {
> 
> Why require the page count to be 1?

Hmm, I think the PageLocked() and page_count() tests meant to
skip pages being manipulated by someone else.

You can just remove them.  In fact the page_count()==1 will exclude
the grabbed_page, so must be removed. Thanks for the reminder!

> 
> > +				list_move(&the_page->lru, &zone->inactive_list);
> 
> The LRU list manipulation interface has changed since this patch.

Yeah.

> I believe we should replace the list_move() call with:
> 	del_page_from_lru_list(zone, the_page, LRU_INACTIVE_FILE);
> 	add_page_to_lru_list(zone, the_page, LRU_INACTIVE_FILE);
> This moves the page to the top of the list, but also notifies mem_cgroup.
> It also, I believe needlessly, decrements and then increments the zone
> state for each move.

Why do you think mem_cgroup shall be notified here? As me understand
it, mem_cgroup should only care about page addition/removal.

> > +				pgrescue++;
> > +			}
> > +		} while (nr_pages &&
> > +				page_mapping(page) == mapping &&
> > +				page_index(page) == index);
> 
> Is it ok to not lock each page in this while loop? (Does the zone lock
> protect all the reads and writes?)

I believe yes. We are only changing page->lru, which is protected by
zone->lru_lock. btw, why shall we care read/write?

> Will the zone be the same for all pages seen inside a given run of this
> while loop?

Sure. page->lru always links to other pages in the same zone.

> Do you think performance would be better if the code used a pagevec and
> a call to find_get_pages_contig(), instead of the above find_get_page()
> and this loop over the LRU list?

I'm not sure. It should not be a big problem either way.
We can consider it if the find_get_pages_contig() implementation would
be way more simple and clean :)

> 
> > +
> > +next_unlock:
> > +		spin_unlock_irq(&zone->lru_lock);
> > +		page_cache_release(grabbed_page);
> > +		cond_resched();
> > +	}
> > +
> > +	ra_account(ra, RA_EVENT_READAHEAD_RESCUE, pgrescue);
> 
> I don't see ra_account() or relevant fields in struct file_ra_state in
> the current kernel. I'll drop the ra_account() call?

Yes, please. It's for some unmerged feature..

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
