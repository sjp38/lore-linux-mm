Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f42.google.com (mail-la0-f42.google.com [209.85.215.42])
	by kanga.kvack.org (Postfix) with ESMTP id D8A37900003
	for <linux-mm@kvack.org>; Mon,  7 Jul 2014 08:00:29 -0400 (EDT)
Received: by mail-la0-f42.google.com with SMTP id pn19so2801908lab.15
        for <linux-mm@kvack.org>; Mon, 07 Jul 2014 05:00:28 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id ed4si68645008lbc.43.2014.07.07.05.00.27
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Jul 2014 05:00:27 -0700 (PDT)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH -mm 0/8] memcg: reparent kmem on css offline
Date: Mon, 7 Jul 2014 16:00:05 +0400
Message-ID: <cover.1404733720.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mhocko@suse.cz, hannes@cmpxchg.org, cl@linux.com, glommer@gmail.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi,

This patch set introduces re-parenting of kmem charges on memcg css
offline. The idea lying behind it is very simple - instead of pointing
from kmem objects (kmem caches, non-slab kmem pages) directly to the
memcg which they are charged against, we make them point to a proxy
object, mem_cgroup_kmem_context, which, in turn, points to the memcg
which it belongs to. As a result on memcg offline, it's enough to only
re-parent the memcg's mem_cgroup_kmem_context.

Note, reparented kmem contexts will hang around until there is at least
one object accounted to them, but since they are small (especially
comparing to struct mem_cgroup), it's no big deal.

Reviews are appreciated.

Thanks,

Vladimir Davydov (8):
  memcg: add pointer from memcg_cache_params to owner cache
  memcg: keep all children of each root cache on a list
  slab: guarantee unique kmem cache naming
  slub: remove kmemcg id from create_unique_id
  memcg: rework non-slab kmem pages charge path
  memcg: introduce kmem context
  memcg: move some kmem definitions upper
  memcg: reparent kmem context on memcg offline

 include/linux/memcontrol.h |   88 ++++-----
 include/linux/mm_types.h   |    6 +
 include/linux/slab.h       |   17 +-
 mm/memcontrol.c            |  468 +++++++++++++++++++++-----------------------
 mm/page_alloc.c            |   22 ++-
 mm/slab.c                  |   40 ++--
 mm/slab_common.c           |   64 ++++--
 mm/slub.c                  |   45 ++---
 8 files changed, 382 insertions(+), 368 deletions(-)

-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
