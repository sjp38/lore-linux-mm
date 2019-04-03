Return-Path: <SRS0=DmM3=SF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B2840C10F0B
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 14:18:10 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 72A6420830
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 14:18:10 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 72A6420830
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F140F6B0278; Wed,  3 Apr 2019 10:18:09 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EC1E86B0279; Wed,  3 Apr 2019 10:18:09 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id D88356B027A; Wed,  3 Apr 2019 10:18:09 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 8231F6B0278
	for <linux-mm@kvack.org>; Wed,  3 Apr 2019 10:18:09 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id z98so7701890ede.3
        for <linux-mm@kvack.org>; Wed, 03 Apr 2019 07:18:09 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=Z5ii9WWPo9WVfhue9NtkIQuQCcbK0pxcqGqIbiUCEeU=;
        b=SBWbpvrx2VrPeiGyzl2lNCkfl2xvYY9kYTbhip2Dw5Ao1y+T7b8GIvOSWFtQaOtQCB
         s51z9OxPx9kzsB8U8/NORxtQfCbtgO2QFVGjuTPhBkyjdaWM2T3bY2K+4iVjLIl0jWvy
         XTxXN9mx7IcqZ0nZuDfctc9NOfbyGLlngGuR6mvPYB5H2NRY6t+cjqjYTp9HOB1UlKmr
         pLquLJKy3s5VqC+iK2Nrvm7RFDfh+HMxuGA1PZxCHHLauk6OoxGricILLfA3ovZLa6o0
         yV2D4aHaS7u+llbXxXrwWzjdfnHRNxyYxcdyqYdg0Dv5R6ALA+SgbrqwSpTe7Dx3tpme
         A7bw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: APjAAAWegNiaP1tNIDzb6rN6eTf3l5jnPYl4Coc+bDYNm4KyubFZV4UW
	ak0WhSWJDqusksFOMagdXYl9a9Nb2ar39T1+u1wKZQ+6HO3piVKyqnoPwSKu7Imu7UGKSPVk/ca
	NwlQZOBqNTiIzKfyRoJgF5kSLINohX9JbcwSAAiBqcZIPLI8W93SjuZ1lhEp7EDJm7Q==
X-Received: by 2002:a17:906:63ca:: with SMTP id u10mr43958538ejk.127.1554301089017;
        Wed, 03 Apr 2019 07:18:09 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzBeaxnt50ZSUv+KiMkBRV//IuoLYlC175eXI/py/FiuINOtclV71vNhJUqE+4REdqCSUKF
X-Received: by 2002:a17:906:63ca:: with SMTP id u10mr43958452ejk.127.1554301087360;
        Wed, 03 Apr 2019 07:18:07 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554301087; cv=none;
        d=google.com; s=arc-20160816;
        b=vLL7F0U+5210Iq3+/auuTLPk6svxS5tRzjN+NzQlvZsF14ceMQ1oKVhHbeQ45172nr
         RAC6DUY57Qe+uAthtvGKrUl5Fetr1y2AfDfwyv3hlX0hXwwIYLtSkhL5rQDxYTjRdrU7
         eWmH6z7ibgSFs6ClvG2bpS+itj6Ldt3OOg5O/oQdNksgSQEdPSWnCgEReJlHwaMZfPCI
         RvjzfxU1BCV5fj+5gl2PcM2XlTxt65n3XSQE9FZsGcl+d1NwiARnlpKiJ+/83mPYGph1
         Yr/jetrLVWVCdJig1EHrSTgh4u+MDHfuVJzG8pOKG5XhYFoHvJAFhTYYSJGgyuySOya0
         HesA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=Z5ii9WWPo9WVfhue9NtkIQuQCcbK0pxcqGqIbiUCEeU=;
        b=KebRNxqQPYOj+X65WWIk5SqTmRKX2vmQzBP6k59gnZmU8XDM8OXzWADNqbhFFbYc3z
         mPnwvIB1Q8kOcuRDZsS3K6wYmlR1Yz55bVFfOiBrrsQSPlj3dBqelhC0QfuTqzKBzn3w
         ruNSxJZAvCRSuzoS6jtF6yfCELIt25Acr2wK2mzp8JKSdggzhpaELg1kiuBwA8eI0JOM
         cSTWl7qtsnWcyxxG2mKrr35I1pt0It0kbjSew+g9EWw97+qglU3aRhuecG9c0XO7R1vb
         d0ZbZtz/EvJLmFfX+eTy5APt/N7CK/MqvAXGizStGVvak4vFl//U9PPuvR+3SUFaBmmu
         Zw9g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id q2si4217337edn.429.2019.04.03.07.18.06
        for <linux-mm@kvack.org>;
        Wed, 03 Apr 2019 07:18:07 -0700 (PDT)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 2A999EBD;
	Wed,  3 Apr 2019 07:18:06 -0700 (PDT)
Received: from e112269-lin.arm.com (e112269-lin.cambridge.arm.com [10.1.196.69])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id BFC9E3F68F;
	Wed,  3 Apr 2019 07:18:02 -0700 (PDT)
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
Subject: [PATCH v8 14/20] arm64: mm: Convert mm/dump.c to use walk_page_range()
Date: Wed,  3 Apr 2019 15:16:21 +0100
Message-Id: <20190403141627.11664-15-steven.price@arm.com>
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

