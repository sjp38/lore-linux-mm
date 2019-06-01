Return-Path: <SRS0=MiGm=UA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 50F06C28CC6
	for <linux-mm@archiver.kernel.org>; Sat,  1 Jun 2019 07:51:19 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F2E8F27144
	for <linux-mm@archiver.kernel.org>; Sat,  1 Jun 2019 07:51:18 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="AU5xvubM"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F2E8F27144
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 9767E6B026F; Sat,  1 Jun 2019 03:51:02 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 8FA0A6B027A; Sat,  1 Jun 2019 03:51:02 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 74C0C6B027B; Sat,  1 Jun 2019 03:51:02 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 108D96B026F
	for <linux-mm@kvack.org>; Sat,  1 Jun 2019 03:51:02 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id f9so9183776pfn.6
        for <linux-mm@kvack.org>; Sat, 01 Jun 2019 00:51:02 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=CX2xDKm/BtwIjEp1GIuII943bJVuO6SxR5dA4QjQvNY=;
        b=mSdKOUAMKSr+kZ/raOA1+nBV47lrX3IjJ/zwrpwyU6C/NR06g0GaPx8atrcJ2Udcwq
         mGDT6fNd0m0whxNs95MTTxrq68HsI5mn4JGOqowHhhXSNNKZNUnpjxkkoA6HOAZjKIyN
         B5whomsoJyhqqLvH/i210F+zaPbRcRm6cJ9r3UMbwifoh1XWaHDltaEa1u8oGWedRHET
         0Jq32HOGOgvN6uJYMuxbpZEbdpaYQfGVomxquAqu+p1o2tGOAPIXIxnGvSU20cbbtVL+
         nR//oVpdXfoUXY/CdOmSUSLo8uq1nWA6NOPyH1dUNUkoB5k5zqlemXCiP0hqRhofbMDC
         LzCQ==
X-Gm-Message-State: APjAAAWixgRVE+JCEUtCj1bn5dsTIYEiKfHc68jB7NF7c7rh5nkoBa1C
	nY86f8xPwNOcdkoRdBnS3eo0tUOwe0SutUpcEQLpjl/U8O0Xsv7HAn6IaoQQKCR9KoyTnSAwFCm
	V3D2EeLcDFHym1qHH09OQkmy2clZTwLZdjUzscROx+JIiY/KYvG2Z1GbII0JfU4E=
X-Received: by 2002:a17:902:30a3:: with SMTP id v32mr14609479plb.6.1559375461701;
        Sat, 01 Jun 2019 00:51:01 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwAiO++TOm8ZIZ0fsHNydQIezd5i0xKAS5kY5/d+yBUe5oF/gE2WsgWybHecOo+CmPUOBxM
