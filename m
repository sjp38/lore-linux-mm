Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5A3056B0391
	for <linux-mm@kvack.org>; Mon,  6 Mar 2017 11:00:21 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id u48so66629740wrc.0
        for <linux-mm@kvack.org>; Mon, 06 Mar 2017 08:00:21 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id m5sor9443wme.5.1969.12.31.16.00.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 06 Mar 2017 08:00:20 -0800 (PST)
From: Andrey Konovalov <andreyknvl@google.com>
Subject: [PATCH v3 6/9] kasan: improve slab object description
Date: Mon,  6 Mar 2017 17:00:06 +0100
Message-Id: <294aefecc13340513940ba71a0e1f1db07d3ef4d.1488815789.git.andreyknvl@google.com>
In-Reply-To: <cover.1488815789.git.andreyknvl@google.com>
References: <cover.1488815789.git.andreyknvl@google.com>
In-Reply-To: <cover.1488815789.git.andreyknvl@google.com>
References: <cover.1488815789.git.andreyknvl@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, kasan-dev@googlegroups.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Andrey Konovalov <andreyknvl@google.com>

Changes slab object description from:

Object at ffff880068388540, in cache kmalloc-128 size: 128

to:

Object at ffff880068388540 belongs to cache kmalloc-128 of size 128
Access 123 bytes inside of 128-byte region [ffff880068388540, ffff8800683885c0)

This adds information about relative offset of the accessed address to
the start of the object.

Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
---
 mm/kasan/report.c | 51 ++++++++++++++++++++++++++++++++++++++++-----------
 1 file changed, 40 insertions(+), 11 deletions(-)

diff --git a/mm/kasan/report.c b/mm/kasan/report.c
index 156f998199e2..87f8293d7b79 100644
--- a/mm/kasan/report.c
+++ b/mm/kasan/report.c
@@ -194,18 +194,47 @@ static struct page *addr_to_page(const void *addr)
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
+	if (access_addr < object_addr) {
+		rel_type = "to the left";
+		rel_bytes = object_addr - access_addr;
+	} else if (access_addr >= object_addr + cache->object_size) {
+		rel_type = "to the right";
+		rel_bytes = access_addr - (object_addr + cache->object_size);
+	} else {
+		rel_type = "inside";
+		rel_bytes = access_addr - object_addr;
+	}
+
+	pr_err("Access %d bytes %s of %d-byte region [%p, %p)\n",
+		rel_bytes, rel_type, cache->object_size, (void *)object_addr,
+		(void *)(object_addr + cache->object_size));
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
@@ -217,13 +246,13 @@ void kasan_report_double_free(struct kmem_cache *cache, void *object,
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
@@ -233,9 +262,9 @@ static void print_address_description(struct kasan_access_info *info)
 
 	if (page && PageSlab(page)) {
 		struct kmem_cache *cache = page->slab_cache;
-		void *object = nearest_obj(cache, page,	(void *)addr);
+		void *object = nearest_obj(cache, page,	addr);
 
-		describe_object(cache, object);
+		describe_object(cache, object, addr);
 	}
 
 	if (kernel_or_module_addr(addr)) {
-- 
2.12.0.rc1.440.g5b76565f74-goog

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
