Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 649316006B6
	for <linux-mm@kvack.org>; Mon, 26 Jul 2010 08:39:58 -0400 (EDT)
Date: Mon, 26 Jul 2010 20:39:37 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 5/6] writeback: try more writeback as long as something
 was written
Message-ID: <20100726123937.GB11947@localhost>
References: <20100722050928.653312535@intel.com>
 <20100722061823.050523298@intel.com>
 <20100723173953.GB20540@quack.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100723173953.GB20540@quack.suse.cz>
Sender: owner-linux-mm@kvack.org
To: Jan Kara <jack@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dave Chinner <david@fromorbit.com>, Christoph Hellwig <hch@infradead.org>, Mel Gorman <mel@csn.ul.ie>, Chris Mason <chris.mason@oracle.com>, Jens Axboe <jens.axboe@oracle.com>, LKML <linux-kernel@vger.kernel.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Sat, Jul 24, 2010 at 01:39:54AM +0800, Jan Kara wrote:
> On Thu 22-07-10 13:09:33, Wu Fengguang wrote:
> > writeback_inodes_wb()/__writeback_inodes_sb() are not agressive in that
> > they only populate b_io when necessary at entrance time. When the queued
> > set of inodes are all synced, they just return, possibly with
> > wbc.nr_to_write > 0.
> > 
> > For kupdate and background writeback, there may be more eligible inodes
> > sitting in b_dirty when the current set of b_io inodes are completed. So
> > it is necessary to try another round of writeback as long as we made some
> > progress in this round. When there are no more eligible inodes, no more
> > inodes will be enqueued in queue_io(), hence nothing could/will be
> > synced and we may safely bail.
> > 
> > This will livelock sync when there are heavy dirtiers. However in that case
> > sync will already be livelocked w/o this patch, as the current livelock
> > avoidance code is virtually a no-op (for one thing, wb_time should be
> > set statically at sync start time and be used in move_expired_inodes()).
> > The sync livelock problem will be addressed in other patches.
>   Hmm, any reason why you don't solve this problem by just removing the
> condition before queue_io()? It would also make the logic simpler - always

Yeah I'll remove queue_io() in the coming sync livelock patchset.
This patchset does the below. Though awkward, it avoids unnecessary
behavior changes for non-background cases.

-       if (!wbc->for_kupdate || list_empty(&wb->b_io))
+       if (!(wbc->for_kupdate || wbc->for_background) || list_empty(&wb->b_io))
                queue_io(wb, wbc);


> queue all inodes that are eligible for writeback...

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
