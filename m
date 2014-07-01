Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f173.google.com (mail-we0-f173.google.com [74.125.82.173])
	by kanga.kvack.org (Postfix) with ESMTP id BA4616B0031
	for <linux-mm@kvack.org>; Tue,  1 Jul 2014 16:58:21 -0400 (EDT)
Received: by mail-we0-f173.google.com with SMTP id t60so10286029wes.32
        for <linux-mm@kvack.org>; Tue, 01 Jul 2014 13:58:21 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id x6si16880918wiw.78.2014.07.01.13.58.20
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 01 Jul 2014 13:58:20 -0700 (PDT)
Date: Tue, 1 Jul 2014 21:58:17 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 0/5] Improve sequential read throughput v4r8
Message-ID: <20140701205817.GY10819@suse.de>
References: <1404146883-21414-1-git-send-email-mgorman@suse.de>
 <20140701171611.GB1369@cmpxchg.org>
 <20140701183915.GW10819@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20140701183915.GW10819@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>

On Tue, Jul 01, 2014 at 07:39:15PM +0100, Mel Gorman wrote:
> The fair zone policy itself is partially working against the lowmem
> reserve idea. The point of the lowmem reserve was to preserve the lower
> zones when an upper zone can be used and the fair zone policy breaks
> that. The fair zone policy ignores that and it was never reconciled. The
> dirty page distribution does a different interleaving again and was never
> reconciled with the fair zone policy or lowmem reserves. kswapd itself was
> not using the classzone_idx it actually woken for although in this case
> it may not matter. The end result is that the model is fairly inconsistent
> which makes comparison against it a difficult exercise at best. About all
> that was left was that from a performance perspective that the fair zone
> allocation policy is not doing the right thing for streaming workloads.
> 

The inevitable feedback will be to reconcile those differences so I'm
redid the series and queued it for testing. Patch list currently looks
like

mm: pagemap: Avoid unnecessary overhead when tracepoints are deactivated
mm: Rearrange zone fields into read-only, page alloc, statistics and page reclaim lines
mm: page_alloc: Add ALLOC_DIRTY for dirty page distribution
mm: page_alloc: Only apply the fair zone allocation policy if it's eligible
mm: page_alloc: Only apply either the fair zone or dirty page distribution policy, not both
mm: page_alloc: Reduce cost of the fair zone allocation policy
mm: page_alloc: Reconcile lowmem reserves with fair zone allocation policy
mm: vmscan: Fix oddities with classzone and zone balancing
mm: vmscan: Reconcile balance gap lowmem reclaim with fair zone allocation policy
mm: vmscan: Remove classzone considerations from kswapd decisions

About 13 hours to test for ext3 on the small machine, 3 days for the larger
machine. The test could be accelerated by either reducing the iterations or
the memory size of the machine but that would distort the results too badly.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
