Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 40F5A6B0287
	for <linux-mm@kvack.org>; Tue, 28 Nov 2017 02:49:24 -0500 (EST)
Received: by mail-pf0-f200.google.com with SMTP id h21so24684658pfk.14
        for <linux-mm@kvack.org>; Mon, 27 Nov 2017 23:49:24 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id e14sor1105930pfi.40.2017.11.27.23.49.23
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 27 Nov 2017 23:49:23 -0800 (PST)
From: js1304@gmail.com
Subject: [PATCH 01/18] mm/kasan: make some kasan functions global
Date: Tue, 28 Nov 2017 16:48:36 +0900
Message-Id: <1511855333-3570-2-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1511855333-3570-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1511855333-3570-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, kasan-dev@googlegroups.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Namhyung Kim <namhyung@kernel.org>, Wengang Wang <wen.gang.wang@oracle.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

From: Joonsoo Kim <iamjoonsoo.kim@lge.com>

They will be used for the vchecker in the following patch.
Make it non-static and add declairation in header files.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 include/linux/kasan.h | 1 +
 mm/kasan/kasan.c      | 2 +-
 mm/kasan/kasan.h      | 2 ++
 mm/kasan/report.c     | 2 +-
 4 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/include/linux/kasan.h b/include/linux/kasan.h
index e3eb834..50f49fe 100644
--- a/include/linux/kasan.h
+++ b/include/linux/kasan.h
@@ -37,6 +37,7 @@ extern void kasan_enable_current(void);
 /* Disable reporting bugs for current task */
 extern void kasan_disable_current(void);
 
+void kasan_poison_shadow(const void *address, size_t size, u8 value);
 void kasan_unpoison_shadow(const void *address, size_t size);
 
 void kasan_unpoison_task_stack(struct task_struct *task);
diff --git a/mm/kasan/kasan.c b/mm/kasan/kasan.c
index 405bba4..2bcbdbd 100644
--- a/mm/kasan/kasan.c
+++ b/mm/kasan/kasan.c
@@ -54,7 +54,7 @@ void kasan_disable_current(void)
  * Poisons the shadow memory for 'size' bytes starting from 'addr'.
  * Memory addresses should be aligned to KASAN_SHADOW_SCALE_SIZE.
  */
-static void kasan_poison_shadow(const void *address, size_t size, u8 value)
+void kasan_poison_shadow(const void *address, size_t size, u8 value)
 {
 	void *shadow_start, *shadow_end;
 
diff --git a/mm/kasan/kasan.h b/mm/kasan/kasan.h
index c70851a..b5d086d 100644
--- a/mm/kasan/kasan.h
+++ b/mm/kasan/kasan.h
@@ -99,6 +99,8 @@ static inline const void *kasan_shadow_to_mem(const void *shadow_addr)
 
 void kasan_report(unsigned long addr, size_t size,
 		bool is_write, unsigned long ip);
+void describe_object(struct kmem_cache *cache, void *object,
+				const void *addr);
 void kasan_report_double_free(struct kmem_cache *cache, void *object,
 					void *ip);
 
diff --git a/mm/kasan/report.c b/mm/kasan/report.c
index 6bcfb01..b78735a 100644
--- a/mm/kasan/report.c
+++ b/mm/kasan/report.c
@@ -230,7 +230,7 @@ static void describe_object_addr(struct kmem_cache *cache, void *object,
 		(void *)(object_addr + cache->object_size));
 }
 
-static void describe_object(struct kmem_cache *cache, void *object,
+void describe_object(struct kmem_cache *cache, void *object,
 				const void *addr)
 {
 	struct kasan_alloc_meta *alloc_info = get_alloc_info(cache, object);
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
