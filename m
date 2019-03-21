Return-Path: <SRS0=0MJS=RY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 359BFC43381
	for <linux-mm@archiver.kernel.org>; Thu, 21 Mar 2019 14:21:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id E6A5F21916
	for <linux-mm@archiver.kernel.org>; Thu, 21 Mar 2019 14:21:09 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org E6A5F21916
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B7A126B0270; Thu, 21 Mar 2019 10:20:57 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B2BD86B0271; Thu, 21 Mar 2019 10:20:57 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9F19B6B0272; Thu, 21 Mar 2019 10:20:57 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 543466B0270
	for <linux-mm@kvack.org>; Thu, 21 Mar 2019 10:20:57 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id n12so2298499edo.5
        for <linux-mm@kvack.org>; Thu, 21 Mar 2019 07:20:57 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=Z5ii9WWPo9WVfhue9NtkIQuQCcbK0pxcqGqIbiUCEeU=;
        b=b/pkVHE/A2DoH+jshInyt1vnK2rgs3ieEcRtIuoB5ZV+V/qOrgx2ECz2c8Xjg9Iw/C
         6tpNj400fK8H5gV0uR16DPqY3N8YLZ7Htw3Gn7hDKkpDEEJ5MfdmoWgMVR/nMzbarv/N
         SinIdIy+jjQkqifVld117M1ZxDCoFAIBRpLN4VC6WF1/r57W7VUV7vpk2ihB1g6RLe/8
         Rop5ULkfVrHOOexqoHu3hCaZvQHGWQ6lyMumR/HCc5C+BLopTblvAxvcm4A3Ewv1hwAq
         vtWqSkJtzHwyFdzgNbSbKxA74lWM0Qh/lpKbbacfEzR2Sa4sWnrTnn8BL4nv2liaTNSC
         95gw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: APjAAAVpmjYD1Gfghi/MxM9i6wmWtOe3FXGU18pYSQRkPek0I0Io9ltq
	UtzqcwcCGd5783UAfCdOFZnQ+biuJtL4zZdTujSj51jBJjkNoTcvKhSwQjcgbUNSioAkmWWBN+S
	cC8vlDc96UONhjUPykTTvziliNT/rcMtMqR6+E6KIzvaHAPcgcRemhkivb0pcsHDAXg==
X-Received: by 2002:a50:ba8c:: with SMTP id x12mr2744411ede.230.1553178056862;
        Thu, 21 Mar 2019 07:20:56 -0700 (PDT)
X-Google-Smtp-Source: APXvYqykLvvcgP+znzUc7XxjvWbX3sGceMG4bxaEsv2IRqhNM+0a0kHWzEApbZjyFzWDnfyDX0/A
X-Received: by 2002:a50:ba8c:: with SMTP id x12mr2744336ede.230.1553178055374;
        Thu, 21 Mar 2019 07:20:55 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553178055; cv=none;
        d=google.com; s=arc-20160816;
        b=t+b/7udIWvq19dwa2UdYQFPAUy1GFxIPSaMJk4oITdiWKgP3wa6PtJAXUzD9fovdND
         tUJVzGuPweNybDVls4hqjVgfhjcaq5DaA1lU5Q11PNCcpkFgn7VbMhmp8K7hw9rX5BdN
         CIzblCjQPievn9EtajIXQ+/iDhpMzOYMO2dFt/D+1TZkHHPFGJTOp6jg2sjlyu3Wn9aw
         /plqul3T9wy/dRqhlNhXsrhKSGik1U2fyN6Nz/rbk5FyzudoN+gynyADKgmboUldIg+r
         Y/qyR77zCIJvKV35v1pnMghbexOslYUqnzYoOT5HWkb3GM5DhM89HxjsVhpKC2UqB1qp
         VGtQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=Z5ii9WWPo9WVfhue9NtkIQuQCcbK0pxcqGqIbiUCEeU=;
        b=XI3m1Hk3VF4Dge5hN0AH6aHuGEauTmxzoGm+MIpCWTlF+A+WWp89dD0m3gIcy66Mya
         7i6A3iJpkbKWqxbORZqCbpFBdui0vLjvNKPhjNLvXkWmAtaYVbuWzjB99aYyOsBReTUo
         DGU0EdDfa2cJJvoCaCoJyn87/dZ4ope/d84tAiuVnW9+N+5RPsFKEHVl1f57C1lsBdcw
         tGz7DLHW5iFIk/q2/Z2uqB6VvbLSAVdZbIuwoHx1fU/13RtQkiYfIK8C/7EQOr3oQtpW
         yA+gf6196ClJzdE60OfaH5ihzQMWEkRWnqXXYB7IHz50IvOZRtl13I8uk8ybvKlkmM4+
         lGQw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id g21si1324884eda.45.2019.03.21.07.20.54
        for <linux-mm@kvack.org>;
        Thu, 21 Mar 2019 07:20:55 -0700 (PDT)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 463FE1AC1;
	Thu, 21 Mar 2019 07:20:54 -0700 (PDT)
