Return-Path: <SRS0=Z+ZU=Q2=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SIGNED_OFF_BY,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AACFBC43381
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 10:33:00 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5BDA720818
	for <linux-mm@archiver.kernel.org>; Tue, 19 Feb 2019 10:33:00 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="Dott+BC9"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5BDA720818
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 049228E0002; Tue, 19 Feb 2019 05:32:58 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id EF4518E0007; Tue, 19 Feb 2019 05:32:57 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id B9A0A8E0004; Tue, 19 Feb 2019 05:32:57 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 63D648E0002
	for <linux-mm@kvack.org>; Tue, 19 Feb 2019 05:32:57 -0500 (EST)
Received: by mail-pg1-f200.google.com with SMTP id 11so10682629pgd.19
        for <linux-mm@kvack.org>; Tue, 19 Feb 2019 02:32:57 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:message-id:user-agent:date:from
         :to:cc:subject:references:mime-version;
        bh=d6CMV2hoQm5MnywciM5LER++5NYy5jN9jsJ9wqpDUgs=;
        b=tbLyLTNrEyJbM+cf7jf88JYwjydBdyVnG+Ux2RzcAsR4cM99m620taf8K0V90NAktR
         Xwytp7oExu3ToIX3qrzrZASCbH/tNGhaTcYHiB676qQav0aiXXHoy0QpqNHG6b6svkRa
         5t/4gDRWl6gvkioUCXiZvIbZTylP3ruwsv4tAItY+7VkUMDeEWyTFMlL9j7uQiKww0C3
         T4rB/X7oklOT56VKdGufHOdrmiNeis38Gn3z6KqdZHJ9pzT3Y2Z4NbukwFXZmVHxDh+/
         cHaCneLdmAKtfcBHD5sCtCjmWPcOfhgKok2uXkLdMk2U4j0HcUyMWmJX4VRloEvajEIA
         TfVA==
X-Gm-Message-State: AHQUAubjJs3DpjUKvw379lJepdEvOIU3gYmHNkFibr//EhKmmiLIlTHt
	ICHSz33YBdUHmMxzcoyCsLmQcjYskt+hp7FflnfyyxjwVSni51V506DpSPjHKub8AOcO3CCJGXL
	+8B46QlnBKinI2t5YhT12tMespt2JzlD0JseoR9e0Hsk3XqVGM+HOxG7z0QCDHx6ScQ==
X-Received: by 2002:a63:d413:: with SMTP id a19mr23039918pgh.199.1550572377029;
        Tue, 19 Feb 2019 02:32:57 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbUaFz5tAud2aT6PwrsAVYfV0Dr0iGRwf9d0GSrprx01QiSj1qG7etxkoluXt6eRkegPo0p
