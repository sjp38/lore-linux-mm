Return-Path: <SRS0=NBIx=RK=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS,USER_AGENT_GIT
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id B84ECC43381
	for <linux-mm@archiver.kernel.org>; Thu,  7 Mar 2019 13:25:03 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 4318620835
	for <linux-mm@archiver.kernel.org>; Thu,  7 Mar 2019 13:25:03 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4318620835
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=ghiti.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id DA26B8E0004; Thu,  7 Mar 2019 08:25:02 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id D536F8E0002; Thu,  7 Mar 2019 08:25:02 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id BF54D8E0004; Thu,  7 Mar 2019 08:25:02 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 5E1B28E0002
	for <linux-mm@kvack.org>; Thu,  7 Mar 2019 08:25:02 -0500 (EST)
Received: by mail-ed1-f72.google.com with SMTP id o27so8144409edc.14
        for <linux-mm@kvack.org>; Thu, 07 Mar 2019 05:25:02 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:from:to:cc
         :subject:date:message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=mvvKxD5ftXeu6TGsYhr80mxp0BHfHLSr33hH3EPdeHQ=;
        b=H0b7bWS39SpnaWvy5c3qAmtZoG0utKi2jVr0ZZTfnvlCCPUVdsm1r+C02pYI7H7C//
         c7NAQxXDolyDQD15pEFEhUEtH1WhquzXK3NslZnnArLNMGAq9WJPandMii6hvb9Z1FgC
         sgeIxeFGZXizGYOFieLWOctGd55ffcHovNQH3Wy3Y4wUYJGuDPTUCT8ZDgw56cimVDJv
         baS0DOvJgC1WoIWF1WITtWI5mWr5Zq5OTnBIIjgJTi6ckOb8cwVJS35tRfhW1NXCVG06
         JGXaMBdBbqYaf4tw3HhrvsbyiXhwGx2HW30Zgrf/UJJm083M3+GvVtUEkQ5j6s3vKeLs
         7Olg==
