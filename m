Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f41.google.com (mail-wm0-f41.google.com [74.125.82.41])
	by kanga.kvack.org (Postfix) with ESMTP id A76B8828DF
	for <linux-mm@kvack.org>; Fri, 26 Feb 2016 08:31:01 -0500 (EST)
Received: by mail-wm0-f41.google.com with SMTP id g62so72648279wme.0
        for <linux-mm@kvack.org>; Fri, 26 Feb 2016 05:31:01 -0800 (PST)
Received: from mail-wm0-x234.google.com (mail-wm0-x234.google.com. [2a00:1450:400c:c09::234])
        by mx.google.com with ESMTPS id b63si4158914wme.9.2016.02.26.05.30.56
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 26 Feb 2016 05:30:57 -0800 (PST)
Received: by mail-wm0-x234.google.com with SMTP id g62so70309738wme.0
        for <linux-mm@kvack.org>; Fri, 26 Feb 2016 05:30:56 -0800 (PST)
From: Alexander Potapenko <glider@google.com>
Subject: [PATCH v3 4/7] arch, ftrace: For KASAN put hard/soft IRQ entries into separate sections
Date: Fri, 26 Feb 2016 14:30:43 +0100
Message-Id: <c387c8362eb0eeb622fd7425904b9b429fc636f0.1456492360.git.glider@google.com>
In-Reply-To: <cover.1456492360.git.glider@google.com>
References: <cover.1456492360.git.glider@google.com>
In-Reply-To: <cover.1456492360.git.glider@google.com>
References: <cover.1456492360.git.glider@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: adech.fo@gmail.com, cl@linux.com, dvyukov@google.com, akpm@linux-foundation.org, ryabinin.a.a@gmail.com, rostedt@goodmis.org, iamjoonsoo.kim@lge.com, js1304@gmail.com, kcc@google.com
Cc: kasan-dev@googlegroups.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

KASAN needs to know whether the allocation happens in an IRQ handler.
This lets us strip everything below the IRQ entry point to reduce the
number of unique stack traces needed to be stored.

Move the definition of __irq_entry to <linux/interrupt.h> so that the
users don't need to pull in <linux/ftrace.h>. Also introduce the
__softirq_entry macro which is similar to __irq_entry, but puts the
corresponding functions to the .softirqentry.text section.

Signed-off-by: Alexander Potapenko <glider@google.com>
---
v2: - per request from Steven Rostedt, moved the declarations of __softirq_entry
and __irq_entry to <linux/interrupt.h>

v3: - minor description changes
---
 arch/arm/kernel/vmlinux.lds.S        |  1 +
 arch/arm64/kernel/vmlinux.lds.S      |  1 +
 arch/blackfin/kernel/vmlinux.lds.S   |  1 +
 arch/c6x/kernel/vmlinux.lds.S        |  1 +
 arch/metag/kernel/vmlinux.lds.S      |  1 +
 arch/microblaze/kernel/vmlinux.lds.S |  1 +
 arch/mips/kernel/vmlinux.lds.S       |  1 +
 arch/nios2/kernel/vmlinux.lds.S      |  1 +
 arch/openrisc/kernel/vmlinux.lds.S   |  1 +
 arch/parisc/kernel/vmlinux.lds.S     |  1 +
 arch/powerpc/kernel/vmlinux.lds.S    |  1 +
 arch/s390/kernel/vmlinux.lds.S       |  1 +
 arch/sh/kernel/vmlinux.lds.S         |  1 +
 arch/sparc/kernel/vmlinux.lds.S      |  1 +
 arch/tile/kernel/vmlinux.lds.S       |  1 +
 arch/x86/kernel/vmlinux.lds.S        |  1 +
 include/asm-generic/vmlinux.lds.h    | 12 +++++++++++-
 include/linux/ftrace.h               | 11 -----------
 include/linux/interrupt.h            | 20 ++++++++++++++++++++
 kernel/softirq.c                     |  2 +-
 kernel/trace/trace_functions_graph.c |  1 +
 21 files changed, 49 insertions(+), 13 deletions(-)

diff --git a/arch/arm/kernel/vmlinux.lds.S b/arch/arm/kernel/vmlinux.lds.S
index 8b60fde..28b690fc 100644
--- a/arch/arm/kernel/vmlinux.lds.S
+++ b/arch/arm/kernel/vmlinux.lds.S
@@ -105,6 +105,7 @@ SECTIONS
 			*(.exception.text)
 			__exception_text_end = .;
 			IRQENTRY_TEXT
+			SOFTIRQENTRY_TEXT
 			TEXT_TEXT
 			SCHED_TEXT
 			LOCK_TEXT
