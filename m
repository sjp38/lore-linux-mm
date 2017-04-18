Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9373A2806D9
	for <linux-mm@kvack.org>; Tue, 18 Apr 2017 17:17:51 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id z185so2975602pgz.11
        for <linux-mm@kvack.org>; Tue, 18 Apr 2017 14:17:51 -0700 (PDT)
Received: from NAM03-CO1-obe.outbound.protection.outlook.com (mail-co1nam03on0069.outbound.protection.outlook.com. [104.47.40.69])
        by mx.google.com with ESMTPS id m67si292801pfm.52.2017.04.18.14.17.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 18 Apr 2017 14:17:50 -0700 (PDT)
From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: [PATCH v5 08/32] x86/mm: Simplify p[g4um]d_page() macros
Date: Tue, 18 Apr 2017 16:17:46 -0500
Message-ID: <20170418211746.10190.25735.stgit@tlendack-t1.amdoffice.net>
In-Reply-To: <20170418211612.10190.82788.stgit@tlendack-t1.amdoffice.net>
References: <20170418211612.10190.82788.stgit@tlendack-t1.amdoffice.net>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-arch@vger.kernel.org, linux-efi@vger.kernel.org, kvm@vger.kernel.org, linux-doc@vger.kernel.org, x86@kernel.org, kexec@lists.infradead.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, iommu@lists.linux-foundation.org
Cc: Rik van Riel <riel@redhat.com>, Radim =?utf-8?b?S3LEjW3DocWZ?= <rkrcmar@redhat.com>, Toshimitsu Kani <toshi.kani@hpe.com>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Matt Fleming <matt@codeblueprint.co.uk>, "Michael S. Tsirkin" <mst@redhat.com>, Joerg Roedel <joro@8bytes.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Paolo Bonzini <pbonzini@redhat.com>, Larry Woodman <lwoodman@redhat.com>, Brijesh Singh <brijesh.singh@amd.com>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, Andy Lutomirski <luto@kernel.org>, "H. Peter
 Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dave Young <dyoung@redhat.com>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>

Create a pgd_pfn() and p4d_pfn() macro similar to the p[um]d_pfn() macros
and then use the p[g4um]d_pfn() macros in the p[g4um]d_page() macros
instead of duplicating the code.

Signed-off-by: Tom Lendacky <thomas.lendacky@amd.com>
---
 arch/x86/include/asm/pgtable.h |   16 +++++++++-------
 1 file changed, 9 insertions(+), 7 deletions(-)

diff --git a/arch/x86/include/asm/pgtable.h b/arch/x86/include/asm/pgtable.h
index 942482a..42b7193 100644
--- a/arch/x86/include/asm/pgtable.h
+++ b/arch/x86/include/asm/pgtable.h
@@ -195,6 +195,11 @@ static inline unsigned long p4d_pfn(p4d_t p4d)
 	return (p4d_val(p4d) & p4d_pfn_mask(p4d)) >> PAGE_SHIFT;
 }
 
+static inline unsigned long pgd_pfn(pgd_t pgd)
+{
+	return (pgd_val(pgd) & PTE_PFN_MASK) >> PAGE_SHIFT;
+}
+
 static inline int p4d_large(p4d_t p4d)
 {
 	/* No 512 GiB pages yet */
@@ -704,8 +709,7 @@ static inline unsigned long pmd_page_vaddr(pmd_t pmd)
  * Currently stuck as a macro due to indirect forward reference to
  * linux/mmzone.h's __section_mem_map_addr() definition:
  */
-#define pmd_page(pmd)		\
-	pfn_to_page((pmd_val(pmd) & pmd_pfn_mask(pmd)) >> PAGE_SHIFT)
+#define pmd_page(pmd)	pfn_to_page(pmd_pfn(pmd))
 
 /*
  * the pmd page can be thought of an array like this: pmd_t[PTRS_PER_PMD]
@@ -773,8 +777,7 @@ static inline unsigned long pud_page_vaddr(pud_t pud)
  * Currently stuck as a macro due to indirect forward reference to
  * linux/mmzone.h's __section_mem_map_addr() definition:
  */
-#define pud_page(pud)		\
-	pfn_to_page((pud_val(pud) & pud_pfn_mask(pud)) >> PAGE_SHIFT)
+#define pud_page(pud)	pfn_to_page(pud_pfn(pud))
 
 /* Find an entry in the second-level page table.. */
 static inline pmd_t *pmd_offset(pud_t *pud, unsigned long address)
@@ -824,8 +827,7 @@ static inline unsigned long p4d_page_vaddr(p4d_t p4d)
  * Currently stuck as a macro due to indirect forward reference to
  * linux/mmzone.h's __section_mem_map_addr() definition:
  */
-#define p4d_page(p4d)		\
-	pfn_to_page((p4d_val(p4d) & p4d_pfn_mask(p4d)) >> PAGE_SHIFT)
+#define p4d_page(p4d)	pfn_to_page(p4d_pfn(p4d))
 
 /* Find an entry in the third-level page table.. */
 static inline pud_t *pud_offset(p4d_t *p4d, unsigned long address)
@@ -859,7 +861,7 @@ static inline unsigned long pgd_page_vaddr(pgd_t pgd)
  * Currently stuck as a macro due to indirect forward reference to
  * linux/mmzone.h's __section_mem_map_addr() definition:
  */
-#define pgd_page(pgd)		pfn_to_page(pgd_val(pgd) >> PAGE_SHIFT)
+#define pgd_page(pgd)	pfn_to_page(pgd_pfn(pgd))
 
 /* to find an entry in a page-table-directory. */
 static inline p4d_t *p4d_offset(pgd_t *pgd, unsigned long address)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
