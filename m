Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id C6A776006F5
	for <linux-mm@kvack.org>; Thu,  8 Jul 2010 10:05:40 -0400 (EDT)
Received: by wyj26 with SMTP id 26so656308wyj.14
        for <linux-mm@kvack.org>; Thu, 08 Jul 2010 07:05:37 -0700 (PDT)
From: Eric B Munson <emunson@mgebm.net>
Subject: [PATCH] Add trace event for munmap
Date: Thu,  8 Jul 2010 15:05:31 +0100
Message-Id: <1278597931-26855-1-git-send-email-emunson@mgebm.net>
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: mingo@redhat.com, hugh.dickins@tiscali.co.uk, riel@redhat.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, peterz@infradead.org, anton@samba.org, Eric B Munson <emunson@mgebm.net>
List-ID: <linux-mm.kvack.org>

This patch adds a trace event for munmap which will record the starting
address of the unmapped area and the length of the umapped area.  This
event will be used for modeling memory usage.

Signed-of-by: Eric B Munson <emunson@mgebm.net>
---
 include/trace/events/mm.h |   30 ++++++++++++++++++++++++++++++
 mm/mmap.c                 |    5 +++++
 2 files changed, 35 insertions(+), 0 deletions(-)
 create mode 100644 include/trace/events/mm.h

diff --git a/include/trace/events/mm.h b/include/trace/events/mm.h
new file mode 100644
index 0000000..c3a3857
--- /dev/null
+++ b/include/trace/events/mm.h
@@ -0,0 +1,30 @@
+#if !defined(_TRACE_MM_H) || defined(TRACE_HEADER_MULTI_READ)
+#define _TRACE_MM_H_
+
+#include <linux/tracepoint.h>
+
+#undef TRACE_SYSTEM
+#define TRACE_SYSTEM mm
+
+TRACE_EVENT(munmap,
+	TP_PROTO(unsigned long start, size_t len),
+
+	TP_ARGS(start, len),
+
+	TP_STRUCT__entry(
+		__field(unsigned long, start)
+		__field(size_t, len)
+	),
+
+	TP_fast_assign(
+		__entry->start = start;
+		__entry->len = len;
+	),
+
+	TP_printk("unmapping %u bytes at %lu\n", __entry->len, __entry->start)
+);
+
+#endif /* _TRACE_MM_H_ */
+
+/* This part must be outside protection */
+#include <trace/define_trace.h>
diff --git a/mm/mmap.c b/mm/mmap.c
index 456ec6f..0775a30 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -29,6 +29,9 @@
 #include <linux/mmu_notifier.h>
 #include <linux/perf_event.h>
 
+#define CREATE_TRACE_POINTS
+#include <trace/events/mm.h>
+
 #include <asm/uaccess.h>
 #include <asm/cacheflush.h>
 #include <asm/tlb.h>
@@ -2079,6 +2082,8 @@ int do_munmap(struct mm_struct *mm, unsigned long start, size_t len)
 		}
 	}
 
+	trace_munmap(start, len);
+
 	/*
 	 * Remove the vma's, and unmap the actual pages
 	 */
-- 
1.7.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
