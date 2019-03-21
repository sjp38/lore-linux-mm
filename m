Return-Path: <SRS0=0MJS=RY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id BE47CC43381
	for <linux-mm@archiver.kernel.org>; Thu, 21 Mar 2019 14:21:35 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 862DA218FF
	for <linux-mm@archiver.kernel.org>; Thu, 21 Mar 2019 14:21:35 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 862DA218FF
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 586AA6B0277; Thu, 21 Mar 2019 10:21:11 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5363F6B0278; Thu, 21 Mar 2019 10:21:11 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 451446B0279; Thu, 21 Mar 2019 10:21:11 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id E172A6B0277
	for <linux-mm@kvack.org>; Thu, 21 Mar 2019 10:21:10 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id o27so2279817edc.14
        for <linux-mm@kvack.org>; Thu, 21 Mar 2019 07:21:10 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=QI1ft8uG/6LmqX3YnTkHhfrqxc9+RDV6RJGxqI2lX8w=;
        b=GSIuQ7cd8bfNPfqwdPKqFPs5U6lkSv2P7HoHWJxUQ/fQRbojBVmJ9HAvRhqCffNZUK
         WEYJDJOdl5EZexPS95Myiy7HU4KgF2Kf5rcGPuOjRO918w9DVPZOCJCJCbFZMCYxCXj9
         OE6fLrlwIAKTKpMrr2Ca3k6pI4rfsZyaq2gJQlBjIEs0F9i3qe+DmDsxT+VjjPvaXvq2
         3Xes3qmQDs1GAl1rusv1O4SJGwOQNOfQJ5K4x1v90OTqr95+nfHNE9sNVmIizMcjy5rO
         ylAJYCClifjIsBz29GkZQEIzvVv4ahTp/a6wTeqenHqblsKkFGHQoKvA6KJM2n/8vZ8G
         5IFw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: APjAAAWdxcpAR00COwGFRw8di+MoUPKl91RICryqhDLSIElM+dnMHxoQ
	aj+gvDBsK8h/Wc2p50REWrdki2vv/4NODHidNNfcTzAdgpyBmr1htvT8vlxTSTCStFcTsICe8YI
	qRdMjkfT4OfbByKKRJ6BEIe4QHLKEFVXnluutI8KgiuUpcXhccjMhJc7mWyF0weyqxA==
X-Received: by 2002:a17:906:708d:: with SMTP id b13mr2363072ejk.120.1553178070441;
        Thu, 21 Mar 2019 07:21:10 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxgs1x9XcDLpCnhRPVb0+GB0NmeZ6dm7X4+SO4Vpmh8cK3RDzo52S4MRqThtOMu/mJBeBm5
X-Received: by 2002:a17:906:708d:: with SMTP id b13mr2363033ejk.120.1553178069449;
        Thu, 21 Mar 2019 07:21:09 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553178069; cv=none;
        d=google.com; s=arc-20160816;
        b=Wd2S2baUihNObolVNvar1Q9FZaLx4GV1dtzde8Qo9Z84EUOI/ZQC2E3omL7RO9mc8N
         Rir6KyeebOE+hlql1i9oJIaKZqFcnoUESMBWhtLK7/Nl3BHBeF6alV7WDjivNF1ZBeF2
         BV6h2c9NiPvj6qosZKd0uW9Ym9yKjbZC0ek98YVaTXRo1EQQuNX2/iphvWx5N5UWuXeB
         pGLbxs36n4Jr9e+5gFBSr62hh2X1QiiMpOoTPNN9QMFQ4Xi8h3hgOKhfrsdzYt4ug69P
         jB1bIqElQ2g9p8bK4pkp8VY7xr5BWPwlAHceM9NTq2wJaZxmWTZv1kMdp2cMoapdg8Q3
         6RfQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=QI1ft8uG/6LmqX3YnTkHhfrqxc9+RDV6RJGxqI2lX8w=;
        b=rRzp+M5+bFJ1PeSgX+tc0kIZGUfqo6M9BR2LSiPZaFwDJGEMIGKr7hsvXI2NmKwvuq
         qm/4pba5L9Cu3kERJMsaAjsSr++GPK7s80Kyv4LBWOg/7WvVo11Q0ib2HJd7IVmRfgJT
         o8YzgDL99JMguGPb93MEMfi8P0B4zUJqBJIUbzYFMhTPcvogZBrqmrLRBkFl1AUy/bsC
         gdGtQ6zZZDraiXZYgwcSnwT+IV/QsEcgOTWff0flWufGmIX9xnbZ42sHRpm94rpnR+uH
         lNerLUF9bD5OC2NXNS7tBfnxsdyZ3eJDDIPxWbvIsNDrUB53e67EVbSBJAldyjND92rA
         EFCQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id e3si2150862edd.270.2019.03.21.07.21.09
        for <linux-mm@kvack.org>;
        Thu, 21 Mar 2019 07:21:09 -0700 (PDT)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 6EB6F165C;
	Thu, 21 Mar 2019 07:21:08 -0700 (PDT)
Received: from e112269-lin.arm.com (e112269-lin.cambridge.arm.com [10.1.196.69])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 31C9C3F575;
	Thu, 21 Mar 2019 07:21:05 -0700 (PDT)
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
Subject: [PATCH v5 17/19] x86: mm: Convert ptdump_walk_pgd_level_debugfs() to take an mm_struct
Date: Thu, 21 Mar 2019 14:19:51 +0000
Message-Id: <20190321141953.31960-18-steven.price@arm.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190321141953.31960-1-steven.price@arm.com>
References: <20190321141953.31960-1-steven.price@arm.com>
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

