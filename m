Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f52.google.com (mail-oi0-f52.google.com [209.85.218.52])
	by kanga.kvack.org (Postfix) with ESMTP id 6E6296B0253
	for <linux-mm@kvack.org>; Thu,  9 Jul 2015 13:04:55 -0400 (EDT)
Received: by oihr66 with SMTP id r66so137889363oih.2
        for <linux-mm@kvack.org>; Thu, 09 Jul 2015 10:04:55 -0700 (PDT)
Received: from g9t5008.houston.hp.com (g9t5008.houston.hp.com. [15.240.92.66])
        by mx.google.com with ESMTPS id p132si4671044oig.125.2015.07.09.10.04.52
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 09 Jul 2015 10:04:52 -0700 (PDT)
From: Toshi Kani <toshi.kani@hp.com>
Subject: [PATCH 2/2] x86, mm: Fix page table dump to show PAT bit
Date: Thu,  9 Jul 2015 11:03:51 -0600
Message-Id: <1436461431-27305-3-git-send-email-toshi.kani@hp.com>
In-Reply-To: <1436461431-27305-1-git-send-email-toshi.kani@hp.com>
References: <1436461431-27305-1-git-send-email-toshi.kani@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hpa@zytor.com, tglx@linutronix.de, mingo@redhat.com
Cc: akpm@linux-foundation.org, bp@alien8.de, linux-mm@kvack.org, linux-kernel@vger.kernel.org, x86@kernel.org, jgross@suse.com, konrad.wilk@oracle.com, elliott@hp.com, Toshi Kani <toshi.kani@hp.com>

/sys/kernel/debug/kernel_page_tables does not show the PAT bit
for PUD and PMD mappings.  This is because walk_pud_level(),
walk_pmd_level() and note_page() mask the flags with PTE_FLAGS_MASK,
which does not cover their PAT bit, _PAGE_PAT_LARGE.

Fix it by replacing the use of PTE_FLAGS_MASK with pXd_flags(),
which mask the flags properly.

Change also to show the PAT bit as "PAT" to be consistent with
other bits.

Reported-by: Robert Elliott <elliott@hp.com>
Signed-off-by: Toshi Kani <toshi.kani@hp.com>
Cc: Juergen Gross <jgross@suse.com>
Cc: Konrad Wilk <konrad.wilk@oracle.com>
Cc: Robert Elliott <elliott@hp.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: H. Peter Anvin <hpa@zytor.com>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: Borislav Petkov <bp@alien8.de>
Cc: Andrew Morton <akpm@linux-foundation.org>
---
 arch/x86/mm/dump_pagetables.c |   39 +++++++++++++++++++++------------------
 1 file changed, 21 insertions(+), 18 deletions(-)

diff --git a/arch/x86/mm/dump_pagetables.c b/arch/x86/mm/dump_pagetables.c
index f0cedf3..71ab2d7 100644
--- a/arch/x86/mm/dump_pagetables.c
+++ b/arch/x86/mm/dump_pagetables.c
@@ -155,7 +155,7 @@ static void printk_prot(struct seq_file *m, pgprot_t prot, int level, bool dmsg)
 			pt_dump_cont_printf(m, dmsg, "    ");
 		if ((level == 4 && pr & _PAGE_PAT) ||
 		    ((level == 3 || level == 2) && pr & _PAGE_PAT_LARGE))
-			pt_dump_cont_printf(m, dmsg, "pat ");
+			pt_dump_cont_printf(m, dmsg, "PAT ");
 		else
 			pt_dump_cont_printf(m, dmsg, "    ");
 		if (pr & _PAGE_GLOBAL)
