Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1A9356B037C
	for <linux-mm@kvack.org>; Tue, 18 Jul 2017 10:15:39 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id g7so23211647pgp.1
        for <linux-mm@kvack.org>; Tue, 18 Jul 2017 07:15:39 -0700 (PDT)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id w15si1912933plk.57.2017.07.18.07.15.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 18 Jul 2017 07:15:38 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv2 02/10] x86/xen: Provide pre-built page tables only for XEN_PV and XEN_PVH
Date: Tue, 18 Jul 2017 17:15:09 +0300
Message-Id: <20170718141517.52202-3-kirill.shutemov@linux.intel.com>
In-Reply-To: <20170718141517.52202-1-kirill.shutemov@linux.intel.com>
References: <20170718141517.52202-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, Michal Hocko <mhocko@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Looks like we only need pre-built page tables for XEN_PV and XEN_PVH
cases. Let's not provide them for other configuration.

This patch if preparation for boot-time switching between 4- and 5-level
paging. pgd_index() is going to depend on a variable and cannot be
easily used in head_64.S.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Reviewed-by: Juergen Gross <jgross@suse.com>
---
 arch/x86/kernel/head_64.S | 11 ++++++-----
 1 file changed, 6 insertions(+), 5 deletions(-)

diff --git a/arch/x86/kernel/head_64.S b/arch/x86/kernel/head_64.S
index 6225550883df..979b388d5e37 100644
--- a/arch/x86/kernel/head_64.S
+++ b/arch/x86/kernel/head_64.S
@@ -37,11 +37,12 @@
  *
  */
 
-#define p4d_index(x)	(((x) >> P4D_SHIFT) & (PTRS_PER_P4D-1))
 #define pud_index(x)	(((x) >> PUD_SHIFT) & (PTRS_PER_PUD-1))
 
+#if defined(CONFIG_XEN_PV) || defined(CONFIG_XEN_PVH)
 PGD_PAGE_OFFSET = pgd_index(__PAGE_OFFSET_BASE)
 PGD_START_KERNEL = pgd_index(__START_KERNEL_map)
+#endif
 L3_START_KERNEL = pud_index(__START_KERNEL_map)
 
 	.text
@@ -345,10 +346,7 @@ NEXT_PAGE(early_dynamic_pgts)
 
 	.data
 
-#ifndef CONFIG_XEN
-NEXT_PAGE(init_top_pgt)
-	.fill	512,8,0
-#else
+#if defined(CONFIG_XEN_PV) || defined(CONFIG_XEN_PVH)
 NEXT_PAGE(init_top_pgt)
 	.quad   level3_ident_pgt - __START_KERNEL_map + _KERNPG_TABLE
 	.org    init_top_pgt + PGD_PAGE_OFFSET*8, 0
@@ -365,6 +363,9 @@ NEXT_PAGE(level2_ident_pgt)
 	 * Don't set NX because code runs from these pages.
 	 */
 	PMDS(0, __PAGE_KERNEL_IDENT_LARGE_EXEC, PTRS_PER_PMD)
+#else
+NEXT_PAGE(init_top_pgt)
+	.fill	512,8,0
 #endif
 
 #ifdef CONFIG_X86_5LEVEL
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
