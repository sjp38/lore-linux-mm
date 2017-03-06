Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 6E2726B039A
	for <linux-mm@kvack.org>; Mon,  6 Mar 2017 11:00:26 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id y90so46755493wrb.1
        for <linux-mm@kvack.org>; Mon, 06 Mar 2017 08:00:26 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id v5sor36540wrc.19.1969.12.31.16.00.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 06 Mar 2017 08:00:25 -0800 (PST)
From: Andrey Konovalov <andreyknvl@google.com>
Subject: [PATCH v3 9/9] kasan: separate report parts by empty lines
Date: Mon,  6 Mar 2017 17:00:09 +0100
Message-Id: <5233c99e63a952ead6624415dc5e213481bc6df9.1488815789.git.andreyknvl@google.com>
In-Reply-To: <cover.1488815789.git.andreyknvl@google.com>
References: <cover.1488815789.git.andreyknvl@google.com>
In-Reply-To: <cover.1488815789.git.andreyknvl@google.com>
References: <cover.1488815789.git.andreyknvl@google.com>
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
index e5b762f4a6a4..2f3ff28b4d76 100644
--- a/mm/kasan/report.c
+++ b/mm/kasan/report.c
@@ -231,7 +231,9 @@ static void describe_object(struct kmem_cache *cache, void *object,
 
 	if (cache->flags & SLAB_KASAN) {
 		print_track(&alloc_info->alloc_track, "Allocated");
+		pr_err("\n");
 		print_track(&alloc_info->free_track, "Freed");
+		pr_err("\n");
 	}
 
 	describe_object_addr(cache, object, addr);
@@ -242,6 +244,7 @@ static void print_address_description(void *addr)
 	struct page *page = addr_to_page(addr);
 
 	dump_stack();
+	pr_err("\n");
 
 	if (page && PageSlab(page)) {
 		struct kmem_cache *cache = page->slab_cache;
@@ -320,7 +323,9 @@ void kasan_report_double_free(struct kmem_cache *cache, void *object,
 
 	kasan_start_report(&flags);
 	pr_err("BUG: KASAN: double-free or invalid-free in %pS\n", ip);
+	pr_err("\n");
 	print_address_description(object);
+	pr_err("\n");
 	print_shadow_for_address(object);
 	kasan_end_report(&flags);
 }
@@ -332,11 +337,13 @@ static void kasan_report_error(struct kasan_access_info *info)
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
