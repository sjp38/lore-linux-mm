Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 8BF4E6B0038
	for <linux-mm@kvack.org>; Thu, 23 Mar 2017 11:10:12 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id d66so22077329wmi.2
        for <linux-mm@kvack.org>; Thu, 23 Mar 2017 08:10:12 -0700 (PDT)
Received: from mout.kundenserver.de (mout.kundenserver.de. [212.227.126.130])
        by mx.google.com with ESMTPS id h13si7847534wme.149.2017.03.23.08.10.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 23 Mar 2017 08:10:11 -0700 (PDT)
From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] kasan: avoid -Wmaybe-uninitialized warning
Date: Thu, 23 Mar 2017 16:04:09 +0100
Message-Id: <20170323150415.301180-1-arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Arnd Bergmann <arnd@arndb.de>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Andrew Morton <akpm@linux-foundation.org>, Andrey Konovalov <andreyknvl@google.com>, Peter Zijlstra <peterz@infradead.org>, kasan-dev@googlegroups.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

gcc-7 produces this warning:

mm/kasan/report.c: In function 'kasan_report':
mm/kasan/report.c:351:3: error: 'info.first_bad_addr' may be used uninitialized in this function [-Werror=maybe-uninitialized]
   print_shadow_for_address(info->first_bad_addr);
   ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
mm/kasan/report.c:360:27: note: 'info.first_bad_addr' was declared here

The code seems fine as we only print info.first_bad_addr when there is a shadow,
and we always initialize it in that case, but this is relatively hard
for gcc to figure out after the latest rework. Adding an intialization
in the other code path gets rid of the warning.

Fixes: b235b9808664 ("kasan: unify report headers")
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
 mm/kasan/report.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/mm/kasan/report.c b/mm/kasan/report.c
index 718a10a48a19..63de3069dceb 100644
--- a/mm/kasan/report.c
+++ b/mm/kasan/report.c
@@ -109,6 +109,8 @@ const char *get_wild_bug_type(struct kasan_access_info *info)
 {
 	const char *bug_type = "unknown-crash";
 
+	info->first_bad_addr = (void *)(-1ul);
+
 	if ((unsigned long)info->access_addr < PAGE_SIZE)
 		bug_type = "null-ptr-deref";
 	else if ((unsigned long)info->access_addr < TASK_SIZE)
-- 
2.9.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
