Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id A2F886B00F0
	for <linux-mm@kvack.org>; Wed, 12 Nov 2014 03:25:11 -0500 (EST)
Received: by mail-pd0-f176.google.com with SMTP id ft15so11781742pdb.21
        for <linux-mm@kvack.org>; Wed, 12 Nov 2014 00:25:11 -0800 (PST)
Received: from lgemrelse7q.lge.com (LGEMRELSE7Q.lge.com. [156.147.1.151])
        by mx.google.com with ESMTP id ao2si22297872pad.52.2014.11.12.00.25.05
        for <linux-mm@kvack.org>;
        Wed, 12 Nov 2014 00:25:06 -0800 (PST)
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: [RFC PATCH 4/5] stacktrace: support snprint
Date: Wed, 12 Nov 2014 17:27:14 +0900
Message-Id: <1415780835-24642-5-git-send-email-iamjoonsoo.kim@lge.com>
In-Reply-To: <1415780835-24642-1-git-send-email-iamjoonsoo.kim@lge.com>
References: <1415780835-24642-1-git-send-email-iamjoonsoo.kim@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Alexander Nyberg <alexn@dsv.su.se>, Dave Hansen <dave@linux.vnet.ibm.com>, Michal Nazarewicz <mina86@mina86.com>, Jungsoo Son <jungsoo.son@lge.com>, Ingo Molnar <mingo@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Joonsoo Kim <iamjoonsoo.kim@lge.com>

Current stacktrace only have the function for console output.
page_owner that will be introduced in following patch needs to print
the output of stacktrace into the buffer for our own output format. Also,
it needs to print message to debugfs output buffer, so new function,
snprint is needed.

Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
---
 include/linux/stacktrace.h |    3 +++
 kernel/stacktrace.c        |   24 ++++++++++++++++++++++++
 2 files changed, 27 insertions(+)

diff --git a/include/linux/stacktrace.h b/include/linux/stacktrace.h
index 115b570..5948c67 100644
--- a/include/linux/stacktrace.h
+++ b/include/linux/stacktrace.h
@@ -20,6 +20,8 @@ extern void save_stack_trace_tsk(struct task_struct *tsk,
 				struct stack_trace *trace);
 
 extern void print_stack_trace(struct stack_trace *trace, int spaces);
+extern int  snprint_stack_trace(char *buf, int buf_len,
+				struct stack_trace *trace, int spaces);
 
 #ifdef CONFIG_USER_STACKTRACE_SUPPORT
 extern void save_stack_trace_user(struct stack_trace *trace);
@@ -32,6 +34,7 @@ extern void save_stack_trace_user(struct stack_trace *trace);
 # define save_stack_trace_tsk(tsk, trace)		do { } while (0)
 # define save_stack_trace_user(trace)			do { } while (0)
 # define print_stack_trace(trace, spaces)		do { } while (0)
+# define snprint_stack_trace(buf, len, trace, spaces)	do { } while (0)
 #endif
 
 #endif
diff --git a/kernel/stacktrace.c b/kernel/stacktrace.c
index 00fe55c..61088ff 100644
--- a/kernel/stacktrace.c
+++ b/kernel/stacktrace.c
@@ -25,6 +25,30 @@ void print_stack_trace(struct stack_trace *trace, int spaces)
 }
 EXPORT_SYMBOL_GPL(print_stack_trace);
 
+int snprint_stack_trace(char *buf, int buf_len, struct stack_trace *trace,
+			int spaces)
+{
+	int i, printed;
+	unsigned long ip;
+	int ret = 0;
+
+	if (WARN_ON(!trace->entries))
+		return 0;
+
+	for (i = 0; i < trace->nr_entries && buf_len; i++) {
+		ip = trace->entries[i];
+		printed = snprintf(buf, buf_len, "%*c[<%p>] %pS\n",
+				1 + spaces, ' ', (void *) ip, (void *) ip);
+
+		buf_len -= printed;
+		ret += printed;
+		buf += printed;
+	}
+
+	return ret;
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
