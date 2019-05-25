Return-Path: <SRS0=GxOJ=TZ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AEC27C28CBF
	for <linux-mm@archiver.kernel.org>; Sat, 25 May 2019 13:32:26 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 58EB32053B
	for <linux-mm@archiver.kernel.org>; Sat, 25 May 2019 13:32:26 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="BLm0o4Yn"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 58EB32053B
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=lst.de
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 21D0F6B0005; Sat, 25 May 2019 09:32:22 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 1D1B76B000A; Sat, 25 May 2019 09:32:22 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id E4FF46B0007; Sat, 25 May 2019 09:32:21 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8570A6B0007
	for <linux-mm@kvack.org>; Sat, 25 May 2019 09:32:21 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id y9so7741954plt.11
        for <linux-mm@kvack.org>; Sat, 25 May 2019 06:32:21 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=WftgFc7mOq3cB8qhgVt3hx68vBZh4IAshC5wr1PSaqk=;
        b=N5/HEx9NfO1p+iMMX3rbC7uUHhz6CawLOAs7V0eG3IS8pqeM3LbN3+wjtw2obrjkFi
         Avv4pfJdzB6+ukq4YtCMe60Z0g49iqegGkEyaoUKQQqapjqbX9DL3GBVjctB2OJeTkcB
         eQo/CgmeVJ1CN8MwsOFx0vNtSMoxaf9+831ShB57VyMxuKYyeR032podIDYmb+9Jz83l
         oVEIiGvgpLkMYywiQPHtftzZzHizhnn46A5PDVRRKYxcE65Ln7o7K6RVpFzubaOj8AYH
         T2jS8MpoTsweChx64SX/pWjkjUprMj8z9YIMElRq2LpeZXNWEY7Nl/sptE/Vm+WSKykQ
         NolQ==
X-Gm-Message-State: APjAAAW/lHmxm6xwItUxg+7oW2lj40k/TxGlEVvXmCl914wLfTwUqjKN
	ebdisfbUjlvo2BX9VtwSbY9LT7rssXo/yd0jPvzm2KKyahS951I0qOY6Ucqz7AFtefamscPUXiH
	+UQEHTxffOFXmqrf8x3Rf9LLZ0gdXkqecTaSHMcTltF3njQLnSDVpZMcTcziGj/w=
X-Received: by 2002:a17:90a:de08:: with SMTP id m8mr15990541pjv.18.1558791141068;
        Sat, 25 May 2019 06:32:21 -0700 (PDT)
