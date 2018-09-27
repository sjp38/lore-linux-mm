Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f197.google.com (mail-oi1-f197.google.com [209.85.167.197])
	by kanga.kvack.org (Postfix) with ESMTP id B5AB48E0001
	for <linux-mm@kvack.org>; Thu, 27 Sep 2018 10:56:44 -0400 (EDT)
Received: by mail-oi1-f197.google.com with SMTP id e136-v6so488944oib.11
        for <linux-mm@kvack.org>; Thu, 27 Sep 2018 07:56:44 -0700 (PDT)
Received: from huawei.com (szxga07-in.huawei.com. [45.249.212.35])
        by mx.google.com with ESMTPS id 93-v6si1096985otq.130.2018.09.27.07.56.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Sep 2018 07:56:43 -0700 (PDT)
From: zhong jiang <zhongjiang@huawei.com>
Subject: [STABLE PATCH] slub: make ->cpu_partial unsigned int
Date: Thu, 27 Sep 2018 22:43:40 +0800
Message-ID: <1538059420-14439-1-git-send-email-zhongjiang@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: gregkh@linux-foundation.org
Cc: iamjoonsoo.kim@lge.com, rientjes@google.com, cl@linux.com, penberg@kernel.org, akpm@linux-foundation.org, mhocko@suse.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, stable@vger.kernel.org

From: Alexey Dobriyan <adobriyan@gmail.com>

        /*
         * cpu_partial determined the maximum number of objects
         * kept in the per cpu partial lists of a processor.
         */

Can't be negative.

I hit a real issue that it will result in a large number of memory leak.
Because Freeing slabs are in interrupt context. So it can trigger this issue.
put_cpu_partial can be interrupted more than once.
due to a union struct of lru and pobjects in struct page, when other core handles
page->lru list, for eaxmple, remove_partial in freeing slab code flow, It will
result in pobjects being a negative value(0xdead0000). Therefore, a large number
of slabs will be added to per_cpu partial list.

I had posted the issue to community before. The detailed issue description is as follows.

Link: https://www.spinics.net/lists/kernel/msg2870979.html

After applying the patch, The issue is fixed. So the patch is a effective bugfix.
It should go into stable.

Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
Acked-by: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>
Cc: David Rientjes <rientjes@google.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: stable@vger.kernel.org 
Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
Signed-off-by: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: zhong jiang <zhongjiang@huawei.com>
---
 include/linux/slub_def.h | 3 ++-
 mm/slub.c                | 6 +++---
 2 files changed, 5 insertions(+), 4 deletions(-)

diff --git a/include/linux/slub_def.h b/include/linux/slub_def.h
index 3388511..9b681f2 100644
--- a/include/linux/slub_def.h
+++ b/include/linux/slub_def.h
@@ -67,7 +67,8 @@ struct kmem_cache {
 	int size;		/* The size of an object including meta data */
 	int object_size;	/* The size of an object without meta data */
 	int offset;		/* Free pointer offset. */
-	int cpu_partial;	/* Number of per cpu partial objects to keep around */
+	/* Number of per cpu partial objects to keep around */
+	unsigned int cpu_partial;
 	struct kmem_cache_order_objects oo;
 
 	/* Allocation and freeing of slabs */
diff --git a/mm/slub.c b/mm/slub.c
index 2284c43..c33b0e1 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -1661,7 +1661,7 @@ static void *get_partial_node(struct kmem_cache *s, struct kmem_cache_node *n,
 {
 	struct page *page, *page2;
 	void *object = NULL;
-	int available = 0;
+	unsigned int available = 0;
 	int objects;
 
 	/*
@@ -4674,10 +4674,10 @@ static ssize_t cpu_partial_show(struct kmem_cache *s, char *buf)
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
1.7.12.4
