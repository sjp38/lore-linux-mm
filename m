Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 2C88E6B03A5
	for <linux-mm@kvack.org>; Mon, 24 Apr 2017 14:26:10 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id 72so17926350pge.10
        for <linux-mm@kvack.org>; Mon, 24 Apr 2017 11:26:10 -0700 (PDT)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTPS id b27si19994949pfj.20.2017.04.24.11.26.09
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 24 Apr 2017 11:26:09 -0700 (PDT)
Date: Mon, 24 Apr 2017 21:25:56 +0300
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: Re: get_zone_device_page() in get_page() and
 page_cache_get_speculative()
Message-ID: <20170424182555.faoarzlpi4ilm5dt@black.fi.intel.com>
References: <CAA9_cmf7=aGXKoQFkzS_UJtznfRtWofitDpV2AyGwpaRGKyQkg@mail.gmail.com>
 <20170423233125.nehmgtzldgi25niy@node.shutemov.name>
 <CAPcyv4i8mBOCuA8k-A8RXGMibbnqHUsa3Ly+YcQbr0eCdjruUw@mail.gmail.com>
 <20170424173021.ayj3hslvfrrgrie7@node.shutemov.name>
 <CAPcyv4g74LT6sK2WgG6FnwQHCC5fNTwfqBPq1BY8PnZ7zwdGPw@mail.gmail.com>
 <20170424180158.y26m3kgzhpmawbhg@node.shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170424180158.y26m3kgzhpmawbhg@node.shutemov.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: Dan Williams <dan.j.williams@intel.com>, Linux MM <linux-mm@kvack.org>, Catalin Marinas <catalin.marinas@arm.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Steve Capper <steve.capper@linaro.org>, Thomas Gleixner <tglx@linutronix.de>, Peter Zijlstra <peterz@infradead.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Ingo Molnar <mingo@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, "H. Peter Anvin" <hpa@zytor.com>, Dave Hansen <dave.hansen@intel.com>, Borislav Petkov <bp@alien8.de>, Rik van Riel <riel@redhat.com>, Dann Frazier <dann.frazier@canonical.com>, Linus Torvalds <torvalds@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, linux-tip-commits@vger.kernel.org

On Mon, Apr 24, 2017 at 09:01:58PM +0300, Kirill A. Shutemov wrote:
> On Mon, Apr 24, 2017 at 10:47:43AM -0700, Dan Williams wrote:
> I think it's still better to do it on page_ref_* level.

Something like patch below? What do you think?

diff --git a/include/linux/memremap.h b/include/linux/memremap.h
index 93416196ba64..bd1b13af4567 100644
--- a/include/linux/memremap.h
+++ b/include/linux/memremap.h
@@ -35,20 +35,6 @@ static inline struct vmem_altmap *to_vmem_altmap(unsigned long memmap_start)
 }
 #endif
 
-/**
- * struct dev_pagemap - metadata for ZONE_DEVICE mappings
- * @altmap: pre-allocated/reserved memory for vmemmap allocations
- * @res: physical address range covered by @ref
- * @ref: reference count that pins the devm_memremap_pages() mapping
- * @dev: host device of the mapping for debug
- */
-struct dev_pagemap {
-	struct vmem_altmap *altmap;
-	const struct resource *res;
-	struct percpu_ref *ref;
-	struct device *dev;
-};
-
 #ifdef CONFIG_ZONE_DEVICE
 void *devm_memremap_pages(struct device *dev, struct resource *res,
 		struct percpu_ref *ref, struct vmem_altmap *altmap);
diff --git a/include/linux/mm.h b/include/linux/mm.h
index e197d3ca3e8a..c2749b878199 100644
--- a/include/linux/mm.h
+++ b/include/linux/mm.h
@@ -760,19 +760,11 @@ static inline enum zone_type page_zonenum(const struct page *page)
 }
 
 #ifdef CONFIG_ZONE_DEVICE
