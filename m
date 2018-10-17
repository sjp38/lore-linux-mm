Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 4C7846B0006
	for <linux-mm@kvack.org>; Wed, 17 Oct 2018 10:59:14 -0400 (EDT)
Received: by mail-pg1-f199.google.com with SMTP id v138-v6so20069809pgb.7
        for <linux-mm@kvack.org>; Wed, 17 Oct 2018 07:59:14 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id d37-v6si18585897pla.40.2018.10.17.07.59.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Oct 2018 07:59:12 -0700 (PDT)
Date: Wed, 17 Oct 2018 22:59:04 +0800
From: Aaron Lu <aaron.lu@intel.com>
Subject: Re: [RFC v4 PATCH 2/5] mm/__free_one_page: skip merge for order-0
 page unless compaction failed
Message-ID: <20181017145904.GC9167@intel.com>
References: <20181017063330.15384-1-aaron.lu@intel.com>
 <20181017063330.15384-3-aaron.lu@intel.com>
 <20181017104427.GJ5819@techsingularity.net>
 <20181017131059.GA9167@intel.com>
 <20181017135807.GL5819@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181017135807.GL5819@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Huang Ying <ying.huang@intel.com>, Dave Hansen <dave.hansen@linux.intel.com>, Kemi Wang <kemi.wang@intel.com>, Tim Chen <tim.c.chen@linux.intel.com>, Andi Kleen <ak@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Matthew Wilcox <willy@infradead.org>, Daniel Jordan <daniel.m.jordan@oracle.com>, Tariq Toukan <tariqt@mellanox.com>, Jesper Dangaard Brouer <brouer@redhat.com>

On Wed, Oct 17, 2018 at 02:58:07PM +0100, Mel Gorman wrote:
> On Wed, Oct 17, 2018 at 09:10:59PM +0800, Aaron Lu wrote:
> > On Wed, Oct 17, 2018 at 11:44:27AM +0100, Mel Gorman wrote:
> > > On Wed, Oct 17, 2018 at 02:33:27PM +0800, Aaron Lu wrote:
> > > > Running will-it-scale/page_fault1 process mode workload on a 2 sockets
> > > > Intel Skylake server showed severe lock contention of zone->lock, as
> > > > high as about 80%(42% on allocation path and 35% on free path) CPU
> > > > cycles are burnt spinning. With perf, the most time consuming part inside
> > > > that lock on free path is cache missing on page structures, mostly on
> > > > the to-be-freed page's buddy due to merging.
> > > > 
> > > 
> > > This confuses me slightly. The commit log for d8a759b57035 ("mm,
> > > page_alloc: double zone's batchsize") indicates that the contention for
> > > will-it-scale moved from the zone lock to the LRU lock. This appears to
> > > contradict that although the exact test case is different (page_fault_1
> > > vs page_fault2). Can you clarify why commit d8a759b57035 is
> > > insufficient?
> > 
> > commit d8a759b57035 helps zone lock scalability and while it reduced
> > zone lock scalability to some extent(but not entirely eliminated it),
> > the lock contention shifted to LRU lock in the meantime.
> > 
> 
> I assume you meant "zone lock contention" in the second case.

Yes, that's right.

> 
> > e.g. from commit d8a759b57035's changelog, with the same test case
> > will-it-scale/page_fault1:
> > 
> > 4 sockets Skylake:
> >     batch   score     change   zone_contention   lru_contention   total_contention
> >      31   15345900    +0.00%       64%                 8%           72%
> >      63   17992886   +17.25%       24%                45%           69%
> > 
> > 4 sockets Broadwell:
> >     batch   score     change   zone_contention   lru_contention   total_contention
> >      31   16703983    +0.00%       67%                 7%           74%
> >      63   18288885    +9.49%       38%                33%           71%
> > 
> > 2 sockets Skylake:
> >     batch   score     change   zone_contention   lru_contention   total_contention
> >      31   9554867     +0.00%       66%                 3%           69%
> >      63   9980145     +4.45%       62%                 4%           66%
> > 
> > Please note that though zone lock contention for the 4 sockets server
> > reduced a lot with commit d8a759b57035, 2 sockets Skylake still suffered
> > a lot from zone lock contention even after we doubled batch size.
> > 
> 
> Any particuular reason why? I assume it's related to the number of zone
> locks with the increase number of zones and the number of threads used
> for the test.

I think so too.

The 4 sockets server has 192 CPUs in total while the 2 sockets server
has 112 CPUs in total. Assume only ZONE_NORMAL are used, for the 4
sockets server it would be 192/4=48(CPUs per zone) while for the 2
sockets server it is 112/2=56(CPUs per zone). The test is started with
nr_task=nr_cpu so for the 2 sockets servers, it ends up having more CPUs
consuming one zone.

> 
> > Also, the reduced zone lock contention will again get worse if LRU lock
> > is optimized away by Daniel's work, or in cases there are no LRU in the
> > picture, e.g. an in-kernel user of page allocator like Tariq Toukan
> > demonstrated with netperf.
> > 
> 
> Vaguely understood, I never looked at the LRU lock patches.
> 
> > > I'm wondering is this really about reducing the number of dirtied cache
> > > lines due to struct page updates and less about the actual zone lock.
> > 
> > Hmm...if we reduce the time it takes under the zone lock, aren't we
> > helping the zone lock? :-)
> > 
> 
> Indirectly yes but reducing cache line dirtying is useful in itself so
> they should be at least considered separately as independent
> optimisations.
> 
> > > 
> > > > One way to avoid this overhead is not do any merging at all for order-0
> > > > pages. With this approach, the lock contention for zone->lock on free
> > > > path dropped to 1.1% but allocation side still has as high as 42% lock
> > > > contention. In the meantime, the dropped lock contention on free side
> > > > doesn't translate to performance increase, instead, it's consumed by
> > > > increased lock contention of the per node lru_lock(rose from 5% to 37%)
> > > > and the final performance slightly dropped about 1%.
> > > > 
> > > 
> > > Although this implies it's really about contention.
> > > 
> > > > Though performance dropped a little, it almost eliminated zone lock
> > > > contention on free path and it is the foundation for the next patch
> > > > that eliminates zone lock contention for allocation path.
> > > > 
> > > 
> > > Can you clarify whether THP was enabled or not? As this is order-0 focused,
> > > it would imply the series should have minimal impact due to limited merging.
> > 
> > Sorry about this, I should have mentioned THP is not used here.
> > 
> 
> That's important to know. It does reduce the utility of the patch
> somewhat but not all arches support THP and THP is not always enabled on
> x86.

