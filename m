Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8B9F76B0263
	for <linux-mm@kvack.org>; Wed, 13 Jul 2016 11:49:34 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id p41so35897564lfi.0
        for <linux-mm@kvack.org>; Wed, 13 Jul 2016 08:49:34 -0700 (PDT)
Received: from mail2-relais-roc.national.inria.fr (mail2-relais-roc.national.inria.fr. [192.134.164.83])
        by mx.google.com with ESMTPS id wh9si1727297wjb.121.2016.07.13.08.49.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Jul 2016 08:49:33 -0700 (PDT)
Date: Wed, 13 Jul 2016 17:49:16 +0200 (CEST)
From: Julia Lawall <julia.lawall@lip6.fr>
Subject: Re: [PATCH 4/4] x86: use pte_none() to test for empty PTE
In-Reply-To: <20160713151820.GA20693@dhcp22.suse.cz>
Message-ID: <alpine.DEB.2.10.1607131746570.2959@hadrien>
References: <20160708001909.FB2443E2@viggo.jf.intel.com> <20160708001915.813703D9@viggo.jf.intel.com> <20160713151820.GA20693@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Dave Hansen <dave@sr71.net>, linux-kernel@vger.kernel.org, x86@kernel.org, linux-mm@kvack.org, torvalds@linux-foundation.org, akpm@linux-foundation.org, bp@alien8.de, ak@linux.intel.com, dave.hansen@intel.com, dave.hansen@linux.intel.com, Julia Lawall <Julia.Lawall@lip6.fr>

My results are below.  There are a couple of cases in arch/mn10300/mm that
were not in the original patch.

julia

diff -u -p a/arch/x86/mm/pageattr.c b/arch/x86/mm/pageattr.c
--- a/arch/x86/mm/pageattr.c
+++ b/arch/x86/mm/pageattr.c
@@ -1185,7 +1185,7 @@ repeat:
 		return __cpa_process_fault(cpa, address, primary);

 	old_pte = *kpte;
-	if (!pte_val(old_pte))
+	if (pte_none(old_pte))
 		return __cpa_process_fault(cpa, address, primary);

 	if (level == PG_LEVEL_4K) {
diff -u -p a/arch/x86/mm/init_64.c b/arch/x86/mm/init_64.c
--- a/arch/x86/mm/init_64.c
+++ b/arch/x86/mm/init_64.c
@@ -354,7 +354,7 @@ phys_pte_init(pte_t *pte_page, unsigned
 		 * pagetable pages as RO. So assume someone who pre-setup
 		 * these mappings are more intelligent.
 		 */
-		if (pte_val(*pte)) {
+		if (!pte_none(*pte)) {
 			if (!after_bootmem)
 				pages++;
 			continue;
@@ -396,7 +396,7 @@ phys_pmd_init(pmd_t *pmd_page, unsigned
 			continue;
 		}

-		if (pmd_val(*pmd)) {
+		if (!pmd_none(*pmd)) {
 			if (!pmd_large(*pmd)) {
 				spin_lock(&init_mm.page_table_lock);
 				pte = (pte_t *)pmd_page_vaddr(*pmd);
@@ -470,7 +470,7 @@ phys_pud_init(pud_t *pud_page, unsigned
 			continue;
 		}

-		if (pud_val(*pud)) {
+		if (!pud_none(*pud)) {
 			if (!pud_large(*pud)) {
 				pmd = pmd_offset(pud, 0);
 				last_map_addr = phys_pmd_init(pmd, addr, end,
@@ -673,7 +673,7 @@ static void __meminit free_pte_table(pte

 	for (i = 0; i < PTRS_PER_PTE; i++) {
 		pte = pte_start + i;
-		if (pte_val(*pte))
+		if (!pte_none(*pte))
 			return;
 	}

@@ -691,7 +691,7 @@ static void __meminit free_pmd_table(pmd

 	for (i = 0; i < PTRS_PER_PMD; i++) {
 		pmd = pmd_start + i;
-		if (pmd_val(*pmd))
+		if (!pmd_none(*pmd))
 			return;
 	}

@@ -710,7 +710,7 @@ static bool __meminit free_pud_table(pud

 	for (i = 0; i < PTRS_PER_PUD; i++) {
 		pud = pud_start + i;
-		if (pud_val(*pud))
+		if (!pud_none(*pud))
 			return false;
 	}

diff -u -p a/arch/x86/mm/pgtable_32.c b/arch/x86/mm/pgtable_32.c
--- a/arch/x86/mm/pgtable_32.c
+++ b/arch/x86/mm/pgtable_32.c
@@ -47,7 +47,7 @@ void set_pte_vaddr(unsigned long vaddr,
 		return;
 	}
 	pte = pte_offset_kernel(pmd, vaddr);
-	if (pte_val(pteval))
+	if (!pte_none(pteval))
 		set_pte_at(&init_mm, vaddr, pte, pteval);
 	else
 		pte_clear(&init_mm, vaddr, pte);
diff -u -p a/arch/mn10300/mm/cache-flush-icache.c b/arch/mn10300/mm/cache-flush-icache.c
--- a/arch/mn10300/mm/cache-flush-icache.c
+++ b/arch/mn10300/mm/cache-flush-icache.c
@@ -67,11 +67,11 @@ static void flush_icache_page_range(unsi
 		return;

 	pud = pud_offset(pgd, start);
-	if (!pud || !pud_val(*pud))
+	if (!pud || pud_none(*pud))
 		return;

 	pmd = pmd_offset(pud, start);
-	if (!pmd || !pmd_val(*pmd))
+	if (!pmd || pmd_none(*pmd))
 		return;

 	ppte = pte_offset_map(pmd, start);
diff -u -p a/arch/mn10300/mm/cache-inv-icache.c b/arch/mn10300/mm/cache-inv-icache.c
--- a/arch/mn10300/mm/cache-inv-icache.c
+++ b/arch/mn10300/mm/cache-inv-icache.c
@@ -45,11 +45,11 @@ static void flush_icache_page_range(unsi
 		return;

 	pud = pud_offset(pgd, start);
-	if (!pud || !pud_val(*pud))
+	if (!pud || pud_none(*pud))
 		return;

 	pmd = pmd_offset(pud, start);
-	if (!pmd || !pmd_val(*pmd))
+	if (!pmd || pmd_none(*pmd))
 		return;

 	ppte = pte_offset_map(pmd, start);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
