Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 58A966B0003
	for <linux-mm@kvack.org>; Thu,  1 Mar 2018 05:22:32 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id j13so3040904wmh.3
        for <linux-mm@kvack.org>; Thu, 01 Mar 2018 02:22:32 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id f19si2307967wme.246.2018.03.01.02.22.30
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 01 Mar 2018 02:22:30 -0800 (PST)
Subject: Re: [UNTESTED RFC PATCH 0/8] compaction scanners rework
References: <20171213085915.9278-1-vbabka@suse.cz>
 <20180123200539.GA27770@cmpxchg.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <3d8269c7-8a09-83ac-622f-771862e12fc3@suse.cz>
Date: Thu, 1 Mar 2018 11:22:25 +0100
MIME-Version: 1.0
In-Reply-To: <20180123200539.GA27770@cmpxchg.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org, Mel Gorman <mgorman@techsingularity.net>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>

On 01/23/2018 09:05 PM, Johannes Weiner wrote:
> Hi Vlastimil,

Hi, sorry for the long delay!

> On Wed, Dec 13, 2017 at 09:59:07AM +0100, Vlastimil Babka wrote:
>> Hi,
>>
>> I have been working on this in the past weeks, but probably won't have time to
>> finish and test properly this year. So here's an UNTESTED RFC for those brave
>> enough to test, and also for review comments. I've been focusing on 1-7, and
>> patch 8 is unchanged since the last posting,  so Mel's suggestions (wrt
>> fallbacks and scanning pageblock where we get the free page from) from are not
>> included yet.
>>
>> For context, please see the recent threads [1] [2]. The main goal is to
>> eliminate the reported huge free scanner activity by replacing the scanner with
>> allocation from free lists. This has some dangers of excessive migrations as
>> described in Patch 8 commit log, so the earlier patches try to eliminate most
>> of them by making the migration scanner decide to actually migrate pages only
>> if it looks like it can succeed. This should be benefical even in the current
>> scheme.
> 
> I'm interested in helping to push this along, since we suffer from the
> current compaction free scanner.
> 
> On paper the patches make sense to me and the code looks reasonable as
> well. However, testing them with our workload would probably not add
> much to this series, since the new patches 1-7 are supposed to address
> issues we didn't observe in practice.

Well, the main purpose of 1-7 was to minimize issues expected due to 8 :)

> Since Mel isn't comfortable with replacing the scanner with freelist
> allocations - and I have to admit I also find the freelist allocations

Hm IIRC he said in the end that it would be OK, especially if freelist
was used as a pointer to pageblock which would be scanned. I don't think
it's a fundamental difference from purely freelist allocations.

> harder to reason about - I wonder if a different approach to this is
> workable.
> 
> The crux here is that this problem gets worse as memory sizes get
> bigger. We don't have an issue on 16G machines. But the page orders we
> want to allocate do not scale up the same way: THPs are still the same
> size, MAX_ORDER is still the same. So why, on a 256G machine, do we
> have to find matching used/free page candidates across the entire 256G
> memory range? We allocate THPs on 8G machines all the time - cheaper.
> 
> Yes, we always have to compact all of memory. But we don't have to aim
> for perfect defragmentation, with all used pages to the left and all
> free pages to the right. Currently, on a 256G machine, we essentially
> try to - although never getting there - compact a single order-25 free
> page. That seems like an insane goal.
> 
> So I wonder if instead we could split large memory ranges into smaller
> compaction chunks, each with their own pairs of migration and free
> scanners.

At first sight that would mean the same number of pages would still be
scanned, just in different order...

> We could then cheaply skip over entire chunks for which
> reclaim didn't produce any free pages.

OK this could mean less scanning in theory, but now we also have
skipping of pageblocks where compaction failed to isolate anything, so I
don't immediately see if this scheme would mean more efficient skipping.

> And we could compact all these
> sub chunks in parallel.

That could reduce allocation latency, but then multiple CPU's would be
burning time in compaction, and people would be still unhappy I guess.
Also compaction needs lru and zone locks for isolation, so those would
get contended and it wouldn't scale?

> Splitting the "matchmaking pool" like this would of course cause us to
> miss compaction opportunities between sources and targets in disjunct
> subranges. But we only need compaction to produce the largest common
> allocation requests; there has to be a maximum pool size on which a
> migrate & free scanner pair operates beyond which the rising scan cost
> yields diminishing returns, and beyond which divide and conquer would
> scale much better for the potentially increased allocation frequencies
> on larger machines.

I wonder if there's some other non-obvious underlying reason why
compaction works worse one 256G systems than on 8G. Could it be because
min_free_kbytes scales sub-linearly (IIRC?) with zone size? Compaction
performs better with more free memory.
Or higher zone/lru lock contention because there are also more cpus?
That would make terminating async compaction more likely, thus retrying
with the more expensive sync compaction.

Could some kind of experiments with fake numa splitting to smaller nodes
shed some more light here?

Vlastimil

> Does this make sense? Am I missing something in the way the allocator
> works that would make this impractical?
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
