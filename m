Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1F4A96B0359
	for <linux-mm@kvack.org>; Fri, 24 Mar 2017 15:32:43 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id 20so7225144wrx.6
        for <linux-mm@kvack.org>; Fri, 24 Mar 2017 12:32:43 -0700 (PDT)
Received: from mail-wr0-x22c.google.com (mail-wr0-x22c.google.com. [2a00:1450:400c:c0c::22c])
        by mx.google.com with ESMTPS id i63si4349919wmd.135.2017.03.24.12.32.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 Mar 2017 12:32:41 -0700 (PDT)
Received: by mail-wr0-x22c.google.com with SMTP id y90so8023470wrb.0
        for <linux-mm@kvack.org>; Fri, 24 Mar 2017 12:32:41 -0700 (PDT)
From: Andrey Konovalov <andreyknvl@google.com>
Subject: [PATCH v4 4/9] kasan: simplify address description logic
Date: Fri, 24 Mar 2017 20:32:30 +0100
Message-Id: <91b198a9825326a3f3e9037df60d49704f5479ad.1490383597.git.andreyknvl@google.com>
In-Reply-To: <cover.1490383597.git.andreyknvl@google.com>
References: <cover.1490383597.git.andreyknvl@google.com>
In-Reply-To: <cover.1490383597.git.andreyknvl@google.com>
References: <cover.1490383597.git.andreyknvl@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, kasan-dev@googlegroups.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Andrey Konovalov <andreyknvl@google.com>

Simplify logic for describing a memory address.
Add addr_to_page() helper function.

Makes the code easier to follow.

Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
---
 mm/kasan/report.c | 36 ++++++++++++++++++++----------------
 1 file changed, 20 insertions(+), 16 deletions(-)

diff --git a/mm/kasan/report.c b/mm/kasan/report.c
index 382d4d2b9052..f77341979dae 100644
--- a/mm/kasan/report.c
+++ b/mm/kasan/report.c
@@ -188,11 +188,17 @@ static void print_track(struct kasan_track *track, const char *prefix)
 	}
 }
 
-static void kasan_object_err(struct kmem_cache *cache, void *object)
+static struct page *addr_to_page(const void *addr)
+{
+	if ((addr >= (void *)PAGE_OFFSET) && (addr < high_memory))
+		return virt_to_head_page(addr);
+	return NULL;
+}
+
+static void describe_object(struct kmem_cache *cache, void *object)
 {
 	struct kasan_alloc_meta *alloc_info = get_alloc_info(cache, object);
 
-	dump_stack();
 	pr_err("Object at %p, in cache %s size: %d\n", object, cache->name,
 		cache->object_size);
 
@@ -211,34 +217,32 @@ void kasan_report_double_free(struct kmem_cache *cache, void *object,
 	kasan_start_report(&flags);
 	pr_err("BUG: Double free or freeing an invalid pointer\n");
 	pr_err("Unexpected shadow byte: 0x%hhX\n", shadow);
-	kasan_object_err(cache, object);
+	dump_stack();
+	describe_object(cache, object);
 	kasan_end_report(&flags);
 }
 
 static void print_address_description(struct kasan_access_info *info)
 {
 	const void *addr = info->access_addr;
+	struct page *page = addr_to_page(addr);
 
-	if ((addr >= (void *)PAGE_OFFSET) &&
-		(addr < high_memory)) {
-		struct page *page = virt_to_head_page(addr);
-
-		if (PageSlab(page)) {
-			void *object;
-			struct kmem_cache *cache = page->slab_cache;
-			object = nearest_obj(cache, page,
-						(void *)info->access_addr);
-			kasan_object_err(cache, object);
-			return;
-		}
+	if (page)
 		dump_page(page, "kasan: bad access detected");
+
+	dump_stack();
+
+	if (page && PageSlab(page)) {
+		struct kmem_cache *cache = page->slab_cache;
+		void *object = nearest_obj(cache, page,	(void *)addr);
+
+		describe_object(cache, object);
 	}
 
 	if (kernel_or_module_addr(addr)) {
 		if (!init_task_stack_addr(addr))
 			pr_err("Address belongs to variable %pS\n", addr);
 	}
-	dump_stack();
 }
 
 static bool row_is_guilty(const void *row, const void *guilty)
-- 
2.12.1.578.ge9c3154ca4-goog

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
