Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 5FC816B0371
	for <linux-mm@kvack.org>; Fri, 24 Mar 2017 15:32:45 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id x124so7670573wmf.1
        for <linux-mm@kvack.org>; Fri, 24 Mar 2017 12:32:45 -0700 (PDT)
Received: from mail-wr0-x22d.google.com (mail-wr0-x22d.google.com. [2a00:1450:400c:c0c::22d])
        by mx.google.com with ESMTPS id l28si4683676wrl.237.2017.03.24.12.32.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 Mar 2017 12:32:44 -0700 (PDT)
Received: by mail-wr0-x22d.google.com with SMTP id u108so7958294wrb.3
        for <linux-mm@kvack.org>; Fri, 24 Mar 2017 12:32:43 -0700 (PDT)
From: Andrey Konovalov <andreyknvl@google.com>
Subject: [PATCH v4 6/9] kasan: improve slab object description
Date: Fri, 24 Mar 2017 20:32:32 +0100
Message-Id: <5ee51ce71c19e681d1e9bf10fb7632729bedd202.1490383597.git.andreyknvl@google.com>
In-Reply-To: <cover.1490383597.git.andreyknvl@google.com>
References: <cover.1490383597.git.andreyknvl@google.com>
In-Reply-To: <cover.1490383597.git.andreyknvl@google.com>
References: <cover.1490383597.git.andreyknvl@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, kasan-dev@googlegroups.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Andrey Konovalov <andreyknvl@google.com>

Changes slab object description from:

Object at ffff880068388540, in cache kmalloc-128 size: 128

to:

Object at ffff88006a2d5a80 belongs to cache kmalloc-128 of size 128
 accessed at offset 123

This adds information about relative offset of the accessed address to
the start of the object.

Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
---
 mm/kasan/report.c | 38 +++++++++++++++++++++++++++-----------
 1 file changed, 27 insertions(+), 11 deletions(-)

diff --git a/mm/kasan/report.c b/mm/kasan/report.c
index 156f998199e2..06e27a342d1d 100644
--- a/mm/kasan/report.c
+++ b/mm/kasan/report.c
@@ -194,18 +194,34 @@ static struct page *addr_to_page(const void *addr)
 	return NULL;
 }
 
-static void describe_object(struct kmem_cache *cache, void *object)
+static void describe_object_addr(struct kmem_cache *cache, void *object,
+				const void *addr)
 {
-	struct kasan_alloc_meta *alloc_info = get_alloc_info(cache, object);
+	unsigned long access_addr = (unsigned long)addr;
+	unsigned long object_addr = (unsigned long)object;
+	const char *rel_type;
+	int rel_bytes;
 
-	pr_err("Object at %p, in cache %s size: %d\n", object, cache->name,
-		cache->object_size);
+	pr_err("Object at %p belongs to cache %s of size %d\n",
+		object, cache->name, cache->object_size);
 
-	if (!(cache->flags & SLAB_KASAN))
+	if (!addr)
 		return;
 
-	print_track(&alloc_info->alloc_track, "Allocated");
-	print_track(&alloc_info->free_track, "Freed");
+	pr_err(" accessed at offset %d\n", access_addr - object_addr);
+}
+
+static void describe_object(struct kmem_cache *cache, void *object,
+				const void *addr)
+{
+	struct kasan_alloc_meta *alloc_info = get_alloc_info(cache, object);
+
+	if (cache->flags & SLAB_KASAN) {
+		print_track(&alloc_info->alloc_track, "Allocated");
+		print_track(&alloc_info->free_track, "Freed");
+	}
+
+	describe_object_addr(cache, object, addr);
 }
 
 void kasan_report_double_free(struct kmem_cache *cache, void *object,
@@ -217,13 +233,13 @@ void kasan_report_double_free(struct kmem_cache *cache, void *object,
 	pr_err("BUG: Double free or freeing an invalid pointer\n");
 	pr_err("Unexpected shadow byte: 0x%hhX\n", shadow);
 	dump_stack();
-	describe_object(cache, object);
+	describe_object(cache, object, NULL);
 	kasan_end_report(&flags);
 }
 
 static void print_address_description(struct kasan_access_info *info)
 {
-	const void *addr = info->access_addr;
+	void *addr = (void *)info->access_addr;
 	struct page *page = addr_to_page(addr);
 
 	if (page)
@@ -233,9 +249,9 @@ static void print_address_description(struct kasan_access_info *info)
 
 	if (page && PageSlab(page)) {
 		struct kmem_cache *cache = page->slab_cache;
-		void *object = nearest_obj(cache, page,	(void *)addr);
+		void *object = nearest_obj(cache, page,	addr);
 
-		describe_object(cache, object);
+		describe_object(cache, object, addr);
 	}
 
 	if (kernel_or_module_addr(addr)) {
-- 
2.12.1.578.ge9c3154ca4-goog

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
