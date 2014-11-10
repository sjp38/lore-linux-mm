Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f54.google.com (mail-oi0-f54.google.com [209.85.218.54])
	by kanga.kvack.org (Postfix) with ESMTP id DC58A82BEF
	for <linux-mm@kvack.org>; Mon, 10 Nov 2014 02:12:06 -0500 (EST)
Received: by mail-oi0-f54.google.com with SMTP id a141so4926307oig.41
        for <linux-mm@kvack.org>; Sun, 09 Nov 2014 23:12:06 -0800 (PST)
Received: from bear.ext.ti.com (bear.ext.ti.com. [192.94.94.41])
        by mx.google.com with ESMTPS id t8si19501921oev.71.2014.11.09.23.12.05
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Sun, 09 Nov 2014 23:12:05 -0800 (PST)
From: Peter Ujfalusi <peter.ujfalusi@ti.com>
Subject: [PATCH] slab: Fix compilation error in case of !CONFIG_NUMA
Date: Mon, 10 Nov 2014 09:11:57 +0200
Message-ID: <1415603517-9527-1-git-send-email-peter.ujfalusi@ti.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, vdavydov@parallels.com

Move the definition of slab_free() outside of #ifdef CONFIG_NUMA since it
is used by code which is not NUMA specific. Fixes the following error
introduced by the following commit:
5da1c3c725ab slab: recharge slab pages to the allocating memory cgroup

  CC      mm/slab.o
/home/ZZZZZ/linux/mm/slab.c: In function a??slab_alloca??:
/home/ZZZZZ/linux/mm/slab.c:3260:4: error: implicit declaration of function a??slab_freea?? [-Werror=implicit-function-declaration]
    slab_free(cachep, objp);
    ^
/home/ZZZZZ/linux/mm/slab.c: At top level:
/home/ZZZZZ/linux/mm/slab.c:3534:29: warning: conflicting types for a??slab_freea?? [enabled by default]
 static __always_inline void slab_free(struct kmem_cache *cachep, void *objp)
                             ^
/home/ZZZZZ/linux/mm/slab.c:3534:29: error: static declaration of a??slab_freea?? follows non-static declaration
/home/ZZZZZ/linux/mm/slab.c:3260:4: note: previous implicit declaration of a??slab_freea?? was here
    slab_free(cachep, objp);
    ^
cc1: some warnings being treated as errors
/home/ZZZZZ/linux/scripts/Makefile.build:257: recipe for target 'mm/slab.o' failed
make[2]: *** [mm/slab.o] Error 1
/home/ZZZZZ/linux/Makefile:953: recipe for target 'mm' failed
make[1]: *** [mm] Error 2
make[1]: *** Waiting for unfinished jobs....
  CHK     kernel/config_data.h

Signed-off-by: Peter Ujfalusi <peter.ujfalusi@ti.com>
---
 mm/slab.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/slab.c b/mm/slab.c
index 61b01c2ae1d9..301ede1c6784 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -3133,8 +3133,6 @@ done:
 	return obj;
 }
 
-static __always_inline void slab_free(struct kmem_cache *cachep, void *objp);
-
 static __always_inline void *
 slab_alloc_node(struct kmem_cache *cachep, gfp_t flags, int nodeid,
 		   unsigned long caller)
@@ -3228,6 +3226,8 @@ __do_cache_alloc(struct kmem_cache *cachep, gfp_t flags)
 
 #endif /* CONFIG_NUMA */
 
+static __always_inline void slab_free(struct kmem_cache *cachep, void *objp);
+
 static __always_inline void *
 slab_alloc(struct kmem_cache *cachep, gfp_t flags, unsigned long caller)
 {
-- 
2.1.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
