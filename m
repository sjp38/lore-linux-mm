Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 0FD916B000E
	for <linux-mm@kvack.org>; Mon,  5 Mar 2018 15:08:01 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id h33so11906527wrh.10
        for <linux-mm@kvack.org>; Mon, 05 Mar 2018 12:08:01 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 7sor3370315wrn.74.2018.03.05.12.07.59
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 05 Mar 2018 12:07:59 -0800 (PST)
From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: [PATCH 09/25] slub: make ->remote_node_defrag_ratio unsigned int
Date: Mon,  5 Mar 2018 23:07:14 +0300
Message-Id: <20180305200730.15812-9-adobriyan@gmail.com>
In-Reply-To: <20180305200730.15812-1-adobriyan@gmail.com>
References: <20180305200730.15812-1-adobriyan@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, linux-mm@kvack.org, adobriyan@gmail.com

->remote_node_defrag_ratio is in range 0..1000.

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
---
 include/linux/slub_def.h |  2 +-
 mm/slub.c                | 11 ++++++-----
 2 files changed, 7 insertions(+), 6 deletions(-)

diff --git a/include/linux/slub_def.h b/include/linux/slub_def.h
index 8ad99c47b19c..f6548083fe0f 100644
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
index b2f529a33400..d9db1d184549 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -5288,21 +5288,22 @@ SLAB_ATTR(shrink);
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
2.16.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