@@ -198,8 +198,8 @@ static void note_page(struct seq_file *m, struct pg_state *st,
 	 * we have now. "break" is either changing perms, levels or
 	 * address space marker.
 	 */
-	prot = pgprot_val(new_prot) & PTE_FLAGS_MASK;
-	cur = pgprot_val(st->current_prot) & PTE_FLAGS_MASK;
+	prot = pgprot_val(new_prot);
+	cur = pgprot_val(st->current_prot);
 
 	if (!st->level) {
 		/* First entry */
@@ -269,13 +269,13 @@ static void walk_pte_level(struct seq_file *m, struct pg_state *st, pmd_t addr,
 {
 	int i;
 	pte_t *start;
+	pgprotval_t prot;
 
 	start = (pte_t *) pmd_page_vaddr(addr);
 	for (i = 0; i < PTRS_PER_PTE; i++) {
-		pgprot_t prot = pte_pgprot(*start);
-
+		prot = pte_flags(*start);
 		st->current_address = normalize_addr(P + i * PTE_LEVEL_MULT);
-		note_page(m, st, prot, 4);
+		note_page(m, st, __pgprot(prot), 4);
 		start++;
 	}
 }
@@ -287,18 +287,19 @@ static void walk_pmd_level(struct seq_file *m, struct pg_state *st, pud_t addr,
 {
 	int i;
 	pmd_t *start;
+	pgprotval_t prot;
 
 	start = (pmd_t *) pud_page_vaddr(addr);
 	for (i = 0; i < PTRS_PER_PMD; i++) {
 		st->current_address = normalize_addr(P + i * PMD_LEVEL_MULT);
 		if (!pmd_none(*start)) {
-			pgprotval_t prot = pmd_val(*start) & PTE_FLAGS_MASK;
-
-			if (pmd_large(*start) || !pmd_present(*start))
+			if (pmd_large(*start) || !pmd_present(*start)) {
+				prot = pmd_flags(*start);
 				note_page(m, st, __pgprot(prot), 3);
-			else
+			} else {
 				walk_pte_level(m, st, *start,
 					       P + i * PMD_LEVEL_MULT);
+			}
 		} else
 			note_page(m, st, __pgprot(0), 3);
 		start++;
@@ -318,19 +319,20 @@ static void walk_pud_level(struct seq_file *m, struct pg_state *st, pgd_t addr,
 {
 	int i;
 	pud_t *start;
+	pgprotval_t prot;
 
 	start = (pud_t *) pgd_page_vaddr(addr);
 
 	for (i = 0; i < PTRS_PER_PUD; i++) {
 		st->current_address = normalize_addr(P + i * PUD_LEVEL_MULT);
 		if (!pud_none(*start)) {
-			pgprotval_t prot = pud_val(*start) & PTE_FLAGS_MASK;
-
-			if (pud_large(*start) || !pud_present(*start))
+			if (pud_large(*start) || !pud_present(*start)) {
+				prot = pud_flags(*start);
 				note_page(m, st, __pgprot(prot), 2);
-			else
+			} else {
 				walk_pmd_level(m, st, *start,
 					       P + i * PUD_LEVEL_MULT);
+			}
 		} else
 			note_page(m, st, __pgprot(0), 2);
 
@@ -351,6 +353,7 @@ void ptdump_walk_pgd_level(struct seq_file *m, pgd_t *pgd)
 #else
 	pgd_t *start = swapper_pg_dir;
 #endif
+	pgprotval_t prot;
 	int i;
 	struct pg_state st = {};
 
@@ -362,13 +365,13 @@ void ptdump_walk_pgd_level(struct seq_file *m, pgd_t *pgd)
 	for (i = 0; i < PTRS_PER_PGD; i++) {
 		st.current_address = normalize_addr(i * PGD_LEVEL_MULT);
 		if (!pgd_none(*start)) {
-			pgprotval_t prot = pgd_val(*start) & PTE_FLAGS_MASK;
-
-			if (pgd_large(*start) || !pgd_present(*start))
+			if (pgd_large(*start) || !pgd_present(*start)) {
+				prot = pgd_flags(*start);
 				note_page(m, &st, __pgprot(prot), 1);
-			else
+			} else {
 				walk_pud_level(m, &st, *start,
 					       i * PGD_LEVEL_MULT);
+			}
 		} else
 			note_page(m, &st, __pgprot(0), 1);
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
