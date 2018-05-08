Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id BFFFA6B0275
	for <linux-mm@kvack.org>; Tue,  8 May 2018 08:16:49 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id f188-v6so4068857wme.2
        for <linux-mm@kvack.org>; Tue, 08 May 2018 05:16:49 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z133sor826376wmc.68.2018.05.08.05.16.48
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 08 May 2018 05:16:48 -0700 (PDT)
From: Alexander Potapenko <glider@google.com>
Subject: [PATCH] x86/boot/64/clang: Use fixup_pointer() to access '__supported_pte_mask'
Date: Tue,  8 May 2018 14:16:38 +0200
Message-Id: <20180508121638.174022-1-glider@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dave.hansen@linux.intel.com, mingo@kernel.org, kirill.shutemov@linux.intel.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, mka@chromium.org, dvyukov@google.com, md@google.com

Similarly to commit 187e91fe5e91
("x86/boot/64/clang: Use fixup_pointer() to access 'next_early_pgt'"),
'__supported_pte_mask' must be also accessed using fixup_pointer() to
avoid position-dependent relocations.

Signed-off-by: Alexander Potapenko <glider@google.com>
Fixes: fb43d6cb91ef ("x86/mm: Do not auto-massage page protections")
---
 arch/x86/kernel/head64.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/arch/x86/kernel/head64.c b/arch/x86/kernel/head64.c
index 0c408f8c4ed4..1b36ae4d0035 100644
--- a/arch/x86/kernel/head64.c
+++ b/arch/x86/kernel/head64.c
@@ -113,6 +113,7 @@ unsigned long __head __startup_64(unsigned long physaddr,
 	p4dval_t *p4d;
 	pudval_t *pud;
 	pmdval_t *pmd, pmd_entry;
+	pteval_t *mask_ptr;
 	bool la57;
 	int i;
 	unsigned int *next_pgt_ptr;
@@ -196,7 +197,8 @@ unsigned long __head __startup_64(unsigned long physaddr,
 
 	pmd_entry = __PAGE_KERNEL_LARGE_EXEC & ~_PAGE_GLOBAL;
 	/* Filter out unsupported __PAGE_KERNEL_* bits: */
-	pmd_entry &= __supported_pte_mask;
+	mask_ptr = (pteval_t *)fixup_pointer(&__supported_pte_mask, physaddr);
+	pmd_entry &= *mask_ptr;
 	pmd_entry += sme_get_me_mask();
 	pmd_entry +=  physaddr;
 
-- 
2.17.0.441.gb46fe60e1d-goog
