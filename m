From: Christoph Lameter <clameter@sgi.com>
Subject: [patch 00/10] SLUB: SMP regression tests on Dual Xeon E5345 (8p) and new performance patches
Date: Sat, 27 Oct 2007 20:31:56 -0700
Message-ID: <20071028033156.022983073@sgi.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756135AbXJ1DeL@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
To: Matthew Wilcox <matthew@wil.cx>
Cc: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>
List-Id: linux-mm.kvack.org

Recent reports from Intel indicated that there were regression on
SMP benchmarks vs. SLAB. This is a discussion of performance results
and some patches are attached to fix various issues.
The patches are also available via git pull from

git://git.kernel.org/pub/scm/linux/kernel/git/christoph/slab.git performance


SLAB and SLUB are fundamentally different architectures. SLAB batches multiple
objects on queues. The movement between queues is protected by a single lock
(at least in the SMP configuration). SLAB can move an arbitrary amount of
objects by taking the list_lock. Integration of objects into the slabs
is deferred as much as possible while objects circle on various slab
queues.

SLUB's design is to directly integrate or extract the objects from the
slabs without going through intermediate queues. Thus the overhead is
eliminated. SLUB has a lock in each slab allowing fine grained locking.
Centralized locks are rarely taken. SLUB cannot batch objects to
optimize lock use. Instead a whole slab is assigned to a processor.
Allocations and frees can then occur from the CPU slab without taking
the slab lock. However, that is limited to the number of objects that
fit into a slab in contrast to SLAB which can extract objects from
multiple slabs and put them on a per CPU queue.

If SLUB is freeing an objects then the per CPU slab can only be used if the
object is part of the CPU slab. This is usually the case for short lived
allocations. Long lived allocations and objects allocated on other CPUs
will need to use the slow path where the slab_lock must be taken to
synchronize the free. This makes the slab_free() path particularly
problematic in SMP contexts.

Optimization in SLUB is therefore mainly optimization of locking
and of the execution code paths. The following patches optimize
locking further by using a cmpxchg_local in the fast path and
by avoiding stores to page struct fields etc to address regressions
that we see under SMP.

Another fundamental distinction between SLAB and SLUB is that SLAB
was designed with SMP in mind. NUMA was a later add-on that added
a significant complexity. SLUB was written for NUMA. NUMA support is
native. The same slab_free() path that is problematic under SMP is
effectively dealing with the alien cache problem that SLAB has under NUMA
and is increasing performance of remote free operations significantly.
The cpu_slab concept makes the determination of NUMA locality of objects
simpler since we can match on the page that an object belongs to and move
the whole page of objects in a NUMA aware fashion instead of the individual
objects in the queues of SLAB.

The fine grained locking is also important for SMP system with a large number
of processors. SLAB can put lots of objects on its queues. However, current
processors can take a large number of objects off the queues in a short
time period. As a result we see significant lock contention using SLAB during
parallel operations on the 8p SMP machine that is investigated here. SLAB has
less problems scaling on NUMA with a more limited number of processors per node
because SLAB will then use node based locks instead of global locks.

Tests were run with 4 different kernels:

SLAB = 2.6.24-rc1 configured to run SLAB
SLUB = 2.6.24-rc1 configured to run SLUB
SLUB+ = 2.6.24-rc1 patched with the following patches.
SLUB-o = SLUB+ booted with slub_max_order=3 slub_min_objects=20

The SLAB tests result in the baseline to work against. SLUB is the
current state of 2.6.24. SLUB+ is an version of SLUB that was optimized
to run on the 8p SMP box after observing some of the performance issues.
SLUB-o is useful to see what effect the use of higher order pages has
on performance.

All tests are done by running 10000 operations on each processor. The time
needed is measured using TSC times tamps.

All measurements are in cycle counts. The higher the cycle count the more
time the allocator needs to perform an operation. The lower the count the
better the performance of the allocator.

Test A: Single threaded kmalloc
===============================

A single cpu is running and is allocating 10000 objects of various
sizes.

	SLAB	SLUB	SLUB+	SLUB-o
   8	96	86	45	44	2 *
  16	84	92	49	48	++++
  32	84	106	61	59	+++
  64	102	129	82	88	++
 128	147	226	188	181	--
 256	200	248	207	285	-
 512	300	301	260	209	++
1024	416	440	398	264	++
2048	720	542	530	390	+++
4096	1254	342	342	336	3 *

SLUB passes 4k allocations directly through to the page allocator which
is more efficient at handling page sized allocations than SLABs handling
of them. 4k (or page sized) allocations will be special throughout these
tests.

We see a performance degradation vs. SLAB in the middle range that
is reduced by the patch set.

The cmpxchg_local operation used in SLUB+ effectively cuts the cycles
spend on the fast path in half. However, SLUB has to use its slow path
more frequently than SLAB. So the advantage gradually disappears at 128
bytes. The frequency of slow path use increases for SLAB when we go
to higher sizes since SLAB reduces the size of the objects queues for
larger sizes. SLUB's slow path is more effective and so there is a slight
win starting at 512 bytes size.

