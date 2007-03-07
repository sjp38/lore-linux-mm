From: Christoph Lameter <clameter@sgi.com>
Message-Id: <20070307023502.19658.39217.sendpatchset@schroedinger.engr.sgi.com>
Subject: [SLUB 0/3] SLUB: The unqueued slab allocator V4
Date: Tue,  6 Mar 2007 18:35:02 -0800 (PST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: Marcelo Tosatti <marcelo@kvack.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Christoph Lameter <clameter@sgi.com>, mpm@selenic.com, Manfred Spraul <manfred@colorfullife.com>
List-ID: <linux-mm.kvack.org>

[PATCH] SLUB The unqueued slab allocator v4

V3->V4
- Rename /proc/slabinfo to /proc/slubinfo. We have a different format after
  all.
- More bug fixes and stabilization of diagnostic functions. This seems
  to be finally something that works wherever we test it.
- Serialize kmem_cache_create and kmem_cache_destroy via slub_lock (Adrian's
  idea)
- Add two new modifications (separate patches) to guarantee
  a mininum number of objects per slab and to pass through large
  allocations.

Note that SLUB will warn on zero sized allocations. SLAB just allocates
some memory. So some traces from the usb subsystem etc should be expected.
There are very likely also issues remaining in SLUB.

V2->V3
- Debugging and diagnostic support. This is runtime enabled and not compile
  time enabled. Runtime debugging can be controlled via kernel boot options
  on an individual slab cache basis or globally.
- Slab Trace support (For individual slab caches).
- Resiliency support: If basic sanity checks are enabled (via F f.e.)
  (boot option) then SLUB will do the best to perform diagnostics and
  then continue (i.e. mark corrupted objects as used).
- Fix up numerous issues including clash of SLUBs use of page
  flags with i386 arch use for pmd and pgds (which are managed
  as slab caches, sigh).
- Dynamic per CPU array sizing.
- Explain SLUB slabcache flags

V1->V2
- Fix up various issues. Tested on i386 UP, X86_64 SMP, ia64 NUMA.
- Provide NUMA support by splitting partial lists per node.
- Better Slab cache merge support (now at around 50% of slabs)
- List slab cache aliases if slab caches are merged.
- Updated descriptions /proc/slabinfo output

This is a new slab allocator which was motivated by the complexity of the
existing code in mm/slab.c. It attempts to address a variety of concerns
with the existing implementation.

A. Management of object queues

   A particular concern was the complex management of the numerous object
   queues in SLAB. SLUB has no such queues. Instead we dedicate a slab for
   each allocating CPU and use objects from a slab directly instead of
   queueing them up.

B. Storage overhead of object queues

   SLAB Object queues exist per node, per CPU. The alien cache queue even
   has a queue array that contain a queue for each processor on each
   node. For very large systems the number of queues and the number of
   objects that may be caught in those queues grows exponentially. On our
   systems with 1k nodes / processors we have several gigabytes just tied up
   for storing references to objects for those queues  This does not include
   the objects that could be on those queues. One fears that the whole
   memory of the machine could one day be consumed by those queues.

C. SLAB meta data overhead

   SLAB has overhead at the beginning of each slab. This means that data
   cannot be naturally aligned at the beginning of a slab block. SLUB keeps
   all meta data in the corresponding page_struct. Objects can be naturally
   aligned in the slab. F.e. a 128 byte object will be aligned at 128 byte
   boundaries and can fit tightly into a 4k page with no bytes left over.
   SLAB cannot do this.

D. SLAB has a complex cache reaper

   SLUB does not need a cache reaper for UP systems. On SMP systems
   the per CPU slab may be pushed back into partial list but that
   operation is simple and does not require an iteration over a list
   of objects. SLAB expires per CPU, shared and alien object queues
   during cache reaping which may cause strange hold offs.

E. SLAB has complex NUMA policy layer support

   SLUB pushes NUMA policy handling into the page allocator. This means that
   allocation is coarser (SLUB does interleave on a page level) but that
   situation was also present before 2.6.13. SLABs application of
   policies to individual slab objects allocated in SLAB is
   certainly a performance concern due to the frequent references to
   memory policies which may lead a sequence of objects to come from
   one node after another. SLUB will get a slab full of objects
   from one node and then will switch to the next.

F. Reduction of the size of partial slab lists

   SLAB has per node partial lists. This means that over time a large
   number of partial slabs may accumulate on those lists. These can
   only be reused if allocator occur on specific nodes. SLUB has a global
   pool of partial slabs and will consume slabs from that pool to
   decrease fragmentation.

G. Tunables

   SLAB has sophisticated tuning abilities for each slab cache. One can
   manipulate the queue sizes in detail. However, filling the queues still
   requires the uses of the spin lock to check out slabs. SLUB has a global
   parameter (min_slab_order) for tuning. Increasing the minimum slab
   order can decrease the locking overhead. The bigger the slab order the
   less motions of pages between per CPU and partial lists occur and the
   better SLUB will be scaling.

G. Slab merging

   We often have slab caches with similar parameters. SLUB detects those
   on boot up and merges them into the corresponding general caches. This
   leads to more effective memory use. About 50% of all caches can
   be eliminated through slab merging. This will also decrease
   slab fragmentation because partial allocated slabs can be filled
   up again. Slab merging can be switched off by specifying
   slub_nomerge on boot up.

   Note that merging can expose heretofore unknown bugs in the kernel
   because corrupted objects may now be placed differently and corrupt
   differing neighboring objects. Enable sanity checks to find those.

H. Diagnostics

   The current slab diagnostics are difficult to use and require a
   recompilation of the kernel. SLUB contains debugging code that
   is always available (but is kept out of the hot code paths).
   SLUB diagnostics can be enabled via the "slab_debug" option.
   Parameters can be specified to select a single or a group of
   slab caches for diagnostics. This means that the system is running
   with the usual performance and it is much more likely that
   race conditions can be reproduced.

I. Resiliency

   If basic sanity checks are on then SLUB is capable of detecting
   common error conditions and recover as best as possible to allow the
   system to continue.

J. Tracing

   Tracing can be enabled via the slab_debug=T,<slabcache> option
   during boot. SLUB will then protocol each action on that slabcache
   and dump the object contents on free.

K. On demand DMA cache creation.

   Generally DMA caches are not needed. If a kmalloc is used with
   __GFP_DMA then just create this single slabcache that is needed.
   For systems that have no ZONE_DMA requirement the support is
   completely eliminated.

Tested on:
i386 SMP, x86_64 UP + SMP + NUMA emulation, IA64 NUMA + Simulator

SLUB Boot options

slub_nomerge		Disable merging of slabs
slub_min_order=x	Require a minimum order for slab caches. This
			increases the managed chunk size and therefore
			reduces meta data and locking overhead.
slub_debug		Enable all diagnostics for all caches
slub_debug=<options>	Enable selective options for all caches
slub_debug=<o>,<cache>	Enable selective options for a certain set of
			caches
slub_min_objects	Mininum objects per slab. Default is 8.

Available Debug options
F		Double Free checking, sanity and resiliency
R		Red zoning
P		Object / padding poisoning
U		Track last free / alloc
T		Trace all allocs / frees (only use on individual slabs).

To use SLUB: Apply this patch and then select SLUB as the default slab
allocator. The output of /proc/slabinfo will then change. Here is a
sample (this is an UP/SMP format. The NUMA display will show on which nodes
the slabs were allocated). Flags are

a	Cpucache Align requested
A	Hardware Align required
C	Constructor
d	DMA cache
D	Destructor
F	Double free checking/Sanity
p	Panic on failure
P	Poisoning
r	Objects are reclaimable
R	RCU destroy
S	Memory Spreading
U	User Tracking
T	Tracing
Z	Red Zone


Thanks to Adrian Drzewiecki <z@drze.net> for many ideas and spotting many
bugs.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