Received: from e112269-lin.arm.com (e112269-lin.cambridge.arm.com [10.1.196.69])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 0BBD83F575;
	Thu, 21 Mar 2019 07:20:50 -0700 (PDT)
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
Subject: [PATCH v5 13/19] arm64: mm: Convert mm/dump.c to use walk_page_range()
Date: Thu, 21 Mar 2019 14:19:47 +0000
Message-Id: <20190321141953.31960-14-steven.price@arm.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190321141953.31960-1-steven.price@arm.com>
References: <20190321141953.31960-1-steven.price@arm.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Now walk_page_range() can walk kernel page tables, we can switch the
arm64 ptdump code over to using it, simplifying the code.

Signed-off-by: Steven Price <steven.price@arm.com>
---
 arch/arm64/mm/dump.c | 117 ++++++++++++++++++++++---------------------
 1 file changed, 59 insertions(+), 58 deletions(-)

diff --git a/arch/arm64/mm/dump.c b/arch/arm64/mm/dump.c
index 14fe23cd5932..ea20c1213498 100644
--- a/arch/arm64/mm/dump.c
+++ b/arch/arm64/mm/dump.c
@@ -72,7 +72,7 @@ struct pg_state {
 	struct seq_file *seq;
 	const struct addr_marker *marker;
 	unsigned long start_address;
-	unsigned level;
+	int level;
 	u64 current_prot;
 	bool check_wx;
 	unsigned long wx_pages;
@@ -234,11 +234,14 @@ static void note_prot_wx(struct pg_state *st, unsigned long addr)
 	st->wx_pages += (addr - st->start_address) / PAGE_SIZE;
 }
 
