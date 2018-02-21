Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 9C4B56B0003
	for <linux-mm@kvack.org>; Wed, 21 Feb 2018 10:42:20 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id e126so998541pfh.4
        for <linux-mm@kvack.org>; Wed, 21 Feb 2018 07:42:20 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id d30-v6si10976492pld.452.2018.02.21.07.42.18
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Wed, 21 Feb 2018 07:42:18 -0800 (PST)
Date: Wed, 21 Feb 2018 07:42:14 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Use higher-order pages in vmalloc
Message-ID: <20180221154214.GA4167@bombadil.infradead.org>
References: <151670492223.658225.4605377710524021456.stgit@buzz>
 <151670493255.658225.2881484505285363395.stgit@buzz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <151670493255.658225.2881484505285363395.stgit@buzz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Cc: Dave Hansen <dave.hansen@intel.com>, linux-kernel@vger.kernel.org, Christoph Hellwig <hch@infradead.org>, linux-mm@kvack.org, Andy Lutomirski <luto@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill@shutemov.name>

On Tue, Jan 23, 2018 at 01:55:32PM +0300, Konstantin Khlebnikov wrote:
> Virtually mapped stack have two bonuses: it eats order-0 pages and
> adds guard page at the end. But it slightly slower if system have
> plenty free high-order pages.
> 
> This patch adds option to use virtually bapped stack as fallback for
> atomic allocation of traditional high-order page.

This prompted me to write a patch I've been meaning to do for a while,
allocating large pages if they're available to satisfy vmalloc.  I thought
it would save on touching multiple struct pages, but it turns out that
the checking code we currently have in the free_pages path requires you
to have initialised all of the tail pages (maybe we can make that code
conditional ...)

It does save the buddy allocator the trouble of breaking down higher-order
pages into order-0 pages, only to allocate them again immediately.

(um, i seem to have broken the patch while cleaning it up for submission.
since it probably won't be accepted anyway, I'm not going to try to debug it)

diff --git a/kernel/fork.c b/kernel/fork.c
index be8aa5b98666..2bc01071b6ae 100644
--- a/kernel/fork.c
+++ b/kernel/fork.c
@@ -319,12 +319,12 @@ static void account_kernel_stack(struct task_struct *tsk, int account)
 	if (vm) {
 		int i;
 
-		BUG_ON(vm->nr_pages != THREAD_SIZE / PAGE_SIZE);
-
-		for (i = 0; i < THREAD_SIZE / PAGE_SIZE; i++) {
-			mod_zone_page_state(page_zone(vm->pages[i]),
+		for (i = 0; i < vm->nr_pages; i++) {
+			struct page *page = vm->pages[i];
+			unsigned int size = PAGE_SIZE << compound_order(page);
+			mod_zone_page_state(page_zone(page),
 					    NR_KERNEL_STACK_KB,
-					    PAGE_SIZE / 1024 * account);
+					    size / 1024 * account);
 		}
 
 		/* All stack pages belong to the same memcg. */
diff --git a/mm/vmalloc.c b/mm/vmalloc.c
index b728c98f49cd..4bfc29b21bc1 100644
--- a/mm/vmalloc.c
+++ b/mm/vmalloc.c
@@ -134,6 +134,7 @@ static void vunmap_page_range(unsigned long addr, unsigned long end)
 static int vmap_pte_range(pmd_t *pmd, unsigned long addr,
 		unsigned long end, pgprot_t prot, struct page **pages, int *nr)
 {
+	unsigned int i;
 	pte_t *pte;
 
 	/*
@@ -151,9 +152,13 @@ static int vmap_pte_range(pmd_t *pmd, unsigned long addr,
 			return -EBUSY;
 		if (WARN_ON(!page))
 			return -ENOMEM;
-		set_pte_at(&init_mm, addr, pte, mk_pte(page, prot));
+		for (i = 0; i < (1UL << compound_order(page)); i++) {
+			set_pte_at(&init_mm, addr, pte++,
+					mk_pte(page + i, prot));
+			addr += PAGE_SIZE;
+		}
 		(*nr)++;
-	} while (pte++, addr += PAGE_SIZE, addr != end);
+	} while (addr != end);
 	return 0;
 }
 
@@ -1530,14 +1535,14 @@ static void __vunmap(const void *addr, int deallocate_pages)
 	debug_check_no_obj_freed(addr, get_vm_area_size(area));
 
 	if (deallocate_pages) {
-		int i;
+		unsigned int i;
 
 		for (i = 0; i < area->nr_pages; i++) {
 			struct page *page = area->pages[i];
 
 			BUG_ON(!page);
 			__ClearPageVmalloc(page);
-			__free_pages(page, 0);
+			__free_pages(page, compound_order(page));
 		}
 
 		kvfree(area->pages);
@@ -1696,11 +1701,20 @@ static void *__vmalloc_area_node(struct vm_struct *area, gfp_t gfp_mask,
 
 	for (i = 0; i < area->nr_pages; i++) {
 		struct page *page;
-
-		if (node == NUMA_NO_NODE)
-			page = alloc_page(alloc_mask);
-		else
-			page = alloc_pages_node(node, alloc_mask, 0);
+		unsigned int j = ilog2(area->nr_pages - i) + 1;
+
+		do {
+			j--;
+			if (node == NUMA_NO_NODE)
+				page = alloc_pages(alloc_mask, j);
+			else
+				page = alloc_pages_node(node, alloc_mask, j);
+		} while (!page && j);
+
+		if (j) {
+			area->nr_pages -= (1UL << j) - 1;
+			prep_compound_page(page, j);
+		}
 
 		if (unlikely(!page)) {
 			/* Successfully allocated i pages, free them in __vunmap() */
@@ -1719,8 +1733,8 @@ static void *__vmalloc_area_node(struct vm_struct *area, gfp_t gfp_mask,
 
 fail:
 	warn_alloc(gfp_mask, NULL,
-			  "vmalloc: allocation failure, allocated %ld of %ld bytes",
-			  (area->nr_pages*PAGE_SIZE), area->size);
+		   "vmalloc: allocation failure, allocated %ld of %ld bytes",
+		   (nr_pages * PAGE_SIZE), get_vm_area_size(area));
 	vfree(area->addr);
 	return NULL;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
