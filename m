Return-Path: <SRS0=Q21e=VW=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.7 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 006D9C76191
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 06:56:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B52162070B
	for <linux-mm@archiver.kernel.org>; Thu, 25 Jul 2019 06:56:26 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B52162070B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4B9D18E0040; Thu, 25 Jul 2019 02:56:26 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 442C78E0031; Thu, 25 Jul 2019 02:56:26 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 332558E0040; Thu, 25 Jul 2019 02:56:26 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f69.google.com (mail-ed1-f69.google.com [209.85.208.69])
	by kanga.kvack.org (Postfix) with ESMTP id D2FA78E0031
	for <linux-mm@kvack.org>; Thu, 25 Jul 2019 02:56:25 -0400 (EDT)
Received: by mail-ed1-f69.google.com with SMTP id i9so31552499edr.13
        for <linux-mm@kvack.org>; Wed, 24 Jul 2019 23:56:25 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references;
        bh=HAStVEoD/IxDwL4SAfGEE94eJX2H0xCdYWDQvcqDvYw=;
        b=hWwIzuNU3UbFCoS/N9Q3yRPd51Sp4aIreLGo0tzCiZ/YpAO2PztZz0kJwUzAJw7nJi
         g8H7jdwEeAR/04FOASgAalObqlW1+O/JCcts3Xk41XZEuKFpD9gt2ZLPEJLLersYfpQ2
         1VPAWJcG48zsqilBDwRBVtU6SwV71ZkbqL8ndEMV/WVf+6YEBh7cMg87gd5GNWtAhv6K
         Yvkiq0NJbvxrfZt6YMPdr7tou1tFYEm7Tsizu9l57hrWANfIGksiPuLZIVWaroEl2Nwt
         TBYfMoRX+M18YKZbBAr2IWCY6B14kEFBWWI9cqBxmZBIQ4D2zNMQSr4H+mP0luZeXYJp
         c7ig==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
X-Gm-Message-State: APjAAAX87rA6cLTO61Pb13niv+M6ZKUfToFZHo5gnV+kOwHO3IBJk9aH
	iRgoEczNSBRU8KpcPqWjFE7a4ANh08eQL9yW/8hEPl56qCm8jzSrJALPSK/tQc6GsOjYcvCa0Eb
	OmbgQ5Z2dO25v4vfVE3k5P1ltwdCAW6TgjQ4vO+dkdWy6d6FBYcnW43WA03CB+Ex9vg==
X-Received: by 2002:a17:906:28c4:: with SMTP id p4mr66863679ejd.181.1564037785384;
        Wed, 24 Jul 2019 23:56:25 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwAUT3Fu1Tw1LiyrliwFoygN7EjJ/Hf14/tl6INkdzOehhJZfll/loE4XvfNBW26/1OCydW
X-Received: by 2002:a17:906:28c4:: with SMTP id p4mr66863613ejd.181.1564037783982;
        Wed, 24 Jul 2019 23:56:23 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1564037783; cv=none;
        d=google.com; s=arc-20160816;
        b=hxAyBuNAflE9305zKxkPVoxICQOKxlYNRCkXX9WVt7vEmPU24vEGd/0cAC1WJSqFug
         5z6qTWJ0r3cGLqsODwvYxXwR+MmL43jOAaZBTX+QrGPsJ0OeIW3QoSsguUO2UHp+k4ot
         KSy09vjtQpuwTqMgAixa77XAfdYfX64vIICPb95llQft/EQ/ZD/4lIzg6w06LlL13wHq
         MpUiF8mhxIGhOhmSro94xkJjEgb9IyzDaHnOPZRbeO9DKvGf8r4DkE+Vt9hK7n/7GpnU
         zgJuULnDFIiQDDBO0d2hDQD6g4fzGmVueTJawPnR2iL9WLwzC8DBEeGR9gebdq4FwI+Q
         7bFQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from;
        bh=HAStVEoD/IxDwL4SAfGEE94eJX2H0xCdYWDQvcqDvYw=;
        b=1A/FrVdj7YuI5nc0ogdlz/d65qnzBOH13vkT27QojM/9JEWTenM5Oz5m+FK/UMw98o
         NdVGU60/qt+A0G7grXMqwDUrRrHMyfsmoKIruydAXbStPs3ztQAuZsgPccnPbFSbnkLY
         sKMFUoOhp+JdsU2auXo2yIVB4IFePqhcjNHUNF9a66MnR3xqYYNgPFjQ1aZuFo+oyDvJ
         A2lMMnzX+Tv5tpKPCdlGI0+nuCOGPj0pwa8F5bXwXAOdEb7OHvlzboSiHHmOsKXhJ9sm
         0rvjxSX2XgbYp9BXCc8KaYumbuAiWtP14I5BC5rcwKderezjfrK8Qq64TEmsDUyP4r5I
         ou5g==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.110.172])
        by mx.google.com with ESMTP id e16si8406702ejj.162.2019.07.24.23.56.23
        for <linux-mm@kvack.org>;
        Wed, 24 Jul 2019 23:56:23 -0700 (PDT)
