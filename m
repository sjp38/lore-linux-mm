Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vn0-f52.google.com (mail-vn0-f52.google.com [209.85.216.52])
	by kanga.kvack.org (Postfix) with ESMTP id 730DC6B0038
	for <linux-mm@kvack.org>; Tue,  7 Apr 2015 07:33:10 -0400 (EDT)
Received: by vnbg190 with SMTP id g190so5652765vnb.8
        for <linux-mm@kvack.org>; Tue, 07 Apr 2015 04:33:10 -0700 (PDT)
Received: from szxga02-in.huawei.com (szxga02-in.huawei.com. [119.145.14.65])
        by mx.google.com with ESMTPS id q63si3519954ykf.139.2015.04.07.04.33.07
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 07 Apr 2015 04:33:09 -0700 (PDT)
From: Xie XiuQi <xiexiuqi@huawei.com>
Subject: [RFC PATCH v3 2/2] tracing: add trace event for memory-failure
Date: Tue, 7 Apr 2015 19:05:31 +0800
Message-ID: <1428404731-21565-3-git-send-email-xiexiuqi@huawei.com>
In-Reply-To: <1428404731-21565-1-git-send-email-xiexiuqi@huawei.com>
References: <1428404731-21565-1-git-send-email-xiexiuqi@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: n-horiguchi@ah.jp.nec.com, rostedt@goodmis.org, mingo@redhat.com
Cc: akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, koct9i@gmail.com, hpa@linux.intel.com, hannes@cmpxchg.org, iamjoonsoo.kim@lge.com, luto@amacapital.net, nasa4836@gmail.com, gong.chen@linux.intel.com, bhelgaas@google.com, bp@suse.de, tony.luck@intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

RAS user space tools like rasdaemon which base on trace event, could
receive mce error event, but no memory recovery result event. So, I
want to add this event to make this scenario complete.

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
       mce-inject-13150 [001] ....   277.019359: memory_failure_event: pfn 0x19869: recovery action for free buddy page: Delayed


Cc: Tony Luck <tony.luck@intel.com>
Cc: Steven Rostedt <rostedt@goodmis.org>
Signed-off-by: Xie XiuQi <xiexiuqi@huawei.com>
---
 include/ras/ras_event.h | 83 +++++++++++++++++++++++++++++++++++++++++++++++++
 kernel/trace/trace.c    |  2 +-
 mm/memory-failure.c     |  2 ++
 3 files changed, 86 insertions(+), 1 deletion(-)

diff --git a/include/ras/ras_event.h b/include/ras/ras_event.h
index 79abb9c..52c75f2 100644
--- a/include/ras/ras_event.h
+++ b/include/ras/ras_event.h
@@ -11,6 +11,7 @@
 #include <linux/pci.h>
 #include <linux/aer.h>
 #include <linux/cper.h>
