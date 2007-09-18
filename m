Subject: Re: [PATCH/RFC 11/14] Reclaim Scalability: swap backed pages are
	nonreclaimable when no swap space available
From: Lee Schermerhorn <Lee.Schermerhorn@hp.com>
In-Reply-To: <20070918115933.886238b3.kamezawa.hiroyu@jp.fujitsu.com>
References: <20070914205359.6536.98017.sendpatchset@localhost>
	 <20070914205512.6536.89432.sendpatchset@localhost>
	 <20070918115933.886238b3.kamezawa.hiroyu@jp.fujitsu.com>
Content-Type: text/plain
Date: Tue, 18 Sep 2007 11:47:21 -0400
Message-Id: <1190130442.5035.36.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, mel@csn.ul.ie, clameter@sgi.com, riel@redhat.com, balbir@linux.vnet.ibm.com, andrea@suse.de, a.p.zijlstra@chello.nl, eric.whitney@hp.com, npiggin@suse.de
List-ID: <linux-mm.kvack.org>

On Tue, 2007-09-18 at 11:59 +0900, KAMEZAWA Hiroyuki wrote:
> On Fri, 14 Sep 2007 16:55:12 -0400
> Lee Schermerhorn <lee.schermerhorn@hp.com> wrote:
> 
> > +#ifdef CONFIG_NORECLAIM_NO_SWAP
> > +	if (page_anon(page) && !PageSwapCache(page) && !nr_swap_pages)
> > +		return 0;
> > +#endif
> 
> nr_swap_pages depends on CONFIG_SWAP. 

I didn't think that was the case [see definition in page_alloc.c and
extern declaration in swap.h].  If this is the case, I'll have to change
that.  

> 
> So I recommend you to use total_swap_pages. (if CONFIG_SWAP=n, total_swap_pages is
> compield to be 0.)

total_swap_pages is not appropriate in this context.  total_swap_pages
can be non-zero, but we can have MANY more swap-backed pages than we
have room for.  So, we want to declare any such pages as non-reclaimable
once the existing swap space has been exhausted.  That's the theory,
anyway.

> 
> ==
> if (!total_swap_pages && page_anon(page)) 
> 	return 0;
> ==
> By the way, nr_swap_pages is "# of currently available swap pages".
> Should this page will be put into NORECLAIM list ? This number can be
> changed to be > 0 easily.

Right.  This means we need to come up with a way to bring pages back
from the noreclaim list when swap becomes available.  This is currently
and unsolved problem--the noreclaim series IS a work in progress :-).  

Now, Rik vR has a patch that I've kept around in another tree, that
frees swap space when pages are swapped in, if we're under "swap
pressure"  [swap space > 1/2 full].  We might want to add this patch
into the mix and, perhaps, keep the various types of non-reclaimable
pages on different lists--e.g., in this case, the unswappable list.
Then, if the list is non-empty when we free a page of swap space, we can
bring back one page from the "unswappable" list.  Thus, we'd rotate
pages through the unswappable noreclaim state so as to not penalize
late-comers after swap space has all been allocated.

Again, I have got there yet, and am open to suggestions, patches, ...


Thanks,
Lee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
