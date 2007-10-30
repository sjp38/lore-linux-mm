Message-Id: <20071030192103.932633073@polymtl.ca>
References: <20071030191557.947156623@polymtl.ca>
Date: Tue, 30 Oct 2007 15:16:05 -0400
From: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
Subject: [patch 08/28] Add cmpxchg_local to avr32
Content-Disposition: inline; filename=add-cmpxchg-local-to-avr32.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, matthew@wil.cx, linux-arch@vger.kernel.org, penberg@cs.helsinki.fi, linux-mm@kvack.org, Christoph Lameter <clameter@sgi.com>
Cc: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>, Haavard Skinnemoen <hskinnemoen@atmel.com>
List-ID: <linux-mm.kvack.org>

Use the new generic cmpxchg_local (disables interrupt) for 8, 16 and 64 bits
cmpxchg_local. Use the __cmpxchg_u32 primitive for 32 bits cmpxchg_local.

Note that cmpxchg only uses the __cmpxchg_u32 or __cmpxchg_u64 and will cause
a linker error if called with 8 or 16 bits argument.

Signed-off-by: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
Acked-by: Haavard Skinnemoen <hskinnemoen@atmel.com>
CC: clameter@sgi.com
CC: hskinnemoen@atmel.com
---
 include/asm-avr32/system.h |   23 +++++++++++++++++++++++
 1 file changed, 23 insertions(+)

Index: linux-2.6-lttng/include/asm-avr32/system.h
===================================================================
--- linux-2.6-lttng.orig/include/asm-avr32/system.h	2007-07-20 19:10:57.000000000 -0400
+++ linux-2.6-lttng/include/asm-avr32/system.h	2007-07-20 19:32:36.000000000 -0400
@@ -140,6 +140,29 @@ static inline unsigned long __cmpxchg(vo
 				   (unsigned long)(new),	\
 				   sizeof(*(ptr))))
 
+#include <asm-generic/cmpxchg-local.h>
+
+static inline unsigned long __cmpxchg_local(volatile void *ptr,
+				      unsigned long old,
+				      unsigned long new, int size)
+{
+	switch (size) {
+	case 4:
+		return __cmpxchg_u32(ptr, old, new);
+	default:
+		return __cmpxchg_local_generic(ptr, old, new, size);
+	}
+
+	return old;
+}
+
+#define cmpxchg_local(ptr, old, new)					\
+	((typeof(*(ptr)))__cmpxchg_local((ptr), (unsigned long)(old),	\
+				   (unsigned long)(new),		\
+				   sizeof(*(ptr))))
+
+#define cmpxchg64_local(ptr,o,n) __cmpxchg64_local_generic((ptr), (o), (n))
+
 struct pt_regs;
 void NORET_TYPE die(const char *str, struct pt_regs *regs, long err);
 void _exception(long signr, struct pt_regs *regs, int code,

-- 
Mathieu Desnoyers
Computer Engineering Ph.D. Student, Ecole Polytechnique de Montreal
OpenPGP key fingerprint: 8CD5 52C3 8E3C 4140 715F  BA06 3F25 A8FE 3BAE 9A68

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
