Return-Path: <SRS0=VMr4=QW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 74C08C10F02
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 17:03:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3A49221924
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 17:03:37 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3A49221924
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6E0D68E000B; Fri, 15 Feb 2019 12:03:35 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 691BC8E0001; Fri, 15 Feb 2019 12:03:35 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 580778E000B; Fri, 15 Feb 2019 12:03:35 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id F267D8E0001
	for <linux-mm@kvack.org>; Fri, 15 Feb 2019 12:03:34 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id u19so4147355eds.12
        for <linux-mm@kvack.org>; Fri, 15 Feb 2019 09:03:34 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=+F2lxaeFDvQ8eJHjFbD9vB/FESYGJ6cBcX+b4/bW6NY=;
        b=nl8WQ59ihu9OAD0C3BsMSN5GwbwkhV8Jh9JisyWoPjNqRlIJ3myC/EsE36GXaKUS2U
         HztxWqYi7F4YUscudjr+4CVC4RnP1QmfQAvEsdTV89LPFzu2uUqzk8PLxo1lQtgQaZ38
         zL4U+jN3sB/P7pFszPPuevxaCVrNwevH2x8NS6W1i1gPax3Slq5RusPiXasCR2NrCoqx
         qHsemtPKbUtCyFRUTHhn+eeA4bwtxzKJmDhoF0b6je2HsCh1b0LZ7iv9FlrpuIJ4oPNn
         RDKenaKOeJQhldKqlfPRzngba3oxoMk8cXfw/oQInQnXV59V72p+iz1RNddSHWhsOYXK
         iSBA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: AHQUAubK/spHCC1xUnCTd5OEpmceYtZ587/85kfvhjfP4J4U/w/jM74C
	8GnPk6xio+yeK8Cf+lhi1ZZ9aETPMHEbgib9cv8QJ26hdIE4KnIlfbph9LPBe5wVb7maGRmLuyQ
	LkTPWaYOFZ5Xr9Q9sU9PdizEs3//r/fdG8SpVccUgJfe88sHsMB2XEUcD7NRhGlY9VA==
X-Received: by 2002:a17:906:3d69:: with SMTP id r9mr3216687ejf.92.1550250214464;
        Fri, 15 Feb 2019 09:03:34 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbKSv5CYlx2/ZuJdiDkb7Irk76FDUM6kdNc4z8zQLjFYGR8jVkTadP6MkJDU6UrBIFYmxyS
X-Received: by 2002:a17:906:3d69:: with SMTP id r9mr3216602ejf.92.1550250212788;
        Fri, 15 Feb 2019 09:03:32 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550250212; cv=none;
        d=google.com; s=arc-20160816;
        b=lUAY9tcbJtRJlZQq05WKDkszA6oRcXsf4zWJ7r9LfmhBk124CfG/AcyjvjYpr7xV27
         Y9frp0CMvjmVfmRkOub7Zav2bNiDEt6l0Bp2veR4Lv2d8ta48DYklSn/SnH8ud6dODhF
         zJR9Q/jDBa87LU/h6Z+MDQ9TYYMOh7re7yE0aLS3331GIsAskeOg8q7Mho4KP1JoG7B8
         jyE+sfkaVZHcmuULkf9NwHZc6IdTGwteTiqEDhlqEEsDKBfO9Ww2JR+YnOSWjlOS9vjj
         H/pNIFg6JMn2djxTPhZoybGWyu61O0MU6+nNia6gthDHLUb4QGXtRPx6pztDLvDJ2+Rl
         U9zA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=+F2lxaeFDvQ8eJHjFbD9vB/FESYGJ6cBcX+b4/bW6NY=;
        b=L1fYX39wJ+4BbOoK/jYSTqVSWfjvpKibp5jt89TEC4SoLiv9hkzybBhUojEGSVu+eF
         xYiRYUlleS1a2XVh7NcWeCbQFFXjYz9XKd9AHwPH1XXT69dsmW5vyqRF2valRvsRjHGo
         kjSMB3ThuLJoyCWB9+zkNyaqtKMlQdKmCGZHuRyDl4nyf+0b+2jDOy2hgQ8D8DSRRwaE
         LrOdZYFDrUjFMW9BE/MWDT0r4I6xT8cYGepaYded0YtKaCIXmwM5ibRPIMzYM7FGfKbm
         A7IR9eIrwwDiMe6NQ0wDyCCpzpHfHnF1y8BzSOaevyV0FoyRRRI2tUL2NwsV+85dQAcN
         EWGg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id r53si236380edd.365.2019.02.15.09.03.32
        for <linux-mm@kvack.org>;
        Fri, 15 Feb 2019 09:03:32 -0800 (PST)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 7D43A1650;
	Fri, 15 Feb 2019 09:03:31 -0800 (PST)
Received: from e112269-lin.arm.com (e112269-lin.cambridge.arm.com [10.1.196.69])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 89BB73F557;
	Fri, 15 Feb 2019 09:03:28 -0800 (PST)
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
	linux-kernel@vger.kernel.org
Subject: [PATCH 08/13] arm64: mm: Convert mm/dump.c to use walk_page_range()
Date: Fri, 15 Feb 2019 17:02:29 +0000
Message-Id: <20190215170235.23360-9-steven.price@arm.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190215170235.23360-1-steven.price@arm.com>
References: <20190215170235.23360-1-steven.price@arm.com>
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
 arch/arm64/mm/dump.c | 108 +++++++++++++++++++++----------------------
 1 file changed, 53 insertions(+), 55 deletions(-)

diff --git a/arch/arm64/mm/dump.c b/arch/arm64/mm/dump.c
index 99bb8facb5cb..ee0bc1441dd0 100644
--- a/arch/arm64/mm/dump.c
+++ b/arch/arm64/mm/dump.c
@@ -286,73 +286,71 @@ static void note_page(struct pg_state *st, unsigned long addr, unsigned level,
 
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
 
-	do {
-		note_page(st, addr, 4, READ_ONCE(pte_val(*ptep)));
-	} while (ptep++, addr += PAGE_SIZE, addr != end);
+	if (pud_table(val))
+		return 0;
+
+	note_page(st, addr, 2, pud_val(val));
+
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
+static int pte_hole(unsigned long addr, unsigned long next, int depth,
+		struct mm_walk *walk)
+{
+	struct pg_state *st = walk->private;
+
+	note_page(st, addr, depth+1, 0);
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

