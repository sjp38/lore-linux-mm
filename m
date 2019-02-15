Return-Path: <SRS0=VMr4=QW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A9BEFC10F02
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 17:03:48 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 6F6F721924
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 17:03:48 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 6F6F721924
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 583888E000E; Fri, 15 Feb 2019 12:03:44 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 531CF8E0001; Fri, 15 Feb 2019 12:03:44 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4481C8E000E; Fri, 15 Feb 2019 12:03:44 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id E2FD58E0001
	for <linux-mm@kvack.org>; Fri, 15 Feb 2019 12:03:43 -0500 (EST)
Received: by mail-ed1-f71.google.com with SMTP id p52so4145993eda.18
        for <linux-mm@kvack.org>; Fri, 15 Feb 2019 09:03:43 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=ctfQAjdhDywt5nLYxqKiK2RzJwkOOVzCEeLiTsCnJr0=;
        b=SjkblWy9HEfGCYxGjCKZrSiqEWJy9Mr79i/NG31dYC5bPep9IwLkGMvCg0p6xZKDVt
         Tgqx//ctH39Fe5Xalvg6S5THgTAnRlJZ+qDMOXg3AIj0MT1g6JCWLxu6xhLrSXZomreT
         GcXpHf3vCq3+cWJG0YR/6U+t9VxmXAcNFgmG0nk81uwvTFjNJRm2TkQS3NaWVCfcw2Bp
         0GRt7tHHCx/32ocJIhc+kaXrvQ7GmOCZktyp9CwKmP+edBakmfFORp9veMWfIrnumAeE
         3fxDYQbnuvm7eR1RmGQahvPR7KOk/vD+k7MxcWfOn5fRAo3ZBbPBGCLGPS3wqb1gqlBu
         wdgg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: AHQUAuakeZsHlypynNvC9gfmkgP3NDU+t8h7GmnE4Bcfuadwjonn5DSc
	gvWrh9yWO6ZWM8XGHLNN9Z5T0m/sYEu4x79Vj2w4OB9BpWCp22ro+vlgwl3c8DSjZttJNRrSL6y
	lT4SOKkMp7KUJzIzOV0X5I6UQlVHnFKBPz0hU1yGHdGbpf5Eu/lUhvM221IZijICK/Q==
X-Received: by 2002:aa7:ca41:: with SMTP id j1mr8399561edt.34.1550250223418;
        Fri, 15 Feb 2019 09:03:43 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYKPmxAbL22CRcIZbq9LjIwufV57isNz5EK59vKmzzZxTVIQImrfRE+hM1Mrq8fgEEMt6LN
X-Received: by 2002:aa7:ca41:: with SMTP id j1mr8399499edt.34.1550250222330;
        Fri, 15 Feb 2019 09:03:42 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550250222; cv=none;
        d=google.com; s=arc-20160816;
        b=JlZAUffrFy0llUNI2Pa+zL9FqNDc+lYxtzP4B0o47xQDkyOLbHl6CLc3vjP68O6zlV
         Mavfn8gAGGSPEeYQI65iGH2hkgyaQcZPOzcIJCnUK9IVsGe2NLe/sxZWX8wu5u/ZmH8U
         F3auwrlwZ1EBcZpXLJ9GyBPAkW6IDjt2SoY5UOEUo3r4zqm56i7aRJIjiigGfK+ytSqk
         Ae8nTg7ZNsm5jAkaj5+gYkBRpERMsKLQdQSQJyErYhDjG4TS6HD/fSYwE/mIFNGqVM2m
         SXZ+8hnGTdYXkNuYoOIQ9F7YqMzgvvp0JJ7nlZ/m/BwIYquqM5KR386wWwaSRyWpLjc6
         5bdg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=ctfQAjdhDywt5nLYxqKiK2RzJwkOOVzCEeLiTsCnJr0=;
        b=eIGraqPc8eTeyQBHBrrfMvE+aSCSOHf55CnFmhxfG7Aqb2KYACT7p2hsJdbvClnxOU
         DCoYSg9s8JfiPk5J9HqQ2CxCFlkIuWbcEvpJ8I7briD3S25skihv+Rj9Hi4toZLITKzC
         gEEpK8Y5t4hhXE9Eur1LkIxyLFmTqBDB3BFuRT6mZpSboVh8EOpCKxQzCzHZHOVwqu2o
         LEi70cjRtzrVN0wgYBZyR4rlZes0vOdt1cr87O1na0QTzW7CcBv5YNeF48UWoTtyvvYk
         2hUBWbD9vEbvvyS/AwQRqKkzhTOHGY3O+OJ8aAncjXyZVN9DBzLOByjPQuAT+Rsf4Aig
         JAQA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id f26si810897ejb.21.2019.02.15.09.03.41
        for <linux-mm@kvack.org>;
        Fri, 15 Feb 2019 09:03:42 -0800 (PST)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 45C4B1682;
	Fri, 15 Feb 2019 09:03:41 -0800 (PST)
Received: from e112269-lin.arm.com (e112269-lin.cambridge.arm.com [10.1.196.69])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 521F63F557;
	Fri, 15 Feb 2019 09:03:38 -0800 (PST)
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
Subject: [PATCH 11/13] x86/mm: Convert ptdump_walk_pgd_level_debugfs() to take an mm_struct
Date: Fri, 15 Feb 2019 17:02:32 +0000
Message-Id: <20190215170235.23360-12-steven.price@arm.com>
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

