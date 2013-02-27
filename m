Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx116.postini.com [74.125.245.116])
	by kanga.kvack.org (Postfix) with SMTP id D7DBB6B0002
	for <linux-mm@kvack.org>; Wed, 27 Feb 2013 18:24:17 -0500 (EST)
MIME-Version: 1.0
Message-ID: <0efe9610-1aa5-4aa9-bde9-227acfa969ca@default>
Date: Wed, 27 Feb 2013 15:24:07 -0800 (PST)
From: Dan Magenheimer <dan.magenheimer@oracle.com>
Subject: zsmalloc limitations and related topics
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: minchan@kernel.org, sjenning@linux.vnet.ibm.com, Nitin Gupta <nitingupta910@gmail.com>
Cc: Konrad Wilk <konrad.wilk@oracle.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Bob Liu <lliubbo@gmail.com>, Luigi Semenzato <semenzato@google.com>, Mel Gorman <mgorman@suse.de>

Hi all --

I've been doing some experimentation on zsmalloc in preparation
for my topic proposed for LSFMM13 and have run across some
perplexing limitations.  Those familiar with the intimate details
of zsmalloc might be well aware of these limitations, but they
aren't documented or immediately obvious, so I thought it would
be worthwhile to air them publicly.  I've also included some
measurements from the experimentation and some related thoughts.

(Some of the terms here are unusual and may be used inconsistently
by different developers so a glossary of definitions of the terms
used here is appended.)

ZSMALLOC LIMITATIONS

Zsmalloc is used for two zprojects: zram and the out-of-tree
zswap.  Zsmalloc can achieve high density when "full".  But:

1) Zsmalloc has a worst-case density of 0.25 (one zpage per
   four pageframes).
2) When not full and especially when nearly-empty _after_
   being full, density may fall below 1.0 as a result of
   fragmentation.
3) Zsmalloc has a density of exactly 1.0 for any number of
   zpages with zsize >=3D 0.8.
4) Zsmalloc contains several compile-time parameters;
   the best value of these parameters may be very workload
   dependent.

If density =3D=3D 1.0, that means we are paying the overhead of
compression+decompression for no space advantage.  If
density < 1.0, that means using zsmalloc is detrimental,
resulting in worse memory pressure than if it were not used.

WORKLOAD ANALYSIS

These limitations emphasize that the workload used to evaluate
zsmalloc is very important.  Benchmarks that measure data
throughput or CPU utilization are of questionable value because
it is the _content_ of the data that is particularly relevant
for compression.  Even more precisely, it is the "entropy"
of the data that is relevant, because the amount of
compressibility in the data is related to the entropy:
I.e. an entirely random pagefull of bits will compress poorly
and a highly-regular pagefull of bits will compress well.
Since the zprojects manage a large number of zpages, both
the mean and distribution of zsize of the workload should
be "representative".

The workload most widely used to publish results for
the various zprojects is a kernel-compile using "make -jN"
where N is artificially increased to impose memory pressure.
By adding some debug code to zswap, I was able to analyze
this workload and found the following:

1) The average page compressed by almost a factor of six
   (mean zsize =3D=3D 694, stddev =3D=3D 474)
2) Almost eleven percent of the pages were zero pages.  A
   zero page compresses to 28 bytes.
3) On average, 77% of the bytes (3156) in the pages-to-be-
   compressed contained a byte-value of zero.
4) Despite the above, mean density of zsmalloc was measured at
   3.2 zpages/pageframe, presumably losing nearly half of
   available space to fragmentation.

I have no clue if these measurements are representative
of a wide range of workloads over the lifetime of a booted
machine, but I am suspicious that they are not.  For example,
the lzo1x compression algorithm claims to compress data by
about a factor of two.

I would welcome ideas on how to evaluate workloads for
"representativeness".  Personally I don't believe we should
be making decisions about selecting the "best" algorithms
or merging code without an agreement on workloads.

PAGEFRAME EVACUATION AND RECLAIM

I've repeatedly stated the opinion that managing the number of
pageframes containing compressed pages will be valuable for
managing MM interaction/policy when compression is used in
the kernel.  After the experimentation above and some brainstorming,
I still do not see an effective method for zsmalloc evacuating and
reclaiming pageframes, because both are complicated by high density
and page-crossing.  In other words, zsmalloc's strengths may
also be its Achilles heels.  For zram, as far as I can see,
pageframe evacuation/reclaim is irrelevant except perhaps
as part of mass defragmentation.  For zcache and zswap, where
writethrough is used, pageframe evacuation/reclaim is very relevant.
(Note: The writeback implemented in zswap does _zpage_ evacuation
without pageframe reclaim.)

CLOSING THOUGHT

Since zsmalloc and zbud have different strengths and weaknesses,
I wonder if some combination or hybrid might be more optimal?
But unless/until we have and can measure a representative workload,
only intuition can answer that.

GLOSSARY

zproject -- a kernel project using compression (zram, zcache, zswap)
zpage -- a compressed sequence of PAGE_SIZE bytes
zsize -- the number of bytes in a compressed page
pageframe -- the term "page" is widely used both to describe
    either (1) PAGE_SIZE bytes of data, or (2) a physical RAM
    area with size=3DPAGE_SIZE which is PAGE_SIZE-aligned,
    as represented in the kernel by a struct page.  To be explicit,
    we refer to (2) as a pageframe.
density -- zpages per pageframe; higher is (presumably) better
zsmalloc -- a slab-based allocator written by Nitin Gupta to
     efficiently store zpages and designed to allow zpages
     to be split across two non-contiguous pageframes
zspage -- a grouping of N non-contiguous pageframes managed
     as a unit by zsmalloc to store zpages for which zsize
     falls within a certain range.  (The compile-time
     default maximum size for N is 4).
zbud -- a buddy-based allocator written by Dan Magenheimer
     (specifically for zcache) to predictably store zpages;
     no more than two zpages are stored in any pageframe
pageframe evacuation/reclaim -- the process of removing
     zpages from one or more pageframes, including pointers/nodes
     from any data structures referencing those zpages,
     so that the pageframe(s) can be freed for use by
     the rest of the kernel
writeback --  the process of transferring zpages from
     storage in a zproject to a backing swap device
lzo1x -- a compression algorithm used by default by all the
     zprojects; the kernel implementation resides in lib/lzo.c
entropy -- randomness of data to be compressed; higher entropy
     means worse data compression

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
