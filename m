Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 71E7D8D0040
	for <linux-mm@kvack.org>; Tue, 29 Mar 2011 03:52:28 -0400 (EDT)
Date: Tue, 29 Mar 2011 15:52:23 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH RFC 0/5] IO-less balance_dirty_pages() v2 (simple
 approach)
Message-ID: <20110329075223.GA23537@localhost>
References: <1299623475-5512-1-git-send-email-jack@suse.cz>
 <20110318143001.GA6173@localhost>
 <20110322214314.GC19716@quack.suse.cz>
 <20110325134411.GA8645@localhost>
 <20110325230544.GD26932@quack.suse.cz>
 <20110328024445.GA11816@localhost>
 <20110329021458.GF3008@dastard>
 <20110329024120.GA9416@localhost>
 <20110329055947.GG3008@dastard>
 <20110329073102.GA19640@localhost>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110329073102.GA19640@localhost>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Jan Kara <jack@suse.cz>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrew Morton <akpm@linux-foundation.org>, Theodore Ts'o <tytso@mit.edu>, Chris Mason <chris.mason@oracle.com>, Andreas Dilger <adilger@dilger.ca>

On Tue, Mar 29, 2011 at 03:31:02PM +0800, Wu Fengguang wrote:
> On Tue, Mar 29, 2011 at 01:59:47PM +0800, Dave Chinner wrote:
> > On Tue, Mar 29, 2011 at 10:41:20AM +0800, Wu Fengguang wrote:
> > > On Tue, Mar 29, 2011 at 10:14:58AM +0800, Dave Chinner wrote:
> > > > -printable
> > > > Content-Length: 2034
> > > > Lines: 51
> > > > 
> > > > On Mon, Mar 28, 2011 at 10:44:45AM +0800, Wu Fengguang wrote:
> > > > > On Sat, Mar 26, 2011 at 07:05:44AM +0800, Jan Kara wrote:
> > > > > > And actually the NFS traces you pointed to originally seem to be different
> > > > > > problem, in fact not directly related to what balance_dirty_pages() does...
> > > > > > And with local filesystem the results seem to be reasonable (although there
> > > > > > are some longer sleeps in your JBOD measurements I don't understand yet).
> > > > > 
> > > > > Yeah the NFS case can be improved on the FS side (for now you may just
> > > > > reuse my NFS patches and focus on other generic improvements).
> > > > > 
> > > > > The JBOD issue is also beyond my understanding.
> > > > > 
> > > > > Note that XFS will also see one big IO completion per 0.5-1 seconds,
> > > > > when we are to increase the write chunk size from the current 4MB to
> > > > > near the bdi's write bandwidth. As illustrated by this graph:
> > > > > 
> > > > > http://www.kernel.org/pub/linux/kernel/people/wfg/writeback/dirty-throttling-v6/4G/xfs-1dd-1M-8p-3927M-20%25-2.6.38-rc6-dt6+-2011-02-27-22-58/global_dirtied_written-500.png
> > > > 
> > > > Which is _bad_.
> > > > 
> > > > Increasing the writeback chunk size simply causes dirty queue
> > > > starvation issues when there are lots of dirty files and lots more
> > > > memory than there is writeback bandwidth. Think of a machine with
> > > > 1TB of RAM (that's a 200GB dirty limit) and 1GB/s of disk
> > > > throughput. Thats 3 minutes worth of writeback and increasing the
> > > > chunk size to ~1s worth of throughput means that the 200th dirty
> > > > file won't get serviced for 3 minutes....
> > > > 
> > > > We used to have behaviour similar to this this (prior to 2.6.16, IIRC),
> > > > and it caused all sorts of problems where people were losing 10-15
> > > > minute old data when the system crashed because writeback didn't
> > > > process the dirty inode list fast enough in the presence of lots of
> > > > large files....
> > >  
> > > Yes it is a problem, and can be best solved by automatically lowering
> > > bdi dirty limit to (bdi->write_bandwidth * dirty_expire_interval/100).
> > > Then we reliably control the lost data size to < 30s by default.
> > 
> > Perhaps, though I see problems with that also. e.g. write bandwidth
> > is 100MB/s (dirty limit ~= 3GB), then someone runs a find on the
> > same disk and write bandwidth drops to 10MB/s (dirty limit changes
> > to ~300MB). Then we are 10x over the new dirty limit and the
> > writing application will be completely throttled for the next 270s
> > until the dirty pages drop below the new dirty limit or the find
> > stops.
> > 
> > IOWs, it changing IO workloads will cause interesting corner cases
> > to be discovered and hence further complexity to handle effectively.
> > And trying to diagnose problems because of such changes in IO load
> > will be nigh on impossible - how would you gather sufficient
> > information to determine that application A stalled for a minute
> > because application B read a bunch of stuff from disk at the wrong
> > time? Then how would you prove that you'd fixed the problem without
> > introducing some other regression triggered by different workload
> > changes?
> 
> Good point. The v6 dirty throttle patchset has taken this into
> account, by separating the concept of dirty goal and hard dirty
> limit. Sorry I should have use bdi dirty goal in the previous email.
> 
> When for whatever reason the bdi dirty goal becomes a lot more smaller
> than bdi dirty pages, the bdi dirtiers will be throttled at typically
> lower than balanced bandwidth, so that the bdi dirty pages can smoothly
> drop to the dirty goal.
> 
> In the below graph, the bdi dirty pages start from much higher from
> bdi dirty goal because we start dd's on a USB stick and a hard disk
> at the same time, and the USB stick manage to accumulate lots of dirty
> pages before the dirty throttling logic starts to work. So you can see
> two dropping red lines in the (40s, 120s) time range. The green
> "position bandwidth" line shows that in that range, the tasks are 
> throttled a most 1/8 lower than the balanced throttle bandwidth and
> restored to normal after 140s.
> 
> http://www.kernel.org/pub/linux/kernel/people/wfg/writeback/dirty-throttling-v6/1UKEY+1HDD-3G/xfs-1dd-1M-8p-2945M-20%25-2.6.38-rc5-dt6+-2011-02-22-09-21/balance_dirty_pages-pages.png

This is the comment that explains how the above behavior is achieved in code.

https://patchwork.kernel.org/patch/605161/

 * (4) global/bdi control lines
 *
 * dirty_throttle_bandwidth() applies 2 main and 3 regional control lines for
 * scaling up/down the base bandwidth based on the position of dirty pages.
 *
 * The two main control lines for the global/bdi control scopes do not end at
 * thresh/bdi_thresh.  They are centered at setpoint/bdi_setpoint and cover the
 * whole [0, limit].  If the control line drops below 0 before reaching @limit,
 * an auxiliary line will be setup to connect them. The below figure illustrates
 * the main bdi control line with an auxiliary line extending it to @limit.
 *
 * This allows smoothly throttling down bdi_dirty back to normal if it starts
 * high in situations like
 * - start writing to a slow SD card and a fast disk at the same time. The SD
 *   card's bdi_dirty may rush to 5 times higher than bdi_setpoint.
 * - the global/bdi dirty thresh/goal may be knocked down suddenly either on
 *   user request or on increased memory consumption.
 *
 *   o
 *     o
 *       o                                      [o] main control line
 *         o                                    [*] auxiliary control line
 *           o
 *             o
 *               o
 *                 o
 *                   o
 *                     o
 *                       o--------------------- balance point, bw scale = 1
 *                       | o
 *                       |   o
 *                       |     o
 *                       |       o
 *                       |         o
 *                       |           o
 *                       |             o------- connect point, bw scale = 1/2
 *                       |               .*
 *                       |                 .   *
 *                       |                   .      *
 *                       |                     .         *
 *                       |                       .           *
 *                       |                         .              *
 *                       |                           .                 *
 *  [--------------------*-----------------------------.--------------------*]
 *  0                 bdi_setpoint                  bdi_origin           limit

Suppose two dirty page numbers

                         A                                 B

At point B, the dirtiers will be throttled at roughly 1/4 balanced
bandwidth (dirty rate == disk write rate). So under the control of the
above control line, the bdi dirty pages will slowly decrease to A
while the task's throttle bandwidth slowly increase to the balanced
bandwidth.

Thanks,
Fengguang

> This is the corresponding pause times. They are perfectly under
> control (less than the configurable 200ms max pause time).
> 
> http://www.kernel.org/pub/linux/kernel/people/wfg/writeback/dirty-throttling-v6/1UKEY+1HDD-3G/xfs-1dd-1M-8p-2945M-20%25-2.6.38-rc5-dt6+-2011-02-22-09-21/balance_dirty_pages-pause.png
> 
> Actually the patchset does not set hard limit for bdi dirty pages at
> all. It only maintains one hard limit for the global dirty pages.
> That global hard limit is introduced exactly to handle your mentioned
> case.
> 
> https://patchwork.kernel.org/patch/605201/
> 
> + * The global dirty threshold is normally equal to global dirty limit, except
> + * when the system suddenly allocates a lot of anonymous memory and knocks down
> + * the global dirty threshold quickly, in which case the global dirty limit
> + * will follow down slowly to prevent livelocking all dirtier tasks.
> 
> Here "global dirty threshold" is the one returned by current
> global_dirty_limits(), the "global dirty limit" is
> default_backing_dev_info.dirty_threshold in the above patch.
> Sorry the names are a bit confusing..

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
