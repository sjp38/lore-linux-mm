Message-Id: <20071030192101.749932864@polymtl.ca>
References: <20071030191557.947156623@polymtl.ca>
Date: Tue, 30 Oct 2007 15:15:58 -0400
From: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
Subject: [patch 01/28] Add cmpxchg_local to asm-generic for per cpu atomic operations
Content-Disposition: inline; filename=add-cmpxchg-local-to-generic-for-up.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org, linux-kernel@vger.kernel.org, matthew@wil.cx, linux-arch@vger.kernel.org, penberg@cs.helsinki.fi, linux-mm@kvack.org, Christoph Lameter <clameter@sgi.com>
Cc: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
List-ID: <linux-mm.kvack.org>

Emulates the cmpxchg_local by disabling interrupts around variable modification.
This is not reentrant wrt NMIs and MCEs. It is only protected against normal
interrupts, but this is enough for architectures without such interrupt sources
or if used in a context where the data is not shared with such handlers.

It can be used as a fallback for architectures lacking a real cmpxchg
instruction.

For architectures that have a real cmpxchg but does not have NMIs or MCE,
testing which of the generic vs architecture specific cmpxchg is the fastest
should be done.

asm-generic/cmpxchg.h defines a cmpxchg that uses cmpxchg_local. It is meant to
be used as a cmpxchg fallback for architectures that do not support SMP.

* Patch series comments

Using cmpxchg_local shows a performance improvements of the fast path goes from
a 66% speedup on a Pentium 4 to a 14% speedup on AMD64.

In detail:

Tested-by: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
Measurements on a Pentium4, 3GHz, Hyperthread.
SLUB Performance testing
========================
1. Kmalloc: Repeatedly allocate then free test

* slub HEAD, test 1
kmalloc(8) = 201 cycles         kfree = 351 cycles
kmalloc(16) = 198 cycles        kfree = 359 cycles
kmalloc(32) = 200 cycles        kfree = 381 cycles
kmalloc(64) = 224 cycles        kfree = 394 cycles
kmalloc(128) = 285 cycles       kfree = 424 cycles
kmalloc(256) = 411 cycles       kfree = 546 cycles
kmalloc(512) = 480 cycles       kfree = 619 cycles
kmalloc(1024) = 623 cycles      kfree = 750 cycles
kmalloc(2048) = 686 cycles      kfree = 811 cycles
kmalloc(4096) = 482 cycles      kfree = 538 cycles
kmalloc(8192) = 680 cycles      kfree = 734 cycles
kmalloc(16384) = 713 cycles     kfree = 843 cycles

* Slub HEAD, test 2
kmalloc(8) = 190 cycles         kfree = 351 cycles
kmalloc(16) = 195 cycles        kfree = 360 cycles
kmalloc(32) = 201 cycles        kfree = 370 cycles
kmalloc(64) = 245 cycles        kfree = 389 cycles
kmalloc(128) = 283 cycles       kfree = 413 cycles
kmalloc(256) = 409 cycles       kfree = 547 cycles
kmalloc(512) = 476 cycles       kfree = 616 cycles
kmalloc(1024) = 628 cycles      kfree = 753 cycles
kmalloc(2048) = 684 cycles      kfree = 811 cycles
kmalloc(4096) = 480 cycles      kfree = 539 cycles
kmalloc(8192) = 661 cycles      kfree = 746 cycles
kmalloc(16384) = 741 cycles     kfree = 856 cycles

* cmpxchg_local Slub test
kmalloc(8) = 83 cycles          kfree = 363 cycles
kmalloc(16) = 85 cycles         kfree = 372 cycles
kmalloc(32) = 92 cycles         kfree = 377 cycles
kmalloc(64) = 115 cycles        kfree = 397 cycles
kmalloc(128) = 179 cycles       kfree = 438 cycles
kmalloc(256) = 314 cycles       kfree = 564 cycles
kmalloc(512) = 398 cycles       kfree = 615 cycles
kmalloc(1024) = 573 cycles      kfree = 745 cycles
kmalloc(2048) = 629 cycles      kfree = 816 cycles
kmalloc(4096) = 473 cycles      kfree = 548 cycles
kmalloc(8192) = 659 cycles      kfree = 745 cycles
kmalloc(16384) = 724 cycles     kfree = 843 cycles

2. Kmalloc: alloc/free test

