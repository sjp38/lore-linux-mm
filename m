Return-Path: <SRS0=x8zE=RC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 9EF9FC43381
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 17:08:04 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 56EE220842
	for <linux-mm@archiver.kernel.org>; Wed, 27 Feb 2019 17:08:04 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 56EE220842
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 032628E001B; Wed, 27 Feb 2019 12:08:04 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EFE818E0001; Wed, 27 Feb 2019 12:08:03 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DC47C8E001B; Wed, 27 Feb 2019 12:08:03 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f70.google.com (mail-ed1-f70.google.com [209.85.208.70])
	by kanga.kvack.org (Postfix) with ESMTP id 7A9748E0001
	for <linux-mm@kvack.org>; Wed, 27 Feb 2019 12:08:03 -0500 (EST)
Received: by mail-ed1-f70.google.com with SMTP id y26so2500575edb.4
        for <linux-mm@kvack.org>; Wed, 27 Feb 2019 09:08:03 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=Q3LahD/eKhxJHoEJe0Td4Cv/PyOGamrBgg4jdWEHeDw=;
        b=YxRm6TX73kawqjSiOss6vnjhOjz7eAcpJGjrP4Y7+EG/rwsPUzCZrjr1SPY37cFYVA
         t2oYdJUWmNwttwBBlNLu+i2u0RRsClQ2vR/CWQJts1SVxmfHOc+xvH/Ce7TiCXVMvIOW
         lTbbhyRGZ54U4VyjQXHavs67UEv0RRWjGdQ4cehHScX/xBf1I0tjjO6S71i88K5v9AWI
         dkX6As1MtX7vwQghew7AaYRckJd/FHhCltdIwatv97tOe2te9gWtNBAu17YrINr/f/Ka
         T2acjwdDdMg4KZc2XOwUao9LXEHLtXHnuAAtlyQTAY0cFes/hTd2qEHAFL4bNzFIqVmL
         AMAg==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
X-Gm-Message-State: AHQUAuY5kJkZVUdYEqJCmq+zYcvV3CZ3HDgpm5dgcsnbgwevGzwXcqpK
	iDIpik85r2sEk2ekI7ZDUdwVA6PU1g8YVNjsxNaJgvt/DOIbvpoqwvmXs8T0EGr3B8n1hhyxxXB
	L0ioR4LNHnPGBqMX4eSkpA9HWuHOY6tI6DUU7LOM1GYEF3Sq+KN2VPi5DJ+w0kajeSw==
X-Received: by 2002:a50:ac6d:: with SMTP id w42mr3231418edc.122.1551287282976;
        Wed, 27 Feb 2019 09:08:02 -0800 (PST)
X-Google-Smtp-Source: AHgI3IaUwokAr+M5KYUoOYXNl1020b8a630kLaoeKcWwCyBZ+mjRG8yAfWIg2KrOCdxqQak2SpUC
X-Received: by 2002:a50:ac6d:: with SMTP id w42mr3231339edc.122.1551287281666;
        Wed, 27 Feb 2019 09:08:01 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551287281; cv=none;
        d=google.com; s=arc-20160816;
        b=alysk4PuKTZtsVAWbhBTluZ3q9u6dHuCHneODjfzJooC7WevGe4TNY2Iy5o+fzPQWo
         sSR8jmyJhPotXNlqw9IB3azEHZg/uCW1nvddoSSVGmKJEoEP8XrWGph8NDh5XOXyxqI8
         cWhHrKby3gMR5CF90IjVtKY3perKiiN7ng39dYH0/60hQTZj0Bm8TnKcWNEJoCY42X3B
         +5STJcbsTlLp0RCyw2mRhTqOvlD8d7fsc9gsq91cWloaxKlYg5MWoRunNFCx+MeLAAiT
         7DqBrDGbWWpJ5DTo0oWT+7w7c+BS2V6mLYe+AdNBJZBkMisZw6ToEBGVnlJuXIodlEq7
         czwQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=Q3LahD/eKhxJHoEJe0Td4Cv/PyOGamrBgg4jdWEHeDw=;
        b=0+SR6dGEviAtavKQWYAayBnU7Sd07ijy9Wq6ZFIY78VCPkZrD8amv+pzVnNj/+ACE+
         KgBkj6xXGsr2BE73uCmMtLgZ9u649Kz1/DHgNWV9bCCzopTD6MZoZh4ZEOkdIqfNc86r
         J4ZxLb+Nl89SJ6YGKRYWGiDYxlRxtNZDja/kEQ+fj2B9Rrl/VqEuDRpUFg5jhz+yc4U/
         imntC832hmiELSc/cWyeeHhK5o3SjnKrsQGk0EllIAUbil2FefNGlC/j8+NdbLoDCtIv
         02d50qrJMBnRwkGH+i2UMcCAqzKidHSAhMyVFitjNxiSRYZG34sRUZ0rZ9Bc9vraiiwq
         ++ww==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id gj14si1364182ejb.183.2019.02.27.09.08.01
        for <linux-mm@kvack.org>;
        Wed, 27 Feb 2019 09:08:01 -0800 (PST)
