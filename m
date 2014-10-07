Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f182.google.com (mail-ob0-f182.google.com [209.85.214.182])
	by kanga.kvack.org (Postfix) with ESMTP id E9DEE6B0038
	for <linux-mm@kvack.org>; Tue,  7 Oct 2014 03:42:35 -0400 (EDT)
Received: by mail-ob0-f182.google.com with SMTP id uy5so5306413obc.27
        for <linux-mm@kvack.org>; Tue, 07 Oct 2014 00:42:35 -0700 (PDT)
Received: from mail-ob0-x22c.google.com (mail-ob0-x22c.google.com [2607:f8b0:4003:c01::22c])
        by mx.google.com with ESMTPS id kx1si29979812obc.25.2014.10.07.00.42.34
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 07 Oct 2014 00:42:34 -0700 (PDT)
Received: by mail-ob0-f172.google.com with SMTP id wo20so5254808obc.3
        for <linux-mm@kvack.org>; Tue, 07 Oct 2014 00:42:34 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140929195337.GA9177@cerebellum.variantweb.net>
References: <1411714395-18115-1-git-send-email-iamjoonsoo.kim@lge.com>
	<20140929195337.GA9177@cerebellum.variantweb.net>
Date: Tue, 7 Oct 2014 16:42:33 +0900
Message-ID: <CAAmzW4PV5JAVg_StBtV2O+XyMwNHDuLFR01CXwL+cY48Ws7QoA@mail.gmail.com>
Subject: Re: [RFC PATCH 1/2] mm/afmalloc: introduce anti-fragmentation memory allocator
From: Joonsoo Kim <js1304@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjennings@variantweb.net>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>, Nitin Gupta <ngupta@vflare.org>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Jerome Marchand <jmarchan@redhat.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Dan Streetman <ddstreet@ieee.org>, Luigi Semenzato <semenzato@google.com>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>

Hello, Seth.
Sorry for late response. :)

2014-09-30 4:53 GMT+09:00 Seth Jennings <sjennings@variantweb.net>:
> On Fri, Sep 26, 2014 at 03:53:14PM +0900, Joonsoo Kim wrote:
>> WARNING: This is just RFC patchset. patch 2/2 is only for testing.
>> If you know useful place to use this allocator, please let me know.
>>
>> This is brand-new allocator, called anti-fragmentation memory allocator
>> (aka afmalloc), in order to deal with arbitrary sized object allocation
>> efficiently. zram and zswap uses arbitrary sized object to store
>> compressed data so they can use this allocator. If there are any other
>> use cases, they can use it, too.
>>
>> This work is motivated by observation of fragmentation on zsmalloc which
>> intended for storing arbitrary sized object with low fragmentation.
>> Although it works well on allocation-intensive workload, memory could be
>> highly fragmented after many free occurs. In some cases, unused memory due
>> to fragmentation occupy 20% ~ 50% amount of real used memory. The other
>> problem is that other subsystem cannot use these unused memory. These
>> fragmented memory are zsmalloc specific, so most of other subsystem cannot
>> use it until zspage is freed to page allocator.
>
> Yes, zsmalloc has a fragmentation issue.  This has been a topic lately.
> I and others are looking at putting compaction logic into zsmalloc to
> help with this.
>
>>
>> I guess that there are similar fragmentation problem in zbud, but, I
>> didn't deeply investigate it.
>>
>> This new allocator uses SLAB allocator to solve above problems. When
>> request comes, it returns handle that is pointer of metatdata to point
>> many small chunks. These small chunks are in power of 2 size and
>> build up whole requested memory. We can easily acquire these chunks
>> using SLAB allocator. Following is conceptual represetation of metadata
>> used in this allocator to help understanding of this allocator.
>>
>> Handle A for 400 bytes
>> {
>>       Pointer for 256 bytes chunk
>>       Pointer for 128 bytes chunk
>>       Pointer for 16 bytes chunk
>>
>>       (256 + 128 + 16 = 400)
>> }
>>
>> As you can see, 400 bytes memory are not contiguous in afmalloc so that
>> allocator specific store/load functions are needed. These require some
>> computation overhead and I guess that this is the only drawback this
>> allocator has.
>
> One problem with using the SLAB allocator is that kmalloc caches greater
> than 256 bytes, at least on my x86_64 machine, have slabs that require
> high order page allocations, which are going to be really hard to come
> by in the memory stressed environment in which zswap/zram are expected
> to operate.  I guess you could max out at 256 byte chunks to overcome
> this.  However, if you have a 3k object, that would require copying 12
> chunks from potentially 12 different pages into a contiguous area at
> mapping time and a larger metadata size.

