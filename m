Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id 086DB6B0075
	for <linux-mm@kvack.org>; Fri,  6 Feb 2015 09:51:30 -0500 (EST)
Received: by pdjz10 with SMTP id z10so15177446pdj.13
        for <linux-mm@kvack.org>; Fri, 06 Feb 2015 06:51:29 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id bp5si10584269pbb.111.2015.02.06.06.51.17
        for <linux-mm@kvack.org>;
        Fri, 06 Feb 2015 06:51:17 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv2, RESEND 12/19] s390: expose number of page table levels
Date: Fri,  6 Feb 2015 16:50:57 +0200
Message-Id: <1423234264-197684-13-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1423234264-197684-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1423234264-197684-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>

We would want to use number of page table level to define mm_struct.
Let's expose it as CONFIG_PGTABLE_LEVELS.

Core mm expects __PAGETABLE_{PUD,PMD}_FOLDED to be defined if these page
table levels folded.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: Heiko Carstens <heiko.carstens@de.ibm.com>
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
 arch/s390/Kconfig               | 5 +++++
 arch/s390/include/asm/pgtable.h | 2 ++
 2 files changed, 7 insertions(+)

diff --git a/arch/s390/Kconfig b/arch/s390/Kconfig
index 373cd5badf1c..f6aebcb7a0f8 100644
--- a/arch/s390/Kconfig
+++ b/arch/s390/Kconfig
@@ -155,6 +155,11 @@ config S390
 config SCHED_OMIT_FRAME_POINTER
 	def_bool y
 
+config PGTABLE_LEVELS
+	int
+	default 4 if 64BIT
+	default 2
+
 source "init/Kconfig"
 
 source "kernel/Kconfig.freezer"
diff --git a/arch/s390/include/asm/pgtable.h b/arch/s390/include/asm/pgtable.h
index fbb5ee3ae57c..e08ec38f8c6e 100644
--- a/arch/s390/include/asm/pgtable.h
+++ b/arch/s390/include/asm/pgtable.h
@@ -91,7 +91,9 @@ extern unsigned long zero_page_mask;
  */
 #define PTRS_PER_PTE	256
 #ifndef CONFIG_64BIT
+#define __PAGETABLE_PUD_FOLDED
 #define PTRS_PER_PMD	1
+#define __PAGETABLE_PMD_FOLDED
 #define PTRS_PER_PUD	1
 #else /* CONFIG_64BIT */
 #define PTRS_PER_PMD	2048
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
