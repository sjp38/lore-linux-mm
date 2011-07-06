Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id B1FF49000C2
	for <linux-mm@kvack.org>; Wed,  6 Jul 2011 03:17:39 -0400 (EDT)
Date: Wed, 6 Jul 2011 17:17:33 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 03/27] xfs: use write_cache_pages for writeback
 clustering
Message-ID: <20110706071733.GY1026@dastard>
References: <20110629140109.003209430@bombadil.infradead.org>
 <20110629140336.950805096@bombadil.infradead.org>
 <20110701022248.GM561@dastard>
 <20110701041851.GN561@dastard>
 <20110701093305.GA28531@infradead.org>
 <20110701154136.GA17881@localhost>
 <20110704032534.GD1026@dastard>
 <20110706045301.GA11604@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <20110706045301.GA11604@localhost>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Christoph Hellwig <hch@infradead.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <jweiner@redhat.com>, "xfs@oss.sgi.com" <xfs@oss.sgi.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Tue, Jul 05, 2011 at 09:53:01PM -0700, Wu Fengguang wrote:
> On Mon, Jul 04, 2011 at 11:25:34AM +0800, Dave Chinner wrote:
> > On Fri, Jul 01, 2011 at 11:41:36PM +0800, Wu Fengguang wrote:
> > We have to remember that memory reclaim is doing LRU reclaim and the
> > flusher threads are doing "oldest first" writeback. IOWs, both are trying
> > to operate in the same direction (oldest to youngest) for the same
> > purpose.  The fundamental problem that occurs when memory reclaim
> > starts writing pages back from the LRU is this:
> > 
> > 	- memory reclaim has run ahead of IO writeback -
> > 
> > The LRU usually looks like this:
> > 
> > 	oldest					youngest
> > 	+---------------+---------------+--------------+
> > 	clean		writeback	dirty
> > 			^		^
> > 			|		|
> > 			|		Where flusher will next work from
> > 			|		Where kswapd is working from
> > 			|
> > 			IO submitted by flusher, waiting on completion
> > 
> > 
> > If memory reclaim is hitting dirty pages on the LRU, it means it has
> > got ahead of writeback without being throttled - it's passed over
> > all the pages currently under writeback and is trying to write back
> > pages that are *newer* than what writeback is working on. IOWs, it
> > starts trying to do the job of the flusher threads, and it does that
> > very badly.
> > 
> > The $100 question is a??why is it getting ahead of writeback*?
> 
> The most important case is: faster reader + relatively slow writer.

Same thing I said to Mel: that is not the workload that is causing
this problem I am seeing.

> Assume for every 10 pages read, 1 page is dirtied, and the dirty speed
> is fast enough to trigger the 20% dirty ratio and hence dirty balancing.
> 
> That pattern is able to evenly distribute dirty pages all over the LRU
> list and hence trigger lots of pageout()s. The "skip reclaim writes on
> low pressure" approach can fix this case.

Sure it can, but even better would be to simply skip the dirty pages
and reclaim the interspersed clean pages which greatly
outnumber the dirty pages. That then lets writeback deal with
cleaning the dirty pages in the most optimal manner, and no
writeback from memory reclaim is needed.

IOWs, I don't think writeback from the LRU is the right solution to
the problem you've described, either.

> 
> Thanks,
> Fengguang
> ---
> Subject: writeback: introduce bdi_start_inode_writeback()
> Date: Thu Jul 29 14:41:19 CST 2010
> 
> This relays ASYNC file writeback IOs to the flusher threads.
> 
> pageout() will continue to serve the SYNC file page writes for necessary
> throttling for preventing OOM, which may happen if the LRU list is small
> and/or the storage is slow, so that the flusher cannot clean enough
> pages before the LRU is full scanned.
> 
> Only ASYNC pageout() is relayed to the flusher threads, the less
> frequent SYNC pageout()s will work as before as a last resort.
> This helps to avoid OOM when the LRU list is small and/or the storage is
> slow, and the flusher cannot clean enough pages before the LRU is
> full scanned.

Which ignores the fact that async pageout should not be happening in
most cases. Let's try and fix the root cause of the problem, not
paper over it again...

