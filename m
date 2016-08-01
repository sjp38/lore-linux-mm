Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f72.google.com (mail-oi0-f72.google.com [209.85.218.72])
	by kanga.kvack.org (Postfix) with ESMTP id E2D89828E4
	for <linux-mm@kvack.org>; Mon,  1 Aug 2016 10:44:22 -0400 (EDT)
Received: by mail-oi0-f72.google.com with SMTP id w207so301207030oiw.1
        for <linux-mm@kvack.org>; Mon, 01 Aug 2016 07:44:22 -0700 (PDT)
Received: from EUR02-AM5-obe.outbound.protection.outlook.com (mail-eopbgr00124.outbound.protection.outlook.com. [40.107.0.124])
        by mx.google.com with ESMTPS id 30si19830051otb.226.2016.08.01.07.44.16
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 01 Aug 2016 07:44:16 -0700 (PDT)
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Subject: [PATCH 6/6] kasan: improve double-free reports.
Date: Mon, 1 Aug 2016 17:45:15 +0300
Message-ID: <1470062715-14077-6-git-send-email-aryabinin@virtuozzo.com>
In-Reply-To: <1470062715-14077-1-git-send-email-aryabinin@virtuozzo.com>
References: <1470062715-14077-1-git-send-email-aryabinin@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Alexander Potapenko <glider@google.com>, Dave Jones <davej@codemonkey.org.uk>, Vegard Nossum <vegard.nossum@oracle.com>, Sasha Levin <alexander.levin@verizon.com>, Dmitry Vyukov <dvyukov@google.com>, kasan-dev@googlegroups.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrey Ryabinin <aryabinin@virtuozzo.com>

Currently we just dump stack in case of double free bug.
Let's dump all info about the object that we have.

Signed-off-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
---
 mm/kasan/kasan.c  |  3 +--
 mm/kasan/kasan.h  |  2 ++
 mm/kasan/report.c | 54 ++++++++++++++++++++++++++++++++++++++----------------
 3 files changed, 41 insertions(+), 18 deletions(-)

diff --git a/mm/kasan/kasan.c b/mm/kasan/kasan.c
index 92750e3..88af13c 100644
--- a/mm/kasan/kasan.c
+++ b/mm/kasan/kasan.c
@@ -543,8 +543,7 @@ bool kasan_slab_free(struct kmem_cache *cache, void *object)
 
 	shadow_byte = READ_ONCE(*(s8 *)kasan_mem_to_shadow(object));
 	if (shadow_byte < 0 || shadow_byte >= KASAN_SHADOW_SCALE_SIZE) {
-		pr_err("Double free");
-		dump_stack();
+		kasan_report_double_free(cache, object, shadow_byte);
 		return true;
 	}
 
diff --git a/mm/kasan/kasan.h b/mm/kasan/kasan.h
index 9b7b31e..e5c2181 100644
--- a/mm/kasan/kasan.h
+++ b/mm/kasan/kasan.h
@@ -99,6 +99,8 @@ static inline bool kasan_report_enabled(void)
 
 void kasan_report(unsigned long addr, size_t size,
 		bool is_write, unsigned long ip);
+void kasan_report_double_free(struct kmem_cache *cache, void *object,
+			s8 shadow);
 
 #if defined(CONFIG_SLAB) || defined(CONFIG_SLUB)
 void quarantine_put(struct kasan_free_meta *info, struct kmem_cache *cache);
diff --git a/mm/kasan/report.c b/mm/kasan/report.c
index f437398..ee2bdb4 100644
--- a/mm/kasan/report.c
+++ b/mm/kasan/report.c
@@ -116,6 +116,26 @@ static inline bool init_task_stack_addr(const void *addr)
 			sizeof(init_thread_union.stack));
 }
 
+static DEFINE_SPINLOCK(report_lock);
+
+static void kasan_start_report(unsigned long *flags)
+{
+	/*
+	 * Make sure we don't end up in loop.
+	 */
+	kasan_disable_current();
+	spin_lock_irqsave(&report_lock, *flags);
+	pr_err("==================================================================\n");
+}
+
+static void kasan_end_report(unsigned long *flags)
+{
+	pr_err("==================================================================\n");
+	add_taint(TAINT_BAD_PAGE, LOCKDEP_NOW_UNRELIABLE);
+	spin_unlock_irqrestore(&report_lock, *flags);
+	kasan_enable_current();
+}
+
 static void print_track(struct kasan_track *track)
 {
 	pr_err("PID = %u\n", track->pid);
@@ -129,8 +149,7 @@ static void print_track(struct kasan_track *track)
 	}
 }
 
-static void kasan_object_err(struct kmem_cache *cache, struct page *page,
-				void *object, char *unused_reason)
+static void kasan_object_err(struct kmem_cache *cache, void *object)
 {
 	struct kasan_alloc_meta *alloc_info = get_alloc_info(cache, object);
 
@@ -147,6 +166,18 @@ static void kasan_object_err(struct kmem_cache *cache, struct page *page,
 	print_track(&alloc_info->free_track);
 }
 
+void kasan_report_double_free(struct kmem_cache *cache, void *object,
+			s8 shadow)
+{
+	unsigned long flags;
+
+	kasan_start_report(&flags);
+	pr_err("BUG: Double free or corrupt pointer\n");
+	pr_err("Unexpected shadow byte: 0x%hhX\n", shadow);
+	kasan_object_err(cache, object);
+	kasan_end_report(&flags);
+}
+
 static void print_address_description(struct kasan_access_info *info)
 {
 	const void *addr = info->access_addr;
@@ -160,8 +191,7 @@ static void print_address_description(struct kasan_access_info *info)
 			struct kmem_cache *cache = page->slab_cache;
 			object = nearest_obj(cache, page,
 						(void *)info->access_addr);
-			kasan_object_err(cache, page, object,
-					"kasan: bad access detected");
+			kasan_object_err(cache, object);
 			return;
 		}
 		dump_page(page, "kasan: bad access detected");
@@ -226,19 +256,13 @@ static void print_shadow_for_address(const void *addr)
 	}
 }
 
-static DEFINE_SPINLOCK(report_lock);
-
 static void kasan_report_error(struct kasan_access_info *info)
 {
 	unsigned long flags;
 	const char *bug_type;
 
-	/*
-	 * Make sure we don't end up in loop.
-	 */
-	kasan_disable_current();
-	spin_lock_irqsave(&report_lock, flags);
-	pr_err("==================================================================\n");
+	kasan_start_report(&flags);
+
 	if (info->access_addr <
 			kasan_shadow_to_mem((void *)KASAN_SHADOW_START)) {
 		if ((unsigned long)info->access_addr < PAGE_SIZE)
@@ -259,10 +283,8 @@ static void kasan_report_error(struct kasan_access_info *info)
 		print_address_description(info);
 		print_shadow_for_address(info->first_bad_addr);
 	}
-	pr_err("==================================================================\n");
-	add_taint(TAINT_BAD_PAGE, LOCKDEP_NOW_UNRELIABLE);
-	spin_unlock_irqrestore(&report_lock, flags);
-	kasan_enable_current();
+
+	kasan_end_report(&flags);
 }
 
 void kasan_report(unsigned long addr, size_t size,
-- 
2.7.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
