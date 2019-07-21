Return-Path: <SRS0=x6gJ=VS=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-9.6 required=3.0 tests=DKIM_INVALID,DKIM_SIGNED,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_HELO_NONE,SPF_PASS,USER_AGENT_GIT autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id AE0F6C76196
	for <linux-mm@archiver.kernel.org>; Sun, 21 Jul 2019 10:46:20 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 5AA762085A
	for <linux-mm@archiver.kernel.org>; Sun, 21 Jul 2019 10:46:20 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=infradead.org header.i=@infradead.org header.b="ILI7Ai/q"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 5AA762085A
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=infradead.org
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id F41108E0007; Sun, 21 Jul 2019 06:46:19 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id ED0C78E0005; Sun, 21 Jul 2019 06:46:19 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id C0E158E0007; Sun, 21 Jul 2019 06:46:19 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 81C2F8E0005
	for <linux-mm@kvack.org>; Sun, 21 Jul 2019 06:46:19 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id m17so12731832pgh.21
        for <linux-mm@kvack.org>; Sun, 21 Jul 2019 03:46:19 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:cc:subject:date
         :message-id:in-reply-to:references:mime-version
         :content-transfer-encoding;
        bh=GN6prBEc9OxXBozwmtQx/sYg0ub34bNOmdwtjSsuhI4=;
        b=czL7CHaPA1sTY/qyO5SgV/JYyYC+uqe4f3YC56PyEOsGQMOwAeEIJwhBwoFIzNuBcU
         qpz3WOi6LJ67t6GwJRbI3wFDs4DgVBiBv+uSk6Zaq1Itc7UazPC2xkVfcD3+njZPVWjb
         7XMuqKG+p77Co/JK62H+HTbb3lK9zF5HPLN5hjMAl0Mp1AJvsE5D6ZutaycwhRAkUfin
         nd5wkwcX1JBOAgyNpmtJhILj8BPrujlausymBajf6RnyY9SDQhkCapYnHdLrR7KU0qyZ
         I/4mZaAeIT/4xmCK8waDOH8c4/oGIrnISE+kqVHA62WtuyKpAKJ0F1YnwR/Up4D0xOAM
         +wCw==
X-Gm-Message-State: APjAAAX7HQ+e4yyDPHm7sDHR/IaEOSFwL1+IcyHqdTMf0xw2BV4kTPJH
	SnRxLUhJrqps6lt1YfATpz1CsCgRBv16h1sryU8APXqhiu4/KyFL/HcfQ8yc9v8PoLWSSeNLhuw
	nexrcc3ijEUDAMrdud8SeDHBwUIK18otnS6HBaQHiP3ysfd+mfqzLAEh99JHWV2zFAQ==
X-Received: by 2002:a65:4b8b:: with SMTP id t11mr65573477pgq.130.1563705978074;
        Sun, 21 Jul 2019 03:46:18 -0700 (PDT)
X-Google-Smtp-Source: APXvYqxxkDQpvJZ4SvANBZ8IP/OPHubwRzMTKXM3D01Ep8Ac975G6vCOZ3o2nBa+5Kl02JaQVcku
X-Received: by 2002:a65:4b8b:: with SMTP id t11mr65573406pgq.130.1563705976866;
        Sun, 21 Jul 2019 03:46:16 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1563705976; cv=none;
        d=google.com; s=arc-20160816;
        b=j30vwuhLP6SjF8A15gte7RqhEEYuGQDHOcF8rXwVTAiIoL8VWSskA8NpZivgW2bnNr
         GsEsWuEK+bDYgS3f800tlLWfth9npzP94QUTHsA076o33wHzS300HNIgDCbU89bvquZr
         g/edhdQPgM2a3lUYUzcmBBthGJHGFH6bZ6wBq2GuB6YXvO7xWQphJO68Ds3bZb6jhse8
         GhbXe44JrJBWoqLqgywdFMTE6iB+TzhdXkZR2qPBok3zFo/aoHk64W0MwfLfHFQKF4Vj
         bFaKkDlI+7V4B8IIhtde8V2ixzaq+mbTIwQ23hMXI5xgeWvmwKdPsWrYwOuEqroE3/iR
         dxJw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-transfer-encoding:mime-version:references:in-reply-to
         :message-id:date:subject:cc:to:from:dkim-signature;
        bh=GN6prBEc9OxXBozwmtQx/sYg0ub34bNOmdwtjSsuhI4=;
        b=ANQgg8Q05Z3DC703hYuvbGm/5midbT2FA1LJI9B7JgBS+Q9GDteanwB6R+EOXPFg0J
         egwYcJQzGXqYUlJvwsmJH+AvfqYcDhFv+Uq/rfsAPDMci09e26sQ8UWK1Ccld404gnf2
         mM7zeW7+8gQlkdqxXLVBOhC/hJsNQoUpIGPsD9mOYHxQAV9/nGl8S4oJUtIv+XRTCVqN
         eLBMkd6vlx22uEYLBkpZs3VzhZgqb+Lxp8K+aQOhGUVOrxOYiykbnvhwzhg3LIod6Evf
         839Z58CUhAvxclyc3wzmhkCLSDOkLCbRzSu4ox38MDTv5I/rXy+6fT1e7Hj1yQ6RAJFw
         /vAg==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b="ILI7Ai/q";
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id c18si8293015plo.316.2019.07.21.03.46.15
        for <linux-mm@kvack.org>
        (version=TLS1_3 cipher=AEAD-AES256-GCM-SHA384 bits=256/256);
        Sun, 21 Jul 2019 03:46:15 -0700 (PDT)
