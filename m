Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 951656B036E
	for <linux-mm@kvack.org>; Fri, 24 Mar 2017 15:32:43 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id t195so4685564wme.11
        for <linux-mm@kvack.org>; Fri, 24 Mar 2017 12:32:43 -0700 (PDT)
Received: from mail-wm0-x232.google.com (mail-wm0-x232.google.com. [2a00:1450:400c:c09::232])
        by mx.google.com with ESMTPS id w75si4380424wmd.74.2017.03.24.12.32.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 Mar 2017 12:32:42 -0700 (PDT)
Received: by mail-wm0-x232.google.com with SMTP id t189so10118421wmt.1
        for <linux-mm@kvack.org>; Fri, 24 Mar 2017 12:32:42 -0700 (PDT)
From: Andrey Konovalov <andreyknvl@google.com>
Subject: [PATCH v4 7/9] kasan: print page description after stacks
Date: Fri, 24 Mar 2017 20:32:33 +0100
Message-Id: <06d2e8e2e4ae9f2794fa8026c292fb90eb9e362c.1490383597.git.andreyknvl@google.com>
In-Reply-To: <cover.1490383597.git.andreyknvl@google.com>
References: <cover.1490383597.git.andreyknvl@google.com>
In-Reply-To: <cover.1490383597.git.andreyknvl@google.com>
References: <cover.1490383597.git.andreyknvl@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, kasan-dev@googlegroups.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Andrey Konovalov <andreyknvl@google.com>

Moves page description after the stacks since it's less important.

Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
---
 mm/kasan/report.c | 14 ++++++++------
 1 file changed, 8 insertions(+), 6 deletions(-)

diff --git a/mm/kasan/report.c b/mm/kasan/report.c
index 06e27a342d1d..e0f7dbf9e883 100644
--- a/mm/kasan/report.c
+++ b/mm/kasan/report.c
@@ -242,9 +242,6 @@ static void print_address_description(struct kasan_access_info *info)
 	void *addr = (void *)info->access_addr;
 	struct page *page = addr_to_page(addr);
 
-	if (page)
-		dump_page(page, "kasan: bad access detected");
-
 	dump_stack();
 
 	if (page && PageSlab(page)) {
@@ -254,9 +251,14 @@ static void print_address_description(struct kasan_access_info *info)
 		describe_object(cache, object, addr);
 	}
 
-	if (kernel_or_module_addr(addr)) {
-		if (!init_task_stack_addr(addr))
-			pr_err("Address belongs to variable %pS\n", addr);
+	if (kernel_or_module_addr(addr) && !init_task_stack_addr(addr)) {
+		pr_err("The buggy address belongs to the variable:\n");
+		pr_err(" %pS\n", addr);
+	}
+
+	if (page) {
+		pr_err("The buggy address belongs to the page:\n");
+		dump_page(page, "kasan: bad access detected");
 	}
 }
 
-- 
2.12.1.578.ge9c3154ca4-goog

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
