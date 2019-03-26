Return-Path: <SRS0=c5Kt=R5=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 39361C10F05
	for <linux-mm@archiver.kernel.org>; Tue, 26 Mar 2019 16:27:47 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EB0D320863
	for <linux-mm@archiver.kernel.org>; Tue, 26 Mar 2019 16:27:46 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EB0D320863
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6A7C66B0286; Tue, 26 Mar 2019 12:27:44 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 656616B0287; Tue, 26 Mar 2019 12:27:44 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 56DC36B0288; Tue, 26 Mar 2019 12:27:44 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 080146B0286
	for <linux-mm@kvack.org>; Tue, 26 Mar 2019 12:27:44 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id m32so5532809edd.9
        for <linux-mm@kvack.org>; Tue, 26 Mar 2019 09:27:43 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=0Qu5DM7t7O6eLZ930vwdwyGGSyJREtb45OisMEetzTk=;
        b=IYWOvqQ2HVTlyGROBCpHQarhK9z9XyY2hCLRaHPCozmH0gOAVffAjzazaDK0r6PUk/
         kDlsJmYbw87kmIyYGVf60r77Y+RzlCNWJfyNfjK7S0/bz8zM6dHachs8jB9LkfkHWfeQ
         y5f2L0VrpkUbDFw8Xnl5Ocpaf61N8nJGcGIevij3o4dE3NZmfYta6en0w665jthMK4nZ
         NyVX5ud7NXmZoonFGIrad1oYPNTQKQqfE/d20m17HksuDqzwj8M5+YCblCeME7uYZGlJ
         YgD1JeyrbkTNBBcwA7uTXGSaPzT7QsHn90REm7Z81lFj33VVmbywhI+BJkLGJCKrdrzA
         2grw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: APjAAAUqmZAWfKQ4qhF6Xn4ciK0LA3xF2sLs87ZSq6cfGb0Co0n/yMUs
	eE1bbO8qKHPcezQojd1P10NNCbt+eOD8PFGo4hGfCndr+za8OWYyJwuM7LAt9821cCo08tvd2HB
	QaHEt3Ipq3u8Ou0LvByL6dBw9at3KbjGCAVSItA3PSXhtcyz15NWmvjCRf3u6A4JIDQ==
X-Received: by 2002:a17:906:eb87:: with SMTP id mh7mr14108363ejb.152.1553617663545;
        Tue, 26 Mar 2019 09:27:43 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwK82bVaeEp9zb+R476rz43rU4mroASZhXCXIT99bUmu5ehlpf7mZONIdBKI95jR1+BZMAI
X-Received: by 2002:a17:906:eb87:: with SMTP id mh7mr14108323ejb.152.1553617662538;
        Tue, 26 Mar 2019 09:27:42 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553617662; cv=none;
        d=google.com; s=arc-20160816;
        b=e2jaGo3x+xT4ePSpIblpLDzfjXTOVXcngse4VGzzaodcK/6WmrqWz1TeHtTqFnFfCT
         TnO5nUrn/oJMyMxvkZFtek4UahY7rHWpdN0GjNPieh0SSyofu7jVB43BIH5JrCqxhosr
         0FQQnLD9snb4G7xp76BBvr8QT7pCHrVRkwWoqhwB4SNJuM8nJ6Fc0vPp2IjKFxiKG4MS
         Of4E0lws34yCNT7ERCZ1U/ZB2MigUU7072eMdBamQ60r6vkvPX23jHp9MF6Huxj3uyL+
         DOLP3iHz1+S6ccYTrUN39wU8ZevofBBxc25rmxnq1omnjN+fnJxD/S3F0flcQYRu/1Oa
         Z8Pw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=0Qu5DM7t7O6eLZ930vwdwyGGSyJREtb45OisMEetzTk=;
        b=EgoWISEPdlR7sFzZuMNwKLKQznNxDkSwZlxjFyFL8uju9Hzs9iws5siuDxPpXTAH3P
         RufToD5bZE5wF4juSo/pNZ8lsCDO3RK/9hugNVpf56cG1Zl45NWSchD/VsebS/uHwOCI
         sjfq0q/gIpZ8Tl7wWQ1s/F+N8xtVDkFUQD9riwdpchX1isyHjDWRiN256EMOyIeLrqL/
         elvQEkL6AZkDwrTZOtuQkZj6rIT0gauzN5zzn8GbGobApmllOd5mIe+hOwXhK0lvKq9I
         X5EyS0Dw5+rLadAbJrt15nZm+qQja8ChqBytm8HMFX7oXW4AMuzm8PrxcLnEMZSnw6Wp
         /WuQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id p9si4308749ejr.333.2019.03.26.09.27.42
        for <linux-mm@kvack.org>;
        Tue, 26 Mar 2019 09:27:42 -0700 (PDT)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 7DCD21596;
	Tue, 26 Mar 2019 09:27:41 -0700 (PDT)
Received: from e112269-lin.arm.com (e112269-lin.cambridge.arm.com [10.1.196.69])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 39E4D3F614;
	Tue, 26 Mar 2019 09:27:38 -0700 (PDT)
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
Subject: [PATCH v6 18/19] x86: mm: Convert ptdump_walk_pgd_level_core() to take an mm_struct
Date: Tue, 26 Mar 2019 16:26:23 +0000
Message-Id: <20190326162624.20736-19-steven.price@arm.com>
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

