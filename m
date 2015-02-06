Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f170.google.com (mail-pd0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id F104B6B0078
	for <linux-mm@kvack.org>; Fri,  6 Feb 2015 09:51:31 -0500 (EST)
Received: by pdjy10 with SMTP id y10so15167716pdj.7
        for <linux-mm@kvack.org>; Fri, 06 Feb 2015 06:51:31 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id ui5si10587077pab.130.2015.02.06.06.51.17
        for <linux-mm@kvack.org>;
        Fri, 06 Feb 2015 06:51:17 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv2, RESEND 15/19] tile: expose number of page table levels
Date: Fri,  6 Feb 2015 16:51:00 +0200
Message-Id: <1423234264-197684-16-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1423234264-197684-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1423234264-197684-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

We would want to use number of page table level to define mm_struct.
Let's expose it as CONFIG_PGTABLE_LEVELS.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Acked-by: Chris Metcalf <cmetcalf@ezchip.com>
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
 arch/tile/Kconfig | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/arch/tile/Kconfig b/arch/tile/Kconfig
index 7cca41842a9e..0142d578b5a8 100644
--- a/arch/tile/Kconfig
+++ b/arch/tile/Kconfig
@@ -147,6 +147,11 @@ config ARCH_DEFCONFIG
 	default "arch/tile/configs/tilepro_defconfig" if !TILEGX
 	default "arch/tile/configs/tilegx_defconfig" if TILEGX
 
+config PGTABLE_LEVELS
+	int
+	default 3 if 64BIT
+	default 2
+
 source "init/Kconfig"
 
 source "kernel/Kconfig.freezer"
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
