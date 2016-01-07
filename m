Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f46.google.com (mail-qg0-f46.google.com [209.85.192.46])
	by kanga.kvack.org (Postfix) with ESMTP id CEA986B0008
	for <linux-mm@kvack.org>; Thu,  7 Jan 2016 09:03:51 -0500 (EST)
Received: by mail-qg0-f46.google.com with SMTP id e32so237752101qgf.3
        for <linux-mm@kvack.org>; Thu, 07 Jan 2016 06:03:51 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id 18si1139469qgl.97.2016.01.07.06.03.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Jan 2016 06:03:50 -0800 (PST)
Subject: [PATCH 03/10] mm: fault-inject take over bootstrap kmem_cache check
From: Jesper Dangaard Brouer <brouer@redhat.com>
Date: Thu, 07 Jan 2016 15:03:48 +0100
Message-ID: <20160107140348.28907.35881.stgit@firesoul>
In-Reply-To: <20160107140253.28907.5469.stgit@firesoul>
References: <20160107140253.28907.5469.stgit@firesoul>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Christoph Lameter <cl@linux.com>
Cc: Vladimir Davydov <vdavydov@virtuozzo.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Jesper Dangaard Brouer <brouer@redhat.com>

Remove the SLAB specific function slab_should_failslab(), by moving
the check against fault-injection for the bootstrap slab, into the
shared function should_failslab() (used by both SLAB and SLUB).

This is a step towards sharing alloc_hook's between SLUB and SLAB.

This bootstrap slab "kmem_cache" is used for allocating struct
kmem_cache objects to the allocator itself.

Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
---
 include/linux/fault-inject.h |    5 ++---
 mm/failslab.c                |   11 ++++++++---
 mm/slab.c                    |   12 ++----------
 mm/slab.h                    |    2 +-
 4 files changed, 13 insertions(+), 17 deletions(-)

diff --git a/include/linux/fault-inject.h b/include/linux/fault-inject.h
index 3159a7dba034..9f4956d8601c 100644
--- a/include/linux/fault-inject.h
+++ b/include/linux/fault-inject.h
@@ -62,10 +62,9 @@ static inline struct dentry *fault_create_debugfs_attr(const char *name,
 #endif /* CONFIG_FAULT_INJECTION */
 
 #ifdef CONFIG_FAILSLAB
-extern bool should_failslab(size_t size, gfp_t gfpflags, unsigned long flags);
+extern bool should_failslab(struct kmem_cache *s, gfp_t gfpflags);
 #else
-static inline bool should_failslab(size_t size, gfp_t gfpflags,
-				unsigned long flags)
+static inline bool should_failslab(struct kmem_cache *s, gfp_t gfpflags)
 {
 	return false;
 }
diff --git a/mm/failslab.c b/mm/failslab.c
index 79171b4a5826..0c5b3f31f310 100644
--- a/mm/failslab.c
+++ b/mm/failslab.c
@@ -1,5 +1,6 @@
 #include <linux/fault-inject.h>
 #include <linux/slab.h>
+#include "slab.h"
 
 static struct {
 	struct fault_attr attr;
@@ -11,18 +12,22 @@ static struct {
 	.cache_filter = false,
 };
 
-bool should_failslab(size_t size, gfp_t gfpflags, unsigned long cache_flags)
+bool should_failslab(struct kmem_cache *s, gfp_t gfpflags)
 {
+	/* No fault-injection for bootstrap cache */
+	if (unlikely(s == kmem_cache))
+		return false;
+
 	if (gfpflags & __GFP_NOFAIL)
 		return false;
 
 	if (failslab.ignore_gfp_reclaim && (gfpflags & __GFP_RECLAIM))
 		return false;
 
-	if (failslab.cache_filter && !(cache_flags & SLAB_FAILSLAB))
+	if (failslab.cache_filter && !(s->flags & SLAB_FAILSLAB))
 		return false;
 
-	return should_fail(&failslab.attr, size);
+	return should_fail(&failslab.attr, s->object_size);
 }
 
 static int __init setup_failslab(char *str)
diff --git a/mm/slab.c b/mm/slab.c
index 4765c97ce690..d5b29e7bee81 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -2917,14 +2917,6 @@ static void *cache_alloc_debugcheck_after(struct kmem_cache *cachep,
 #define cache_alloc_debugcheck_after(a,b,objp,d) (objp)
 #endif
 
-static bool slab_should_failslab(struct kmem_cache *cachep, gfp_t flags)
-{
-	if (unlikely(cachep == kmem_cache))
-		return false;
-
-	return should_failslab(cachep->object_size, flags, cachep->flags);
-}
-
 static inline void *____cache_alloc(struct kmem_cache *cachep, gfp_t flags)
 {
 	void *objp;
@@ -3152,7 +3144,7 @@ slab_alloc_node(struct kmem_cache *cachep, gfp_t flags, int nodeid,
 
 	lockdep_trace_alloc(flags);
 
-	if (slab_should_failslab(cachep, flags))
+	if (should_failslab(cachep, flags))
 		return NULL;
 
 	cachep = memcg_kmem_get_cache(cachep, flags);
@@ -3240,7 +3232,7 @@ slab_alloc(struct kmem_cache *cachep, gfp_t flags, unsigned long caller)
 
 	lockdep_trace_alloc(flags);
 
-	if (slab_should_failslab(cachep, flags))
+	if (should_failslab(cachep, flags))
 		return NULL;
 
 	cachep = memcg_kmem_get_cache(cachep, flags);
diff --git a/mm/slab.h b/mm/slab.h
index 92b10da2c71f..343ee496c53b 100644
--- a/mm/slab.h
+++ b/mm/slab.h
@@ -358,7 +358,7 @@ static inline struct kmem_cache *slab_pre_alloc_hook(struct kmem_cache *s,
 	lockdep_trace_alloc(flags);
 	might_sleep_if(gfpflags_allow_blocking(flags));
 
-	if (should_failslab(s->object_size, flags, s->flags))
+	if (should_failslab(s, flags))
 		return NULL;
 
 	return memcg_kmem_get_cache(s, flags);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
