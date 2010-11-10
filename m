Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 2BE826B004A
	for <linux-mm@kvack.org>; Wed, 10 Nov 2010 10:40:44 -0500 (EST)
Date: Wed, 10 Nov 2010 09:40:39 -0600 (CST)
From: Christoph Lameter <cl@linux.com>
Subject: percpu: Implement this_cpu_add,sub,dec,inc_return
In-Reply-To: <alpine.DEB.2.00.1011091124490.9898@router.home>
Message-ID: <alpine.DEB.2.00.1011100939530.23566@router.home>
References: <alpine.DEB.2.00.1011091124490.9898@router.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, eric.dumazet@gmail.com
List-ID: <linux-mm.kvack.org>

Tried it. This is the result.


Implement this_cpu_add_return and friends and supply an optimized
implementation for x86.

Use this_cpu_add_return for vmstats and nmi processing.

There is no win in terms of code size (stays the same because xadd is a
longer instruction thaninc and requires loading a constant in a register first)
but we eliminate one memory access.

Plus we introduce a more flexible way of per cpu atomic operations.

Signed-off-by: Christoph Lameter <cl@linux.com>

---
 arch/x86/include/asm/percpu.h |   50 +++++++++++++++++++++++++++
 arch/x86/kernel/apic/nmi.c    |    3 -
 include/linux/percpu.h        |   77 ++++++++++++++++++++++++++++++++++++++++++
 mm/vmstat.c                   |    8 +---
 4 files changed, 130 insertions(+), 8 deletions(-)

Index: linux-2.6/arch/x86/kernel/apic/nmi.c
===================================================================
--- linux-2.6.orig/arch/x86/kernel/apic/nmi.c	2010-11-10 09:30:42.000000000 -0600
+++ linux-2.6/arch/x86/kernel/apic/nmi.c	2010-11-10 09:33:18.000000000 -0600
@@ -432,8 +432,7 @@ nmi_watchdog_tick(struct pt_regs *regs,
 		 * Ayiee, looks like this CPU is stuck ...
 		 * wait a few IRQs (5 seconds) before doing the oops ...
 		 */
-		__this_cpu_inc(alert_counter);
-		if (__this_cpu_read(alert_counter) == 5 * nmi_hz)
+		if (__this_cpu_inc_return(alert_counter) == 5 * nmi_hz)
 			/*
 			 * die_nmi will return ONLY if NOTIFY_STOP happens..
 			 */
Index: linux-2.6/include/linux/percpu.h
===================================================================
--- linux-2.6.orig/include/linux/percpu.h	2010-11-10 09:30:42.000000000 -0600
+++ linux-2.6/include/linux/percpu.h	2010-11-10 09:37:58.000000000 -0600
@@ -240,6 +240,20 @@ extern void __bad_size_call_parameter(vo
 	pscr_ret__;							\
 })

