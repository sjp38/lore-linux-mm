Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id ECC8A6006B6
	for <linux-mm@kvack.org>; Mon, 26 Jul 2010 07:01:43 -0400 (EDT)
Date: Mon, 26 Jul 2010 12:01:25 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 5/6] writeback: try more writeback as long as something
	was written
Message-ID: <20100726110125.GN5300@csn.ul.ie>
References: <20100722050928.653312535@intel.com> <20100722061823.050523298@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20100722061823.050523298@intel.com>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Dave Chinner <david@fromorbit.com>, Christoph Hellwig <hch@infradead.org>, Chris Mason <chris.mason@oracle.com>, Jens Axboe <jens.axboe@oracle.com>, LKML <linux-kernel@vger.kernel.org>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, Jul 22, 2010 at 01:09:33PM +0800, Wu Fengguang wrote:
> writeback_inodes_wb()/__writeback_inodes_sb() are not agressive in that
> they only populate b_io when necessary at entrance time. When the queued
> set of inodes are all synced, they just return, possibly with
> wbc.nr_to_write > 0.
> 
> For kupdate and background writeback, there may be more eligible inodes
> sitting in b_dirty when the current set of b_io inodes are completed. So
> it is necessary to try another round of writeback as long as we made some
> progress in this round. When there are no more eligible inodes, no more
> inodes will be enqueued in queue_io(), hence nothing could/will be
> synced and we may safely bail.
> 
> This will livelock sync when there are heavy dirtiers. However in that case
> sync will already be livelocked w/o this patch, as the current livelock
> avoidance code is virtually a no-op (for one thing, wb_time should be
> set statically at sync start time and be used in move_expired_inodes()).
> The sync livelock problem will be addressed in other patches.
> 

There does seem to be a livelock issue. During iozone, I see messages in
the console log with this series applied that look like

[ 1687.132034] INFO: task iozone:21225 blocked for more than 120 seconds.
[ 1687.211425] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
[ 1687.305204] iozone        D ffff880001b13640     0 21225  21108 0x00000000
[ 1687.387677]  ffff880037419d48 0000000000000082 0000000000000348 0000000000013640
[ 1687.476594]  ffff880037419fd8 ffff880037419fd8 ffff880065892da0 0000000000013640
[ 1687.565512]  0000000000013640 0000000000013640 ffff880065892da0 ffff88007f411510
[ 1687.654431] Call Trace:
[ 1687.683663]  [<ffffffff81002996>] ? ftrace_call+0x5/0x2b
[ 1687.747204]  [<ffffffff812d8f67>] schedule_timeout+0x2d/0x214
[ 1687.815947]  [<ffffffff81002996>] ? ftrace_call+0x5/0x2b
[ 1687.879489]  [<ffffffff812d8527>] wait_for_common+0xd2/0x14a
[ 1687.947195]  [<ffffffff8103ef1e>] ? default_wake_function+0x0/0x14
[ 1688.021132]  [<ffffffff81002996>] ? ftrace_call+0x5/0x2b
[ 1688.084680]  [<ffffffff811160f0>] ? sync_one_sb+0x0/0x22
[ 1688.148223]  [<ffffffff812d8657>] wait_for_completion+0x1d/0x1f
[ 1688.219051]  [<ffffffff811121c4>] sync_inodes_sb+0x92/0x14c
[ 1688.285710]  [<ffffffff811160f0>] ? sync_one_sb+0x0/0x22
[ 1688.349249]  [<ffffffff811160b9>] __sync_filesystem+0x4c/0x83
[ 1688.417995]  [<ffffffff81116110>] sync_one_sb+0x20/0x22
[ 1688.480505]  [<ffffffff810f6a23>] iterate_supers+0x66/0xa4
[ 1688.546124]  [<ffffffff81116157>] sys_sync+0x45/0x5c
[ 1688.605509]  [<ffffffff81002c72>] system_call_fastpath+0x16/0x1b

Similar messages do not appear without the patch. iozone does complete though
and the performance figures are not affected. Should I be worried?

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
