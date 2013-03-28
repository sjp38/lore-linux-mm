Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx183.postini.com [74.125.245.183])
	by kanga.kvack.org (Postfix) with SMTP id EAE276B0027
	for <linux-mm@kvack.org>; Wed, 27 Mar 2013 21:55:04 -0400 (EDT)
Received: by mail-da0-f47.google.com with SMTP id s35so4332339dak.20
        for <linux-mm@kvack.org>; Wed, 27 Mar 2013 18:55:04 -0700 (PDT)
Date: Thu, 28 Mar 2013 09:54:52 +0800
From: Shaohua Li <shli@kernel.org>
Subject: Re: [RFC] mm: remove swapcache page early
Message-ID: <20130328015452.GA17351@kernel.org>
References: <1364350932-12853-1-git-send-email-minchan@kernel.org>
 <alpine.LNX.2.00.1303271230210.29687@eggly.anvils>
 <433aaa17-7547-4e39-b472-7060ee15e85f@default>
 <alpine.LNX.2.00.1303271541200.30535@eggly.anvils>
 <20130328011824.GC22908@blaptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130328011824.GC22908@blaptop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Hugh Dickins <hughd@google.com>, Dan Magenheimer <dan.magenheimer@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Seth Jennings <sjenning@linux.vnet.ibm.com>, Nitin Gupta <ngupta@vflare.org>, Konrad Rzeszutek Wilk <konrad@darnok.org>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Bob Liu <bob.liu@oracle.com>

On Thu, Mar 28, 2013 at 10:18:24AM +0900, Minchan Kim wrote:
> On Wed, Mar 27, 2013 at 04:16:48PM -0700, Hugh Dickins wrote:
> > On Wed, 27 Mar 2013, Dan Magenheimer wrote:
> > > > From: Hugh Dickins [mailto:hughd@google.com]
> > > > Subject: Re: [RFC] mm: remove swapcache page early
> > > > 
> > > > On Wed, 27 Mar 2013, Minchan Kim wrote:
> > > > 
> > > > > Swap subsystem does lazy swap slot free with expecting the page
> > > > > would be swapped out again so we can't avoid unnecessary write.
> > > >                              so we can avoid unnecessary write.
> > > > >
> > > > > But the problem in in-memory swap is that it consumes memory space
> > > > > until vm_swap_full(ie, used half of all of swap device) condition
> > > > > meet. It could be bad if we use multiple swap device, small in-memory swap
> > > > > and big storage swap or in-memory swap alone.
> > > > 
> > > > That is a very good realization: it's surprising that none of us
> > > > thought of it before - no disrespect to you, well done, thank you.
> > > 
> > > Yes, my compliments also Minchan.  This problem has been thought of before
> > > but this patch is the first to identify a possible solution.
> > >  
> > > > And I guess swap readahead is utterly unhelpful in this case too.
> > > 
> > > Yes... as is any "swap writeahead".  Excuse my ignorance, but I
> > > think this is not done in the swap subsystem but instead the kernel
> > > assumes write-coalescing will be done in the block I/O subsystem,
> > > which means swap writeahead would affect zram but not zcache/zswap
> > > (since frontswap subverts the block I/O subsystem).
> > 
> > I don't know what swap writeahead is; but write coalescing, yes.
> > I don't see any problem with it in this context.
> > 
> > > 
> > > However I think a swap-readahead solution would be helpful to
> > > zram as well as zcache/zswap.
> > 
> > Whereas swap readahead on zmem is uncompressing zmem to pagecache
> > which may never be needed, and may take a circuit of the inactive
> > LRU before it gets reclaimed (if it turns out not to be needed,
> > at least it will remain clean and be easily reclaimed).
> 
> But it could evict more important pages before reaching out the tail.
> That's thing we really want to avoid if possible.
> 
> > 
> > > 
> > > > > This patch changes vm_swap_full logic slightly so it could free
> > > > > swap slot early if the backed device is really fast.
> > > > > For it, I used SWP_SOLIDSTATE but It might be controversial.
> > > > 
> > > > But I strongly disagree with almost everything in your patch :)
> > > > I disagree with addressing it in vm_swap_full(), I disagree that
> > > > it can be addressed by device, I disagree that it has anything to
> > > > do with SWP_SOLIDSTATE.
> > > > 
> > > > This is not a problem with swapping to /dev/ram0 or to /dev/zram0,
> > > > is it?  In those cases, a fixed amount of memory has been set aside
> > > > for swap, and it works out just like with disk block devices.  The
> > > > memory set aside may be wasted, but that is accepted upfront.
> > > 
> > > It is (I believe) also a problem with swapping to ram.  Two
> > > copies of the same page are kept in memory in different places,
> > > right?  Fixed vs variable size is irrelevant I think.  Or am
> > > I misunderstanding something about swap-to-ram?
> > 
> > I may be misrembering how /dev/ram0 works, or simply assuming that
> > if you want to use it for swap (interesting for testing, but probably
> > not for general use), then you make sure to allocate each page of it
> > in advance.
> > 
> > The pages of /dev/ram0 don't get freed, or not before it's closed
> > (swapoff'ed) anyway.  Yes, swapcache would be duplicating data from
> > other memory into /dev/ram0 memory; but that /dev/ram0 memory has
> > been set aside for this purpose, and removing from swapcache won't
> > free any more memory.
> > 
> > > 
> > > > Similarly, this is not a problem with swapping to SSD.  There might
> > > > or might not be other reasons for adjusting the vm_swap_full() logic
> > > > for SSD or generally, but those have nothing to do with this issue.
> > > 
> > > I think it is at least highly related.  The key issue is the
> > > tradeoff of the likelihood that the page will soon be read/written
> > > again while it is in swap cache vs the time/resource-usage necessary
> > > to "reconstitute" the page into swap cache.  Reconstituting from disk
> > > requires a LOT of elapsed time.  Reconstituting from
> > > an SSD likely takes much less time.  Reconstituting from
> > > zcache/zram takes thousands of CPU cycles.
> > 
> > I acknowledge my complete ignorance of how to judge the tradeoff
> > between memory usage and cpu usage, but I think Minchan's main
> > concern was with the memory usage.  Neither hard disk nor SSD
> > is occupying memory.
> 
> Hmm, It seems I misunderstood Dan's opinion in previous thread.
> You're right, Hugh. My main concern is memory usage but the rationale
> I used SWP_SOLIDSTATE is writing on SSD could be cheap rather than 
> storage. Yeb, it depends on SSD's internal's FTL algorith and fragment
> ratio due to wear-leveling. That's why I said "It might be controversial".

Even SSD is fast, there is tradeoff. And unncessary write to SSD should be
avoided if possible, because write makes wear out faster and makes subsequent
write slower potentially (if garbage collection runs).

Thanks,
Shaohua

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
