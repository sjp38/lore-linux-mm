Return-Path: <SRS0=NGLy=QU=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=unavailable autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id F1213C282C2
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 19:26:30 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id A13AD218D3
	for <linux-mm@archiver.kernel.org>; Wed, 13 Feb 2019 19:26:30 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org A13AD218D3
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ghiti.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 439018E0004; Wed, 13 Feb 2019 14:26:30 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 3C14D8E0001; Wed, 13 Feb 2019 14:26:30 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 28A6C8E0004; Wed, 13 Feb 2019 14:26:30 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f71.google.com (mail-wm1-f71.google.com [209.85.128.71])
	by kanga.kvack.org (Postfix) with ESMTP id AC1C08E0001
	for <linux-mm@kvack.org>; Wed, 13 Feb 2019 14:26:29 -0500 (EST)
Received: by mail-wm1-f71.google.com with SMTP id f193so1287585wme.8
        for <linux-mm@kvack.org>; Wed, 13 Feb 2019 11:26:29 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:mime-version:content-transfer-encoding;
        bh=VTce/FTp1vN41x/v2MuM87om7f1Le2D3AsZ8cQrfj0M=;
        b=N6ptwk9pd2IeGAEsOSBM1YNsi4OS0FdlR+DFcibYNWywsatZipTUcLjo3OTOL4mP+U
         lmIrTsRwFLBwPV7XtwJ4emhpIL7gEbP1CjVuwaavY7O0lndiKq48/uvJprrMtZng95Bz
         5ehalE+Awci71+nfWQwTeWyina0Zx8t165MGbYm/skO2NvcNCZB2MItLCrg7H4F3Kn6X
         81oRUtuFNW/P3LYmGT38qqjCAe1ISDErrKCZR4EhEno091g5iUpmc7RV6kzq2gCrZpXT
         rspYYShKtVUQ+4DGFipjPU8ZNzg/mb2MaJQb297ZzkT3r6jgEJGk37FE+WRleocvRnjm
         mdXw==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 217.70.183.200 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Gm-Message-State: AHQUAuai/isKorWe0CPUyfzdXuqavYk272blf2e/ekDk/Zt36opQcaeg
	89qE08an/I/FPIw3j2IHiFKGyfoavsOgt4OJMNct1QzbfP/iUocVYKzvRO5sYqQOOwrlZz5BRU/
	36etUrRNF6IE3LOOup5+sJfFGHK7sA/lvPLeNosP4FkaY//EcaQz+qtQB7U4ossE=
X-Received: by 2002:a05:6000:92:: with SMTP id m18mr1626296wrx.258.1550085989230;
        Wed, 13 Feb 2019 11:26:29 -0800 (PST)
X-Google-Smtp-Source: AHgI3IZq5KbMcSdxuEoE905Vxt1zlGcEUs1P4bjg2gThdLlFBmAU/iK1Zg6pZqvmUyexU1IU5iRR
X-Received: by 2002:a05:6000:92:: with SMTP id m18mr1626238wrx.258.1550085987739;
        Wed, 13 Feb 2019 11:26:27 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550085987; cv=none;
        d=google.com; s=arc-20160816;
        b=Di4bULtGP3Q5cIxFQTAHAWOCN3Hmsw0G2rggE/lJWKhHPTgHJvP45egC2Cq+AHLZXJ
         KA2XW1SkUPxda1/3j7TE+9sOLUlEpFkG2yMwzB5crvYVIkeeRP0b3frLjJGTXSJCHrHI
         wEgIQRF7UTqRD9Asv/OePRSqafAaxS2s/m9bn+lcPNoXkHja0w3e6x9HG61Z+dOkYopU
         zoIVQN1ZS7kFVNLrzAZ7k/bQVv7rqvveyF2vXUABcuHD1Zh+ZMmehNRf0/9cJSxfWVrH
         x9ZfpwIsKhRvGt+cWrLbnDUUcUK4fWFxwN/65GhVXdEhbtK7cDrAK50/+/S5UEHL12dW
         66DA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:message-id:date:subject:cc
         :to:from;
        bh=VTce/FTp1vN41x/v2MuM87om7f1Le2D3AsZ8cQrfj0M=;
        b=NGO06yLnqHISDE7efT2SRjaY5zeZACklZHjxYe8oRMXsbqRQr+PrxRi5S183ShAWOI
         uJANVhFS7+VFl/sRmBn9LaIc1OjwEsGoz0hGg6tGjpyPOccPfr7clrkHaAe7IqaHE5uo
         M2fGLe5Vd+iuJXuVGgpKyjgry967oFnOJE7D51WEMMbGlSGxFbJ1TcaugWHF8eYdhKdg
         auMXtEcv/e9/UQ+XWzbLWbZflJ650r6oIHVcBVhkALTJq1A51sRB5qCHHDUROrH2XuRc
         dDtck/BdvuYNFp/t5JFFvGpzEGu4CN3vmLs4dc3A/uu+yoKrzQDRpLQFMkC6iSOGgUOw
         EoMA==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 217.70.183.200 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
