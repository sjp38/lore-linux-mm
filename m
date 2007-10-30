Message-Id: <20071030192107.465641328@polymtl.ca>
References: <20071030191557.947156623@polymtl.ca>
Date: Tue, 30 Oct 2007 15:16:15 -0400
From: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
Subject: [patch 18/28] Add cmpxchg_local to m86k
Content-Disposition: inline; filename=add-cmpxchg-local-to-m68k.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, matthew@wil.cx, linux-arch@vger.kernel.org, penberg@cs.helsinki.fi, linux-mm@kvack.org, Christoph Lameter <clameter@sgi.com>
Cc: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>, zippel@linux-m68k.org, linux-m68k@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Use the new generic cmpxchg_local (disables interrupt). Also use the generic
cmpxchg as fallback if SMP is not set.

Signed-off-by: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
CC: clameter@sgi.com
CC: zippel@linux-m68k.org
CC: linux-m68k@lists.linux-m68k.org
---
 include/asm-m68k/system.h |   21 +++++++++++++++++++++
 1 file changed, 21 insertions(+)

Index: linux-2.6-lttng/include/asm-m68k/system.h
===================================================================
--- linux-2.6-lttng.orig/include/asm-m68k/system.h	2007-08-07 14:31:51.000000000 -0400
+++ linux-2.6-lttng/include/asm-m68k/system.h	2007-08-07 15:01:41.000000000 -0400
@@ -154,6 +154,10 @@ static inline unsigned long __xchg(unsig
 }
 #endif
 
+#include <asm-generic/cmpxchg-local.h>
+
+#define cmpxchg64_local(ptr,o,n) __cmpxchg64_local_generic((ptr), (o), (n))
+
 /*
  * Atomic compare and exchange.  Compare OLD with MEM, if identical,
  * store NEW in MEM.  Return the initial value in MEM.  Success is
@@ -188,6 +192,23 @@ static inline unsigned long __cmpxchg(vo
 #define cmpxchg(ptr,o,n)\
 	((__typeof__(*(ptr)))__cmpxchg((ptr),(unsigned long)(o),\
 					(unsigned long)(n),sizeof(*(ptr))))
+#define cmpxchg_local(ptr,o,n)\
+	((__typeof__(*(ptr)))__cmpxchg((ptr),(unsigned long)(o),\
+					(unsigned long)(n),sizeof(*(ptr))))
+#else
+
+/*
+ * cmpxchg_local and cmpxchg64_local are atomic wrt current CPU. Always make
+ * them available.
+ */
+#define cmpxchg_local(ptr,o,n)					  	    \
+     (__typeof__(*(ptr)))__cmpxchg_local_generic((ptr), (unsigned long)(o), \
+			   	 (unsigned long)(n), sizeof(*(ptr)))
+
+#ifndef CONFIG_SMP
+#include <asm-generic/cmpxchg.h>
+#endif
+
 #endif
 
 #define arch_align_stack(x) (x)

-- 
Mathieu Desnoyers
Computer Engineering Ph.D. Student, Ecole Polytechnique de Montreal
OpenPGP key fingerprint: 8CD5 52C3 8E3C 4140 715F  BA06 3F25 A8FE 3BAE 9A68

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
