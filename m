Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id 3082E6B0038
	for <linux-mm@kvack.org>; Tue,  7 Oct 2014 22:31:47 -0400 (EDT)
Received: by mail-pa0-f45.google.com with SMTP id rd3so8217522pab.4
        for <linux-mm@kvack.org>; Tue, 07 Oct 2014 19:31:46 -0700 (PDT)
Received: from lgeamrelo02.lge.com (lgeamrelo02.lge.com. [156.147.1.126])
        by mx.google.com with ESMTP id t5si3554360pda.50.2014.10.07.19.31.43
        for <linux-mm@kvack.org>;
        Tue, 07 Oct 2014 19:31:45 -0700 (PDT)
Date: Wed, 8 Oct 2014 11:31:48 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [RFC PATCH 1/2] mm/afmalloc: introduce anti-fragmentation memory
 allocator
Message-ID: <20141008023148.GA11036@js1304-P5Q-DELUXE>
References: <1411714395-18115-1-git-send-email-iamjoonsoo.kim@lge.com>
 <20140929195337.GA9177@cerebellum.variantweb.net>
 <CAAmzW4PV5JAVg_StBtV2O+XyMwNHDuLFR01CXwL+cY48Ws7QoA@mail.gmail.com>
 <20141007202635.GA9176@cerebellum.variantweb.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141007202635.GA9176@cerebellum.variantweb.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Seth Jennings <sjennings@variantweb.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>, Nitin Gupta <ngupta@vflare.org>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Jerome Marchand <jmarchan@redhat.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Dan Streetman <ddstreet@ieee.org>, Luigi Semenzato <semenzato@google.com>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>

