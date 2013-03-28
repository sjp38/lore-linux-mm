Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx129.postini.com [74.125.245.129])
	by kanga.kvack.org (Postfix) with SMTP id 5E39F6B0027
	for <linux-mm@kvack.org>; Wed, 27 Mar 2013 21:18:28 -0400 (EDT)
Date: Thu, 28 Mar 2013 10:18:24 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [RFC] mm: remove swapcache page early
Message-ID: <20130328011824.GC22908@blaptop>
References: <1364350932-12853-1-git-send-email-minchan@kernel.org>
 <alpine.LNX.2.00.1303271230210.29687@eggly.anvils>
 <433aaa17-7547-4e39-b472-7060ee15e85f@default>
 <alpine.LNX.2.00.1303271541200.30535@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LNX.2.00.1303271541200.30535@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Dan Magenheimer <dan.magenheimer@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Seth Jennings <sjenning@linux.vnet.ibm.com>, Nitin Gupta <ngupta@vflare.org>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Shaohua Li <shli@kernel.org>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Bob Liu <bob.liu@oracle.com>

On Wed, Mar 27, 2013 at 04:16:48PM -0700, Hugh Dickins wrote:
> On Wed, 27 Mar 2013, Dan Magenheimer wrote:
> > > From: Hugh Dickins [mailto:hughd@google.com]
> > > Subject: Re: [RFC] mm: remove swapcache page early
> > > 
> > > On Wed, 27 Mar 2013, Minchan Kim wrote:
> > > 
> > > > Swap subsystem does lazy swap slot free with expecting the page
> > > > would be swapped out again so we can't avoid unnecessary write.
> > >                              so we can avoid unnecessary write.
> > > >
> > > > But the problem in in-memory swap is that it consumes memory space
> > > > until vm_swap_full(ie, used half of all of swap device) condition
> > > > meet. It could be bad if we use multiple swap device, small in-memory swap
> > > > and big storage swap or in-memory swap alone.
> > > 
> > > That is a very good realization: it's surprising that none of us
> > > thought of it before - no disrespect to you, well done, thank you.
> > 
> > Yes, my compliments also Minchan.  This problem has been thought of before
> > but this patch is the first to identify a possible solution.
> >  
> > > And I guess swap readahead is utterly unhelpful in this case too.
> > 
> > Yes... as is any "swap writeahead".  Excuse my ignorance, but I
> > think this is not done in the swap subsystem but instead the kernel
> > assumes write-coalescing will be done in the block I/O subsystem,
> > which means swap writeahead would affect zram but not zcache/zswap
> > (since frontswap subverts the block I/O subsystem).
> 
> I don't know what swap writeahead is; but write coalescing, yes.
> I don't see any problem with it in this context.
> 
> > 
> > However I think a swap-readahead solution would be helpful to
> > zram as well as zcache/zswap.
> 
> Whereas swap readahead on zmem is uncompressing zmem to pagecache
> which may never be needed, and may take a circuit of the inactive
> LRU before it gets reclaimed (if it turns out not to be needed,
> at least it will remain clean and be easily reclaimed).

But it could evict more important pages before reaching out the tail.
That's thing we really want to avoid if possible.