Received: from relay7-d.mail.gandi.net (relay7-d.mail.gandi.net. [217.70.183.200])
        by mx.google.com with ESMTPS id q2si75302wrw.423.2019.02.13.11.26.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 13 Feb 2019 11:26:27 -0800 (PST)
Received-SPF: neutral (google.com: 217.70.183.200 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) client-ip=217.70.183.200;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 217.70.183.200 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Originating-IP: 79.86.19.127
Received: from alex.numericable.fr (127.19.86.79.rev.sfr.net [79.86.19.127])
	(Authenticated sender: alex@ghiti.fr)
	by relay7-d.mail.gandi.net (Postfix) with ESMTPSA id B67852000B;
	Wed, 13 Feb 2019 19:26:17 +0000 (UTC)
From: Alexandre Ghiti <alex@ghiti.fr>
To: Vlastimil Babka <vbabka@suse.cz>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Paul Mackerras <paulus@samba.org>,
	Michael Ellerman <mpe@ellerman.id.au>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>,
	Borislav Petkov <bp@alien8.de>,
	"H . Peter Anvin" <hpa@zytor.com>,
	x86@kernel.org,
	Dave Hansen <dave.hansen@linux.intel.com>,
	Andy Lutomirski <luto@kernel.org>,
	Peter Zijlstra <peterz@infradead.org>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Mike Kravetz <mike.kravetz@oracle.com>,
	linux-arm-kernel@lists.infradead.org,
	linux-kernel@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org,
	linux-s390@vger.kernel.org,
	linux-fsdevel@vger.kernel.org,
	linux-mm@kvack.org
Cc: Alexandre Ghiti <alex@ghiti.fr>
Subject: [PATCH v2] hugetlb: allow to free gigantic pages regardless of the configuration
Date: Wed, 13 Feb 2019 14:26:10 -0500
Message-Id: <20190213192610.17265-1-alex@ghiti.fr>
X-Mailer: git-send-email 2.20.1
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

On systems without CMA or (MEMORY_ISOLATION && COMPACTION) activated but
that support gigantic pages, boottime reserved gigantic pages can not be
freed at all. This patch simply enables the possibility to hand back
those pages to memory allocator.

This patch also renames:

- the triplet CMA or (MEMORY_ISOLATION && COMPACTION) into COMPACTION_CORE,
and gets rid of all use of it in architecture specific code (and then
removes ARCH_HAS_GIGANTIC_PAGE config).
- gigantic_page_supported to make it more accurate: this value being false
does not mean that the system cannot use gigantic pages, it just means that
runtime allocation of gigantic pages is not supported, one can still
allocate boottime gigantic pages if the architecture supports it.

Signed-off-by: Alexandre Ghiti <alex@ghiti.fr>
---

Changes in v2 as suggested by Vlastimil Babka:
- Get rid of ARCH_HAS_GIGANTIC_PAGE
- Get rid of architecture specific gigantic_page_supported
- Factorize CMA or (MEMORY_ISOLATION && COMPACTION) into COMPACTION_CORE

Compiles on all arches and validated on riscv.

 arch/arm64/Kconfig                           |  1 -
 arch/arm64/include/asm/hugetlb.h             |  4 --
 arch/powerpc/include/asm/book3s/64/hugetlb.h |  7 ----
 arch/powerpc/platforms/Kconfig.cputype       |  1 -
 arch/s390/Kconfig                            |  1 -
 arch/s390/include/asm/hugetlb.h              |  3 --
 arch/x86/Kconfig                             |  1 -
 arch/x86/include/asm/hugetlb.h               |  4 --
 arch/x86/mm/hugetlbpage.c                    |  2 +-
 fs/Kconfig                                   |  3 +-
 include/linux/gfp.h                          |  4 +-
 mm/hugetlb.c                                 | 44 +++++++++++---------
 mm/page_alloc.c                              |  7 ++--
 13 files changed, 32 insertions(+), 50 deletions(-)

diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
index a4168d366127..6c778046b9f7 100644
--- a/arch/arm64/Kconfig
+++ b/arch/arm64/Kconfig
@@ -18,7 +18,6 @@ config ARM64
 	select ARCH_HAS_FAST_MULTIPLIER
 	select ARCH_HAS_FORTIFY_SOURCE
 	select ARCH_HAS_GCOV_PROFILE_ALL
