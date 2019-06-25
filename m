Return-Path: <SRS0=nbyn=UY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 24A35C48BD7
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 14:38:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id C44982146E
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 14:38:35 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="Voixl5wJ"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org C44982146E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 7681C8E000F; Tue, 25 Jun 2019 10:38:18 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 6CA218E000B; Tue, 25 Jun 2019 10:38:18 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 543098E000F; Tue, 25 Jun 2019 10:38:18 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 152648E000B
	for <linux-mm@kvack.org>; Tue, 25 Jun 2019 10:38:18 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id z35so8259075pgl.17
        for <linux-mm@kvack.org>; Tue, 25 Jun 2019 07:38:18 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=nhYNp2rhSSMYWrdeYfaQg9xtCg/tCYGSAHXqYjk4fcU=;
        b=s0e7+lZbntH1YK4Q26GZmaKSvE+P0kGtCF3ipvhyuRv18t6K2bzsxAzvl9RZf0m6fl
         b/BfsqF0cPHJ0KHry/rIScjSkY4qlHM1ERaoSy7IjJhNR5hgSZWg/tvqxKLIZp1E/YAz
         mWkbx2hrk+qJH1CNnHE/P8apZdklcs3Bg+B9jxQxMCOy86Ezmkn6+g4eFPdOlS1Fvpvr
         bX/6vAxAmOAZm22o5HF+R31HwybTVvoB68hQ0e1/cnTpI+mfCa9aVp3kG1MnzxWFAi50
         e5fChNmvp3YVYASyaiu2Vqsqhc+eZm6jlPZnftUSbeL5Ncez//UeJIncu1Vw8bk8VBRi
         BxmA==
X-Gm-Message-State: APjAAAXyJCMMyLj4+xicPSHAbO/jvXwdj1Xv3a2t2ehhIqp1gg1rqcpB
	i6lhnt3G+UKtd+URTVBi0fgBk8p7tanzNaDxTmi8d9WO76OyIWjjFECwf84mZwbBHNZYkQe0Lpj
	wo1t1ksGcyIKNHFxKFc1T/MgaISwJK47CfYfJCeiGZYDcr18E4CfwT2ZvbhNQDJE=
X-Received: by 2002:a17:902:30a3:: with SMTP id v32mr156644815plb.6.1561473497755;
        Tue, 25 Jun 2019 07:38:17 -0700 (PDT)
