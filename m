Return-Path: <SRS0=idO3=TP=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-6.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SPF_PASS,
	USER_AGENT_GIT autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 815BEC04E53
	for <linux-mm@archiver.kernel.org>; Wed, 15 May 2019 13:21:25 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 27F5D20843
	for <linux-mm@archiver.kernel.org>; Wed, 15 May 2019 13:21:25 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="fLMePcIC"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 27F5D20843
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id BD6476B0008; Wed, 15 May 2019 09:21:24 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id B5E026B000A; Wed, 15 May 2019 09:21:24 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id A283A6B000C; Wed, 15 May 2019 09:21:24 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 689896B0008
	for <linux-mm@kvack.org>; Wed, 15 May 2019 09:21:24 -0400 (EDT)
Received: by mail-pl1-f198.google.com with SMTP id b69so1718064plb.9
        for <linux-mm@kvack.org>; Wed, 15 May 2019 06:21:24 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=ip56oQp/MiPwbfoD/lJd9v+rKbeF28/RCtEcjd99m7M=;
        b=IPd0s26v0gq48HklCR5FBF0FCaDYjICGSEzCnIL+Q/qgahDJEpDD0hynkHa3aDkO8J
         sPJtqagqYf5jG3WMEX9094PRdyh7big8xv+wNhSp0gUKeTTXs3XYfmDH2OxWcQ9GrPM3
         poZSFqaQjWppr9Q/SL8M9N9RCt6SvahLJen/la6qcQkyqFy08e9oQpli7PTKpIedNi44
         d9fnDHo3LJag8qwrHOIjdnN2B5USNDQVBTAKmbfkjP9jyxhXLiGiZ+tQ9gUeOSdR5zlw
         f1NNzgOJJoOfFX9h+wiqFhzUPhmhyE+YoqorShbpB9SwxJGV5+h3o3ZYUQ+rjWQLxXm4
         bVMw==
X-Gm-Message-State: APjAAAX/Cn6pY6dD73hHlee7q/3CTpjzRPIgJe3L98+Yv6Trm231PGCj
	duHqtuPjNTO62xh3hwganWDOhYKmReiBxhY5kw8SH0orMODb4BxI64KXipuUekBqvrPlyNsIbHv
	sd7ZQPOFsO9BdpXGTBDfRc1q5k7lsgMmgohkYswtIgKsvHdKj8EuuimlL2FNBySUCOw==
X-Received: by 2002:a17:902:2883:: with SMTP id f3mr18193618plb.26.1557926484074;
        Wed, 15 May 2019 06:21:24 -0700 (PDT)