SLUB uses high order allocation by default, but, it has fallback method. It
uses low order allocation if failed with high order allocation. So, we don't
need to worry about high order allocation.

>>
>> For optimization, it uses another approach for power of 2 sized request.
>> Instead of returning handle for metadata, it adds tag on pointer from
>> SLAB allocator and directly returns this value as handle. With this tag,
>> afmalloc can recognize whether handle is for metadata or not and do proper
>> processing on it. This optimization can save some memory.
>>
>> Although afmalloc use some memory for metadata, overall utilization of
>> memory is really good due to zero internal fragmentation by using power
>
> Smallest kmalloc cache is 8 bytes so up to 7 bytes of internal
> fragmentation per object right?  If so, "near zero".
>
>> of 2 sized object. Although zsmalloc has many size class, there is
>> considerable internal fragmentation in zsmalloc.
>
> Lets put a number on it. Internal fragmentation on objects with size >
> ZS_MIN_ALLOC_SIZE is ZS_SIZE_CLASS_DELTA-1, which is 15 bytes with
> PAGE_SIZE of 4k.  If the allocation is less than ZS_MIN_ALLOC_SIZE,
> fragmentation could be as high as ZS_MIN_ALLOC_SIZE-1 which is 31 on a
> 64-bit system with 4k pages.  (Note: I don't think that is it possible to
> compress a 4k page to less than 32 bytes, so for zswap, there will be no
> allocations in this size range).
>
> So we are looking at up to 7 vs 15 bytes of internal fragmentation per
> object in the case when allocations are > ZS_MIN_ALLOC_SIZE.  Once you
> take into account the per-object metadata overhead of afmalloc, I think
> zsmalloc comes out ahead here.

Sorry for misleading word usage.
What I want to tell is that the unused space at the end of zspage when
zspage isn't perfectly divided. For example, think about 2064 bytes size_class.
It's zspage would be 4 pages and it can have only 7 objects at maximum.
Remainder is 1936 bytes and we can't use this space. This is 11% of total
space on zspage. If we only use power of 2 size, there is no remainder and
no this type of unused space.

>>
>> In workload that needs many free, memory could be fragmented like
>> zsmalloc, but, there is big difference. These unused portion of memory
>> are SLAB specific memory so that other subsystem can use it. Therefore,
>> fragmented memory could not be a big problem in this allocator.
>
> While freeing chunks back to the slab allocator does make that memory
> available to other _kernel_ users, the fragmentation problem is just
> moved one level down.  The fragmentation will exist in the slabs and
> those fragmented slabs won't be freed to the page allocator, which would
> make them available to _any_ user, not just the kernel.  Additionally,
> there is little visibility into how chunks are organized in the slab,
> making compaction at the afmalloc level nearly impossible.  (The only
> visibility being the address returned by kmalloc())

Okay. Free objects in slab subsystem isn't perfect solution, but, it is better
than current situation.

And, I think that afmalloc could be compacted just with returned address.
My idea is sorting chunks by memory address and copying their contents
to temporary buffer in ascending order. After copy is complete, chunks could
be freed. These freed objects would be in contiguous range so SLAB would
free the slab to the page allocator. After some free are done, we allocate
chunks from SLAB again and copy contents in temporary buffers to these
newly allocated chunks. These chunks would be positioned in fragmented
slab so that fragmentation would be reduced.

>>
>> Extra benefit of this allocator design is NUMA awareness. This allocator
>> allocates real memory from SLAB allocator. SLAB considers client's NUMA
>> affinity, so these allocated memory is NUMA-friendly. Currently, zsmalloc
>> and zbud which are backend of zram and zswap, respectively, are not NUMA
>> awareness so that remote node's memory could be returned to requestor.
>> I think that it could be solved easily if NUMA awareness turns out to be
>> real problem. But, it may enlarge fragmentation depending on number of
>> nodes. Anyway, there is no NUMA awareness issue in this allocator.
>>
>> Although I'd like to replace zsmalloc with this allocator, it cannot be
>> possible, because zsmalloc supports HIGHMEM. In 32-bits world, SLAB memory
>> would be very limited so supporting HIGHMEM would be really good advantage
>> of zsmalloc. Because there is no HIGHMEM in 32-bits low memory device or
>> 64-bits world, this allocator may be good option for this system. I
>> didn't deeply consider whether this allocator can replace zbud or not.
>>
>> Below is the result of my simple test.
>> (zsmalloc used in experiments is patched with my previous patch:
>> zsmalloc: merge size_class to reduce fragmentation)
>>
>> TEST ENV: EXT4 on zram, mount with discard option
>> WORKLOAD: untar kernel source, remove dir in descending order in size.
>> (drivers arch fs sound include)
>>
>> Each line represents orig_data_size, compr_data_size, mem_used_total,
>> fragmentation overhead (mem_used - compr_data_size) and overhead ratio
>> (overhead to compr_data_size), respectively, after untar and remove
>> operation is executed. In afmalloc case, overhead is calculated by
>> before/after 'SUnreclaim' on /proc/meminfo. And there are two more columns
>> in afmalloc, one is real_overhead which represents metadata usage and
>> overhead of internal fragmentation, and the other is a ratio,
>> real_overhead to compr_data_size. Unlike zsmalloc, only metadata and
>> internal fragmented memory cannot be used by other subsystem. So,
>> comparing real_overhead in afmalloc with overhead on zsmalloc seems to
>> be proper comparison.
>
> See last comment about why the real measure of memory usage should be
> total pages not returned to the page allocator.  I don't consider chunks
> freed to the slab allocator to be truly freed unless the slab containing
> the chunks is also freed to the page allocator.
>
> The closest thing I can think of to measure the memory utilization of
> this allocator is, for each kmalloc cache, do a before/after of how many
> slabs are in the cache, then multiply that delta by pagesperslab and sum
> the results.  This would give a rough measure of the number of pages
> utilized in the slab allocator either by or as a result of afmalloc.
> Of course, there will be noise from other components doing allocations
> during the time between the before and after measurement.

