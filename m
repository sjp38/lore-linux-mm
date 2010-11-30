From: Christoph Lameter <cl@linux.com>
Subject: [thisops uV3 04/18] x86: Support for this_cpu_add,sub,dec,inc_return
Date: Tue, 30 Nov 2010 13:07:11 -0600
Message-ID: <20101130190843.437924198@linux.com>
References: <20101130190707.457099608@linux.com>
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by lo.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1PNVZN-0000E7-2e
	for glkm-linux-mm-2@m.gmane.org; Tue, 30 Nov 2010 20:08:53 +0100
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 6B14F6B0088
	for <linux-mm@kvack.org>; Tue, 30 Nov 2010 14:08:46 -0500 (EST)
Content-Disposition: inline; filename=this_cpu_add_x86
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, linux-kernel@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org
List-Id: linux-mm.kvack.org

Supply an implementation for x86 in order to generate more efficient code.

V2->V3:
	- Cleanup
	- Remove strange type checking from percpu_add_return_op.

Signed-off-by: Christoph Lameter <cl@linux.com>

---
 arch/x86/include/asm/percpu.h |   46 ++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 46 insertions(+)

Index: linux-2.6/arch/x86/include/asm/percpu.h
===================================================================
--- linux-2.6.orig/arch/x86/include/asm/percpu.h	2010-11-29 14:29:13.000000000 -0600
+++ linux-2.6/arch/x86/include/asm/percpu.h	2010-11-30 08:42:02.000000000 -0600
@@ -177,6 +177,41 @@ do {									\
 	}								\
 } while (0)
 
+
+/*
+ * Add return operation
+ */
+#define percpu_add_return_op(var, val)					\
+({									\
+	typedef typeof(var) pao_T__;					\
+	typeof(var) ret__ = val;					\
+	switch (sizeof(var)) {						\
+	case 1:								\
+		asm("xaddb %0, "__percpu_arg(1)				\
+			    : "+q" (ret__), "+m" (var)			\
+			    : : "memory");				\
+		break;							\
+	case 2:								\
+		asm("xaddw %0, "__percpu_arg(1)				\
+			    : "+r" (ret__), "+m" (var)			\
+			    : : "memory");				\
+		break;							\
+	case 4:								\
+		asm("xaddl %0, "__percpu_arg(1)				\
+			    : "+r"(ret__), "+m" (var)			\
+			    : : "memory");				\
+		break;							\
+	case 8:								\
+		asm("xaddq %0, "__percpu_arg(1)				\
+			    : "+re" (ret__),  "+m" (var)		\
+			    : : "memory");				\
+		break;							\
+	default: __bad_percpu_size();					\
+	}								\
+	ret__ += val;							\
+	ret__;								\
+})
+
 #define percpu_from_op(op, var, constraint)		\
 ({							\
 	typeof(var) pfo_ret__;				\
@@ -300,6 +335,14 @@ do {									\
 #define irqsafe_cpu_xor_2(pcp, val)	percpu_to_op("xor", (pcp), val)
 #define irqsafe_cpu_xor_4(pcp, val)	percpu_to_op("xor", (pcp), val)
 
+#ifndef CONFIG_M386
+#define __this_cpu_add_return_1(pcp, val)	percpu_add_return_op(pcp, val)
+#define __this_cpu_add_return_2(pcp, val)	percpu_add_return_op(pcp, val)
+#define __this_cpu_add_return_4(pcp, val)	percpu_add_return_op(pcp, val)
+#define this_cpu_add_return_1(pcp, val)		percpu_add_return_op(pcp, val)
+#define this_cpu_add_return_2(pcp, val)		percpu_add_return_op(pcp, val)
+#define this_cpu_add_return_4(pcp, val)		percpu_add_return_op(pcp, val)
+#endif
 /*
  * Per cpu atomic 64 bit operations are only available under 64 bit.
  * 32 bit must fall back to generic operations.
@@ -324,6 +367,9 @@ do {									\
 #define irqsafe_cpu_or_8(pcp, val)	percpu_to_op("or", (pcp), val)
 #define irqsafe_cpu_xor_8(pcp, val)	percpu_to_op("xor", (pcp), val)
 
+#define __this_cpu_add_return_8(pcp, val)	percpu_add_return_op(pcp, val)
+#define this_cpu_add_return_8(pcp, val)	percpu_add_return_op(pcp, val)
+
 #endif
 
 /* This is not atomic against other CPUs -- CPU preemption needs to be off */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
