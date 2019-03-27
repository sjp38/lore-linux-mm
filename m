Return-Path: <SRS0=JxSR=R6=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,URIBL_BLOCKED,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 57996C43381
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 06:41:32 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 02C582075E
	for <linux-mm@archiver.kernel.org>; Wed, 27 Mar 2019 06:41:32 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 02C582075E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ghiti.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B031B6B000D; Wed, 27 Mar 2019 02:41:31 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AB1A06B000E; Wed, 27 Mar 2019 02:41:31 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 97A286B0010; Wed, 27 Mar 2019 02:41:31 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 438786B000D
	for <linux-mm@kvack.org>; Wed, 27 Mar 2019 02:41:31 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id f11so2987080edq.18
        for <linux-mm@kvack.org>; Tue, 26 Mar 2019 23:41:31 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=cbIutQEpAPxZ/KdU7m2lcqPjdOI8X56/ZOv99DdJWe4=;
        b=azJPI06Go8+i8RPqcGHZqol8UZo8op2JEAdjVZ9D+k/zL1QF+Bx7J//CR130hKZs3I
         6+muk5rbn4GJJt83cWRKl9iOZe2MzaXniJKUj5CqZWNCXO9lrqx72c33fb3CeUz+jA4+
         5zyB36IgvK8dg4U2KSdww4ka978GY+2EXGaaG69Sa1biZYR14TfoUU1pAeN5i2Q6WbGs
         iyCE6CmrL2Ds/st0kFXTc59ZjS/T7ghZWZYbzBfYcEhDNBd0TpfmvEHz9mlpWQuLlTKS
         if75PUhm/btSccpDGg45c6RxAaUaQRvwFoiqlX1ybxaK2Gdz5xwsV9Npg8hbxz9Q4vPe
         EOEQ==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 217.70.178.232 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Gm-Message-State: APjAAAVspiBUjxCNpI8hDPCgMsoiiDudbMeCFUn01K3w96uZMpq1pOf0
	bGQDekuYPK0r9Vx9vtJN5xhEBaPPGe2O81YGCsyiaJD+OjAQwNFacNS+FbVGtT5GFrv1i+qv5ZZ
	9Jq3pA8+MdADUDYt+5zHmKZsXq6ux0cg0WSvbpGD3AlNzUD/5IWC7ylKwbTJn8qI=
X-Received: by 2002:a17:906:3c3:: with SMTP id c3mr19170615eja.181.1553668890746;
        Tue, 26 Mar 2019 23:41:30 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzA7YMKyetXK8s8RgJ+4l0f86ZTi2R+qTa+3Xxa2RXeUBoYfW+G7VuDGqErU70pKVOT5q80
X-Received: by 2002:a17:906:3c3:: with SMTP id c3mr19170550eja.181.1553668889188;
        Tue, 26 Mar 2019 23:41:29 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1553668889; cv=none;
        d=google.com; s=arc-20160816;
        b=depE0KUxChAYWkH533SxbY35OuXV9aWRp8pedu324oaxjlKvJrTMz2aiVphrRwPsze
         b+pWYUvQyaGKqzwjA5dtFJ4fmezn6lE0MVM8GvWznKo2BoIgTLH5Qm+fGYziUaMThB6s
         l/iX7FqqI60K7plCBC3GgLpL/0+JXbzurDrUBIRqV2FYLWALQmf5spoSjY9Qz0Nqgzfs
         PZoo+lVu5n1AUowxixJE3rQKmoQnaFsMpGG6iXd1MhigStCNmCh2P/GY+d0NR6Icfyqx
         t3HPlkbv2s3+DnOIhktQhj9jNRwgOo5NvqPcrhSDQyLPxmdOqyOwJ9Nlis7eJdoGCLf1
         l6MQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=cbIutQEpAPxZ/KdU7m2lcqPjdOI8X56/ZOv99DdJWe4=;
        b=nzaHRc0x0Hv8BJjklKTviSi+rG3RTOWXU8WEXqK/iVbpalm4HYs1fzUcATcHd3WL93
         9MNanr04kBKh3Zb3f0xPuSlGbbLoMykJWcenvpOvAEbGs333GxmGcMbLCLbKetPjORB8
         UXdRpoCV21VRPQj174U8msDGxrwwfnaBh3ytVPMzuS9UgUChkdVqjznO9HSXqkGBPF/g
         GJnPoNEh0UpQ9pVWEGJm4GGlYgj5LTGcX6zImRD4BwndyNovxqWxXlcv3GLuB4gK2NB+
         1HGxdc4xSqIB4XO7H3rPoeNZQ2oJeNlE14gNOZY5YjcIIbfw5IY8OQNLLcc3Ax/VuJrm
         VNuQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 217.70.178.232 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
