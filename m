Return-Path: <SRS0=nbyn=UY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 31FA3C48BD5
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 14:38:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D3977213F2
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 14:38:19 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="hU21sXIG"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D3977213F2
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DB8F18E0009; Tue, 25 Jun 2019 10:38:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id C20278E000D; Tue, 25 Jun 2019 10:38:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A9DEE8E0009; Tue, 25 Jun 2019 10:38:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 62D8D8E000B
	for <linux-mm@kvack.org>; Tue, 25 Jun 2019 10:38:04 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id s195so11776592pgs.13
        for <linux-mm@kvack.org>; Tue, 25 Jun 2019 07:38:04 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=cNb5LAit4OQE9csyW8Gi3qb52ub8bWsatrdoLvwwMmk=;
        b=CRYIT5gMpQdSybLp4KeKi8vyYOOA//zoovIMLYJEyq5i1Hc9WpKkf5Fn9xVJbk/p/7
         LLPVrveN4HxcRBOrkgE0jMVpjl1rrlhLpLMdPkZ9kSj1yVu2q5hcaNzifdClR0hUfeIN
         nQF7Ib+ptKXFAPk1QcP5YllOvDh/zXHgm4wvAUOLBDX060ybxta/16RhnSgn0to4Hj1F
         OItc81YaphlYRTlzcaeAfJZcrjLQPM/kXym1CujMCzA0VeCS5IR/l/7XCdCG1roi8tvn
         neXpytENcOaFh6kOwFpBgrzEc0WQuXXr7hKy9LaKAAzZnM+Kx1SksTN9H8HNI8y2qdkf
         5u/Q==
X-Gm-Message-State: APjAAAVo3DGLNA92FCuAK8rl6le34ddgaGX6IYt+Tk/66QGRbRJ6uGP4
	/En3cdxG66aNijGN/QHKTrvckK+Pzxy+XfOuMG6IxasLx473yHbdYGzUgB5AC++P9WHgE7eJmcV
	f7Z725Ot7tTT1S23+A14utAdqUQ+siJ7r4j4a9Y+Ab2C47bGobu85MD/A9O3WAM4=
X-Received: by 2002:a17:90a:2228:: with SMTP id c37mr32803630pje.9.1561473484039;
        Tue, 25 Jun 2019 07:38:04 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzLY/r+uzsod5/tLNl7EA5r2Syy/uIUuep2ZkH8BMb1vM0mUqO3y7kMq3AY09Ejvj5rki/r
