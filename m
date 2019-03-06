Return-Path: <SRS0=43/C=RJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9E82EC43381
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 15:52:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 504FC20663
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 15:52:21 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 504FC20663
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 424098E001E; Wed,  6 Mar 2019 10:51:59 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3ACF58E0015; Wed,  6 Mar 2019 10:51:59 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 24F8D8E001E; Wed,  6 Mar 2019 10:51:59 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id B27E38E0015
	for <linux-mm@kvack.org>; Wed,  6 Mar 2019 10:51:58 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id f2so6457863edm.18
        for <linux-mm@kvack.org>; Wed, 06 Mar 2019 07:51:58 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=vb4bmP8Fo2cBijSAZJ9Hj0yAo2JYFPjw5BmoHVJKNV8=;
        b=ZRYD6gpq9ZqQ9tgFa4N3qxgeybJ294eR3yNkn8Owmtj3zMAUHL+8v0suPXLtV7ObCD
         yVL3AfxNumAL7t45hfwbtEQo0MaO1wrtRX+e1aH59ienlqLu5aIt2L8PZJu2yyS3+VB6
         03OLIRD9vR7WR2cbjYdsQSSgREualC4l0p68ZMFH+3RkDL8KA0zi6V6IMI0dSVVUhkE2
         mJKxEKROSnoDd0UskwTmIdQ3jKSOuml8HQKqg2J9xPH+tBNTapoCuqVEpnWI7ThoSfhG
         D/oppdePUgaQWqlbQGfYufYgvZqwUVL0YlbZojgj9DEChx4pBNNIep5+GexOpenZmZja
         vEjw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: APjAAAVw+SrnJiM29mNmQuLimML+RcFJXouaTwDGw9fOn55em2cG/qEK
	U+0T/BE8YUlTZ0I+E5tmQ2JyNlLvOduieKqXXeRNpyBqzuDzo30NdBK57h8K+me6waJvLmatPsC
	iRv1479aKsGq0kwxhbhAF/3LCKUUQP/JuV/EMaWp34xczVDgon4fuGsLmDMjtK1scbA==
X-Received: by 2002:a50:ae63:: with SMTP id c90mr23726444edd.285.1551887517904;
        Wed, 06 Mar 2019 07:51:57 -0800 (PST)
X-Google-Smtp-Source: APXvYqz3SVxqM8KbsTV9tWx5Vtdeum38npToFdiahx+XCMbCAH6tiDAXlOrF1Y/Pf2a8lKjwR7Ud
X-Received: by 2002:a50:ae63:: with SMTP id c90mr23726364edd.285.1551887516469;
        Wed, 06 Mar 2019 07:51:56 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551887516; cv=none;
        d=google.com; s=arc-20160816;
        b=JhC/ZWfaC+Ug8/OhZJV97fC3nucEiWLmnGlCSLv0mInJaZT/kUBqKsUeAlD7YVbTfk
         HbFEpAbffKHfC/zonQokT54eLegtXX+uasd+A8K5KzKu6stWw+O3OTDDtYriIjOPyIwu
         93OzMb9vhUbee+uB+JpnDRo5xAki5Qo9DhZWd3ueEkhUW8ehggIkivabyWsgwlZlGvQ+
         XyylP+esAKzRdrKvFG6EZBbeSF4CFqog6dYmfsRcgi8UMU2lsVlVtckeqC5l3NR2q4Wf
         IAxmDiAvOKsrwGTUO/T3eRPdrYyN3nwr7jIKrX46H+qTt+4LX5vXcnhWo+95v9K9CgWL
         OVjg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=vb4bmP8Fo2cBijSAZJ9Hj0yAo2JYFPjw5BmoHVJKNV8=;
        b=JRLBP+Hj/TMSHlPxQpyS02NYoKVJLR4+YeO9Idzn+vVR95EibOlwD409ruJXMpjEoh
         s9pAmjyOXip5bfd7o5YNguPgpGeatn9vcmk9em+LKxkyEk9gCGnTNCNw8iupuT5ZAfh8
         yJ8GBD7Q2S3bF2vNGU5ahLma6lZ/fARTc16ipxpmzFKJepjl2bjkboJqfmh+ZE1TS9JS
         8NZfM6N4QB/q76WekV/gaQMOHcB0TppzVKEnFRrkeuT2+Xl8haucxdy93cf/wQS+3d2h
         b26QBT+G2LkpNs0l2CqI/zsMafAVDhUzYCkG5ttupNoQZ4XgdTY/7bCB2OhnGBrdClc5
         xZ2g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id z5si725710ejp.73.2019.03.06.07.51.55
        for <linux-mm@kvack.org>;
        Wed, 06 Mar 2019 07:51:56 -0800 (PST)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 3FC02165C;
	Wed,  6 Mar 2019 07:51:55 -0800 (PST)
Received: from e112269-lin.arm.com (e112269-lin.cambridge.arm.com [10.1.196.69])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 04C0D3F703;
	Wed,  6 Mar 2019 07:51:51 -0800 (PST)
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
Subject: [PATCH v4 19/19] x86: mm: Convert dump_pagetables to use walk_page_range
Date: Wed,  6 Mar 2019 15:50:31 +0000
Message-Id: <20190306155031.4291-20-steven.price@arm.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190306155031.4291-1-steven.price@arm.com>
References: <20190306155031.4291-1-steven.price@arm.com>
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
index b1c04ecc18cc..f6b814aaddf7 100644
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
@@ -356,22 +360,21 @@ static inline pgprotval_t effective_prot(pgprotval_t prot1, pgprotval_t prot2)
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
@@ -400,133 +403,152 @@ static inline bool kasan_page_table(struct pg_state *st, void *pt)
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
+static int ptdump_hole(unsigned long addr, unsigned long next,
+		       struct mm_walk *walk)
+{
+	struct pg_state *st = walk->private;
+
+	st->current_address = normalize_addr(addr);
+
+	note_page(st, __pgprot(0), 0, -1);
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
@@ -534,27 +556,15 @@ static void ptdump_walk_pgd_level_core(struct seq_file *m, struct mm_struct *mm,
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

