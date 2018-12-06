Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f71.google.com (mail-wr1-f71.google.com [209.85.221.71])
	by kanga.kvack.org (Postfix) with ESMTP id 1E36B6B7A19
	for <linux-mm@kvack.org>; Thu,  6 Dec 2018 07:25:25 -0500 (EST)
Received: by mail-wr1-f71.google.com with SMTP id j6so91591wrw.1
        for <linux-mm@kvack.org>; Thu, 06 Dec 2018 04:25:25 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j19sor175947wre.41.2018.12.06.04.25.23
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 06 Dec 2018 04:25:23 -0800 (PST)
From: Andrey Konovalov <andreyknvl@google.com>
Subject: [PATCH v13 21/25] kasan, mm, arm64: tag non slab memory allocated via pagealloc
Date: Thu,  6 Dec 2018 13:24:39 +0100
Message-Id: <d758ddcef46a5abc9970182b9137e2fbee202a2c.1544099024.git.andreyknvl@google.com>
In-Reply-To: <cover.1544099024.git.andreyknvl@google.com>
References: <cover.1544099024.git.andreyknvl@google.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Christoph Lameter <cl@linux.com>, Andrew Morton <akpm@linux-foundation.org>, Mark Rutland <mark.rutland@arm.com>, Nick Desaulniers <ndesaulniers@google.com>, Marc Zyngier <marc.zyngier@arm.com>, Dave Martin <dave.martin@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, "Eric W . Biederman" <ebiederm@xmission.com>, Ingo Molnar <mingo@kernel.org>, Paul Lawrence <paullawrence@google.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Arnd Bergmann <arnd@arndb.de>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Kate Stewart <kstewart@linuxfoundation.org>, Mike Rapoport <rppt@linux.vnet.ibm.com>, kasan-dev@googlegroups.com, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-sparse@vger.kernel.org, linux-mm@kvack.org, linux-kbuild@vger.kernel.org
Cc: Kostya Serebryany <kcc@google.com>, Evgeniy Stepanov <eugenis@google.com>, Lee Smith <Lee.Smith@arm.com>, Ramana Radhakrishnan <Ramana.Radhakrishnan@arm.com>, Jacob Bramley <Jacob.Bramley@arm.com>, Ruben Ayrapetyan <Ruben.Ayrapetyan@arm.com>, Jann Horn <jannh@google.com>, Mark Brand <markbrand@google.com>, Chintan Pandya <cpandya@codeaurora.org>, Vishwath Mohan <vishwath@google.com>, Andrey Konovalov <andreyknvl@google.com>

Tag-based KASAN doesn't check memory accesses through pointers tagged with
0xff. When page_address is used to get pointer to memory that corresponds
to some page, the tag of the resulting pointer gets set to 0xff, even
though the allocated memory might have been tagged differently.

For slab pages it's impossible to recover the correct tag to return from
page_address, since the page might contain multiple slab objects tagged
with different values, and we can't know in advance which one of them is
going to get accessed. For non slab pages however, we can recover the tag
in page_address, since the whole page was marked with the same tag.

This patch adds tagging to non slab memory allocated with pagealloc. To
set the tag of the pointer returned from page_address, the tag gets stored
to page->flags when the memory gets allocated.

Reviewed-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
Reviewed-by: Dmitry Vyukov <dvyukov@google.com>
Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
---
 arch/arm64/include/asm/memory.h   |  8 +++++++-
 include/linux/mm.h                | 29 +++++++++++++++++++++++++++++
 include/linux/page-flags-layout.h | 10 ++++++++++
 mm/cma.c                          | 11 +++++++++++
 mm/kasan/common.c                 | 15 +++++++++++++--
 mm/page_alloc.c                   |  1 +
 mm/slab.c                         |  2 +-
 7 files changed, 72 insertions(+), 4 deletions(-)

diff --git a/arch/arm64/include/asm/memory.h b/arch/arm64/include/asm/memory.h
index 5fe2353f111b..7db28404609b 100644
--- a/arch/arm64/include/asm/memory.h
+++ b/arch/arm64/include/asm/memory.h
@@ -314,7 +314,13 @@ static inline void *phys_to_virt(phys_addr_t x)
 #define __virt_to_pgoff(kaddr)	(((u64)(kaddr) & ~PAGE_OFFSET) / PAGE_SIZE * sizeof(struct page))
 #define __page_to_voff(kaddr)	(((u64)(kaddr) & ~VMEMMAP_START) * PAGE_SIZE / sizeof(struct page))
 
