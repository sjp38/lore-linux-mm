Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id E263A6B00A4
	for <linux-mm@kvack.org>; Tue, 12 May 2009 19:58:53 -0400 (EDT)
Received: from mt1.gw.fujitsu.co.jp ([10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n4CNxl8K010697
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Wed, 13 May 2009 08:59:47 +0900
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 2ECCD45DE52
	for <linux-mm@kvack.org>; Wed, 13 May 2009 08:59:47 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id F0D5445DE54
	for <linux-mm@kvack.org>; Wed, 13 May 2009 08:59:46 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id CD10E1DB803C
	for <linux-mm@kvack.org>; Wed, 13 May 2009 08:59:46 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.249.87.107])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 6B2321DB803F
	for <linux-mm@kvack.org>; Wed, 13 May 2009 08:59:46 +0900 (JST)
Date: Wed, 13 May 2009 08:58:16 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 2/3] fix swap cache account leak at swapin-readahead
Message-Id: <20090513085816.13dc7709.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20090512112359.GA20771@cmpxchg.org>
References: <20090512104401.28edc0a8.kamezawa.hiroyu@jp.fujitsu.com>
	<20090512104603.ac4ca1f4.kamezawa.hiroyu@jp.fujitsu.com>
	<20090512112359.GA20771@cmpxchg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, mingo@elte.hu, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Tue, 12 May 2009 13:24:00 +0200
Johannes Weiner <hannes@cmpxchg.org> wrote:

> On Tue, May 12, 2009 at 10:46:03AM +0900, KAMEZAWA Hiroyuki wrote:
> > From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > 
> > In general, Linux's swp_entry handling is done by combination of lazy techniques
> > and global LRU. It works well but when we use mem+swap controller, some more
> > strict control is appropriate. Otherwise, swp_entry used by a cgroup will be
> > never freed until global LRU works. In a system where memcg is well-configured,
> > global LRU doesn't work frequently.
> > 
> >   Example) Assume swapin-readahead.
> > 	      CPU0			      CPU1
> > 	   zap_pte()			  read_swap_cache_async()
> > 					  swap_duplicate().
> >            swap_entry_free() = 1
> > 	   find_get_page()=> NULL.
> > 					  add_to_swap_cache().
> > 					  issue swap I/O. 
> > 
> > There are many patterns of this kind of race (but no problems).
> > 
> > free_swap_and_cache() is called for freeing swp_entry. But it is a best-effort
> > function. If the swp_entry/page seems busy, swp_entry is not freed.
> > This is not a problem because global-LRU will find SwapCache at page reclaim.
> > 
> > If memcg is used, on the other hand, global LRU may not work. Then, above
> > unused SwapCache will not be freed.
> > (unmapped SwapCache occupy swp_entry but never be freed if not on memcg's LRU)
> > 
> > So, even if there are no tasks in a cgroup, swp_entry usage still remains.
> > In bad case, OOM by mem+swap controller is triggered by this "leak" of
> > swp_entry as Nishimura reported.
> > 
> > Considering this issue, swapin-readahead itself is not very good for memcg.
> > It read swap cache which will not be used. (and _unused_ swapcache will
> > not be accounted.) Even if we account swap cache at add_to_swap_cache(),
> > we need to account page to several _unrelated_ memcg. This is bad.
> > 
> > This patch tries to fix racy case of free_swap_and_cache() and page status.
> > 
> > After this patch applied, following test works well.
> > 
> >   # echo 1-2M > ../memory.limit_in_bytes
> >   # run tasks under memcg.
> >   # kill all tasks and make memory.tasks empty
> >   # check memory.memsw.usage_in_bytes == memory.usage_in_bytes and
> >     there is no _used_ swp_entry.
> > 
> > What this patch does is
> >  - avoid swapin-readahead when memcg is activated.
> > 
> > Changelog: v6 -> v7
> >  - just handle races in readahead.
> >  - races in writeback is handled in the next patch.
> > 
> > Changelog: v5 -> v6
> >  - works only when memcg is activated.
> >  - check after I/O works only after writeback.
> >  - avoid swapin-readahead when memcg is activated.
> >  - fixed page refcnt issue.
> > Changelog: v4->v5
> >  - completely new design.
> > 
> > Reported-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
> > Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > ---
> >  mm/swap_state.c |   20 +++++++++++++++++---
> >  1 file changed, 17 insertions(+), 3 deletions(-)
> > 
> > Index: mmotm-2.6.30-May07/mm/swap_state.c
> > ===================================================================
> > --- mmotm-2.6.30-May07.orig/mm/swap_state.c
> > +++ mmotm-2.6.30-May07/mm/swap_state.c
> > @@ -349,9 +349,9 @@ struct page *read_swap_cache_async(swp_e
> >  struct page *swapin_readahead(swp_entry_t entry, gfp_t gfp_mask,
> >  			struct vm_area_struct *vma, unsigned long addr)
> >  {
> > -	int nr_pages;
> > +	int nr_pages = 1;
> >  	struct page *page;
> > -	unsigned long offset;
> > +	unsigned long offset = 0;
> >  	unsigned long end_offset;
> >  
> >  	/*
> > @@ -360,8 +360,22 @@ struct page *swapin_readahead(swp_entry_
> >  	 * No, it's very unlikely that swap layout would follow vma layout,
> >  	 * more likely that neighbouring swap pages came from the same node:
> >  	 * so use the same "addr" to choose the same node for each swap read.
> > +	 *
> > +	 * But, when memcg is used, swapin readahead give us some bad
> > +	 * effects. There are 2 big problems in general.
> > +	 * 1. Swapin readahead tend to use/read _not required_ memory.
> > +	 *    And _not required_ memory is only freed by global LRU.
> > +	 * 2. We can't charge pages for swap-cache readahead because
> > +	 *    we should avoid account memory in a cgroup which a
> > +	 *    thread call this function is not related to.
> > +	 * And swapin-readahead have racy condition with
> > +	 * free_swap_and_cache(). This also annoys memcg.
> > +	 * Then, if memcg is really used, we avoid readahead.
> >  	 */
> > -	nr_pages = valid_swaphandles(entry, &offset);
> > +
> > +	if (!mem_cgroup_activated())
> > +		nr_pages = valid_swaphandles(entry, &offset);
> > +
> >  	for (end_offset = offset + nr_pages; offset < end_offset; offset++) {
> >  		/* Ok, do the async read-ahead now */
> >  		page = read_swap_cache_async(swp_entry(swp_type(entry), offset),
> 
> Having nr_pages set to 1 and offset to zero will actually enter hat
> loop and try to read a swap slot at offset zero, including a
> superfluous page allocation, just to fail at the swap_duplicate()
> (swap slot 0 is swap header -> SWAP_MAP_BAD).
> 
Hmm ?
 swp_entry(swp_type(entry), offset),
can be zero ?

> How about:
> 
> 	if (mem_cgroup_activated())
> 		goto pivot;
> 	nr_pages = valid_swaphandles(...);
> 	for (readahead loop)
> 		...
> pivot:
> 	return read_swap_cache_async();
> 
> That will also save you the runtime initialization of nr_pages and
> offset completely when the cgroup is active.  And you'll have only one
> branch and no second one for offset < end_offset in the loop.  And the
> lru draining, but I'm not sure about that.  I think it's not needed.
> 
Hmm. I'm not sure why lru_add_drain()->read_swap_cache_async() is inserted before returing
to caller. Is the page to be returned isn't necessary to be on LRU ?

Thanks,
-Kame



> 	Hannes
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
