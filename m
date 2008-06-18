Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e6.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m5IMZxkM021059
	for <linux-mm@kvack.org>; Wed, 18 Jun 2008 18:35:59 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m5IMXUaC231336
	for <linux-mm@kvack.org>; Wed, 18 Jun 2008 18:33:30 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m5IMXUfb020050
	for <linux-mm@kvack.org>; Wed, 18 Jun 2008 18:33:30 -0400
Message-Id: <20080618223329.493513729@linux.vnet.ibm.com>
References: <20080618223254.966080905@linux.vnet.ibm.com>
Date: Wed, 18 Jun 2008 17:32:59 -0500
From: shaggy@linux.vnet.ibm.com
Subject: [patch 5/6] powerpc: Add Strong Access Ordering
Content-Disposition: inline; filename=sao.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Paul Mackerras <paulus@au1.ibm.com>, linux-mm@kvack.org, Linuxppc-dev@ozlabs.org
List-ID: <linux-mm.kvack.org>

Allow an application to enable Strong Access Ordering on specific pages of
memory on Power 7 hardware. Currently, power has a weaker memory model than
x86. Implementing a stronger memory model allows an emulator to more
efficiently translate x86 code into power code, resulting in faster code
execution.

On Power 7 hardware, storing 0b1110 in the WIMG bits of the hpte enables
strong access ordering mode for the memory page.  This patchset allows a
user to specify which pages are thus enabled by passing a new protection
bit through mmap() and mprotect().  I have tentatively defined this bit,
PROT_SAO, as 0x10.

Signed-off-by: Dave Kleikamp <shaggy@linux.vnet.ibm.com>
---

 arch/powerpc/kernel/syscalls.c |    3 +++
 include/asm-powerpc/mman.h     |   28 ++++++++++++++++++++++++++++
 2 files changed, 31 insertions(+)

Index: linux-2.6.26-rc5/arch/powerpc/kernel/syscalls.c
===================================================================
--- linux-2.6.26-rc5.orig/arch/powerpc/kernel/syscalls.c
+++ linux-2.6.26-rc5/arch/powerpc/kernel/syscalls.c
@@ -143,6 +143,9 @@ static inline unsigned long do_mmap2(uns
 	struct file * file = NULL;
 	unsigned long ret = -EINVAL;
 
+	if (!arch_validate_prot(prot))
+		goto out;
+
 	if (shift) {
 		if (off & ((1 << shift) - 1))
 			goto out;
Index: linux-2.6.26-rc5/include/asm-powerpc/mman.h
===================================================================
--- linux-2.6.26-rc5.orig/include/asm-powerpc/mman.h
+++ linux-2.6.26-rc5/include/asm-powerpc/mman.h
@@ -1,7 +1,9 @@
 #ifndef _ASM_POWERPC_MMAN_H
 #define _ASM_POWERPC_MMAN_H
 
+#include <asm/cputable.h>
 #include <asm-generic/mman.h>
+#include <linux/mm.h>
 
 /*
  * This program is free software; you can redistribute it and/or
@@ -26,4 +28,30 @@
 #define MAP_POPULATE	0x8000		/* populate (prefault) pagetables */
 #define MAP_NONBLOCK	0x10000		/* do not block on IO */
 
+/*
+ * This file is included by linux/mman.h, so we can't use cacl_vm_prot_bits()
+ * here.  How important is the optimization?
+ */
+static inline unsigned long arch_calc_vm_prot_bits(unsigned long prot)
+{
+	return (prot & PROT_SAO) ? VM_SAO : 0;
+}
+#define arch_calc_vm_prot_bits(prot) arch_calc_vm_prot_bits(prot)
+
+static inline pgprot_t arch_vm_get_page_prot(unsigned long vm_flags)
+{
+	return (vm_flags & VM_SAO) ? __pgprot(_PAGE_SAO) : 0;
+}
+#define arch_vm_get_page_prot(vm_flags) arch_vm_get_page_prot(vm_flags)
+
+static inline int arch_validate_prot(unsigned long prot)
+{
+	if (prot & ~(PROT_READ | PROT_WRITE | PROT_EXEC | PROT_SEM | PROT_SAO))
+		return 0;
+	if ((prot & PROT_SAO) && !cpu_has_feature(CPU_FTR_SAO))
+		return 0;
+	return 1;
+}
+#define arch_validate_prot(prot) arch_validate_prot(prot)
+
 #endif	/* _ASM_POWERPC_MMAN_H */

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
