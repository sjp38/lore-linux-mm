Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f175.google.com (mail-ob0-f175.google.com [209.85.214.175])
	by kanga.kvack.org (Postfix) with ESMTP id CDD766B0038
	for <linux-mm@kvack.org>; Wed, 18 Mar 2015 23:11:06 -0400 (EDT)
Received: by obcjt1 with SMTP id jt1so25275332obc.2
        for <linux-mm@kvack.org>; Wed, 18 Mar 2015 20:11:06 -0700 (PDT)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [119.145.14.66])
        by mx.google.com with ESMTPS id ps6si10272397obb.84.2015.03.18.20.11.04
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 18 Mar 2015 20:11:06 -0700 (PDT)
From: Xie XiuQi <xiexiuqi@huawei.com>
Subject: [PATCH] tracing: add trace event for memory-failure
Date: Thu, 19 Mar 2015 11:04:30 +0800
Message-ID: <1426734270-8146-1-git-send-email-xiexiuqi@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: n-horiguchi@ah.jp.nec.com
Cc: gong.chen@linux.intel.com, bhelgaas@google.com, bp@suse.de, tony.luck@intel.com, rostedt@goodmis.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jingle.chen@huawei.com

Memory-failure as the high level machine check handler, it's necessary
to report memory page recovery action result to user space by ftrace.

This patch add a event at ras group for memory-failure.

The output like below:
#  tracer: nop
# 
#  entries-in-buffer/entries-written: 2/2   #P:24
# 
#                               _-----=> irqs-off
#                              / _----=> need-resched
#                             | / _---=> hardirq/softirq
#                             || / _--=> preempt-depth
#                             ||| /     delay
#            TASK-PID   CPU#  ||||    TIMESTAMP  FUNCTION
#               | |       |   ||||       |         |
       mce-inject-13150 [001] ....   277.019359: memory_failure_event: pfn 0x19869: free buddy page recovery: Delayed

---
v1->v2:
 - Comment update
 - Just passing 'result' instead of 'action_name[result]',
   suggested by Steve. And hard coded there because trace-cmd
   and perf do not have a way to process enums.

Cc: Tony Luck <tony.luck@intel.com>
Cc: Steven Rostedt <rostedt@goodmis.org>
Signed-off-by: Xie XiuQi <xiexiuqi@huawei.com>
---
 include/ras/ras_event.h | 38 ++++++++++++++++++++++++++++++++++++++
 mm/memory-failure.c     |  3 +++
 2 files changed, 41 insertions(+)

diff --git a/include/ras/ras_event.h b/include/ras/ras_event.h
index 79abb9c..ebb05f3 100644
--- a/include/ras/ras_event.h
+++ b/include/ras/ras_event.h
@@ -232,6 +232,44 @@ TRACE_EVENT(aer_event,
 		__print_flags(__entry->status, "|", aer_uncorrectable_errors))
 );
 
+/*
+ * memory-failure recovery action result event
+ *
+ * unsigned long pfn -	Page Number of the corrupted page
+ * char * action -	Recovery action for various type of pages
+ * int result	 -	Action result
+ *
+ * NOTE: 'action' and 'result' are defined at mm/memory-failure.c
+ */
+TRACE_EVENT(memory_failure_event,
+	TP_PROTO(const unsigned long pfn,
+		 const char *action,
+		 const int result),
+
+	TP_ARGS(pfn, action, result),
+
+	TP_STRUCT__entry(
+		__field(unsigned long, pfn)
+		__string(action, action)
+		__field(int, result)
+	),
+
+	TP_fast_assign(
+		__entry->pfn	= pfn;
+		__assign_str(action, action);
+		__entry->result	= result;
+	),
+
+	TP_printk("pfn %#lx: %s page recovery: %s",
+		__entry->pfn,
+		__get_str(action),
+		__print_symbolic(__entry->result,
+				{0, "Ignored"},
+				{1, "Failed"},
+				{2, "Delayed"},
+				{3, "Recovered"})
+	)
+);
 #endif /* _TRACE_HW_EVENT_MC_H */
 
 /* This part must be outside protection */
diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index feb803b..3a71668 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -56,6 +56,7 @@
 #include <linux/mm_inline.h>
 #include <linux/kfifo.h>
 #include "internal.h"
+#include <ras/ras_event.h>
 
 int sysctl_memory_failure_early_kill __read_mostly = 0;
 
@@ -844,6 +845,8 @@ static struct page_state {
  */
 static void action_result(unsigned long pfn, char *msg, int result)
 {
+	trace_memory_failure_event(pfn, msg, result);
+
 	pr_err("MCE %#lx: %s page recovery: %s\n",
 		pfn, msg, action_name[result]);
 }
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
