Return-Path: <SRS0=xW7F=T2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 169EBC282E3
	for <linux-mm@archiver.kernel.org>; Sun, 26 May 2019 13:53:50 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BC1762075E
	for <linux-mm@archiver.kernel.org>; Sun, 26 May 2019 13:53:49 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BC1762075E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ghiti.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 6D4B26B0003; Sun, 26 May 2019 09:53:49 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 685316B0005; Sun, 26 May 2019 09:53:49 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 59AC46B0007; Sun, 26 May 2019 09:53:49 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id 0AF096B0003
	for <linux-mm@kvack.org>; Sun, 26 May 2019 09:53:49 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id n23so23335370edv.9
        for <linux-mm@kvack.org>; Sun, 26 May 2019 06:53:49 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=VTQC7kI6uLCH8Kj/P0fJoMTcPRoRnmnCtakF65iLIOc=;
        b=TZeZtAIEV0XdnDIBNhizXWen7RQWGtQp0AQbMCPqezdvu5nomFwXXbDGAXiAHtTh+y
         mAFleCmu7ghrT15eKRJ4DtNvI/M4M/ibQOTkb+w0tb0Z6N2HnPpte/o1Susy3QWYlKwI
         YOkjloZ7NStzTsMKze3cIFDVvqR4ABakfjNYba/wNeN96CEPdJDlamrz/Wa/om49+FqP
         wx15QNfEoJpYvr8ErOy9S5C/dpxffxonf40ERozoDQHw6ekI9tljvK6ksNeYribNJ5eC
         PbMh65XGqNr05FcQ7TDvTsBH5DkOxd4Wt2Yt1zvavfWuxMkVTRKVWW1SKuCoqPAfUqE8
         oZXw==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 217.70.178.231 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Gm-Message-State: APjAAAXax/qlZRhif9P2KOtv0P6DDPz1SVHH/30AeOCcA31+BIjDWMeC
	XjChr4UY8s/uX05HBZ22rX/lSqbjzA+Q+J+NiNU2UiYOvRcmVxYpWPLb17z1bkk9L/3xuplbSwm
	0mG2fqR0m4apUkybIpzjojYQ2fe9oAg3mQn9VeeRbC5qjQjQuTqJudOlmLjfDGzk=
X-Received: by 2002:a50:f5d4:: with SMTP id x20mr116150460edm.88.1558878828554;
        Sun, 26 May 2019 06:53:48 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwnRYVl7BdQ+Pt3avWk7DBivEpWgtrw5KGanPZjy+P6yg4YkCgWtdKTpfDmz4d0ph64UUOC
X-Received: by 2002:a50:f5d4:: with SMTP id x20mr116150384edm.88.1558878827320;
        Sun, 26 May 2019 06:53:47 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558878827; cv=none;
        d=google.com; s=arc-20160816;
        b=nHUp5iW+XxXz1fpYLgFOyl57IVL9LHSmWtj9CJjD0/tkECMXZh983A5EcKN2qZ0Uq0
         06o15VM/pgJC2kAp1vFHwJ9P2sLxR0kijLSmvE9oG7bXanh1DRsJgVVp7HRIUKn6qGvf
         8c13PfuWiYMLt2qebyXMyEllkw4R87MwqZzvyd5PBU8TABXxBoxIDNbd9T6/CBlnn9ca
         1osIG4eob7EGHEV2OsE+bPEzfm4LP+9w9XZA6F/HNmucMqCMmzXf0XOg4rjMS7FPYvHl
         RcSFOwfi64wskJdKoxT+bc1QrsuR7E+jD71FeKtSnpq2TF+XVDCWdMPwLqMtNp/bokC+
         M9cg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=VTQC7kI6uLCH8Kj/P0fJoMTcPRoRnmnCtakF65iLIOc=;
        b=uvZjHOe1/0ZhdKnfbkHpr58rmZry+PvwJgd1b+rPY+qj2CjJ8kh6mDxNJhsTqsAslR
         /4MiDwbwKugXRkK72XUMyt1s9m281vhgjufk6JKY80EpVTCC2cLUQ07Byt9Fl/KHXSK8
         F+tnT77jXlynpswEl/weIIupdzu6z9qbYOi7ygBrTNLrG4HmVROQXJkcq0fck40fZSR7
         wNZg29AsnriqccMEsIbXBc7OYl39Xf3add+9B4PxSx9tmHCFQJC+eMjBxfilrRsgCNKr
         RJ9Yq5btzaHbvQaJgzDaaH8QzNcpBeFLHE1DXLCCnkHOp/G6vjpzOdd50lswdzUgAf6X
         oDyQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 217.70.178.231 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
