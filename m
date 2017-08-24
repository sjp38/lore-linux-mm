Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id AAA64440846
	for <linux-mm@kvack.org>; Thu, 24 Aug 2017 07:30:33 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id b7so454754wrf.3
        for <linux-mm@kvack.org>; Thu, 24 Aug 2017 04:30:33 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id o4si1442995wmo.122.2017.08.24.04.30.26
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 24 Aug 2017 04:30:26 -0700 (PDT)
Subject: Re: [RFC PATCH 0/6] proactive kcompactd
References: <20170727160701.9245-1-vbabka@suse.cz>
 <alpine.DEB.2.10.1708091353500.1218@chino.kir.corp.google.com>
 <20170821141014.GC1371@cmpxchg.org>
 <20170823053612.GA19689@js1304-P5Q-DELUXE>
 <502d438b-7167-5b78-c66c-0e1b47ba2434@suse.cz>
 <20170824062457.GA24656@js1304-P5Q-DELUXE>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <07967c37-d0e5-4743-7021-109dfeb9027a@suse.cz>
Date: Thu, 24 Aug 2017 13:30:24 +0200
MIME-Version: 1.0
In-Reply-To: <20170824062457.GA24656@js1304-P5Q-DELUXE>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@kernel.org>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>

On 08/24/2017 08:24 AM, Joonsoo Kim wrote:
>>
>>> If someone doesn't agree with above solution, your approach looks the
>>> second best to me. Though, there is something to optimize.
>>>
>>> I think that we don't need to be precise to track the pageblock's
>>> freepage state. Compaction is a far rare event compared to page
>>> allocation so compaction could be tolerate with false positive.
>>>
>>> So, my suggestion is:
>>>
>>> 1) Use 1 bit for the pageblock. Reusing PB_migrate_skip looks the best
>>> to me.
>>
>> Wouldn't the reusing cripple the original use for the migration scanner?
> 
> I think that there is no serious problem. Problem happens if we set
> PB_migrate_skip wrongly. Consider following two cases that set
> PB_migrate_skip.
> 
> 1) migration scanner find that whole pages in the pageblock is pinned.
> -> set skip -> it is cleared after one of the page is freed. No
> problem.
> 
> There is a possibility that temporary pinned page is unpinned and we
> miss this pageblock but it would be minor case.
> 
> 2) migration scanner find that whole pages in the pageblock are free.
> -> set skip -> we can miss the pageblock for a long time.

On second thought, this is probably not an issue. If whole pageblock is
free, then there's most likely no reason for compaction to be running.
It's also not likely that migrate scanner would see a pageblock that the
free scanner has processed previously, which is why we already use
single bit for both scanners.

But I realized your code seems wrong. You want to set skip bit when a
page is freed, although for the free scanner that means a page has
become available so we would actually want to *clear* the bit in that
case. That could be indeed much more accurate for kcompactd (which runs
after kswapd reclaim) than its ignore_skip_hint usage

> We need to fix 2) case in order to reuse PB_migrate_skip. I guess that
> just counting the number of freepage in isolate_migratepages_block()
> and considering it to not set PB_migrate_skip will work.
> 
>>
>>> 2) Mark PB_migrate_skip only in free path and only when needed.
>>> Unmark it in compaction if freepage scan fails in that pageblock.
>>> In compaction, skip the pageblock if PB_migrate_skip is set. It means
>>> that there is no freepage in the pageblock.
>>>
>>> Following is some code about my suggestion.
>>
>> Otherwise is sounds like it could work until the direct allocation
>> approach is fully developed (or turns out to be infeasible).
> 
> Agreed.
> 
> Thanks.
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
