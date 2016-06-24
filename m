Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 05A8F6B0005
	for <linux-mm@kvack.org>; Fri, 24 Jun 2016 03:51:03 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id c82so10296165wme.2
        for <linux-mm@kvack.org>; Fri, 24 Jun 2016 00:51:02 -0700 (PDT)
Received: from outbound-smtp07.blacknight.com (outbound-smtp07.blacknight.com. [46.22.139.12])
        by mx.google.com with ESMTPS id y188si2603545wmg.106.2016.06.24.00.51.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 Jun 2016 00:51:01 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail05.blacknight.ie [81.17.254.26])
	by outbound-smtp07.blacknight.com (Postfix) with ESMTPS id 46FF61C11E1
	for <linux-mm@kvack.org>; Fri, 24 Jun 2016 08:51:01 +0100 (IST)
Date: Fri, 24 Jun 2016 08:50:59 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 00/27] Move LRU page reclaim from zones to nodes v7
Message-ID: <20160624075059.GC1868@techsingularity.net>
References: <1466518566-30034-1-git-send-email-mgorman@techsingularity.net>
 <3c062233-1ef7-bc85-5079-255f61f57c7d@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <3c062233-1ef7-bc85-5079-255f61f57c7d@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Balbir Singh <bsingharora@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>

On Fri, Jun 24, 2016 at 04:35:45PM +1000, Balbir Singh wrote:
> > 1. The residency of a page partially depends on what zone the page was
> >    allocated from.  This is partially combatted by the fair zone allocation
> >    policy but that is a partial solution that introduces overhead in the
> >    page allocator paths.
> > 
> > 2. Currently, reclaim on node 0 behaves slightly different to node 1. For
> >    example, direct reclaim scans in zonelist order and reclaims even if
> >    the zone is over the high watermark regardless of the age of pages
> >    in that LRU. Kswapd on the other hand starts reclaim on the highest
> >    unbalanced zone. A difference in distribution of file/anon pages due
> >    to when they were allocated results can result in a difference in 
> >    again. While the fair zone allocation policy mitigates some of the
> >    problems here, the page reclaim results on a multi-zone node will
> >    always be different to a single-zone node.
> >    it was scheduled on as a result.
> > 
> > 3. kswapd and the page allocator scan zones in the opposite order to
> >    avoid interfering with each other but it's sensitive to timing.  This
> >    mitigates the page allocator using pages that were allocated very recently
> >    in the ideal case but it's sensitive to timing. When kswapd is allocating
> >    from lower zones then it's great but during the rebalancing of the highest
> >    zone, the page allocator and kswapd interfere with each other. It's worse
> >    if the highest zone is small and difficult to balance.
> > 
> > 4. slab shrinkers are node-based which makes it harder to identify the exact
> >    relationship between slab reclaim and LRU reclaim.
> > 
> 
> Sorry, I am late in reading the thread and the patches, but I am trying to understand
> the key benefits?

The key benefits were outlined at the beginning of the changelog. The
one that is missing is the large overhead from the fair zone allocation
policy which can be removed safely by the feature. The benefit to page
allocator micro-benchmarks is outlined in the series introduction.

> I know that
> zones have grown to be overloaded to mean many things now. What is the contention impact
> of moving the LRU from zone to nodes?

Expected to be minimal. On NUMA machines, most nodes have only one zone.
On machines with multiple zones, the lock per zone is not that fine-grained
given the size of the zones on large memory configurations.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
