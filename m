Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id BFF656B0024
	for <linux-mm@kvack.org>; Mon,  5 Mar 2018 15:08:07 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id v21so5102582wmh.9
        for <linux-mm@kvack.org>; Mon, 05 Mar 2018 12:08:07 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u1sor1936379wrd.75.2018.03.05.12.08.06
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 05 Mar 2018 12:08:06 -0800 (PST)
From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH 15/25] slub: make ->cpu_partial unsigned int
Date: Mon,  5 Mar 2018 23:07:20 +0300
Message-Id: <20180305200730.15812-15-adobriyan@gmail.com>
In-Reply-To: <20180305200730.15812-1-adobriyan@gmail.com>
References: <20180305200730.15812-1-adobriyan@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, linux-mm@kvack.org, adobriyan@gmail.com

	/*
	 * cpu_partial determined the maximum number of objects
	 * kept in the per cpu partial lists of a processor.
	 */

Can't be negative.

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---
 include/linux/slub_def.h | 3 ++-
 mm/slub.c                | 6 +++---
 2 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/include/linux/slub_def.h b/include/linux/slub_def.h
index 2287b800474f..d2cc1391f17a 100644
--- a/include/linux/slub_def.h
+++ b/include/linux/slub_def.h
@@ -88,7 +88,8 @@ struct kmem_cache {
 	int object_size;	/* The size of an object without meta data */
 	int offset;		/* Free pointer offset. */
 #ifdef CONFIG_SLUB_CPU_PARTIAL
-	int cpu_partial;	/* Number of per cpu partial objects to keep around */
+	/* Number of per cpu partial objects to keep around */
+	unsigned int cpu_partial;
 #endif
 	struct kmem_cache_order_objects oo;
 
diff --git a/mm/slub.c b/mm/slub.c
index b4c07dcab0e1..2fbf5a16e453 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1811,7 +1811,7 @@ static void *get_partial_node(struct kmem_cache *s, struct kmem_cache_node *n,
 {
 	struct page *page, *page2;
 	void *object = NULL;
-	int available = 0;
+	unsigned int available = 0;
 	int objects;
 
 	/*
@@ -4961,10 +4961,10 @@ static ssize_t cpu_partial_show(struct kmem_cache *s, char *buf)
 static ssize_t cpu_partial_store(struct kmem_cache *s, const char *buf,
 				 size_t length)
 {
-	unsigned long objects;
+	unsigned int objects;
 	int err;
 
-	err = kstrtoul(buf, 10, &objects);
+	err = kstrtouint(buf, 10, &objects);
 	if (err)
 		return err;
 	if (objects && !kmem_cache_has_cpu_partial(s))
-- 
2.16.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