diff --git a/arch/arm64/kernel/vmlinux.lds.S b/arch/arm64/kernel/vmlinux.lds.S
index e3928f5..b9242b7 100644
--- a/arch/arm64/kernel/vmlinux.lds.S
+++ b/arch/arm64/kernel/vmlinux.lds.S
@@ -102,6 +102,7 @@ SECTIONS
 			*(.exception.text)
 			__exception_text_end = .;
 			IRQENTRY_TEXT
+			SOFTIRQENTRY_TEXT
 			TEXT_TEXT
 			SCHED_TEXT
 			LOCK_TEXT
diff --git a/arch/blackfin/kernel/vmlinux.lds.S b/arch/blackfin/kernel/vmlinux.lds.S
index c9eec84..d920b95 100644
--- a/arch/blackfin/kernel/vmlinux.lds.S
+++ b/arch/blackfin/kernel/vmlinux.lds.S
@@ -35,6 +35,7 @@ SECTIONS
 #endif
 		LOCK_TEXT
 		IRQENTRY_TEXT
+		SOFTIRQENTRY_TEXT
 		KPROBES_TEXT
 #ifdef CONFIG_ROMKERNEL
 		__sinittext = .;
diff --git a/arch/c6x/kernel/vmlinux.lds.S b/arch/c6x/kernel/vmlinux.lds.S
index 5a6e141..50bc10f 100644
--- a/arch/c6x/kernel/vmlinux.lds.S
+++ b/arch/c6x/kernel/vmlinux.lds.S
@@ -72,6 +72,7 @@ SECTIONS
 		SCHED_TEXT
 		LOCK_TEXT
 		IRQENTRY_TEXT
+		SOFTIRQENTRY_TEXT
 		KPROBES_TEXT
 		*(.fixup)
 		*(.gnu.warning)
diff --git a/arch/metag/kernel/vmlinux.lds.S b/arch/metag/kernel/vmlinux.lds.S
index e12055e..150ace9 100644
--- a/arch/metag/kernel/vmlinux.lds.S
+++ b/arch/metag/kernel/vmlinux.lds.S
@@ -24,6 +24,7 @@ SECTIONS
 	LOCK_TEXT
 	KPROBES_TEXT
 	IRQENTRY_TEXT
+	SOFTIRQENTRY_TEXT
 	*(.text.*)
 	*(.gnu.warning)
 	}
diff --git a/arch/microblaze/kernel/vmlinux.lds.S b/arch/microblaze/kernel/vmlinux.lds.S
index be9488d..0a47f04 100644
--- a/arch/microblaze/kernel/vmlinux.lds.S
+++ b/arch/microblaze/kernel/vmlinux.lds.S
@@ -36,6 +36,7 @@ SECTIONS {
 		LOCK_TEXT
 		KPROBES_TEXT
 		IRQENTRY_TEXT
+		SOFTIRQENTRY_TEXT
 		. = ALIGN (4) ;
 		_etext = . ;
 	}
diff --git a/arch/mips/kernel/vmlinux.lds.S b/arch/mips/kernel/vmlinux.lds.S
index 0a93e83..54d653e 100644
--- a/arch/mips/kernel/vmlinux.lds.S
+++ b/arch/mips/kernel/vmlinux.lds.S
@@ -58,6 +58,7 @@ SECTIONS
 		LOCK_TEXT
 		KPROBES_TEXT
 		IRQENTRY_TEXT
+		SOFTIRQENTRY_TEXT
 		*(.text.*)
 		*(.fixup)
 		*(.gnu.warning)
diff --git a/arch/nios2/kernel/vmlinux.lds.S b/arch/nios2/kernel/vmlinux.lds.S
index 326fab4..e23e895 100644
--- a/arch/nios2/kernel/vmlinux.lds.S
+++ b/arch/nios2/kernel/vmlinux.lds.S
@@ -39,6 +39,7 @@ SECTIONS
 		SCHED_TEXT
 		LOCK_TEXT
 		IRQENTRY_TEXT
+		SOFTIRQENTRY_TEXT
 		KPROBES_TEXT
 	} =0
 	_etext = .;
diff --git a/arch/openrisc/kernel/vmlinux.lds.S b/arch/openrisc/kernel/vmlinux.lds.S
index 2d69a85..d936de4 100644
--- a/arch/openrisc/kernel/vmlinux.lds.S
+++ b/arch/openrisc/kernel/vmlinux.lds.S
@@ -50,6 +50,7 @@ SECTIONS
 	  LOCK_TEXT
 	  KPROBES_TEXT
 	  IRQENTRY_TEXT