Received-SPF: pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of steven.price@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=steven.price@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 972BEA78;
	Wed, 27 Feb 2019 09:08:00 -0800 (PST)
Received: from e112269-lin.arm.com (e112269-lin.cambridge.arm.com [10.1.196.69])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPSA id 5C0463F738;
	Wed, 27 Feb 2019 09:07:57 -0800 (PST)
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
Subject: [PATCH v3 24/34] mm: Add generic p?d_large() macros
Date: Wed, 27 Feb 2019 17:05:58 +0000
Message-Id: <20190227170608.27963-25-steven.price@arm.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190227170608.27963-1-steven.price@arm.com>
References: <20190227170608.27963-1-steven.price@arm.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Exposing the pud/pgd levels of the page tables to walk_page_range() means
we may come across the exotic large mappings that come with large areas
of contiguous memory (such as the kernel's linear map).

Where levels are folded we need to provide the appropriate stub
implementation of p?d_large().

For x86 move the existing definitions of p?d_large() so that they are
only defined when the corresponding levels are not folded.

Signed-off-by: Steven Price <steven.price@arm.com>
---
 arch/x86/include/asm/pgtable.h           | 21 ++++++++-------------
 include/asm-generic/4level-fixup.h       |  1 +
 include/asm-generic/5level-fixup.h       |  1 +
 include/asm-generic/pgtable-nop4d-hack.h |  1 +
 include/asm-generic/pgtable-nop4d.h      |  1 +
 include/asm-generic/pgtable-nopmd.h      |  1 +
 include/asm-generic/pgtable-nopud.h      |  1 +
 7 files changed, 14 insertions(+), 13 deletions(-)

diff --git a/arch/x86/include/asm/pgtable.h b/arch/x86/include/asm/pgtable.h
index 2779ace16d23..1b854c64cc7d 100644
--- a/arch/x86/include/asm/pgtable.h
+++ b/arch/x86/include/asm/pgtable.h
@@ -222,12 +222,6 @@ static inline unsigned long pgd_pfn(pgd_t pgd)
 	return (pgd_val(pgd) & PTE_PFN_MASK) >> PAGE_SHIFT;
 }
 
-static inline int p4d_large(p4d_t p4d)
-{
-	/* No 512 GiB pages yet */
-	return 0;
-}
-
 #define pte_page(pte)	pfn_to_page(pte_pfn(pte))
 
 static inline int pmd_large(pmd_t pte)
@@ -867,11 +861,6 @@ static inline int pud_bad(pud_t pud)
 {
 	return (pud_flags(pud) & ~(_KERNPG_TABLE | _PAGE_USER)) != 0;
 }
-#else
-static inline int pud_large(pud_t pud)
-{
-	return 0;
-}
 #endif	/* CONFIG_PGTABLE_LEVELS > 2 */
 
 static inline unsigned long pud_index(unsigned long address)
@@ -890,6 +879,12 @@ static inline int p4d_present(p4d_t p4d)
 	return p4d_flags(p4d) & _PAGE_PRESENT;
 }
 
+static inline int p4d_large(p4d_t p4d)
+{
+	/* No 512 GiB pages yet */
+	return 0;
+}
+
 static inline unsigned long p4d_page_vaddr(p4d_t p4d)
 {
 	return (unsigned long)__va(p4d_val(p4d) & p4d_pfn_mask(p4d));
@@ -931,6 +926,8 @@ static inline int pgd_present(pgd_t pgd)
 	return pgd_flags(pgd) & _PAGE_PRESENT;
 }
 
+static inline int pgd_large(pgd_t pgd) { return 0; }
+
 static inline unsigned long pgd_page_vaddr(pgd_t pgd)
 {
 	return (unsigned long)__va((unsigned long)pgd_val(pgd) & PTE_PFN_MASK);
@@ -1213,8 +1210,6 @@ static inline bool pgdp_maps_userspace(void *__ptr)
 	return (((ptr & ~PAGE_MASK) / sizeof(pgd_t)) < PGD_KERNEL_START);
 }
 
