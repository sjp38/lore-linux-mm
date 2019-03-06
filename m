Return-Path: <SRS0=43/C=RJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 76112C4360F
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 15:52:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 299BA20663
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 15:52:08 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 299BA20663
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 38AE68E001A; Wed,  6 Mar 2019 10:51:45 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1FF9E8E0015; Wed,  6 Mar 2019 10:51:45 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EFABF8E001A; Wed,  6 Mar 2019 10:51:44 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 84A7D8E0015
	for <linux-mm@kvack.org>; Wed,  6 Mar 2019 10:51:44 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id f2so6457534edm.18
        for <linux-mm@kvack.org>; Wed, 06 Mar 2019 07:51:44 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=AkvggREiF8avTQvXMF9m1CKYPzMfajgNOKSO3I/i4V0=;
        b=O7wKvfPT/FnYXE10rCufPa0a7HTgoO18IcSRRHdSqRGGUXqwu9hMi5mhmNnFjlMxpk
         nAHqwpCqA2Guiudfay/02/rPC88pOYWZ8neoN1VLOCMbi1sK7wXyijihL2U5aUfZDdGC
         YgTxWKzjpCx8SshBLg61yi2Z/aw4Z2rN5S2S85uPs3Wd4Mrc0MeXb1Dt3n8PJP6Mc6Ts
         dxqSKsotb0yhLTULKtyz6wb2wuzn0D7Xwh0QzSKnTVoYYVGPt8LKV2NBwa4KX2GmgDaX
         5eBb5G5lNQRoLzcgy7thNyvm2W6yHcA6TtTu9qKqAaL20bwH1+N273KmGi4NHaexRWcA
         uKew==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: APjAAAWT7oBCQKpFfoASJOJxSj7O1umOhn34VHvmsS4ldXoqcUv5k8LQ
	Jy8Jhojst1cPBdMu+sDC90DePA7j3u5zmZA1Mjxu6FbiVCgoT4T5GK7+CzMHv1gVc2p9VJP/QJL
	Ty14IVp3sXj9UB3177L3mr6o1olKLM0jf8gv6bod4+sMH8p65FQr3jCZRNjJ5/5DAxw==
X-Received: by 2002:a05:6402:1817:: with SMTP id g23mr23932839edy.295.1551887503749;
        Wed, 06 Mar 2019 07:51:43 -0800 (PST)
X-Google-Smtp-Source: APXvYqy2cLOeqez8aL4n4ZE43+N87fDI7EktfEAFgR8Yj4ZApSKRycvfGlQItUeA3CEFy/31irWx
X-Received: by 2002:a05:6402:1817:: with SMTP id g23mr23932746edy.295.1551887502233;
        Wed, 06 Mar 2019 07:51:42 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551887502; cv=none;
        d=google.com; s=arc-20160816;
        b=WV8TxeBxn85qeztBOcV/XTYVkHokXARX1EFk7dFuCF5+PZVGFJEspeMxYArw3EK1rv
         kVMDanxYU4isSoPzG+M6VM0uXOg0nLstyH0KMX0/23Is/8MZxIeSZ57ZKJvo+2hLBYva
         Z4t0AvRg+Y+hmlSUNd6BVqpxd3k0XHO6sPMdtxXIxL9NzLStpVfb3TRJQunpBakuPupy
         nP785/lWCqF9ZhFhXDBy9JN8ApYxYm/Tp+WC92D065HgymAe6RQz2qJZJtAw1kOW8sNl
         g2sBJjJppa/zo7BRc02OAgO8uBwIkF6WDZM2ReB+Km8aXMa7oRMhoEbJEVoL8GZ1bpq8
         /8Ug==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=AkvggREiF8avTQvXMF9m1CKYPzMfajgNOKSO3I/i4V0=;
        b=qIOUVLeI+erwJCeaGK3PqzrM7Vt//vUa31MuHjVonekClIMeG8KdhwsIEgQfRSxAhC
         Gd8F5zb/YXr/eXyUIO6safhSBfkBDQ2BMDS7UumOw1IOvihFM6TND58UhMejDqAMwkDs
         jfnKEgeQB+PsBdU8TyuC1yk7c7GwTL703CQcRBzlIfA6ymM+khFWH6ROm17jxK4KTITF
         2YWcioix69VvSDdx6fxxv0DMsi+xNe5+fKeZMB/oZQ7GYgG83l3/F72I/znogQwNs+yf
         0nnAMZkWrB3vA7QN9H62uaaoze4KUsMAT51esLmJQb9POqj0n8X4UqNtmhzPbr2OGoxt
         SpGg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id cw8si729544ejb.176.2019.03.06.07.51.41
        for <linux-mm@kvack.org>;
        Wed, 06 Mar 2019 07:51:42 -0800 (PST)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 3C59C1993;
	Wed,  6 Mar 2019 07:51:41 -0800 (PST)
