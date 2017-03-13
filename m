Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 1A90A6B042C
	for <linux-mm@kvack.org>; Mon, 13 Mar 2017 01:51:03 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id 190so206504092pgg.3
        for <linux-mm@kvack.org>; Sun, 12 Mar 2017 22:51:03 -0700 (PDT)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id l70si10514823pgd.3.2017.03.12.22.51.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 12 Mar 2017 22:51:02 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 05/26] x86/mm: add support of p4d_t in vmalloc_fault()
Date: Mon, 13 Mar 2017 08:49:59 +0300
Message-Id: <20170313055020.69655-6-kirill.shutemov@linux.intel.com>
In-Reply-To: <20170313055020.69655-1-kirill.shutemov@linux.intel.com>
References: <20170313055020.69655-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Arnd Bergmann <arnd@arndb.de>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, Michal Hocko <mhocko@suse.com>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

With 4-level paging copying happens on p4d level, as we have pgd_none()
always false when p4d_t folded.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 arch/x86/mm/fault.c | 27 ++++++++++++++++++++++++---
 1 file changed, 24 insertions(+), 3 deletions(-)

diff --git a/arch/x86/mm/fault.c b/arch/x86/mm/fault.c
index 605fd5e8e048..88040bb2b78a 100644
--- a/arch/x86/mm/fault.c
+++ b/arch/x86/mm/fault.c
@@ -435,6 +435,7 @@ void vmalloc_sync_all(void)
 static noinline int vmalloc_fault(unsigned long address)
 {
 	pgd_t *pgd, *pgd_ref;
+	p4d_t *p4d, *p4d_ref;
 	pud_t *pud, *pud_ref;
 	pmd_t *pmd, *pmd_ref;
 	pte_t *pte, *pte_ref;
@@ -458,17 +459,37 @@ static noinline int vmalloc_fault(unsigned long address)
 	if (pgd_none(*pgd)) {
 		set_pgd(pgd, *pgd_ref);
 		arch_flush_lazy_mmu_mode();
-	} else {
+	} else if (CONFIG_PGTABLE_LEVELS > 4) {
+		/*
+		 * With folded p4d, pgd_none() is always false. So pgd may
+		 * point to empty page table entry and pgd_page_vaddr()
+		 * will return garbage.
+		 *
+		 * We will do the correct sanity check on p4d level.
+		 */
 		BUG_ON(pgd_page_vaddr(*pgd) != pgd_page_vaddr(*pgd_ref));
 	}
 
+	/* With 4-level paging copying happens on p4d level. */
+	p4d = p4d_offset(pgd, address);
+	p4d_ref = p4d_offset(pgd_ref, address);
+	if (p4d_none(*p4d_ref))
+		return -1;
+
+	if (p4d_none(*p4d)) {
+		set_p4d(p4d, *p4d_ref);
+		arch_flush_lazy_mmu_mode();
+	} else {
+		BUG_ON(p4d_pfn(*p4d) != p4d_pfn(*p4d_ref));
+	}
+
 	/*
 	 * Below here mismatches are bugs because these lower tables
 	 * are shared:
 	 */
 
-	pud = pud_offset(pgd, address);
-	pud_ref = pud_offset(pgd_ref, address);
+	pud = pud_offset(p4d, address);
+	pud_ref = pud_offset(p4d_ref, address);
 	if (pud_none(*pud_ref))
 		return -1;
 
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
