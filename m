Message-Id: <20071030192107.805918575@polymtl.ca>
References: <20071030191557.947156623@polymtl.ca>
Date: Tue, 30 Oct 2007 15:16:16 -0400
From: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
Subject: [patch 19/28] Add cmpxchg_local to m68knommu
Content-Disposition: inline; filename=add-cmpxchg-local-to-m68knommu.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, matthew@wil.cx, linux-arch@vger.kernel.org, penberg@cs.helsinki.fi, linux-mm@kvack.org, Christoph Lameter <clameter@sgi.com>
Cc: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>, gerg@uclinux.org
List-ID: <linux-mm.kvack.org>

Use the new generic cmpxchg_local (disables interrupt). Also use the generic
cmpxchg as fallback if SMP is not set.

Signed-off-by: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
CC: clameter@sgi.com
CC: gerg@uclinux.org
---
 include/asm-m68knommu/system.h |   28 +++++++++++-----------------
 1 file changed, 11 insertions(+), 17 deletions(-)

Index: linux-2.6-lttng/include/asm-m68knommu/system.h
===================================================================
--- linux-2.6-lttng.orig/include/asm-m68knommu/system.h	2007-07-20 18:36:08.000000000 -0400
+++ linux-2.6-lttng/include/asm-m68knommu/system.h	2007-07-20 19:37:02.000000000 -0400
@@ -187,26 +187,20 @@ static inline unsigned long __xchg(unsig
 }
 #endif
 
+#include <asm-generic/cmpxchg-local.h>
+
 /*
- * Atomic compare and exchange.  Compare OLD with MEM, if identical,
- * store NEW in MEM.  Return the initial value in MEM.  Success is
- * indicated by comparing RETURN with OLD.
+ * cmpxchg_local and cmpxchg64_local are atomic wrt current CPU. Always make
+ * them available.
  */
-#define __HAVE_ARCH_CMPXCHG	1
-
-static __inline__ unsigned long
-cmpxchg(volatile int *p, int old, int new)
-{
-	unsigned long flags;
-	int prev;
-
-	local_irq_save(flags);
-	if ((prev = *p) == old)
-		*p = new;
-	local_irq_restore(flags);
-	return(prev);
-}
+#define cmpxchg_local(ptr,o,n)					  	    \
+     (__typeof__(*(ptr)))__cmpxchg_local_generic((ptr), (unsigned long)(o), \
+			   	 (unsigned long)(n), sizeof(*(ptr)))
+#define cmpxchg64_local(ptr,o,n) __cmpxchg64_local_generic((ptr), (o), (n))
 
+#ifndef CONFIG_SMP
+#include <asm-generic/cmpxchg.h>
+#endif
 
 #ifdef CONFIG_M68332
 #define HARD_RESET_NOW() ({		\

-- 
Mathieu Desnoyers
Computer Engineering Ph.D. Student, Ecole Polytechnique de Montreal
OpenPGP key fingerprint: 8CD5 52C3 8E3C 4140 715F  BA06 3F25 A8FE 3BAE 9A68

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
