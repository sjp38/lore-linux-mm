Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f45.google.com (mail-pa0-f45.google.com [209.85.220.45])
	by kanga.kvack.org (Postfix) with ESMTP id B785D8309E
	for <linux-mm@kvack.org>; Sun,  7 Feb 2016 12:27:44 -0500 (EST)
Received: by mail-pa0-f45.google.com with SMTP id uo6so62369875pac.1
        for <linux-mm@kvack.org>; Sun, 07 Feb 2016 09:27:44 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id o90si40233699pfi.192.2016.02.07.09.27.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 07 Feb 2016 09:27:43 -0800 (PST)
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: [PATCH 0/5] mm: workingset: make shadow node shrinker memcg aware
Date: Sun, 7 Feb 2016 20:27:30 +0300
Message-ID: <cover.1454864628.git.vdavydov@virtuozzo.com>
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

The actual work is done in patch 5 of the series. Patches 1 and 2
prepare memcg/shrinker infrastructure for the change. Patch 3 is just a
collateral cleanup. Patch 4 makes radix_tree_node accounted, which is
necessary for making shadow node shrinker memcg aware.

Thanks,

Vladimir Davydov (5):
  mm: memcontrol: enable kmem accounting for all cgroups in the legacy
    hierarchy
  mm: vmscan: pass root_mem_cgroup instead of NULL to memcg aware
    shrinker
  mm: memcontrol: zap memcg_kmem_online helper
  radix-tree: account radix_tree_node to memory cgroup
  mm: workingset: make shadow node shrinker memcg aware

 include/linux/memcontrol.h | 20 +++++++++----------
 lib/radix-tree.c           | 16 +++++++++++++---
 mm/memcontrol.c            | 48 ++++++++--------------------------------------
 mm/slab_common.c           |  2 +-
 mm/vmscan.c                | 15 ++++++++++-----
 mm/workingset.c            | 11 ++++++++---
 6 files changed, 50 insertions(+), 62 deletions(-)

-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