+	  SOFTIRQENTRY_TEXT
 	  *(.fixup)
 	  *(.text.__*)
 	  _etext = .;
diff --git a/arch/parisc/kernel/vmlinux.lds.S b/arch/parisc/kernel/vmlinux.lds.S
index 308f290..f3ead0b 100644
--- a/arch/parisc/kernel/vmlinux.lds.S
+++ b/arch/parisc/kernel/vmlinux.lds.S
@@ -72,6 +72,7 @@ SECTIONS
 		LOCK_TEXT
 		KPROBES_TEXT
 		IRQENTRY_TEXT
+		SOFTIRQENTRY_TEXT
 		*(.text.do_softirq)
 		*(.text.sys_exit)
 		*(.text.do_sigaltstack)
diff --git a/arch/powerpc/kernel/vmlinux.lds.S b/arch/powerpc/kernel/vmlinux.lds.S
index d41fd0a..2dd91f7 100644
--- a/arch/powerpc/kernel/vmlinux.lds.S
+++ b/arch/powerpc/kernel/vmlinux.lds.S
@@ -55,6 +55,7 @@ SECTIONS
 		LOCK_TEXT
 		KPROBES_TEXT
 		IRQENTRY_TEXT
+		SOFTIRQENTRY_TEXT
 
 #ifdef CONFIG_PPC32
 		*(.got1)
diff --git a/arch/s390/kernel/vmlinux.lds.S b/arch/s390/kernel/vmlinux.lds.S
index 445657f..0f41a82 100644
--- a/arch/s390/kernel/vmlinux.lds.S
+++ b/arch/s390/kernel/vmlinux.lds.S
@@ -28,6 +28,7 @@ SECTIONS
 		LOCK_TEXT
 		KPROBES_TEXT
 		IRQENTRY_TEXT
+		SOFTIRQENTRY_TEXT
 		*(.fixup)
 		*(.gnu.warning)
 	} :text = 0x0700
diff --git a/arch/sh/kernel/vmlinux.lds.S b/arch/sh/kernel/vmlinux.lds.S
index db88cbf..235a410 100644
--- a/arch/sh/kernel/vmlinux.lds.S
+++ b/arch/sh/kernel/vmlinux.lds.S
@@ -39,6 +39,7 @@ SECTIONS
 		LOCK_TEXT
 		KPROBES_TEXT
 		IRQENTRY_TEXT
+		SOFTIRQENTRY_TEXT
 		*(.fixup)
 		*(.gnu.warning)
 		_etext = .;		/* End of text section */
diff --git a/arch/sparc/kernel/vmlinux.lds.S b/arch/sparc/kernel/vmlinux.lds.S
index f1a2f68..aadd321 100644
--- a/arch/sparc/kernel/vmlinux.lds.S
+++ b/arch/sparc/kernel/vmlinux.lds.S
@@ -48,6 +48,7 @@ SECTIONS
 		LOCK_TEXT
 		KPROBES_TEXT
 		IRQENTRY_TEXT
+		SOFTIRQENTRY_TEXT
 		*(.gnu.warning)
 	} = 0
 	_etext = .;
diff --git a/arch/tile/kernel/vmlinux.lds.S b/arch/tile/kernel/vmlinux.lds.S
index 0e059a0..378f5d8 100644
--- a/arch/tile/kernel/vmlinux.lds.S
+++ b/arch/tile/kernel/vmlinux.lds.S
@@ -45,6 +45,7 @@ SECTIONS
     LOCK_TEXT
     KPROBES_TEXT
     IRQENTRY_TEXT
+    SOFTIRQENTRY_TEXT
     __fix_text_end = .;   /* tile-cpack won't rearrange before this */
     ALIGN_FUNCTION();
     *(.hottext*)
diff --git a/arch/x86/kernel/vmlinux.lds.S b/arch/x86/kernel/vmlinux.lds.S
index 74e4bf1..056a97a 100644
--- a/arch/x86/kernel/vmlinux.lds.S
+++ b/arch/x86/kernel/vmlinux.lds.S
@@ -102,6 +102,7 @@ SECTIONS
 		KPROBES_TEXT
 		ENTRY_TEXT
 		IRQENTRY_TEXT
+		SOFTIRQENTRY_TEXT
 		*(.fixup)
 		*(.gnu.warning)
 		/* End of text section */
diff --git a/include/asm-generic/vmlinux.lds.h b/include/asm-generic/vmlinux.lds.h
index c4bd0e2..b470421 100644
--- a/include/asm-generic/vmlinux.lds.h
+++ b/include/asm-generic/vmlinux.lds.h
@@ -456,7 +456,7 @@
 		*(.entry.text)						\
 		VMLINUX_SYMBOL(__entry_text_end) = .;
 
