Return-Path: <SRS0=f00L=TH=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.7 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 23DA3C004C9
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 04:06:21 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id CC8AD206BF
	for <linux-mm@archiver.kernel.org>; Tue,  7 May 2019 04:06:20 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="g5/nHkdG"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org CC8AD206BF
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 29FCB6B0007; Tue,  7 May 2019 00:06:14 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 0841D6B000D; Tue,  7 May 2019 00:06:14 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id DC9E36B0007; Tue,  7 May 2019 00:06:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id A0DA16B000A
	for <linux-mm@kvack.org>; Tue,  7 May 2019 00:06:13 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id u1so4074566plk.10
        for <linux-mm@kvack.org>; Mon, 06 May 2019 21:06:13 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references;
        bh=RFQwlT4Xa6bVp5Em9dWQbH41T5/VxyUFyxeMfJ+yY74=;
        b=onODisxhStd1uiaclDb9RWSy6SdIqO7JwNXGcv9sTM87JuNDkZDgK1BS7frKeQmtqa
         PPoTRC9pgxmJasU0l6cG77jBNNGvo34IJaHOWtyzrWyK/Bz4rA9MQUPfyRER5OulZNzn
         Lo9nbTQo54ZgxRHkVzKpWhTQUfmhV4M1y3zFni8bP8ZNFpEtB5lSWT8RW6h2EvYkpumM
         BOkDn9MTadOk0GOiRVoTJdSr8duuUOKPYNw9h39it/DZ+EECFkIJI5Q/UrpxQ2bq+NHz
         PPG4sYeVV7kvUCl7gwFMSdkEwHydZhu08VpiHXWvl6DM7FJfBg/8ECqWkxXh6AAsWscv
         /E9Q==
X-Gm-Message-State: APjAAAVPNW8e31FWIKlcQE/yDHnPBvQXR8+zh+R26Jw9lC+ZXkRLva+N
	tN5DUuVJ3KYR+av7RLmOm1RSKtvfchLURTcxkvABq6WK+gYiHjsQcQNxxMZAwASKtNncqXoSEG4
	X5rNztdj4Zuu1aGGYpDC1fpElzJdsNsp9O1GvQwqsrITAlZRa9ocBoCjcHV+9CpduyA==
X-Received: by 2002:a17:902:e393:: with SMTP id ch19mr12826983plb.300.1557201973283;
        Mon, 06 May 2019 21:06:13 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzxV2X6zBXWU+dnBvkqCf4zQ7ePBwnhkhnUivNXPP4xq5lUPMnUngIXGtQITmZEmr4TKmz2
X-Received: by 2002:a17:902:e393:: with SMTP id ch19mr12826869plb.300.1557201971980;
        Mon, 06 May 2019 21:06:11 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557201971; cv=none;
        d=google.com; s=arc-20160816;
        b=CpObM1Oc1gq0ZfdalFAmOtZ9iPpYoY1o2lboKw4GTNJ7BtDcH8ok62LZ2RJzkkKDKs
         HXWP2m3mQAgCUHvf1jrF3WmFPHFhsMryLih0Mowj1COXlNOWPRu3kWhE6+aaUH0QgW0D
         KHxIEr1qWuQxcPvyOxC20E7KWiQ6z6sHubDOlTfiVoywhb61GIK/aJFacdLXdNMy4yDN
         a6PyuxlRxW6OKJ1IJ0vGAir+spB5jiXuJSJ4BT36UegCJZp/QZ7DDDfBjcwdlKzMAZOe
         TgNIq97QfokfZg9qEgTcx6E9zErVOCGwweq0lL4ND9KRDrHZ4aAHBaZlzTo9V5SOqxA/
         pO2w==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=references:in-reply-to:message-id:date:subject:cc:to:from
         :dkim-signature;
        bh=RFQwlT4Xa6bVp5Em9dWQbH41T5/VxyUFyxeMfJ+yY74=;
        b=NCJ5jKqvjis28osR1tJRZ1hhPWh6+TirPHqTAhDJe9ZxoAafixOO1wLdhM5vB2vj5w
         gM5USx95WezxqzOXqhEKH/x6ncKMRNbcjpNHAYA1OZSuJs6yGCW7Nct36aqQ41u+6eiJ
         mVw9KqCxAeSMB7FODTRnSUACG0m6hEV9dtfR1fKjSHqDP8Sx516PyM/Bf0RCzSFaHxi9
         8kgpJcr+o2vzbDszqq8m+D+c4QeV3xGt8XUg2snSw69HK52OoUl5FiHAj+Ma7C0B+28E
         bWY42D21d2dTX/eFeTTK+iwDkfQI1JkYaGB1kVoOgrRXli71e4WeaDQOM6LONC5HIt89
         bV5A==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b="g5/nHkdG";
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id l73si11346748pfb.126.2019.05.06.21.06.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 06 May 2019 21:06:11 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b="g5/nHkdG";
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=References:In-Reply-To:Message-Id:
	Date:Subject:Cc:To:From:Sender:Reply-To:MIME-Version:Content-Type:
	Content-Transfer-Encoding:Content-ID:Content-Description:Resent-Date:
	Resent-From:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:
	List-Help:List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	 bh=RFQwlT4Xa6bVp5Em9dWQbH41T5/VxyUFyxeMfJ+yY74=; b=g5/nHkdGHC8OTftVlVKefRLlU
	OnEWB6pY56N3h09dNgqy2QYIKK5JrHDSnTun/Wah9Gs7q+XUN5B51SOntlAQPR9pGy9n9c4xdjYxI
	kjyGiANdj50P6cWGZ6vm4LFxo9/acEqiqiAmsCwYRtdVKMcsRQhg+K6Q/+yJZppJbAZ79t+oxbr2L
	OibP6CbRQdxGMzsJu8B2NcLmgIGwI7EX436U71frF7i64r6foEf+az+vcPAfdNZYvK1g88JKSMVG9
	mO0UywPgV3hzHqaHCc7ndgtzVtQ4vnKH3QC6x8EfUYTlluRkuHT1kQ2Um+b1h0eG2fOllcbkDGqJb
	sq0ReUOCQ==;
