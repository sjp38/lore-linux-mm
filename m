Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e5.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m5AM1Ohm021551
	for <linux-mm@kvack.org>; Tue, 10 Jun 2008 18:01:24 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m5AM1PUu183568
	for <linux-mm@kvack.org>; Tue, 10 Jun 2008 18:01:25 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m5AM1OtB015863
	for <linux-mm@kvack.org>; Tue, 10 Jun 2008 18:01:24 -0400
Date: Tue, 10 Jun 2008 18:01:24 -0400
From: Dave Kleikamp <shaggy@linux.vnet.ibm.com>
Message-Id: <20080610220123.10257.69686.sendpatchset@norville.austin.ibm.com>
In-Reply-To: <20080610220055.10257.84465.sendpatchset@norville.austin.ibm.com>
References: <20080610220055.10257.84465.sendpatchset@norville.austin.ibm.com>
Subject: [RFC:PATCH 05/06] powerpc: Add Strong Access Ordering
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linuxppc-dev list <Linuxppc-dev@ozlabs.org>
Cc: linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

Things I don't like about this patch:

1. All the includes I added to asm-powerpc/mman.h
2. It doesn't look like mmap() used to validate prot.  Now instead of
ignoring invalid values, it will return -EINVAL.  Could this be a problem?
3. Are these new functions in any hot paths that the extra instructions will
add any significant overhead?

Signed-off-by: Dave Kleikamp <shaggy@linux.vnet.ibm.com>
---

 arch/powerpc/kernel/syscalls.c |    3 +++
 include/asm-powerpc/mman.h     |   26 ++++++++++++++++++++++++++
 2 files changed, 29 insertions(+)

diff -Nurp linux004/arch/powerpc/kernel/syscalls.c linux005/arch/powerpc/kernel/syscalls.c
--- linux004/arch/powerpc/kernel/syscalls.c	2008-06-05 10:07:32.000000000 -0500
+++ linux005/arch/powerpc/kernel/syscalls.c	2008-06-10 16:48:59.000000000 -0500
@@ -143,6 +143,9 @@ static inline unsigned long do_mmap2(uns
 	struct file * file = NULL;
 	unsigned long ret = -EINVAL;
 
+	if (!arch_validate_prot(prot))
+		goto out;
+
 	if (shift) {
 		if (off & ((1 << shift) - 1))
 			goto out;
diff -Nurp linux004/include/asm-powerpc/mman.h linux005/include/asm-powerpc/mman.h
--- linux004/include/asm-powerpc/mman.h	2008-06-10 16:48:59.000000000 -0500
+++ linux005/include/asm-powerpc/mman.h	2008-06-10 16:48:59.000000000 -0500
@@ -1,7 +1,9 @@
 #ifndef _ASM_POWERPC_MMAN_H
 #define _ASM_POWERPC_MMAN_H
 
+#include <asm/cputable.h>
 #include <asm-generic/mman.h>
+#include <linux/mm.h>
 
 /*
  * This program is free software; you can redistribute it and/or
@@ -26,4 +28,28 @@
 #define MAP_POPULATE	0x8000		/* populate (prefault) pagetables */
 #define MAP_NONBLOCK	0x10000		/* do not block on IO */
 
+#define HAVE_ARCH_PROT_BITS
+
+/*
+ * This file is included by linux/mman.h, so we can't use cacl_vm_prot_bits()
+ * here.  How important is the optimization?
+ */
+static inline unsigned long arch_calc_vm_prot_bits(unsigned long prot)
+{
+	return (prot & PROT_SAO) ? VM_SAO : 0;
+}
+
+static inline pgprot_t arch_vm_get_page_prot(unsigned long vm_flags)
+{
+	return (vm_flags & VM_SAO) ? __pgprot(_PAGE_SAO) : 0;
+}
+
+static inline int arch_validate_prot(unsigned long prot)
+{
+	if (prot & ~(PROT_READ | PROT_WRITE | PROT_EXEC | PROT_SEM | PROT_SAO))
+		return 1;
+	if ((prot & PROT_SAO) && !cpu_has_feature(CPU_FTR_SAO))
+		return 1;
+	return 0;
+}
 #endif	/* _ASM_POWERPC_MMAN_H */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