-#ifdef CONFIG_FUNCTION_GRAPH_TRACER
+#if defined(CONFIG_FUNCTION_GRAPH_TRACER) || defined(CONFIG_KASAN)
 #define IRQENTRY_TEXT							\
 		ALIGN_FUNCTION();					\
 		VMLINUX_SYMBOL(__irqentry_text_start) = .;		\
@@ -466,6 +466,16 @@
 #define IRQENTRY_TEXT
 #endif
 
+#if defined(CONFIG_FUNCTION_GRAPH_TRACER) || defined(CONFIG_KASAN)
+#define SOFTIRQENTRY_TEXT						\
+		ALIGN_FUNCTION();					\
+		VMLINUX_SYMBOL(__softirqentry_text_start) = .;		\
+		*(.softirqentry.text)					\
+		VMLINUX_SYMBOL(__softirqentry_text_end) = .;
+#else
+#define SOFTIRQENTRY_TEXT
+#endif
+
 /* Section used for early init (in .S files) */
 #define HEAD_TEXT  *(.head.text)
 
diff --git a/include/linux/ftrace.h b/include/linux/ftrace.h
index c2b340e..4da848d 100644
--- a/include/linux/ftrace.h
+++ b/include/linux/ftrace.h
@@ -799,16 +799,6 @@ ftrace_push_return_trace(unsigned long ret, unsigned long func, int *depth,
  */
 #define __notrace_funcgraph		notrace
 
-/*
- * We want to which function is an entrypoint of a hardirq.
- * That will help us to put a signal on output.
- */
-#define __irq_entry		 __attribute__((__section__(".irqentry.text")))
-
-/* Limits of hardirq entrypoints */
-extern char __irqentry_text_start[];
-extern char __irqentry_text_end[];
-
 #define FTRACE_NOTRACE_DEPTH 65536
 #define FTRACE_RETFUNC_DEPTH 50
 #define FTRACE_RETSTACK_ALLOC_SIZE 32
@@ -845,7 +835,6 @@ static inline void unpause_graph_tracing(void)
 #else /* !CONFIG_FUNCTION_GRAPH_TRACER */
 
 #define __notrace_funcgraph
-#define __irq_entry
 #define INIT_FTRACE_GRAPH
 
 static inline void ftrace_graph_init_task(struct task_struct *t) { }
diff --git a/include/linux/interrupt.h b/include/linux/interrupt.h
index 0e95fcc..1dcecaf 100644
--- a/include/linux/interrupt.h
+++ b/include/linux/interrupt.h
@@ -673,4 +673,24 @@ extern int early_irq_init(void);
 extern int arch_probe_nr_irqs(void);
 extern int arch_early_irq_init(void);
 
+#if defined(CONFIG_FUNCTION_GRAPH_TRACER) || defined(CONFIG_KASAN)
+/*
+ * We want to know which function is an entrypoint of a hardirq or a softirq.
+ */
+#define __irq_entry		 __attribute__((__section__(".irqentry.text")))
+#define __softirq_entry  \
+	__attribute__((__section__(".softirqentry.text")))
+
+/* Limits of hardirq entrypoints */
+extern char __irqentry_text_start[];
+extern char __irqentry_text_end[];
+/* Limits of softirq entrypoints */
+extern char __softirqentry_text_start[];
+extern char __softirqentry_text_end[];
+
+#else
+#define __irq_entry
+#define __softirq_entry
+#endif
+
 #endif
diff --git a/kernel/softirq.c b/kernel/softirq.c
index 479e443..359be4f 100644
--- a/kernel/softirq.c
+++ b/kernel/softirq.c
@@ -227,7 +227,7 @@ static inline bool lockdep_softirq_start(void) { return false; }
 static inline void lockdep_softirq_end(bool in_hardirq) { }
 #endif
 
-asmlinkage __visible void __do_softirq(void)
+asmlinkage __visible void __softirq_entry __do_softirq(void)
 {
 	unsigned long end = jiffies + MAX_SOFTIRQ_TIME;
 	unsigned long old_flags = current->flags;
diff --git a/kernel/trace/trace_functions_graph.c b/kernel/trace/trace_functions_graph.c
index a663cbb..3e6f7d4 100644
--- a/kernel/trace/trace_functions_graph.c
+++ b/kernel/trace/trace_functions_graph.c
@@ -8,6 +8,7 @@
  */
 #include <linux/uaccess.h>
 #include <linux/ftrace.h>
+#include <linux/interrupt.h>
 #include <linux/slab.h>
 #include <linux/fs.h>
 
-- 
2.7.0.rc3.207.g0ac5344

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
