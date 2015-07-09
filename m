Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com [209.85.212.182])
	by kanga.kvack.org (Postfix) with ESMTP id 884576B0038
	for <linux-mm@kvack.org>; Thu,  9 Jul 2015 04:14:30 -0400 (EDT)
Received: by wibdq8 with SMTP id dq8so234428337wib.1
        for <linux-mm@kvack.org>; Thu, 09 Jul 2015 01:14:30 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id ce9si8227518wib.4.2015.07.09.01.14.28
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 09 Jul 2015 01:14:29 -0700 (PDT)
Date: Thu, 9 Jul 2015 09:14:25 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 4/4] mm: Increase SWAP_CLUSTER_MAX to batch TLB flushes
Message-ID: <20150709081425.GU6812@suse.de>
References: <1436189996-7220-1-git-send-email-mgorman@suse.de>
 <1436189996-7220-5-git-send-email-mgorman@suse.de>
 <20150707162526.c8a5e49db01a72a6dcdcf84f@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20150707162526.c8a5e49db01a72a6dcdcf84f@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Dave Hansen <dave.hansen@intel.com>, Ingo Molnar <mingo@kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, Jul 07, 2015 at 04:25:26PM -0700, Andrew Morton wrote:
> On Mon,  6 Jul 2015 14:39:56 +0100 Mel Gorman <mgorman@suse.de> wrote:
> 
> > Pages that are unmapped for reclaim must be flushed before being freed to
> > avoid corruption due to a page being freed and reallocated while a stale
> > TLB entry exists. When reclaiming mapped pages, the requires one IPI per
> > SWAP_CLUSTER_MAX. This patch increases SWAP_CLUSTER_MAX to 256 so more
> > pages can be flushed with a single IPI. This number was selected because
> > it reduced IPIs for TLB shootdowns by 40% on a workload that is dominated
> > by mapped pages.
> > 
> > Note that it is expected that doubling SWAP_CLUSTER_MAX would not always
> > halve the IPIs as it is workload dependent. Reclaim efficiency was not 100%
> > on this workload which was picked for being IPI-intensive and was closer to
> > 35%. More importantly, reclaim does not always isolate in SWAP_CLUSTER_MAX
> > pages. The LRU lists for a zone may be small, the priority can be low
> > and even when reclaiming a lot of pages, the last isolation may not be
> > exactly SWAP_CLUSTER_MAX.
> > 
> > There are a few potential issues with increasing SWAP_CLUSTER_MAX.
> > 
> > 1. LRU lock hold times increase slightly because more pages are being
> >    isolated.
> > 2. There are slight timing changes due to more pages having to be
> >    processed before they are freed. There is a slight risk that more
> >    pages than are necessary get reclaimed.
> > 3. There is a risk that too_many_isolated checks will be easier to
> >    trigger resulting in a HZ/10 stall.
> > 4. The rotation rate of active->inactive is slightly faster but there
> >    should be fewer rotations before the lists get balanced so it
> >    shouldn't matter.
> > 5. More pages are reclaimed in a single pass if zone_reclaim_mode is
> >    active but that thing sucks hard when it's enabled no matter what
> > 6. More pages are isolated for compaction so page hold times there
> >    are longer while they are being copied
> > 
> > It's unlikely any of these will be problems but worth keeping in mind if
> > there are any reclaim-related bug reports in the near future.
> 
> Yes, this may well cause small&subtle changes which will take some time
> to be noticed.
> 
> What is the overall effect on the performance improvement if this patch
> is omitted?
> 

For the workload that maps a lot of memory and is reclaim-intensive, the
headline performance difference is marginal, in the noise and inconclusive
as to whether it's a win -- at least on the workloads and machines I
tried. This is a representative example;

vmscale
                                                           4.2.0-rc1                          4.2.0-rc1
                                                    batchdirty-v7r17                  swapcluster-v7r17
Ops lru-file-mmap-read-elapsed                       20.47 (  0.00%)                    20.36 (  0.54%)
Ops lru-file-mmap-read-time_range                     0.59 (  0.00%)                     0.72 (-22.03%)
Ops lru-file-mmap-read-time_stddv                     0.19 (  0.00%)                     0.22 (-16.26%)

           4.2.0-rc1   4.2.0-rc1
        batchdirty-v7r17swapcluster-v7r17
User           58.20       57.13
System         76.97       78.09
Elapsed        22.50       22.45

There is a slight gain in elapsed time but well within standard deviation
and an increase in system CPUI usage. The number of IPIs sent is halved but
other factors dominate such as LRU processing, rmap walks, page reference
counting, IO etc.

A workload that force fragments memory and then attempts to allocate THP
reported no significant difference as a result of this patch.

Other reclaim workloads were inconclusive on whether it was a gain or a
loss. lmbench for mappings of different sizes showed little difference
but it was nice to note that reclaim activity is approximately the same.

The "stutter" workload that measures the latency of mmap in the presense
of intensive reclaim was odd for two reasons. This workload used to be a
reliable indicator if a desktop interactivity would stall during heavy
IO. First, it showed that mapping latency was higher -- 63ns stall on
average with patch applied vs 30ns without patch.  Second, it showed
that compaction activity was high with many more migration attempts and
failures. It follows that COMPACT_CLUSTER_MAX should have been divorced
from SWAP_CLUSTER_MAX and separately considered.

A workload that runs a in-memory database while doing a lot of IO in the
background showed no difference.

Overall, I would say that none of these workloads justify the patch on
its own. Reducing IPIs further is nice but we got the bulk of the
benefit from the two batching patches and after that other factors
dominate. Based on the results I have, I'd be ok with the patch being
dropped. It can be reconsidered for evaluation if someone complains
about excessive IPIs again on reclaim intensive workloads.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
