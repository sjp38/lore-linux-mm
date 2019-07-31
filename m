Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EE61FC32751
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 15:47:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A3389216C8
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 15:47:04 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A3389216C8
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4402F8E0023; Wed, 31 Jul 2019 11:47:01 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 41A108E0003; Wed, 31 Jul 2019 11:47:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 307EA8E0023; Wed, 31 Jul 2019 11:47:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id D7AA88E0003
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 11:47:00 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id b12so42619092ede.23
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 08:47:00 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=maKVlbOyQye3qG0rXhjb4/gEvSCwsev433JyCg81uSU=;
        b=lemJFRzjSFgf8dVC0jjFDnfJmKYfUuxsVuEZ2cbgxuT37OefZ9gK63GYKhuM/fbKl6
         cFP+jybZdqPAm6JIHLcdZHwoQHCUuhzxzcV/XEgAaWdUqg62jWTmdvv4nF21OxFdPDJ7
         1/GjEsvJNRnLFjOiTrHxh4XeY+eON4tFWyBhzGYDfihbXjZW8M1cvDd5lUlHkeDXWhEP
         YLNXneiLCxDuCv1WFXEA9fAAEhDoxj9sqkj/4rvAyGmh0YOHWL8mkOHdGbTxOR5x4551
         e98Jy9GSd5r5Pal+avwrJ8KVJLM1kNEGksUrmUQ/5XddHSqcDlL3jmD1H1sxhI9SOvHB
         hNFw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: APjAAAWhTdGgnWmCM2cveJHmXX9pLJk0KJOm5yMg+v2xZe8DVMJvv4TQ
	Tjkq7GSnP7D0hxAFux1y0Bb03QL17GUoiinJFYiHpP/T+mqLNs4CGp/gyCP0pbo/L9U9uqVeB+o
	lxcupRza32emU064jfsCIRZGXhUZlOZeqBBA8fdzZSaX8nOASf7hD2vHm5h8Ad42dvQ==
X-Received: by 2002:aa7:d404:: with SMTP id z4mr107674283edq.131.1564588020463;
        Wed, 31 Jul 2019 08:47:00 -0700 (PDT)
X-Google-Smtp-Source: APXvYqztNfgH5FEglLW5dkCLT1t6LT/uXnWbfVfE2ttWaDEAi81r6EiKTrQYWeJQMVVSqq68L+ul
X-Received: by 2002:aa7:d404:: with SMTP id z4mr107674221edq.131.1564588019658;
        Wed, 31 Jul 2019 08:46:59 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564588019; cv=none;
        d=google.com; s=arc-20160816;
        b=yx1riLafVJwCUB1+pZaS+dw2aavU0aEkiHklNefsCHRgMyNPG9iVi/tGBsfH4BiP4L
         +rExnln382IwTIkuzJysVDJ5VvmFjNQJ7awYTuaUeLOtqnI/p+dGP+o5pebuLsf+a11u
         HUJRg0+2mUAm58FUrokeZWFD2qJy9DEBE8BIuYfBwfINbxPZWYEJK/mWmW7ubfgIRZhG
         ZNJA0R+lYNfmN8nLJMJvUlBKb2oE3buKB1tIRxWOhdxO8xPRRnnBiv19zL3Y483rfqB+
         z+mFG3j2M4VXRW7oAWaqVSpFimbnJ3wNYg5xxuuj1J4PV9kGaPG8flP6Ut9h2dnnhqEc
         jMHQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=maKVlbOyQye3qG0rXhjb4/gEvSCwsev433JyCg81uSU=;
        b=US8i8YqijX2vB65Lep/sLDt1WE5XFJGms1c32T1oY/9KWRqnw/WeEWKBIi80RtHZwg
         V8r10xH9WPeRUVJDlAsOFzpXd3143Hey7z7R6qcjCWIKIy+h0UWNh6zvdu2dATVGsuxR
         wnSFsl1xFVyDqV/ew2MQ3cu0v2thJdeqQxiiRxUqEcitDDcnCbclFAE1kzB+fRtg312T
         +yy76gKMt6ZGoNAo68vsfvaCmgI19MK1HOx8n5KQQYTm0uzuLu2SAczwZs1BLW0PunIn
         vnYLLWvhxhENUTJGJqNxXEnw++KHB+rCBLZ32NlsiBK65NlyAUVaBnOJ8c95yn3Bjp/C
         cHPw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id i20si18560008ejb.107.2019.07.31.08.46.59
        for <linux-mm@kvack.org>;
        Wed, 31 Jul 2019 08:46:59 -0700 (PDT)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id BF05B1596;
	Wed, 31 Jul 2019 08:46:58 -0700 (PDT)