-	select ARCH_HAS_GIGANTIC_PAGE if (MEMORY_ISOLATION && COMPACTION) || CMA
 	select ARCH_HAS_KCOV
 	select ARCH_HAS_MEMBARRIER_SYNC_CORE
 	select ARCH_HAS_PTE_SPECIAL
diff --git a/arch/arm64/include/asm/hugetlb.h b/arch/arm64/include/asm/hugetlb.h
index fb6609875455..59893e766824 100644
--- a/arch/arm64/include/asm/hugetlb.h
+++ b/arch/arm64/include/asm/hugetlb.h
@@ -65,8 +65,4 @@ extern void set_huge_swap_pte_at(struct mm_struct *mm, unsigned long addr,
 
 #include <asm-generic/hugetlb.h>
 
-#ifdef CONFIG_ARCH_HAS_GIGANTIC_PAGE
-static inline bool gigantic_page_supported(void) { return true; }
-#endif
-
 #endif /* __ASM_HUGETLB_H */
diff --git a/arch/powerpc/include/asm/book3s/64/hugetlb.h b/arch/powerpc/include/asm/book3s/64/hugetlb.h
index 5b0177733994..d04a0bcc2f1c 100644
--- a/arch/powerpc/include/asm/book3s/64/hugetlb.h
+++ b/arch/powerpc/include/asm/book3s/64/hugetlb.h
@@ -32,13 +32,6 @@ static inline int hstate_get_psize(struct hstate *hstate)
 	}
 }
 
-#ifdef CONFIG_ARCH_HAS_GIGANTIC_PAGE
-static inline bool gigantic_page_supported(void)
-{
-	return true;
-}
-#endif
-
 /* hugepd entry valid bit */
 #define HUGEPD_VAL_BITS		(0x8000000000000000UL)
 
diff --git a/arch/powerpc/platforms/Kconfig.cputype b/arch/powerpc/platforms/Kconfig.cputype
index 8c7464c3f27f..3e629dfb5efa 100644
--- a/arch/powerpc/platforms/Kconfig.cputype
+++ b/arch/powerpc/platforms/Kconfig.cputype
@@ -319,7 +319,6 @@ config ARCH_ENABLE_SPLIT_PMD_PTLOCK
 config PPC_RADIX_MMU
 	bool "Radix MMU Support"
 	depends on PPC_BOOK3S_64
-	select ARCH_HAS_GIGANTIC_PAGE if (MEMORY_ISOLATION && COMPACTION) || CMA
 	default y
 	help
 	  Enable support for the Power ISA 3.0 Radix style MMU. Currently this
diff --git a/arch/s390/Kconfig b/arch/s390/Kconfig
index ed554b09eb3f..556860f290e9 100644
--- a/arch/s390/Kconfig
+++ b/arch/s390/Kconfig
@@ -69,7 +69,6 @@ config S390
 	select ARCH_HAS_ELF_RANDOMIZE
 	select ARCH_HAS_FORTIFY_SOURCE
 	select ARCH_HAS_GCOV_PROFILE_ALL
-	select ARCH_HAS_GIGANTIC_PAGE if (MEMORY_ISOLATION && COMPACTION) || CMA
 	select ARCH_HAS_KCOV
 	select ARCH_HAS_PTE_SPECIAL
 	select ARCH_HAS_SET_MEMORY
diff --git a/arch/s390/include/asm/hugetlb.h b/arch/s390/include/asm/hugetlb.h
index 2d1afa58a4b6..bd191560efcf 100644
--- a/arch/s390/include/asm/hugetlb.h
+++ b/arch/s390/include/asm/hugetlb.h
@@ -116,7 +116,4 @@ static inline pte_t huge_pte_modify(pte_t pte, pgprot_t newprot)
 	return pte_modify(pte, newprot);
 }
 
-#ifdef CONFIG_ARCH_HAS_GIGANTIC_PAGE
-static inline bool gigantic_page_supported(void) { return true; }
-#endif
 #endif /* _ASM_S390_HUGETLB_H */
diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index 68261430fe6e..2fd983e2b2f6 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -23,7 +23,6 @@ config X86_64
 	def_bool y
 	depends on 64BIT
 	# Options that are inherently 64-bit kernel only:
-	select ARCH_HAS_GIGANTIC_PAGE if (MEMORY_ISOLATION && COMPACTION) || CMA
 	select ARCH_SUPPORTS_INT128
 	select ARCH_USE_CMPXCHG_LOCKREF
 	select HAVE_ARCH_SOFT_DIRTY