+#define __pcpu_size_call_return2(stem, variable, val)			\
+({	typeof(variable) pscr_ret__;					\
+	__verify_pcpu_ptr(&(variable));					\
+	switch(sizeof(variable)) {					\
+	case 1: pscr_ret__ = stem##1(variable, val);break;		\
+	case 2: pscr_ret__ = stem##2(variable, val);break;		\
+	case 4: pscr_ret__ = stem##4(variable, val);break;		\
+	case 8: pscr_ret__ = stem##8(variable, val);break;		\
+	default:							\
+		__bad_size_call_parameter();break;			\
+	}								\
+	pscr_ret__;							\
+})
+
 #define __pcpu_size_call(stem, variable, ...)				\
 do {									\
 	__verify_pcpu_ptr(&(variable));					\
@@ -529,6 +543,69 @@ do {									\
 # define __this_cpu_xor(pcp, val)	__pcpu_size_call(__this_cpu_xor_, (pcp), (val))
 #endif

+#define _this_cpu_generic_add_return(pcp, val)				\
+({	typeof(pcp) ret__;						\
+	preempt_disable();						\
+	__this_cpu_add((pcp), val);					\
+	ret__ = __this_cpu_read((pcp));					\
+	preempt_enable();						\
+	ret__;								\
+})
+
+#ifndef this_cpu_add_return
+# ifndef this_cpu_add_return_1
+#  define this_cpu_add_return_1(pcp, val)	_this_cpu_generic_add_return(pcp, val)
+# endif
+# ifndef this_cpu_add_return_2
+#  define this_cpu_add_return_2(pcp, val)	_this_cpu_generic_add_return(pcp, val)
+# endif
+# ifndef this_cpu_add_return_4
+#  define this_cpu_add_return_4(pcp, val)	_this_cpu_generic_add_return(pcp, val)
+# endif
+# ifndef this_cpu_add_return_8
+#  define this_cpu_add_return_8(pcp, val)	_this_cpu_generic_add_return(pcp, val)
+# endif
+# define this_cpu_add_return(pcp, val)	__pcpu_size_call_return2(this_cpu_add_return_, (pcp), val)
+#endif
+
+#define this_cpu_sub_return(pcp, val)	this_cpu_add_return(pcp, -(val))
+#define this_cpu_inc_return(pcp)	this_cpu_add_return(pcp, 1)
+#define this_cpu_dec_return(pcp)	this_cpu_add_return(pcp, -1)
+
+#define __this_cpu_generic_add_return(pcp, val)				\
+({	typeof(pcp) ret__;						\
+	__this_cpu_add((pcp), val);					\
+	ret__ = __this_cpu_read((pcp));					\
+	ret__;								\
+})
+
+#ifndef __this_cpu_add_return
+# ifndef __this_cpu_add_return_1
+#  define __this_cpu_add_return_1(pcp, val)	__this_cpu_generic_add_return(pcp, val)
+# endif
+# ifndef __this_cpu_add_return_2
+#  define __this_cpu_add_return_2(pcp, val)	__this_cpu_generic_add_return(pcp, val)
+# endif
+# ifndef __this_cpu_add_return_4
+#  define __this_cpu_add_return_4(pcp, val)	__this_cpu_generic_add_return(pcp, val)
+# endif
+# ifndef __this_cpu_add_return_8
+#  define __this_cpu_add_return_8(pcp, val)	__this_cpu_generic_add_return(pcp, val)
+# endif
+# define __this_cpu_add_return(pcp, val)	__pcpu_size_call_return2(this_cpu_add_return_, (pcp), val)
+#endif
+
+#define __this_cpu_sub_return(pcp, val)	this_cpu_add_return(pcp, -(val))
+#define __this_cpu_inc_return(pcp)	this_cpu_add_return(pcp, 1)
+#define __this_cpu_dec_return(pcp)	this_cpu_add_return(pcp, -1)
+
+#define _this_cpu_generic_to_op(pcp, val, op)				\
+do {									\
+	preempt_disable();						\
+	*__this_cpu_ptr(&(pcp)) op val;					\
+	preempt_enable();						\
+} while (0)
+
 /*
  * IRQ safe versions of the per cpu RMW operations. Note that these operations
  * are *not* safe against modification of the same variable from another
Index: linux-2.6/mm/vmstat.c
===================================================================
--- linux-2.6.orig/mm/vmstat.c	2010-11-10 09:30:42.000000000 -0600
+++ linux-2.6/mm/vmstat.c	2010-11-10 09:33:18.000000000 -0600
@@ -227,9 +227,7 @@ void __inc_zone_state(struct zone *zone,
 	s8 * __percpu p = pcp->vm_stat_diff + item;
 	int v, t;

-	__this_cpu_inc(*p);
-
-	v = __this_cpu_read(*p);
+	v = __this_cpu_inc_return(*p);
 	t = __this_cpu_read(pcp->stat_threshold);
 	if (unlikely(v > t)) {
 		int overstep = t / 2;
@@ -251,9 +249,7 @@ void __dec_zone_state(struct zone *zone,
 	s8 * __percpu p = pcp->vm_stat_diff + item;
 	int v, t;

-	__this_cpu_dec(*p);
-
-	v = __this_cpu_read(*p);
+	v = __this_cpu_dec_return(*p);
 	t = __this_cpu_read(pcp->stat_threshold);
 	if (unlikely(v < - t)) {
 		int overstep = t / 2;
Index: linux-2.6/arch/x86/include/asm/percpu.h
===================================================================
--- linux-2.6.orig/arch/x86/include/asm/percpu.h	2010-11-10 09:30:42.000000000 -0600
+++ linux-2.6/arch/x86/include/asm/percpu.h	2010-11-10 09:33:18.000000000 -0600
@@ -177,6 +177,45 @@ do {									\
 	}								\
 } while (0)

+
+/*
+ * Add return operation
+ */
+#define percpu_add_return_op(var, val)					\
+({									\
+	typedef typeof(var) pao_T__;					\
+	typeof(var) pfo_ret__ = val;					\
+	if (0) {							\
+		pao_T__ pao_tmp__;					\
+		pao_tmp__ = (val);					\
+		(void)pao_tmp__;					\
+	}								\
+	switch (sizeof(var)) {						\
+	case 1:								\
+		asm("xaddb %0, "__percpu_arg(1)				\
+			    : "+q" (pfo_ret__), "+m" (var)		\
+			    : : "memory");				\
+		break;							\
+	case 2:								\
+		asm("xaddw %0, "__percpu_arg(1)				\
+			    : "+r" (pfo_ret__), "+m" (var)		\
+			    : : "memory");				\
+		break;							\
+	case 4:								\
+		asm("xaddl %0, "__percpu_arg(1)				\
+			    : "+r"(pfo_ret__), "+m" (var)		\
+			    : : "memory");				\
+		break;							\
+	case 8:								\
+		asm("xaddq %0, "__percpu_arg(1)				\
+			    : "+re" (pfo_ret__),  "+m" (var)		\
+			    : : "memory");				\
+		break;							\
+	default: __bad_percpu_size();					\
+	}								\
+	pfo_ret__;							\
+})
+
 #define percpu_from_op(op, var, constraint)		\
 ({							\
 	typeof(var) pfo_ret__;				\
@@ -300,6 +339,14 @@ do {									\
 #define irqsafe_cpu_xor_2(pcp, val)	percpu_to_op("xor", (pcp), val)
 #define irqsafe_cpu_xor_4(pcp, val)	percpu_to_op("xor", (pcp), val)

+#ifndef CONFIG_M386
+#define __this_cpu_add_return_1(pcp, val)	percpu_add_return_op((pcp), val)
+#define __this_cpu_add_return_2(pcp, val)	percpu_add_return_op((pcp), val)
+#define __this_cpu_add_return_4(pcp, val)	percpu_add_return_op((pcp), val)
+#define this_cpu_add_return_1(pcp, val)		percpu_add_return_op((pcp), val)
+#define this_cpu_add_return_2(pcp, val)		percpu_add_return_op((pcp), val)
+#define this_cpu_add_return_4(pcp, val)		percpu_add_return_op((pcp), val)
+#endif
 /*
  * Per cpu atomic 64 bit operations are only available under 64 bit.
  * 32 bit must fall back to generic operations.
@@ -324,6 +371,9 @@ do {									\
 #define irqsafe_cpu_or_8(pcp, val)	percpu_to_op("or", (pcp), val)
 #define irqsafe_cpu_xor_8(pcp, val)	percpu_to_op("xor", (pcp), val)

+#define __this_cpu_add_return_8(pcp, val)	percpu_add_return_op((pcp), val)
+#define this_cpu_add_return_8(pcp, val)	percpu_add_return_op((pcp), val)
+
 #endif

 /* This is not atomic against other CPUs -- CPU preemption needs to be off */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
