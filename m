Return-Path: <SRS0=vS5V=Q4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id DEBCCC4360F
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 11:36:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A3C242086C
	for <linux-mm@archiver.kernel.org>; Thu, 21 Feb 2019 11:36:06 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A3C242086C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 8F2F58E007F; Thu, 21 Feb 2019 06:36:04 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 89E768E0075; Thu, 21 Feb 2019 06:36:04 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 6F13B8E007F; Thu, 21 Feb 2019 06:36:04 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 127C18E0075
	for <linux-mm@kvack.org>; Thu, 21 Feb 2019 06:36:04 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id e46so1997148ede.9
        for <linux-mm@kvack.org>; Thu, 21 Feb 2019 03:36:04 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=htZ43xbxBik8G+1SZkvefzMNP0baYE6/YcLJdQXc4CE=;
        b=R3Fv0yxNXHW6KLXXGONjVmTi2e3FdWaBkeKfSPA9T1AXuoImYKzdkxlh7dQ1TrRf2N
         Bg+HP2vXQGwaBR7eLS8/1cZtf3+n/CMJpiODMYQ5ZSX2PtgyZi9IP1Uzlx7V0GlqdUWr
         RtqBaOdpsblBNHKkvo9XPifDAMlA3zNmvPRbMPMwnNYJ34anN579A9aQvbkc3e90pei+
         tdRehWWeG4cZENWHIK44C8McYE/1rLj3aTyxPXrWQ82wMhlzMM35gmGQ7Lkc0BsO/TUM
         WOtILkONXoA8wE3hma1ZXUCu7W2JNPGW0w1mKui7RwaTP787DbiK5MxgbnKStfuuZm4t
         nEmw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: AHQUAub3/TjwP4q9A0K6/ZhRXLKjy8jtUKvYVqH5OsV8JzHqfnyjTQeb
	LQii5GQ8esiuM3b+yecpxCkFAsMNqTQ+p0NcLI6oHKXSe4m+vDvUzehuDf3Vh55MgodN6brDdlN
	0O7tnENXfkUrVkmc7Cj4UKcNcYMkYq54jX16M8IbKIqYNmhZ+SBCi5YQRK29f7I9YGg==
X-Received: by 2002:a17:906:ee1:: with SMTP id x1mr27091264eji.85.1550748963560;
        Thu, 21 Feb 2019 03:36:03 -0800 (PST)
X-Google-Smtp-Source: AHgI3IaVRWF5vSfg6TFU2jZ41BCbgRNGNHempPD3bHlq4qVrEBOQ5uFR9PrwIaTfPG0nujXJ8ZVC
X-Received: by 2002:a17:906:ee1:: with SMTP id x1mr27091208eji.85.1550748962443;
        Thu, 21 Feb 2019 03:36:02 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550748962; cv=none;
        d=google.com; s=arc-20160816;
        b=LU1frJm30cBboNHcRlKX+H08Jg37pb7BPkFBB2BvgYbvMbVvnEiKGtpU7Mk1/NE6lS
         IfRAL8k8eE60l1BmETchwzIWiLWasT0MOfapHCU2Sv1Z/Rt7PM8t+DPkE/rYK/9KJLDh
         v/qcGk+XOBmarXhxgW5s2tuBVkCg8houMZ6K2Cvm+5dAC9Oppg2yIfTSU7iWB6KR0VOF
         aiGLZ7AGcZ3qfQ6A0xdrj1GMwiyl0tzNO/krRcTrJChn+VGVkk2FjV+JH9RNZvak481J
         BcYIUmI1B8YkiGDhTImT8x1q3XSZ1W4UPwsuI4GLjir8ZcIpsnN2TG0+3L1hQAt1g/ms
         gEVA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=htZ43xbxBik8G+1SZkvefzMNP0baYE6/YcLJdQXc4CE=;
        b=BCblbhlYx/O33/yk+mu41+SLq0A37lhwVwBeQA2S6W/+BB/KMhxA5RoY+f15PKNxBM
         3yLWhoG9CfUUYMpHGvN0emlBZk7AdFpuo0pV6WC92s9OUq/Oel7gUEO8RPS5mCI5n0ty
         jeK2aGbgdakRlX7SaG8qRzfRIA4dTXmYDRO2HYbqrWDifR0sItpOto+6p7BsO0G3qZ7a
         zVYX87K75THkAVQIP7Dd+K+rVQ+Al6qQtlARS/mVsbLgNBHkRRp+QW6Uak69CyiEon3Y
         JCkRYlLdc1zX+bwlhFWeAQl+xULKB+eYJEFbBfeotpkel2KIBfKAtqpGd0JHUuxUHGkd
         FRDg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id a3si2082015edl.25.2019.02.21.03.36.01
        for <linux-mm@kvack.org>;
        Thu, 21 Feb 2019 03:36:02 -0800 (PST)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 58B7480D;
	Thu, 21 Feb 2019 03:36:01 -0800 (PST)
