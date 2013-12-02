Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f45.google.com (mail-pb0-f45.google.com [209.85.160.45])
	by kanga.kvack.org (Postfix) with ESMTP id 4A27A6B0031
	for <linux-mm@kvack.org>; Mon,  2 Dec 2013 03:47:26 -0500 (EST)
Received: by mail-pb0-f45.google.com with SMTP id rp16so18379532pbb.4
        for <linux-mm@kvack.org>; Mon, 02 Dec 2013 00:47:25 -0800 (PST)
Received: from LGEMRELSE6Q.lge.com (LGEMRELSE6Q.lge.com. [156.147.1.121])
        by mx.google.com with ESMTP id d5si19553623pac.57.2013.12.02.00.47.23
        for <linux-mm@kvack.org>;
        Mon, 02 Dec 2013 00:47:24 -0800 (PST)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH v3 0/5] slab: implement byte sized indexes for the freelist of a slab
Date: Mon,  2 Dec 2013 17:49:38 +0900
Message-Id: <1385974183-31423-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@kernel.org>
Cc: Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Wanpeng Li <liwanp@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <js1304@gmail.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

This patchset implements byte sized indexes for the freelist of a slab.

Currently, the freelist of a slab consist of unsigned int sized indexes.
Most of slabs have less number of objects than 256, so much space is wasted.
To reduce this overhead, this patchset implements byte sized indexes for
the freelist of a slab. With it, we can save 3 bytes for each objects.

Below is some numbers of 'cat /proc/slabinfo'.

* Before *
kmalloc-512          525    640    512    8    1 : tunables   54   27    0 : slabdata     80     80      0
kmalloc-256          210    210    256   15    1 : tunables  120   60    0 : slabdata     14     14      0
kmalloc-192         1016   1040    192   20    1 : tunables  120   60    0 : slabdata     52     52      0
kmalloc-96           560    620    128   31    1 : tunables  120   60    0 : slabdata     20     20      0
kmalloc-64          2148   2280     64   60    1 : tunables  120   60    0 : slabdata     38     38      0
kmalloc-128          647    682    128   31    1 : tunables  120   60    0 : slabdata     22     22      0
kmalloc-32         11360  11413     32  113    1 : tunables  120   60    0 : slabdata    101    101      0
kmem_cache           197    200    192   20    1 : tunables  120   60    0 : slabdata     10     10      0

* After *
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

       229,945,138 cache-misses                                                  ( +-  0.23% )

      11.627897174 seconds time elapsed                                          ( +-  0.14% )

* After *

 Performance counter stats for 'perf bench sched messaging -g 50 -l 1000' (10 runs):

       218,640,472 cache-misses                                                  ( +-  0.42% )

      11.504999837 seconds time elapsed                                          ( +-  0.21% )

cache-misses are reduced by this patchset, roughly 5%.
And elapsed times are improved by 1%.

This patchset comes from a Christoph's idea.
https://lkml.org/lkml/2013/8/23/315

Patches are on top of v3.13-rc1.

Thanks.

Joonsoo Kim (5):
  slab: factor out calculate nr objects in cache_estimate
  slab: introduce helper functions to get/set free object
  slab: restrict the number of objects in a slab
  slab: introduce byte sized index for the freelist of a slab
  slab: make more slab management structure off the slab

 include/linux/slab.h |   11 ++++++
 mm/slab.c            |   97 +++++++++++++++++++++++++++++++++-----------------
 2 files changed, 76 insertions(+), 32 deletions(-)

-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
