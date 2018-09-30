Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f200.google.com (mail-pf1-f200.google.com [209.85.210.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3402F8E0001
	for <linux-mm@kvack.org>; Sun, 30 Sep 2018 06:41:01 -0400 (EDT)
Received: by mail-pf1-f200.google.com with SMTP id d22-v6so12308117pfn.3
        for <linux-mm@kvack.org>; Sun, 30 Sep 2018 03:41:01 -0700 (PDT)
Received: from huawei.com (szxga06-in.huawei.com. [45.249.212.32])
        by mx.google.com with ESMTPS id n27-v6si8976114pgb.628.2018.09.30.03.40.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 30 Sep 2018 03:40:59 -0700 (PDT)
From: zhong jiang <zhongjiang@huawei.com>
Subject: [STABLE PATCH] slub: make ->cpu_partial unsigned int
Date: Sun, 30 Sep 2018 18:28:21 +0800
Message-ID: <1538303301-61784-1-git-send-email-zhongjiang@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: gregkh@linux-foundation.org
Cc: cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, mhocko@kernel.org, mgorman@suse.de, vbabka@suse.cz, andrea@kernel.org, kirill@shutemov.name, linux-mm@kvack.org, linux-kernel@vger.kernel.org

From: Alexey Dobriyan <adobriyan@gmail.com>

[ Upstream commit e5d9998f3e09359b372a037a6ac55ba235d95d57 ]

        /*
         * cpu_partial determined the maximum number of objects
         * kept in the per cpu partial lists of a processor.
         */

Can't be negative.

I hit a real issue that it will result in a large number of memory leak.
Becuase Freeing slabs are in interrupt context. So it can trigger this issue.
put_cpu_partial can be interrupted more than once.
due to a union struct of lru and pobjects in struct page, when other core handles
page->lru list, for eaxmple, remove_partial in freeing slab code flow, It will
result in pobjects being a negative value(0xdead0000). Therefore, a large number
of slabs will be added to per_cpu partial list.

I had posted the issue to community before. The detailed issue description is as follows.

https://www.spinics.net/lists/kernel/msg2870979.html

After applying the patch, The issue is fixed. So the patch is a effective bugfix.
It should go into stable.

Link: http://lkml.kernel.org/r/20180305200730.15812-15-adobriyan@gmail.com
Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>
Acked-by: Christoph Lameter <cl@linux.com>
Cc: Pekka Enberg <penberg@kernel.org>
Cc: David Rientjes <rientjes@google.com>
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Cc: <stable@vger.kernel.org> # 4.4.x
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
