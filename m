Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id D5DB86B0038
	for <linux-mm@kvack.org>; Wed, 28 Jan 2015 11:23:01 -0500 (EST)
Received: by mail-pa0-f52.google.com with SMTP id kx10so26985804pab.11
        for <linux-mm@kvack.org>; Wed, 28 Jan 2015 08:23:01 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id kt6si6436796pbc.47.2015.01.28.08.23.00
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 28 Jan 2015 08:23:01 -0800 (PST)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH -mm v2 0/3] slub: make dead caches discard free slabs immediately
Date: Wed, 28 Jan 2015 19:22:48 +0300
Message-ID: <cover.1422461573.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi,

The kmem extension of the memory cgroup is almost usable now. There is,
in fact, the only serious issue left: per memcg kmem caches may pin the
owner cgroup for indefinitely long. This is, because a slab cache may
keep empty slab pages in its private structures to optimize performance,
while we take a css reference per each charged kmem page.

The issue is only relevant to SLUB, because SLAB periodically reaps
empty slabs. This patch set fixes this issue for SLUB. For details,
please see patch 3.

Changes in v2:
 - address Christoph's concerns regarding kmem_cache_shrink
 - fix race between put_cpu_partial reading ->cpu_partial and
   kmem_cache_shrink updating it as proposed by Joonsoo

v1: https://lkml.org/lkml/2015/1/26/317

Thanks,

Vladimir Davydov (3):
  slub: never fail to shrink cache
  slub: fix kmem_cache_shrink return value
  slub: make dead caches discard free slabs immediately

 mm/slab.c        |    4 +--
 mm/slab.h        |    2 +-
 mm/slab_common.c |   15 +++++++--
 mm/slob.c        |    2 +-
 mm/slub.c        |   94 +++++++++++++++++++++++++++++++++++-------------------
 5 files changed, 78 insertions(+), 39 deletions(-)

-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
