From: Christoph Lameter <cl@linux.com>
Subject: [thisops uV3 03/18] percpu: Generic support for this_cpu_add,sub,dec,inc_return
Date: Tue, 30 Nov 2010 13:07:10 -0600
Message-ID: <20101130190842.869940433@linux.com>
References: <20101130190707.457099608@linux.com>
Return-path: <owner-linux-mm@kvack.org>
Received: from kanga.kvack.org ([205.233.56.17])
	by lo.gmane.org with esmtp (Exim 4.69)
	(envelope-from <owner-linux-mm@kvack.org>)
	id 1PNVZg-0000U0-Qg
	for glkm-linux-mm-2@m.gmane.org; Tue, 30 Nov 2010 20:09:13 +0100
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 9FD316B0095
	for <linux-mm@kvack.org>; Tue, 30 Nov 2010 14:08:51 -0500 (EST)
Content-Disposition: inline; filename=this_cpu_add_dec_return
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, linux-kernel@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org
List-Id: linux-mm.kvack.org

Introduce generic support for this_cpu_add_return etc.

The fallback is to realize these operations with simpler __this_cpu_ops.

Reviewed-by: Tejun Heo <tj@kernel.org>
Reviewed-by: Mathieu Desnoyers <mathieu.desnoyers@efficios.com>
Signed-off-by: Christoph Lameter <cl@linux.com>

---
 include/linux/percpu.h |   77 +++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 77 insertions(+)

Index: linux-2.6/include/linux/percpu.h
===================================================================
--- linux-2.6.orig/include/linux/percpu.h	2010-11-29 10:19:28.000000000 -0600
+++ linux-2.6/include/linux/percpu.h	2010-11-29 10:24:57.000000000 -0600
@@ -240,6 +240,25 @@ extern void __bad_size_call_parameter(vo
 	pscr_ret__;							\
 })
 
+#define __pcpu_size_call_return2(stem, pcp, ...)			\
+({									\
+	typeof(pcp) ret__;						\
+	__verify_pcpu_ptr(&(pcp));					\
+	switch(sizeof(pcp)) {						\
+	case 1: ret__ = stem##1(pcp, __VA_ARGS__);			\
+		break;							\
+	case 2: ret__ = stem##2(pcp, __VA_ARGS__);			\
+		break;							\
+	case 4: ret__ = stem##4(pcp, __VA_ARGS__);			\
+		break;							\
+	case 8: ret__ = stem##8(pcp, __VA_ARGS__);			\
+		break;							\
+	default:							\
+		__bad_size_call_parameter();break;			\
+	}								\
+	ret__;								\
+})
+
 #define __pcpu_size_call(stem, variable, ...)				\
 do {									\
 	__verify_pcpu_ptr(&(variable));					\
@@ -529,6 +548,64 @@ do {									\
 # define __this_cpu_xor(pcp, val)	__pcpu_size_call(__this_cpu_xor_, (pcp), (val))
 #endif
 
+#define _this_cpu_generic_add_return(pcp, val)				\
+({									\
+	typeof(pcp) ret__;						\
+	preempt_disable();						\
+	__this_cpu_add(pcp, val);					\
+	ret__ = __this_cpu_read(pcp);					\
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
+# define this_cpu_add_return(pcp, val)	__pcpu_size_call_return2(this_cpu_add_return_, pcp, val)
+#endif
+
+#define this_cpu_sub_return(pcp, val)	this_cpu_add_return(pcp, -(val))
+#define this_cpu_inc_return(pcp)	this_cpu_add_return(pcp, 1)
+#define this_cpu_dec_return(pcp)	this_cpu_add_return(pcp, -1)
+
+#define __this_cpu_generic_add_return(pcp, val)				\
+({									\
+	typeof(pcp) ret__;						\
+	__this_cpu_add(pcp, val);					\
+	ret__ = __this_cpu_read(pcp);					\
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
+# define __this_cpu_add_return(pcp, val)	__pcpu_size_call_return2(this_cpu_add_return_, pcp, val)
+#endif
+
+#define __this_cpu_sub_return(pcp, val)	this_cpu_add_return(pcp, -(val))
+#define __this_cpu_inc_return(pcp)	this_cpu_add_return(pcp, 1)
+#define __this_cpu_dec_return(pcp)	this_cpu_add_return(pcp, -1)
+
 /*
  * IRQ safe versions of the per cpu RMW operations. Note that these operations
  * are *not* safe against modification of the same variable from another

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
