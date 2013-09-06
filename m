Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id D53106B0033
	for <linux-mm@kvack.org>; Fri,  6 Sep 2013 01:57:46 -0400 (EDT)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [REPOST PATCH 0/4] slab: implement byte sized indexes for the freelist of a slab
Date: Fri,  6 Sep 2013 14:57:43 +0900
Message-Id: <1378447067-19832-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <js1304@gmail.com>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

* THIS IS JUST REPOSTED ACCORDING TO MAINTAINER'S REQUEST *

* Changes from original post
Correct the position of the results.
Attach more results about cache-misses and elapsed time on a hackbench test.

-----------------------------------------------------
This patchset implements byte sized indexes for the freelist of a slab.

Currently, the freelist of a slab consist of unsigned int sized indexes.
Most of slabs have less number of objects than 256, so much space is wasted.
To reduce this overhead, this patchset implements byte sized indexes for
the freelist of a slab. With it, we can save 3 bytes for each objects.

This introduce one likely branch to functions used for setting/getting
objects to/from the freelist, but we may get more benefits from
this change.

Below is some numbers of 'cat /proc/slabinfo' related to my previous posting
and this patchset.


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

* After my previous posting(overload struct slab over struct page) *
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

We can improve further with this patchset.

* My previous posting + this patchset *
# name            <active_objs> <num_objs> <objsize> <objperslab> <pagesperslab> : tunables [snip...]
kmalloc-512          521    648    512    8    1 : tunables   54   27    0 : slabdata     81     81      0
kmalloc-256          208    208    256   16    1 : tunables  120   60    0 : slabdata     13     13      0
kmalloc-192         1029   1029    192   21    1 : tunables  120   60    0 : slabdata     49     49      0
kmalloc-96           529    589    128   31    1 : tunables  120   60    0 : slabdata     19     19      0
kmalloc-64          2142   2142     64   63    1 : tunables  120   60    0 : slabdata     34     34      0
kmalloc-128          660    682    128   31    1 : tunables  120   60    0 : slabdata     22     22      0
kmalloc-32         11716  11780     32  124    1 : tunables  120   60    0 : slabdata     95     95      0
kmem_cache           197    210    192   21    1 : tunables  120   60    0 : slabdata     10     10      0

kmem_caches consisting of objects less than or equal to 256 byte have
one or more objects than before. In the case of kmalloc-32, we have 11 more
objects, so 352 bytes (11 * 32) are saved and this is roughly 9% saving of
memory. Of couse, this percentage decreases as the number of objects
in a slab decreases.



Here are the performance results on my 4 cpus machine.

* Before *

 Performance counter stats for 'perf bench sched messaging -g 50 -l 1000' (10 runs):

       238,309,671 cache-misses                                                  ( +-  0.40% )

      12.010172090 seconds time elapsed                                          ( +-  0.21% )

* After my previous posting *

 Performance counter stats for 'perf bench sched messaging -g 50 -l 1000' (10 runs):

       229,945,138 cache-misses                                                  ( +-  0.23% )

      11.627897174 seconds time elapsed                                          ( +-  0.14% )

* My previous posting + this patchset *

 Performance counter stats for 'perf bench sched messaging -g 50 -l 1000' (10 runs):

       218,640,472 cache-misses                                                  ( +-  0.42% )

      11.504999837 seconds time elapsed                                          ( +-  0.21% )


cache-misses are reduced by each patchset, roughly 5% respectively.
And elapsed times are also improved by 3.1% and 4.2% to baseline, respectively.

I think that all patchsets deserve to be merged, since it reduces memory usage and
also improves performance. :)

Please let me know expert's opinions :)
Thanks.

This patchset comes from a Christoph's idea.
https://lkml.org/lkml/2013/8/23/315

Patches are on top of my previous posting.
https://lkml.org/lkml/2013/8/22/137

Joonsoo Kim (4):
  slab: factor out calculate nr objects in cache_estimate
  slab: introduce helper functions to get/set free object
  slab: introduce byte sized index for the freelist of a slab
  slab: make more slab management structure off the slab

 mm/slab.c |  138 +++++++++++++++++++++++++++++++++++++++++++++----------------
 1 file changed, 103 insertions(+), 35 deletions(-)

-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
