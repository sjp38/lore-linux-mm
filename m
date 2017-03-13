Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id B50826B0406
	for <linux-mm@kvack.org>; Mon, 13 Mar 2017 01:50:36 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id e5so284128868pgk.1
        for <linux-mm@kvack.org>; Sun, 12 Mar 2017 22:50:36 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTPS id e3si10487362pgn.333.2017.03.12.22.50.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 12 Mar 2017 22:50:35 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 09/26] x86/mm/pat: handle additional page table
Date: Mon, 13 Mar 2017 08:50:03 +0300
Message-Id: <20170313055020.69655-10-kirill.shutemov@linux.intel.com>
In-Reply-To: <20170313055020.69655-1-kirill.shutemov@linux.intel.com>
References: <20170313055020.69655-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Arnd Bergmann <arnd@arndb.de>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, Michal Hocko <mhocko@suse.com>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Straight-forward extension of existing code to support additional page
table level.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 arch/x86/mm/pageattr.c | 56 ++++++++++++++++++++++++++++++++++++--------------
 1 file changed, 41 insertions(+), 15 deletions(-)

diff --git a/arch/x86/mm/pageattr.c b/arch/x86/mm/pageattr.c
index 28d42130243c..eb0ad12cdfde 100644
--- a/arch/x86/mm/pageattr.c
+++ b/arch/x86/mm/pageattr.c
@@ -346,6 +346,7 @@ static inline pgprot_t static_protections(pgprot_t prot, unsigned long address,
 pte_t *lookup_address_in_pgd(pgd_t *pgd, unsigned long address,
 			     unsigned int *level)
 {
+	p4d_t *p4d;
 	pud_t *pud;
 	pmd_t *pmd;
 
@@ -354,7 +355,15 @@ pte_t *lookup_address_in_pgd(pgd_t *pgd, unsigned long address,
 	if (pgd_none(*pgd))
 		return NULL;
 
-	pud = pud_offset(pgd, address);
+	p4d = p4d_offset(pgd, address);
+	if (p4d_none(*p4d))
+		return NULL;
+
+	*level = PG_LEVEL_512G;
+	if (p4d_large(*p4d) || !p4d_present(*p4d))
+		return (pte_t *)p4d;
+
+	pud = pud_offset(p4d, address);
 	if (pud_none(*pud))
 		return NULL;
 
@@ -406,13 +415,18 @@ static pte_t *_lookup_address_cpa(struct cpa_data *cpa, unsigned long address,
 pmd_t *lookup_pmd_address(unsigned long address)
 {
 	pgd_t *pgd;
+	p4d_t *p4d;
 	pud_t *pud;
 
 	pgd = pgd_offset_k(address);
 	if (pgd_none(*pgd))
 		return NULL;
 
-	pud = pud_offset(pgd, address);
+	p4d = p4d_offset(pgd, address);
+	if (p4d_none(*p4d) || p4d_large(*p4d) || !p4d_present(*p4d))
+		return NULL;
+
+	pud = pud_offset(p4d, address);
 	if (pud_none(*pud) || pud_large(*pud) || !pud_present(*pud))
 		return NULL;
 
@@ -477,11 +491,13 @@ static void __set_pmd_pte(pte_t *kpte, unsigned long address, pte_t pte)
 
 		list_for_each_entry(page, &pgd_list, lru) {
 			pgd_t *pgd;
+			p4d_t *p4d;
 			pud_t *pud;
 			pmd_t *pmd;
 
 			pgd = (pgd_t *)page_address(page) + pgd_index(address);
-			pud = pud_offset(pgd, address);
+			p4d = p4d_offset(pgd, address);
+			pud = pud_offset(p4d, address);
 			pmd = pmd_offset(pud, address);
 			set_pte_atomic((pte_t *)pmd, pte);
 		}
@@ -836,9 +852,9 @@ static void unmap_pmd_range(pud_t *pud, unsigned long start, unsigned long end)
 			pud_clear(pud);
 }
 
-static void unmap_pud_range(pgd_t *pgd, unsigned long start, unsigned long end)
+static void unmap_pud_range(p4d_t *p4d, unsigned long start, unsigned long end)
 {
-	pud_t *pud = pud_offset(pgd, start);
+	pud_t *pud = pud_offset(p4d, start);
 
 	/*
 	 * Not on a GB page boundary?
@@ -1004,8 +1020,8 @@ static long populate_pmd(struct cpa_data *cpa,
 	return num_pages;
 }
 
-static long populate_pud(struct cpa_data *cpa, unsigned long start, pgd_t *pgd,
-			 pgprot_t pgprot)
+static int populate_pud(struct cpa_data *cpa, unsigned long start, p4d_t *p4d,
+			pgprot_t pgprot)
 {
 	pud_t *pud;
 	unsigned long end;
@@ -1026,7 +1042,7 @@ static long populate_pud(struct cpa_data *cpa, unsigned long start, pgd_t *pgd,
 		cur_pages = (pre_end - start) >> PAGE_SHIFT;
 		cur_pages = min_t(int, (int)cpa->numpages, cur_pages);
 
-		pud = pud_offset(pgd, start);
+		pud = pud_offset(p4d, start);
 
 		/*
 		 * Need a PMD page?
@@ -1047,7 +1063,7 @@ static long populate_pud(struct cpa_data *cpa, unsigned long start, pgd_t *pgd,
 	if (cpa->numpages == cur_pages)
 		return cur_pages;
 
-	pud = pud_offset(pgd, start);
+	pud = pud_offset(p4d, start);
 	pud_pgprot = pgprot_4k_2_large(pgprot);
 
 	/*
@@ -1067,7 +1083,7 @@ static long populate_pud(struct cpa_data *cpa, unsigned long start, pgd_t *pgd,
 	if (start < end) {
 		long tmp;
 
-		pud = pud_offset(pgd, start);
+		pud = pud_offset(p4d, start);
 		if (pud_none(*pud))
 			if (alloc_pmd_page(pud))
 				return -1;
@@ -1090,33 +1106,43 @@ static int populate_pgd(struct cpa_data *cpa, unsigned long addr)
 {
 	pgprot_t pgprot = __pgprot(_KERNPG_TABLE);
 	pud_t *pud = NULL;	/* shut up gcc */
+	p4d_t *p4d;
 	pgd_t *pgd_entry;
 	long ret;
 
 	pgd_entry = cpa->pgd + pgd_index(addr);
 
+	if (pgd_none(*pgd_entry)) {
+		p4d = (p4d_t *)get_zeroed_page(GFP_KERNEL | __GFP_NOTRACK);
+		if (!p4d)
+			return -1;
+
+		set_pgd(pgd_entry, __pgd(__pa(p4d) | _KERNPG_TABLE));
+	}
+
 	/*
-	 * Allocate a PUD page and hand it down for mapping.
+	 * Allocate a P4D page and hand it down for mapping.
 	 */
-	if (pgd_none(*pgd_entry)) {
+	p4d = p4d_offset(pgd_entry, addr);
+	if (p4d_none(*p4d)) {
 		pud = (pud_t *)get_zeroed_page(GFP_KERNEL | __GFP_NOTRACK);
 		if (!pud)
 			return -1;
 
-		set_pgd(pgd_entry, __pgd(__pa(pud) | _KERNPG_TABLE));
+		set_p4d(p4d, __p4d(__pa(pud) | _KERNPG_TABLE));
 	}
 
 	pgprot_val(pgprot) &= ~pgprot_val(cpa->mask_clr);
 	pgprot_val(pgprot) |=  pgprot_val(cpa->mask_set);
 
-	ret = populate_pud(cpa, addr, pgd_entry, pgprot);
+	ret = populate_pud(cpa, addr, p4d, pgprot);
 	if (ret < 0) {
 		/*
 		 * Leave the PUD page in place in case some other CPU or thread
 		 * already found it, but remove any useless entries we just
 		 * added to it.
 		 */
-		unmap_pud_range(pgd_entry, addr,
+		unmap_pud_range(p4d, addr,
 				addr + (cpa->numpages << PAGE_SHIFT));
 		return ret;
 	}
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
