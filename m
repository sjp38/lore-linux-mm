Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f45.google.com (mail-pb0-f45.google.com [209.85.160.45])
	by kanga.kvack.org (Postfix) with ESMTP id 0A1896B0031
	for <linux-mm@kvack.org>; Wed, 16 Oct 2013 04:44:15 -0400 (EDT)
Received: by mail-pb0-f45.google.com with SMTP id mc17so527468pbc.18
        for <linux-mm@kvack.org>; Wed, 16 Oct 2013 01:44:15 -0700 (PDT)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH v2 00/15] slab: overload struct slab over struct page to reduce memory usage
Date: Wed, 16 Oct 2013 17:43:57 +0900
Message-Id: <1381913052-23875-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <js1304@gmail.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Wanpeng Li <liwanp@linux.vnet.ibm.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

There is two main topics in this patchset. One is to reduce memory usage
and the other is to change a management method of free objects of a slab.

The SLAB allocate a struct slab for each slab. The size of this structure
except bufctl array is 40 bytes on 64 bits machine. We can reduce memory
waste and cache footprint if we overload struct slab over struct page.

And this patchset change a management method of free objects of a slab.
Current free objects management method of the slab is weird, because
it touch random position of the array of kmem_bufctl_t when we try to
get free object. See following example.
    
struct slab's free = 6 
kmem_bufctl_t array: 1 END 5 7 0 4 3 2 
    
To get free objects, we access this array with following index pattern.
6 -> 3 -> 7 -> 2 -> 5 -> 4 -> 0 -> 1 -> END
    
If we have many objects, this array would be larger and be not in the same
cache line. It is not good for performance.
    
We can do same thing through more easy way, like as the stack.
This patchset implement it and remove complex code for above algorithm.
This makes slab code much cleaner.

Below is some numbers of 'cat /proc/slabinfo'.

* Before *
# name            <active_objs> <num_objs> <objsize> <objperslab> <pagesperslab> : tunables [snip...]
kmalloc-512          527    600    512    8    1 : tunables   54   27    0 : slabdata     75     75      0
kmalloc-256          210    210    256   15    1 : tunables  120   60    0 : slabdata     14     14      0
kmalloc-192         1040   1040    192   20    1 : tunables  120   60    0 : slabdata     52     52      0
kmalloc-96           750    750    128   30    1 : tunables  120   60    0 : slabdata     25     25      0
kmalloc-64          2773   2773     64   59    1 : tunables  120   60    0 : slabdata     47     47      0
kmalloc-128          660    690    128   30    1 : tunables  120   60    0 : slabdata     23     23      0
kmalloc-32         11200  11200     32  112    1 : tunables  120   60    0 : slabdata    100    100      0
kmem_cache           197    200    192   20    1 : tunables  120   60    0 : slabdata     10     10      0

* After *
# name            <active_objs> <num_objs> <objsize> <objperslab> <pagesperslab> : tunables [snip...]
kmalloc-512          525    640    512    8    1 : tunables   54   27    0 : slabdata     80     80      0
kmalloc-256          210    210    256   15    1 : tunables  120   60    0 : slabdata     14     14      0
kmalloc-192         1016   1040    192   20    1 : tunables  120   60    0 : slabdata     52     52      0
kmalloc-96           560    620    128   31    1 : tunables  120   60    0 : slabdata     20     20      0
kmalloc-64          2148   2280     64   60    1 : tunables  120   60    0 : slabdata     38     38      0
kmalloc-128          647    682    128   31    1 : tunables  120   60    0 : slabdata     22     22      0
kmalloc-32         11360  11413     32  113    1 : tunables  120   60    0 : slabdata    101    101      0
kmem_cache           197    200    192   20    1 : tunables  120   60    0 : slabdata     10     10      0

kmem_caches consisting of objects less than or equal to 128 byte have one more
objects in a slab. You can see it at objperslab.


Here are the performance results on my 4 cpus machine.

* Before *

 Performance counter stats for 'perf bench sched messaging -g 50 -l 1000' (10 runs):

       238,309,671 cache-misses                                                  ( +-  0.40% )

      12.010172090 seconds time elapsed                                          ( +-  0.21% )

* After *

 Performance counter stats for 'perf bench sched messaging -g 50 -l 1000' (10 runs):

       229,945,138 cache-misses                                                  ( +-  0.23% )

      11.627897174 seconds time elapsed                                          ( +-  0.14% )

cache-misses are reduced by this patchset, roughly 5%.
And elapsed times are also improved by 3.1% to baseline.

I think that this patchsets deserve to be merged, since it reduces memory usage and
also improves performance. :)
Please let me know expert's opinion.

Thanks.

This patchset is based on v3.12-rc5.

Joonsoo Kim (15):
  slab: correct pfmemalloc check
  slab: change return type of kmem_getpages() to struct page
  slab: remove colouroff in struct slab
  slab: remove nodeid in struct slab
  slab: remove cachep in struct slab_rcu
  slab: overloading the RCU head over the LRU for RCU free
  slab: use well-defined macro, virt_to_slab()
  slab: use __GFP_COMP flag for allocating slab pages
  slab: change the management method of free objects of the slab
  slab: remove kmem_bufctl_t
  slab: remove SLAB_LIMIT
  slab: replace free and inuse in struct slab with newly introduced
    active
  slab: use struct page for slab management
  slab: remove useless statement for checking pfmemalloc
  slab: rename slab_bufctl to slab_freelist

 include/linux/mm_types.h |   24 +-
 include/linux/slab.h     |    9 +-
 include/linux/slab_def.h |    4 +-
 mm/slab.c                |  565 ++++++++++++++++++----------------------------
 4 files changed, 244 insertions(+), 358 deletions(-)

-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
