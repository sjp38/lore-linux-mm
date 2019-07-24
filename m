Return-Path: <SRS0=cVar=VV=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 891FDC7618B
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 06:04:34 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 456AA227BF
	for <linux-mm@archiver.kernel.org>; Wed, 24 Jul 2019 06:04:34 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 456AA227BF
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ghiti.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id E6C2E6B0008; Wed, 24 Jul 2019 02:04:33 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id E1DA48E0002; Wed, 24 Jul 2019 02:04:33 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id CE5486B000C; Wed, 24 Jul 2019 02:04:33 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 820306B0008
	for <linux-mm@kvack.org>; Wed, 24 Jul 2019 02:04:33 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id n3so29535681edr.8
        for <linux-mm@kvack.org>; Tue, 23 Jul 2019 23:04:33 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=xUMIXSZ5nuvBFA60vBMZNUvU4VVEKzW7SPhwc++PAj4=;
        b=ZD9v3243JN/69F+GokzPUqiyeCH5WKe31vUxP8kxMrTowiA5Dpb85bPYuSJxtIxgyz
         FuyrGwRUDDbEDHvmC0wFS9oVrMhMVUNw7RT2c1iX/dZIa3iUp8uopr0bhn7QG6jSvrsA
         /h9Yn7QGmgIIWf8jXQ979VaxRDOR6mWmXB//Cko7QUTL1CsdeLaPB619H6uUMUETKqDd
         czja8qP6GTNpsNCeiXctMFvK/xPU23I+0YtKn3gih8VQ5hh1t827BKQuFteKlHlYXCK1
         siGMToJWlPiIl30SlPoiBkDAAgqNH/9qpl7XPgbZyMfulvS0Xt+SyKuYTa+cusO1mdMD
         Qpng==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 217.70.178.232 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Gm-Message-State: APjAAAXpWl0guTa9rYAzsKJH2YjwSU+nmHSrJUlQprBPqpdVXsocBDor
	DiFYA314e3MiwoQudtIierD9T9aVIAgoUjpKpsazKPy1NZ2OeWk0rjujwW3GvkeZtuJV7+f1oCI
	6QhnVS5M4OnEkHpo0STmo7teSwLnD8ifnfiUV+QzSQpTJBpZkzjlgW2Cgzc1wRb0=
X-Received: by 2002:a05:6402:683:: with SMTP id f3mr67885709edy.200.1563948273110;
        Tue, 23 Jul 2019 23:04:33 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxpl4UoUS/PIgDmTxAzBFNEZ+7dkR8UbyPDwWbuwh7OrzXUva5qvVO5QCX7kFTaBf1u3FW/
X-Received: by 2002:a05:6402:683:: with SMTP id f3mr67885674edy.200.1563948272393;
        Tue, 23 Jul 2019 23:04:32 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563948272; cv=none;
        d=google.com; s=arc-20160816;
        b=Dm245FNNOYNPhNPVTMyLDWXxiMy82BwRp4xze0zQQbTvDb4Gybz32IU3EqeEYSqeft
         21JPhCEmyMelVWRVa3RzaHsvTqQfrpRJCszJi90jIac2q+8fBDh/RNq0EcPZ0qT0zkz7
         rRiSk9ZMO/uxLzOERBrRXwoaFAXaByrhngqC7gSGDfAHe8JQWvBjgtut5nq0ZV3476wc
         PRlbe1nl7+NQBkXcXd16Gx1MnArNTIGE3iM4Oti7jwxIEuafHjpgL8qjnyTZA59HSyTo
         Lka/WplaVQrVVsXtaatvi7uzuWfyd6kPo95f5WbfKE5N5fglDuQZJWazGoyWqplnk51h
         AhPg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=xUMIXSZ5nuvBFA60vBMZNUvU4VVEKzW7SPhwc++PAj4=;
        b=SGTnnaV8OkWPFb0BngA4qvqtKf38abPU0tENzJgWJMOexDK6dC9KKdZod3OLqPCwH2
         mJGM6f0tyx3yqhEt60d3YLAYMPrx7igQcHNY/81wN4ddd8XhIeI8nxTRrl4lQWfs8/iV
         HWx+1WVvZlDs7pknAuMbJJ4NDeDpPFX7aIVkXTHV5eCGIKYhbksiIsKjR4nQ7JW5xV+0
         s6dhO39xvMdDJ6Hzs4/GC+EXqAnuqEd32B6fuujsfnZ3noDYs0uReFMZbIEqLpVQvLNe
         pNCyjkSTTZ8s1/oQuP/RoiQxoi/t5i56jpeHw86VqzsRykeEIRZrN4q1G49GJVT/lY71
         qVKQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 217.70.178.232 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
Received: from relay12.mail.gandi.net (relay12.mail.gandi.net. [217.70.178.232])
        by mx.google.com with ESMTPS id m34si8328058edc.296.2019.07.23.23.04.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 23 Jul 2019 23:04:32 -0700 (PDT)
Received-SPF: neutral (google.com: 217.70.178.232 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) client-ip=217.70.178.232;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 217.70.178.232 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
Received: from alex.numericable.fr (127.19.86.79.rev.sfr.net [79.86.19.127])
	(Authenticated sender: alex@ghiti.fr)
	by relay12.mail.gandi.net (Postfix) with ESMTPSA id B5FF6200008;
	Wed, 24 Jul 2019 06:04:26 +0000 (UTC)
