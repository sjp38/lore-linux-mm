Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 79DD06B0497
	for <linux-mm@kvack.org>; Sun, 16 Jul 2017 19:00:03 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id d193so92569876pgc.0
        for <linux-mm@kvack.org>; Sun, 16 Jul 2017 16:00:03 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id d90si10055102pld.635.2017.07.16.16.00.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 16 Jul 2017 16:00:02 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 2/8] x86/dump_pagetables: Fix printout of p4d level
Date: Mon, 17 Jul 2017 01:59:48 +0300
Message-Id: <20170716225954.74185-3-kirill.shutemov@linux.intel.com>
In-Reply-To: <20170716225954.74185-1-kirill.shutemov@linux.intel.com>
References: <20170716225954.74185-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Modify printk_prot() and callers to print out additional page table
level correctly.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 arch/x86/mm/dump_pagetables.c | 18 +++++++++---------
 1 file changed, 9 insertions(+), 9 deletions(-)

diff --git a/arch/x86/mm/dump_pagetables.c b/arch/x86/mm/dump_pagetables.c
index a824d575bb84..b371ab68f2d4 100644
--- a/arch/x86/mm/dump_pagetables.c
+++ b/arch/x86/mm/dump_pagetables.c
@@ -138,7 +138,7 @@ static void printk_prot(struct seq_file *m, pgprot_t prot, int level, bool dmsg)
 {
 	pgprotval_t pr = pgprot_val(prot);
 	static const char * const level_name[] =
-		{ "cr3", "pgd", "pud", "pmd", "pte" };
+		{ "cr3", "pgd", "p4d", "pud", "pmd", "pte" };
 
 	if (!pgprot_val(prot)) {
 		/* Not present */
@@ -162,12 +162,12 @@ static void printk_prot(struct seq_file *m, pgprot_t prot, int level, bool dmsg)
 			pt_dump_cont_printf(m, dmsg, "    ");
 
 		/* Bit 7 has a different meaning on level 3 vs 4 */
-		if (level <= 3 && pr & _PAGE_PSE)
+		if (level <= 4 && pr & _PAGE_PSE)
 			pt_dump_cont_printf(m, dmsg, "PSE ");
 		else
 			pt_dump_cont_printf(m, dmsg, "    ");
-		if ((level == 4 && pr & _PAGE_PAT) ||
-		    ((level == 3 || level == 2) && pr & _PAGE_PAT_LARGE))
+		if ((level == 5 && pr & _PAGE_PAT) ||
+		    ((level == 4 || level == 3) && pr & _PAGE_PAT_LARGE))
 			pt_dump_cont_printf(m, dmsg, "PAT ");
 		else
 			pt_dump_cont_printf(m, dmsg, "    ");
@@ -298,7 +298,7 @@ static void walk_pte_level(struct seq_file *m, struct pg_state *st, pmd_t addr,
 	for (i = 0; i < PTRS_PER_PTE; i++) {
 		prot = pte_flags(*start);
 		st->current_address = normalize_addr(P + i * PTE_LEVEL_MULT);
-		note_page(m, st, __pgprot(prot), 4);
+		note_page(m, st, __pgprot(prot), 5);
 		start++;
 	}
 }
@@ -317,13 +317,13 @@ static void walk_pmd_level(struct seq_file *m, struct pg_state *st, pud_t addr,
 		if (!pmd_none(*start)) {
 			if (pmd_large(*start) || !pmd_present(*start)) {
 				prot = pmd_flags(*start);
-				note_page(m, st, __pgprot(prot), 3);
+				note_page(m, st, __pgprot(prot), 4);
 			} else {
 				walk_pte_level(m, st, *start,
 					       P + i * PMD_LEVEL_MULT);
 			}
 		} else
-			note_page(m, st, __pgprot(0), 3);
+			note_page(m, st, __pgprot(0), 4);
 		start++;
 	}
 }
@@ -362,13 +362,13 @@ static void walk_pud_level(struct seq_file *m, struct pg_state *st, p4d_t addr,
 		    !pud_already_checked(prev_pud, start, st->check_wx)) {
 			if (pud_large(*start) || !pud_present(*start)) {
 				prot = pud_flags(*start);
-				note_page(m, st, __pgprot(prot), 2);
+				note_page(m, st, __pgprot(prot), 3);
 			} else {
 				walk_pmd_level(m, st, *start,
 					       P + i * PUD_LEVEL_MULT);
 			}
 		} else
-			note_page(m, st, __pgprot(0), 2);
+			note_page(m, st, __pgprot(0), 3);
 
 		prev_pud = start;
 		start++;
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
