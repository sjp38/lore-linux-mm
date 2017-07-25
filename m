Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id E0FBF6B02F3
	for <linux-mm@kvack.org>; Tue, 25 Jul 2017 11:27:44 -0400 (EDT)
Received: by mail-wr0-f200.google.com with SMTP id q50so28715996wrb.14
        for <linux-mm@kvack.org>; Tue, 25 Jul 2017 08:27:44 -0700 (PDT)
Received: from mout.kundenserver.de (mout.kundenserver.de. [212.227.17.24])
        by mx.google.com with ESMTPS id 61si8997182wrg.24.2017.07.25.08.27.43
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 25 Jul 2017 08:27:43 -0700 (PDT)
From: Arnd Bergmann <arnd@arndb.de>
Subject: [PATCH] [v3] kasan: avoid -Wmaybe-uninitialized warning
Date: Tue, 25 Jul 2017 17:27:29 +0200
Message-Id: <20170725152739.4176967-1-arnd@arndb.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Arnd Bergmann <arnd@arndb.de>, Dmitry Vyukov <dvyukov@google.com>, Alexander Potapenko <glider@google.com>, Andrew Morton <akpm@linux-foundation.org>, Andrey Konovalov <andreyknvl@google.com>, Mark Rutland <mark.rutland@arm.com>, kasan-dev@googlegroups.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

gcc-7 produces this warning:

mm/kasan/report.c: In function 'kasan_report':
mm/kasan/report.c:351:3: error: 'info.first_bad_addr' may be used uninitialized in this function [-Werror=maybe-uninitialized]
   print_shadow_for_address(info->first_bad_addr);
   ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
mm/kasan/report.c:360:27: note: 'info.first_bad_addr' was declared here

The code seems fine as we only print info.first_bad_addr when there is a shadow,
and we always initialize it in that case, but this is relatively hard
for gcc to figure out after the latest rework. Adding an intialization
to the most likely value together with the other struct members
shuts up that warning.

Fixes: b235b9808664 ("kasan: unify report headers")
Link: https://patchwork.kernel.org/patch/9641417/
Suggested-by: Alexander Potapenko <glider@google.com>
Suggested-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Dmitry Vyukov <dvyukov@google.com>
Signed-off-by: Arnd Bergmann <arnd@arndb.de>
---
Originally submitted on March 23, but unfortunately is still needed,
as verified on 4.13-rc1, with aarch64-linux-gcc-7.1.1

v2: add a comment as Andrew suggested
v3: move initialization as Alexander and Andrey suggested
---
 mm/kasan/report.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/mm/kasan/report.c b/mm/kasan/report.c
index 04bb1d3eb9ec..6bcfb01ba038 100644
--- a/mm/kasan/report.c
+++ b/mm/kasan/report.c
@@ -401,6 +401,7 @@ void kasan_report(unsigned long addr, size_t size,
 	disable_trace_on_warning();
 
 	info.access_addr = (void *)addr;
+	info.first_bad_addr = (void *)addr;
 	info.access_size = size;
 	info.is_write = is_write;
 	info.ip = ip;
-- 
2.9.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
