Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx114.postini.com [74.125.245.114])
	by kanga.kvack.org (Postfix) with SMTP id 094B06B0069
	for <linux-mm@kvack.org>; Fri, 17 Aug 2012 16:59:38 -0400 (EDT)
Message-Id: <000001393662553e-a046af11-99f9-41f2-8549-01c1417a5379-000000@email.amazonses.com>
Date: Fri, 17 Aug 2012 20:59:37 +0000
From: Christoph Lameter <cl@linux.com>
Subject: C12 [00/19] Sl[auo]b: Common code rework V12
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Joonsoo Kim <js1304@gmail.com>, Glauber Costa <glommer@parallels.com>, linux-mm@kvack.org, David Rientjes <rientjes@google.com>

V11->V12
- Rediff against current slab/next from Pekka
- Drop the label renaming patch
- Also available via git at git://gentwo.org/christoph common

V10->V11
- Fix issues pointed out by Joonsoo and Glauber
- Simplify Slab bootstrap further

V9->V10
- Memory leak was a false alarm
- Resequence patches to make it easier
  to apply.
- Do more boot sequence consolidation in slab/slub.
  [We could still do much more like common kmalloc
  handling]
- Fixes suggested by David and Glauber

V8->V9:
- Fix numerous things pointed out by Glauber.
- Cleanup the way error handling works in the
  common kmem_cache_create() function.
- General cleanup by breaking things up
  into multiple patches were necessary.

V7->V8:
- Do not use kfree for kmem_cache in slub.
- Add more patches up to a common
  scheme for object alignment.

V6->V7:
- Omit pieces that were merged for 3.6
- Fix issues pointed out by Glauber.
- Include the patches up to the point at which
  the slab name handling is unified

V5->V6:
- Patches against Pekka's for-next tree.
- Go slow and cut down to just patches that are safe
  (there will likely be some churn already due to the
  mutex unification between slabs)
- More to come next week when I have more time (
  took me almost the whole week to catch up after
  being gone for awhile).

V4->V5
- Rediff against current upstream + Pekka's cleanup branch.

V3->V4:
- Do not use the COMMON macro anymore.
- Fixup various issues
- No general sysfs support yet due to lockdep issues with
  keys in kmalloc'ed memory.

V2->V3:
- Incorporate more feedback from Joonsoo Kim and Glauber Costa
- And a couple more patches to deal with slab duping and move
  more code to slab_common.c

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


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