Received-SPF: pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) client-ip=217.140.110.172;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of anshuman.khandual@arm.com designates 217.140.110.172 as permitted sender) smtp.mailfrom=anshuman.khandual@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.121.207.14])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 080FB152D;
	Wed, 24 Jul 2019 23:56:23 -0700 (PDT)
Received: from p8cg001049571a15.blr.arm.com (p8cg001049571a15.blr.arm.com [10.162.42.109])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPA id 765A53F71F;
	Wed, 24 Jul 2019 23:58:22 -0700 (PDT)
From: Anshuman Khandual <anshuman.khandual@arm.com>
To: linux-mm@kvack.org
Cc: Anshuman Khandual <anshuman.khandual@arm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Michal Hocko <mhocko@kernel.org>,
	Mark Rutland <mark.rutland@arm.com>,
	Mark Brown <Mark.Brown@arm.com>,
	Steven Price <Steven.Price@arm.com>,
	Ard Biesheuvel <ard.biesheuvel@linaro.org>,
	Masahiro Yamada <yamada.masahiro@socionext.com>,
	Kees Cook <keescook@chromium.org>,
	Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>,
	Matthew Wilcox <willy@infradead.org>,
	Sri Krishna chowdary <schowdary@nvidia.com>,
	Dave Hansen <dave.hansen@intel.com>,
	linux-arm-kernel@lists.infradead.org,
	x86@kernel.org,
	linux-kernel@vger.kernel.org
Subject: [RFC] mm/pgtable/debug: Add test validating architecture page table helpers
Date: Thu, 25 Jul 2019 12:25:23 +0530
Message-Id: <1564037723-26676-2-git-send-email-anshuman.khandual@arm.com>
X-Mailer: git-send-email 2.7.4
In-Reply-To: <1564037723-26676-1-git-send-email-anshuman.khandual@arm.com>
References: <1564037723-26676-1-git-send-email-anshuman.khandual@arm.com>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This adds a test module which will validate architecture page table helpers
and accessors regarding compliance with generic MM semantics expectations.
This will help various architectures in validating changes to the existing
page table helpers or addition of new ones.

Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@kernel.org>
Cc: Mark Rutland <mark.rutland@arm.com>
Cc: Mark Brown <Mark.Brown@arm.com>
Cc: Steven Price <Steven.Price@arm.com>
Cc: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Cc: Masahiro Yamada <yamada.masahiro@socionext.com>
Cc: Kees Cook <keescook@chromium.org>
Cc: Tetsuo Handa <penguin-kernel@i-love.sakura.ne.jp>
Cc: Matthew Wilcox <willy@infradead.org>
Cc: Sri Krishna chowdary <schowdary@nvidia.com>
Cc: Dave Hansen <dave.hansen@intel.com>
Cc: linux-arm-kernel@lists.infradead.org
Cc: x86@kernel.org
Cc: linux-kernel@vger.kernel.org