X-Received: by 2002:a63:d413:: with SMTP id a19mr23039860pgh.199.1550572376203;
        Tue, 19 Feb 2019 02:32:56 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1550572376; cv=none;
        d=google.com; s=arc-20160816;
        b=YH4Z3K27ovz043HxtUhToVxRFcV864+FWk8vrD6l1rCWwHnKF9NCgWCZSWLBLWJsNY
         SGXlROrh7jCZmS/3y5GDd9fSRiky3nshxdVxJNlsW1lRTy2B+qdxwAUOlOCa5kF8VoL+
         jMNwywSKLGFQRRvfX3OeyCjCuwRC5UxYd+3UzQjUeUIvMy6ar0oZG1rLo8MF1N2EzSQQ
         WuKS5WWooHPcRBPLusyMPh02gSR0CGOCUFXutKckejlKLxq2llbQ6e4lxnPuQbXXCZiC
         Kww9bqD6zO40XIvDQ0RpxTGOXfz7pVZOQQKg6bnKXa5tqIN9MEU2BfYeFMGPgBIBqZ7Y
         SxNQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=mime-version:references:subject:cc:to:from:date:user-agent
         :message-id:dkim-signature;
        bh=d6CMV2hoQm5MnywciM5LER++5NYy5jN9jsJ9wqpDUgs=;
        b=HnqE0qsfFgnkiMGwBPHC2HKJ+4zmf3fOnkQW8npojbbTfTg5a2S6ovUty9mSIkqSxj
         Rc4/auRDKFhkfr9sjZlGMbFqWBr4ylaKjHgDp7t2frlL7r6SKvHjPpaTViS7HUpT+QEu
         KOE8zC2zYX1Nk7N4JgsB/3LuuA6xyMCxXxwdioeAFkdwl4QB4+I14guyd502mK4u8+e1
         Gt/WL7jUyTYeFLt4byP3AC07JsmOH6itsrQsFfP5vOvvkP4Geis/cOvpiWzrLafa9rWK
         ye3U5SloNPcuBjHepj5nUa5839Qg4dr9NBHbairRgvkE2TODzoYmxcL6lJELaKisCHlh
         uzQQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=Dott+BC9;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=peterz@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id b1si111862pgt.559.2019.02.19.02.32.55
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 19 Feb 2019 02:32:56 -0800 (PST)
Received-SPF: pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=Dott+BC9;
       spf=pass (google.com: best guess record for domain of peterz@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=peterz@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Type:MIME-Version:References:
	Subject:Cc:To:From:Date:Message-Id:Sender:Reply-To:Content-Transfer-Encoding:
	Content-ID:Content-Description:Resent-Date:Resent-From:Resent-Sender:
	Resent-To:Resent-Cc:Resent-Message-ID:In-Reply-To:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=d6CMV2hoQm5MnywciM5LER++5NYy5jN9jsJ9wqpDUgs=; b=Dott+BC9vmocj3ZSL9gYdJdgVe
	66SUpKrkfDQgyJ+nEIOavGswfH7k2Xm1jflWTAqPdDVu/+A06ahJOB9SY8gxPKR7beJgQdsruRuxx
	bYU6bPskXUJKMnPf+07rN0g8bYMjSVYSoTQ5GVv9k6kwBKA+Fxb0fNqJkOyHOJ49gkGJBg7J8EwY2
	rknIhm+LdjjKU9pE8avmJvJBOwB5FAEB8kvSPbLCXzsQesatdnK7lhVmkUx78vtzcVSqcOpV7/PMd
	wHfN5bgXY8N8l+WALh1F5dIOby8l3CubB0fsuVtv7davrXAZM9IwL/YrgFs692Di3Lz89AXqJSYaM
	9N7lCuHA==;
Received: from j217100.upc-j.chello.nl ([24.132.217.100] helo=hirez.programming.kicks-ass.net)
	by bombadil.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1gw2hn-0006ZP-RV; Tue, 19 Feb 2019 10:32:52 +0000
Received: by hirez.programming.kicks-ass.net (Postfix, from userid 0)
	id 677ED2852059D; Tue, 19 Feb 2019 11:32:48 +0100 (CET)
Message-Id: <20190219103233.443069009@infradead.org>
User-Agent: quilt/0.65
Date: Tue, 19 Feb 2019 11:31:58 +0100
From: Peter Zijlstra <peterz@infradead.org>
To: will.deacon@arm.com,
 aneesh.kumar@linux.vnet.ibm.com,
 akpm@linux-foundation.org,
 npiggin@gmail.com
Cc: linux-arch@vger.kernel.org,
 linux-mm@kvack.org,
 linux-kernel@vger.kernel.org,
 peterz@infradead.org,
 linux@armlinux.org.uk,
 heiko.carstens@de.ibm.com,
 riel@surriel.com,
 Yoshinori Sato <ysato@users.sourceforge.jp>,
 Rich Felker <dalias@libc.org>
Subject: [PATCH v6 10/18] sh/tlb: Convert SH to generic mmu_gather
References: <20190219103148.192029670@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

Generic mmu_gather provides everything SH needs (range tracking and
cache coherency).

Cc: Will Deacon <will.deacon@arm.com>
Cc: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Nick Piggin <npiggin@gmail.com>
Cc: Yoshinori Sato <ysato@users.sourceforge.jp>
Cc: Rich Felker <dalias@libc.org>
Signed-off-by: Peter Zijlstra (Intel) <peterz@infradead.org>
---
 arch/sh/include/asm/pgalloc.h |    7 ++
 arch/sh/include/asm/tlb.h     |  130 ------------------------------------------
 2 files changed, 8 insertions(+), 129 deletions(-)

--- a/arch/sh/include/asm/pgalloc.h
+++ b/arch/sh/include/asm/pgalloc.h
@@ -72,6 +72,15 @@ do {							\
 	tlb_remove_page((tlb), (pte));			\
 } while (0)
 
+#if CONFIG_PGTABLE_LEVELS > 2
+#define __pmd_free_tlb(tlb, pmdp, addr)			\
+do {							\
+	struct page *page = virt_to_page(pmdp);		\
+	pgtable_pmd_page_dtor(page);			\
+	tlb_remove_page((tlb), page);			\
+} while (0);
+#endif
+
 static inline void check_pgt_cache(void)
 {
 	quicklist_trim(QUICK_PT, NULL, 25, 16);
--- a/arch/sh/include/asm/tlb.h
+++ b/arch/sh/include/asm/tlb.h
@@ -11,131 +11,8 @@
 
 #ifdef CONFIG_MMU
 #include <linux/swap.h>
-#include <asm/pgalloc.h>
-#include <asm/tlbflush.h>
-#include <asm/mmu_context.h>
-
-/*
- * TLB handling.  This allows us to remove pages from the page
- * tables, and efficiently handle the TLB issues.
- */
-struct mmu_gather {
-	struct mm_struct	*mm;
-	unsigned int		fullmm;
-	unsigned long		start, end;
-};
 
-static inline void init_tlb_gather(struct mmu_gather *tlb)
-{
-	tlb->start = TASK_SIZE;
-	tlb->end = 0;
-
-	if (tlb->fullmm) {
-		tlb->start = 0;
-		tlb->end = TASK_SIZE;
-	}
-}
-
-static inline void
-arch_tlb_gather_mmu(struct mmu_gather *tlb, struct mm_struct *mm,
-		unsigned long start, unsigned long end)
-{
-	tlb->mm = mm;
-	tlb->start = start;
-	tlb->end = end;
-	tlb->fullmm = !(start | (end+1));
-
-	init_tlb_gather(tlb);
-}
-
-static inline void
-arch_tlb_finish_mmu(struct mmu_gather *tlb,
-		unsigned long start, unsigned long end, bool force)
-{
-	if (tlb->fullmm || force)
-		flush_tlb_mm(tlb->mm);
-
-	/* keep the page table cache within bounds */
-	check_pgt_cache();
-}
-
-static inline void
-tlb_remove_tlb_entry(struct mmu_gather *tlb, pte_t *ptep, unsigned long address)
-{
-	if (tlb->start > address)
-		tlb->start = address;
-	if (tlb->end < address + PAGE_SIZE)
-		tlb->end = address + PAGE_SIZE;
-}
-
-#define tlb_remove_huge_tlb_entry(h, tlb, ptep, address)	\
-	tlb_remove_tlb_entry(tlb, ptep, address)
-
-/*
- * In the case of tlb vma handling, we can optimise these away in the
- * case where we're doing a full MM flush.  When we're doing a munmap,
- * the vmas are adjusted to only cover the region to be torn down.
- */
-static inline void
-tlb_start_vma(struct mmu_gather *tlb, struct vm_area_struct *vma)
-{
-	if (!tlb->fullmm)
-		flush_cache_range(vma, vma->vm_start, vma->vm_end);
-}
-
-static inline void
-tlb_end_vma(struct mmu_gather *tlb, struct vm_area_struct *vma)
-{
-	if (!tlb->fullmm && tlb->end) {
-		flush_tlb_range(vma, tlb->start, tlb->end);
-		init_tlb_gather(tlb);
-	}
-}
-
-static inline void tlb_flush_mmu_tlbonly(struct mmu_gather *tlb)
-{
-}
-
-static inline void tlb_flush_mmu_free(struct mmu_gather *tlb)
-{
-}
-
-static inline void tlb_flush_mmu(struct mmu_gather *tlb)
-{
-}
-
-static inline int __tlb_remove_page(struct mmu_gather *tlb, struct page *page)
-{
-	free_page_and_swap_cache(page);
-	return false; /* avoid calling tlb_flush_mmu */
-}
-
-static inline void tlb_remove_page(struct mmu_gather *tlb, struct page *page)
-{
-	__tlb_remove_page(tlb, page);
-}
-
-static inline bool __tlb_remove_page_size(struct mmu_gather *tlb,
-					  struct page *page, int page_size)
-{
-	return __tlb_remove_page(tlb, page);
-}
-
-static inline void tlb_remove_page_size(struct mmu_gather *tlb,
-					struct page *page, int page_size)
-{
-	return tlb_remove_page(tlb, page);
-}
-
-static inline void tlb_change_page_size(struct mmu_gather *tlb, unsigned int page_size)
-{
-}
-
-#define pte_free_tlb(tlb, ptep, addr)	pte_free((tlb)->mm, ptep)
-#define pmd_free_tlb(tlb, pmdp, addr)	pmd_free((tlb)->mm, pmdp)
-#define pud_free_tlb(tlb, pudp, addr)	pud_free((tlb)->mm, pudp)
-
-#define tlb_migrate_finish(mm)		do { } while (0)
+#include <asm-generic/tlb.h>
 
 #if defined(CONFIG_CPU_SH4) || defined(CONFIG_SUPERH64)
 extern void tlb_wire_entry(struct vm_area_struct *, unsigned long, pte_t);
@@ -155,11 +32,6 @@ static inline void tlb_unwire_entry(void
 
 #else /* CONFIG_MMU */
 
-#define tlb_start_vma(tlb, vma)				do { } while (0)
-#define tlb_end_vma(tlb, vma)				do { } while (0)
-#define __tlb_remove_tlb_entry(tlb, pte, address)	do { } while (0)
-#define tlb_flush(tlb)					do { } while (0)
-
 #include <asm-generic/tlb.h>
 
 #endif /* CONFIG_MMU */