Received: from relay12.mail.gandi.net (relay12.mail.gandi.net. [217.70.178.232])
        by mx.google.com with ESMTPS id bq13si2600334ejb.7.2019.03.26.23.41.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 26 Mar 2019 23:41:29 -0700 (PDT)
Received-SPF: neutral (google.com: 217.70.178.232 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) client-ip=217.70.178.232;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 217.70.178.232 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
Received: from alex.numericable.fr (127.19.86.79.rev.sfr.net [79.86.19.127])
	(Authenticated sender: alex@ghiti.fr)
	by relay12.mail.gandi.net (Postfix) with ESMTPSA id 556BD200008;
	Wed, 27 Mar 2019 06:41:15 +0000 (UTC)
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
Subject: [PATCH v8 4/4] hugetlb: allow to free gigantic pages regardless of the configuration
Date: Wed, 27 Mar 2019 02:36:26 -0400
Message-Id: <20190327063626.18421-5-alex@ghiti.fr>
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

On systems without CONTIG_ALLOC activated but that support gigantic pages,
boottime reserved gigantic pages can not be freed at all. This patch
simply enables the possibility to hand back those pages to memory
allocator.

Signed-off-by: Alexandre Ghiti <alex@ghiti.fr>
Acked-by: David S. Miller <davem@davemloft.net> [sparc]
---
 arch/arm64/Kconfig                           |  2 +-
 arch/arm64/include/asm/hugetlb.h             |  4 --
 arch/powerpc/include/asm/book3s/64/hugetlb.h |  5 +-
 arch/powerpc/platforms/Kconfig.cputype       |  2 +-
 arch/s390/Kconfig                            |  2 +-
 arch/s390/include/asm/hugetlb.h              |  8 +--
 arch/sh/Kconfig                              |  2 +-
 arch/sparc/Kconfig                           |  2 +-
 arch/x86/Kconfig                             |  2 +-
 arch/x86/include/asm/hugetlb.h               |  4 --
 include/asm-generic/hugetlb.h                |  7 +++
 include/linux/gfp.h                          |  2 +-
 mm/hugetlb.c                                 | 54 ++++++++++++++------
 mm/page_alloc.c                              |  4 +-
 14 files changed, 61 insertions(+), 39 deletions(-)

diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
index a8380629cb3f..d33c6a7b9fc5 100644
--- a/arch/arm64/Kconfig
+++ b/arch/arm64/Kconfig
@@ -18,7 +18,7 @@ config ARM64
 	select ARCH_HAS_FAST_MULTIPLIER
 	select ARCH_HAS_FORTIFY_SOURCE
 	select ARCH_HAS_GCOV_PROFILE_ALL
-	select ARCH_HAS_GIGANTIC_PAGE if CONTIG_ALLOC
+	select ARCH_HAS_GIGANTIC_PAGE
 	select ARCH_HAS_KCOV
 	select ARCH_HAS_MEMBARRIER_SYNC_CORE
 	select ARCH_HAS_PTE_SPECIAL
diff --git a/arch/arm64/include/asm/hugetlb.h b/arch/arm64/include/asm/hugetlb.h
index c6a07a3b433e..4aad6382f631 100644
--- a/arch/arm64/include/asm/hugetlb.h
+++ b/arch/arm64/include/asm/hugetlb.h
@@ -70,8 +70,4 @@ extern void set_huge_swap_pte_at(struct mm_struct *mm, unsigned long addr,
 
 #include <asm-generic/hugetlb.h>
 
-#ifdef CONFIG_ARCH_HAS_GIGANTIC_PAGE
-static inline bool gigantic_page_supported(void) { return true; }
-#endif
-
 #endif /* __ASM_HUGETLB_H */
diff --git a/arch/powerpc/include/asm/book3s/64/hugetlb.h b/arch/powerpc/include/asm/book3s/64/hugetlb.h
index ec2a55a553c7..7013284f0f1b 100644
--- a/arch/powerpc/include/asm/book3s/64/hugetlb.h
+++ b/arch/powerpc/include/asm/book3s/64/hugetlb.h
@@ -36,8 +36,8 @@ static inline int hstate_get_psize(struct hstate *hstate)
 	}
 }
 
