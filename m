Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f69.google.com (mail-vk0-f69.google.com [209.85.213.69])
	by kanga.kvack.org (Postfix) with ESMTP id 249A2828E5
	for <linux-mm@kvack.org>; Fri,  8 Jul 2016 05:52:06 -0400 (EDT)
Received: by mail-vk0-f69.google.com with SMTP id v6so84116457vkb.2
        for <linux-mm@kvack.org>; Fri, 08 Jul 2016 02:52:06 -0700 (PDT)
Received: from outbound-smtp02.blacknight.com (outbound-smtp02.blacknight.com. [81.17.249.8])
        by mx.google.com with ESMTPS id s83si2145054wmf.10.2016.07.08.02.52.04
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 08 Jul 2016 02:52:05 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail03.blacknight.ie [81.17.254.16])
	by outbound-smtp02.blacknight.com (Postfix) with ESMTPS id 8F5781DC084
	for <linux-mm@kvack.org>; Fri,  8 Jul 2016 09:52:04 +0000 (UTC)
Date: Fri, 8 Jul 2016 10:52:03 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 00/31] Move LRU page reclaim from zones to nodes v8
Message-ID: <20160708095203.GB11498@techsingularity.net>
References: <1467387466-10022-1-git-send-email-mgorman@techsingularity.net>
 <20160707232713.GM27480@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20160707232713.GM27480@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>

On Fri, Jul 08, 2016 at 09:27:13AM +1000, Dave Chinner wrote:
> .....
> > This series is not without its hazards. There are at least three areas
> > that I'm concerned with even though I could not reproduce any problems in
> > that area.
> > 
> > 1. Reclaim/compaction is going to be affected because the amount of reclaim is
> >    no longer targetted at a specific zone. Compaction works on a per-zone basis
> >    so there is no guarantee that reclaiming a few THP's worth page pages will
> >    have a positive impact on compaction success rates.
> > 
> > 2. The Slab/LRU reclaim ratio is affected because the frequency the shrinkers
> >    are called is now different. This may or may not be a problem but if it
> >    is, it'll be because shrinkers are not called enough and some balancing
> >    is required.
> 
> Given that XFS has a much more complex set of shrinkers and has a
> much more finely tuned balancing between LRU and shrinker reclaim,
> I'd be interested to see if you get the same results on XFS for the
> tests you ran on ext4. It might also be worth running some highly
> concurrent inode cache benchmarks (e.g. the 50-million inode, 16-way
> concurrent fsmark tests) to see what impact heavy slab cache
> pressure has on shrinker behaviour and system balance...
> 

I had tested XFS with earlier releases and noticed no major problems
so later releases tested only one filesystem.  Given the changes since,
a retest is desirable. I've posted the current version of the series but
I'll queue the tests to run over the weekend. They are quite time consuming
to run unfortunately.

On the fsmark configuration, I configured the test to use 4K files
instead of 0-sized files that normally would be used to stress inode
creation/deletion. This is to have a mix of page cache and slab
allocations. Shout if this does not suit your expectations.

Finally, not all the machines I'm using can store 50 million inodes
of this size. The benchmark has been configured to use as many inodes
as it estimates will fit in the disk. In all cases, it'll exert memory
pressure. Unfortunately, the storage is simple so there is no guarantee
it'll find all problems but that's standard unfortunately.

Thanks.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
