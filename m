Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6DFD86B026D
	for <linux-mm@kvack.org>; Wed, 13 Dec 2017 05:59:10 -0500 (EST)
Received: by mail-pl0-f71.google.com with SMTP id d4so904435plr.8
        for <linux-mm@kvack.org>; Wed, 13 Dec 2017 02:59:10 -0800 (PST)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id w61si1152488plb.736.2017.12.13.02.59.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Dec 2017 02:59:09 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv4 03/12] arm/mm: Provide pmdp_establish() helper
Date: Wed, 13 Dec 2017 13:57:47 +0300
Message-Id: <20171213105756.69879-4-kirill.shutemov@linux.intel.com>
In-Reply-To: <20171213105756.69879-1-kirill.shutemov@linux.intel.com>
References: <20171213105756.69879-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Andrea Arcangeli <aarcange@redhat.com>, Michal Hocko <mhocko@kernel.org>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Catalin Marinas <catalin.marinas@arm.com>

ARM LPAE doesn't have hardware dirty/accessed bits.

generic_pmdp_establish() is the right implementation of pmdp_establish
for this case.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
Cc: Catalin Marinas <catalin.marinas@arm.com>
---
 arch/arm/include/asm/pgtable-3level.h | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/arch/arm/include/asm/pgtable-3level.h b/arch/arm/include/asm/pgtable-3level.h
index 1a7a17b2a1ba..2a4836087358 100644
--- a/arch/arm/include/asm/pgtable-3level.h
+++ b/arch/arm/include/asm/pgtable-3level.h
@@ -249,6 +249,9 @@ PMD_BIT_FUNC(mkyoung,   |= PMD_SECT_AF);
 #define pfn_pmd(pfn,prot)	(__pmd(((phys_addr_t)(pfn) << PAGE_SHIFT) | pgprot_val(prot)))
 #define mk_pmd(page,prot)	pfn_pmd(page_to_pfn(page),prot)
 
+/* No hardware dirty/accessed bits -- generic_pmdp_establish() fits */
+#define pmdp_establish generic_pmdp_establish
+
 /* represent a notpresent pmd by faulting entry, this is used by pmdp_invalidate */
 static inline pmd_t pmd_mknotpresent(pmd_t pmd)
 {
-- 
2.15.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
