Return-Path: <SRS0=On+J=TX=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_HELO_NONE,SPF_PASS,
	USER_AGENT_GIT autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 5BBC1C282DE
	for <linux-mm@archiver.kernel.org>; Thu, 23 May 2019 15:03:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 0F37B2177E
	for <linux-mm@archiver.kernel.org>; Thu, 23 May 2019 15:03:36 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 0F37B2177E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=arm.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B0B346B000E; Thu, 23 May 2019 11:03:35 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id A95136B0010; Thu, 23 May 2019 11:03:35 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 93A616B0266; Thu, 23 May 2019 11:03:35 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id 458C46B000E
	for <linux-mm@kvack.org>; Thu, 23 May 2019 11:03:35 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id h12so9397322edl.23
        for <linux-mm@kvack.org>; Thu, 23 May 2019 08:03:35 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=GpTEqD8XoKhCQeXR0WWWARsHxCmoAKY+/W+smFPVQrY=;
        b=P4sxr/EAXBKqSGs+/WRd9Igq99rwmFKqBXam5r7Y5KLO0ObbFBz0wOdB9Ji9OajiP8
         3GislsYSDGgCETh6x+lRDMXKxGgp9KW7+Gt0wWrOiCaCrjXzQrMPOZdwjDPo33hMrYFx
         zxm83aSmKG64e6hL8Zk0VorX1eK8Jry6q24Gva9BwG0++lQ42g+XWcScsEqP5YRwDds0
         rIf/1w3YIe44usTUIQ0+HPvd6L+qF59wvkQWYwWZ2PdEgkMBUFRE69kzC0zAeBiFSfNo
         pbeiGHbgiGOnvqi4uMOjw8cgMgmGU7gqZPdXJ6iOhS4JkvL0k5Z3lMEBc7CpjIIbIsF6
         VOQQ==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of robin.murphy@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=robin.murphy@arm.com
X-Gm-Message-State: APjAAAVbB/BXpBYoXwXekREax5cFmjs3kYw6WkWIdMwaFIZHfLLj9E2S
	0sKmFpjEiMc0cRb+1grj1qmKmnXxma94mk/S2fJfBdaBUBIMdjE9aP+ndGbK7YXSLSLyvEl2WHo
	1ZawLXI352258CtNGtIcsOxB6CeIOqcz8jlaeQubn5pqBALJXlqntq1nHjx09XNyxMQ==
X-Received: by 2002:a17:906:4f8f:: with SMTP id o15mr61507891eju.129.1558623814685;
        Thu, 23 May 2019 08:03:34 -0700 (PDT)
X-Google-Smtp-Source: APXvYqwot+DmcQxP90El4eAEGytzf/fT5baWGO8/eMlqYS/u0lz172wrhxQAkUsp4wlZAKznCxOy
X-Received: by 2002:a17:906:4f8f:: with SMTP id o15mr61507716eju.129.1558623812945;
        Thu, 23 May 2019 08:03:32 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558623812; cv=none;
        d=google.com; s=arc-20160816;
        b=DOb/+LB5eFSAv3YgobRUL94BFJ0agGOc7Hcpqzs/anjMHD6Cdf6s4HjNNHq4BY/but
         wZgzZ2t4EkPPNMFsYeYsKMCUHUPvvOuhaRGUMbBqhaQ2j8pyJcmEMS4r7yAEKbxqA5zr
         91Bp5P//E+VBk2vi11eCXhzkpZQ5JbiMI36QgiFJwLxdzgTX8zxsutNpMd75o9S5ubgS
         cVXJTJzfClL2magyoCBsKkOT52UhFQvL/CKlRT+YW9aFSzdyAiPtZCbU8QyOnciDpS3H
         DUstAAHQtgmYnTD/inmVrfTcQgTpRtRFQRkYYJ+Yu1kHctGsACZ2/ZxB++kpsRv9oOEY
         3oYA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=GpTEqD8XoKhCQeXR0WWWARsHxCmoAKY+/W+smFPVQrY=;
        b=dkPHvkpI9cCKZC8algzhJSwfjoWO0weGLPJttXAuRqrr3wu7echBN0Fq5zr6tCE/FS
         fWKSx8SWIwNZKN+tgfvqSpT3V1QMWFiDhjBrb/r7iQjeDGhd67zJ9o3XSPiutBEN8vdn
         C0j1sxjf2AJcN6n1BPLMPfUfr55bx6JiMfn6/FqJqdJXHqLcaScaYqOyDsg7cDN57WnG
         abSXX3IqCpeC4hjjzMmdmxmky1Sj8KCy5a4vqhtdg6kv16kmhikgnBRK8IaErXens9dI
         +4cCVOtjT1bxKuwf9SKK4PejAWwCasbCMD78sv7fR/ypn17evR67tCUjvbSwZJpFOPOq
         l+2A==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of robin.murphy@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=robin.murphy@arm.com
