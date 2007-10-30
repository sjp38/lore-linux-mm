Message-Id: <20071030192104.567760860@polymtl.ca>
References: <20071030191557.947156623@polymtl.ca>
Date: Tue, 30 Oct 2007 15:16:07 -0400
From: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
Subject: [patch 10/28] Add cmpxchg_local to cris
Content-Disposition: inline; filename=add-cmpxchg-local-to-cris.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, matthew@wil.cx, linux-arch@vger.kernel.org, penberg@cs.helsinki.fi, linux-mm@kvack.org, Christoph Lameter <clameter@sgi.com>
Cc: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>, starvik@axis.com
List-ID: <linux-mm.kvack.org>

Use the new generic cmpxchg_local (disables interrupt). Also use the generic
cmpxchg as fallback if SMP is not set.

Signed-off-by: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
CC: clameter@sgi.com
CC: starvik@axis.com
---
 include/asm-cris/system.h |   15 +++++++++++++++
 1 file changed, 15 insertions(+)

Index: linux-2.6-lttng/include/asm-cris/system.h
===================================================================
--- linux-2.6-lttng.orig/include/asm-cris/system.h	2007-08-07 14:31:52.000000000 -0400
+++ linux-2.6-lttng/include/asm-cris/system.h	2007-08-07 14:48:53.000000000 -0400
@@ -66,6 +66,21 @@ static inline unsigned long __xchg(unsig
   return x;
 }
 
+#include <asm-generic/cmpxchg-local.h>
+
+/*
+ * cmpxchg_local and cmpxchg64_local are atomic wrt current CPU. Always make
+ * them available.
+ */
+#define cmpxchg_local(ptr,o,n)					  	    \
+     (__typeof__(*(ptr)))__cmpxchg_local_generic((ptr), (unsigned long)(o), \
+			   	 (unsigned long)(n), sizeof(*(ptr)))
+#define cmpxchg64_local(ptr,o,n) __cmpxchg64_local_generic((ptr), (o), (n))
+
+#ifndef CONFIG_SMP
+#include <asm-generic/cmpxchg.h>
+#endif
+
 #define arch_align_stack(x) (x)
 
 void default_idle(void);

-- 
Mathieu Desnoyers
Computer Engineering Ph.D. Student, Ecole Polytechnique de Montreal
OpenPGP key fingerprint: 8CD5 52C3 8E3C 4140 715F  BA06 3F25 A8FE 3BAE 9A68

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