Received-SPF: pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) client-ip=2607:7c80:54:e::133;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@infradead.org header.s=bombadil.20170209 header.b="ILI7Ai/q";
       spf=pass (google.com: best guess record for domain of willy@infradead.org designates 2607:7c80:54:e::133 as permitted sender) smtp.mailfrom=willy@infradead.org
DKIM-Signature: v=1; a=rsa-sha256; q=dns/txt; c=relaxed/relaxed;
	d=infradead.org; s=bombadil.20170209; h=Content-Transfer-Encoding:
	MIME-Version:References:In-Reply-To:Message-Id:Date:Subject:Cc:To:From:Sender
	:Reply-To:Content-Type:Content-ID:Content-Description:Resent-Date:Resent-From
	:Resent-Sender:Resent-To:Resent-Cc:Resent-Message-ID:List-Id:List-Help:
	List-Unsubscribe:List-Subscribe:List-Post:List-Owner:List-Archive;
	bh=GN6prBEc9OxXBozwmtQx/sYg0ub34bNOmdwtjSsuhI4=; b=ILI7Ai/qVKkWPtUdzO9bTbn4/i
	F3TPPZOUt9+oFU53lX3CqV/4DTd4gBxLNIXXxzVKeCP2He6eAOO5k2FhnIT9DgJUuu4ApnAVxyyUh
	cNWRvhTzvE9loorPa2HwPuo5Mw2Z1o+wDKXab3Lo8jMO+LM5dFsHnpILAbFlHn25W6l6uLwrRaEgh
	9t2iKC8MvqX0HKhGS+j+42Oyrn2daIoF4GY+GZYwKYamHOpZ8UMMzvIMEJeooiNQtFGK//ZyPIjlA
	yQT2oZuEGxQ4rOlCaVMtRIkBZ28/CvlD8FJvv06G4bmj6zTNDR/Rddw+ASNAlBlakEmgfuwcK6KtI
	rXerpmIA==;
