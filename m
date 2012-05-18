Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx104.postini.com [74.125.245.104])
	by kanga.kvack.org (Postfix) with SMTP id DF61A6B0082
	for <linux-mm@kvack.org>; Fri, 18 May 2012 12:19:28 -0400 (EDT)
Message-Id: <20120518161906.207356777@linux.com>
Date: Fri, 18 May 2012 11:19:06 -0500
From: Christoph Lameter <cl@linux.com>
Subject: [RFC] Common code 00/12] Sl[auo]b: Common functionality V2
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: linux-mm@kvack.org, David Rientjes <rientjes@google.com>, Matt Mackall <mpm@selenic.com>, Glauber Costa <glommer@parallels.com>, Joonsoo Kim <js1304@gmail.com>, Alex Shi <alex.shi@intel.com>

V1->V2:
- Incorporate glommers feedback.
- Add 2 more patches dealing with common code in kmem_cache_destroy

This is a series of patches that extracts common functionality from
slab allocators into a common code base. The intend is to standardize
as much as possible of the allocator behavior while keeping the
distinctive features of each allocator which are mostly due to their
storage format and serialization approaches.

This patchset makes a beginning by extracting common functionality in
kmem_cache_create() and kmem_cache_destroy(). However, there are
numerous other areas where such work could be beneficial:

1. Extract the sysfs support from SLUB and make it common. That way
   all allocators have a common sysfs API and are handleable in the same
   way regardless of the allocator chose.

2. Extract the error reporting and checking from SLUB and make
   it available for all allocators. This means that all allocators
   will gain the resiliency and error handling capabilties.

3. Extract the memory hotplug and cpu hotplug handling. It seems that
   SLAB may be more sophisticated here. Having common code here will
   make it easier to maintain the special code.

4. Extract the aliasing capability of SLUB. This will enable fast
   slab creation without creating too many additional slab caches.
   The arrays of caches of varying sizes in numerous subsystems
   do not cause the creation of numerous slab caches. Storage
   density is increased and the cache footprint is reduced.

Ultimately it is to be hoped that the special code for each allocator
shrinks to a mininum. This will also make it easier to make modification
to allocators.

In the far future one could envision that the current allocators will
just become storage algorithms that can be chosen based on the need of
the subsystem. F.e.

Cpu cache dependend performance		= Bonwick allocator (SLAB)
Minimal cycle count and cache footprint	= SLUB
Maximum storage density			= K&R allocator (SLOB)

But that could be controversial and inefficient if indirect calls are needed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
