Return-Path: <SRS0=SemS=S7=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 1766FC43219
	for <linux-mm@archiver.kernel.org>; Mon, 29 Apr 2019 17:22:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id B99802147A
	for <linux-mm@archiver.kernel.org>; Mon, 29 Apr 2019 17:22:35 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org B99802147A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 607936B0008; Mon, 29 Apr 2019 13:22:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 515956B000A; Mon, 29 Apr 2019 13:22:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 42AA16B000C; Mon, 29 Apr 2019 13:22:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id E1AB86B0008
	for <linux-mm@kvack.org>; Mon, 29 Apr 2019 13:22:34 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id r48so5145448eda.11
        for <linux-mm@kvack.org>; Mon, 29 Apr 2019 10:22:34 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=TeehqriwnfAzZxk6PUNuJHpfUbkf/0d7jrAAjX1GZsM=;
        b=k9SfOw+ETou5MUs2bWEigsgIMLjeYstiVAKxfJDlVLCT68UM3QHy6ViFivm0QttUxw
         sUJouqhB8SR8xnTaaH8v/a8z7PW+yWaWC73RMiaw/2beLO7usuo5d2mCw8R4dWOiklZp
         nOKQpz5vPuYlFTi/Rhee+7j+QiqWTTJ+xY0NpYKuZRg2y6h05hQpy/arxyX1Ulb3xUPW
         NoCrqeVKU75UbL69oofiRmb1DOaHqqwnMEsHY3h0Evd2mEFwkM5zz3rhE1KVYK43/Q0m
         AA/RqO1WSEbeB64yvvAsTECl9UKOi3ys9noH2HhybZ1si2+AnsJkZmoxkb68Yg+4qGr2
         qJKQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of robin.murphy@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=robin.murphy@arm.com
X-Gm-Message-State: APjAAAWU/LoCG4Vu5a1qdmxhG/MgN94mJFRjrrg1hvxbhKUmBbv4mdRu
	QWwehTsEyd/rMiQkgPtDm8VJe6B7PniZzqOmGDtNLvQd/TbgeMlTlfQEZTNuwLN0tDPTIS81hb8
	l9CRET28hR7wQoPFTbqs+GdA88cPPIJn4IMEaIqskO6XhRXBhXiVeprQpmch2sliQ3Q==
X-Received: by 2002:a50:a4db:: with SMTP id x27mr39733316edb.120.1556558554416;
        Mon, 29 Apr 2019 10:22:34 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwSY36OeVoXo9c2t8gXY0WAa8SM4jAojM0CVap1OQEjNXh6C/z3B1Da2WFPQEhooPLxLOiJ
X-Received: by 2002:a50:a4db:: with SMTP id x27mr39733262edb.120.1556558553527;
        Mon, 29 Apr 2019 10:22:33 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556558553; cv=none;
        d=google.com; s=arc-20160816;
        b=O4DYlHDhJyjfoOfjCUZqgRn9wCqj/ylR+4EAMYn458CVixjkure9EtVz/hOigzD3WL
         TVAJCvYrRfr25vtpYlPisNv8fPkjhik3l9z6mDl0PeIxBt4ogMjTVPIoNPyZhtrBVEKf
         Ndg8pcZydmZcK9oK39DFXq0CdwjUix0zsmLj+p0WZEl/bu+IhUWl5dPWxYe1E+5UHTbb
         t59xRypifVRZVNo8bylOzjCrLumOCb554CB/icjuBtr8JegMj1Wrpw/lTDHIGvz5GLOA
         gKh1D03XPLa9UNvrG9dldE9uB9nATCiFhRhseJrq9PidNwcOdsTEs7CGmcLCZajNVXmj
         zp6g==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=TeehqriwnfAzZxk6PUNuJHpfUbkf/0d7jrAAjX1GZsM=;
        b=hAJDjDMwlGZy/6XEHZeQkLWW5XT8c37pCd5J8FB/ytSTbIUqKqDng/nTl7GZmR9U8i
         AJ8HlsRWwImjhniC0HqT+6Rtb/IrVwdDx27KUSn50qn5UYgnIreeMfWmlsV8JacfOA+T
         /t7r6uCHL3eZjtFLOPnyOuWHPr/VZi4GKhIee0ONMge+CULbJLTVU4IPG9J4UDS9/Tj0
         PqHh+T3LY9JdNcFgdqoyUk1mhqTnszIUZdXNzmJ4P47pdLacx6ui0LZeaFFX7SFBLWBi
         n3kJ1dF/WliCqXx2a8pp10jjnWXfrYxeY3Nvtu6Q0/sV75xxAmj3ixf24SsvhdnfFnyF
         EBvA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of robin.murphy@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=robin.murphy@arm.com
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id hk19si2492861ejb.321.2019.04.29.10.22.33
        for <linux-mm@kvack.org>;
        Mon, 29 Apr 2019 10:22:33 -0700 (PDT)