-static void note_page(struct pg_state *st, unsigned long addr, unsigned level,
+static void note_page(struct pg_state *st, unsigned long addr, int level,
 				u64 val)
 {
 	static const char units[] = "KMGTPE";
-	u64 prot = val & pg_level[level].mask;
+	u64 prot = 0;
+
+	if (level >= 0)
+		prot = val & pg_level[level].mask;
 
 	if (!st->level) {
 		st->level = level;
@@ -286,73 +289,71 @@ static void note_page(struct pg_state *st, unsigned long addr, unsigned level,
 
 }
 
-static void walk_pte(struct pg_state *st, pmd_t *pmdp, unsigned long start,
-		     unsigned long end)
+static int pud_entry(pud_t *pud, unsigned long addr,
+		unsigned long next, struct mm_walk *walk)
 {
-	unsigned long addr = start;
-	pte_t *ptep = pte_offset_kernel(pmdp, start);
+	struct pg_state *st = walk->private;
+	pud_t val = READ_ONCE(*pud);
+
+	if (pud_table(val))
+		return 0;
+
+	note_page(st, addr, 2, pud_val(val));
 
-	do {
-		note_page(st, addr, 4, READ_ONCE(pte_val(*ptep)));
-	} while (ptep++, addr += PAGE_SIZE, addr != end);
+	return 0;
 }
 
-static void walk_pmd(struct pg_state *st, pud_t *pudp, unsigned long start,
-		     unsigned long end)
+static int pmd_entry(pmd_t *pmd, unsigned long addr,
+		unsigned long next, struct mm_walk *walk)
 {
-	unsigned long next, addr = start;
-	pmd_t *pmdp = pmd_offset(pudp, start);
-
-	do {
-		pmd_t pmd = READ_ONCE(*pmdp);
-		next = pmd_addr_end(addr, end);
-
-		if (pmd_none(pmd) || pmd_sect(pmd)) {
-			note_page(st, addr, 3, pmd_val(pmd));
-		} else {
-			BUG_ON(pmd_bad(pmd));
-			walk_pte(st, pmdp, addr, next);
-		}
-	} while (pmdp++, addr = next, addr != end);
+	struct pg_state *st = walk->private;
+	pmd_t val = READ_ONCE(*pmd);
+
+	if (pmd_table(val))
+		return 0;
+
+	note_page(st, addr, 3, pmd_val(val));
+
+	return 0;
 }
 
-static void walk_pud(struct pg_state *st, pgd_t *pgdp, unsigned long start,
-		     unsigned long end)
+static int pte_entry(pte_t *pte, unsigned long addr,
+		unsigned long next, struct mm_walk *walk)
 {
-	unsigned long next, addr = start;
-	pud_t *pudp = pud_offset(pgdp, start);
-
-	do {
-		pud_t pud = READ_ONCE(*pudp);
-		next = pud_addr_end(addr, end);
-
-		if (pud_none(pud) || pud_sect(pud)) {
-			note_page(st, addr, 2, pud_val(pud));
-		} else {
-			BUG_ON(pud_bad(pud));
-			walk_pmd(st, pudp, addr, next);
-		}
-	} while (pudp++, addr = next, addr != end);
+	struct pg_state *st = walk->private;
+	pte_t val = READ_ONCE(*pte);
+
+	note_page(st, addr, 4, pte_val(val));
+
+	return 0;
+}
+
+static int pte_hole(unsigned long addr, unsigned long next,
+		struct mm_walk *walk)
+{
+	struct pg_state *st = walk->private;
+
+	note_page(st, addr, -1, 0);
+
+	return 0;
 }
 
 static void walk_pgd(struct pg_state *st, struct mm_struct *mm,
-		     unsigned long start)
+		unsigned long start)
 {
-	unsigned long end = (start < TASK_SIZE_64) ? TASK_SIZE_64 : 0;
-	unsigned long next, addr = start;
-	pgd_t *pgdp = pgd_offset(mm, start);
-
-	do {
-		pgd_t pgd = READ_ONCE(*pgdp);
-		next = pgd_addr_end(addr, end);
-
-		if (pgd_none(pgd)) {
-			note_page(st, addr, 1, pgd_val(pgd));
-		} else {
-			BUG_ON(pgd_bad(pgd));
-			walk_pud(st, pgdp, addr, next);
-		}
-	} while (pgdp++, addr = next, addr != end);
+	struct mm_walk walk = {
+		.mm = mm,
+		.private = st,
+		.pud_entry = pud_entry,
+		.pmd_entry = pmd_entry,
+		.pte_entry = pte_entry,
+		.pte_hole = pte_hole
+	};
+	down_read(&mm->mmap_sem);
+	walk_page_range(start, start | (((unsigned long)PTRS_PER_PGD <<
+					 PGDIR_SHIFT) - 1),
+			&walk);
+	up_read(&mm->mmap_sem);
 }
 
 void ptdump_walk_pgd(struct seq_file *m, struct ptdump_info *info)
-- 
2.20.1

