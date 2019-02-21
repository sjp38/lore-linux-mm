Return-Path: <SRS0=vS5V=Q4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 22576C43381
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 11:35:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id DDCFD2147A
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 11:35:49 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org DDCFD2147A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 5985A8E007B; Thu, 21 Feb 2019 06:35:49 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 51F2E8E0075; Thu, 21 Feb 2019 06:35:49 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3BED78E007B; Thu, 21 Feb 2019 06:35:49 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id D1CB38E0075
	for <linux-mm@kvack.org>; Thu, 21 Feb 2019 06:35:48 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id u12so3238414edo.5
        for <linux-mm@kvack.org>; Thu, 21 Feb 2019 03:35:48 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=+F2lxaeFDvQ8eJHjFbD9vB/FESYGJ6cBcX+b4/bW6NY=;
        b=cThZjvjSQDAj3t5CRLMoD5mEOSJsaQzKjtGKKtfN83++Ggsn1NG83SLw3emlSk+7kK
         zcamY6rz08HiMrSPJ4IGMIgoOLJpSOfOtXf+8UwIH7T5LbsiM4oje1AA4yxB9Rw7C/+f
         6Mm8DfS9jzDR9EHzCukLDztIvcE0tFKJxdYAte7xeRRhDT9Jx0Y5X7xUdMoceOcwlWbs
         LOHfYcO6P4oH1oq+T8NMVDtRR0JUvUenCg9/JxeBnCO4TXh7wSqdM2+mb3tLWXN1fIpS
         h0Vhk+5lt2Y490hWW/oUXvo4QklQgTBj80FrjtnxuBViHWxkMcCd5UKZjjc4Xu18+j6f
         k92A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: AHQUAuYRwx5ZM8GV8OT6GkBm/TwPsL6Q1Ut3hsqWqxMttJ/ABCwRt3J/
	1CXbKAaPzr0csDaRo1npIgtY7MVMu/n85tlQtVf8WMO+30SLCrBw9aw9u+6bmYkaiWeFR2ru90C
	ut73zpL2BXW2w6Np3BzUz5QOVTR/FBvoqH2MteioxtQIyO2Ug9aQBwoVlXGgp8pqU1A==
X-Received: by 2002:a50:90e8:: with SMTP id d37mr29250880eda.252.1550748948353;
        Thu, 21 Feb 2019 03:35:48 -0800 (PST)
X-Google-Smtp-Source: AHgI3IaCnRAhqsw6nHjZFpbrN8nxxlRM4Ele/Qk8g1e9RGLVYmOw30Vyoj/mSTjNgIR6S6/lx3cA
X-Received: by 2002:a50:90e8:: with SMTP id d37mr29250816eda.252.1550748947212;
        Thu, 21 Feb 2019 03:35:47 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550748947; cv=none;
        d=google.com; s=arc-20160816;
        b=oA8o+wlmHTlwngAXXj6Vfl1mctApSMXQJr68N01xAuEoSuMM59+3QcKXeyvKJno/El
         PtPSdWGvqfyblGAQL+TAiH/seOwx12jTyeTNIWLilHM2MgxGWqvVJdbitZKuTWduFfDK
         BHGZHFEaH4nNpG+Rx6eAsTBXBMk/hp67gyKqm8P6XmbGGeVAytKtYYmc1MmMIXWU9HZx
         qUhpak8TD8NSV4II84r8YjlUC18yUgVLGVUHk9GgXkVn83zZeNI4LJAhJqtlJsENs06n
         GYTYKFv1ightOViSJVI+jnSQSO0lNUeBqXuN4no4YaHBI/y27mGk9nnau0vgcpwCVBbz
         7EeA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=+F2lxaeFDvQ8eJHjFbD9vB/FESYGJ6cBcX+b4/bW6NY=;
        b=MY7hheHYiZB4kxO8q7EUb3x46QV64iAEEBIBiwxZZ3rFs0K59Vzkz8dz+mnuI9YcvE
         791e8ukGcuYkrztMsGGuSjbVvRIHr50oUHCHZwbLjgTnWVQ9wi3OtyXe2GR6aAywFxlK
         azx/LnoHv08vWLNd6C3k5HyDSLuPICDV4Se/16hewnJh+UeTFP2x0J2soxWyesn2hVdR
         4dzhp40Xp86CK7xeQbV0weUaBNwYi/0iTkfhkI/SloNHgCpuz2Nc4tlvv0kvnhgc8+qi
         737jwjsIBaRENmKyvmnZQnwjnZVC4vMGEuCA9du0/I/ttUi4CYsbTwKuE3JKyFe+L50Y
         5bOw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id i12si8730832ede.179.2019.02.21.03.35.46
        for <linux-mm@kvack.org>;
        Thu, 21 Feb 2019 03:35:47 -0800 (PST)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 027DD1688;
	Thu, 21 Feb 2019 03:35:46 -0800 (PST)
Received: from e112269-lin.arm.com (e112269-lin.cambridge.arm.com [10.1.196.69])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 750E03F5C1;
	Thu, 21 Feb 2019 03:35:42 -0800 (PST)
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
Subject: [PATCH v2 08/13] arm64: mm: Convert mm/dump.c to use walk_page_range()
Date: Thu, 21 Feb 2019 11:34:57 +0000
Message-Id: <20190221113502.54153-9-steven.price@arm.com>
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