-#define page_to_virt(page)	((void *)((__page_to_voff(page)) | PAGE_OFFSET))
+#define page_to_virt(page)	({					\
+	unsigned long __addr =						\
+		((__page_to_voff(page)) | PAGE_OFFSET);			\
+	__addr = __tag_set(__addr, page_kasan_tag(page));		\
+	((void *)__addr);						\
+})
+
 #define virt_to_page(vaddr)	((struct page *)((__virt_to_pgoff(vaddr)) | VMEMMAP_START))
 
 #define _virt_addr_valid(kaddr)	pfn_valid((((u64)(kaddr) & ~PAGE_OFFSET) \
diff --git a/include/linux/mm.h b/include/linux/mm.h
index 5411de93a363..b4d01969e700 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -804,6 +804,7 @@ vm_fault_t finish_mkwrite_fault(struct vm_fault *vmf);
 #define NODES_PGOFF		(SECTIONS_PGOFF - NODES_WIDTH)
 #define ZONES_PGOFF		(NODES_PGOFF - ZONES_WIDTH)
 #define LAST_CPUPID_PGOFF	(ZONES_PGOFF - LAST_CPUPID_WIDTH)
+#define KASAN_TAG_PGOFF		(LAST_CPUPID_PGOFF - KASAN_TAG_WIDTH)
 
 /*
  * Define the bit shifts to access each section.  For non-existent
@@ -814,6 +815,7 @@ vm_fault_t finish_mkwrite_fault(struct vm_fault *vmf);
 #define NODES_PGSHIFT		(NODES_PGOFF * (NODES_WIDTH != 0))
 #define ZONES_PGSHIFT		(ZONES_PGOFF * (ZONES_WIDTH != 0))
 #define LAST_CPUPID_PGSHIFT	(LAST_CPUPID_PGOFF * (LAST_CPUPID_WIDTH != 0))
+#define KASAN_TAG_PGSHIFT	(KASAN_TAG_PGOFF * (KASAN_TAG_WIDTH != 0))
 
 /* NODE:ZONE or SECTION:ZONE is used to ID a zone for the buddy allocator */
 #ifdef NODE_NOT_IN_PAGE_FLAGS
@@ -836,6 +838,7 @@ vm_fault_t finish_mkwrite_fault(struct vm_fault *vmf);
 #define NODES_MASK		((1UL << NODES_WIDTH) - 1)
 #define SECTIONS_MASK		((1UL << SECTIONS_WIDTH) - 1)
 #define LAST_CPUPID_MASK	((1UL << LAST_CPUPID_SHIFT) - 1)
+#define KASAN_TAG_MASK		((1UL << KASAN_TAG_WIDTH) - 1)
 #define ZONEID_MASK		((1UL << ZONEID_SHIFT) - 1)
 
 static inline enum zone_type page_zonenum(const struct page *page)
@@ -1101,6 +1104,32 @@ static inline bool cpupid_match_pid(struct task_struct *task, int cpupid)
 }
 #endif /* CONFIG_NUMA_BALANCING */
 
