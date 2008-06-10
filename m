Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e3.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m5AM1Hfd018873
	for <linux-mm@kvack.org>; Tue, 10 Jun 2008 18:01:17 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m5AM17iv237874
	for <linux-mm@kvack.org>; Tue, 10 Jun 2008 18:01:07 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m5AM17QP015317
	for <linux-mm@kvack.org>; Tue, 10 Jun 2008 18:01:07 -0400
Date: Tue, 10 Jun 2008 18:01:07 -0400
From: Dave Kleikamp <shaggy@linux.vnet.ibm.com>
Message-Id: <20080610220106.10257.69841.sendpatchset@norville.austin.ibm.com>
In-Reply-To: <20080610220055.10257.84465.sendpatchset@norville.austin.ibm.com>
References: <20080610220055.10257.84465.sendpatchset@norville.austin.ibm.com>
Subject: [RFC:PATCH 02/06] mm: Allow architectures to define additional protection bits
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linuxppc-dev list <Linuxppc-dev@ozlabs.org>
Cc: linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

This patch allows architectures to define functions to deal with
additional protections bits for mmap() and mprotect().

arch_calc_vm_prot_bits() maps additonal protection bits to vm_flags
arch_vm_get_page_prot() maps additional vm_flags to the vma's vm_page_prot
arch_validate_prot() checks for valid values of the protection bits

Note: vm_get_page_prot() is now pretty ugly.  Suggestions?

Signed-off-by: Dave Kleikamp <shaggy@linux.vnet.ibm.com>
---

 include/linux/mman.h |   23 ++++++++++++++++++++++-
 mm/mmap.c            |    5 +++--
 mm/mprotect.c        |    2 +-
 3 files changed, 26 insertions(+), 4 deletions(-)

diff -Nurp linux001/include/linux/mman.h linux002/include/linux/mman.h
--- linux001/include/linux/mman.h	2008-06-05 10:08:01.000000000 -0500
+++ linux002/include/linux/mman.h	2008-06-10 16:48:59.000000000 -0500
@@ -34,6 +34,26 @@ static inline void vm_unacct_memory(long
 }
 
 /*
+ * Allow architectures to handle additional protection bits
+ */
+
+#ifndef HAVE_ARCH_PROT_BITS
+#define arch_calc_vm_prot_bits(prot) 0
+#define arch_vm_get_page_prot(vm_flags) __pgprot(0)
+
+/*
+ * This is called from mprotect().  PROT_GROWSDOWN and PROT_GROWSUP have
+ * already been masked out.
+ *
+ * Returns true if the prot flags are valid
+ */
+static inline int arch_validate_prot(unsigned long prot)
+{
+	return (prot & ~(PROT_READ | PROT_WRITE | PROT_EXEC | PROT_SEM)) == 0;
+}
+#endif /* HAVE_ARCH_PROT_BITS */
+
+/*
  * Optimisation macro.  It is equivalent to:
  *      (x & bit1) ? bit2 : 0
  * but this version is faster.
@@ -51,7 +71,8 @@ calc_vm_prot_bits(unsigned long prot)
 {
 	return _calc_vm_trans(prot, PROT_READ,  VM_READ ) |
 	       _calc_vm_trans(prot, PROT_WRITE, VM_WRITE) |
-	       _calc_vm_trans(prot, PROT_EXEC,  VM_EXEC );
+	       _calc_vm_trans(prot, PROT_EXEC,  VM_EXEC) |
+	       arch_calc_vm_prot_bits(prot);
 }
 
 /*
diff -Nurp linux001/mm/mmap.c linux002/mm/mmap.c
--- linux001/mm/mmap.c	2008-06-05 10:08:03.000000000 -0500
+++ linux002/mm/mmap.c	2008-06-10 16:48:59.000000000 -0500
@@ -72,8 +72,9 @@ pgprot_t protection_map[16] = {
 
 pgprot_t vm_get_page_prot(unsigned long vm_flags)
 {
-	return protection_map[vm_flags &
-				(VM_READ|VM_WRITE|VM_EXEC|VM_SHARED)];
+	return __pgprot(pgprot_val(protection_map[vm_flags &
+				(VM_READ|VM_WRITE|VM_EXEC|VM_SHARED)]) |
+			pgprot_val(arch_vm_get_page_prot(vm_flags)));
 }
 EXPORT_SYMBOL(vm_get_page_prot);
 
diff -Nurp linux001/mm/mprotect.c linux002/mm/mprotect.c
--- linux001/mm/mprotect.c	2008-06-05 10:08:03.000000000 -0500
+++ linux002/mm/mprotect.c	2008-06-10 16:48:59.000000000 -0500
@@ -239,7 +239,7 @@ sys_mprotect(unsigned long start, size_t
 	end = start + len;
 	if (end <= start)
 		return -ENOMEM;
-	if (prot & ~(PROT_READ | PROT_WRITE | PROT_EXEC | PROT_SEM))
+	if (!arch_validate_prot(prot))
 		return -EINVAL;
 
 	reqprot = prot;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