Received: from willy by bombadil.infradead.org with local (Exim 4.92 #3 (Red Hat Linux))
	id 1hp9M6-000500-Lw; Sun, 21 Jul 2019 10:46:14 +0000
From: Matthew Wilcox <willy@infradead.org>
To: Andrew Morton <akpm@linux-foundation.org>,
	linux-mm@kvack.org
Cc: Matthew Wilcox <willy@infradead.org>,
	Michal Hocko <mhocko@suse.com>
Subject: [PATCH v2 1/3] mm: Introduce page_size()
Date: Sun, 21 Jul 2019 03:46:10 -0700
Message-Id: <20190721104612.19120-2-willy@infradead.org>
X-Mailer: git-send-email 2.21.0
In-Reply-To: <20190721104612.19120-1-willy@infradead.org>
References: <20190721104612.19120-1-willy@infradead.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Matthew Wilcox (Oracle) <willy@infradead.org>

It's unnecessarily hard to find out the size of a potentially huge page.
Replace 'PAGE_SIZE << compound_order(page)' with page_size(page).

Signed-off-by: Matthew Wilcox (Oracle) <willy@infradead.org>
Acked-by: Michal Hocko <mhocko@suse.com>
---
 arch/arm/mm/flush.c                           |  3 +--
 arch/arm64/mm/flush.c                         |  3 +--
 arch/ia64/mm/init.c                           |  2 +-
 drivers/crypto/chelsio/chtls/chtls_io.c       |  5 ++---
 drivers/staging/android/ion/ion_system_heap.c |  4 ++--
 drivers/target/tcm_fc/tfc_io.c                |  3 +--
 fs/io_uring.c                                 |  2 +-
 include/linux/hugetlb.h                       |  2 +-
 include/linux/mm.h                            |  6 ++++++
 lib/iov_iter.c                                |  2 +-
 mm/kasan/common.c                             |  8 +++-----
 mm/nommu.c                                    |  2 +-
 mm/page_vma_mapped.c                          |  3 +--
 mm/rmap.c                                     |  6 ++----
 mm/slob.c                                     |  2 +-
 mm/slub.c                                     | 18 +++++++++---------
 net/xdp/xsk.c                                 |  2 +-
 17 files changed, 35 insertions(+), 38 deletions(-)

diff --git a/arch/arm/mm/flush.c b/arch/arm/mm/flush.c
index 6ecbda87ee46..4c7ebe094a83 100644
--- a/arch/arm/mm/flush.c
+++ b/arch/arm/mm/flush.c
@@ -204,8 +204,7 @@ void __flush_dcache_page(struct address_space *mapping, struct page *page)
 	 * coherent with the kernels mapping.
 	 */
 	if (!PageHighMem(page)) {
-		size_t page_size = PAGE_SIZE << compound_order(page);
-		__cpuc_flush_dcache_area(page_address(page), page_size);
+		__cpuc_flush_dcache_area(page_address(page), page_size(page));
 	} else {
 		unsigned long i;
 		if (cache_is_vipt_nonaliasing()) {
diff --git a/arch/arm64/mm/flush.c b/arch/arm64/mm/flush.c
index dc19300309d2..ac485163a4a7 100644
--- a/arch/arm64/mm/flush.c
+++ b/arch/arm64/mm/flush.c
@@ -56,8 +56,7 @@ void __sync_icache_dcache(pte_t pte)
 	struct page *page = pte_page(pte);
 
 	if (!test_and_set_bit(PG_dcache_clean, &page->flags))
-		sync_icache_aliases(page_address(page),
-				    PAGE_SIZE << compound_order(page));
+		sync_icache_aliases(page_address(page), page_size(page));
 }
 EXPORT_SYMBOL_GPL(__sync_icache_dcache);
 
diff --git a/arch/ia64/mm/init.c b/arch/ia64/mm/init.c
index aae75fd7b810..e97e24816bd4 100644
--- a/arch/ia64/mm/init.c
+++ b/arch/ia64/mm/init.c
@@ -63,7 +63,7 @@ __ia64_sync_icache_dcache (pte_t pte)
 	if (test_bit(PG_arch_1, &page->flags))
 		return;				/* i-cache is already coherent with d-cache */
 
-	flush_icache_range(addr, addr + (PAGE_SIZE << compound_order(page)));
+	flush_icache_range(addr, addr + page_size(page));
 	set_bit(PG_arch_1, &page->flags);	/* mark page as clean */
 }
 
diff --git a/drivers/crypto/chelsio/chtls/chtls_io.c b/drivers/crypto/chelsio/chtls/chtls_io.c
index 551bca6fef24..925be5942895 100644
--- a/drivers/crypto/chelsio/chtls/chtls_io.c
+++ b/drivers/crypto/chelsio/chtls/chtls_io.c
@@ -1078,7 +1078,7 @@ int chtls_sendmsg(struct sock *sk, struct msghdr *msg, size_t size)
 			bool merge;
 
 			if (page)
-				pg_size <<= compound_order(page);
+				pg_size = page_size(page);
 			if (off < pg_size &&
 			    skb_can_coalesce(skb, i, page, off)) {
 				merge = 1;
@@ -1105,8 +1105,7 @@ int chtls_sendmsg(struct sock *sk, struct msghdr *msg, size_t size)
 							   __GFP_NORETRY,
 							   order);
 					if (page)
-						pg_size <<=
-							compound_order(page);
+						pg_size <<= order;
 				}
 				if (!page) {
 					page = alloc_page(gfp);
diff --git a/drivers/staging/android/ion/ion_system_heap.c b/drivers/staging/android/ion/ion_system_heap.c
index aa8d8425be25..b83a1d16bd89 100644
--- a/drivers/staging/android/ion/ion_system_heap.c
+++ b/drivers/staging/android/ion/ion_system_heap.c
@@ -120,7 +120,7 @@ static int ion_system_heap_allocate(struct ion_heap *heap,
 		if (!page)
 			goto free_pages;
 		list_add_tail(&page->lru, &pages);
-		size_remaining -= PAGE_SIZE << compound_order(page);
+		size_remaining -= page_size(page);
 		max_order = compound_order(page);
 		i++;
 	}
@@ -133,7 +133,7 @@ static int ion_system_heap_allocate(struct ion_heap *heap,
 
 	sg = table->sgl;
 	list_for_each_entry_safe(page, tmp_page, &pages, lru) {
-		sg_set_page(sg, page, PAGE_SIZE << compound_order(page), 0);
+		sg_set_page(sg, page, page_size(page), 0);
 		sg = sg_next(sg);
 		list_del(&page->lru);
 	}
diff --git a/drivers/target/tcm_fc/tfc_io.c b/drivers/target/tcm_fc/tfc_io.c
index a254792d882c..1354a157e9af 100644
--- a/drivers/target/tcm_fc/tfc_io.c
+++ b/drivers/target/tcm_fc/tfc_io.c
@@ -136,8 +136,7 @@ int ft_queue_data_in(struct se_cmd *se_cmd)
 					   page, off_in_page, tlen);
 			fr_len(fp) += tlen;
 			fp_skb(fp)->data_len += tlen;
-			fp_skb(fp)->truesize +=
-					PAGE_SIZE << compound_order(page);
+			fp_skb(fp)->truesize += page_size(page);
 		} else {
 			BUG_ON(!page);
 			from = kmap_atomic(page + (mem_off >> PAGE_SHIFT));
diff --git a/fs/io_uring.c b/fs/io_uring.c
index e2a66e12fbc6..c55d8b411d2a 100644
--- a/fs/io_uring.c
+++ b/fs/io_uring.c
@@ -3084,7 +3084,7 @@ static int io_uring_mmap(struct file *file, struct vm_area_struct *vma)
 	}
 
 	page = virt_to_head_page(ptr);
