Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id 43E266B029F
	for <linux-mm@kvack.org>; Tue, 28 Nov 2017 02:50:05 -0500 (EST)
Received: by mail-pl0-f69.google.com with SMTP id u14so1840529plm.19
        for <linux-mm@kvack.org>; Mon, 27 Nov 2017 23:50:05 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id u65sor557747pgc.27.2017.11.27.23.50.04
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 27 Nov 2017 23:50:04 -0800 (PST)
From: js1304@gmail.com
Subject: [PATCH 13/18] mm/vchecker: support inline KASAN build
Date: Tue, 28 Nov 2017 16:48:48 +0900
Message-Id: <1511855333-3570-14-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1511855333-3570-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1511855333-3570-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, kasan-dev@googlegroups.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Namhyung Kim <namhyung@kernel.org>, Wengang Wang <wen.gang.wang@oracle.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>

From: Joonsoo Kim <iamjoonsoo.kim@lge.com>

There is no reason not to support inline KASAN build. Support it.

Note that vchecker_check() function is now placed on kasan report function
to support inline build because gcc generates the inline check code and
then directly jump to kasan report function when poisoned value is found.
Name is somewhat misleading but there is no problem in the view of
implementation.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 lib/Kconfig.kasan | 1 -
 mm/kasan/report.c | 8 ++++++++
 2 files changed, 8 insertions(+), 1 deletion(-)

diff --git a/lib/Kconfig.kasan b/lib/Kconfig.kasan
index 51c0a05..d3552f3 100644
--- a/lib/Kconfig.kasan
+++ b/lib/Kconfig.kasan
@@ -63,6 +63,5 @@ config VCHECKER
 	  happens at the area.
 
 	depends on KASAN && DEBUG_FS
-	select KASAN_OUTLINE
 
 endif
diff --git a/mm/kasan/report.c b/mm/kasan/report.c
index 6c83631..3d002aa 100644
--- a/mm/kasan/report.c
+++ b/mm/kasan/report.c
@@ -413,6 +413,8 @@ void kasan_report(unsigned long addr, size_t size,
 #define DEFINE_ASAN_REPORT_LOAD(size)                     \
 void __asan_report_load##size##_noabort(unsigned long addr) \
 {                                                         \
+	if (vchecker_check(addr, size, false, _RET_IP_))  \
+		return;					  \
 	kasan_report(addr, size, false, _RET_IP_);	  \
 }                                                         \
 EXPORT_SYMBOL(__asan_report_load##size##_noabort)
@@ -420,6 +422,8 @@ EXPORT_SYMBOL(__asan_report_load##size##_noabort)
 #define DEFINE_ASAN_REPORT_STORE(size)                     \
 void __asan_report_store##size##_noabort(unsigned long addr) \
 {                                                          \
+	if (vchecker_check(addr, size, true, _RET_IP_))   \
+		return;					  \
 	kasan_report(addr, size, true, _RET_IP_);	   \
 }                                                          \
 EXPORT_SYMBOL(__asan_report_store##size##_noabort)
@@ -437,12 +441,16 @@ DEFINE_ASAN_REPORT_STORE(16);
 
 void __asan_report_load_n_noabort(unsigned long addr, size_t size)
 {
+	if (vchecker_check(addr, size, false, _RET_IP_))
+		return;
 	kasan_report(addr, size, false, _RET_IP_);
 }
 EXPORT_SYMBOL(__asan_report_load_n_noabort);
 
 void __asan_report_store_n_noabort(unsigned long addr, size_t size)
 {
+	if (vchecker_check(addr, size, true, _RET_IP_))
+		return;
 	kasan_report(addr, size, true, _RET_IP_);
 }
 EXPORT_SYMBOL(__asan_report_store_n_noabort);
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