* slub HEAD, test 1
kmalloc(8)/kfree = 322 cycles
kmalloc(16)/kfree = 318 cycles
kmalloc(32)/kfree = 318 cycles
kmalloc(64)/kfree = 325 cycles
kmalloc(128)/kfree = 318 cycles
kmalloc(256)/kfree = 328 cycles
kmalloc(512)/kfree = 328 cycles
kmalloc(1024)/kfree = 328 cycles
kmalloc(2048)/kfree = 328 cycles
kmalloc(4096)/kfree = 678 cycles
kmalloc(8192)/kfree = 1013 cycles
kmalloc(16384)/kfree = 1157 cycles

* Slub HEAD, test 2
kmalloc(8)/kfree = 323 cycles
kmalloc(16)/kfree = 318 cycles
kmalloc(32)/kfree = 318 cycles
kmalloc(64)/kfree = 318 cycles
kmalloc(128)/kfree = 318 cycles
kmalloc(256)/kfree = 328 cycles
kmalloc(512)/kfree = 328 cycles
kmalloc(1024)/kfree = 328 cycles
kmalloc(2048)/kfree = 328 cycles
kmalloc(4096)/kfree = 648 cycles
kmalloc(8192)/kfree = 1009 cycles
kmalloc(16384)/kfree = 1105 cycles

* cmpxchg_local Slub test
kmalloc(8)/kfree = 112 cycles
kmalloc(16)/kfree = 103 cycles
kmalloc(32)/kfree = 103 cycles
kmalloc(64)/kfree = 103 cycles
kmalloc(128)/kfree = 112 cycles
kmalloc(256)/kfree = 111 cycles
kmalloc(512)/kfree = 111 cycles
kmalloc(1024)/kfree = 111 cycles
kmalloc(2048)/kfree = 121 cycles
kmalloc(4096)/kfree = 650 cycles
kmalloc(8192)/kfree = 1042 cycles
kmalloc(16384)/kfree = 1149 cycles


Tested-by: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
Measurements on a AMD64 2.0 GHz dual-core

In this test, we seem to remove 10 cycles from the kmalloc fast path.
On small allocations, it gives a 14% performance increase. kfree fast
path also seems to have a 10 cycles improvement.

1. Kmalloc: Repeatedly allocate then free test

* cmpxchg_local slub
kmalloc(8) = 63 cycles      kfree = 126 cycles
kmalloc(16) = 66 cycles     kfree = 129 cycles
kmalloc(32) = 76 cycles     kfree = 138 cycles
kmalloc(64) = 100 cycles    kfree = 288 cycles
kmalloc(128) = 128 cycles   kfree = 309 cycles
kmalloc(256) = 170 cycles   kfree = 315 cycles
kmalloc(512) = 221 cycles   kfree = 357 cycles
kmalloc(1024) = 324 cycles  kfree = 393 cycles
kmalloc(2048) = 354 cycles  kfree = 440 cycles
kmalloc(4096) = 394 cycles  kfree = 330 cycles
kmalloc(8192) = 523 cycles  kfree = 481 cycles
kmalloc(16384) = 643 cycles kfree = 649 cycles

* Base
kmalloc(8) = 74 cycles      kfree = 113 cycles
kmalloc(16) = 76 cycles     kfree = 116 cycles
kmalloc(32) = 85 cycles     kfree = 133 cycles
kmalloc(64) = 111 cycles    kfree = 279 cycles
kmalloc(128) = 138 cycles   kfree = 294 cycles
kmalloc(256) = 181 cycles   kfree = 304 cycles
kmalloc(512) = 237 cycles   kfree = 327 cycles
kmalloc(1024) = 340 cycles  kfree = 379 cycles
kmalloc(2048) = 378 cycles  kfree = 433 cycles
kmalloc(4096) = 399 cycles  kfree = 329 cycles
kmalloc(8192) = 528 cycles  kfree = 624 cycles
kmalloc(16384) = 651 cycles kfree = 737 cycles

2. Kmalloc: alloc/free test

* cmpxchg_local slub
kmalloc(8)/kfree = 96 cycles
kmalloc(16)/kfree = 97 cycles
kmalloc(32)/kfree = 97 cycles
kmalloc(64)/kfree = 97 cycles
kmalloc(128)/kfree = 97 cycles
kmalloc(256)/kfree = 105 cycles
kmalloc(512)/kfree = 108 cycles
kmalloc(1024)/kfree = 105 cycles
kmalloc(2048)/kfree = 107 cycles
kmalloc(4096)/kfree = 390 cycles
kmalloc(8192)/kfree = 626 cycles
kmalloc(16384)/kfree = 662 cycles

