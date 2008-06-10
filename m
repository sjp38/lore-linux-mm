Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e4.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m5AM1DSs015823
	for <linux-mm@kvack.org>; Tue, 10 Jun 2008 18:01:13 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m5AM1DaB213264
	for <linux-mm@kvack.org>; Tue, 10 Jun 2008 18:01:13 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m5AM1DA2015491
	for <linux-mm@kvack.org>; Tue, 10 Jun 2008 18:01:13 -0400
Date: Tue, 10 Jun 2008 18:01:12 -0400
From: Dave Kleikamp <shaggy@linux.vnet.ibm.com>
Message-Id: <20080610220112.10257.48747.sendpatchset@norville.austin.ibm.com>
In-Reply-To: <20080610220055.10257.84465.sendpatchset@norville.austin.ibm.com>
References: <20080610220055.10257.84465.sendpatchset@norville.austin.ibm.com>
Subject: [RFC:PATCH 03/06] powerpc: Define flags for Strong Access Ordering
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linuxppc-dev list <Linuxppc-dev@ozlabs.org>
Cc: linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

This patch defines:

- PROT_SAO, which is passed into mmap() and mprotect() in the prot field
- VM_SAO in vma->vm_flags, and
- _PAGE_SAO, the combination of WIMG bits in the pte that enables strong
access ordering for the page.

NOTE: There doesn't seem to be a precedent for architecture-dependent vm_flags.
It may be better to define VM_SAO somewhere in include/asm-powerpc/.  Since
vm_flags is a long, defining it in the high-order word would help prevent a
collision with any newly added values in architecture-independent code.

Signed-off-by: Dave Kleikamp <shaggy@linux.vnet.ibm.com>
---

 include/asm-powerpc/mman.h          |    2 ++
 include/asm-powerpc/pgtable-ppc64.h |    3 +++
 include/linux/mm.h                  |    1 +
 3 files changed, 6 insertions(+)

diff -Nurp linux002/include/asm-powerpc/mman.h linux003/include/asm-powerpc/mman.h
--- linux002/include/asm-powerpc/mman.h	2008-04-16 21:49:44.000000000 -0500
+++ linux003/include/asm-powerpc/mman.h	2008-06-10 16:48:59.000000000 -0500
@@ -10,6 +10,8 @@
  * 2 of the License, or (at your option) any later version.
  */
 
+#define PROT_SAO	0x10		/* Strong Access Ordering */
+
 #define MAP_RENAME      MAP_ANONYMOUS   /* In SunOS terminology */
 #define MAP_NORESERVE   0x40            /* don't reserve swap pages */
 #define MAP_LOCKED	0x80
diff -Nurp linux002/include/asm-powerpc/pgtable-ppc64.h linux003/include/asm-powerpc/pgtable-ppc64.h
--- linux002/include/asm-powerpc/pgtable-ppc64.h	2008-06-05 10:07:56.000000000 -0500
+++ linux003/include/asm-powerpc/pgtable-ppc64.h	2008-06-10 16:48:59.000000000 -0500
@@ -94,6 +94,9 @@
 #define _PAGE_HASHPTE	0x0400 /* software: pte has an associated HPTE */
 #define _PAGE_BUSY	0x0800 /* software: PTE & hash are busy */
 
+/* Strong Access Ordering */
+#define _PAGE_SAO	(_PAGE_WRITETHRU | _PAGE_NO_CACHE | _PAGE_COHERENT)
+
 #define _PAGE_BASE	(_PAGE_PRESENT | _PAGE_ACCESSED | _PAGE_COHERENT)
 
 #define _PAGE_WRENABLE	(_PAGE_RW | _PAGE_DIRTY)
diff -Nurp linux002/include/linux/mm.h linux003/include/linux/mm.h
--- linux002/include/linux/mm.h	2008-06-05 10:08:01.000000000 -0500
+++ linux003/include/linux/mm.h	2008-06-10 16:48:59.000000000 -0500
@@ -108,6 +108,7 @@ extern unsigned int kobjsize(const void 
 
 #define VM_CAN_NONLINEAR 0x08000000	/* Has ->fault & does nonlinear pages */
 #define VM_MIXEDMAP	0x10000000	/* Can contain "struct page" and pure PFN pages */
+#define VM_SAO		0x20000000	/* Strong Access Ordering (powerpc) */
 
 #ifndef VM_STACK_DEFAULT_FLAGS		/* arch can override this */
 #define VM_STACK_DEFAULT_FLAGS VM_DATA_DEFAULT_FLAGS

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
