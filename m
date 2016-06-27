Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id D37EB6B0253
	for <linux-mm@kvack.org>; Mon, 27 Jun 2016 08:48:12 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id g62so397319998pfb.3
        for <linux-mm@kvack.org>; Mon, 27 Jun 2016 05:48:12 -0700 (PDT)
Received: from mail-pa0-x229.google.com (mail-pa0-x229.google.com. [2607:f8b0:400e:c03::229])
        by mx.google.com with ESMTPS id ss9si26587922pab.185.2016.06.27.05.48.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 27 Jun 2016 05:48:11 -0700 (PDT)
Received: by mail-pa0-x229.google.com with SMTP id hl6so58946878pac.2
        for <linux-mm@kvack.org>; Mon, 27 Jun 2016 05:48:11 -0700 (PDT)
Subject: Re: [PATCH 00/27] Move LRU page reclaim from zones to nodes v7
References: <1466518566-30034-1-git-send-email-mgorman@techsingularity.net>
 <3c062233-1ef7-bc85-5079-255f61f57c7d@gmail.com>
 <20160624075059.GC1868@techsingularity.net>
From: Balbir Singh <bsingharora@gmail.com>
Message-ID: <57712083.8060500@gmail.com>
Date: Mon, 27 Jun 2016 22:48:03 +1000
MIME-Version: 1.0
In-Reply-To: <20160624075059.GC1868@techsingularity.net>
Content-Type: text/plain; charset=iso-8859-15
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>



On 24/06/16 17:50, Mel Gorman wrote:
> On Fri, Jun 24, 2016 at 04:35:45PM +1000, Balbir Singh wrote:
>>> 1. The residency of a page partially depends on what zone the page was
>>>    allocated from.  This is partially combatted by the fair zone allocation
>>>    policy but that is a partial solution that introduces overhead in the
>>>    page allocator paths.
>>>
>>> 2. Currently, reclaim on node 0 behaves slightly different to node 1. For
>>>    example, direct reclaim scans in zonelist order and reclaims even if
>>>    the zone is over the high watermark regardless of the age of pages
>>>    in that LRU. Kswapd on the other hand starts reclaim on the highest
>>>    unbalanced zone. A difference in distribution of file/anon pages due
>>>    to when they were allocated results can result in a difference in 
>>>    again. While the fair zone allocation policy mitigates some of the
>>>    problems here, the page reclaim results on a multi-zone node will
>>>    always be different to a single-zone node.
>>>    it was scheduled on as a result.
>>>
>>> 3. kswapd and the page allocator scan zones in the opposite order to
>>>    avoid interfering with each other but it's sensitive to timing.  This
>>>    mitigates the page allocator using pages that were allocated very recently
>>>    in the ideal case but it's sensitive to timing. When kswapd is allocating
>>>    from lower zones then it's great but during the rebalancing of the highest
>>>    zone, the page allocator and kswapd interfere with each other. It's worse
>>>    if the highest zone is small and difficult to balance.
>>>
>>> 4. slab shrinkers are node-based which makes it harder to identify the exact
>>>    relationship between slab reclaim and LRU reclaim.
>>>
>>
>> Sorry, I am late in reading the thread and the patches, but I am trying to understand
>> the key benefits?
> 
> The key benefits were outlined at the beginning of the changelog. The
> one that is missing is the large overhead from the fair zone allocation
> policy which can be removed safely by the feature. The benefit to page
> allocator micro-benchmarks is outlined in the series introduction.

I did look at them, but between 1 to 4, it seemed like the largest benefit
was mm cleanup and better behaviour of reclaim on node 0.

> 
>> I know that
>> zones have grown to be overloaded to mean many things now. What is the contention impact
>> of moving the LRU from zone to nodes?
> 
> Expected to be minimal. On NUMA machines, most nodes have only one zone.
> On machines with multiple zones, the lock per zone is not that fine-grained
> given the size of the zones on large memory configurations.
> 

Makes sense

Thanks,
Balbir Singh.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
