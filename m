Date: Wed, 12 Sep 2007 11:47:21 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH] overwride page->mapping [2/3] page_mapping_info
Message-Id: <20070912114721.10083abc.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20070912114322.e4d8a86e.kamezawa.hiroyu@jp.fujitsu.com>
References: <20070912114322.e4d8a86e.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>, "nickpiggin@yahoo.com.au" <nickpiggin@yahoo.com.au>, Christoph Lameter <clameter@sgi.com>, "Lee.Schermerhorn@hp.com" <Lee.Schermerhorn@hp.com>, "balbir@linux.vnet.ibm.com" <balbir@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

This patch overrides page->mapping with page_mapping_info.

As following.
	page->mapping points to  anon_vma or address_space or mapping_info

mapping_info is strucutured as
	struct mapping_info {
		union {
			anon_vma;
			address_space;
		}
		/* Additional Information to this user's page */
	}
(A purpose of this patch is storing additional information per page by some
 safe way. I'm now wondring that memory-controller information can be moved
 to page_mapping_info rather than adding new member to struct page.)

In "add page->mapping interface patches", direct access to page->mapping
was removed. Then, we can overrides page->mapping with some other structure
by adding some hook in page_mapping_xxx functions.

This patch uses page->mapping's lower 2 bits for
MAPPING_PAGE_ANON and MAPPING_PAGE_INFO.

If MAPPING_PAGE_INFO is not set, page->mapping points to address_space or
anon_vma. If MAPPING_PAGE_INFO is set, page->mapping points to struct
page_mapping_info. If page_mapping_info is not used, there is small (no?)
overheads.

Attach and Detach of page_mapping_info must be guarded by lock_page().
(If a page is linked to objrmap.)

I think this lock will guarantee no-race in page->mapping handling.
(Typical file systems assumes page->mapping can be changed while they
 unlock page. I think there is *basically* no race.
 Of course, need more tests. please point out if you have concerns.)

mapping_info is removed when page is removed from page-cache or page is
removed from anon (swapped-out or freed).

Works well, but maybe error-handling is not complete, sorry.

Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

---
 include/linux/mm_types.h   |   19 +++++++++
 include/linux/page-cache.h |   70 ++++++++++++++++++++++++++++++++----
 mm/filemap.c               |    9 ++++
 mm/page_alloc.c            |    1 
 mm/rmap.c                  |   87 ++++++++++++++++++++++++++++++++++++++++++---
 5 files changed, 172 insertions(+), 14 deletions(-)

Index: test-2.6.23-rc4-mm1/include/linux/mm_types.h
===================================================================
--- test-2.6.23-rc4-mm1.orig/include/linux/mm_types.h
+++ test-2.6.23-rc4-mm1/include/linux/mm_types.h
@@ -14,6 +14,7 @@
 #include <asm/mmu.h>
 
 struct address_space;
+struct anon_vma;
 
 #if NR_CPUS >= CONFIG_SPLIT_PTLOCK_CPUS
 typedef atomic_long_t mm_counter_t;
@@ -94,6 +95,23 @@ struct page {
 };
 
 /*
+ * A structure for containing per page information which is not necessary for
+ * *all* pages. This extra information can be used for anon and page-cache.
+ * (User's page)
+ * Using this will add extra overhead to VM, please consider well before
+ * using this. If used, this is ponted by page->mapping.
+ * See page-cache.h for details.
+ */
+struct anon_vma;
+struct page_mapping_info {
+	struct page *page;
+	union {
+		struct anon_vma		*anon_vma;
+		struct address_space	*mapping;
+	};
+};
+
+/*
  * This struct defines a memory VMM memory area. There is one of these
  * per VM-area/task.  A VM area is any part of the process virtual memory
  * space that has a special rule for the page-fault handlers (ie a shared
@@ -227,4 +245,5 @@ struct mm_struct {
 #endif
 };
 
+
 #endif /* _LINUX_MM_TYPES_H */
Index: test-2.6.23-rc4-mm1/include/linux/page-cache.h
===================================================================
--- test-2.6.23-rc4-mm1.orig/include/linux/page-cache.h
+++ test-2.6.23-rc4-mm1/include/linux/page-cache.h
@@ -20,16 +20,56 @@
  * refers to user virtual address space into which the page is mapped.
  */
 #define PAGE_MAPPING_ANON	1
+#define PAGE_MAPPING_INFO	2   /* page->mapping points to extra info */
+
+#define PAGE_MAPPING_MASK	~(0x3)
+
+#define PAGE_MAPPING(page)	((page)->mapping & PAGE_MAPPING_MASK)
+
+/*
+ * if (!page_has_mapping_info(page))
+ *	page->mapping points to anon_vma or address_space depends on PageAnon.
+ * if (page_has_mapping_info(page))
+ *  	page->mapping points to page_mapping_info.
+ */
 
 static inline int PageAnon(struct page *page)
 {
 	return (page->mapping & PAGE_MAPPING_ANON) != 0;
 }
 
