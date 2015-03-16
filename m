Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id AA3006B006E
	for <linux-mm@kvack.org>; Mon, 16 Mar 2015 12:08:25 -0400 (EDT)
Received: by pabyw6 with SMTP id yw6so68835370pab.2
        for <linux-mm@kvack.org>; Mon, 16 Mar 2015 09:08:25 -0700 (PDT)
Received: from mailout3.w1.samsung.com (mailout3.w1.samsung.com. [210.118.77.13])
        by mx.google.com with ESMTPS id l1si6083350pdm.154.2015.03.16.09.08.24
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Mon, 16 Mar 2015 09:08:24 -0700 (PDT)
Received: from eucpsbgm2.samsung.com (unknown [203.254.199.245])
 by mailout3.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0NLB00K3QBONVF00@mailout3.w1.samsung.com> for
 linux-mm@kvack.org; Mon, 16 Mar 2015 16:12:23 +0000 (GMT)
From: Stefan Strogin <s.strogin@partner.samsung.com>
Subject: [PATCH v4 3/5] stacktrace: add seq_print_stack_trace()
Date: Mon, 16 Mar 2015 19:06:58 +0300
Message-id: 
 <19b2815dbb60bfd38d17596a3d466637ee44c9a5.1426521377.git.s.strogin@partner.samsung.com>
In-reply-to: <cover.1426521377.git.s.strogin@partner.samsung.com>
References: <cover.1426521377.git.s.strogin@partner.samsung.com>
In-reply-to: <cover.1426521377.git.s.strogin@partner.samsung.com>
References: <cover.1426521377.git.s.strogin@partner.samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Stefan Strogin <s.strogin@partner.samsung.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, aneesh.kumar@linux.vnet.ibm.com, Laurent Pinchart <laurent.pinchart@ideasonboard.com>, Dmitry Safonov <d.safonov@partner.samsung.com>, Pintu Kumar <pintu.k@samsung.com>, Weijie Yang <weijie.yang@samsung.com>, Laura Abbott <lauraa@codeaurora.org>, SeongJae Park <sj38.park@gmail.com>, Hui Zhu <zhuhui@xiaomi.com>, Minchan Kim <minchan@kernel.org>, Dyasly Sergey <s.dyasly@samsung.com>, Vyacheslav Tyrtov <v.tyrtov@samsung.com>, Aleksei Mateosian <a.mateosian@samsung.com>, gregory.0xf0@gmail.com, sasha.levin@oracle.com, gioh.kim@lge.com, pavel@ucw.cz, stefan.strogin@gmail.com

Add a function seq_print_stack_trace() which prints stacktraces to seq_files.

Signed-off-by: Stefan Strogin <stefan.strogin@gmail.com>
Reviewed-by: SeongJae Park <sj38.park@gmail.com>
---
 include/linux/stacktrace.h |  4 ++++
 kernel/stacktrace.c        | 17 +++++++++++++++++
 2 files changed, 21 insertions(+)

diff --git a/include/linux/stacktrace.h b/include/linux/stacktrace.h
index 0a34489..d80f2e9 100644
--- a/include/linux/stacktrace.h
+++ b/include/linux/stacktrace.h
@@ -2,6 +2,7 @@
 #define __LINUX_STACKTRACE_H
 
 #include <linux/types.h>
+#include <linux/seq_file.h>
 
 struct task_struct;
 struct pt_regs;
@@ -22,6 +23,8 @@ extern void save_stack_trace_tsk(struct task_struct *tsk,
 extern void print_stack_trace(struct stack_trace *trace, int spaces);
 extern int snprint_stack_trace(char *buf, size_t size,
 			struct stack_trace *trace, int spaces);
+extern void seq_print_stack_trace(struct seq_file *m,
+			struct stack_trace *trace, int spaces);
 
 #ifdef CONFIG_USER_STACKTRACE_SUPPORT
 extern void save_stack_trace_user(struct stack_trace *trace);
@@ -35,6 +38,7 @@ extern void save_stack_trace_user(struct stack_trace *trace);
 # define save_stack_trace_user(trace)			do { } while (0)
 # define print_stack_trace(trace, spaces)		do { } while (0)
 # define snprint_stack_trace(buf, size, trace, spaces)	do { } while (0)
+# define seq_print_stack_trace(m, trace, spaces)	do { } while (0)
 #endif
 
 #endif
diff --git a/kernel/stacktrace.c b/kernel/stacktrace.c
index b6e4c16..66ef6f4 100644
--- a/kernel/stacktrace.c
+++ b/kernel/stacktrace.c
@@ -57,6 +57,23 @@ int snprint_stack_trace(char *buf, size_t size,
 }
 EXPORT_SYMBOL_GPL(snprint_stack_trace);
 
+void seq_print_stack_trace(struct seq_file *m, struct stack_trace *trace,
+			int spaces)
+{
+	int i;
+
+	if (WARN_ON(!trace->entries))
+		return;
+
+	for (i = 0; i < trace->nr_entries; i++) {
+		unsigned long ip = trace->entries[i];
+
+		seq_printf(m, "%*c[<%p>] %pS\n", 1 + spaces, ' ',
+				(void *) ip, (void *) ip);
+	}
+}
+EXPORT_SYMBOL_GPL(seq_print_stack_trace);
+
 /*
  * Architectures that do not implement save_stack_trace_tsk or
  * save_stack_trace_regs get this weak alias and a once-per-bootup warning
-- 
2.1.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
