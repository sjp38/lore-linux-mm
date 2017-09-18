Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 65FF46B027B
	for <linux-mm@kvack.org>; Mon, 18 Sep 2017 06:56:42 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id f84so162086pfj.0
        for <linux-mm@kvack.org>; Mon, 18 Sep 2017 03:56:42 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id c16si4477827pgu.476.2017.09.18.03.56.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 18 Sep 2017 03:56:41 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv7 04/19] x86/xen: Provide pre-built page tables only for XEN_PV and XEN_PVH
Date: Mon, 18 Sep 2017 13:55:38 +0300
Message-Id: <20170918105553.27914-5-kirill.shutemov@linux.intel.com>
In-Reply-To: <20170918105553.27914-1-kirill.shutemov@linux.intel.com>
References: <20170918105553.27914-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andy Lutomirski <luto@amacapital.net>, Cyrill Gorcunov <gorcunov@openvz.org>, Borislav Petkov <bp@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Looks like we only need pre-built page tables for XEN_PV and XEN_PVH
cases. Let's not provide them for other configurations.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Reviewed-by: Juergen Gross <jgross@suse.com>
---
 arch/x86/kernel/head_64.S | 11 ++++++-----
 1 file changed, 6 insertions(+), 5 deletions(-)

diff --git a/arch/x86/kernel/head_64.S b/arch/x86/kernel/head_64.S
index 513cbb012ecc..2be7d1e7fcf1 100644
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
@@ -361,10 +362,7 @@ NEXT_PAGE(early_dynamic_pgts)
 
 	.data
 
-#ifndef CONFIG_XEN
-NEXT_PAGE(init_top_pgt)
-	.fill	512,8,0
-#else
+#if defined(CONFIG_XEN_PV) || defined(CONFIG_XEN_PVH)
 NEXT_PAGE(init_top_pgt)
 	.quad   level3_ident_pgt - __START_KERNEL_map + _KERNPG_TABLE_NOENC
 	.org    init_top_pgt + PGD_PAGE_OFFSET*8, 0
@@ -381,6 +379,9 @@ NEXT_PAGE(level2_ident_pgt)
 	 * Don't set NX because code runs from these pages.
 	 */
 	PMDS(0, __PAGE_KERNEL_IDENT_LARGE_EXEC, PTRS_PER_PMD)
+#else
+NEXT_PAGE(init_top_pgt)
+	.fill	512,8,0
 #endif
 
 #ifdef CONFIG_X86_5LEVEL
-- 
2.14.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
