Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx143.postini.com [74.125.245.143])
	by kanga.kvack.org (Postfix) with SMTP id E66326B006C
	for <linux-mm@kvack.org>; Thu,  1 Nov 2012 08:08:10 -0400 (EDT)
From: Glauber Costa <glommer@parallels.com>
Subject: [PATCH v6 00/29] kmem controller for memcg.
Date: Thu,  1 Nov 2012 16:07:16 +0400
Message-Id: <1351771665-11076-1-git-send-email-glommer@parallels.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, kamezawa.hiroyu@jp.fujitsu.com, Johannes Weiner <hannes@cmpxchg.org>, Tejun Heo <tj@kernel.org>, Michal Hocko <mhocko@suse.cz>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>

Hi,

This work introduces the kernel memory controller for memcg. Unlike previous
submissions, this includes the whole controller, comprised of slab and stack
memory.

Slab-specific considerations: I've modified the kmem_cache_free() mechanism
so we would have the code in a single location. It is then inlined into all
interested instances of kmem_cache_free. Following this logic, there is little
to be simplified in kmalloc/kmem_cache_alloc, which already does only exactly
this. The attribute propagation code was kept, since integrating it would still
depend on quite some infrastructure.



*v6	- joint submission slab + stack.
        - fixed race conditions with cache destruction.
        - unified code for kmem_cache_free cache derivation in mm/slab.h.
        - changed memcg_css_id to memcg_cache_id, now not equal to css_id.
        - remove extra memcg_kmem_get_cache in the kmalloc path.
        - fixed a bug with slab that would occur with some invocations of
          kmem_cache_free
        - use post_create() for memcg kmem_accounted_flag propagation.

*v5:    - changed charged order, kmem charged first.
        - minor nits and comments merged.

*v4:    - kmem_accounted can no longer become unlimited
        - kmem_accounted can no longer become limited, if group has children.
        - documentation moved to this patchset
        - more style changes
        - css_get in charge path to ensure task won't move during charge
*v3:
	- Changed function names to match memcg's
	- avoid doing get/put in charge/uncharge path
	- revert back to keeping the account enabled after it is first activated

Numbers can be found at https://lkml.org/lkml/2012/9/13/239

A (throwaway) git tree with them is placed at:

	git://git.kernel.org/pub/scm/linux/kernel/git/glommer/memcg.git kmemcg-slab


The kernel memory limitation mechanism for memcg concerns itself with
disallowing potentially non-reclaimable allocations to happen in exaggerate
quantities by a particular set of tasks (cgroup). Those allocations could
create pressure that affects the behavior of a different and unrelated set of
tasks.

Its basic working mechanism consists in annotating interesting allocations with
the _GFP_KMEMCG flag. When this flag is set, the current task allocating will
have its memcg identified and charged against. When reaching a specific limit,
further allocations will be denied.

As of this work, pages allocated on behalf of the slab allocator, and stack
memory are tracked. Other kinds of memory, like spurious calls to
__get_free_pages, vmalloc, page tables, etc are not tracked. Besides the memcg
cost that may be present with those allocations - that other allocations may
rightfully want to avoid - memory need to be somehow traceable back to a task
in order to be accounted by memcg. This may be trivial - as in the stack - or a
bit complicated, requiring extra work to be done - as in the case of the slab.
IOW, which memory to track is always a complexity tradeoff. We believe stack +
slab provides enough coverage of the relevant kernel memory most of the time.

Tracking accuracy depends on how well we can track memory back to a specific
task. Memory allocated for the stack is always accurately tracked, since stack
memory trivially belongs to a task and is never shared. For the slab, the
accuracy depends on the amount of object-sharing existing between tasks in
different cgroups (like memcg does for shmem, the kernel memory controller
operates in a first-touch basis). Workloads, such as OS containers, usually
have a very low amount of sharing, and will therefore present high accuracy.

One example of problematic pressure that can be prevented by this work is
a fork bomb conducted in a shell. We prevent it by noting that tasks use a
limited amount of stack pages. Seen this way, a fork bomb is just a special
case of resource abuse. If the offender is unable to grab more pages for the
stack, no new tasks can be created.

There are also other things the general mechanism protects against. For
example, using too much of pinned dentry and inode cache, by touching files an
leaving them in memory forever.

In fact, a simple:

while true; do mkdir x; cd x; done

