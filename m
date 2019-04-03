Return-Path: <SRS0=DmM3=SF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9082EC4360F
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 14:18:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3ED092084C
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 14:18:32 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3ED092084C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DFDBB6B0282; Wed,  3 Apr 2019 10:18:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D878C6B0283; Wed,  3 Apr 2019 10:18:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C9B7E6B0284; Wed,  3 Apr 2019 10:18:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 77A216B0282
	for <linux-mm@kvack.org>; Wed,  3 Apr 2019 10:18:31 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id f2so7635328edv.15
        for <linux-mm@kvack.org>; Wed, 03 Apr 2019 07:18:31 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=kX4dLJraJo092n4y125DLKk3n4IU7HsLifEATF3quag=;
        b=nSV1uAeNc3vLGxr+7uG4wF4dDDgntR8Jj5SFah6vrSDgffFOj3IKB4RP5MjoRBWtDJ
         NypckRb77CjBqivkb+aYGtchnclabwT+jyfDxNF+jNViMylhBK3IVSLagmT1WKBTS2ZI
         +YyUcR+HLsIY6ZocgAatEbWFzuwL79jfnOa/ACl2S1xmFa88F5/Oj/w2Vbm8r9ocibiM
         wcAILokq4OVCswfrA3pedMiO3rCYu4zJ6b469mQnqnouCEOEmE/hXD46IbfOb4CSa/7x
         xwRsvrgei4z6v0QWXv6lLsC4BL/VSdXn3xgSo4k+X0UO98jrOsmPh9NiT9nZ1QpWgyHA
         oYbg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: APjAAAWYvCVeaOWxwGQPTBbbdBHiC65FQcNRcaFDgV+mA2nOBkqt/OZL
	oAD6Om7OKl335Mj1eUnl+XKWsCv/6pcoMtR6wgTVR3tutcpFJcA6kvNp10V6taynXKj4aBWsHHK
	tu/cLaKGzAGi6tZq8d/xu2AnhPdMfyI/cg+qgzsAmLspV3jnsGTilkpM3tmZ54gXUdA==
X-Received: by 2002:a17:906:31cf:: with SMTP id f15mr40010681ejf.246.1554301110961;
        Wed, 03 Apr 2019 07:18:30 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzpboJh7wfl89AtEw4eVBcaUPhLf+E+UGK7fdPIlVAcqGSmfkx/PDTmxd0GtmQTrj4Um48N
X-Received: by 2002:a17:906:31cf:: with SMTP id f15mr40010601ejf.246.1554301109229;
        Wed, 03 Apr 2019 07:18:29 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554301109; cv=none;
        d=google.com; s=arc-20160816;
        b=aehmAjdFQvqnTyScsxq1q+s1Gg0/Tq6YdiinmIgWQfH2e/2wicLR8UNWCQFFmaPfz+
         YJyX5clMLXCwe3moe/pri/wbXXeGlBrQe3Oc4L46YSAHFxoxAe1hQ15Ws/a7y2apBtnx
         dS9x2N4mCRgd7GF0sT7LHx8zB7a8eMpIRX3GlPNKQbAU1LfI2BB9bjdFBxVuiqX6lCVX
         /9iJjVGwldw8DO+8QjsjCzePMn5ha5L3YjbK4EmjTWxaS11Ug342iUeQYOd2vikEszEf
         YoRCHawMQC0qh2u+ZNyrT2+PfLOUgMMZ70uDlvCGkmiiJayWhuyjAMu7LuvndYOGlXYv
         KicQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=kX4dLJraJo092n4y125DLKk3n4IU7HsLifEATF3quag=;
        b=jg7fRhMEdObJIw6w2yRXekIpcW/vuDCKWc1wVzNp6ad+XoWD5f7TAjNXl8x00MdR/5
         dLxodmmKxqYpjqXmOM7nZOlh+rfQo5IjqQCJugbTzojy1ynjoHDd8hIr7sEhX/80KOkE
         JIJ/maoSJRrcKM6jCmWYLL+meaKOe0A6kwo4t2QM5HSujqf/BIU5QqhzKwiYYT1PxGnc
         tpXoJGZPoboWzTpAVAGiY8U6mly0Lf+HyqX2pL+oRbIIbWVO6OxT7lA12c3kf/GL2/6d
         tuO+mCwBXAJE6BAHnF+0Ex/9i3tmq9aWsqltT6gSBqgcmDho48NAUqy4BSYiwYrHIqeX
         UKRA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id e1si2162944edy.366.2019.04.03.07.18.28
        for <linux-mm@kvack.org>;
        Wed, 03 Apr 2019 07:18:29 -0700 (PDT)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 3968D169E;
	Wed,  3 Apr 2019 07:18:28 -0700 (PDT)
Received: from e112269-lin.arm.com (e112269-lin.cambridge.arm.com [10.1.196.69])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id CF37D3F68F;
	Wed,  3 Apr 2019 07:18:24 -0700 (PDT)
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
	"Liang, Kan" <kan.liang@linux.intel.com>,
	Andrew Morton <akpm@linux-foundation.org>
Subject: [PATCH v8 20/20] x86: mm: Convert dump_pagetables to use walk_page_range
Date: Wed,  3 Apr 2019 15:16:27 +0100
Message-Id: <20190403141627.11664-21-steven.price@arm.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190403141627.11664-1-steven.price@arm.com>
References: <20190403141627.11664-1-steven.price@arm.com>
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
 arch/x86/mm/dump_pagetables.c | 280 ++++++++++++++++++----------------
 1 file changed, 146 insertions(+), 134 deletions(-)

diff --git a/arch/x86/mm/dump_pagetables.c b/arch/x86/mm/dump_pagetables.c
index c0fbb9e5a790..f6b814aaddf7 100644
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
@@ -400,131 +403,152 @@ static inline bool kasan_page_table(struct pg_state *st, void *pt)
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
@@ -532,27 +556,15 @@ static void ptdump_walk_pgd_level_core(struct seq_file *m, struct mm_struct *mm,
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

