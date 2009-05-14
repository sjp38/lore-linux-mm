Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 7F3EE6B0142
	for <linux-mm@kvack.org>; Wed, 13 May 2009 20:06:59 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp ([10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n4E072iP011630
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 14 May 2009 09:07:02 +0900
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 1306845DE5D
	for <linux-mm@kvack.org>; Thu, 14 May 2009 09:07:02 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id A995E45DE51
	for <linux-mm@kvack.org>; Thu, 14 May 2009 09:07:01 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 7FA8A1DB8042
	for <linux-mm@kvack.org>; Thu, 14 May 2009 09:07:01 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 213CC1DB803F
	for <linux-mm@kvack.org>; Thu, 14 May 2009 09:07:01 +0900 (JST)
Date: Thu, 14 May 2009 09:05:29 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 2/3] fix swap cache account leak at swapin-readahead
Message-Id: <20090514090529.b7bfcb7b.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <Pine.LNX.4.64.0905131707330.27813@blonde.anvils>
References: <20090512104401.28edc0a8.kamezawa.hiroyu@jp.fujitsu.com>
	<20090512104603.ac4ca1f4.kamezawa.hiroyu@jp.fujitsu.com>
	<20090512112359.GA20771@cmpxchg.org>
	<20090513085816.13dc7709.kamezawa.hiroyu@jp.fujitsu.com>
	<20090513111800.GA2254@cmpxchg.org>
	<Pine.LNX.4.64.0905131707330.27813@blonde.anvils>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Hugh Dickins <hugh@veritas.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, "nishimura@mxp.nes.nec.co.jp" <nishimura@mxp.nes.nec.co.jp>, "akpm@linux-foundation.org" <akpm@linux-foundation.org>, mingo@elte.hu, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Johannes, Hugh, thank you for comments.


On Wed, 13 May 2009 19:03:47 +0100 (BST)
Hugh Dickins <hugh@veritas.com> wrote:

> On Wed, 13 May 2009, Johannes Weiner wrote:
> > On Wed, May 13, 2009 at 08:58:16AM +0900, KAMEZAWA Hiroyuki wrote:
> > > On Tue, 12 May 2009 13:24:00 +0200
> > > Johannes Weiner <hannes@cmpxchg.org> wrote:
> > > > On Tue, May 12, 2009 at 10:46:03AM +0900, KAMEZAWA Hiroyuki wrote:
> > > > > From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> > > > >
> > > > > Index: mmotm-2.6.30-May07/mm/swap_state.c
> > > > > ===================================================================
> > > > > --- mmotm-2.6.30-May07.orig/mm/swap_state.c
> > > > > +++ mmotm-2.6.30-May07/mm/swap_state.c
> > > > > @@ -349,9 +349,9 @@ struct page *read_swap_cache_async(swp_e
> > > > >  struct page *swapin_readahead(swp_entry_t entry, gfp_t gfp_mask,
> > > > >  			struct vm_area_struct *vma, unsigned long addr)
> > > > >  {
> > > > > -	int nr_pages;
> > > > > +	int nr_pages = 1;
> > > > >  	struct page *page;
> > > > > -	unsigned long offset;
> > > > > +	unsigned long offset = 0;
> > > > >  	unsigned long end_offset;
> > > > >  
> > > > >  	/*
> > > > > @@ -360,8 +360,22 @@ struct page *swapin_readahead(swp_entry_
> > > > >  	 * No, it's very unlikely that swap layout would follow vma layout,
> > > > >  	 * more likely that neighbouring swap pages came from the same node:
> > > > >  	 * so use the same "addr" to choose the same node for each swap read.
> > > > > +	 *
> > > > > +	 * But, when memcg is used, swapin readahead give us some bad
> > > > > +	 * effects. There are 2 big problems in general.
> > > > > +	 * 1. Swapin readahead tend to use/read _not required_ memory.
> > > > > +	 *    And _not required_ memory is only freed by global LRU.
> > > > > +	 * 2. We can't charge pages for swap-cache readahead because
> > > > > +	 *    we should avoid account memory in a cgroup which a
> > > > > +	 *    thread call this function is not related to.
> > > > > +	 * And swapin-readahead have racy condition with
> > > > > +	 * free_swap_and_cache(). This also annoys memcg.
> > > > > +	 * Then, if memcg is really used, we avoid readahead.
> > > > >  	 */
> > > > > -	nr_pages = valid_swaphandles(entry, &offset);
> > > > > +
> > > > > +	if (!mem_cgroup_activated())
> > > > > +		nr_pages = valid_swaphandles(entry, &offset);
> > > > > +
> > > > >  	for (end_offset = offset + nr_pages; offset < end_offset; offset++) {
> > > > >  		/* Ok, do the async read-ahead now */
> > > > >  		page = read_swap_cache_async(swp_entry(swp_type(entry), offset),
> > > > 
> > > > Having nr_pages set to 1 and offset to zero will actually enter hat
> > > > loop and try to read a swap slot at offset zero, including a
> > > > superfluous page allocation, just to fail at the swap_duplicate()
> > > > (swap slot 0 is swap header -> SWAP_MAP_BAD).
> > > > 
> > > Hmm ?
> > >  swp_entry(swp_type(entry), offset),
> > > can be zero ?
> > 
> > I'm not sure I understand your question.
> 
> Nor I, but I think KAMEZAWA-san is suggesting that we never come here
> with offset 0 anyway.  Which I believe is correct.
> 
Sorry for too short text. yes, I thought so.
 
> (And in passing, off topic, note that we have a problem if we ever
> do need to read page 0 in this way, in the swap-to-regular-file case: 
> because the swap_extents reading of page 0 can differ from sys_swapon's
> reading of the header page without swap_extents - possibly hibernate
> to swapfile can suffer from that, but not regular swapping paths.)
> 
> > Whether this whole
> > expression can or can not be zero is irrelevant.  My point is that you
> > enter the readahead loop with a bogus offset, while your original
> > intention is to completey disable readahead.
> 
> I don't really buy your point on offset 0 in particular: if offset 0
> is asked for, it goes through the intended motions, though you and I
> know that offset 0 will subsequently be found unsuitable; but it does
> what is asked of it.
> 
> However, I do agree with you that it's silly to be entering this loop
> at all when avoiding readahead.  When doing readahead, we have to cope
> with the fact that any of the calls in the loop might have failed, so
> we do the extra, targetted read_swap_cache_async at the end, to satisfy
> the actual request.  When avoiding readahead, better just to go to that
> final read_swap_cache_async, instead of duplicating it and compensating
> with a page_cache_release too.
> 
Ok, will do that.

> Which is what initializing nr_pages = 0 should achieve: see how
> valid_swaphandles() returns 0 rather than 1 when avoiding readahead,
> precisely to avoid the unnecessary duplication.  So I'd recommend
> nr_pages = 0 rather than nr_pages = 1 at the top.
> 

I see.

> > 
> > > > How about:
> > > > 
> > > > 	if (mem_cgroup_activated())
> > > > 		goto pivot;
> > > > 	nr_pages = valid_swaphandles(...);
> > > > 	for (readahead loop)
> > > > 		...
> > > > pivot:
> > > > 	return read_swap_cache_async();
> > > > 
> > > > That will also save you the runtime initialization of nr_pages and
> > > > offset completely when the cgroup is active.  And you'll have only one
> > > > branch and no second one for offset < end_offset in the loop.  And the
> > > > lru draining, but I'm not sure about that.  I think it's not needed.
> > > > 
> > > Hmm. I'm not sure why lru_add_drain()->read_swap_cache_async() is inserted before returing
> > > to caller. Is the page to be returned isn't necessary to be on LRU ?
> > 
> > I'm not sure either.  Neither the fault handler nor concurrent
> > swap-ins seem to care.  I added Hugh on CC.
> 
> Thanks, though you've probably got me from git-blame identifying when
> I moved that code around: the person you really want is akpm, then
> @digeo.com, in ChangeLog-2.5.46:
> 
> 	[PATCH] empty the deferred lru-addition buffers in swapin_readahead
> 	
> 	If we're about to return to userspace after performing some swap
> 	readahead, the pages in the deferred-addition LRU queues could stay
> 	there for some time.  So drain them after performing readahead.
> 
> I suspect that's a "seems like a good idea, especially if we've many cpus"
> (which I do agree with), rather than a practical finding in some workload.
> If we've read in a number of pages which quite possibly will prove of no
> use to anyone, better have them visible to reclaim on the LRU as soon as
> possible, rather than stuck indefinitely in per-cpu vectors.
> 
> The non-readahead case is a little different, in that you know the one
> page is really of use to someone; so it's less important to drain in
> that case, but whether worth avoiding the drain I don't know.
> 
Thank you very much ! It seems lru_add_drain is not necessary, here.


> (On the general matter of these patches: mostly these days I find no
> time to do better than let the memcg people go their own way.  I do
> like these minimal patches much better than those putting blocks of
> #ifdef'ed code into mm/page_io.c and mm/vmscan.c etc.
And it was not perfect ;(

> But we'll need
> to see what how badly suppressing readahead works out - as I've said
> before, I'm no devout believer in readahead here, but have observed
> in the past that it really does help.  I always thought that to handle
> swapin readahead correctly, the memcg people would need to record the
> cgs of what's on swap.)
> 

IIUC, we record it. But to use the record correctly, we have to "charge" newly
swapped-in pages which may not be used and may be under other cgroup which
we are not under. With big modification, we may be able to charge at
add_to_swap_cache(). But in this case, (when page_cluster=3)

  swp_entry + 0  -> cg0
  swp_entry + 1  -> cg1
  ..............
  swp_entry + 7  -> cg7

We may have to charge 8cgs and has to call try_to_free_pages() in 8cgs with
risk of OOM in other cgroup.

What I think ideal is
at swap_readahead()
==
  swp_entry + 0  -> special cg (or lru) for unused swap
  swp_entry + 1  -> special cg (or lru) for unused swap
  ...
  swp_entry + 7  -> special cg (or lru) for unused swap
==
And move SwapCaches in sepcial cg to real cg when they are mapped
(or added to shmem's address space).

But, now, I can't find a good way to add "special cg" without complicated races
and tons of codes. (Then, bugfix in this way will add more new bugs, I think.)

Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
