Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx197.postini.com [74.125.245.197])
	by kanga.kvack.org (Postfix) with SMTP id 024466B0006
	for <linux-mm@kvack.org>; Wed, 13 Mar 2013 11:14:12 -0400 (EDT)
Received: from /spool/local
	by e23smtp03.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <rcjenn@linux.vnet.ibm.com>;
	Thu, 14 Mar 2013 01:07:33 +1000
Received: from d23relay05.au.ibm.com (d23relay05.au.ibm.com [9.190.235.152])
	by d23dlp02.au.ibm.com (Postfix) with ESMTP id 01A742BB0051
	for <linux-mm@kvack.org>; Thu, 14 Mar 2013 02:14:04 +1100 (EST)
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay05.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r2DF196N43778134
	for <linux-mm@kvack.org>; Thu, 14 Mar 2013 02:01:10 +1100
Received: from d23av01.au.ibm.com (loopback [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r2DFE2ni007743
	for <linux-mm@kvack.org>; Thu, 14 Mar 2013 02:14:03 +1100
Date: Wed, 13 Mar 2013 10:14:00 -0500
From: Robert Jennings <rcj@linux.vnet.ibm.com>
Subject: Re: zsmalloc limitations and related topics
Message-ID: <20130313151359.GA3130@linux.vnet.ibm.com>
References: <0efe9610-1aa5-4aa9-bde9-227acfa969ca@default>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <0efe9610-1aa5-4aa9-bde9-227acfa969ca@default>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: minchan@kernel.org, sjenning@linux.vnet.ibm.com, Nitin Gupta <nitingupta910@gmail.com>, Konrad Wilk <konrad.wilk@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Bob Liu <lliubbo@gmail.com>, Luigi Semenzato <semenzato@google.com>, Mel Gorman <mgorman@suse.de>, Robert Jennings <rcj@linux.vnet.ibm.com>

* Dan Magenheimer (dan.magenheimer@oracle.com) wrote:
> Hi all --
> 
> I've been doing some experimentation on zsmalloc in preparation
> for my topic proposed for LSFMM13 and have run across some
> perplexing limitations.  Those familiar with the intimate details
> of zsmalloc might be well aware of these limitations, but they
> aren't documented or immediately obvious, so I thought it would
> be worthwhile to air them publicly.  I've also included some
> measurements from the experimentation and some related thoughts.
> 
> (Some of the terms here are unusual and may be used inconsistently
> by different developers so a glossary of definitions of the terms
> used here is appended.)
> 
> ZSMALLOC LIMITATIONS
> 
> Zsmalloc is used for two zprojects: zram and the out-of-tree
> zswap.  Zsmalloc can achieve high density when "full".  But:
> 
> 1) Zsmalloc has a worst-case density of 0.25 (one zpage per
>    four pageframes).

The design of the allocator results in a trade-off between best case
density and the worst-case which is true for any allocator.  For zsmalloc,
the best case density with a 4K page size is 32.0, or 177.0 for a 64K page
size, based on storing a set of zero-filled pages compressed by lzo1x-1.

> 2) When not full and especially when nearly-empty _after_
>    being full, density may fall below 1.0 as a result of
>    fragmentation.

True and there are several ways to address this including
defragmentation, fewer class sizes in zsmalloc, aging, and/or writeback
of zpages in sparse zspages to free pageframes during normal writeback.

> 3) Zsmalloc has a density of exactly 1.0 for any number of
>    zpages with zsize >= 0.8.

For this reason zswap does not cache pages which in this range.
It is not enforced in the allocator because some users may be forced to
store these pages; users like zram.

> 4) Zsmalloc contains several compile-time parameters;
>    the best value of these parameters may be very workload
>    dependent.

The parameters fall into two major areas, handle computation and class
size.  The handle can be abstracted away, eliminating the compile-time
parameters.  The class-size tunable could be changed to a default value
with the option for specifying an alternate value from the user during
pool creation.

> If density == 1.0, that means we are paying the overhead of
> compression+decompression for no space advantage.  If
> density < 1.0, that means using zsmalloc is detrimental,
> resulting in worse memory pressure than if it were not used.
> 
> WORKLOAD ANALYSIS
> 
> These limitations emphasize that the workload used to evaluate
> zsmalloc is very important.  Benchmarks that measure data
> throughput or CPU utilization are of questionable value because
> it is the _content_ of the data that is particularly relevant
> for compression.  Even more precisely, it is the "entropy"
> of the data that is relevant, because the amount of
> compressibility in the data is related to the entropy:
> I.e. an entirely random pagefull of bits will compress poorly
> and a highly-regular pagefull of bits will compress well.
> Since the zprojects manage a large number of zpages, both
> the mean and distribution of zsize of the workload should
> be "representative".
> 
> The workload most widely used to publish results for
> the various zprojects is a kernel-compile using "make -jN"
> where N is artificially increased to impose memory pressure.
> By adding some debug code to zswap, I was able to analyze
> this workload and found the following:
> 
> 1) The average page compressed by almost a factor of six
>    (mean zsize == 694, stddev == 474)
> 2) Almost eleven percent of the pages were zero pages.  A
>    zero page compresses to 28 bytes.
> 3) On average, 77% of the bytes (3156) in the pages-to-be-
>    compressed contained a byte-value of zero.
> 4) Despite the above, mean density of zsmalloc was measured at
>    3.2 zpages/pageframe, presumably losing nearly half of
>    available space to fragmentation.
> 
> I have no clue if these measurements are representative
> of a wide range of workloads over the lifetime of a booted
> machine, but I am suspicious that they are not.  For example,
> the lzo1x compression algorithm claims to compress data by
> about a factor of two.

