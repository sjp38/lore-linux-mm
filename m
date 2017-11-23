Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id BFE276B0273
	for <linux-mm@kvack.org>; Thu, 23 Nov 2017 17:17:22 -0500 (EST)
Received: by mail-wr0-f199.google.com with SMTP id l4so10365624wre.10
        for <linux-mm@kvack.org>; Thu, 23 Nov 2017 14:17:22 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 94sor7402375wrf.42.2017.11.23.14.17.21
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 23 Nov 2017 14:17:21 -0800 (PST)
From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH 14/23] slub: make ->cpu_partial unsigned int
Date: Fri, 24 Nov 2017 01:16:19 +0300
Message-Id: <20171123221628.8313-14-adobriyan@gmail.com>
In-Reply-To: <20171123221628.8313-1-adobriyan@gmail.com>
References: <20171123221628.8313-1-adobriyan@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, Alexey Dobriyan <adobriyan@gmail.com>

->cpu_partial is at least 0, can't be negative.

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---
 include/linux/slub_def.h | 3 ++-
 mm/slub.c                | 6 +++---
 2 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/include/linux/slub_def.h b/include/linux/slub_def.h
index 2383c46c88ce..d8b40e53e8f6 100644
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
index f5b86d86be9a..61218ecc0ea7 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1809,7 +1809,7 @@ static void *get_partial_node(struct kmem_cache *s, struct kmem_cache_node *n,
 {
 	struct page *page, *page2;
 	void *object = NULL;
-	int available = 0;
+	unsigned int available = 0;
 	int objects;
 
 	/*
@@ -4943,10 +4943,10 @@ static ssize_t cpu_partial_show(struct kmem_cache *s, char *buf)
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
2.13.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
