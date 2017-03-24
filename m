Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id C48FC6B0372
	for <linux-mm@kvack.org>; Fri, 24 Mar 2017 15:32:44 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id n55so7275114wrn.0
        for <linux-mm@kvack.org>; Fri, 24 Mar 2017 12:32:44 -0700 (PDT)
Received: from mail-wr0-x233.google.com (mail-wr0-x233.google.com. [2a00:1450:400c:c0c::233])
        by mx.google.com with ESMTPS id 52si4725246wru.27.2017.03.24.12.32.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 Mar 2017 12:32:43 -0700 (PDT)
Received: by mail-wr0-x233.google.com with SMTP id u108so7958149wrb.3
        for <linux-mm@kvack.org>; Fri, 24 Mar 2017 12:32:43 -0700 (PDT)
From: Andrey Konovalov <andreyknvl@google.com>
Subject: [PATCH v4 5/9] kasan: change report header
Date: Fri, 24 Mar 2017 20:32:31 +0100
Message-Id: <1cf237df18589bbefc84d850aacb917931028f22.1490383597.git.andreyknvl@google.com>
In-Reply-To: <cover.1490383597.git.andreyknvl@google.com>
References: <cover.1490383597.git.andreyknvl@google.com>
In-Reply-To: <cover.1490383597.git.andreyknvl@google.com>
References: <cover.1490383597.git.andreyknvl@google.com>
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
2.12.1.578.ge9c3154ca4-goog

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
