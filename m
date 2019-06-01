Return-Path: <SRS0=MiGm=UA=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id EC758C28CC3
	for <linux-mm@archiver.kernel.org>; Sat,  1 Jun 2019 07:51:27 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 9A54C27176
	for <linux-mm@archiver.kernel.org>; Sat,  1 Jun 2019 07:51:27 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="uhSG68q8"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 9A54C27176
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 309016B027D; Sat,  1 Jun 2019 03:51:15 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 2B9426B0280; Sat,  1 Jun 2019 03:51:15 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 1854E6B0281; Sat,  1 Jun 2019 03:51:15 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id CBD4A6B027D
	for <linux-mm@kvack.org>; Sat,  1 Jun 2019 03:51:14 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id q6so5433811pll.22
        for <linux-mm@kvack.org>; Sat, 01 Jun 2019 00:51:14 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=QLcekuKrvOI4dWVXNCuVhJniXqHoxP9REgAQe9/06L0=;
        b=INuGQXk4jLJ8qU/iyrId78SqoSuCU3ATwW02qKHf90Ry5QQc9mUq0i5qMxxW1BhGlb
         aavTB7z5V/vMgWmVht3vQd5ex6dY1VfR6If5MUSqgqKotINg79+hkRR1bH+mnsFWk9hj
         S255vj6LwFxMYnrpvTuowxk2hrPyZhdyz/+H7etFJ4Wf4c3AogHsyjipIogwAzryDIW3
         pTCU5pVqyCpB43uTcHRBIJeIWY47Bxx9XbvVVJAD9bBpjC5gTr39qnKMyrDnMHsel7HQ
         le3NpesxANRwmGQhPtQYoq69BQijzgPogiMHw1FmUsE66JyN6a3090VLoMmPAoPdBdLX
         b1VA==
X-Gm-Message-State: APjAAAXpPj/e5dMOIgnOm+1feSzAAnS9Rgte5XDFiuPxGObLKCUnEee2
	0f+ViTOVHnn1KWoZxHSYC6kkLedSbX7LFO9XXmBCf2DswoA2CmwUyaWAeGbIFouWSaaIcDwQGiR
	MsRbul4IfC3qwcgmu/fjKhjRJQ2ag+/FQ2IHGJwGHrUjeHEdC3/VsNMBTV2q7u5U=
X-Received: by 2002:a17:902:7003:: with SMTP id y3mr14462432plk.70.1559375474467;
        Sat, 01 Jun 2019 00:51:14 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyEV6mcXnxTPW05m3T93M1/ycZ/FSSddVVhXD+MlT8DvE5L89ZzU10+bYwl3f7V1NaiC46Z
X-Received: by 2002:a17:902:7003:: with SMTP id y3mr14462388plk.70.1559375473583;
        Sat, 01 Jun 2019 00:51:13 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1559375473; cv=none;
        d=google.com; s=arc-20160816;
        b=n9gRh8ABh3dnmE9RnW10ypbJZaEq330dKcUhrP0/PRiCK8v027BdYexoCruKcCr32a
         mOAIVEIvPDHDkXVZLtTdf4gESPp3lB1GIiy7JXJNMXaethYueCpMfVe36OYwzSM0E6SZ
         MPJpCuMVTCcTMvTJYaJ9FbAXmb2+dtkmJSDl4YhueYqhx/zG2Oi69RE801YTlGjXP2FT
         w5L/ylxna9BDgFT+gBOqQnSDveuuqL5AWYYNG/bvKxuZAuLECERXneUQTpGbfWeA7Cw2
         /iQg/hMRXzFkCocBm23FBBQMpFdI70UT1uwTeiq2lK7QBngqpmBJ7h4gSc9GtRF0bxHF
         Kbog==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=QLcekuKrvOI4dWVXNCuVhJniXqHoxP9REgAQe9/06L0=;
        b=JSh7JP9saMX/X0eDULBUy9FZ9tnq51Bgppibnl1YOACmPoStJMG3GLOB2vWmhDwZzy
         LbJejiK67jJYoAeyNMuznR47kjxhgkGHlsYuBFXD9+oRFqHRwn5nTCOEXl9ASHSN6IjZ
         NyPVSFCYXSZ9L8iqu+8bipmCU4Lt0FhCwSbiicakrZnfwJa1ScqiQMykoj4LZGco7urz
         HDYsGJcIsKRSE1h151p94kytwvzOK1+v+RyZihcMi1KW+AyZKRzbN21a7DZJ8O8m0G1O
         9ISJDJiC1ZnLaVzVMrIszmeglnzwXEWS/ap2yzIhIIv8M7LppZNR3NHhd0mf5RIb8c1E
         oeEA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=uhSG68q8;
       spf=pass (google.com: best guess record for domain of batv+47bfdebe920718d2a071+5760+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+47bfdebe920718d2a071+5760+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id 12si3218705pfi.213.2019.06.01.00.51.13
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sat, 01 Jun 2019 00:51:13 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+47bfdebe920718d2a071+5760+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=uhSG68q8;
       spf=pass (google.com: best guess record for domain of batv+47bfdebe920718d2a071+5760+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+47bfdebe920718d2a071+5760+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=QLcekuKrvOI4dWVXNCuVhJniXqHoxP9REgAQe9/06L0=; b=uhSG68q8OhBN4rQ9TINYT+2WPP
	g8PywO2smdNlf80VMfpmdvNndfBRIs9vrNH2dnkNXyDJYZD82r3apjxyHGT0wtlzs+mr9gE9clc/U
	eUdAzXGd6OpEWix0e6G8QQUBNn26YJ7x9OBKzLLcY3XbVCqxraRLD39b4MQqnJ6xWuo3dmylNM6Bi
	HtpkTUeZh6Xan3Ciiw91K0eoEXlZLlI9X/dJOsqYPXb6klqTght0D+2c7AfYOu8z/yDuO3b4oVF9k
	fpEi1421seOuX0irCDasaXYfPwIdSmf5uFHU9z7H17mkv60tjc3isHNpZqLdW05EcpOxd+o24PC+S
	eJxJiqKw==;
Received: from 217-76-161-89.static.highway.a1.net ([217.76.161.89] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hWyn4-0007qX-Gh; Sat, 01 Jun 2019 07:50:59 +0000
From: Christoph Hellwig <hch@lst.de>
To: Linus Torvalds <torvalds@linux-foundation.org>,
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
Date: Sat,  1 Jun 2019 09:49:57 +0200
Message-Id: <20190601074959.14036-15-hch@lst.de>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190601074959.14036-1-hch@lst.de>
References: <20190601074959.14036-1-hch@lst.de>
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
index 53b50c63ba51..e03c7e6b1422 100644
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