X-Received: by 2002:a17:902:2883:: with SMTP id f3mr18193534plb.26.1557926482999;
        Wed, 15 May 2019 06:21:22 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1557926482; cv=none;
        d=google.com; s=arc-20160816;
        b=ceMbgGjdcaifuQGIoKlpIcS/E3aUd0yhqAAWPx+C8dR+XBRZ71F/qwMjtNcvZsrplT
         8Ic3fnykr6VGiwm0xUfly/7h2MhHVSws0qLpG+FVLfuf3sBgi4BaWwdh1Z3D3Q/hZ1+H
         0KZoWq9czewLdfzlJRo+H0UM9owph9dgaFtCTAlyAb8cT37jIrdCwC7pWOYVNFBiLj+T
         CkrOfHoRMAZkFlpdtx+717AU+0L0VKgN8czrBMSBUZASU25I6GXzWVkqMNQEgbNuN2b4
         Z4RvkngZcyNQ5MvsDQHf9+BRcQb63sUBeOIvzfWt4D0ZWGl9u6rrVJiI0FfhVsnYsezg
         JdGw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=ip56oQp/MiPwbfoD/lJd9v+rKbeF28/RCtEcjd99m7M=;
        b=jw8xLdjGroZ15fikLUTxhd0ijwG26hBRt1LlXpijHtlY9VGCMx7XHa7AhF3CzpWQAR
         rCh/MPb3IrXj507UA15iBN+izLWvnQXTVGvjO1Xw/nLplZWYVL2W/AOWkhc8Bw0pdftQ
         QAeV7QYmfkWry1T9aZs/PL+soBhQsszwjCPKfqIUpZWCUi8FsmnYkmFA9XnKKGr5Scs2
         j9otxl0Tudnauyx60RbAe3vcsmDJhhlLb4gcPybanPizoxZ/4SW7OeNjbDKBlDPWC7w3
         CHT+UW1DAmL1ZoPG025v2SOuLnxUCzw2assE139sxGWZGbJeNFfVvkx+keRFkoLZIecp
         S6NA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=fLMePcIC;
       spf=pass (google.com: domain of npiggin@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=npiggin@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id s193sor2401716pfs.6.2019.05.15.06.21.22
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 15 May 2019 06:21:22 -0700 (PDT)
Received-SPF: pass (google.com: domain of npiggin@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=fLMePcIC;
       spf=pass (google.com: domain of npiggin@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=npiggin@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:cc:subject:date:message-id:in-reply-to:references
         :mime-version:content-transfer-encoding;
        bh=ip56oQp/MiPwbfoD/lJd9v+rKbeF28/RCtEcjd99m7M=;
        b=fLMePcICUHw6bk34/HXTSNEnZQbib95S4xjsXp2eaJHwSjzUE84qBl+TWgWMe/Pdor
         y0sz+OT/XjfRQrRYK3LAU1EZGMMqgZ4M/T2tMhbmreGnDXtxAWDLvgVWQbwvl3fswdf4
         FCfcJqKFs624EhoATPsqTNVdwsNi+qhQ7tVFXSK/2548PgibNFqugO77ElNnmfr+OE4j
         6G51bHLaSHvAox0YBnbspdV1V7icCN96rCQj25rhHVbPzmBMw9VOxtIMtSyjDGJHAipB
         x2lWSS7PMTp0MRVljrUt+p+MIlstq8t7yr4XahdjehAreJ3+NNiGkE4UuAGqil3hN1SC
         3HVg==
X-Google-Smtp-Source: APXvYqw0njhCj9KpkSNJkxMjl1+53gGa9zdHsWSP7PpJ5b02y8wyAiMtjyVWx7Mmq1iIEDkXr0Zt5Q==
X-Received: by 2002:aa7:8a87:: with SMTP id a7mr9083441pfc.53.1557926482683;
        Wed, 15 May 2019 06:21:22 -0700 (PDT)
Received: from bobo.local0.net (115-64-240-98.tpgi.com.au. [115.64.240.98])
        by smtp.gmail.com with ESMTPSA id a19sm2784459pgm.46.2019.05.15.06.21.20
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 May 2019 06:21:22 -0700 (PDT)
From: Nicholas Piggin <npiggin@gmail.com>
To: linuxppc-dev@lists.ozlabs.org,
	linux-mm@kvack.org
Cc: Nicholas Piggin <npiggin@gmail.com>,
	Linus Torvalds <torvalds@linux-foundation.org>
Subject: [RFC PATCH 3/5] mm/vmalloc: Hugepage vmalloc mappings
Date: Wed, 15 May 2019 23:19:42 +1000
Message-Id: <20190515131944.12489-3-npiggin@gmail.com>
X-Mailer: git-send-email 2.20.1
In-Reply-To: <20190515131944.12489-1-npiggin@gmail.com>
References: <20190515131944.12489-1-npiggin@gmail.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This appears to help cached git diff performance by about 5% on a
POWER9 (with 32MB dentry cache hash).

  Profiling git diff dTLB misses with a vanilla kernel:

  81.75%  git      [kernel.vmlinux]    [k] __d_lookup_rcu
   7.21%  git      [kernel.vmlinux]    [k] strncpy_from_user
   1.77%  git      [kernel.vmlinux]    [k] find_get_entry
   1.59%  git      [kernel.vmlinux]    [k] kmem_cache_free

            40,168      dTLB-miss
       0.100342754 seconds time elapsed

After this patch (and the subsequent powerpc HUGE_VMAP patches), the
dentry cache hash gets mapped with 2MB pages:

             2,987      dTLB-miss
       0.095933138 seconds time elapsed

elapsed time improvement isn't too scientific but seems consistent,
TLB misses certainly improves an order of magnitude. My laptop
takes a lot of misses here too, so x86 would be interesting to test,
I think it should just work there.

---
 include/linux/vmalloc.h |  1 +
 mm/vmalloc.c            | 87 +++++++++++++++++++++++++++--------------
 2 files changed, 59 insertions(+), 29 deletions(-)

diff --git a/include/linux/vmalloc.h b/include/linux/vmalloc.h
index c6eebb839552..029635560306 100644
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
index e5e9e1fcac01..c9ba88768bca 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -216,32 +216,34 @@ static int vmap_p4d_range(pgd_t *pgd, unsigned long addr,
  * Ie. pte at addr+N*PAGE_SIZE shall point to pfn corresponding to pages[N]
  */
 static int vmap_page_range_noflush(unsigned long start, unsigned long end,
-				   pgprot_t prot, struct page **pages)
+				   pgprot_t prot, struct page **pages,
+				   unsigned int page_shift)
 {
-	pgd_t *pgd;
-	unsigned long next;
 	unsigned long addr = start;
-	int err = 0;
-	int nr = 0;
+	unsigned int i, nr = (end - start) >> (PAGE_SHIFT + page_shift);
 
-	BUG_ON(addr >= end);
-	pgd = pgd_offset_k(addr);
-	do {
-		next = pgd_addr_end(addr, end);
-		err = vmap_p4d_range(pgd, addr, next, prot, pages, &nr);
+	for (i = 0; i < nr; i++) {
+		int err;
+
+		err = ioremap_page_range(addr,
+					addr + (PAGE_SIZE << page_shift),
+					__pa(page_address(pages[i])), prot);
 		if (err)
 			return err;
-	} while (pgd++, addr = next, addr != end);
+
+		addr += PAGE_SIZE << page_shift;
+	}
 
 	return nr;
 }
 
 static int vmap_page_range(unsigned long start, unsigned long end,
-			   pgprot_t prot, struct page **pages)
+			   pgprot_t prot, struct page **pages,
+			   unsigned int page_shift)
 {
 	int ret;
 
-	ret = vmap_page_range_noflush(start, end, prot, pages);
+	ret = vmap_page_range_noflush(start, end, prot, pages, page_shift);
 	flush_cache_vmap(start, end);
 	return ret;
 }
@@ -1189,7 +1191,7 @@ void *vm_map_ram(struct page **pages, unsigned int count, int node, pgprot_t pro
 		addr = va->va_start;
 		mem = (void *)addr;
 	}
-	if (vmap_page_range(addr, addr + size, prot, pages) < 0) {
+	if (vmap_page_range(addr, addr + size, prot, pages, 0) < 0) {
 		vm_unmap_ram(mem, count);
 		return NULL;
 	}
@@ -1305,7 +1307,7 @@ void __init vmalloc_init(void)
 int map_kernel_range_noflush(unsigned long addr, unsigned long size,
 			     pgprot_t prot, struct page **pages)
 {
-	return vmap_page_range_noflush(addr, addr + size, prot, pages);
+	return vmap_page_range_noflush(addr, addr + size, prot, pages, 0);
 }
 
 /**
@@ -1352,7 +1354,7 @@ int map_vm_area(struct vm_struct *area, pgprot_t prot, struct page **pages)
 	unsigned long end = addr + get_vm_area_size(area);
 	int err;
 
-	err = vmap_page_range(addr, end, prot, pages);
+	err = vmap_page_range(addr, end, prot, pages, 0);
 
 	return err > 0 ? 0 : err;
 }
@@ -1395,8 +1397,9 @@ static struct vm_struct *__get_vm_area_node(unsigned long size,
 		return NULL;
 
 	if (flags & VM_IOREMAP)
-		align = 1ul << clamp_t(int, get_count_order_long(size),
-				       PAGE_SHIFT, IOREMAP_MAX_ORDER);
+		align = max(align,
+				1ul << clamp_t(int, get_count_order_long(size),
+				       PAGE_SHIFT, IOREMAP_MAX_ORDER));
 
 	area = kzalloc_node(sizeof(*area), gfp_mask & GFP_RECLAIM_MASK, node);
 	if (unlikely(!area))
@@ -1608,7 +1611,7 @@ static void __vunmap(const void *addr, int deallocate_pages)
 			struct page *page = area->pages[i];
 
 			BUG_ON(!page);
-			__free_pages(page, 0);
+			__free_pages(page, area->page_shift);
 		}
 
 		kvfree(area->pages);
@@ -1751,14 +1754,17 @@ static void *__vmalloc_area_node(struct vm_struct *area, gfp_t gfp_mask,
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
@@ -1779,10 +1785,8 @@ static void *__vmalloc_area_node(struct vm_struct *area, gfp_t gfp_mask,
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
@@ -1794,8 +1798,9 @@ static void *__vmalloc_area_node(struct vm_struct *area, gfp_t gfp_mask,
 			cond_resched();
 	}
 
-	if (map_vm_area(area, prot, pages))
+	if (vmap_page_range(addr, addr + size, prot, pages, page_shift) < 0)
 		goto fail;
+
 	return area->addr;
 
 fail:
@@ -1832,19 +1837,35 @@ void *__vmalloc_node_range(unsigned long size, unsigned long align,
 	struct vm_struct *area;
 	void *addr;
 	unsigned long real_size = size;
+	unsigned long real_align = align;
+	unsigned long size_per_node;
+	unsigned int shift;
 
 	size = PAGE_ALIGN(size);
 	if (!size || (size >> PAGE_SHIFT) > totalram_pages())
 		goto fail;
 
+	size_per_node = size;
+	if (node == NUMA_NO_NODE)
+		size_per_node /= num_online_nodes();
+	if (size_per_node >= PMD_SIZE)
+		shift = PMD_SHIFT;
+	else
+		shift = PAGE_SHIFT;
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
@@ -1858,8 +1879,16 @@ void *__vmalloc_node_range(unsigned long size, unsigned long align,
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

