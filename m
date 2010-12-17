Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id 2BE7B6B0098
	for <linux-mm@kvack.org>; Thu, 16 Dec 2010 23:16:41 -0500 (EST)
From: KyongHo Cho <pullip.cho@samsung.com>
Subject: [RFCv2,3/8] mm: vcm: physical memory allocator added
Date: Fri, 17 Dec 2010 12:56:22 +0900
Message-Id: <1292558187-17348-4-git-send-email-pullip.cho@samsung.com>
In-Reply-To: <1292558187-17348-3-git-send-email-pullip.cho@samsung.com>
References: <1292558187-17348-1-git-send-email-pullip.cho@samsung.com>
 <1292558187-17348-2-git-send-email-pullip.cho@samsung.com>
 <1292558187-17348-3-git-send-email-pullip.cho@samsung.com>
Sender: owner-linux-mm@kvack.org
To: KyongHo Cho <pullip.cho@samsung.com>
Cc: Kyungmin Park <kyungmin.park@samsung.com>, Kukjin Kim <kgene.kim@samsung.com>, Inho Lee <ilho215.lee@samsung.com>, Inki Dae <inki.dae@samsung.com>, Andrew Morton <akpm@linux-foundation.org>, Ankita Garg <ankita@in.ibm.com>, Daniel Walker <dwalker@codeaurora.org>, Johan MOSSBERG <johan.xx.mossberg@stericsson.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Mel Gorman <mel@csn.ul.ie>, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-media@vger.kernel.org, linux-mm@kvack.org, linux-samsung-soc@vger.kernel.org, Michal Nazarewicz <m.nazarewicz@samsung.com>
List-ID: <linux-mm.kvack.org>

From: Michal Nazarewicz <m.nazarewicz@samsung.com>

This commits adds vcm_phys_alloc() function with some
accompanying functions which allocates physical memory.  This
should be used from withing alloc or phys callback of a VCM
driver if one does not want to provide its own allocator.

Signed-off-by: Michal Nazarewicz <m.nazarewicz@samsung.com>
Signed-off-by: Kyungmin Park <kyungmin.park@samsung.com>
---
 Documentation/virtual-contiguous-memory.txt |   31 ++++
 include/linux/vcm-drv.h                     |   88 ++++++++++
 mm/Kconfig                                  |    9 +
 mm/vcm.c                                    |  249 +++++++++++++++++++++++++++
 4 files changed, 377 insertions(+), 0 deletions(-)

diff --git a/Documentation/virtual-contiguous-memory.txt b/Documentation/virtual-contiguous-memory.txt
index 2008465..10a0638 100644
--- a/Documentation/virtual-contiguous-memory.txt
+++ b/Documentation/virtual-contiguous-memory.txt
@@ -672,6 +672,37 @@ Both phys and alloc callbacks need to provide a free callbakc along
 with the vc_phys structure, which will, as one may imagine, free
 allocated space when user calls vcm_free().
 
+Unless VCM driver needs some special handling of physical memory, the
+vcm_phys_alloc() function can be used:
+
+	struct vcm_phys *__must_check
+	vcm_phys_alloc(resource_size_t size, unsigned flags,
+		       const unsigned char *orders);
+
+The last argument of this function (orders) is an array of orders of
+page sizes that function should try to allocate.  This array must be
+sorted from highest order to lowest and the last entry must be zero.
+
+For instance, an array { 8, 4, 0 } means that the function should try
+and allocate 1MiB, 64KiB and 4KiB pages (this is assuming PAGE_SIZE is
+4KiB which is true for all supported architectures).  For example, if
+requested size is 2MiB and 68 KiB, the function will try to allocate
+two 1MiB pages, one 64KiB page and one 4KiB page.  This may be useful
+when the mapping is written to the MMU since the largest possible
+pages will be used reducing the number of entries.
+
+The function allocates memory from DMA32 zone.  If driver has some
+other requirements (that is require different GFP flags) it can use
+__vcm_phys_alloc() function which, besides arguments that
+vcm_phys_alloc() accepts, take GFP flags as the last argument:
+
+	struct vcm_phys *__must_check
+	__vcm_phys_alloc(resource_size_t size, unsigned flags,
+			 const unsigned char *orders, gfp_t gfp);
+
+However, if those functions are used, VCM driver needs to select an
+VCM_PHYS Kconfig option or oterwise they won't be available.
+
 All those operations may assume that size is a non-zero and divisible
 by PAGE_SIZE.
 