-	if (sz > (PAGE_SIZE << compound_order(page)))
+	if (sz > page_size(page))
 		return -EINVAL;
 
 	pfn = virt_to_phys(ptr) >> PAGE_SHIFT;
diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
index edfca4278319..53fc34f930d0 100644
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -454,7 +454,7 @@ static inline pte_t arch_make_huge_pte(pte_t entry, struct vm_area_struct *vma,
 static inline struct hstate *page_hstate(struct page *page)
 {
 	VM_BUG_ON_PAGE(!PageHuge(page), page);
-	return size_to_hstate(PAGE_SIZE << compound_order(page));
+	return size_to_hstate(page_size(page));
 }
 
 static inline unsigned hstate_index_to_shift(unsigned index)
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 0334ca97c584..899dfcf7c23d 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -805,6 +805,12 @@ static inline void set_compound_order(struct page *page, unsigned int order)
 	page[1].compound_order = order;
 }
 
+/* Returns the number of bytes in this potentially compound page. */
+static inline unsigned long page_size(struct page *page)
+{
+	return PAGE_SIZE << compound_order(page);
+}
+
 void free_compound_page(struct page *page);
 
 #ifdef CONFIG_MMU
diff --git a/lib/iov_iter.c b/lib/iov_iter.c
index f1e0569b4539..639d5e7014c1 100644
--- a/lib/iov_iter.c
+++ b/lib/iov_iter.c
@@ -878,7 +878,7 @@ static inline bool page_copy_sane(struct page *page, size_t offset, size_t n)
 	head = compound_head(page);
 	v += (page - head) << PAGE_SHIFT;
 
-	if (likely(n <= v && v <= (PAGE_SIZE << compound_order(head))))
+	if (likely(n <= v && v <= (page_size(head))))
 		return true;
 	WARN_ON(1);
 	return false;
