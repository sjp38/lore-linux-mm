Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id A05C56B051C
	for <linux-mm@kvack.org>; Tue, 11 Jul 2017 15:06:01 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id 13so1330329pgg.8
        for <linux-mm@kvack.org>; Tue, 11 Jul 2017 12:06:01 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id v19si73205pgo.347.2017.07.11.12.06.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 11 Jul 2017 12:06:00 -0700 (PDT)
Date: Tue, 11 Jul 2017 22:05:54 +0300
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: KASAN vs. boot-time switching between 4- and 5-level paging
Message-ID: <20170711190554.zxkpjeg2bt65wtir@black.fi.intel.com>
References: <20170710184704.realchrhzpblqqlk@node.shutemov.name>
 <CALCETrVJQ_u-agPm8fFHAW1UJY=VLowdbM+gXyjFCb586r0V3g@mail.gmail.com>
 <20170710212403.7ycczkhhki3vrgac@node.shutemov.name>
 <CALCETrW6pWzpdf1MVx_ytaYYuVGBsF7R+JowEsKqd3i=vCwJ_w@mail.gmail.com>
 <20170711103548.mkv5w7dd5gpdenne@node.shutemov.name>
 <CALCETrVpNUq3-zEu1Q1O77N8r4kv4kFdefXp7XEs3Hpf-JPAjg@mail.gmail.com>
 <d3caf8c4-4575-c1b5-6b0f-95527efaf2f9@virtuozzo.com>
 <f11d9e07-6b31-1add-7677-6a29d15ab608@virtuozzo.com>
 <20170711170332.wlaudicepkg35dmm@node.shutemov.name>
 <e9a395f4-018e-4c8c-2098-170172e438f3@virtuozzo.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <e9a395f4-018e-4c8c-2098-170172e438f3@virtuozzo.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, Andy Lutomirski <luto@kernel.org>, Dmitry Vyukov <dvyukov@google.com>, Alexander Potapenko <glider@google.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, "x86@kernel.org" <x86@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Andi Kleen <ak@linux.intel.com>, Dave Hansen <dave.hansen@intel.com>, linux-arch <linux-arch@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, kasan-dev <kasan-dev@googlegroups.com>

> > Can use your Signed-off-by for a [cleaned up version of your] patch?
> 
> Sure.

Another KASAN-releated issue: dumping page tables for KASAN shadow memory
region takes unreasonable time due to kasan_zero_p?? mapped there.

The patch below helps. Any objections?

diff --git a/arch/x86/mm/dump_pagetables.c b/arch/x86/mm/dump_pagetables.c
index b371ab68f2d4..8601153c34e7 100644
--- a/arch/x86/mm/dump_pagetables.c
+++ b/arch/x86/mm/dump_pagetables.c
@@ -17,8 +17,8 @@
 #include <linux/init.h>
 #include <linux/sched.h>
 #include <linux/seq_file.h>
+#include <linux/kasan.h>
 
-#include <asm/kasan.h>
 #include <asm/pgtable.h>
 
 /*
@@ -291,10 +291,15 @@ static void note_page(struct seq_file *m, struct pg_state *st,
 static void walk_pte_level(struct seq_file *m, struct pg_state *st, pmd_t addr, unsigned long P)
 {
 	int i;
+	unsigned long pte_addr;
 	pte_t *start;
 	pgprotval_t prot;
 
-	start = (pte_t *)pmd_page_vaddr(addr);
+	pte_addr = pmd_page_vaddr(addr);
+	if (__pa(pte_addr) == __pa(kasan_zero_pte))
+		return;
+
+	start = (pte_t *)pte_addr;
 	for (i = 0; i < PTRS_PER_PTE; i++) {
 		prot = pte_flags(*start);
 		st->current_address = normalize_addr(P + i * PTE_LEVEL_MULT);
@@ -308,10 +313,15 @@ static void walk_pte_level(struct seq_file *m, struct pg_state *st, pmd_t addr,
 static void walk_pmd_level(struct seq_file *m, struct pg_state *st, pud_t addr, unsigned long P)
 {
 	int i;
+	unsigned long pmd_addr;
 	pmd_t *start;
 	pgprotval_t prot;
 
-	start = (pmd_t *)pud_page_vaddr(addr);
+	pmd_addr = pud_page_vaddr(addr);
+	if (__pa(pmd_addr) == __pa(kasan_zero_pmd))
+		return;
+
+	start = (pmd_t *)pmd_addr;
 	for (i = 0; i < PTRS_PER_PMD; i++) {
 		st->current_address = normalize_addr(P + i * PMD_LEVEL_MULT);
 		if (!pmd_none(*start)) {
@@ -350,12 +360,16 @@ static bool pud_already_checked(pud_t *prev_pud, pud_t *pud, bool checkwx)
 static void walk_pud_level(struct seq_file *m, struct pg_state *st, p4d_t addr, unsigned long P)
 {
 	int i;
+	unsigned long pud_addr;
 	pud_t *start;
 	pgprotval_t prot;
 	pud_t *prev_pud = NULL;
 
-	start = (pud_t *)p4d_page_vaddr(addr);
+	pud_addr = p4d_page_vaddr(addr);
+	if (__pa(pud_addr) == __pa(kasan_zero_pud))
+		return;
 
+	start = (pud_t *)pud_addr;
 	for (i = 0; i < PTRS_PER_PUD; i++) {
 		st->current_address = normalize_addr(P + i * PUD_LEVEL_MULT);
 		if (!pud_none(*start) &&
@@ -386,11 +400,15 @@ static void walk_pud_level(struct seq_file *m, struct pg_state *st, p4d_t addr,
 static void walk_p4d_level(struct seq_file *m, struct pg_state *st, pgd_t addr, unsigned long P)
 {
 	int i;
+	unsigned long p4d_addr;
 	p4d_t *start;
 	pgprotval_t prot;
 
-	start = (p4d_t *)pgd_page_vaddr(addr);
+	p4d_addr = pgd_page_vaddr(addr);
+	if (__pa(p4d_addr) == __pa(kasan_zero_p4d))
+		return;
 
+	start = (p4d_t *)p4d_addr;
 	for (i = 0; i < PTRS_PER_P4D; i++) {
 		st->current_address = normalize_addr(P + i * P4D_LEVEL_MULT);
 		if (!p4d_none(*start)) {
-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
