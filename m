Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 1F6BC6B0254
	for <linux-mm@kvack.org>; Wed,  9 Dec 2015 16:42:23 -0500 (EST)
Received: by pacej9 with SMTP id ej9so35940206pac.2
        for <linux-mm@kvack.org>; Wed, 09 Dec 2015 13:42:22 -0800 (PST)
Received: from mail-pa0-x22d.google.com (mail-pa0-x22d.google.com. [2607:f8b0:400e:c03::22d])
        by mx.google.com with ESMTPS id dw8si15127998pab.16.2015.12.09.13.42.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 Dec 2015 13:42:22 -0800 (PST)
Received: by pacdm15 with SMTP id dm15so35951982pac.3
        for <linux-mm@kvack.org>; Wed, 09 Dec 2015 13:42:22 -0800 (PST)
From: Yang Shi <yang.shi@linaro.org>
Subject: [PATCH v5 1/7] trace/events: Add gup trace events
Date: Wed,  9 Dec 2015 13:22:25 -0800
Message-Id: <1449696151-4195-2-git-send-email-yang.shi@linaro.org>
In-Reply-To: <1449696151-4195-1-git-send-email-yang.shi@linaro.org>
References: <1449696151-4195-1-git-send-email-yang.shi@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, rostedt@goodmis.org, mingo@redhat.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linaro-kernel@lists.linaro.org, yang.shi@linaro.org

page-faults events record the invoke to handle_mm_fault, but the invoke
may come from do_page_fault or gup. In some use cases, the finer event count
mey be needed, so add trace events support for:

__get_user_pages
__get_user_pages_fast
fixup_user_fault

Signed-off-by: Yang Shi <yang.shi@linaro.org>
---
 include/trace/events/gup.h | 63 ++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 63 insertions(+)
 create mode 100644 include/trace/events/gup.h

diff --git a/include/trace/events/gup.h b/include/trace/events/gup.h
new file mode 100644
index 0000000..ac0e011
--- /dev/null
+++ b/include/trace/events/gup.h
@@ -0,0 +1,63 @@
+#undef TRACE_SYSTEM
+#define TRACE_SYSTEM gup
+
+#if !defined(_TRACE_GUP_H) || defined(TRACE_HEADER_MULTI_READ)
+#define _TRACE_GUP_H
+
+#include <linux/types.h>
+#include <linux/tracepoint.h>
+
+TRACE_EVENT(gup_fixup_user_fault,
+
+	TP_PROTO(unsigned long address),
+
+	TP_ARGS(address),
+
+	TP_STRUCT__entry(
+		__field(	unsigned long,	address		)
+	),
+
+	TP_fast_assign(
+		__entry->address	= address;
+	),
+
+	TP_printk("address=%lx",  __entry->address)
+);
+
+DECLARE_EVENT_CLASS(gup,
+
+	TP_PROTO(unsigned long start, unsigned int nr_pages),
+
+	TP_ARGS(start, nr_pages),
+
+	TP_STRUCT__entry(
+		__field(	unsigned long,	start		)
+		__field(	unsigned int,	nr_pages	)
+	),
+
+	TP_fast_assign(
+		__entry->start		= start;
+		__entry->nr_pages	= nr_pages;
+	),
+
+	TP_printk("start=%lx nr_pages=%d", __entry->start, __entry->nr_pages)
+);
+
+DEFINE_EVENT(gup, gup_get_user_pages,
+
+	TP_PROTO(unsigned long start, unsigned int nr_pages),
+
+	TP_ARGS(start, nr_pages)
+);
+
+DEFINE_EVENT(gup, gup_get_user_pages_fast,
+
+	TP_PROTO(unsigned long start, unsigned int nr_pages),
+
+	TP_ARGS(start, nr_pages)
+);
+
+#endif /* _TRACE_GUP_H */
+
+/* This part must be outside protection */
+#include <trace/define_trace.h>
-- 
2.0.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