-#ifdef CONFIG_ARCH_HAS_GIGANTIC_PAGE
-static inline bool gigantic_page_supported(void)
+#define __HAVE_ARCH_GIGANTIC_PAGE_RUNTIME_SUPPORTED
+static inline bool gigantic_page_runtime_supported(void)
 {
 	/*
 	 * We used gigantic page reservation with hypervisor assist in some case.
@@ -49,7 +49,6 @@ static inline bool gigantic_page_supported(void)
 
 	return true;
 }
-#endif
 
 /* hugepd entry valid bit */
 #define HUGEPD_VAL_BITS		(0x8000000000000000UL)
diff --git a/arch/powerpc/platforms/Kconfig.cputype b/arch/powerpc/platforms/Kconfig.cputype
index eb0f592cde69..03ca91439473 100644
--- a/arch/powerpc/platforms/Kconfig.cputype
+++ b/arch/powerpc/platforms/Kconfig.cputype
@@ -325,7 +325,7 @@ config ARCH_ENABLE_SPLIT_PMD_PTLOCK
 config PPC_RADIX_MMU
 	bool "Radix MMU Support"
 	depends on PPC_BOOK3S_64
-	select ARCH_HAS_GIGANTIC_PAGE if CONTIG_ALLOC
+	select ARCH_HAS_GIGANTIC_PAGE
 	default y
 	help
 	  Enable support for the Power ISA 3.0 Radix style MMU. Currently this
diff --git a/arch/s390/Kconfig b/arch/s390/Kconfig
index 1c8cb55b4e5d..5a9cc12c32c6 100644
--- a/arch/s390/Kconfig
+++ b/arch/s390/Kconfig
@@ -69,7 +69,7 @@ config S390
 	select ARCH_HAS_ELF_RANDOMIZE
 	select ARCH_HAS_FORTIFY_SOURCE
 	select ARCH_HAS_GCOV_PROFILE_ALL
-	select ARCH_HAS_GIGANTIC_PAGE if CONTIG_ALLOC
+	select ARCH_HAS_GIGANTIC_PAGE
 	select ARCH_HAS_KCOV
 	select ARCH_HAS_PTE_SPECIAL
 	select ARCH_HAS_SET_MEMORY
diff --git a/arch/s390/include/asm/hugetlb.h b/arch/s390/include/asm/hugetlb.h
index 2d1afa58a4b6..bb59dd964590 100644
--- a/arch/s390/include/asm/hugetlb.h
+++ b/arch/s390/include/asm/hugetlb.h
@@ -116,7 +116,9 @@ static inline pte_t huge_pte_modify(pte_t pte, pgprot_t newprot)
 	return pte_modify(pte, newprot);
 }
 
-#ifdef CONFIG_ARCH_HAS_GIGANTIC_PAGE
-static inline bool gigantic_page_supported(void) { return true; }
-#endif
+static inline bool gigantic_page_runtime_supported(void)
+{
+	return true;
+}
+
 #endif /* _ASM_S390_HUGETLB_H */
diff --git a/arch/sh/Kconfig b/arch/sh/Kconfig
index 67931bdaf32f..6d3db745ab7c 100644
--- a/arch/sh/Kconfig
+++ b/arch/sh/Kconfig
@@ -53,7 +53,7 @@ config SUPERH
 	select HAVE_FUTEX_CMPXCHG if FUTEX
 	select HAVE_NMI
 	select NEED_SG_DMA_LENGTH
-	select ARCH_HAS_GIGANTIC_PAGE if CONTIG_ALLOC
+	select ARCH_HAS_GIGANTIC_PAGE
 
 	help
 	  The SuperH is a RISC processor targeted for use in embedded systems
