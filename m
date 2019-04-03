Return-Path: <SRS0=DmM3=SF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9580EC4360F
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 14:18:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 544422084C
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 14:18:21 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 544422084C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D137C6B027D; Wed,  3 Apr 2019 10:18:20 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CC5116B027E; Wed,  3 Apr 2019 10:18:20 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B3D346B027F; Wed,  3 Apr 2019 10:18:20 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 651F66B027D
	for <linux-mm@kvack.org>; Wed,  3 Apr 2019 10:18:20 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id d2so7489539edo.23
        for <linux-mm@kvack.org>; Wed, 03 Apr 2019 07:18:20 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=82GVaLwkCHLAJuw0cg7cs7mz13Kyr233/Gpjb9qS/I0=;
        b=Cs2NKMw9gg1Mnu0r6oMb5bDIeamFQ0e3m0/nLjPpzQp3GohjOfIfBM6HDzDUGsoiC4
         O38BVeM4gtojq2BD7Cyht9HTBtZfq4iDERPgQAYZf12ZZA1KhUhezA3Wrp8iDXUziYP8
         FeizyaH6MG8B811F1gIbpDyI2OmHZCkBMgzgznawt7DZmRn84TGiscpCHVAx/qO+yYgg
         +uH/GprrW7DsLuW4I8zWhtY+6qCex3t5VsFrsCKA3XSlbTC8HgYez+i7hAh2d7XS27do
         Y72VHWGv6fvFh6o2oFvVuRQaQLp8nK+2sup0t2R0pKVAg8dVPMtV+mE88wvZ6NBEeLc5
         wOEg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: APjAAAUu/+aaMo7uamRcl9/YrRSTGFdkBzK0Ws+dQEwvCznStSbevBtZ
	EDPPHdw0JyxGG2WlesbXH3rsSZiV0qVhCdhrCEn76aOnXkXzrWqXeO+gT3mvPtfNYdW4EvZ5T94
	j46ATvSSmac8Fq9OSI7jO7Tlda26xarvZkyXHvTex1VgCd7FXaoSgLYnlOTMZq5k8mA==
X-Received: by 2002:a17:906:4958:: with SMTP id f24mr44255462ejt.77.1554301099919;
        Wed, 03 Apr 2019 07:18:19 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz8DR6Fb+JK1Hx4D3oCjoi+h1knT8mptG1RH6XDBodB7ZO0FUVYoMk6YyLuXOQd7AytjYwc
X-Received: by 2002:a17:906:4958:: with SMTP id f24mr44255380ejt.77.1554301098315;
        Wed, 03 Apr 2019 07:18:18 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554301098; cv=none;
        d=google.com; s=arc-20160816;
        b=F4pOvFlUL/ijYpP+QTRDbWfksTcyj1ay4+hkkjqqB74Iy3AQjxoYtWkPcCUcyPYsD7
         ScjbAkL/d3+cgC53TcAvGXbS5LRJZDsBb2Ql2bjF78TqCm+czi/YAtSJivBg3oybmWtk
         Ev8xTu//7U54pSsSTdrSb7VOI8RBprUvfKeh+TffZ2AlfXIqF1GPe8UI27P9MnANOCQV
         LrSdvncTvZWwxttQM0UTHtKp1U3g4v/zYONCU5VM+CwcSE07HCLUKVsQosfiYKeLQfv7
         vjaxSJdaW7JSbvbTp0ubYsKHZJ1SWRqFy3YmC5zhyxh0mTkxRxpbhmtOFlBG1xwEY0Dc
         0UgA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=82GVaLwkCHLAJuw0cg7cs7mz13Kyr233/Gpjb9qS/I0=;
        b=WyVgLfOU+8VEd/2vgWxaxgh8txc03HQQwNmY1Uq4k/oNFPHQ/hyxkxU8Miioy67umn
         /7lNJExDxdtI+zocem7J0AJJxP5fVV4ajnksQ9vJM932n9nxNGHULAsPM9mWdtXOLkgp
         M6R42ETT+piwHZO6YMueJwWQ6qfjT6Sm7upYChzQZsd+rFxIcH8UXl0femrOu9ESlRuL
         SGN49GpAjbSX7HklJ3b3CcMI8KYai9uHd/+1Xhg645kJFibOInTcz+uXIABVdoSm5FL9
         qAlbrqfEkHpjS7uEHXVxGoFIrEUs9WyHyswtv6LGdDi71vTjNsl0kxjxSmTetXhrQHoc
         Ht4g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id t6si3152240eda.289.2019.04.03.07.18.17
        for <linux-mm@kvack.org>;
        Wed, 03 Apr 2019 07:18:18 -0700 (PDT)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 426FF1713;
	Wed,  3 Apr 2019 07:18:17 -0700 (PDT)
Received: from e112269-lin.arm.com (e112269-lin.cambridge.arm.com [10.1.196.69])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id D73153F68F;
	Wed,  3 Apr 2019 07:18:13 -0700 (PDT)
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
Subject: [PATCH v8 17/20] x86: mm+efi: Convert ptdump_walk_pgd_level() to take a mm_struct
Date: Wed,  3 Apr 2019 15:16:24 +0100
Message-Id: <20190403141627.11664-18-steven.price@arm.com>
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
index 3d12ac031144..ddf8ea6b059d 100644
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