+#ifdef CONFIG_KASAN_SW_TAGS
+static inline u8 page_kasan_tag(const struct page *page)
+{
+	return (page->flags >> KASAN_TAG_PGSHIFT) & KASAN_TAG_MASK;
+}
+
+static inline void page_kasan_tag_set(struct page *page, u8 tag)
+{
+	page->flags &= ~(KASAN_TAG_MASK << KASAN_TAG_PGSHIFT);
+	page->flags |= (tag & KASAN_TAG_MASK) << KASAN_TAG_PGSHIFT;
+}
+
+static inline void page_kasan_tag_reset(struct page *page)
+{
+	page_kasan_tag_set(page, 0xff);
+}
+#else
+static inline u8 page_kasan_tag(const struct page *page)
+{
+	return 0xff;
+}
+
+static inline void page_kasan_tag_set(struct page *page, u8 tag) { }
+static inline void page_kasan_tag_reset(struct page *page) { }
+#endif
+
 static inline struct zone *page_zone(const struct page *page)
 {
 	return &NODE_DATA(page_to_nid(page))->node_zones[page_zonenum(page)];
diff --git a/include/linux/page-flags-layout.h b/include/linux/page-flags-layout.h
index 7ec86bf31ce4..1dda31825ec4 100644
--- a/include/linux/page-flags-layout.h
+++ b/include/linux/page-flags-layout.h
@@ -82,6 +82,16 @@
 #define LAST_CPUPID_WIDTH 0
 #endif
 
+#ifdef CONFIG_KASAN_SW_TAGS
+#define KASAN_TAG_WIDTH 8
+#if SECTIONS_WIDTH+NODES_WIDTH+ZONES_WIDTH+LAST_CPUPID_WIDTH+KASAN_TAG_WIDTH \
+	> BITS_PER_LONG - NR_PAGEFLAGS
+#error "KASAN: not enough bits in page flags for tag"
+#endif
+#else
+#define KASAN_TAG_WIDTH 0
+#endif
+
 /*
  * We are going to use the flags for the page to node mapping if its in
  * there.  This includes the case where there is no node, so it is implicit.
diff --git a/mm/cma.c b/mm/cma.c
index 4cb76121a3ab..c7b39dd3b4f6 100644
--- a/mm/cma.c
+++ b/mm/cma.c
@@ -407,6 +407,7 @@ struct page *cma_alloc(struct cma *cma, size_t count, unsigned int align,
 	unsigned long pfn = -1;
 	unsigned long start = 0;
 	unsigned long bitmap_maxno, bitmap_no, bitmap_count;
+	size_t i;
 	struct page *page = NULL;
 	int ret = -ENOMEM;
 
@@ -466,6 +467,16 @@ struct page *cma_alloc(struct cma *cma, size_t count, unsigned int align,
 
 	trace_cma_alloc(pfn, page, count, align);
 
+	/*
+	 * CMA can allocate multiple page blocks, which results in different
+	 * blocks being marked with different tags. Reset the tags to ignore
+	 * those page blocks.
+	 */
+	if (page) {
+		for (i = 0; i < count; i++)
+			page_kasan_tag_reset(page + i);
+	}
+
 	if (ret && !no_warn) {
 		pr_err("%s: alloc failed, req-size: %zu pages, ret: %d\n",
 			__func__, count, ret);
diff --git a/mm/kasan/common.c b/mm/kasan/common.c
index 27f0cae336c9..195ca385cf7a 100644
--- a/mm/kasan/common.c
+++ b/mm/kasan/common.c
@@ -220,8 +220,15 @@ void kasan_unpoison_stack_above_sp_to(const void *watermark)
 
 void kasan_alloc_pages(struct page *page, unsigned int order)
 {
+	u8 tag;
+	unsigned long i;
+
 	if (unlikely(PageHighMem(page)))
 		return;
+
+	tag = random_tag();
+	for (i = 0; i < (1 << order); i++)
+		page_kasan_tag_set(page + i, tag);
 	kasan_unpoison_shadow(page_address(page), PAGE_SIZE << order);
 }
 
@@ -319,6 +326,10 @@ struct kasan_free_meta *get_free_info(struct kmem_cache *cache,
 
 void kasan_poison_slab(struct page *page)
 {
+	unsigned long i;
+
+	for (i = 0; i < (1 << compound_order(page)); i++)
+		page_kasan_tag_reset(page + i);
 	kasan_poison_shadow(page_address(page),
 			PAGE_SIZE << compound_order(page),
 			KASAN_KMALLOC_REDZONE);
@@ -517,7 +528,7 @@ void kasan_poison_kfree(void *ptr, unsigned long ip)
 	page = virt_to_head_page(ptr);
 
 	if (unlikely(!PageSlab(page))) {
-		if (reset_tag(ptr) != page_address(page)) {
+		if (ptr != page_address(page)) {
 			kasan_report_invalid_free(ptr, ip);
 			return;
 		}
@@ -530,7 +541,7 @@ void kasan_poison_kfree(void *ptr, unsigned long ip)
 
 void kasan_kfree_large(void *ptr, unsigned long ip)
 {
-	if (reset_tag(ptr) != page_address(virt_to_head_page(ptr)))
+	if (ptr != page_address(virt_to_head_page(ptr)))
 		kasan_report_invalid_free(ptr, ip);
 	/* The object will be poisoned by page_alloc. */
 }
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 2ec9cc407216..365dc0930f8c 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1183,6 +1183,7 @@ static void __meminit __init_single_page(struct page *page, unsigned long pfn,
 	init_page_count(page);
 	page_mapcount_reset(page);
 	page_cpupid_reset_last(page);
+	page_kasan_tag_reset(page);
 
 	INIT_LIST_HEAD(&page->lru);
 #ifdef WANT_PAGE_VIRTUAL
diff --git a/mm/slab.c b/mm/slab.c
index d2f827316dfc..d747433ecdbb 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -2357,7 +2357,7 @@ static void *alloc_slabmgmt(struct kmem_cache *cachep,
 	void *freelist;
 	void *addr = page_address(page);
 
-	page->s_mem = addr + colour_off;
+	page->s_mem = kasan_reset_tag(addr) + colour_off;
 	page->active = 0;
 
 	if (OBJFREELIST_SLAB(cachep))
-- 
2.20.0.rc1.387.gf8505762e3-goog