X-Received: by 2002:a17:90a:2228:: with SMTP id c37mr32803541pje.9.1561473483138;
        Tue, 25 Jun 2019 07:38:03 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561473483; cv=none;
        d=google.com; s=arc-20160816;
        b=CBOmrmZte7xYfeue62n556R35KFMOve3t88XanuDG5j1iNP/yzGw/ZlyYQT0VcegO7
         VCplsCnhnxGNI/tETdl/onuFbE7k/BDecfgWz5wp8QA43cnW0IICNSk1POZ8J0oPke7K
         XQfuX0hU4RoWBB70NbT81uDaE2RYvaM5mwpMaEWU2tlN+/dvUcT5CMLOCx0X6XAGryRH
         wN3x1pDcOu7qUcFUPKc6F1g00xOiNB/CzgoAdHJb71D1zitkSD4By201ZFK8nrwyLzJA
         kKpRHP+4TGb85c/ltBLyKYh80GJFAuGNx9fDxeeSFKzisbTtnommp0t593AWvXI8I4ux
         vPDw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=cNb5LAit4OQE9csyW8Gi3qb52ub8bWsatrdoLvwwMmk=;
        b=H3j+bsedpMt2R7fZNETqkqWH7y9GFkm3PnhNCht7futPZzZEsalfJ2VJrECc7ukiL4
         uhK/7BBWoW6acIdD8nSCqfIUebbVEiqq/EgnO9Mb6fvknUEoWY5KEX3nHiJdEdssINvq
         ZmdURZoLfGvSvlW8ajrNLcVMRokCqFp9iyX/WR137MQAEUNQFNS2A+XHL0OqNW/LdjRA
         E1fCLjk2nRFVxOd2BZz/oTMtRw47U6VLyj4gEweOTJTc68JfOkBsPxcfXfldiZtePIwO
         bSuLcKBBw4Om6g0lAXV5b+dEHQ8m9DHE0hVj0BmlynEURkgjyO60wGVBgdc5hEW0I6pe
         SEuA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=hU21sXIG;
       spf=pass (google.com: best guess record for domain of batv+c5155a46dc30cc8634d8+5784+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+c5155a46dc30cc8634d8+5784+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id i3si453240plt.306.2019.06.25.07.38.03
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 25 Jun 2019 07:38:03 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+c5155a46dc30cc8634d8+5784+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=hU21sXIG;
       spf=pass (google.com: best guess record for domain of batv+c5155a46dc30cc8634d8+5784+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+c5155a46dc30cc8634d8+5784+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=cNb5LAit4OQE9csyW8Gi3qb52ub8bWsatrdoLvwwMmk=; b=hU21sXIGXyk/mxw1HaN+6x5I8z
	REbMk/9AO2/RX7OUJZAz7uatsrDjVraOr2R7w7o1uB8bi/MLY5BSeHDuWcSqGT5qb92FfOOrlqA2v
	xJ2Iaq6iLlaonDvnyUn5rB14ArrIZJHdVpacxQ/NwA3kG90jz2cLueycWPfxq6Rc616kRcKbJbsFJ
	9M7rzU2H2ztN2yfxRYs2U9z7anC8kgI5e72AOG7KgDREQgaJjpXZnyVd6ke/dfDgqq7QTq53Ii19X
	eiU1xmwauAPSmID0U5JtNbc8tf9F59Gh1UqNi4XjkgpBeJBDDaUvUaCvKXGZqrZ6jCSA0xo+6Fb3C
	eS+bPF9g==;
Received: from 213-225-6-159.nat.highway.a1.net ([213.225.6.159] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hfmZy-00081q-2P; Tue, 25 Jun 2019 14:37:50 +0000
From: Christoph Hellwig <hch@lst.de>
To: Andrew Morton <akpm@linux-foundation.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
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
	linux-kernel@vger.kernel.org,
	Jason Gunthorpe <jgg@mellanox.com>
Subject: [PATCH 10/16] mm: rename CONFIG_HAVE_GENERIC_GUP to CONFIG_HAVE_FAST_GUP
Date: Tue, 25 Jun 2019 16:37:09 +0200
Message-Id: <20190625143715.1689-11-hch@lst.de>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190625143715.1689-1-hch@lst.de>
References: <20190625143715.1689-1-hch@lst.de>
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
Reviewed-by: Khalid Aziz <khalid.aziz@oracle.com>
Reviewed-by: Jason Gunthorpe <jgg@mellanox.com>
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
index 6fddfc3c9710..f6b15ecc37a3 100644
--- a/arch/sh/Kconfig
+++ b/arch/sh/Kconfig
@@ -14,7 +14,7 @@ config SUPERH
 	select HAVE_ARCH_TRACEHOOK
 	select HAVE_PERF_EVENTS
 	select HAVE_DEBUG_BUGVERBOSE
-	select HAVE_GENERIC_GUP
+	select HAVE_FAST_GUP if MMU
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
index 9b72f2ea3471..7328890ad8d3 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -1651,7 +1651,7 @@ struct page *get_dump_page(unsigned long addr)
 #endif /* CONFIG_ELF_CORE */
 
 /*
- * Generic Fast GUP
+ * Fast GUP
  *
  * get_user_pages_fast attempts to pin user pages by walking the page
  * tables directly and avoids taking locks. Thus the walker needs to be
@@ -1683,7 +1683,7 @@ struct page *get_dump_page(unsigned long addr)
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

