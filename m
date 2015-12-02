Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id A99426B0253
	for <linux-mm@kvack.org>; Wed,  2 Dec 2015 18:13:22 -0500 (EST)
Received: by pacej9 with SMTP id ej9so53657339pac.2
        for <linux-mm@kvack.org>; Wed, 02 Dec 2015 15:13:22 -0800 (PST)
Received: from mail-pa0-x229.google.com (mail-pa0-x229.google.com. [2607:f8b0:400e:c03::229])
        by mx.google.com with ESMTPS id 83si7599117pfl.23.2015.12.02.15.13.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 02 Dec 2015 15:13:21 -0800 (PST)
Received: by pabfh17 with SMTP id fh17so55173665pab.0
        for <linux-mm@kvack.org>; Wed, 02 Dec 2015 15:13:21 -0800 (PST)
From: Yang Shi <yang.shi@linaro.org>
Subject: [PATCH V2 1/7] trace/events: Add gup trace events
Date: Wed,  2 Dec 2015 14:53:27 -0800
Message-Id: <1449096813-22436-2-git-send-email-yang.shi@linaro.org>
In-Reply-To: <1449096813-22436-1-git-send-email-yang.shi@linaro.org>
References: <1449096813-22436-1-git-send-email-yang.shi@linaro.org>
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
 include/trace/events/gup.h | 71 ++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 71 insertions(+)
 create mode 100644 include/trace/events/gup.h

diff --git a/include/trace/events/gup.h b/include/trace/events/gup.h
new file mode 100644
index 0000000..03a4674
--- /dev/null
+++ b/include/trace/events/gup.h
@@ -0,0 +1,71 @@
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
+	TP_PROTO(struct task_struct *tsk, struct mm_struct *mm,
+			unsigned long address, unsigned int fault_flags),
+
+	TP_ARGS(tsk, mm, address, fault_flags),
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
+TRACE_EVENT(gup_get_user_pages,
+
+	TP_PROTO(struct task_struct *tsk, struct mm_struct *mm,
+			unsigned long start, unsigned long nr_pages),
+
+	TP_ARGS(tsk, mm, start, nr_pages),
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
+TRACE_EVENT(gup_get_user_pages_fast,
+
+	TP_PROTO(unsigned long start, int nr_pages, int write,
+			struct page **pages),
+
+	TP_ARGS(start, nr_pages, write, pages),
+
+	TP_STRUCT__entry(
+		__field(	unsigned long,	start		)
+		__field(	unsigned long,	nr_pages	)
+	),
+
+	TP_fast_assign(
+		__entry->start  	= start;
+		__entry->nr_pages	= nr_pages;
+	),
+
+	TP_printk("start=%lx nr_pages=%lu",  __entry->start, __entry->nr_pages)
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
