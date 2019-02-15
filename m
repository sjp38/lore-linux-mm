Return-Path: <SRS0=VMr4=QW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0DB02C4360F
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 17:03:45 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BD705222BE
	for <linux-mm@archiver.kernel.org>; Fri, 15 Feb 2019 17:03:44 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BD705222BE
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 50BD78E000D; Fri, 15 Feb 2019 12:03:41 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 4BD4A8E0001; Fri, 15 Feb 2019 12:03:41 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 3B1658E000D; Fri, 15 Feb 2019 12:03:41 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id BE1BF8E0001
	for <linux-mm@kvack.org>; Fri, 15 Feb 2019 12:03:40 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id u19so4147488eds.12
        for <linux-mm@kvack.org>; Fri, 15 Feb 2019 09:03:40 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=ZxfOscDKXutNwaZpM2VXWTmUvZzMiqbo2UDKLtcN8fs=;
        b=c1O2MNuFgdR4s93iWs4HkVyf7kK/66lqTOj24QWSuMTEIaFrP402eHIKkSy4yjKeMo
         RiGNOXOV8dDrP5C4LNLzy6/DL1PC6OX6s72IFZinmW7ksmiqMxzhqItxclV6rrC67YBo
         t3f58SZpUh2jPWh7okde+3Vgw7I1NSRLtDZTpHrVPyhZ5GtlSK94qz+mrRGGB3OKaf9s
         jPL1FH2YjJPqMJEoQh+WDemnuvNeaulHFSEAdxjdwIMOHP3azsYOEDhnFwss+b+zZoMy
         eDG2AGPVDu09JddGnXN7zoENeQNT55DAfqcHkAcpdXGK8NQlXkdK0PQKVSzdtzwiSQcQ
         sH3A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: AHQUAuZKduCEaTcmV9i85P1HPG0OQ9kxwP4M6xPOD2r+GfKPEnv4FNQw
	GLIhP8fGMi7eK13W48CMImLPfdd3I5kC4bWe+sv3iPpmJoPNnD/7MJndRWSh7E+yZynXTAMi4re
	H5uqUxWLLRBB+sS0m1mOhXj2byqFFbiIx848nzR8iQ5u45m9ZwJ5z3sEYp66xkxzReg==
X-Received: by 2002:a17:906:14c9:: with SMTP id y9mr7378313ejc.182.1550250220252;
        Fri, 15 Feb 2019 09:03:40 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ib3/jlVymjyuu3xQEeo/DhlIJmkS0CMGpfZeD2JQeONde1vR2fPep6vVsBgnqUAxd9pe5md
X-Received: by 2002:a17:906:14c9:: with SMTP id y9mr7378262ejc.182.1550250219210;
        Fri, 15 Feb 2019 09:03:39 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550250219; cv=none;
        d=google.com; s=arc-20160816;
        b=AN9qS2BTYQbtknyG7sOJaSa0+Y0TjIzoFw2O6397cbS3TCKmKvWP+Azy86c01tZob6
         zt6+bQJKCRECSJcZIrVYK9wtzXJ615vK7qdPQqggXyuyGhdKi77mTzepKZjFJGet8DbC
         9+YQHtzZ0ILw9HAn/2BUiNOKwfpBy2a6s9G1LP2V/SwEuXyJ3F1cu4NDLN6b7RiAhR5S
         RKyyVdrPUxnb6LOSd+WpY7kQMCNamSq/bi7/JSSnSW+9lCY5yBEG+x3od+cic8yH2DGH
         QcugdH46Wq4Re6aqvJYJMaImmutXZ3UTN4C0nL+aZLscXkPUlEXolVEWuCyjS/mN8sFu
         mqsA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=ZxfOscDKXutNwaZpM2VXWTmUvZzMiqbo2UDKLtcN8fs=;
        b=Fi8z76iFnov1gD0HvFjJJoznkLA+E2Q+/OA92lasGHLstss7c/G8f/cq0DyRdvlxCs
         ZpJNZ/Mxs1B1BOZBkh/Q2HexvSbMr5L5KpJpLtTmduNxrSrfh9L/ZABxn5nHO2Ry6ncI
         wSib5ngpWee1/XcGiYTvcYvhDx6ySSEvoYK9Ocejdi7Yg5j1qRsExSARkt/8YEdklOpa
         q+ay+j6uj2rbeS5wgUP5M7a3TKsqtiYo6S87RjKyX0XjmiouRL1Bst0qgBsZFuCkfeGv
         krs9I56oh3XrC9biAFkx0d21EzB21/9lazU1GRg5uhmw6iXrH9DuEtzFHc3qiLxWBC5a
         WpyA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id ca20si2409135ejb.146.2019.02.15.09.03.38
        for <linux-mm@kvack.org>;
        Fri, 15 Feb 2019 09:03:39 -0800 (PST)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 12BAE1596;
	Fri, 15 Feb 2019 09:03:38 -0800 (PST)
