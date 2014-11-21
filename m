Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id C5E136B006E
	for <linux-mm@kvack.org>; Fri, 21 Nov 2014 08:43:47 -0500 (EST)
Received: by mail-pd0-f181.google.com with SMTP id z10so5348377pdj.40
        for <linux-mm@kvack.org>; Fri, 21 Nov 2014 05:43:47 -0800 (PST)
Received: from mail-pd0-x236.google.com (mail-pd0-x236.google.com. [2607:f8b0:400e:c02::236])
        by mx.google.com with ESMTPS id pu3si8484651pdb.150.2014.11.21.05.43.45
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 21 Nov 2014 05:43:46 -0800 (PST)
Received: by mail-pd0-f182.google.com with SMTP id r10so5390438pdi.27
        for <linux-mm@kvack.org>; Fri, 21 Nov 2014 05:43:45 -0800 (PST)
From: Mahendran Ganesh <opensource.ganesh@gmail.com>
Subject: [PATCH v2] mm/zsmalloc: avoid duplicate assignment of prev_class
Date: Fri, 21 Nov 2014 21:43:23 +0800
Message-Id: <1416577403-7887-1-git-send-email-opensource.ganesh@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: minchan@kernel.org, ngupta@vflare.org, iamjoonsoo.kim@lge.com, ddstreet@ieee.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mahendran Ganesh <opensource.ganesh@gmail.com>

In zs_create_pool(), prev_class is assigned (ZS_SIZE_CLASSES - 1)
times. And the prev_class only references to the previous size_class.
So we do not need unnecessary assignement.

This patch assigns *prev_class* when a new size_class structure
is allocated and uses prev_class to check whether the first class
has been allocated.

Signed-off-by: Mahendran Ganesh <opensource.ganesh@gmail.com>

---
v1 -> v2:
  - follow Dan Streetman's advise to use prev_class to
    check whether the first class has been allocated
  - follow Minchan Kim's advise to remove uninitialized_var()
---
 mm/zsmalloc.c |    7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index b3b57ef..810eda1 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -970,7 +970,7 @@ struct zs_pool *zs_create_pool(gfp_t flags)
 		int size;
 		int pages_per_zspage;
 		struct size_class *class;
-		struct size_class *prev_class;
+		struct size_class *prev_class = NULL;
 
 		size = ZS_MIN_ALLOC_SIZE + i * ZS_SIZE_CLASS_DELTA;
 		if (size > ZS_MAX_ALLOC_SIZE)
@@ -986,8 +986,7 @@ struct zs_pool *zs_create_pool(gfp_t flags)
 		 * characteristics. So, we makes size_class point to
 		 * previous size_class if possible.
 		 */
-		if (i < ZS_SIZE_CLASSES - 1) {
-			prev_class = pool->size_class[i + 1];
+		if (prev_class) {
 			if (can_merge(prev_class, size, pages_per_zspage)) {
 				pool->size_class[i] = prev_class;
 				continue;
@@ -1003,6 +1002,8 @@ struct zs_pool *zs_create_pool(gfp_t flags)
 		class->pages_per_zspage = pages_per_zspage;
 		spin_lock_init(&class->lock);
 		pool->size_class[i] = class;
+
+		prev_class = class;
 	}
 
 	pool->flags = flags;
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
