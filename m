Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 89E816B0376
	for <linux-mm@kvack.org>; Fri, 24 Mar 2017 15:32:46 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id b16so3902618wmi.14
        for <linux-mm@kvack.org>; Fri, 24 Mar 2017 12:32:46 -0700 (PDT)
Received: from mail-wm0-x22c.google.com (mail-wm0-x22c.google.com. [2a00:1450:400c:c09::22c])
        by mx.google.com with ESMTPS id m197si4358345wmd.63.2017.03.24.12.32.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 Mar 2017 12:32:45 -0700 (PDT)
Received: by mail-wm0-x22c.google.com with SMTP id n11so10107289wma.0
        for <linux-mm@kvack.org>; Fri, 24 Mar 2017 12:32:45 -0700 (PDT)
From: Andrey Konovalov <andreyknvl@google.com>
Subject: [PATCH v4 9/9] kasan: separate report parts by empty lines
Date: Fri, 24 Mar 2017 20:32:35 +0100
Message-Id: <b0d3a20a010c7b50367b06c9e840d18680f31a02.1490383597.git.andreyknvl@google.com>
In-Reply-To: <cover.1490383597.git.andreyknvl@google.com>
References: <cover.1490383597.git.andreyknvl@google.com>
In-Reply-To: <cover.1490383597.git.andreyknvl@google.com>
References: <cover.1490383597.git.andreyknvl@google.com>
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
index 2368b8cf5f95..a79fc1036161 100644
--- a/mm/kasan/report.c
+++ b/mm/kasan/report.c
@@ -218,7 +218,9 @@ static void describe_object(struct kmem_cache *cache, void *object,
 
 	if (cache->flags & SLAB_KASAN) {
 		print_track(&alloc_info->alloc_track, "Allocated");
+		pr_err("\n");
 		print_track(&alloc_info->free_track, "Freed");
+		pr_err("\n");
 	}
 
 	describe_object_addr(cache, object, addr);
@@ -229,6 +231,7 @@ static void print_address_description(void *addr)
 	struct page *page = addr_to_page(addr);
 
 	dump_stack();
+	pr_err("\n");
 
 	if (page && PageSlab(page)) {
 		struct kmem_cache *cache = page->slab_cache;
@@ -307,7 +310,9 @@ void kasan_report_double_free(struct kmem_cache *cache, void *object,
 
 	kasan_start_report(&flags);
 	pr_err("BUG: KASAN: double-free or invalid-free in %pS\n", ip);
+	pr_err("\n");
 	print_address_description(object);
+	pr_err("\n");
 	print_shadow_for_address(object);
 	kasan_end_report(&flags);
 }
@@ -319,11 +324,13 @@ static void kasan_report_error(struct kasan_access_info *info)
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
2.12.1.578.ge9c3154ca4-goog

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
