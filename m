Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f198.google.com (mail-pl1-f198.google.com [209.85.214.198])
	by kanga.kvack.org (Postfix) with ESMTP id 845708E005B
	for <linux-mm@kvack.org>; Mon, 31 Dec 2018 08:42:27 -0500 (EST)
Received: by mail-pl1-f198.google.com with SMTP id l9so21708279plt.7
        for <linux-mm@kvack.org>; Mon, 31 Dec 2018 05:42:27 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id z136si20578837pgz.28.2018.12.31.05.42.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Mon, 31 Dec 2018 05:42:25 -0800 (PST)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH] mm: Introduce page_size()
Date: Mon, 31 Dec 2018 05:42:23 -0800
Message-Id: <20181231134223.20765-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
Cc: Matthew Wilcox <willy@infradead.org>

It's unnecessarily hard to find out the size of a potentially huge page.
Replace 'PAGE_SIZE << compound_order(page)' with page_size(page).

Signed-off-by: Matthew Wilcox <willy@infradead.org>
---
 arch/arm/mm/flush.c                           | 3 +--
 arch/arm64/mm/flush.c                         | 3 +--
 arch/ia64/mm/init.c                           | 2 +-
 drivers/crypto/chelsio/chtls/chtls_io.c       | 5 ++---
 drivers/staging/android/ion/ion_system_heap.c | 4 ++--
 drivers/target/tcm_fc/tfc_io.c                | 3 +--
 include/linux/hugetlb.h                       | 2 +-
 include/linux/mm.h                            | 6 ++++++
 lib/iov_iter.c                                | 2 +-
 mm/kasan/kasan.c                              | 8 +++-----
 mm/nommu.c                                    | 2 +-
 mm/page_vma_mapped.c                          | 3 +--
 mm/rmap.c                                     | 4 ++--
 mm/slob.c                                     | 2 +-
 mm/slub.c                                     | 4 ++--
 net/xdp/xsk.c                                 | 2 +-
 16 files changed, 27 insertions(+), 28 deletions(-)

diff --git a/arch/arm/mm/flush.c b/arch/arm/mm/flush.c
index 58469623b0158..c68a120de28b4 100644
--- a/arch/arm/mm/flush.c
+++ b/arch/arm/mm/flush.c
@@ -207,8 +207,7 @@ void __flush_dcache_page(struct address_space *mapping, struct page *page)
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
index 30695a8681074..9822bd6955429 100644
--- a/arch/arm64/mm/flush.c
+++ b/arch/arm64/mm/flush.c
@@ -63,8 +63,7 @@ void __sync_icache_dcache(pte_t pte)
 	struct page *page = pte_page(pte);
 
 	if (!test_and_set_bit(PG_dcache_clean, &page->flags))
-		sync_icache_aliases(page_address(page),
-				    PAGE_SIZE << compound_order(page));
+		sync_icache_aliases(page_address(page), page_size(page));
 }
 EXPORT_SYMBOL_GPL(__sync_icache_dcache);
 
diff --git a/arch/ia64/mm/init.c b/arch/ia64/mm/init.c
index d5e12ff1d73cf..e31c578e9c96d 100644
--- a/arch/ia64/mm/init.c
+++ b/arch/ia64/mm/init.c
@@ -62,7 +62,7 @@ __ia64_sync_icache_dcache (pte_t pte)
 	if (test_bit(PG_arch_1, &page->flags))
 		return;				/* i-cache is already coherent with d-cache */
 
-	flush_icache_range(addr, addr + (PAGE_SIZE << compound_order(page)));
+	flush_icache_range(addr, addr + page_size(page));
 	set_bit(PG_arch_1, &page->flags);	/* mark page as clean */
 }
 
diff --git a/drivers/crypto/chelsio/chtls/chtls_io.c b/drivers/crypto/chelsio/chtls/chtls_io.c
index 18f553fcc1673..97bf5ba3a5439 100644
--- a/drivers/crypto/chelsio/chtls/chtls_io.c
+++ b/drivers/crypto/chelsio/chtls/chtls_io.c
@@ -1082,7 +1082,7 @@ int chtls_sendmsg(struct sock *sk, struct msghdr *msg, size_t size)
 			bool merge;
 
 			if (page)