diff --git a/arch/sparc/Kconfig b/arch/sparc/Kconfig
index 52193cfb0f32..98f8dd663fd8 100644
--- a/arch/sparc/Kconfig
+++ b/arch/sparc/Kconfig
@@ -91,7 +91,7 @@ config SPARC64
 	select ARCH_CLOCKSOURCE_DATA
 	select ARCH_HAS_PTE_SPECIAL
 	select PCI_DOMAINS if PCI
-	select ARCH_HAS_GIGANTIC_PAGE if CONTIG_ALLOC
+	select ARCH_HAS_GIGANTIC_PAGE
 
 config ARCH_DEFCONFIG
 	string
diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index 749bab313dc1..1b7584d17a5a 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -21,7 +21,7 @@ config X86_64
 	def_bool y
 	depends on 64BIT
 	# Options that are inherently 64-bit kernel only:
-	select ARCH_HAS_GIGANTIC_PAGE if CONTIG_ALLOC
+	select ARCH_HAS_GIGANTIC_PAGE
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
diff --git a/include/asm-generic/hugetlb.h b/include/asm-generic/hugetlb.h
index 71d7b77eea50..822f433ac95c 100644
--- a/include/asm-generic/hugetlb.h
+++ b/include/asm-generic/hugetlb.h
@@ -126,4 +126,11 @@ static inline pte_t huge_ptep_get(pte_t *ptep)
 }
 #endif
 
+#ifndef __HAVE_ARCH_GIGANTIC_PAGE_RUNTIME_SUPPORTED
+static inline bool gigantic_page_runtime_supported(void)
+{
+	return IS_ENABLED(CONFIG_ARCH_HAS_GIGANTIC_PAGE);
+}
+#endif /* __HAVE_ARCH_GIGANTIC_PAGE_RUNTIME_SUPPORTED */
+
 #endif /* _ASM_GENERIC_HUGETLB_H */
diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index e77ab30e9328..fb07b503dc45 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -589,8 +589,8 @@ static inline bool pm_suspended_storage(void)
 /* The below functions must be run on a range from a single zone. */
 extern int alloc_contig_range(unsigned long start, unsigned long end,
 			      unsigned migratetype, gfp_t gfp_mask);
-extern void free_contig_range(unsigned long pfn, unsigned nr_pages);
 #endif
+void free_contig_range(unsigned long pfn, unsigned int nr_pages);
 
 #ifdef CONFIG_CMA
 /* CMA stuff */
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index 97b1e0290c66..f3e84c1bef11 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -1059,6 +1059,7 @@ static void free_gigantic_page(struct page *page, unsigned int order)
 	free_contig_range(page_to_pfn(page), 1 << order);
 }
 
