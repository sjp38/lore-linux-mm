Return-Path: <SRS0=80m6=VT=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 83A60C76188
	for <linux-mm@archiver.kernel.org>; Mon, 22 Jul 2019 15:43:28 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 212A42190F
	for <linux-mm@archiver.kernel.org>; Mon, 22 Jul 2019 15:43:28 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 212A42190F
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CF0BF8E0014; Mon, 22 Jul 2019 11:43:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C7BF38E000E; Mon, 22 Jul 2019 11:43:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id AF3788E0014; Mon, 22 Jul 2019 11:43:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 5B39D8E000E
	for <linux-mm@kvack.org>; Mon, 22 Jul 2019 11:43:18 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id y3so26523974edm.21
        for <linux-mm@kvack.org>; Mon, 22 Jul 2019 08:43:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=emRikM1OxiMr4txqEPA99/ZelM98uQ+z2aULjxVQqXY=;
        b=JMaLAbK6TlLkYgSGj/PAxFWMWf/9dONzhCW28YFW2B0HT/mVH9F5uoKXplx6jWc7so
         uqLmPFsRc95cNr+MHl/iVZ2r199qAYt47vhy5HvSSXnqh2gk87OD9GAgGYZJkgtizIwz
         aM687xDGjd5iKIw+9Io69J/xB0HU42R4wBtRzV9ojgeHdoOwCR5GLW+hcXCirn4Zdu9m
         JTGzIZ8hxUzqMKmjQMsnx0ENHViOYFYM4o9MeWgZ6G/uZhZ/hf+3nAAmk081qla3zy8b
         aB7xLKg2Q8gG27Bam1VfqABcPpHJ1zs6UUilKj59NM0kICEhBmICegR2ydbB0as9UtG0
         DbZQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: APjAAAW1LM/ZsDKvdprwmLR5kKzEkh0RJY95a4/AKIFFZj/zdobz2l/l
	bCoxiqplckWd3cPoCfbrvDL0XDCdYQAYphiCFuj57vRw73xycKPq0kFbp+d7MM+WMw5+K8nbgQO
	NlStmv2pbN79puLQwvjUEkg/oI+uRUrtEcuGu8Jy2iCz0iTp0UIHAXYfMAbFqQ7OK1g==
X-Received: by 2002:a17:906:af86:: with SMTP id mj6mr8434756ejb.157.1563810197949;
        Mon, 22 Jul 2019 08:43:17 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzimau2JzWuPh6+OLUS3OP3aL8QMhqSsDB44EtCaWMytfMIjLVYtPp40NNoiBb0g107RdG5
X-Received: by 2002:a17:906:af86:: with SMTP id mj6mr8434692ejb.157.1563810196960;
        Mon, 22 Jul 2019 08:43:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563810196; cv=none;
        d=google.com; s=arc-20160816;
        b=DAZT5DP7qnxy7dmX43TxYqrWodEwPtEuAqtw1Ho4XhOnPkeV8AkKAcOCmtwen0zku/
         Kz05TAnoxFCtAbt9Kv5HN7OJbOT0IpzcGVHcynBcIFeAVOcP/1L5DVqzwcMggrBVeY9E
         k/frMoE8+MyYDtnOLIieDwPIdJNRlrwbuniZ7c5eFMZ3Rs+0tlHBLHqhojhjCnxeYBwf
         NY7Aw4BKlh4yTpNYdV6oOV9y0o+sWKXiBUGbeIXyMEGnH2fV8tGBq5W5tFpcQ3OVk9LU
         c0TyEKL7IGDis6hjOL+ibUTNtUbJgEV8NHTrtDIWQL6WQ5muRBIT4P1rmhIVzqXu0ctr
         O79g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=emRikM1OxiMr4txqEPA99/ZelM98uQ+z2aULjxVQqXY=;
        b=ZCN2t4YrIt7byJ/2ZmSKN1mDmYBMhoUInEV1SxKKtdFYU++HkYy0dTo0oqdDazhfpX
         JCWddJ8KtOVkmMhWjN5Px393SGTNg/e7RlGByNe0uklu4Jcf8H5U19A2puCCrSeBK0ch
         ZmdUBXAQndX8mn4Mhork0w4xMjCFD2F9QfS0UXyrvwKeFttiITvTwoZvEpBVA931AFna
         1qvbRsEaW9UetJTsv768eGiIONb+c/sF2DM5sEPX2n+UXg630kTiJQAgSVCYWdlmIpRN
         gL0pw1Mw4ngcOVT3oi55iKV86YjExl883cVTLrDv3HH/Agut9cJPDLic/eT/rzOPAcN+
         2EnQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id c22si5636626edc.378.2019.07.22.08.43.16
        for <linux-mm@kvack.org>;
        Mon, 22 Jul 2019 08:43:16 -0700 (PDT)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 16C1515A2;
	Mon, 22 Jul 2019 08:43:16 -0700 (PDT)
Received: from e112269-lin.arm.com (e112269-lin.cambridge.arm.com [10.1.196.133])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 8186F3F694;
	Mon, 22 Jul 2019 08:43:13 -0700 (PDT)
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
Subject: [PATCH v9 18/21] x86: mm: Convert ptdump_walk_pgd_level_core() to take an mm_struct
Date: Mon, 22 Jul 2019 16:42:07 +0100
Message-Id: <20190722154210.42799-19-steven.price@arm.com>
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
index bcaf27b637e0..546e28a7785c 100644
--- a/arch/x86/mm/dump_pagetables.c
+++ b/arch/x86/mm/dump_pagetables.c
@@ -107,8 +107,6 @@ static struct addr_marker address_markers[] = {
 	[END_OF_SPACE_NR]	= { -1,			NULL }
 };
 
-#define INIT_PGD	((pgd_t *) &init_top_pgt)
-
 #else /* CONFIG_X86_64 */
 
 enum address_markers_idx {
@@ -143,8 +141,6 @@ static struct addr_marker address_markers[] = {
 	[END_OF_SPACE_NR]	= { -1,			NULL }
 };
 
-#define INIT_PGD	(swapper_pg_dir)
-
 #endif /* !CONFIG_X86_64 */
 
 /* Multipliers for offsets within the PTEs */
@@ -516,10 +512,10 @@ static inline bool is_hypervisor_range(int idx)
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
@@ -566,39 +562,49 @@ static void ptdump_walk_pgd_level_core(struct seq_file *m, pgd_t *pgd,
 
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
 	if (user && boot_cpu_has(X86_FEATURE_PTI))
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
 	    !boot_cpu_has(X86_FEATURE_PTI))
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