I'm suspicious of the "factor of two" claim.  The reference
(http://www.oberhumer.com/opensource/lzo/lzodoc.php) for this would appear
to be the results of compressing the Calgary Corpus.  This is fine for
comparing compression algorithms but I would be hesitant to apply that
to this problem space.  To illustrate the affect of input set, the newer
Canterbury Corpus compresses to ~43% of the input size using LZO1X-1.

In practice the average for LZO would be workload dependent, as you
demonstrate with the kernel build.  Swap page entropy for any given
workload will not necessarily fit the distribution present in the
Calgary Corpus.  The high density allocation design in zsmalloc allows
for workloads that can compress to factors greater than 2 to do so.

> I would welcome ideas on how to evaluate workloads for
> "representativeness".  Personally I don't believe we should
> be making decisions about selecting the "best" algorithms
> or merging code without an agreement on workloads.

I'd argue that there is no such thing as a "representative workload".
Instead, we try different workloads to validate the design and illustrate
the performance characteristics and impacts.

> PAGEFRAME EVACUATION AND RECLAIM
> 
> I've repeatedly stated the opinion that managing the number of
> pageframes containing compressed pages will be valuable for
> managing MM interaction/policy when compression is used in
> the kernel.  After the experimentation above and some brainstorming,
> I still do not see an effective method for zsmalloc evacuating and
> reclaiming pageframes, because both are complicated by high density
> and page-crossing.  In other words, zsmalloc's strengths may
> also be its Achilles heels.  For zram, as far as I can see,
> pageframe evacuation/reclaim is irrelevant except perhaps
> as part of mass defragmentation.  For zcache and zswap, where
> writethrough is used, pageframe evacuation/reclaim is very relevant.
> (Note: The writeback implemented in zswap does _zpage_ evacuation
> without pageframe reclaim.)

zswap writeback without guaranteed pageframe reclaim can occur during
swap activity.  Reclaim, even if it doesn't free a physical page, makes
room in the page for incoming swap.  With zswap the writeback mechanism
is driven by swap activity, so a zpage freed through writeback can be
back-filled by a newly compressed zpage.  Fragmentation is an issue when
processes exit and block zpages are invalidated and becomes an issue when
zswap is idle.  Otherwise the holes provide elasticity to accommodate
incoming pages to zswap.  This is the case for both zswap and zcache.

At idle we would want defragmentation or aging, either of which has
the end result of shrinking the cache and returning pages to the
memory manager.  The former only reduces fragmentation while the
later has the additional benefit of returning memory for other uses.
By adding aging, through periodic writeback, zswap becomes a true cache,
it eliminates long-held allocations, and addresses fragmentation for
long-held allocations.

Because the return value of zs_malloc() is not a pointer, but an opaque
value that only has meaning to zsmalloc, the API zsmalloc already has
would support the addition of an abstraction layer that would accommodate
allocation migration necessary for defragmentation.

> CLOSING THOUGHT
> 
> Since zsmalloc and zbud have different strengths and weaknesses,
> I wonder if some combination or hybrid might be more optimal?
> But unless/until we have and can measure a representative workload,
> only intuition can answer that.
> 
> GLOSSARY
> 
> zproject -- a kernel project using compression (zram, zcache, zswap)
> zpage -- a compressed sequence of PAGE_SIZE bytes
> zsize -- the number of bytes in a compressed page
> pageframe -- the term "page" is widely used both to describe
>     either (1) PAGE_SIZE bytes of data, or (2) a physical RAM
>     area with size=PAGE_SIZE which is PAGE_SIZE-aligned,
>     as represented in the kernel by a struct page.  To be explicit,
>     we refer to (2) as a pageframe.
> density -- zpages per pageframe; higher is (presumably) better
> zsmalloc -- a slab-based allocator written by Nitin Gupta to
>      efficiently store zpages and designed to allow zpages
>      to be split across two non-contiguous pageframes
> zspage -- a grouping of N non-contiguous pageframes managed
>      as a unit by zsmalloc to store zpages for which zsize
>      falls within a certain range.  (The compile-time
>      default maximum size for N is 4).
> zbud -- a buddy-based allocator written by Dan Magenheimer
>      (specifically for zcache) to predictably store zpages;
>      no more than two zpages are stored in any pageframe
> pageframe evacuation/reclaim -- the process of removing
>      zpages from one or more pageframes, including pointers/nodes
>      from any data structures referencing those zpages,
>      so that the pageframe(s) can be freed for use by
>      the rest of the kernel
> writeback --  the process of transferring zpages from
>      storage in a zproject to a backing swap device
> lzo1x -- a compression algorithm used by default by all the
>      zprojects; the kernel implementation resides in lib/lzo.c
> entropy -- randomness of data to be compressed; higher entropy
>      means worse data compression

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
