Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id B96F16B0266
	for <linux-mm@kvack.org>; Thu, 24 May 2018 07:00:25 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id z69-v6so1042872wrb.20
        for <linux-mm@kvack.org>; Thu, 24 May 2018 04:00:25 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id z102-v6si2245844ede.440.2018.05.24.04.00.23
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 24 May 2018 04:00:24 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [RFC PATCH 0/5] kmalloc-reclaimable caches
Date: Thu, 24 May 2018 13:00:06 +0200
Message-Id: <20180524110011.1940-1-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Roman Gushchin <guro@fb.com>, Michal Hocko <mhocko@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, linux-api@vger.kernel.org, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Mel Gorman <mgorman@techsingularity.net>, Vijayanand Jitta <vjitta@codeaurora.org>, Vlastimil Babka <vbabka@suse.cz>

Hi,

as discussed at LSF/MM [1] here's a RFC patchset that introduces
kmalloc-reclaimable caches (more details in the first patch) and uses them
for SLAB freelists and dcache external names. The latter allows us to
repurpose the NR_INDIRECTLY_RECLAIMABLE_BYTES counter later in the series.

This is how /proc/slabinfo looks like after booting in virtme:

...
kmalloc-reclaimable-4194304      0      0 4194304    1 1024 : tunables    1    1    0 : slabdata      0      0      0
...
kmalloc-reclaimable-96     17     64    128   32    1 : tunables  120   60    8 : slabdata      2      2      0
kmalloc-reclaimable-64     50    128     64   64    1 : tunables  120   60    8 : slabdata      2      2      6
kmalloc-reclaimable-32      0      0     32  124    1 : tunables  120   60    8 : slabdata      0      0      0
kmalloc-4194304        0      0 4194304    1 1024 : tunables    1    1    0 : slabdata      0      0      0
...
kmalloc-64          2888   2944     64   64    1 : tunables  120   60    8 : slabdata     46     46    454
kmalloc-32          4325   4712     32  124    1 : tunables  120   60    8 : slabdata     38     38    563
kmalloc-128         1178   1216    128   32    1 : tunables  120   60    8 : slabdata     38     38    114
...

/proc/vmstat with new/renamed nr_reclaimable counter (patch 4):

...
nr_slab_reclaimable 2817
nr_slab_unreclaimable 1781
...
nr_reclaimable 2817
...

/proc/meminfo with exposed nr_reclaimable counter (patch 5):

...
AnonPages:          8624 kB
Mapped:             3340 kB
Shmem:               564 kB
Reclaimable:       11272 kB
Slab:              18368 kB
SReclaimable:      11272 kB
SUnreclaim:         7096 kB
KernelStack:        1168 kB
PageTables:          448 kB
...

Now for the issues a.k.a. why RFC:

- I haven't find any other obvious users for reclaimable kmalloc (yet)
- the name of caches kmalloc-reclaimable-X is rather long
- the vmstat/meminfo counter name is rather general and might suggest it also
  includes reclaimable page caches, which it doesn't

Suggestions welcome for all three points. For the last one, we might also keep
the counter separate from nr_slab_reclaimable, not superset. I did a superset
as IIRC somebody suggested that in the older threads or at LSF.

Thanks,
Vlastimil


[1] https://lwn.net/Articles/753154/

Vlastimil Babka (5):
  mm, slab/slub: introduce kmalloc-reclaimable caches
  mm, slab: allocate off-slab freelists as reclaimable when appropriate
  dcache: allocate external names from reclaimable kmalloc caches
  mm: rename and change semantics of nr_indirectly_reclaimable_bytes
  mm, proc: add NR_RECLAIMABLE to /proc/meminfo

 drivers/base/node.c                         |  2 +
 drivers/staging/android/ion/ion_page_pool.c |  4 +-
 fs/dcache.c                                 | 40 ++++-----------
 fs/proc/meminfo.c                           |  3 +-
 include/linux/mmzone.h                      |  2 +-
 include/linux/slab.h                        | 17 +++++--
 mm/page_alloc.c                             | 15 ++----
 mm/slab.c                                   | 23 ++++++---
 mm/slab_common.c                            | 56 ++++++++++++++-------
 mm/slub.c                                   | 12 ++---
 mm/util.c                                   | 16 ++----
 mm/vmstat.c                                 |  6 +--
 12 files changed, 99 insertions(+), 97 deletions(-)

-- 
2.17.0
