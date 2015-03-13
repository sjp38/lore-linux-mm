Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f178.google.com (mail-ob0-f178.google.com [209.85.214.178])
	by kanga.kvack.org (Postfix) with ESMTP id CB943829B6
	for <linux-mm@kvack.org>; Fri, 13 Mar 2015 06:13:24 -0400 (EDT)
Received: by obcuz6 with SMTP id uz6so18718675obc.5
        for <linux-mm@kvack.org>; Fri, 13 Mar 2015 03:13:24 -0700 (PDT)
Received: from szxga02-in.huawei.com (szxga02-in.huawei.com. [119.145.14.65])
        by mx.google.com with ESMTPS id v84si814790oig.22.2015.03.13.03.13.21
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Fri, 13 Mar 2015 03:13:23 -0700 (PDT)
From: Xie XiuQi <xiexiuqi@huawei.com>
Subject: [PATCH] tracing: add trace event for memory-failure
Date: Fri, 13 Mar 2015 18:10:51 +0800
Message-ID: <1426241451-25729-1-git-send-email-xiexiuqi@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: n-horiguchi@ah.jp.nec.com, gong.chen@linux.intel.com, bhelgaas@google.com, bp@suse.de, tony.luck@intel.com
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, jingle.chen@huawei.com

Memory-failure as the high level machine check handler, it's necessary
to report memory page recovery action result to user space by ftrace.

This patch add a event at ras group for memory-failure.

The output like below:
# tracer: nop
#
# entries-in-buffer/entries-written: 2/2   #P:24
#
#                              _-----=> irqs-off
#                             / _----=> need-resched
#                            | / _---=> hardirq/softirq
#                            || / _--=> preempt-depth
#                            ||| /     delay
#           TASK-PID   CPU#  ||||    TIMESTAMP  FUNCTION
#              | |       |   ||||       |         |
      mce-inject-13150 [001] ....   277.019359: memory_failure_event: pfn 0x19869: free buddy page recovery: Delayed

Signed-off-by: Xie XiuQi <xiexiuqi@huawei.com>
---
 include/ras/ras_event.h |   36 ++++++++++++++++++++++++++++++++++++
 mm/memory-failure.c     |    3 +++
 2 files changed, 39 insertions(+), 0 deletions(-)

diff --git a/include/ras/ras_event.h b/include/ras/ras_event.h
index 79abb9c..0a6c8f3 100644
--- a/include/ras/ras_event.h
+++ b/include/ras/ras_event.h
@@ -232,6 +232,42 @@ TRACE_EVENT(aer_event,
 		__print_flags(__entry->status, "|", aer_uncorrectable_errors))
 );
 
+/*
+ * memory-failure recovery action result event
+ *
+ * unsigned long pfn -	Page Number of the corrupted page
+ * char * action -	Recovery action: "free buddy", "free huge", "high
+ *			order kernel", "free buddy, 2nd try", "different
+ *			compound page after locking", "hugepage already
+ *			hardware poisoned", "unmapping failed", "already
+ *			truncated LRU", etc.
+ * char * result -	Action result: Ignored, Failed, Delayed, Recovered.
+ */
+TRACE_EVENT(memory_failure_event,
+	TP_PROTO(const unsigned long pfn,
+		 const char *action,
+		 const char *result),
+
+	TP_ARGS(pfn, action, result),
+
+	TP_STRUCT__entry(
+		__field(unsigned long, pfn)
+		__string(action, action)
+		__string(result, result)
+	),
+
+	TP_fast_assign(
+		__entry->pfn = pfn;
+		__assign_str(action, action);
+		__assign_str(result, result);
+	),
+
+	TP_printk("pfn %#lx: %s page recovery: %s",
+		__entry->pfn,
+		__get_str(action),
+		__get_str(result)
+	)
+);
 #endif /* _TRACE_HW_EVENT_MC_H */
 
 /* This part must be outside protection */
diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index d487f8d..86a9cce 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -56,6 +56,7 @@
 #include <linux/mm_inline.h>
 #include <linux/kfifo.h>
 #include "internal.h"
+#include <ras/ras_event.h>
 
 int sysctl_memory_failure_early_kill __read_mostly = 0;
 
@@ -837,6 +838,8 @@ static struct page_state {
  */
 static void action_result(unsigned long pfn, char *msg, int result)
 {
+	trace_memory_failure_event(pfn, msg, action_name[result]);
+
 	pr_err("MCE %#lx: %s page recovery: %s\n",
 		pfn, msg, action_name[result]);
 }
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
