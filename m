Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 8EE3D6B038D
	for <linux-mm@kvack.org>; Thu,  2 Mar 2017 08:49:09 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id u108so16509044wrb.3
        for <linux-mm@kvack.org>; Thu, 02 Mar 2017 05:49:09 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id n16sor37119wra.18.1969.12.31.16.00.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 02 Mar 2017 05:49:08 -0800 (PST)
From: Andrey Konovalov <andreyknvl@google.com>
Subject: [PATCH v2 9/9] kasan: separate report parts by empty lines
Date: Thu,  2 Mar 2017 14:48:51 +0100
Message-Id: <20170302134851.101218-10-andreyknvl@google.com>
In-Reply-To: <20170302134851.101218-1-andreyknvl@google.com>
References: <20170302134851.101218-1-andreyknvl@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, kasan-dev@googlegroups.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Andrey Konovalov <andreyknvl@google.com>

Makes the report easier to read.

Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
---
 mm/kasan/report.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/mm/kasan/report.c b/mm/kasan/report.c
index 210131bc0a3c..718a10a48a19 100644
--- a/mm/kasan/report.c
+++ b/mm/kasan/report.c
@@ -235,7 +235,9 @@ static void describe_object(struct kmem_cache *cache, void *object,
 
 	if (cache->flags & SLAB_KASAN) {
 		print_track(&alloc_info->alloc_track, "Allocated");
+		pr_err("\n");
 		print_track(&alloc_info->free_track, "Freed");
+		pr_err("\n");
 	}
 
 	describe_object_addr(cache, object, addr);
@@ -246,6 +248,7 @@ static void print_address_description(void *addr)
 	struct page *page = addr_to_page(addr);
 
 	dump_stack();
+	pr_err("\n");
 
 	if (page && PageSlab(page)) {
 		struct kmem_cache *cache = page->slab_cache;
@@ -324,7 +327,9 @@ void kasan_report_double_free(struct kmem_cache *cache, void *object,
 
 	kasan_start_report(&flags);
 	pr_err("BUG: KASAN: double-free or invalid-free in %pS\n", ip);
+	pr_err("\n");
 	print_address_description(object);
+	pr_err("\n");
 	print_shadow_for_address(object);
 	kasan_end_report(&flags);
 }
@@ -336,11 +341,13 @@ static void kasan_report_error(struct kasan_access_info *info)
 	kasan_start_report(&flags);
 
 	print_error_description(info);
+	pr_err("\n");
 
 	if (!addr_has_shadow(info)) {
 		dump_stack();
 	} else {
 		print_address_description((void *)info->access_addr);
+		pr_err("\n");
 		print_shadow_for_address(info->first_bad_addr);
 	}
 
-- 
2.12.0.rc1.440.g5b76565f74-goog

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