* Base
kmalloc(8)/kfree = 116 cycles
kmalloc(16)/kfree = 116 cycles
kmalloc(32)/kfree = 116 cycles
kmalloc(64)/kfree = 116 cycles
kmalloc(128)/kfree = 116 cycles
kmalloc(256)/kfree = 126 cycles
kmalloc(512)/kfree = 126 cycles
kmalloc(1024)/kfree = 126 cycles
kmalloc(2048)/kfree = 126 cycles
kmalloc(4096)/kfree = 384 cycles
kmalloc(8192)/kfree = 749 cycles
kmalloc(16384)/kfree = 786 cycles


Tested-by: Christoph Lameter <clameter@sgi.com>
I can confirm Mathieus' measurement now:

Athlon64:

regular NUMA/discontig

1. Kmalloc: Repeatedly allocate then free test
10000 times kmalloc(8) -> 79 cycles kfree -> 92 cycles
10000 times kmalloc(16) -> 79 cycles kfree -> 93 cycles
10000 times kmalloc(32) -> 88 cycles kfree -> 95 cycles
10000 times kmalloc(64) -> 124 cycles kfree -> 132 cycles
10000 times kmalloc(128) -> 157 cycles kfree -> 247 cycles
10000 times kmalloc(256) -> 200 cycles kfree -> 257 cycles
10000 times kmalloc(512) -> 250 cycles kfree -> 277 cycles
10000 times kmalloc(1024) -> 337 cycles kfree -> 314 cycles
10000 times kmalloc(2048) -> 365 cycles kfree -> 330 cycles
10000 times kmalloc(4096) -> 352 cycles kfree -> 240 cycles
10000 times kmalloc(8192) -> 456 cycles kfree -> 340 cycles
10000 times kmalloc(16384) -> 646 cycles kfree -> 471 cycles
2. Kmalloc: alloc/free test
10000 times kmalloc(8)/kfree -> 124 cycles
10000 times kmalloc(16)/kfree -> 124 cycles
10000 times kmalloc(32)/kfree -> 124 cycles
10000 times kmalloc(64)/kfree -> 124 cycles
10000 times kmalloc(128)/kfree -> 124 cycles
10000 times kmalloc(256)/kfree -> 132 cycles
10000 times kmalloc(512)/kfree -> 132 cycles
10000 times kmalloc(1024)/kfree -> 132 cycles
10000 times kmalloc(2048)/kfree -> 132 cycles
10000 times kmalloc(4096)/kfree -> 319 cycles
10000 times kmalloc(8192)/kfree -> 486 cycles
10000 times kmalloc(16384)/kfree -> 539 cycles

cmpxchg_local NUMA/discontig

1. Kmalloc: Repeatedly allocate then free test
10000 times kmalloc(8) -> 55 cycles kfree -> 90 cycles
10000 times kmalloc(16) -> 55 cycles kfree -> 92 cycles
10000 times kmalloc(32) -> 70 cycles kfree -> 91 cycles
10000 times kmalloc(64) -> 100 cycles kfree -> 141 cycles
10000 times kmalloc(128) -> 128 cycles kfree -> 233 cycles
10000 times kmalloc(256) -> 172 cycles kfree -> 251 cycles
10000 times kmalloc(512) -> 225 cycles kfree -> 275 cycles
10000 times kmalloc(1024) -> 325 cycles kfree -> 311 cycles
10000 times kmalloc(2048) -> 346 cycles kfree -> 330 cycles
10000 times kmalloc(4096) -> 351 cycles kfree -> 238 cycles
10000 times kmalloc(8192) -> 450 cycles kfree -> 342 cycles
10000 times kmalloc(16384) -> 630 cycles kfree -> 546 cycles
2. Kmalloc: alloc/free test
10000 times kmalloc(8)/kfree -> 81 cycles
10000 times kmalloc(16)/kfree -> 81 cycles
10000 times kmalloc(32)/kfree -> 81 cycles
10000 times kmalloc(64)/kfree -> 81 cycles
10000 times kmalloc(128)/kfree -> 81 cycles
10000 times kmalloc(256)/kfree -> 91 cycles
10000 times kmalloc(512)/kfree -> 90 cycles
10000 times kmalloc(1024)/kfree -> 91 cycles
10000 times kmalloc(2048)/kfree -> 90 cycles
10000 times kmalloc(4096)/kfree -> 318 cycles
10000 times kmalloc(8192)/kfree -> 483 cycles
10000 times kmalloc(16384)/kfree -> 536 cycles