X-Google-Smtp-Source: APXvYqykPGpIS42ef6ymUmbRrHR6BkfpfW94y/1YzK394lsgTpm/ZfyXVqYgqko5O7iSDXBGRJfF
X-Received: by 2002:a17:90a:de08:: with SMTP id m8mr15990404pjv.18.1558791139857;
        Sat, 25 May 2019 06:32:19 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1558791139; cv=none;
        d=google.com; s=arc-20160816;
        b=kLWvO1p6DVJqtyFGtwUcVjXruYS0Vs5vEPKC8+5m/EmOTVNL0P7kPG8J8d9w9vPjG+
         EURPUf6ZVo1tQpNSBvP5AxaPX7PtwlEgkb944P3UMltJnkiqvB86sSuMVHlrKWKU/hQe
         HyNoTPSK+L3BGWE+rKUJV18rHYNxv0EM9b54DDmcfYUDZfMTxZeUlx8eliFxgr0GY6/9
         /WpvHgGw9hgz+59PsZpsEugMFoo3oSxWF/727Kcbnrs3T28HSrYvKArEhYpOG0sSAzRU
         KQetvoBitFEOfb1Yzc3OOryl63pbbzsBIRvBCd0zCPeao37v/CjnlGGlBAGO3nZnhYMd
         xNoA==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=WftgFc7mOq3cB8qhgVt3hx68vBZh4IAshC5wr1PSaqk=;
        b=bmcfdp1N61IRN/NYOvJcRNkfWEViWPlDjSaLm29jfdOuyVkeGIYljU8lsrKnd8YaNi
         ScOH5TT5vkRN6YHqaZG45N8v8KvmE1aV+z7j3WzLpL7RH/Jjsvod+rODcSJxbG3GLkMH
         2UYOZZCh9J6hzCdWCQxt5+9hKJe5iQNyrEq3t6tLnLy4Hjr2s7a27R48LHTnNB9TgilW
         W1hdPif8xt3kR88PnOU8cLTCeXP9lyq7HDKnLc72C2O1cIQLIqGjOwhydT+4kYOQCF3+
         7Pp6B4qXbn73arXmIy6B4uVDUTzVap8DxHlbu6dIwaSDAfkIC6Iw8Fih+6Rnw6wcIMZu
         W/0g==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=BLm0o4Yn;
       spf=pass (google.com: best guess record for domain of batv+928801bc91e84a78d6f1+5753+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+928801bc91e84a78d6f1+5753+infradead.org+hch@bombadil.srs.infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id m63si8307833pld.421.2019.05.25.06.32.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sat, 25 May 2019 06:32:19 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of batv+928801bc91e84a78d6f1+5753+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b=BLm0o4Yn;
       spf=pass (google.com: best guess record for domain of batv+928801bc91e84a78d6f1+5753+infradead.org+hch@bombadil.srs.infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=BATV+928801bc91e84a78d6f1+5753+infradead.org+hch@bombadil.srs.infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=WftgFc7mOq3cB8qhgVt3hx68vBZh4IAshC5wr1PSaqk=; b=BLm0o4Yn1zLKezN1O0Wf89g5Ow
	AamtQTjXmQGzrRuvpsNJTIeQmpjN0qwNsFM5+vRzWpocHGxrdPQoHVAFPExC6cMxneYhE4wa/p/jh
	Gl1g30BrengFh+F3BksXoZReUNKNedUVVu4OIwnGgTOejvK7ZZXlcBmqJ0HuDL7fz2cWX02SLvAI6
	vcIF57kZUCMb5RZAZqXajnE5Fj/UySRlW03i9idO3lfnkOgAqey2KGCNOl3PHLLBBJYZfGIGCMVP/
	KWwMMzAEXsHpTWI3xejytIR7OT8yWx/UvnI2eQBge+SNTtbi08dC7mX2NjReztSjEdNku/nkNaK8M
	R3pwKC5g==;
Received: from 213-225-10-46.nat.highway.a1.net ([213.225.10.46] helo=localhost)
	by bombadil.infradead.org with esmtpsa (Exim 4.90_1 #2 (Red Hat Linux))
	id 1hUWmP-0006Xr-S5; Sat, 25 May 2019 13:32:10 +0000
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
Subject: [PATCH 1/6] MIPS: use the generic get_user_pages_fast code
Date: Sat, 25 May 2019 15:31:58 +0200
Message-Id: <20190525133203.25853-2-hch@lst.de>
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

The mips code is mostly equivalent to the generic one, minus various
bugfixes and one and a half arch overrides that this patch adds to
pgtable.h.

Note that this defines ARCH_HAS_PTE_SPECIAL for mips as mips has
pte_special and pte_mkspecial implemented and used in the existing
gup code.  They are no-op stubs, though which makes me a little unsure
if this is really right thing to do.

Signed-off-by: Christoph Hellwig <hch@lst.de>
---
 arch/mips/Kconfig               |   2 +
 arch/mips/include/asm/pgtable.h |  30 ++++
 arch/mips/mm/Makefile           |   1 -
 arch/mips/mm/gup.c              | 303 --------------------------------
 4 files changed, 32 insertions(+), 304 deletions(-)
 delete mode 100644 arch/mips/mm/gup.c

diff --git a/arch/mips/Kconfig b/arch/mips/Kconfig
index 70d3200476bf..53a103cdc352 100644
--- a/arch/mips/Kconfig
+++ b/arch/mips/Kconfig
@@ -6,6 +6,7 @@ config MIPS
 	select ARCH_BINFMT_ELF_STATE if MIPS_FP_SUPPORT
 	select ARCH_CLOCKSOURCE_DATA
 	select ARCH_HAS_ELF_RANDOMIZE
+	select ARCH_HAS_PTE_SPECIAL
 	select ARCH_HAS_TICK_BROADCAST if GENERIC_CLOCKEVENTS_BROADCAST
 	select ARCH_HAS_UBSAN_SANITIZE_ALL
 	select ARCH_SUPPORTS_UPROBES
@@ -55,6 +56,7 @@ config MIPS
 	select HAVE_FTRACE_MCOUNT_RECORD
 	select HAVE_FUNCTION_GRAPH_TRACER
 	select HAVE_FUNCTION_TRACER
+	select HAVE_GENERIC_GUP
 	select HAVE_IDE
 	select HAVE_IOREMAP_PROT
 	select HAVE_IRQ_EXIT_ON_IRQ_STACK
diff --git a/arch/mips/include/asm/pgtable.h b/arch/mips/include/asm/pgtable.h
index 4ccb465ef3f2..a6fd98563837 100644
--- a/arch/mips/include/asm/pgtable.h
+++ b/arch/mips/include/asm/pgtable.h
@@ -20,6 +20,7 @@
 #include <asm/cmpxchg.h>
 #include <asm/io.h>
 #include <asm/pgtable-bits.h>
+#include <asm/cpu-features.h>
 
 struct mm_struct;
 struct vm_area_struct;
@@ -651,4 +652,33 @@ pgprot_t phys_mem_access_prot(struct file *file, unsigned long pfn,
  */
 #define pgtable_cache_init()	do { } while (0)
 
+static inline bool gup_fast_permitted(unsigned long start, int nr_pages)
+{
+	unsigned long len = (unsigned long)nr_pages << PAGE_SHIFT;
+	unsigned long end = start + len;
+
+	return !cpu_has_dc_aliases && end >= start;
+}
+#define gup_fast_permitted gup_fast_permitted
+
+#if defined(CONFIG_PHYS_ADDR_T_64BIT) && defined(CONFIG_CPU_MIPS32)
+static inline pte_t gup_get_pte(pte_t *ptep)
+{
+	pte_t pte;
+
+retry:
+	pte.pte_low = ptep->pte_low;
+	smp_rmb();
+	pte.pte_high = ptep->pte_high;
+	smp_rmb();
+	if (unlikely(pte.pte_low != ptep->pte_low))
+		goto retry;
+
+	return pte;
+}
+#define gup_get_pte gup_get_pte
+#endif
+
+static int gup_pte_range(pmd_t pmd, unsigned long addr, unsigned long end,
+
 #endif /* _ASM_PGTABLE_H */
diff --git a/arch/mips/mm/Makefile b/arch/mips/mm/Makefile
index f34d7ff5eb60..1e8d335025d7 100644
--- a/arch/mips/mm/Makefile
+++ b/arch/mips/mm/Makefile
@@ -7,7 +7,6 @@ obj-y				+= cache.o
 obj-y				+= context.o
 obj-y				+= extable.o
 obj-y				+= fault.o
-obj-y				+= gup.o
 obj-y				+= init.o
 obj-y				+= mmap.o
 obj-y				+= page.o
diff --git a/arch/mips/mm/gup.c b/arch/mips/mm/gup.c
deleted file mode 100644
index 4c2b4483683c..000000000000
--- a/arch/mips/mm/gup.c
+++ /dev/null
@@ -1,303 +0,0 @@
-// SPDX-License-Identifier: GPL-2.0
-/*
- * Lockless get_user_pages_fast for MIPS
- *
- * Copyright (C) 2008 Nick Piggin
- * Copyright (C) 2008 Novell Inc.
- * Copyright (C) 2011 Ralf Baechle
- */
-#include <linux/sched.h>
-#include <linux/mm.h>
-#include <linux/vmstat.h>
-#include <linux/highmem.h>
-#include <linux/swap.h>
-#include <linux/hugetlb.h>
-
-#include <asm/cpu-features.h>
-#include <asm/pgtable.h>
-
-static inline pte_t gup_get_pte(pte_t *ptep)
-{
-#if defined(CONFIG_PHYS_ADDR_T_64BIT) && defined(CONFIG_CPU_MIPS32)
-	pte_t pte;
-
-retry:
-	pte.pte_low = ptep->pte_low;
-	smp_rmb();
-	pte.pte_high = ptep->pte_high;
-	smp_rmb();
-	if (unlikely(pte.pte_low != ptep->pte_low))
-		goto retry;
-
-	return pte;
-#else
-	return READ_ONCE(*ptep);
-#endif
-}
-
-static int gup_pte_range(pmd_t pmd, unsigned long addr, unsigned long end,
-			int write, struct page **pages, int *nr)
-{
-	pte_t *ptep = pte_offset_map(&pmd, addr);
-	do {
-		pte_t pte = gup_get_pte(ptep);
-		struct page *page;
-
-		if (!pte_present(pte) ||
-		    pte_special(pte) || (write && !pte_write(pte))) {
-			pte_unmap(ptep);
-			return 0;
-		}
-		VM_BUG_ON(!pfn_valid(pte_pfn(pte)));
-		page = pte_page(pte);
-		get_page(page);
-		SetPageReferenced(page);
-		pages[*nr] = page;
-		(*nr)++;
-
-	} while (ptep++, addr += PAGE_SIZE, addr != end);
-
-	pte_unmap(ptep - 1);
-	return 1;
-}
-
-static inline void get_head_page_multiple(struct page *page, int nr)
-{
-	VM_BUG_ON(page != compound_head(page));
-	VM_BUG_ON(page_count(page) == 0);
-	page_ref_add(page, nr);
-	SetPageReferenced(page);
-}
-
-static int gup_huge_pmd(pmd_t pmd, unsigned long addr, unsigned long end,
-			int write, struct page **pages, int *nr)
-{
-	pte_t pte = *(pte_t *)&pmd;
-	struct page *head, *page;
-	int refs;
-
-	if (write && !pte_write(pte))
-		return 0;
-	/* hugepages are never "special" */
-	VM_BUG_ON(pte_special(pte));
-	VM_BUG_ON(!pfn_valid(pte_pfn(pte)));
-
-	refs = 0;
-	head = pte_page(pte);
-	page = head + ((addr & ~PMD_MASK) >> PAGE_SHIFT);
-	do {
-		VM_BUG_ON(compound_head(page) != head);
-		pages[*nr] = page;
-		(*nr)++;
-		page++;
-		refs++;
-	} while (addr += PAGE_SIZE, addr != end);
-
-	get_head_page_multiple(head, refs);
-	return 1;
-}
-
-static int gup_pmd_range(pud_t pud, unsigned long addr, unsigned long end,
-			int write, struct page **pages, int *nr)
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
-		if (unlikely(pmd_huge(pmd))) {
-			if (!gup_huge_pmd(pmd, addr, next, write, pages,nr))
-				return 0;
-		} else {
-			if (!gup_pte_range(pmd, addr, next, write, pages,nr))
-				return 0;
-		}
-	} while (pmdp++, addr = next, addr != end);
-
-	return 1;
-}
-
-static int gup_huge_pud(pud_t pud, unsigned long addr, unsigned long end,
-			int write, struct page **pages, int *nr)
-{
-	pte_t pte = *(pte_t *)&pud;
-	struct page *head, *page;
-	int refs;
-
-	if (write && !pte_write(pte))
-		return 0;
-	/* hugepages are never "special" */
-	VM_BUG_ON(pte_special(pte));
-	VM_BUG_ON(!pfn_valid(pte_pfn(pte)));
-
-	refs = 0;
-	head = pte_page(pte);
-	page = head + ((addr & ~PUD_MASK) >> PAGE_SHIFT);
-	do {
-		VM_BUG_ON(compound_head(page) != head);
-		pages[*nr] = page;
-		(*nr)++;
-		page++;
-		refs++;
-	} while (addr += PAGE_SIZE, addr != end);
-
-	get_head_page_multiple(head, refs);
-	return 1;
-}
-
-static int gup_pud_range(pgd_t pgd, unsigned long addr, unsigned long end,
-			int write, struct page **pages, int *nr)
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
-		if (unlikely(pud_huge(pud))) {
-			if (!gup_huge_pud(pud, addr, next, write, pages,nr))
-				return 0;
-		} else {
-			if (!gup_pmd_range(pud, addr, next, write, pages,nr))
-				return 0;
-		}
-	} while (pudp++, addr = next, addr != end);
-
-	return 1;
-}
-
-/*
- * Like get_user_pages_fast() except its IRQ-safe in that it won't fall
- * back to the regular GUP.
- * Note a difference with get_user_pages_fast: this always returns the
- * number of pages pinned, 0 if no pages were pinned.
- */
-int __get_user_pages_fast(unsigned long start, int nr_pages, int write,
-			  struct page **pages)
-{
-	struct mm_struct *mm = current->mm;
-	unsigned long addr, len, end;
-	unsigned long next;
-	unsigned long flags;
-	pgd_t *pgdp;
-	int nr = 0;
-
-	start &= PAGE_MASK;
-	addr = start;
-	len = (unsigned long) nr_pages << PAGE_SHIFT;
-	end = start + len;
-	if (unlikely(!access_ok((void __user *)start, len)))
-		return 0;
-
-	/*
-	 * XXX: batch / limit 'nr', to avoid large irq off latency
-	 * needs some instrumenting to determine the common sizes used by
-	 * important workloads (eg. DB2), and whether limiting the batch
-	 * size will decrease performance.
-	 *
-	 * It seems like we're in the clear for the moment. Direct-IO is
-	 * the main guy that batches up lots of get_user_pages, and even
-	 * they are limited to 64-at-a-time which is not so many.
-	 */
-	/*
-	 * This doesn't prevent pagetable teardown, but does prevent
-	 * the pagetables and pages from being freed.
-	 *
-	 * So long as we atomically load page table pointers versus teardown,
-	 * we can follow the address down to the page and take a ref on it.
-	 */
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
-/**
- * get_user_pages_fast() - pin user pages in memory
- * @start:	starting user address
- * @nr_pages:	number of pages from start to pin
- * @gup_flags:	flags modifying pin behaviour
- * @pages:	array that receives pointers to the pages pinned.
- *		Should be at least nr_pages long.
- *
- * Attempt to pin user pages in memory without taking mm->mmap_sem.
- * If not successful, it will fall back to taking the lock and
- * calling get_user_pages().
- *
- * Returns number of pages pinned. This may be fewer than the number
- * requested. If nr_pages is 0 or negative, returns 0. If no pages
- * were pinned, returns -errno.
- */
-int get_user_pages_fast(unsigned long start, int nr_pages,
-			unsigned int gup_flags, struct page **pages)
-{
-	struct mm_struct *mm = current->mm;
-	unsigned long addr, len, end;
-	unsigned long next;
-	pgd_t *pgdp;
-	int ret, nr = 0;
-
-	start &= PAGE_MASK;
-	addr = start;
-	len = (unsigned long) nr_pages << PAGE_SHIFT;
-
-	end = start + len;
-	if (end < start || cpu_has_dc_aliases)
-		goto slow_irqon;
-
-	/* XXX: batch / limit 'nr' */
-	local_irq_disable();
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
-	local_irq_enable();
-
-	VM_BUG_ON(nr != (end - start) >> PAGE_SHIFT);
-	return nr;
-slow:
-	local_irq_enable();
-
-slow_irqon:
-	/* Try to get the remaining pages with get_user_pages */
-	start += nr << PAGE_SHIFT;
-	pages += nr;
-
-	ret = get_user_pages_unlocked(start, (end - start) >> PAGE_SHIFT,
-				      pages, gup_flags);
-
-	/* Have to be a bit careful with return values */
-	if (nr > 0) {
-		if (ret < 0)
-			ret = nr;
-		else
-			ret += nr;
-	}
-	return ret;
-}
-- 
2.20.1

