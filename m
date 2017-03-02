Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 2F31F6B0388
	for <linux-mm@kvack.org>; Thu,  2 Mar 2017 08:49:06 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id v66so29133321wrc.4
        for <linux-mm@kvack.org>; Thu, 02 Mar 2017 05:49:06 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id u15sor37118wru.12.1969.12.31.16.00.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 02 Mar 2017 05:49:05 -0800 (PST)
From: Andrey Konovalov <andreyknvl@google.com>
Subject: [PATCH v2 5/9] kasan: change report header
Date: Thu,  2 Mar 2017 14:48:47 +0100
Message-Id: <20170302134851.101218-6-andreyknvl@google.com>
In-Reply-To: <20170302134851.101218-1-andreyknvl@google.com>
References: <20170302134851.101218-1-andreyknvl@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, kasan-dev@googlegroups.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Andrey Konovalov <andreyknvl@google.com>

Change report header format from:

BUG: KASAN: use-after-free in unwind_get_return_address+0x28a/0x2c0 at addr ffff880069437950
Read of size 8 by task insmod/3925

to:

BUG: KASAN: use-after-free in unwind_get_return_address+0x28a/0x2c0
Read of size 8 at addr ffff880069437950 by task insmod/3925

The exact access address is not usually important, so move it to the
second line. This also makes the header look visually balanced.

Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
---
 mm/kasan/report.c | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/mm/kasan/report.c b/mm/kasan/report.c
index 8b0b27eb37cd..945d0e13e8a4 100644
--- a/mm/kasan/report.c
+++ b/mm/kasan/report.c
@@ -130,11 +130,11 @@ static void print_error_description(struct kasan_access_info *info)
 {
 	const char *bug_type = get_bug_type(info);
 
-	pr_err("BUG: KASAN: %s in %pS at addr %p\n",
-		bug_type, (void *)info->ip, info->access_addr);
-	pr_err("%s of size %zu by task %s/%d\n",
+	pr_err("BUG: KASAN: %s in %pS\n",
+		bug_type, (void *)info->ip);
+	pr_err("%s of size %zu at addr %p by task %s/%d\n",
 		info->is_write ? "Write" : "Read", info->access_size,
-		current->comm, task_pid_nr(current));
+		info->access_addr, current->comm, task_pid_nr(current));
 }
 
 static inline bool kernel_or_module_addr(const void *addr)
-- 
2.12.0.rc1.440.g5b76565f74-goog

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
