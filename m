From: Christoph Lameter <clameter@sgi.com>
Message-Id: <20070331193056.1800.68058.sendpatchset@schroedinger.engr.sgi.com>
Subject: [SLUB 0/2] SLUB: The unqueued slab allocator V6
Date: Sat, 31 Mar 2007 12:30:56 -0700 (PDT)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@osdl.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Christoph Lameter <clameter@sgi.com>, mpm@selenic.com
List-ID: <linux-mm.kvack.org>

[PATCH] SLUB The unqueued slab allocator v6

Note that the definition of the return type of ksize() is currently
different between mm and Linus' tree. Patch is conforming to mm.
This patch also needs sprint_symbol() support from mm.

V5->V6:

- Straighten out various coding issues u.a. to make the hot path clearer
  in slab_alloc and slab_free. This adds more gotos. sigh.

- Detailed alloc / free tracking including pid, cpu, time of alloc / free
  if SLAB_STORE_USER is enabled or slub_debug=U specified on boot.

- sysfs support via /sys/slab. Drop /proc/slubinfo support.
  Include slabinfo tool that produces an output similar to what
  /proc/slabinfo does. Tool needs to be made more sophisticated
  to allow control of various slub options at runtime. Currently
  reports total slab sizes, slab fragmentation and slab effectiveness
  (actual object use vs. slab space use).

- Runtime debug option changes per slab via /sys/slab/<slabcache>.
  All slab debug options can be configured via sysfs provided that
  no objects have been allocated yet.

- Deal with i386 use of slab page structs. Main patch disables
  slub for i386 (CONFIG_ARCH_USES_SLAB_PAGE_STRUCT). Then a special
  patch removes the page sized slabs and removes that setting.
  See the caveats in that patch for further details.

V4->V5:

- Single object slabs only for slabs > slub_max_order otherwise generate
  sufficient objects to avoid frequent use of the page allocator. This is
  necessary to compensate for fragmentation caused by frequent uses of
  the page allocator. We expect slabs of PAGE_SIZE from this rule since
  multi object slabs require uses of fields that are in use on i386 and
  x86_64. See the quicklist patchset for a way to fix that issue
  and a patch to get rid of the PAGE_SIZE special casing.

- Drop pass through to page allocator due to page allocator fragmenting
  memory. The buffering through large order allocations is done in SLUB.
  Infrequent larger order allocations cause less fragmentation
  than frequent small order allocations.

- We need to update object sizes when merging slabs otherwise kzalloc
  will not initialize the full object (this caused the failure on
  various platforms).

- Padding checks before redzone checks so that we get messages about
  the corruption of whole slab and not about a single object.

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
   during boot. SLUB will then protocol all actions on that slabcache
   and dump the object contents on free.

K. On demand DMA cache creation.

   Generally DMA caches are not needed. If a kmalloc is used with
   __GFP_DMA then just create this single slabcache that is needed.
   For systems that have no ZONE_DMA requirement the support is
   completely eliminated.

L. Performance increase

   Some benchmarks have shown speed improvements on kernbench in the
   range of 5-10%. The locking overhead of slub is based on the
   underlying base allocation size. If we can reliably allocate
   larger order pages then it is possible to increase slub
   performance much further. The anti-fragmentation patches may
   enable further performance increases.

Tested on:
i386 UP + SMP, x86_64 UP + SMP + NUMA emulation, IA64 NUMA + Simulator

SLUB Boot options

slub_nomerge		Disable merging of slabs
slub_min_order=x	Require a minimum order for slab caches. This
			increases the managed chunk size and therefore
			reduces meta data and locking overhead.
slub_min_objects=x	Mininum objects per slab. Default is 8.
slub_max_order=x	Avoid generating slabs larger than order specified.
slub_debug		Enable all diagnostics for all caches
slub_debug=<options>	Enable selective options for all caches
slub_debug=<o>,<cache>	Enable selective options for a certain set of
			caches

Available Debug options
F		Double Free checking, sanity and resiliency
R		Red zoning
P		Object / padding poisoning
U		Track last free / alloc
T		Trace all allocs / frees (only use for individual slabs).

To use SLUB: Apply this patch and then select SLUB as the default slab
allocator.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
