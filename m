Return-Path: <SRS0=JJ+4=UJ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 21772C468BC
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 04:41:14 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id D104A206C3
	for <linux-mm@archiver.kernel.org>; Mon, 10 Jun 2019 04:41:13 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="RO1OVz8a"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org D104A206C3
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 637096B000E; Mon, 10 Jun 2019 00:41:13 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 5E52B6B0010; Mon, 10 Jun 2019 00:41:13 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 4600C6B0266; Mon, 10 Jun 2019 00:41:13 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 06DBE6B000E
	for <linux-mm@kvack.org>; Mon, 10 Jun 2019 00:41:13 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id g11so5009783plt.23
        for <linux-mm@kvack.org>; Sun, 09 Jun 2019 21:41:12 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=sL83o5GmSL2dCmHfrkqeaNUT3nyNNx/ViCtqeruTtoM=;
        b=tJfSeLfKhpgg2ND1H4Icy77VkcZt9CPZkGFxUsKB3+9LijJiT5/upAJ//eRzz1CSqZ
         hI6hLSRBJ5afgs/yRldAuI5jD+TFvfy8UkrTzyok3nNBV3Spxkh36Kn5/RtEnPhPzunT
         eUi0PRhseZzrhWMWx0D+Wz9OSJWl4b5ktlyEIUZPFJohxGswj7qpysVlA2STCYQmgiWs
         Aj0lvNQo/yGr5DIPrCWukgzImZ0O5m0Z1GNWLu5xIDw+zCEwJes8/Wm0+FkikSvrJfrB
         8RisHh5Haw0l17GDq7IqW1VtObqN9Ts207r1VeZfGvqeUEx3x1TrEVNTv0X8aqk1LB14
         s5vw==
X-Gm-Message-State: APjAAAVHuNDEaLPONWh4t3i0byJWHKCAGQzZRDPaV+zhFq7iJdcGO1kR
	pSx9JBTWyXekIvL8Rwz1+g+MGS74FeL4/82jezUQLL9fZenbKXj19bam/1EI9mBvWivR6jjvKYO
	WCxVz+zrFIkQBZI9VcOJfkXWHxmGgTHnLsXAFBpzuUHGZoWj/xbSJXmFfpro9FxzGmA==
X-Received: by 2002:aa7:8294:: with SMTP id s20mr63538268pfm.75.1560141672584;
        Sun, 09 Jun 2019 21:41:12 -0700 (PDT)