-void get_zone_device_page(struct page *page);
-void put_zone_device_page(struct page *page);
 static inline bool is_zone_device_page(const struct page *page)
 {
 	return page_zonenum(page) == ZONE_DEVICE;
 }
 #else
-static inline void get_zone_device_page(struct page *page)
-{
-}
-static inline void put_zone_device_page(struct page *page)
-{
-}
 static inline bool is_zone_device_page(const struct page *page)
 {
 	return false;
@@ -788,9 +780,6 @@ static inline void get_page(struct page *page)
 	 */
 	VM_BUG_ON_PAGE(page_ref_count(page) <= 0, page);
 	page_ref_inc(page);
-
-	if (unlikely(is_zone_device_page(page)))
-		get_zone_device_page(page);
 }
 
 static inline void put_page(struct page *page)
@@ -799,9 +788,6 @@ static inline void put_page(struct page *page)
 
 	if (put_page_testzero(page))
 		__put_page(page);
-
-	if (unlikely(is_zone_device_page(page)))
-		put_zone_device_page(page);
 }
 
 #if defined(CONFIG_SPARSEMEM) && !defined(CONFIG_SPARSEMEM_VMEMMAP)
diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
index 45cdb27791a3..fb7bb60d446b 100644
--- a/include/linux/mm_types.h
+++ b/include/linux/mm_types.h
@@ -601,4 +601,18 @@ typedef struct {
 	unsigned long val;
 } swp_entry_t;
 
+/**
+ * struct dev_pagemap - metadata for ZONE_DEVICE mappings
+ * @altmap: pre-allocated/reserved memory for vmemmap allocations
+ * @res: physical address range covered by @ref
+ * @ref: reference count that pins the devm_memremap_pages() mapping
+ * @dev: host device of the mapping for debug
+ */
+struct dev_pagemap {
+	struct vmem_altmap *altmap;
+	const struct resource *res;
+	struct percpu_ref *ref;
+	struct device *dev;
+};
+
 #endif /* _LINUX_MM_TYPES_H */
diff --git a/include/linux/page_ref.h b/include/linux/page_ref.h
index 610e13271918..d834c68e21fd 100644
--- a/include/linux/page_ref.h
+++ b/include/linux/page_ref.h
@@ -61,6 +61,8 @@ static inline void __page_ref_unfreeze(struct page *page, int v)
 
 #endif
 
+static inline bool is_zone_device_page(const struct page *page);
+
 static inline int page_ref_count(struct page *page)
 {
 	return atomic_read(&page->_refcount);
@@ -92,6 +94,9 @@ static inline void page_ref_add(struct page *page, int nr)
 	atomic_add(nr, &page->_refcount);
 	if (page_ref_tracepoint_active(__tracepoint_page_ref_mod))
 		__page_ref_mod(page, nr);
+
+	if (unlikely(is_zone_device_page(page)))
+		percpu_ref_get_many(page->pgmap->ref, nr);
 }
 
 static inline void page_ref_sub(struct page *page, int nr)
@@ -99,6 +104,9 @@ static inline void page_ref_sub(struct page *page, int nr)
 	atomic_sub(nr, &page->_refcount);
 	if (page_ref_tracepoint_active(__tracepoint_page_ref_mod))
 		__page_ref_mod(page, -nr);
+
+	if (unlikely(is_zone_device_page(page)))
+		percpu_ref_put_many(page->pgmap->ref, nr);
 }
 
 static inline void page_ref_inc(struct page *page)
@@ -106,6 +114,9 @@ static inline void page_ref_inc(struct page *page)
 	atomic_inc(&page->_refcount);
 	if (page_ref_tracepoint_active(__tracepoint_page_ref_mod))
 		__page_ref_mod(page, 1);
+
+	if (unlikely(is_zone_device_page(page)))
+		percpu_ref_get(page->pgmap->ref);
 }
 
 static inline void page_ref_dec(struct page *page)
@@ -113,6 +124,9 @@ static inline void page_ref_dec(struct page *page)
 	atomic_dec(&page->_refcount);
 	if (page_ref_tracepoint_active(__tracepoint_page_ref_mod))
 		__page_ref_mod(page, -1);
