Return-Path: <SRS0=0MJS=RY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 670D5C43381
	for <linux-mm@archiver.kernel.org>; Thu, 21 Mar 2019 14:21:43 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 15F7A218FF
	for <linux-mm@archiver.kernel.org>; Thu, 21 Mar 2019 14:21:43 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 15F7A218FF
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id C3D1D6B0279; Thu, 21 Mar 2019 10:21:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id BED0B6B027A; Thu, 21 Mar 2019 10:21:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B02986B027B; Thu, 21 Mar 2019 10:21:14 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 61C086B0279
	for <linux-mm@kvack.org>; Thu, 21 Mar 2019 10:21:14 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id h27so2261258eda.8
        for <linux-mm@kvack.org>; Thu, 21 Mar 2019 07:21:14 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=0Qu5DM7t7O6eLZ930vwdwyGGSyJREtb45OisMEetzTk=;
        b=NW+H9YJ0EBMaSTkG46Kdq0/ErGBO4hOVohMx58YfIFTgEaujxVCGWEdkr/wf2wRO0K
         hH5lxkfF1tidb6ztAh/kZY3To/mc7wzWrLXsekzpmuU88dV+Qvmbvxkgl/9IM37h/WYr
         LzQkGDJbFvVB2ovd2wWKBBNXpyZucxH+q7Gf1t5NGMYHL7sHinEs1Ek6MikGvgNuyJzE
         LdwpKPUDwR7O1gOc7lUvgzw5vkAB5fHLx0CiPlCllAXNonuCjJJZ4idwgrg4Z7VhVwOn
         TDZquD+pYaTFKqsWcerk6Sq79eI70cY/A+/4sph0LUBoChm2RoXRgdBVYOjtQDgBgI/R
         s2hw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: APjAAAW+c5EafexHTEP95XeLshWewWe9qQGS1Lw9oMSuc2FDXuIzRKu+
	VL0oXQM+15DKbybnw6MtUnj99QZe/NtQSzOp6ZI7qw8/0z+S1f2zxwO99L/izxuurkFfUVytn4f
	BUMhMzMhbGPimHaut2ntWRccX44eZq7uLVESJTHKq8PU21KtLDzCxxgV/nTQ82s/SgA==
X-Received: by 2002:a17:906:77c1:: with SMTP id m1mr2183370ejn.148.1553178073917;
        Thu, 21 Mar 2019 07:21:13 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzGIlmz/Yms0NzHwFuqCH3jp2gOf+ttdlWH/Yt8/NMwwT/qGE6zDqeF+nfSxrpYTDggqPs5
X-Received: by 2002:a17:906:77c1:: with SMTP id m1mr2183336ejn.148.1553178073005;
        Thu, 21 Mar 2019 07:21:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553178073; cv=none;
        d=google.com; s=arc-20160816;
        b=Ht91OfLmPcs8kfN/6adMpRo0E70UcU2a3ZdotlB+QxTrMAoe4EYtZkdO4rzm6wstZQ
         z+paVy3mqzl7Rkhhpo111+kcAcD5Qo+T7th5QU/LCFJ6nBb0jhZAmgdqw+gmJ72co+Jg
         EPR34wy53kjz8Svbcn+rPt1Ck9u/7AB2z7YzxAKR4pGXyBsBbbQckVE/BGnL2yMaKm4v
         p2QaFHiiLlddKhRjxcaZLQJhzm412f5xyJXuHI7XLECqhIZSxXApOVxnZnih/eRabEJ6
         60m571YdaEpCUxLozUZ8mmOYbuBKWZuDdXcmg5lrmcCZOfbnhGrNHy4BsezXaDfZE5Xg
         RF0A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=0Qu5DM7t7O6eLZ930vwdwyGGSyJREtb45OisMEetzTk=;
        b=eC81z+GFvsv9b1btcgeeJE6wBctHyOtx/ZT7xwiUuCGjDSa713yt6kcz5QlU/qsGWt
         kldt4iNzVKlrpX/gxACVAQ5XnVOuXAZZ95VzWFpV4l/F9fsoVZ2DoUCVEm5oaLpDkLIw
         Mh6+xu5ILCteyx//6Wu9rrykUp6ucdZIXNx11hhPFDDt2kRcZcWqEAOWHsyEZIBV9PGJ
         bMDj20VVj6KpuqnbBl9nBAIUHBI0ND5vQynLo8+JeXKRYbCXlXDEMxXWaywfBUDlxH8B
         4VpkpIOGuLmRw++445ASnxqJMSM0RdkmZJIWTz+XK/rbOxqTnCCeIOUvNdh4Z+dJjW8s
         GaJQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id m29si2132203edm.213.2019.03.21.07.21.12
        for <linux-mm@kvack.org>;
        Thu, 21 Mar 2019 07:21:12 -0700 (PDT)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id E8ECB168F;
	Thu, 21 Mar 2019 07:21:11 -0700 (PDT)
Received: from e112269-lin.arm.com (e112269-lin.cambridge.arm.com [10.1.196.69])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id AE3743F575;
	Thu, 21 Mar 2019 07:21:08 -0700 (PDT)
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
Subject: [PATCH v5 18/19] x86: mm: Convert ptdump_walk_pgd_level_core() to take an mm_struct
Date: Thu, 21 Mar 2019 14:19:52 +0000
Message-Id: <20190321141953.31960-19-steven.price@arm.com>
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