diff --git a/include/linux/vcm-drv.h b/include/linux/vcm-drv.h
index d7ae660..536b051 100644
--- a/include/linux/vcm-drv.h
+++ b/include/linux/vcm-drv.h
@@ -114,4 +114,92 @@ struct vcm_phys {
  */
 struct vcm *__must_check vcm_init(struct vcm *vcm);
 
+#ifdef CONFIG_VCM_PHYS
+
+/**
+ * __vcm_phys_alloc() - allocates physical discontiguous space
+ * @size:	size of the block to allocate.
+ * @flags:	additional allocation flags; XXX FIXME: document
+ * @orders:	array of orders of pages supported by the MMU sorted from
+ *		the largest to the smallest.  The last element is always
+ *		zero (which means 4K page).
+ * @gfp:	the gfp flags for pages to allocate.
+ *
+ * This function tries to allocate a physical discontiguous space in
+ * such a way that it allocates the largest possible blocks from the
+ * sizes donated by the @orders array.  So if @orders is { 8, 0 }
+ * (which means 1MiB and 4KiB pages are to be used) and requested
+ * @size is 2MiB and 12KiB the function will try to allocate two 1MiB
+ * pages and three 4KiB pages (in that order).  If big page cannot be
+ * allocated the function will still try to allocate more smaller
+ * pages.
+ */
+struct vcm_phys *__must_check
+__vcm_phys_alloc(resource_size_t size, unsigned flags,
+		 const unsigned char *orders, gfp_t gfp);
+
+/**
+ * vcm_phys_alloc() - allocates physical discontiguous space
+ * @size:	size of the block to allocate.
+ * @flags:	additional allocation flags; XXX FIXME: document
+ * @orders:	array of orders of pages supported by the MMU sorted from
+ *		the largest to the smallest.  The last element is always
+ *		zero (which means 4K page).
+ *
+ * This function tries to allocate a physical discontiguous space in
+ * such a way that it allocates the largest possible blocks from the
+ * sizes donated by the @orders array.  So if @orders is { 8, 0 }
+ * (which means 1MiB and 4KiB pages are to be used) and requested
+ * @size is 2MiB and 12KiB the function will try to allocate two 1MiB
+ * pages and three 4KiB pages (in that order).  If big page cannot be
+ * allocated the function will still try to allocate more smaller
+ * pages.
+ */
+static inline struct vcm_phys *__must_check
+vcm_phys_alloc(resource_size_t size, unsigned flags,
+	       const unsigned char *orders) {
+	return __vcm_phys_alloc(size, flags, orders, GFP_DMA32);
+}
+
+/**
+ * vcm_phys_walk() - helper function for mapping physical pages
+ * @vaddr:	virtual address to map/unmap physical space to/from
+ * @phys:	physical space
+ * @orders:	array of orders of pages supported by the MMU sorted from
+ *		the largest to the smallest.  The last element is always
+ *		zero (which means 4K page).
+ * @callback:	function called for each page.
+ * @recover:	function called for each page when @callback returns
+ *		negative number; if it also returns negative number
+ *		function terminates; may be NULL.
+ * @priv:	private data for the callbacks.
+ *
+ * This function walks through @phys trying to mach largest possible
+ * page size donated by @orders.  For each such page @callback is
+ * called.  If @callback returns negative number the function calls
+ * @recover for each page @callback was called successfully.
+ *
+ * So, for instance, if we have a physical memory which consist of
+ * 1Mib part and 8KiB part and @orders is { 8, 0 } (which means 1MiB
+ * and 4KiB pages are to be used), @callback will be called first with
+ * 1MiB page and then two times with 4KiB page.  This is of course
+ * provided that @vaddr has correct alignment.
+ *
+ * The idea is for hardware MMU drivers to call this function and
+ * provide a callbacks for mapping/unmapping a single page.  The
+ * function divides the region into pages that the MMU can handle.
+ *
+ * If @callback at one point returns a negative number this is the
+ * return value of the function; otherwise zero is returned.
+ */
+int vcm_phys_walk(dma_addr_t vaddr, const struct vcm_phys *phys,
+		  const unsigned char *orders,
+		  int (*callback)(dma_addr_t vaddr, dma_addr_t paddr,
+				  unsigned order, void *priv),
+		  int (*recovery)(dma_addr_t vaddr, dma_addr_t paddr,
+				  unsigned order, void *priv),
+		  void *priv);
+
+#endif
+
 #endif
diff --git a/mm/Kconfig b/mm/Kconfig
index b937f32..00d975e 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -360,6 +360,15 @@ config VCM_RES_REFCNT
 	  This enables reference counting on a reservation to make sharing
 	  and migrating the ownership of the reservation easier.
 
+config VCM_PHYS
+	bool "VCM physical allocation wrappers"
+	depends on VCM && MODULES
+	help
+	  This enables the vcm_phys family of functions provided for VCM
+	  drivers.  If a VCM driver is built that requires this option, it
+	  will be automatically selected.  You select it if you are going to
+	  build external modules that will use this functionality.
+
 #
 # UP and nommu archs use km based percpu allocator
 #
diff --git a/mm/vcm.c b/mm/vcm.c
index 5819f0f..6804114 100644
--- a/mm/vcm.c
+++ b/mm/vcm.c
@@ -319,3 +319,252 @@ struct vcm *__must_check vcm_init(struct vcm *vcm)
 	return vcm;
 }
 EXPORT_SYMBOL_GPL(vcm_init);