Received: from e112269-lin.arm.com (e112269-lin.cambridge.arm.com [10.1.196.133])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 340B43F694;
	Wed, 31 Jul 2019 08:46:56 -0700 (PDT)
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
	Will Deacon <will@kernel.org>,
	x86@kernel.org,
	"H. Peter Anvin" <hpa@zytor.com>,
	linux-arm-kernel@lists.infradead.org,
	linux-kernel@vger.kernel.org,
	Mark Rutland <Mark.Rutland@arm.com>,
	"Liang, Kan" <kan.liang@linux.intel.com>,
	Andrew Morton <akpm@linux-foundation.org>
Subject: [PATCH v10 16/22] x86: mm+efi: Convert ptdump_walk_pgd_level() to take a mm_struct
Date: Wed, 31 Jul 2019 16:45:57 +0100
Message-Id: <20190731154603.41797-17-steven.price@arm.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190731154603.41797-1-steven.price@arm.com>
References: <20190731154603.41797-1-steven.price@arm.com>
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
index 6986a451619e..1a2b469f6e75 100644
--- a/arch/x86/include/asm/pgtable.h
+++ b/arch/x86/include/asm/pgtable.h
@@ -29,7 +29,7 @@
 extern pgd_t early_top_pgt[PTRS_PER_PGD];
 int __init __early_make_pgtable(unsigned long address, pmdval_t pmd);
 
-void ptdump_walk_pgd_level(struct seq_file *m, pgd_t *pgd);
+void ptdump_walk_pgd_level(struct seq_file *m, struct mm_struct *mm);
 void ptdump_walk_pgd_level_debugfs(struct seq_file *m, pgd_t *pgd, bool user);
 void ptdump_walk_pgd_level_checkwx(void);
 void ptdump_walk_user_pgd_level_checkwx(void);
diff --git a/arch/x86/mm/dump_pagetables.c b/arch/x86/mm/dump_pagetables.c
index 4dc6f4df40af..24fe76325b31 100644
--- a/arch/x86/mm/dump_pagetables.c
+++ b/arch/x86/mm/dump_pagetables.c
@@ -567,9 +567,9 @@ static void ptdump_walk_pgd_level_core(struct seq_file *m, pgd_t *pgd,
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
index 9959657127f4..1616074075c3 100644
--- a/arch/x86/platform/efi/efi_32.c
+++ b/arch/x86/platform/efi/efi_32.c
@@ -49,7 +49,7 @@ void efi_sync_low_kernel_mappings(void) {}
 void __init efi_dump_pagetable(void)
 {
 #ifdef CONFIG_EFI_PGT_DUMP
-	ptdump_walk_pgd_level(NULL, swapper_pg_dir);
+	ptdump_walk_pgd_level(NULL, &init_mm);
 #endif
 }
 
diff --git a/arch/x86/platform/efi/efi_64.c b/arch/x86/platform/efi/efi_64.c
index 08ce8177c3af..3cb63cd369d6 100644
--- a/arch/x86/platform/efi/efi_64.c
+++ b/arch/x86/platform/efi/efi_64.c
@@ -614,9 +614,9 @@ void __init efi_dump_pagetable(void)
 {
 #ifdef CONFIG_EFI_PGT_DUMP
 	if (efi_enabled(EFI_OLD_MEMMAP))
-		ptdump_walk_pgd_level(NULL, swapper_pg_dir);
+		ptdump_walk_pgd_level(NULL, &init_mm);
 	else
-		ptdump_walk_pgd_level(NULL, efi_mm.pgd);
+		ptdump_walk_pgd_level(NULL, &efi_mm);
 #endif
 }
 
-- 
2.20.1

