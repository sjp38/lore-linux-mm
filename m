Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f171.google.com (mail-pf0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id 817016B0254
	for <linux-mm@kvack.org>; Tue,  8 Dec 2015 14:59:55 -0500 (EST)
Received: by pfdd184 with SMTP id d184so17005720pfd.3
        for <linux-mm@kvack.org>; Tue, 08 Dec 2015 11:59:55 -0800 (PST)
Received: from mail-pf0-x22c.google.com (mail-pf0-x22c.google.com. [2607:f8b0:400e:c00::22c])
        by mx.google.com with ESMTPS id f2si7106409pfj.59.2015.12.08.11.59.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 08 Dec 2015 11:59:54 -0800 (PST)
Received: by pfnn128 with SMTP id n128so17049061pfn.0
        for <linux-mm@kvack.org>; Tue, 08 Dec 2015 11:59:54 -0800 (PST)
From: Yang Shi <yang.shi@linaro.org>
Subject: [PATCH v3 1/7] trace/events: Add gup trace events
Date: Tue,  8 Dec 2015 11:39:49 -0800
Message-Id: <1449603595-718-2-git-send-email-yang.shi@linaro.org>
In-Reply-To: <1449603595-718-1-git-send-email-yang.shi@linaro.org>
References: <1449603595-718-1-git-send-email-yang.shi@linaro.org>
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
index 0000000..7575930
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
+	TP_PROTO(unsigned long start, unsigned long nr_pages),
+
+	TP_ARGS(start, nr_pages),
+
+	TP_STRUCT__entry(
+		__field(	unsigned long,	start		)
+		__field(	unsigned long,	nr_pages	)
+	),
+
+	TP_fast_assign(
+		__entry->start		= start;
+		__entry->nr_pages	= nr_pages;
+	),
+
+	TP_printk("start=%lx nr_pages=%lu", __entry->start, __entry->nr_pages)
+);
+
+DEFINE_EVENT(gup, gup_get_user_pages,
+
+	TP_PROTO(unsigned long start, unsigned long nr_pages),
+
+	TP_ARGS(start, nr_pages)
+);
+
+DEFINE_EVENT(gup, gup_get_user_pages_fast,
+
+	TP_PROTO(unsigned long start, unsigned long nr_pages),
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
