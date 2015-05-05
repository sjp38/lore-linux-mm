Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id 140436B0038
	for <linux-mm@kvack.org>; Tue,  5 May 2015 05:45:56 -0400 (EDT)
Received: by pdea3 with SMTP id a3so190544496pde.3
        for <linux-mm@kvack.org>; Tue, 05 May 2015 02:45:55 -0700 (PDT)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id zb14si23501731pac.209.2015.05.05.02.45.54
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 May 2015 02:45:55 -0700 (PDT)
From: Vladimir Davydov <vdavydov@parallels.com>
Subject: [PATCH 1/2] gfp: add __GFP_NOACCOUNT
Date: Tue, 5 May 2015 12:45:42 +0300
Message-ID: <fdf631b3fa95567a830ea4f3e19d0b3b2fc99662.1430819044.git.vdavydov@parallels.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Greg Thelen <gthelen@google.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

Not all kmem allocations should be accounted to memcg. The following
patch gives an example when accounting of a certain type of allocations
to memcg can effectively result in a memory leak. This patch adds the
__GFP_NOACCOUNT flag which if passed to kmalloc and friends will force
the allocation to go through the root cgroup. It will be used by the
next patch.

Note, since in case of kmemleak enabled each kmalloc implies yet another
allocation from the kmemleak_object cache, we add __GFP_NOACCOUNT to
gfp_kmemleak_mask.

Signed-off-by: Vladimir Davydov <vdavydov@parallels.com>
---
 include/linux/gfp.h        |    2 ++
 include/linux/memcontrol.h |    4 ++++
 mm/kmemleak.c              |    3 ++-
 3 files changed, 8 insertions(+), 1 deletion(-)

diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index 97a9373e61e8..37c422df2a0f 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -30,6 +30,7 @@ struct vm_area_struct;
 #define ___GFP_HARDWALL		0x20000u
 #define ___GFP_THISNODE		0x40000u
 #define ___GFP_RECLAIMABLE	0x80000u
+#define ___GFP_NOACCOUNT	0x100000u
 #define ___GFP_NOTRACK		0x200000u
 #define ___GFP_NO_KSWAPD	0x400000u
 #define ___GFP_OTHER_NODE	0x800000u
@@ -87,6 +88,7 @@ struct vm_area_struct;
 #define __GFP_HARDWALL   ((__force gfp_t)___GFP_HARDWALL) /* Enforce hardwall cpuset memory allocs */
 #define __GFP_THISNODE	((__force gfp_t)___GFP_THISNODE)/* No fallback, no policies */
 #define __GFP_RECLAIMABLE ((__force gfp_t)___GFP_RECLAIMABLE) /* Page is reclaimable */
+#define __GFP_NOACCOUNT	((__force gfp_t)___GFP_NOACCOUNT) /* Don't account to memcg */
 #define __GFP_NOTRACK	((__force gfp_t)___GFP_NOTRACK)  /* Don't track with kmemcheck */
 
 #define __GFP_NO_KSWAPD	((__force gfp_t)___GFP_NO_KSWAPD)
diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 72dff5fb0d0c..6c8918114804 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -463,6 +463,8 @@ memcg_kmem_newpage_charge(gfp_t gfp, struct mem_cgroup **memcg, int order)
 	if (!memcg_kmem_enabled())
 		return true;
 
+	if (gfp & __GFP_NOACCOUNT)
+		return true;
 	/*
 	 * __GFP_NOFAIL allocations will move on even if charging is not
 	 * possible. Therefore we don't even try, and have this allocation
@@ -522,6 +524,8 @@ memcg_kmem_get_cache(struct kmem_cache *cachep, gfp_t gfp)
 {
 	if (!memcg_kmem_enabled())
 		return cachep;
+	if (gfp & __GFP_NOACCOUNT)
+		return cachep;
 	if (gfp & __GFP_NOFAIL)
 		return cachep;
 	if (in_interrupt() || (!current->mm) || (current->flags & PF_KTHREAD))
diff --git a/mm/kmemleak.c b/mm/kmemleak.c
index 5405aff5a590..f0fe4f2c1fa7 100644
--- a/mm/kmemleak.c
+++ b/mm/kmemleak.c
@@ -115,7 +115,8 @@
 #define BYTES_PER_POINTER	sizeof(void *)
 
 /* GFP bitmask for kmemleak internal allocations */
-#define gfp_kmemleak_mask(gfp)	(((gfp) & (GFP_KERNEL | GFP_ATOMIC)) | \
+#define gfp_kmemleak_mask(gfp)	(((gfp) & (GFP_KERNEL | GFP_ATOMIC | \
+					   __GFP_NOACCOUNT)) | \
 				 __GFP_NORETRY | __GFP_NOMEMALLOC | \
 				 __GFP_NOWARN)
 
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
