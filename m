Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e6.ny.us.ibm.com (8.12.10/8.12.10) with ESMTP id iBH0iM6q011204
	for <linux-mm@kvack.org>; Thu, 16 Dec 2004 19:44:22 -0500
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.12.10/NCO/VER6.6) with ESMTP id iBH0iLqZ282590
	for <linux-mm@kvack.org>; Thu, 16 Dec 2004 19:44:21 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11/8.12.11) with ESMTP id iBH0iLHq000300
	for <linux-mm@kvack.org>; Thu, 16 Dec 2004 19:44:21 -0500
Subject: [patch] CONFIG_ARCH_HAS_ATOMIC_UNSIGNED
From: Dave Hansen <haveblue@us.ibm.com>
Date: Thu, 16 Dec 2004 16:44:20 -0800
Message-Id: <E1Cf6EG-00015y-00@kernel.beaverton.ibm.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: ak@suse.de
Cc: linux-mm@kvack.org, Dave Hansen <haveblue@us.ibm.com>
List-ID: <linux-mm.kvack.org>

This reduces another one of the dependencies that struct page's
definition has on any arch-specific header files.  Currently,
only x86_64 uses this, so it's the only architecture that needed
to be modified.

Signed-off-by: Dave Hansen <haveblue@us.ibm.com>
---

 apw2-dave/arch/x86_64/Kconfig         |    4 ++++
 apw2-dave/include/asm-x86_64/bitops.h |    2 --
 apw2-dave/include/linux/mm.h          |    2 +-
 apw2-dave/include/linux/mmzone.h      |    2 +-
 4 files changed, 6 insertions(+), 4 deletions(-)

diff -puN arch/x86_64/Kconfig~000-CONFIG_ARCH_HAS_ATOMIC_UNSIGNED arch/x86_64/Kconfig
--- apw2/arch/x86_64/Kconfig~000-CONFIG_ARCH_HAS_ATOMIC_UNSIGNED	2004-12-16 16:29:29.000000000 -0800
+++ apw2-dave/arch/x86_64/Kconfig	2004-12-16 16:30:48.000000000 -0800
@@ -193,6 +193,10 @@ config X86_LOCAL_APIC
 	bool
 	default y
 
+config ARCH_HAS_ATOMIC_UNSIGNED
+	bool
+	default y
+
 config MTRR
 	bool "MTRR (Memory Type Range Register) support"
 	---help---
diff -puN include/linux/mm.h~000-CONFIG_ARCH_HAS_ATOMIC_UNSIGNED include/linux/mm.h
--- apw2/include/linux/mm.h~000-CONFIG_ARCH_HAS_ATOMIC_UNSIGNED	2004-12-16 16:29:29.000000000 -0800
+++ apw2-dave/include/linux/mm.h	2004-12-16 16:30:57.000000000 -0800
@@ -216,7 +216,7 @@ struct vm_operations_struct {
 struct mmu_gather;
 struct inode;
 
-#ifdef ARCH_HAS_ATOMIC_UNSIGNED
+#ifdef CONFIG_ARCH_HAS_ATOMIC_UNSIGNED
 typedef unsigned page_flags_t;
 #else
 typedef unsigned long page_flags_t;
diff -puN include/linux/mmzone.h~000-CONFIG_ARCH_HAS_ATOMIC_UNSIGNED include/linux/mmzone.h
--- apw2/include/linux/mmzone.h~000-CONFIG_ARCH_HAS_ATOMIC_UNSIGNED	2004-12-16 16:29:29.000000000 -0800
+++ apw2-dave/include/linux/mmzone.h	2004-12-16 16:31:07.000000000 -0800
@@ -388,7 +388,7 @@ extern struct pglist_data contig_page_da
 
 #include <asm/mmzone.h>
 
-#if BITS_PER_LONG == 32 || defined(ARCH_HAS_ATOMIC_UNSIGNED)
+#if BITS_PER_LONG == 32 || defined(CONFIG_ARCH_HAS_ATOMIC_UNSIGNED)
 /*
  * with 32 bit page->flags field, we reserve 8 bits for node/zone info.
  * there are 3 zones (2 bits) and this leaves 8-2=6 bits for nodes.
diff -puN include/asm-x86_64/bitops.h~000-CONFIG_ARCH_HAS_ATOMIC_UNSIGNED include/asm-x86_64/bitops.h
--- apw2/include/asm-x86_64/bitops.h~000-CONFIG_ARCH_HAS_ATOMIC_UNSIGNED	2004-12-16 16:32:42.000000000 -0800
+++ apw2-dave/include/asm-x86_64/bitops.h	2004-12-16 16:32:48.000000000 -0800
@@ -411,8 +411,6 @@ static __inline__ int ffs(int x)
 /* find last set bit */
 #define fls(x) generic_fls(x)
 
-#define ARCH_HAS_ATOMIC_UNSIGNED 1
-
 #endif /* __KERNEL__ */
 
 #endif /* _X86_64_BITOPS_H */
_
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
