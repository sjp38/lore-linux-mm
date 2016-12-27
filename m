Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 02E036B0271
	for <linux-mm@kvack.org>; Mon, 26 Dec 2016 20:54:52 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id 5so269124519pgj.6
        for <linux-mm@kvack.org>; Mon, 26 Dec 2016 17:54:51 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id n187si26679909pga.63.2016.12.26.17.54.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 26 Dec 2016 17:54:51 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv2 26/29] x86/mm: make kernel_physical_mapping_init() support 5-level paging
Date: Tue, 27 Dec 2016 04:54:10 +0300
Message-Id: <20161227015413.187403-27-kirill.shutemov@linux.intel.com>
In-Reply-To: <20161227015413.187403-1-kirill.shutemov@linux.intel.com>
References: <20161227015413.187403-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Arnd Bergmann <arnd@arndb.de>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Properly populate addition pagetable level if CONFIG_X86_5LEVEL is
enabled.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 arch/x86/mm/init_64.c | 71 ++++++++++++++++++++++++++++++++++++++++++++-------
 1 file changed, 62 insertions(+), 9 deletions(-)

diff --git a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
index 72f99e837ec2..ac0a4048efac 100644
--- a/arch/x86/mm/init_64.c
+++ b/arch/x86/mm/init_64.c
@@ -611,6 +611,58 @@ phys_pud_init(pud_t *pud_page, unsigned long paddr, unsigned long paddr_end,
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
+			    !e820_any_mapped(paddr & P4D_MASK, paddr_next,
+					     E820_RAM) &&
+			    !e820_any_mapped(paddr & P4D_MASK, paddr_next,
+					     E820_RESERVED_KERN)) {
+				set_p4d(p4d, __p4d(0));
+			}
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
@@ -632,26 +684,27 @@ kernel_physical_mapping_init(unsigned long paddr_start,
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
+			p4d_populate(&init_mm, p4d_offset(pgd, vaddr),
+					(pud_t *) p4d);
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
