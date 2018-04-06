Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id E247A6B0012
	for <linux-mm@kvack.org>; Fri,  6 Apr 2018 16:58:13 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id d6-v6so1757662plo.2
        for <linux-mm@kvack.org>; Fri, 06 Apr 2018 13:58:13 -0700 (PDT)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id g3si1718403pgr.635.2018.04.06.13.58.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 06 Apr 2018 13:58:12 -0700 (PDT)
Subject: [PATCH 09/11] x86/pti: enable global pages for shared areas
From: Dave Hansen <dave.hansen@linux.intel.com>
Date: Fri, 06 Apr 2018 13:55:15 -0700
References: <20180406205501.24A1A4E7@viggo.jf.intel.com>
In-Reply-To: <20180406205501.24A1A4E7@viggo.jf.intel.com>
Message-Id: <20180406205515.2977EE7D@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, Dave Hansen <dave.hansen@linux.intel.com>, aarcange@redhat.com, luto@kernel.org, torvalds@linux-foundation.org, keescook@google.com, hughd@google.com, jgross@suse.com, x86@kernel.org, namit@vmware.com


From: Dave Hansen <dave.hansen@linux.intel.com>

The entry/exit text and cpu_entry_area are mapped into userspace and
the kernel.  But, they are not _PAGE_GLOBAL.  This creates unnecessary
TLB misses.

Add the _PAGE_GLOBAL flag for these areas.

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Andy Lutomirski <luto@kernel.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Kees Cook <keescook@google.com>
Cc: Hugh Dickins <hughd@google.com>
Cc: Juergen Gross <jgross@suse.com>
Cc: x86@kernel.org
Cc: Nadav Amit <namit@vmware.com>
---

 b/arch/x86/mm/cpu_entry_area.c |   14 +++++++++++++-
 b/arch/x86/mm/pti.c            |   23 ++++++++++++++++++++++-
 2 files changed, 35 insertions(+), 2 deletions(-)

diff -puN arch/x86/mm/cpu_entry_area.c~kpti-why-no-global arch/x86/mm/cpu_entry_area.c
--- a/arch/x86/mm/cpu_entry_area.c~kpti-why-no-global	2018-04-06 10:47:58.246796118 -0700
+++ b/arch/x86/mm/cpu_entry_area.c	2018-04-06 10:47:58.252796118 -0700
@@ -27,8 +27,20 @@ EXPORT_SYMBOL(get_cpu_entry_area);
 void cea_set_pte(void *cea_vaddr, phys_addr_t pa, pgprot_t flags)
 {
 	unsigned long va = (unsigned long) cea_vaddr;
+	pte_t pte = pfn_pte(pa >> PAGE_SHIFT, flags);
 
-	set_pte_vaddr(va, pfn_pte(pa >> PAGE_SHIFT, flags));
+	/*
+	 * The cpu_entry_area is shared between the user and kernel
+	 * page tables.  All of its ptes can safely be global.
+	 * _PAGE_GLOBAL gets reused to help indicate PROT_NONE for
+	 * non-present PTEs, so be careful not to set it in that
+	 * case to avoid confusion.
+	 */
+	if (boot_cpu_has(X86_FEATURE_PGE) &&
+	    (pgprot_val(flags) & _PAGE_PRESENT))
+		pte = pte_set_flags(pte, _PAGE_GLOBAL);
+
+	set_pte_vaddr(va, pte);
 }
 
 static void __init
diff -puN arch/x86/mm/pti.c~kpti-why-no-global arch/x86/mm/pti.c
--- a/arch/x86/mm/pti.c~kpti-why-no-global	2018-04-06 10:47:58.248796118 -0700
+++ b/arch/x86/mm/pti.c	2018-04-06 10:47:58.252796118 -0700
@@ -300,6 +300,27 @@ pti_clone_pmds(unsigned long start, unsi
 			return;
 
 		/*
+		 * Only clone present PMDs.  This ensures only setting
+		 * _PAGE_GLOBAL on present PMDs.  This should only be
+		 * called on well-known addresses anyway, so a non-
+		 * present PMD would be a surprise.
+		 */
+		if (WARN_ON(!(pmd_flags(*pmd) & _PAGE_PRESENT)))
+			return;
+
+		/*
+		 * Setting 'target_pmd' below creates a mapping in both
+		 * the user and kernel page tables.  It is effectively
+		 * global, so set it as global in both copies.  Note:
+		 * the X86_FEATURE_PGE check is not _required_ because
+		 * the CPU ignores _PAGE_GLOBAL when PGE is not
+		 * supported.  The check keeps consistentency with
+		 * code that only set this bit when supported.
+		 */
+		if (boot_cpu_has(X86_FEATURE_PGE))
+			*pmd = pmd_set_flags(*pmd, _PAGE_GLOBAL);
+
+		/*
 		 * Copy the PMD.  That is, the kernelmode and usermode
 		 * tables will share the last-level page tables of this
 		 * address range
@@ -348,7 +369,7 @@ static void __init pti_clone_entry_text(
 {
 	pti_clone_pmds((unsigned long) __entry_text_start,
 			(unsigned long) __irqentry_text_end,
-		       _PAGE_RW | _PAGE_GLOBAL);
+		       _PAGE_RW);
 }
 
 /*
_
