Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e3.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id l7LKh15V008038
	for <linux-mm@kvack.org>; Tue, 21 Aug 2007 16:43:01 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.5) with ESMTP id l7LKh1E5532826
	for <linux-mm@kvack.org>; Tue, 21 Aug 2007 16:43:01 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l7LKh1Ma009550
	for <linux-mm@kvack.org>; Tue, 21 Aug 2007 16:43:01 -0400
Subject: [RFC][PATCH 9/9] pagemap: export swap ptes
From: Dave Hansen <haveblue@us.ibm.com>
Date: Tue, 21 Aug 2007 13:42:59 -0700
References: <20070821204248.0F506A29@kernel>
In-Reply-To: <20070821204248.0F506A29@kernel>
Message-Id: <20070821204259.1F6E8A44@kernel>
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

 lxc-dave/fs/proc/task_mmu.c |   29 ++++++++++++++++++++++++++---
 1 file changed, 26 insertions(+), 3 deletions(-)

diff -puN fs/proc/task_mmu.c~pagemap-export-swap-ptes fs/proc/task_mmu.c
--- lxc/fs/proc/task_mmu.c~pagemap-export-swap-ptes	2007-08-21 13:30:55.000000000 -0700
+++ lxc-dave/fs/proc/task_mmu.c	2007-08-21 13:30:55.000000000 -0700
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
@@ -539,6 +545,21 @@ static int pagemap_pte_hole(unsigned lon
 	return err;
 }
 
+unsigned long swap_pte_to_pagemap_entry(pte_t pte)
+{
+	unsigned long ret = 0;
+	swp_entry_t entry = pte_to_swp_entry(pte);
+	unsigned long offset;
+	unsigned long swap_file_nr;
+
+	offset = swp_offset(entry);
+	swap_file_nr = swp_type(entry);
+	ret = PM_SWAP | swap_file_nr | (offset << MAX_SWAPFILES_SHIFT);
+	return ret;
+}
+	
+
+
 static int pagemap_pte_range(pmd_t *pmd, unsigned long addr, unsigned long end,
 			     void *private)
 {
@@ -549,7 +570,9 @@ static int pagemap_pte_range(pmd_t *pmd,
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
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
