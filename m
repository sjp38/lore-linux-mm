Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 852E06B0038
	for <linux-mm@kvack.org>; Thu,  2 Oct 2014 01:47:11 -0400 (EDT)
Received: by mail-pa0-f54.google.com with SMTP id ey11so1651781pad.27
        for <linux-mm@kvack.org>; Wed, 01 Oct 2014 22:47:11 -0700 (PDT)
Received: from lgemrelse7q.lge.com (LGEMRELSE7Q.lge.com. [156.147.1.151])
        by mx.google.com with ESMTP id i10si2870237pdr.145.2014.10.01.22.47.08
        for <linux-mm@kvack.org>;
        Wed, 01 Oct 2014 22:47:10 -0700 (PDT)
Date: Thu, 2 Oct 2014 14:47:18 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [RFC PATCH 1/2] mm/afmalloc: introduce anti-fragmentation memory
 allocator
Message-ID: <20141002054718.GD7433@js1304-P5Q-DELUXE>
References: <1411714395-18115-1-git-send-email-iamjoonsoo.kim@lge.com>
 <CALZtONArbej7s-FKqur2HyGQ0idp6wnsAW29OUTNzqkX3dNmPg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CALZtONArbej7s-FKqur2HyGQ0idp6wnsAW29OUTNzqkX3dNmPg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Streetman <ddstreet@ieee.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>, Nitin Gupta <ngupta@vflare.org>, Linux-MM <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, Jerome Marchand <jmarchan@redhat.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Luigi Semenzato <semenzato@google.com>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>

On Mon, Sep 29, 2014 at 11:41:45AM -0400, Dan Streetman wrote:
> On Fri, Sep 26, 2014 at 2:53 AM, Joonsoo Kim <iamjoonsoo.kim@lge.com> wrote:
> > WARNING: This is just RFC patchset. patch 2/2 is only for testing.
> > If you know useful place to use this allocator, please let me know.
> >
> > This is brand-new allocator, called anti-fragmentation memory allocator
> > (aka afmalloc), in order to deal with arbitrary sized object allocation
> > efficiently. zram and zswap uses arbitrary sized object to store
> > compressed data so they can use this allocator. If there are any other
> > use cases, they can use it, too.
> >
> > This work is motivated by observation of fragmentation on zsmalloc which
> > intended for storing arbitrary sized object with low fragmentation.
> > Although it works well on allocation-intensive workload, memory could be
> > highly fragmented after many free occurs. In some cases, unused memory due
> > to fragmentation occupy 20% ~ 50% amount of real used memory. The other
> > problem is that other subsystem cannot use these unused memory. These
> > fragmented memory are zsmalloc specific, so most of other subsystem cannot
> > use it until zspage is freed to page allocator.
> >
> > I guess that there are similar fragmentation problem in zbud, but, I
> > didn't deeply investigate it.
> >
> > This new allocator uses SLAB allocator to solve above problems. When
> > request comes, it returns handle that is pointer of metatdata to point
> > many small chunks. These small chunks are in power of 2 size and
> > build up whole requested memory. We can easily acquire these chunks
> > using SLAB allocator. Following is conceptual represetation of metadata
> > used in this allocator to help understanding of this allocator.
> >
> > Handle A for 400 bytes
> > {
> >         Pointer for 256 bytes chunk
> >         Pointer for 128 bytes chunk
> >         Pointer for 16 bytes chunk
> >
> >         (256 + 128 + 16 = 400)
> > }
> >
> > As you can see, 400 bytes memory are not contiguous in afmalloc so that
> > allocator specific store/load functions are needed. These require some
> > computation overhead and I guess that this is the only drawback this
> > allocator has.
> 
> This also requires additional memory copying, for each map/unmap, no?

Indeed.