diff --git a/arch/x86/include/asm/hugetlb.h b/arch/x86/include/asm/hugetlb.h
index 7469d321f072..f65cfb48cfdd 100644
--- a/arch/x86/include/asm/hugetlb.h
+++ b/arch/x86/include/asm/hugetlb.h
@@ -17,8 +17,4 @@ static inline void arch_clear_hugepage_flags(struct page *page)
 {
 }
 
-#ifdef CONFIG_ARCH_HAS_GIGANTIC_PAGE
-static inline bool gigantic_page_supported(void) { return true; }
-#endif
-
 #endif /* _ASM_X86_HUGETLB_H */
diff --git a/arch/x86/mm/hugetlbpage.c b/arch/x86/mm/hugetlbpage.c
index 92e4c4b85bba..4c3d8f8fc414 100644
--- a/arch/x86/mm/hugetlbpage.c
+++ b/arch/x86/mm/hugetlbpage.c
@@ -203,7 +203,7 @@ static __init int setup_hugepagesz(char *opt)
 }
 __setup("hugepagesz=", setup_hugepagesz);
 
-#if (defined(CONFIG_MEMORY_ISOLATION) && defined(CONFIG_COMPACTION)) || defined(CONFIG_CMA)
+#ifdef CONFIG_COMPACTION_CORE
 static __init int gigantic_pages_init(void)
 {
 	/* With compaction or CMA we can allocate gigantic pages at runtime */
diff --git a/fs/Kconfig b/fs/Kconfig
index ac474a61be37..8fecd3ea5563 100644
--- a/fs/Kconfig
+++ b/fs/Kconfig
@@ -207,8 +207,9 @@ config HUGETLB_PAGE
 config MEMFD_CREATE
 	def_bool TMPFS || HUGETLBFS
 
-config ARCH_HAS_GIGANTIC_PAGE
+config COMPACTION_CORE
 	bool
+	default y if (MEMORY_ISOLATION && MIGRATION) || CMA
 
 source "fs/configfs/Kconfig"
 source "fs/efivarfs/Kconfig"
diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index 5f5e25fd6149..aa0e899a9753 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -585,12 +585,12 @@ static inline bool pm_suspended_storage(void)
 }
 #endif /* CONFIG_PM_SLEEP */
 
-#if (defined(CONFIG_MEMORY_ISOLATION) && defined(CONFIG_COMPACTION)) || defined(CONFIG_CMA)
+#ifdef CONFIG_COMPACTION_CORE
 /* The below functions must be run on a range from a single zone. */
 extern int alloc_contig_range(unsigned long start, unsigned long end,
 			      unsigned migratetype, gfp_t gfp_mask);
-extern void free_contig_range(unsigned long pfn, unsigned nr_pages);
 #endif
+extern void free_contig_range(unsigned long pfn, unsigned int nr_pages);
 
 #ifdef CONFIG_CMA
 /* CMA stuff */
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index afef61656c1e..61bbcf8dcd9b 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -1035,7 +1035,6 @@ static int hstate_next_node_to_free(struct hstate *h, nodemask_t *nodes_allowed)
 		((node = hstate_next_node_to_free(hs, mask)) || 1);	\
 		nr_nodes--)
 
-#ifdef CONFIG_ARCH_HAS_GIGANTIC_PAGE
 static void destroy_compound_gigantic_page(struct page *page,
 					unsigned int order)
 {
@@ -1058,6 +1057,12 @@ static void free_gigantic_page(struct page *page, unsigned int order)
 	free_contig_range(page_to_pfn(page), 1 << order);
 }
 