diff --git a/mm/kasan/common.c b/mm/kasan/common.c
index 2277b82902d8..a929a3b9444d 100644
--- a/mm/kasan/common.c
+++ b/mm/kasan/common.c
@@ -321,8 +321,7 @@ void kasan_poison_slab(struct page *page)
 
 	for (i = 0; i < (1 << compound_order(page)); i++)
 		page_kasan_tag_reset(page + i);
-	kasan_poison_shadow(page_address(page),
-			PAGE_SIZE << compound_order(page),
+	kasan_poison_shadow(page_address(page), page_size(page),
 			KASAN_KMALLOC_REDZONE);
 }
 
@@ -518,7 +517,7 @@ void * __must_check kasan_kmalloc_large(const void *ptr, size_t size,
 	page = virt_to_page(ptr);
 	redzone_start = round_up((unsigned long)(ptr + size),
 				KASAN_SHADOW_SCALE_SIZE);
-	redzone_end = (unsigned long)ptr + (PAGE_SIZE << compound_order(page));
+	redzone_end = (unsigned long)ptr + page_size(page);
 
 	kasan_unpoison_shadow(ptr, size);
 	kasan_poison_shadow((void *)redzone_start, redzone_end - redzone_start,
@@ -554,8 +553,7 @@ void kasan_poison_kfree(void *ptr, unsigned long ip)
 			kasan_report_invalid_free(ptr, ip);
 			return;
 		}
-		kasan_poison_shadow(ptr, PAGE_SIZE << compound_order(page),
-				KASAN_FREE_PAGE);
+		kasan_poison_shadow(ptr, page_size(page), KASAN_FREE_PAGE);
 	} else {
 		__kasan_slab_free(page->slab_cache, ptr, ip, false);
 	}
diff --git a/mm/nommu.c b/mm/nommu.c
index fed1b6e9c89b..99b7ec318824 100644
--- a/mm/nommu.c
+++ b/mm/nommu.c
@@ -108,7 +108,7 @@ unsigned int kobjsize(const void *objp)
 	 * The ksize() function is only guaranteed to work for pointers
 	 * returned by kmalloc(). So handle arbitrary pointers here.
 	 */
-	return PAGE_SIZE << compound_order(page);
+	return page_size(page);
 }
 
 /**
diff --git a/mm/page_vma_mapped.c b/mm/page_vma_mapped.c
index 11df03e71288..eff4b4520c8d 100644
--- a/mm/page_vma_mapped.c
+++ b/mm/page_vma_mapped.c
@@ -153,8 +153,7 @@ bool page_vma_mapped_walk(struct page_vma_mapped_walk *pvmw)
 
 	if (unlikely(PageHuge(pvmw->page))) {
 		/* when pud is not present, pte will be NULL */
-		pvmw->pte = huge_pte_offset(mm, pvmw->address,
-					    PAGE_SIZE << compound_order(page));
+		pvmw->pte = huge_pte_offset(mm, pvmw->address, page_size(page));
 		if (!pvmw->pte)
 			return false;
 
