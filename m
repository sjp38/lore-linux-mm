Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id E72676B028D
	for <linux-mm@kvack.org>; Tue, 10 Jul 2018 18:32:55 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id a12-v6so14741887pfn.12
        for <linux-mm@kvack.org>; Tue, 10 Jul 2018 15:32:55 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id z10-v6si17009124pgo.412.2018.07.10.15.31.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 10 Jul 2018 15:31:13 -0700 (PDT)
From: Yu-cheng Yu <yu-cheng.yu@intel.com>
Subject: [RFC PATCH v2 11/27] x86/mm: Modify ptep_set_wrprotect and pmdp_set_wrprotect for _PAGE_DIRTY_SW
Date: Tue, 10 Jul 2018 15:26:23 -0700
Message-Id: <20180710222639.8241-12-yu-cheng.yu@intel.com>
In-Reply-To: <20180710222639.8241-1-yu-cheng.yu@intel.com>
References: <20180710222639.8241-1-yu-cheng.yu@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: x86@kernel.org, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-api@vger.kernel.org, Arnd Bergmann <arnd@arndb.de>, Andy Lutomirski <luto@amacapital.net>, Balbir Singh <bsingharora@gmail.com>, Cyrill Gorcunov <gorcunov@gmail.com>, Dave Hansen <dave.hansen@linux.intel.com>, Florian Weimer <fweimer@redhat.com>, "H.J. Lu" <hjl.tools@gmail.com>, Jann Horn <jannh@google.com>, Jonathan Corbet <corbet@lwn.net>, Kees Cook <keescook@chromiun.org>, Mike Kravetz <mike.kravetz@oracle.com>, Nadav Amit <nadav.amit@gmail.com>, Oleg Nesterov <oleg@redhat.com>, Pavel Machek <pavel@ucw.cz>, Peter Zijlstra <peterz@infradead.org>, "Ravi V. Shankar" <ravi.v.shankar@intel.com>, Vedvyas Shanbhogue <vedvyas.shanbhogue@intel.com>
Cc: Yu-cheng Yu <yu-cheng.yu@intel.com>

Update ptep_set_wrprotect() and pmdp_set_wrprotect() for
_PAGE_DIRTY_SW.

Signed-off-by: Yu-cheng Yu <yu-cheng.yu@intel.com>
---
 arch/x86/include/asm/pgtable.h | 22 ++++++++++++++++++++++
 1 file changed, 22 insertions(+)

diff --git a/arch/x86/include/asm/pgtable.h b/arch/x86/include/asm/pgtable.h
index ecbd3539a864..456a864aa605 100644
--- a/arch/x86/include/asm/pgtable.h
+++ b/arch/x86/include/asm/pgtable.h
@@ -1170,7 +1170,18 @@ static inline pte_t ptep_get_and_clear_full(struct mm_struct *mm,
 static inline void ptep_set_wrprotect(struct mm_struct *mm,
 				      unsigned long addr, pte_t *ptep)
 {
+	pte_t pte;
+
 	clear_bit(_PAGE_BIT_RW, (unsigned long *)&ptep->pte);
+	pte = *ptep;
+
+	/*
+	 * On platforms before CET, other threads could race to
+	 * create a RO and _PAGE_DIRTY_HW PTE again.  However,
+	 * on CET platforms, this is safe without a TLB flush.
+	 */
+	pte = pte_move_flags(pte, _PAGE_DIRTY_HW, _PAGE_DIRTY_SW);
+	set_pte_at(mm, addr, ptep, pte);
 }
 
 #define flush_tlb_fix_spurious_fault(vma, address) do { } while (0)
@@ -1220,7 +1231,18 @@ static inline pud_t pudp_huge_get_and_clear(struct mm_struct *mm,
 static inline void pmdp_set_wrprotect(struct mm_struct *mm,
 				      unsigned long addr, pmd_t *pmdp)
 {
+	pmd_t pmd;
+
 	clear_bit(_PAGE_BIT_RW, (unsigned long *)pmdp);
+	pmd = *pmdp;
+
+	/*
+	 * On platforms before CET, other threads could race to
+	 * create a RO and _PAGE_DIRTY_HW PMD again.  However,
+	 * on CET platforms, this is safe without a TLB flush.
+	 */
+	pmd = pmd_move_flags(pmd, _PAGE_DIRTY_HW, _PAGE_DIRTY_SW);
+	set_pmd_at(mm, addr, pmdp, pmd);
 }
 
 #define pud_write pud_write
-- 
2.17.1
