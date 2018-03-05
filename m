Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 23DE56B0026
	for <linux-mm@kvack.org>; Mon,  5 Mar 2018 15:08:10 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id p14so4227384wmc.0
        for <linux-mm@kvack.org>; Mon, 05 Mar 2018 12:08:10 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d125sor2383014wmd.61.2018.03.05.12.08.08
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 05 Mar 2018 12:08:08 -0800 (PST)
From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH 17/25] slub: make ->object_size unsigned int
Date: Mon,  5 Mar 2018 23:07:22 +0300
Message-Id: <20180305200730.15812-17-adobriyan@gmail.com>
In-Reply-To: <20180305200730.15812-1-adobriyan@gmail.com>
References: <20180305200730.15812-1-adobriyan@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, linux-mm@kvack.org, adobriyan@gmail.com

Linux doesn't support negative length objects.

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---
 include/linux/slub_def.h | 2 +-
 mm/slab_common.c         | 2 +-
 mm/slub.c                | 8 ++++----
 3 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/include/linux/slub_def.h b/include/linux/slub_def.h
index db00dbd7e89f..7d74f121ef4e 100644
--- a/include/linux/slub_def.h
+++ b/include/linux/slub_def.h
@@ -85,7 +85,7 @@ struct kmem_cache {
 	slab_flags_t flags;
 	unsigned long min_partial;
 	int size;		/* The size of an object including meta data */
-	int object_size;	/* The size of an object without meta data */
+	unsigned int object_size;/* The size of an object without meta data */
 	unsigned int offset;	/* Free pointer offset. */
 #ifdef CONFIG_SLUB_CPU_PARTIAL
 	/* Number of per cpu partial objects to keep around */
diff --git a/mm/slab_common.c b/mm/slab_common.c
index 8abb2a46ae85..3e07b1fb22bd 100644
--- a/mm/slab_common.c
+++ b/mm/slab_common.c
@@ -103,7 +103,7 @@ static int kmem_cache_sanity_check(const char *name, unsigned int size)
 		 */
 		res = probe_kernel_address(s->name, tmp);
 		if (res) {
-			pr_err("Slab cache with size %d has lost its name\n",
+			pr_err("Slab cache with size %u has lost its name\n",
 			       s->object_size);
 			continue;
 		}
diff --git a/mm/slub.c b/mm/slub.c
index 2fbf5a16e453..153340cbe48e 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -680,7 +680,7 @@ static void print_trailer(struct kmem_cache *s, struct page *page, u8 *p)
 		print_section(KERN_ERR, "Bytes b4 ", p - 16, 16);
 
 	print_section(KERN_ERR, "Object ", p,
-		      min_t(unsigned long, s->object_size, PAGE_SIZE));
+		      min_t(unsigned int, s->object_size, PAGE_SIZE));
 	if (s->flags & SLAB_RED_ZONE)
 		print_section(KERN_ERR, "Redzone ", p + s->object_size,
 			s->inuse - s->object_size);
@@ -2398,7 +2398,7 @@ slab_out_of_memory(struct kmem_cache *s, gfp_t gfpflags, int nid)
 
 	pr_warn("SLUB: Unable to allocate memory on node %d, gfp=%#x(%pGg)\n",
 		nid, gfpflags, &gfpflags);
-	pr_warn("  cache: %s, object size: %d, buffer size: %d, default order: %d, min order: %d\n",
+	pr_warn("  cache: %s, object size: %u, buffer size: %d, default order: %d, min order: %d\n",
 		s->name, s->object_size, s->size, oo_order(s->oo),
 		oo_order(s->min));
 
@@ -4254,7 +4254,7 @@ __kmem_cache_alias(const char *name, unsigned int size, unsigned int align,
 		 * Adjust the object sizes so that we clear
 		 * the complete object on kzalloc.
 		 */
-		s->object_size = max(s->object_size, (int)size);
+		s->object_size = max(s->object_size, size);
 		s->inuse = max(s->inuse, ALIGN(size, sizeof(void *)));
 
 		for_each_memcg_cache(c, s) {
@@ -4900,7 +4900,7 @@ SLAB_ATTR_RO(align);
 
 static ssize_t object_size_show(struct kmem_cache *s, char *buf)
 {
-	return sprintf(buf, "%d\n", s->object_size);
+	return sprintf(buf, "%u\n", s->object_size);
 }
 SLAB_ATTR_RO(object_size);
 
-- 
2.16.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
