Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx158.postini.com [74.125.245.158])
	by kanga.kvack.org (Postfix) with SMTP id DCD2F6B005D
	for <linux-mm@kvack.org>; Tue, 21 Aug 2012 20:48:20 -0400 (EDT)
Subject: Re: [RFC PATCH 2/2] mm: Batch page_check_references in
 shrink_page_list sharing the same i_mmap_mutex
From: Tim Chen <tim.c.chen@linux.intel.com>
In-Reply-To: <20120821132129.GC6960@linux.intel.com>
References: <1345251998.13492.235.camel@schen9-DESK>
	 <1345480982.13492.239.camel@schen9-DESK>
	 <20120821132129.GC6960@linux.intel.com>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 21 Aug 2012 17:48:20 -0700
Message-ID: <1345596500.13492.264.camel@schen9-DESK>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@linux.intel.com>
Cc: Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, Minchan Kim <minchan@kernel.org>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andi Kleen <ak@linux.intel.com>, linux-mm@kvack.org, linux-kernel <linux-kernel@vger.kernel.org>, Alex Shi <alex.shi@intel.com>

On Tue, 2012-08-21 at 09:21 -0400, Matthew Wilcox wrote:
> On Mon, Aug 20, 2012 at 09:43:02AM -0700, Tim Chen wrote:
> > > In shrink_page_list, call to page_referenced_file will causes the
> > > acquisition/release of mapping->i_mmap_mutex for each page in the page
> > > list.  However, it is very likely that successive pages in the list
> > > share the same mapping and we can reduce the frequency of i_mmap_mutex
> > > acquisition by holding the mutex in shrink_page_list. This improves the
> > > performance when the system has a lot page reclamations for file mapped
> > > pages if workloads are using a lot of memory for page cache.
> 
> Is there a (performant) way to avoid passing around the
> 'mmap_mutex_locked' state?
> 
> For example, does it hurt to have all the callers hold the i_mmap_mutex()
> over the entire call, or do we rely on being able to execute large chunks
> of this in parallel?
> 
> Here's what I'm thinking:
> 
> 1. Rename the existing page_referenced implementation to __page_referenced().
> 2. Add:
> 
> int needs_page_mmap_mutex(struct page *page)
> {
> 	return page->mapping && page_mapped(page) && page_rmapping(page) &&
> 		!PageKsm(page) && !PageAnon(page);
> }
> 
> int page_referenced(struct page *page, int is_locked, struct mem_cgroup *memcg,
> 						unsigned long *vm_flags)
> {
> 	int result, needs_lock;
> 
> 	needs_lock = needs_page_mmap_mutex(page);
> 	if (needs_lock)
> 		mutex_lock(&page->mapping->i_mmap_mutex);
> 	result = __page_referenced(page, is_locked, memcg, vm_flags);
> 	if (needs_lock)
> 		mutex_unlock(&page->mapping->i_mmap_mutex);
> 	return result;
> }
> 
> 3. Rename the existing try_to_unmap() to __try_to_unmap()
> 4. Add:
> 
> int try_to_unmap(struct page *page, enum ttu_flags flags)
> {
> 	int result, needs_lock;
> 	
> 	needs_lock = needs_page_mmap_mutex(page);
> 	if (needs_lock)
> 		mutex_lock(&page->mapping->i_mmap_mutex);
> 	result = __try_to_unmap(page, is_locked, memcg, vm_flags);
> 	if (needs_lock)
> 		mutex_unlock(&page->mapping->i_mmap_mutex);
> 	return result;
> }
> 
> 5. Change page_check_references to always call __page_referenced (since it
> now always holds the mutex)
> 6. Replace the mutex_lock() calls in page_referenced_file() and
> try_to_unmap_file() with
> 	BUG_ON(!mutex_is_locked(&mapping->i_mmap_mutex));
> 7. I think you can simplify this:


Thanks to Matthew's suggestions on improving the patch. Here's the
updated version.  It seems to be sane when I booted my machine up.  I
will put it through more testing when I get a chance.

Tim

---
Signed-off-by: Tim Chen <tim.c.chen@linux.intel.com>
---
diff --git a/include/linux/rmap.h b/include/linux/rmap.h
index fd07c45..f1320b1 100644
--- a/include/linux/rmap.h
+++ b/include/linux/rmap.h
@@ -156,8 +156,11 @@ static inline void page_dup_rmap(struct page *page)
 /*
  * Called from mm/vmscan.c to handle paging out
  */
-int page_referenced(struct page *, int is_locked,
-			struct mem_cgroup *memcg, unsigned long *vm_flags);
+int needs_page_mmap_mutex(struct page *page);
+int page_referenced(struct page *, int is_locked, struct mem_cgroup *memcg,
+				unsigned long *vm_flags);
+int __page_referenced(struct page *, int is_locked, struct mem_cgroup *memcg,
+				unsigned long *vm_flags);
 int page_referenced_one(struct page *, struct vm_area_struct *,
 	unsigned long address, unsigned int *mapcount, unsigned long *vm_flags);
 