Suggested-by: Catalin Marinas <catalin.marinas@arm.com>
Signed-off-by: Anshuman Khandual <anshuman.khandual@arm.com>
---
 lib/Kconfig.debug       |  14 +++
 lib/Makefile            |   1 +
 lib/test_arch_pgtable.c | 290 ++++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 305 insertions(+)
 create mode 100644 lib/test_arch_pgtable.c

diff --git a/lib/Kconfig.debug b/lib/Kconfig.debug
index 5960e29..a27fe8d 100644
--- a/lib/Kconfig.debug
+++ b/lib/Kconfig.debug
@@ -1719,6 +1719,20 @@ config TEST_SORT
 
 	  If unsure, say N.
 
+config TEST_ARCH_PGTABLE
+	tristate "Test arch page table helpers for semantics compliance"
+	depends on MMU
+	depends on DEBUG_KERNEL || m
+	help
+	  This options provides a kernel module which can be used to test
+	  architecture page table helper functions on various platform in
+	  verifing if they comply with expected generic MM semantics. This
+	  will help architectures code in making sure that any changes or
+	  new additions of these helpers will still conform to generic MM
+	  expeted semantics.
+
+	  If unsure, say N.
+
 config KPROBES_SANITY_TEST
 	bool "Kprobes sanity tests"
 	depends on DEBUG_KERNEL
diff --git a/lib/Makefile b/lib/Makefile
index 095601c..0806d61 100644
--- a/lib/Makefile
+++ b/lib/Makefile
@@ -76,6 +76,7 @@ obj-$(CONFIG_TEST_VMALLOC) += test_vmalloc.o
 obj-$(CONFIG_TEST_OVERFLOW) += test_overflow.o
 obj-$(CONFIG_TEST_RHASHTABLE) += test_rhashtable.o
 obj-$(CONFIG_TEST_SORT) += test_sort.o
+obj-$(CONFIG_TEST_ARCH_PGTABLE) += test_arch_pgtable.o
 obj-$(CONFIG_TEST_USER_COPY) += test_user_copy.o
 obj-$(CONFIG_TEST_STATIC_KEYS) += test_static_keys.o
 obj-$(CONFIG_TEST_STATIC_KEYS) += test_static_key_base.o