X-Received: by 2002:a17:902:30a3:: with SMTP id v32mr14609406plb.6.1559375460417;
        Sat, 01 Jun 2019 00:51:00 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559375460; cv=none;
        d=google.com; s=arc-20160816;
        b=qHCemxNVSOJwUDD9KFiZnqk8wdBZlj80Ifxyv19VwTeuvWe1nwqD4B7SIOuuoubG25
         qX95I7IEqqh/YmLmSKs9RJ9/yW1tMRmVEoXHC/O1o6Dc8xgdFidUry9KcdZbvG7VDRzE
         lTkiG3A6tGUBbSSQepeSsJXZG/nj07XIFBGLRYrw8suinldtsIiqdjAl7PfdX7eXiv4n
         dCxRiT8tZ6hKoajkdNkcgyzFV41aaioWe7P9VGcOEqA9yDKS38FBUkNvSUmNOqxrDJ6c
         qvLk5N5Yi81d0USbdT3TdEz3L4taE5mxGTg3p5K09mEsTpoapUUkc+/whhbGltzXNi7j
         YN2A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=CX2xDKm/BtwIjEp1GIuII943bJVuO6SxR5dA4QjQvNY=;
        b=oKNvLgk0S+M49zdArUnkWPuIaReN0tKpw+PT1/2NeKPtvqNtOzJro692ohtISarsqh
         GzAT3o7ZztOW3TxL4eZayKgqa0iEbBdRxTgB/hfVrXC3Wict72A6hFALWrex5k1zOcRI
         /daU02vTzok2pg59GIhHDwYsw3wYCDh51pxguyFI8J/NYxAPSqUKVeCuV4ZsM8wIpWg8
         41G002OnMgfbOWPGxa1IQPmzjanGhrZvzsEVzzzlXxgxtTJ/4xUHMzABvca9t0zXbvzJ
         TyCGuKw7/P0T1nbcy5FSNbWjzZczmKRYeXr9BzZQYSS9Cnwq+PoxjW+48MkiBT80KTeu
         zJqw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=AU5xvubM;
       spf=pass (google.com: best guess record for domain of batv+47bfdebe920718d2a071+5760+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+47bfdebe920718d2a071+5760+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id n189si8681600pgn.581.2019.06.01.00.51.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sat, 01 Jun 2019 00:51:00 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+47bfdebe920718d2a071+5760+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=AU5xvubM;
       spf=pass (google.com: best guess record for domain of batv+47bfdebe920718d2a071+5760+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+47bfdebe920718d2a071+5760+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=CX2xDKm/BtwIjEp1GIuII943bJVuO6SxR5dA4QjQvNY=; b=AU5xvubMQ09fI70Q63kOIrJTuq
	zYJMF3aefcDf0GFcW9nCJfY+4JpjP9HfbzZCCOhkO9v/S83lbkxevdCxzAjjrt+lYvSC2jC2F9L0S
	uaTVpl+kGZRFRPEZHnofRjsVXNP6xcTfJUZDaU/Dex1wTevMmCnBzqA3ZMuJugywLyWp1lEnk51ZE
	EwkSMxuTvCaMF9hkxI89xtxd7p7AfF31oQtDcoW3NBjKnMQP93xlio5LR2SkZqaWLRE7QsZ6UjfEU
	d7G7A4FP2dKMsdkjB+CEpRnZmj4YJU0vIkmAXfxBwOfkSmilr+JV9GofODCn+nUJOW+Jr0S9O57si
	KiXVyKDQ==;
Received: from 217-76-161-89.static.highway.a1.net ([217.76.161.89] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hWyms-0007o0-7f; Sat, 01 Jun 2019 07:50:47 +0000
From: Christoph Hellwig <hch@lst.de>
To: Linus Torvalds <torvalds@linux-foundation.org>,
	Paul Burton <paul.burton@mips.com>,
	James Hogan <jhogan@kernel.org>,
	Yoshinori Sato <ysato@users.sourceforge.jp>,
	Rich Felker <dalias@libc.org>,
	"David S. Miller" <davem@davemloft.net>
Cc: Nicholas Piggin <npiggin@gmail.com>,
	Khalid Aziz <khalid.aziz@oracle.com>,
	Andrey Konovalov <andreyknvl@google.com>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Paul Mackerras <paulus@samba.org>,
	Michael Ellerman <mpe@ellerman.id.au>,
	linux-mips@vger.kernel.org,
	linux-sh@vger.kernel.org,
	sparclinux@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org,
	linux-mm@kvack.org,
	x86@kernel.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH 11/16] mm: rename CONFIG_HAVE_GENERIC_GUP to CONFIG_HAVE_FAST_GUP
Date: Sat,  1 Jun 2019 09:49:54 +0200
Message-Id: <20190601074959.14036-12-hch@lst.de>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190601074959.14036-1-hch@lst.de>
References: <20190601074959.14036-1-hch@lst.de>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-SRS-Rewrite: SMTP reverse-path rewritten from <hch@infradead.org> by bombadil.infradead.org. See http://www.infradead.org/rpr.html
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

We only support the generic GUP now, so rename the config option to
be more clear, and always use the mm/Kconfig definition of the
symbol and select it from the arch Kconfigs.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 arch/arm/Kconfig     | 5 +----
 arch/arm64/Kconfig   | 4 +---
 arch/mips/Kconfig    | 2 +-
 arch/powerpc/Kconfig | 2 +-
 arch/s390/Kconfig    | 2 +-
 arch/sh/Kconfig      | 2 +-
 arch/sparc/Kconfig   | 2 +-
 arch/x86/Kconfig     | 4 +---
 mm/Kconfig           | 2 +-
 mm/gup.c             | 4 ++--
 10 files changed, 11 insertions(+), 18 deletions(-)

diff --git a/arch/arm/Kconfig b/arch/arm/Kconfig
index 8869742a85df..3879a3e2c511 100644
--- a/arch/arm/Kconfig
+++ b/arch/arm/Kconfig
@@ -73,6 +73,7 @@ config ARM
 	select HAVE_DYNAMIC_FTRACE_WITH_REGS if HAVE_DYNAMIC_FTRACE
 	select HAVE_EFFICIENT_UNALIGNED_ACCESS if (CPU_V6 || CPU_V6K || CPU_V7) && MMU
 	select HAVE_EXIT_THREAD
+	select HAVE_FAST_GUP if ARM_LPAE
 	select HAVE_FTRACE_MCOUNT_RECORD if !XIP_KERNEL
 	select HAVE_FUNCTION_GRAPH_TRACER if !THUMB2_KERNEL && !CC_IS_CLANG
 	select HAVE_FUNCTION_TRACER if !XIP_KERNEL
@@ -1596,10 +1597,6 @@ config ARCH_SELECT_MEMORY_MODEL
 config HAVE_ARCH_PFN_VALID
 	def_bool ARCH_HAS_HOLES_MEMORYMODEL || !SPARSEMEM
 
-config HAVE_GENERIC_GUP
-	def_bool y
-	depends on ARM_LPAE
-
 config HIGHMEM
 	bool "High Memory Support"
 	depends on MMU
diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
index 697ea0510729..4a6ee3e92757 100644
--- a/arch/arm64/Kconfig
+++ b/arch/arm64/Kconfig
@@ -140,6 +140,7 @@ config ARM64
 	select HAVE_DMA_CONTIGUOUS
 	select HAVE_DYNAMIC_FTRACE
 	select HAVE_EFFICIENT_UNALIGNED_ACCESS
+	select HAVE_FAST_GUP
 	select HAVE_FTRACE_MCOUNT_RECORD
 	select HAVE_FUNCTION_TRACER
 	select HAVE_FUNCTION_GRAPH_TRACER
@@ -262,9 +263,6 @@ config GENERIC_CALIBRATE_DELAY
 config ZONE_DMA32
 	def_bool y
 
-config HAVE_GENERIC_GUP
-	def_bool y
-
 config ARCH_ENABLE_MEMORY_HOTPLUG
 	def_bool y
 
diff --git a/arch/mips/Kconfig b/arch/mips/Kconfig
index 64108a2a16d4..b1e42f0e4ed0 100644
--- a/arch/mips/Kconfig
+++ b/arch/mips/Kconfig
@@ -54,10 +54,10 @@ config MIPS
 	select HAVE_DMA_CONTIGUOUS
 	select HAVE_DYNAMIC_FTRACE
 	select HAVE_EXIT_THREAD
+	select HAVE_FAST_GUP
 	select HAVE_FTRACE_MCOUNT_RECORD
 	select HAVE_FUNCTION_GRAPH_TRACER
 	select HAVE_FUNCTION_TRACER
-	select HAVE_GENERIC_GUP
 	select HAVE_IDE
 	select HAVE_IOREMAP_PROT
 	select HAVE_IRQ_EXIT_ON_IRQ_STACK
diff --git a/arch/powerpc/Kconfig b/arch/powerpc/Kconfig
index 8c1c636308c8..992a04796e56 100644
--- a/arch/powerpc/Kconfig
+++ b/arch/powerpc/Kconfig
@@ -185,12 +185,12 @@ config PPC
 	select HAVE_DYNAMIC_FTRACE_WITH_REGS	if MPROFILE_KERNEL
 	select HAVE_EBPF_JIT			if PPC64
 	select HAVE_EFFICIENT_UNALIGNED_ACCESS	if !(CPU_LITTLE_ENDIAN && POWER7_CPU)
+	select HAVE_FAST_GUP
 	select HAVE_FTRACE_MCOUNT_RECORD
 	select HAVE_FUNCTION_ERROR_INJECTION
 	select HAVE_FUNCTION_GRAPH_TRACER
 	select HAVE_FUNCTION_TRACER
 	select HAVE_GCC_PLUGINS			if GCC_VERSION >= 50200   # plugin support on gcc <= 5.1 is buggy on PPC
-	select HAVE_GENERIC_GUP
 	select HAVE_HW_BREAKPOINT		if PERF_EVENTS && (PPC_BOOK3S || PPC_8xx)
 	select HAVE_IDE
 	select HAVE_IOREMAP_PROT
diff --git a/arch/s390/Kconfig b/arch/s390/Kconfig
index 109243fdb6ec..aaff0376bf53 100644
--- a/arch/s390/Kconfig
+++ b/arch/s390/Kconfig
@@ -137,6 +137,7 @@ config S390
 	select HAVE_DMA_CONTIGUOUS
 	select HAVE_DYNAMIC_FTRACE
 	select HAVE_DYNAMIC_FTRACE_WITH_REGS
+	select HAVE_FAST_GUP
 	select HAVE_EFFICIENT_UNALIGNED_ACCESS
 	select HAVE_FENTRY
 	select HAVE_FTRACE_MCOUNT_RECORD
@@ -144,7 +145,6 @@ config S390
 	select HAVE_FUNCTION_TRACER
 	select HAVE_FUTEX_CMPXCHG if FUTEX
 	select HAVE_GCC_PLUGINS
-	select HAVE_GENERIC_GUP
 	select HAVE_KERNEL_BZIP2
 	select HAVE_KERNEL_GZIP
 	select HAVE_KERNEL_LZ4
diff --git a/arch/sh/Kconfig b/arch/sh/Kconfig
index 6fddfc3c9710..56712f3c9838 100644
--- a/arch/sh/Kconfig
+++ b/arch/sh/Kconfig
@@ -14,7 +14,7 @@ config SUPERH
 	select HAVE_ARCH_TRACEHOOK
 	select HAVE_PERF_EVENTS
 	select HAVE_DEBUG_BUGVERBOSE
-	select HAVE_GENERIC_GUP
+	select HAVE_FAST_GUP
 	select ARCH_HAVE_CUSTOM_GPIO_H
 	select ARCH_HAVE_NMI_SAFE_CMPXCHG if (GUSA_RB || CPU_SH4A)
 	select ARCH_HAS_GCOV_PROFILE_ALL
diff --git a/arch/sparc/Kconfig b/arch/sparc/Kconfig
index 22435471f942..659232b760e1 100644
--- a/arch/sparc/Kconfig
+++ b/arch/sparc/Kconfig
@@ -28,7 +28,7 @@ config SPARC
 	select RTC_DRV_M48T59
 	select RTC_SYSTOHC
 	select HAVE_ARCH_JUMP_LABEL if SPARC64
-	select HAVE_GENERIC_GUP if SPARC64
+	select HAVE_FAST_GUP if SPARC64
 	select GENERIC_IRQ_SHOW
 	select ARCH_WANT_IPC_PARSE_VERSION
 	select GENERIC_PCI_IOMAP
diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index 7cd53cc59f0f..44500e0ed630 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -157,6 +157,7 @@ config X86
 	select HAVE_EFFICIENT_UNALIGNED_ACCESS
 	select HAVE_EISA
 	select HAVE_EXIT_THREAD
+	select HAVE_FAST_GUP
 	select HAVE_FENTRY			if X86_64 || DYNAMIC_FTRACE
 	select HAVE_FTRACE_MCOUNT_RECORD
 	select HAVE_FUNCTION_GRAPH_TRACER
@@ -2874,9 +2875,6 @@ config HAVE_ATOMIC_IOMAP
 config X86_DEV_DMA_OPS
 	bool
 
-config HAVE_GENERIC_GUP
-	def_bool y
-
 source "drivers/firmware/Kconfig"
 
 source "arch/x86/kvm/Kconfig"
diff --git a/mm/Kconfig b/mm/Kconfig
index fe51f104a9e0..98dffb0f2447 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -132,7 +132,7 @@ config HAVE_MEMBLOCK_NODE_MAP
 config HAVE_MEMBLOCK_PHYS_MAP
 	bool
 
-config HAVE_GENERIC_GUP
+config HAVE_FAST_GUP
 	bool
 
 config ARCH_KEEP_MEMBLOCK
diff --git a/mm/gup.c b/mm/gup.c
index a86d65cd7051..a24f52292c7f 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -1650,7 +1650,7 @@ struct page *get_dump_page(unsigned long addr)
 #endif /* CONFIG_ELF_CORE */
 
 /*
- * Generic Fast GUP
+ * Fast GUP
  *
  * get_user_pages_fast attempts to pin user pages by walking the page
  * tables directly and avoids taking locks. Thus the walker needs to be
@@ -1682,7 +1682,7 @@ struct page *get_dump_page(unsigned long addr)
  *
  * This code is based heavily on the PowerPC implementation by Nick Piggin.
  */
-#ifdef CONFIG_HAVE_GENERIC_GUP
+#ifdef CONFIG_HAVE_FAST_GUP
 #ifdef CONFIG_GUP_GET_PTE_LOW_HIGH
 /*
  * WARNING: only to be used in the get_user_pages_fast() implementation.
-- 
2.20.1