> 
> >
> > For optimization, it uses another approach for power of 2 sized request.
> > Instead of returning handle for metadata, it adds tag on pointer from
> > SLAB allocator and directly returns this value as handle. With this tag,
> > afmalloc can recognize whether handle is for metadata or not and do proper
> > processing on it. This optimization can save some memory.
> >
> > Although afmalloc use some memory for metadata, overall utilization of
> > memory is really good due to zero internal fragmentation by using power
> > of 2 sized object. Although zsmalloc has many size class, there is
> > considerable internal fragmentation in zsmalloc.
> >
> > In workload that needs many free, memory could be fragmented like
> > zsmalloc, but, there is big difference. These unused portion of memory
> > are SLAB specific memory so that other subsystem can use it. Therefore,
> > fragmented memory could not be a big problem in this allocator.
> >
> > Extra benefit of this allocator design is NUMA awareness. This allocator
> > allocates real memory from SLAB allocator. SLAB considers client's NUMA
> > affinity, so these allocated memory is NUMA-friendly. Currently, zsmalloc
> > and zbud which are backend of zram and zswap, respectively, are not NUMA
> > awareness so that remote node's memory could be returned to requestor.
> > I think that it could be solved easily if NUMA awareness turns out to be
> > real problem. But, it may enlarge fragmentation depending on number of
> > nodes. Anyway, there is no NUMA awareness issue in this allocator.
> >
> > Although I'd like to replace zsmalloc with this allocator, it cannot be
> > possible, because zsmalloc supports HIGHMEM. In 32-bits world, SLAB memory
> > would be very limited so supporting HIGHMEM would be really good advantage
> > of zsmalloc. Because there is no HIGHMEM in 32-bits low memory device or
> > 64-bits world, this allocator may be good option for this system. I
> > didn't deeply consider whether this allocator can replace zbud or not.
> 
> While it looks like there may be some situations that benefit from
> this, this won't work for all cases (as you mention), so maybe zpool
> can allow zram to choose between zsmalloc and afmalloc.

Yes. :)

> >
> > Below is the result of my simple test.
> > (zsmalloc used in experiments is patched with my previous patch:
> > zsmalloc: merge size_class to reduce fragmentation)
> >
> > TEST ENV: EXT4 on zram, mount with discard option
> > WORKLOAD: untar kernel source, remove dir in descending order in size.
> > (drivers arch fs sound include)
> >
> > Each line represents orig_data_size, compr_data_size, mem_used_total,
> > fragmentation overhead (mem_used - compr_data_size) and overhead ratio
> > (overhead to compr_data_size), respectively, after untar and remove
> > operation is executed. In afmalloc case, overhead is calculated by
> > before/after 'SUnreclaim' on /proc/meminfo.
> > And there are two more columns
> > in afmalloc, one is real_overhead which represents metadata usage and
> > overhead of internal fragmentation, and the other is a ratio,
> > real_overhead to compr_data_size. Unlike zsmalloc, only metadata and
> > internal fragmented memory cannot be used by other subsystem. So,
> > comparing real_overhead in afmalloc with overhead on zsmalloc seems to
> > be proper comparison.
> >
> > * untar-merge.out
> >
> > orig_size compr_size used_size overhead overhead_ratio
> > 526.23MB 199.18MB 209.81MB  10.64MB 5.34%
> > 288.68MB  97.45MB 104.08MB   6.63MB 6.80%
> > 177.68MB  61.14MB  66.93MB   5.79MB 9.47%
> > 146.83MB  47.34MB  52.79MB   5.45MB 11.51%
> > 124.52MB  38.87MB  44.30MB   5.43MB 13.96%
> > 104.29MB  31.70MB  36.83MB   5.13MB 16.19%
> >
> > * untar-afmalloc.out
> >
> > orig_size compr_size used_size overhead overhead_ratio real real-ratio
> > 526.27MB 199.18MB 206.37MB   8.00MB 4.02%   7.19MB 3.61%
> > 288.71MB  97.45MB 101.25MB   5.86MB 6.01%   3.80MB 3.90%
> > 177.71MB  61.14MB  63.44MB   4.39MB 7.19%   2.30MB 3.76%
> > 146.86MB  47.34MB  49.20MB   3.97MB 8.39%   1.86MB 3.93%
> > 124.55MB  38.88MB  40.41MB   3.71MB 9.54%   1.53MB 3.95%
> > 104.32MB  31.70MB  32.96MB   3.43MB 10.81%   1.26MB 3.96%
> >
> > As you can see above result, real_overhead_ratio in afmalloc is
> > just 3% ~ 4% while overhead_ratio on zsmalloc varies 5% ~ 17%.
> >
> > And, 4% ~ 11% overhead_ratio in afmalloc is also slightly better
> > than overhead_ratio in zsmalloc which is 5% ~ 17%.
> 
> I think the key will be scaling up this test more.  What does it look
> like when using 20G or more?

In fact, main usage type of zram, that is, zram-swap, doesn't use 20G
memory in normal case. But, I also wanna know how it is scalable. I will
do this kinds of some testing if possible.

> 
> It certainly looks better when using (relatively) small amounts of data, though.

Yes.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
