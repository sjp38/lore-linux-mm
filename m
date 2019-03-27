Return-Path: <SRS0=JxSR=R6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id C875CC43381
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 06:40:17 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 7EE962075E
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 06:40:17 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 7EE962075E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ghiti.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 11BF76B000C; Wed, 27 Mar 2019 02:40:17 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0C8026B000D; Wed, 27 Mar 2019 02:40:17 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id ED4556B000E; Wed, 27 Mar 2019 02:40:16 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id AE0226B000C
	for <linux-mm@kvack.org>; Wed, 27 Mar 2019 02:40:16 -0400 (EDT)
Received: by mail-ed1-f70.google.com with SMTP id w27so6228394edb.13
        for <linux-mm@kvack.org>; Tue, 26 Mar 2019 23:40:16 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=/zbjy0xHtWTkP+fIAccQPSAH97OdqDJ4T3uxkDu73/0=;
        b=qygd/mFyL+M69sBwqS8UD/1Dg4080ojQ56hhfZa627Etmc6GzYnCYbGb0oMrjg34U7
         +1u+C+92jHwkbmAOXuzrqWmJlSN8BIe3+2SwbhXOTSl9KCn/Pbm9FBNErp3RPwp3Gb05
         oW0dLSow/+qbI/Ne0iG0s0/bCWOeFBnVTlh5B3Q94Be4r6sjwWHM5pMlx0mawhGqtkZl
         8JD895TtdWZzTT5rwIDkzZWnZarQtskJVNAMOAl6FKU14VLEIQdZglpClRpc+IrnH66F
         DZLQlwG/8JgnrIUMcPbSbZseBL0IrzxPXwx4KVqjjJ7h6jn0begl527xauHe8OlMP8/i
         MLiA==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 217.70.183.197 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Gm-Message-State: APjAAAWFZmUhwIePtmLUK5ierMp6gYKYss35ds58RMLdh69+ZTrAUazo
	j97msRnrFV2mXJ4dRMlZM4LNTW97oUDGawYXqI4CJpmnZrKY3xSj6ErGAj8LKe2nNjV5MwDSh5V
	JmR+8tudz1wBr6jb0QtIKnLdBePDzh7jmWedFZ7bOkiJNiLSCuyJUfhMzGuP21EA=
X-Received: by 2002:a50:ad23:: with SMTP id y32mr15087337edc.90.1553668816195;
        Tue, 26 Mar 2019 23:40:16 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxDkGY/Q8HGW82JSE/IYMxe6kyCk5/vw2ZY6M6JORfruQV8Jugs0/bo3jV5GL9UGWHyH9pV
X-Received: by 2002:a50:ad23:: with SMTP id y32mr15087286edc.90.1553668815175;
        Tue, 26 Mar 2019 23:40:15 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553668815; cv=none;
        d=google.com; s=arc-20160816;
        b=QGZ1t/kzbjWw1F3nCheCWuT+FgDpgZ0seueYsNDdEXu9Gm/ImB0l7WnmPVR6FG6F1Z
         +5X407a8rBSHw6R7mrpi3lDMXCWjlBSNZApp5F+qyP6w37t+QQYX0wdQ6kEAANmvPAaA
         3Uu8guQNW3eBBwrPH1/iQ7pNBlsXYXaiK71MsBQPUVYQPBTzoA6M75opWzKvjRMxJl4C
         E3WrQ+aGnthEh8SYd40RQBli8YzvoUeuC6xdB2SwHEz1yzsqSy03lRFQjQV4VE4Rw34S
         jftmAYplsKgkiGXA9PWQoszCFklx1kOu6xdk7OfOTs6vpj2AUZ8WXQrUXqkxse+B2TRK
         yXYA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=/zbjy0xHtWTkP+fIAccQPSAH97OdqDJ4T3uxkDu73/0=;
        b=03jyRpXFsEibuFplyXE0p1fQ+OHUOkjEoVC5Xc7YfY1wjoYQ+zq9mvtlE9GxifS5gc
         hE46H8gQ8R81DEVBXEChNCxWRBVh8pAAt6hDHCn/95McukV1zbT7CAKPxbyAsR8NoHPN
         4x72XsGyfKt37l5lL4aw01tLTm/wKPAbVUw1JHJsUyIr/iLAq8Gy86TP6jn+yT1zDcly
         gEw4DXXLt5pvBEN0s6RDJOCkTXBrVtRQAo6aI8gz/lSJVYlkKrJcYNz+AKo39PfYr3XF
         nRvLHln6UM4pXzevFe+MwgaZFis5rqJBMl0Z1wVyhU5WVGulnVR1O2+qjfOKBPcoG9Ys
         tc7Q==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 217.70.183.197 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
Received: from relay5-d.mail.gandi.net (relay5-d.mail.gandi.net. [217.70.183.197])
        by mx.google.com with ESMTPS id v9si3821065edc.26.2019.03.26.23.40.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 26 Mar 2019 23:40:15 -0700 (PDT)