X-Received: by 2002:aa7:8294:: with SMTP id s20mr63538204pfm.75.1560141671087;
        Sun, 09 Jun 2019 21:41:11 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1560141671; cv=none;
        d=google.com; s=arc-20160816;
        b=tlXD4K3lKp+yfMr5rSgVU0jNMgipgscatvXe+i26+NsqIgyqTyBX8JTFH2XGfFJmnx
         b7ZbLKPn+ggGOHbjoFoad4a3R+ar05LyFOv7Udjr11hD5y/CsbHOYvzcP8EEaU+B9fmr
         2spt7tYlBE9BkEY9g5/i2pDiBuiqcWaseBwphiQ06WMDCW3zTmVQcwmoemjIkAjpVcft
         fZFVvXqUj/saEgX3+U0EaSlrILKcBnkWpjVTml4YzBg4zljPv7cXtRdhiYd10jhb6Pkc
         BrCXRJ/ASMei3WgnWjy9jyjAE6t4ev9lUFSiTuMfqfHL/p3Px1uWmeOswYkrVZAPL8Fo
         DCzg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=sL83o5GmSL2dCmHfrkqeaNUT3nyNNx/ViCtqeruTtoM=;
        b=cHA/1MmxU+l2lxkBB7PI1JmfaJYKEVqfA+kuGLemWHzZjyrf5OjWUb0pyUUilQy5r3
         cIzuF57ZexcbO/d0ntTdG9YNnVIviqDoPoHP4K3OUpRJxf2aK0D5D86sMt2jU9lmuXsi
         AV4lLcc/lfKZifvPpc38Er10rKt/p66sCLaN1sO7EBA2eLiw/7dx5dW6eHCLhtXuo3cs
         Ok78hF6IdUKqA1U/mPYceRHj+CiX5oBUpOALVJvbTVwKKelvIMs+l5g+PbXvAwLOlKj2
         FViWoKJ0rE3PObBgQvKvT/P4it+Ej2/8tuDzgiBEbDC4Rk2M5z2PlRNRZSUGwWmI2COK
         WoMQ==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=RO1OVz8a;
       spf=pass (google.com: domain of npiggin@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=npiggin@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id d6sor10558547pjs.23.2019.06.09.21.41.10
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 09 Jun 2019 21:41:11 -0700 (PDT)
Received-SPF: pass (google.com: domain of npiggin@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=RO1OVz8a;
       spf=pass (google.com: domain of npiggin@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=npiggin@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=sL83o5GmSL2dCmHfrkqeaNUT3nyNNx/ViCtqeruTtoM=;
        b=RO1OVz8aaLV5Rr9K7e6Kj+LnA1vIHWrb9LtDUDXGEyE9Sjtvt4YQF+5ZcrF/4bVwk5
         0gHf3z1I/9rFUqJic3T2F4qbrXx9GixwaS3gwpL4u8KkjK7vESCtsydKVWvcVKYLy7bb
         uHkphxOUuDVniKUm+UYECNHKvuFQKiZOOUnBdVPZ9tzdcErdJmHSqBBV+u+0Ee5SCouk
         wUsZM5oIOc1lnIIfkEmgYF/aS0lpxEBe1s8j0dEQTKwkoCmwVNrc1a/JtAsby4fGD4OD
         h20RZZt8XYksTyyjUgW9zIezh8TaSurYm2QmMadQdKeXK2aEi3P8K85i22wEhBaIP4WW
         GesA==
X-Google-Smtp-Source: APXvYqx5xLsoxUHDjuTqVHUN6KWL4KccSuLF+xYRdn3IRei9u/+KqQ8FZiwEbYaMYD/V+xoD54miIA==
X-Received: by 2002:a17:90a:b298:: with SMTP id c24mr19149840pjr.18.1560141670415;
        Sun, 09 Jun 2019 21:41:10 -0700 (PDT)
Received: from bobo.local0.net (60-241-56-246.tpgi.com.au. [60.241.56.246])
        by smtp.gmail.com with ESMTPSA id l1sm9166802pgj.67.2019.06.09.21.41.07
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Sun, 09 Jun 2019 21:41:09 -0700 (PDT)
From: Nicholas Piggin <npiggin@gmail.com>
To: linux-mm@kvack.org
Cc: Nicholas Piggin <npiggin@gmail.com>,
	linuxppc-dev@lists.ozlabs.org,
	linux-arm-kernel@lists.infradead.org
Subject: [PATCH 4/4] mm/vmalloc: Hugepage vmalloc mappings
Date: Mon, 10 Jun 2019 14:38:38 +1000
Message-Id: <20190610043838.27916-4-npiggin@gmail.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190610043838.27916-1-npiggin@gmail.com>
References: <20190610043838.27916-1-npiggin@gmail.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

For platforms that define HAVE_ARCH_HUGE_VMAP, have vmap allow vmalloc to
allocate huge pages and map them

This brings dTLB misses for linux kernel tree `git diff` from 45,000 to
8,000 on a Kaby Lake KVM guest with 8MB dentry hash and mitigations=off
(performance is in the noise, under 1% difference, page tables are likely
to be well cached for this workload). Similar numbers are seen on POWER9.

Signed-off-by: Nicholas Piggin <npiggin@gmail.com>
---
 include/asm-generic/4level-fixup.h |   1 +
 include/asm-generic/5level-fixup.h |   1 +
 include/linux/vmalloc.h            |   1 +
 mm/vmalloc.c                       | 132 +++++++++++++++++++++++------
 4 files changed, 107 insertions(+), 28 deletions(-)

diff --git a/include/asm-generic/4level-fixup.h b/include/asm-generic/4level-fixup.h
index e3667c9a33a5..3cc65a4dd093 100644
--- a/include/asm-generic/4level-fixup.h
+++ b/include/asm-generic/4level-fixup.h
@@ -20,6 +20,7 @@
 #define pud_none(pud)			0
 #define pud_bad(pud)			0
 #define pud_present(pud)		1
+#define pud_large(pud)			0
 #define pud_ERROR(pud)			do { } while (0)
 #define pud_clear(pud)			pgd_clear(pud)
 #define pud_val(pud)			pgd_val(pud)
diff --git a/include/asm-generic/5level-fixup.h b/include/asm-generic/5level-fixup.h
index bb6cb347018c..c4377db09a4f 100644
--- a/include/asm-generic/5level-fixup.h
+++ b/include/asm-generic/5level-fixup.h
@@ -22,6 +22,7 @@
 #define p4d_none(p4d)			0
 #define p4d_bad(p4d)			0
 #define p4d_present(p4d)		1
+#define p4d_large(p4d)			0
 #define p4d_ERROR(p4d)			do { } while (0)
 #define p4d_clear(p4d)			pgd_clear(p4d)
 #define p4d_val(p4d)			pgd_val(p4d)
diff --git a/include/linux/vmalloc.h b/include/linux/vmalloc.h
index 812bea5866d6..4c92dc608928 100644
--- a/include/linux/vmalloc.h
+++ b/include/linux/vmalloc.h
@@ -42,6 +42,7 @@ struct vm_struct {
 	unsigned long		size;
 	unsigned long		flags;
 	struct page		**pages;
+	unsigned int		page_shift;
 	unsigned int		nr_pages;
 	phys_addr_t		phys_addr;
 	const void		*caller;
diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index dd27cfb29b10..0cf8e861caeb 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -36,6 +36,7 @@
 #include <linux/rbtree_augmented.h>
 
 #include <linux/uaccess.h>
+#include <asm/pgtable.h>
 #include <asm/tlbflush.h>
 #include <asm/shmparam.h>
 
@@ -440,6 +441,41 @@ static int vmap_pages_range(unsigned long start, unsigned long end,
 	return ret;
 }
 
+#ifdef CONFIG_HAVE_ARCH_HUGE_VMAP
+static int vmap_hpages_range(unsigned long start, unsigned long end,
+				   pgprot_t prot, struct page **pages,
+				   unsigned int page_shift)
+{
+	unsigned long addr = start;
+	unsigned int i, nr = (end - start) >> (PAGE_SHIFT + page_shift);
+
+	for (i = 0; i < nr; i++) {
+		int err;
+
+		err = vmap_range_noflush(addr,
+					addr + (PAGE_SIZE << page_shift),
+					__pa(page_address(pages[i])), prot,
+					PAGE_SHIFT + page_shift);
+		if (err)
+			return err;
+
+		addr += PAGE_SIZE << page_shift;
+	}
+	flush_cache_vmap(start, end);
+
+	return nr;
+}
+#else
+static int vmap_hpages_range(unsigned long start, unsigned long end,
+			   pgprot_t prot, struct page **pages,
+			   unsigned int page_shift)
+{
+	BUG_ON(page_shift != PAGE_SIZE);
+	return vmap_pages_range(start, end, prot, pages);
+}
+#endif
+
+
 int is_vmalloc_or_module_addr(const void *x)
 {
 	/*
@@ -462,7 +498,7 @@ struct page *vmalloc_to_page(const void *vmalloc_addr)
 {
 	unsigned long addr = (unsigned long) vmalloc_addr;
 	struct page *page = NULL;
-	pgd_t *pgd = pgd_offset_k(addr);
+	pgd_t *pgd;
 	p4d_t *p4d;
 	pud_t *pud;
 	pmd_t *pmd;
@@ -474,27 +510,38 @@ struct page *vmalloc_to_page(const void *vmalloc_addr)
 	 */
 	VIRTUAL_BUG_ON(!is_vmalloc_or_module_addr(vmalloc_addr));
 
+	pgd = pgd_offset_k(addr);
 	if (pgd_none(*pgd))
 		return NULL;
+
 	p4d = p4d_offset(pgd, addr);
 	if (p4d_none(*p4d))
 		return NULL;
-	pud = pud_offset(p4d, addr);
+#ifdef CONFIG_HAVE_ARCH_HUGE_VMAP
+	if (p4d_large(*p4d))
+		return p4d_page(*p4d) + ((addr & ~P4D_MASK) >> PAGE_SHIFT);
+#endif
+	if (WARN_ON_ONCE(p4d_bad(*p4d)))
+		return NULL;
 
-	/*
-	 * Don't dereference bad PUD or PMD (below) entries. This will also
-	 * identify huge mappings, which we may encounter on architectures
-	 * that define CONFIG_HAVE_ARCH_HUGE_VMAP=y. Such regions will be
-	 * identified as vmalloc addresses by is_vmalloc_addr(), but are
-	 * not [unambiguously] associated with a struct page, so there is
-	 * no correct value to return for them.
-	 */
-	WARN_ON_ONCE(pud_bad(*pud));
-	if (pud_none(*pud) || pud_bad(*pud))
+	pud = pud_offset(p4d, addr);
+	if (pud_none(*pud))
+		return NULL;
+#ifdef CONFIG_HAVE_ARCH_HUGE_VMAP
+	if (pud_large(*pud))
+		return pud_page(*pud) + ((addr & ~PUD_MASK) >> PAGE_SHIFT);
+#endif
+	if (WARN_ON_ONCE(pud_bad(*pud)))
 		return NULL;
+
 	pmd = pmd_offset(pud, addr);
-	WARN_ON_ONCE(pmd_bad(*pmd));
-	if (pmd_none(*pmd) || pmd_bad(*pmd))
+	if (pmd_none(*pmd))
+		return NULL;
+#ifdef CONFIG_HAVE_ARCH_HUGE_VMAP
+	if (pmd_large(*pmd))
+		return pmd_page(*pmd) + ((addr & ~PMD_MASK) >> PAGE_SHIFT);
+#endif
+	if (WARN_ON_ONCE(pmd_bad(*pmd)))
 		return NULL;
 
 	ptep = pte_offset_map(pmd, addr);
@@ -502,6 +549,7 @@ struct page *vmalloc_to_page(const void *vmalloc_addr)
 	if (pte_present(pte))
 		page = pte_page(pte);
 	pte_unmap(ptep);
+
 	return page;
 }
 EXPORT_SYMBOL(vmalloc_to_page);
@@ -2185,8 +2233,9 @@ static struct vm_struct *__get_vm_area_node(unsigned long size,
 		return NULL;
 
 	if (flags & VM_IOREMAP)
-		align = 1ul << clamp_t(int, get_count_order_long(size),
-				       PAGE_SHIFT, IOREMAP_MAX_ORDER);
+		align = max(align,
+				1ul << clamp_t(int, get_count_order_long(size),
+				       PAGE_SHIFT, IOREMAP_MAX_ORDER));
 
 	area = kzalloc_node(sizeof(*area), gfp_mask & GFP_RECLAIM_MASK, node);
 	if (unlikely(!area))
@@ -2398,7 +2447,7 @@ static void __vunmap(const void *addr, int deallocate_pages)
 			struct page *page = area->pages[i];
 
 			BUG_ON(!page);
-			__free_pages(page, 0);
+			__free_pages(page, area->page_shift);
 		}
 
 		kvfree(area->pages);
@@ -2541,14 +2590,17 @@ static void *__vmalloc_area_node(struct vm_struct *area, gfp_t gfp_mask,
 				 pgprot_t prot, int node)
 {
 	struct page **pages;
+	unsigned long addr = (unsigned long)area->addr;
+	unsigned long size = get_vm_area_size(area);
+	unsigned int page_shift = area->page_shift;
+	unsigned int shift = page_shift + PAGE_SHIFT;
 	unsigned int nr_pages, array_size, i;
 	const gfp_t nested_gfp = (gfp_mask & GFP_RECLAIM_MASK) | __GFP_ZERO;
 	const gfp_t alloc_mask = gfp_mask | __GFP_NOWARN;
 	const gfp_t highmem_mask = (gfp_mask & (GFP_DMA | GFP_DMA32)) ?
-					0 :
-					__GFP_HIGHMEM;
+					0 : __GFP_HIGHMEM;
 
-	nr_pages = get_vm_area_size(area) >> PAGE_SHIFT;
+	nr_pages = size >> shift;
 	array_size = (nr_pages * sizeof(struct page *));
 
 	area->nr_pages = nr_pages;
@@ -2569,10 +2621,8 @@ static void *__vmalloc_area_node(struct vm_struct *area, gfp_t gfp_mask,
 	for (i = 0; i < area->nr_pages; i++) {
 		struct page *page;
 
-		if (node == NUMA_NO_NODE)
-			page = alloc_page(alloc_mask|highmem_mask);
-		else
-			page = alloc_pages_node(node, alloc_mask|highmem_mask, 0);
+		page = alloc_pages_node(node,
+				alloc_mask|highmem_mask, page_shift);
 
 		if (unlikely(!page)) {
 			/* Successfully allocated i pages, free them in __vunmap() */
@@ -2584,8 +2634,9 @@ static void *__vmalloc_area_node(struct vm_struct *area, gfp_t gfp_mask,
 			cond_resched();
 	}
 
-	if (map_vm_area(area, prot, pages))
+	if (vmap_hpages_range(addr, addr + size, prot, pages, page_shift) < 0)
 		goto fail;
+
 	return area->addr;
 
 fail:
@@ -2619,22 +2670,39 @@ void *__vmalloc_node_range(unsigned long size, unsigned long align,
 			pgprot_t prot, unsigned long vm_flags, int node,
 			const void *caller)
 {
-	struct vm_struct *area;
+	struct vm_struct *area = NULL;
 	void *addr;
 	unsigned long real_size = size;
+	unsigned long real_align = align;
+	unsigned int shift = PAGE_SHIFT;
 
 	size = PAGE_ALIGN(size);
 	if (!size || (size >> PAGE_SHIFT) > totalram_pages())
 		goto fail;
 
+	if (IS_ENABLED(CONFIG_HAVE_ARCH_HUGE_VMAP)) {
+		unsigned long size_per_node;
+
+		size_per_node = size;
+		if (node == NUMA_NO_NODE)
+			size_per_node /= num_online_nodes();
+		if (size_per_node >= PMD_SIZE)
+			shift = PMD_SHIFT;
+	}
+again:
+	align = max(real_align, 1UL << shift);
+	size = ALIGN(real_size, align);
+
 	area = __get_vm_area_node(size, align, VM_ALLOC | VM_UNINITIALIZED |
 				vm_flags, start, end, node, gfp_mask, caller);
 	if (!area)
 		goto fail;
 
+	area->page_shift = shift - PAGE_SHIFT;
+
 	addr = __vmalloc_area_node(area, gfp_mask, prot, node);
 	if (!addr)
-		return NULL;
+		goto fail;
 
 	/*
 	 * In this function, newly allocated vm_struct has VM_UNINITIALIZED
@@ -2648,8 +2716,16 @@ void *__vmalloc_node_range(unsigned long size, unsigned long align,
 	return addr;
 
 fail:
-	warn_alloc(gfp_mask, NULL,
+	if (shift == PMD_SHIFT) {
+		shift = PAGE_SHIFT;
+		goto again;
+	}
+
+	if (!area) {
+		/* Warn for area allocation, page allocations already warn */
+		warn_alloc(gfp_mask, NULL,
 			  "vmalloc: allocation failure: %lu bytes", real_size);
+	}
 	return NULL;
 }
 
-- 
2.20.1

