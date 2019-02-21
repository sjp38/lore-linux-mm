Return-Path: <SRS0=vS5V=Q4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3042DC43381
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 11:35:58 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id ECF382086C
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 11:35:57 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org ECF382086C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D80268E007D; Thu, 21 Feb 2019 06:35:56 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D326D8E0075; Thu, 21 Feb 2019 06:35:56 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BD92E8E007D; Thu, 21 Feb 2019 06:35:56 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 591448E0075
	for <linux-mm@kvack.org>; Thu, 21 Feb 2019 06:35:56 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id d31so7281079eda.1
        for <linux-mm@kvack.org>; Thu, 21 Feb 2019 03:35:56 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=A6FWLpEKbC8B3Rr+irQKv2sIC2Ggbgddq6ZimVEhPUk=;
        b=lp2OVFMBXyWdQ/6dNHC68UEX14m8y+IIebh+jEGqzBp4MZv7L5l16k2u+jn4gwdhzt
         V59PpT1PgtVFFVI8YtUPc/sPk18148F6pmIi8iMuqh2CxsHFcHjg6cY2Tc1Ef3AHMb+Z
         yyWjzlVWyAAaUAlYhIJjN2+eZX22dbZ+/HO+nhZjkzMEW3ruPv/sFlQMagtoagIvr6al
         LvpqM9U+x5/5rTsBcX4FvMcL6LKKIfCfu55bP6cSHWYn58Pk8RtoQHX22nmk1HTHomEh
         hdDKrCQhbLylsdXxT8vWDKs19fuiPvW7YwYvejgeK7QjmcMLZBmEItj1znZkWzP+85SW
         0USQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: AHQUAuZvocH3IShmcn7xpV89ZE6j0t8DgnBolzYB8zCuFqCkW+dHlkIR
	I2+0hcqlbKO2zM1D3qb4MrUIyogrHBKD7Ln/mwol/BZt/uoa/13ee8yh5LRj+MKmW9mtxVe4fck
	fB2mxYRiFvM0zDQXHyvDuycbxG0DnW9zDbDhPIrbc5Qypy45J0Ox+sH9dlFZi+SJtrw==
X-Received: by 2002:a50:a741:: with SMTP id h59mr29446003edc.106.1550748955850;
        Thu, 21 Feb 2019 03:35:55 -0800 (PST)
X-Google-Smtp-Source: AHgI3Ia1pYi9MPjlHuHlg/t1TTQv2hvyhJ5B6TKAZnZ7FkQBMObsYLdhPHLxy05iT5ZQ52r+ybdZ
X-Received: by 2002:a50:a741:: with SMTP id h59mr29445953edc.106.1550748954835;
        Thu, 21 Feb 2019 03:35:54 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550748954; cv=none;
        d=google.com; s=arc-20160816;
        b=do5n5kMm38os2YjOzQf5olm4vgij0TvBBzN+MCIp3zI+l8MmhaVZeusfGjAZoWb0an
         c/53z7CCSSaYk/8CB46QGWrMkf4B13OwZ8ndMj/vpXj3dSQnhaoByusJrehJlrzjJf02
         8hgfr4y4YWkGeprAsFScEdXgURm5uUeAhDdet+chfPW4ljxOZaTPKqjdG9GafWC/YRxx
         ak81JflYLuJMqFaHLYvzXon6153G3DRAwNFu7IYKEIxEcDUTz2FyI2F7Cb/RN7jadu9W
         LgWr5+hHQ+Di2YSkuTslW0uo4KGZoJgUDc6TXU8Hff5LuXhadqal9wquoX+Pch1fRpvv
         OFBw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=A6FWLpEKbC8B3Rr+irQKv2sIC2Ggbgddq6ZimVEhPUk=;
        b=jQ3IuK/0DuI8Ea2iLvdi8Y+8lUmKWAUwlztj9ezoI6KifKI8zboxPWjW+/f2naj3lt
         RyP2YfGvByk430L5aYZGXoM3e3Tnar+47UmZmavQgjIEHEtL+gosPGAya5dLg81MYn5Q
         zbOWQH12HYbozHPvjElwUoSFOR60xvwVD/ztB7X+8tPHJQFDj3D2L1ENbst8bKoMdWA/
         WhAPipPbZfrGvWQ75cWH8kzUmLoOLmTdb34oLB5r26i4bFJdVuiKgUuRtT5L9HjCldAh
         fjEU4pJ588iR6QWgmxCMRNOJPTq30agmAf60GyQGwFGboKlbIHlk2D+KoMXgm3G0GgKl
         gC+Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id by17si7098953ejb.40.2019.02.21.03.35.54
        for <linux-mm@kvack.org>;
        Thu, 21 Feb 2019 03:35:54 -0800 (PST)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id B9D1A1715;
	Thu, 21 Feb 2019 03:35:53 -0800 (PST)
Received: from e112269-lin.arm.com (e112269-lin.cambridge.arm.com [10.1.196.69])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 397C03F5C1;
	Thu, 21 Feb 2019 03:35:50 -0800 (PST)
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
Subject: [PATCH v2 10/13] x86/mm+efi: Convert ptdump_walk_pgd_level() to take a mm_struct
Date: Thu, 21 Feb 2019 11:34:59 +0000
Message-Id: <20190221113502.54153-11-steven.price@arm.com>
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
index b1b86157d456..07f62d5517da 100644
--- a/arch/x86/mm/dump_pagetables.c
+++ b/arch/x86/mm/dump_pagetables.c
@@ -575,9 +575,9 @@ static void ptdump_walk_pgd_level_core(struct seq_file *m, pgd_t *pgd,
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

