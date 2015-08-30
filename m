Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f48.google.com (mail-pa0-f48.google.com [209.85.220.48])
	by kanga.kvack.org (Postfix) with ESMTP id 892D16B0254
	for <linux-mm@kvack.org>; Sun, 30 Aug 2015 15:02:30 -0400 (EDT)
Received: by padhy3 with SMTP id hy3so9688770pad.0
        for <linux-mm@kvack.org>; Sun, 30 Aug 2015 12:02:30 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id tf10si19383813pac.5.2015.08.30.12.02.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 30 Aug 2015 12:02:29 -0700 (PDT)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH 0/2] Fix memcg/memory.high in case kmem accounting is enabled
Date: Sun, 30 Aug 2015 22:02:16 +0300
Message-ID: <cover.1440960578.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Michal Hocko <mhocko@kernel.org>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi,

Tejun reported that sometimes memcg/memory.high threshold seems to be
silently ignored if kmem accounting is enabled:

  http://www.spinics.net/lists/linux-mm/msg93613.html

It turned out that both SLAB and SLUB try to allocate without __GFP_WAIT
first. As a result, if there is enough free pages, memcg reclaim will
not get invoked on kmem allocations, which will lead to uncontrollable
growth of memory usage no matter what memory.high is set to.

This patch set attempts to fix this issue. For more details please see
comments to individual patches.

Thanks,

Vladimir Davydov (2):
  mm/slab: skip memcg reclaim only if in atomic context
  mm/slub: do not bypass memcg reclaim for high-order page allocation

 mm/slab.c | 32 +++++++++++---------------------
 mm/slub.c | 24 +++++++++++-------------
 2 files changed, 22 insertions(+), 34 deletions(-)

-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
