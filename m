Return-Path: <SRS0=nbyn=UY=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=ham
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3926CC48BD4
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 14:38:16 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D563A2146E
	for <linux-mm@archiver.kernel.org>; Tue, 25 Jun 2019 14:38:15 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="SY5u8/KE"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D563A2146E
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BE45C8E000C; Tue, 25 Jun 2019 10:38:04 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B372A8E000B; Tue, 25 Jun 2019 10:38:04 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 7B3728E000C; Tue, 25 Jun 2019 10:38:04 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3FFEF8E0009
	for <linux-mm@kvack.org>; Tue, 25 Jun 2019 10:38:04 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id w22so2794156pgc.20
        for <linux-mm@kvack.org>; Tue, 25 Jun 2019 07:38:04 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=4KPE6CsNMoZOfy+nrZ2rpLzplDkTMTzqNqNxkX6IqeY=;
        b=dsWWLppAxuKo+3BlaHbfgRMBt46VRibGXmvokkuKLCLFpLxMXyr3x3Vc2yKPox0gNj
         AnPTpGG0bra0LcgJLOZWiGX/9kQMc8LVVxkpC7ApHWTrYZP0pbdBA9GNUAefBfEEFsnD
         5CNdbopYjU7KJwmbOGizZ9UD/5eWGeRBv+alsDba9VWV2L2weBtWCy7S95zQYUZRf3im
         EoTD0LXkiwNn4+tYfKpfEWlYJfw5XxP7pXFccK+jzHOdi8eplqMu/rbC+6n1R7OgATD1
         2LaUGgvGjndocpPx9o41AnaYRTJ+VOTt92UtIcmeImTloGxWHioFIfdRxdmVZRLHxVuH
         moww==
X-Gm-Message-State: APjAAAXUFRHMrPH71IQgwt592Biyu9A1tPl1M7eQJdcLCdQTvZn5dU0U
	gYUDgZyLUlRfs9zXu5jZQNLsSzu+WTBZuCgxOIrGg63dQJi6Rour/G7f1j9J3SJ1yMMOHvkSxb8
	iGsb2nMDqBKHM8J1lb4W2lWHxCHdGQdlNU60Nw2HsJR2ds0RccXZ/vPqvW2mmgXQ=
X-Received: by 2002:a63:1a5e:: with SMTP id a30mr38261021pgm.433.1561473483805;
        Tue, 25 Jun 2019 07:38:03 -0700 (PDT)
