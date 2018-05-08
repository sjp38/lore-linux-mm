Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f199.google.com (mail-wr0-f199.google.com [209.85.128.199])
	by kanga.kvack.org (Postfix) with ESMTP id B51786B02AF
	for <linux-mm@kvack.org>; Tue,  8 May 2018 12:28:35 -0400 (EDT)
Received: by mail-wr0-f199.google.com with SMTP id p1-v6so21733436wrm.7
        for <linux-mm@kvack.org>; Tue, 08 May 2018 09:28:35 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x6-v6sor11641910wrl.36.2018.05.08.09.28.33
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 08 May 2018 09:28:34 -0700 (PDT)
From: Alexander Potapenko <glider@google.com>
Subject: [PATCH v2] x86/boot/64/clang: Use fixup_pointer() to access '__supported_pte_mask'
Date: Tue,  8 May 2018 18:28:29 +0200
Message-Id: <20180508162829.7729-1-glider@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dave.hansen@linux.intel.com, mingo@kernel.org, kirill.shutemov@linux.intel.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, mka@chromium.org, dvyukov@google.com, md@google.com

Clang builds with defconfig started crashing after commit fb43d6cb91ef
("x86/mm: Do not auto-massage page protections")
This was caused by introducing a new global access in __startup_64().

Code in __startup_64() can be relocated during execution, but the compiler
doesn't have to generate PC-relative relocations when accessing globals
from that function. Clang actually does not generate them, which leads
to boot-time crashes. To work around this problem, every global pointer
must be adjusted using fixup_pointer().

Signed-off-by: Alexander Potapenko <glider@google.com>
Fixes: fb43d6cb91ef ("x86/mm: Do not auto-massage page protections")
---
 v2: better patch description, added a comment to __startup_64()
---
 arch/x86/kernel/head64.c | 11 ++++++++++-
 1 file changed, 10 insertions(+), 1 deletion(-)

diff --git a/arch/x86/kernel/head64.c b/arch/x86/kernel/head64.c
index 0c408f8c4ed4..9223792f6d0e 100644
--- a/arch/x86/kernel/head64.c
+++ b/arch/x86/kernel/head64.c
@@ -104,6 +104,13 @@ static bool __head check_la57_support(unsigned long physaddr)
 }
 #endif
 
+
+/* Code in __startup_64() can be relocated during execution, but the compiler
+ * doesn't have to generate PC-relative relocations when accessing globals from
+ * that function. Clang actually does not generate them, which leads to
+ * boot-time crashes. To work around this problem, every global pointer must
+ * be adjusted using fixup_pointer().
+ */
 unsigned long __head __startup_64(unsigned long physaddr,
 				  struct boot_params *bp)
 {
@@ -113,6 +120,7 @@ unsigned long __head __startup_64(unsigned long physaddr,
 	p4dval_t *p4d;
 	pudval_t *pud;
 	pmdval_t *pmd, pmd_entry;
+	pteval_t *mask_ptr;
 	bool la57;
 	int i;
 	unsigned int *next_pgt_ptr;
@@ -196,7 +204,8 @@ unsigned long __head __startup_64(unsigned long physaddr,
 
 	pmd_entry = __PAGE_KERNEL_LARGE_EXEC & ~_PAGE_GLOBAL;
 	/* Filter out unsupported __PAGE_KERNEL_* bits: */
-	pmd_entry &= __supported_pte_mask;
+	mask_ptr = (pteval_t *)fixup_pointer(&__supported_pte_mask, physaddr);
+	pmd_entry &= *mask_ptr;
 	pmd_entry += sme_get_me_mask();
 	pmd_entry +=  physaddr;
 
-- 
2.17.0.441.gb46fe60e1d-goog