I always wondered how systems are making use of THP.
After all, when system has been runing a while(days or months), file
cache should consumed a lot of memory and high order pages will become
more and more scare. If order9 page can't be reliably allocated, will
workload rely on it?
Just a thought.

THP is of course pretty neat that it reduced TLB cost, needs fewer page
table etc. I just wondered if people really rely on it, or using it
after their system has been up for a long time.

> > > compaction. Lazy merging doesn't say anything about the mobility of
> > > buddy pages that are still allocated.
> > 
> > True.
> > I was thinking if compactions isn't enabled, we probably shouldn't
> > enable this lazy buddy merging feature as it would make high order
> > allocation success rate dropping a lot.
> > 
> 
> It probably is lower as reclaim is not that aggressive. Add a comment
> with an explanation as to why it's compaction-specific.
> 
> > I probably should have mentioned clearly somewhere in the changelog that
> > the function of merging those unmerged order0 pages are embedded in
> > compaction code, in function isolate_migratepages_block() when isolate
> > candidates are scanned.
> > 
> 
> Yes, but note that the concept is still problematic.
> isolate_migratepages_block is not guaranteed to find a pageblock with
> unmerged buddies in it. If there are pageblocks towards the end of the
> zone with unmerged pages, they may never be found. This will be very hard
> to detect at runtime because it's heavily dependant on the exact state
> of the system.

Quite true.

The intent here though, is not to have compaction merge back all
unmerged pages, but did the merge for these unmerged pages in a
piggyback way, i.e. since isolate_migratepages_block() is doing the
scan, why don't we let it handle these unmerged pages when it meets
them?

If for some reason isolate_migratepages_block() didn't meet a single
unmerged page before compaction succeed, we probably do not need worry
much yet since compaction succeeded anyway.

> > > 
> > > When lazy buddy merging was last examined years ago, a consequence was
> > > that high-order allocation success rates were reduced. I see you do the
> > 
> > I tried mmtests/stress-highalloc on one desktop and didn't see
> > high-order allocation success rate dropping as shown in patch0's
> > changelog. But it could be that I didn't test enough machines or using
> > other test cases? Any suggestions on how to uncover this problem?
> > 
> 
> stress-highalloc is nowhere near as useful as it used to be
> unfortunately. It was built at a time when 4G machines were unusual.
> config-global-dhp__workload_thpscale can be sometimes useful but it's

Will take a look at this, thanks for the pointer.

> variable. There is not a good modern example of detecting allocation success
> rates of highly fragmented systems at the moment which is a real pity.
> 
> > > merging when compaction has been recently considered but I don't see how
> > > that is sufficient. If a high-order allocation fails, there is no
> > > guarantee that compaction will find those unmerged buddies. There is
> > 
> > Any unmerged buddies will have page->buddy_merge_skipped set and during
> > compaction, when isolate_migratepages_block() iterates pages to find
> > isolate candidates, it will find these unmerged pages and will do_merge()
> > for them. Suppose an order-9 pageblock, every page is merge_skipped
> > order-0 page; after isolate_migratepages_block() iterates them one by one
> > and calls do_merge() for them one by one, higher order page will be
> > formed during this process and after the last unmerged order0 page goes
> > through do_merge(), an order-9 buddy page will be formed.
> > 
> 
> Again, as compaction is not guaranteed to find the pageblocks, it would
> be important to consider whether a) that matters or b) find an
> alternative way of keeping unmerged buddies on separate lists so they
> can be quickly discovered when a high-order allocation fails.

That's a good question.
I tend to think it doesn't matter whether we can find all unmerged pages.
Let compaction does its job as before and do_merge() for any unmerged
pages when it scanned them is probably enough. But as you said, we don't
have a good enough case to test this yet.

> > > also no guarantee that a page free will find them. So, in the event of a
> > > high-order allocation failure, what finds all those unmerged buddies and
> > > puts them together to see if the allocation would succeed without
> > > reclaim/compaction/etc.
> > 
> > compaction is needed to form a high-order page after high-order
> > allocation failed, I think this is also true for vanilla kernel?
> 
> It's needed to form them efficiently but excessive reclaim or writing 3
> to drop_caches can also do it. Be careful of tying lazy buddy too
> closely to compaction.

That's the current design of this patchset, do you see any immediate
problem of this? Is it that you are worried about high-order allocation
success rate using this design?
