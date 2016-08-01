Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id CFBB8828E4
	for <linux-mm@kvack.org>; Mon,  1 Aug 2016 10:44:17 -0400 (EDT)
Received: by mail-io0-f197.google.com with SMTP id g14so308493534ioj.3
        for <linux-mm@kvack.org>; Mon, 01 Aug 2016 07:44:17 -0700 (PDT)
Received: from EUR02-AM5-obe.outbound.protection.outlook.com (mail-eopbgr00137.outbound.protection.outlook.com. [40.107.0.137])
        by mx.google.com with ESMTPS id j93si475230otj.261.2016.08.01.07.44.13
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 01 Aug 2016 07:44:14 -0700 (PDT)
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Subject: [PATCH 4/6] mm/kasan: get rid of ->alloc_size in struct kasan_alloc_meta
Date: Mon, 1 Aug 2016 17:45:13 +0300
Message-ID: <1470062715-14077-4-git-send-email-aryabinin@virtuozzo.com>
In-Reply-To: <1470062715-14077-1-git-send-email-aryabinin@virtuozzo.com>
References: <1470062715-14077-1-git-send-email-aryabinin@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Alexander Potapenko <glider@google.com>, Dave Jones <davej@codemonkey.org.uk>, Vegard Nossum <vegard.nossum@oracle.com>, Sasha Levin <alexander.levin@verizon.com>, Dmitry Vyukov <dvyukov@google.com>, kasan-dev@googlegroups.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrey Ryabinin <aryabinin@virtuozzo.com>

Size of slab object already stored in cache->object_size.

Note, that kmalloc() internally rounds up size of allocation, so
object_size may be not equal to alloc_size, but, usually we don't need
to know the exact size of allocated object. In case if we need that
information, we still can figure it out from the report. The dump of
shadow memory allows to identify the end of allocated memory, and thereby
the exact allocation size.

Signed-off-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
---
 mm/kasan/kasan.c  | 1 -
 mm/kasan/kasan.h  | 3 +--
 mm/kasan/report.c | 8 +++-----
 3 files changed, 4 insertions(+), 8 deletions(-)

diff --git a/mm/kasan/kasan.c b/mm/kasan/kasan.c
index c99ef40..388e812 100644
--- a/mm/kasan/kasan.c
+++ b/mm/kasan/kasan.c
@@ -584,7 +584,6 @@ void kasan_kmalloc(struct kmem_cache *cache, const void *object, size_t size,
 			get_alloc_info(cache, object);
 
 		alloc_info->state = KASAN_STATE_ALLOC;
-		alloc_info->alloc_size = size;
 		set_track(&alloc_info->track, flags);
 	}
 }
diff --git a/mm/kasan/kasan.h b/mm/kasan/kasan.h
index 31972cd..aa17546 100644
--- a/mm/kasan/kasan.h
+++ b/mm/kasan/kasan.h
@@ -75,8 +75,7 @@ struct kasan_track {
 
 struct kasan_alloc_meta {
 	struct kasan_track track;
-	u32 state : 2;	/* enum kasan_state */
-	u32 alloc_size : 30;
+	u32 state;
 };
 
 struct qlist_node {
diff --git a/mm/kasan/report.c b/mm/kasan/report.c
index 861b977..d67a7e0 100644
--- a/mm/kasan/report.c
+++ b/mm/kasan/report.c
@@ -136,7 +136,9 @@ static void kasan_object_err(struct kmem_cache *cache, struct page *page,
 	struct kasan_free_meta *free_info;
 
 	dump_stack();
-	pr_err("Object at %p, in cache %s\n", object, cache->name);
+	pr_err("Object at %p, in cache %s size: %d\n", object, cache->name,
+		cache->object_size);
+
 	if (!(cache->flags & SLAB_KASAN))
 		return;
 	switch (alloc_info->state) {
@@ -144,15 +146,11 @@ static void kasan_object_err(struct kmem_cache *cache, struct page *page,
 		pr_err("Object not allocated yet\n");
 		break;
 	case KASAN_STATE_ALLOC:
-		pr_err("Object allocated with size %u bytes.\n",
-		       alloc_info->alloc_size);
 		pr_err("Allocation:\n");
 		print_track(&alloc_info->track);
 		break;
 	case KASAN_STATE_FREE:
 	case KASAN_STATE_QUARANTINE:
-		pr_err("Object freed, allocated with size %u bytes\n",
-		       alloc_info->alloc_size);
 		free_info = get_free_info(cache, object);
 		pr_err("Allocation:\n");
 		print_track(&alloc_info->track);
-- 
2.7.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
