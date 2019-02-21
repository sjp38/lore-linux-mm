Return-Path: <SRS0=vS5V=Q4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 33940C4360F
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 11:36:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E35CF214AF
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 11:36:10 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E35CF214AF
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 87A298E0080; Thu, 21 Feb 2019 06:36:08 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 828B48E0075; Thu, 21 Feb 2019 06:36:08 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6A5878E0080; Thu, 21 Feb 2019 06:36:08 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 052D18E0075
	for <linux-mm@kvack.org>; Thu, 21 Feb 2019 06:36:08 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id i22so5632237eds.20
        for <linux-mm@kvack.org>; Thu, 21 Feb 2019 03:36:07 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=NqO2orxBM0NrjJiuXU9Xz8In8V4AR0Skp7YUe6D+Fac=;
        b=b6iNGPka82tcUu11K7FW3eXf6R/uVmK3rj4I74Skq8DzobZhGtwGMyewYfouI0VaBs
         GOHV1UhS3YiztK+Bxfdho2YVURrhOys4hguQFZzQ1AECA/A14Uh2px0DpbY9lej8c55P
         5S/HItc+VdRTNcoQw51NWtkFJWan7u18PB67cOlkHM9R1ueah7fRmgPEdjBNx0++TVE/
         6VDpZD58gRCfvCM1SxG2pn/iTMZEfLiNMW/3f+TG+22awQz8FdYLw5svaw45MT0RqE13
         Y+ALSXzAumNMNhCs2frau7YIlbWALDXxqVyqcvySBYzweEjzy0jj75gw7wwn8vzrmGwP
         43MQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: AHQUAubKzbD9UxNyM/kJHz9RysPrCtYdCk0ykxnCCzVg4hWrJlQZzUZE
	jPN/0H0PgiaN8n7n+3+Ai1eavnD1c3v03g29YxJ+Ve4AGsaPBb1QMpmyfoLELv0muzirfpCM1AJ
	oOnrPn757wXm7YxwiKhlLBvqfqKI12tNQYyBWjUL+dmovJ5omg4pQhMTKC/E0ehjIdA==
X-Received: by 2002:a50:ad31:: with SMTP id y46mr30303970edc.97.1550748967479;
        Thu, 21 Feb 2019 03:36:07 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ib6eOJHTLC57IRupXey/AbX4DV0uzr8bWemaCMLddwljP4qqS8w4HB1xn2uaZNbtqi+IqcU
X-Received: by 2002:a50:ad31:: with SMTP id y46mr30303895edc.97.1550748966221;
        Thu, 21 Feb 2019 03:36:06 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550748966; cv=none;
        d=google.com; s=arc-20160816;
        b=ubfLcxpl5zGSc7EGXyeSqPuiRb4zS9Idlj9RJqj6+472JCcKL0mbXYrUBZ4C68xxi1
         T/Cworw5NVwCAYRVMKe5mfqdZYoJdD4o9ovk7eziNOPW1qSMuudjSnR0lZnuNcArqXg1
         1fp1Znkz1sl6zOKTcpABDCD/SuEl90AWs5f6hRb5OTUw+rHZ8ncvG6zlPZ28WtkVixLa
         wgUrUXM9FG5wcjX9bYfYKh2uO65oZJYtf901b43hebxmGeWUIpfCvQqe2W8mkAwHn9Hu
         i3o4F+SynMiGMr4odMNxrrFAIGCfoDSi5t9zflAgF3208tQoQB2TMOlEt/rz1P9l+ov4
         Ad5A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=NqO2orxBM0NrjJiuXU9Xz8In8V4AR0Skp7YUe6D+Fac=;
        b=fiZbK1MStl6F/bxAPOSavJNMFoS907RGdo/NlvpevgQzcaD8Go4493Fax005uqAFyn
         +HlaVJ1q1ZzqasA3LjYQO1sfoKVb6BRJ3aFzvX7Bl2sn0Ya9SeG+SwUiXv4xrMkaDRhF
         QeLUOPNaOssizgWK/y2HZ00xw+HbZARKJhFVGh+cwZ00GqTG9nVw9OHs+qgY2NPavEiE
         CUdlzOGmoFlEhOiHB+ECHUz+44TxllQhLAiHS4fWrpWhGsSRTK1Eyya8EUAEbWjUZPKz
         U/pNvFv+DKymV1qGS4c3UuPBMJm0H9XNdqWVItuxHvd9x4b7JntvXtKMWCsO7Wt+lo5u
         sg1A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id q1si2342314ejz.59.2019.02.21.03.36.05
        for <linux-mm@kvack.org>;
        Thu, 21 Feb 2019 03:36:06 -0800 (PST)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 281A0165C;
	Thu, 21 Feb 2019 03:36:05 -0800 (PST)
