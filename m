Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 0556F800CA
	for <linux-mm@kvack.org>; Mon, 24 Nov 2014 03:12:54 -0500 (EST)
Received: by mail-pa0-f47.google.com with SMTP id kq14so9097823pab.20
        for <linux-mm@kvack.org>; Mon, 24 Nov 2014 00:12:53 -0800 (PST)
Received: from lgeamrelo01.lge.com (lgeamrelo01.lge.com. [156.147.1.125])
        by mx.google.com with ESMTP id lk3si20487489pab.43.2014.11.24.00.12.47
        for <linux-mm@kvack.org>;
        Mon, 24 Nov 2014 00:12:48 -0800 (PST)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [PATCH v3 5/8] stacktrace: introduce snprint_stack_trace for buffer output
Date: Mon, 24 Nov 2014 17:15:23 +0900
Message-Id: <1416816926-7756-6-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1416816926-7756-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1416816926-7756-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Dave Hansen <dave@sr71.net>, Michal Nazarewicz <mina86@mina86.com>, Jungsoo Son <jungsoo.son@lge.com>, Ingo Molnar <mingo@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

Current stacktrace only have the function for console output.
page_owner that will be introduced in following patch needs to print
the output of stacktrace into the buffer for our own output format
so so new function, snprint_stack_trace(), is needed.

v3:
 fix potential buffer overflow case
 make snprint_stack_trace() return generated string length rather than
 printed string length like as snprint* functions semantic.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 include/linux/stacktrace.h |    5 +++++
 kernel/stacktrace.c        |   32 ++++++++++++++++++++++++++++++++
 2 files changed, 37 insertions(+)

diff --git a/include/linux/stacktrace.h b/include/linux/stacktrace.h
index 115b570..669045a 100644
--- a/include/linux/stacktrace.h
+++ b/include/linux/stacktrace.h
@@ -1,6 +1,8 @@
 #ifndef __LINUX_STACKTRACE_H
 #define __LINUX_STACKTRACE_H
 
+#include <linux/types.h>
+
 struct task_struct;
 struct pt_regs;
 
@@ -20,6 +22,8 @@ extern void save_stack_trace_tsk(struct task_struct *tsk,
 				struct stack_trace *trace);
 
 extern void print_stack_trace(struct stack_trace *trace, int spaces);
+extern int snprint_stack_trace(char *buf, size_t size,
+			struct stack_trace *trace, int spaces);
 
 #ifdef CONFIG_USER_STACKTRACE_SUPPORT
 extern void save_stack_trace_user(struct stack_trace *trace);
@@ -32,6 +36,7 @@ extern void save_stack_trace_user(struct stack_trace *trace);
 # define save_stack_trace_tsk(tsk, trace)		do { } while (0)
 # define save_stack_trace_user(trace)			do { } while (0)
 # define print_stack_trace(trace, spaces)		do { } while (0)
+# define snprint_stack_trace(buf, size, trace, spaces)	do { } while (0)
 #endif
 
 #endif
diff --git a/kernel/stacktrace.c b/kernel/stacktrace.c
index 00fe55c..b6e4c16 100644
--- a/kernel/stacktrace.c
+++ b/kernel/stacktrace.c
@@ -25,6 +25,38 @@ void print_stack_trace(struct stack_trace *trace, int spaces)
 }
 EXPORT_SYMBOL_GPL(print_stack_trace);
 
+int snprint_stack_trace(char *buf, size_t size,
+			struct stack_trace *trace, int spaces)
+{
+	int i;
+	unsigned long ip;
+	int generated;
+	int total = 0;
+
+	if (WARN_ON(!trace->entries))
+		return 0;
+
+	for (i = 0; i < trace->nr_entries; i++) {
+		ip = trace->entries[i];
+		generated = snprintf(buf, size, "%*c[<%p>] %pS\n",
+				1 + spaces, ' ', (void *) ip, (void *) ip);
+
+		total += generated;
+
+		/* Assume that generated isn't a negative number */
+		if (generated >= size) {
+			buf += size;
+			size = 0;
+		} else {
+			buf += generated;
+			size -= generated;
+		}
+	}
+
+	return total;
+}
+EXPORT_SYMBOL_GPL(snprint_stack_trace);
+
 /*
  * Architectures that do not implement save_stack_trace_tsk or
  * save_stack_trace_regs get this weak alias and a once-per-bootup warning
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