diff --git a/mm/rmap.c b/mm/rmap.c
index e5dfe2ae6b0d..09ce05c481fc 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -898,8 +898,7 @@ static bool page_mkclean_one(struct page *page, struct vm_area_struct *vma,
 	 */
 	mmu_notifier_range_init(&range, MMU_NOTIFY_PROTECTION_PAGE,
 				0, vma, vma->vm_mm, address,
-				min(vma->vm_end, address +
-				    (PAGE_SIZE << compound_order(page))));
+				min(vma->vm_end, address + page_size(page)));
 	mmu_notifier_invalidate_range_start(&range);
 
 	while (page_vma_mapped_walk(&pvmw)) {
@@ -1374,8 +1373,7 @@ static bool try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 	 */
 	mmu_notifier_range_init(&range, MMU_NOTIFY_CLEAR, 0, vma, vma->vm_mm,
 				address,
-				min(vma->vm_end, address +
-				    (PAGE_SIZE << compound_order(page))));
+				min(vma->vm_end, address + page_size(page)));
 	if (PageHuge(page)) {
 		/*
 		 * If sharing is possible, start and end will be adjusted
diff --git a/mm/slob.c b/mm/slob.c
index 7f421d0ca9ab..cf377beab962 100644
--- a/mm/slob.c
+++ b/mm/slob.c
@@ -539,7 +539,7 @@ size_t __ksize(const void *block)
 
 	sp = virt_to_page(block);
 	if (unlikely(!PageSlab(sp)))
-		return PAGE_SIZE << compound_order(sp);
+		return page_size(sp);
 
 	align = max_t(size_t, ARCH_KMALLOC_MINALIGN, ARCH_SLAB_MINALIGN);
 	m = (unsigned int *)(block - align);
diff --git a/mm/slub.c b/mm/slub.c
index e6c030e47364..1e8e20a99660 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -829,7 +829,7 @@ static int slab_pad_check(struct kmem_cache *s, struct page *page)
 		return 1;
 
 	start = page_address(page);
-	length = PAGE_SIZE << compound_order(page);
+	length = page_size(page);
 	end = start + length;
 	remainder = length % s->size;
 	if (!remainder)
@@ -1074,13 +1074,14 @@ static void setup_object_debug(struct kmem_cache *s, struct page *page,
 	init_tracking(s, object);
 }
 
-static void setup_page_debug(struct kmem_cache *s, void *addr, int order)
+static
+void setup_page_debug(struct kmem_cache *s, struct page *page, void *addr)
 {
 	if (!(s->flags & SLAB_POISON))
 		return;
 
 	metadata_access_enable();
-	memset(addr, POISON_INUSE, PAGE_SIZE << order);
+	memset(addr, POISON_INUSE, page_size(page));
 	metadata_access_disable();
 }
 
@@ -1340,8 +1341,8 @@ slab_flags_t kmem_cache_flags(unsigned int object_size,
 #else /* !CONFIG_SLUB_DEBUG */
 static inline void setup_object_debug(struct kmem_cache *s,
 			struct page *page, void *object) {}
-static inline void setup_page_debug(struct kmem_cache *s,
-			void *addr, int order) {}
+static inline
+void setup_page_debug(struct kmem_cache *s, struct page *page, void *addr) {}
 
 static inline int alloc_debug_processing(struct kmem_cache *s,
 	struct page *page, void *object, unsigned long addr) { return 0; }
@@ -1635,7 +1636,7 @@ static struct page *allocate_slab(struct kmem_cache *s, gfp_t flags, int node)
 	struct kmem_cache_order_objects oo = s->oo;
 	gfp_t alloc_gfp;
 	void *start, *p, *next;
-	int idx, order;
+	int idx;
 	bool shuffle;
 
 	flags &= gfp_allowed_mask;
@@ -1669,7 +1670,6 @@ static struct page *allocate_slab(struct kmem_cache *s, gfp_t flags, int node)
 
 	page->objects = oo_objects(oo);
 
-	order = compound_order(page);
 	page->slab_cache = s;
 	__SetPageSlab(page);
 	if (page_is_pfmemalloc(page))
@@ -1679,7 +1679,7 @@ static struct page *allocate_slab(struct kmem_cache *s, gfp_t flags, int node)
 
 	start = page_address(page);
 
-	setup_page_debug(s, start, order);
+	setup_page_debug(s, page, start);
 
 	shuffle = shuffle_freelist(s, page);
 
@@ -3926,7 +3926,7 @@ size_t __ksize(const void *object)
 
 	if (unlikely(!PageSlab(page))) {
 		WARN_ON(!PageCompound(page));
-		return PAGE_SIZE << compound_order(page);
+		return page_size(page);
 	}
 
 	return slab_ksize(page->slab_cache);
diff --git a/net/xdp/xsk.c b/net/xdp/xsk.c
index 59b57d708697..44bfb76fbad9 100644
--- a/net/xdp/xsk.c
+++ b/net/xdp/xsk.c
@@ -739,7 +739,7 @@ static int xsk_mmap(struct file *file, struct socket *sock,
 	/* Matches the smp_wmb() in xsk_init_queue */
 	smp_rmb();
 	qpg = virt_to_head_page(q->ring);
-	if (size > (PAGE_SIZE << compound_order(qpg)))
+	if (size > page_size(qpg))
 		return -EINVAL;
 
 	pfn = virt_to_phys(q->ring) >> PAGE_SHIFT;
-- 
2.20.1