+#include <linux/mm.h>
 
 /*
  * MCE Extended Error Log trace event
@@ -232,6 +233,88 @@ TRACE_EVENT(aer_event,
 		__print_flags(__entry->status, "|", aer_uncorrectable_errors))
 );
 
+/*
+ * memory-failure recovery action result event
+ *
+ * unsigned long pfn -	Page Number of the corrupted page
+ * int type	-	Page types of the corrupted page
+ * int result	-	Result of recovery action
+ */
+
+#define MF_ACTION_RESULT	\
+	EM ( MF_IGNORED, "Ignord" )	\
+	EM ( MF_FAILED,  "Failed" )	\
+	EM ( MF_DELAYED, "Delayed" )	\
+	EMe ( MF_RECOVERED, "Recovered" )
+
+#define MF_PAGE_TYPE		\
+	EM ( MF_KERNEL, "reserved kernel page" )			\
+	EM ( MF_KERNEL_HIGH_ORDER, "high-order kernel page" )		\
+	EM ( MF_SLAB, "kernel slab page" )				\
+	EM ( MF_DIFFERENT_COMPOUND, "different compound page after locking" ) \
+	EM ( MF_POISONED_HUGE, "huge page already hardware poisoned" )	\
+	EM ( MF_HUGE, "huge page" )					\
+	EM ( MF_FREE_HUGE, "free huge page" )				\
+	EM ( MF_UNMAP_FAILED, "unmapping failed page" )			\
+	EM ( MF_DIRTY_SWAPCACHE, "dirty swapcache page" )		\
+	EM ( MF_CLEAN_SWAPCACHE, "clean swapcache page" )		\
+	EM ( MF_DIRTY_MLOCKED_LRU, "dirty mlocked LRU page" )		\
+	EM ( MF_CLEAN_MLOCKED_LRU, "clean mlocked LRU page" )		\
+	EM ( MF_DIRTY_UNEVICTABLE_LRU, "dirty unevictable LRU page" )	\
+	EM ( MF_CLEAN_UNEVICTABLE_LRU, "clean unevictable LRU page" )	\
+	EM ( MF_DIRTY_LRU, "dirty LRU page" )				\
+	EM ( MF_CLEAN_LRU, "clean LRU page" )				\
+	EM ( MF_TRUNCATED_LRU, "already truncated LRU page" )		\
+	EM ( MF_BUDDY, "free buddy page" )				\
+	EM ( MF_BUDDY_2ND, "free buddy page (2nd try)" )		\
+	EMe ( MF_UNKNOWN, "unknown page" )
+
+/*
+ * First define the enums in MM_ACTION_RESULT to be exported to userspace
+ * via TRACE_DEFINE_ENUM().
+ */
+#undef EM
+#undef EMe
+#define EM(a,b) TRACE_DEFINE_ENUM(a);
+#define EMe(a,b)	TRACE_DEFINE_ENUM(a);
+
+MF_ACTION_RESULT
+MF_PAGE_TYPE
+
+/*
+ * Now redefine the EM() and EMe() macros to map the enums to the strings
+ * that will be printed in the output.
+ */
+#undef EM
+#undef EMe
+#define EM(a,b)		{ a, b },
+#define EMe(a,b)	{ a, b }
+
+TRACE_EVENT(memory_failure_event,
+	TP_PROTO(unsigned long pfn,
+		 int type,
+		 int result),
+
+	TP_ARGS(pfn, type, result),
+
+	TP_STRUCT__entry(
+		__field(unsigned long, pfn)
+		__field(int, type)
+		__field(int, result)
+	),
+
+	TP_fast_assign(
+		__entry->pfn	= pfn;
+		__entry->type	= type;
+		__entry->result	= result;
+	),
+
+	TP_printk("pfn %#lx: recovery action for %s: %s",
+		__entry->pfn,
+		__print_symbolic(__entry->type, MF_PAGE_TYPE),
+		__print_symbolic(__entry->result, MF_ACTION_RESULT)
+	)
+);
 #endif /* _TRACE_HW_EVENT_MC_H */
 
 /* This part must be outside protection */
diff --git a/kernel/trace/trace.c b/kernel/trace/trace.c
index 25334e7..f5e8856 100644
--- a/kernel/trace/trace.c
+++ b/kernel/trace/trace.c
@@ -6776,7 +6776,7 @@ static struct notifier_block trace_module_nb = {
 };
 #endif
 
-static __init int tracer_init_debugfs(void)
+static __init int tracer_init_tracefs(void)
 {
 	struct dentry *d_tracer;
 
diff --git a/mm/memory-failure.c b/mm/memory-failure.c
index 34e9c65..d118af8 100644
--- a/mm/memory-failure.c
+++ b/mm/memory-failure.c
@@ -850,6 +850,8 @@ static struct page_state {
  */
 static void action_result(unsigned long pfn, int type, int result)
 {
+	trace_memory_failure_event(pfn, type, result);
+
 	pr_err("MCE %#lx: recovery action for %s: %s\n",
 		pfn, action_page_type[type], action_name[result]);
 }
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
