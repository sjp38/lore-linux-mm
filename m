Return-Path: <SRS0=43/C=RJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 8F279C43381
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 15:52:02 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4D16E20663
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 15:52:02 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4D16E20663
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 50D3E8E0018; Wed,  6 Mar 2019 10:51:38 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4BF638E0015; Wed,  6 Mar 2019 10:51:38 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3D3658E0018; Wed,  6 Mar 2019 10:51:38 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id D7EC98E0015
	for <linux-mm@kvack.org>; Wed,  6 Mar 2019 10:51:37 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id k21so6652130eds.19
        for <linux-mm@kvack.org>; Wed, 06 Mar 2019 07:51:37 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=3se5x9e60F5pHicDwQ8/uBQi1VomgQ/cYp+w07wEFJ4=;
        b=uYghR9V7Spxq0D6Ws00vi+rPROuvAAh9yXKBbYephqUpD1ebzksqeHsHzSi4d36OD3
         aInEHV+icVTiPuJNK6ez9c+oWFpto2Pt+9wHG5c+C1SGFIOK5bz1EzefqV41hK+DQIVN
         c/7JgVUUDcZ6Jqi4v8FkJuZB7BA7VvpEG9H2VCBaP0Mn/Mg/lYEX73a9zEfbMBh88MoF
         +CCNyZXkT6XS+jS78sfymTELAj/0NKnwhVGmY1SHr6yLjfg7eQgiKzrZhOE7lwK01TE9
         hnQUb1XgbHsvb24YMs6YKpRX3QERH3xFC0z5kaJq8dPbzdRd1Ghan/QdBhd9K0Yt1V0x
         wdOg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: APjAAAXX1CObRVhZb+pnOAg4cW/28BG8d5b6CC0pYtS/PFQ4ATyfZNJI
	yKiCA+T6cDWWLCq8RvjY1mVskO1wnfCgkRcPORt8tzA5Ta9mHzlxr/t7pkAemqFyRnQeIEyWj9X
	1JKVasKzS6zFrx6JaipWrkSmm9Yq+G00l9auhSeTdKVkTDK3gOU+BeGoUm/lm3hp5Gw==
X-Received: by 2002:a17:906:81d7:: with SMTP id e23mr4364750ejx.207.1551887497028;
        Wed, 06 Mar 2019 07:51:37 -0800 (PST)
X-Google-Smtp-Source: APXvYqwchvPIdhOtPdhV1k67LRezjmS0vVURhJz5gIO6/PCPtUqpY2D24gLhIt+X24TuGXN5GHnD
X-Received: by 2002:a17:906:81d7:: with SMTP id e23mr4364650ejx.207.1551887495091;
        Wed, 06 Mar 2019 07:51:35 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551887495; cv=none;
        d=google.com; s=arc-20160816;
        b=z5qktZlc7f/Va2k0tq6avG9lgRxut4NqibtnD1eJX2rBDifTfI0PRAc5PynsbJR9Xs
         xfD0tOAQyNWvdj6sXpkYt2ojf9DpxGTJtEnvt10fI8O6GLfIQBNoLu5bM0BfT/HTZgzY
         751zT3RsXbq8jjvy0O2Ht+qUuJHNypcP4eunsL1OzCBgOHypR0RGspH58kMMuu/KRXX1
         eI5S3sjtOjd7/9xvDU3/Xfu95XPvWeP3HS1MeFnK+ij+sat+IRgqcZc77HG7I6a97tNa
         VbK9qse5BrCrkTiXjs8s2zyxJUGON/lmzS8ap/Es9fpsHn6sXneSFDaTc+x2gMP8HeCu
         t6qg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=3se5x9e60F5pHicDwQ8/uBQi1VomgQ/cYp+w07wEFJ4=;
        b=0HsPkYFhkv6/igTA83mxEQ2jb8+XMr1OVC8rVdOHUrEv3qkw3zO6ItWWNRgWMuU0hq
         pocDcBmNuBIi2/WP56qqhfK27fd6fXWRY9Ghwu7JLHQ592Xf3gwArXUxBKivjG90Anzj
         3ihUX7AOEzdszeXI9Y0w+m3ydTDfos1Th99UgM94ChGjuVvxYooSGXWAWq/t4U7o7MH4
         sLRdhMpbv9u8jNv4Spzu+CIB0aGqkrBYIR9XbqhTfS3BcL3lXlEuIxcw9vtshwUp01Kp
         Ubw8gLU7oYethLvBIh/NmXf4yIKO7PdApBQVOxq9zosPL3+GRydQx1uOV+oW/P6C43+r
         sYEQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id g26si756333ejd.14.2019.03.06.07.51.34
        for <linux-mm@kvack.org>;
        Wed, 06 Mar 2019 07:51:35 -0800 (PST)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 18012174E;
	Wed,  6 Mar 2019 07:51:34 -0800 (PST)
Received: from e112269-lin.arm.com (e112269-lin.cambridge.arm.com [10.1.196.69])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id D0D233F738;
	Wed,  6 Mar 2019 07:51:30 -0800 (PST)
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
Subject: [PATCH v4 13/19] arm64: mm: Convert mm/dump.c to use walk_page_range()
Date: Wed,  6 Mar 2019 15:50:25 +0000
Message-Id: <20190306155031.4291-14-steven.price@arm.com>
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

Now walk_page_range() can walk kernel page tables, we can switch the
arm64 ptdump code over to using it, simplifying the code.

Signed-off-by: Steven Price <steven.price@arm.com>
---
 arch/arm64/mm/dump.c | 117 ++++++++++++++++++++++---------------------
 1 file changed, 59 insertions(+), 58 deletions(-)

diff --git a/arch/arm64/mm/dump.c b/arch/arm64/mm/dump.c
index 99bb8facb5cb..c5e936507565 100644
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