@@ -176,6 +179,7 @@ enum ttu_flags {
 bool is_vma_temporary_stack(struct vm_area_struct *vma);
 
 int try_to_unmap(struct page *, enum ttu_flags flags);
+int __try_to_unmap(struct page *, enum ttu_flags flags);
 int try_to_unmap_one(struct page *, struct vm_area_struct *,
 			unsigned long address, enum ttu_flags flags);
 
diff --git a/mm/rmap.c b/mm/rmap.c
index 5b5ad58..ca8cd21 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -843,8 +843,7 @@ static int page_referenced_file(struct page *page,
 	 * so we can safely take mapping->i_mmap_mutex.
 	 */
 	BUG_ON(!PageLocked(page));
-
-	mutex_lock(&mapping->i_mmap_mutex);
+	BUG_ON(!mutex_is_locked(&mapping->i_mmap_mutex));
 
 	/*
 	 * i_mmap_mutex does not stabilize mapcount at all, but mapcount
@@ -869,21 +868,16 @@ static int page_referenced_file(struct page *page,
 			break;
 	}
 
-	mutex_unlock(&mapping->i_mmap_mutex);
 	return referenced;
 }
 
-/**
- * page_referenced - test if the page was referenced
- * @page: the page to test
- * @is_locked: caller holds lock on the page
- * @memcg: target memory cgroup
- * @vm_flags: collect encountered vma->vm_flags who actually referenced the page
- *
- * Quick test_and_clear_referenced for all mappings to a page,
- * returns the number of ptes which referenced the page.
- */
-int page_referenced(struct page *page,
+int needs_page_mmap_mutex(struct page *page)
+{
+	return page->mapping && page_mapped(page) && page_rmapping(page) &&
+		!PageKsm(page) && !PageAnon(page);
+}
+
+int __page_referenced(struct page *page,
 		    int is_locked,
 		    struct mem_cgroup *memcg,
 		    unsigned long *vm_flags)
@@ -919,6 +913,32 @@ out:
 	return referenced;
 }
 
+/**
+ * page_referenced - test if the page was referenced
+ * @page: the page to test
+ * @is_locked: caller holds lock on the page
+ * @memcg: target memory cgroup
+ * @vm_flags: collect encountered vma->vm_flags who actually referenced the page
+ *
+ * Quick test_and_clear_referenced for all mappings to a page,
+ * returns the number of ptes which referenced the page.
+ */
+int page_referenced(struct page *page,
+		    int is_locked,
+		    struct mem_cgroup *memcg,
+		    unsigned long *vm_flags)
+{
+	int result, needs_lock;
+
+	needs_lock = needs_page_mmap_mutex(page);
+	if (needs_lock)
+		mutex_lock(&page->mapping->i_mmap_mutex);
+	result = __page_referenced(page, is_locked, memcg, vm_flags);
+	if (needs_lock)
+		mutex_unlock(&page->mapping->i_mmap_mutex);
+	return result;
+}
+
 static int page_mkclean_one(struct page *page, struct vm_area_struct *vma,
 			    unsigned long address)
 {
@@ -1560,7 +1580,7 @@ static int try_to_unmap_file(struct page *page, enum ttu_flags flags)
 	unsigned long max_nl_size = 0;
 	unsigned int mapcount;
 
-	mutex_lock(&mapping->i_mmap_mutex);
+	BUG_ON(!mutex_is_locked(&mapping->i_mmap_mutex));
 	vma_prio_tree_foreach(vma, &iter, &mapping->i_mmap, pgoff, pgoff) {
 		unsigned long address = vma_address(page, vma);
 		if (address == -EFAULT)
@@ -1640,7 +1660,24 @@ static int try_to_unmap_file(struct page *page, enum ttu_flags flags)
 	list_for_each_entry(vma, &mapping->i_mmap_nonlinear, shared.vm_set.list)
 		vma->vm_private_data = NULL;
 out:
-	mutex_unlock(&mapping->i_mmap_mutex);
+	return ret;
+}
+
+int __try_to_unmap(struct page *page, enum ttu_flags flags)
+{
+	int ret;
+
+	BUG_ON(!PageLocked(page));
+	VM_BUG_ON(!PageHuge(page) && PageTransHuge(page));
+
+	if (unlikely(PageKsm(page)))
+		ret = try_to_unmap_ksm(page, flags);
+	else if (PageAnon(page))
+		ret = try_to_unmap_anon(page, flags);
+	else
+		ret = try_to_unmap_file(page, flags);
+	if (ret != SWAP_MLOCK && !page_mapped(page))
+		ret = SWAP_SUCCESS;
 	return ret;
 }
 
@@ -1660,20 +1697,27 @@ out:
  */
 int try_to_unmap(struct page *page, enum ttu_flags flags)
 {
-	int ret;
+	int result, needs_lock;
+
+	needs_lock = needs_page_mmap_mutex(page);
+	if (needs_lock)
+		mutex_lock(&page->mapping->i_mmap_mutex);
+	result = __try_to_unmap(page, flags);
+	if (needs_lock)
+		mutex_unlock(&page->mapping->i_mmap_mutex);
+	return result;
+}
 
-	BUG_ON(!PageLocked(page));
-	VM_BUG_ON(!PageHuge(page) && PageTransHuge(page));
+int __try_to_munlock(struct page *page)
+{
+	VM_BUG_ON(!PageLocked(page) || PageLRU(page));
 
 	if (unlikely(PageKsm(page)))
-		ret = try_to_unmap_ksm(page, flags);
+		return try_to_unmap_ksm(page, TTU_MUNLOCK);
 	else if (PageAnon(page))
-		ret = try_to_unmap_anon(page, flags);
+		return try_to_unmap_anon(page, TTU_MUNLOCK);
 	else
-		ret = try_to_unmap_file(page, flags);
-	if (ret != SWAP_MLOCK && !page_mapped(page))
-		ret = SWAP_SUCCESS;
-	return ret;
+		return try_to_unmap_file(page, TTU_MUNLOCK);
 }
 
 /**
@@ -1693,14 +1737,15 @@ int try_to_unmap(struct page *page, enum ttu_flags flags)
  */
 int try_to_munlock(struct page *page)
 {
-	VM_BUG_ON(!PageLocked(page) || PageLRU(page));
-
-	if (unlikely(PageKsm(page)))
-		return try_to_unmap_ksm(page, TTU_MUNLOCK);
-	else if (PageAnon(page))
-		return try_to_unmap_anon(page, TTU_MUNLOCK);
-	else
-		return try_to_unmap_file(page, TTU_MUNLOCK);
+	int result, needs_lock;
+
+	needs_lock = needs_page_mmap_mutex(page);
+	if (needs_lock)
+		mutex_lock(&page->mapping->i_mmap_mutex);
+	result = __try_to_munlock(page);
+	if (needs_lock)
+		mutex_unlock(&page->mapping->i_mmap_mutex);
+	return result;
 }
 
 void __put_anon_vma(struct anon_vma *anon_vma)
diff --git a/mm/vmscan.c b/mm/vmscan.c
index d4ab646..74a5fd0 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -27,6 +27,7 @@
 					buffer_heads_over_limit */
 #include <linux/mm_inline.h>
 #include <linux/backing-dev.h>
+#include <linux/ksm.h>
 #include <linux/rmap.h>
 #include <linux/topology.h>
 #include <linux/cpu.h>
@@ -786,7 +787,7 @@ static enum page_references page_check_references(struct page *page,
 	int referenced_ptes, referenced_page;
 	unsigned long vm_flags;
 
-	referenced_ptes = page_referenced(page, 1, mz->mem_cgroup, &vm_flags);
+	referenced_ptes = __page_referenced(page, 1, mz->mem_cgroup, &vm_flags);
 	referenced_page = TestClearPageReferenced(page);
 
 	/* Lumpy reclaim - ignore references */
@@ -856,6 +857,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 	unsigned long nr_congested = 0;
 	unsigned long nr_reclaimed = 0;
 	unsigned long nr_writeback = 0;
+	struct mutex *i_mmap_mutex = NULL;
 
 	cond_resched();
 
@@ -909,7 +911,15 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 			}
 		}
 
+		if (needs_page_mmap_mutex(page) &&
+			       i_mmap_mutex != &page->mapping->i_mmap_mutex) {
+			if (i_mmap_mutex)
+				mutex_unlock(i_mmap_mutex);
+			i_mmap_mutex = &page->mapping->i_mmap_mutex;
+			mutex_lock(i_mmap_mutex);
+		}
 		references = page_check_references(page, mz, sc);
+
 		switch (references) {
 		case PAGEREF_ACTIVATE:
 			goto activate_locked;
@@ -939,7 +949,7 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 		 * processes. Try to unmap it here.
 		 */
 		if (page_mapped(page) && mapping) {
-			switch (try_to_unmap(page, TTU_UNMAP)) {
+			switch (__try_to_unmap(page, TTU_UNMAP)) {
 			case SWAP_FAIL:
 				goto activate_locked;
 			case SWAP_AGAIN:
@@ -1090,6 +1100,8 @@ keep_lumpy:
 		VM_BUG_ON(PageLRU(page) || PageUnevictable(page));
 	}
 
+	if (i_mmap_mutex)
+		mutex_unlock(i_mmap_mutex);
 	nr_reclaimed += __remove_mapping_batch(&unmap_pages, &ret_pages,
 					       &free_pages);
 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
