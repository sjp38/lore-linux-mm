Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f200.google.com (mail-wr0-f200.google.com [209.85.128.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1A1996B0033
	for <linux-mm@kvack.org>; Fri, 19 Jan 2018 12:44:28 -0500 (EST)
Received: by mail-wr0-f200.google.com with SMTP id p4so1721920wrf.4
        for <linux-mm@kvack.org>; Fri, 19 Jan 2018 09:44:28 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f199sor554476wme.71.2018.01.19.09.44.26
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 19 Jan 2018 09:44:26 -0800 (PST)
From: Andrey Konovalov <andreyknvl@google.com>
Subject: [PATCH] kasan: add __asan_report_loadN/storeN_noabort callbacks
Date: Fri, 19 Jan 2018 18:44:22 +0100
Message-Id: <891fbd1fe77f46701fb1958e77bdd89651c12643.1516383788.git.andreyknvl@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, kasan-dev@googlegroups.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Kostya Serebryany <kcc@google.com>, Evgeniy Stepanov <eugenis@google.com>, Andrey Konovalov <andreyknvl@google.com>

Instead of __asan_report_load_n_noabort and __asan_report_store_n_noabort
callbacks Clang emits differently named __asan_report_loadN_noabort and
__asan_report_storeN_noabort (similar to __asan_loadN/storeN_noabort, whose
names both GCC and Clang agree on).

Add callback implementation for __asan_report_loadN/storeN_noabort.

Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
---
 mm/kasan/report.c | 12 ++++++++++++
 1 file changed, 12 insertions(+)

diff --git a/mm/kasan/report.c b/mm/kasan/report.c
index eff12e040498..caf4c9e948c6 100644
--- a/mm/kasan/report.c
+++ b/mm/kasan/report.c
@@ -450,3 +450,15 @@ void __asan_report_store_n_noabort(unsigned long addr, size_t size)
 	kasan_report(addr, size, true, _RET_IP_);
 }
 EXPORT_SYMBOL(__asan_report_store_n_noabort);
+
+void __asan_report_loadN_noabort(unsigned long addr, size_t size)
+{
+	kasan_report(addr, size, false, _RET_IP_);
+}
+EXPORT_SYMBOL(__asan_report_loadN_noabort);
+
+void __asan_report_storeN_noabort(unsigned long addr, size_t size)
+{
+	kasan_report(addr, size, true, _RET_IP_);
+}
+EXPORT_SYMBOL(__asan_report_storeN_noabort);
-- 
2.16.0.rc1.238.g530d649a79-goog

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