From: Alexandre Ghiti <alex@ghiti.fr>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Christoph Hellwig <hch@lst.de>,
	Russell King <linux@armlinux.org.uk>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	Ralf Baechle <ralf@linux-mips.org>,
	Paul Burton <paul.burton@mips.com>,
	James Hogan <jhogan@kernel.org>,
	Palmer Dabbelt <palmer@sifive.com>,
	Albert Ou <aou@eecs.berkeley.edu>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Luis Chamberlain <mcgrof@kernel.org>,
	Kees Cook <keescook@chromium.org>,
	linux-kernel@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	linux-mips@vger.kernel.org,
	linux-riscv@lists.infradead.org,
	linux-fsdevel@vger.kernel.org,
	linux-mm@kvack.org,
	Alexandre Ghiti <alex@ghiti.fr>
Subject: [PATCH REBASE v4 05/14] arm64, mm: Make randomization selected by generic topdown mmap layout
Date: Wed, 24 Jul 2019 01:58:41 -0400
Message-Id: <20190724055850.6232-6-alex@ghiti.fr>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190724055850.6232-1-alex@ghiti.fr>
References: <20190724055850.6232-1-alex@ghiti.fr>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This commits selects ARCH_HAS_ELF_RANDOMIZE when an arch uses the generic
topdown mmap layout functions so that this security feature is on by
default.
Note that this commit also removes the possibility for arm64 to have elf
randomization and no MMU: without MMU, the security added by randomization
is worth nothing.

Signed-off-by: Alexandre Ghiti <alex@ghiti.fr>
Acked-by: Catalin Marinas <catalin.marinas@arm.com>
Acked-by: Kees Cook <keescook@chromium.org>
Reviewed-by: Christoph Hellwig <hch@lst.de>
---
 arch/Kconfig                |  1 +
 arch/arm64/Kconfig          |  1 -
 arch/arm64/kernel/process.c |  8 --------
 mm/util.c                   | 11 +++++++++--
 4 files changed, 10 insertions(+), 11 deletions(-)

diff --git a/arch/Kconfig b/arch/Kconfig
index a0bb6fa4d381..d4c1f0551dfe 100644
--- a/arch/Kconfig
+++ b/arch/Kconfig
@@ -705,6 +705,7 @@ config HAVE_ARCH_COMPAT_MMAP_BASES
 config ARCH_WANT_DEFAULT_TOPDOWN_MMAP_LAYOUT
 	bool
 	depends on MMU
+	select ARCH_HAS_ELF_RANDOMIZE
 
 config HAVE_COPY_THREAD_TLS
 	bool
diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
index 14a194e63458..399f595ef852 100644
--- a/arch/arm64/Kconfig
+++ b/arch/arm64/Kconfig
@@ -16,7 +16,6 @@ config ARM64
 	select ARCH_HAS_DMA_MMAP_PGPROT
 	select ARCH_HAS_DMA_PREP_COHERENT
 	select ARCH_HAS_ACPI_TABLE_UPGRADE if ACPI
-	select ARCH_HAS_ELF_RANDOMIZE
 	select ARCH_HAS_FAST_MULTIPLIER
 	select ARCH_HAS_FORTIFY_SOURCE
 	select ARCH_HAS_GCOV_PROFILE_ALL
diff --git a/arch/arm64/kernel/process.c b/arch/arm64/kernel/process.c
index 6a869d9f304f..3f59d0d1632e 100644
--- a/arch/arm64/kernel/process.c
+++ b/arch/arm64/kernel/process.c
@@ -524,14 +524,6 @@ unsigned long arch_align_stack(unsigned long sp)
 	return sp & ~0xf;
 }
 
-unsigned long arch_randomize_brk(struct mm_struct *mm)
-{
-	if (is_compat_task())
-		return randomize_page(mm->brk, SZ_32M);
-	else
-		return randomize_page(mm->brk, SZ_1G);
-}
-
 /*
  * Called from setup_new_exec() after (COMPAT_)SET_PERSONALITY.
  */
diff --git a/mm/util.c b/mm/util.c
index 0781e5575cb3..16f1e56e2996 100644
--- a/mm/util.c
+++ b/mm/util.c
@@ -321,7 +321,15 @@ unsigned long randomize_stack_top(unsigned long stack_top)
 }
 
 #ifdef CONFIG_ARCH_WANT_DEFAULT_TOPDOWN_MMAP_LAYOUT
-#ifdef CONFIG_ARCH_HAS_ELF_RANDOMIZE
+unsigned long arch_randomize_brk(struct mm_struct *mm)
+{
+	/* Is the current task 32bit ? */
+	if (!IS_ENABLED(CONFIG_64BIT) || is_compat_task())
+		return randomize_page(mm->brk, SZ_32M);
+
+	return randomize_page(mm->brk, SZ_1G);
+}
+
 unsigned long arch_mmap_rnd(void)
 {
 	unsigned long rnd;
@@ -335,7 +343,6 @@ unsigned long arch_mmap_rnd(void)
 
 	return rnd << PAGE_SHIFT;
 }
-#endif /* CONFIG_ARCH_HAS_ELF_RANDOMIZE */
 
 static int mmap_is_legacy(struct rlimit *rlim_stack)
 {
-- 
2.20.1

