Return-Path: <SRS0=kLvD=R7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DBE1EC4360F
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 15:23:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 8A3202173C
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 15:23:06 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 8A3202173C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 67B5F6B0273; Thu, 28 Mar 2019 11:23:01 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 629D96B0274; Thu, 28 Mar 2019 11:23:01 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4F1086B0275; Thu, 28 Mar 2019 11:23:01 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id EE63F6B0273
	for <linux-mm@kvack.org>; Thu, 28 Mar 2019 11:23:00 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id k8so5122992edl.22
        for <linux-mm@kvack.org>; Thu, 28 Mar 2019 08:23:00 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=82GVaLwkCHLAJuw0cg7cs7mz13Kyr233/Gpjb9qS/I0=;
        b=DUvruicbE6Qv+WSX6PYcyJ4ItjF+HHZlfyzwHYh8TSFrpzM+3iS9eIYNpp5us3aCI2
         2lo0Xwh/xmqDHWvQYH+jUEhTNQA7LRtdE5bwJM3XQIwtyJ8U6Cagb0D4fDiAsftbzwdM
         bed+v5UUkxBIWgvceBNNBmgG4up/vANbYyTjc0YTXRdDM0xfcAZgWMmyTqYrsyEQXPEe
         aYzO7wRDEeREP5rJUXLA3LypsuboH1rO4xWew5c2NsWgIBsQ116L+bvrt5dV6Kki7nxw
         cG7kAnpTFhI5gu7O+3ptcMZkDSuev0fodI5Vw1/lhzm4xTRtm8bYMU93b2ZSHVhXCuK2
         xgtg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: APjAAAW9FpNzQtURkRoh4VojdJ68fVTk1+n2vVRnPC5iBJ4zq1QrKKfh
	vM6mujuR017ceI4gmf94z3tjYAD14V+D+D3D4JmDNcZa6+DYZdsoguMRaErRDIJSdYEy8r622cR
	uo2yGTGihiPvjor2Xa6JtyXWvWpIE+c37IkchEibvC3wP1yPPZstFMMMi/XO6ksGo6w==
X-Received: by 2002:a05:6402:608:: with SMTP id n8mr28449967edv.136.1553786580494;
        Thu, 28 Mar 2019 08:23:00 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzHMNCOtuIjQ//4LkUHCxtNuavjXbIN9l4yw4SqxrfoUBvWSXReZTJWVV9SF0oAWhBSIYEl
X-Received: by 2002:a05:6402:608:: with SMTP id n8mr28449900edv.136.1553786579012;
        Thu, 28 Mar 2019 08:22:59 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553786579; cv=none;
        d=google.com; s=arc-20160816;
        b=GsPDFJ+CWLu+QZsu7PXKkXILAp2qS7tw+OhKa2F/2IMn0sphODqblrI7VGupjnUJNJ
         CU0RPO/+te8RJKXG8WWowLg2UfghO4ZSKViiUszNo2TTqDZItxrIfFK1DO3lz92Z0ltV
         Gdl4usXSEKgSsvRen8y1rwNwAZmSxEOXhkJmFVz9hGDHINUpnnkIaF8YomHQk+C7oWgN
         tgLs7g/bkIkle9z+gB9MzepuwI0yD+q412enICB3Cq7elBrbl6FUz5VhiJXhrq+ENdBO
         kYvbUcf7pciMUCLzBSxfwSqJnncR7v3o46Gg8wGnbIHx1K6W/gCTT/i4y6bEYA2X/M0K
         2H3A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=82GVaLwkCHLAJuw0cg7cs7mz13Kyr233/Gpjb9qS/I0=;
        b=Eh2EXiDuu/WtE0oXO+HIuJwV+qZGKsVj44Ypv4ZFt5nf51AOhNI9dttJ851DKT6aTZ
         0SylQTv3Ef9u6CNaV8nd948oASu4QOVNOIHnvqtINoLeh+BJiw2CFqwLwNW4/e5ZHxoB
         L5LaUBQSWar+kTqNz9WTDMwFwCDnmMv0MfsRHm+RUuFEPVh4yZ3uy7JLY02vb9XCODGD
         VB2OhzDm5CnbK3lWv4gCFGCxqmFRFT2vF68QDLkXJSxf7j2+S6IV5rotCR9OaSkmbiR1
         VHmFtlCTAKVAu/zXvegaN6NCPMsh0WpLv7cVql7aYiC50KLmI6WA8mzHZ0GzMVbZ/aY9
         RQwQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id w7si1708609edu.115.2019.03.28.08.22.58
        for <linux-mm@kvack.org>;
        Thu, 28 Mar 2019 08:22:58 -0700 (PDT)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id C649C168F;
	Thu, 28 Mar 2019 08:22:57 -0700 (PDT)
Received: from e112269-lin.arm.com (e112269-lin.cambridge.arm.com [10.1.196.69])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 7DF2F3F557;
	Thu, 28 Mar 2019 08:22:54 -0700 (PDT)
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
Subject: [PATCH v7 17/20] x86: mm+efi: Convert ptdump_walk_pgd_level() to take a mm_struct
Date: Thu, 28 Mar 2019 15:21:01 +0000
Message-Id: <20190328152104.23106-18-steven.price@arm.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190328152104.23106-1-steven.price@arm.com>
References: <20190328152104.23106-1-steven.price@arm.com>
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

