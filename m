Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 791CD6B0391
	for <linux-mm@kvack.org>; Mon,  6 Mar 2017 11:00:20 -0500 (EST)
Received: by mail-wr0-f197.google.com with SMTP id w37so67475559wrc.2
        for <linux-mm@kvack.org>; Mon, 06 Mar 2017 08:00:20 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id k110sor66233wrc.17.1969.12.31.16.00.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 06 Mar 2017 08:00:19 -0800 (PST)
From: Andrey Konovalov <andreyknvl@google.com>
Subject: [PATCH v3 5/9] kasan: change report header
Date: Mon,  6 Mar 2017 17:00:05 +0100
Message-Id: <27f193aec3a3680ad6fb5d087e971cfbd4a9c2ca.1488815789.git.andreyknvl@google.com>
In-Reply-To: <cover.1488815789.git.andreyknvl@google.com>
References: <cover.1488815789.git.andreyknvl@google.com>
In-Reply-To: <cover.1488815789.git.andreyknvl@google.com>
References: <cover.1488815789.git.andreyknvl@google.com>
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
 mm/kasan/report.c | 7 +++----
 1 file changed, 3 insertions(+), 4 deletions(-)

diff --git a/mm/kasan/report.c b/mm/kasan/report.c
index f77341979dae..156f998199e2 100644
--- a/mm/kasan/report.c
+++ b/mm/kasan/report.c
@@ -130,11 +130,10 @@ static void print_error_description(struct kasan_access_info *info)
 {
 	const char *bug_type = get_bug_type(info);
 
-	pr_err("BUG: KASAN: %s in %pS at addr %p\n",
-		bug_type, (void *)info->ip, info->access_addr);
-	pr_err("%s of size %zu by task %s/%d\n",
+	pr_err("BUG: KASAN: %s in %pS\n", bug_type, (void *)info->ip);
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
