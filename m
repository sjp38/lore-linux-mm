Return-Path: <SRS0=vS5V=Q4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 08997C4360F
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 11:36:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B669F2086C
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 11:36:02 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B669F2086C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B37668E007E; Thu, 21 Feb 2019 06:36:00 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AE8B28E0075; Thu, 21 Feb 2019 06:36:00 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 966418E007E; Thu, 21 Feb 2019 06:36:00 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 36F888E0075
	for <linux-mm@kvack.org>; Thu, 21 Feb 2019 06:36:00 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id a21so10232812eda.3
        for <linux-mm@kvack.org>; Thu, 21 Feb 2019 03:36:00 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=1HaF7HdEQu5nvTk+zAQqC41ZLRHJB1dniFbJzkE+I4g=;
        b=D02KGzoWSXpQ26d7aP5ufMJnxSw28stbWekmZhlnv37eiT/JS86cb1lnfHtTDObS4p
         ul6VNiS8R8SHnYta5+ahnGQ5VDRzluZwVpfHmCQ7GQOC2e83QqmbInH0Z4DEHzVp7ei4
         cnbG2XgM1SJ/Abo3QHujGvFRwW3AqVsukWLERRR2zvsZgV7xkU3W0Z8wtWj7qGtH23iM
         wk6CeAeuR0oME6N0EPDAQOIhspRAYuPcjfwy2evaBfxaLgZjHv5stKdXR30k10Xnltqy
         XfNkueFNGSYO/t2ID5u1HhPeLQlweNuIbKE7dCn0AqchyoL7+j9n9t9PAyzn+HTPP1dV
         MwJw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: AHQUAuZWpCsOMLUcM7V5jV7Rh/b4G8Av5+WD4JZnhdJEVksW2l9LL4Ch
	3vHifP3ddnc1tecGvJWMD710w4gMmjvNsgVgOyCxaXvoZ2Lf6Q+T0jLCF5zTV3lrAXwQH57tq1b
	ceoUAsIyHxa8hy2dLuNqM+TD2q2+E1z/LmA2/UdsVvvQLeIslc9Mw3d8EuODThNn0qg==
X-Received: by 2002:a50:910c:: with SMTP id e12mr21680594eda.259.1550748959713;
        Thu, 21 Feb 2019 03:35:59 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYK53pUlbsxzCHC2I5TxEZwc6uKM19yndtBSuZRMI7AHcphuCVNa3aKjKyalY9eWd7Wt4P3
X-Received: by 2002:a50:910c:: with SMTP id e12mr21680539eda.259.1550748958679;
        Thu, 21 Feb 2019 03:35:58 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550748958; cv=none;
        d=google.com; s=arc-20160816;
        b=bW0PybuACR8QPrPrMHOuD/IQyf3NWBXAfFeeEnGL0CquR4fXuLfdHmoVuz0NnCN5ol
         V6iE71IIWdmsDq9DyH1FUfVwAYzhDkdumYjZMnuhBx/IuWU3MsHy/C5A/KQViHs5m7rZ
         SVzjL/TuEZdmnKejKBikLvItlRS3fxsERmpc1NnmroLHI0m8Y5oq0k7oRwufxYVlbm4q
         J/ZVTB2KxDtpwXGsNBGtIcTKVUypEBFmgJoHyAxalcK7dIOvwZOW8lRrllqFdYoeIGH+
         9RHjosq6DTwSDmVNaT11l7YiKjND8hM98Q/4hpfwnsco3etM9WPd5QHq2QGWnkwQZC6c
         xwUg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=1HaF7HdEQu5nvTk+zAQqC41ZLRHJB1dniFbJzkE+I4g=;
        b=fTirzOGXMRSz4jYZzQNWF0X6TuHBMp1MS1MBZ3o/QnVwBj4bw3zS2lwrUUzFjHn+4e
         XSnkeJ2jRBdrGNxfjrRGtW/JZ5wcczynX2qvXipaD237GqtduHdqYN+RY81PlHtaaP8B
         XLb2qr0WHWSTtibBEIF56+0/oQKR3P1/LwWV9y9wqjFnoJ/83HHuMNzyo99Vnddytmqy
         vemkcASgHLKqc0f8qARTPO73q10QpTSnCYJiYgBttl0xSUKURKZ3QLkUeWGLvti8DGEK
         fcbiMdo52ZmRcW/vkaQiE89koCKTBi9arsvyx3twjqJcwPzsFvB3IDIGcduLaAGz7obf
         aErw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id a3si5582760edi.17.2019.02.21.03.35.58
        for <linux-mm@kvack.org>;
        Thu, 21 Feb 2019 03:35:58 -0800 (PST)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 88DFD15AB;
	Thu, 21 Feb 2019 03:35:57 -0800 (PST)
Received: from e112269-lin.arm.com (e112269-lin.cambridge.arm.com [10.1.196.69])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 07E943F5C1;
	Thu, 21 Feb 2019 03:35:53 -0800 (PST)
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
Subject: [PATCH v2 11/13] x86/mm: Convert ptdump_walk_pgd_level_debugfs() to take an mm_struct
Date: Thu, 21 Feb 2019 11:35:00 +0000
Message-Id: <20190221113502.54153-12-steven.price@arm.com>
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
index 07f62d5517da..8b457a65ad8e 100644
--- a/arch/x86/mm/dump_pagetables.c
+++ b/arch/x86/mm/dump_pagetables.c
@@ -526,16 +526,12 @@ static inline bool is_hypervisor_range(int idx)
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
@@ -580,8 +576,10 @@ void ptdump_walk_pgd_level(struct seq_file *m, struct mm_struct *mm)
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
@@ -607,7 +605,7 @@ void ptdump_walk_user_pgd_level_checkwx(void)
 
 void ptdump_walk_pgd_level_checkwx(void)
 {
-	ptdump_walk_pgd_level_core(NULL, NULL, true, false);
+	ptdump_walk_pgd_level_core(NULL, INIT_PGD, true, false);
 }
 
 static int __init pt_dump_init(void)
-- 
2.20.1