Received: from willy by bombadil.infradead.org with local (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hNrMp-0005hr-Fa; Tue, 07 May 2019 04:06:11 +0000
From: Matthew Wilcox <willy@infradead.org>
To: linux-mm@kvack.org
Cc: "Matthew Wilcox (Oracle)" <willy@infradead.org>
Subject: [PATCH 03/11] mm: Pass order to __get_free_pages() in GFP flags
Date: Mon,  6 May 2019 21:06:01 -0700
Message-Id: <20190507040609.21746-4-willy@infradead.org>
X-Mailer: git-send-email 2.14.5
In-Reply-To: <20190507040609.21746-1-willy@infradead.org>
References: <20190507040609.21746-1-willy@infradead.org>
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: "Matthew Wilcox (Oracle)" <willy@infradead.org>

Matches the change to the __alloc_pages_nodemask API.

Signed-off-by: Matthew Wilcox (Oracle) <willy@infradead.org>
---
 arch/x86/mm/init.c    | 3 ++-
 arch/x86/mm/pgtable.c | 7 ++++---
 drivers/base/devres.c | 2 +-
 include/linux/gfp.h   | 6 +++---
 mm/mmu_gather.c       | 2 +-
 mm/page_alloc.c       | 8 ++++----
 6 files changed, 15 insertions(+), 13 deletions(-)

diff --git a/arch/x86/mm/init.c b/arch/x86/mm/init.c
index f905a2371080..963f30581291 100644
--- a/arch/x86/mm/init.c
+++ b/arch/x86/mm/init.c
@@ -94,7 +94,8 @@ __ref void *alloc_low_pages(unsigned int num)
 		unsigned int order;
 
 		order = get_order((unsigned long)num << PAGE_SHIFT);
-		return (void *)__get_free_pages(GFP_ATOMIC | __GFP_ZERO, order);
+		return (void *)__get_free_pages(GFP_ATOMIC | __GFP_ZERO |
+				__GFP_ORDER(order));
 	}
 
 	if ((pgt_buf_end + num) > pgt_buf_top || !can_use_brk_pgt) {
diff --git a/arch/x86/mm/pgtable.c b/arch/x86/mm/pgtable.c
index 7bd01709a091..3d3d13f859e5 100644
--- a/arch/x86/mm/pgtable.c
+++ b/arch/x86/mm/pgtable.c
@@ -401,8 +401,8 @@ static inline pgd_t *_pgd_alloc(void)
 	 * We allocate one page for pgd.
 	 */
 	if (!SHARED_KERNEL_PMD)
-		return (pgd_t *)__get_free_pages(PGALLOC_GFP,
-						 PGD_ALLOCATION_ORDER);
+		return (pgd_t *)__get_free_pages(PGALLOC_GFP |
+					__GFP_ORDER(PGD_ALLOCATION_ORDER));
 
 	/*
 	 * Now PAE kernel is not running as a Xen domain. We can allocate
@@ -422,7 +422,8 @@ static inline void _pgd_free(pgd_t *pgd)
 
 static inline pgd_t *_pgd_alloc(void)
 {
-	return (pgd_t *)__get_free_pages(PGALLOC_GFP, PGD_ALLOCATION_ORDER);
+	return (pgd_t *)__get_free_pages(PGALLOC_GFP |
+					 __GFP_ORDER(PGD_ALLOCATION_ORDER));
 }
 
 static inline void _pgd_free(pgd_t *pgd)
diff --git a/drivers/base/devres.c b/drivers/base/devres.c
index e038e2b3b7ea..572e81282285 100644
--- a/drivers/base/devres.c
+++ b/drivers/base/devres.c
@@ -992,7 +992,7 @@ unsigned long devm_get_free_pages(struct device *dev,
 	struct pages_devres *devres;
 	unsigned long addr;
 
-	addr = __get_free_pages(gfp_mask, order);
+	addr = __get_free_pages(gfp_mask | __GFP_ORDER(order));
 
 	if (unlikely(!addr))
 		return 0;
diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index e7845c2510db..23fbd6da1fb6 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -536,7 +536,7 @@ extern struct page *alloc_pages_vma(gfp_t gfp_mask, struct vm_area_struct *vma,
 #define alloc_page_vma_node(gfp_mask, vma, addr, node)		\
 	alloc_pages_vma(gfp_mask, vma, addr, node, false)
 
-extern unsigned long __get_free_pages(gfp_t gfp_mask, unsigned int order);
+extern unsigned long __get_free_pages(gfp_t gfp_mask);
 extern unsigned long get_zeroed_page(gfp_t gfp_mask);
 
 void *alloc_pages_exact(size_t size, gfp_t gfp_mask);
@@ -544,10 +544,10 @@ void free_pages_exact(void *virt, size_t size);
 void * __meminit alloc_pages_exact_nid(int nid, size_t size, gfp_t gfp_mask);
 
 #define __get_free_page(gfp_mask) \
-		__get_free_pages((gfp_mask), 0)
+		__get_free_pages(gfp_mask)
 
 #define __get_dma_pages(gfp_mask, order) \
-		__get_free_pages((gfp_mask) | GFP_DMA, (order))
+		__get_free_pages((gfp_mask) | GFP_DMA | __GFP_ORDER(order))
 
 extern void __free_pages(struct page *page, unsigned int order);
 extern void free_pages(unsigned long addr, unsigned int order);
diff --git a/mm/mmu_gather.c b/mm/mmu_gather.c
index f2f03c655807..d370621c8c5d 100644
--- a/mm/mmu_gather.c
+++ b/mm/mmu_gather.c
@@ -26,7 +26,7 @@ static bool tlb_next_batch(struct mmu_gather *tlb)
 	if (tlb->batch_count == MAX_GATHER_BATCH_COUNT)
 		return false;
 
-	batch = (void *)__get_free_pages(GFP_NOWAIT | __GFP_NOWARN, 0);
+	batch = (void *)__get_free_page(GFP_NOWAIT | __GFP_NOWARN);
 	if (!batch)
 		return false;
 
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 13191fe2f19d..e26536825a0b 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -4681,11 +4681,11 @@ EXPORT_SYMBOL(__alloc_pages_nodemask);
  * address cannot represent highmem pages. Use alloc_pages and then kmap if
  * you need to access high mem.
  */
-unsigned long __get_free_pages(gfp_t gfp_mask, unsigned int order)
+unsigned long __get_free_pages(gfp_t gfp_mask)
 {
 	struct page *page;
 
-	page = alloc_pages(gfp_mask & ~__GFP_HIGHMEM, order);
+	page = __alloc_pages(gfp_mask & ~__GFP_HIGHMEM, numa_mem_id());
 	if (!page)
 		return 0;
 	return (unsigned long) page_address(page);
@@ -4694,7 +4694,7 @@ EXPORT_SYMBOL(__get_free_pages);
 
 unsigned long get_zeroed_page(gfp_t gfp_mask)
 {
-	return __get_free_pages(gfp_mask | __GFP_ZERO, 0);
+	return __get_free_page(gfp_mask | __GFP_ZERO);
 }
 EXPORT_SYMBOL(get_zeroed_page);
 
@@ -4869,7 +4869,7 @@ void *alloc_pages_exact(size_t size, gfp_t gfp_mask)
 	if (WARN_ON_ONCE(gfp_mask & __GFP_COMP))
 		gfp_mask &= ~__GFP_COMP;
 
-	addr = __get_free_pages(gfp_mask, order);
+	addr = __get_free_pages(gfp_mask | __GFP_ORDER(order));
 	return make_alloc_exact(addr, order, size);
 }
 EXPORT_SYMBOL(alloc_pages_exact);
-- 
2.20.1

