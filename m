Return-Path: <SRS0=csuj=WE=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.8 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id D0D5FC433FF
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 06:23:37 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9B65820B7C
	for <linux-mm@archiver.kernel.org>; Thu,  8 Aug 2019 06:23:37 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9B65820B7C
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ghiti.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3466B6B000A; Thu,  8 Aug 2019 02:23:37 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2D14C6B000C; Thu,  8 Aug 2019 02:23:37 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1C05B6B000D; Thu,  8 Aug 2019 02:23:37 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id BEACE6B000A
	for <linux-mm@kvack.org>; Thu,  8 Aug 2019 02:23:36 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id k37so847399eda.7
        for <linux-mm@kvack.org>; Wed, 07 Aug 2019 23:23:36 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=Uc9HCc/6hNvOV8B2vZv1Mz7T1SIEtuaecktNCSj6hGE=;
        b=DgcxQW8McC/TKfNQ2wPK8bbjRq5JFNjMK/yIgtCfpSE01MfVVixHFB2UbBuzEquaTI
         SohRhjnBk6kDeHINGBP3Wun7QxVskUN3mRCFcZy3YS057JZW8mHQjdbDZX/xm2l8fGUY
         ziHGAYPW/pYhfHC7zbMojpsqYZ9U7QZfD+QrsNS8v+su1Hv5TkP1QcEeQD+X7gAYaTBP
         PB0sXRPCsH71kCCdySSRtsV0OMKqbqux3hpuk5S1NWeiXpQUfAWShHpGshaX4tEqlMWK
         auQ7evjPsWhPtoHhCexue55pm0nkqP1iH9UyOahJkhkIve6wVBGJlNtjr6Ek/h4e1/oG
         u2+g==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 217.70.183.195 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Gm-Message-State: APjAAAUtNFF78/MVJuqu9knWyTLRCkH3JHzfFX7ltPCP9dTM4IUweMZu
	1PYWxjHAoXyKJUHzdDb1Kuq/ToIWa/iU+9XhUKsKY1eLCfMX+Jo/vuyJf18BaIgclZWkSrfEXYv
	31WD1vgK3j4EZrALOcUtjLZRWHAq4whOtlDuQcbFuCXYnk6oAo18hEc87UlD6mSE=
X-Received: by 2002:a05:6402:712:: with SMTP id w18mr4932280edx.201.1565245416239;
        Wed, 07 Aug 2019 23:23:36 -0700 (PDT)
X-Google-Smtp-Source: APXvYqz2AAvYy9fKM7jvQGyjwGxdMEEEo0CWTPhKvY31pFbVtO0YB3Lj/HTpTIetYhQdWBi9tXJv
X-Received: by 2002:a05:6402:712:: with SMTP id w18mr4932243edx.201.1565245415454;
        Wed, 07 Aug 2019 23:23:35 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1565245415; cv=none;
        d=google.com; s=arc-20160816;
        b=ANkZ1thjl+is+O+eHfiPZDjnMfueGI8KPmLM8Wfj1yp8Gw9A766pPSJ1fzZLSN9Ekj
         7W9SOETtQ4Z2jS9WrX9PUbA1BCUsN0AHvcx0fxZGHneefezHefoeepTzIht62fabZ0a6
         Z36yeLqwEKrT6bV5ZuV2+kxbJ76GsmEFXRExXxuJQNE8S+LpsMasXIJ9ydH23T/f3Xsu
         nfZ9dDWpWHoeo56HJ2vvZxMY5F3v1OapA/SQo4Co1DVPhctRSJ0o+wlGG8O8GiPWwjFa
         i2JDQZU7IqASMp3j3hKi7aqL7d3mBphBwqDjqOpWVF6QQjmp2HsnaSiBWSCZeAZdB+Kx
         Yd2A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=Uc9HCc/6hNvOV8B2vZv1Mz7T1SIEtuaecktNCSj6hGE=;
        b=Ru4vWwwdqQL4CDkEV1nydSPu9MRw1b8Io0IRt4uq1nbUUrAdNUj4IfEhqEcoD/OQ2C
         Z2gsq5sezwsGzvUX7BX+m4Zx3b4z1ZmPssniD/9yjQZlvsoc7eCFsQk46vFfv/Lwpgcb
         rgtTryqzlkeSBoz8SSK9GAa/SeEw4HtqQQn7EkVBi5e1pAtZIUCrJTdnPbmreRqBIx+y
         KcOOe4Yk8hxqbBjpHk5GgISy+p/7mqMVYUV1uvinD55fD0tqDJnJN7fEbwz8MTm1/g5H
         QeGA9UNadpfDmO5ekpPl05cXdu/UEjie0dGzGo3QEbmzCDrqO5e7K6vQhI/8JQnc8gYL
         GDrA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 217.70.183.195 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
Received: from relay3-d.mail.gandi.net (relay3-d.mail.gandi.net. [217.70.183.195])
        by mx.google.com with ESMTPS id b17si638481edb.341.2019.08.07.23.23.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 07 Aug 2019 23:23:35 -0700 (PDT)
Received-SPF: neutral (google.com: 217.70.183.195 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) client-ip=217.70.183.195;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 217.70.183.195 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Originating-IP: 79.86.19.127
Received: from alex.numericable.fr (127.19.86.79.rev.sfr.net [79.86.19.127])
	(Authenticated sender: alex@ghiti.fr)
	by relay3-d.mail.gandi.net (Postfix) with ESMTPSA id D423E60002;
	Thu,  8 Aug 2019 06:23:30 +0000 (UTC)
From: Alexandre Ghiti <alex@ghiti.fr>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Paul Walmsley <paul.walmsley@sifive.com>,
	Luis Chamberlain <mcgrof@kernel.org>,
	Christoph Hellwig <hch@lst.de>,
	Russell King <linux@armlinux.org.uk>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	Ralf Baechle <ralf@linux-mips.org>,
	Paul Burton <paul.burton@mips.com>,
	James Hogan <jhogan@kernel.org>,
	Palmer Dabbelt <palmer@sifive.com>,
	Albert Ou <aou@eecs.berkeley.edu>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Kees Cook <keescook@chromium.org>,
	linux-kernel@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org,
	linux-mips@vger.kernel.org,
	linux-riscv@lists.infradead.org,
	linux-fsdevel@vger.kernel.org,
	linux-mm@kvack.org,
	Alexandre Ghiti <alex@ghiti.fr>
Subject: [PATCH v6 05/14] arm64, mm: Make randomization selected by generic topdown mmap layout
Date: Thu,  8 Aug 2019 02:17:47 -0400
Message-Id: <20190808061756.19712-6-alex@ghiti.fr>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190808061756.19712-1-alex@ghiti.fr>
References: <20190808061756.19712-1-alex@ghiti.fr>
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
Reviewed-by: Luis Chamberlain <mcgrof@kernel.org>
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
index f674f28df663..8ddc2471b054 100644
--- a/arch/arm64/kernel/process.c
+++ b/arch/arm64/kernel/process.c
@@ -548,14 +548,6 @@ unsigned long arch_align_stack(unsigned long sp)
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

