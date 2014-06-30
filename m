Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id F1EC86B0037
	for <linux-mm@kvack.org>; Mon, 30 Jun 2014 17:14:06 -0400 (EDT)
Received: by mail-pa0-f46.google.com with SMTP id eu11so9270875pac.19
        for <linux-mm@kvack.org>; Mon, 30 Jun 2014 14:14:06 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTP id ih3si24528066pbc.92.2014.06.30.14.14.05
        for <linux-mm@kvack.org>;
        Mon, 30 Jun 2014 14:14:06 -0700 (PDT)
Date: Mon, 30 Jun 2014 14:14:04 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 4/4] mm: page_alloc: Reduce cost of the fair zone
 allocation policy
Message-Id: <20140630141404.e09bdb5fa6a879d17c4556b1@linux-foundation.org>
In-Reply-To: <1404146883-21414-5-git-send-email-mgorman@suse.de>
References: <1404146883-21414-1-git-send-email-mgorman@suse.de>
	<1404146883-21414-5-git-send-email-mgorman@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>, Johannes Weiner <hannes@cmpxchg.org>

On Mon, 30 Jun 2014 17:48:03 +0100 Mel Gorman <mgorman@suse.de> wrote:

> The fair zone allocation policy round-robins allocations between zones
> within a node to avoid age inversion problems during reclaim. If the
> first allocation fails, the batch counts is reset and a second attempt
> made before entering the slow path.
> 
> One assumption made with this scheme is that batches expire at roughly the
> same time and the resets each time are justified. This assumption does not
> hold when zones reach their low watermark as the batches will be consumed
> at uneven rates.  Allocation failure due to watermark depletion result in
> additional zonelist scans for the reset and another watermark check before
> hitting the slowpath.
> 
> This patch makes a number of changes that should reduce the overall cost
> 
> o Abort the fair zone allocation policy once remote zones are encountered
> o Use a simplier scan when resetting NR_ALLOC_BATCH
> o Use a simple flag to identify depleted zones instead of accessing a
>   potentially write-intensive cache line for counters
> 
> On UMA machines, the effect on overall performance is marginal. The main
> impact is on system CPU usage which is small enough on UMA to begin with.
> This comparison shows the system CPu usage between vanilla, the previous
> patch and this patch.
> 
>           3.16.0-rc2  3.16.0-rc2  3.16.0-rc2
>              vanilla checklow-v4 fairzone-v4
> User          390.13      400.85      396.13
> System        404.41      393.60      389.61
> Elapsed      5412.45     5166.12     5163.49
> 
> There is a small reduction and it appears consistent.
> 
> On NUMA machines, the scanning overhead is higher as zones are scanned
> that are ineligible for use by zone allocation policy. This patch fixes
> the zone-order zonelist policy and reduces the numbers of zones scanned
> by the allocator leading to an overall reduction of CPU usage.
> 
>           3.16.0-rc2  3.16.0-rc2  3.16.0-rc2
>              vanilla checklow-v4 fairzone-v4
> User          744.05      763.26      778.53
> System      70148.60    49331.48    44905.73
> Elapsed     28094.08    27476.72    27378.98

That's a large change in system time.  Does this all include kswapd
activity?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
