Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 79E626B0069
	for <linux-mm@kvack.org>; Mon, 28 Nov 2016 06:00:46 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id y16so36123335wmd.6
        for <linux-mm@kvack.org>; Mon, 28 Nov 2016 03:00:46 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id p21si25295778wmb.29.2016.11.28.03.00.43
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 28 Nov 2016 03:00:43 -0800 (PST)
Subject: Re: [PATCH] mm: page_alloc: High-order per-cpu page allocator v3
References: <20161127131954.10026-1-mgorman@techsingularity.net>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <5621b386-ee65-0fa5-e217-334924412c7f@suse.cz>
Date: Mon, 28 Nov 2016 12:00:41 +0100
MIME-Version: 1.0
In-Reply-To: <20161127131954.10026-1-mgorman@techsingularity.net>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>, Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Michal Hocko <mhocko@suse.com>, Johannes Weiner <hannes@cmpxchg.org>, Linux-MM <linux-mm@kvack.org>, Linux-Kernel <linux-kernel@vger.kernel.org>

On 11/27/2016 02:19 PM, Mel Gorman wrote:
>
> 2-socket modern machine
>                                 4.9.0-rc5             4.9.0-rc5
>                                   vanilla             hopcpu-v3
> Hmean    send-64         178.38 (  0.00%)      256.74 ( 43.93%)
> Hmean    send-128        351.49 (  0.00%)      507.52 ( 44.39%)
> Hmean    send-256        671.23 (  0.00%)     1004.19 ( 49.60%)
> Hmean    send-1024      2663.60 (  0.00%)     3910.42 ( 46.81%)
> Hmean    send-2048      5126.53 (  0.00%)     7562.13 ( 47.51%)
> Hmean    send-3312      7949.99 (  0.00%)    11565.98 ( 45.48%)
> Hmean    send-4096      9433.56 (  0.00%)    12929.67 ( 37.06%)
> Hmean    send-8192     15940.64 (  0.00%)    21587.63 ( 35.43%)
> Hmean    send-16384    26699.54 (  0.00%)    32013.79 ( 19.90%)
> Hmean    recv-64         178.38 (  0.00%)      256.72 ( 43.92%)
> Hmean    recv-128        351.49 (  0.00%)      507.47 ( 44.38%)
> Hmean    recv-256        671.20 (  0.00%)     1003.95 ( 49.57%)
> Hmean    recv-1024      2663.45 (  0.00%)     3909.70 ( 46.79%)
> Hmean    recv-2048      5126.26 (  0.00%)     7560.67 ( 47.49%)
> Hmean    recv-3312      7949.50 (  0.00%)    11564.63 ( 45.48%)
> Hmean    recv-4096      9433.04 (  0.00%)    12927.48 ( 37.04%)
> Hmean    recv-8192     15939.64 (  0.00%)    21584.59 ( 35.41%)
> Hmean    recv-16384    26698.44 (  0.00%)    32009.77 ( 19.89%)
>
> 1-socket 6 year old machine
>                                 4.9.0-rc5             4.9.0-rc5
>                                   vanilla             hopcpu-v3
> Hmean    send-64          87.47 (  0.00%)      127.14 ( 45.36%)
> Hmean    send-128        174.36 (  0.00%)      256.42 ( 47.06%)
> Hmean    send-256        347.52 (  0.00%)      509.41 ( 46.59%)
> Hmean    send-1024      1363.03 (  0.00%)     1991.54 ( 46.11%)
> Hmean    send-2048      2632.68 (  0.00%)     3759.51 ( 42.80%)
> Hmean    send-3312      4123.19 (  0.00%)     5873.28 ( 42.45%)
> Hmean    send-4096      5056.48 (  0.00%)     7072.81 ( 39.88%)
> Hmean    send-8192      8784.22 (  0.00%)    12143.92 ( 38.25%)
> Hmean    send-16384    15081.60 (  0.00%)    19812.71 ( 31.37%)
> Hmean    recv-64          86.19 (  0.00%)      126.59 ( 46.87%)
> Hmean    recv-128        173.93 (  0.00%)      255.21 ( 46.73%)
> Hmean    recv-256        346.19 (  0.00%)      506.72 ( 46.37%)
> Hmean    recv-1024      1358.28 (  0.00%)     1980.03 ( 45.77%)
> Hmean    recv-2048      2623.45 (  0.00%)     3729.35 ( 42.15%)
> Hmean    recv-3312      4108.63 (  0.00%)     5831.47 ( 41.93%)
> Hmean    recv-4096      5037.25 (  0.00%)     7021.59 ( 39.39%)
> Hmean    recv-8192      8762.32 (  0.00%)    12072.44 ( 37.78%)
> Hmean    recv-16384    15042.36 (  0.00%)    19690.14 ( 30.90%)

That looks way much better than the "v1" RFC posting. Was it just 
because you stopped doing the "at first iteration, use migratetype as 
index", and initializing pindex UINT_MAX hits so much quicker, or was 
there something more subtle that I missed? There was no changelog 
between "v1" and "v2".

>
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>

Acked-by: Vlastimil Babka <vbabka@suse.cz>


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
