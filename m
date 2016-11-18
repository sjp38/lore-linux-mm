Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 659D96B047D
	for <linux-mm@kvack.org>; Fri, 18 Nov 2016 15:58:58 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id s63so4191991wms.7
        for <linux-mm@kvack.org>; Fri, 18 Nov 2016 12:58:58 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id to13si4930668wjb.192.2016.11.18.12.58.55
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 18 Nov 2016 12:58:56 -0800 (PST)
Subject: Re: [patch 1/2] mm, zone: track number of pages in free area by
 migratetype
References: <alpine.DEB.2.10.1611161731350.17379@chino.kir.corp.google.com>
 <49ed7412-eab7-4d8d-c6df-fdf76d98da4d@suse.cz>
 <alpine.DEB.2.10.1611171405210.99747@chino.kir.corp.google.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <b938271e-e54c-a80b-d177-1f2c9b379532@suse.cz>
Date: Fri, 18 Nov 2016 21:58:42 +0100
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.10.1611171405210.99747@chino.kir.corp.google.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@suse.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 11/17/2016 11:11 PM, David Rientjes wrote:
> On Thu, 17 Nov 2016, Vlastimil Babka wrote:
> 
>>> The total number of free pages is still tracked, however, to not make
>>> zone_watermark_ok() more expensive.  Reading /proc/pagetypeinfo, however,
>>> is faster.
>>
>> Yeah I've already seen a case with /proc/pagetypeinfo causing soft
>> lockups due to high number of iterations...
>>
> 
> Thanks for taking a look at the patchset!
> 
> Wow, I haven't seen /proc/pagetypeinfo soft lockups yet, I thought this 
> was a relatively minor point :)

Well to be honest, it was a system misconfigured with numa=off which
made the lists both longer and more numa-distant. But nevertheless, we
might get there. It's not nice when userspace can so easily trigger long
iterations under the zone/node lock...

> But it looks like we need some 
> improvement in this behavior independent of memory compaction anyway.

Yeah.

>>> This patch introduces no functional change and increases the amount of
>>> per-zone metadata at worst by 48 bytes per memory zone (when CONFIG_CMA
>>> and CONFIG_MEMORY_ISOLATION are enabled).
>>
>> Isn't it 48 bytes per zone and order?
>>
> 
> Yes, sorry, I'll fix that in v2.  I think less than half a kilobyte for 
> each memory zone is satisfactory for extra tracking, compaction 
> improvements, and optimized /proc/pagetypeinfo, though.

I'm not worried about memory usage, but perhaps cache usage.

>>> Signed-off-by: David Rientjes <rientjes@google.com>
>>
>> I'd be for this if there are no performance regressions. It affects hot
>> paths and increases cache footprint. I think at least some allocator
>> intensive microbenchmark should be used.
>>
> 
> I can easily implement a test to stress movable page allocations from 
> fallback MIGRATE_UNMOVABLE pageblocks and freeing back to the same 
> pageblocks.  I assume we're not interested in memory offline benchmarks.

I meant just allocation benchmarks to see how much the extra operations
and cache footprint matters.

> What do you think about the logic presented in patch 2/2?  Are you 
> comfortable with a hard-coded ratio such as 1/64th of free memory or would 
> you prefer to look at the zone's watermark with the number of free pages 
> from MIGRATE_MOVABLE pageblocks rather than NR_FREE_PAGES?  I was split 
> between the two options.

The second options makes more sense to me intuitively as it resembles
what we've been doing until now. Maybe just don't require such a large
gap as compaction_suitable does?

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