+
+
+/************************ Physical memory management ************************/
+
+#ifdef CONFIG_VCM_PHYS
+
+struct vcm_phys_list {
+	struct vcm_phys_list	*next;
+	unsigned		count;
+	struct vcm_phys_part	parts[31];
+};
+
+static struct vcm_phys_list *__must_check
+vcm_phys_alloc_list_order(struct vcm_phys_list *last, resource_size_t *pages,
+			  unsigned flags, unsigned order, unsigned *total,
+			  gfp_t gfp)
+{
+	unsigned count;
+
+	count	= *pages >> order;
+
+	do {
+		struct page *page = alloc_pages(gfp, order);
+
+		if (!page)
+			/*
+			 * If allocation failed we may still
+			 * try to continua allocating smaller
+			 * pages.
+			 */
+			break;
+
+		if (last->count == ARRAY_SIZE(last->parts)) {
+			struct vcm_phys_list *l;
+			l = kmalloc(sizeof *l, GFP_KERNEL);
+			if (!l)
+				return NULL;
+
+			l->next = NULL;
+			l->count = 0;
+			last->next = l;
+			last = l;
+		}
+
+		last->parts[last->count].start = page_to_phys(page);
+		last->parts[last->count].size  = (1 << order);
+		last->parts[last->count].page  = page;
+		++last->count;
+		++*total;
+		*pages -= 1 << order;
+	} while (--count);
+
+	return last;
+}
+
+static unsigned __must_check
+vcm_phys_alloc_list(struct vcm_phys_list *first,
+		    resource_size_t size, unsigned flags,
+		    const unsigned char *orders, gfp_t gfp)
+{
+	struct vcm_phys_list *last = first;
+	unsigned total_parts = 0;
+	resource_size_t pages;
+
+	/*
+	 * We are trying to allocate as large pages as possible but
+	 * not larger then pages that MMU driver that called us
+	 * supports (ie. the ones provided by page_sizes).  This makes
+	 * it possible to map the region using fewest possible number
+	 * of entries.
+	 */
+	pages = size >> PAGE_SHIFT;
+	do {
+		while (!(pages >> *orders))
+			++orders;
+
+		last = vcm_phys_alloc_list_order(last, &pages, flags, *orders,
+						 &total_parts, gfp);
+		if (!last)
+			return 0;
+
+	} while (*orders++ && pages);
+
+	if (pages)
+		return 0;
+
+	return total_parts;
+}
+
+static void vcm_phys_free_parts(struct vcm_phys_part *parts, unsigned count)
+{
+	do {
+		__free_pages(parts->page, ffs(parts->size) - 1 - PAGE_SHIFT);
+	} while (++parts, --count);
+}
+
+static void vcm_phys_free(struct vcm_phys *phys)
+{
+	vcm_phys_free_parts(phys->parts, phys->count);
+	kfree(phys);
+}
+
+struct vcm_phys *__must_check
+__vcm_phys_alloc(resource_size_t size, unsigned flags,
+		 const unsigned char *orders, gfp_t gfp)
+{
+	struct vcm_phys_list *lst, *n;
+	struct vcm_phys_part *out;
+	struct vcm_phys *phys;
+	unsigned count;
+
+	if (WARN_ON((size & (PAGE_SIZE - 1)) || !size || !orders))
+		return ERR_PTR(-EINVAL);
+
+	lst = kmalloc(sizeof *lst, GFP_KERNEL);
+	if (!lst)
+		return ERR_PTR(-ENOMEM);
+
+	lst->next = NULL;
+	lst->count = 0;
+
+	count = vcm_phys_alloc_list(lst, size, flags, orders, gfp);
+	if (!count)
+		goto error;
+
+	phys = kmalloc(sizeof *phys + count * sizeof *phys->parts, GFP_KERNEL);
+	if (!phys)
+		goto error;
+
+	phys->free  = vcm_phys_free;
+	phys->count = count;
+	phys->size  = size;
+
+	out = phys->parts;
+	do {
+		memcpy(out, lst->parts, lst->count * sizeof *out);
+		out += lst->count;
+
+		n = lst->next;
+		kfree(lst);
+		lst = n;
+	} while (lst);
+
+	return phys;
+
+error:
+	do {
+		vcm_phys_free_parts(lst->parts, lst->count);
+
+		n = lst->next;
+		kfree(lst);
+		lst = n;
+	} while (lst);
+
+	return ERR_PTR(-ENOMEM);
+}
+EXPORT_SYMBOL_GPL(__vcm_phys_alloc);
+
+static inline bool is_of_order(dma_addr_t size, unsigned order)
+{
+	return !(size & (((dma_addr_t)PAGE_SIZE << order) - 1));
+}
+
+static int
+__vcm_phys_walk_part(dma_addr_t vaddr, const struct vcm_phys_part *part,
+		     const unsigned char *orders,
+		     int (*callback)(dma_addr_t vaddr, dma_addr_t paddr,
+				     unsigned order, void *priv), void *priv,
+		     unsigned *limit)
+{
+	resource_size_t size = part->size;
+	dma_addr_t paddr = part->start;
+	resource_size_t ps;
+
+	while (!is_of_order(vaddr, *orders))
+		++orders;
+	while (!is_of_order(paddr, *orders))
+		++orders;
+
+	ps = PAGE_SIZE << *orders;
+	for (; *limit && size; --*limit) {
+		int ret;
+
+		while (ps > size)
+			ps = PAGE_SIZE << *++orders;
+
+		ret = callback(vaddr, paddr, *orders, priv);
+		if (ret < 0)
+			return ret;
+
+		ps = PAGE_SIZE << *orders;
+		vaddr += ps;
+		paddr += ps;
+		size  -= ps;
+	}
+
+	return 0;
+}
+
+int vcm_phys_walk(dma_addr_t _vaddr, const struct vcm_phys *phys,
+		  const unsigned char *orders,
+		  int (*callback)(dma_addr_t vaddr, dma_addr_t paddr,
+				  unsigned order, void *arg),
+		  int (*recovery)(dma_addr_t vaddr, dma_addr_t paddr,
+				  unsigned order, void *arg),
+		  void *priv)
+{
+	unsigned limit = ~0;
+	int r = 0;
+
+	if (WARN_ON(!phys || ((_vaddr | phys->size) & (PAGE_SIZE - 1)) ||
+		    !phys->size || !orders || !callback))
+		return -EINVAL;
+
+	for (;;) {
+		const struct vcm_phys_part *part = phys->parts;
+		unsigned count = phys->count;
+		dma_addr_t vaddr = _vaddr;
+		int ret = 0;
+
+		for (; count && limit; --count, ++part) {
+			ret = __vcm_phys_walk_part(vaddr, part, orders,
+						   callback, priv, &limit);
+			if (ret)
+				break;
+
+			vaddr += part->size;
+		}
+
+		if (r)
+			/* We passed error recovery */
+			return r;
+
+		/*
+		 * Either operation suceeded or we were not provided
+		 * with a recovery callback -- return.
+		 */
+		if (!ret || !recovery)
+			return ret;
+
+		/* Switch to recovery */
+		limit = ~0 - limit;
+		callback = recovery;
+		r = ret;
+	}
+}
+EXPORT_SYMBOL_GPL(vcm_phys_walk);
+
+#endif
-- 
1.6.2.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
