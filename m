Return-Path: <SRS0=DmM3=SF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id A863DC10F06
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 14:18:24 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 613482084C
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 14:18:24 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 613482084C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 091DC6B027F; Wed,  3 Apr 2019 10:18:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EE89B6B0280; Wed,  3 Apr 2019 10:18:23 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DFD7A6B0281; Wed,  3 Apr 2019 10:18:23 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8E8696B027F
	for <linux-mm@kvack.org>; Wed,  3 Apr 2019 10:18:23 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id m31so7655612edm.4
        for <linux-mm@kvack.org>; Wed, 03 Apr 2019 07:18:23 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=QI1ft8uG/6LmqX3YnTkHhfrqxc9+RDV6RJGxqI2lX8w=;
        b=D8LMM/m8DjtJwFsm/6UV6IOjLs1ZS5wJSo+FosumURwXa2n2OMFY+U8EJShE4bZm/M
         nM3omECLjXjqJZr56BSXik4vhDhgjIqzwtNKM3niNNK8PzIFsr/UahYYwkhlMak0nRL5
         rGMeCJntxn/5QHXcS9hDkMBu2ol3djamp9roMVwnsOgEzju+25Qie+bzDfVQqaTrEY8Q
         LG2AKMeAiuejWJLAFtse8auQlMtYG8eE68mCiSWlmgRw/azfTdyTbv04/akGaCm6yhzG
         mzbdYtx4lH5GXh/kvPRg0s04hC1oFwvEnqZs9/Xh5Y/3HJpcvxMHJk1WFufjw4qKuStu
         XzaA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: APjAAAV5k2nYujA9QqkNfPq5oTdpzLUZga1I4pDeBAHtCgSbXzpG4nVv
	+9KsXikGq+TYXlhpd4Hby3+BaW5F9nEsz6JIKuW6bmBZ518tS4lB/zqvPHb2oF88p6CrS1a6YVr
	/3Zf1alwQrPjMNvALE7GBogNB8nGjIXONHc4FKK34dqqtmtvV7d8RjMffJHxOPBhblw==
X-Received: by 2002:a50:f5f8:: with SMTP id x53mr52652195edm.2.1554301103064;
        Wed, 03 Apr 2019 07:18:23 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwfN5WA0EhZKnyIZ7dIoLc6/CxA23Ub8mW8y0LzSU5uyMxR5UmfAltuv1CzOvJxT1zrdQBw
X-Received: by 2002:a50:f5f8:: with SMTP id x53mr52652135edm.2.1554301102021;
        Wed, 03 Apr 2019 07:18:22 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554301102; cv=none;
        d=google.com; s=arc-20160816;
        b=Oh+Fjs10ZpNeu/sQ5Z+HSyEsdIxjo6+1p5V4zpQ9NXvlb1uUMBOr2DUILBg9237KGs
         oWGJaQERdxXweSp2XHy+fjOnEgromuMh5ebkncmOTYbNqHB44enFyQm9ocsmCIuYQLAI
         J6iwBNhDgU+UrgwtdbRlJZsdOLHo7gDx10wE9q1q2QzvZBKrSwPQ2uvbsX50AghgcwX+
         NrXP54nWpiGQnXiWUJTkrkO0nafYvzY1iwNIG+Xh1TJe5NDPzDa7wZvwIQHzDX4mzYJX
         5IQfIq84xDLwjydKA1NDrI3rQ65DANEp1bMlWdBvIfGXH7t7i7rjsabiH2ETUyRY4zfA
         ZgYA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=QI1ft8uG/6LmqX3YnTkHhfrqxc9+RDV6RJGxqI2lX8w=;
        b=B1NRivDsdb+ger0tvqoj117Ih739ODN71QToESzCrdp2Pd5oYDXz48pcFDhd0tQEgZ
         3u5QpJ3MuKEsq+SsgFXObTRLlzW8/+THy0Dqj7vsgF4vTkHVHTKn8+bDRs0qNgn4cfe2
         5BV/mYlARodUE63OhaB4D/V8epR9p+5u4v6k0tobTkqhXOXFg4dgtFFHE9+BTVkzUfbx
         Dbv60zrKA6+Klj8IwoYgikCznIJnwvhx7HKM0KNjlIYjz3GCYnPHCFdw5Us/pzbHPeCU
         8LywPl5CAyVzsNENAGUdbNlhbg0Diu94WPrA41Nr7nvLtryxM05ldr3wvqZUSJoMAw7/
         Trsg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id k23si2356701edd.387.2019.04.03.07.18.21
        for <linux-mm@kvack.org>;
        Wed, 03 Apr 2019 07:18:22 -0700 (PDT)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id E144C1684;
	Wed,  3 Apr 2019 07:18:20 -0700 (PDT)
Received: from e112269-lin.arm.com (e112269-lin.cambridge.arm.com [10.1.196.69])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 81C473F68F;
	Wed,  3 Apr 2019 07:18:17 -0700 (PDT)
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
Subject: [PATCH v8 18/20] x86: mm: Convert ptdump_walk_pgd_level_debugfs() to take an mm_struct
Date: Wed,  3 Apr 2019 15:16:25 +0100
Message-Id: <20190403141627.11664-19-steven.price@arm.com>
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

