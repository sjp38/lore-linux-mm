Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f172.google.com (mail-we0-f172.google.com [74.125.82.172])
	by kanga.kvack.org (Postfix) with ESMTP id 679AF6B0035
	for <linux-mm@kvack.org>; Thu, 10 Jul 2014 08:18:34 -0400 (EDT)
Received: by mail-we0-f172.google.com with SMTP id u57so8919826wes.17
        for <linux-mm@kvack.org>; Thu, 10 Jul 2014 05:18:33 -0700 (PDT)
Received: from zene.cmpxchg.org (zene.cmpxchg.org. [2a01:238:4224:fa00:ca1f:9ef3:caee:a2bd])
        by mx.google.com with ESMTPS id dz10si12385920wib.76.2014.07.10.05.18.33
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 10 Jul 2014 05:18:33 -0700 (PDT)
Date: Thu, 10 Jul 2014 08:18:30 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 6/6] mm: page_alloc: Reduce cost of the fair zone
 allocation policy
Message-ID: <20140710121830.GN29639@cmpxchg.org>
References: <1404893588-21371-1-git-send-email-mgorman@suse.de>
 <1404893588-21371-7-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1404893588-21371-7-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>

On Wed, Jul 09, 2014 at 09:13:08AM +0100, Mel Gorman wrote:
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
> On UMA, the benefit is negligible -- around 0.25%. On 4-socket NUMA
> machine it's variable due to the variability of measuring overhead with
> the vmstat changes. The system CPU overhead comparison looks like
> 
>           3.16.0-rc3  3.16.0-rc3  3.16.0-rc3
>              vanilla   vmstat-v5 lowercost-v5
> User          746.94      774.56      802.00
> System      65336.22    32847.27    40852.33
> Elapsed     27553.52    27415.04    27368.46
> 
> However it is worth noting that the overall benchmark still completed
> faster and intuitively it makes sense to take as few passes as possible
> through the zonelists.
> 
> Signed-off-by: Mel Gorman <mgorman@suse.de>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
