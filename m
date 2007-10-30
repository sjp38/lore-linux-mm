Message-Id: <20071030192108.727092833@polymtl.ca>
References: <20071030191557.947156623@polymtl.ca>
Date: Tue, 30 Oct 2007 15:16:19 -0400
From: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
Subject: [patch 22/28] Add cmpxchg_local to s390
Content-Disposition: inline; filename=add-cmpxchg-local-to-s390.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, matthew@wil.cx, linux-arch@vger.kernel.org, penberg@cs.helsinki.fi, linux-mm@kvack.org, Christoph Lameter <clameter@sgi.com>
Cc: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>, schwidefsky@de.ibm.com, linux390@de.ibm.com
List-ID: <linux-mm.kvack.org>

Use the standard __cmpxchg for every type that can be updated atomically.
Use the new generic cmpxchg_local (disables interrupt) for other types.

Signed-off-by: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
CC: clameter@sgi.com
CC: schwidefsky@de.ibm.com
CC: linux390@de.ibm.com
---
 include/asm-s390/system.h |   34 ++++++++++++++++++++++++++++++++++
 1 file changed, 34 insertions(+)

Index: linux-2.6-lttng/include/asm-s390/system.h
===================================================================
--- linux-2.6-lttng.orig/include/asm-s390/system.h	2007-08-27 11:46:43.000000000 -0400
+++ linux-2.6-lttng/include/asm-s390/system.h	2007-08-27 11:48:38.000000000 -0400
@@ -355,6 +355,40 @@ __cmpxchg(volatile void *ptr, unsigned l
 
 #include <linux/irqflags.h>
 
+#include <asm-generic/cmpxchg-local.h>
+
+static inline unsigned long __cmpxchg_local(volatile void *ptr,
+				      unsigned long old,
+				      unsigned long new, int size)
+{
+	switch (size) {
+	case 1:
+	case 2:
+	case 4:
+#ifdef __s390x__
+	case 8:
+#endif
+		return __cmpxchg(ptr, old, new, size);
+	default:
+		return __cmpxchg_local_generic(ptr, old, new, size);
+	}
+
+	return old;
+}
+
+/*
+ * cmpxchg_local and cmpxchg64_local are atomic wrt current CPU. Always make
+ * them available.
+ */
+#define cmpxchg_local(ptr,o,n)						\
+     (__typeof__(*(ptr)))__cmpxchg_local((ptr), (unsigned long)(o),	\
+			   	 (unsigned long)(n), sizeof(*(ptr)))
+#ifdef __s390x__
+#define cmpxchg64_local(ptr,o,n) cmpxchg_local((ptr),(o),(n))
+#else
+#define cmpxchg64_local(ptr,o,n) __cmpxchg64_local_generic((ptr), (o), (n))
+#endif
+
 /*
  * Use to set psw mask except for the first byte which
  * won't be changed by this function.

-- 
Mathieu Desnoyers
Computer Engineering Ph.D. Student, Ecole Polytechnique de Montreal
OpenPGP key fingerprint: 8CD5 52C3 8E3C 4140 715F  BA06 3F25 A8FE 3BAE 9A68

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
