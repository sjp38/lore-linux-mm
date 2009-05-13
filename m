Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id B90A86B00ED
	for <linux-mm@kvack.org>; Wed, 13 May 2009 07:20:06 -0400 (EDT)
Date: Wed, 13 May 2009 13:18:00 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 2/3] fix swap cache account leak at swapin-readahead
Message-ID: <20090513111800.GA2254@cmpxchg.org>
References: <20090512104401.28edc0a8.kamezawa.hiroyu@jp.fujitsu.com> <20090512104603.ac4ca1f4.kamezawa.hiroyu@jp.fujitsu.com> <20090512112359.GA20771@cmpxchg.org> <20090513085816.13dc7709.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090513085816.13dc7709.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, mingo@elte.hu, Hugh Dickins <hugh@veritas.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, May 13, 2009 at 08:58:16AM +0900, KAMEZAWA Hiroyuki wrote:
> On Tue, 12 May 2009 13:24:00 +0200
> Johannes Weiner <hannes@cmpxchg.org> wrote:
> 
> > On Tue, May 12, 2009 at 10:46:03AM +0900, KAMEZAWA Hiroyuki wrote:
> > > From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > >
> > > Index: mmotm-2.6.30-May07/mm/swap_state.c
> > > ===================================================================
> > > --- mmotm-2.6.30-May07.orig/mm/swap_state.c
> > > +++ mmotm-2.6.30-May07/mm/swap_state.c
> > > @@ -349,9 +349,9 @@ struct page *read_swap_cache_async(swp_e
> > >  struct page *swapin_readahead(swp_entry_t entry, gfp_t gfp_mask,
> > >  			struct vm_area_struct *vma, unsigned long addr)
> > >  {
> > > -	int nr_pages;
> > > +	int nr_pages = 1;
> > >  	struct page *page;
> > > -	unsigned long offset;
> > > +	unsigned long offset = 0;
> > >  	unsigned long end_offset;
> > >  
> > >  	/*
> > > @@ -360,8 +360,22 @@ struct page *swapin_readahead(swp_entry_
> > >  	 * No, it's very unlikely that swap layout would follow vma layout,
> > >  	 * more likely that neighbouring swap pages came from the same node:
> > >  	 * so use the same "addr" to choose the same node for each swap read.
> > > +	 *
> > > +	 * But, when memcg is used, swapin readahead give us some bad
> > > +	 * effects. There are 2 big problems in general.
> > > +	 * 1. Swapin readahead tend to use/read _not required_ memory.
> > > +	 *    And _not required_ memory is only freed by global LRU.
> > > +	 * 2. We can't charge pages for swap-cache readahead because
> > > +	 *    we should avoid account memory in a cgroup which a
> > > +	 *    thread call this function is not related to.
> > > +	 * And swapin-readahead have racy condition with
> > > +	 * free_swap_and_cache(). This also annoys memcg.
> > > +	 * Then, if memcg is really used, we avoid readahead.
> > >  	 */
> > > -	nr_pages = valid_swaphandles(entry, &offset);
> > > +
> > > +	if (!mem_cgroup_activated())
> > > +		nr_pages = valid_swaphandles(entry, &offset);
> > > +
> > >  	for (end_offset = offset + nr_pages; offset < end_offset; offset++) {
> > >  		/* Ok, do the async read-ahead now */
> > >  		page = read_swap_cache_async(swp_entry(swp_type(entry), offset),
> > 
> > Having nr_pages set to 1 and offset to zero will actually enter hat
> > loop and try to read a swap slot at offset zero, including a
> > superfluous page allocation, just to fail at the swap_duplicate()
> > (swap slot 0 is swap header -> SWAP_MAP_BAD).
> > 
> Hmm ?
>  swp_entry(swp_type(entry), offset),
> can be zero ?

I'm not sure I understand your question.  Whether this whole
expression can or can not be zero is irrelevant.  My point is that you
enter the readahead loop with a bogus offset, while your original
intention is to completey disable readahead.

> > How about:
> > 
> > 	if (mem_cgroup_activated())
> > 		goto pivot;
> > 	nr_pages = valid_swaphandles(...);
> > 	for (readahead loop)
> > 		...
> > pivot:
> > 	return read_swap_cache_async();
> > 
> > That will also save you the runtime initialization of nr_pages and
> > offset completely when the cgroup is active.  And you'll have only one
> > branch and no second one for offset < end_offset in the loop.  And the
> > lru draining, but I'm not sure about that.  I think it's not needed.
> > 
> Hmm. I'm not sure why lru_add_drain()->read_swap_cache_async() is inserted before returing
> to caller. Is the page to be returned isn't necessary to be on LRU ?

I'm not sure either.  Neither the fault handler nor concurrent
swap-ins seem to care.  I added Hugh on CC.

	Hannes

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
