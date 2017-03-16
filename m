Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id BA44B6B0389
	for <linux-mm@kvack.org>; Thu, 16 Mar 2017 11:27:13 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id g2so96770827pge.7
        for <linux-mm@kvack.org>; Thu, 16 Mar 2017 08:27:13 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id t6si5641811pgo.14.2017.03.16.08.27.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 16 Mar 2017 08:27:12 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 3/7] mm/gup: Move page table entry dereference into helper
Date: Thu, 16 Mar 2017 18:26:51 +0300
Message-Id: <20170316152655.37789-4-kirill.shutemov@linux.intel.com>
In-Reply-To: <20170316152655.37789-1-kirill.shutemov@linux.intel.com>
References: <20170316152655.37789-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Dave Hansen <dave.hansen@intel.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Steve Capper <steve.capper@linaro.org>, Dann Frazier <dann.frazier@canonical.com>, Catalin Marinas <catalin.marinas@arm.com>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

This is preparation patch for transition of x86 to generic GUP_fast()
implementation.

On x86 PAE, page table entry is larger than sizeof(long) and we would
need to provide helper that can read the entry atomically.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 mm/gup.c | 20 ++++++++++++--------
 1 file changed, 12 insertions(+), 8 deletions(-)

diff --git a/mm/gup.c b/mm/gup.c
index a62a778ce4ec..ed2259dc4606 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -1189,6 +1189,17 @@ struct page *get_dump_page(unsigned long addr)
  */
 #ifdef CONFIG_HAVE_GENERIC_RCU_GUP
 
+#ifndef gup_get_pte
+/*
+ * We assume that the pte can be read atomically. If this is not the case for
+ * your architecture, please provide the helper.
+ */
+static inline pte_t gup_get_pte(pte_t *ptep)
+{
+	return READ_ONCE(*ptep);
+}
+#endif
+
 #ifdef __HAVE_ARCH_PTE_SPECIAL
 static int gup_pte_range(pmd_t pmd, unsigned long addr, unsigned long end,
 			 int write, struct page **pages, int *nr)
@@ -1198,14 +1209,7 @@ static int gup_pte_range(pmd_t pmd, unsigned long addr, unsigned long end,
 
 	ptem = ptep = pte_offset_map(&pmd, addr);
 	do {
-		/*
-		 * In the line below we are assuming that the pte can be read
-		 * atomically. If this is not the case for your architecture,
-		 * please wrap this in a helper function!
-		 *
-		 * for an example see gup_get_pte in arch/x86/mm/gup.c
-		 */
-		pte_t pte = READ_ONCE(*ptep);
+		pte_t pte = gup_get_pte(ptep);
 		struct page *head, *page;
 
 		/*
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
