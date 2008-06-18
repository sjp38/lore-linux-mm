Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e32.co.us.ibm.com (8.13.8/8.13.8) with ESMTP id m5IMSwGD019682
	for <linux-mm@kvack.org>; Wed, 18 Jun 2008 18:28:58 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m5IMXUYq178208
	for <linux-mm@kvack.org>; Wed, 18 Jun 2008 16:33:30 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m5IMXT5A024205
	for <linux-mm@kvack.org>; Wed, 18 Jun 2008 16:33:30 -0600
Message-Id: <20080618223329.166670421@linux.vnet.ibm.com>
References: <20080618223254.966080905@linux.vnet.ibm.com>
Date: Wed, 18 Jun 2008 17:32:57 -0500
From: shaggy@linux.vnet.ibm.com
Subject: [patch 3/6] powerpc: Define flags for Strong Access Ordering
Content-Disposition: inline; filename=SAO-defines.patch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Paul Mackerras <paulus@au1.ibm.com>, linux-mm@kvack.org, Linuxppc-dev@ozlabs.org
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

Index: linux-2.6.26-rc5/include/asm-powerpc/mman.h
===================================================================
--- linux-2.6.26-rc5.orig/include/asm-powerpc/mman.h
+++ linux-2.6.26-rc5/include/asm-powerpc/mman.h
@@ -10,6 +10,8 @@
  * 2 of the License, or (at your option) any later version.
  */
 
+#define PROT_SAO	0x10		/* Strong Access Ordering */
+
 #define MAP_RENAME      MAP_ANONYMOUS   /* In SunOS terminology */
 #define MAP_NORESERVE   0x40            /* don't reserve swap pages */
 #define MAP_LOCKED	0x80
Index: linux-2.6.26-rc5/include/asm-powerpc/pgtable-ppc64.h
===================================================================
--- linux-2.6.26-rc5.orig/include/asm-powerpc/pgtable-ppc64.h
+++ linux-2.6.26-rc5/include/asm-powerpc/pgtable-ppc64.h
@@ -94,6 +94,9 @@
 #define _PAGE_HASHPTE	0x0400 /* software: pte has an associated HPTE */
 #define _PAGE_BUSY	0x0800 /* software: PTE & hash are busy */
 
+/* Strong Access Ordering */
+#define _PAGE_SAO	(_PAGE_WRITETHRU | _PAGE_NO_CACHE | _PAGE_COHERENT)
+
 #define _PAGE_BASE	(_PAGE_PRESENT | _PAGE_ACCESSED | _PAGE_COHERENT)
 
 #define _PAGE_WRENABLE	(_PAGE_RW | _PAGE_DIRTY)
Index: linux-2.6.26-rc5/include/linux/mm.h
===================================================================
--- linux-2.6.26-rc5.orig/include/linux/mm.h
+++ linux-2.6.26-rc5/include/linux/mm.h
@@ -108,6 +108,7 @@ extern unsigned int kobjsize(const void 
 
 #define VM_CAN_NONLINEAR 0x08000000	/* Has ->fault & does nonlinear pages */
 #define VM_MIXEDMAP	0x10000000	/* Can contain "struct page" and pure PFN pages */
+#define VM_SAO		0x20000000	/* Strong Access Ordering (powerpc) */
 
 #ifndef VM_STACK_DEFAULT_FLAGS		/* arch can override this */
 #define VM_STACK_DEFAULT_FLAGS VM_DATA_DEFAULT_FLAGS

-- 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
