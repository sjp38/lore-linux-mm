Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0DC5AC32751
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 15:47:08 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C4AE8214DA
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 15:47:07 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C4AE8214DA
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 26A0A8E0024; Wed, 31 Jul 2019 11:47:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 242978E0003; Wed, 31 Jul 2019 11:47:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 10BE08E0024; Wed, 31 Jul 2019 11:47:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id B5F828E0003
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 11:47:03 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id z20so42703874edr.15
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 08:47:03 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=S8UWoGAjbQzkRfJne+k52mUoFeIHKsUKT3qxB38cy7g=;
        b=a/uJ+FpCNDQhrWb57au5n+MmkM6+nDuZvHTduxSME/8IEppmEz0jLi1EEmRu+UeciN
         dTgo1Q1RDdoumQbhmzFEokM6uc/wpSXyS4M4sl5AqCMDKEKzpAX/dRLF2wM66ru9+fkG
         kgdg2BahZENzKJGy9qF6yZQPwpLJooHc3htirVGD16lR7nTzUJbQlY5C9LQhsAeLh388
         bi8eru6uWjS89qdEOB/vREYhIuY8kLoYhygZSWT9GJhR+e8atULscbSLh3G7L3daTt5n
         5CeBJebcnxB+88xDkissnpu83hsjdu49Kg/xWYFBmBy+DWZfvtyLvAUUH8CIwrJjg5kx
         aKCg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: APjAAAW1tSsfp2lXS8XBGshPzIdjWcschmqUYDgaiUIZzDxr+b/3US5t
	ppDMc/UhXhF+/cefVnUFiP18he9JSEZyj8CKsc2JeyWh2vguIBtrbdiN1V1ucK4k3TbLSU0vHgx
	IRNH3gcjf3bfkhwWKf7M1UU5Nka/150bOU3sKDv96UAzzYvVemL8UbPiWOkaNfe+feQ==
X-Received: by 2002:a17:906:7d12:: with SMTP id u18mr93462099ejo.24.1564588023320;
        Wed, 31 Jul 2019 08:47:03 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwqmghijKYNbHhIf9N/+HoEJB0x691sVDofzGIo5/8pgKlhm/YgToED1Bf5iBOXXvSqS7si
X-Received: by 2002:a17:906:7d12:: with SMTP id u18mr93462044ejo.24.1564588022407;
        Wed, 31 Jul 2019 08:47:02 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564588022; cv=none;
        d=google.com; s=arc-20160816;
        b=GpeIUoyj5l8+PzV9nyIU9zSj+9gVHmVpp+LRZzcBa7xXnm5CroQwfMvOAmX6I3n7DI
         +TrLzNCvZJRq+wJqtDP+LIuhop79XL9ozzW/DC/mN/JyqPrDbt7DCCYQREDiqyUbX8tk
         JgnEdJd74j0nqYGGkhnwpkeQw12i+XyyNwyUDEWN2E15QMgx9MQVj8D7LcBujTLdvFdL
         5+0AMVjdiGTNsa9+A/iO9VoLIMA3zR+g4eqXgGyK8ilSt5t6BodxD5KMLZrNPIth7lsx
         0Wi5cFqIxGpntKfDtLXkB1qZHkNhHa8bD89yPXE2ZhE0GKFfAUOU90LZEaUX61a6Uhkx
         gCcg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=S8UWoGAjbQzkRfJne+k52mUoFeIHKsUKT3qxB38cy7g=;
        b=vGDwnERgZAdlDVD+8Yii/Jw2MZN45MFZmhTDGAfqKyWFMgbBZQX6d6vC3unc5xyQf3
         y8bQZeKruZ2Lpvcoe+pdQaMYa8T5R8TwKnF/0xdlgADZ0SmcWuHuloR7KwFimWIgn2OK
         gkFmx7mIsPvDV9i7GhSYyDr5OkzAYZ7M0Jdxg08iBp/tR4aiWTacMVlV2prnJtHbPFWl
         GIHt+hBYc1Bjj3mAiZhCrE3NckQWeqHXxew70+LIUTQs4LwDI30woBVN1Tzsf9sBOgeC
         3IAyja7q9Ds9HyiqE0pOyvZbuOwRL8hhAVDq7akXPWQowJcaKg8rulWGvhklhvs7yRL6
         /JQw==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id f12si22860525edd.204.2019.07.31.08.47.02
        for <linux-mm@kvack.org>;
        Wed, 31 Jul 2019 08:47:02 -0700 (PDT)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 8A2281570;
	Wed, 31 Jul 2019 08:47:01 -0700 (PDT)
