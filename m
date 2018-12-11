Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f198.google.com (mail-lj1-f198.google.com [209.85.208.198])
	by kanga.kvack.org (Postfix) with ESMTP id C011C8E004D
	for <linux-mm@kvack.org>; Tue, 11 Dec 2018 05:37:40 -0500 (EST)
Received: by mail-lj1-f198.google.com with SMTP id t7-v6so3703374ljg.9
        for <linux-mm@kvack.org>; Tue, 11 Dec 2018 02:37:40 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 129sor3613013lfl.19.2018.12.11.02.37.38
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 11 Dec 2018 02:37:38 -0800 (PST)
From: Anders Roxell <anders.roxell@linaro.org>
Subject: [PATCH] kasan: mark kasan_check_(read|write) as 'notrace'
Date: Tue, 11 Dec 2018 11:37:33 +0100
Message-Id: <20181211103733.22284-1-anders.roxell@linaro.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: aryabinin@virtuozzo.com
Cc: kasan-dev@googlegroups.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, rostedt@goodmis.org, Anders Roxell <anders.roxell@linaro.org>

When option CONFIG_KASAN is enabled toghether with ftrace, function
ftrace_graph_caller() gets in to a recursion, via functions
kasan_check_read() and kasan_check_write().

 Breakpoint 2, ftrace_graph_caller () at ../arch/arm64/kernel/entry-ftrace.S:179
 179             mcount_get_pc             x0    //     function's pc
 (gdb) bt
 #0  ftrace_graph_caller () at ../arch/arm64/kernel/entry-ftrace.S:179
 #1  0xffffff90101406c8 in ftrace_caller () at ../arch/arm64/kernel/entry-ftrace.S:151
 #2  0xffffff90106fd084 in kasan_check_write (p=0xffffffc06c170878, size=4) at ../mm/kasan/common.c:105
 #3  0xffffff90104a2464 in atomic_add_return (v=<optimized out>, i=<optimized out>) at ./include/generated/atomic-instrumented.h:71
 #4  atomic_inc_return (v=<optimized out>) at ./include/generated/atomic-fallback.h:284
 #5  trace_graph_entry (trace=0xffffffc03f5ff380) at ../kernel/trace/trace_functions_graph.c:441
 #6  0xffffff9010481774 in trace_graph_entry_watchdog (trace=<optimized out>) at ../kernel/trace/trace_selftest.c:741
 #7  0xffffff90104a185c in function_graph_enter (ret=<optimized out>, func=<optimized out>, frame_pointer=18446743799894897728, retp=<optimized out>) at ../kernel/trace/trace_functions_graph.c:196
 #8  0xffffff9010140628 in prepare_ftrace_return (self_addr=18446743592948977792, parent=0xffffffc03f5ff418, frame_pointer=18446743799894897728) at ../arch/arm64/kernel/ftrace.c:231
 #9  0xffffff90101406f4 in ftrace_graph_caller () at ../arch/arm64/kernel/entry-ftrace.S:182
 Backtrace stopped: previous frame identical to this frame (corrupt stack?)
 (gdb)

Rework so that kasan_check_read() and kasan_check_write() is marked with
'notrace'.

Signed-off-by: Anders Roxell <anders.roxell@linaro.org>
---
 mm/kasan/common.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/mm/kasan/common.c b/mm/kasan/common.c
index 03d5d1374ca7..71507d15712b 100644
--- a/mm/kasan/common.c
+++ b/mm/kasan/common.c
@@ -95,13 +95,13 @@ void kasan_disable_current(void)
 	current->kasan_depth--;
 }
 
-void kasan_check_read(const volatile void *p, unsigned int size)
+void notrace kasan_check_read(const volatile void *p, unsigned int size)
 {
 	check_memory_region((unsigned long)p, size, false, _RET_IP_);
 }
 EXPORT_SYMBOL(kasan_check_read);
 
-void kasan_check_write(const volatile void *p, unsigned int size)
+void notrace kasan_check_write(const volatile void *p, unsigned int size)
 {
 	check_memory_region((unsigned long)p, size, true, _RET_IP_);
 }
-- 
2.19.2
