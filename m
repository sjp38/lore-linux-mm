Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 384D46B0023
	for <linux-mm@kvack.org>; Fri, 23 Mar 2018 13:47:04 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id g61-v6so4840852plb.10
        for <linux-mm@kvack.org>; Fri, 23 Mar 2018 10:47:04 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id u16si7118783pfl.299.2018.03.23.10.47.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Mar 2018 10:47:03 -0700 (PDT)
Subject: [PATCH 09/11] x86/pti: enable global pages for shared areas
From: Dave Hansen <dave.hansen@linux.intel.com>
Date: Fri, 23 Mar 2018 10:45:00 -0700
References: <20180323174447.55F35636@viggo.jf.intel.com>
In-Reply-To: <20180323174447.55F35636@viggo.jf.intel.com>
Message-Id: <20180323174500.64BD3D36@viggo.jf.intel.com>
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

 b/arch/x86/mm/cpu_entry_area.c |   10 +++++++++-
 b/arch/x86/mm/pti.c            |    9 ++++++++-
 2 files changed, 17 insertions(+), 2 deletions(-)

diff -puN arch/x86/mm/cpu_entry_area.c~kpti-why-no-global arch/x86/mm/cpu_entry_area.c
--- a/arch/x86/mm/cpu_entry_area.c~kpti-why-no-global	2018-03-21 16:32:00.797192311 -0700
+++ b/arch/x86/mm/cpu_entry_area.c	2018-03-21 16:32:00.802192311 -0700
@@ -27,8 +27,16 @@ EXPORT_SYMBOL(get_cpu_entry_area);
 void cea_set_pte(void *cea_vaddr, phys_addr_t pa, pgprot_t flags)
 {
 	unsigned long va = (unsigned long) cea_vaddr;
+	pte_t pte = pfn_pte(pa >> PAGE_SHIFT, flags);
 
-	set_pte_vaddr(va, pfn_pte(pa >> PAGE_SHIFT, flags));
+	/*
+	 * The cpu_entry_area is shared between the user and kernel
+	 * page tables.  All of its ptes can safely be global.
+	 */
+	if (boot_cpu_has(X86_FEATURE_PGE))
+		pte = pte_set_flags(pte, _PAGE_GLOBAL);
+
+	set_pte_vaddr(va, pte);
 }
 
 static void __init
diff -puN arch/x86/mm/pti.c~kpti-why-no-global arch/x86/mm/pti.c
--- a/arch/x86/mm/pti.c~kpti-why-no-global	2018-03-21 16:32:00.799192311 -0700
+++ b/arch/x86/mm/pti.c	2018-03-21 16:32:00.803192311 -0700
@@ -300,6 +300,13 @@ pti_clone_pmds(unsigned long start, unsi
 			return;
 
 		/*
+		 * Setting 'target_pmd' below creates a mapping in both
+		 * the user and kernel page tables.  It is effectively
+		 * global, so set it as global in both copies.
+		 */
+		*pmd = pmd_set_flags(*pmd, _PAGE_GLOBAL);
+
+		/*
 		 * Copy the PMD.  That is, the kernelmode and usermode
 		 * tables will share the last-level page tables of this
 		 * address range
@@ -348,7 +355,7 @@ static void __init pti_clone_entry_text(
 {
 	pti_clone_pmds((unsigned long) __entry_text_start,
 			(unsigned long) __irqentry_text_end,
-		       _PAGE_RW | _PAGE_GLOBAL);
+		       _PAGE_RW);
 }
 
 /*
_