can halt your system easily because the file system limits are hard to reach
(big disks), but the kernel memory is not. Those are examples, but the list
certainly don't stop here.

An important use case for all that, is concerned with people offering hosting
services through containers. In a physical box we can put a limit to some
resources, like total number of processes or threads. But in an environment
where each independent user gets its own piece of the machine, we don't want a
potentially malicious user to destroy good users' services.

This might be true for systemd as well, that now groups services inside
cgroups. They generally want to put forward a set of guarantees that limits the
running service in a variety of ways, so that if they become badly behaved,
they won't interfere with the rest of the system.

There is, of course, a cost for that. To attempt to mitigate that, static
branches are used. This code will only be enabled after the first user of this
service configures any kmem limit, guaranteeing near-zero overhead even if a
large number of (non-kmem limited) memcgs are deployed.

Behavior depends on the values of memory.limit_in_bytes (U), and
memory.kmem.limit_in_bytes (K):

    U != 0, K = unlimited:
    This is the standard memcg limitation mechanism already present before kmem
    accounting. Kernel memory is completely ignored.

    U != 0, K < U:
    Kernel memory is a subset of the user memory. This setup is useful in
    deployments where the total amount of memory per-cgroup is overcommited.
    Overcommiting kernel memory limits is definitely not recommended, since the
    box can still run out of non-reclaimable memory.
    In this case, the admin could set up K so that the sum of all groups is
    never greater than the total memory, and freely set U at the cost of his
    QoS.

    U != 0, K >= U:
    Since kmem charges will also be fed to the user counter and reclaim will be
    triggered for the cgroup for both kinds of memory. This setup gives the
    admin a unified view of memory, and it is also useful for people who just
    want to track kernel memory usage.


Glauber Costa (27):
  memcg: change defines to an enum
  kmem accounting basic infrastructure
  Add a __GFP_KMEMCG flag
  memcg: kmem controller infrastructure
  mm: Allocate kernel pages to the right memcg
  res_counter: return amount of charges after res_counter_uncharge
  memcg: kmem accounting lifecycle management
  memcg: use static branches when code not in use
  memcg: allow a memcg with kmem charges to be destructed.
  execute the whole memcg freeing in free_worker
  protect architectures where THREAD_SIZE >= PAGE_SIZE against fork
    bombs
  Add documentation about the kmem controller
  slab/slub: struct memcg_params
  slab: annotate on-slab caches nodelist locks
  consider a memcg parameter in kmem_create_cache
  Allocate memory for memcg caches whenever a new memcg appears
  memcg: infrastructure to match an allocation to the right cache
  memcg: skip memcg kmem allocations in specified code regions
  sl[au]b: always get the cache from its page in kmem_cache_free
  sl[au]b: Allocate objects from memcg cache
  memcg: destroy memcg caches
  memcg/sl[au]b Track all the memcg children of a kmem_cache.
  memcg/sl[au]b: shrink dead caches
  Aggregate memcg cache values in slabinfo
  slab: propagate tunables values
  slub: slub-specific propagation changes.
  Add slab-specific documentation about the kmem controller

Suleiman Souhlal (2):
  memcg: Make it possible to use the stock for more than one page.
  memcg: Reclaim when more than one page needed.

 Documentation/cgroups/memory.txt           |   66 +-
 Documentation/cgroups/resource_counter.txt |    7 +-
 include/linux/gfp.h                        |    6 +-
 include/linux/memcontrol.h                 |  203 ++++
 include/linux/res_counter.h                |   12 +-
 include/linux/sched.h                      |    1 +
 include/linux/slab.h                       |   48 +
 include/linux/slab_def.h                   |    3 +
 include/linux/slub_def.h                   |    9 +-
 include/linux/thread_info.h                |    2 +
 include/trace/events/gfpflags.h            |    1 +
 init/Kconfig                               |    2 +-
 kernel/fork.c                              |    4 +-
 kernel/res_counter.c                       |   20 +-
 mm/memcontrol.c                            | 1562 ++++++++++++++++++++++++----
 mm/page_alloc.c                            |   35 +
 mm/slab.c                                  |   93 +-
 mm/slab.h                                  |  137 ++-
 mm/slab_common.c                           |  118 ++-
 mm/slob.c                                  |    2 +-
 mm/slub.c                                  |  124 ++-
 21 files changed, 2171 insertions(+), 284 deletions(-)

-- 
1.7.11.7

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
