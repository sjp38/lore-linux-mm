Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8A7FA6B0393
	for <linux-mm@kvack.org>; Mon,  6 Mar 2017 11:00:22 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id u9so27254072wme.6
        for <linux-mm@kvack.org>; Mon, 06 Mar 2017 08:00:22 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id e27sor81892wra.15.1969.12.31.16.00.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 06 Mar 2017 08:00:21 -0800 (PST)
From: Andrey Konovalov <andreyknvl@google.com>
Subject: [PATCH v3 7/9] kasan: print page description after stacks
Date: Mon,  6 Mar 2017 17:00:07 +0100
Message-Id: <421a0075dee347435a0ed1457126bc3bd0f1b3af.1488815789.git.andreyknvl@google.com>
In-Reply-To: <cover.1488815789.git.andreyknvl@google.com>
References: <cover.1488815789.git.andreyknvl@google.com>
In-Reply-To: <cover.1488815789.git.andreyknvl@google.com>
References: <cover.1488815789.git.andreyknvl@google.com>
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
index 87f8293d7b79..09a5f5b4bc79 100644
--- a/mm/kasan/report.c
+++ b/mm/kasan/report.c
@@ -255,9 +255,6 @@ static void print_address_description(struct kasan_access_info *info)
 	void *addr = (void *)info->access_addr;
 	struct page *page = addr_to_page(addr);
 
-	if (page)
-		dump_page(page, "kasan: bad access detected");
-
 	dump_stack();
 
 	if (page && PageSlab(page)) {
@@ -267,9 +264,14 @@ static void print_address_description(struct kasan_access_info *info)
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
2.12.0.rc1.440.g5b76565f74-goog

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
