Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9B0046B0253
	for <linux-mm@kvack.org>; Sat,  9 Jul 2016 04:35:20 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id p64so68133693pfb.0
        for <linux-mm@kvack.org>; Sat, 09 Jul 2016 01:35:20 -0700 (PDT)
Received: from mail-pa0-x244.google.com (mail-pa0-x244.google.com. [2607:f8b0:400e:c03::244])
        by mx.google.com with ESMTPS id q6si1911391pag.32.2016.07.09.01.35.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 09 Jul 2016 01:35:19 -0700 (PDT)
Received: by mail-pa0-x244.google.com with SMTP id ib6so9483478pad.3
        for <linux-mm@kvack.org>; Sat, 09 Jul 2016 01:35:19 -0700 (PDT)
Date: Sat, 9 Jul 2016 04:33:59 -0400
From: Janani Ravichandran <janani.rvchndrn@gmail.com>
Subject: [PATCH 0/3] Add names of shrinkers and have tracepoints display them
Message-ID: <cover.1468051277.git.janani.rvchndrn@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: riel@surriel.com, akpm@linux-foundation.org, hannes@cmpxchg.org, vdavydov@virtuozzo.com, mhocko@suse.com, vbabka@suse.cz, mgorman@techsingularity.net, kirill.shutemov@linux.intel.com, bywxiaobai@163.com

Hello,

I'm an Outreachy intern working under Rik van Riel. My project is about
latency tracing during memory allocation. The idea is to use 
tracepoints, both existing and new, to derive higher level information
on memory allocation and identify where time was spent.
This patchset which

1, adds a new field to struct shrinker to hold names of shrinkers,
2, updates the newly added field in instances of the struct,
3, changes tracepoint definitions to have the field displayed,

would be useful when one wants to observe which shrinkers
contributed to excessive latencies.

A post processing script like the one here-

https://github.com/Jananiravichandran/Analyzing-tracepoints/blob/master/shrink_slab_latencies.py ,

can use the new information this patchset adds to see which shrinkers
were invoked and how long each of them took.

Sample output:

i915_gem_shrinker : 0.166 ms
ext4_es_shrinker : 0.954 ms
workingset_shadow_shrinker : 1.091 ms
deferred_split_shrinker : 6.043 ms
super_cache_shrinker : 84.218 ms

total time spent in shrinkers = 92.472 ms

This shows the various shrinkers called and the times spent.

Janani Ravichandran (3):
  Add a new field to struct shrinker
  Update name field for all shrinker instances
  Add name fields in shrinker tracepoint definitions

 arch/x86/kvm/mmu.c                                 |  1 +
 drivers/gpu/drm/i915/i915_gem_shrinker.c           |  1 +
 drivers/gpu/drm/ttm/ttm_page_alloc.c               |  1 +
 drivers/gpu/drm/ttm/ttm_page_alloc_dma.c           |  1 +
 drivers/md/bcache/btree.c                          |  1 +
 drivers/md/dm-bufio.c                              |  1 +
 drivers/md/raid5.c                                 |  1 +
 drivers/staging/android/ashmem.c                   |  1 +
 drivers/staging/android/ion/ion_heap.c             |  1 +
 drivers/staging/android/lowmemorykiller.c          |  1 +
 drivers/staging/lustre/lustre/ldlm/ldlm_pool.c     |  1 +
 drivers/staging/lustre/lustre/obdclass/lu_object.c |  1 +
 drivers/staging/lustre/lustre/ptlrpc/sec_bulk.c    |  1 +
 fs/ext4/extents_status.c                           |  1 +
 fs/f2fs/super.c                                    |  1 +
 fs/gfs2/glock.c                                    |  1 +
 fs/gfs2/quota.c                                    |  1 +
 fs/mbcache.c                                       |  1 +
 fs/nfs/super.c                                     |  1 +
 fs/nfsd/nfscache.c                                 |  1 +
 fs/quota/dquot.c                                   |  1 +
 fs/super.c                                         |  1 +
 fs/ubifs/super.c                                   |  1 +
 fs/xfs/xfs_buf.c                                   |  1 +
 fs/xfs/xfs_qm.c                                    |  1 +
 include/linux/shrinker.h                           |  1 +
 include/trace/events/vmscan.h                      | 10 ++++++++--
 mm/huge_memory.c                                   |  2 ++
 mm/workingset.c                                    |  1 +
 mm/zsmalloc.c                                      |  1 +
 net/sunrpc/auth.c                                  |  1 +
 31 files changed, 39 insertions(+), 2 deletions(-)

-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