+static inline bool gigantic_page_runtime_allocation_supported(void)
+{
+	return IS_ENABLED(CONFIG_COMPACTION_CORE);
+}
+
+#ifdef CONFIG_COMPACTION_CORE
 static int __alloc_gigantic_page(unsigned long start_pfn,
 				unsigned long nr_pages, gfp_t gfp_mask)
 {
@@ -1143,22 +1148,15 @@ static struct page *alloc_gigantic_page(struct hstate *h, gfp_t gfp_mask,
 static void prep_new_huge_page(struct hstate *h, struct page *page, int nid);
 static void prep_compound_gigantic_page(struct page *page, unsigned int order);
 
-#else /* !CONFIG_ARCH_HAS_GIGANTIC_PAGE */
-static inline bool gigantic_page_supported(void) { return false; }
+#else /* !CONFIG_COMPACTION_CORE */
 static struct page *alloc_gigantic_page(struct hstate *h, gfp_t gfp_mask,
 		int nid, nodemask_t *nodemask) { return NULL; }
-static inline void free_gigantic_page(struct page *page, unsigned int order) { }
-static inline void destroy_compound_gigantic_page(struct page *page,
-						unsigned int order) { }
 #endif
 
 static void update_and_free_page(struct hstate *h, struct page *page)
 {
 	int i;
 
-	if (hstate_is_gigantic(h) && !gigantic_page_supported())
-		return;
-
 	h->nr_huge_pages--;
 	h->nr_huge_pages_node[page_to_nid(page)]--;
 	for (i = 0; i < pages_per_huge_page(h); i++) {
@@ -2276,13 +2274,20 @@ static int adjust_pool_surplus(struct hstate *h, nodemask_t *nodes_allowed,
 }
 
 #define persistent_huge_pages(h) (h->nr_huge_pages - h->surplus_huge_pages)
-static unsigned long set_max_huge_pages(struct hstate *h, unsigned long count,
+static int set_max_huge_pages(struct hstate *h, unsigned long count,
 						nodemask_t *nodes_allowed)
 {
 	unsigned long min_count, ret;
 
-	if (hstate_is_gigantic(h) && !gigantic_page_supported())
-		return h->max_huge_pages;
+	if (hstate_is_gigantic(h) &&
+		!gigantic_page_runtime_allocation_supported()) {
+		spin_lock(&hugetlb_lock);
+		if (count > persistent_huge_pages(h)) {
+			spin_unlock(&hugetlb_lock);
+			return -EINVAL;
+		}
+		goto decrease_pool;
+	}
 
 	/*
 	 * Increase the pool size
@@ -2322,6 +2327,7 @@ static unsigned long set_max_huge_pages(struct hstate *h, unsigned long count,
 			goto out;
 	}
 
+decrease_pool:
 	/*
 	 * Decrease the pool size
 	 * First return free pages to the buddy allocator (being careful
@@ -2350,9 +2356,10 @@ static unsigned long set_max_huge_pages(struct hstate *h, unsigned long count,
 			break;
 	}
 out:
-	ret = persistent_huge_pages(h);
+	h->max_huge_pages = persistent_huge_pages(h);
 	spin_unlock(&hugetlb_lock);
-	return ret;
+
+	return 0;
 }
 
 #define HSTATE_ATTR_RO(_name) \
@@ -2404,11 +2411,6 @@ static ssize_t __nr_hugepages_store_common(bool obey_mempolicy,
 	int err;
 	NODEMASK_ALLOC(nodemask_t, nodes_allowed, GFP_KERNEL | __GFP_NORETRY);
 
-	if (hstate_is_gigantic(h) && !gigantic_page_supported()) {
-		err = -EINVAL;
-		goto out;
-	}
-
 	if (nid == NUMA_NO_NODE) {
 		/*
 		 * global hstate attribute
@@ -2428,7 +2430,9 @@ static ssize_t __nr_hugepages_store_common(bool obey_mempolicy,
 	} else
 		nodes_allowed = &node_states[N_MEMORY];
 
-	h->max_huge_pages = set_max_huge_pages(h, count, nodes_allowed);
+	err = set_max_huge_pages(h, count, nodes_allowed);
+	if (err)
+		goto out;
 
 	if (nodes_allowed != &node_states[N_MEMORY])
 		NODEMASK_FREE(nodes_allowed);
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 35fdde041f5c..e319548d2da2 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -8024,8 +8024,7 @@ bool has_unmovable_pages(struct zone *zone, struct page *page, int count,
 	return true;
 }
 
-#if (defined(CONFIG_MEMORY_ISOLATION) && defined(CONFIG_COMPACTION)) || defined(CONFIG_CMA)
-
+#ifdef CONFIG_COMPACTION_CORE
 static unsigned long pfn_max_align_down(unsigned long pfn)
 {
 	return pfn & ~(max_t(unsigned long, MAX_ORDER_NR_PAGES,
@@ -8235,8 +8234,9 @@ int alloc_contig_range(unsigned long start, unsigned long end,
 				pfn_max_align_up(end), migratetype);
 	return ret;
 }
+#endif
 
-void free_contig_range(unsigned long pfn, unsigned nr_pages)
+void free_contig_range(unsigned long pfn, unsigned int nr_pages)
 {
 	unsigned int count = 0;
 
@@ -8248,7 +8248,6 @@ void free_contig_range(unsigned long pfn, unsigned nr_pages)
 	}
 	WARN(count != 0, "%d pages are still in use!\n", count);
 }
-#endif
 
 #ifdef CONFIG_MEMORY_HOTPLUG
 /*
-- 
2.20.1

