Return-Path: <SRS0=80m6=VT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 84CDEC76190
	for <linux-mm@archiver.kernel.org>; Mon, 22 Jul 2019 15:43:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4C9D32190F
	for <linux-mm@archiver.kernel.org>; Mon, 22 Jul 2019 15:43:20 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4C9D32190F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9BC5F8E0012; Mon, 22 Jul 2019 11:43:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 94A968E000E; Mon, 22 Jul 2019 11:43:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6FB148E0012; Mon, 22 Jul 2019 11:43:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 228A98E000E
	for <linux-mm@kvack.org>; Mon, 22 Jul 2019 11:43:13 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id c31so26565527ede.5
        for <linux-mm@kvack.org>; Mon, 22 Jul 2019 08:43:13 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=e+D/bNblaWHksT3FIh7wtQ5Ym2FMIUB1cczZSKIH7dE=;
        b=VDVtMcB5Gf2aRKKGj9dzUhf6koNbSz5UMr36lKFoHeLsT2Ycco9+Zo/v4SaOJ0PFke
         lb0CsN/Vl4f4BCiWhk6HOycHGKPbn22n+fEglsgfmgIhmzGZ37dzFFytOco4E2lKySuo
         fixIHCEJyvJmS1CRelDAigILM3QJ/NKWnz0xYEPELtwJ/W+Mbb0xdL/kc1ee80PTMkZU
         oEm72leUIKYplBMqN3Nz/7OBrN6FAEV8mUgMxZlJJQbXhj+YgcjZX3AldzLi+2c+Y6/l
         p3TI4VpaCD6uKnDBqnrFLOvCg4AptU7Ox6eQwLKlAwGeKFMQdJ9AU1TD/RMdKmy12Rfa
         eluw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: APjAAAV5HvidHxCqFmXl+Vot2tAWVZjS+FiHxly/2PEYxM1qZV8AXYTM
	OB4jKxgkWf3/qYr5D8i+rHub4Cm9l6rWrN21VzD8v2ohNp643jVVDHMwy9TEx19D/AlAsxNYV8z
	gb99EzFeixJ8hSwEaOU79wDAVxyFwKqdaRCOjTE4ZMk+2shlgK3AG2g1Q0ynjXvetig==
X-Received: by 2002:a17:906:ece7:: with SMTP id qt7mr54335241ejb.155.1563810192697;
        Mon, 22 Jul 2019 08:43:12 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwCIJXhEBsFNIk+gquF4+m2W66HXTO+0MoJIfqvqj6OkOhPy1WAQUWnS1I44cDQDtsdlv+F
X-Received: by 2002:a17:906:ece7:: with SMTP id qt7mr54335166ejb.155.1563810191386;
        Mon, 22 Jul 2019 08:43:11 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563810191; cv=none;
        d=google.com; s=arc-20160816;
        b=HQ+naqkjpeuQjv1MzjSFEM2h6R+GFJSujTGguuzV5ygh1zL+B19k6AOwZ/cDN6S2i7
         RTnQ5dryH48fcrCj/dVt02o7RjJsk7Np1gu4MSsmyuotMtIuEE8rYtbP+EIvTVtUGhwr
         xutdgGel0JLmn2bZZsAw84/KfqDrA6jn9j+iv4uL6TcFevY5UikiY26ao8E/wnfJh/ix
         e8wi5To6DKA9FIEuHK9FyvWvA+x7lrYGVW099IlsF+/KT3z/oYdD31b+K+rSk4GHMK0J
         e2LGDwL7xjIu7jmbl5eXEMaAFCPJo64s7cd/wEjEtfZzeKxug9NzzV5kxkep2AQhaXv0
         Tlmg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=e+D/bNblaWHksT3FIh7wtQ5Ym2FMIUB1cczZSKIH7dE=;
        b=pNPBzQnPHX/WF1wHGDgaHehdzFyYcyPcHa9crrk3q/VbtW2ULwi3SOmtfXg1qU9mop
         AoqVdzXIzWJ7kKrWPKPGunAWA/VOjp9zUHKujKqXap1380H0OObTJvAQdPpjUIdUSCpc
         Ach7UaEA7tC//FMdLnWeubP6o3l23LQDYj8hbBW9IIRN86h7AaQDlnDXs6E3z2T6/lud
         RWkGyNl10GD7a6dhIDmbfw6R4yvqtd31Wx+qAaDhPEQYBaGLr71qKIZrG931Y4yC584B
         3vVcCYvkAkULTN0V34+mKdRcHXnMYAsd8q9rdnhFxYSiPpyfW4MxqzILCpD63ewljH/A
         5A8g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id s18si4990902edd.291.2019.07.22.08.43.11
        for <linux-mm@kvack.org>;
        Mon, 22 Jul 2019 08:43:11 -0700 (PDT)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 7F0791509;
	Mon, 22 Jul 2019 08:43:10 -0700 (PDT)
Received: from e112269-lin.arm.com (e112269-lin.cambridge.arm.com [10.1.196.133])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id E99833F694;
	Mon, 22 Jul 2019 08:43:07 -0700 (PDT)
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
Subject: [PATCH v9 16/21] x86: mm+efi: Convert ptdump_walk_pgd_level() to take a mm_struct
Date: Mon, 22 Jul 2019 16:42:05 +0100
Message-Id: <20190722154210.42799-17-steven.price@arm.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190722154210.42799-1-steven.price@arm.com>
References: <20190722154210.42799-1-steven.price@arm.com>
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
index fe21b57f629f..6f0d1296dee1 100644
--- a/arch/x86/mm/dump_pagetables.c
+++ b/arch/x86/mm/dump_pagetables.c
@@ -568,9 +568,9 @@ static void ptdump_walk_pgd_level_core(struct seq_file *m, pgd_t *pgd,
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
index 08ce8177c3af..47a4c6c70648 100644
--- a/arch/x86/platform/efi/efi_64.c
+++ b/arch/x86/platform/efi/efi_64.c
@@ -614,9 +614,9 @@ void __init efi_dump_pagetable(void)
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

