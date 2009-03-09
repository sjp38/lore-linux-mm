Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 9327B6B003D
	for <linux-mm@kvack.org>; Mon,  9 Mar 2009 12:39:35 -0400 (EDT)
Date: Mon, 9 Mar 2009 09:43:16 -0700
From: mark gross <mgross@linux.intel.com>
Subject: Re: possible bug in find_get_pages
Message-ID: <20090309164316.GB31140@linux.intel.com>
Reply-To: mgross@linux.intel.com
References: <20090306192625.GA3267@linux.intel.com> <20090307084732.b01bcfee.minchan.kim@barrios-desktop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090307084732.b01bcfee.minchan.kim@barrios-desktop>
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: linux-mm@kvack.org, Nick Piggin <npiggin@suse.de>, Christoph Lameter <cl@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Sat, Mar 07, 2009 at 08:47:32AM +0900, Minchan Kim wrote:
> Nick already found and solved this problem .
> It can help you. 
> 
> http://patchwork.kernel.org/patch/860/
> 

Wow, this reads just like the problem we are seeing.  I'll try the
patch and let the test run for a few days!

We've even see it come out of the live lock once in a while as well.  I
was thinking cache coherency HW issue until this :)

I'll send an update after running the test.

thanks!

--mgross


> 
> > On Fri, 6 Mar 2009 11:26:25 -0800
> > mark gross <mgross@linux.intel.com> wrote:
> >
> > I'm looking at a system hang (note: new hardware going under stress
> > tests using a ubuntu 2.6.27-11-generic)
> > 
> > It seems that page->_count == 0 at some point on some overnight runs
> > with locks the system into a tight loop from the repeat: and a goto
> > repeat in find_get_pages. 
> > 
> > Code inserted for convenience:
> > 
> > unsigned find_get_pages(struct address_space *mapping, pgoff_t start,
> > 			    unsigned int nr_pages, struct page **pages)
> > {
> > 	unsigned int i;
> > 	unsigned int ret;
> > 	unsigned int nr_found;
> > 
> > 	rcu_read_lock();
> > restart:
> > 	nr_found = radix_tree_gang_lookup_slot(&mapping->page_tree,
> > 				(void ***)pages, start, nr_pages);
> > 	ret = 0;
> > 	for (i = 0; i < nr_found; i++) {
> > 		struct page *page;
> > repeat:
> > 		page = radix_tree_deref_slot((void **)pages[i]);
> > 		if (unlikely(!page))
> > 			continue;
> > 		/*
> > 		 * this can only trigger if nr_found == 1, making
> > 		 * livelock
> > 		 * a non issue.
> > 		 */
> > 		if (unlikely(page == RADIX_TREE_RETRY))
> > 			goto restart;
> > 
> > 		if (!page_cache_get_speculative(page))
> > 			goto repeat; <---------_always_hits_ 
> > 
> > 		/* Has the page moved? */
> > 		if (unlikely(page != *((void **)pages[i]))) {
> > 			page_cache_release(page);
> > 			goto repeat;
> > 		}
> > 
> > 		pages[ret] = page;
> > 		ret++;
> > 	}
> > 	rcu_read_unlock();
> > 	return ret;
> > }
> > 
> > My question is that as I look at this code I don't see any way out of it
> > once I get a page with zero _count from radix_tree_deref_slot, then I
> > will get the same page forever.  The input to radix_tree_deref_slot
> > never changes so I assume the output should be the same crappy page with
> > zero _count that drops me on the goto repeat line.
> > 
> > Is this a bug?
> > 
> > Also, is having a page->_count == 0 an unexpected or invalid state?
> > 
> > Thanks!
> > 
> > --mgross
> > 
> > 
> > 
> > 
> > 
> > --
> > To unsubscribe, send a message with 'unsubscribe linux-mm' in
> > the body to majordomo@kvack.org.  For more info on Linux MM,
> > see: http://www.linux-mm.org/ .
> > Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 
> 
> -- 
> Kinds Regards
> Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