> 
> > 
> > > > This patch changes vm_swap_full logic slightly so it could free
> > > > swap slot early if the backed device is really fast.
> > > > For it, I used SWP_SOLIDSTATE but It might be controversial.
> > > 
> > > But I strongly disagree with almost everything in your patch :)
> > > I disagree with addressing it in vm_swap_full(), I disagree that
> > > it can be addressed by device, I disagree that it has anything to
> > > do with SWP_SOLIDSTATE.
> > > 
> > > This is not a problem with swapping to /dev/ram0 or to /dev/zram0,
> > > is it?  In those cases, a fixed amount of memory has been set aside
> > > for swap, and it works out just like with disk block devices.  The
> > > memory set aside may be wasted, but that is accepted upfront.
> > 
> > It is (I believe) also a problem with swapping to ram.  Two
> > copies of the same page are kept in memory in different places,
> > right?  Fixed vs variable size is irrelevant I think.  Or am
> > I misunderstanding something about swap-to-ram?
> 
> I may be misrembering how /dev/ram0 works, or simply assuming that
> if you want to use it for swap (interesting for testing, but probably
> not for general use), then you make sure to allocate each page of it
> in advance.
> 
> The pages of /dev/ram0 don't get freed, or not before it's closed
> (swapoff'ed) anyway.  Yes, swapcache would be duplicating data from
> other memory into /dev/ram0 memory; but that /dev/ram0 memory has
> been set aside for this purpose, and removing from swapcache won't
> free any more memory.
> 
> > 
> > > Similarly, this is not a problem with swapping to SSD.  There might
> > > or might not be other reasons for adjusting the vm_swap_full() logic
> > > for SSD or generally, but those have nothing to do with this issue.
> > 
> > I think it is at least highly related.  The key issue is the
> > tradeoff of the likelihood that the page will soon be read/written
> > again while it is in swap cache vs the time/resource-usage necessary
> > to "reconstitute" the page into swap cache.  Reconstituting from disk
> > requires a LOT of elapsed time.  Reconstituting from
> > an SSD likely takes much less time.  Reconstituting from
> > zcache/zram takes thousands of CPU cycles.
> 
> I acknowledge my complete ignorance of how to judge the tradeoff
> between memory usage and cpu usage, but I think Minchan's main
> concern was with the memory usage.  Neither hard disk nor SSD
> is occupying memory.

Hmm, It seems I misunderstood Dan's opinion in previous thread.
You're right, Hugh. My main concern is memory usage but the rationale
I used SWP_SOLIDSTATE is writing on SSD could be cheap rather than 
storage. Yeb, it depends on SSD's internal's FTL algorith and fragment
ratio due to wear-leveling. That's why I said "It might be controversial".

> 
> > 
> > > The problem here is peculiar to frontswap, and the variably sized
> > > memory behind it, isn't it?  We are accustomed to using swap to free
> > > up memory by transferring its data to some other, cheaper but slower
> > > resource.
> > 
> > Frontswap does make the problem more complex because some pages
> > are in "fairly fast" storage (zcache, needs decompression) and
> > some are on the actual (usually) rotating media.  Fortunately,
> > differentiating between these two cases is just a table lookup
> > (see frontswap_test).
> > 
> > > But in the case of frontswap and zmem (I'll say that to avoid thinking
> > > through which backends are actually involved), it is not a cheaper and
> > > slower resource, but the very same memory we are trying to save: swap
> > > is stolen from the memory under reclaim, so any duplication becomes
> > > counter-productive (if we ignore cpu compression/decompression costs:
> > > I have no idea how fair it is to do so, but anyone who chooses zmem
> > > is prepared to pay some cpu price for that).
> > 
> > Exactly.  There is some "robbing of Peter to pay Paul" and
> > other complex resource tradeoffs.  Presumably, though, it is
> > not "the very same memory we are trying to save" but a
> > fraction of it, saving the same page of data more efficiently
> > in memory, using less than a page, at some CPU cost.
> 
> Yes, I'm not saying that frontswap/zmem is pointless: just agreeing
> with Minchan that in this case the duplication inherent in swapcache
> can be waste of memory that we should try to avoid.
> 
> > 
> > > And because it's a frontswap thing, we cannot decide this by device:
> > > frontswap may or may not stand in front of each device.  There is no
> > > problem with swapcache duplicated on disk (until that area approaches
> > > being full or fragmented), but at the higher level we cannot see what
> > > is in zmem and what is on disk: we only want to free up the zmem dup.
> > 
> > I *think* frontswap_test(page) resolves this problem, as long as
> > we have a specific page available to use as a parameter.
> > 
> > > I believe the answer is for frontswap/zmem to invalidate the frontswap
> > > copy of the page (to free up the compressed memory when possible) and
> > > SetPageDirty on the PageUptodate PageSwapCache page when swapping in
> > > (setting page dirty so nothing will later go to read it from the
> > > unfreed location on backing swap disk, which was never written).
> > 
> > There are two duplication issues:  (1) When can the page be removed
> > from the swap cache after a call to frontswap_store; and (2) When
> > can the page be removed from the frontswap storage after it
> > has been brought back into memory via frontswap_load.
> > 
> > This patch from Minchan addresses (1).
> 
> Ying Han was reminding me of this case a couple of hours ago, we don't
> see a problem there: when frontswap_store() succeeds, there's an
> end_page_writeback() as there should be, and shrink_page_list()
> should reclaim the page immediately.  So I think (1) is already
> handled and Minchan was not trying to address it.

Absolutely.

> 
> > The issue you are raising
> > here is (2).  You may not know that (2) has recently been solved
> > in frontswap, at least for zcache.  See frontswap_exclusive_gets_enabled.
> > If this is enabled (and it is for zcache but not yet for zswap),
> > what you suggest (SetPageDirty) is what happens.
> 
> Ah, and I have a dim, perhaps mistaken, memory that I gave you
> input on that before, suggesting the SetPageDirty.  Good, sounds
> like the solution is already in place, if not actually activated.
> 
> Thanks, must dash,
> Hugh
> 
> > 
> > > We cannot rely on freeing the swap itself, because in general there
> > > may be multiple references to the swap, and we only satisfy the one
> > > which has faulted.  It may or may not be a good idea to use rmap to
> > > locate the other places to insert pte in place of swap entry, to
> > > resolve them all at once; but we have chosen not to do so in the
> > > past, and there's no need for that, if the zmem gets invalidated
> > > and the swapcache page set dirty.
> > 
> > I see.  Minchan's patch handles the removal "reactively"... it
> > might be possible to handle it more proactively.  Or it may
> > be possible to take the number of references into account when
> > deciding whether to frontswap_store the page as, presumably,
> > the likelihood of needing to "reconstitute" the page sooner increases
> > with each additional reference.
> > 
> > > Hugh
> > 
> > Very useful thoughts, Hugh.  Thanks much and looking forward
> > to more discussion at LSF/MM!
> > 
> > Dan
> > 
> > P.S. When I refer to zcache, I am referring to the version in
> > drivers/staging/zcache in 3.9.  The code in drivers/staging/zcache
> > in 3.8 is "old zcache"... "new zcache" is in drivers/staging/ramster
> > in 3.8.  Sorry for any confusion...
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