diff --git a/lib/test_arch_pgtable.c b/lib/test_arch_pgtable.c
new file mode 100644
index 0000000..1396664
--- /dev/null
+++ b/lib/test_arch_pgtable.c
@@ -0,0 +1,290 @@
+// SPDX-License-Identifier: GPL-2.0-only
+/*
+ * This kernel module validates architecture page table helpers &
+ * accessors and helps in verifying their continued compliance with
+ * generic MM semantics.
+ *
+ * Copyright (C) 2019 ARM Ltd.
+ *
+ * Author: Anshuman Khandual <anshuman.khandual@arm.com>
+ */
+#define pr_fmt(fmt) "test_arch_pgtable: %s " fmt, __func__
+
+#include <linux/kernel.h>
+#include <linux/hugetlb.h>
+#include <linux/mm.h>
+#include <linux/mman.h>
+#include <linux/mm_types.h>
+#include <linux/module.h>
+#include <linux/printk.h>
+#include <linux/swap.h>
+#include <linux/swapops.h>
+#include <linux/pfn_t.h>
+#include <linux/gfp.h>
+#include <asm/pgalloc.h>
+#include <asm/pgtable.h>
+
+/*
+ * Basic operations
+ *
+ * mkold(entry)			= An old and not an young entry
+ * mkyoung(entry)		= An young and not an old entry
+ * mkdirty(entry)		= A dirty and not a clean entry
+ * mkclean(entry)		= A clean and not a dirty entry
+ * mkwrite(entry)		= An write and not an write protected entry
+ * wrprotect(entry)		= An write protected and not an write entry
+ * pxx_bad(entry)		= A mapped and non-table entry
+ * pxx_same(entry1, entry2)	= Both entries hold the exact same value
+ */
+#define VMA_TEST_FLAGS (VM_READ|VM_WRITE|VM_EXEC)
+
+static struct vm_area_struct vma;
+static struct mm_struct mm;
+static struct page *page;
+static pgprot_t prot;
+static unsigned long pfn, addr;
+
+static void pte_basic_tests(void)
+{
+	pte_t pte;
+
+	pte = mk_pte(page, prot);
+	WARN_ON(!pte_same(pte, pte));
+	WARN_ON(!pte_young(pte_mkyoung(pte)));
+	WARN_ON(!pte_dirty(pte_mkdirty(pte)));
+	WARN_ON(!pte_write(pte_mkwrite(pte)));
+	WARN_ON(pte_young(pte_mkold(pte)));
+	WARN_ON(pte_dirty(pte_mkclean(pte)));
+	WARN_ON(pte_write(pte_wrprotect(pte)));
+}
+
+#ifdef CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE
+static void pmd_basic_tests(void)
+{
+	pmd_t pmd;
+
+	pmd = mk_pmd(page, prot);
+	WARN_ON(!pmd_same(pmd, pmd));
+	WARN_ON(!pmd_young(pmd_mkyoung(pmd)));
+	WARN_ON(!pmd_dirty(pmd_mkdirty(pmd)));
+	WARN_ON(!pmd_write(pmd_mkwrite(pmd)));
+	WARN_ON(pmd_young(pmd_mkold(pmd)));
+	WARN_ON(pmd_dirty(pmd_mkclean(pmd)));
+	WARN_ON(pmd_write(pmd_wrprotect(pmd)));
+	/*
+	 * A huge page does not point to next level page table
+	 * entry. Hence this must qualify as pmd_bad().
+	 */
+	WARN_ON(!pmd_bad(pmd_mkhuge(pmd)));
+}
+#else
+static void pmd_basic_tests(void) { }
+#endif
+
+#ifdef CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE_PUD
+static void pud_basic_tests(void)
+{
+	pud_t pud;
+
+	pud = pfn_pud(pfn, prot);
+	WARN_ON(!pud_same(pud, pud));
+	WARN_ON(!pud_young(pud_mkyoung(pud)));
+	WARN_ON(!pud_write(pud_mkwrite(pud)));
+	WARN_ON(pud_write(pud_wrprotect(pud)));
+	WARN_ON(pud_young(pud_mkold(pud)));
+
+#if !defined(__PAGETABLE_PMD_FOLDED) && !defined(__ARCH_HAS_4LEVEL_HACK)
+	/*
+	 * A huge page does not point to next level page table
+	 * entry. Hence this must qualify as pud_bad().
+	 */
+	WARN_ON(!pud_bad(pud_mkhuge(pud)));
+#endif
+}
+#else
+static void pud_basic_tests(void) { }
+#endif
+
+static void p4d_basic_tests(void)
+{
+	pte_t pte;
+	p4d_t p4d;
+
+	pte = mk_pte(page, prot);
+	p4d = (p4d_t) { (pte_val(pte)) };
+	WARN_ON(!p4d_same(p4d, p4d));
+}
+
+static void pgd_basic_tests(void)
+{
+	pte_t pte;
+	pgd_t pgd;
+
+	pte = mk_pte(page, prot);
+	pgd = (pgd_t) { (pte_val(pte)) };
+	WARN_ON(!pgd_same(pgd, pgd));
+}
+
+#if !defined(__PAGETABLE_PMD_FOLDED) && !defined(__ARCH_HAS_4LEVEL_HACK)
+static void pud_clear_tests(void)
+{
+	pud_t pud;
+
+	pud_clear(&pud);
+	WARN_ON(!pud_none(pud));
+}
+
+static void pud_populate_tests(void)
+{
+	pmd_t pmd;
+	pud_t pud;
+
+	/*
+	 * This entry points to next level page table page.
+	 * Hence this must not qualify as pud_bad().
+	 */
+	pmd_clear(&pmd);
+	pud_clear(&pud);
+	pud_populate(&mm, &pud, &pmd);
+	WARN_ON(pud_bad(pud));
+}
+#else
+static void pud_clear_tests(void) { }
+static void pud_populate_tests(void) { }
+#endif
+
+#if !defined(__PAGETABLE_PUD_FOLDED) && !defined(__ARCH_HAS_5LEVEL_HACK)
+static void p4d_clear_tests(void)
+{
+	p4d_t p4d;
+
+	p4d_clear(&p4d);
+	WARN_ON(!p4d_none(p4d));
+}
+
+static void p4d_populate_tests(void)
+{
+	pud_t pud;
+	p4d_t p4d;
+
+	/*
+	 * This entry points to next level page table page.
+	 * Hence this must not qualify as p4d_bad().
+	 */
+	pud_clear(&pud);
+	p4d_clear(&p4d);
+	p4d_populate(&mm, &p4d, &pud);
+	WARN_ON(p4d_bad(p4d));
+}
+#else
+static void p4d_clear_tests(void) { }
+static void p4d_populate_tests(void) { }
+#endif
+
+#ifndef __PAGETABLE_P4D_FOLDED
+static void pgd_clear_tests(void)
+{
+	pgd_t pgd;
+
+	pgd_clear(&pgd);
+	WARN_ON(!pgd_none(pgd));
+}
+
+static void pgd_populate_tests(void)
+{
+	pgd_t p4d;
+	pgd_t pgd;
+
+	/*
+	 * This entry points to next level page table page.
+	 * Hence this must not qualify as pgd_bad().
+	 */
+	p4d_clear(&p4d);
+	pgd_clear(&pgd);
+	pgd_populate(&mm, &pgd, &p4d);
+	WARN_ON(pgd_bad(pgd));
+}
+#else
+static void pgd_clear_tests(void) { }
+static void pgd_populate_tests(void) { }
+#endif
+
+static void pxx_clear_tests(void)
+{
+	pte_t pte;
+	pmd_t pmd;
+
+	pte_clear(NULL, 0, &pte);
+	WARN_ON(!pte_none(pte));
+
+	pmd_clear(&pmd);
+	WARN_ON(!pmd_none(pmd));
+
+	pud_clear_tests();
+	p4d_clear_tests();
+	pgd_clear_tests();
+}
+
+static void pxx_populate_tests(void)
+{
+	pmd_t pmd;
+
+	/*
+	 * This entry points to next level page table page.
+	 * Hence this must not qualify as pmd_bad().
+	 */
+	memset(page, 0, sizeof(*page));
+	pmd_clear(&pmd);
+	pmd_populate(&mm, &pmd, page);
+	WARN_ON(pmd_bad(pmd));
+
+	pud_populate_tests();
+	p4d_populate_tests();
+	pgd_populate_tests();
+}
+
+static int variables_alloc(void)
+{
+	vma_init(&vma, &mm);
+	prot = vm_get_page_prot(VMA_TEST_FLAGS);
+	page = alloc_page(GFP_KERNEL | __GFP_ZERO);
+	if (!page) {
+		pr_err("Test struct page allocation failed\n");
+		return 1;
+	}
+	pfn = page_to_pfn(page);
+	addr = 0;
+	return 0;
+}
+
+static void variables_free(void)
+{
+	free_page((unsigned long)page_address(page));
+}
+
+static int __init arch_pgtable_tests_init(void)
+{
+	int ret;
+
+	ret = variables_alloc();
+	if (ret) {
+		pr_err("Test resource initialization failed\n");
+		return 1;
+	}
+
+	pte_basic_tests();
+	pmd_basic_tests();
+	pud_basic_tests();
+	p4d_basic_tests();
+	pgd_basic_tests();
+	pxx_clear_tests();
+	pxx_populate_tests();
+	variables_free();
+	return 0;
+}
+
+static void __exit arch_pgtable_tests_exit(void) { }
+
+module_init(arch_pgtable_tests_init);
+module_exit(arch_pgtable_tests_exit);
+MODULE_LICENSE("GPL v2");
-- 
2.7.4

