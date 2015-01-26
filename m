Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 2527F6B0032
	for <linux-mm@kvack.org>; Mon, 26 Jan 2015 07:55:41 -0500 (EST)
Received: by mail-pd0-f182.google.com with SMTP id z10so11709490pdj.13
        for <linux-mm@kvack.org>; Mon, 26 Jan 2015 04:55:40 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id ds15si12038527pdb.225.2015.01.26.04.55.40
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Jan 2015 04:55:40 -0800 (PST)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH -mm 0/3] slub: make dead caches discard free slabs immediately
Date: Mon, 26 Jan 2015 15:55:26 +0300
Message-ID: <cover.1422275084.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi,

The kmem extension of the memory cgroup is almost usable now. There is,
in fact, the only serious issue left: per memcg kmem caches may pin the
owner cgroup for indefinitely long. This is, because a slab cache may
keep empty slab pages in its private structures to optimize performance,
while we take a css reference per each charged kmem page.

The issue is only relevant to SLUB, because SLAB periodically reaps
empty slabs. This patch set fixes this issue for SLUB. For details,
please see patch 3.

Thanks,

Vladimir Davydov (3):
  slub: don't fail kmem_cache_shrink if slab placement optimization
    fails
  slab: zap kmem_cache_shrink return value
  slub: make dead caches discard free slabs immediately

 include/linux/slab.h |    2 +-
 mm/slab.c            |    9 +++++++--
 mm/slab.h            |    2 +-
 mm/slab_common.c     |   21 +++++++++++++-------
 mm/slob.c            |    3 +--
 mm/slub.c            |   53 +++++++++++++++++++++++++++++++++++---------------
 6 files changed, 61 insertions(+), 29 deletions(-)

-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