Received: from foss.arm.com (usa-sjc-mx-foss1.foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id r1si12697555ejh.347.2019.05.23.08.03.32
        for <linux-mm@kvack.org>;
        Thu, 23 May 2019 08:03:32 -0700 (PDT)
Received-SPF: pass (google.com: domain of robin.murphy@arm.com designates 217.140.101.70 as permitted sender) client-ip=217.140.101.70;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of robin.murphy@arm.com designates 217.140.101.70 as permitted sender) smtp.mailfrom=robin.murphy@arm.com
Received: from usa-sjc-imap-foss1.foss.arm.com (unknown [10.72.51.249])
	by usa-sjc-mx-foss1.foss.arm.com (Postfix) with ESMTP id BF3AA15AB;
	Thu, 23 May 2019 08:03:31 -0700 (PDT)
Received: from e110467-lin.cambridge.arm.com (e110467-lin.cambridge.arm.com [10.1.196.75])
	by usa-sjc-imap-foss1.foss.arm.com (Postfix) with ESMTPA id 7E2B83F690;
	Thu, 23 May 2019 08:03:29 -0700 (PDT)
From: Robin Murphy <robin.murphy@arm.com>
To: linux-mm@kvack.org
Cc: akpm@linux-foundation.org,
	will.deacon@arm.com,
	catalin.marinas@arm.com,
	anshuman.khandual@arm.com,
	linux-arm-kernel@lists.infradead.org,
	linux-kernel@vger.kernel.org,
	x86@kernel.org,
	linuxppc-dev@lists.ozlabs.org,
	Michael Ellerman <mpe@ellerman.id.au>,
	Dan Williams <dan.j.williams@intel.com>,
	Ira Weiny <ira.weiny@intel.com>,
	Oliver O'Halloran <oohall@gmail.com>
Subject: [PATCH v3 3/4] mm: introduce ARCH_HAS_PTE_DEVMAP
Date: Thu, 23 May 2019 16:03:15 +0100
Message-Id: <87554aa78478a02a63f2c4cf60a847279ae3eb3b.1558547956.git.robin.murphy@arm.com>
X-Mailer: git-send-email 2.21.0.dirty
In-Reply-To: <cover.1558547956.git.robin.murphy@arm.com>
References: <cover.1558547956.git.robin.murphy@arm.com>
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
index 8c1c636308c8..1120ff8ac715 100644
--- a/arch/powerpc/Kconfig
+++ b/arch/powerpc/Kconfig
@@ -128,6 +128,7 @@ config PPC
 	select ARCH_HAS_MMIOWB			if PPC64
 	select ARCH_HAS_PHYS_TO_DMA
 	select ARCH_HAS_PMEM_API                if PPC64
+	select ARCH_HAS_PTE_DEVMAP		if PPC_BOOK3S_64
 	select ARCH_HAS_PTE_SPECIAL
 	select ARCH_HAS_MEMBARRIER_CALLBACKS
 	select ARCH_HAS_SCALED_CPUTIME		if VIRT_CPU_ACCOUNTING_NATIVE && PPC64
@@ -135,7 +136,6 @@ config PPC
 	select ARCH_HAS_TICK_BROADCAST		if GENERIC_CLOCKEVENTS_BROADCAST
 	select ARCH_HAS_UACCESS_FLUSHCACHE	if PPC64
 	select ARCH_HAS_UBSAN_SANITIZE_ALL
-	select ARCH_HAS_ZONE_DEVICE		if PPC_BOOK3S_64
 	select ARCH_HAVE_NMI_SAFE_CMPXCHG
 	select ARCH_KEEP_MEMBLOCK
 	select ARCH_MIGHT_HAVE_PC_PARPORT
