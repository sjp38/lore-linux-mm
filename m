Return-Path: <SRS0=80m6=VT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 85810C76194
	for <linux-mm@archiver.kernel.org>; Mon, 22 Jul 2019 15:43:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 49D8F2171F
	for <linux-mm@archiver.kernel.org>; Mon, 22 Jul 2019 15:43:24 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 49D8F2171F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E76B88E0013; Mon, 22 Jul 2019 11:43:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E008C8E000E; Mon, 22 Jul 2019 11:43:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CA1AB8E0013; Mon, 22 Jul 2019 11:43:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 73E3C8E000E
	for <linux-mm@kvack.org>; Mon, 22 Jul 2019 11:43:15 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id c31so26565583ede.5
        for <linux-mm@kvack.org>; Mon, 22 Jul 2019 08:43:15 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=tVn36/eohke460Tf96oidajGI5MBBqVcYlCzmwYSLTY=;
        b=d0VATPwpH5J+RCklllvz3UtulNZLw7ZZE4jk5v5Bc5wqCChaPMAT6wbDUVMKNg3eut
         d5kFzzP5tq0chwZjQCb4cQWbwMrt/rVXTmILz/zOE74PbBYtSzQL3k2Z5mDN66v9VUoG
         bahnWihMh1VBz+67hff3GHVAQNGp57t2ZEOJQv6MR+9qcqa/Y8Y6yhVZd+x69UWZwfVc
         6lnTWswJ0OnapZykDPZkgDUvdX0nmBsDPWFDd2SC9NANs8u7mr1GTv6UnB4c4WfcnIOg
         zZGii3quH4YJlYag1Qh0KyjfFE1pJCwz4Yn6y7MNlPKrJG0Um0e3tKo5hxdAWjv8Kfm8
         oETA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: APjAAAVzNb17TqFseajRixB9+7Thf6kFDu31JH0DpNsVklIlhfcBfsjM
	GgOJcl0HDzkiJSUeToerd79BqQPTr4nxTgUabYi4g0wMuaDmanzNDOgfv3n/TSUWcJL+4x/UXpg
	3vAC5F8sUmh5YyFGWwMJahyMMtGJp2sUu1GFJf0YvqquxbV8acZ2gX4NIdTsanGtgaQ==
X-Received: by 2002:aa7:d28a:: with SMTP id w10mr60981546edq.251.1563810195062;
        Mon, 22 Jul 2019 08:43:15 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyt3zaxH0bjhox8zOZXVCM7Hnp2+lgi4RNkOitnOXzOddYRRS/aVjOOGMiLC8KWL0DAwA6R
X-Received: by 2002:aa7:d28a:: with SMTP id w10mr60981483edq.251.1563810194262;
        Mon, 22 Jul 2019 08:43:14 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563810194; cv=none;
        d=google.com; s=arc-20160816;
        b=hLXpvpqiDuUBHIsZuJ+CQb+piu4OOPZP6n08WjVpdwRhufm2AHavQYii+17/Gspgcb
         zl2/dlERD2cYG0MKQ3pUNdQHn+KuX3WZ/zOV1sPbK6BymaAY9eibr0wcGlQC4HdRCit+
         KSPFg2Qzr8QMLQD6n2qa4EoQ9V7+pRRwTc4WzKtKZeWJPtg68sZc6hBpnCYCy12lwMbW
         Bdg8D9MoD4cQaTRoisEkTmxlazrmtmFQjjlieZT6xueQfkl+X6IQr92/n9A1gYRA0CMd
         WVwJJ3l9uYuBJgWwGnAC7dW2gZwNOf0P1PWeBiAdnaTnLANE8EUks5xnsqJr52nHF9KI
         mFjg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=tVn36/eohke460Tf96oidajGI5MBBqVcYlCzmwYSLTY=;
        b=YFhFNmWzGBX8j/knzivX/BVrLWORdwINRXdFpE5JE/Y0qpkpYH9d1I1kDmnERAbETP
         oemY2eNLA1eE9x+r8DbuwJyZWbTTGMCPsot6jWdRq97QG/86A2MpdEPpFYIbZPRZlOPt
         NF0wQ9oycYwAwt0cSsv3y18sjCQkXN5KI3ZoR9HWMnFXwDmiAIK3DWuyhOd7TEc0gj1/
         neV2HH6EOSyPmGqGCgOkjsMEulO7XUZjQjac4ySgi4BdHhFjR74tNcgpwwlgWGf3gIat
         DuATBBGAxPza0sWUBSNwKdCLWskGrve6Ud7xq9TOI5MpFNau9ccW/q2JXfb+lvYllVrz
         0rxw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id b50si6638081edb.127.2019.07.22.08.43.13
        for <linux-mm@kvack.org>;
        Mon, 22 Jul 2019 08:43:14 -0700 (PDT)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 4B3A328;
	Mon, 22 Jul 2019 08:43:13 -0700 (PDT)
