Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 13BE76B0028
	for <linux-mm@kvack.org>; Mon,  5 Mar 2018 15:08:11 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id p14so4227403wmc.0
        for <linux-mm@kvack.org>; Mon, 05 Mar 2018 12:08:11 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b11sor3860095wrf.40.2018.03.05.12.08.09
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 05 Mar 2018 12:08:09 -0800 (PST)
From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH 18/25] slub: make ->size unsigned int
Date: Mon,  5 Mar 2018 23:07:23 +0300
Message-Id: <20180305200730.15812-18-adobriyan@gmail.com>
In-Reply-To: <20180305200730.15812-1-adobriyan@gmail.com>
References: <20180305200730.15812-1-adobriyan@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, linux-mm@kvack.org, adobriyan@gmail.com

Linux doesn't support negative length objects (including meta data).

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---
 include/linux/slub_def.h |  2 +-
 mm/slub.c                | 12 ++++++------
 2 files changed, 7 insertions(+), 7 deletions(-)

diff --git a/include/linux/slub_def.h b/include/linux/slub_def.h
index 7d74f121ef4e..bc02fd3a8ccf 100644
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
index 153340cbe48e..424cb7693a5c 100644
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
@@ -3824,7 +3824,7 @@ void __check_heap_object(const void *ptr, unsigned long n, struct page *page,
 			 bool to_user)
 {
 	struct kmem_cache *s;
-	unsigned long offset;
+	unsigned int offset;
 	size_t object_size;
 
 	/* Find object and usable object size. */
@@ -4888,7 +4888,7 @@ struct slab_attribute {
 
 static ssize_t slab_size_show(struct kmem_cache *s, char *buf)
 {
-	return sprintf(buf, "%d\n", s->size);
+	return sprintf(buf, "%u\n", s->size);
 }
 SLAB_ATTR_RO(slab_size);
 
@@ -5663,7 +5663,7 @@ static char *create_unique_id(struct kmem_cache *s)
 		*p++ = 'A';
 	if (p != name + 1)
 		*p++ = '-';
-	p += sprintf(p, "%07d", s->size);
+	p += sprintf(p, "%07u", s->size);
 
 	BUG_ON(p > name + ID_STR_LENGTH - 1);
 	return name;
-- 
2.16.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
