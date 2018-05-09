Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 47FFD6B04C9
	for <linux-mm@kvack.org>; Wed,  9 May 2018 05:18:30 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id e1-v6so3998584wma.3
        for <linux-mm@kvack.org>; Wed, 09 May 2018 02:18:30 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 70sor2787358wmf.63.2018.05.09.02.18.28
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 09 May 2018 02:18:29 -0700 (PDT)
From: Alexander Potapenko <glider@google.com>
Subject: [PATCH v3] x86/boot/64/clang: Use fixup_pointer() to access '__supported_pte_mask'
Date: Wed,  9 May 2018 11:18:22 +0200
Message-Id: <20180509091822.191810-1-glider@google.com>
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
 v3: removed unnecessary cast
 v2: better patch description, added a comment to __startup_64()
---
 arch/x86/kernel/head64.c | 11 ++++++++++-
 1 file changed, 10 insertions(+), 1 deletion(-)

diff --git a/arch/x86/kernel/head64.c b/arch/x86/kernel/head64.c
index 0c408f8c4ed4..5ea28e9a0250 100644
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
+	mask_ptr = fixup_pointer(&__supported_pte_mask, physaddr);
+	pmd_entry &= *mask_ptr;
 	pmd_entry += sme_get_me_mask();
 	pmd_entry +=  physaddr;
 
-- 
2.17.0.441.gb46fe60e1d-goog
