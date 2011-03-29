Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 81D7B8D0040
	for <linux-mm@kvack.org>; Tue, 29 Mar 2011 03:31:11 -0400 (EDT)
Date: Tue, 29 Mar 2011 15:31:03 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH RFC 0/5] IO-less balance_dirty_pages() v2 (simple
 approach)
Message-ID: <20110329073102.GA19640@localhost>
References: <1299623475-5512-1-git-send-email-jack@suse.cz>
 <20110318143001.GA6173@localhost>
 <20110322214314.GC19716@quack.suse.cz>
 <20110325134411.GA8645@localhost>
 <20110325230544.GD26932@quack.suse.cz>
 <20110328024445.GA11816@localhost>
 <20110329021458.GF3008@dastard>
 <20110329024120.GA9416@localhost>
 <20110329055947.GG3008@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110329055947.GG3008@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Jan Kara <jack@suse.cz>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Andrew Morton <akpm@linux-foundation.org>, Theodore Ts'o <tytso@mit.edu>, Chris Mason <chris.mason@oracle.com>, Andreas Dilger <adilger@dilger.ca>

On Tue, Mar 29, 2011 at 01:59:47PM +0800, Dave Chinner wrote:
> On Tue, Mar 29, 2011 at 10:41:20AM +0800, Wu Fengguang wrote:
> > On Tue, Mar 29, 2011 at 10:14:58AM +0800, Dave Chinner wrote:
> > > -printable
> > > Content-Length: 2034
> > > Lines: 51
> > > 
> > > On Mon, Mar 28, 2011 at 10:44:45AM +0800, Wu Fengguang wrote:
> > > > On Sat, Mar 26, 2011 at 07:05:44AM +0800, Jan Kara wrote:
> > > > > And actually the NFS traces you pointed to originally seem to be different
> > > > > problem, in fact not directly related to what balance_dirty_pages() does...
> > > > > And with local filesystem the results seem to be reasonable (although there
> > > > > are some longer sleeps in your JBOD measurements I don't understand yet).
> > > > 
> > > > Yeah the NFS case can be improved on the FS side (for now you may just
> > > > reuse my NFS patches and focus on other generic improvements).
> > > > 
> > > > The JBOD issue is also beyond my understanding.
> > > > 
> > > > Note that XFS will also see one big IO completion per 0.5-1 seconds,
> > > > when we are to increase the write chunk size from the current 4MB to
> > > > near the bdi's write bandwidth. As illustrated by this graph:
> > > > 
> > > > http://www.kernel.org/pub/linux/kernel/people/wfg/writeback/dirty-throttling-v6/4G/xfs-1dd-1M-8p-3927M-20%25-2.6.38-rc6-dt6+-2011-02-27-22-58/global_dirtied_written-500.png
> > > 
> > > Which is _bad_.
> > > 
> > > Increasing the writeback chunk size simply causes dirty queue
> > > starvation issues when there are lots of dirty files and lots more
> > > memory than there is writeback bandwidth. Think of a machine with
> > > 1TB of RAM (that's a 200GB dirty limit) and 1GB/s of disk
> > > throughput. Thats 3 minutes worth of writeback and increasing the
> > > chunk size to ~1s worth of throughput means that the 200th dirty
> > > file won't get serviced for 3 minutes....
> > > 
> > > We used to have behaviour similar to this this (prior to 2.6.16, IIRC),
> > > and it caused all sorts of problems where people were losing 10-15
> > > minute old data when the system crashed because writeback didn't
> > > process the dirty inode list fast enough in the presence of lots of
> > > large files....
> >  
> > Yes it is a problem, and can be best solved by automatically lowering
> > bdi dirty limit to (bdi->write_bandwidth * dirty_expire_interval/100).
> > Then we reliably control the lost data size to < 30s by default.
> 
> Perhaps, though I see problems with that also. e.g. write bandwidth
> is 100MB/s (dirty limit ~= 3GB), then someone runs a find on the
> same disk and write bandwidth drops to 10MB/s (dirty limit changes
> to ~300MB). Then we are 10x over the new dirty limit and the
> writing application will be completely throttled for the next 270s
> until the dirty pages drop below the new dirty limit or the find
> stops.
> 
> IOWs, it changing IO workloads will cause interesting corner cases
> to be discovered and hence further complexity to handle effectively.
> And trying to diagnose problems because of such changes in IO load
> will be nigh on impossible - how would you gather sufficient
> information to determine that application A stalled for a minute
> because application B read a bunch of stuff from disk at the wrong
> time? Then how would you prove that you'd fixed the problem without
> introducing some other regression triggered by different workload
> changes?

Good point. The v6 dirty throttle patchset has taken this into
account, by separating the concept of dirty goal and hard dirty
limit. Sorry I should have use bdi dirty goal in the previous email.

When for whatever reason the bdi dirty goal becomes a lot more smaller
than bdi dirty pages, the bdi dirtiers will be throttled at typically
lower than balanced bandwidth, so that the bdi dirty pages can smoothly
drop to the dirty goal.

In the below graph, the bdi dirty pages start from much higher from
bdi dirty goal because we start dd's on a USB stick and a hard disk
at the same time, and the USB stick manage to accumulate lots of dirty
pages before the dirty throttling logic starts to work. So you can see
two dropping red lines in the (40s, 120s) time range. The green
"position bandwidth" line shows that in that range, the tasks are 
throttled a most 1/8 lower than the balanced throttle bandwidth and
restored to normal after 140s.

http://www.kernel.org/pub/linux/kernel/people/wfg/writeback/dirty-throttling-v6/1UKEY+1HDD-3G/xfs-1dd-1M-8p-2945M-20%25-2.6.38-rc5-dt6+-2011-02-22-09-21/balance_dirty_pages-pages.png

This is the corresponding pause times. They are perfectly under
control (less than the configurable 200ms max pause time).

http://www.kernel.org/pub/linux/kernel/people/wfg/writeback/dirty-throttling-v6/1UKEY+1HDD-3G/xfs-1dd-1M-8p-2945M-20%25-2.6.38-rc5-dt6+-2011-02-22-09-21/balance_dirty_pages-pause.png

Actually the patchset does not set hard limit for bdi dirty pages at
all. It only maintains one hard limit for the global dirty pages.
That global hard limit is introduced exactly to handle your mentioned
case.

https://patchwork.kernel.org/patch/605201/

+ * The global dirty threshold is normally equal to global dirty limit, except
+ * when the system suddenly allocates a lot of anonymous memory and knocks down
+ * the global dirty threshold quickly, in which case the global dirty limit
+ * will follow down slowly to prevent livelocking all dirtier tasks.

Here "global dirty threshold" is the one returned by current
global_dirty_limits(), the "global dirty limit" is
default_backing_dev_info.dirty_threshold in the above patch.
Sorry the names are a bit confusing..

> > > A small writeback chunk size has no adverse impact on XFS as long as
> > > the elevator does it's job of merging IOs (which in 99.9% of cases
> > > it does) so I'm wondering what the reason for making this change
> > > is.
> > 
> > It's explained in this changelog (is the XFS paragraph still valid?)
> > 
> >         https://patchwork.kernel.org/patch/605151/
> 
> You mean this paragraph?
> 
> "According to Christoph, the current writeback size is way too
> small, and XFS had a hack that bumped out nr_to_write to four times
> the value sent by the VM to be able to saturate medium-sized RAID
> arrays.  This value was also problematic for ext4 as well, as it
> caused large files to be come interleaved on disk by in 8 megabyte
> chunks (we bumped up the nr_to_write by a factor of two)."

Yes.
 
> We _used_ to have such a hack. It was there from 2.6.30 through to
> 2.6.35 - from when we realised writeback had bitrotted into badness
> to when we fixed the last set of bugs that the nr_to_write windup
> was papering over. between 2.6.30 and 2.6.35 we changed to dedicated
> flusher threads, got rid of congestion backoff, fixed up a bunch
> of queueing issues and finally stopped nr_to_write from going and
> staying negative and getting stuck on single inodes until they had
> no more dirty pages left. That was when this was committed:
> 
> commit 254c8c2dbf0e06a560a5814eb90cb628adb2de66
> Author: Dave Chinner <dchinner@redhat.com>
> Date:   Wed Jun 9 10:37:19 2010 +1000
> 
>     xfs: remove nr_to_write writeback windup.
>     
>     Now that the background flush code has been fixed, we shouldn't need to
>     silently multiply the wbc->nr_to_write to get good writeback. Remove
>     that code.
>     
>     Signed-off-by: Dave Chinner <dchinner@redhat.com>
>     Reviewed-by: Christoph Hellwig <hch@lst.de>
>     Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
> 
> And writeback throughput is now as good as it ever was....

Glad to know about the improvements :)
 
> > The larger write chunk size generally helps ext4 and RAID setups.
> 
> Is this still true with ext4's new submit_bio()-based writeback IO
> submission path that was copied from the XFS? It's a lot more
> efficient so should be much better on RAID setups.

I believe >4MB write chunk size will still help.. Although 
I have no real data to back it up for now.

On the other hand, are there chances for XFS to be hurt by the
larger write chunk size?

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
