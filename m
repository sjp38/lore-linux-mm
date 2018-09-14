Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id B0C9E8E0001
	for <linux-mm@kvack.org>; Fri, 14 Sep 2018 06:59:22 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id w44-v6so3672997edb.16
        for <linux-mm@kvack.org>; Fri, 14 Sep 2018 03:59:22 -0700 (PDT)
Received: from theia.8bytes.org (8bytes.org. [2a01:238:4383:600:38bc:a715:4b6d:a889])
        by mx.google.com with ESMTPS id g45-v6si3131475edg.399.2018.09.14.03.59.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 14 Sep 2018 03:59:20 -0700 (PDT)
From: Joerg Roedel <joro@8bytes.org>
Subject: [PATCH] Revert "x86/mm/legacy: Populate the user page-table with user pgd's"
Date: Fri, 14 Sep 2018 12:59:14 +0200
Message-Id: <1536922754-31379-1-git-send-email-joro@8bytes.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>
Cc: hpa@zytor.com, x86@kernel.org, linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andy Lutomirski <luto@kernel.org>, Dave Hansen <dave.hansen@intel.com>, Borislav Petkov <bp@alien8.de>, Andrea Arcangeli <aarcange@redhat.com>, Meelis Roos <mroos@linux.ee>, Joerg Roedel <jroedel@suse.de>

From: Joerg Roedel <jroedel@suse.de>

This reverts commit 1f40a46cf47c12d93a5ad9dccd82bd36ff8f956a.

It turned out that this patch is not sufficient to enable
PTI on 32 bit systems with legacy 2-level page-tables. In
this paging mode the huge-page PTEs are in the top-level
page-table directory, where also the mirroring to the
user-space page-table happens. So every huge PTE exits
twice, in the kernel and in the user page-table.

That means that accessed/dirty bits need to be fetched from
two PTEs in this mode to be safe, but this is not trivial to
implement because it needs changes to generic code just for
the sake of enabling PTI with 32-bit legacy paging. As all
systems that need PTI should support PAE anyway, remove
support for PTI when 32-bit legacy paging is used.

Reported-by: Meelis Roos <mroos@linux.ee>
Fixes: 7757d607c6b3 ('x86/pti: Allow CONFIG_PAGE_TABLE_ISOLATION for x86_32')
Signed-off-by: Joerg Roedel <jroedel@suse.de>
---
 arch/x86/include/asm/pgtable-2level.h | 9 ---------
 security/Kconfig                      | 2 +-
 2 files changed, 1 insertion(+), 10 deletions(-)

diff --git a/arch/x86/include/asm/pgtable-2level.h b/arch/x86/include/asm/pgtable-2level.h
index 24c6cf5f16b7..60d0f9015317 100644
--- a/arch/x86/include/asm/pgtable-2level.h
+++ b/arch/x86/include/asm/pgtable-2level.h
@@ -19,9 +19,6 @@ static inline void native_set_pte(pte_t *ptep , pte_t pte)
 
 static inline void native_set_pmd(pmd_t *pmdp, pmd_t pmd)
 {
-#ifdef CONFIG_PAGE_TABLE_ISOLATION
-	pmd.pud.p4d.pgd = pti_set_user_pgtbl(&pmdp->pud.p4d.pgd, pmd.pud.p4d.pgd);
-#endif
 	*pmdp = pmd;
 }
 
@@ -61,9 +58,6 @@ static inline pte_t native_ptep_get_and_clear(pte_t *xp)
 #ifdef CONFIG_SMP
 static inline pmd_t native_pmdp_get_and_clear(pmd_t *xp)
 {
-#ifdef CONFIG_PAGE_TABLE_ISOLATION
-	pti_set_user_pgtbl(&xp->pud.p4d.pgd, __pgd(0));
-#endif
 	return __pmd(xchg((pmdval_t *)xp, 0));
 }
 #else
@@ -73,9 +67,6 @@ static inline pmd_t native_pmdp_get_and_clear(pmd_t *xp)
 #ifdef CONFIG_SMP
 static inline pud_t native_pudp_get_and_clear(pud_t *xp)
 {
-#ifdef CONFIG_PAGE_TABLE_ISOLATION
-	pti_set_user_pgtbl(&xp->p4d.pgd, __pgd(0));
-#endif
 	return __pud(xchg((pudval_t *)xp, 0));
 }
 #else
diff --git a/security/Kconfig b/security/Kconfig
index 27d8b2688f75..d9aa521b5206 100644
--- a/security/Kconfig
+++ b/security/Kconfig
@@ -57,7 +57,7 @@ config SECURITY_NETWORK
 config PAGE_TABLE_ISOLATION
 	bool "Remove the kernel mapping in user mode"
 	default y
-	depends on X86 && !UML
+	depends on (X86_64 || X86_PAE) && !UML
 	help
 	  This feature reduces the number of hardware side channels by
 	  ensuring that the majority of kernel addresses are not mapped
-- 
2.16.4
