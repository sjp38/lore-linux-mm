Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 2410E6B0281
	for <linux-mm@kvack.org>; Thu, 23 Nov 2017 17:17:26 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id k18so12251478wre.11
        for <linux-mm@kvack.org>; Thu, 23 Nov 2017 14:17:26 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id c51sor6216854wrc.22.2017.11.23.14.17.24
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 23 Nov 2017 14:17:24 -0800 (PST)
From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH 17/23] slub: make ->size unsigned int
Date: Fri, 24 Nov 2017 01:16:22 +0300
Message-Id: <20171123221628.8313-17-adobriyan@gmail.com>
In-Reply-To: <20171123221628.8313-1-adobriyan@gmail.com>
References: <20171123221628.8313-1-adobriyan@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, Alexey Dobriyan <adobriyan@gmail.com>

Linux doesn't support negative length objects in kmem caches
(including metadata).

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---
 include/linux/slub_def.h |  2 +-
 mm/slub.c                | 12 ++++++------
 2 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/include/linux/slub_def.h b/include/linux/slub_def.h
index b9d1f0ef1335..e768ac49f0b4 100644
--- a/include/linux/slub_def.h
+++ b/include/linux/slub_def.h
@@ -84,7 +84,7 @@ struct kmem_cache {
 	/* Used for retriving partial slabs etc */
 	slab_flags_t flags;
 	unsigned long min_partial;
-	int size;		/* The size of an object including meta data */
+	unsigned int size;	/* The size of an object including meta data */
 	unsigned int object_size;/* The size of an object without meta data */
 	unsigned int offset;	/* Free pointer offset. */
 #ifdef CONFIG_SLUB_CPU_PARTIAL
diff --git a/mm/slub.c b/mm/slub.c
index 4e09dabb89da..042421584ef8 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -2398,7 +2398,7 @@ slab_out_of_memory(struct kmem_cache *s, gfp_t gfpflags, int nid)
 
 	pr_warn("SLUB: Unable to allocate memory on node %d, gfp=%#x(%pGg)\n",
 		nid, gfpflags, &gfpflags);
-	pr_warn("  cache: %s, object size: %u, buffer size: %d, default order: %d, min order: %d\n",
+	pr_warn("  cache: %s, object size: %u, buffer size: %u, default order: %d, min order: %d\n",
 		s->name, s->object_size, s->size, oo_order(s->oo),
 		oo_order(s->min));
 
@@ -3632,8 +3632,8 @@ static int kmem_cache_open(struct kmem_cache *s, slab_flags_t flags)
 	free_kmem_cache_nodes(s);
 error:
 	if (flags & SLAB_PANIC)
-		panic("Cannot create slab %s size=%lu realsize=%u order=%u offset=%u flags=%lx\n",
-		      s->name, (unsigned long)s->size, s->size,
+		panic("Cannot create slab %s size=%u realsize=%u order=%u offset=%u flags=%lx\n",
+		      s->name, s->size, s->size,
 		      oo_order(s->oo), s->offset, (unsigned long)flags);
 	return -EINVAL;
 }
@@ -3822,7 +3822,7 @@ const char *__check_heap_object(const void *ptr, unsigned long n,
 				struct page *page)
 {
 	struct kmem_cache *s;
-	unsigned long offset;
+	unsigned int offset;
 	size_t object_size;
 
 	/* Find object and usable object size. */
@@ -4870,7 +4870,7 @@ struct slab_attribute {
 
 static ssize_t slab_size_show(struct kmem_cache *s, char *buf)
 {
-	return sprintf(buf, "%d\n", s->size);
+	return sprintf(buf, "%u\n", s->size);
 }
 SLAB_ATTR_RO(slab_size);
 
@@ -5638,7 +5638,7 @@ static char *create_unique_id(struct kmem_cache *s)
 		*p++ = 'A';
 	if (p != name + 1)
 		*p++ = '-';
-	p += sprintf(p, "%07d", s->size);
+	p += sprintf(p, "%07u", s->size);
 
 	BUG_ON(p > name + ID_STR_LENGTH - 1);
 	return name;
-- 
2.13.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