+static inline int page_has_mapping_info(struct page *page)
+{
+	return (page->mapping & PAGE_MAPPING_INFO) != 0;
+}
+
+static inline struct address_space *page_mapping_info_cache(struct page *page)
+{
+	struct page_mapping_info *info;
+
+	if (!page_has_mapping_info(page))
+		return (struct address_space *)PAGE_MAPPING(page);
+	info = (struct page_mapping_info *)PAGE_MAPPING(page);
+	return info->mapping;
+}
+
+static inline struct anon_vma *page_mapping_info_anon(struct page *page)
+{
+	struct page_mapping_info *info;
+
+	if (!page_has_mapping_info(page))
+		return (struct anon_vma *)PAGE_MAPPING(page);
+	info = (struct page_mapping_info *)PAGE_MAPPING(page);
+	return info->anon_vma;
+}
+
+
 extern struct address_space swapper_space;
 static inline struct address_space *page_mapping(struct page *page)
 {
-	struct address_space *mapping = (struct address_space *)page->mapping;
+	struct address_space *mapping;
+
+	mapping = page_mapping_info_cache(page);
 
 	VM_BUG_ON(PageSlab(page));
 	if (unlikely(PageSwapCache(page)))
@@ -38,7 +78,7 @@ static inline struct address_space *page
 	else if (unlikely(PageSlab(page)))
 		mapping = NULL;
 #endif
-	else if (unlikely((unsigned long)mapping & PAGE_MAPPING_ANON))
+	else if (unlikely(PageAnon(page)))
 		mapping = NULL;
 	return mapping;
 }
@@ -47,21 +87,27 @@ static inline struct anon_vma *page_mapp
 {
 	if (!page->mapping || !PageAnon(page))
 		return NULL;
-	return (struct anon_vma *)(page->mapping - PAGE_MAPPING_ANON);
+	return page_mapping_info_anon(page);
 }
 
 static inline struct address_space *page_mapping_cache(struct page *page)
 {
 	if (!page->mapping || PageAnon(page))
 		return NULL;
-	return (struct address_space *)page->mapping;
+	return page_mapping_info_cache(page);
 }
 
+static inline struct page_mapping_info *page_mapping_info(struct page *page)
+{
+	if (!page->mapping || !page_has_mapping_info(page))
+		return NULL;
+	return (struct page_mapping_info *) PAGE_MAPPING(page);
+}
+
+
 static inline int page_is_pagecache(struct page *page)
 {
-	if (!page->mapping || (page->mapping & PAGE_MAPPING_ANON))
-		return 0;
-	return 1;
+	return page_mapping_cache(page) != NULL;
 }
 
 /*
@@ -84,4 +130,14 @@ pagecache_consistent(struct page *page, 
 	return (page_mapping(page) == as);
 }
 
+/*
+ * Attach/Detach page_mapping_info to struct page.
+ * These functions should be called under page_lock().
+ * See mm/rmap.c
+ */
+extern int
+page_add_mapping_info(struct page *page, struct page_mapping_info *info);
+extern void page_remove_mapping_info(struct page *page);
+extern struct page_mapping_info *alloc_page_mapping_info(void);
+extern void free_page_mapping_info(struct page_mapping_info *info);
 #endif
Index: test-2.6.23-rc4-mm1/mm/rmap.c
===================================================================
--- test-2.6.23-rc4-mm1.orig/mm/rmap.c
+++ test-2.6.23-rc4-mm1/mm/rmap.c
@@ -154,6 +154,75 @@ void __init anon_vma_init(void)
 }
 
 /*
+ * page_mapping_info related functions.
+ */
+struct kmem_cache *mapping_info_cachep;
+struct page_mapping_info *alloc_page_mapping_info(void)
+{
+	struct page_mapping_info *info;
+	info = kmem_cache_alloc(mapping_info_cachep, GFP_KERNEL);
+	memset(info, 0, sizeof(*info));
+	return info;
+}
+
+void free_page_mapping_info(struct page_mapping_info *info)
+{
+	kmem_cache_free(mapping_info_cachep, info);
+}
+
+int
+page_add_mapping_info(struct page *page, struct page_mapping_info *info)
+{
+	unsigned long flag = PAGE_MAPPING_INFO;
+
+	if (page_has_mapping_info(page))
+		return 0;
+
+	if (!page->mapping) {
+		/* page is not inserted into objrmap */
+		info->mapping = NULL;
+	} else if (PageAnon(page)) {
+		BUG_ON(!PageLocked(page));
+		info->anon_vma = page_mapping_anon(page);
+		flag |= PAGE_MAPPING_ANON;
+	} else {
+		BUG_ON(!PageLocked(page));
+		info->mapping = page_mapping_cache(page);
+	}
+	smp_wmb();
+	page->mapping = (unsigned long)info | flag;
+	return 1;
+}
+
+
+void page_remove_mapping_info(struct page *page)
+{
+	unsigned long is_anon = PageAnon(page);
+	struct page_mapping_info *info = page_mapping_info(page);
+
+	if (!info)
+		return;
+
+	if (is_anon)
+		page->mapping =
+			(unsigned long)info->anon_vma | PAGE_MAPPING_ANON;
+	else
+		page->mapping = (unsigned long)info->mapping;
+	free_page_mapping_info(info);
+}
+
+
+int __init mapping_info_init(void)
+{
+	mapping_info_cachep =
+		kmem_cache_create("mapping_info",
+					sizeof(struct page_mapping_info),
+					0, SLAB_PANIC, NULL);
+	return 0;
+}
+__initcall(mapping_info_init);
+
+/*
  * Getting a lock on a stable anon_vma from a page off the LRU is
  * tricky: page_lock_anon_vma rely on RCU to guard against the races.
  */