Signed-off-by: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
CC: linux-arch@vger.kernel.org
CC: clameter@sgi.com
---
 include/asm-generic/cmpxchg-local.h |   60 ++++++++++++++++++++++++++++++++++++
 include/asm-generic/cmpxchg.h       |   22 +++++++++++++
 2 files changed, 82 insertions(+)

Index: linux-2.6-lttng/include/asm-generic/cmpxchg.h
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ linux-2.6-lttng/include/asm-generic/cmpxchg.h	2007-08-22 10:45:12.000000000 -0400
@@ -0,0 +1,22 @@
+#ifndef __ASM_GENERIC_CMPXCHG_H
+#define __ASM_GENERIC_CMPXCHG_H
+
+/*
+ * Generic cmpxchg
+ *
+ * Uses the local cmpxchg. Does not support SMP.
+ */
+#ifdef CONFIG_SMP
+#error "Cannot use generic cmpxchg on SMP"
+#endif
+
+/*
+ * Atomic compare and exchange.
+ *
+ * Do not define __HAVE_ARCH_CMPXCHG because we want to use it to check whether
+ * a cmpxchg primitive faster than repeated local irq save/restore exists.
+ */
+#define cmpxchg(ptr,o,n)	cmpxchg_local((ptr), (o), (n))
+#define cmpxchg64(ptr,o,n)	cmpxchg64_local((ptr), (o), (n))
+
+#endif
Index: linux-2.6-lttng/include/asm-generic/cmpxchg-local.h
===================================================================
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ linux-2.6-lttng/include/asm-generic/cmpxchg-local.h	2007-08-20 17:54:12.000000000 -0400
@@ -0,0 +1,60 @@
+#ifndef __ASM_GENERIC_CMPXCHG_LOCAL_H
+#define __ASM_GENERIC_CMPXCHG_LOCAL_H
+
+#include <linux/types.h>
+
+extern unsigned long wrong_size_cmpxchg(volatile void *ptr);
+
+/*
+ * Generic version of __cmpxchg_local (disables interrupts). Takes an unsigned
+ * long parameter, supporting various types of architectures.
+ */
+static inline unsigned long __cmpxchg_local_generic(volatile void *ptr,
+				    unsigned long old,
+				    unsigned long new, int size)
+{
+	unsigned long flags, prev;
+
+	/*
+	 * Sanity checking, compile-time.
+	 */
+	if (size == 8 && sizeof(unsigned long) != 8)
+		wrong_size_cmpxchg(ptr);
+
+	local_irq_save(flags);
+	switch (size) {
+	case 1: if ((prev = *(u8*)ptr) == old)
+			*(u8*)ptr = (u8)new;
+		break;
+	case 2: if ((prev = *(u16*)ptr) == old)
+			*(u16*)ptr = (u16)new;
+		break;
+	case 4: if ((prev = *(u32*)ptr) == old)
+			*(u32*)ptr = (u32)new;
+		break;
+	case 8: if ((prev = *(u64*)ptr) == old)
+			*(u64*)ptr = (u64)new;
+		break;
+	default:
+		wrong_size_cmpxchg(ptr);
+	}
+	local_irq_restore(flags);
+	return prev;
+}
+
+/*
+ * Generic version of __cmpxchg64_local. Takes an u64 parameter.
+ */
+static inline u64 __cmpxchg64_local_generic(volatile void *ptr, u64 old, u64 new)
+{
+	u64 prev;
+	unsigned long flags;
+
+	local_irq_save(flags);
+	if ((prev = *(u64*)ptr) == old)
+		*(u64*)ptr = new;
+	local_irq_restore(flags);
+	return prev;
+}
+
+#endif

-- 
Mathieu Desnoyers
Computer Engineering Ph.D. Student, Ecole Polytechnique de Montreal
OpenPGP key fingerprint: 8CD5 52C3 8E3C 4140 715F  BA06 3F25 A8FE 3BAE 9A68

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
