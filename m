Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id C9E0B6B0008
	for <linux-mm@kvack.org>; Tue, 27 Mar 2018 07:43:11 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id m18so11070158pgu.14
        for <linux-mm@kvack.org>; Tue, 27 Mar 2018 04:43:11 -0700 (PDT)
Received: from mailout1.samsung.com (mailout1.samsung.com. [203.254.224.24])
        by mx.google.com with ESMTPS id i61-v6si1096241plb.560.2018.03.27.04.43.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 27 Mar 2018 04:43:10 -0700 (PDT)
Received: from epcas5p3.samsung.com (unknown [182.195.41.41])
	by mailout1.samsung.com (KnoxPortal) with ESMTP id 20180327114308epoutp015b4ce2249d5b552be3ba3360e63b803a~fxEJxTpha2220922209epoutp01A
	for <linux-mm@kvack.org>; Tue, 27 Mar 2018 11:43:08 +0000 (GMT)
From: Maninder Singh <maninder1.s@samsung.com>
Subject: [PATCH v3] mm/page_owner: ignore everything below the IRQ entry
 point
Date: Tue, 27 Mar 2018 17:11:47 +0530
Message-Id: <1522150907-33547-1-git-send-email-maninder1.s@samsung.com>
Content-Type: text/plain; charset="utf-8"
References: <CGME20180327114307epcas5p100770b64c770cc5bfb98ef1f820434ef@epcas5p1.samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: aryabinin@virtuozzo.com, glider@google.com, dvyukov@google.com, kstewart@linuxfoundation.org, tglx@linutronix.de, pombredanne@nexb.com, gregkh@linuxfoundation.org, akpm@linux-foundation.org, vbabka@suse.cz, sfr@canb.auug.org.au, mhocko@suse.com, vinmenon@codeaurora.org, gomonovych@gmail.com, ayush.m@samsung.com
Cc: linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, a.sahrawat@samsung.com, pankaj.m@samsung.com, v.narang@samsung.com, Maninder Singh <maninder1.s@samsung.com>

Check whether the allocation happens in an IRQ handler.
This lets us strip everything below the IRQ entry point to reduce the
number of unique stack traces needed to be stored.

so moved code of KASAN in generic file so that page_owner can also
do same filteration.

Initial KASAN commit
id=be7635e7287e0e8013af3c89a6354a9e0182594c

Original:-
 __alloc_pages_nodemask+0xfc/0x220
  page_frag_alloc+0x84/0x140
  __napi_alloc_skb+0x83/0xe0
  rtl8169_poll+0x1e5/0x670
  net_rx_action+0x132/0x3a0
  __do_softirq+0xce/0x298
  irq_exit+0xa3/0xb0
  do_IRQ+0x72/0xc0
  ret_from_intr+0x0/0x18
  cpuidle_enter_state+0x96/0x290
  do_idle+0x163/0x1a0

After patch:-
  __alloc_pages_nodemask+0xfc/0x220
  page_frag_alloc+0x84/0x140
  __napi_alloc_skb+0x83/0xe0
  rtl8169_poll+0x1e5/0x670
  net_rx_action+0x132/0x3a0
  __do_softirq+0xce/0x298

Signed-off-by: Vaneet Narang <v.narang@samsung.com>
Signed-off-by: Maninder Singh <maninder1.s@samsung.com>
---
v1->v2: fix build break for tile and blackfin
(https://lkml.org/lkml/2017/12/3/287, verified for blackfin)
v2->v3: remove inline as functions are larger,
        Declarations for __irqentry_text_start and friends are redundant.

 include/linux/stacktrace.h |  3 +++
 kernel/stacktrace.c        | 22 ++++++++++++++++++++++
 mm/kasan/kasan.c           | 22 ----------------------
 mm/page_owner.c            |  1 +
 4 files changed, 26 insertions(+), 22 deletions(-)

diff --git a/include/linux/stacktrace.h b/include/linux/stacktrace.h
index ba29a06..1a37fcae 100644
--- a/include/linux/stacktrace.h
+++ b/include/linux/stacktrace.h
@@ -26,6 +26,8 @@ extern int save_stack_trace_tsk_reliable(struct task_struct *tsk,
 extern int snprint_stack_trace(char *buf, size_t size,
 			struct stack_trace *trace, int spaces);
 
+void filter_irq_stacks(struct stack_trace *trace);
+
 #ifdef CONFIG_USER_STACKTRACE_SUPPORT
 extern void save_stack_trace_user(struct stack_trace *trace);
 #else
@@ -38,6 +40,7 @@ extern int snprint_stack_trace(char *buf, size_t size,
 # define save_stack_trace_user(trace)			do { } while (0)
 # define print_stack_trace(trace, spaces)		do { } while (0)
 # define snprint_stack_trace(buf, size, trace, spaces)	do { } while (0)
+# define filter_irq_stacks(trace)			do { } while (0)
 # define save_stack_trace_tsk_reliable(tsk, trace)	({ -ENOSYS; })
 #endif /* CONFIG_STACKTRACE */
 
diff --git a/kernel/stacktrace.c b/kernel/stacktrace.c
index f8edee9..b28c4e1 100644
--- a/kernel/stacktrace.c
+++ b/kernel/stacktrace.c
@@ -77,3 +77,25 @@ int snprint_stack_trace(char *buf, size_t size,
 	WARN_ONCE(1, KERN_INFO "save_stack_tsk_reliable() not implemented yet.\n");
 	return -ENOSYS;
 }
+
+static bool in_irqentry_text(unsigned long ptr)
+{
+	return (ptr >= (unsigned long)&__irqentry_text_start &&
+		ptr < (unsigned long)&__irqentry_text_end) ||
+		(ptr >= (unsigned long)&__softirqentry_text_start &&
+		 ptr < (unsigned long)&__softirqentry_text_end);
+}
+
+void filter_irq_stacks(struct stack_trace *trace)
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