@@ -208,7 +277,7 @@ unsigned long page_address_in_vma(struct
 	if (PageAnon(page)) {
 		if (vma->anon_vma != page_mapping_anon(page))
 			return -EFAULT;
-	} else if (page->mapping && !(vma->vm_flags & VM_NONLINEAR)) {
+	} else if (page_is_pagecache(page) && !(vma->vm_flags & VM_NONLINEAR)) {
 		if (!vma->vm_file ||
 		    vma->vm_file->f_mapping != page_mapping_cache(page))
 			return -EFAULT;
@@ -508,10 +577,17 @@ static void __page_set_anon_rmap(struct 
 	struct vm_area_struct *vma, unsigned long address)
 {
 	struct anon_vma *anon_vma = vma->anon_vma;
+	struct page_mapping_info *info;
 
 	BUG_ON(!anon_vma);
-	anon_vma = (void *) anon_vma + PAGE_MAPPING_ANON;
-	page->mapping = (unsigned long) anon_vma;
+	info = page_mapping_info(page);
+	if (info) {
+		info->anon_vma = anon_vma;
+		page->mapping |= PAGE_MAPPING_ANON;
+	} else {
+		anon_vma = (void *) anon_vma + PAGE_MAPPING_ANON;
+		page->mapping = (unsigned long) anon_vma;
+	}
 
 	page->index = linear_page_index(vma, address);
 
@@ -545,8 +621,7 @@ static void __page_check_anon_rmap(struc
 	 * over the call to page_add_new_anon_rmap.
 	 */
 	struct anon_vma *anon_vma = vma->anon_vma;
-	anon_vma = (void *) anon_vma + PAGE_MAPPING_ANON;
-	BUG_ON(page->mapping != (unsigned long)anon_vma);
+	BUG_ON(page_mapping_anon(page) != anon_vma);
 	BUG_ON(page->index != linear_page_index(vma, address));
 #endif
 }
@@ -670,6 +745,8 @@ void page_remove_rmap(struct page *page,
 			page_clear_dirty(page);
 			set_page_dirty(page);
 		}
+		if (PageAnon(page))
+			page_remove_mapping_info(page);
 		mem_container_uncharge_page(page);
 
 		__dec_zone_page_state(page,
Index: test-2.6.23-rc4-mm1/mm/filemap.c
===================================================================
--- test-2.6.23-rc4-mm1.orig/mm/filemap.c
+++ test-2.6.23-rc4-mm1/mm/filemap.c
@@ -117,6 +117,7 @@ void __remove_from_page_cache(struct pag
 {
 	struct address_space *mapping = page_mapping(page);
 
+	page_remove_mapping_info(page);
 	mem_container_uncharge_page(page);
 	radix_tree_delete(&mapping->page_tree, page->index);
 	page->mapping = 0;
@@ -442,6 +443,7 @@ int add_to_page_cache(struct page *page,
 		pgoff_t offset, gfp_t gfp_mask)
 {
 	int error = radix_tree_preload(gfp_mask & ~__GFP_HIGHMEM);
+	struct page_mapping_info *info;
 
 	if (error == 0) {
 
@@ -454,7 +456,12 @@ int add_to_page_cache(struct page *page,
 		if (!error) {
 			page_cache_get(page);
 			SetPageLocked(page);
-			page->mapping = (unsigned long)mapping;
+			info = page_mapping_info(page);
+			if (info) {
+				info->mapping = mapping;
+			} else {
+				page->mapping = (unsigned long)mapping;
+			}
 			page->index = offset;
 			mapping->nrpages++;
 			__inc_zone_page_state(page, NR_FILE_PAGES);
Index: test-2.6.23-rc4-mm1/mm/page_alloc.c
===================================================================
--- test-2.6.23-rc4-mm1.orig/mm/page_alloc.c
+++ test-2.6.23-rc4-mm1/mm/page_alloc.c
@@ -2739,7 +2739,6 @@ static void setup_pagelist_highmark(stru
 		pcp->batch = PAGE_SHIFT * 8;
 }
 
-
 #ifdef CONFIG_NUMA
 /*
  * Boot pageset table. One per cpu which is going to be used for all

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
