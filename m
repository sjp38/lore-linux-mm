Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f199.google.com (mail-ua0-f199.google.com [209.85.217.199])
	by kanga.kvack.org (Postfix) with ESMTP id EFC7B6B0253
	for <linux-mm@kvack.org>; Sun, 14 Aug 2016 06:50:51 -0400 (EDT)
Received: by mail-ua0-f199.google.com with SMTP id m60so68727700uam.3
        for <linux-mm@kvack.org>; Sun, 14 Aug 2016 03:50:51 -0700 (PDT)
Received: from mail-wm0-f53.google.com (mail-wm0-f53.google.com. [74.125.82.53])
        by mx.google.com with ESMTPS id w4si14924715wjp.216.2016.08.14.03.50.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 14 Aug 2016 03:50:50 -0700 (PDT)
Received: by mail-wm0-f53.google.com with SMTP id q128so47622886wma.1
        for <linux-mm@kvack.org>; Sun, 14 Aug 2016 03:50:50 -0700 (PDT)
Date: Sun, 14 Aug 2016 12:50:49 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: 4.7.0, cp -al causes OOM
Message-ID: <20160814105048.GD9248@dhcp22.suse.cz>
References: <201608120901.41463.a.miskiewicz@gmail.com>
 <20160812074340.GC3639@dhcp22.suse.cz>
 <20160812074455.GD3639@dhcp22.suse.cz>
 <20160813014259.GB16044@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160813014259.GB16044@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: arekm@maven.pl, linux-ext4@vger.kernel.org, linux-mm@kvack.org

On Sat 13-08-16 11:42:59, Dave Chinner wrote:
> On Fri, Aug 12, 2016 at 09:44:55AM +0200, Michal Hocko wrote:
> > > [...]
> > > 
> > > > [114824.060378] Mem-Info:
> > > > [114824.060403] active_anon:170168 inactive_anon:170168 isolated_anon:0
> > > >                  active_file:192892 inactive_file:133384 isolated_file:0
> > > 
> > > LRU 32%
> > > 
> > > >                  unevictable:0 dirty:37109 writeback:1 unstable:0
> > > >                  slab_reclaimable:1176088 slab_unreclaimable:109598
> > > 
> > > slab 61%
> > > 
> > > [...]
> > > 
> > > That being said it is really unusual to see such a large kernel memory
> > > foot print. The slab memory consumption grows but it doesn't seem to be
> > > a memory leak at first glance.
> 
> >From discussions on #xfs, it's the ext4 inode slab that is consuming
> most of this memory. Which, of course, is expected when running
> a workload that is creating millions of lots of hardlinks.
> 
> AFAICT, the difference between XFS and ext4 in this case is that XFS
> throttles direct reclaim to the synchronous inode reclaim rate in
> its custom inode cache shrinker. This is necessary because when we
> are dirtying large numbers of inodes, memory reclaim encounters
> those dirty inodes and can't reclaim them immediately. i.e. it takes
> IO to reclaim them, just like it does for dirty pages.

OK, I see. Thanks for the clarification. This also sounds like a reason
why the compaction fails for this setup. The available reclaimable LRU
pages are probably not sufficient to form order-2 pages. But that would
require more debugging data.

> However, we throttle the rate at which we dirty pages to prevent
> filling memory with unreclaimable dirty pages as that causes
> spurious OOM situations to occur. The same spurious OOM situations
> occur when memory is full of dirty inodes, and so allocation rate
> throttling is needed for large scale inode cache intersive workloads
> like this as well....

Is there any generic way to do this throttling or every fs has to
implement its own way?

Thanks!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