-				pg_size <<= compound_order(page);
+				pg_size = page_size(page);
 			if (off < pg_size &&
 			    skb_can_coalesce(skb, i, page, off)) {
 				merge = 1;
@@ -1109,8 +1109,7 @@ int chtls_sendmsg(struct sock *sk, struct msghdr *msg, size_t size)
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
index 548bb02c0ca6b..3ac7488d893b9 100644
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
index 1eb1f58e00e49..83c1ec65dbccc 100644
--- a/drivers/target/tcm_fc/tfc_io.c
+++ b/drivers/target/tcm_fc/tfc_io.c
@@ -148,8 +148,7 @@ int ft_queue_data_in(struct se_cmd *se_cmd)
 					   page, off_in_page, tlen);
 			fr_len(fp) += tlen;
 			fp_skb(fp)->data_len += tlen;
-			fp_skb(fp)->truesize +=
-					PAGE_SIZE << compound_order(page);
+			fp_skb(fp)->truesize += page_size(page);
 		} else {
 			BUG_ON(!page);
 			from = kmap_atomic(page + (mem_off >> PAGE_SHIFT));
diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
index 087fd5f48c912..6140dc031b8c9 100644
--- a/include/linux/hugetlb.h
+++ b/include/linux/hugetlb.h
@@ -466,7 +466,7 @@ static inline pte_t arch_make_huge_pte(pte_t entry, struct vm_area_struct *vma,
 static inline struct hstate *page_hstate(struct page *page)
 {
 	VM_BUG_ON_PAGE(!PageHuge(page), page);
-	return size_to_hstate(PAGE_SIZE << compound_order(page));
+	return size_to_hstate(page_size(page));
 }
 
 static inline unsigned hstate_index_to_shift(unsigned index)
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 5411de93a363e..e920ef9927539 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -712,6 +712,12 @@ static inline void set_compound_order(struct page *page, unsigned int order)
 	page[1].compound_order = order;
 }
 
+/* Returns the number of bytes in this potentially compound page. */
+static inline unsigned long page_size(struct page *page)
+{
+	return (unsigned long)PAGE_SIZE << compound_order(page);
+}
+
 void free_compound_page(struct page *page);
 
 #ifdef CONFIG_MMU
diff --git a/lib/iov_iter.c b/lib/iov_iter.c
index 54c248526b55f..8910a368c3e1b 100644
--- a/lib/iov_iter.c
+++ b/lib/iov_iter.c
@@ -857,7 +857,7 @@ static inline bool page_copy_sane(struct page *page, size_t offset, size_t n)
 	struct page *head = compound_head(page);
 	size_t v = n + offset + page_address(page) - page_address(head);
 
-	if (likely(n <= v && v <= (PAGE_SIZE << compound_order(head))))
+	if (likely(n <= v && v <= (page_size(head))))
 		return true;
 	WARN_ON(1);
 	return false;
diff --git a/mm/kasan/kasan.c b/mm/kasan/kasan.c
index c3bd5209da380..9d2c9b11b49e9 100644
--- a/mm/kasan/kasan.c
+++ b/mm/kasan/kasan.c
@@ -396,8 +396,7 @@ size_t kasan_metadata_size(struct kmem_cache *cache)
 
 void kasan_poison_slab(struct page *page)
 {
-	kasan_poison_shadow(page_address(page),
-			PAGE_SIZE << compound_order(page),
+	kasan_poison_shadow(page_address(page), page_size(page),
 			KASAN_KMALLOC_REDZONE);
 }
 
@@ -569,7 +568,7 @@ void kasan_kmalloc_large(const void *ptr, size_t size, gfp_t flags)
 	page = virt_to_page(ptr);
 	redzone_start = round_up((unsigned long)(ptr + size),
 				KASAN_SHADOW_SCALE_SIZE);
-	redzone_end = (unsigned long)ptr + (PAGE_SIZE << compound_order(page));
+	redzone_end = (unsigned long)ptr + page_size(page);
 
 	kasan_unpoison_shadow(ptr, size);
 	kasan_poison_shadow((void *)redzone_start, redzone_end - redzone_start,
@@ -602,8 +601,7 @@ void kasan_poison_kfree(void *ptr, unsigned long ip)
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
index 749276beb1094..1603132273db8 100644
--- a/mm/nommu.c
+++ b/mm/nommu.c
@@ -107,7 +107,7 @@ unsigned int kobjsize(const void *objp)
 	 * The ksize() function is only guaranteed to work for pointers
 	 * returned by kmalloc(). So handle arbitrary pointers here.
 	 */
-	return PAGE_SIZE << compound_order(page);
+	return page_size(page);
 }
 
 static long __get_user_pages(struct task_struct *tsk, struct mm_struct *mm,
diff --git a/mm/page_vma_mapped.c b/mm/page_vma_mapped.c
index 11df03e71288c..eff4b4520c8d5 100644
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
index 85b7f94233526..b177925c08401 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -896,7 +896,7 @@ static bool page_mkclean_one(struct page *page, struct vm_area_struct *vma,
 	 * We have to assume the worse case ie pmd for invalidation. Note that
 	 * the page can not be free from this function.
 	 */
-	end = min(vma->vm_end, start + (PAGE_SIZE << compound_order(page)));
+	end = min(vma->vm_end, start + page_size(page));
 	mmu_notifier_invalidate_range_start(vma->vm_mm, start, end);
 
 	while (page_vma_mapped_walk(&pvmw)) {
@@ -1369,7 +1369,7 @@ static bool try_to_unmap_one(struct page *page, struct vm_area_struct *vma,
 	 * Note that the page can not be free in this function as call of
 	 * try_to_unmap() must hold a reference on the page.
 	 */
-	end = min(vma->vm_end, start + (PAGE_SIZE << compound_order(page)));
+	end = min(vma->vm_end, start + page_size(page));
 	if (PageHuge(page)) {
 		/*
 		 * If sharing is possible, start and end will be adjusted
diff --git a/mm/slob.c b/mm/slob.c
index 307c2c9feb441..d7d3429e07e1a 100644
--- a/mm/slob.c
+++ b/mm/slob.c
@@ -516,7 +516,7 @@ size_t ksize(const void *block)
 
 	sp = virt_to_page(block);
 	if (unlikely(!PageSlab(sp)))
-		return PAGE_SIZE << compound_order(sp);
+		return page_size(sp);
 
 	align = max_t(size_t, ARCH_KMALLOC_MINALIGN, ARCH_SLAB_MINALIGN);
 	m = (unsigned int *)(block - align);
diff --git a/mm/slub.c b/mm/slub.c
index e3629cd7aff16..274fab6581e7c 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -830,7 +830,7 @@ static int slab_pad_check(struct kmem_cache *s, struct page *page)
 		return 1;
 
 	start = page_address(page);
-	length = PAGE_SIZE << compound_order(page);
+	length = page_size(page);
 	end = start + length;
 	remainder = length % s->size;
 	if (!remainder)
@@ -3905,7 +3905,7 @@ static size_t __ksize(const void *object)
 
 	if (unlikely(!PageSlab(page))) {
 		WARN_ON(!PageCompound(page));
-		return PAGE_SIZE << compound_order(page);
+		return page_size(page);
 	}
 
 	return slab_ksize(page->slab_cache);
diff --git a/net/xdp/xsk.c b/net/xdp/xsk.c
index a03268454a276..902cd2e7b0189 100644
--- a/net/xdp/xsk.c
+++ b/net/xdp/xsk.c
@@ -679,7 +679,7 @@ static int xsk_mmap(struct file *file, struct socket *sock,
 		return -EINVAL;
 
 	qpg = virt_to_head_page(q->ring);
-	if (size > (PAGE_SIZE << compound_order(qpg)))
+	if (size > page_size(qpg))
 		return -EINVAL;
 
 	pfn = virt_to_phys(q->ring) >> PAGE_SHIFT;
-- 
2.19.2