Received-SPF: neutral (google.com: 217.70.183.197 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) client-ip=217.70.183.197;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 217.70.183.197 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Originating-IP: 79.86.19.127
Received: from alex.numericable.fr (127.19.86.79.rev.sfr.net [79.86.19.127])
	(Authenticated sender: alex@ghiti.fr)
	by relay5-d.mail.gandi.net (Postfix) with ESMTPSA id CD0641C0008;
	Wed, 27 Mar 2019 06:40:04 +0000 (UTC)
From: Alexandre Ghiti <alex@ghiti.fr>
To: aneesh.kumar@linux.ibm.com,
	mpe@ellerman.id.au,
	Andrew Morton <akpm@linux-foundation.org>,
	Vlastimil Babka <vbabka@suse.cz>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Paul Mackerras <paulus@samba.org>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	Yoshinori Sato <ysato@users.sourceforge.jp>,
	Rich Felker <dalias@libc.org>,
	"David S . Miller" <davem@davemloft.net>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>,
	Borislav Petkov <bp@alien8.de>,
	"H . Peter Anvin" <hpa@zytor.com>,
	x86@kernel.org,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Andy Lutomirski <luto@kernel.org>,
	Peter Zijlstra <peterz@infradead.org>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	linux-arm-kernel@lists.infradead.org,
	linux-kernel@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org,
	linux-s390@vger.kernel.org,
	linux-sh@vger.kernel.org,
	sparclinux@vger.kernel.org,
	linux-mm@kvack.org
Cc: Alexandre Ghiti <alex@ghiti.fr>
Subject: [PATCH v8 3/4] mm: Simplify MEMORY_ISOLATION && COMPACTION || CMA into CONTIG_ALLOC
Date: Wed, 27 Mar 2019 02:36:25 -0400
Message-Id: <20190327063626.18421-4-alex@ghiti.fr>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190327063626.18421-1-alex@ghiti.fr>
References: <20190327063626.18421-1-alex@ghiti.fr>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This condition allows to define alloc_contig_range, so simplify
it into a more accurate naming.

Suggested-by: Vlastimil Babka <vbabka@suse.cz>
Signed-off-by: Alexandre Ghiti <alex@ghiti.fr>
Acked-by: Vlastimil Babka <vbabka@suse.cz>
---
 arch/arm64/Kconfig                     | 2 +-
 arch/powerpc/platforms/Kconfig.cputype | 2 +-
 arch/s390/Kconfig                      | 2 +-
 arch/sh/Kconfig                        | 2 +-
 arch/sparc/Kconfig                     | 2 +-
 arch/x86/Kconfig                       | 2 +-
 arch/x86/mm/hugetlbpage.c              | 2 +-
 include/linux/gfp.h                    | 2 +-
 mm/Kconfig                             | 3 +++
 mm/page_alloc.c                        | 3 +--
 10 files changed, 12 insertions(+), 10 deletions(-)

diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
index 7e34b9eba5de..a8380629cb3f 100644
--- a/arch/arm64/Kconfig
+++ b/arch/arm64/Kconfig
@@ -18,7 +18,7 @@ config ARM64
 	select ARCH_HAS_FAST_MULTIPLIER
 	select ARCH_HAS_FORTIFY_SOURCE
 	select ARCH_HAS_GCOV_PROFILE_ALL
-	select ARCH_HAS_GIGANTIC_PAGE if (MEMORY_ISOLATION && COMPACTION) || CMA
+	select ARCH_HAS_GIGANTIC_PAGE if CONTIG_ALLOC
 	select ARCH_HAS_KCOV
 	select ARCH_HAS_MEMBARRIER_SYNC_CORE
 	select ARCH_HAS_PTE_SPECIAL
diff --git a/arch/powerpc/platforms/Kconfig.cputype b/arch/powerpc/platforms/Kconfig.cputype
index 842b2c7e156a..eb0f592cde69 100644
--- a/arch/powerpc/platforms/Kconfig.cputype
+++ b/arch/powerpc/platforms/Kconfig.cputype
@@ -325,7 +325,7 @@ config ARCH_ENABLE_SPLIT_PMD_PTLOCK
 config PPC_RADIX_MMU
 	bool "Radix MMU Support"
 	depends on PPC_BOOK3S_64
-	select ARCH_HAS_GIGANTIC_PAGE if (MEMORY_ISOLATION && COMPACTION) || CMA
+	select ARCH_HAS_GIGANTIC_PAGE if CONTIG_ALLOC
 	default y
 	help
 	  Enable support for the Power ISA 3.0 Radix style MMU. Currently this
diff --git a/arch/s390/Kconfig b/arch/s390/Kconfig
index b6e3d0653002..1c8cb55b4e5d 100644
--- a/arch/s390/Kconfig
+++ b/arch/s390/Kconfig
@@ -69,7 +69,7 @@ config S390
 	select ARCH_HAS_ELF_RANDOMIZE
 	select ARCH_HAS_FORTIFY_SOURCE
 	select ARCH_HAS_GCOV_PROFILE_ALL
