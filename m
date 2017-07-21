Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5DE9F6B0292
	for <linux-mm@kvack.org>; Fri, 21 Jul 2017 17:02:56 -0400 (EDT)
Received: by mail-wr0-f198.google.com with SMTP id p12so18098308wrc.8
        for <linux-mm@kvack.org>; Fri, 21 Jul 2017 14:02:56 -0700 (PDT)
Received: from mout.kundenserver.de (mout.kundenserver.de. [217.72.192.73])
        by mx.google.com with ESMTPS id g2si8292617wrc.311.2017.07.21.14.02.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Jul 2017 14:02:55 -0700 (PDT)
From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] [v2] kasan: avoid -Wmaybe-uninitialized warning
Date: Fri, 21 Jul 2017 23:02:37 +0200
Message-Id: <20170721210251.3378996-1-arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Arnd Bergmann <arnd@arndb.de>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Andrew Morton <akpm@linux-foundation.org>, Andrey Konovalov <andreyknvl@google.com>, kasan-dev@googlegroups.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

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
Link: https://patchwork.kernel.org/patch/9641417/
Acked-by: Dmitry Vyukov <dvyukov@google.com>
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
Originally submitted on March 23, but unfortunately is still needed,
as verified on 4.13-rc1, with aarch64-linux-gcc-7.1.1

v2: add a comment as Andrew suggested
---
 mm/kasan/report.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/mm/kasan/report.c b/mm/kasan/report.c
index 04bb1d3eb9ec..28fb222ab149 100644
--- a/mm/kasan/report.c
+++ b/mm/kasan/report.c
@@ -111,6 +111,9 @@ static const char *get_wild_bug_type(struct kasan_access_info *info)
 {
 	const char *bug_type = "unknown-crash";
 
+	/* shut up spurious -Wmaybe-uninitialized warning */
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
