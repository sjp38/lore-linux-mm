Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi1-f197.google.com (mail-oi1-f197.google.com [209.85.167.197])
	by kanga.kvack.org (Postfix) with ESMTP id 526E66B7B50
	for <linux-mm@kvack.org>; Thu,  6 Dec 2018 13:21:18 -0500 (EST)
Received: by mail-oi1-f197.google.com with SMTP id p128so610903oib.2
        for <linux-mm@kvack.org>; Thu, 06 Dec 2018 10:21:18 -0800 (PST)
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id l1si404158oib.170.2018.12.06.10.21.16
        for <linux-mm@kvack.org>;
        Thu, 06 Dec 2018 10:21:16 -0800 (PST)
From: Will Deacon <will.deacon@arm.com>
Subject: [RESEND PATCH v4 4/5] lib/ioremap: Ensure phys_addr actually corresponds to a physical address
Date: Thu,  6 Dec 2018 18:21:34 +0000
Message-Id: <1544120495-17438-5-git-send-email-will.deacon@arm.com>
In-Reply-To: <1544120495-17438-1-git-send-email-will.deacon@arm.com>
References: <1544120495-17438-1-git-send-email-will.deacon@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, cpandya@codeaurora.org, toshi.kani@hpe.com, tglx@linutronix.de, mhocko@suse.com, sean.j.christopherson@intel.com, Will Deacon <will.deacon@arm.com>

The current ioremap() code uses a phys_addr variable at each level of
page table, which is confusingly offset by subtracting the base virtual
address being mapped so that adding the current virtual address back on
when iterating through the page table entries gives back the corresponding
physical address.

This is fairly confusing and results in all users of phys_addr having to
add the current virtual address back on. Instead, this patch just updates
phys_addr when iterating over the page table entries, ensuring that it's
always up-to-date and doesn't require explicit offsetting.

Cc: Chintan Pandya <cpandya@codeaurora.org>
Cc: Toshi Kani <toshi.kani@hpe.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Sean Christopherson <sean.j.christopherson@intel.com>
Tested-by: Sean Christopherson <sean.j.christopherson@intel.com>
Reviewed-by: Sean Christopherson <sean.j.christopherson@intel.com>
Signed-off-by: Will Deacon <will.deacon@arm.com>
---
 lib/ioremap.c | 28 ++++++++++++----------------
 1 file changed, 12 insertions(+), 16 deletions(-)

diff --git a/lib/ioremap.c b/lib/ioremap.c
index 6c72764af19c..10d7c5485c39 100644
--- a/lib/ioremap.c
+++ b/lib/ioremap.c
@@ -101,19 +101,18 @@ static inline int ioremap_pmd_range(pud_t *pud, unsigned long addr,
 	pmd_t *pmd;
 	unsigned long next;
 
-	phys_addr -= addr;
 	pmd = pmd_alloc(&init_mm, pud, addr);
 	if (!pmd)
 		return -ENOMEM;
 	do {
 		next = pmd_addr_end(addr, end);
 
-		if (ioremap_try_huge_pmd(pmd, addr, next, phys_addr + addr, prot))
+		if (ioremap_try_huge_pmd(pmd, addr, next, phys_addr, prot))
 			continue;
 
-		if (ioremap_pte_range(pmd, addr, next, phys_addr + addr, prot))
+		if (ioremap_pte_range(pmd, addr, next, phys_addr, prot))
 			return -ENOMEM;
-	} while (pmd++, addr = next, addr != end);
+	} while (pmd++, phys_addr += (next - addr), addr = next, addr != end);
 	return 0;
 }
 
@@ -142,19 +141,18 @@ static inline int ioremap_pud_range(p4d_t *p4d, unsigned long addr,
 	pud_t *pud;
 	unsigned long next;
 
-	phys_addr -= addr;
 	pud = pud_alloc(&init_mm, p4d, addr);
 	if (!pud)
 		return -ENOMEM;
 	do {
 		next = pud_addr_end(addr, end);
 
-		if (ioremap_try_huge_pud(pud, addr, next, phys_addr + addr, prot))
+		if (ioremap_try_huge_pud(pud, addr, next, phys_addr, prot))
 			continue;
 
-		if (ioremap_pmd_range(pud, addr, next, phys_addr + addr, prot))
+		if (ioremap_pmd_range(pud, addr, next, phys_addr, prot))
 			return -ENOMEM;
-	} while (pud++, addr = next, addr != end);
+	} while (pud++, phys_addr += (next - addr), addr = next, addr != end);
 	return 0;
 }
 
@@ -164,7 +162,6 @@ static inline int ioremap_p4d_range(pgd_t *pgd, unsigned long addr,
 	p4d_t *p4d;
 	unsigned long next;
 
-	phys_addr -= addr;
 	p4d = p4d_alloc(&init_mm, pgd, addr);
 	if (!p4d)
 		return -ENOMEM;
@@ -173,14 +170,14 @@ static inline int ioremap_p4d_range(pgd_t *pgd, unsigned long addr,
 
 		if (ioremap_p4d_enabled() &&
 		    ((next - addr) == P4D_SIZE) &&
-		    IS_ALIGNED(phys_addr + addr, P4D_SIZE)) {
-			if (p4d_set_huge(p4d, phys_addr + addr, prot))
+		    IS_ALIGNED(phys_addr, P4D_SIZE)) {
+			if (p4d_set_huge(p4d, phys_addr, prot))
 				continue;
 		}
 
-		if (ioremap_pud_range(p4d, addr, next, phys_addr + addr, prot))
+		if (ioremap_pud_range(p4d, addr, next, phys_addr, prot))
 			return -ENOMEM;
-	} while (p4d++, addr = next, addr != end);
+	} while (p4d++, phys_addr += (next - addr), addr = next, addr != end);
 	return 0;
 }
 
@@ -196,14 +193,13 @@ int ioremap_page_range(unsigned long addr,
 	BUG_ON(addr >= end);
 
 	start = addr;
-	phys_addr -= addr;
 	pgd = pgd_offset_k(addr);
 	do {
 		next = pgd_addr_end(addr, end);
-		err = ioremap_p4d_range(pgd, addr, next, phys_addr+addr, prot);
+		err = ioremap_p4d_range(pgd, addr, next, phys_addr, prot);
 		if (err)
 			break;
-	} while (pgd++, addr = next, addr != end);
+	} while (pgd++, phys_addr += (next - addr), addr = next, addr != end);
 
 	flush_cache_vmap(start, end);
 
-- 
2.1.4
