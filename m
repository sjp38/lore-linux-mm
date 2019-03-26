Return-Path: <SRS0=c5Kt=R5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9D499C4360F
	for <linux-mm@archiver.kernel.org>; Tue, 26 Mar 2019 16:27:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 59DFD20863
	for <linux-mm@archiver.kernel.org>; Tue, 26 Mar 2019 16:27:43 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 59DFD20863
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E47C16B0283; Tue, 26 Mar 2019 12:27:40 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id DD39B6B0284; Tue, 26 Mar 2019 12:27:40 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C07206B0285; Tue, 26 Mar 2019 12:27:40 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 6DE646B0283
	for <linux-mm@kvack.org>; Tue, 26 Mar 2019 12:27:40 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id c40so4238632eda.10
        for <linux-mm@kvack.org>; Tue, 26 Mar 2019 09:27:40 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=QI1ft8uG/6LmqX3YnTkHhfrqxc9+RDV6RJGxqI2lX8w=;
        b=g/5+CecAfouwgJ0q3EIAoI9+jTwWOaI12MSq31ILSEghAkRuCJGgAdw2yC+g/VqBDZ
         fCBIm3RT0IIrAwhnimVdpRslP9LOqZ9hMyp3AGmVUG+vVJmOHLH9/TPqOXD03Z32HglM
         VUc48H19kIO6nvuesjT/WqZZVgWH7c/BGuQAXz6HWP13V5srzm/WqLuHnI2P2upJGKv+
         sOyXv5b73l11fhd3x7cH/j8IHjEWT4OzHevtekK/T1w7kxV+Oaa+bOC4N5RtlUeMhBxw
         YbYCPo37+IS4lR3YYSg8rzcq/dwTGH236dapRBhFE/SQqxmt5TOoT8gf1/BlQqsOuw4E
         WdMg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: APjAAAWTlcteIPv1f4q+FBOuMquXDdcnfSBog/2J9pTSQgAFsRsTTzgx
	6zgfV14sRJj/PnXvfogR10fRLfVUTOrI7uthCcbCslZyzgTIwBRpAcakjqLAgK4uR/3HhPG7zYD
	u2B9KsUNc753qSrw53es5aeags20Mw74y3euqy8+E1yHs4b8MqR8RftODSKHRdvSioQ==
X-Received: by 2002:a50:eac9:: with SMTP id u9mr10452484edp.159.1553617659951;
        Tue, 26 Mar 2019 09:27:39 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzclWfq3l4pHGs/e6umc+WeO7LfYhGJiaKg6VjqRhvmp86FHaRHzuHIOfC87xDuupxpCdKo
X-Received: by 2002:a50:eac9:: with SMTP id u9mr10452434edp.159.1553617658949;
        Tue, 26 Mar 2019 09:27:38 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553617658; cv=none;
        d=google.com; s=arc-20160816;
        b=peLFUMlvnxhqqwhQLAHLu/19b4hWz6bNX5ffcMxovUqbnwDPeFK+Vqa0uNsrAEWdvM
         8QkjLcubyC1Qs6/QzaTdK/bT3lfS4TfgPeRCwH8b49YIpTlnx3kfO4VNDsd14C4R0sYZ
         4HFxjNEeR8BDVOb50dJg+VkECZ+tQ1P/QLpt8BP5u1FKNoREOCnAqXBEf/VdBmc3Umqi
         bTzkF07qwIzafV6ElSMYwons0973zqupFK1y1+yJwmorq52Ur5kkSu5VLvLW5adWxSuE
         LVHOPlPiHzYFBzvntQcApIorqoiMt30DyexEz4anVhDvKQykW6ZlW16N/9YR8dBwLmsG
         5Now==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=QI1ft8uG/6LmqX3YnTkHhfrqxc9+RDV6RJGxqI2lX8w=;
        b=IzkDvfgXpYw6iMKcQepzhMlJa8u9y80rZOI2X9JkKULbd0IYrp0w+pnnLWBVlclzIv
         +/meuFuNcbRe44vdI/JDqRG3LtUyp16OyWwdfpIFrsUDBlF4HzOfovRLoSsu3wpyzA9b
         fSroA+PbNJcio8C0OLpTsHBVD1Ge/vK27cxLO6w3nAGmSIuhf3zQ/mWukPOL6q1x93ME
         HR4FQw9/ATax7UG8O5PMoBbW2WmBCYShPEdsb4KQTnCvEEDg1ODdL3VNsCd4AgmiCTeC
         cYvLsNAULE49W88ktt9Ss0z8qVby66usJDmtQPbnf2w0PQysRv+NEPjrvSNwmcIGgw0E
         YSjg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id q8si2028942eju.121.2019.03.26.09.27.38
        for <linux-mm@kvack.org>;
        Tue, 26 Mar 2019 09:27:38 -0700 (PDT)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id EF6221B4B;
	Tue, 26 Mar 2019 09:27:37 -0700 (PDT)
Received: from e112269-lin.arm.com (e112269-lin.cambridge.arm.com [10.1.196.69])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id B256C3F614;
	Tue, 26 Mar 2019 09:27:34 -0700 (PDT)
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
Subject: [PATCH v6 17/19] x86: mm: Convert ptdump_walk_pgd_level_debugfs() to take an mm_struct
Date: Tue, 26 Mar 2019 16:26:22 +0000
Message-Id: <20190326162624.20736-18-steven.price@arm.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190326162624.20736-1-steven.price@arm.com>
References: <20190326162624.20736-1-steven.price@arm.com>
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
index ddf8ea6b059d..40b3f1da6e15 100644
--- a/arch/x86/mm/dump_pagetables.c
+++ b/arch/x86/mm/dump_pagetables.c
@@ -525,16 +525,12 @@ static inline bool is_hypervisor_range(int idx)
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
@@ -579,8 +575,10 @@ void ptdump_walk_pgd_level(struct seq_file *m, struct mm_struct *mm)
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
@@ -606,7 +604,7 @@ void ptdump_walk_user_pgd_level_checkwx(void)
 
 void ptdump_walk_pgd_level_checkwx(void)
 {
-	ptdump_walk_pgd_level_core(NULL, NULL, true, false);
+	ptdump_walk_pgd_level_core(NULL, INIT_PGD, true, false);
 }
 
 static int __init pt_dump_init(void)
-- 
2.20.1