X-Original-Authentication-Results: mx.google.com;       spf=neutral (google.com: 217.70.183.195 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Gm-Message-State: APjAAAX8V+L6NOUXJfQwm+crlN3UQAl+6ZLS9M7HP2ZLg79O4iz4m4qV
	FHYqmAcWEodHdT81XZR4QQGJlvTiKPwIvCSMRBPkdq3kCtQtN1n/u//wO9EKFhzyix4a2ySnwU6
	N6mRTam97vLulu5LiTBnLFJJs7Z1tBqH7Ce39hSgOe24OzyUw9ifzlIhoTVVIbWc=
X-Received: by 2002:a17:906:5f91:: with SMTP id a17mr7878598eju.48.1551965101567;
        Thu, 07 Mar 2019 05:25:01 -0800 (PST)
X-Google-Smtp-Source: APXvYqz4PedQYCqyq8A95Ktb6zVScRuQZgExxpRgDFoG4huxRQQ2KmZvHYifnM/474HwomfOQ0Oi
X-Received: by 2002:a17:906:5f91:: with SMTP id a17mr7878513eju.48.1551965099883;
        Thu, 07 Mar 2019 05:24:59 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1551965099; cv=none;
        d=google.com; s=arc-20160816;
        b=xPYTVIgvT4XLxLMQy0ng/4qB/DOR3vDZiTUo7sEvWq6BmlXL6W5Ij+JHkbRgXpWKzN
         zE/P9X8xpYtikjdjxQQMdyVmDgKYNFrawjm5cDD5O92MVD5lYcHuj5n1OW5lxH3oq50v
         Ir3Asq+6nekxtMQ6Uvq844aNJq4cAXUCONdWnOHIuLdHJM5z/rVjJrSzUnQZ0PpFrvDW
         cWUoTEDYnWFUAzbJao/iUBRIeE5TgV2//JQUmCMo/5G6VbTJAE8z9derU7quMdZ0nMl0
         P6U7DBLiTd7K/aRBpfwS7puSgoAHdtnpN6bgYMUsp2iRTaJjBVwKESTWbTW9LFoCMFa8
         RDfA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from;
        bh=mvvKxD5ftXeu6TGsYhr80mxp0BHfHLSr33hH3EPdeHQ=;
        b=zH+ONx0/0fTYVXmM1SBHiZOeh35/HlaG13uehhK84MMGeiJkj/FDgr3jHwUdhAABLe
         M5I8QKMVsQonGGqCzK0hsFNUpF1y1V1zGCbHlX/v+jgfP+tuvi5gsypvMiutVb6ENFLU
         zxlG5GcgFhWZGLH5zu1/Agq7dQV9tLQ0z5KEFgnadqIY8nd4Md/53f+AKRGMzHlgA5fs
         SW5iP4rgLu2Ycb6gv09CykuaxdW2hHc9GhbEydNY6qDHbxhnQoctwSkljB5Z+HpO2k4p
         1jHZClAYKbmXbvVzZK64K2wVk3LtFaUfVhofabhQgSV20PrIJ9/oEVKT00v+6VSYyGbV
         cTMQ==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=neutral (google.com: 217.70.183.195 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
Received: from relay3-d.mail.gandi.net (relay3-d.mail.gandi.net. [217.70.183.195])
        by mx.google.com with ESMTPS id e8si1962160edd.87.2019.03.07.05.24.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Thu, 07 Mar 2019 05:24:59 -0800 (PST)
Received-SPF: neutral (google.com: 217.70.183.195 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) client-ip=217.70.183.195;
Authentication-Results: mx.google.com;
       spf=neutral (google.com: 217.70.183.195 is neither permitted nor denied by best guess record for domain of alex@ghiti.fr) smtp.mailfrom=alex@ghiti.fr
X-Originating-IP: 79.86.19.127
Received: from alex.numericable.fr (127.19.86.79.rev.sfr.net [79.86.19.127])
	(Authenticated sender: alex@ghiti.fr)
	by relay3-d.mail.gandi.net (Postfix) with ESMTPSA id 58E2260016;
	Thu,  7 Mar 2019 13:24:53 +0000 (UTC)
From: Alexandre Ghiti <alex@ghiti.fr>
To: Andrew Morton <akpm@linux-foundation.org>,
	Vlastimil Babka <vbabka@suse.cz>,
	Catalin Marinas <catalin.marinas@arm.com>,
	Will Deacon <will.deacon@arm.com>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Paul Mackerras <paulus@samba.org>,
	Michael Ellerman <mpe@ellerman.id.au>,
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
Subject: [PATCH v6 4/4] hugetlb: allow to free gigantic pages regardless of the configuration
Date: Thu,  7 Mar 2019 08:20:15 -0500
Message-Id: <20190307132015.26970-5-alex@ghiti.fr>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190307132015.26970-1-alex@ghiti.fr>
References: <20190307132015.26970-1-alex@ghiti.fr>
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
 arch/powerpc/include/asm/book3s/64/hugetlb.h |  7 ---
 arch/powerpc/platforms/Kconfig.cputype       |  2 +-
 arch/s390/Kconfig                            |  2 +-
 arch/s390/include/asm/hugetlb.h              |  3 --
 arch/sh/Kconfig                              |  2 +-
 arch/sparc/Kconfig                           |  2 +-
 arch/x86/Kconfig                             |  2 +-
 arch/x86/include/asm/hugetlb.h               |  4 --
 include/linux/gfp.h                          |  2 +-
 mm/hugetlb.c                                 | 57 ++++++++++++--------
 mm/page_alloc.c                              |  4 +-
 13 files changed, 44 insertions(+), 49 deletions(-)

diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
index 091a513b93e9..af687eff884a 100644
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
index f677c8974212..dc0328de20cd 100644
--- a/arch/powerpc/platforms/Kconfig.cputype
+++ b/arch/powerpc/platforms/Kconfig.cputype
@@ -319,7 +319,7 @@ config ARCH_ENABLE_SPLIT_PMD_PTLOCK
 config PPC_RADIX_MMU
 	bool "Radix MMU Support"
 	depends on PPC_BOOK3S_64
-	select ARCH_HAS_GIGANTIC_PAGE if CONTIG_ALLOC
+	select ARCH_HAS_GIGANTIC_PAGE
 	default y
 	help
 	  Enable support for the Power ISA 3.0 Radix style MMU. Currently this
diff --git a/arch/s390/Kconfig b/arch/s390/Kconfig
index 1c57b83c76f5..d84e536796b1 100644
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
diff --git a/arch/sh/Kconfig b/arch/sh/Kconfig
index c7266302691c..404b12a0d871 100644
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
index ca33c80870e2..234a6bd46e89 100644
--- a/arch/sparc/Kconfig
+++ b/arch/sparc/Kconfig
@@ -90,7 +90,7 @@ config SPARC64
 	select ARCH_CLOCKSOURCE_DATA
 	select ARCH_HAS_PTE_SPECIAL
 	select PCI_DOMAINS if PCI
-	select ARCH_HAS_GIGANTIC_PAGE if CONTIG_ALLOC
+	select ARCH_HAS_GIGANTIC_PAGE
 
 config ARCH_DEFCONFIG
 	string
diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
index 8ba90f3e0038..ff24eaeef211 100644
--- a/arch/x86/Kconfig
+++ b/arch/x86/Kconfig
@@ -23,7 +23,7 @@ config X86_64
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
diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index 1f1ad9aeebb9..58ea44bf75de 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -589,8 +589,8 @@ static inline bool pm_suspended_storage(void)
 /* The below functions must be run on a range from a single zone. */
 extern int alloc_contig_range(unsigned long start, unsigned long end,
 			      unsigned migratetype, gfp_t gfp_mask);
-extern void free_contig_range(unsigned long pfn, unsigned nr_pages);
 #endif
+extern void free_contig_range(unsigned long pfn, unsigned int nr_pages);
 
 #ifdef CONFIG_CMA
 /* CMA stuff */
diff --git a/mm/hugetlb.c b/mm/hugetlb.c
index afef61656c1e..9fc96ef5aa78 100644
--- a/mm/hugetlb.c
+++ b/mm/hugetlb.c
@@ -1058,6 +1058,7 @@ static void free_gigantic_page(struct page *page, unsigned int order)
 	free_contig_range(page_to_pfn(page), 1 << order);
 }
 
+#ifdef CONFIG_CONTIG_ALLOC
 static int __alloc_gigantic_page(unsigned long start_pfn,
 				unsigned long nr_pages, gfp_t gfp_mask)
 {
@@ -1142,11 +1143,20 @@ static struct page *alloc_gigantic_page(struct hstate *h, gfp_t gfp_mask,
 
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
@@ -1156,9 +1166,6 @@ static void update_and_free_page(struct hstate *h, struct page *page)
 {
 	int i;
 
-	if (hstate_is_gigantic(h) && !gigantic_page_supported())
-		return;
-
 	h->nr_huge_pages--;
 	h->nr_huge_pages_node[page_to_nid(page)]--;
 	for (i = 0; i < pages_per_huge_page(h); i++) {
@@ -2276,13 +2283,27 @@ static int adjust_pool_surplus(struct hstate *h, nodemask_t *nodes_allowed,
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
@@ -2295,7 +2316,6 @@ static unsigned long set_max_huge_pages(struct hstate *h, unsigned long count,
 	 * pool might be one hugepage larger than it needs to be, but
 	 * within all the constraints specified by the sysctls.
 	 */
-	spin_lock(&hugetlb_lock);
 	while (h->surplus_huge_pages && count > persistent_huge_pages(h)) {
 		if (!adjust_pool_surplus(h, nodes_allowed, -1))
 			break;
@@ -2350,9 +2370,10 @@ static unsigned long set_max_huge_pages(struct hstate *h, unsigned long count,
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
@@ -2404,11 +2425,6 @@ static ssize_t __nr_hugepages_store_common(bool obey_mempolicy,
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
@@ -2428,15 +2444,12 @@ static ssize_t __nr_hugepages_store_common(bool obey_mempolicy,
 	} else
 		nodes_allowed = &node_states[N_MEMORY];
 
-	h->max_huge_pages = set_max_huge_pages(h, count, nodes_allowed);
+	err = set_max_huge_pages(h, count, nodes_allowed);
 
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
index ac9c45ffb344..a4547d90fa7a 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -8234,8 +8234,9 @@ int alloc_contig_range(unsigned long start, unsigned long end,
 				pfn_max_align_up(end), migratetype);
 	return ret;
 }
+#endif /* CONFIG_CONTIG_ALLOC */
 
-void free_contig_range(unsigned long pfn, unsigned nr_pages)
+void free_contig_range(unsigned long pfn, unsigned int nr_pages)
 {
 	unsigned int count = 0;
 
@@ -8247,7 +8248,6 @@ void free_contig_range(unsigned long pfn, unsigned nr_pages)
 	}
 	WARN(count != 0, "%d pages are still in use!\n", count);
 }
-#endif
 
 #ifdef CONFIG_MEMORY_HOTPLUG
 /*
-- 
2.20.1