X-Google-Smtp-Source: APXvYqyUTBf1Dxrhtyi4Wn/oA54witRRIo1p01W0J4xm6aQU22CJPpRExEILm0eEZ/hFY1blWfGa
X-Received: by 2002:a63:1a5e:: with SMTP id a30mr38260941pgm.433.1561473482525;
        Tue, 25 Jun 2019 07:38:02 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1561473482; cv=none;
        d=google.com; s=arc-20160816;
        b=A1M/CYLlPCn1v4+/j9DQ0mtsnfVHDuu2spwJGfRnEukdaN/8ZeBzL++z0qpE6jLidS
         7giFSrATY1yQ4p9sWaMAyPMkx87oJq3XbSj7tfjGxbWJ8ij8pTlUvS1bDWFRIEaGGF6k
         G8hLrtGHNWzTFAnyreNYU4sz/zDc3rq1aQtuuYPu4hZrvvd9fEaVwAqsD/KYGjEwkGXt
         ST59j2V16W/e2qN4vnlHsJLOvLZVPl5lMYqrPnQuuT0OhXZuzHiSkeA8+p4RfmkZlCaS
         peYqKqFSk2G+empWxlcW8v4VT51OCvLqvBwDvCBj82SA40q3QE8HrMFlbtQimCCDk9AK
         ILGQ==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=4KPE6CsNMoZOfy+nrZ2rpLzplDkTMTzqNqNxkX6IqeY=;
        b=nAAZy6sWtmWwq//eBTuRtcuPBdKt4trPhonfdvI4n3giGF69n0eG3YVKvqAglY/44V
         e1k+khpkV0ApbbTOZD5P4hSQ/dhtW+VA9jbp5ZMASFd1LQ/rrgi8yhb/pCb5SR3qupS1
         k7ngxGWes5GP95JCVyHxy1oWPG6C283XzOTs5ooB+9oJvCo0k+S3nCyoRoRQ0Rl4ygxr
         106XBagW4e5O4ZfGeJRwNBRlwI3+SO3s1IvMlGaIxc9lOSnA0oDWdkBXZhtQDy0RMVjk
         nasxEsrr1yEeLHU1MjiaFT0+NrVf7I/DfV8FcG6ZUgghNWIinLC/KRxh1jVAI4eGQXk6
         +/qA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b="SY5u8/KE";
       spf=pass (google.com: best guess record for domain of batv+c5155a46dc30cc8634d8+5784+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+c5155a46dc30cc8634d8+5784+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id n8si2830340pfa.223.2019.06.25.07.38.02
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Tue, 25 Jun 2019 07:38:02 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+c5155a46dc30cc8634d8+5784+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b="SY5u8/KE";
       spf=pass (google.com: best guess record for domain of batv+c5155a46dc30cc8634d8+5784+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+c5155a46dc30cc8634d8+5784+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=4KPE6CsNMoZOfy+nrZ2rpLzplDkTMTzqNqNxkX6IqeY=; b=SY5u8/KEOcSaGAxBr8rD1KvWvr
	s/9lmkVyVeUxe0fYK4ULXh4cCHAFwwFg9GGQZTqINOls9Idsgns06d/W6OfiCuJbmDKZmx1UxHe+3
	BGp8CG/C5/Wz10+fUYoiMuwhZ+jEA9LzctPJKB6APtIILDApzjvneH2XLjt0Gb/01jR2yu1mu2luM
	MMe8Wlouwk0uyid9P1ufEUufHq2y55QNwzaM3qvIaAS3dqwa0ZFXWFZCA8n+2wMAVduAgjOTrey0I
	lvC98FgNCZGE61ht0JHlh0fDmKl16WJgD2QKiDrMQjA6XCt58AXbzGQLEk7pozrwrIbP/BEh6Vj9p
	RRtI+E3Q==;
Received: from 213-225-6-159.nat.highway.a1.net ([213.225.6.159] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.92 #3 (Red Hat Linux))
	id 1hfmZu-00080r-Ot; Tue, 25 Jun 2019 14:37:47 +0000
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
Subject: [PATCH 09/16] sparc64: use the generic get_user_pages_fast code
Date: Tue, 25 Jun 2019 16:37:08 +0200
Message-Id: <20190625143715.1689-10-hch@lst.de>
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

The sparc64 code is mostly equivalent to the generic one, minus various
bugfixes and two arch overrides that this patch adds to pgtable.h.

Signed-off-by: Christoph Hellwig <hch@lst.de>
Reviewed-by: Khalid Aziz <khalid.aziz@oracle.com>
---
 arch/sparc/Kconfig                  |   1 +
 arch/sparc/include/asm/pgtable_64.h |  18 ++
 arch/sparc/mm/Makefile              |   2 +-
 arch/sparc/mm/gup.c                 | 340 ----------------------------
 4 files changed, 20 insertions(+), 341 deletions(-)
 delete mode 100644 arch/sparc/mm/gup.c

diff --git a/arch/sparc/Kconfig b/arch/sparc/Kconfig
index 26ab6f5bbaaf..22435471f942 100644
--- a/arch/sparc/Kconfig
+++ b/arch/sparc/Kconfig
@@ -28,6 +28,7 @@ config SPARC
 	select RTC_DRV_M48T59
 	select RTC_SYSTOHC
 	select HAVE_ARCH_JUMP_LABEL if SPARC64
+	select HAVE_GENERIC_GUP if SPARC64
 	select GENERIC_IRQ_SHOW
 	select ARCH_WANT_IPC_PARSE_VERSION
 	select GENERIC_PCI_IOMAP
diff --git a/arch/sparc/include/asm/pgtable_64.h b/arch/sparc/include/asm/pgtable_64.h
index 1904782dcd39..547ff96fb228 100644
--- a/arch/sparc/include/asm/pgtable_64.h
+++ b/arch/sparc/include/asm/pgtable_64.h
@@ -1098,6 +1098,24 @@ static inline unsigned long untagged_addr(unsigned long start)
 }
 #define untagged_addr untagged_addr
 
+static inline bool pte_access_permitted(pte_t pte, bool write)
+{
+	u64 prot;
+
+	if (tlb_type == hypervisor) {
+		prot = _PAGE_PRESENT_4V | _PAGE_P_4V;
+		if (write)
+			prot |= _PAGE_WRITE_4V;
+	} else {
+		prot = _PAGE_PRESENT_4U | _PAGE_P_4U;
+		if (write)
+			prot |= _PAGE_WRITE_4U;
+	}
+
+	return (pte_val(pte) & (prot | _PAGE_SPECIAL)) == prot;
+}
+#define pte_access_permitted pte_access_permitted
+
 #include <asm/tlbflush.h>
 #include <asm-generic/pgtable.h>
 
diff --git a/arch/sparc/mm/Makefile b/arch/sparc/mm/Makefile
index d39075b1e3b7..b078205b70e0 100644
--- a/arch/sparc/mm/Makefile
+++ b/arch/sparc/mm/Makefile
@@ -5,7 +5,7 @@
 asflags-y := -ansi
 ccflags-y := -Werror
 
-obj-$(CONFIG_SPARC64)   += ultra.o tlb.o tsb.o gup.o
+obj-$(CONFIG_SPARC64)   += ultra.o tlb.o tsb.o
 obj-y                   += fault_$(BITS).o
 obj-y                   += init_$(BITS).o
 obj-$(CONFIG_SPARC32)   += extable.o srmmu.o iommu.o io-unit.o
diff --git a/arch/sparc/mm/gup.c b/arch/sparc/mm/gup.c
deleted file mode 100644
index 1e770a517d4a..000000000000
--- a/arch/sparc/mm/gup.c
+++ /dev/null
@@ -1,340 +0,0 @@
-// SPDX-License-Identifier: GPL-2.0
-/*
- * Lockless get_user_pages_fast for sparc, cribbed from powerpc
- *
- * Copyright (C) 2008 Nick Piggin
- * Copyright (C) 2008 Novell Inc.
- */
-
-#include <linux/sched.h>
-#include <linux/mm.h>
-#include <linux/vmstat.h>
-#include <linux/pagemap.h>
-#include <linux/rwsem.h>
-#include <asm/pgtable.h>
-#include <asm/adi.h>
-
-/*
- * The performance critical leaf functions are made noinline otherwise gcc
- * inlines everything into a single function which results in too much
- * register pressure.
- */
-static noinline int gup_pte_range(pmd_t pmd, unsigned long addr,
-		unsigned long end, int write, struct page **pages, int *nr)
-{
-	unsigned long mask, result;
-	pte_t *ptep;
-
-	if (tlb_type == hypervisor) {
-		result = _PAGE_PRESENT_4V|_PAGE_P_4V;
-		if (write)
-			result |= _PAGE_WRITE_4V;
-	} else {
-		result = _PAGE_PRESENT_4U|_PAGE_P_4U;
-		if (write)
-			result |= _PAGE_WRITE_4U;
-	}
-	mask = result | _PAGE_SPECIAL;
-
-	ptep = pte_offset_kernel(&pmd, addr);
-	do {
-		struct page *page, *head;
-		pte_t pte = *ptep;
-
-		if ((pte_val(pte) & mask) != result)
-			return 0;
-		VM_BUG_ON(!pfn_valid(pte_pfn(pte)));
-
-		/* The hugepage case is simplified on sparc64 because
-		 * we encode the sub-page pfn offsets into the
-		 * hugepage PTEs.  We could optimize this in the future
-		 * use page_cache_add_speculative() for the hugepage case.
-		 */
-		page = pte_page(pte);
-		head = compound_head(page);
-		if (!page_cache_get_speculative(head))
-			return 0;
-		if (unlikely(pte_val(pte) != pte_val(*ptep))) {
-			put_page(head);
-			return 0;
-		}
-
-		pages[*nr] = page;
-		(*nr)++;
-	} while (ptep++, addr += PAGE_SIZE, addr != end);
-
-	return 1;
-}
-
-static int gup_huge_pmd(pmd_t *pmdp, pmd_t pmd, unsigned long addr,
-			unsigned long end, int write, struct page **pages,
-			int *nr)
-{
-	struct page *head, *page;
-	int refs;
-
-	if (!(pmd_val(pmd) & _PAGE_VALID))
-		return 0;
-
-	if (write && !pmd_write(pmd))
-		return 0;
-
-	refs = 0;
-	page = pmd_page(pmd) + ((addr & ~PMD_MASK) >> PAGE_SHIFT);
-	head = compound_head(page);
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
-	if (unlikely(pmd_val(pmd) != pmd_val(*pmdp))) {
-		*nr -= refs;
-		while (refs--)
-			put_page(head);
-		return 0;
-	}
-
-	return 1;
-}
-
-static int gup_huge_pud(pud_t *pudp, pud_t pud, unsigned long addr,
-			unsigned long end, int write, struct page **pages,
-			int *nr)
-{
-	struct page *head, *page;
-	int refs;
-
-	if (!(pud_val(pud) & _PAGE_VALID))
-		return 0;
-
-	if (write && !pud_write(pud))
-		return 0;
-
-	refs = 0;
-	page = pud_page(pud) + ((addr & ~PUD_MASK) >> PAGE_SHIFT);
-	head = compound_head(page);
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
-	if (unlikely(pud_val(pud) != pud_val(*pudp))) {
-		*nr -= refs;
-		while (refs--)
-			put_page(head);
-		return 0;
-	}
-
-	return 1;
-}
-
-static int gup_pmd_range(pud_t pud, unsigned long addr, unsigned long end,
-		int write, struct page **pages, int *nr)
-{
-	unsigned long next;
-	pmd_t *pmdp;
-
-	pmdp = pmd_offset(&pud, addr);
-	do {
-		pmd_t pmd = *pmdp;
-
-		next = pmd_addr_end(addr, end);
-		if (pmd_none(pmd))
-			return 0;
-		if (unlikely(pmd_large(pmd))) {
-			if (!gup_huge_pmd(pmdp, pmd, addr, next,
-					  write, pages, nr))
-				return 0;
-		} else if (!gup_pte_range(pmd, addr, next, write,
-					  pages, nr))
-			return 0;
-	} while (pmdp++, addr = next, addr != end);
-
-	return 1;
-}
-
-static int gup_pud_range(pgd_t pgd, unsigned long addr, unsigned long end,
-		int write, struct page **pages, int *nr)
-{
-	unsigned long next;
-	pud_t *pudp;
-
-	pudp = pud_offset(&pgd, addr);
-	do {
-		pud_t pud = *pudp;
-
-		next = pud_addr_end(addr, end);
-		if (pud_none(pud))
-			return 0;
-		if (unlikely(pud_large(pud))) {
-			if (!gup_huge_pud(pudp, pud, addr, next,
-					  write, pages, nr))
-				return 0;
-		} else if (!gup_pmd_range(pud, addr, next, write, pages, nr))
-			return 0;
-	} while (pudp++, addr = next, addr != end);
-
-	return 1;
-}
-
-/*
- * Note a difference with get_user_pages_fast: this always returns the
- * number of pages pinned, 0 if no pages were pinned.
- */
-int __get_user_pages_fast(unsigned long start, int nr_pages, int write,
-			  struct page **pages)
-{
-	struct mm_struct *mm = current->mm;
-	unsigned long addr, len, end;
-	unsigned long next, flags;
-	pgd_t *pgdp;
-	int nr = 0;
-
-#ifdef CONFIG_SPARC64
-	if (adi_capable()) {
-		long addr = start;
-
-		/* If userspace has passed a versioned address, kernel
-		 * will not find it in the VMAs since it does not store
-		 * the version tags in the list of VMAs. Storing version
-		 * tags in list of VMAs is impractical since they can be
-		 * changed any time from userspace without dropping into
-		 * kernel. Any address search in VMAs will be done with
-		 * non-versioned addresses. Ensure the ADI version bits
-		 * are dropped here by sign extending the last bit before
-		 * ADI bits. IOMMU does not implement version tags.
-		 */
-		addr = (addr << (long)adi_nbits()) >> (long)adi_nbits();
-		start = addr;
-	}
-#endif
-	start &= PAGE_MASK;
-	addr = start;
-	len = (unsigned long) nr_pages << PAGE_SHIFT;
-	end = start + len;
-
-	local_irq_save(flags);
-	pgdp = pgd_offset(mm, addr);
-	do {
-		pgd_t pgd = *pgdp;
-
-		next = pgd_addr_end(addr, end);
-		if (pgd_none(pgd))
-			break;
-		if (!gup_pud_range(pgd, addr, next, write, pages, &nr))
-			break;
-	} while (pgdp++, addr = next, addr != end);
-	local_irq_restore(flags);
-
-	return nr;
-}
-
-int get_user_pages_fast(unsigned long start, int nr_pages,
-			unsigned int gup_flags, struct page **pages)
-{
-	struct mm_struct *mm = current->mm;
-	unsigned long addr, len, end;
-	unsigned long next;
-	pgd_t *pgdp;
-	int nr = 0;
-
-#ifdef CONFIG_SPARC64
-	if (adi_capable()) {
-		long addr = start;
-
-		/* If userspace has passed a versioned address, kernel
-		 * will not find it in the VMAs since it does not store
-		 * the version tags in the list of VMAs. Storing version
-		 * tags in list of VMAs is impractical since they can be
-		 * changed any time from userspace without dropping into
-		 * kernel. Any address search in VMAs will be done with
-		 * non-versioned addresses. Ensure the ADI version bits
-		 * are dropped here by sign extending the last bit before
-		 * ADI bits. IOMMU does not implements version tags,
-		 */
-		addr = (addr << (long)adi_nbits()) >> (long)adi_nbits();
-		start = addr;
-	}
-#endif
-	start &= PAGE_MASK;
-	addr = start;
-	len = (unsigned long) nr_pages << PAGE_SHIFT;
-	end = start + len;
-
-	/*
-	 * XXX: batch / limit 'nr', to avoid large irq off latency
-	 * needs some instrumenting to determine the common sizes used by
-	 * important workloads (eg. DB2), and whether limiting the batch size
-	 * will decrease performance.
-	 *
-	 * It seems like we're in the clear for the moment. Direct-IO is
-	 * the main guy that batches up lots of get_user_pages, and even
-	 * they are limited to 64-at-a-time which is not so many.
-	 */
-	/*
-	 * This doesn't prevent pagetable teardown, but does prevent
-	 * the pagetables from being freed on sparc.
-	 *
-	 * So long as we atomically load page table pointers versus teardown,
-	 * we can follow the address down to the the page and take a ref on it.
-	 */
-	local_irq_disable();
-
-	pgdp = pgd_offset(mm, addr);
-	do {
-		pgd_t pgd = *pgdp;
-
-		next = pgd_addr_end(addr, end);
-		if (pgd_none(pgd))
-			goto slow;
-		if (!gup_pud_range(pgd, addr, next, gup_flags & FOLL_WRITE,
-				   pages, &nr))
-			goto slow;
-	} while (pgdp++, addr = next, addr != end);
-
-	local_irq_enable();
-
-	VM_BUG_ON(nr != (end - start) >> PAGE_SHIFT);
-	return nr;
-
-	{
-		int ret;
-
-slow:
-		local_irq_enable();
-
-		/* Try to get the remaining pages with get_user_pages */
-		start += nr << PAGE_SHIFT;
-		pages += nr;
-
-		ret = get_user_pages_unlocked(start,
-			(end - start) >> PAGE_SHIFT, pages,
-			gup_flags);
-
-		/* Have to be a bit careful with return values */
-		if (nr > 0) {
-			if (ret < 0)
-				ret = nr;
-			else
-				ret += nr;
-		}
-
-		return ret;
-	}
-}
-- 
2.20.1

