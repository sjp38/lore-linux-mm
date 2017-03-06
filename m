Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id C633A6B039D
	for <linux-mm@kvack.org>; Mon,  6 Mar 2017 08:54:23 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id j5so199692541pfb.3
        for <linux-mm@kvack.org>; Mon, 06 Mar 2017 05:54:23 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id z190si5742303pfb.188.2017.03.06.05.54.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Mar 2017 05:54:22 -0800 (PST)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv4 25/33] x86/dump_pagetables: support 5-level paging
Date: Mon,  6 Mar 2017 16:53:49 +0300
Message-Id: <20170306135357.3124-26-kirill.shutemov@linux.intel.com>
In-Reply-To: <20170306135357.3124-1-kirill.shutemov@linux.intel.com>
References: <20170306135357.3124-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, x86@kernel.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Arnd Bergmann <arnd@arndb.de>, "H. Peter Anvin" <hpa@zytor.com>
Cc: Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, Andy Lutomirski <luto@amacapital.net>, linux-arch@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Simple extension to support one more page table level.

Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
---
 arch/x86/mm/dump_pagetables.c | 49 ++++++++++++++++++++++++++++++++++++-------
 1 file changed, 42 insertions(+), 7 deletions(-)

diff --git a/arch/x86/mm/dump_pagetables.c b/arch/x86/mm/dump_pagetables.c
index 58b5bee7ea27..0effac6989cd 100644
--- a/arch/x86/mm/dump_pagetables.c
+++ b/arch/x86/mm/dump_pagetables.c
@@ -110,7 +110,8 @@ static struct addr_marker address_markers[] = {
 #define PTE_LEVEL_MULT (PAGE_SIZE)
 #define PMD_LEVEL_MULT (PTRS_PER_PTE * PTE_LEVEL_MULT)
 #define PUD_LEVEL_MULT (PTRS_PER_PMD * PMD_LEVEL_MULT)
-#define PGD_LEVEL_MULT (PTRS_PER_PUD * PUD_LEVEL_MULT)
+#define P4D_LEVEL_MULT (PTRS_PER_PUD * PUD_LEVEL_MULT)
+#define PGD_LEVEL_MULT (PTRS_PER_PUD * P4D_LEVEL_MULT)
 
 #define pt_dump_seq_printf(m, to_dmesg, fmt, args...)		\
 ({								\
@@ -347,7 +348,7 @@ static bool pud_already_checked(pud_t *prev_pud, pud_t *pud, bool checkwx)
 	return checkwx && prev_pud && (pud_val(*prev_pud) == pud_val(*pud));
 }
 
-static void walk_pud_level(struct seq_file *m, struct pg_state *st, pgd_t addr,
+static void walk_pud_level(struct seq_file *m, struct pg_state *st, p4d_t addr,
 							unsigned long P)
 {
 	int i;
@@ -355,7 +356,7 @@ static void walk_pud_level(struct seq_file *m, struct pg_state *st, pgd_t addr,
 	pgprotval_t prot;
 	pud_t *prev_pud = NULL;
 
-	start = (pud_t *) pgd_page_vaddr(addr);
+	start = (pud_t *) p4d_page_vaddr(addr);
 
 	for (i = 0; i < PTRS_PER_PUD; i++) {
 		st->current_address = normalize_addr(P + i * PUD_LEVEL_MULT);
@@ -377,9 +378,43 @@ static void walk_pud_level(struct seq_file *m, struct pg_state *st, pgd_t addr,
 }
 
 #else
-#define walk_pud_level(m,s,a,p) walk_pmd_level(m,s,__pud(pgd_val(a)),p)
-#define pgd_large(a) pud_large(__pud(pgd_val(a)))
-#define pgd_none(a)  pud_none(__pud(pgd_val(a)))
+#define walk_pud_level(m,s,a,p) walk_pmd_level(m,s,__pud(p4d_val(a)),p)
+#define p4d_large(a) pud_large(__pud(p4d_val(a)))
+#define p4d_none(a)  pud_none(__pud(p4d_val(a)))
+#endif
+
+#if PTRS_PER_P4D > 1
+
+static void walk_p4d_level(struct seq_file *m, struct pg_state *st, pgd_t addr,
+							unsigned long P)
+{
+	int i;
+	p4d_t *start;
+	pgprotval_t prot;
+
+	start = (p4d_t *) pgd_page_vaddr(addr);
+
+	for (i = 0; i < PTRS_PER_P4D; i++) {
+		st->current_address = normalize_addr(P + i * P4D_LEVEL_MULT);
+		if (!p4d_none(*start)) {
+			if (p4d_large(*start) || !p4d_present(*start)) {
+				prot = p4d_flags(*start);
+				note_page(m, st, __pgprot(prot), 2);
+			} else {
+				walk_pud_level(m, st, *start,
+					       P + i * P4D_LEVEL_MULT);
+			}
+		} else
+			note_page(m, st, __pgprot(0), 2);
+
+		start++;
+	}
+}
+
+#else
+#define walk_p4d_level(m,s,a,p) walk_pud_level(m,s,__p4d(pgd_val(a)),p)
+#define pgd_large(a) p4d_large(__p4d(pgd_val(a)))
+#define pgd_none(a)  p4d_none(__p4d(pgd_val(a)))
 #endif
 
 static inline bool is_hypervisor_range(int idx)
@@ -424,7 +459,7 @@ static void ptdump_walk_pgd_level_core(struct seq_file *m, pgd_t *pgd,
 				prot = pgd_flags(*start);
 				note_page(m, &st, __pgprot(prot), 1);
 			} else {
-				walk_pud_level(m, &st, *start,
+				walk_p4d_level(m, &st, *start,
 					       i * PGD_LEVEL_MULT);
 			}
 		} else
-- 
2.11.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