diff --git a/arch/powerpc/include/asm/book3s/64/pgtable.h b/arch/powerpc/include/asm/book3s/64/pgtable.h
index 7dede2e34b70..c6c2bdfb369b 100644
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
index 2bbbd4d1ba31..57c4e80bd368 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -69,6 +69,7 @@ config X86
 	select ARCH_HAS_KCOV			if X86_64
 	select ARCH_HAS_MEMBARRIER_SYNC_CORE
 	select ARCH_HAS_PMEM_API		if X86_64
+	select ARCH_HAS_PTE_DEVMAP		if X86_64
 	select ARCH_HAS_PTE_SPECIAL
 	select ARCH_HAS_REFCOUNT
 	select ARCH_HAS_UACCESS_FLUSHCACHE	if X86_64
@@ -79,7 +80,6 @@ config X86
 	select ARCH_HAS_STRICT_MODULE_RWX
 	select ARCH_HAS_SYNC_CORE_BEFORE_USERMODE
 	select ARCH_HAS_UBSAN_SANITIZE_ALL
-	select ARCH_HAS_ZONE_DEVICE		if X86_64
 	select ARCH_HAVE_NMI_SAFE_CMPXCHG
 	select ARCH_MIGHT_HAVE_ACPI_PDC		if ACPI
 	select ARCH_MIGHT_HAVE_PC_PARPORT
diff --git a/arch/x86/include/asm/pgtable.h b/arch/x86/include/asm/pgtable.h
index 5e0509b41986..0bc530c4eb13 100644
--- a/arch/x86/include/asm/pgtable.h
+++ b/arch/x86/include/asm/pgtable.h
@@ -271,7 +271,7 @@ static inline int has_transparent_hugepage(void)
 	return boot_cpu_has(X86_FEATURE_PSE);
 }
 
-#ifdef __HAVE_ARCH_PTE_DEVMAP
+#ifdef CONFIG_ARCH_HAS_PTE_DEVMAP
 static inline int pmd_devmap(pmd_t pmd)
 {
 	return !!(pmd_val(pmd) & _PAGE_DEVMAP);
@@ -732,7 +732,7 @@ static inline int pte_present(pte_t a)
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
index 9cd613a7f67b..f61c016de005 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -536,7 +536,7 @@ static inline void vma_set_anonymous(struct vm_area_struct *vma)
 struct mmu_gather;
 struct inode;
 
-#if !defined(__HAVE_ARCH_PTE_DEVMAP) || !defined(CONFIG_TRANSPARENT_HUGEPAGE)
+#if !defined(CONFIG_ARCH_HAS_PTE_DEVMAP) || !defined(CONFIG_TRANSPARENT_HUGEPAGE)
 static inline int pmd_devmap(pmd_t pmd)
 {
 	return 0;
@@ -1754,7 +1754,7 @@ static inline void sync_mm_rss(struct mm_struct *mm)
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
index ee8d1f311858..3aeef0442d03 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -647,8 +647,7 @@ config IDLE_PAGE_TRACKING
 	  See Documentation/admin-guide/mm/idle_page_tracking.rst for
 	  more details.
 
-# arch_add_memory() comprehends device memory
-config ARCH_HAS_ZONE_DEVICE
+config ARCH_HAS_PTE_DEVMAP
 	bool
 
 config ZONE_DEVICE
@@ -656,7 +655,7 @@ config ZONE_DEVICE
 	depends on MEMORY_HOTPLUG
 	depends on MEMORY_HOTREMOVE
 	depends on SPARSEMEM_VMEMMAP
-	depends on ARCH_HAS_ZONE_DEVICE
+	depends on ARCH_HAS_PTE_DEVMAP
 	select XARRAY_MULTI
 
 	help
diff --git a/mm/gup.c b/mm/gup.c
index 2c08248d4fa2..777010ca3bf0 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -1799,7 +1799,7 @@ static int gup_pte_range(pmd_t pmd, unsigned long addr, unsigned long end,
 }
 #endif /* CONFIG_ARCH_HAS_PTE_SPECIAL */
 
-#if defined(__HAVE_ARCH_PTE_DEVMAP) && defined(CONFIG_TRANSPARENT_HUGEPAGE)
+#if defined(CONFIG_ARCH_HAS_PTE_DEVMAP) && defined(CONFIG_TRANSPARENT_HUGEPAGE)
 static int __gup_device_huge(unsigned long pfn, unsigned long addr,
 		unsigned long end, struct page **pages, int *nr)
 {
-- 
2.21.0.dirty

