Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id EE6D26B008C
	for <linux-mm@kvack.org>; Wed, 15 Dec 2010 10:09:21 -0500 (EST)
Date: Wed, 15 Dec 2010 23:07:14 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [PATCH 29/35] nfs: in-commit pages accounting and wait queue
Message-ID: <20101215150714.GA22454@localhost>
References: <20101213144646.341970461@intel.com>
 <20101213150329.831955132@intel.com>
 <1292274951.8795.28.camel@heimdal.trondhjem.org>
 <20101214154026.GA8959@localhost>
 <1292342245.2976.13.camel@heimdal.trondhjem.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1292342245.2976.13.camel@heimdal.trondhjem.org>
Sender: owner-linux-mm@kvack.org
To: Trond Myklebust <Trond.Myklebust@netapp.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Jan Kara <jack@suse.cz>, Christoph Hellwig <hch@lst.de>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>, Chris Mason <chris.mason@oracle.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Greg Thelen <gthelen@google.com>, Minchan Kim <minchan.kim@gmail.com>, linux-mm <linux-mm@kvack.org>, "linux-fsdevel@vger.kernel.org" <linux-fsdevel@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Tue, Dec 14, 2010 at 11:57:25PM +0800, Trond Myklebust wrote:
> On Tue, 2010-12-14 at 23:40 +0800, Wu Fengguang wrote:
> > On Tue, Dec 14, 2010 at 05:15:51AM +0800, Trond Myklebust wrote:
> > > On Mon, 2010-12-13 at 22:47 +0800, Wu Fengguang wrote:
> > > > plain text document attachment (writeback-nfs-in-commit.patch)
> > > > When doing 10+ concurrent dd's, I observed very bumpy commits submission
> > > > (partly because the dd's are started at the same time, and hence reached
> > > > 4MB to-commit pages at the same time). Basically we rely on the server
> > > > to complete and return write/commit requests, and want both to progress
> > > > smoothly and not consume too many pages. The write request wait queue is
> > > > not enough as it's mainly network bounded. So add another commit request
> > > > wait queue. Only async writes need to sleep on this queue.
> > > > 
> > > 
> > > I'm not understanding the above reasoning. Why should we serialise
> > > commits at the per-filesystem level (and only for non-blocking flushes
> > > at that)?
> > 
> > I did the commit wait queue after seeing this graph, where there is
> > very bursty pattern of commit submission and hence completion:
> > 
> > http://www.kernel.org/pub/linux/kernel/people/wfg/writeback/tests/3G/nfs-100dd-1M-8p-2953M-2.6.37-rc3+-2010-12-03-01/nfs-commit-1000.png
> > 
> > leading to big fluctuations, eg. the almost straight up/straight down
> > lines below
> > http://www.kernel.org/pub/linux/kernel/people/wfg/writeback/tests/3G/nfs-100dd-1M-8p-2953M-2.6.37-rc3+-2010-12-03-01/vmstat-dirty-300.png
> > http://www.kernel.org/pub/linux/kernel/people/wfg/writeback/tests/3G/nfs-100dd-1M-8p-2953M-2.6.37-rc3+-2010-12-03-01/dirty-pages.png
> > http://www.kernel.org/pub/linux/kernel/people/wfg/writeback/tests/3G/nfs-100dd-1M-8p-2953M-2.6.37-rc3+-2010-12-03-01/dirty-pages-200.png
> > 
> > A commit wait queue will help wipe out the "peaks". The "fixed" graph
> > is
> > http://www.kernel.org/pub/linux/kernel/people/wfg/writeback/tests/3G/nfs-100dd-1M-8p-2952M-2.6.37-rc5+-2010-12-09-03-23/vmstat-dirty-300.png
> > http://www.kernel.org/pub/linux/kernel/people/wfg/writeback/tests/3G/nfs-100dd-1M-8p-2952M-2.6.37-rc5+-2010-12-09-03-23/dirty-pages.png
> > 
> > Blocking flushes don't need to wait on this queue because they already
> > throttle themselves by waiting on the inode commit lock before/after
> > the commit.  They actually should not wait on this queue, to prevent
> > sync requests being unnecessarily blocked by async ones.
> 
> OK, but isn't it better then to just abort the commit, and have the
> relevant async process retry it later?

I'll drop this patch. I vaguely remember that bursty commit graph
mentioned below

> > I did the commit wait queue after seeing this graph, where there is
> > very bursty pattern of commit submission and hence completion:
> > 
> > http://www.kernel.org/pub/linux/kernel/people/wfg/writeback/tests/3G/nfs-100dd-1M-8p-2953M-2.6.37-rc3+-2010-12-03-01/nfs-commit-1000.png

is caused by this condition in nfs_should_commit():

        /* big enough */
        if (to_commit >= MIN_WRITEBACK_PAGES)
                return true;

It's because the 100 dd's accumulated 4MB dirty pages at roughly the
same time. Then I added the in_commit accounting (for the below test)
and wait queue. It seems that the below condition is good enough to
smooth out the commit distribution.

        /* active commits drop low: kick more IO for the server disk */
        if (to_commit > in_commit / 2)
                return true;

And I'm going further remove the above two conditions, and do a much
more simple change:

-               if (nfsi->ncommit <= (nfsi->npages >> 1))
+               if (nfsi->ncommit <= (nfsi->npages >> 4))
                        goto out_mark_dirty;

The change to ">> 4" helps reduce the fluctuation to the acceptable
level: balance_dirty_page() is now doing soft dirty throttling in a
small range of bdi_dirty_limit/8. The above change guarantees that
when an NFS commit completes, the bdi_dirty won't suddenly drop out
of the soft throttling region. On my mem=3GB test box and 1-dd case,
npages/16 ~= 32MB is still a large size.

Basic tests show that it achieves roughly the same effect with these
two patches

[PATCH 29/35] nfs: in-commit pages accounting and wait queue
[PATCH 30/35] nfs: heuristics to avoid commit

It would not only be simpler, but also be able to do larger commits in
the case of "fast and memory bounty server/client connected by slow
network". In this case, the above two patches will do 4MB commits,
while the simpler change can do much larger.

> This is a code path which is followed by kswapd, for instance. It seems
> dangerous to be throttling that instead of allowing it to proceed (and
> perhaps being able to free up memory on some other partition in the mean
> time).

It seems pageout() calls nfs_writepage(), the latter does unstable
write and also won't commit the page. This means pageout() cannot
guarantee free of the page at all.. so NFS dirty pages are virtually
unreclaimable..

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