Received: from e112269-lin.arm.com (e112269-lin.cambridge.arm.com [10.1.196.69])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id CB4BF3F5C1;
	Thu, 21 Feb 2019 03:35:57 -0800 (PST)
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
Subject: [PATCH v2 12/13] x86/mm: Convert ptdump_walk_pgd_level_core() to take an mm_struct
Date: Thu, 21 Feb 2019 11:35:01 +0000
Message-Id: <20190221113502.54153-13-steven.price@arm.com>
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

An mm_struct is needed to enable x86 to use of the generic
walk_page_range() function.

In the case of walking the user page tables (when
CONFIG_PAGE_TABLE_ISOLATION is enabled), it is necessary to create a
fake_mm structure because there isn't an mm_struct with a pointer
to the pgd of the user page tables. This fake_mm structure is
initialised with the minimum necessary for the generic page walk code.

Signed-off-by: Steven Price <steven.price@arm.com>
---
 arch/x86/mm/dump_pagetables.c | 36 ++++++++++++++++++++---------------
 1 file changed, 21 insertions(+), 15 deletions(-)

diff --git a/arch/x86/mm/dump_pagetables.c b/arch/x86/mm/dump_pagetables.c
index 8b457a65ad8e..0953bf44d792 100644
--- a/arch/x86/mm/dump_pagetables.c
+++ b/arch/x86/mm/dump_pagetables.c
@@ -111,8 +111,6 @@ static struct addr_marker address_markers[] = {
 	[END_OF_SPACE_NR]	= { -1,			NULL }
 };
 
-#define INIT_PGD	((pgd_t *) &init_top_pgt)
-
 #else /* CONFIG_X86_64 */
 
 enum address_markers_idx {
@@ -147,8 +145,6 @@ static struct addr_marker address_markers[] = {
 	[END_OF_SPACE_NR]	= { -1,			NULL }
 };
 
-#define INIT_PGD	(swapper_pg_dir)
-
 #endif /* !CONFIG_X86_64 */
 
 /* Multipliers for offsets within the PTEs */
@@ -523,10 +519,10 @@ static inline bool is_hypervisor_range(int idx)
 #endif
 }
 
-static void ptdump_walk_pgd_level_core(struct seq_file *m, pgd_t *pgd,
+static void ptdump_walk_pgd_level_core(struct seq_file *m, struct mm_struct *mm,
 				       bool checkwx, bool dmesg)
 {
-	pgd_t *start = pgd;
+	pgd_t *start = mm->pgd;
 	pgprotval_t prot, eff;
 	int i;
 	struct pg_state st = {};
@@ -573,39 +569,49 @@ static void ptdump_walk_pgd_level_core(struct seq_file *m, pgd_t *pgd,
 
 void ptdump_walk_pgd_level(struct seq_file *m, struct mm_struct *mm)
 {
-	ptdump_walk_pgd_level_core(m, mm->pgd, false, true);
+	ptdump_walk_pgd_level_core(m, mm, false, true);
 }
 
+#ifdef CONFIG_PAGE_TABLE_ISOLATION
+static void ptdump_walk_pgd_level_user_core(struct seq_file *m,
+					    struct mm_struct *mm,
+					    bool checkwx, bool dmesg)
+{
+	struct mm_struct fake_mm = {
+		.pgd = kernel_to_user_pgdp(mm->pgd)
+	};
+	init_rwsem(&fake_mm.mmap_sem);
+	ptdump_walk_pgd_level_core(m, &fake_mm, checkwx, dmesg);
+}
+#endif
+
 void ptdump_walk_pgd_level_debugfs(struct seq_file *m, struct mm_struct *mm,
 				   bool user)
 {
-	pgd_t *pgd = mm->pgd;
 #ifdef CONFIG_PAGE_TABLE_ISOLATION
 	if (user && static_cpu_has(X86_FEATURE_PTI))
-		pgd = kernel_to_user_pgdp(pgd);
+		ptdump_walk_pgd_level_user_core(m, mm, false, false);
+	else
 #endif
-	ptdump_walk_pgd_level_core(m, pgd, false, false);
+		ptdump_walk_pgd_level_core(m, mm, false, false);
 }
 EXPORT_SYMBOL_GPL(ptdump_walk_pgd_level_debugfs);
 
 void ptdump_walk_user_pgd_level_checkwx(void)
 {
 #ifdef CONFIG_PAGE_TABLE_ISOLATION
-	pgd_t *pgd = INIT_PGD;
-
 	if (!(__supported_pte_mask & _PAGE_NX) ||
 	    !static_cpu_has(X86_FEATURE_PTI))
 		return;
 
 	pr_info("x86/mm: Checking user space page tables\n");
-	pgd = kernel_to_user_pgdp(pgd);
-	ptdump_walk_pgd_level_core(NULL, pgd, true, false);
+	ptdump_walk_pgd_level_user_core(NULL, &init_mm, true, false);
 #endif
 }
 
 void ptdump_walk_pgd_level_checkwx(void)
 {
-	ptdump_walk_pgd_level_core(NULL, INIT_PGD, true, false);
+	ptdump_walk_pgd_level_core(NULL, &init_mm, true, false);
 }
 
 static int __init pt_dump_init(void)
-- 
2.20.1

