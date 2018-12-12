Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf1-f70.google.com (mail-lf1-f70.google.com [209.85.167.70])
	by kanga.kvack.org (Postfix) with ESMTP id 0A5038E00E5
	for <linux-mm@kvack.org>; Wed, 12 Dec 2018 13:36:48 -0500 (EST)
Received: by mail-lf1-f70.google.com with SMTP id g16so1984891lfb.22
        for <linux-mm@kvack.org>; Wed, 12 Dec 2018 10:36:47 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l20-v6sor11248149lji.21.2018.12.12.10.36.45
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 12 Dec 2018 10:36:46 -0800 (PST)
From: Anders Roxell <anders.roxell@linaro.org>
Subject: [PATCH v2] kasan: mark file common so ftrace doesn't trace it
Date: Wed, 12 Dec 2018 19:34:47 +0100
Message-Id: <20181212183447.15890-1-anders.roxell@linaro.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: aryabinin@virtuozzo.com, dvyukov@google.com
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

Rework so that the kasan implementation isn't traced.

Signed-off-by: Anders Roxell <anders.roxell@linaro.org>
---
 mm/kasan/Makefile | 1 +
 1 file changed, 1 insertion(+)

diff --git a/mm/kasan/Makefile b/mm/kasan/Makefile
index 0a14fcff70ed..e2bb06c1b45e 100644
--- a/mm/kasan/Makefile
+++ b/mm/kasan/Makefile
@@ -5,6 +5,7 @@ UBSAN_SANITIZE_generic.o := n
 UBSAN_SANITIZE_tags.o := n
 KCOV_INSTRUMENT := n
 
+CFLAGS_REMOVE_common.o = -pg
 CFLAGS_REMOVE_generic.o = -pg
 # Function splitter causes unnecessary splits in __asan_load1/__asan_store1
 # see: https://gcc.gnu.org/bugzilla/show_bug.cgi?id=63533
-- 
2.19.2
