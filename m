Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 7328A6B002B
	for <linux-mm@kvack.org>; Mon,  5 Mar 2018 15:08:14 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id 7so4768923wrp.2
        for <linux-mm@kvack.org>; Mon, 05 Mar 2018 12:08:14 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 53sor6233484wrv.61.2018.03.05.12.08.13
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 05 Mar 2018 12:08:13 -0800 (PST)
From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH 21/25] slab: make usercopy region 32-bit
Date: Mon,  5 Mar 2018 23:07:26 +0300
Message-Id: <20180305200730.15812-21-adobriyan@gmail.com>
In-Reply-To: <20180305200730.15812-1-adobriyan@gmail.com>
References: <20180305200730.15812-1-adobriyan@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, linux-mm@kvack.org, adobriyan@gmail.com, netdev@vger.kernel.org

If kmem case sizes are 32-bit, then usecopy region should be too.

Cc: netdev@vger.kernel.org
Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---
 include/linux/slab.h     | 2 +-
 include/linux/slab_def.h | 4 ++--
 include/linux/slub_def.h | 4 ++--
 include/net/sock.h       | 4 ++--
 mm/slab.h                | 4 ++--
 mm/slab_common.c         | 7 ++++---
 mm/slub.c                | 2 +-
 7 files changed, 14 insertions(+), 13 deletions(-)

diff --git a/include/linux/slab.h b/include/linux/slab.h
index d36e8f03730e..04402c637171 100644
--- a/include/linux/slab.h
+++ b/include/linux/slab.h
@@ -143,7 +143,7 @@ struct kmem_cache *kmem_cache_create(const char *name, unsigned int size,
 struct kmem_cache *kmem_cache_create_usercopy(const char *name,
 			unsigned int size, unsigned int align,
 			slab_flags_t flags,
-			size_t useroffset, size_t usersize,
+			unsigned int useroffset, unsigned int usersize,
 			void (*ctor)(void *));
 void kmem_cache_destroy(struct kmem_cache *);
 int kmem_cache_shrink(struct kmem_cache *);
diff --git a/include/linux/slab_def.h b/include/linux/slab_def.h
index 7385547c04b1..d9228e4d0320 100644
--- a/include/linux/slab_def.h
+++ b/include/linux/slab_def.h
@@ -85,8 +85,8 @@ struct kmem_cache {
 	unsigned int *random_seq;
 #endif
 
-	size_t useroffset;		/* Usercopy region offset */
-	size_t usersize;		/* Usercopy region size */
+	unsigned int useroffset;	/* Usercopy region offset */
+	unsigned int usersize;		/* Usercopy region size */
 
 	struct kmem_cache_node *node[MAX_NUMNODES];
 };
diff --git a/include/linux/slub_def.h b/include/linux/slub_def.h
index bc02fd3a8ccf..623d6ba92036 100644
--- a/include/linux/slub_def.h
+++ b/include/linux/slub_def.h
@@ -137,8 +137,8 @@ struct kmem_cache {
 	struct kasan_cache kasan_info;
 #endif
 
-	size_t useroffset;		/* Usercopy region offset */
-	size_t usersize;		/* Usercopy region size */
+	unsigned int useroffset;	/* Usercopy region offset */
+	unsigned int usersize;		/* Usercopy region size */
 
 	struct kmem_cache_node *node[MAX_NUMNODES];
 };
diff --git a/include/net/sock.h b/include/net/sock.h
index 169c92afcafa..c86b1ebaae7a 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -1109,8 +1109,8 @@ struct proto {
 	struct kmem_cache	*slab;
 	unsigned int		obj_size;
 	slab_flags_t		slab_flags;
-	size_t			useroffset;	/* Usercopy region offset */
-	size_t			usersize;	/* Usercopy region size */
+	unsigned int		useroffset;	/* Usercopy region offset */
+	unsigned int		usersize;	/* Usercopy region size */
 
 	struct percpu_counter	*orphan_count;
 
diff --git a/mm/slab.h b/mm/slab.h
index 8f1072f49285..e8981e811c45 100644
--- a/mm/slab.h
+++ b/mm/slab.h
@@ -22,8 +22,8 @@ struct kmem_cache {
 	unsigned int size;	/* The aligned/padded/added on size  */
 	unsigned int align;	/* Alignment as calculated */
 	slab_flags_t flags;	/* Active flags on the slab */
-	size_t useroffset;	/* Usercopy region offset */
-	size_t usersize;	/* Usercopy region size */
+	unsigned int useroffset;/* Usercopy region offset */
+	unsigned int usersize;	/* Usercopy region size */
 	const char *name;	/* Slab name for sysfs */
 	int refcount;		/* Use counter */
 	void (*ctor)(void *);	/* Called on object slot creation */
diff --git a/mm/slab_common.c b/mm/slab_common.c
index 3e07b1fb22bd..01224cb90080 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -380,8 +380,8 @@ struct kmem_cache *find_mergeable(unsigned int size, unsigned int align,
 
 static struct kmem_cache *create_cache(const char *name,
 		unsigned int object_size, unsigned int size, unsigned int align,
-		slab_flags_t flags, size_t useroffset,
-		size_t usersize, void (*ctor)(void *),
+		slab_flags_t flags, unsigned int useroffset,
+		unsigned int usersize, void (*ctor)(void *),
 		struct mem_cgroup *memcg, struct kmem_cache *root_cache)
 {
 	struct kmem_cache *s;
@@ -454,7 +454,8 @@ static struct kmem_cache *create_cache(const char *name,
 struct kmem_cache *
 kmem_cache_create_usercopy(const char *name,
 		  unsigned int size, unsigned int align,
-		  slab_flags_t flags, size_t useroffset, size_t usersize,
+		  slab_flags_t flags,
+		  unsigned int useroffset, unsigned int usersize,
 		  void (*ctor)(void *))
 {
 	struct kmem_cache *s = NULL;
diff --git a/mm/slub.c b/mm/slub.c
index 87a7a947f2c9..865d964f4c93 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -5080,7 +5080,7 @@ SLAB_ATTR_RO(cache_dma);
 
 static ssize_t usersize_show(struct kmem_cache *s, char *buf)
 {
-	return sprintf(buf, "%zu\n", s->usersize);
+	return sprintf(buf, "%u\n", s->usersize);
 }
 SLAB_ATTR_RO(usersize);
 
-- 
2.16.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