It was already in below benchmark result. overhead and overhead ratio on
intar-afmalloc.out result are measured by number of allocated page in SLAB.
You can see that overhead and overhead ratio of afmalloc is less than
zsmalloc even in this metric.

Thanks.

> Seth
>
>>
>> * untar-merge.out
>>
>> orig_size compr_size used_size overhead overhead_ratio
>> 526.23MB 199.18MB 209.81MB  10.64MB 5.34%
>> 288.68MB  97.45MB 104.08MB   6.63MB 6.80%
>> 177.68MB  61.14MB  66.93MB   5.79MB 9.47%
>> 146.83MB  47.34MB  52.79MB   5.45MB 11.51%
>> 124.52MB  38.87MB  44.30MB   5.43MB 13.96%
>> 104.29MB  31.70MB  36.83MB   5.13MB 16.19%
>>
>> * untar-afmalloc.out
>>
>> orig_size compr_size used_size overhead overhead_ratio real real-ratio
>> 526.27MB 199.18MB 206.37MB   8.00MB 4.02%   7.19MB 3.61%
>> 288.71MB  97.45MB 101.25MB   5.86MB 6.01%   3.80MB 3.90%
>> 177.71MB  61.14MB  63.44MB   4.39MB 7.19%   2.30MB 3.76%
>> 146.86MB  47.34MB  49.20MB   3.97MB 8.39%   1.86MB 3.93%
>> 124.55MB  38.88MB  40.41MB   3.71MB 9.54%   1.53MB 3.95%
>> 104.32MB  31.70MB  32.96MB   3.43MB 10.81%   1.26MB 3.96%
>>
>> As you can see above result, real_overhead_ratio in afmalloc is
>> just 3% ~ 4% while overhead_ratio on zsmalloc varies 5% ~ 17%.
>>
>> And, 4% ~ 11% overhead_ratio in afmalloc is also slightly better
>> than overhead_ratio in zsmalloc which is 5% ~ 17%.
>>
>> Below is another simple test to check fragmentation effect in alloc/free
>> repetition workload.
>>
>> TEST ENV: EXT4 on zram, mount with discard option
>> WORKLOAD: untar kernel source, remove dir in descending order in size
>> (drivers arch fs sound include). Repeat this untar and remove 10 times.
>>
>> * untar-merge.out
>>
>> orig_size compr_size used_size overhead overhead_ratio
>> 526.24MB 199.18MB 209.79MB  10.61MB 5.33%
>> 288.69MB  97.45MB 104.09MB   6.64MB 6.81%
>> 177.69MB  61.14MB  66.89MB   5.75MB 9.40%
>> 146.84MB  47.34MB  52.77MB   5.43MB 11.46%
>> 124.53MB  38.88MB  44.28MB   5.40MB 13.90%
>> 104.29MB  31.71MB  36.87MB   5.17MB 16.29%
>> 535.59MB 200.30MB 211.77MB  11.47MB 5.73%
>> 294.84MB  98.28MB 106.24MB   7.97MB 8.11%
>> 179.99MB  61.58MB  69.34MB   7.76MB 12.60%
>> 148.67MB  47.75MB  55.19MB   7.43MB 15.57%
>> 125.98MB  39.26MB  46.62MB   7.36MB 18.75%
>> 105.05MB  32.03MB  39.18MB   7.15MB 22.32%
>> (snip...)
>> 535.59MB 200.31MB 211.88MB  11.57MB 5.77%
>> 294.84MB  98.28MB 106.62MB   8.34MB 8.49%
>> 179.99MB  61.59MB  73.83MB  12.24MB 19.88%
>> 148.67MB  47.76MB  59.58MB  11.82MB 24.76%
>> 125.98MB  39.27MB  51.10MB  11.84MB 30.14%
>> 105.05MB  32.04MB  43.68MB  11.64MB 36.31%
>> 535.59MB 200.31MB 211.89MB  11.58MB 5.78%
>> 294.84MB  98.28MB 106.68MB   8.40MB 8.55%
>> 179.99MB  61.59MB  74.14MB  12.55MB 20.37%
>> 148.67MB  47.76MB  59.94MB  12.18MB 25.50%
>> 125.98MB  39.27MB  51.46MB  12.19MB 31.04%
>> 105.05MB  32.04MB  44.01MB  11.97MB 37.35%
>>
>> * untar-afmalloc.out
>>
>> orig_size compr_size used_size overhead overhead_ratio real real-ratio
>> 526.23MB 199.17MB 206.36MB   8.02MB 4.03%   7.19MB 3.61%
>> 288.68MB  97.45MB 101.25MB   5.42MB 5.56%   3.80MB 3.90%
>> 177.68MB  61.14MB  63.43MB   4.00MB 6.54%   2.30MB 3.76%
>> 146.83MB  47.34MB  49.20MB   3.66MB 7.74%   1.86MB 3.93%
>> 124.52MB  38.87MB  40.41MB   3.33MB 8.57%   1.54MB 3.96%
>> 104.29MB  31.70MB  32.95MB   3.23MB 10.19%   1.26MB 3.97%
>> 535.59MB 200.30MB 207.59MB   9.21MB 4.60%   7.29MB 3.64%
>> 294.84MB  98.27MB 102.14MB   6.23MB 6.34%   3.87MB 3.94%
>> 179.99MB  61.58MB  63.91MB   4.98MB 8.09%   2.33MB 3.78%
>> 148.67MB  47.75MB  49.64MB   4.48MB 9.37%   1.89MB 3.95%
>> 125.98MB  39.26MB  40.82MB   4.23MB 10.78%   1.56MB 3.97%
>> 105.05MB  32.03MB  33.30MB   4.10MB 12.81%   1.27MB 3.98%
>> (snip...)
>> 535.59MB 200.30MB 207.60MB   8.94MB 4.46%   7.29MB 3.64%
>> 294.84MB  98.27MB 102.14MB   6.19MB 6.29%   3.87MB 3.94%
>> 179.99MB  61.58MB  63.91MB   8.25MB 13.39%   2.33MB 3.79%
>> 148.67MB  47.75MB  49.64MB   7.98MB 16.71%   1.89MB 3.96%
>> 125.98MB  39.26MB  40.82MB   7.52MB 19.15%   1.56MB 3.98%
>> 105.05MB  32.03MB  33.31MB   7.04MB 21.97%   1.28MB 3.98%
>> 535.59MB 200.31MB 207.60MB   9.26MB 4.62%   7.30MB 3.64%
>> 294.84MB  98.28MB 102.15MB   6.85MB 6.97%   3.87MB 3.94%
>> 179.99MB  61.58MB  63.91MB   9.08MB 14.74%   2.33MB 3.79%
>> 148.67MB  47.75MB  49.64MB   8.77MB 18.36%   1.89MB 3.96%
>> 125.98MB  39.26MB  40.82MB   8.35MB 21.28%   1.56MB 3.98%
>> 105.05MB  32.03MB  33.31MB   8.24MB 25.71%   1.28MB 3.98%
>>
>> As you can see above result, fragmentation grows continuously at each run.
>> But, real_overhead_ratio in afmalloc is always just 3% ~ 4%,
>> while overhead_ratio on zsmalloc varies 5% ~ 38%.
>> Fragmented slab memory can be used for other system, so we don't
>> have to much worry about overhead metric in afmalloc. Anyway, overhead
>> metric is also better in afmalloc, 4% ~ 26%.
>>
>> As a result, I think that afmalloc is better than zsmalloc in terms of
>> memory efficiency. But, I could be wrong so any comments are welcome. :)
>>
>> Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
>> ---
>>  include/linux/afmalloc.h |   21 ++
>>  mm/Kconfig               |    7 +
>>  mm/Makefile              |    1 +
>>  mm/afmalloc.c            |  590 ++++++++++++++++++++++++++++++++++++++++++++++
>>  4 files changed, 619 insertions(+)
>>  create mode 100644 include/linux/afmalloc.h
>>  create mode 100644 mm/afmalloc.c

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
