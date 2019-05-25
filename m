Return-Path: <SRS0=GxOJ=TZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0FE17C282CE
	for <linux-mm@archiver.kernel.org>; Sat, 25 May 2019 13:32:36 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id BA2272053B
	for <linux-mm@archiver.kernel.org>; Sat, 25 May 2019 13:32:35 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="ltH4iEbS"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org BA2272053B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 3C8E86B000C; Sat, 25 May 2019 09:32:29 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 37D756B000D; Sat, 25 May 2019 09:32:29 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 21D776B000E; Sat, 25 May 2019 09:32:29 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id C697A6B000C
	for <linux-mm@kvack.org>; Sat, 25 May 2019 09:32:28 -0400 (EDT)
Received: by mail-pf1-f198.google.com with SMTP id c7so9204131pfp.14
        for <linux-mm@kvack.org>; Sat, 25 May 2019 06:32:28 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=QKVBbQ5hgk52CNIynfl61ZRTkUz1QI9cVbx1xyoJ60A=;
        b=LtcgeGCohR47e160CWtXAKFzsVXwRB7lx1CPa2xlsCaRXNqwh5V7RFnCqEvqxJ6AWT
         l32YfZ2p7YzhcJL8JeGpO2xyBVnH4iKj0rIdkNFhHvnsftrcgrVXBhCNTKScRfkTj0Ka
         FIRnM0QtkiybIX0LTkkjKItVKeNZq5Vfw5AUd4UyFP9gIrc8+hIwnMHMxTIYIpE2yLDD
         WGvAIRalas2w7YAneQxhYemdoFSQ7yhiP9weGLoPFtGxtLZs/ul+ElVk/FnJ/comArjC
         SqqEcbxmGjfBkkgqvtQxRPp1y+RYSAVhcj7AhRJfrtC9y6ujGuLVaJQEvhTh5NamRVop
         q5GQ==
X-Gm-Message-State: APjAAAULWtLPKV3yf/hgubwF+LKl6ERtJkFZ80ziKACxPiIY3Wv//tmR
	ihtAZtb4Vh2XsA8IBB23UskQXTZPH1XiW/yo593wRCqmAIhgAXnEwocfDz9UGx2WWFImMaKu4Tz
	YSCrtmU2qD8tTF0/iEPzykU0qDzJjUwJfs9xmLGNi6jFQh2VOmbmoO3ZQ3Ez+SCE=
X-Received: by 2002:a62:7793:: with SMTP id s141mr54020487pfc.21.1558791148038;
        Sat, 25 May 2019 06:32:28 -0700 (PDT)