Allowing a larger allocation order in SLUB-o only has a beneficial effect
above 512 bytes but there it gives SLUB a significant advantage.

Test B: Single threaded kfree
=============================

A single cpu is freeing the objects allocated during test A.

	SLAB	SLUB	SLUB+	SLUB-o
   8	129	170	128	127	=
  16	127	173	132	131	=
  32	127	177	135	136	-
  64	121	182	138	144	-
 128	134	195	154	156	--
 256	167	268	233	197	---
 512	329	408	375	273	=
1024	432	518	448	343	-
2048	622	596	525	395	++
4096	896	342	333	332	2 *

For smaller and larger sizes the performance is equal or better but
in the mid range from 32 bytes to 256 bytes we have regressions
that are only partially addressed by the code path optimizations
or the higher order allocs.

The problem for SLUB here is that the slab_free() fast path cannot be used.
10000 objects are way beyond what fits into a single page and thus we
always operate on the slow path. Adrian and I have tinkered around with
adding some queueing for freeing to SLUB but that would add SLAB concepts
to SLUB making it more complex.  Maybe we can avoid that.

Test C: Short lived object: Alloc and immediately free
======================================================

On a single cpu an object is allocated and then immediately freed.
This is mainly useful to show the fastest alloc/free sequence possible.
It shows how fast the fast path can get.

	SLAB	SLUB	SLUB+	SLUB-o
	137-146	151	68-72	68-74	2 *

The cycle counts vary only slightly for different sizes, so there is no
use in displaying the whole table. The numbers show that the SLUB fast path
is a tad slower than SLAB. However, the cmpxchg_local optimizations
cut the cycle count in half and at that point SLUB becomes twice as fast
as SLAB. So for relatively short lived objects that can be freed to the
cpu_slab SLUB will be twice as fast.

Test D: Concurrent kmalloc on 8 processors
==========================================

This test is running 10000 allocations concurrently on all processors to see
how lock contention influences the allocator speed.

	SLAB	SLUB	SLUB+	SLUB-o
   8	1177	101	66	64	> 10 *
  16	1038	117	92	85	> 10 *
  32	1049	151	116	131	9 *
  64	1680	220	211	200	7 *
 128	2964	360	365	363	7 *
 256	6228	791	786	1024	7 *
 512	12914	1100	1103	1122	> 10 *
1024	26309	1535	1509	1430	> 10 *
2048	52237	6372	6455	2349	7 *
4096	64661	11420	11678	11999	6 *

This shows the effect of SLUBs finer grained locking. SLAB list_lock
contention becomes a major factor on an 8p system. SLUB rarely takes
global locks and thus is always more than 6 times faster than SLAB.
One may be able to address this issue by increasing the SLAB queue
sizes for 8p systems. However, these queues are per cpu so the amount
of memory caught in queues grows with the increase in processor numbers.
The interrupt hold offs grow if the queue size is increased and the processing
cost in the cache reaper too (which cause lots of trouble for MPI jobs f.e.).

Test E: Short lived object: Concurrent alloc and free immediately
=================================================================

Basically the same test as test C but with concurrent allocations. This
verifies that the fast paths of the allocators are decoupled.

	SLAB	SLUB	SLUB+	SLUB-o
	136-149	151-153	68-72	69-72	2 *

Same results as before. cmpxchg_local doubles the speed of SLUB.


Test F: Remote free of 70000 objects from a single processor
============================================================

This is a test to simulate the problem that Intel saw. Objects are
allocated on 7 processors and then the 8th processor frees them all
All frees are remote and all objects are cache cold.

	SLAB	SLUB	SLUB+	SLUB-o
   8	1120	1309	1046	1047	+
  16	1118	1414	1157	1157	=
  32	1124	1615	1359	1359	-
  64	1619	2038	1732	1722	-
 128	1892	2451	2247	2251	--
 256	2144	2869	2658	2565	--
 512	3021	3329	3123	2751	-
1024	3698	3993	3786	2889	++
2048	5708	4469	4231	3413	++
4096	9188	5486	5524	5525	++++

Again some regressions for SLUB in the middle range.
The code path optimizations and the removal of atomic ops in
SLUB+ closes the gap for many sizes and makes SLUB+ in some
sizes superior to SLAB. This is likely effective in dealing
with the performance problem that Intel saw.

The higher order SLUB reduces the regression even more for 512
to 2048 bytes.

Further possible optimizations:
===============================

I would like to with the basic idea of SLUB and avoid adding queues.
I think on average one will find after these patches that the performance
of SLUB is at equal to SLAB even on SMP. SLAB has some issues with lock
contention for higher cpu counts. So SLUB will become better as
we add more CPUs.

There are a couple of additional optimizations that could be done without
having to resort to queueing objects:

