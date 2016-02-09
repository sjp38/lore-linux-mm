Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id ABC896B0005
	for <linux-mm@kvack.org>; Tue,  9 Feb 2016 08:56:07 -0500 (EST)
Received: by mail-pa0-f52.google.com with SMTP id ho8so91767361pac.2
        for <linux-mm@kvack.org>; Tue, 09 Feb 2016 05:56:07 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id x9si54210712pas.214.2016.02.09.05.56.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 09 Feb 2016 05:56:06 -0800 (PST)
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: [PATCH v2 0/6] mm: workingset: make shadow node shrinker memcg aware
Date: Tue, 9 Feb 2016 16:55:48 +0300
Message-ID: <cover.1455025246.git.vdavydov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi,

Workingset code was recently made memcg aware, but shadow node shrinker
is still global. As a result, one small cgroup can consume all memory
available for shadow nodes, possibly hurting other cgroups by reclaiming
their shadow nodes, even though reclaim distances stored in its shadow
nodes have no effect. To avoid this, we need to make shadow node
shrinker memcg aware.

The actual work is done in patch 6 of the series. Patches 1 and 2
prepare memcg/shrinker infrastructure for the change. Patch 3 is just a
collateral cleanup. Patch 4 makes radix_tree_node accounted, which is
necessary for making shadow node shrinker memcg aware. Patch 5 reduces
shadow nodes overhead in case workload mostly uses anonymous pages.

Changes in v2:
 - Use (FILE_ACTIVE+FILE_INACTIVE)/2 instead of FILE_ACTIVE for maximal
   refault distance (Johannes).

Thanks,

Vladimir Davydov (6):
  mm: memcontrol: enable kmem accounting for all cgroups in the legacy
    hierarchy
  mm: vmscan: pass root_mem_cgroup instead of NULL to memcg aware
    shrinker
  mm: memcontrol: zap memcg_kmem_online helper
  radix-tree: account radix_tree_node to memory cgroup
  mm: workingset: size shadow nodes lru basing on file cache size
  mm: workingset: make shadow node shrinker memcg aware

 include/linux/memcontrol.h | 20 +++++++++----------
 lib/radix-tree.c           | 16 +++++++++++++---
 mm/memcontrol.c            | 48 ++++++++--------------------------------------
 mm/slab_common.c           |  2 +-
 mm/vmscan.c                | 15 ++++++++++-----
 mm/workingset.c            | 10 ++++++++--
 6 files changed, 50 insertions(+), 61 deletions(-)

-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
