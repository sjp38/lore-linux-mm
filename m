Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id 12D00900015
	for <linux-mm@kvack.org>; Fri,  6 Feb 2015 09:58:50 -0500 (EST)
Received: by pdjy10 with SMTP id y10so15202986pdj.7
        for <linux-mm@kvack.org>; Fri, 06 Feb 2015 06:58:49 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id bp5si10584269pbb.111.2015.02.06.06.51.18
        for <linux-mm@kvack.org>;
        Fri, 06 Feb 2015 06:51:18 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv2, RESEND 16/19] um: expose number of page table levels
Date: Fri,  6 Feb 2015 16:51:01 +0200
Message-Id: <1423234264-197684-17-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1423234264-197684-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1423234264-197684-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Jeff Dike <jdike@addtoit.com>

We would want to use number of page table level to define mm_struct.
Let's expose it as CONFIG_PGTABLE_LEVELS.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Acked-by: Richard Weinberger <richard@nod.at>
Cc: Jeff Dike <jdike@addtoit.com>
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
 arch/um/Kconfig.um | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/arch/um/Kconfig.um b/arch/um/Kconfig.um
index a7520c90f62d..5dbfe3d9107c 100644
--- a/arch/um/Kconfig.um
+++ b/arch/um/Kconfig.um
@@ -155,3 +155,8 @@ config MMAPPER
 
 config NO_DMA
 	def_bool y
+
+config PGTABLE_LEVELS
+	int
+	default 3 if 3_LEVEL_PGTABLES
+	default 2
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