Received: from e112269-lin.arm.com (e112269-lin.cambridge.arm.com [10.1.196.133])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 0131B3F694;
	Wed, 31 Jul 2019 08:46:58 -0700 (PDT)
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
Subject: [PATCH v10 17/22] x86: mm: Convert ptdump_walk_pgd_level_debugfs() to take an mm_struct
Date: Wed, 31 Jul 2019 16:45:58 +0100
Message-Id: <20190731154603.41797-18-steven.price@arm.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190731154603.41797-1-steven.price@arm.com>
References: <20190731154603.41797-1-steven.price@arm.com>
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
index 1a2b469f6e75..1b255987712e 100644
--- a/arch/x86/include/asm/pgtable.h
+++ b/arch/x86/include/asm/pgtable.h
@@ -30,7 +30,8 @@ extern pgd_t early_top_pgt[PTRS_PER_PGD];
 int __init __early_make_pgtable(unsigned long address, pmdval_t pmd);
 
 void ptdump_walk_pgd_level(struct seq_file *m, struct mm_struct *mm);
-void ptdump_walk_pgd_level_debugfs(struct seq_file *m, pgd_t *pgd, bool user);
+void ptdump_walk_pgd_level_debugfs(struct seq_file *m, struct mm_struct *mm,
+				   bool user);
 void ptdump_walk_pgd_level_checkwx(void);
 void ptdump_walk_user_pgd_level_checkwx(void);
 
diff --git a/arch/x86/mm/debug_pagetables.c b/arch/x86/mm/debug_pagetables.c
index 39001a401eff..d0efec713c6c 100644
--- a/arch/x86/mm/debug_pagetables.c
+++ b/arch/x86/mm/debug_pagetables.c
@@ -7,7 +7,7 @@
 
 static int ptdump_show(struct seq_file *m, void *v)
 {
-	ptdump_walk_pgd_level_debugfs(m, NULL, false);
+	ptdump_walk_pgd_level_debugfs(m, &init_mm, false);
 	return 0;
 }
 
@@ -17,7 +17,7 @@ static int ptdump_curknl_show(struct seq_file *m, void *v)
 {
 	if (current->mm->pgd) {
 		down_read(&current->mm->mmap_sem);
-		ptdump_walk_pgd_level_debugfs(m, current->mm->pgd, false);
+		ptdump_walk_pgd_level_debugfs(m, current->mm, false);
 		up_read(&current->mm->mmap_sem);
 	}
 	return 0;
@@ -30,7 +30,7 @@ static int ptdump_curusr_show(struct seq_file *m, void *v)
 {
 	if (current->mm->pgd) {
 		down_read(&current->mm->mmap_sem);
-		ptdump_walk_pgd_level_debugfs(m, current->mm->pgd, true);
+		ptdump_walk_pgd_level_debugfs(m, current->mm, true);
 		up_read(&current->mm->mmap_sem);
 	}
 	return 0;
@@ -43,7 +43,7 @@ DEFINE_SHOW_ATTRIBUTE(ptdump_curusr);
 static int ptdump_efi_show(struct seq_file *m, void *v)
 {
 	if (efi_mm.pgd)
-		ptdump_walk_pgd_level_debugfs(m, efi_mm.pgd, false);
+		ptdump_walk_pgd_level_debugfs(m, &efi_mm, false);
 	return 0;
 }
 
diff --git a/arch/x86/mm/dump_pagetables.c b/arch/x86/mm/dump_pagetables.c
index 24fe76325b31..2f5f32f21f81 100644
--- a/arch/x86/mm/dump_pagetables.c
+++ b/arch/x86/mm/dump_pagetables.c
@@ -518,16 +518,12 @@ static inline bool is_hypervisor_range(int idx)
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
@@ -572,8 +568,10 @@ void ptdump_walk_pgd_level(struct seq_file *m, struct mm_struct *mm)
 	ptdump_walk_pgd_level_core(m, mm->pgd, false, true);
 }
 
-void ptdump_walk_pgd_level_debugfs(struct seq_file *m, pgd_t *pgd, bool user)
+void ptdump_walk_pgd_level_debugfs(struct seq_file *m, struct mm_struct *mm,
+				   bool user)
 {
+	pgd_t *pgd = mm->pgd;
 #ifdef CONFIG_PAGE_TABLE_ISOLATION
 	if (user && boot_cpu_has(X86_FEATURE_PTI))
 		pgd = kernel_to_user_pgdp(pgd);
@@ -599,7 +597,7 @@ void ptdump_walk_user_pgd_level_checkwx(void)
 
 void ptdump_walk_pgd_level_checkwx(void)
 {
-	ptdump_walk_pgd_level_core(NULL, NULL, true, false);
+	ptdump_walk_pgd_level_core(NULL, INIT_PGD, true, false);
 }
 
 static int __init pt_dump_init(void)
-- 
2.20.1