X-Google-Smtp-Source: APXvYqx9BaVhAdl2opK9oMYkJxlAXtJIg/Hu2hkHVDbaCI41tauMrO0CHoP4JH1avn+0pPh881bo
X-Received: by 2002:a17:902:30a3:: with SMTP id v32mr156644721plb.6.1561473496848;
        Tue, 25 Jun 2019 07:38:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561473496; cv=none;
        d=google.com; s=arc-20160816;
        b=FaNcc2OpqK1RMr8SZ7wsmHYnL+duWhnhyPSK28ZLF5n6lt6lRMHvDcDIUBzUp3Ryad
         BTp3NNDn1zWrtqhWXqUmg7KRl8LtHLDjn42cvcqcdR/M3Ahg2A1hp0Vtd9sVMfMd8Y/L
         lXIC4D461IF8Pvl8xr38FXPd9huMS0YSXttDBfJ6MjV2qPwJ8E/UmAAQ93Cp5bxx8qJH
         HqHWQ1A784iAowwZD+OBc0JEt5mus/RY/yXyZ2l/uILMYNq+T5BASdQTVBNQdVRw4Tr+
         UxKgOwV/wBbTR4lqAUXBDBs4lMJwknHhzazwWmqBZjqlmO8bCUK4TvlC5dVpBG2ghfFm
         RtBQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=nhYNp2rhSSMYWrdeYfaQg9xtCg/tCYGSAHXqYjk4fcU=;
        b=qCZZV5BEdTvX6dx9c6ZTN1cZevXD4Hbtuuoso+VK9R9ZK/P68GAdVAtAfA2fkaQ0eX
         +BsZ9ttYbc20D1mVbNRcMDLEKkZuW2YEvtz+u3uhlvfXd57LNZmECeLa2gsgc9YrdUim
         XsaEV1RDdrpLEJnaA4R44vwJsz7bxR4xYa2IfGdkLk6iXlP1iseTBo5YlWa9zkfLGLOS
         VQfdIJiBLRoj2CvMA6QMupJ04GzvGyhTMKqmMZBYnu6XBZcrwo8t6fnDZH5el2jYIPQn
         zFzh06L/48EmyN6wSiCEP9TOtvuXwlY1IpfR7sTEMJFunG1Nevopcc/5O9w7gV6IcYQH
         PhcQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=Voixl5wJ;
       spf=pass (google.com: best guess record for domain of batv+c5155a46dc30cc8634d8+5784+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+c5155a46dc30cc8634d8+5784+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id k4si12596551pgq.293.2019.06.25.07.38.16
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 25 Jun 2019 07:38:16 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+c5155a46dc30cc8634d8+5784+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=Voixl5wJ;
       spf=pass (google.com: best guess record for domain of batv+c5155a46dc30cc8634d8+5784+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+c5155a46dc30cc8634d8+5784+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=nhYNp2rhSSMYWrdeYfaQg9xtCg/tCYGSAHXqYjk4fcU=; b=Voixl5wJryX6fnOcp1CrbyiJxt
	svVwJ6IVf1Zg9nS0a8eQaOFx2NiEThIjQNDbCBJfjtCBqp69jRTpmqtm47ZfIM/ml/dreqYANF5Km
	CiiFPYBjHfbc1h+Wh1MG6O6XayGPhs8aR3X2t+eks1uA8MAaK2irFJkU4/p/AU22qh5JYOhiO41sp
	OSis/Ri1OoSLC3Ze5PeoJ7a1d3oj/RgEkuVs02sYa4KCLru/bHe1zpvH5jWqWoMrHBV1Ht8p8em7c
	u/QvzbfzbAONII0CN0vqJMYUA9EKSmd1YW6p22xcI55o3GRvVKUTxyJIh1BNF3T6Wxroel8kNaPlM
	4pr+FgJA==;
Received: from 213-225-6-159.nat.highway.a1.net ([213.225.6.159] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hfmaB-00086r-Ed; Tue, 25 Jun 2019 14:38:04 +0000
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
	linux-kernel@vger.kernel.org
Subject: [PATCH 14/16] mm: move the powerpc hugepd code to mm/gup.c
Date: Tue, 25 Jun 2019 16:37:13 +0200
Message-Id: <20190625143715.1689-15-hch@lst.de>
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

While only powerpc supports the hugepd case, the code is pretty
generic and I'd like to keep all GUP internals in one place.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 arch/powerpc/Kconfig          |  1 +
 arch/powerpc/mm/hugetlbpage.c | 72 ------------------------------
 include/linux/hugetlb.h       | 18 --------
 mm/Kconfig                    | 10 +++++
 mm/gup.c                      | 82 +++++++++++++++++++++++++++++++++++
 5 files changed, 93 insertions(+), 90 deletions(-)

diff --git a/arch/powerpc/Kconfig b/arch/powerpc/Kconfig
index 992a04796e56..4f1b00979cde 100644
--- a/arch/powerpc/Kconfig
+++ b/arch/powerpc/Kconfig
@@ -125,6 +125,7 @@ config PPC
 	select ARCH_HAS_FORTIFY_SOURCE
 	select ARCH_HAS_GCOV_PROFILE_ALL
 	select ARCH_HAS_KCOV
+	select ARCH_HAS_HUGEPD			if HUGETLB_PAGE
 	select ARCH_HAS_MMIOWB			if PPC64
 	select ARCH_HAS_PHYS_TO_DMA
 	select ARCH_HAS_PMEM_API                if PPC64
diff --git a/arch/powerpc/mm/hugetlbpage.c b/arch/powerpc/mm/hugetlbpage.c
index b5d92dc32844..51716c11d0fb 100644
--- a/arch/powerpc/mm/hugetlbpage.c
+++ b/arch/powerpc/mm/hugetlbpage.c
@@ -511,13 +511,6 @@ struct page *follow_huge_pd(struct vm_area_struct *vma,
 	return page;
 }
 
-static unsigned long hugepte_addr_end(unsigned long addr, unsigned long end,
-				      unsigned long sz)
-{
-	unsigned long __boundary = (addr + sz) & ~(sz-1);
-	return (__boundary - 1 < end - 1) ? __boundary : end;
-}
-
 #ifdef CONFIG_PPC_MM_SLICES
 unsigned long hugetlb_get_unmapped_area(struct file *file, unsigned long addr,
 					unsigned long len, unsigned long pgoff,
@@ -665,68 +658,3 @@ void flush_dcache_icache_hugepage(struct page *page)
 		}
 	}
 }
-
-static int gup_hugepte(pte_t *ptep, unsigned long sz, unsigned long addr,
-		       unsigned long end, int write, struct page **pages, int *nr)
-{
-	unsigned long pte_end;
-	struct page *head, *page;
-	pte_t pte;
-	int refs;
-
-	pte_end = (addr + sz) & ~(sz-1);
-	if (pte_end < end)
-		end = pte_end;
-
-	pte = READ_ONCE(*ptep);
-
-	if (!pte_access_permitted(pte, write))
-		return 0;
-
-	/* hugepages are never "special" */
-	VM_BUG_ON(!pfn_valid(pte_pfn(pte)));
-
-	refs = 0;
-	head = pte_page(pte);
-
-	page = head + ((addr & (sz-1)) >> PAGE_SHIFT);
-	do {
-		VM_BUG_ON(compound_head(page) != head);
-		pages[*nr] = page;
-		(*nr)++;
-		page++;
-		refs++;
-	} while (addr += PAGE_SIZE, addr != end);
-
-	if (!page_cache_add_speculative(head, refs)) {
-		*nr -= refs;
-		return 0;
-	}
-
-	if (unlikely(pte_val(pte) != pte_val(*ptep))) {
-		/* Could be optimized better */
-		*nr -= refs;
-		while (refs--)
-			put_page(head);
-		return 0;
-	}
-
-	return 1;
-}
-
-int gup_huge_pd(hugepd_t hugepd, unsigned long addr, unsigned int pdshift,
-		unsigned long end, int write, struct page **pages, int *nr)
-{
-	pte_t *ptep;
-	unsigned long sz = 1UL << hugepd_shift(hugepd);
-	unsigned long next;
-
-	ptep = hugepte_offset(hugepd, addr, pdshift);
-	do {
-		next = hugepte_addr_end(addr, end, sz);
-		if (!gup_hugepte(ptep, sz, addr, end, write, pages, nr))
-			return 0;
-	} while (ptep++, addr = next, addr != end);
-
-	return 1;
-}
diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
index edf476c8cfb9..0f91761e2c53 100644
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -16,29 +16,11 @@ struct user_struct;
 struct mmu_gather;
 
 #ifndef is_hugepd
-/*
- * Some architectures requires a hugepage directory format that is
- * required to support multiple hugepage sizes. For example
- * a4fe3ce76 "powerpc/mm: Allow more flexible layouts for hugepage pagetables"
- * introduced the same on powerpc. This allows for a more flexible hugepage
- * pagetable layout.
- */
 typedef struct { unsigned long pd; } hugepd_t;
 #define is_hugepd(hugepd) (0)
 #define __hugepd(x) ((hugepd_t) { (x) })
-static inline int gup_huge_pd(hugepd_t hugepd, unsigned long addr,
-			      unsigned pdshift, unsigned long end,
-			      int write, struct page **pages, int *nr)
-{
-	return 0;
-}
-#else
-extern int gup_huge_pd(hugepd_t hugepd, unsigned long addr,
-		       unsigned pdshift, unsigned long end,
-		       int write, struct page **pages, int *nr);
 #endif
 
-
 #ifdef CONFIG_HUGETLB_PAGE
 
 #include <linux/mempolicy.h>
diff --git a/mm/Kconfig b/mm/Kconfig
index 5c41409557da..44be3f01a2b2 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -769,4 +769,14 @@ config GUP_GET_PTE_LOW_HIGH
 config ARCH_HAS_PTE_SPECIAL
 	bool
 
+#
+# Some architectures require a special hugepage directory format that is
+# required to support multiple hugepage sizes. For example a4fe3ce76
+# "powerpc/mm: Allow more flexible layouts for hugepage pagetables"
+# introduced it on powerpc.  This allows for a more flexible hugepage
+# pagetable layouts.
+#
+config ARCH_HAS_HUGEPD
+	bool
+
 endmenu
diff --git a/mm/gup.c b/mm/gup.c
index 37a2083b1ed8..7077549bc8ea 100644
--- a/mm/gup.c
+++ b/mm/gup.c
@@ -1966,6 +1966,88 @@ static int __gup_device_huge_pud(pud_t pud, pud_t *pudp, unsigned long addr,
 }
 #endif
 
+#ifdef CONFIG_ARCH_HAS_HUGEPD
+static unsigned long hugepte_addr_end(unsigned long addr, unsigned long end,
+				      unsigned long sz)
+{
+	unsigned long __boundary = (addr + sz) & ~(sz-1);
+	return (__boundary - 1 < end - 1) ? __boundary : end;
+}
+
+static int gup_hugepte(pte_t *ptep, unsigned long sz, unsigned long addr,
+		       unsigned long end, int write, struct page **pages, int *nr)
+{
+	unsigned long pte_end;
+	struct page *head, *page;
+	pte_t pte;
+	int refs;
+
+	pte_end = (addr + sz) & ~(sz-1);
+	if (pte_end < end)
+		end = pte_end;
+
+	pte = READ_ONCE(*ptep);
+
+	if (!pte_access_permitted(pte, write))
+		return 0;
+
+	/* hugepages are never "special" */
+	VM_BUG_ON(!pfn_valid(pte_pfn(pte)));
+
+	refs = 0;
+	head = pte_page(pte);
+
+	page = head + ((addr & (sz-1)) >> PAGE_SHIFT);
+	do {
+		VM_BUG_ON(compound_head(page) != head);
+		pages[*nr] = page;
+		(*nr)++;
+		page++;
+		refs++;
+	} while (addr += PAGE_SIZE, addr != end);
+
+	if (!page_cache_add_speculative(head, refs)) {
+		*nr -= refs;
+		return 0;
+	}
+
+	if (unlikely(pte_val(pte) != pte_val(*ptep))) {
+		/* Could be optimized better */
+		*nr -= refs;
+		while (refs--)
+			put_page(head);
+		return 0;
+	}
+
+	return 1;
+}
+
+static int gup_huge_pd(hugepd_t hugepd, unsigned long addr,
+		unsigned int pdshift, unsigned long end, int write,
+		struct page **pages, int *nr)
+{
+	pte_t *ptep;
+	unsigned long sz = 1UL << hugepd_shift(hugepd);
+	unsigned long next;
+
+	ptep = hugepte_offset(hugepd, addr, pdshift);
+	do {
+		next = hugepte_addr_end(addr, end, sz);
+		if (!gup_hugepte(ptep, sz, addr, end, write, pages, nr))
+			return 0;
+	} while (ptep++, addr = next, addr != end);
+
+	return 1;
+}
+#else
+static inline int gup_huge_pd(hugepd_t hugepd, unsigned long addr,
+		unsigned pdshift, unsigned long end, int write,
+		struct page **pages, int *nr)
+{
+	return 0;
+}
+#endif /* CONFIG_ARCH_HAS_HUGEPD */
+
 static int gup_huge_pmd(pmd_t orig, pmd_t *pmdp, unsigned long addr,
 		unsigned long end, unsigned int flags, struct page **pages, int *nr)
 {
-- 
2.20.1

