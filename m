Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 56C748D0048
	for <linux-mm@kvack.org>; Wed, 30 Mar 2011 16:24:19 -0400 (EDT)
Message-Id: <20110330202415.596399815@linux.com>
Date: Wed, 30 Mar 2011 15:23:43 -0500
From: Christoph Lameter <cl@linux.com>
Subject: [slubll1 01/19] percpu: Fixup __this_cpu_xchg* operations
References: <20110330202342.669400887@linux.com>
Content-Disposition: inline; filename=fixup_xchg
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: David Rientjes <rientjes@google.com>, linux-mm@kvack.org, Eric Dumazet <eric.dumazet@gmail.com>, "H. Peter Anvin" <hpa@zytor.com>, Mathieu Desnoyers <mathieu.desnoyers@efficios.com>

Somehow we got into a situation where the __this_cpu_xchg() operations were
not defined in the same way as this_cpu_xchg() and friends. I had some build
failures under 32 bit compiles that were addressed by these fixes.

Signed-off-by: Christoph Lameter <cl@linux.com>


---
 arch/x86/include/asm/percpu.h |   12 ++++++------
 1 file changed, 6 insertions(+), 6 deletions(-)

Index: linux-2.6/arch/x86/include/asm/percpu.h
===================================================================
--- linux-2.6.orig/arch/x86/include/asm/percpu.h	2011-03-30 14:09:28.000000000 -0500
+++ linux-2.6/arch/x86/include/asm/percpu.h	2011-03-30 14:10:16.000000000 -0500
@@ -388,12 +388,9 @@ do {									\
 #define __this_cpu_xor_1(pcp, val)	percpu_to_op("xor", (pcp), val)
 #define __this_cpu_xor_2(pcp, val)	percpu_to_op("xor", (pcp), val)
 #define __this_cpu_xor_4(pcp, val)	percpu_to_op("xor", (pcp), val)
-/*
- * Generic fallback operations for __this_cpu_xchg_[1-4] are okay and much
- * faster than an xchg with forced lock semantics.
- */
-#define __this_cpu_xchg_8(pcp, nval)	percpu_xchg_op(pcp, nval)
-#define __this_cpu_cmpxchg_8(pcp, oval, nval)	percpu_cmpxchg_op(pcp, oval, nval)
+#define __this_cpu_xchg_1(pcp, val)	percpu_xchg_op(pcp, val)
+#define __this_cpu_xchg_2(pcp, val)	percpu_xchg_op(pcp, val)
+#define __this_cpu_xchg_4(pcp, val)	percpu_xchg_op(pcp, val)
 
 #define this_cpu_read_1(pcp)		percpu_from_op("mov", (pcp), "m"(pcp))
 #define this_cpu_read_2(pcp)		percpu_from_op("mov", (pcp), "m"(pcp))
@@ -471,6 +468,7 @@ do {									\
 #define __this_cpu_cmpxchg_double_4(pcp1, pcp2, o1, o2, n1, n2)		percpu_cmpxchg8b_double(pcp1, o1, o2, n1, n2)
 #define this_cpu_cmpxchg_double_4(pcp1, pcp2, o1, o2, n1, n2)		percpu_cmpxchg8b_double(pcp1, o1, o2, n1, n2)
 #define irqsafe_cpu_cmpxchg_double_4(pcp1, pcp2, o1, o2, n1, n2)	percpu_cmpxchg8b_double(pcp1, o1, o2, n1, n2)
+
 #endif /* CONFIG_X86_CMPXCHG64 */
 
 /*
@@ -485,6 +483,8 @@ do {									\
 #define __this_cpu_or_8(pcp, val)	percpu_to_op("or", (pcp), val)
 #define __this_cpu_xor_8(pcp, val)	percpu_to_op("xor", (pcp), val)
 #define __this_cpu_add_return_8(pcp, val) percpu_add_return_op(pcp, val)
+#define __this_cpu_xchg_8(pcp, nval)	percpu_xchg_op(pcp, nval)
+#define __this_cpu_cmpxchg_8(pcp, oval, nval)	percpu_cmpxchg_op(pcp, oval, nval)
 
 #define this_cpu_read_8(pcp)		percpu_from_op("mov", (pcp), "m"(pcp))
 #define this_cpu_write_8(pcp, val)	percpu_to_op("mov", (pcp), val)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
