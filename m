Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id EDD6F6B02A3
	for <linux-mm@kvack.org>; Fri,  9 Jul 2010 11:54:05 -0400 (EDT)
Received: by mail-wy0-f169.google.com with SMTP id 26so1846761wyj.14
        for <linux-mm@kvack.org>; Fri, 09 Jul 2010 08:54:04 -0700 (PDT)
From: Eric B Munson <emunson@mgebm.net>
Subject: [PATCH 2/2] Add trace point to mremap
Date: Fri,  9 Jul 2010 16:53:50 +0100
Message-Id: <1278690830-22145-2-git-send-email-emunson@mgebm.net>
In-Reply-To: <1278690830-22145-1-git-send-email-emunson@mgebm.net>
References: <1278690830-22145-1-git-send-email-emunson@mgebm.net>
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: mingo@redhat.com, hugh.dickins@tiscali.co.uk, riel@redhat.com, peterz@infradead.org, anton@samba.org, hch@infradead.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Eric B Munson <emunson@mgebm.net>
List-ID: <linux-mm.kvack.org>

This patch completes the trace point addition to the [m|mre|mun]map
and brk functions.  These trace points will be used by a userspace
tool that models application memory usage.

Signed-off-by: Eric B Munson <emunson@mgebm.net>
---
 include/trace/events/mremap.h |   37 +++++++++++++++++++++++++++++++++++++
 mm/mremap.c                   |    5 +++++
 2 files changed, 42 insertions(+), 0 deletions(-)
 create mode 100644 include/trace/events/mremap.h

diff --git a/include/trace/events/mremap.h b/include/trace/events/mremap.h
new file mode 100644
index 0000000..754a43b
--- /dev/null
+++ b/include/trace/events/mremap.h
@@ -0,0 +1,37 @@
+#if !defined(_TRACE_MREMAP_H) || defined(TRACE_HEADER_MULTI_READ)
+#define _TRACE_MREMAP_H_
+
+#include <linux/tracepoint.h>
+
+#undef TRACE_SYSTEM
+#define TRACE_SYSTEM mremap
+
+TRACE_EVENT(mremap,
+	TP_PROTO(unsigned long addr, unsigned long old_len,
+		 unsigned long new_addr, unsigned long new_len),
+
+	TP_ARGS(addr, old_len, new_addr, new_len),
+
+	TP_STRUCT__entry(
+		__field(unsigned long, addr)
+		__field(unsigned long, old_len)
+		__field(unsigned long, new_addr)
+		__field(unsigned long, new_len)
+	),
+
+	TP_fast_assign(
+		__entry->addr = addr;
+		__entry->old_len = old_len;
+		__entry->new_addr = new_addr;
+		__entry->new_len = new_len;
+	),
+
+	TP_printk("remapping %lu bytes from %lu to %lu bytes at %lu\n",
+		  __entry->old_len, __entry->addr, __entry->new_len,
+		  __entry->new_addr)
+);
+
+#endif /* _TRACE_MREMAP_H_ */
+
+/* This part must be outside protection */
+#include <trace/define_trace.h>
diff --git a/mm/mremap.c b/mm/mremap.c
index cde56ee..b3aaff0 100644
--- a/mm/mremap.c
+++ b/mm/mremap.c
@@ -20,6 +20,9 @@
 #include <linux/syscalls.h>
 #include <linux/mmu_notifier.h>
 
+#define CREATE_TRACE_POINTS
+#include <trace/events/mremap.h>
+
 #include <asm/uaccess.h>
 #include <asm/cacheflush.h>
 #include <asm/tlbflush.h>
@@ -504,6 +507,8 @@ unsigned long do_mremap(unsigned long addr,
 out:
 	if (ret & ~PAGE_MASK)
 		vm_unacct_memory(charged);
+	else
+		trace_mremap(addr, old_len, new_addr, new_len);
 	return ret;
 }
 
-- 
1.7.0.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