+
+	if (unlikely(is_zone_device_page(page)))
+		percpu_ref_put(page->pgmap->ref);
 }
 
 static inline int page_ref_sub_and_test(struct page *page, int nr)
@@ -121,6 +135,9 @@ static inline int page_ref_sub_and_test(struct page *page, int nr)
 
 	if (page_ref_tracepoint_active(__tracepoint_page_ref_mod_and_test))
 		__page_ref_mod_and_test(page, -nr, ret);
+
+	if (unlikely(is_zone_device_page(page)))
+		percpu_ref_put_many(page->pgmap->ref, nr);
 	return ret;
 }
 
@@ -130,6 +147,9 @@ static inline int page_ref_inc_return(struct page *page)
 
 	if (page_ref_tracepoint_active(__tracepoint_page_ref_mod_and_return))
 		__page_ref_mod_and_return(page, 1, ret);
+
+	if (unlikely(is_zone_device_page(page)))
+		percpu_ref_get(page->pgmap->ref);
 	return ret;
 }
 
@@ -139,6 +159,9 @@ static inline int page_ref_dec_and_test(struct page *page)
 
 	if (page_ref_tracepoint_active(__tracepoint_page_ref_mod_and_test))
 		__page_ref_mod_and_test(page, -1, ret);
+
+	if (unlikely(is_zone_device_page(page)))
+		percpu_ref_put(page->pgmap->ref);
 	return ret;
 }
 
@@ -148,6 +171,9 @@ static inline int page_ref_dec_return(struct page *page)
 
 	if (page_ref_tracepoint_active(__tracepoint_page_ref_mod_and_return))
 		__page_ref_mod_and_return(page, -1, ret);
+
+	if (unlikely(is_zone_device_page(page)))
+		percpu_ref_put(page->pgmap->ref);
 	return ret;
 }
 
@@ -157,6 +183,9 @@ static inline int page_ref_add_unless(struct page *page, int nr, int u)
 
 	if (page_ref_tracepoint_active(__tracepoint_page_ref_mod_unless))
 		__page_ref_mod_unless(page, nr, ret);
+
+	if (unlikely(is_zone_device_page(page)) && ret)
+		percpu_ref_get_many(page->pgmap->ref, nr);
 	return ret;
 }
 
@@ -166,6 +195,9 @@ static inline int page_ref_freeze(struct page *page, int count)
 
 	if (page_ref_tracepoint_active(__tracepoint_page_ref_freeze))
 		__page_ref_freeze(page, count, ret);
+
+	if (unlikely(is_zone_device_page(page)) && ret)
+		percpu_ref_put_many(page->pgmap->ref, count);
 	return ret;
 }
 
@@ -177,6 +209,9 @@ static inline void page_ref_unfreeze(struct page *page, int count)
 	atomic_set(&page->_refcount, count);
 	if (page_ref_tracepoint_active(__tracepoint_page_ref_unfreeze))
 		__page_ref_unfreeze(page, count);
+
+	if (unlikely(is_zone_device_page(page)))
+		percpu_ref_get_many(page->pgmap->ref, count);
 }
 
 #endif
diff --git a/kernel/memremap.c b/kernel/memremap.c
index 06123234f118..936cef79d811 100644
--- a/kernel/memremap.c
+++ b/kernel/memremap.c
@@ -182,18 +182,6 @@ struct page_map {
 	struct vmem_altmap altmap;
 };
 
-void get_zone_device_page(struct page *page)
-{
-	percpu_ref_get(page->pgmap->ref);
-}
-EXPORT_SYMBOL(get_zone_device_page);
-
-void put_zone_device_page(struct page *page)
-{
-	put_dev_pagemap(page->pgmap);
-}
-EXPORT_SYMBOL(put_zone_device_page);
-
 static void pgmap_radix_release(struct resource *res)
 {
 	resource_size_t key, align_start, align_size, align_end;
-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