Received: from e112269-lin.arm.com (e112269-lin.cambridge.arm.com [10.1.196.69])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id D20823F703;
	Wed,  6 Mar 2019 07:51:37 -0800 (PST)
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
Subject: [PATCH v4 15/19] x86: mm: Point to struct seq_file from struct pg_state
Date: Wed,  6 Mar 2019 15:50:27 +0000
Message-Id: <20190306155031.4291-16-steven.price@arm.com>
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

mm/dump_pagetables.c passes both struct seq_file and struct pg_state
down the chain of walk_*_level() functions to be passed to note_page().
Instead place the struct seq_file in struct pg_state and access it from
struct pg_state (which is private to this file) in note_page().

Signed-off-by: Steven Price <steven.price@arm.com>
---
 arch/x86/mm/dump_pagetables.c | 69 ++++++++++++++++++-----------------
 1 file changed, 35 insertions(+), 34 deletions(-)

diff --git a/arch/x86/mm/dump_pagetables.c b/arch/x86/mm/dump_pagetables.c
index f9eb25dd3766..b448546277f4 100644
--- a/arch/x86/mm/dump_pagetables.c
+++ b/arch/x86/mm/dump_pagetables.c
@@ -40,6 +40,7 @@ struct pg_state {
 	bool to_dmesg;
 	bool check_wx;
 	unsigned long wx_pages;
+	struct seq_file *seq;
 };
 
 struct addr_marker {
@@ -268,11 +269,12 @@ static void note_wx(struct pg_state *st)
  * of PTE entries; the next one is different so we need to
  * print what we collected so far.
  */
-static void note_page(struct seq_file *m, struct pg_state *st,
-		      pgprot_t new_prot, pgprotval_t new_eff, int level)
+static void note_page(struct pg_state *st, pgprot_t new_prot,
+		      pgprotval_t new_eff, int level)
 {
 	pgprotval_t prot, cur, eff;
 	static const char units[] = "BKMGTPE";
+	struct seq_file *m = st->seq;
 
 	/*
 	 * If we have a "break" in the series, we need to flush the state that
@@ -358,8 +360,8 @@ static inline pgprotval_t effective_prot(pgprotval_t prot1, pgprotval_t prot2)
 	       ((prot1 | prot2) & _PAGE_NX);
 }
 
-static void walk_pte_level(struct seq_file *m, struct pg_state *st, pmd_t addr,
-			   pgprotval_t eff_in, unsigned long P)
+static void walk_pte_level(struct pg_state *st, pmd_t addr, pgprotval_t eff_in,
+			   unsigned long P)
 {
 	int i;
 	pte_t *pte;
@@ -370,7 +372,7 @@ static void walk_pte_level(struct seq_file *m, struct pg_state *st, pmd_t addr,
 		pte = pte_offset_map(&addr, st->current_address);
 		prot = pte_flags(*pte);
 		eff = effective_prot(eff_in, prot);
-		note_page(m, st, __pgprot(prot), eff, 5);
+		note_page(st, __pgprot(prot), eff, 5);
 		pte_unmap(pte);
 	}
 }
@@ -383,22 +385,20 @@ static void walk_pte_level(struct seq_file *m, struct pg_state *st, pmd_t addr,
  * us dozens of seconds (minutes for 5-level config) while checking for
  * W+X mapping or reading kernel_page_tables debugfs file.
  */
-static inline bool kasan_page_table(struct seq_file *m, struct pg_state *st,
-				void *pt)
+static inline bool kasan_page_table(struct pg_state *st, void *pt)
 {
 	if (__pa(pt) == __pa(kasan_early_shadow_pmd) ||
 	    (pgtable_l5_enabled() &&
 			__pa(pt) == __pa(kasan_early_shadow_p4d)) ||
 	    __pa(pt) == __pa(kasan_early_shadow_pud)) {
 		pgprotval_t prot = pte_flags(kasan_early_shadow_pte[0]);
-		note_page(m, st, __pgprot(prot), 0, 5);
+		note_page(st, __pgprot(prot), 0, 5);
 		return true;
 	}
 	return false;
 }
 #else
-static inline bool kasan_page_table(struct seq_file *m, struct pg_state *st,
-				void *pt)
+static inline bool kasan_page_table(struct pg_state *st, void *pt)
 {
 	return false;
 }
@@ -406,7 +406,7 @@ static inline bool kasan_page_table(struct seq_file *m, struct pg_state *st,
 
 #if PTRS_PER_PMD > 1
 
-static void walk_pmd_level(struct seq_file *m, struct pg_state *st, pud_t addr,
+static void walk_pmd_level(struct pg_state *st, pud_t addr,
 			   pgprotval_t eff_in, unsigned long P)
 {
 	int i;
@@ -420,19 +420,19 @@ static void walk_pmd_level(struct seq_file *m, struct pg_state *st, pud_t addr,
 			prot = pmd_flags(*start);
 			eff = effective_prot(eff_in, prot);
 			if (pmd_large(*start) || !pmd_present(*start)) {
-				note_page(m, st, __pgprot(prot), eff, 4);
-			} else if (!kasan_page_table(m, st, pmd_start)) {
-				walk_pte_level(m, st, *start, eff,
+				note_page(st, __pgprot(prot), eff, 4);
+			} else if (!kasan_page_table(st, pmd_start)) {
+				walk_pte_level(st, *start, eff,
 					       P + i * PMD_LEVEL_MULT);
 			}
 		} else
-			note_page(m, st, __pgprot(0), 0, 4);
+			note_page(st, __pgprot(0), 0, 4);
 		start++;
 	}
 }
 
 #else
-#define walk_pmd_level(m,s,a,e,p) walk_pte_level(m,s,__pmd(pud_val(a)),e,p)
+#define walk_pmd_level(s,a,e,p) walk_pte_level(s,__pmd(pud_val(a)),e,p)
 #undef pud_large
 #define pud_large(a) pmd_large(__pmd(pud_val(a)))
 #define pud_none(a)  pmd_none(__pmd(pud_val(a)))
@@ -440,8 +440,8 @@ static void walk_pmd_level(struct seq_file *m, struct pg_state *st, pud_t addr,
 
 #if PTRS_PER_PUD > 1
 
-static void walk_pud_level(struct seq_file *m, struct pg_state *st, p4d_t addr,
-			   pgprotval_t eff_in, unsigned long P)
+static void walk_pud_level(struct pg_state *st, p4d_t addr, pgprotval_t eff_in,
+			   unsigned long P)
 {
 	int i;
 	pud_t *start, *pud_start;
@@ -456,13 +456,13 @@ static void walk_pud_level(struct seq_file *m, struct pg_state *st, p4d_t addr,
 			prot = pud_flags(*start);
 			eff = effective_prot(eff_in, prot);
 			if (pud_large(*start) || !pud_present(*start)) {
-				note_page(m, st, __pgprot(prot), eff, 3);
-			} else if (!kasan_page_table(m, st, pud_start)) {
-				walk_pmd_level(m, st, *start, eff,
+				note_page(st, __pgprot(prot), eff, 3);
+			} else if (!kasan_page_table(st, pud_start)) {
+				walk_pmd_level(st, *start, eff,
 					       P + i * PUD_LEVEL_MULT);
 			}
 		} else
-			note_page(m, st, __pgprot(0), 0, 3);
+			note_page(st, __pgprot(0), 0, 3);
 
 		prev_pud = start;
 		start++;
@@ -470,21 +470,21 @@ static void walk_pud_level(struct seq_file *m, struct pg_state *st, p4d_t addr,
 }
 
 #else
-#define walk_pud_level(m,s,a,e,p) walk_pmd_level(m,s,__pud(p4d_val(a)),e,p)
+#define walk_pud_level(s,a,e,p) walk_pmd_level(s,__pud(p4d_val(a)),e,p)
 #undef p4d_large
 #define p4d_large(a) pud_large(__pud(p4d_val(a)))
 #define p4d_none(a)  pud_none(__pud(p4d_val(a)))
 #endif
 
-static void walk_p4d_level(struct seq_file *m, struct pg_state *st, pgd_t addr,
-			   pgprotval_t eff_in, unsigned long P)
+static void walk_p4d_level(struct pg_state *st, pgd_t addr, pgprotval_t eff_in,
+			   unsigned long P)
 {
 	int i;
 	p4d_t *start, *p4d_start;
 	pgprotval_t prot, eff;
 
 	if (PTRS_PER_P4D == 1)
-		return walk_pud_level(m, st, __p4d(pgd_val(addr)), eff_in, P);
+		return walk_pud_level(st, __p4d(pgd_val(addr)), eff_in, P);
 
 	p4d_start = start = (p4d_t *)pgd_page_vaddr(addr);
 
@@ -494,13 +494,13 @@ static void walk_p4d_level(struct seq_file *m, struct pg_state *st, pgd_t addr,
 			prot = p4d_flags(*start);
 			eff = effective_prot(eff_in, prot);
 			if (p4d_large(*start) || !p4d_present(*start)) {
-				note_page(m, st, __pgprot(prot), eff, 2);
-			} else if (!kasan_page_table(m, st, p4d_start)) {
-				walk_pud_level(m, st, *start, eff,
+				note_page(st, __pgprot(prot), eff, 2);
+			} else if (!kasan_page_table(st, p4d_start)) {
+				walk_pud_level(st, *start, eff,
 					       P + i * P4D_LEVEL_MULT);
 			}
 		} else
-			note_page(m, st, __pgprot(0), 0, 2);
+			note_page(st, __pgprot(0), 0, 2);
 
 		start++;
 	}
@@ -538,6 +538,7 @@ static void ptdump_walk_pgd_level_core(struct seq_file *m, pgd_t *pgd,
 	}
 
 	st.check_wx = checkwx;
+	st.seq = m;
 	if (checkwx)
 		st.wx_pages = 0;
 
@@ -551,13 +552,13 @@ static void ptdump_walk_pgd_level_core(struct seq_file *m, pgd_t *pgd,
 			eff = prot;
 #endif
 			if (pgd_large(*start) || !pgd_present(*start)) {
-				note_page(m, &st, __pgprot(prot), eff, 1);
+				note_page(&st, __pgprot(prot), eff, 1);
 			} else {
-				walk_p4d_level(m, &st, *start, eff,
+				walk_p4d_level(&st, *start, eff,
 					       i * PGD_LEVEL_MULT);
 			}
 		} else
-			note_page(m, &st, __pgprot(0), 0, 1);
+			note_page(&st, __pgprot(0), 0, 1);
 
 		cond_resched();
 		start++;
@@ -565,7 +566,7 @@ static void ptdump_walk_pgd_level_core(struct seq_file *m, pgd_t *pgd,
 
 	/* Flush out the last page */
 	st.current_address = normalize_addr(PTRS_PER_PGD*PGD_LEVEL_MULT);
-	note_page(m, &st, __pgprot(0), 0, 0);
+	note_page(&st, __pgprot(0), 0, 0);
 	if (!checkwx)
 		return;
 	if (st.wx_pages)
-- 
2.20.1

