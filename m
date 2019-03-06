Return-Path: <SRS0=43/C=RJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F2685C4360F
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 15:52:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B306620663
	for <linux-mm@archiver.kernel.org>; Wed,  6 Mar 2019 15:52:17 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B306620663
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 81C568E001D; Wed,  6 Mar 2019 10:51:55 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 7AC7A8E0015; Wed,  6 Mar 2019 10:51:55 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 5FBA28E001D; Wed,  6 Mar 2019 10:51:55 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id F19708E0015
	for <linux-mm@kvack.org>; Wed,  6 Mar 2019 10:51:54 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id o25so6588660edr.0
        for <linux-mm@kvack.org>; Wed, 06 Mar 2019 07:51:54 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=2coDtKUAAHa6O24jio+8J0JOqtELt/lHMje4085swNg=;
        b=IzAzlDQv1fsfZISEOPN5BmSSrbGgciBq/orvtugc2zCil8kq4yhEyxM1GS6lyGvnN4
         RhDTJNiQG5rIxpFbk587eyx6fgVonW+eg/3x52rjeLFRta0/tVQbHQw2kXn2V6hCJxxh
         wlAEw/IoXAuhFd0TNG2tLhJGqmp/+pqAZJAEFoObM2vL8xTIPb6VIi7ucP8nwwwLfk8k
         iKM9dQyurkOvHGAbhEVC8WzEipT3OxgbeRHlVeBOpe9zw9oZMz+ad3QZ0g/WPiZQWIyX
         3FXX2aybYBKPAWaOFeDQTihDIx8fYG68nfFAoeMmDxxvcDU5U8pGjBh47ww8RtZjLUu6
         Zauw==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: APjAAAUX/ThrZtnn6lUnMtniu6xIrSlCiB1XPsoq1GiAeGurtvL5Q8hw
	Q/PFBNmiC8v/h3YQkqpz8Mc52FTeOTvWQnZLDQGqOjcCdvSjBVE3AbG69V+Dh4iSofEvNQ7jvWq
	P5adUJyyCvYNFS207lh+fguAY9duwPN9VOFj6aAn8pLoLL6aYEHwLu9vXkjaWHY/BbQ==
X-Received: by 2002:a17:906:6a43:: with SMTP id n3mr4482308ejs.0.1551887514131;
        Wed, 06 Mar 2019 07:51:54 -0800 (PST)
X-Google-Smtp-Source: APXvYqw79tVSbBoa/I4p7RYai83s1QrZQN7TckPizVkMhEWr0fXeg6f1Pyjo+9bhRpHVSS41GgwG
X-Received: by 2002:a17:906:6a43:: with SMTP id n3mr4482239ejs.0.1551887512766;
        Wed, 06 Mar 2019 07:51:52 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551887512; cv=none;
        d=google.com; s=arc-20160816;
        b=Ib7ZGaO7pSmM049s4cJcanwtaEsXnwkAfzeJeeR7BouOagm1cZyGjP9Wyoux2Ssk+j
         b3C8dIePNz4Izr9VkVIoASza9jAxPY7uLlA62RdDxrKZuPEFexxLPcy4MiidH97dWnX7
         2lOfmp9cjVKaHPnCuG4jpCSklOwd4Kc3I4WdNqXQT2+jV5DtQerU6NI2YVEFAgIqsHol
         O6Za91hi1vWQXrpbFg5ik1aytTtiqKqMgENsdvzH4/ho14E2NmW6bYqN0LilR8MUVXQ5
         xucgi17J/DNnI/izfDqcbIwLfM2FOsgdD52lr68G8hClckxCnSdr+ZU0aRUWgJkVRnp5
         0z2A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=2coDtKUAAHa6O24jio+8J0JOqtELt/lHMje4085swNg=;
        b=p2v36ELZDZVDsGhTfHY22DJQ1cN9fdAyKiVnerlhazKzqUdevQ5le1c1m6Gl5uIKEB
         NGZrpq/Ieg4MJ4wGIwuakSjN954vZPeCWJzTnqm5JPmljq91bEB6Cu965p9NtLPDsrDH
         CpyG60/1mp00t1JjE6O3KGXMc1I4mr1exZbZL0IolqpE0q7y9PW38HSzhcQKIYY9l1ha
         X+dl13AZPeRyniAudni8vDgYHAMXMqUZ+YKs/D6e8mzfztqjX73nJZw+0EaQBLp5QTIB
         F+WaBQq8A3Qk82IbRhZIOFtCGv7/cgMlXOpxpCuFzULVahVf/ZVXQd0N3CCjnXE/LrbO
         Q8bg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id w10si777608edc.303.2019.03.06.07.51.52
        for <linux-mm@kvack.org>;
        Wed, 06 Mar 2019 07:51:52 -0800 (PST)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id B8DE91A25;
	Wed,  6 Mar 2019 07:51:51 -0800 (PST)
Received: from e112269-lin.arm.com (e112269-lin.cambridge.arm.com [10.1.196.69])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 7D6503F703;
	Wed,  6 Mar 2019 07:51:48 -0800 (PST)
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
Subject: [PATCH v4 18/19] x86: mm: Convert ptdump_walk_pgd_level_core() to take an mm_struct
Date: Wed,  6 Mar 2019 15:50:30 +0000
Message-Id: <20190306155031.4291-19-steven.price@arm.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190306155031.4291-1-steven.price@arm.com>
References: <20190306155031.4291-1-steven.price@arm.com>
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
index 1c1b37c32787..b1c04ecc18cc 100644
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
@@ -524,10 +520,10 @@ static inline bool is_hypervisor_range(int idx)
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
@@ -574,39 +570,49 @@ static void ptdump_walk_pgd_level_core(struct seq_file *m, pgd_t *pgd,
 
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

