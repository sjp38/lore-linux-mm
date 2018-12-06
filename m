Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot1-f69.google.com (mail-ot1-f69.google.com [209.85.210.69])
	by kanga.kvack.org (Postfix) with ESMTP id 6D48E6B7B50
	for <linux-mm@kvack.org>; Thu,  6 Dec 2018 13:21:17 -0500 (EST)
Received: by mail-ot1-f69.google.com with SMTP id o8so557004otp.16
        for <linux-mm@kvack.org>; Thu, 06 Dec 2018 10:21:17 -0800 (PST)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id e2si430989otf.278.2018.12.06.10.21.16
        for <linux-mm@kvack.org>;
        Thu, 06 Dec 2018 10:21:16 -0800 (PST)
From: Will Deacon <will.deacon@arm.com>
Subject: [RESEND PATCH v4 1/5] ioremap: Rework pXd_free_pYd_page() API
Date: Thu,  6 Dec 2018 18:21:31 +0000
Message-Id: <1544120495-17438-2-git-send-email-will.deacon@arm.com>
In-Reply-To: <1544120495-17438-1-git-send-email-will.deacon@arm.com>
References: <1544120495-17438-1-git-send-email-will.deacon@arm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, cpandya@codeaurora.org, toshi.kani@hpe.com, tglx@linutronix.de, mhocko@suse.com, sean.j.christopherson@intel.com, Will Deacon <will.deacon@arm.com>

The recently merged API for ensuring break-before-make on page-table
entries when installing huge mappings in the vmalloc/ioremap region is
fairly counter-intuitive, resulting in the arch freeing functions
(e.g. pmd_free_pte_page()) being called even on entries that aren't
present. This resulted in a minor bug in the arm64 implementation, giving
rise to spurious VM_WARN messages.

This patch moves the pXd_present() checks out into the core code,
refactoring the callsites at the same time so that we avoid the complex
conjunctions when determining whether or not we can put down a huge
mapping.

Cc: Chintan Pandya <cpandya@codeaurora.org>
Cc: Toshi Kani <toshi.kani@hpe.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Suggested-by: Linus Torvalds <torvalds@linux-foundation.org>
Reviewed-by: Toshi Kani <toshi.kani@hpe.com>
Signed-off-by: Will Deacon <will.deacon@arm.com>
---
 lib/ioremap.c | 56 ++++++++++++++++++++++++++++++++++++++++++--------------
 1 file changed, 42 insertions(+), 14 deletions(-)

diff --git a/lib/ioremap.c b/lib/ioremap.c
index 517f5853ffed..6c72764af19c 100644
--- a/lib/ioremap.c
+++ b/lib/ioremap.c
@@ -76,6 +76,25 @@ static int ioremap_pte_range(pmd_t *pmd, unsigned long addr,
 	return 0;
 }
 
+static int ioremap_try_huge_pmd(pmd_t *pmd, unsigned long addr,
+				unsigned long end, phys_addr_t phys_addr,
+				pgprot_t prot)
+{
+	if (!ioremap_pmd_enabled())
+		return 0;
+
+	if ((end - addr) != PMD_SIZE)
+		return 0;
+
+	if (!IS_ALIGNED(phys_addr, PMD_SIZE))
+		return 0;
+
+	if (pmd_present(*pmd) && !pmd_free_pte_page(pmd, addr))
+		return 0;
+
+	return pmd_set_huge(pmd, phys_addr, prot);
+}
+
 static inline int ioremap_pmd_range(pud_t *pud, unsigned long addr,
 		unsigned long end, phys_addr_t phys_addr, pgprot_t prot)
 {
@@ -89,13 +108,8 @@ static inline int ioremap_pmd_range(pud_t *pud, unsigned long addr,
 	do {
 		next = pmd_addr_end(addr, end);
 
-		if (ioremap_pmd_enabled() &&
-		    ((next - addr) == PMD_SIZE) &&
-		    IS_ALIGNED(phys_addr + addr, PMD_SIZE) &&
-		    pmd_free_pte_page(pmd, addr)) {
-			if (pmd_set_huge(pmd, phys_addr + addr, prot))
-				continue;
-		}
+		if (ioremap_try_huge_pmd(pmd, addr, next, phys_addr + addr, prot))
+			continue;
 
 		if (ioremap_pte_range(pmd, addr, next, phys_addr + addr, prot))
 			return -ENOMEM;
@@ -103,6 +117,25 @@ static inline int ioremap_pmd_range(pud_t *pud, unsigned long addr,
 	return 0;
 }
 
+static int ioremap_try_huge_pud(pud_t *pud, unsigned long addr,
+				unsigned long end, phys_addr_t phys_addr,
+				pgprot_t prot)
+{
+	if (!ioremap_pud_enabled())
+		return 0;
+
+	if ((end - addr) != PUD_SIZE)
+		return 0;
+
+	if (!IS_ALIGNED(phys_addr, PUD_SIZE))
+		return 0;
+
+	if (pud_present(*pud) && !pud_free_pmd_page(pud, addr))
+		return 0;
+
+	return pud_set_huge(pud, phys_addr, prot);
+}
+
 static inline int ioremap_pud_range(p4d_t *p4d, unsigned long addr,
 		unsigned long end, phys_addr_t phys_addr, pgprot_t prot)
 {
@@ -116,13 +149,8 @@ static inline int ioremap_pud_range(p4d_t *p4d, unsigned long addr,
 	do {
 		next = pud_addr_end(addr, end);
 
-		if (ioremap_pud_enabled() &&
-		    ((next - addr) == PUD_SIZE) &&
-		    IS_ALIGNED(phys_addr + addr, PUD_SIZE) &&
-		    pud_free_pmd_page(pud, addr)) {
-			if (pud_set_huge(pud, phys_addr + addr, prot))
-				continue;
-		}
+		if (ioremap_try_huge_pud(pud, addr, next, phys_addr + addr, prot))
+			continue;
 
 		if (ioremap_pmd_range(pud, addr, next, phys_addr + addr, prot))
 			return -ENOMEM;
-- 
2.1.4