X-Google-Smtp-Source: APXvYqzrMhcOprOB5riqEuVO/IcvorTLSNh/oi6El8lW7pNEy+4RXMXbJIryCpYjryiVEJpGHwpW
X-Received: by 2002:a62:7793:: with SMTP id s141mr54020354pfc.21.1558791146893;
        Sat, 25 May 2019 06:32:26 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558791146; cv=none;
        d=google.com; s=arc-20160816;
        b=sUgPFN8MjhLCQZfiY8zdZWODN8NcsKWtk2vTcf5MQDBsiD5dBnPtvvD4C4I3EZOEt0
         XI4pqEsnefMWROG5VH8Pfg2gWdWQWafG1ndrse4mrE9l8ls10EqGTABJX+B/OBdMIbj7
         EQf6A949Q8bQf/DMrKCMFo0aIKfcUE3fwfB3gO5tg5b/D+bwXBKriIkXA+7XFlHXl4Ah
         OR0XKx++Fmr70Ru++wV6GCwOzM9Nf7WojtqZaS1ufshTEmQLjk3d8X3gN7DPh0BtjIBL
         WUplNzXAed7b148xs6IgBSVhGTF39UPVQsFRjVJ1m5A443iLjWI+taciuOcsR4vI4ruq
         ZlMw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=QKVBbQ5hgk52CNIynfl61ZRTkUz1QI9cVbx1xyoJ60A=;
        b=Ndv3GexkIjl//7dpfzRgrxikTUhz5jstOCpK+5fo74dGRnSWZETwris+1mZqpQU9HG
         kUynmh9pA1sAsc9IkNt2onWrrwftug1BjIkEKXj718+s2XqgOC1PYtF81vMCUpA/ath2
         uGGhx8Fs3Pyw2pD5WGUGuNiN2muAcP768615VhYtE6uH78yZY19LzjclpLGCe2kxEHIk
         7xvSaXKrtXdGz98hVMNaWd5lGJm53e/K/I3ePf2m5hZL70Hu0NuPCwqMaafKqMpeb43s
         QRW1Zye0bxFw/yCd5rPwuvUgOMNeE5yGNqB9afQ2m6hClbXYkzsV4IG4W02kmn9shg4V
         Xkyw==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=ltH4iEbS;
       spf=pass (google.com: best guess record for domain of batv+928801bc91e84a78d6f1+5753+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+928801bc91e84a78d6f1+5753+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id d24si8206127pgj.18.2019.05.25.06.32.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sat, 25 May 2019 06:32:26 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+928801bc91e84a78d6f1+5753+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=ltH4iEbS;
       spf=pass (google.com: best guess record for domain of batv+928801bc91e84a78d6f1+5753+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+928801bc91e84a78d6f1+5753+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=QKVBbQ5hgk52CNIynfl61ZRTkUz1QI9cVbx1xyoJ60A=; b=ltH4iEbSKpJdZfFd6LbQAuw6B0
	b/pwHOJxuhDeV9bkdFtAEvO59vKKPkYYrt9EDb+OotWfL15l1nxUrPqLLBcS76WzTp2cXzgxK2kzw
	KtAsLaEb3vgUMbY6HGh4+G1AeAEsH/ydiTc+5vcc9rDRbisuSW4e9olcUDfwDs12kVvLSbC79uLkh
	tSgLvX8yy2vu4lafGhkLbINVowbf1IpJWfd51KMPTbK0XYuY9RNIzTYKL52ahb9tVQKdmiUfUpaAz
	ODxmIj9NypE1PBVE8q3rMMse1g4gvRqrvTUHymXkIAOp5/t/jtsWq+kJzxcoXyiGaBe7ACnK9bVcf
	mDhKAUSw==;
Received: from 213-225-10-46.nat.highway.a1.net ([213.225.10.46] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hUWmc-0006ZE-56; Sat, 25 May 2019 13:32:22 +0000
From: Christoph Hellwig <hch@lst.de>
To: Linus Torvalds <torvalds@linux-foundation.org>,
	Paul Burton <paul.burton@mips.com>,
	James Hogan <jhogan@kernel.org>,
	Yoshinori Sato <ysato@users.sourceforge.jp>,
	Rich Felker <dalias@libc.org>,
	"David S. Miller" <davem@davemloft.net>
Cc: Nicholas Piggin <npiggin@gmail.com>,
	linux-mips@vger.kernel.org,
	linux-sh@vger.kernel.org,
	sparclinux@vger.kernel.org,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH 5/6] sparc64: use the generic get_user_pages_fast code
Date: Sat, 25 May 2019 15:32:02 +0200
Message-Id: <20190525133203.25853-6-hch@lst.de>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190525133203.25853-1-hch@lst.de>
References: <20190525133203.25853-1-hch@lst.de>
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
---
 arch/sparc/Kconfig                  |   1 +
 arch/sparc/include/asm/pgtable_64.h |  40 ++++
 arch/sparc/mm/Makefile              |   2 +-
 arch/sparc/mm/gup.c                 | 340 ----------------------------
 4 files changed, 42 insertions(+), 341 deletions(-)
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
index 22500c3be7a9..753d1417bae1 100644
--- a/arch/sparc/include/asm/pgtable_64.h
+++ b/arch/sparc/include/asm/pgtable_64.h
@@ -1075,6 +1075,46 @@ static inline int io_remap_pfn_range(struct vm_area_struct *vma,
 }
 #define io_remap_pfn_range io_remap_pfn_range 
 
+static inline unsigned long gup_fixup_start_addr(unsigned long start)
+{
+	if (adi_capable()) {
+		long addr = start;
+
+		/* If userspace has passed a versioned address, kernel
+		 * will not find it in the VMAs since it does not store
+		 * the version tags in the list of VMAs. Storing version
+		 * tags in list of VMAs is impractical since they can be
+		 * changed any time from userspace without dropping into
+		 * kernel. Any address search in VMAs will be done with
+		 * non-versioned addresses. Ensure the ADI version bits
+		 * are dropped here by sign extending the last bit before
+		 * ADI bits. IOMMU does not implement version tags.
+		 */
+		return (addr << (long)adi_nbits()) >> (long)adi_nbits();
+	}
+
+	return start;
+}
+#define gup_fixup_start_addr gup_fixup_start_addr
+
+static inline bool pte_access_permitted(pte_t pte, bool write)
+{
+	u64 prot;
+
+	if (tlb_type == hypervisor) {
+		prot = _PAGE_PRESENT_4V | _PAGE_P_4V;
+		if (prot)
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