Received: from e112269-lin.arm.com (e112269-lin.cambridge.arm.com [10.1.196.133])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id B4F913F694;
	Mon, 22 Jul 2019 08:43:10 -0700 (PDT)
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
Subject: [PATCH v9 17/21] x86: mm: Convert ptdump_walk_pgd_level_debugfs() to take an mm_struct
Date: Mon, 22 Jul 2019 16:42:06 +0100
Message-Id: <20190722154210.42799-18-steven.price@arm.com>
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
index 1a2b469f6e75..1b255987712e 100644
--- a/arch/x86/include/asm/pgtable.h
+++ b/arch/x86/include/asm/pgtable.h
@@ -30,7 +30,8 @@ extern pgd_t early_top_pgt[PTRS_PER_PGD];
 int __init __early_make_pgtable(unsigned long address, pmdval_t pmd);
 
 void ptdump_walk_pgd_level(struct seq_file *m, struct mm_struct *mm);
-void ptdump_walk_pgd_level_debugfs(struct seq_file *m, pgd_t *pgd, bool user);
+void ptdump_walk_pgd_level_debugfs(struct seq_file *m, struct mm_struct *mm,
+				   bool user);
 void ptdump_walk_pgd_level_checkwx(void);
 void ptdump_walk_user_pgd_level_checkwx(void);
 
diff --git a/arch/x86/mm/debug_pagetables.c b/arch/x86/mm/debug_pagetables.c
index 39001a401eff..d0efec713c6c 100644
--- a/arch/x86/mm/debug_pagetables.c
+++ b/arch/x86/mm/debug_pagetables.c
@@ -7,7 +7,7 @@
 
 static int ptdump_show(struct seq_file *m, void *v)
 {
-	ptdump_walk_pgd_level_debugfs(m, NULL, false);
+	ptdump_walk_pgd_level_debugfs(m, &init_mm, false);
 	return 0;
 }
 
@@ -17,7 +17,7 @@ static int ptdump_curknl_show(struct seq_file *m, void *v)
 {
 	if (current->mm->pgd) {
 		down_read(&current->mm->mmap_sem);
-		ptdump_walk_pgd_level_debugfs(m, current->mm->pgd, false);
+		ptdump_walk_pgd_level_debugfs(m, current->mm, false);
 		up_read(&current->mm->mmap_sem);
 	}
 	return 0;
@@ -30,7 +30,7 @@ static int ptdump_curusr_show(struct seq_file *m, void *v)
 {
 	if (current->mm->pgd) {
 		down_read(&current->mm->mmap_sem);
-		ptdump_walk_pgd_level_debugfs(m, current->mm->pgd, true);
+		ptdump_walk_pgd_level_debugfs(m, current->mm, true);
 		up_read(&current->mm->mmap_sem);
 	}
 	return 0;
@@ -43,7 +43,7 @@ DEFINE_SHOW_ATTRIBUTE(ptdump_curusr);
 static int ptdump_efi_show(struct seq_file *m, void *v)
 {
 	if (efi_mm.pgd)
-		ptdump_walk_pgd_level_debugfs(m, efi_mm.pgd, false);
+		ptdump_walk_pgd_level_debugfs(m, &efi_mm, false);
 	return 0;
 }
 
diff --git a/arch/x86/mm/dump_pagetables.c b/arch/x86/mm/dump_pagetables.c
index 6f0d1296dee1..bcaf27b637e0 100644
--- a/arch/x86/mm/dump_pagetables.c
+++ b/arch/x86/mm/dump_pagetables.c
@@ -519,16 +519,12 @@ static inline bool is_hypervisor_range(int idx)
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
@@ -573,8 +569,10 @@ void ptdump_walk_pgd_level(struct seq_file *m, struct mm_struct *mm)
 	ptdump_walk_pgd_level_core(m, mm->pgd, false, true);
 }
 
-void ptdump_walk_pgd_level_debugfs(struct seq_file *m, pgd_t *pgd, bool user)
+void ptdump_walk_pgd_level_debugfs(struct seq_file *m, struct mm_struct *mm,
+				   bool user)
 {
+	pgd_t *pgd = mm->pgd;
 #ifdef CONFIG_PAGE_TABLE_ISOLATION
 	if (user && boot_cpu_has(X86_FEATURE_PTI))
 		pgd = kernel_to_user_pgdp(pgd);
@@ -600,7 +598,7 @@ void ptdump_walk_user_pgd_level_checkwx(void)
 
 void ptdump_walk_pgd_level_checkwx(void)
 {
-	ptdump_walk_pgd_level_core(NULL, NULL, true, false);
+	ptdump_walk_pgd_level_core(NULL, INIT_PGD, true, false);
 }
 
 static int __init pt_dump_init(void)
-- 
2.20.1

