Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f71.google.com (mail-lf0-f71.google.com [209.85.215.71])
	by kanga.kvack.org (Postfix) with ESMTP id 5B7876B026A
	for <linux-mm@kvack.org>; Thu, 13 Oct 2016 06:59:19 -0400 (EDT)
Received: by mail-lf0-f71.google.com with SMTP id x79so46941057lff.2
        for <linux-mm@kvack.org>; Thu, 13 Oct 2016 03:59:19 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id af4si16980868wjc.51.2016.10.13.03.59.17
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 13 Oct 2016 03:59:18 -0700 (PDT)
Subject: Re: [RFC PATCH 3/5] mm/page_alloc: stop instantly reusing freed page
References: <1476346102-26928-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1476346102-26928-4-git-send-email-iamjoonsoo.kim@lge.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <44132140-c678-73a2-b747-f04ad0f3d7df@suse.cz>
Date: Thu, 13 Oct 2016 12:59:14 +0200
MIME-Version: 1.0
In-Reply-To: <1476346102-26928-4-git-send-email-iamjoonsoo.kim@lge.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: js1304@gmail.com, Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@techsingularity.net>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

On 10/13/2016 10:08 AM, js1304@gmail.com wrote:
> From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
>
> Allocation/free pattern is usually sequantial. If they are freed to
> the buddy list, they can be coalesced. However, we first keep these freed
> pages at the pcp list and try to reuse them until threshold is reached
> so we don't have enough chance to get a high order freepage. This reusing
> would provide us some performance advantages since we don't need to
> get the zone lock and we don't pay the cost to check buddy merging.
> But, less fragmentation and more high order freepage would compensate
> this overhead in other ways. First, we would trigger less direct
> compaction which has high overhead. And, there are usecases that uses
> high order page to boost their performance.
>
> Instantly resuing freed page seems to provide us computational benefit
> but the other affects more precious things like as I/O performance and
> memory consumption so I think that it's a good idea to weight
> later advantage more.

Again, there's also cache hotness to consider. And whether the 
sequential pattern is still real on a system with higher uptime. Should 
be possible to evaluate with tracepoints?


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