On Tue, Oct 07, 2014 at 03:26:35PM -0500, Seth Jennings wrote:
> On Tue, Oct 07, 2014 at 04:42:33PM +0900, Joonsoo Kim wrote:
> > Hello, Seth.
> > Sorry for late response. :)
> > 
> > 2014-09-30 4:53 GMT+09:00 Seth Jennings <sjennings@variantweb.net>:
> > > On Fri, Sep 26, 2014 at 03:53:14PM +0900, Joonsoo Kim wrote:
> > >> WARNING: This is just RFC patchset. patch 2/2 is only for testing.
> > >> If you know useful place to use this allocator, please let me know.
> > >>
> > >> This is brand-new allocator, called anti-fragmentation memory allocator
> > >> (aka afmalloc), in order to deal with arbitrary sized object allocation
> > >> efficiently. zram and zswap uses arbitrary sized object to store
> > >> compressed data so they can use this allocator. If there are any other
> > >> use cases, they can use it, too.
> > >>
> > >> This work is motivated by observation of fragmentation on zsmalloc which
> > >> intended for storing arbitrary sized object with low fragmentation.
> > >> Although it works well on allocation-intensive workload, memory could be
> > >> highly fragmented after many free occurs. In some cases, unused memory due
> > >> to fragmentation occupy 20% ~ 50% amount of real used memory. The other
> > >> problem is that other subsystem cannot use these unused memory. These
> > >> fragmented memory are zsmalloc specific, so most of other subsystem cannot
> > >> use it until zspage is freed to page allocator.
> > >
> > > Yes, zsmalloc has a fragmentation issue.  This has been a topic lately.
> > > I and others are looking at putting compaction logic into zsmalloc to
> > > help with this.
> > >
> > >>
> > >> I guess that there are similar fragmentation problem in zbud, but, I
> > >> didn't deeply investigate it.
> > >>
> > >> This new allocator uses SLAB allocator to solve above problems. When
> > >> request comes, it returns handle that is pointer of metatdata to point
> > >> many small chunks. These small chunks are in power of 2 size and
> > >> build up whole requested memory. We can easily acquire these chunks
> > >> using SLAB allocator. Following is conceptual represetation of metadata
> > >> used in this allocator to help understanding of this allocator.
> > >>
> > >> Handle A for 400 bytes
> > >> {
> > >>       Pointer for 256 bytes chunk
> > >>       Pointer for 128 bytes chunk
> > >>       Pointer for 16 bytes chunk
> > >>
> > >>       (256 + 128 + 16 = 400)
> > >> }
> > >>
> > >> As you can see, 400 bytes memory are not contiguous in afmalloc so that
> > >> allocator specific store/load functions are needed. These require some
> > >> computation overhead and I guess that this is the only drawback this
> > >> allocator has.
> > >
> > > One problem with using the SLAB allocator is that kmalloc caches greater
> > > than 256 bytes, at least on my x86_64 machine, have slabs that require
> > > high order page allocations, which are going to be really hard to come
> > > by in the memory stressed environment in which zswap/zram are expected
> > > to operate.  I guess you could max out at 256 byte chunks to overcome
> > > this.  However, if you have a 3k object, that would require copying 12
> > > chunks from potentially 12 different pages into a contiguous area at
> > > mapping time and a larger metadata size.
> > 
> > SLUB uses high order allocation by default, but, it has fallback method. It
> > uses low order allocation if failed with high order allocation. So, we don't
> > need to worry about high order allocation.
> 
> Didn't know about the fallback method :)
> 
> > 
> > >>
> > >> For optimization, it uses another approach for power of 2 sized request.
> > >> Instead of returning handle for metadata, it adds tag on pointer from
> > >> SLAB allocator and directly returns this value as handle. With this tag,
> > >> afmalloc can recognize whether handle is for metadata or not and do proper
> > >> processing on it. This optimization can save some memory.
> > >>
> > >> Although afmalloc use some memory for metadata, overall utilization of
> > >> memory is really good due to zero internal fragmentation by using power
> > >
> > > Smallest kmalloc cache is 8 bytes so up to 7 bytes of internal
> > > fragmentation per object right?  If so, "near zero".
> > >
> > >> of 2 sized object. Although zsmalloc has many size class, there is
> > >> considerable internal fragmentation in zsmalloc.
> > >
> > > Lets put a number on it. Internal fragmentation on objects with size >
> > > ZS_MIN_ALLOC_SIZE is ZS_SIZE_CLASS_DELTA-1, which is 15 bytes with
> > > PAGE_SIZE of 4k.  If the allocation is less than ZS_MIN_ALLOC_SIZE,
> > > fragmentation could be as high as ZS_MIN_ALLOC_SIZE-1 which is 31 on a
> > > 64-bit system with 4k pages.  (Note: I don't think that is it possible to
> > > compress a 4k page to less than 32 bytes, so for zswap, there will be no
> > > allocations in this size range).
> > >
> > > So we are looking at up to 7 vs 15 bytes of internal fragmentation per
> > > object in the case when allocations are > ZS_MIN_ALLOC_SIZE.  Once you
> > > take into account the per-object metadata overhead of afmalloc, I think
> > > zsmalloc comes out ahead here.
> > 
> > Sorry for misleading word usage.
> > What I want to tell is that the unused space at the end of zspage when
> > zspage isn't perfectly divided. For example, think about 2064 bytes size_class.
> > It's zspage would be 4 pages and it can have only 7 objects at maximum.
> > Remainder is 1936 bytes and we can't use this space. This is 11% of total
> > space on zspage. If we only use power of 2 size, there is no remainder and
> > no this type of unused space.
> 
> Ah, ok.  That's true.
> 
> > 
> > >>
> > >> In workload that needs many free, memory could be fragmented like
> > >> zsmalloc, but, there is big difference. These unused portion of memory
> > >> are SLAB specific memory so that other subsystem can use it. Therefore,
> > >> fragmented memory could not be a big problem in this allocator.
> > >
> > > While freeing chunks back to the slab allocator does make that memory
> > > available to other _kernel_ users, the fragmentation problem is just
> > > moved one level down.  The fragmentation will exist in the slabs and
> > > those fragmented slabs won't be freed to the page allocator, which would
> > > make them available to _any_ user, not just the kernel.  Additionally,
> > > there is little visibility into how chunks are organized in the slab,
> > > making compaction at the afmalloc level nearly impossible.  (The only
> > > visibility being the address returned by kmalloc())
> > 
> > Okay. Free objects in slab subsystem isn't perfect solution, but, it is better
> > than current situation.
> > 
> > And, I think that afmalloc could be compacted just with returned address.
> > My idea is sorting chunks by memory address and copying their contents
> > to temporary buffer in ascending order. After copy is complete, chunks could
> > be freed. These freed objects would be in contiguous range so SLAB would
> > free the slab to the page allocator. After some free are done, we allocate
> > chunks from SLAB again and copy contents in temporary buffers to these
> > newly allocated chunks. These chunks would be positioned in fragmented
> > slab so that fragmentation would be reduced.
> 
> I guess something that could be a problem is that the slabs might not
> contain only afmalloc allocations.  If another kernel process is
> allocating objects from the same slabs, then afmalloc might not be able
> to evacuate entire slabs.  A side effect of not having unilateral
> control of the memory pool at the page level.

Yes, it could be a problem. But, if we decide to implement compaction
in afmalloc, we don't need to adhere using general kmem_cache, because
fragmentation would be not an issue with compaction. In this case, afmalloc
can use its own private kmem_caches for power of 2 sized objects and
this would solves above concern.

