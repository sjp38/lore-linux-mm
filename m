Return-Path: <SRS0=2Grs=V4=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 4C9B1C32751
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 15:47:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 08FBA2184D
	for <linux-mm@archiver.kernel.org>; Wed, 31 Jul 2019 15:47:11 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 08FBA2184D
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id CF2EB8E0025; Wed, 31 Jul 2019 11:47:06 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id CCADB8E0003; Wed, 31 Jul 2019 11:47:06 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B91E98E0025; Wed, 31 Jul 2019 11:47:06 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 654688E0003
	for <linux-mm@kvack.org>; Wed, 31 Jul 2019 11:47:06 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id y24so42733254edb.1
        for <linux-mm@kvack.org>; Wed, 31 Jul 2019 08:47:06 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=0ZNi3wu57Zc9Md+8OEhjIzPPnSQp51CnLOM2RGWHFP8=;
        b=ExAtsk4lWP+VZEIGWxsUsiJQs5EbLPmUct6eipnh5KuuI8FCuyd/kmwsDqEahPdo5V
         N3qahli8AbVVh58kw8WL9Ac+3Jc98sEoSfT/Wr60mq0J0zUXbRzxX45G+YaDEFk/oOEZ
         Iz4rop48f5zIS/+T02fDvOKWoOxUf6/jnixEcGlZTfwY2lPSAnXlVoLHmTu3XXIpznso
         fnCOXVkDyDsYoVx8EEP7qiJkJuZldTj2k9AB3GVYoN2OIfPBx0mYkAeXPnwokime9T5p
         tqEvRt8xRUpXy/QvhCACfB0m07a8e1+xXKy/3LldXFBZRm0sH4GF9CkehcxMvpSZlo+x
         j2Xg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: APjAAAWfO1d4sv3lY6q10lQTIuPW9/GQsEEPc95dOUuVMjoieuU/j7HC
	hnTx6AxZnVLI2IaF5c0ksvy87b9q/mwwgHTtSOeAVtpz0Kk7uLMFITImEXozWLclRaiI2lmQ302
	5SCMfUfl9/c6qZmfkQu4sDdaeu+peDOrkhhVOMHqO/0PU+tCVOylO10cQ7u6LBpVYRg==
X-Received: by 2002:a50:d7d0:: with SMTP id m16mr105538637edj.162.1564588025998;
        Wed, 31 Jul 2019 08:47:05 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwiIEkE1nFakMWdh567UME55ptXYkgFepJsVEjqQtysxicJiUkNKPC2JH1VVaXeGlSOWaCZ
X-Received: by 2002:a50:d7d0:: with SMTP id m16mr105538575edj.162.1564588025190;
        Wed, 31 Jul 2019 08:47:05 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564588025; cv=none;
        d=google.com; s=arc-20160816;
        b=oacGW36hIBCQwMWl/c8I2qVfLT++pTdFerT0Cb28i+0Zf9T1OmU0/I2l20S/R4pXaO
         EsM8d10OBSpaBS3ns7qw8FstM/v01/xxxIkdMgqaQjxsv8soL023cYmGBd/cszF1yt7y
         oNf8UUN+Uev2gH1K/UorYS8Q4k5Rbn9E/e/+nXtHYT7aiE3lFRWZJNk3Kf+K/gh7i2+3
         ono2kKFGyqQG4TtCpiDJ0MKNz/kgj50h+EHuW+//1GB3j1dv6hGVahrBNVOdBYMdCF3x
         iw+krIUcybtpHMgn1GmEedHSigaGGLsMKGEY6gS9sycQy8fdjbIi+lnuAFTsSIg8v8ls
         P+EA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=0ZNi3wu57Zc9Md+8OEhjIzPPnSQp51CnLOM2RGWHFP8=;
        b=hdbMRLzcLZXiXL+6E9r/c4iyMGFUwzQXp29FcZNCbUjnZiQf2Kr+0vCNe7t2ULuwHY
         aWBmAOVu3CVkaVyOddY5T78L3V8uc4V45bbVeEMZYsnqb2uvyf9/ZI0s9apNNN1KmCZc
         EudK+Op2sez7P/kzxGnWdj5+HRf+PuX6UYzIMJ0yyhSCIMgTnt8D5SBlKFEEI0ywTeDR
         iO/52PKavSyOF80jJSuNBComwR3vNaNQfyS9lADMfyjffnj+ZhSzxVDPT7/eRztDHEEx
         ns9l/wEuqu4v7EmWx+0HquazL+Rq29YEy9xz3n71z21y3TlQ4mx6VBkQ3mFoG7Amf/yN
         AmJA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id f13si21824472eda.21.2019.07.31.08.47.04
        for <linux-mm@kvack.org>;
        Wed, 31 Jul 2019 08:47:05 -0700 (PDT)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 56001344;
	Wed, 31 Jul 2019 08:47:04 -0700 (PDT)
Received: from e112269-lin.arm.com (e112269-lin.cambridge.arm.com [10.1.196.133])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id C0CF33F694;
	Wed, 31 Jul 2019 08:47:01 -0700 (PDT)
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
Subject: [PATCH v10 18/22] x86: mm: Convert ptdump_walk_pgd_level_core() to take an mm_struct
Date: Wed, 31 Jul 2019 16:45:59 +0100
Message-Id: <20190731154603.41797-19-steven.price@arm.com>
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
index 2f5f32f21f81..3632be89ec99 100644
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
@@ -515,10 +511,10 @@ static inline bool is_hypervisor_range(int idx)
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
@@ -565,39 +561,49 @@ static void ptdump_walk_pgd_level_core(struct seq_file *m, pgd_t *pgd,
 
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

