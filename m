Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 8348D6B0038
	for <linux-mm@kvack.org>; Mon, 21 Jul 2014 07:47:33 -0400 (EDT)
Received: by mail-pa0-f42.google.com with SMTP id lf10so9680531pab.15
        for <linux-mm@kvack.org>; Mon, 21 Jul 2014 04:47:33 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id ok13si7018822pdb.134.2014.07.21.04.47.31
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 Jul 2014 04:47:31 -0700 (PDT)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH -mm 0/6] memcg: release memcg_cache_id on css offline
Date: Mon, 21 Jul 2014 15:47:10 +0400
Message-ID: <cover.1405941342.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mhocko@suse.cz, hannes@cmpxchg.org, cl@linux.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi,

Currently memcg_cache_id (mem_cgroup->kmemcg_id), which is used for
indexing memcg_caches arrays, is released only on css free. As a result,
offline css, whose number is actually limited only by amount of free
RAM, will occupy slots in these arrays making them grow larger and
larger even if there's only a few kmem active memory cgroups out there.

This patch set makes memcg release memcg_cache_id on css offline. This
way the memcg_caches arrays size will be limited by the number of alive
kmem-active memory cgroups, which is much better.

The work is actually done in patch 6 while patches 1-5 only prepare
memcg and slab subsystems to this change.

Thanks,

Vladimir Davydov (6):
  slub: remove kmemcg id from create_unique_id
  slab: use mem_cgroup_id for per memcg cache naming
  memcg: make memcg_cache_id static
  memcg: add pointer to owner cache to memcg_cache_params
  memcg: keep all children of each root cache on a list
  memcg: release memcg_cache_id on css offline

 include/linux/memcontrol.h |    9 +---
 include/linux/slab.h       |    7 ++-
 mm/memcontrol.c            |  112 +++++++++++++++++++++++++++-----------------
 mm/slab.c                  |   40 +++++++++-------
 mm/slab_common.c           |   44 ++++++++---------
 mm/slub.c                  |   45 +++++++++---------
 6 files changed, 140 insertions(+), 117 deletions(-)

-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
