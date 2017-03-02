Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2B3E96B038F
	for <linux-mm@kvack.org>; Thu,  2 Mar 2017 08:49:11 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id n11so10420395wma.5
        for <linux-mm@kvack.org>; Thu, 02 Mar 2017 05:49:11 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id f76sor32149wmd.0.1969.12.31.16.00.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 02 Mar 2017 05:49:10 -0800 (PST)
From: Andrey Konovalov <andreyknvl@google.com>
Subject: [PATCH v2 7/9] kasan: print page description after stacks
Date: Thu,  2 Mar 2017 14:48:49 +0100
Message-Id: <20170302134851.101218-8-andreyknvl@google.com>
In-Reply-To: <20170302134851.101218-1-andreyknvl@google.com>
References: <20170302134851.101218-1-andreyknvl@google.com>
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
index 8dfb7a060d69..1d2b15174a98 100644
--- a/mm/kasan/report.c
+++ b/mm/kasan/report.c
@@ -259,9 +259,6 @@ static void print_address_description(struct kasan_access_info *info)
 	void *addr = (void *)info->access_addr;
 	struct page *page = addr_to_page(addr);
 
-	if (page)
-		dump_page(page, "kasan: bad access detected");
-
 	dump_stack();
 
 	if (page && PageSlab(page)) {
@@ -271,9 +268,14 @@ static void print_address_description(struct kasan_access_info *info)
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
