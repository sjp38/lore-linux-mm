Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id B8F5C6B0261
	for <linux-mm@kvack.org>; Thu,  7 Jul 2016 20:19:19 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id e189so65331382pfa.2
        for <linux-mm@kvack.org>; Thu, 07 Jul 2016 17:19:19 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTP id zf8si747057pac.177.2016.07.07.17.19.15
        for <linux-mm@kvack.org>;
        Thu, 07 Jul 2016 17:19:16 -0700 (PDT)
Subject: [PATCH 4/4] x86: use pte_none() to test for empty PTE
From: Dave Hansen <dave@sr71.net>
Date: Thu, 07 Jul 2016 17:19:15 -0700
References: <20160708001909.FB2443E2@viggo.jf.intel.com>
In-Reply-To: <20160708001909.FB2443E2@viggo.jf.intel.com>
Message-Id: <20160708001915.813703D9@viggo.jf.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: x86@kernel.org, linux-mm@kvack.org, torvalds@linux-foundation.org, akpm@linux-foundation.org, bp@alien8.de, ak@linux.intel.com, mhocko@suse.com, dave.hansen@intel.com, Dave Hansen <dave@sr71.net>, dave.hansen@linux.intel.com


From: Dave Hansen <dave.hansen@linux.intel.com>

The page table manipulation code seems to have grown a couple of
sites that are looking for empty PTEs.  Just in case one of these
entries got a stray bit set, use pte_none() instead of checking
for a zero pte_val().

The use pte_same() makes me a bit nervous.  If we were doing a
pte_same() check against two cleared entries and one of them had
a stray bit set, it might fail the pte_same() check.  But, I
don't think we ever _do_ pte_same() for cleared entries.  It is
almost entirely used for checking for races in fault-in paths.

Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
---

 b/arch/x86/mm/init_64.c    |   12 ++++++------
 b/arch/x86/mm/pageattr.c   |    2 +-
 b/arch/x86/mm/pgtable_32.c |    2 +-
 3 files changed, 8 insertions(+), 8 deletions(-)

diff -puN arch/x86/mm/init_64.c~knl-strays-50-pte_val-cleanups arch/x86/mm/init_64.c
--- a/arch/x86/mm/init_64.c~knl-strays-50-pte_val-cleanups	2016-07-07 17:17:44.942808493 -0700
+++ b/arch/x86/mm/init_64.c	2016-07-07 17:17:44.949808807 -0700
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
 
diff -puN arch/x86/mm/pageattr.c~knl-strays-50-pte_val-cleanups arch/x86/mm/pageattr.c
--- a/arch/x86/mm/pageattr.c~knl-strays-50-pte_val-cleanups	2016-07-07 17:17:44.944808582 -0700
+++ b/arch/x86/mm/pageattr.c	2016-07-07 17:17:44.950808852 -0700
@@ -1185,7 +1185,7 @@ repeat:
 		return __cpa_process_fault(cpa, address, primary);
 
 	old_pte = *kpte;
-	if (!pte_val(old_pte))
+	if (pte_none(old_pte))
 		return __cpa_process_fault(cpa, address, primary);
 
 	if (level == PG_LEVEL_4K) {
diff -puN arch/x86/mm/pgtable_32.c~knl-strays-50-pte_val-cleanups arch/x86/mm/pgtable_32.c
--- a/arch/x86/mm/pgtable_32.c~knl-strays-50-pte_val-cleanups	2016-07-07 17:17:44.946808672 -0700
+++ b/arch/x86/mm/pgtable_32.c	2016-07-07 17:17:44.950808852 -0700
@@ -47,7 +47,7 @@ void set_pte_vaddr(unsigned long vaddr,
 		return;
 	}
 	pte = pte_offset_kernel(pmd, vaddr);
-	if (pte_val(pteval))
+	if (!pte_none(pteval))
 		set_pte_at(&init_mm, vaddr, pte, pteval);
 	else
 		pte_clear(&init_mm, vaddr, pte);
_

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
