Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id B94FE6B0069
	for <linux-mm@kvack.org>; Mon, 22 Aug 2016 22:21:27 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id i144so43471196oib.0
        for <linux-mm@kvack.org>; Mon, 22 Aug 2016 19:21:27 -0700 (PDT)
Received: from ipmail04.adl6.internode.on.net (ipmail04.adl6.internode.on.net. [150.101.137.141])
        by mx.google.com with ESMTP id l63si19566238ita.38.2016.08.22.19.21.25
        for <linux-mm@kvack.org>;
        Mon, 22 Aug 2016 19:21:26 -0700 (PDT)
Date: Tue, 23 Aug 2016 12:20:56 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: 4.7.0, cp -al causes OOM
Message-ID: <20160823022056.GK22388@dastard>
References: <201608120901.41463.a.miskiewicz@gmail.com>
 <20160812074340.GC3639@dhcp22.suse.cz>
 <20160812074455.GD3639@dhcp22.suse.cz>
 <20160813014259.GB16044@dastard>
 <20160814105048.GD9248@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160814105048.GD9248@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: arekm@maven.pl, linux-ext4@vger.kernel.org, linux-mm@kvack.org

On Sun, Aug 14, 2016 at 12:50:49PM +0200, Michal Hocko wrote:
> On Sat 13-08-16 11:42:59, Dave Chinner wrote:
> > On Fri, Aug 12, 2016 at 09:44:55AM +0200, Michal Hocko wrote:
> > However, we throttle the rate at which we dirty pages to prevent
> > filling memory with unreclaimable dirty pages as that causes
> > spurious OOM situations to occur. The same spurious OOM situations
> > occur when memory is full of dirty inodes, and so allocation rate
> > throttling is needed for large scale inode cache intersive workloads
> > like this as well....
> 
> Is there any generic way to do this throttling or every fs has to
> implement its own way?

tl;dr: no obvious generic way - every filesystem has different
reclaim requirements and behaviour.

Keep in mind that the inode cache shrinker tries to avoid dirty
inodes on the LRU, so it never blocks on known dirty inodes. Hence
if the LRU is full of dirty inodes, it won't reclaim any inodes, and
it won't block waiting for inodes to come clean. This feeds back to
the shrinker infrastructure in tht total number of inodes freed by a
shrinker pass (i.e. scanned vs freed ratio).

XFS is quite different. It only marks inodes as having dirty pages,
never as being metadata dirty. We don't even implement
->write_inode, because it is never correct for the VFS to write an
XFS inode directly. Hence, for XFS, VFS reclaim only skips inodes
that are still waiting for dirty page writeback to complete. These
inodes can't be immediately reclaimed, anyway, and page reclaim
should block on them if we are hitting near-OOM conditions in the
first place.

Hence, for XFS, inodes that are just metadata dirty (as is the case
of rm -rf, or cp -al), the VFS only sees clean inodes and so
immediately evicts them. XFS inode reclaim is aware of the dirty
status of inodes marked for reclaim, and optimises for it being a
common case.

When the XFS inode shrinker is run from the superblock shrinker, it
first kicks background reclaim threads - that's where most of the
XFS inode reclaim occurs. It runs async, lockless, non-blocking, and
scans the inode cache in IO-optimal order, enabling reclaim to scan,
clean and reclaim hundreds of thousands of dirty inodes per second.

Meanwhile, after kicking background reclaim, the XFS inode shrinker
picks up a "shrinker reclaim cursor" and starts off from where that
points to. It then cleans and blocking on any dirty inodes it
encounters before reclaiming them; clean inodes are immediately
reclaimed without blocking. This is what throttles memory
reclaim - if background reclaim is keeping up, the shrinker will only
see clean inodes and so it will be fast and non-blocking. If background
reclaim is not keeping up, the shrinker will encounter dirty inodes
and hence it blocks dropping the direct reclaim rate to that at
which inodes are being cleaned. When background reclaim catches up,
the shrinker stops throttling on IO....

Further to that, direct reclaim can trigger massive shrinker
concurrency. This happens when lots of processes are all hitting the
memory allocator and we are low on memory. If we allow all of these
direct reclaimers to issue IO to clean dirty inodes, reclaim turns
into small random write IO and the reclaim rate tanks. Badly.  OOM
occurs pretty much as soon as this happens. To avoid this, we use
reclaim cursors, and have a limited number of them available.  The
shrinker first has to get a reclaim cursor (which is how it knows
where to start reclaim from), and if none are available the shrinker
will block waiting for a cursor. This forms the high level direct
reclaim concurrency control, and it allows the background reclaim
threads to have priority access to the reclaim queues. Hence even
under extreme memory pressure, we get fast, efficient dirty inode
reclaim behaviour rather than overwhelming the IO subsystem and
tanking....

I'm not sure there's anything generic you can get from this; it's
all based around avoiding using the generic VFS dirty inode tracking
to begin with...

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
