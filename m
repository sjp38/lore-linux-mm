Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 9E12D8D0080
	for <linux-mm@kvack.org>; Wed, 17 Nov 2010 03:33:09 -0500 (EST)
Date: Wed, 17 Nov 2010 16:33:01 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 01/13] writeback: IO-less balance_dirty_pages()
Message-ID: <20101117083301.GA25946@localhost>
References: <20101117035905.525232375@intel.com>
 <20101117041926.GA14209@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101117041926.GA14209@localhost>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Theodore Ts'o <tytso@mit.edu>, Chris Mason <chris.mason@oracle.com>, Dave Chinner <david@fromorbit.com>, Jan Kara <jack@suse.cz>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Jens Axboe <axboe@kernel.dk>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Christoph Hellwig <hch@lst.de>, linux-mm <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, Nov 17, 2010 at 12:19:26PM +0800, Wu Fengguang wrote:
> > BEHAVIOR CHANGE
> > ===============
> > 
> > Users will notice that the applications will get throttled once the
> > crossing the global (background + dirty)/2=15% threshold. For a single
> > "cp", it could be soft throttled at 2*bdi->write_bandwidth around 15%
> 
> s/2/8/
> 
> Sorry, the initial soft throttle bandwidth for "cp" is about 8 times
> of bdi bandwidth when reaching 15% dirty pages.

Actually it's x8 for light dirtier and x6 for heavy dirtier. There are
two control lines in the following code. The task control line is
introduced in this patch, while the bdi control line is introduced in
"[PATCH 11/13] writeback: scale down max throttle bandwidth on
concurrent dirtiers".

baseline
                bw = bdi->write_bandwidth;

bdi control line
                bw = bw * (bdi_thresh - bdi_dirty);               
                bw = bw / (bdi_thresh / BDI_SOFT_DIRTY_LIMIT + 1);
        
task control line
                bw = bw * (task_thresh - bdi_dirty);
                bw = bw / (bdi_thresh / TASK_SOFT_DIRTY_LIMIT + 1);

These figures demonstrate how they work together:

http://www.kernel.org/pub/linux/kernel/people/wfg/writeback/heavy-dirtier-control-line.svg
http://www.kernel.org/pub/linux/kernel/people/wfg/writeback/light-dirtier-control-line.svg

Thanks,
Fengguang

> > dirty pages, and be balanced at speed bdi->write_bandwidth around 17.5%
> > dirty pages. Before patch, the behavior is to just throttle it at 17.5%
> > dirty pages.
> > 
> > Since the task will be soft throttled earlier than before, it may be
> > perceived by end users as performance "slow down" if his application
> > happens to dirty more than ~15% memory.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
