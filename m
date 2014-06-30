Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com [209.85.212.170])
	by kanga.kvack.org (Postfix) with ESMTP id 85D046B0035
	for <linux-mm@kvack.org>; Mon, 30 Jun 2014 17:51:26 -0400 (EDT)
Received: by mail-wi0-f170.google.com with SMTP id cc10so6469802wib.3
        for <linux-mm@kvack.org>; Mon, 30 Jun 2014 14:51:25 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id hj12si12245262wib.8.2014.06.30.14.51.24
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 30 Jun 2014 14:51:25 -0700 (PDT)
Date: Mon, 30 Jun 2014 22:51:21 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 4/4] mm: page_alloc: Reduce cost of the fair zone
 allocation policy
Message-ID: <20140630215121.GQ10819@suse.de>
References: <1404146883-21414-1-git-send-email-mgorman@suse.de>
 <1404146883-21414-5-git-send-email-mgorman@suse.de>
 <20140630141404.e09bdb5fa6a879d17c4556b1@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20140630141404.e09bdb5fa6a879d17c4556b1@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>, Johannes Weiner <hannes@cmpxchg.org>

On Mon, Jun 30, 2014 at 02:14:04PM -0700, Andrew Morton wrote:
> On Mon, 30 Jun 2014 17:48:03 +0100 Mel Gorman <mgorman@suse.de> wrote:
> 
> > The fair zone allocation policy round-robins allocations between zones
> > within a node to avoid age inversion problems during reclaim. If the
> > first allocation fails, the batch counts is reset and a second attempt
> > made before entering the slow path.
> > 
> > One assumption made with this scheme is that batches expire at roughly the
> > same time and the resets each time are justified. This assumption does not
> > hold when zones reach their low watermark as the batches will be consumed
> > at uneven rates.  Allocation failure due to watermark depletion result in
> > additional zonelist scans for the reset and another watermark check before
> > hitting the slowpath.
> > 
> > This patch makes a number of changes that should reduce the overall cost
> > 
> > o Abort the fair zone allocation policy once remote zones are encountered
> > o Use a simplier scan when resetting NR_ALLOC_BATCH
> > o Use a simple flag to identify depleted zones instead of accessing a
> >   potentially write-intensive cache line for counters
> > 
> > On UMA machines, the effect on overall performance is marginal. The main
> > impact is on system CPU usage which is small enough on UMA to begin with.
> > This comparison shows the system CPu usage between vanilla, the previous
> > patch and this patch.
> > 
> >           3.16.0-rc2  3.16.0-rc2  3.16.0-rc2
> >              vanilla checklow-v4 fairzone-v4
> > User          390.13      400.85      396.13
> > System        404.41      393.60      389.61
> > Elapsed      5412.45     5166.12     5163.49
> > 
> > There is a small reduction and it appears consistent.
> > 
> > On NUMA machines, the scanning overhead is higher as zones are scanned
> > that are ineligible for use by zone allocation policy. This patch fixes
> > the zone-order zonelist policy and reduces the numbers of zones scanned
> > by the allocator leading to an overall reduction of CPU usage.
> > 
> >           3.16.0-rc2  3.16.0-rc2  3.16.0-rc2
> >              vanilla checklow-v4 fairzone-v4
> > User          744.05      763.26      778.53
> > System      70148.60    49331.48    44905.73
> > Elapsed     28094.08    27476.72    27378.98
> 
> That's a large change in system time.  Does this all include kswapd
> activity?
> 

I don't have a profile to quantify that exactly. It takes 7 hours to
complete a test on that machine in this configuration and it would take
longer with profiling. I was not testing with profiling enabled as that
invalidates performance tests. I'd expect it'd take the guts of two days
to gather full profiles for it and even then it would be masked by remote
access costs and other factors. It'd be worse considering that automatic
NUMA balancing is enabled and I normally test with that turned on.

However, without the kswapd change there are a lot of retries and
reallocations for pages recently reclaimed. For the fairzone patch there
are far fewer scans of unusable zones to find the lower zones. Considering
the number of allocations required there is simply a lot of overhead that
builds up.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
