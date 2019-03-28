Return-Path: <SRS0=kLvD=R7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 2441DC43381
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 15:23:15 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D92E82173C
	for <linux-mm@archiver.kernel.org>; Thu, 28 Mar 2019 15:23:14 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D92E82173C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F06B96B0276; Thu, 28 Mar 2019 11:23:07 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E6B746B0277; Thu, 28 Mar 2019 11:23:07 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C95866B0278; Thu, 28 Mar 2019 11:23:07 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 6A90F6B0276
	for <linux-mm@kvack.org>; Thu, 28 Mar 2019 11:23:07 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id z98so8310482ede.3
        for <linux-mm@kvack.org>; Thu, 28 Mar 2019 08:23:07 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=0Qu5DM7t7O6eLZ930vwdwyGGSyJREtb45OisMEetzTk=;
        b=Rd7qFErUQgiRaciYvZg9mNBSTypN4zkcw5K/vq73VFQC/IjrHDJDBaUDk1XGtdIXsb
         NHvHeCgzgHlSGRtP4hcV5mBTV+ig3DLj8kl/bsw14O0ZSIDUauQGylr+2ExJFNHXRcUe
         N/395B70imE1rsxUuWSoCIQF2SFENX5KAfjGsWZLH5cN23Xa9leqHEORsls2Trey3Zyz
         ztKoyOuyPz9YNjpP14Uj6XulGFcGOWUo0oM/ffQfMj0Nrkv+KNAxU4nM/iIilbDB0xC9
         0eEOzVBVg52ZRrxrx0ZPgv8riZDZ+k1/kfz61LrO9D8bHipIPHzUwQU1oI0B2EooBg5Y
         Vc4w==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: APjAAAW9OnIufBZufn2sOZgkddhcIcPlLAdhIFF3TlEM6S4smlCWKk5c
	AoURTS1kM0IAlyMR41pTsdd6Rzgnx3AdwKWfW640Zax4ow9hKCfY0goSPFWqCyFoe6x7u6nXkyb
	BzRcnfCuHb3Q9GeNnWo8XoqU8GoVhW0JJfW6+aukq0Y2PnyewHBL9Y+Ar7AHd3Hn09g==
X-Received: by 2002:a17:906:31cf:: with SMTP id f15mr21002699ejf.246.1553786586931;
        Thu, 28 Mar 2019 08:23:06 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxnU+zskg+wwB/BI5fwRkm8pn0i3wg5kxP1hbOpLIZ2R0FqSZfBhyUhMUIFLhxi02O6yM6w
X-Received: by 2002:a17:906:31cf:: with SMTP id f15mr21002649ejf.246.1553786585939;
        Thu, 28 Mar 2019 08:23:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553786585; cv=none;
        d=google.com; s=arc-20160816;
        b=FnmWv6ftWP6j9rvwW1XVYOsh8R9viSpfWwiYvQcSxw470NSMSqreIhhibhUTONgmY9
         ExoaY1JUJ/Th57vDkerPjdGvTXHzC8yUYcW1HdoGRgaXdZvrSSoyg44M2fFAow54lC4Q
         0+j113VxT6dmFCtWBmGJd9IYrDHoTFcMjdE5+OOkwFMY5tHUcpIZ09MxDf5eqDXnB5jy
         5HMHFOQPhA1gybf5MPA444s1aUVhuuZ19HsKsCurdWDhWHFwryYY7LYOy6TytSaw8fnS
         DX/VxPLlYUEIPM94rOldToybtbP1LrVOJ4uo7pDmp4h0Q4gE2Fgahm58LF3lezx++B0e
         UOUw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=0Qu5DM7t7O6eLZ930vwdwyGGSyJREtb45OisMEetzTk=;
        b=ivdFJPrjYG58jqP2h60B+38VwkMaQZBDBX0vqPYVrKTZl+cK5HBzzVAerZqePrESlt
         JBHR7reWdhO+Jf6D2+Qwz2N6Yv9qKKdGNmjNPBPA6zKicg9Z+wxXLhby1xcOkqINyQot
         OZBg9XJa0dZBOFQyFNWdiSE/GloPk5Fwg6n//EYQJcjLwYkCwoly42LhEIxCbp7UfolG
         X/NQ5Jbe7GirkolooyTRKY/7HUHdQyGvA7LBjqwPtO3yOTJ5q6RwBzxsmEXKYS+msoiS
         fANbH6eOlqv+mfF8YleWBD6voRag7Us/hl5FPBcWsBLrMoBx8HKz9M2+lVN+HTgjtifw
         80hA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id i10si1936370edk.269.2019.03.28.08.23.05
        for <linux-mm@kvack.org>;
        Thu, 28 Mar 2019 08:23:05 -0700 (PDT)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id E1069169E;
	Thu, 28 Mar 2019 08:23:04 -0700 (PDT)
Received: from e112269-lin.arm.com (e112269-lin.cambridge.arm.com [10.1.196.69])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 99FF43F557;
	Thu, 28 Mar 2019 08:23:01 -0700 (PDT)
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
Subject: [PATCH v7 19/20] x86: mm: Convert ptdump_walk_pgd_level_core() to take an mm_struct
Date: Thu, 28 Mar 2019 15:21:03 +0000
Message-Id: <20190328152104.23106-20-steven.price@arm.com>
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