> The flusher will piggy back more dirty pages for IO
> - it's more IO efficient
> - it helps clean more pages, a good number of them may sit in the same
>   LRU list that is being scanned.
> 
> To avoid memory allocations at page reclaim, a mempool is created.
> 
> Background/periodic works will quit automatically (as done in another
> patch), so as to clean the pages under reclaim ASAP. However for now the
> sync work can still block us for long time.

>  /*
> + * When flushing an inode page (for page reclaim), try to piggy back up to
> + * 4MB nearby pages for IO efficiency. These pages will have good opportunity
> + * to be in the same LRU list.
> + */
> +#define WRITE_AROUND_PAGES	MIN_WRITEBACK_PAGES

Regardless of the trigger, I think you're going too far in the other
direction, here. If we have to do one IO to clean the page that the
VM wants, then it has to be done with as little latency as possible
but large enough to still maintain decent throughput.

With the above patch, for every single dirty page the VM wants
cleaned, we'll clean 4MB of pages around it. Ok, but once the VM has
tripped over pages on 25 different inodes, we've now got 100MB of
writeback work to chew through before we can get to the 26th page
the VM wanted cleaned.

At which point, we may as well just ignore what the VM wants and
continue to clean pages via the existing mechanisms because the
latency for cleaning a specific page will worse than if the VM just
skipped it in the first place....

FWIW, XFS limited such clustering to 64 pages at a time to try to
balance the bandwidth vs completion latency problem.


> +/*
> + * Called by page reclaim code to flush the dirty page ASAP. Do write-around to
> + * improve IO throughput. The nearby pages will have good chance to reside in
> + * the same LRU list that vmscan is working on, and even close to each other
> + * inside the LRU list in the common case of sequential read/write.
> + *
> + * ret > 0: success, found/reused a previous writeback work
> + * ret = 0: success, allocated/queued a new writeback work
> + * ret < 0: failed
> + */
> +long flush_inode_page(struct page *page, struct address_space *mapping)
> +{
> +	struct backing_dev_info *bdi = mapping->backing_dev_info;
> +	struct inode *inode = mapping->host;
> +	pgoff_t offset = page->index;
> +	pgoff_t len = 0;
> +	struct wb_writeback_work *work;
> +	long ret = -ENOENT;
> +
> +	if (unlikely(!inode))
> +		goto out;
> +
> +	len = 1;
> +	spin_lock_bh(&bdi->wb_lock);
> +	list_for_each_entry_reverse(work, &bdi->work_list, list) {
> +		if (work->inode != inode)
> +			continue;
> +		if (extend_writeback_range(work, offset)) {
> +			ret = len;
> +			offset = work->offset;
> +			len = work->nr_pages;
> +			break;
> +		}
> +		if (len++ > 30)	/* do limited search */
> +			break;
> +	}
> +	spin_unlock_bh(&bdi->wb_lock);

I dont think this is a necessary or scalable optimisation. It won't
be useful when there are lots of dirty inodes and dirty pages are
tripped over in their hundreds or thousands - it'll just burn CPU
doing nothing, and serialise against other reclaim and writeback
work. It looks like a case of premature optimisation to me....

Anyway, if there's a page flush near to an existing piece of work the
IO elevator should merge them appropriately.

> +static long wb_flush_inode(struct bdi_writeback *wb,
> +			   struct wb_writeback_work *work)
> +{
> +	loff_t start = work->offset;
> +	loff_t end   = work->offset + work->nr_pages - 1;
> +	int wrote;
> +
> +	wrote = __filemap_fdatawrite_range(work->inode->i_mapping,
> +					   start << PAGE_CACHE_SHIFT,
> +					   end   << PAGE_CACHE_SHIFT,
> +					   WB_SYNC_NONE);
> +	iput(work->inode);
> +	return wrote;
> +}

Out of curiousity, before going down the complex route did you try
just calling this directly and seeing if it solved the problem? i.e.

	igrab()
	get start/end
	unlock page
	__filemap_fdatawrite_range()
	iput()

I mean, much as I dislike the idea of writeback from the LRU, if all
we need to do is call through .writepages() to do get decent IO from
reclaim (when it occurs), then why do we need to add this async
complexity to the generic writeback code to acheive the same end?

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
