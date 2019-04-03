Return-Path: <SRS0=DmM3=SF=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0DF2AC4360F
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 14:18:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BEE892084C
	for <linux-mm@archiver.kernel.org>; Wed,  3 Apr 2019 14:18:27 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BEE892084C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 683626B0280; Wed,  3 Apr 2019 10:18:27 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 632E06B0281; Wed,  3 Apr 2019 10:18:27 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4FB9C6B0282; Wed,  3 Apr 2019 10:18:27 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 0521D6B0280
	for <linux-mm@kvack.org>; Wed,  3 Apr 2019 10:18:27 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id n12so7651110edo.5
        for <linux-mm@kvack.org>; Wed, 03 Apr 2019 07:18:26 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=0Qu5DM7t7O6eLZ930vwdwyGGSyJREtb45OisMEetzTk=;
        b=a+LDXYywEoYdECjpsag9Qt4laP7e7zq7kQ2wUEDXGuyKyWX8Pu/4tjhPeHaK1fjVO7
         WLXnrYTFfkZ4Bzr5GSrLF2Y9SIv0tPCvXLIin21r5/ChYWWeR6ygjLp9G8m2JsRnJI2u
         EORmafHexFFEibb3hiWQtjcaDPVMteT+S9DQFyAJXd4X3vwr13d40gnX+nSuSgf6uKdr
         4XO3ZinO63SRgujmH5MeRtsCaptjWfqq+Zv96+CKSDadZv5vuve53vRyS3aDwvdf/C1h
         1Gco15cCGV49ZpIMBpK/LxcBBYZsbaxh3yvvb61StqNCKM0y1XUPqkDsFzZvxIEFP5Dy
         j/hw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: APjAAAWAqbNSptwurKAITv5BPPUloyuWAQQ8n/FNdivdQhhZk2SInpqT
	Rw/1uW4FyLwJUAIzZHni+4mXXbRedX5LjNuISBf0nfgC/y8EuIQHgXMaX9GLCl8IqLtVbkHFJqJ
	+UZEZnCfYrDxe28sfUULJznUGJAbrnE+DWiv82/mM67INIAwioyKFBkNAf4u+QsrtDg==
X-Received: by 2002:a50:ec89:: with SMTP id e9mr31934559edr.252.1554301106543;
        Wed, 03 Apr 2019 07:18:26 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwU1kJo7gGld2UhuMwibGXOAqu3CzYF9oSuTWaov/ACL4kyTxyiDsZ+OguLoyswC11gDWnw
X-Received: by 2002:a50:ec89:: with SMTP id e9mr31934508edr.252.1554301105640;
        Wed, 03 Apr 2019 07:18:25 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1554301105; cv=none;
        d=google.com; s=arc-20160816;
        b=M5YSDSnKRtT8LbJBNy+F9ZEA+EzLS7TdtyUIHTAoP1JfAsdSxRLplgxzRzz0bM4Mcw
         aPEMhsxLl8YmWybaUXMx9TJa3VCklm2PHwlQJdioC8ElcTavzKVW4CQ9+0R3xj+Jep4V
         U7CAcBhf7Ds61+DxW5EjM1SruH4V08FSYc9uO1DGh6w+C6FomMhN0Pqs3X2QUm87ts3D
         gHjxTnXK82UGaunrRqAaAHKCW/ySWRzfpAWLCJ7iz5cMrJJ7L/LY8jT6dfFOwH73+zrE
         4t526LZidy/eFy80i0OyIQr24YKVzgN3iwXLSWWELp+2DL86t3xM3dBsyaahohZ9N3si
         2e+g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=0Qu5DM7t7O6eLZ930vwdwyGGSyJREtb45OisMEetzTk=;
        b=fDjVR6gTdoyZHG6vq274Q5bkq1LLVJFephExXlaMfDBryKZEKwN3P3PF9seR4EKI+j
         tZYw6qTfR+qsvW0dgBEPw0bx/x/2L7/hzmUDlS+D/v9SATBuOrgv5nTBeOtbheuJeGSB
         DVYtHBH3EO8GQ8zE5q8dcAXsnf5Nwr+Ox0ojCOhvxIGdon9oG88Yy4g6wjYM3P5zVmcF
         7ir4oEfv8ZoiuUv7sQI/HyXRjs7iXUFfr9WsYFduXnIl0pwbfXjlvaADn26QJ5W8MlMA
         avShZCFc0IF2MQcz+cBofV1T9YywfJY/Yt6czZP7YZ/29lhZ0LRDyMwFn5wtb7O95Z3k
         UUyA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id w48si2420346edc.295.2019.04.03.07.18.25
        for <linux-mm@kvack.org>;
        Wed, 03 Apr 2019 07:18:25 -0700 (PDT)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 8FB1D168F;
	Wed,  3 Apr 2019 07:18:24 -0700 (PDT)
Received: from e112269-lin.arm.com (e112269-lin.cambridge.arm.com [10.1.196.69])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 2C9A03F68F;
	Wed,  3 Apr 2019 07:18:21 -0700 (PDT)
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
Subject: [PATCH v8 19/20] x86: mm: Convert ptdump_walk_pgd_level_core() to take an mm_struct
Date: Wed,  3 Apr 2019 15:16:26 +0100
Message-Id: <20190403141627.11664-20-steven.price@arm.com>
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
index 40b3f1da6e15..c0fbb9e5a790 100644
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
@@ -522,10 +518,10 @@ static inline bool is_hypervisor_range(int idx)
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
@@ -572,39 +568,49 @@ static void ptdump_walk_pgd_level_core(struct seq_file *m, pgd_t *pgd,
 
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

