Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 8ACD46B0038
	for <linux-mm@kvack.org>; Thu, 21 Aug 2014 04:11:34 -0400 (EDT)
Received: by mail-pd0-f182.google.com with SMTP id fp1so13570919pdb.27
        for <linux-mm@kvack.org>; Thu, 21 Aug 2014 01:11:34 -0700 (PDT)
Received: from lgeamrelo01.lge.com (lgeamrelo01.lge.com. [156.147.1.125])
        by mx.google.com with ESMTP id p3si35444564pdg.107.2014.08.21.01.11.32
        for <linux-mm@kvack.org>;
        Thu, 21 Aug 2014 01:11:33 -0700 (PDT)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH 3/3] mm/slab: support slab merge
Date: Thu, 21 Aug 2014 17:11:15 +0900
Message-Id: <1408608675-20420-3-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1408608675-20420-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1408608675-20420-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

Slab merge is good feature to reduce fragmentation. If new creating slab
have similar size and property with exsitent slab, this feature reuse
it rather than creating new one. As a result, objects are packed into
fewer slabs so that fragmentation is reduced.

Below is result of my testing.

* After boot, sleep 20; cat /proc/meminfo | grep Slab

<Before>
Slab: 25136 kB

<After>
Slab: 24364 kB

We can save 3% memory used by slab.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 mm/slab.c |   20 ++++++++++++++++++++
 mm/slab.h |    2 +-
 2 files changed, 21 insertions(+), 1 deletion(-)

diff --git a/mm/slab.c b/mm/slab.c
index 09b060e..a1cc1c9 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -2052,6 +2052,26 @@ static int __init_refok setup_cpu_cache(struct kmem_cache *cachep, gfp_t gfp)
 	return 0;
 }
 
+unsigned long kmem_cache_flags(unsigned long object_size,
+	unsigned long flags, const char *name,
+	void (*ctor)(void *))
+{
+	return flags;
+}
+
+struct kmem_cache *
+__kmem_cache_alias(const char *name, size_t size, size_t align,
+		   unsigned long flags, void (*ctor)(void *))
+{
+	struct kmem_cache *cachep;
+
+	cachep = find_mergeable(size, align, flags, name, ctor);
+	if (cachep)
+		cachep->refcount++;
+
+	return cachep;
+}
+
 /**
  * __kmem_cache_create - Create a cache.
  * @cachep: cache management descriptor
diff --git a/mm/slab.h b/mm/slab.h
index 7c6e1ed..13845d0 100644
--- a/mm/slab.h
+++ b/mm/slab.h
@@ -89,7 +89,7 @@ struct mem_cgroup;
 int slab_unmergeable(struct kmem_cache *s);
 struct kmem_cache *find_mergeable(size_t size, size_t align,
 		unsigned long flags, const char *name, void (*ctor)(void *));
-#ifdef CONFIG_SLUB
+#ifndef CONFIG_SLOB
 struct kmem_cache *
 __kmem_cache_alias(const char *name, size_t size, size_t align,
 		   unsigned long flags, void (*ctor)(void *));
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