Received: from e112269-lin.arm.com (e112269-lin.cambridge.arm.com [10.1.196.69])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 9B3C43F5C1;
	Thu, 21 Feb 2019 03:36:01 -0800 (PST)
From: Steven Price <steven.price@arm.com>
To: linux-mm@kvack.org
Cc: Steven Price <steven.price@arm.com>,
	Andy Lutomirski <luto@kernel.org>,
	Ard Biesheuvel <ard.biesheuvel@linaro.org>,
	Arnd Bergmann <arnd@arndb.de>,
	Borislav Petkov <bp@alien8.de>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Ingo Molnar <mingo@redhat.com>,
	James Morse <james.morse@arm.com>,
	=?UTF-8?q?J=C3=A9r=C3=B4me=20Glisse?= <jglisse@redhat.com>,
	Peter Zijlstra <peterz@infradead.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	Will Deacon <will.deacon@arm.com>,
	x86@kernel.org,
	"H. Peter Anvin" <hpa@zytor.com>,
	linux-arm-kernel@lists.infradead.org,
	linux-kernel@vger.kernel.org,
	Mark Rutland <Mark.Rutland@arm.com>,
	"Liang, Kan" <kan.liang@linux.intel.com>
Subject: [PATCH v2 13/13] x86: mm: Convert dump_pagetables to use walk_page_range
Date: Thu, 21 Feb 2019 11:35:02 +0000
Message-Id: <20190221113502.54153-14-steven.price@arm.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190221113502.54153-1-steven.price@arm.com>
References: <20190221113502.54153-1-steven.price@arm.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Make use of the new functionality in walk_page_range to remove the
arch page walking code and use the generic code to walk the page tables.

The effective permissions are passed down the chain using new fields
in struct pg_state.

The KASAN optimisation is implemented by including test_p?d callbacks
which can decide to skip an entire tree of entries

Signed-off-by: Steven Price <steven.price@arm.com>
---
 arch/x86/mm/dump_pagetables.c | 282 ++++++++++++++++++----------------
 1 file changed, 146 insertions(+), 136 deletions(-)

diff --git a/arch/x86/mm/dump_pagetables.c b/arch/x86/mm/dump_pagetables.c
index 0953bf44d792..64d1619493a4 100644
--- a/arch/x86/mm/dump_pagetables.c
+++ b/arch/x86/mm/dump_pagetables.c
@@ -33,6 +33,10 @@ struct pg_state {
 	int level;
 	pgprot_t current_prot;
 	pgprotval_t effective_prot;
+	pgprotval_t effective_prot_pgd;
+	pgprotval_t effective_prot_p4d;
+	pgprotval_t effective_prot_pud;
+	pgprotval_t effective_prot_pmd;
 	unsigned long start_address;
 	unsigned long current_address;
 	const struct addr_marker *marker;
@@ -355,22 +359,21 @@ static inline pgprotval_t effective_prot(pgprotval_t prot1, pgprotval_t prot2)
 	       ((prot1 | prot2) & _PAGE_NX);
 }
 
