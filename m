Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 3860C6B026B
	for <linux-mm@kvack.org>; Thu, 23 Nov 2017 17:17:17 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id u83so4944038wmb.8
        for <linux-mm@kvack.org>; Thu, 23 Nov 2017 14:17:17 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t201sor1925911wmd.44.2017.11.23.14.17.15
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 23 Nov 2017 14:17:16 -0800 (PST)
From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH 08/23] slub: make ->remote_node_defrag_ratio unsigned int
Date: Fri, 24 Nov 2017 01:16:13 +0300
Message-Id: <20171123221628.8313-8-adobriyan@gmail.com>
In-Reply-To: <20171123221628.8313-1-adobriyan@gmail.com>
References: <20171123221628.8313-1-adobriyan@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, Alexey Dobriyan <adobriyan@gmail.com>

->remote_node_defrag_ratio is in range 0..1000.

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---
 include/linux/slub_def.h |  2 +-
 mm/slub.c                | 11 ++++++-----
 2 files changed, 7 insertions(+), 6 deletions(-)

diff --git a/include/linux/slub_def.h b/include/linux/slub_def.h
index 0adae162dc8f..571ff513ed97 100644
--- a/include/linux/slub_def.h
+++ b/include/linux/slub_def.h
@@ -124,7 +124,7 @@ struct kmem_cache {
 	/*
 	 * Defragmentation by allocating from a remote node.
 	 */
-	int remote_node_defrag_ratio;
+	unsigned int remote_node_defrag_ratio;
 #endif
 
 #ifdef CONFIG_SLAB_FREELIST_RANDOM
diff --git a/mm/slub.c b/mm/slub.c
index e653c4b51403..45d8f0cbfb28 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -5264,21 +5264,22 @@ SLAB_ATTR(shrink);
 #ifdef CONFIG_NUMA
 static ssize_t remote_node_defrag_ratio_show(struct kmem_cache *s, char *buf)
 {
-	return sprintf(buf, "%d\n", s->remote_node_defrag_ratio / 10);
+	return sprintf(buf, "%u\n", s->remote_node_defrag_ratio / 10);
 }
 
 static ssize_t remote_node_defrag_ratio_store(struct kmem_cache *s,
 				const char *buf, size_t length)
 {
-	unsigned long ratio;
+	unsigned int ratio;
 	int err;
 
-	err = kstrtoul(buf, 10, &ratio);
+	err = kstrtouint(buf, 10, &ratio);
 	if (err)
 		return err;
+	if (ratio > 100)
+		return -ERANGE;
 
-	if (ratio <= 100)
-		s->remote_node_defrag_ratio = ratio * 10;
+	s->remote_node_defrag_ratio = ratio * 10;
 
 	return length;
 }
-- 
2.13.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
