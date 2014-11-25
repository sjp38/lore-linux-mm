Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id 258896B0038
	for <linux-mm@kvack.org>; Tue, 25 Nov 2014 08:01:02 -0500 (EST)
Received: by mail-pd0-f180.google.com with SMTP id p10so545251pdj.11
        for <linux-mm@kvack.org>; Tue, 25 Nov 2014 05:01:01 -0800 (PST)
Received: from mail-pa0-x231.google.com (mail-pa0-x231.google.com. [2607:f8b0:400e:c03::231])
        by mx.google.com with ESMTPS id je7si1926464pbd.15.2014.11.25.05.01.00
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 25 Nov 2014 05:01:00 -0800 (PST)
Received: by mail-pa0-f49.google.com with SMTP id eu11so546464pac.8
        for <linux-mm@kvack.org>; Tue, 25 Nov 2014 05:01:00 -0800 (PST)
From: Ganesh Mahendran <opensource.ganesh@gmail.com>
Subject: [PATCH v3] mm/zsmalloc: avoid duplicate assignment of prev_class
Date: Tue, 25 Nov 2014 21:00:44 +0800
Message-Id: <1416920444-4181-1-git-send-email-opensource.ganesh@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: minchan@kernel.org, ngupta@vflare.org, ddstreet@ieee.org
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Ganesh Mahendran <opensource.ganesh@gmail.com>

In zs_create_pool(), prev_class is assigned (ZS_SIZE_CLASSES - 1)
times. And the prev_class only references to the previous size_class.
So we do not need unnecessary assignement.

This patch assigns *prev_class* when a new size_class structure
is allocated and uses prev_class to check whether the first class
has been allocated.

Signed-off-by: Ganesh Mahendran <opensource.ganesh@gmail.com>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Nitin Gupta <ngupta@vflare.org>
Cc: Dan Streetman <ddstreet@ieee.org>

---
v1 -> v2:
  - follow Dan Streetman's advise to use prev_class to
    check whether the first class has been allocated
  - follow Minchan Kim's advise to remove uninitialized_var()

v2 -> v3:
  - move *prev_class* definition out of the loop - Dan
---
 mm/zsmalloc.c |    7 ++++---
 1 file changed, 4 insertions(+), 3 deletions(-)

diff --git a/mm/zsmalloc.c b/mm/zsmalloc.c
index 83ecdb6..de1320e 100644
--- a/mm/zsmalloc.c
+++ b/mm/zsmalloc.c
@@ -966,6 +966,7 @@ struct zs_pool *zs_create_pool(gfp_t flags)
 {
 	int i, ovhd_size;
 	struct zs_pool *pool;
+	struct size_class *prev_class = NULL;
 
 	ovhd_size = roundup(sizeof(*pool), PAGE_SIZE);
 	pool = kzalloc(ovhd_size, GFP_KERNEL);
@@ -980,7 +981,6 @@ struct zs_pool *zs_create_pool(gfp_t flags)
 		int size;
 		int pages_per_zspage;
 		struct size_class *class;
-		struct size_class *prev_class;
 
 		size = ZS_MIN_ALLOC_SIZE + i * ZS_SIZE_CLASS_DELTA;
 		if (size > ZS_MAX_ALLOC_SIZE)
@@ -996,8 +996,7 @@ struct zs_pool *zs_create_pool(gfp_t flags)
 		 * characteristics. So, we makes size_class point to
 		 * previous size_class if possible.
 		 */
-		if (i < ZS_SIZE_CLASSES - 1) {
-			prev_class = pool->size_class[i + 1];
+		if (prev_class) {
 			if (can_merge(prev_class, size, pages_per_zspage)) {
 				pool->size_class[i] = prev_class;
 				continue;
@@ -1013,6 +1012,8 @@ struct zs_pool *zs_create_pool(gfp_t flags)
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
