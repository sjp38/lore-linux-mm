Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7F2B26B0038
	for <linux-mm@kvack.org>; Fri, 19 Aug 2016 09:55:20 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id f14so130387125ioj.2
        for <linux-mm@kvack.org>; Fri, 19 Aug 2016 06:55:20 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 38si8227948ioi.186.2016.08.19.06.55.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 19 Aug 2016 06:55:19 -0700 (PDT)
Date: Fri, 19 Aug 2016 15:55:15 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 00/34] Move LRU page reclaim from zones to nodes v9
Message-ID: <20160819135515.hft4t5q27za6eui2@redhat.com>
References: <1467970510-21195-1-git-send-email-mgorman@techsingularity.net>
 <20160819131200.kyqmfcabttkjvhe2@redhat.com>
 <5a560eab-cdf9-1961-1216-deff50cdf494@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5a560eab-cdf9-1961-1216-deff50cdf494@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Rik van Riel <riel@surriel.com>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, LKML <linux-kernel@vger.kernel.org>

On Fri, Aug 19, 2016 at 03:23:20PM +0200, Vlastimil Babka wrote:
> What's that? Never head of this before, but sounds scary :) I thought 
> that zone_reclaim itself was rather discouraged nowadays, not a big 
> candidate for further improvement.,,

It's some fix that I tried to push upstream but wasn't merged. I kept
maintaining it because I got customers bugreport about THP causing
regressions to node_reclaim.

Hard NUMA bindings would solve that but apparently there are apps that
prefers no memory binding to allow flexible spillover, and they only
use CPU bindings only but with a strong NUMA bias provided by
node_reclaim, by shrinking the cache (and only the cache).

In any case it was a regression caused by THP because compaction
wasn't invoked. Note zone_reclaim has a synchronous more aggressive
option that blocks for write back if needed, so invoking direct
compaction there is sure ok, if it's asked on demand.

As usual it's always a tradeoff between long live and short lived
allocation so if you reserve a system for computations and you know
your allocation are very long lived it make perfect sense to be
aggressive if you tune for it.

zone_reclaim or synchronous direct compaction are obviously bad
defaults for general purpose default settings, it doesn't mean it
should be impossible to tune a system for a certain workload to run
optimal.

> Hm I'm not so sure. Are all movable allocations highmem? For example 
> Joonsoo mentions in his ZONE_CMA patchset "blockdev file cache page 
> [...] usually has __GFP_MOVABLE but not __GFP_HIGHMEM and __GFP_USER".
> Now we also have Minchan's infrastructure for arbitrary driver 
> compaction, so those will be movable, but potentially still restricted 
> to e.g. DMA32...

One option is to forbid such corner cases... and VM_WARN_ON (not a
typo :) available in my tree) if __GFP_MOVABLE is passed on lower
classzones.

The other option would be to have a per-classzone lowpfn, highpnf scan
pointers. That has some cons but hey this whole thing is a tradeoff
isn't it?

It's about the fact we're optimizing for less frequent lowmem
allocations so we can as well provide a worse compaction for lowmem
(by reducing the MOVABLE memory restricted to lower classzones like
mentioned above), but leverage the node model to have a more powerful
that crosses all zone boundaries, when the GFP_HIGHUSER is used.

I don't see why the tradeoff is valid when it comes to the LRU but not
valid when it comes to compaction and then I've to do a blind loop of
(for-each-zone-in-the-node-in-reverse { compact_zone_order(zone) })
which works worse than before and works worse than a
zone-boundary-less compaction based on the node model.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
