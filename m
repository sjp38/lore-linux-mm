Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e3.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l7MNIG9L011730
	for <linux-mm@kvack.org>; Wed, 22 Aug 2007 19:18:16 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l7MNIGsI496938
	for <linux-mm@kvack.org>; Wed, 22 Aug 2007 19:18:16 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l7MNIGkt021257
	for <linux-mm@kvack.org>; Wed, 22 Aug 2007 19:18:16 -0400
Subject: [PATCH 9/9] pagemap: export swap ptes
From: Dave Hansen <haveblue@us.ibm.com>
Date: Wed, 22 Aug 2007 16:18:14 -0700
References: <20070822231804.1132556D@kernel>
In-Reply-To: <20070822231804.1132556D@kernel>
Message-Id: <20070822231814.8F5F37A0@kernel>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: mpm@selenic.com
Cc: linux-mm@kvack.org, Dave Hansen <haveblue@us.ibm.com>
List-ID: <linux-mm.kvack.org>

In addition to understanding which physical pages are
used by a process, it would also be very nice to
enumerate how much swap space a process is using.

This patch enables /proc/<pid>/pagemap to display
swap ptes.  In the process, it also changes the
constant that we used to indicate non-present ptes
before.

Signed-off-by: Dave Hansen <haveblue@us.ibm.com>
---

 lxc-dave/fs/proc/task_mmu.c |   38 +++++++++++++++++++++++++++++++-------
 1 file changed, 31 insertions(+), 7 deletions(-)

diff -puN fs/proc/task_mmu.c~pagemap-export-swap-ptes fs/proc/task_mmu.c
--- lxc/fs/proc/task_mmu.c~pagemap-export-swap-ptes	2007-08-22 16:16:55.000000000 -0700
+++ lxc-dave/fs/proc/task_mmu.c	2007-08-22 16:16:55.000000000 -0700
@@ -7,6 +7,8 @@
 #include <linux/pagemap.h>
 #include <linux/ptrace.h>
 #include <linux/mempolicy.h>
+#include <linux/swap.h>
+#include <linux/swapops.h>
 
 #include <asm/elf.h>
 #include <asm/uaccess.h>
@@ -506,9 +508,13 @@ struct pagemapread {
 	int index;
 	unsigned long __user *out;
 };
-
 #define PM_ENTRY_BYTES sizeof(unsigned long)
-#define PM_NOT_PRESENT ((unsigned long)-1)
+#define PM_RESERVED_BITS	3
+#define PM_RESERVED_OFFSET	(BITS_PER_LONG-PM_RESERVED_BITS)
+#define PM_RESERVED_MASK	(((1<<PM_RESERVED_BITS)-1) << PM_RESERVED_OFFSET)
+#define PM_SPECIAL(nr)		(((nr) << PM_RESERVED_OFFSET) | PM_RESERVED_MASK)
+#define PM_NOT_PRESENT	PM_SPECIAL(1)
+#define PM_SWAP		PM_SPECIAL(2)
 #define PAGEMAP_END_OF_BUFFER 1
 
 static int add_to_pagemap(unsigned long addr, unsigned long pfn,
@@ -545,6 +551,19 @@ static int pagemap_pte_hole(unsigned lon
 	return err;
 }
 
+unsigned long swap_pte_to_pagemap_entry(pte_t pte)
+{
+	swp_entry_t entry = pte_to_swp_entry(pte);
+	unsigned long offset;
+	unsigned long swap_file_nr;
+
+	offset = swp_offset(entry);
+	swap_file_nr = swp_type(entry);
+	return PM_SWAP | swap_file_nr | (offset << MAX_SWAPFILES_SHIFT);
+}
+	
+
+
 static int pagemap_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end,
 			     void *private)
 {
@@ -555,7 +574,9 @@ static int pagemap_pte_range(pmd_t *pmd,
 	pte = pte_offset_map(pmd, addr);
 	for (; addr != end; pte++, addr += PAGE_SIZE) {
 		unsigned long pfn = PM_NOT_PRESENT;
-		if (pte_present(*pte))
+		if (is_swap_pte(*pte))
+			pfn = swap_pte_to_pagemap_entry(*pte);
+		else if (pte_present(*pte))
 			pfn = pte_pfn(*pte);
 		err = add_to_pagemap(addr, pfn, pm);
 		if (err)
@@ -578,10 +599,13 @@ static struct mm_walk pagemap_walk =
  * /proc/pid/pagemap - an array mapping virtual pages to pfns
  *
  * For each page in the address space, this file contains one long
- * representing the corresponding physical page frame number (PFN) or
- * -1 if the page isn't present. This allows determining precisely
- * which pages are mapped and comparing mapped pages between
- * processes.
+ * representing the corresponding physical page frame number (PFN)
+ * if the page is present.  If there is a swap entry for the
+ * physical page, then an encoding of the swap file number and the
+ * page's offset into the swap file are returned.  If no page is
+ * present at all, PM_NOT_PRESENT is returned.  This allows
+ * determining precisely which pages are mapped (or in swap)  and
+ * comparing mapped pages between processes.
  *
  * Efficient users of this interface will use /proc/pid/maps to
  * determine which areas of memory are actually mapped and llseek to
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