> 
> > 
> > >>
> > >> Extra benefit of this allocator design is NUMA awareness. This allocator
> > >> allocates real memory from SLAB allocator. SLAB considers client's NUMA
> > >> affinity, so these allocated memory is NUMA-friendly. Currently, zsmalloc
> > >> and zbud which are backend of zram and zswap, respectively, are not NUMA
> > >> awareness so that remote node's memory could be returned to requestor.
> > >> I think that it could be solved easily if NUMA awareness turns out to be
> > >> real problem. But, it may enlarge fragmentation depending on number of
> > >> nodes. Anyway, there is no NUMA awareness issue in this allocator.
> > >>
> > >> Although I'd like to replace zsmalloc with this allocator, it cannot be
> > >> possible, because zsmalloc supports HIGHMEM. In 32-bits world, SLAB memory
> > >> would be very limited so supporting HIGHMEM would be really good advantage
> > >> of zsmalloc. Because there is no HIGHMEM in 32-bits low memory device or
> > >> 64-bits world, this allocator may be good option for this system. I
> > >> didn't deeply consider whether this allocator can replace zbud or not.
> > >>
> > >> Below is the result of my simple test.
> > >> (zsmalloc used in experiments is patched with my previous patch:
> > >> zsmalloc: merge size_class to reduce fragmentation)
> > >>
> > >> TEST ENV: EXT4 on zram, mount with discard option
> > >> WORKLOAD: untar kernel source, remove dir in descending order in size.
> > >> (drivers arch fs sound include)
> > >>
> > >> Each line represents orig_data_size, compr_data_size, mem_used_total,
> > >> fragmentation overhead (mem_used - compr_data_size) and overhead ratio
> > >> (overhead to compr_data_size), respectively, after untar and remove
> > >> operation is executed. In afmalloc case, overhead is calculated by
> > >> before/after 'SUnreclaim' on /proc/meminfo. And there are two more columns
> > >> in afmalloc, one is real_overhead which represents metadata usage and
> > >> overhead of internal fragmentation, and the other is a ratio,
> > >> real_overhead to compr_data_size. Unlike zsmalloc, only metadata and
> > >> internal fragmented memory cannot be used by other subsystem. So,
> > >> comparing real_overhead in afmalloc with overhead on zsmalloc seems to
> > >> be proper comparison.
> > >
> > > See last comment about why the real measure of memory usage should be
> > > total pages not returned to the page allocator.  I don't consider chunks
> > > freed to the slab allocator to be truly freed unless the slab containing
> > > the chunks is also freed to the page allocator.
> > >
> > > The closest thing I can think of to measure the memory utilization of
> > > this allocator is, for each kmalloc cache, do a before/after of how many
> > > slabs are in the cache, then multiply that delta by pagesperslab and sum
> > > the results.  This would give a rough measure of the number of pages
> > > utilized in the slab allocator either by or as a result of afmalloc.
> > > Of course, there will be noise from other components doing allocations
> > > during the time between the before and after measurement.
> > 
> > It was already in below benchmark result. overhead and overhead ratio on
> > intar-afmalloc.out result are measured by number of allocated page in SLAB.
> > You can see that overhead and overhead ratio of afmalloc is less than
> > zsmalloc even in this metric.
> 
> Ah yes, I didn't equate SUnreclaim with "slab usage".
> 
> It does look interesting.  I like the simplicity vs zsmalloc.
> 
> There would be more memcpy() calls in the map/unmap process. I guess you
> can tune the worse case number of memcpy()s by adjusting
> afmalloc_OBJ_MIN_SIZE in exchange for added fragmentation.  There is
> also the impact of many kmalloc() calls per allocated object: 1 for
> metadata and up to 7 for chunks on 64-bit.  Compression efficiency is
> important but so is speed.  Performance under memory pressure is also a
> factor that isn't accounted for in these results.

Yes... As I already mentioned in patch description, performance is
the problem this allocator has.

In fact, I guess that many kmalloc() calls would be no problem, because
SLAB allocation is really fast. Real factor of performance would be how
many pages we allocate from page allocator. If we allocate too many pages
from page allocator, kswapd would be invoked more or direct reclaim would
occurs more. These would be dominent factor of allocation performance.
afmalloc has good memory utilization so that page allocation happens
infrequently than zsmalloc. Therefore, it would be good performance
in this case.

But, it does many memcpy() than zsmalloc and it really affects
performance. IIUC, iozone test with afmalloc on ext4 on zram showed worse
performance than zsmalloc, roughly, 5 ~ 10%. This workload has no diverse
memory contents so there is no factor that affect to performance
except memcpy(). Therefore, I guess that it is upper bound of afmalloc's
performance loss to zsmalloc's. Meanwhile, simple swap test using kernel
build didn't have any noticible difference on performance.

> I'll try to build it and kick the tires soon.  Thanks!

Really appreciate for your interest and trying. :)
Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
