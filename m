Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 185756B038E
	for <linux-mm@kvack.org>; Thu,  2 Mar 2017 08:49:09 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id n11so10420107wma.5
        for <linux-mm@kvack.org>; Thu, 02 Mar 2017 05:49:09 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id h185sor32214wmg.3.1969.12.31.16.00.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 02 Mar 2017 05:49:07 -0800 (PST)
From: Andrey Konovalov <andreyknvl@google.com>
Subject: [PATCH v2 8/9] kasan: improve double-free report format
Date: Thu,  2 Mar 2017 14:48:50 +0100
Message-Id: <20170302134851.101218-9-andreyknvl@google.com>
In-Reply-To: <20170302134851.101218-1-andreyknvl@google.com>
References: <20170302134851.101218-1-andreyknvl@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, kasan-dev@googlegroups.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Andrey Konovalov <andreyknvl@google.com>

Changes double-free report header from:

BUG: Double free or freeing an invalid pointer
Unexpected shadow byte: 0xFB

to:

BUG: KASAN: double-free or invalid-free in kmalloc_oob_left+0xe5/0xef

This makes a bug uniquely identifiable by the first report line.
To account for removing of the unexpected shadow value, print shadow
bytes at the end of the report as in reports for other kinds of bugs.

Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
---
 mm/kasan/kasan.c  |  3 ++-
 mm/kasan/kasan.h  |  2 +-
 mm/kasan/report.c | 30 ++++++++++++++----------------
 3 files changed, 17 insertions(+), 18 deletions(-)

diff --git a/mm/kasan/kasan.c b/mm/kasan/kasan.c
index 25f0e6521f36..bd89fe06bb86 100644
--- a/mm/kasan/kasan.c
+++ b/mm/kasan/kasan.c
@@ -566,7 +566,8 @@ bool kasan_slab_free(struct kmem_cache *cache, void *object)
 
 	shadow_byte = READ_ONCE(*(s8 *)kasan_mem_to_shadow(object));
 	if (shadow_byte < 0 || shadow_byte >= KASAN_SHADOW_SCALE_SIZE) {
-		kasan_report_double_free(cache, object, shadow_byte);
+		kasan_report_double_free(cache, object,
+				__builtin_return_address(1));
 		return true;
 	}
 
diff --git a/mm/kasan/kasan.h b/mm/kasan/kasan.h
index 1c260e6b3b3c..75729173ade9 100644
--- a/mm/kasan/kasan.h
+++ b/mm/kasan/kasan.h
@@ -104,7 +104,7 @@ static inline bool kasan_report_enabled(void)
 void kasan_report(unsigned long addr, size_t size,
 		bool is_write, unsigned long ip);
 void kasan_report_double_free(struct kmem_cache *cache, void *object,
-			s8 shadow);
+					void *ip);
 
 #if defined(CONFIG_SLAB) || defined(CONFIG_SLUB)
 void quarantine_put(struct kasan_free_meta *info, struct kmem_cache *cache);
diff --git a/mm/kasan/report.c b/mm/kasan/report.c
index 1d2b15174a98..210131bc0a3c 100644
--- a/mm/kasan/report.c
+++ b/mm/kasan/report.c
@@ -241,22 +241,8 @@ static void describe_object(struct kmem_cache *cache, void *object,
 	describe_object_addr(cache, object, addr);
 }
 
-void kasan_report_double_free(struct kmem_cache *cache, void *object,
-			s8 shadow)
-{
-	unsigned long flags;
-
-	kasan_start_report(&flags);
-	pr_err("BUG: Double free or freeing an invalid pointer\n");
-	pr_err("Unexpected shadow byte: 0x%hhX\n", shadow);
-	dump_stack();
-	describe_object(cache, object, NULL);
-	kasan_end_report(&flags);
-}
-
-static void print_address_description(struct kasan_access_info *info)
+static void print_address_description(void *addr)
 {
-	void *addr = (void *)info->access_addr;
 	struct page *page = addr_to_page(addr);
 
 	dump_stack();
@@ -331,6 +317,18 @@ static void print_shadow_for_address(const void *addr)
 	}
 }
 
+void kasan_report_double_free(struct kmem_cache *cache, void *object,
+				void *ip)
+{
+	unsigned long flags;
+
+	kasan_start_report(&flags);
+	pr_err("BUG: KASAN: double-free or invalid-free in %pS\n", ip);
+	print_address_description(object);
+	print_shadow_for_address(object);
+	kasan_end_report(&flags);
+}
+
 static void kasan_report_error(struct kasan_access_info *info)
 {
 	unsigned long flags;
@@ -342,7 +340,7 @@ static void kasan_report_error(struct kasan_access_info *info)
 	if (!addr_has_shadow(info)) {
 		dump_stack();
 	} else {
-		print_address_description(info);
+		print_address_description((void *)info->access_addr);
 		print_shadow_for_address(info->first_bad_addr);
 	}
 
-- 
2.12.0.rc1.440.g5b76565f74-goog

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
