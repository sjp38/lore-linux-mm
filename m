Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f54.google.com (mail-pa0-f54.google.com [209.85.220.54])
	by kanga.kvack.org (Postfix) with ESMTP id 47FFD6B0087
	for <linux-mm@kvack.org>; Fri,  6 Feb 2015 09:51:46 -0500 (EST)
Received: by mail-pa0-f54.google.com with SMTP id kx10so2584296pab.13
        for <linux-mm@kvack.org>; Fri, 06 Feb 2015 06:51:46 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id pi3si7176003pbb.50.2015.02.06.06.51.42
        for <linux-mm@kvack.org>;
        Fri, 06 Feb 2015 06:51:42 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv2, RESEND 04/19] frv: mark PUD and PMD folded
Date: Fri,  6 Feb 2015 16:50:49 +0200
Message-Id: <1423234264-197684-5-git-send-email-kirill.shutemov@linux.intel.com>
In-Reply-To: <1423234264-197684-1-git-send-email-kirill.shutemov@linux.intel.com>
References: <1423234264-197684-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, David Howells <dhowells@redhat.com>

Core mm expects __PAGETABLE_{PUD,PMD}_FOLDED to be defined if these page
table levels folded.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: David Howells <dhowells@redhat.com>
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
 arch/frv/include/asm/pgtable.h | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/arch/frv/include/asm/pgtable.h b/arch/frv/include/asm/pgtable.h
index 93bcf2abd1a1..07d7a7ef8bd5 100644
--- a/arch/frv/include/asm/pgtable.h
+++ b/arch/frv/include/asm/pgtable.h
@@ -123,12 +123,14 @@ extern unsigned long empty_zero_page;
 #define PGDIR_MASK		(~(PGDIR_SIZE - 1))
 #define PTRS_PER_PGD		64
 
+#define __PAGETABLE_PUD_FOLDED
 #define PUD_SHIFT		26
 #define PTRS_PER_PUD		1
 #define PUD_SIZE		(1UL << PUD_SHIFT)
 #define PUD_MASK		(~(PUD_SIZE - 1))
 #define PUE_SIZE		256
 
+#define __PAGETABLE_PMD_FOLDED
 #define PMD_SHIFT		26
 #define PMD_SIZE		(1UL << PMD_SHIFT)
 #define PMD_MASK		(~(PMD_SIZE - 1))
-- 
2.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
