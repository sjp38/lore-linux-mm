Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3FD6A6B0365
	for <linux-mm@kvack.org>; Tue,  6 Jun 2017 07:31:48 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id q27so160179262pfi.8
        for <linux-mm@kvack.org>; Tue, 06 Jun 2017 04:31:48 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id d6si22206829pgc.63.2017.06.06.04.31.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 06 Jun 2017 04:31:46 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv7 11/14] x86/mm: Make kernel_physical_mapping_init() support 5-level paging
Date: Tue,  6 Jun 2017 14:31:30 +0300
Message-Id: <20170606113133.22974-12-kirill.shutemov@linux.intel.com>
In-Reply-To: <20170606113133.22974-1-kirill.shutemov@linux.intel.com>
References: <20170606113133.22974-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Populate additional page table level if CONFIG_X86_5LEVEL is enabled.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 arch/x86/mm/init_64.c | 69 ++++++++++++++++++++++++++++++++++++++++++++-------
 1 file changed, 60 insertions(+), 9 deletions(-)

diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
index 7a9497ac468d..b863d14e452a 100644
--- a/arch/x86/mm/init_64.c
+++ b/arch/x86/mm/init_64.c
@@ -624,6 +624,57 @@ phys_pud_init(pud_t *pud_page, unsigned long paddr, unsigned long paddr_end,
 	return paddr_last;
 }
 
+static unsigned long __meminit
+phys_p4d_init(p4d_t *p4d_page, unsigned long paddr, unsigned long paddr_end,
+	      unsigned long page_size_mask)
+{
+	unsigned long paddr_next, paddr_last = paddr_end;
+	unsigned long vaddr = (unsigned long)__va(paddr);
+	int i = p4d_index(vaddr);
+
+	if (!IS_ENABLED(CONFIG_X86_5LEVEL))
+		return phys_pud_init((pud_t *) p4d_page, paddr, paddr_end, page_size_mask);
+
+	for (; i < PTRS_PER_P4D; i++, paddr = paddr_next) {
+		p4d_t *p4d;
+		pud_t *pud;
+
+		vaddr = (unsigned long)__va(paddr);
+		p4d = p4d_page + p4d_index(vaddr);
+		paddr_next = (paddr & P4D_MASK) + P4D_SIZE;
+
+		if (paddr >= paddr_end) {
+			if (!after_bootmem &&
+			    !e820__mapped_any(paddr & P4D_MASK, paddr_next,
+					     E820_TYPE_RAM) &&
+			    !e820__mapped_any(paddr & P4D_MASK, paddr_next,
+					     E820_TYPE_RESERVED_KERN))
+				set_p4d(p4d, __p4d(0));
+			continue;
+		}
+
+		if (!p4d_none(*p4d)) {
+			pud = pud_offset(p4d, 0);
+			paddr_last = phys_pud_init(pud, paddr,
+					paddr_end,
+					page_size_mask);
+			__flush_tlb_all();
+			continue;
+		}
+
+		pud = alloc_low_page();
+		paddr_last = phys_pud_init(pud, paddr, paddr_end,
+					   page_size_mask);
+
+		spin_lock(&init_mm.page_table_lock);
+		p4d_populate(&init_mm, p4d, pud);
+		spin_unlock(&init_mm.page_table_lock);
+	}
+	__flush_tlb_all();
+
+	return paddr_last;
+}
+
 /*
  * Create page table mapping for the physical memory for specific physical
  * addresses. The virtual and physical addresses have to be aligned on PMD level
@@ -645,26 +696,26 @@ kernel_physical_mapping_init(unsigned long paddr_start,
 	for (; vaddr < vaddr_end; vaddr = vaddr_next) {
 		pgd_t *pgd = pgd_offset_k(vaddr);
 		p4d_t *p4d;
-		pud_t *pud;
 
 		vaddr_next = (vaddr & PGDIR_MASK) + PGDIR_SIZE;
 
-		BUILD_BUG_ON(pgd_none(*pgd));
-		p4d = p4d_offset(pgd, vaddr);
-		if (p4d_val(*p4d)) {
-			pud = (pud_t *)p4d_page_vaddr(*p4d);
-			paddr_last = phys_pud_init(pud, __pa(vaddr),
+		if (pgd_val(*pgd)) {
+			p4d = (p4d_t *)pgd_page_vaddr(*pgd);
+			paddr_last = phys_p4d_init(p4d, __pa(vaddr),
 						   __pa(vaddr_end),
 						   page_size_mask);
 			continue;
 		}
 
-		pud = alloc_low_page();
-		paddr_last = phys_pud_init(pud, __pa(vaddr), __pa(vaddr_end),
+		p4d = alloc_low_page();
+		paddr_last = phys_p4d_init(p4d, __pa(vaddr), __pa(vaddr_end),
 					   page_size_mask);
 
 		spin_lock(&init_mm.page_table_lock);
-		p4d_populate(&init_mm, p4d, pud);
+		if (IS_ENABLED(CONFIG_X86_5LEVEL))
+			pgd_populate(&init_mm, pgd, p4d);
+		else
+			p4d_populate(&init_mm, p4d_offset(pgd, vaddr), (pud_t *) p4d);
 		spin_unlock(&init_mm.page_table_lock);
 		pgd_changed = true;
 	}
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
