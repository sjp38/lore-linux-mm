Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id C558C6B0253
	for <linux-mm@kvack.org>; Tue,  1 Dec 2015 18:26:01 -0500 (EST)
Received: by padhx2 with SMTP id hx2so19964746pad.1
        for <linux-mm@kvack.org>; Tue, 01 Dec 2015 15:26:01 -0800 (PST)
Received: from mail-pa0-x233.google.com (mail-pa0-x233.google.com. [2607:f8b0:400e:c03::233])
        by mx.google.com with ESMTPS id hz13si253011pab.78.2015.12.01.15.26.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 01 Dec 2015 15:26:01 -0800 (PST)
Received: by padhx2 with SMTP id hx2so19964537pad.1
        for <linux-mm@kvack.org>; Tue, 01 Dec 2015 15:26:01 -0800 (PST)
From: Yang Shi <yang.shi@linaro.org>
Subject: [PATCH 1/7] trace/events: Add gup trace events
Date: Tue,  1 Dec 2015 15:06:11 -0800
Message-Id: <1449011177-30686-2-git-send-email-yang.shi@linaro.org>
In-Reply-To: <1449011177-30686-1-git-send-email-yang.shi@linaro.org>
References: <1449011177-30686-1-git-send-email-yang.shi@linaro.org>
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
 include/trace/events/gup.h | 77 ++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 77 insertions(+)
 create mode 100644 include/trace/events/gup.h

diff --git a/include/trace/events/gup.h b/include/trace/events/gup.h
new file mode 100644
index 0000000..37d18f9
--- /dev/null
+++ b/include/trace/events/gup.h
@@ -0,0 +1,77 @@
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
+		__array(	char,	comm,	TASK_COMM_LEN	)
+		__field(	unsigned long,	address		)
+	),
+
+	TP_fast_assign(
+		memcpy(__entry->comm, tsk->comm, TASK_COMM_LEN);
+		__entry->address	= address;
+	),
+
+	TP_printk("comm=%s address=%lx", __entry->comm, __entry->address)
+);
+
+TRACE_EVENT(gup_get_user_pages,
+
+	TP_PROTO(struct task_struct *tsk, struct mm_struct *mm,
+			unsigned long start, unsigned long nr_pages,
+			unsigned int gup_flags, struct page **pages,
+			struct vm_area_struct **vmas, int *nonblocking),
+
+	TP_ARGS(tsk, mm, start, nr_pages, gup_flags, pages, vmas, nonblocking),
+
+	TP_STRUCT__entry(
+		__array(	char,	comm,	TASK_COMM_LEN	)
+		__field(	unsigned long,	start		)
+		__field(	unsigned long,	nr_pages	)
+	),
+
+	TP_fast_assign(
+		memcpy(__entry->comm, tsk->comm, TASK_COMM_LEN);
+		__entry->start		= start;
+		__entry->nr_pages	= nr_pages;
+	),
+
+	TP_printk("comm=%s start=%lx nr_pages=%lu", __entry->comm, __entry->start, __entry->nr_pages)
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