Received: from e112269-lin.arm.com (e112269-lin.cambridge.arm.com [10.1.196.69])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 1F3883F557;
	Fri, 15 Feb 2019 09:03:34 -0800 (PST)
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
Subject: [PATCH 10/13] x86/mm+efi: Convert ptdump_walk_pgd_level() to take a mm_struct
Date: Fri, 15 Feb 2019 17:02:31 +0000
Message-Id: <20190215170235.23360-11-steven.price@arm.com>
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
callers of ptdump_walk_pgd_level() need to pass an mm_struct rather
than the raw pgd_t pointer. Luckily since commit 7e904a91bf60
("efi: Use efi_mm in x86 as well as ARM") we now have an mm_struct
for EFI on x86.

Signed-off-by: Steven Price <steven.price@arm.com>
---
 arch/x86/include/asm/pgtable.h | 2 +-
 arch/x86/mm/dump_pagetables.c  | 4 ++--
 arch/x86/platform/efi/efi_32.c | 2 +-
 arch/x86/platform/efi/efi_64.c | 4 ++--
 4 files changed, 6 insertions(+), 6 deletions(-)

diff --git a/arch/x86/include/asm/pgtable.h b/arch/x86/include/asm/pgtable.h
index 3695f6acb6af..371901283d5f 100644
--- a/arch/x86/include/asm/pgtable.h
+++ b/arch/x86/include/asm/pgtable.h
@@ -27,7 +27,7 @@
 extern pgd_t early_top_pgt[PTRS_PER_PGD];
 int __init __early_make_pgtable(unsigned long address, pmdval_t pmd);
 
-void ptdump_walk_pgd_level(struct seq_file *m, pgd_t *pgd);
+void ptdump_walk_pgd_level(struct seq_file *m, struct mm_struct *mm);
 void ptdump_walk_pgd_level_debugfs(struct seq_file *m, pgd_t *pgd, bool user);
 void ptdump_walk_pgd_level_checkwx(void);
 void ptdump_walk_user_pgd_level_checkwx(void);
diff --git a/arch/x86/mm/dump_pagetables.c b/arch/x86/mm/dump_pagetables.c
index ad6986c9e8e7..1a4a03e3a6bd 100644
--- a/arch/x86/mm/dump_pagetables.c
+++ b/arch/x86/mm/dump_pagetables.c
@@ -574,9 +574,9 @@ static void ptdump_walk_pgd_level_core(struct seq_file *m, pgd_t *pgd,
 		pr_info("x86/mm: Checked W+X mappings: passed, no W+X pages found.\n");
 }
 
-void ptdump_walk_pgd_level(struct seq_file *m, pgd_t *pgd)
+void ptdump_walk_pgd_level(struct seq_file *m, struct mm_struct *mm)
 {
-	ptdump_walk_pgd_level_core(m, pgd, false, true);
+	ptdump_walk_pgd_level_core(m, mm->pgd, false, true);
 }
 
 void ptdump_walk_pgd_level_debugfs(struct seq_file *m, pgd_t *pgd, bool user)
diff --git a/arch/x86/platform/efi/efi_32.c b/arch/x86/platform/efi/efi_32.c
index 9959657127f4..9175ceaa6e72 100644
--- a/arch/x86/platform/efi/efi_32.c
+++ b/arch/x86/platform/efi/efi_32.c
@@ -49,7 +49,7 @@ void efi_sync_low_kernel_mappings(void) {}
 void __init efi_dump_pagetable(void)
 {
 #ifdef CONFIG_EFI_PGT_DUMP
-	ptdump_walk_pgd_level(NULL, swapper_pg_dir);
+	ptdump_walk_pgd_level(NULL, init_mm);
 #endif
 }
 
diff --git a/arch/x86/platform/efi/efi_64.c b/arch/x86/platform/efi/efi_64.c
index cf0347f61b21..a2e0f9800190 100644
--- a/arch/x86/platform/efi/efi_64.c
+++ b/arch/x86/platform/efi/efi_64.c
@@ -611,9 +611,9 @@ void __init efi_dump_pagetable(void)
 {
 #ifdef CONFIG_EFI_PGT_DUMP
 	if (efi_enabled(EFI_OLD_MEMMAP))
-		ptdump_walk_pgd_level(NULL, swapper_pg_dir);
+		ptdump_walk_pgd_level(NULL, init_mm);
 	else
-		ptdump_walk_pgd_level(NULL, efi_mm.pgd);
+		ptdump_walk_pgd_level(NULL, efi_mm);
 #endif
 }
 
-- 
2.20.1