Received-SPF: pass (google.com: domain of robin.murphy@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of robin.murphy@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=robin.murphy@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id 5391CEBD;
	Mon, 29 Apr 2019 10:22:32 -0700 (PDT)
Received: from e110467-lin.cambridge.arm.com (e110467-lin.cambridge.arm.com [10.1.196.75])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPA id 746633F557;
	Mon, 29 Apr 2019 10:22:30 -0700 (PDT)
From: Robin Murphy <robin.murphy@arm.com>
To: linux-mm@kvack.org
Cc: akpm@linux-foundation.org,
	linux-kernel@vger.kernel.org,
	x86@kernel.org,
	linuxppc-dev@lists.ozlabs.org,
	Michael Ellerman <mpe@ellerman.id.au>,
	Dan Williams <dan.j.williams@intel.com>,
	Ira Weiny <ira.weiny@intel.com>,
	Oliver O'Halloran <oohall@gmail.com>,
	Anshuman Khandual <anshuman.khandual@arm.com>
Subject: [PATCH v2 3/3] mm: introduce ARCH_HAS_PTE_DEVMAP
Date: Mon, 29 Apr 2019 18:22:17 +0100
Message-Id: <39f00b9e5768d05bf7bbc75493f121ad7b553a2f.1556555457.git.robin.murphy@arm.com>
X-Mailer: git-send-email 2.21.0.dirty
In-Reply-To: <cover.1556555457.git.robin.murphy@arm.com>
References: <cover.1556555457.git.robin.murphy@arm.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

ARCH_HAS_ZONE_DEVICE is somewhat meaningless in itself, and combined
with the long-out-of-date comment can lead to the impression than an
architecture may just enable it (since __add_pages() now "comprehends
device memory" for itself) and expect things to work.

In practice, however, ZONE_DEVICE users have little chance of
functioning correctly without __HAVE_ARCH_PTE_DEVMAP, so let's clean
that up the same way as ARCH_HAS_PTE_SPECIAL and make it the proper
dependency so the real situation is clearer.

Cc: x86@kernel.org
Cc: linuxppc-dev@lists.ozlabs.org
Cc: Michael Ellerman <mpe@ellerman.id.au>
Acked-by: Dan Williams <dan.j.williams@intel.com>
Reviewed-by: Ira Weiny <ira.weiny@intel.com>
Acked-by: Oliver O'Halloran <oohall@gmail.com>
Reviewed-by: Anshuman Khandual <anshuman.khandual@arm.com>
Signed-off-by: Robin Murphy <robin.murphy@arm.com>
---

v2: Add review tags.

 arch/powerpc/Kconfig                         | 2 +-
 arch/powerpc/include/asm/book3s/64/pgtable.h | 1 -
 arch/x86/Kconfig                             | 2 +-
 arch/x86/include/asm/pgtable.h               | 4 ++--
 arch/x86/include/asm/pgtable_types.h         | 1 -
 include/linux/mm.h                           | 4 ++--
 include/linux/pfn_t.h                        | 4 ++--
 mm/Kconfig                                   | 5 ++---
 mm/gup.c                                     | 2 +-
 9 files changed, 11 insertions(+), 14 deletions(-)

diff --git a/arch/powerpc/Kconfig b/arch/powerpc/Kconfig
index 5e3d0853c31d..77e1993bba80 100644
--- a/arch/powerpc/Kconfig
+++ b/arch/powerpc/Kconfig
@@ -135,6 +135,7 @@ config PPC
 	select ARCH_HAS_MMIOWB			if PPC64
 	select ARCH_HAS_PHYS_TO_DMA
 	select ARCH_HAS_PMEM_API                if PPC64
+	select ARCH_HAS_PTE_DEVMAP		if PPC_BOOK3S_64
 	select ARCH_HAS_PTE_SPECIAL
 	select ARCH_HAS_MEMBARRIER_CALLBACKS
 	select ARCH_HAS_SCALED_CPUTIME		if VIRT_CPU_ACCOUNTING_NATIVE && PPC64
@@ -142,7 +143,6 @@ config PPC
 	select ARCH_HAS_TICK_BROADCAST		if GENERIC_CLOCKEVENTS_BROADCAST
 	select ARCH_HAS_UACCESS_FLUSHCACHE	if PPC64
 	select ARCH_HAS_UBSAN_SANITIZE_ALL
-	select ARCH_HAS_ZONE_DEVICE		if PPC_BOOK3S_64
 	select ARCH_HAVE_NMI_SAFE_CMPXCHG
 	select ARCH_MIGHT_HAVE_PC_PARPORT
 	select ARCH_MIGHT_HAVE_PC_SERIO
diff --git a/arch/powerpc/include/asm/book3s/64/pgtable.h b/arch/powerpc/include/asm/book3s/64/pgtable.h
index 581f91be9dd4..02c22ac8f387 100644
--- a/arch/powerpc/include/asm/book3s/64/pgtable.h
+++ b/arch/powerpc/include/asm/book3s/64/pgtable.h
@@ -90,7 +90,6 @@
 #define _PAGE_SOFT_DIRTY	_RPAGE_SW3 /* software: software dirty tracking */
 #define _PAGE_SPECIAL		_RPAGE_SW2 /* software: special page */
 #define _PAGE_DEVMAP		_RPAGE_SW1 /* software: ZONE_DEVICE page */
-#define __HAVE_ARCH_PTE_DEVMAP
 
 /*
  * Drivers request for cache inhibited pte mapping using _PAGE_NO_CACHE
diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index 5ad92419be19..ffd50f27f395 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -60,6 +60,7 @@ config X86
 	select ARCH_HAS_KCOV			if X86_64
 	select ARCH_HAS_MEMBARRIER_SYNC_CORE
 	select ARCH_HAS_PMEM_API		if X86_64
+	select ARCH_HAS_PTE_DEVMAP		if X86_64
 	select ARCH_HAS_PTE_SPECIAL
 	select ARCH_HAS_REFCOUNT
 	select ARCH_HAS_UACCESS_FLUSHCACHE	if X86_64
@@ -69,7 +70,6 @@ config X86
 	select ARCH_HAS_STRICT_MODULE_RWX
 	select ARCH_HAS_SYNC_CORE_BEFORE_USERMODE
 	select ARCH_HAS_UBSAN_SANITIZE_ALL
-	select ARCH_HAS_ZONE_DEVICE		if X86_64
 	select ARCH_HAVE_NMI_SAFE_CMPXCHG
 	select ARCH_MIGHT_HAVE_ACPI_PDC		if ACPI
 	select ARCH_MIGHT_HAVE_PC_PARPORT
diff --git a/arch/x86/include/asm/pgtable.h b/arch/x86/include/asm/pgtable.h
index 2779ace16d23..89a1f6fd48bf 100644
--- a/arch/x86/include/asm/pgtable.h
+++ b/arch/x86/include/asm/pgtable.h
@@ -254,7 +254,7 @@ static inline int has_transparent_hugepage(void)
 	return boot_cpu_has(X86_FEATURE_PSE);
 }
 
-#ifdef __HAVE_ARCH_PTE_DEVMAP
+#ifdef CONFIG_ARCH_HAS_PTE_DEVMAP
 static inline int pmd_devmap(pmd_t pmd)
 {
 	return !!(pmd_val(pmd) & _PAGE_DEVMAP);
@@ -715,7 +715,7 @@ static inline int pte_present(pte_t a)
 	return pte_flags(a) & (_PAGE_PRESENT | _PAGE_PROTNONE);
 }
 
-#ifdef __HAVE_ARCH_PTE_DEVMAP
+#ifdef CONFIG_ARCH_HAS_PTE_DEVMAP
 static inline int pte_devmap(pte_t a)
 {
 	return (pte_flags(a) & _PAGE_DEVMAP) == _PAGE_DEVMAP;
diff --git a/arch/x86/include/asm/pgtable_types.h b/arch/x86/include/asm/pgtable_types.h
index d6ff0bbdb394..b5e49e6bac63 100644
--- a/arch/x86/include/asm/pgtable_types.h
+++ b/arch/x86/include/asm/pgtable_types.h
@@ -103,7 +103,6 @@
 #if defined(CONFIG_X86_64) || defined(CONFIG_X86_PAE)
 #define _PAGE_NX	(_AT(pteval_t, 1) << _PAGE_BIT_NX)
 #define _PAGE_DEVMAP	(_AT(u64, 1) << _PAGE_BIT_DEVMAP)
-#define __HAVE_ARCH_PTE_DEVMAP
 #else
 #define _PAGE_NX	(_AT(pteval_t, 0))
 #define _PAGE_DEVMAP	(_AT(pteval_t, 0))
diff --git a/include/linux/mm.h b/include/linux/mm.h
index d76dfb7ac617..fe05c94f23e9 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -504,7 +504,7 @@ struct inode;
 #define page_private(page)		((page)->private)
 #define set_page_private(page, v)	((page)->private = (v))
 
-#if !defined(__HAVE_ARCH_PTE_DEVMAP) || !defined(CONFIG_TRANSPARENT_HUGEPAGE)
+#if !defined(CONFIG_ARCH_HAS_PTE_DEVMAP) || !defined(CONFIG_TRANSPARENT_HUGEPAGE)
 static inline int pmd_devmap(pmd_t pmd)
 {
 	return 0;
@@ -1698,7 +1698,7 @@ static inline void sync_mm_rss(struct mm_struct *mm)
 }
 #endif
 
-#ifndef __HAVE_ARCH_PTE_DEVMAP
+#ifndef CONFIG_ARCH_HAS_PTE_DEVMAP
 static inline int pte_devmap(pte_t pte)
 {
 	return 0;
diff --git a/include/linux/pfn_t.h b/include/linux/pfn_t.h
index 7bb77850c65a..de8bc66b10a4 100644
--- a/include/linux/pfn_t.h
+++ b/include/linux/pfn_t.h
@@ -104,7 +104,7 @@ static inline pud_t pfn_t_pud(pfn_t pfn, pgprot_t pgprot)
 #endif
 #endif
 
-#ifdef __HAVE_ARCH_PTE_DEVMAP
+#ifdef CONFIG_ARCH_HAS_PTE_DEVMAP
 static inline bool pfn_t_devmap(pfn_t pfn)
 {
 	const u64 flags = PFN_DEV|PFN_MAP;
@@ -122,7 +122,7 @@ pmd_t pmd_mkdevmap(pmd_t pmd);
 	defined(CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE_PUD)
 pud_t pud_mkdevmap(pud_t pud);
 #endif
-#endif /* __HAVE_ARCH_PTE_DEVMAP */
+#endif /* CONFIG_ARCH_HAS_PTE_DEVMAP */
 
 #ifdef CONFIG_ARCH_HAS_PTE_SPECIAL
 static inline bool pfn_t_special(pfn_t pfn)
diff --git a/mm/Kconfig b/mm/Kconfig
index 25c71eb8a7db..fcb7ab08e294 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -655,8 +655,7 @@ config IDLE_PAGE_TRACKING
 	  See Documentation/admin-guide/mm/idle_page_tracking.rst for
 	  more details.
 
-# arch_add_memory() comprehends device memory
-config ARCH_HAS_ZONE_DEVICE
+config ARCH_HAS_PTE_DEVMAP
 	bool
 
 config ZONE_DEVICE
@@ -664,7 +663,7 @@ config ZONE_DEVICE
 	depends on MEMORY_HOTPLUG
 	depends on MEMORY_HOTREMOVE
 	depends on SPARSEMEM_VMEMMAP
-	depends on ARCH_HAS_ZONE_DEVICE
+	depends on ARCH_HAS_PTE_DEVMAP
 	select XARRAY_MULTI
 
 	help
diff --git a/mm/gup.c b/mm/gup.c
index f84e22685aaa..72a5c7d1e1a7 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -1623,7 +1623,7 @@ static int gup_pte_range(pmd_t pmd, unsigned long addr, unsigned long end,
 }
 #endif /* CONFIG_ARCH_HAS_PTE_SPECIAL */
 
-#if defined(__HAVE_ARCH_PTE_DEVMAP) && defined(CONFIG_TRANSPARENT_HUGEPAGE)
+#if defined(CONFIG_ARCH_HAS_PTE_DEVMAP) && defined(CONFIG_TRANSPARENT_HUGEPAGE)
 static int __gup_device_huge(unsigned long pfn, unsigned long addr,
 		unsigned long end, struct page **pages, int *nr)
 {
-- 
2.21.0.dirty

