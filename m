Message-Id: <20070504221555.642061626@sgi.com>
Date: Fri, 04 May 2007 15:15:55 -0700
From: clameter@sgi.com
Subject: [RFC 0/3] Slab Defrag / Slab Targeted Reclaim and general Slab API changes
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, dgc@sgi.com, Eric Dumazet <dada1@cosmosbay.com>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

I originally intended this for the 2.6.23 development cycle but since there
is an aggressive push for SLUB I thought that we may want to introduce this earlier.
Note that this covers new locking approaches that we may need to talk
over before going any further.

This is an RFC for patches that do major changes to the way that slab
allocations are handled in order to introduce some more advanced features
and in order to get rid of some things that are no longer used or awkward.

A. Add Slab fragmentation

On kmem_cache_shrink SLUB will not only sort the partial slabs by object
number but attempt to free objects out of partial slabs that have a low
number of objects. Doing so increases the object density in the remaining
partial slabs and frees up memory. Ideally kmem_cache_shrink would be
able to completely defrag the partial list so that only one partial
slab is left over. But it is advantageous to have slabs with a few free
objects since that speeds up kfree. Also going to the extreme on this one
would mean that the reclaimable slabs would have to be able to move objects
in a reliable way. So we just free objects in slabs with a low population ratio
and tolerate if a attempt to move an object fails.

B. Targeted Reclaim

Mainly to support antifragmentation / defragmentation methods. The slab adds
a new function kmem_cache_vacate(struct page *) which can be used to request
that a page be cleared of all objects. This makes it possible to reduce the
size of the RECLAIMABLE fragmentation area and move slabs into the MOVABLE
area enhancing the capabilities of antifragmentation significantly.

C. Introduces a slab_ops structure that allows a slab user to provide
   operations on slabs.

This replaces the current constructor / destructor scheme. It is necessary
in order to support additional methods needed to support targeted reclaim
and slab defragmentation. A slab supporting targeted reclaim and
slab defragmentation must support the following additional methods:

	1. get_reference(void *)
		Get a reference on a particular slab object.

	2. kick_object(void *)
		Kick an object off a slab. The object is either reclaimed
		(easiest) or a new object is alloced using kmem_cache_alloc()
		and then the object is moved to the new location.

D. Slab creation is no longer done using kmem_cache_create

kmem_cache_create is not a clean API since it has only 2 call backs for
constructor and destructor, does not allow the specification of a slab ops
structure. Parameters are confusing.

F.e. It is possible to specify alignment information in the alignment
field and in addition in the flags field (SLAB_HWCACHE_ALIGN). The semantics
of SLAB_HWCACHE_ALIGN are fuzzy because it only aligns object if
larger than 1/2 cache line.

All of this is really not necessary since the compiler knows how to align
structures and we should use this information instead of having the user
specify an alignment. I would like to get rid of SLAB_HWCACHE_ALIGN
and kmem_cache_create. Instead one would use the following macros (that
then result in a call to __kmem_cache_create).

	KMEM_CACHE(<struct-name>, flags)

The macro will determine the slab name from the struct name and use that for
/sys/slab, will use the size of the struct for slab size and the alignment
of the structure for alignment. This means one will be able to set slab
object alignment by specifying the usual alignment options for static
allocations when defining the structure.

Since the name is derived from the struct name it will much easier to
find the source code for slabs listed in /sys/slab.

An additional macro is provided if the slab also supports slab operations.

	KMEM_CACHE_OPS(<struct-name>, flags, slab_ops)

It is likely that this macro will be rarely used.

E. kmem_cache_create() SLAB_HWCACHE_ALIGN legacy interface

In order to avoid having to modify all slab creation calls throughout
the kernel we will provide a kmem_cache_create emulation. That function
is the only call that will still understand SLAB_HWCACHE_ALIGN. If that
parameter is specified then it will set up the proper alignment (the slab
allocators never see that flag).

If constructor or destructor are specified then we will allocate a slab_ops
structure and populate it with the values specified. Note that this will
cause a memory leak if the slab is disposed of later. If you need disposable
slabs then the new API must be used.

F. Remove destructor support from all slab allocators?

I am only aware of two call sites left after all the changes that are
scheduled to go into 2.6.22-rc1 have been merged. These are in FRV and sh
arch code. The one in FRV will go away if they switch to quicklists like
i386. Sh contains another use but a single user is no justification for keeping
destructors around.



-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