-static void walk_pte_level(struct pg_state *st, pmd_t addr, pgprotval_t eff_in,
-			   unsigned long P)
+static int ptdump_pte_entry(pte_t *pte, unsigned long addr,
+			    unsigned long next, struct mm_walk *walk)
 {
-	int i;
-	pte_t *pte;
-	pgprotval_t prot, eff;
-
-	for (i = 0; i < PTRS_PER_PTE; i++) {
-		st->current_address = normalize_addr(P + i * PTE_LEVEL_MULT);
-		pte = pte_offset_map(&addr, st->current_address);
-		prot = pte_flags(*pte);
-		eff = effective_prot(eff_in, prot);
-		note_page(st, __pgprot(prot), eff, 5);
-		pte_unmap(pte);
-	}
+	struct pg_state *st = walk->private;
+	pgprotval_t eff, prot;
+
+	st->current_address = normalize_addr(addr);
+
+	prot = pte_flags(*pte);
+	eff = effective_prot(st->effective_prot_pmd, prot);
+	note_page(st, __pgprot(prot), eff, 5);
+
+	return 0;
 }
+
 #ifdef CONFIG_KASAN
 
 /*
@@ -399,133 +402,152 @@ static inline bool kasan_page_table(struct pg_state *st, void *pt)
 }
 #endif
 
-#if PTRS_PER_PMD > 1
-
-static void walk_pmd_level(struct pg_state *st, pud_t addr,
-			   pgprotval_t eff_in, unsigned long P)
+static int ptdump_test_pmd(unsigned long addr, unsigned long next,
+			   pmd_t *pmd, struct mm_walk *walk)
 {
-	int i;
-	pmd_t *start, *pmd_start;
-	pgprotval_t prot, eff;
-
-	pmd_start = start = (pmd_t *)pud_page_vaddr(addr);
-	for (i = 0; i < PTRS_PER_PMD; i++) {
-		st->current_address = normalize_addr(P + i * PMD_LEVEL_MULT);
-		if (!pmd_none(*start)) {
-			prot = pmd_flags(*start);
-			eff = effective_prot(eff_in, prot);
-			if (pmd_large(*start) || !pmd_present(*start)) {
-				note_page(st, __pgprot(prot), eff, 4);
-			} else if (!kasan_page_table(st, pmd_start)) {
-				walk_pte_level(st, *start, eff,
-					       P + i * PMD_LEVEL_MULT);
-			}
-		} else
-			note_page(st, __pgprot(0), 0, 4);
-		start++;
-	}
+	struct pg_state *st = walk->private;
+
+	st->current_address = normalize_addr(addr);
+
+	if (kasan_page_table(st, pmd))
+		return 1;
+	return 0;
 }
 
-#else
-#define walk_pmd_level(s,a,e,p) walk_pte_level(s,__pmd(pud_val(a)),e,p)
-#undef pud_large
-#define pud_large(a) pmd_large(__pmd(pud_val(a)))
-#define pud_none(a)  pmd_none(__pmd(pud_val(a)))
-#endif
+static int ptdump_pmd_entry(pmd_t *pmd, unsigned long addr,
+			    unsigned long next, struct mm_walk *walk)
+{
+	struct pg_state *st = walk->private;
+	pgprotval_t eff, prot;
+
+	prot = pmd_flags(*pmd);
+	eff = effective_prot(st->effective_prot_pud, prot);
+
+	st->current_address = normalize_addr(addr);
+
+	if (pmd_large(*pmd))
+		note_page(st, __pgprot(prot), eff, 4);
 
-#if PTRS_PER_PUD > 1
+	st->effective_prot_pmd = eff;
 
-static void walk_pud_level(struct pg_state *st, p4d_t addr, pgprotval_t eff_in,
-			   unsigned long P)
+	return 0;
+}
+
+static int ptdump_test_pud(unsigned long addr, unsigned long next,
+			   pud_t *pud, struct mm_walk *walk)
 {
-	int i;
-	pud_t *start, *pud_start;
-	pgprotval_t prot, eff;
-	pud_t *prev_pud = NULL;
-
-	pud_start = start = (pud_t *)p4d_page_vaddr(addr);
-
-	for (i = 0; i < PTRS_PER_PUD; i++) {
-		st->current_address = normalize_addr(P + i * PUD_LEVEL_MULT);
-		if (!pud_none(*start)) {
-			prot = pud_flags(*start);
-			eff = effective_prot(eff_in, prot);
-			if (pud_large(*start) || !pud_present(*start)) {
-				note_page(st, __pgprot(prot), eff, 3);
-			} else if (!kasan_page_table(st, pud_start)) {
-				walk_pmd_level(st, *start, eff,
-					       P + i * PUD_LEVEL_MULT);
-			}
-		} else
-			note_page(st, __pgprot(0), 0, 3);
+	struct pg_state *st = walk->private;
 
-		prev_pud = start;
-		start++;
-	}
+	st->current_address = normalize_addr(addr);
+
+	if (kasan_page_table(st, pud))
+		return 1;
+	return 0;
 }
 
-#else
-#define walk_pud_level(s,a,e,p) walk_pmd_level(s,__pud(p4d_val(a)),e,p)
-#undef p4d_large
-#define p4d_large(a) pud_large(__pud(p4d_val(a)))
-#define p4d_none(a)  pud_none(__pud(p4d_val(a)))
-#endif
+static int ptdump_pud_entry(pud_t *pud, unsigned long addr,
+			    unsigned long next, struct mm_walk *walk)
+{
+	struct pg_state *st = walk->private;
+	pgprotval_t eff, prot;
+
+	prot = pud_flags(*pud);
+	eff = effective_prot(st->effective_prot_p4d, prot);
+
+	st->current_address = normalize_addr(addr);
+
+	if (pud_large(*pud))
+		note_page(st, __pgprot(prot), eff, 3);
+
+	st->effective_prot_pud = eff;
 
-static void walk_p4d_level(struct pg_state *st, pgd_t addr, pgprotval_t eff_in,
-			   unsigned long P)
+	return 0;
+}
+
+static int ptdump_test_p4d(unsigned long addr, unsigned long next,
+			   p4d_t *p4d, struct mm_walk *walk)
 {
-	int i;
-	p4d_t *start, *p4d_start;
-	pgprotval_t prot, eff;
-
-	if (PTRS_PER_P4D == 1)
-		return walk_pud_level(st, __p4d(pgd_val(addr)), eff_in, P);
-
-	p4d_start = start = (p4d_t *)pgd_page_vaddr(addr);
-
-	for (i = 0; i < PTRS_PER_P4D; i++) {
-		st->current_address = normalize_addr(P + i * P4D_LEVEL_MULT);
-		if (!p4d_none(*start)) {
-			prot = p4d_flags(*start);
-			eff = effective_prot(eff_in, prot);
-			if (p4d_large(*start) || !p4d_present(*start)) {
-				note_page(st, __pgprot(prot), eff, 2);
-			} else if (!kasan_page_table(st, p4d_start)) {
-				walk_pud_level(st, *start, eff,
-					       P + i * P4D_LEVEL_MULT);
-			}
-		} else
-			note_page(st, __pgprot(0), 0, 2);
+	struct pg_state *st = walk->private;
 
-		start++;
-	}
+	st->current_address = normalize_addr(addr);
+
+	if (kasan_page_table(st, p4d))
+		return 1;
+	return 0;
 }
 
-#undef pgd_large
-#define pgd_large(a) (pgtable_l5_enabled() ? pgd_large(a) : p4d_large(__p4d(pgd_val(a))))
-#define pgd_none(a)  (pgtable_l5_enabled() ? pgd_none(a) : p4d_none(__p4d(pgd_val(a))))
+static int ptdump_p4d_entry(p4d_t *p4d, unsigned long addr,
+			    unsigned long next, struct mm_walk *walk)
+{
+	struct pg_state *st = walk->private;
+	pgprotval_t eff, prot;
+
+	prot = p4d_flags(*p4d);
+	eff = effective_prot(st->effective_prot_pgd, prot);
+
+	st->current_address = normalize_addr(addr);
+
+	if (p4d_large(*p4d))
+		note_page(st, __pgprot(prot), eff, 2);
+
+	st->effective_prot_p4d = eff;
+
+	return 0;
+}
 
-static inline bool is_hypervisor_range(int idx)
+static int ptdump_pgd_entry(pgd_t *pgd, unsigned long addr,
+			    unsigned long next, struct mm_walk *walk)
 {
-#ifdef CONFIG_X86_64
-	/*
-	 * A hole in the beginning of kernel address space reserved
-	 * for a hypervisor.
-	 */
-	return	(idx >= pgd_index(GUARD_HOLE_BASE_ADDR)) &&
-		(idx <  pgd_index(GUARD_HOLE_END_ADDR));
+	struct pg_state *st = walk->private;
+	pgprotval_t eff, prot;
+
+	prot = pgd_flags(*pgd);
+
+#ifdef CONFIG_X86_PAE
+	eff = _PAGE_USER | _PAGE_RW;
 #else
