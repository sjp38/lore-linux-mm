Return-Path: <SRS0=x8zE=RC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 10566C00319
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 17:08:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C388A20842
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 17:08:33 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C388A20842
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id D9DD58E0023; Wed, 27 Feb 2019 12:08:31 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D760C8E0001; Wed, 27 Feb 2019 12:08:31 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C65E38E0023; Wed, 27 Feb 2019 12:08:31 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 6B9E88E0001
	for <linux-mm@kvack.org>; Wed, 27 Feb 2019 12:08:31 -0500 (EST)
Received: by mail-ed1-f69.google.com with SMTP id j5so7175523edt.17
        for <linux-mm@kvack.org>; Wed, 27 Feb 2019 09:08:31 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=OsM61sR7KtxeUBiEjMTBAbQYMmMZy1tlMKtG+lRZsQM=;
        b=eAOXngFWE3fNPotLDsNh0jkucl58Ez8K6+24P0zgJ+2Lj3C99J0T0LXItN9Vhh9zDz
         m1sJvhwXpHIn/UNKNjmLfME/+deg1BmiHQ+Z3kUd7J+g5YaEjTaa07uH97em7TWGXq93
         DpMl8Szlh/hP9KyZ3beTNqm2roZSkU3R/A691N5NrjhPxZA4tS0I7bc/ehnslxKTOQBz
         /4XX7vhwAxo1JVyzafN63aieNsbgo6mSGQszwl416U3kebAP+BdHWKrp0V52JkqlRuO7
         CRB18UwgUbtvKH6vBtqNoY49xKrEGL5/zC0jPdiftzQz0qFMFgp35QKeJL22KtCfrd45
         Pojw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: AHQUAuYPgIrxKRt8mHG1wZc1HmYS2v0jSBIpXziUxr2wpONMfFaQE0gE
	pZ4kHD/qP+HEFXokwTeyAsR+7sPkigFjx7gjTCMyESSY5ecRwfEpVXmvK7QMWhJ51wwb67JQSs9
	X1uifzaSg4Es82uK2/uSkKg9Obdw8dz3zRM0Ct74G6SQyp76PHGAWtRXvlRo7ogWj0Q==
X-Received: by 2002:a50:b819:: with SMTP id j25mr3143063ede.77.1551287310911;
        Wed, 27 Feb 2019 09:08:30 -0800 (PST)
X-Google-Smtp-Source: AHgI3IYl1rfZmgYz7ionBgKdJbXKpswOW+TylWOuu16AMlTpyvsoFL3GcvrI5sn23Ml7N31qtZuE
X-Received: by 2002:a50:b819:: with SMTP id j25mr3142998ede.77.1551287309807;
        Wed, 27 Feb 2019 09:08:29 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551287309; cv=none;
        d=google.com; s=arc-20160816;
        b=IVrSo/fBI6i1F5mxLjHoLEPD0UEUorC8SCTln3bx37p/fRKMU1qKrkPagoZtGYAMl5
         G3a34FQf1PS39YQYVRM/Bkyt/JXAMrVLt+dg89QqTxjpcZZra9Kwbrs02wQvmnPZrQQZ
         467UzSCKoxI2IFhBAn3OevNULi60l6a3UZL7LisBCZUHWE5QaKOK4neaVwEfJRTfUVgz
         1pr3bcK7yUlkuYky+arSyNvt8hZ5Evr/wybndmqWO0hLOl49BwxOQJFGzJ2nyiQ81lCO
         hTy6N15G85b2UbZYXhmZoKY1S0VglOJcLtf79+ml3/TQL4Xz7CxHKp+dc8wop4KHWeyt
         +ypQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=OsM61sR7KtxeUBiEjMTBAbQYMmMZy1tlMKtG+lRZsQM=;
        b=dRMrcx8MQq96M8TeWbxaSpYdjHK3SBoVyccNgB09mcdivFSZprxcq52o3HBPUsL25S
         CHKR4W8zB9f01ZHAbO0IoPR0yUD/81fWlmlyeGlckNpSWWJmslK26HbYoEGeYkYpR6le
         svv14lNdhGD8STC9FohOENc05JiHqTC8v/3r9GApAsuSGp7qFwZ2bYpEdQOHFOh2kyBC
         2hm5jaS+Ge5eldXhRbylumFK7AbcMn8XUD8V/8HW8JEbNIKcmr1J1Su48wXrs3lghdDx
         mx2IK9znLiUM5RDDbsJhjVwJdZBBVXMVuXXjHgYR/bv46DT7jD64eP8Ju3uLyRIsrZ5t
         6Z1g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id s40si22714eda.158.2019.02.27.09.08.29
        for <linux-mm@kvack.org>;
        Wed, 27 Feb 2019 09:08:29 -0800 (PST)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id BD0021A25;
	Wed, 27 Feb 2019 09:08:28 -0800 (PST)
Received: from e112269-lin.arm.com (e112269-lin.cambridge.arm.com [10.1.196.69])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 81F613F738;
	Wed, 27 Feb 2019 09:08:25 -0800 (PST)
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
Subject: [PATCH v3 32/34] x86/mm: Convert ptdump_walk_pgd_level_debugfs() to take an mm_struct
Date: Wed, 27 Feb 2019 17:06:06 +0000
Message-Id: <20190227170608.27963-33-steven.price@arm.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190227170608.27963-1-steven.price@arm.com>
References: <20190227170608.27963-1-steven.price@arm.com>
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
index def035fa230e..d6d919a20aac 100644
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
index 3a8cf6699976..fb4b9212cae5 100644
--- a/arch/x86/mm/dump_pagetables.c
+++ b/arch/x86/mm/dump_pagetables.c
@@ -523,16 +523,12 @@ static inline bool is_hypervisor_range(int idx)
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
@@ -577,8 +573,10 @@ void ptdump_walk_pgd_level(struct seq_file *m, struct mm_struct *mm)
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
@@ -604,7 +602,7 @@ void ptdump_walk_user_pgd_level_checkwx(void)
 
 void ptdump_walk_pgd_level_checkwx(void)
 {
-	ptdump_walk_pgd_level_core(NULL, NULL, true, false);
+	ptdump_walk_pgd_level_core(NULL, INIT_PGD, true, false);
 }
 
 static int __init pt_dump_init(void)
-- 
2.20.1

