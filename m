Message-Id: <20071030192104.252451521@polymtl.ca>
References: <20071030191557.947156623@polymtl.ca>
Date: Tue, 30 Oct 2007 15:16:06 -0400
From: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
Subject: [patch 09/28] Add cmpxchg_local to blackfin, replace __cmpxchg by generic cmpxchg
Content-Disposition: inline; filename=add-cmpxchg-local-to-blackfin.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, matthew@wil.cx, linux-arch@vger.kernel.org, penberg@cs.helsinki.fi, linux-mm@kvack.org, Christoph Lameter <clameter@sgi.com>
Cc: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>, michael.frysinger@analog.com
List-ID: <linux-mm.kvack.org>

Use the new generic cmpxchg_local (disables interrupt). Also use the generic
cmpxchg as fallback if SMP is not set since nobody seems to know why __cmpxchg
has been implemented in assembly in the first place thather than in plain C.

Signed-off-by: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
CC: clameter@sgi.com
CC: michael.frysinger@analog.com
---
 include/asm-blackfin/system.h |   59 ++++++++----------------------------------
 1 file changed, 12 insertions(+), 47 deletions(-)

Index: linux-2.6-lttng/include/asm-blackfin/system.h
===================================================================
--- linux-2.6-lttng.orig/include/asm-blackfin/system.h	2007-08-07 14:31:52.000000000 -0400
+++ linux-2.6-lttng/include/asm-blackfin/system.h	2007-08-07 14:47:31.000000000 -0400
@@ -176,55 +176,20 @@ static inline unsigned long __xchg(unsig
 	return tmp;
 }
 
+#include <asm-generic/cmpxchg-local.h>
+
 /*
- * Atomic compare and exchange.  Compare OLD with MEM, if identical,
- * store NEW in MEM.  Return the initial value in MEM.  Success is
- * indicated by comparing RETURN with OLD.
+ * cmpxchg_local and cmpxchg64_local are atomic wrt current CPU. Always make
+ * them available.
  */
-static inline unsigned long __cmpxchg(volatile void *ptr, unsigned long old,
-				      unsigned long new, int size)
-{
-	unsigned long tmp = 0;
-	unsigned long flags = 0;
-
-	local_irq_save(flags);
-
-	switch (size) {
-	case 1:
-		__asm__ __volatile__
-			("%0 = b%3 (z);\n\t"
-			 "CC = %1 == %0;\n\t"
-			 "IF !CC JUMP 1f;\n\t"
-			 "b%3 = %2;\n\t"
-			 "1:\n\t"
-			 : "=&d" (tmp) : "d" (old), "d" (new), "m" (*__xg(ptr)) : "memory");
-		break;
-	case 2:
-		__asm__ __volatile__
-			("%0 = w%3 (z);\n\t"
-			 "CC = %1 == %0;\n\t"
-			 "IF !CC JUMP 1f;\n\t"
-			 "w%3 = %2;\n\t"
-			 "1:\n\t"
-			 : "=&d" (tmp) : "d" (old), "d" (new), "m" (*__xg(ptr)) : "memory");
-		break;
-	case 4:
-		__asm__ __volatile__
-			("%0 = %3;\n\t"
-			 "CC = %1 == %0;\n\t"
-			 "IF !CC JUMP 1f;\n\t"
-			 "%3 = %2;\n\t"
-			 "1:\n\t"
-			 : "=&d" (tmp) : "d" (old), "d" (new), "m" (*__xg(ptr)) : "memory");
-		break;
-	}
-	local_irq_restore(flags);
-	return tmp;
-}
-
-#define cmpxchg(ptr,o,n)\
-        ((__typeof__(*(ptr)))__cmpxchg((ptr),(unsigned long)(o),\
-                                        (unsigned long)(n),sizeof(*(ptr))))
+#define cmpxchg_local(ptr,o,n)					  	    \
+     (__typeof__(*(ptr)))__cmpxchg_local_generic((ptr), (unsigned long)(o), \
+			   	 (unsigned long)(n), sizeof(*(ptr)))
+#define cmpxchg64_local(ptr,o,n) __cmpxchg64_local_generic((ptr), (o), (n))
+
+#ifndef CONFIG_SMP
+#include <asm-generic/cmpxchg.h>
+#endif
 
 #define prepare_to_switch()     do { } while(0)
 

-- 
Mathieu Desnoyers
Computer Engineering Ph.D. Student, Ecole Polytechnique de Montreal
OpenPGP key fingerprint: 8CD5 52C3 8E3C 4140 715F  BA06 3F25 A8FE 3BAE 9A68

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
