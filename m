Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id C10496B006A
	for <linux-mm@kvack.org>; Tue,  5 Oct 2010 14:58:14 -0400 (EDT)
Message-Id: <20101005185725.088808842@linux.com>
Date: Tue, 05 Oct 2010 13:57:25 -0500
From: Christoph Lameter <cl@linux.com>
Subject: [UnifiedV4 00/16] The Unified slab allocator (V4)
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, David Rientjes <rientjes@google.com>
List-ID: <linux-mm.kvack.org>

V3->V4:
- Lots of debugging
- Performance optimizations (more would be good)...
- Drop per slab locking in favor of per node locking for
  partial lists (queuing implies freeing large amounts of objects
  to per node lists of slab).
- Implement object expiration via reclaim VM logic.

The following is a release of an allocator based on SLAB
and SLUB that integrates the best approaches from both allocators. The
per cpu queuing is like in SLAB whereas much of the infrastructure
comes from SLUB.

After this patches SLUB will track the cpu cache contents
like SLAB attemped to. There are a number of architectural differences:

1. SLUB accurately tracks cpu caches instead of assuming that there
   is only a single cpu cache per node or system.

2. SLUB object expiration is tied into the page reclaim logic. There
   is no periodic cache expiration.

3. SLUB caches are dynamically configurable via the sysfs filesystem.

4. There is no per slab page metadata structure to maintain (aside
   from the object bitmap that usually fits into the page struct).

5. Has all the resiliency and diagnostic features of SLUB.

The unified allocator is a merging of SLUB with some queuing concepts from
SLAB and a new way of managing objects in the slabs using bitmaps. Memory
wise this is slightly more inefficient than SLUB (due to the need to place
large bitmaps --sized a few words--in some slab pages if there are more
than BITS_PER_LONG objects in a slab) but in general does not increase space
use too much.

The SLAB scheme of not touching the object during management is adopted.
The unified allocator can efficiently free and allocate cache cold objects
without causing cache misses.

Some numbers using tcp_rr on localhost


Dell R910 128G RAM, 64 processors, 4 NUMA nodes

threads	unified		slub		slab
64	4141798		3729037		3884939
128	4146587		3890993		4105276
192	4003063		3876570		4110971
256	3928857		3942806		4099249
320	3922623		3969042		4093283
384	3827603		4002833		4108420
448	4140345		4027251		4118534
512	4163741		4050130		4122644
576	4175666		4099934		4149355
640	4190332		4142570		4175618
704	4198779		4173177		4193657
768	4662216		4200462		4222686


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
