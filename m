Return-Path: <SRS0=c5Kt=R5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3648EC43381
	for <linux-mm@archiver.kernel.org>; Tue, 26 Mar 2019 16:27:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BD32320863
	for <linux-mm@archiver.kernel.org>; Tue, 26 Mar 2019 16:27:27 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BD32320863
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6CF736B027D; Tue, 26 Mar 2019 12:27:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 681C96B027E; Tue, 26 Mar 2019 12:27:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 571E56B027F; Tue, 26 Mar 2019 12:27:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id ECC996B027D
	for <linux-mm@kvack.org>; Tue, 26 Mar 2019 12:27:26 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id i59so5504756edi.15
        for <linux-mm@kvack.org>; Tue, 26 Mar 2019 09:27:26 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=Z5ii9WWPo9WVfhue9NtkIQuQCcbK0pxcqGqIbiUCEeU=;
        b=OtHgeBRC4ddlYzfDGCfK0NvikVRbKDEY6/LnhJBb26lM3DuRP0vlPnjyoE53KeR9Dl
         KBZ6trcbVQCMI/QgByqHaH5zbVVT9riUMm9rOCGDWuJ09n4KcgK3JW3QyRMYiUOAdPdi
         LoZS4ww1KqKkaSjoQu3aF8K5BWE8z+C+2gTXrxSeajozSIlsgqarZcAZIWrAljvE0OJ2
         oRfHmdQP75uA7TMADnHJFW5qXsqkAjayKO33n7Z6YQCPv2GCxBinXoUw4mYySrQ50OqH
         xOsKY9cfP+USeLH2e45C62pOIDeJOaGCHqahTU9CddKaAZ56TlVE/ZIslZJg3Ac+WZ3X
         LBsg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: APjAAAWNZxx8Jgjzd5v+T0xIYFvngUWxrZg8IusY/sPH21l5f2Mutauh
	HPXzERz788Csul35o1IFFlEVo2ePMjROZOkFi5RP0OIJ2S7wY8dvw4qOoUQW5pcTWc8F2XJk2yr
	6ucYDpqnut9bep4Gg29asQ/f54E1azNBo7KCa2yP1qMP58wfEpmcJKn+4tr4x6P3QdQ==
X-Received: by 2002:a17:906:1c98:: with SMTP id g24mr17469337ejh.178.1553617646471;
        Tue, 26 Mar 2019 09:27:26 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx3NisBDVNhPlSbaSIO4ZPUI0aghayk1kCY+0wpD6mUtds5NKFD5a/i7Pfxvnr4JfSq9B/l
X-Received: by 2002:a17:906:1c98:: with SMTP id g24mr17469274ejh.178.1553617644774;
        Tue, 26 Mar 2019 09:27:24 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553617644; cv=none;
        d=google.com; s=arc-20160816;
        b=z704Uw5PDDJlhJEpMZWkLmc82u5VhIBk/Pplxepu4NV+GgeHb3nhT9lalWU4e7qxJT
         v1oXPlkrq2ATC9h9KRBBa/0BMFMqoMkMgStK0znydq+5+/ocmjvhFs/hu0bUn4bj0IN6
         OwqSqmb6UztLS9o1WJO2Y1ldikSLPltPoS2oEnh0sekNNEspEueEXOCkUmIYzHvg6udm
         WZ0Zy5ffAPAGtrfFYdxQhFfz9hbdL6oDvjIG6s2QqxMoMez/jLs/tw8ctZoKCrucwpz5
         7SnXmd/EZ9uwG/7HVtR6TxtzPJRlHGd4oGkdtUjOVchZHhgzj9PG7JIn9M5dpL9I/9Yw
         zDwA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=Z5ii9WWPo9WVfhue9NtkIQuQCcbK0pxcqGqIbiUCEeU=;
        b=EMos518cjQBlTN3gkm0usdVoIaC8ACOnGUrPzZm8i45RuNFlnEChLD1qg+rwI0n0nG
         DJgNlVAfwTX9iAKKZtz0bnxQuoO1n/OlJTlLa3z/w8onqRjVuk/j72tHL3cG1iezcNcE
         vdufMERmDAF8BTVDLgbj69PQxhFU2+xoBIrb5l0TXli6bDbeovTFRsyc8YeqOwsI8LTk
         nvCg7Tpvm9pMtO0nCAkrkg7biA770h0qoOLXkl8nLA/klTkTVxh3FXnMyCfPBYYD2T/e
         VURvbZ7m7y3aRJsfW5dT9kdFgQYv9Yw2De0jIoTSb+lZsCad1KmaqNM4j6BPh9NAaE9n
         EhPw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id n25si51091edr.314.2019.03.26.09.27.24
        for <linux-mm@kvack.org>;
        Tue, 26 Mar 2019 09:27:24 -0700 (PDT)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id C056D1684;
	Tue, 26 Mar 2019 09:27:23 -0700 (PDT)
Received: from e112269-lin.arm.com (e112269-lin.cambridge.arm.com [10.1.196.69])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 849BD3F614;
	Tue, 26 Mar 2019 09:27:20 -0700 (PDT)
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
Subject: [PATCH v6 13/19] arm64: mm: Convert mm/dump.c to use walk_page_range()
Date: Tue, 26 Mar 2019 16:26:18 +0000
Message-Id: <20190326162624.20736-14-steven.price@arm.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190326162624.20736-1-steven.price@arm.com>
References: <20190326162624.20736-1-steven.price@arm.com>
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

