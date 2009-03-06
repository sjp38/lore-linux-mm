Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id DD1756B011E
	for <linux-mm@kvack.org>; Fri,  6 Mar 2009 14:22:46 -0500 (EST)
Date: Fri, 6 Mar 2009 11:26:25 -0800
From: mark gross <mgross@linux.intel.com>
Subject: possible bug in find_get_pages
Message-ID: <20090306192625.GA3267@linux.intel.com>
Reply-To: mgross@linux.intel.com
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

I'm looking at a system hang (note: new hardware going under stress
tests using a ubuntu 2.6.27-11-generic)

It seems that page->_count == 0 at some point on some overnight runs
with locks the system into a tight loop from the repeat: and a goto
repeat in find_get_pages. 

Code inserted for convenience:

unsigned find_get_pages(struct address_space *mapping, pgoff_t start,
			    unsigned int nr_pages, struct page **pages)
{
	unsigned int i;
	unsigned int ret;
	unsigned int nr_found;

	rcu_read_lock();
restart:
	nr_found = radix_tree_gang_lookup_slot(&mapping->page_tree,
				(void ***)pages, start, nr_pages);
	ret = 0;
	for (i = 0; i < nr_found; i++) {
		struct page *page;
repeat:
		page = radix_tree_deref_slot((void **)pages[i]);
		if (unlikely(!page))
			continue;
		/*
		 * this can only trigger if nr_found == 1, making
		 * livelock
		 * a non issue.
		 */
		if (unlikely(page == RADIX_TREE_RETRY))
			goto restart;

		if (!page_cache_get_speculative(page))
			goto repeat; <---------_always_hits_ 

		/* Has the page moved? */
		if (unlikely(page != *((void **)pages[i]))) {
			page_cache_release(page);
			goto repeat;
		}

		pages[ret] = page;
		ret++;
	}
	rcu_read_unlock();
	return ret;
}

My question is that as I look at this code I don't see any way out of it
once I get a page with zero _count from radix_tree_deref_slot, then I
will get the same page forever.  The input to radix_tree_deref_slot
never changes so I assume the output should be the same crappy page with
zero _count that drops me on the goto repeat line.

Is this a bug?

Also, is having a page->_count == 0 an unexpected or invalid state?

Thanks!

--mgross





--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