+#ifdef CONFIG_CONTIG_ALLOC
 static int __alloc_gigantic_page(unsigned long start_pfn,
 				unsigned long nr_pages, gfp_t gfp_mask)
 {
@@ -1143,11 +1144,20 @@ static struct page *alloc_gigantic_page(struct hstate *h, gfp_t gfp_mask,
 
 static void prep_new_huge_page(struct hstate *h, struct page *page, int nid);
 static void prep_compound_gigantic_page(struct page *page, unsigned int order);
+#else /* !CONFIG_CONTIG_ALLOC */
+static struct page *alloc_gigantic_page(struct hstate *h, gfp_t gfp_mask,
+					int nid, nodemask_t *nodemask)
+{
+	return NULL;
+}
+#endif /* CONFIG_CONTIG_ALLOC */
 
 #else /* !CONFIG_ARCH_HAS_GIGANTIC_PAGE */
-static inline bool gigantic_page_supported(void) { return false; }
 static struct page *alloc_gigantic_page(struct hstate *h, gfp_t gfp_mask,
-		int nid, nodemask_t *nodemask) { return NULL; }
+					int nid, nodemask_t *nodemask)
+{
+	return NULL;
+}
 static inline void free_gigantic_page(struct page *page, unsigned int order) { }
 static inline void destroy_compound_gigantic_page(struct page *page,
 						unsigned int order) { }
@@ -1157,7 +1167,7 @@ static void update_and_free_page(struct hstate *h, struct page *page)
 {
 	int i;
 
-	if (hstate_is_gigantic(h) && !gigantic_page_supported())
+	if (hstate_is_gigantic(h) && !gigantic_page_runtime_supported())
 		return;
 
 	h->nr_huge_pages--;
@@ -2277,13 +2287,27 @@ static int adjust_pool_surplus(struct hstate *h, nodemask_t *nodes_allowed,
 }
 
 #define persistent_huge_pages(h) (h->nr_huge_pages - h->surplus_huge_pages)
-static unsigned long set_max_huge_pages(struct hstate *h, unsigned long count,
-						nodemask_t *nodes_allowed)
+static int set_max_huge_pages(struct hstate *h, unsigned long count,
+			      nodemask_t *nodes_allowed)
 {
 	unsigned long min_count, ret;
 
-	if (hstate_is_gigantic(h) && !gigantic_page_supported())
-		return h->max_huge_pages;
+	spin_lock(&hugetlb_lock);
+
+	/*
+	 * Gigantic pages runtime allocation depend on the capability for large
+	 * page range allocation.
+	 * If the system does not provide this feature, return an error when
+	 * the user tries to allocate gigantic pages but let the user free the
+	 * boottime allocated gigantic pages.
+	 */
+	if (hstate_is_gigantic(h) && !IS_ENABLED(CONFIG_CONTIG_ALLOC)) {
+		if (count > persistent_huge_pages(h)) {
+			spin_unlock(&hugetlb_lock);
+			return -EINVAL;
+		}
+		/* Fall through to decrease pool */
+	}
 
 	/*
 	 * Increase the pool size
@@ -2296,7 +2320,6 @@ static unsigned long set_max_huge_pages(struct hstate *h, unsigned long count,
 	 * pool might be one hugepage larger than it needs to be, but
 	 * within all the constraints specified by the sysctls.
 	 */
-	spin_lock(&hugetlb_lock);
 	while (h->surplus_huge_pages && count > persistent_huge_pages(h)) {
 		if (!adjust_pool_surplus(h, nodes_allowed, -1))
 			break;
@@ -2351,9 +2374,10 @@ static unsigned long set_max_huge_pages(struct hstate *h, unsigned long count,
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
@@ -2405,7 +2429,7 @@ static ssize_t __nr_hugepages_store_common(bool obey_mempolicy,
 	int err;
 	NODEMASK_ALLOC(nodemask_t, nodes_allowed, GFP_KERNEL | __GFP_NORETRY);
 
-	if (hstate_is_gigantic(h) && !gigantic_page_supported()) {
+	if (hstate_is_gigantic(h) && !gigantic_page_runtime_supported()) {
 		err = -EINVAL;
 		goto out;
 	}
@@ -2429,15 +2453,13 @@ static ssize_t __nr_hugepages_store_common(bool obey_mempolicy,
 	} else
 		nodes_allowed = &node_states[N_MEMORY];
 
-	h->max_huge_pages = set_max_huge_pages(h, count, nodes_allowed);
+	err = set_max_huge_pages(h, count, nodes_allowed);
 
+out:
 	if (nodes_allowed != &node_states[N_MEMORY])
 		NODEMASK_FREE(nodes_allowed);
 
-	return len;
-out:
-	NODEMASK_FREE(nodes_allowed);
-	return err;
+	return err ? err : len;
 }
 
 static ssize_t nr_hugepages_store_common(bool obey_mempolicy,
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index ecb115a74a9d..cad000879f14 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -8318,8 +8318,9 @@ int alloc_contig_range(unsigned long start, unsigned long end,
 				pfn_max_align_up(end), migratetype);
 	return ret;
 }
+#endif /* CONFIG_CONTIG_ALLOC */
 
-void free_contig_range(unsigned long pfn, unsigned nr_pages)
+void free_contig_range(unsigned long pfn, unsigned int nr_pages)
 {
 	unsigned int count = 0;
 
@@ -8331,7 +8332,6 @@ void free_contig_range(unsigned long pfn, unsigned nr_pages)
 	}
 	WARN(count != 0, "%d pages are still in use!\n", count);
 }
-#endif
 
 #ifdef CONFIG_MEMORY_HOTPLUG
 /*
-- 
2.20.1

