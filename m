Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 050FC6B0033
	for <linux-mm@kvack.org>; Sun,  3 Dec 2017 23:47:08 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id q3so10504876pgv.16
        for <linux-mm@kvack.org>; Sun, 03 Dec 2017 20:47:07 -0800 (PST)
Received: from mailout2.samsung.com (mailout2.samsung.com. [203.254.224.25])
        by mx.google.com with ESMTPS id h6si8888194pll.190.2017.12.03.20.47.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 03 Dec 2017 20:47:06 -0800 (PST)
Received: from epcas5p2.samsung.com (unknown [182.195.41.40])
	by mailout2.samsung.com (KnoxPortal) with ESMTP id 20171204044703epoutp0290b88d13957ee2553aebaf9d01dd8688~8-fmnAD3h1577815778epoutp023
	for <linux-mm@kvack.org>; Mon,  4 Dec 2017 04:47:03 +0000 (GMT)
From: Maninder Singh <maninder1.s@samsung.com>
Subject: [PATCH 1/1] mm/page_owner: ignore everything below the IRQ entry
 point
Date: Mon,  4 Dec 2017 10:13:20 +0530
Message-Id: <1512362600-40838-1-git-send-email-maninder1.s@samsung.com>
Content-Type: text/plain; charset="utf-8"
References: <CGME20171204044702epcas5p3a8d82d304038fe197ab324a4e0267e55@epcas5p3.samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: aryabinin@virtuozzo.com, glider@google.com, vyukov@google.com, mbenes@suse.cz, tglx@linutronix.de, pombredanne@nexb.com, mingo@kernel.org, gregkh@linuxfoundation.org, jpoimboe@redhat.com, akpm@linux-foundation.org, vbabka@suse.cz, sfr@canb.auug.org.au, mhocko@suse.com
Cc: linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, a.sahrawat@samsung.com, pankaj.m@samsung.com, Maninder Singh <maninder1.s@samsung.com>, Vaneet Narang <v.narang@samsung.com>

Check whether the allocation happens in an IRQ handler.
This lets us strip everything below the IRQ entry point to reduce the
number of unique stack traces needed to be stored.

so moved code of KASAN in generic file so that page_owner can also
do same filteration.

Initial KASAN commit
id=be7635e7287e0e8013af3c89a6354a9e0182594c

Signed-off-by: Vaneet Narang <v.narang@samsung.com>
Signed-off-by: Maninder Singh <maninder1.s@samsung.com>
---
 include/linux/stacktrace.h | 25 +++++++++++++++++++++++++
 mm/kasan/kasan.c           | 22 ----------------------
 mm/page_owner.c            |  1 +
 3 files changed, 26 insertions(+), 22 deletions(-)

diff --git a/include/linux/stacktrace.h b/include/linux/stacktrace.h
index ba29a06..2c1a562 100644
--- a/include/linux/stacktrace.h
+++ b/include/linux/stacktrace.h
@@ -3,6 +3,7 @@
 #define __LINUX_STACKTRACE_H
 
 #include <linux/types.h>
+#include <asm-generic/sections.h>
 
 struct task_struct;
 struct pt_regs;
@@ -26,6 +27,28 @@ extern int save_stack_trace_tsk_reliable(struct task_struct *tsk,
 extern int snprint_stack_trace(char *buf, size_t size,
 			struct stack_trace *trace, int spaces);
 
+static inline int in_irqentry_text(unsigned long ptr)
+{
+	return (ptr >= (unsigned long)&__irqentry_text_start &&
+		ptr < (unsigned long)&__irqentry_text_end) ||
+		(ptr >= (unsigned long)&__softirqentry_text_start &&
+		 ptr < (unsigned long)&__softirqentry_text_end);
+}
+
+static inline void filter_irq_stacks(struct stack_trace *trace)
+{
+	int i;
+
+	if (!trace->nr_entries)
+		return;
+	for (i = 0; i < trace->nr_entries; i++)
+		if (in_irqentry_text(trace->entries[i])) {
+			/* Include the irqentry function into the stack. */
+			trace->nr_entries = i + 1;
+			break;
+		}
+}
+
 #ifdef CONFIG_USER_STACKTRACE_SUPPORT
 extern void save_stack_trace_user(struct stack_trace *trace);
 #else
@@ -38,6 +61,8 @@ extern int snprint_stack_trace(char *buf, size_t size,
 # define save_stack_trace_user(trace)			do { } while (0)
 # define print_stack_trace(trace, spaces)		do { } while (0)
 # define snprint_stack_trace(buf, size, trace, spaces)	do { } while (0)
+# define filter_irq_stacks(trace)			do { } while (0)
+# define in_irqentry_text(ptr)				do { } while (0)
 # define save_stack_trace_tsk_reliable(tsk, trace)	({ -ENOSYS; })
 #endif /* CONFIG_STACKTRACE */
 
diff --git a/mm/kasan/kasan.c b/mm/kasan/kasan.c
index 405bba4..129e7b8 100644
--- a/mm/kasan/kasan.c
+++ b/mm/kasan/kasan.c
@@ -412,28 +412,6 @@ void kasan_poison_object_data(struct kmem_cache *cache, void *object)
 			KASAN_KMALLOC_REDZONE);
 }
 
-static inline int in_irqentry_text(unsigned long ptr)
-{
-	return (ptr >= (unsigned long)&__irqentry_text_start &&
-		ptr < (unsigned long)&__irqentry_text_end) ||
-		(ptr >= (unsigned long)&__softirqentry_text_start &&
-		 ptr < (unsigned long)&__softirqentry_text_end);
-}
-
-static inline void filter_irq_stacks(struct stack_trace *trace)
-{
-	int i;
-
-	if (!trace->nr_entries)
-		return;
-	for (i = 0; i < trace->nr_entries; i++)
-		if (in_irqentry_text(trace->entries[i])) {
-			/* Include the irqentry function into the stack. */
-			trace->nr_entries = i + 1;
-			break;
-		}
-}
-
 static inline depot_stack_handle_t save_stack(gfp_t flags)
 {
 	unsigned long entries[KASAN_STACK_DEPTH];
diff --git a/mm/page_owner.c b/mm/page_owner.c
index 8602fb4..30e9cb2 100644
--- a/mm/page_owner.c
+++ b/mm/page_owner.c
@@ -148,6 +148,7 @@ static noinline depot_stack_handle_t save_stack(gfp_t flags)
 	depot_stack_handle_t handle;
 
 	save_stack_trace(&trace);
+	filter_irq_stacks(&trace);
 	if (trace.nr_entries != 0 &&
 	    trace.entries[trace.nr_entries-1] == ULONG_MAX)
 		trace.nr_entries--;
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
