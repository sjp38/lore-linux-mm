Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id CBB9E6B006A
	for <linux-mm@kvack.org>; Wed,  6 Oct 2010 04:01:36 -0400 (EDT)
Received: by iwn41 with SMTP id 41so2139063iwn.14
        for <linux-mm@kvack.org>; Wed, 06 Oct 2010 01:01:35 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20101005185725.088808842@linux.com>
References: <20101005185725.088808842@linux.com>
Date: Wed, 6 Oct 2010 11:01:35 +0300
Message-ID: <AANLkTinPU4T59PvDH1wX2Rcy7beL=TvmHOZh_wWuBU-T@mail.gmail.com>
Subject: Re: [UnifiedV4 00/16] The Unified slab allocator (V4)
From: Pekka Enberg <penberg@kernel.org>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
To: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, David Rientjes <rientjes@google.com>, Mel Gorman <mel@csn.ul.ie>, npiggin@kernel.dk, yanmin_zhang@linux.intel.com
List-ID: <linux-mm.kvack.org>

(Adding more people who've taken interest in slab performance in the
past to CC.)

On Tue, Oct 5, 2010 at 9:57 PM, Christoph Lameter <cl@linux.com> wrote:
> V3->V4:
> - Lots of debugging
> - Performance optimizations (more would be good)...
> - Drop per slab locking in favor of per node locking for
> =A0partial lists (queuing implies freeing large amounts of objects
> =A0to per node lists of slab).
> - Implement object expiration via reclaim VM logic.
>
> The following is a release of an allocator based on SLAB
> and SLUB that integrates the best approaches from both allocators. The
> per cpu queuing is like in SLAB whereas much of the infrastructure
> comes from SLUB.
>
> After this patches SLUB will track the cpu cache contents
> like SLAB attemped to. There are a number of architectural differences:
>
> 1. SLUB accurately tracks cpu caches instead of assuming that there
> =A0 is only a single cpu cache per node or system.
>
> 2. SLUB object expiration is tied into the page reclaim logic. There
> =A0 is no periodic cache expiration.
>
> 3. SLUB caches are dynamically configurable via the sysfs filesystem.
>
> 4. There is no per slab page metadata structure to maintain (aside
> =A0 from the object bitmap that usually fits into the page struct).
>
> 5. Has all the resiliency and diagnostic features of SLUB.
>
> The unified allocator is a merging of SLUB with some queuing concepts fro=
m
> SLAB and a new way of managing objects in the slabs using bitmaps. Memory
> wise this is slightly more inefficient than SLUB (due to the need to plac=
e
> large bitmaps --sized a few words--in some slab pages if there are more
> than BITS_PER_LONG objects in a slab) but in general does not increase sp=
ace
> use too much.
>
> The SLAB scheme of not touching the object during management is adopted.
> The unified allocator can efficiently free and allocate cache cold object=
s
> without causing cache misses.
>
> Some numbers using tcp_rr on localhost
>
>
> Dell R910 128G RAM, 64 processors, 4 NUMA nodes
>
> threads unified =A0 =A0 =A0 =A0 slub =A0 =A0 =A0 =A0 =A0 =A0slab
> 64 =A0 =A0 =A04141798 =A0 =A0 =A0 =A0 3729037 =A0 =A0 =A0 =A0 3884939
> 128 =A0 =A0 4146587 =A0 =A0 =A0 =A0 3890993 =A0 =A0 =A0 =A0 4105276
> 192 =A0 =A0 4003063 =A0 =A0 =A0 =A0 3876570 =A0 =A0 =A0 =A0 4110971
> 256 =A0 =A0 3928857 =A0 =A0 =A0 =A0 3942806 =A0 =A0 =A0 =A0 4099249
> 320 =A0 =A0 3922623 =A0 =A0 =A0 =A0 3969042 =A0 =A0 =A0 =A0 4093283
> 384 =A0 =A0 3827603 =A0 =A0 =A0 =A0 4002833 =A0 =A0 =A0 =A0 4108420
> 448 =A0 =A0 4140345 =A0 =A0 =A0 =A0 4027251 =A0 =A0 =A0 =A0 4118534
> 512 =A0 =A0 4163741 =A0 =A0 =A0 =A0 4050130 =A0 =A0 =A0 =A0 4122644
> 576 =A0 =A0 4175666 =A0 =A0 =A0 =A0 4099934 =A0 =A0 =A0 =A0 4149355
> 640 =A0 =A0 4190332 =A0 =A0 =A0 =A0 4142570 =A0 =A0 =A0 =A0 4175618
> 704 =A0 =A0 4198779 =A0 =A0 =A0 =A0 4173177 =A0 =A0 =A0 =A0 4193657
> 768 =A0 =A0 4662216 =A0 =A0 =A0 =A0 4200462 =A0 =A0 =A0 =A0 4222686

Are there any stability problems left? Have you tried other benchmarks
(e.g. hackbench, sysbench)? Can we merge the series in smaller
batches? For example, if we leave out the NUMA parts in the first
stage, do we expect to see performance regressions?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