-static inline int pgd_large(pgd_t pgd) { return 0; }
-
 #ifdef CONFIG_PAGE_TABLE_ISOLATION
 /*
  * All top-level PAGE_TABLE_ISOLATION page tables are order-1 pages
diff --git a/include/asm-generic/4level-fixup.h b/include/asm-generic/4level-fixup.h
index e3667c9a33a5..3cc65a4dd093 100644
--- a/include/asm-generic/4level-fixup.h
+++ b/include/asm-generic/4level-fixup.h
@@ -20,6 +20,7 @@
 #define pud_none(pud)			0
 #define pud_bad(pud)			0
 #define pud_present(pud)		1
+#define pud_large(pud)			0
 #define pud_ERROR(pud)			do { } while (0)
 #define pud_clear(pud)			pgd_clear(pud)
 #define pud_val(pud)			pgd_val(pud)
diff --git a/include/asm-generic/5level-fixup.h b/include/asm-generic/5level-fixup.h
index bb6cb347018c..c4377db09a4f 100644
--- a/include/asm-generic/5level-fixup.h
+++ b/include/asm-generic/5level-fixup.h
@@ -22,6 +22,7 @@
 #define p4d_none(p4d)			0
 #define p4d_bad(p4d)			0
 #define p4d_present(p4d)		1
+#define p4d_large(p4d)			0
 #define p4d_ERROR(p4d)			do { } while (0)
 #define p4d_clear(p4d)			pgd_clear(p4d)
 #define p4d_val(p4d)			pgd_val(p4d)
diff --git a/include/asm-generic/pgtable-nop4d-hack.h b/include/asm-generic/pgtable-nop4d-hack.h
index 829bdb0d6327..d3967560d123 100644
--- a/include/asm-generic/pgtable-nop4d-hack.h
+++ b/include/asm-generic/pgtable-nop4d-hack.h
@@ -27,6 +27,7 @@ typedef struct { pgd_t pgd; } pud_t;
 static inline int pgd_none(pgd_t pgd)		{ return 0; }
 static inline int pgd_bad(pgd_t pgd)		{ return 0; }
 static inline int pgd_present(pgd_t pgd)	{ return 1; }
+static inline int pgd_large(pgd_t pgd)		{ return 0; }
 static inline void pgd_clear(pgd_t *pgd)	{ }
 #define pud_ERROR(pud)				(pgd_ERROR((pud).pgd))
 
diff --git a/include/asm-generic/pgtable-nop4d.h b/include/asm-generic/pgtable-nop4d.h
index aebab905e6cd..5d5dde24a8ca 100644
--- a/include/asm-generic/pgtable-nop4d.h
+++ b/include/asm-generic/pgtable-nop4d.h
@@ -22,6 +22,7 @@ typedef struct { pgd_t pgd; } p4d_t;
 static inline int pgd_none(pgd_t pgd)		{ return 0; }
 static inline int pgd_bad(pgd_t pgd)		{ return 0; }
 static inline int pgd_present(pgd_t pgd)	{ return 1; }
+static inline int pgd_large(pgd_t pgd)		{ return 0; }
 static inline void pgd_clear(pgd_t *pgd)	{ }
 #define p4d_ERROR(p4d)				(pgd_ERROR((p4d).pgd))
 
diff --git a/include/asm-generic/pgtable-nopmd.h b/include/asm-generic/pgtable-nopmd.h
index b85b8271a73d..beeb8f375d4d 100644
--- a/include/asm-generic/pgtable-nopmd.h
+++ b/include/asm-generic/pgtable-nopmd.h
@@ -30,6 +30,7 @@ typedef struct { pud_t pud; } pmd_t;
 static inline int pud_none(pud_t pud)		{ return 0; }
 static inline int pud_bad(pud_t pud)		{ return 0; }
 static inline int pud_present(pud_t pud)	{ return 1; }
+static inline int pud_large(pud_t pud)		{ return 0; }
 static inline void pud_clear(pud_t *pud)	{ }
 #define pmd_ERROR(pmd)				(pud_ERROR((pmd).pud))
 
diff --git a/include/asm-generic/pgtable-nopud.h b/include/asm-generic/pgtable-nopud.h
index c77a1d301155..b3ba496965d3 100644
--- a/include/asm-generic/pgtable-nopud.h
+++ b/include/asm-generic/pgtable-nopud.h
@@ -31,6 +31,7 @@ typedef struct { p4d_t p4d; } pud_t;
 static inline int p4d_none(p4d_t p4d)		{ return 0; }
 static inline int p4d_bad(p4d_t p4d)		{ return 0; }
 static inline int p4d_present(p4d_t p4d)	{ return 1; }
+static inline int p4d_large(p4d_t p4d)		{ return 0; }
 static inline void p4d_clear(p4d_t *p4d)	{ }
 #define pud_ERROR(pud)				(p4d_ERROR((pud).p4d))
 
-- 
2.20.1

