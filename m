Return-Path: <SRS0=43/C=RJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9DBA4C43381
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 15:52:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5DF3F20663
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 15:52:14 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5DF3F20663
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D26078E001C; Wed,  6 Mar 2019 10:51:51 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C11B28E0015; Wed,  6 Mar 2019 10:51:51 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9C7468E001C; Wed,  6 Mar 2019 10:51:51 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3FECE8E0015
	for <linux-mm@kvack.org>; Wed,  6 Mar 2019 10:51:51 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id o9so6555194edh.10
        for <linux-mm@kvack.org>; Wed, 06 Mar 2019 07:51:51 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=kfrPCNXIG3FQ3lVFQr7+l/G0hifye/sreV+W8dKJJ+E=;
        b=kApVEtIUeecg+9fPv03rDb+9cM5fXd5TEf4HcI5qnAaHcxkAp0XCdZyxLyCKX/DWGt
         U72zoX7tmJX1WSlScSFUq+QBSbyUTm/pStR4Tm7hAF8eTPimct/MV1kkwxmtBOb26mgS
         jAWqVEbK9GAvj9i1Cs0yrmQEFpAM6yVyGozr6IfIOFQBcGtalU/FM2vor9VnGuepFoiK
         1Qpo/4nvv7AXCESnh0eXP7CirTJdF+F8gtsOsOVqoKW8ymDYTkZX6QkHSpa7oRx+F72F
         5EwbXbDXmQDoloaRsQj9hzGEEkaAFP4dueVvWmAkDyLTRjWQdQWAIeRBC/Sg3j27Mf0F
         1Fbg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: APjAAAU+kLrjpr4VfbpTtGzadUUP04yFBiDKDu8FPAj5c2MsyOt2XkVW
	dxraRt8qoaKemPBn95c7d5fJhDfIYQmqdzqCzCM8Jix/7q0XE2PlgdoK1W3CzuSLm/Ss8GF/E1A
	dui0R/ZKtdZDA6Qqbs/JUAFwofG2XoUeTLZfmFkpmPQhE1luj53VyMuc+7LnOE1myrg==
X-Received: by 2002:a50:aee3:: with SMTP id f32mr23341566edd.108.1551887510516;
        Wed, 06 Mar 2019 07:51:50 -0800 (PST)
X-Google-Smtp-Source: APXvYqxskWx3NeqBu4n8YiNzBu9xJiwQkdbq+VqqLjxHV/4eHyA4FEV1MnqImAMdXn1ukShRtQqY
X-Received: by 2002:a50:aee3:: with SMTP id f32mr23341496edd.108.1551887509292;
        Wed, 06 Mar 2019 07:51:49 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551887509; cv=none;
        d=google.com; s=arc-20160816;
        b=cQ47xechF2Mv5CYxscw39VbYGa2pUJ/UFkSZTCTj86v0d71jVKhpfaIjbBaV041pZY
         qjzFd0dZkB4tl5YZzc+KxGXUjcfSn23JLh0nWwJnriwug+Vqa8F2HwMyGgCV7QH/Y7x1
         3ntFfwequNWZ/VonQk9Gs6rf9VxfvLSOoELecTcz1qPNmDWZ1tcwZ2Yv92GDMcOTrt8H
         GbG78qrpUhDkkUoC9f3J6tc/8FkjadYM4XlqPqJQnwaHfkqFO8Q5XBsAZgovf15828KD
         B3H4I20GZ6Bf10Dpq0bifSfQy+XHruJ3mRrTAZaP6GJ9tGleHjQ2QSPBwsSol/YmE92Y
         eztA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=kfrPCNXIG3FQ3lVFQr7+l/G0hifye/sreV+W8dKJJ+E=;
        b=rZcAieS1pmR/W6okVFZDtEIA3W3oq6yxfssRQaEYzt4bN/V84A6KwPPyNcNZKJBfCh
         XyqyUioqoFiSp0PYPac1VSUEklnA9NCCf5BUZ57Cy20mj2T6J2/XVv4xA3Hnvml5d46f
         4qU25z2bW8/2PwjEdy/2x4W7BIAMyPyaExHwIQvdpTuitZYtJ863rnU3D8AfIgzFJuHu
         tEZgJG0QJQqP+aLpuLOt18vK/U7PQEF8ypfjlScCrsnqDbnoOgEgGi/mbhZVnzzERd1Z
         fHY4fidKEUVitjt4x84ukbcrnpwedp8QywppKd+xEQcrmxKCvPuNF6PxQNFTUhyWMC8i
         9YMw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id s14si12741edb.49.2019.03.06.07.51.48
        for <linux-mm@kvack.org>;
        Wed, 06 Mar 2019 07:51:49 -0800 (PST)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 3E3CE1684;
	Wed,  6 Mar 2019 07:51:48 -0800 (PST)
Received: from e112269-lin.arm.com (e112269-lin.cambridge.arm.com [10.1.196.69])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 029223F703;
	Wed,  6 Mar 2019 07:51:44 -0800 (PST)
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
Subject: [PATCH v4 17/19] x86: mm: Convert ptdump_walk_pgd_level_debugfs() to take an mm_struct
Date: Wed,  6 Mar 2019 15:50:29 +0000
Message-Id: <20190306155031.4291-18-steven.price@arm.com>
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
index 579959750f34..5abf693dc9b2 100644
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
index f3663c5e8c6a..1c1b37c32787 100644
--- a/arch/x86/mm/dump_pagetables.c
+++ b/arch/x86/mm/dump_pagetables.c
@@ -527,16 +527,12 @@ static inline bool is_hypervisor_range(int idx)
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
@@ -581,8 +577,10 @@ void ptdump_walk_pgd_level(struct seq_file *m, struct mm_struct *mm)
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
@@ -608,7 +606,7 @@ void ptdump_walk_user_pgd_level_checkwx(void)
 
 void ptdump_walk_pgd_level_checkwx(void)
 {
-	ptdump_walk_pgd_level_core(NULL, NULL, true, false);
+	ptdump_walk_pgd_level_core(NULL, INIT_PGD, true, false);
 }
 
 static int __init pt_dump_init(void)
-- 
2.20.1

