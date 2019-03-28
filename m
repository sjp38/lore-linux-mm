Return-Path: <SRS0=kLvD=R7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 07FF8C10F03
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 15:23:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B81D121855
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 15:23:10 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B81D121855
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4D23E6B0275; Thu, 28 Mar 2019 11:23:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 42FE86B0276; Thu, 28 Mar 2019 11:23:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 2F8F56B0277; Thu, 28 Mar 2019 11:23:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id CFD0B6B0275
	for <linux-mm@kvack.org>; Thu, 28 Mar 2019 11:23:03 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id d2so5896158edo.23
        for <linux-mm@kvack.org>; Thu, 28 Mar 2019 08:23:03 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=QI1ft8uG/6LmqX3YnTkHhfrqxc9+RDV6RJGxqI2lX8w=;
        b=F1JI0V4DGoAbFVeqiPOx2SIRkXxa2YHJjHT9isHRLhZzPBFHp0ovjyakvHLCsJne8r
         sB2zVygboTgyigsn8Zn4FIPDnu/yypDBiNzLfCKv0dgCHF4rLVX687Kgx1FvlamG3v7H
         Cyy6zhK8gQafAF605QohM/Kf27BXMskOt4X+CJX2/a5kfkA02OeYVmhHJ6KVvA17eeaI
         BOMhyusifaN9u2WO11WA3oHZrZ4Y/NF72USx0GOj62e29f3LUCxeT8RQeZUhgGWT0Pt/
         JMWYMur9aLiwVlBHf7pyZ17vt6rhclv45Rh4iw1zW8yKt+LsYmw7GvluowAk3GE3fe3s
         GH6A==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: APjAAAX6Xs3XFhDpLRXmVN6NddH5EQR5KOjtSWXAxv3GWN8y9LCToB/G
	R9qz9CSb2G15KRvQBA7mVLxvnFiLgxg4T0Ec/rSohOLVlAyFRx+XGxS5XcCQMTsrfAJVUdS+wDZ
	RG0IYwcm6SGapcR+rAh3FyoNlu8GI2m7bdkcDt6KLKe4J+qGwKo4zTNietP2FwCywOw==
X-Received: by 2002:a50:92b2:: with SMTP id k47mr27094169eda.148.1553786583344;
        Thu, 28 Mar 2019 08:23:03 -0700 (PDT)
X-Google-Smtp-Source: APXvYqy6Ltnn8GVO7Z3FikSEljQYfyICtvSurez6PyWE1eC1ptgqPWd/7qpzASwCksQY5lLAvF2x
X-Received: by 2002:a50:92b2:: with SMTP id k47mr27094120eda.148.1553786582365;
        Thu, 28 Mar 2019 08:23:02 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553786582; cv=none;
        d=google.com; s=arc-20160816;
        b=BtTRkvW1nygkCNRn3o+zeMCs5eosJMNl7+aE+9kCkvUXadg6hVO29zah1h9Xy1oXOL
         poBORFlMrgrY69OqIhMNug+kgzvgoiMnhz60VFDTJY9FYeptm7SRvsDfW+1aXiIX71HY
         LEGxGlgGXaiH5AFQcqYlIJ5Q0W5eSJK+tP8GnFxQqENzIaBd8EXSb9R/T9lO8HznQNQQ
         Ar/iybB50QHThDmU1UtoNx0e3Wp0E4+2flNO61IDKWJ1SeEDEG4/QZzp6jRJpECUSUFf
         DYKxWTCKJq6WZB1fYDUEZRp88+f/8jwgB83XX+AEk+nx7+fVp1P6g9fF+U20Xaxb37zJ
         f33g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=QI1ft8uG/6LmqX3YnTkHhfrqxc9+RDV6RJGxqI2lX8w=;
        b=Cw5lnxgPYROLE3ou++Th0YnVbKt38Qcliqmkb3KIYOoUXC1HpdyJsikOJAJZnt0I3p
         xUwo2CN2gpf/x+QtNeRN4kiNWy11vLZ2IbYKKiTuTJoRi0E2bP1MDGxriqFnARHhIxlb
         zSrerb+eVmj82rnjnfA7nJWp5B8aJLqYp5SJ+1QDcaw/HRcuU3FSjqKiANPlSVEMqTBV
         B/Dyd2YmNMVyAIbumvhvtRA3lqnwVrFpe6cb+6JceCcmxf2iABxGsHC2SoDUCJkJWTKW
         d9kvb90Q5RprrEJk19rLbBp5sOOoi7LSKYoyZgGWg0veR+yW6GpT6Z1rHTAKyvch/rG0
         nOvw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id 38si5631576edr.181.2019.03.28.08.23.01
        for <linux-mm@kvack.org>;
        Thu, 28 Mar 2019 08:23:02 -0700 (PDT)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 5988D15AB;
	Thu, 28 Mar 2019 08:23:01 -0700 (PDT)
Received: from e112269-lin.arm.com (e112269-lin.cambridge.arm.com [10.1.196.69])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 1282A3F557;
	Thu, 28 Mar 2019 08:22:57 -0700 (PDT)
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
Subject: [PATCH v7 18/20] x86: mm: Convert ptdump_walk_pgd_level_debugfs() to take an mm_struct
Date: Thu, 28 Mar 2019 15:21:02 +0000
Message-Id: <20190328152104.23106-19-steven.price@arm.com>
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

