Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 2131F6B0036
	for <linux-mm@kvack.org>; Mon, 15 Sep 2014 02:26:02 -0400 (EDT)
Received: by mail-pa0-f54.google.com with SMTP id lj1so5782124pab.27
        for <linux-mm@kvack.org>; Sun, 14 Sep 2014 23:26:01 -0700 (PDT)
Received: from lgeamrelo04.lge.com (lgeamrelo04.lge.com. [156.147.1.127])
        by mx.google.com with ESMTP id vv6si20865074pab.144.2014.09.14.23.25.59
        for <linux-mm@kvack.org>;
        Sun, 14 Sep 2014 23:26:00 -0700 (PDT)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH v2 2/3] mm/slab: support slab merge
Date: Mon, 15 Sep 2014 15:25:56 +0900
Message-Id: <1410762357-7787-2-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1410762357-7787-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1410762357-7787-1-git-send-email-iamjoonsoo.kim@lge.com>
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

For supporting this feature in SLAB, we need to implement SLAB specific
kmem_cache_flag() and __kmem_cache_alias(), because SLUB implements
some SLUB specific processing related to debug flag and object size
change on these functions.

v2: add commit description for the reason to implement SLAB specific
functions.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 mm/slab.c |   20 ++++++++++++++++++++
 mm/slab.h |    2 +-
 2 files changed, 21 insertions(+), 1 deletion(-)

diff --git a/mm/slab.c b/mm/slab.c
index 5927a17..cc246f2 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -2104,6 +2104,26 @@ static int __init_refok setup_cpu_cache(struct kmem_cache *cachep, gfp_t gfp)
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
index 857758b..46c7c25 100644
--- a/mm/slab.h
+++ b/mm/slab.h
@@ -90,7 +90,7 @@ struct mem_cgroup;
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
