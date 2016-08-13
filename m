Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3AB256B0253
	for <linux-mm@kvack.org>; Fri, 12 Aug 2016 21:43:03 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id w128so6504088pfd.3
        for <linux-mm@kvack.org>; Fri, 12 Aug 2016 18:43:03 -0700 (PDT)
Received: from ipmail07.adl2.internode.on.net (ipmail07.adl2.internode.on.net. [150.101.137.131])
        by mx.google.com with ESMTP id qg8si11777110pac.135.2016.08.12.18.43.01
        for <linux-mm@kvack.org>;
        Fri, 12 Aug 2016 18:43:02 -0700 (PDT)
Date: Sat, 13 Aug 2016 11:42:59 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: 4.7.0, cp -al causes OOM
Message-ID: <20160813014259.GB16044@dastard>
References: <201608120901.41463.a.miskiewicz@gmail.com>
 <20160812074340.GC3639@dhcp22.suse.cz>
 <20160812074455.GD3639@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160812074455.GD3639@dhcp22.suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: arekm@maven.pl, linux-ext4@vger.kernel.org, linux-mm@kvack.org

On Fri, Aug 12, 2016 at 09:44:55AM +0200, Michal Hocko wrote:
> > [...]
> > 
> > > [114824.060378] Mem-Info:
> > > [114824.060403] active_anon:170168 inactive_anon:170168 isolated_anon:0
> > >                  active_file:192892 inactive_file:133384 isolated_file:0
> > 
> > LRU 32%
> > 
> > >                  unevictable:0 dirty:37109 writeback:1 unstable:0
> > >                  slab_reclaimable:1176088 slab_unreclaimable:109598
> > 
> > slab 61%
> > 
> > [...]
> > 
> > That being said it is really unusual to see such a large kernel memory
> > foot print. The slab memory consumption grows but it doesn't seem to be
> > a memory leak at first glance.

>From discussions on #xfs, it's the ext4 inode slab that is consuming
most of this memory. Which, of course, is expected when running
a workload that is creating millions of lots of hardlinks.

AFAICT, the difference between XFS and ext4 in this case is that XFS
throttles direct reclaim to the synchronous inode reclaim rate in
its custom inode cache shrinker. This is necessary because when we
are dirtying large numbers of inodes, memory reclaim encounters
those dirty inodes and can't reclaim them immediately. i.e. it takes
IO to reclaim them, just like it does for dirty pages.

However, we throttle the rate at which we dirty pages to prevent
filling memory with unreclaimable dirty pages as that causes
spurious OOM situations to occur. The same spurious OOM situations
occur when memory is full of dirty inodes, and so allocation rate
throttling is needed for large scale inode cache intersive workloads
like this as well....

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
