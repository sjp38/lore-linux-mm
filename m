Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 247E8800DD
	for <linux-mm@kvack.org>; Tue, 23 Jan 2018 15:05:47 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id 17so905920wrm.10
        for <linux-mm@kvack.org>; Tue, 23 Jan 2018 12:05:47 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id f13si2790832edj.256.2018.01.23.12.05.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 23 Jan 2018 12:05:45 -0800 (PST)
Date: Tue, 23 Jan 2018 15:05:39 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [UNTESTED RFC PATCH 0/8] compaction scanners rework
Message-ID: <20180123200539.GA27770@cmpxchg.org>
References: <20171213085915.9278-1-vbabka@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171213085915.9278-1-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-mm@kvack.org, Mel Gorman <mgorman@techsingularity.net>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, David Rientjes <rientjes@google.com>

Hi Vlastimil,

On Wed, Dec 13, 2017 at 09:59:07AM +0100, Vlastimil Babka wrote:
> Hi,
> 
> I have been working on this in the past weeks, but probably won't have time to
> finish and test properly this year. So here's an UNTESTED RFC for those brave
> enough to test, and also for review comments. I've been focusing on 1-7, and
> patch 8 is unchanged since the last posting,  so Mel's suggestions (wrt
> fallbacks and scanning pageblock where we get the free page from) from are not
> included yet.
>
> For context, please see the recent threads [1] [2]. The main goal is to
> eliminate the reported huge free scanner activity by replacing the scanner with
> allocation from free lists. This has some dangers of excessive migrations as
> described in Patch 8 commit log, so the earlier patches try to eliminate most
> of them by making the migration scanner decide to actually migrate pages only
> if it looks like it can succeed. This should be benefical even in the current
> scheme.

I'm interested in helping to push this along, since we suffer from the
current compaction free scanner.

On paper the patches make sense to me and the code looks reasonable as
well. However, testing them with our workload would probably not add
much to this series, since the new patches 1-7 are supposed to address
issues we didn't observe in practice.

Since Mel isn't comfortable with replacing the scanner with freelist
allocations - and I have to admit I also find the freelist allocations
harder to reason about - I wonder if a different approach to this is
workable.

The crux here is that this problem gets worse as memory sizes get
bigger. We don't have an issue on 16G machines. But the page orders we
want to allocate do not scale up the same way: THPs are still the same
size, MAX_ORDER is still the same. So why, on a 256G machine, do we
have to find matching used/free page candidates across the entire 256G
memory range? We allocate THPs on 8G machines all the time - cheaper.

Yes, we always have to compact all of memory. But we don't have to aim
for perfect defragmentation, with all used pages to the left and all
free pages to the right. Currently, on a 256G machine, we essentially
try to - although never getting there - compact a single order-25 free
page. That seems like an insane goal.

So I wonder if instead we could split large memory ranges into smaller
compaction chunks, each with their own pairs of migration and free
scanners. We could then cheaply skip over entire chunks for which
reclaim didn't produce any free pages. And we could compact all these
sub chunks in parallel.

Splitting the "matchmaking pool" like this would of course cause us to
miss compaction opportunities between sources and targets in disjunct
subranges. But we only need compaction to produce the largest common
allocation requests; there has to be a maximum pool size on which a
migrate & free scanner pair operates beyond which the rising scan cost
yields diminishing returns, and beyond which divide and conquer would
scale much better for the potentially increased allocation frequencies
on larger machines.

Does this make sense? Am I missing something in the way the allocator
works that would make this impractical?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