1. Get an IA64 style per cpu area working on x86_64 that maps the per cpu area
   at the same address for each processor. If the per cpu structure is always
   at the same address on all processors then we can simply forget about
   disabling preemption in the fast path (the cmpxchg_local operates on whatever
   current cpu structure we are on) and can avoid to calculate the
   address of the per cpu structure in the fast path. This is likely
   to increase performance by another 30% (The method could also be used
   to optimize the page allocator BTW).

2. One could locklessly free objects into non cpu slabs using a cmpxchg
   thereby avoiding the interrupt disable / enable in the slow slab_free()
   path. There are problems with determining when to free a slab and how to
   deal with the races in relation to adding partial slabs to the lists.
   Got a draft here but I am not sure if its worth continuing to work on it.

3. Higher order allocs would be useful to increase speed in object size ranges
   from 512 - 2048. But the performance gains are likely offset to a bit by
   the slowness of the page allocator in providing higher order pages. Zone
   locks need to be taken and the higher order pages are extracted directly
   from the buddy lists. Optimizing the page allocator to serve higher order
   pages more effectively may increase SLUB performance.



NUMA tests:
-----------

The following tests may not be interesting. It verifies that the
patch set does not impact the already good NUMA performance of SLUB.

IA64 8p 4 node NUMA comparison
==============================

The test was performed on a NUMA system with 2p per node. So we have 4
nodes and 8p. In that case the density of CPUs per node is just 2. SLAB
manages structures per node. Only having 2 nodes per cpu cuts down on the
overhead of concurrent allocations. There is no global lock anymore like
under SMP. SLAB is now almost competitive with the concurrent allocations.

IA64 has a 16k page size and no fast cmpxchg_local. So we cannot use the
version of the SLUB fast path that avoids disabling interrupts. However, the
large page size means that lots of objects can be handled within a single
cpu slab. The test with higher order pages was omitted since the bas page
size is already large.

Test A: Single thread test kmalloc
==================================

	SLAB	SLUB	SLUB+
   8	121	70	84	+++
  16	98	91	87	+
  32	93	98	98	=
  64	94	111	110	-
 128	133	123	132	=
 256	144	156	156	-
 512	180	181	175	+
1024	348	263	263	++
2048	348	310	306	+
4096	490	322	328	++
8192	810	387	389	2 *
16384	1463	594	592	3 *

Small regressions between 64 and 256 byte object size. Overall SLUB is
faster and it was faster even without the performance improvements.

Test B: Single threaded kfree
=============================

	SLAB	SLUB	SLUB+
   8	173	115	103	+++
  16	172	111	94	+++
  32	172	116	100	+++
  64	172	119	103	+++
 128	175	123	106	+++
 256	187	178	141	++
 512	241	310	313	--
1024	221	382	374	--
2048	321	405	403	--
4096	398	407	413	-
8192	608	452	452	+++
16384	977	672	674	++++

The alien cache overhead hits SLAB for many sizes. Regressions
for 512-4096 byte sizes. The optimizations in the slab_free path
have helped somewhat to make SLUB faster.

Test C: Single threaded short lived object: Alloc/free
======================================================
	SLAB	SLUB	SLUB+
	114-142	104-115	101-113	+

The patch set has reduced the cycle count by a few cycles.

SLUB's alloc and free path is simply faster since the NUMA handling overhead
is less if the  handling is performed on a slab level (SLUB) and not on the
object level (SLAB).


Test D: Concurrent allocations on 8 CPUs
========================================

	SLAB	SLUB	SLUB+
   8	156	94	89	++++
  16	123	101	98	+++
  32	127	110	109	++
  64	133	129	127	=
 128	183	168	160	+
 256	229	212	217	+
 512	371	332	327	+
1024	530	555	560	-
2048	1059	1005	957	+
4096	3601	870	824	++++
8192	7123	1131	1084	7 *
16384	12836	1468	1439	9 *

Same picture as before: SLUB is way better for small and large objects.
Medium range is weak.

However, SLAB is scales much better when it has a lock for only 2
processors instead of 8.


Test E: Short lived objects: Alloc/free concurrently
====================================================

	SLAB	SLUB	SLUB+
	116-143	106-117	103-114	+

Same result as for single threaded operations.


Test F: Remote free of 70000 objects from a single processor
============================================================
The objects were allocated on 7 other CPUs.
All frees are remote.

	SLAB	SLUB	SLUB+
   8	3806	1435	1335	3 *
  16	3836	1713	1620	2 *
  32	3836	2298	2207	++++
  64	3825	3441	3373	+++
 128	5943	5713	5666	++
 256	5912	5676	5636	+
 512	6126	5403	5349	++
1024	6291	5300	5257	++
2048	6006	5559	5531	+
4096	6863	5703	5684	++
8192	8935	6031	6013	+++
16384	13208	8012	8013	++++

The alien cache handling hurts SLAB for remote frees. For remote
frees under NUMA SLUB is much better.

-- 
