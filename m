Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 733DD6B0253
	for <linux-mm@kvack.org>; Wed, 25 Jan 2017 11:40:36 -0500 (EST)
Received: by mail-oi0-f69.google.com with SMTP id w144so249655051oiw.0
        for <linux-mm@kvack.org>; Wed, 25 Jan 2017 08:40:36 -0800 (PST)
Received: from EUR01-VE1-obe.outbound.protection.outlook.com (mail-ve1eur01on0100.outbound.protection.outlook.com. [104.47.1.100])
        by mx.google.com with ESMTPS id e5si9166674oih.15.2017.01.25.08.40.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 25 Jan 2017 08:40:35 -0800 (PST)
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Subject: [PATCH v2] kasan: Respect /proc/sys/kernel/traceoff_on_warning
Date: Wed, 25 Jan 2017 19:41:06 +0300
Message-ID: <20170125164106.3514-1-aryabinin@virtuozzo.com>
In-Reply-To: <20170125142524.GQ6515@twins.programming.kicks-ass.net>
References: <20170125142524.GQ6515@twins.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Alexander Potapenko <glider@google.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, Dmitry Vyukov <dvyukov@google.com>, Steven Rostedt <rostedt@goodmis.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>

From: Peter Zijlstra <peterz@infradead.org>

After much waiting I finally reproduced a KASAN issue, only to find my
trace-buffer empty of useful information because it got spooled out :/

Make kasan_report honour the /proc/sys/kernel/traceoff_on_warning
interface.

Signed-off-by: Peter Zijlstra (Intel) <peterz@infradead.org>
Acked-by: Alexander Potapenko <glider@google.com>
Cc: Dmitry Vyukov <dvyukov@google.com>
Cc: Steven Rostedt <rostedt@goodmis.org>
Signed-off-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
---
 mm/kasan/report.c | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/mm/kasan/report.c b/mm/kasan/report.c
index b82b3e2..f479365 100644
--- a/mm/kasan/report.c
+++ b/mm/kasan/report.c
@@ -13,6 +13,7 @@
  *
  */
 
+#include <linux/ftrace.h>
 #include <linux/kernel.h>
 #include <linux/mm.h>
 #include <linux/printk.h>
@@ -300,6 +301,8 @@ void kasan_report(unsigned long addr, size_t size,
 	if (likely(!kasan_report_enabled()))
 		return;
 
+	disable_trace_on_warning();
+
 	info.access_addr = (void *)addr;
 	info.access_size = size;
 	info.is_write = is_write;
-- 
2.10.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