Received: from relay11.mail.gandi.net (relay11.mail.gandi.net. [217.70.178.231])
        by mx.google.com with ESMTPS id d19si1122278ejt.19.2019.05.26.06.53.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sun, 26 May 2019 06:53:47 -0700 (PDT)
Received-SPF: neutral (google.com: 217.70.178.231 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) client-ip=217.70.178.231;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 217.70.178.231 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
Received: from alex.numericable.fr (127.19.86.79.rev.sfr.net [79.86.19.127])
	(Authenticated sender: alex@ghiti.fr)
	by relay11.mail.gandi.net (Postfix) with ESMTPSA id EAC53100002;
	Sun, 26 May 2019 13:53:41 +0000 (UTC)
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
Subject: [PATCH v4 05/14] arm64, mm: Make randomization selected by generic topdown mmap layout
Date: Sun, 26 May 2019 09:47:37 -0400
Message-Id: <20190526134746.9315-6-alex@ghiti.fr>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190526134746.9315-1-alex@ghiti.fr>
References: <20190526134746.9315-1-alex@ghiti.fr>
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
---
 arch/Kconfig                |  1 +
 arch/arm64/Kconfig          |  1 -
 arch/arm64/kernel/process.c |  8 --------
 mm/util.c                   | 11 +++++++++--
 4 files changed, 10 insertions(+), 11 deletions(-)

diff --git a/arch/Kconfig b/arch/Kconfig
index df3ab04270fa..3732654446cc 100644
--- a/arch/Kconfig
+++ b/arch/Kconfig
@@ -710,6 +710,7 @@ config HAVE_ARCH_COMPAT_MMAP_BASES
 config ARCH_WANT_DEFAULT_TOPDOWN_MMAP_LAYOUT
 	bool
 	depends on MMU
+	select ARCH_HAS_ELF_RANDOMIZE
 
 config HAVE_COPY_THREAD_TLS
 	bool
diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
index 3d754c19c11e..403bd3fffdbc 100644
--- a/arch/arm64/Kconfig
+++ b/arch/arm64/Kconfig
@@ -15,7 +15,6 @@ config ARM64
 	select ARCH_HAS_DMA_MMAP_PGPROT
 	select ARCH_HAS_DMA_PREP_COHERENT
 	select ARCH_HAS_ACPI_TABLE_UPGRADE if ACPI
-	select ARCH_HAS_ELF_RANDOMIZE
 	select ARCH_HAS_FAST_MULTIPLIER
 	select ARCH_HAS_FORTIFY_SOURCE
 	select ARCH_HAS_GCOV_PROFILE_ALL
diff --git a/arch/arm64/kernel/process.c b/arch/arm64/kernel/process.c
index 3767fb21a5b8..3f85f8f2d665 100644
--- a/arch/arm64/kernel/process.c
+++ b/arch/arm64/kernel/process.c
@@ -535,14 +535,6 @@ unsigned long arch_align_stack(unsigned long sp)
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
index 717f5d75c16e..8a38126edc74 100644
--- a/mm/util.c
+++ b/mm/util.c
@@ -319,7 +319,15 @@ unsigned long randomize_stack_top(unsigned long stack_top)
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
@@ -333,7 +341,6 @@ unsigned long arch_mmap_rnd(void)
 
 	return rnd << PAGE_SHIFT;
 }
-#endif /* CONFIG_ARCH_HAS_ELF_RANDOMIZE */
 
 static int mmap_is_legacy(struct rlimit *rlim_stack)
 {
-- 
2.20.1

