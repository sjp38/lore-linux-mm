Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id EBDF56B0005
	for <linux-mm@kvack.org>; Sun, 10 Jul 2016 20:48:02 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id qh10so153514362pac.2
        for <linux-mm@kvack.org>; Sun, 10 Jul 2016 17:48:02 -0700 (PDT)
Received: from ipmail06.adl6.internode.on.net (ipmail06.adl6.internode.on.net. [150.101.137.145])
        by mx.google.com with ESMTP id os6si619066pac.128.2016.07.10.17.48.00
        for <linux-mm@kvack.org>;
        Sun, 10 Jul 2016 17:48:01 -0700 (PDT)
Date: Mon, 11 Jul 2016 10:47:57 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [PATCH 00/31] Move LRU page reclaim from zones to nodes v8
Message-ID: <20160711004757.GN12670@dastard>
References: <1467387466-10022-1-git-send-email-mgorman@techsingularity.net>
 <20160707232713.GM27480@dastard>
 <20160708095203.GB11498@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160708095203.GB11498@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>

On Fri, Jul 08, 2016 at 10:52:03AM +0100, Mel Gorman wrote:
> On Fri, Jul 08, 2016 at 09:27:13AM +1000, Dave Chinner wrote:
> > .....
> > > This series is not without its hazards. There are at least three areas
> > > that I'm concerned with even though I could not reproduce any problems in
> > > that area.
> > > 
> > > 1. Reclaim/compaction is going to be affected because the amount of reclaim is
> > >    no longer targetted at a specific zone. Compaction works on a per-zone basis
> > >    so there is no guarantee that reclaiming a few THP's worth page pages will
> > >    have a positive impact on compaction success rates.
> > > 
> > > 2. The Slab/LRU reclaim ratio is affected because the frequency the shrinkers
> > >    are called is now different. This may or may not be a problem but if it
> > >    is, it'll be because shrinkers are not called enough and some balancing
> > >    is required.
> > 
> > Given that XFS has a much more complex set of shrinkers and has a
> > much more finely tuned balancing between LRU and shrinker reclaim,
> > I'd be interested to see if you get the same results on XFS for the
> > tests you ran on ext4. It might also be worth running some highly
> > concurrent inode cache benchmarks (e.g. the 50-million inode, 16-way
> > concurrent fsmark tests) to see what impact heavy slab cache
> > pressure has on shrinker behaviour and system balance...
> > 
> 
> I had tested XFS with earlier releases and noticed no major problems
> so later releases tested only one filesystem.  Given the changes since,
> a retest is desirable. I've posted the current version of the series but
> I'll queue the tests to run over the weekend. They are quite time consuming
> to run unfortunately.

Understood. I'm not following the patchset all that closely, so I
didn' know you'd already tested XFS.

> On the fsmark configuration, I configured the test to use 4K files
> instead of 0-sized files that normally would be used to stress inode
> creation/deletion. This is to have a mix of page cache and slab
> allocations. Shout if this does not suit your expectations.

Sounds fine. I usually limit that test to 10 million inodes - that's
my "10-4" test.

> Finally, not all the machines I'm using can store 50 million inodes
> of this size. The benchmark has been configured to use as many inodes
> as it estimates will fit in the disk. In all cases, it'll exert memory
> pressure. Unfortunately, the storage is simple so there is no guarantee
> it'll find all problems but that's standard unfortunately.

Yup. But it's really the system balance that matters, and if the
balance is maintained then XFS will optimise the IO patterns to get
decent throughput regardless of the storage (i.e. the 10-4 test
should still run at tens of MB/s on a single spinning disk).

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
