Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx140.postini.com [74.125.245.140])
	by kanga.kvack.org (Postfix) with SMTP id 3DED06B0070
	for <linux-mm@kvack.org>; Thu,  9 May 2013 02:06:26 -0400 (EDT)
Received: by mail-pa0-f47.google.com with SMTP id kl13so1883332pab.34
        for <linux-mm@kvack.org>; Wed, 08 May 2013 23:06:25 -0700 (PDT)
From: Francis Deslauriers <fdeslaur@gmail.com>
Subject: [page fault tracepoint 1/2] Add page fault trace event definitions
Date: Thu,  9 May 2013 02:05:19 -0400
Message-Id: <1368079520-11015-1-git-send-email-fdeslaur@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, x86@kernel.org, rostedt@goodmis.org, fweisbec@gmail.com
Cc: raphael.beamonte@gmail.com, mathieu.desnoyers@efficios.com, linux-kernel@vger.kernel.org, Francis Deslauriers <fdeslaur@gmail.com>

Add page_fault_entry and page_fault_exit event definitions. It will
allow each architecture to instrument their page faults.

Signed-off-by: Francis Deslauriers <fdeslaur@gmail.com>
Reviewed-by: RaphaA<<l Beamonte <raphael.beamonte@gmail.com>
Reviewed-by: Mathieu Desnoyers <mathieu.desnoyers@efficios.com>
---
 include/trace/events/fault.h |   51 ++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 51 insertions(+)
 create mode 100644 include/trace/events/fault.h

diff --git a/include/trace/events/fault.h b/include/trace/events/fault.h
new file mode 100644
index 0000000..522ddee
--- /dev/null
+++ b/include/trace/events/fault.h
@@ -0,0 +1,51 @@
+#undef TRACE_SYSTEM
+#define TRACE_SYSTEM fault
+
+#if !defined(_TRACE_FAULT_H) || defined(TRACE_HEADER_MULTI_READ)
+#define _TRACE_FAULT_H
+
+#include <linux/tracepoint.h>
+
+TRACE_EVENT(page_fault_entry,
+
+	TP_PROTO(struct pt_regs *regs, unsigned long address,
+					int write_access),
+
+	TP_ARGS(regs, address, write_access),
+
+	TP_STRUCT__entry(
+		__field(	unsigned long,	ip	)
+		__field(	unsigned long,	addr	)
+		__field(	uint8_t,	write	)
+	),
+
+	TP_fast_assign(
+		__entry->ip	= regs ? instruction_pointer(regs) : 0UL;
+		__entry->addr	= address;
+		__entry->write	= !!write_access;
+	),
+
+	TP_printk("ip=%lu addr=%lu write_access=%d",
+		__entry->ip, __entry->addr, __entry->write)
+);
+
+TRACE_EVENT(page_fault_exit,
+
+	TP_PROTO(int result),
+
+	TP_ARGS(result),
+
+	TP_STRUCT__entry(
+		__field(	int,	res	)
+	),
+
+	TP_fast_assign(
+		__entry->res	= result;
+	),
+
+	TP_printk("result=%d", __entry->res)
+);
+
+#endif /* _TRACE_FAULT_H */
+/* This part must be outside protection */
+#include <trace/define_trace.h>
-- 
1.7.10.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
