Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 2EB226B0257
	for <linux-mm@kvack.org>; Tue, 10 Nov 2015 13:34:37 -0500 (EST)
Received: by pasz6 with SMTP id z6so4537597pas.2
        for <linux-mm@kvack.org>; Tue, 10 Nov 2015 10:34:36 -0800 (PST)
Received: from mx2.parallels.com (mx2.parallels.com. [199.115.105.18])
        by mx.google.com with ESMTPS id my1si6586425pbc.186.2015.11.10.10.34.36
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Nov 2015 10:34:36 -0800 (PST)
From: Vladimir Davydov <vdavydov@virtuozzo.com>
Subject: [PATCH v2 3/6] memcg: only account kmem allocations marked as __GFP_ACCOUNT
Date: Tue, 10 Nov 2015 21:34:04 +0300
Message-ID: <14d7a7f5e696d71793ddd835604de309af1963fd.1447172835.git.vdavydov@virtuozzo.com>
In-Reply-To: <cover.1447172835.git.vdavydov@virtuozzo.com>
References: <cover.1447172835.git.vdavydov@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@kernel.org>, Tejun Heo <tj@kernel.org>, Greg Thelen <gthelen@google.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org

Black-list kmem accounting policy (aka __GFP_NOACCOUNT) turned out to be
fragile and difficult to maintain, because there seem to be many more
allocations that should not be accounted than those that should be.
Besides, false accounting an allocation might result in much worse
consequences than not accounting at all, namely increased memory
consumption due to pinned dead kmem caches.

So this patch switches kmem accounting to the white-policy: now only
those kmem allocations that are marked as __GFP_ACCOUNT are accounted to
memcg. Currently, no kmem allocations are marked like this. The
following patches will mark several kmem allocations that are known to
be easily triggered from userspace and therefore should be accounted to
memcg.

Signed-off-by: Vladimir Davydov <vdavydov@virtuozzo.com>
---
 include/linux/gfp.h        | 4 ++++
 include/linux/memcontrol.h | 2 ++
 mm/page_alloc.c            | 3 ++-
 3 files changed, 8 insertions(+), 1 deletion(-)

diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index 2b917ce34efc..61305a492356 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -30,6 +30,7 @@ struct vm_area_struct;
 #define ___GFP_HARDWALL		0x20000u
 #define ___GFP_THISNODE		0x40000u
 #define ___GFP_RECLAIMABLE	0x80000u
+#define ___GFP_ACCOUNT		0x100000u
 #define ___GFP_NOTRACK		0x200000u
 #define ___GFP_NO_KSWAPD	0x400000u
 #define ___GFP_OTHER_NODE	0x800000u
@@ -90,6 +91,8 @@ struct vm_area_struct;
 #define __GFP_HARDWALL   ((__force gfp_t)___GFP_HARDWALL) /* Enforce hardwall cpuset memory allocs */
 #define __GFP_THISNODE	((__force gfp_t)___GFP_THISNODE)/* No fallback, no policies */
 #define __GFP_RECLAIMABLE ((__force gfp_t)___GFP_RECLAIMABLE) /* Page is reclaimable */
+#define __GFP_ACCOUNT	((__force gfp_t)___GFP_ACCOUNT)	/* Account to memcg (only relevant
+							 * to kmem allocations) */
 #define __GFP_NOTRACK	((__force gfp_t)___GFP_NOTRACK)  /* Don't track with kmemcheck */
 
 #define __GFP_NO_KSWAPD	((__force gfp_t)___GFP_NO_KSWAPD)
@@ -112,6 +115,7 @@ struct vm_area_struct;
 #define GFP_NOIO	(__GFP_WAIT)
 #define GFP_NOFS	(__GFP_WAIT | __GFP_IO)
 #define GFP_KERNEL	(__GFP_WAIT | __GFP_IO | __GFP_FS)
+#define GFP_KERNEL_ACCOUNT	(GFP_KERNEL | __GFP_ACCOUNT)
 #define GFP_TEMPORARY	(__GFP_WAIT | __GFP_IO | __GFP_FS | \
 			 __GFP_RECLAIMABLE)
 #define GFP_USER	(__GFP_WAIT | __GFP_IO | __GFP_FS | __GFP_HARDWALL)
diff --git a/include/linux/memcontrol.h b/include/linux/memcontrol.h
index 2103f36b3bd3..c9d9a8e7b45f 100644
--- a/include/linux/memcontrol.h
+++ b/include/linux/memcontrol.h
@@ -773,6 +773,8 @@ static inline bool __memcg_kmem_bypass(gfp_t gfp)
 {
 	if (!memcg_kmem_enabled())
 		return true;
+	if (!(gfp & __GFP_ACCOUNT))
+		return true;
 	if (in_interrupt() || (!current->mm) || (current->flags & PF_KTHREAD))
 		return true;
 	return false;
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 446bb36ee59d..8e22f5b27de0 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3420,7 +3420,8 @@ EXPORT_SYMBOL(__free_page_frag);
 
 /*
  * alloc_kmem_pages charges newly allocated pages to the kmem resource counter
- * of the current memory cgroup.
+ * of the current memory cgroup if __GFP_ACCOUNT is set, other than that it is
+ * equivalent to alloc_pages.
  *
  * It should be used when the caller would like to use kmalloc, but since the
  * allocation is large, it has to fall back to the page allocator.
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
