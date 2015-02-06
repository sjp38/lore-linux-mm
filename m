Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 9BC886B0071
	for <linux-mm@kvack.org>; Fri,  6 Feb 2015 09:51:21 -0500 (EST)
Received: by mail-pa0-f46.google.com with SMTP id lj1so17713482pab.5
        for <linux-mm@kvack.org>; Fri, 06 Feb 2015 06:51:21 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id ui5si10587077pab.130.2015.02.06.06.51.15
        for <linux-mm@kvack.org>;
        Fri, 06 Feb 2015 06:51:16 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv2, RESEND 07/19] m68k: mark PMD folded and expose number of page table levels
Date: Fri,  6 Feb 2015 16:50:52 +0200
Message-Id: <1423234264-197684-8-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1423234264-197684-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1423234264-197684-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Geert Uytterhoeven <geert@linux-m68k.org>

We would want to use number of page table level to define mm_struct.
Let's expose it as CONFIG_PGTABLE_LEVELS.

Core mm expects __PAGETABLE_{PUD,PMD}_FOLDED to be defined if these page
table levels folded.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Geert Uytterhoeven <geert@linux-m68k.org>
Tested-by: Guenter Roeck <linux@roeck-us.net>
---

I've implemented accounting for pmd page tables as we have for pte (see
mm->nr_ptes). It's requires a new counter in mm_struct: mm->nr_pmds.

But the feature doesn't make any sense if an architecture has PMD level
folded and it would be nice get rid of the counter in this case.

The problem is that we cannot use __PAGETABLE_PMD_FOLDED in
<linux/mm_types.h> due to circular dependencies:

<linux/mm_types> -> <asm/pgtable.h> -> <linux/mm_types.h>

In most cases <asm/pgtable.h> wants <linux/mm_types.h> to get definition
of struct page and struct vm_area_struct. I've tried to split mm_struct
into separate header file to be able to user <asm/pgtable.h> there.

But it doesn't fly on some architectures, like ARM: it wants mm_struct
<asm/pgtable.h> to implement tlb flushing. I don't see how to fix it without
massive de-inlining or coverting a lot for inline functions to macros.

This is other approach: expose number of page tables in use via Kconfig
and use it in <linux/mm_types.h> instead of __PAGETABLE_PMD_FOLDED from
<asm/pgtable.h>.

---
 arch/m68k/Kconfig                  | 4 ++++
 arch/m68k/include/asm/pgtable_mm.h | 2 ++
 2 files changed, 6 insertions(+)

diff --git a/arch/m68k/Kconfig b/arch/m68k/Kconfig
index 87b7c7581b1d..2dd8f63bfbbb 100644
--- a/arch/m68k/Kconfig
+++ b/arch/m68k/Kconfig
@@ -67,6 +67,10 @@ config HZ
 	default 1000 if CLEOPATRA
 	default 100
 
+config PGTABLE_LEVELS
+	default 2 if SUN3 || COLDFIRE
+	default 3
+
 source "init/Kconfig"
 
 source "kernel/Kconfig.freezer"
diff --git a/arch/m68k/include/asm/pgtable_mm.h b/arch/m68k/include/asm/pgtable_mm.h
index 28a145bfbb71..35ed4a9981ae 100644
--- a/arch/m68k/include/asm/pgtable_mm.h
+++ b/arch/m68k/include/asm/pgtable_mm.h
@@ -54,10 +54,12 @@
  */
 #ifdef CONFIG_SUN3
 #define PTRS_PER_PTE   16
+#define __PAGETABLE_PMD_FOLDED
 #define PTRS_PER_PMD   1
 #define PTRS_PER_PGD   2048
 #elif defined(CONFIG_COLDFIRE)
 #define PTRS_PER_PTE	512
+#define __PAGETABLE_PMD_FOLDED
 #define PTRS_PER_PMD	1
 #define PTRS_PER_PGD	1024
 #else
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