-	return false;
+	eff = prot;
 #endif
+
+	st->current_address = normalize_addr(addr);
+
+	if (pgd_large(*pgd))
+		note_page(st, __pgprot(prot), eff, 1);
+
+	st->effective_prot_pgd = eff;
+
+	return 0;
+}
+
+static int ptdump_hole(unsigned long addr, unsigned long next, int depth,
+		       struct mm_walk *walk)
+{
+	struct pg_state *st = walk->private;
+
+	st->current_address = normalize_addr(addr);
+
+	note_page(st, __pgprot(0), 0, depth + 1);
+
+	return 0;
 }
 
 static void ptdump_walk_pgd_level_core(struct seq_file *m, struct mm_struct *mm,
 				       bool checkwx, bool dmesg)
 {
-	pgd_t *start = mm->pgd;
-	pgprotval_t prot, eff;
-	int i;
 	struct pg_state st = {};
+	struct mm_walk walk = {
+		.mm		= mm,
+		.pgd_entry	= ptdump_pgd_entry,
+		.p4d_entry	= ptdump_p4d_entry,
+		.pud_entry	= ptdump_pud_entry,
+		.pmd_entry	= ptdump_pmd_entry,
+		.pte_entry	= ptdump_pte_entry,
+		.test_p4d	= ptdump_test_p4d,
+		.test_pud	= ptdump_test_pud,
+		.test_pmd	= ptdump_test_pmd,
+		.pte_hole	= ptdump_hole,
+		.private	= &st
+	};
 
 	st.to_dmesg = dmesg;
 	st.check_wx = checkwx;
@@ -533,27 +555,15 @@ static void ptdump_walk_pgd_level_core(struct seq_file *m, struct mm_struct *mm,
 	if (checkwx)
 		st.wx_pages = 0;
 
-	for (i = 0; i < PTRS_PER_PGD; i++) {
-		st.current_address = normalize_addr(i * PGD_LEVEL_MULT);
-		if (!pgd_none(*start) && !is_hypervisor_range(i)) {
-			prot = pgd_flags(*start);
-#ifdef CONFIG_X86_PAE
-			eff = _PAGE_USER | _PAGE_RW;
+	down_read(&mm->mmap_sem);
+#ifdef CONFIG_X86_64
+	walk_page_range(0, PTRS_PER_PGD*PGD_LEVEL_MULT/2, &walk);
+	walk_page_range(normalize_addr(PTRS_PER_PGD*PGD_LEVEL_MULT/2), ~0,
+			&walk);
 #else
-			eff = prot;
+	walk_page_range(0, ~0, &walk);
 #endif
-			if (pgd_large(*start) || !pgd_present(*start)) {
-				note_page(&st, __pgprot(prot), eff, 1);
-			} else {
-				walk_p4d_level(&st, *start, eff,
-					       i * PGD_LEVEL_MULT);
-			}
-		} else
-			note_page(&st, __pgprot(0), 0, 1);
-
-		cond_resched();
-		start++;
-	}
+	up_read(&mm->mmap_sem);
 
 	/* Flush out the last page */
 	st.current_address = normalize_addr(PTRS_PER_PGD*PGD_LEVEL_MULT);
-- 
2.20.1

