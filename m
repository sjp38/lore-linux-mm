Return-Path: <SRS0=43/C=RJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 7B740C43381
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 15:52:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 3C4AC20663
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 15:52:11 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 3C4AC20663
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 312AB8E001B; Wed,  6 Mar 2019 10:51:48 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1FF538E0015; Wed,  6 Mar 2019 10:51:48 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id EF7978E001B; Wed,  6 Mar 2019 10:51:47 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 8DEFC8E0015
	for <linux-mm@kvack.org>; Wed,  6 Mar 2019 10:51:47 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id m25so6553693edd.6
        for <linux-mm@kvack.org>; Wed, 06 Mar 2019 07:51:47 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=OBlZRFK1RAUwn4DmMmPrReWAd+klq5PpYKB/ASjab+c=;
        b=Rxvd0LTshOtTgozNcxbgn4eb9G7GHmxwEVf/AMueTzsyylsOvRAJ9kqUOqGeMrzf39
         ragyvmwWV0GpJ9Q8DkahrvhHic6c+myaO2aU1WpLfVGiwSDlqPmSOH4TO9V117rwdTb2
         tvn4zKAUC9kj65B8yl+PylCG+7q6pEH+CPLvkqc7yjiyg7jWZQz/dQcKcCCVRY/ZxgYM
         0OViCKTzlpGeBZ+REDG//e3yM3yUu9lgIReo6eq7fX8Ooqe4cdpyRJCP5vRdThqtiMWI
         xatV7IUfhr4ECqi1/T0JTywhKTtr8EvTemu6RrEZwqYQpSoLBR1YY4oAx+WapEJyPJ3Q
         8jqw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: APjAAAXYC24SMk3jI8L9xRX77hUY1vXjY0XHWLpYxJAHLsuRG7CVDyMo
	W9uDyowls+ETSA4zlS3XJUaX7HEA34UORCFh19Z6STrosKu3DAWQdwljfs4FvqIYm6lLtaKVCn4
	QgSBYq9a+J/MvvURKgmgRaVZOqtk6BRV3nHfx8LHhIOhpnYmew2w0NCcGiGXgcMn9+A==
X-Received: by 2002:a50:9094:: with SMTP id c20mr23788835eda.126.1551887506930;
        Wed, 06 Mar 2019 07:51:46 -0800 (PST)
X-Google-Smtp-Source: APXvYqzfceMWs6ipEpW5PLGc+ibivGWeifaXpyR2CibBJZ60fo5c9AIbvNIrRqx7FmnyM3saezeM
X-Received: by 2002:a50:9094:: with SMTP id c20mr23788768eda.126.1551887505813;
        Wed, 06 Mar 2019 07:51:45 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551887505; cv=none;
        d=google.com; s=arc-20160816;
        b=lpn65QQQUfhm82o5jyDeMd4EGIwRyxJb//JuRBx+jx5QEpYqnjJ7E2jaW2UpcuQWJb
         1jfEiVYyfJRET6m3imnwnKUhJf3a+PYZxpUbU2L8MUbxBRhKxwj1ALUCAjSsBT/96XY+
         ee0JhNKnppezvVBX8rv+TsXJJ2B+aByfRfddB44Mu+C1RZaD00wXTI3BEMBtdHvn/M0K
         jeqXsf0hZxIY95Tqa1txjVHYaKrZLQAas8VSl7I1ixjLq/CsthfEjqkkKR/EXrqLAtkT
         NeXe2pv0hvMr+MJhrky7qV0fmWxmPXO8hRsAS99+pQhI6lE09DD3tPdepypHDZW0EWxU
         YWnA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=OBlZRFK1RAUwn4DmMmPrReWAd+klq5PpYKB/ASjab+c=;
        b=JhWhIK3ks2JyH74fQ1xapE8wQnN3qnvqR1kw78AKpQ26tmAxUNbQJbPVQ58JBExOPg
         sQkBIx7eYVs4bq9OD4aLmNAXltM+C+ya0BCThYnGSFotueixTUXd7FMzUSTwMAoAUBsY
         Px5T0Z6vE6+dbdjwsr93lmbcvtW8VZxFRqrKtn5fmd+L9gaqfCBKTkSZq7sjspuivEKs
         LIFeZ0c+H0PWG6fhkfudh7IDVA/T6snDlGcpg7F/K9b8NcmJSDGudBaKAHQusfsPjiyc
         5sfKpnAG1CRtnx2/8c9iqEqYrV9wx9w5zK2s3YiCzdcy7elvyfVaU/It8cMiw3HounnB
         Nkew==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id b37si761992edb.447.2019.03.06.07.51.45
        for <linux-mm@kvack.org>;
        Wed, 06 Mar 2019 07:51:45 -0800 (PST)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id B6EE1174E;
	Wed,  6 Mar 2019 07:51:44 -0800 (PST)
Received: from e112269-lin.arm.com (e112269-lin.cambridge.arm.com [10.1.196.69])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 7BB333F703;
	Wed,  6 Mar 2019 07:51:41 -0800 (PST)
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
Subject: [PATCH v4 16/19] x86: mm+efi: Convert ptdump_walk_pgd_level() to take a mm_struct
Date: Wed,  6 Mar 2019 15:50:28 +0000
Message-Id: <20190306155031.4291-17-steven.price@arm.com>
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
index 0dd04cf6ebeb..579959750f34 100644
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
index b448546277f4..f3663c5e8c6a 100644
--- a/arch/x86/mm/dump_pagetables.c
+++ b/arch/x86/mm/dump_pagetables.c
@@ -576,9 +576,9 @@ static void ptdump_walk_pgd_level_core(struct seq_file *m, pgd_t *pgd,
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

