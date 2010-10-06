Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id A48B86B004A
	for <linux-mm@kvack.org>; Wed,  6 Oct 2010 08:38:01 -0400 (EDT)
Date: Wed, 6 Oct 2010 20:37:53 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: [UnifiedV4 00/16] The Unified slab allocator (V4)
Message-ID: <20101006123753.GA17674@localhost>
References: <20101005185725.088808842@linux.com>
 <AANLkTinPU4T59PvDH1wX2Rcy7beL=TvmHOZh_wWuBU-T@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <AANLkTinPU4T59PvDH1wX2Rcy7beL=TvmHOZh_wWuBU-T@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@kernel.org>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@cs.helsinki.fi>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, David Rientjes <rientjes@google.com>, Mel Gorman <mel@csn.ul.ie>, npiggin@kernel.dk, yanmin_zhang@linux.intel.com, "Shi, Alex" <alex.shi@intel.com>
List-ID: <linux-mm.kvack.org>

[add CC to Alex: he is now in charge of kernel performance tests]

On Wed, Oct 06, 2010 at 11:01:35AM +0300, Pekka Enberg wrote:
> (Adding more people who've taken interest in slab performance in the
> past to CC.)
> 
> On Tue, Oct 5, 2010 at 9:57 PM, Christoph Lameter <cl@linux.com> wrote:
> > V3->V4:
> > - Lots of debugging
> > - Performance optimizations (more would be good)...
> > - Drop per slab locking in favor of per node locking for
> > A partial lists (queuing implies freeing large amounts of objects
> > A to per node lists of slab).
> > - Implement object expiration via reclaim VM logic.
> >
> > The following is a release of an allocator based on SLAB
> > and SLUB that integrates the best approaches from both allocators. The
> > per cpu queuing is like in SLAB whereas much of the infrastructure
> > comes from SLUB.
> >
> > After this patches SLUB will track the cpu cache contents
> > like SLAB attemped to. There are a number of architectural differences:
> >
> > 1. SLUB accurately tracks cpu caches instead of assuming that there
> > A  is only a single cpu cache per node or system.
> >
> > 2. SLUB object expiration is tied into the page reclaim logic. There
> > A  is no periodic cache expiration.
> >
> > 3. SLUB caches are dynamically configurable via the sysfs filesystem.
> >
> > 4. There is no per slab page metadata structure to maintain (aside
> > A  from the object bitmap that usually fits into the page struct).
> >
> > 5. Has all the resiliency and diagnostic features of SLUB.
> >
> > The unified allocator is a merging of SLUB with some queuing concepts from
> > SLAB and a new way of managing objects in the slabs using bitmaps. Memory
> > wise this is slightly more inefficient than SLUB (due to the need to place
> > large bitmaps --sized a few words--in some slab pages if there are more
> > than BITS_PER_LONG objects in a slab) but in general does not increase space
> > use too much.
> >
> > The SLAB scheme of not touching the object during management is adopted.
> > The unified allocator can efficiently free and allocate cache cold objects
> > without causing cache misses.
> >
> > Some numbers using tcp_rr on localhost
> >
> >
> > Dell R910 128G RAM, 64 processors, 4 NUMA nodes
> >
> > threads unified A  A  A  A  slub A  A  A  A  A  A slab
> > 64 A  A  A 4141798 A  A  A  A  3729037 A  A  A  A  3884939
> > 128 A  A  4146587 A  A  A  A  3890993 A  A  A  A  4105276
> > 192 A  A  4003063 A  A  A  A  3876570 A  A  A  A  4110971
> > 256 A  A  3928857 A  A  A  A  3942806 A  A  A  A  4099249
> > 320 A  A  3922623 A  A  A  A  3969042 A  A  A  A  4093283
> > 384 A  A  3827603 A  A  A  A  4002833 A  A  A  A  4108420
> > 448 A  A  4140345 A  A  A  A  4027251 A  A  A  A  4118534
> > 512 A  A  4163741 A  A  A  A  4050130 A  A  A  A  4122644
> > 576 A  A  4175666 A  A  A  A  4099934 A  A  A  A  4149355
> > 640 A  A  4190332 A  A  A  A  4142570 A  A  A  A  4175618
> > 704 A  A  4198779 A  A  A  A  4173177 A  A  A  A  4193657
> > 768 A  A  4662216 A  A  A  A  4200462 A  A  A  A  4222686
> 
> Are there any stability problems left? Have you tried other benchmarks
> (e.g. hackbench, sysbench)? Can we merge the series in smaller
> batches? For example, if we leave out the NUMA parts in the first
> stage, do we expect to see performance regressions?
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