-	select ARCH_HAS_GIGANTIC_PAGE if (MEMORY_ISOLATION && COMPACTION) || CMA
+	select ARCH_HAS_GIGANTIC_PAGE if CONTIG_ALLOC
 	select ARCH_HAS_KCOV
 	select ARCH_HAS_PTE_SPECIAL
 	select ARCH_HAS_SET_MEMORY
diff --git a/arch/sh/Kconfig b/arch/sh/Kconfig
index 0d9fb2468e0b..67931bdaf32f 100644
--- a/arch/sh/Kconfig
+++ b/arch/sh/Kconfig
@@ -53,7 +53,7 @@ config SUPERH
 	select HAVE_FUTEX_CMPXCHG if FUTEX
 	select HAVE_NMI
 	select NEED_SG_DMA_LENGTH
-	select ARCH_HAS_GIGANTIC_PAGE if (MEMORY_ISOLATION && COMPACTION) || CMA
+	select ARCH_HAS_GIGANTIC_PAGE if CONTIG_ALLOC
 
 	help
 	  The SuperH is a RISC processor targeted for use in embedded systems
diff --git a/arch/sparc/Kconfig b/arch/sparc/Kconfig
index ebcc9435db08..52193cfb0f32 100644
--- a/arch/sparc/Kconfig
+++ b/arch/sparc/Kconfig
@@ -91,7 +91,7 @@ config SPARC64
 	select ARCH_CLOCKSOURCE_DATA
 	select ARCH_HAS_PTE_SPECIAL
 	select PCI_DOMAINS if PCI
-	select ARCH_HAS_GIGANTIC_PAGE if (MEMORY_ISOLATION && COMPACTION) || CMA
+	select ARCH_HAS_GIGANTIC_PAGE if CONTIG_ALLOC
 
 config ARCH_DEFCONFIG
 	string
diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index c1f9b3cf437c..749bab313dc1 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -21,7 +21,7 @@ config X86_64
 	def_bool y
 	depends on 64BIT
 	# Options that are inherently 64-bit kernel only:
-	select ARCH_HAS_GIGANTIC_PAGE if (MEMORY_ISOLATION && COMPACTION) || CMA
+	select ARCH_HAS_GIGANTIC_PAGE if CONTIG_ALLOC
 	select ARCH_SUPPORTS_INT128
 	select ARCH_USE_CMPXCHG_LOCKREF
 	select HAVE_ARCH_SOFT_DIRTY
diff --git a/arch/x86/mm/hugetlbpage.c b/arch/x86/mm/hugetlbpage.c
index 92e4c4b85bba..fab095362c50 100644
--- a/arch/x86/mm/hugetlbpage.c
+++ b/arch/x86/mm/hugetlbpage.c
@@ -203,7 +203,7 @@ static __init int setup_hugepagesz(char *opt)
 }
 __setup("hugepagesz=", setup_hugepagesz);
 
-#if (defined(CONFIG_MEMORY_ISOLATION) && defined(CONFIG_COMPACTION)) || defined(CONFIG_CMA)
+#ifdef CONFIG_CONTIG_ALLOC
 static __init int gigantic_pages_init(void)
 {
 	/* With compaction or CMA we can allocate gigantic pages at runtime */
diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index fdab7de7490d..e77ab30e9328 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -585,7 +585,7 @@ static inline bool pm_suspended_storage(void)
 }
 #endif /* CONFIG_PM_SLEEP */
 
-#if (defined(CONFIG_MEMORY_ISOLATION) && defined(CONFIG_COMPACTION)) || defined(CONFIG_CMA)
+#ifdef CONFIG_CONTIG_ALLOC
 /* The below functions must be run on a range from a single zone. */
 extern int alloc_contig_range(unsigned long start, unsigned long end,
 			      unsigned migratetype, gfp_t gfp_mask);
diff --git a/mm/Kconfig b/mm/Kconfig
index 25c71eb8a7db..137eadc18732 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -258,6 +258,9 @@ config ARCH_ENABLE_HUGEPAGE_MIGRATION
 config ARCH_ENABLE_THP_MIGRATION
 	bool
 
+config CONTIG_ALLOC
+       def_bool (MEMORY_ISOLATION && COMPACTION) || CMA
+
 config PHYS_ADDR_T_64BIT
 	def_bool 64BIT
 
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 03fcf73d47da..ecb115a74a9d 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -8109,8 +8109,7 @@ bool has_unmovable_pages(struct zone *zone, struct page *page, int count,
 	return true;
 }
 
-#if (defined(CONFIG_MEMORY_ISOLATION) && defined(CONFIG_COMPACTION)) || defined(CONFIG_CMA)
-
+#ifdef CONFIG_CONTIG_ALLOC
 static unsigned long pfn_max_align_down(unsigned long pfn)
 {
 	return pfn & ~(max_t(unsigned long, MAX_ORDER_NR_PAGES,
-- 
2.20.1