To enable x86 to use the generic walk_page_range() function, the
callers of ptdump_walk_pgd_level_debugfs() need to pass in the mm_struct.

This means that ptdump_walk_pgd_level_core() is now always passed a
valid pgd, so drop the support for pgd==NULL.

Signed-off-by: Steven Price <steven.price@arm.com>
---
 arch/x86/include/asm/pgtable.h |  3 ++-
 arch/x86/mm/debug_pagetables.c |  8 ++++----
 arch/x86/mm/dump_pagetables.c  | 14 ++++++--------
 3 files changed, 12 insertions(+), 13 deletions(-)

diff --git a/arch/x86/include/asm/pgtable.h b/arch/x86/include/asm/pgtable.h
index 371901283d5f..ab2aa3eb05e9 100644
--- a/arch/x86/include/asm/pgtable.h
+++ b/arch/x86/include/asm/pgtable.h
@@ -28,7 +28,8 @@ extern pgd_t early_top_pgt[PTRS_PER_PGD];
 int __init __early_make_pgtable(unsigned long address, pmdval_t pmd);
 
 void ptdump_walk_pgd_level(struct seq_file *m, struct mm_struct *mm);
-void ptdump_walk_pgd_level_debugfs(struct seq_file *m, pgd_t *pgd, bool user);
+void ptdump_walk_pgd_level_debugfs(struct seq_file *m, struct mm_struct *mm,
+				   bool user);
 void ptdump_walk_pgd_level_checkwx(void);
 void ptdump_walk_user_pgd_level_checkwx(void);
 
diff --git a/arch/x86/mm/debug_pagetables.c b/arch/x86/mm/debug_pagetables.c
index cd84f067e41d..824131052574 100644
--- a/arch/x86/mm/debug_pagetables.c
+++ b/arch/x86/mm/debug_pagetables.c
@@ -6,7 +6,7 @@
 
 static int ptdump_show(struct seq_file *m, void *v)
 {
-	ptdump_walk_pgd_level_debugfs(m, NULL, false);
+	ptdump_walk_pgd_level_debugfs(m, &init_mm, false);
 	return 0;
 }
 
@@ -16,7 +16,7 @@ static int ptdump_curknl_show(struct seq_file *m, void *v)
 {
 	if (current->mm->pgd) {
 		down_read(&current->mm->mmap_sem);
-		ptdump_walk_pgd_level_debugfs(m, current->mm->pgd, false);
+		ptdump_walk_pgd_level_debugfs(m, current->mm, false);
 		up_read(&current->mm->mmap_sem);
 	}
 	return 0;
@@ -31,7 +31,7 @@ static int ptdump_curusr_show(struct seq_file *m, void *v)
 {
 	if (current->mm->pgd) {
 		down_read(&current->mm->mmap_sem);
-		ptdump_walk_pgd_level_debugfs(m, current->mm->pgd, true);
+		ptdump_walk_pgd_level_debugfs(m, current->mm, true);
 		up_read(&current->mm->mmap_sem);
 	}
 	return 0;
@@ -46,7 +46,7 @@ static struct dentry *pe_efi;
 static int ptdump_efi_show(struct seq_file *m, void *v)
 {
 	if (efi_mm.pgd)
-		ptdump_walk_pgd_level_debugfs(m, efi_mm.pgd, false);
+		ptdump_walk_pgd_level_debugfs(m, &efi_mm, false);
 	return 0;
 }
 
diff --git a/arch/x86/mm/dump_pagetables.c b/arch/x86/mm/dump_pagetables.c
index 1a4a03e3a6bd..18fb6193311f 100644
--- a/arch/x86/mm/dump_pagetables.c
+++ b/arch/x86/mm/dump_pagetables.c
@@ -525,16 +525,12 @@ static inline bool is_hypervisor_range(int idx)
 static void ptdump_walk_pgd_level_core(struct seq_file *m, pgd_t *pgd,
 				       bool checkwx, bool dmesg)
 {
-	pgd_t *start = INIT_PGD;
+	pgd_t *start = pgd;
 	pgprotval_t prot, eff;
 	int i;
 	struct pg_state st = {};
 
-	if (pgd) {
-		start = pgd;
-		st.to_dmesg = dmesg;
-	}
-
+	st.to_dmesg = dmesg;
 	st.check_wx = checkwx;
 	st.seq = m;
 	if (checkwx)
@@ -579,8 +575,10 @@ void ptdump_walk_pgd_level(struct seq_file *m, struct mm_struct *mm)
 	ptdump_walk_pgd_level_core(m, mm->pgd, false, true);
 }
 
-void ptdump_walk_pgd_level_debugfs(struct seq_file *m, pgd_t *pgd, bool user)
+void ptdump_walk_pgd_level_debugfs(struct seq_file *m, struct mm_struct *mm,
+				   bool user)
 {
+	pgd_t *pgd = mm->pgd;
 #ifdef CONFIG_PAGE_TABLE_ISOLATION
 	if (user && static_cpu_has(X86_FEATURE_PTI))
 		pgd = kernel_to_user_pgdp(pgd);
@@ -606,7 +604,7 @@ void ptdump_walk_user_pgd_level_checkwx(void)
 
 void ptdump_walk_pgd_level_checkwx(void)
 {
-	ptdump_walk_pgd_level_core(NULL, NULL, true, false);
+	ptdump_walk_pgd_level_core(NULL, INIT_PGD, true, false);
 }
 
 static int __init pt_dump_init(void)
-- 
2.20.1

