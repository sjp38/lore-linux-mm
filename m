Message-Id: <20071030192109.669372596@polymtl.ca>
References: <20071030191557.947156623@polymtl.ca>
Date: Tue, 30 Oct 2007 15:16:22 -0400
From: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
Subject: [patch 25/28] Add cmpxchg_local to sparc, move __cmpxchg to system.h
Content-Disposition: inline; filename=add-cmpxchg-local-to-sparc.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, matthew@wil.cx, linux-arch@vger.kernel.org, penberg@cs.helsinki.fi, linux-mm@kvack.org, Christoph Lameter <clameter@sgi.com>
Cc: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>, wli@holomorphy.com, sparclinux@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Move cmpxchg and add cmpxchg_local to system.h.
Use the new generic cmpxchg_local (disables interrupt).

Signed-off-by: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
CC: clameter@sgi.com
CC: wli@holomorphy.com
CC: sparclinux@vger.kernel.org
---
 include/asm-sparc/atomic.h |   36 ----------------------------------
 include/asm-sparc/system.h |   47 +++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 47 insertions(+), 36 deletions(-)

Index: linux-2.6-lttng/include/asm-sparc/atomic.h
===================================================================
--- linux-2.6-lttng.orig/include/asm-sparc/atomic.h	2007-08-10 19:36:01.000000000 -0400
+++ linux-2.6-lttng/include/asm-sparc/atomic.h	2007-08-10 19:42:47.000000000 -0400
@@ -17,42 +17,6 @@ typedef struct { volatile int counter; }
 
 #ifdef __KERNEL__
 
-/* Emulate cmpxchg() the same way we emulate atomics,
- * by hashing the object address and indexing into an array
- * of spinlocks to get a bit of performance...
- *
- * See arch/sparc/lib/atomic32.c for implementation.
- *
- * Cribbed from <asm-parisc/atomic.h>
- */
-#define __HAVE_ARCH_CMPXCHG	1
-
-/* bug catcher for when unsupported size is used - won't link */
-extern void __cmpxchg_called_with_bad_pointer(void);
-/* we only need to support cmpxchg of a u32 on sparc */
-extern unsigned long __cmpxchg_u32(volatile u32 *m, u32 old, u32 new_);
-
-/* don't worry...optimizer will get rid of most of this */
-static __inline__ unsigned long
-__cmpxchg(volatile void *ptr, unsigned long old, unsigned long new_, int size)
-{
-	switch(size) {
-	case 4:
-		return __cmpxchg_u32((u32 *)ptr, (u32)old, (u32)new_);
-	default:
-		__cmpxchg_called_with_bad_pointer();
-		break;
-	}
-	return old;
-}
-
-#define cmpxchg(ptr,o,n) ({						\
-	__typeof__(*(ptr)) _o_ = (o);					\
-	__typeof__(*(ptr)) _n_ = (n);					\
-	(__typeof__(*(ptr))) __cmpxchg((ptr), (unsigned long)_o_,	\
-			(unsigned long)_n_, sizeof(*(ptr)));		\
-})
-
 #define ATOMIC_INIT(i)  { (i) }
 
 extern int __atomic_add_return(int, atomic_t *);
Index: linux-2.6-lttng/include/asm-sparc/system.h
===================================================================
--- linux-2.6-lttng.orig/include/asm-sparc/system.h	2007-08-10 19:43:08.000000000 -0400
+++ linux-2.6-lttng/include/asm-sparc/system.h	2007-08-10 19:43:42.000000000 -0400
@@ -245,6 +245,53 @@ static __inline__ unsigned long __xchg(u
 	return x;
 }
 
+/* Emulate cmpxchg() the same way we emulate atomics,
+ * by hashing the object address and indexing into an array
+ * of spinlocks to get a bit of performance...
+ *
+ * See arch/sparc/lib/atomic32.c for implementation.
+ *
+ * Cribbed from <asm-parisc/atomic.h>
+ */
+#define __HAVE_ARCH_CMPXCHG	1
+
+/* bug catcher for when unsupported size is used - won't link */
+extern void __cmpxchg_called_with_bad_pointer(void);
+/* we only need to support cmpxchg of a u32 on sparc */
+extern unsigned long __cmpxchg_u32(volatile u32 *m, u32 old, u32 new_);
+
+/* don't worry...optimizer will get rid of most of this */
+static __inline__ unsigned long
+__cmpxchg(volatile void *ptr, unsigned long old, unsigned long new_, int size)
+{
+	switch(size) {
+	case 4:
+		return __cmpxchg_u32((u32 *)ptr, (u32)old, (u32)new_);
+	default:
+		__cmpxchg_called_with_bad_pointer();
+		break;
+	}
+	return old;
+}
+
+#define cmpxchg(ptr,o,n) ({						\
+	__typeof__(*(ptr)) _o_ = (o);					\
+	__typeof__(*(ptr)) _n_ = (n);					\
+	(__typeof__(*(ptr))) __cmpxchg((ptr), (unsigned long)_o_,	\
+			(unsigned long)_n_, sizeof(*(ptr)));		\
+})
+
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
 extern void die_if_kernel(char *str, struct pt_regs *regs) __attribute__ ((noreturn));
 
 #endif /* __KERNEL__ */

-- 
Mathieu Desnoyers
Computer Engineering Ph.D. Student, Ecole Polytechnique de Montreal
OpenPGP key fingerprint: 8CD5 52C3 8E3C 4140 715F  BA06 3F25 A8FE 3BAE 9A68

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
