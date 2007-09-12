Date: Wed, 12 Sep 2007 11:48:24 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: [RFC][PATCH] override page->mapping [3/3] mlock counter per page
Message-Id: <20070912114824.6399b0e7.kamezawa.hiroyu@jp.fujitsu.com>
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

An test/exmapble code for using page_mapping_info.

Remember # of mlock()s against a page.
 * just an example. (there may be some other way to add mlock counter per page)
 * remember mlock_cnt in page_mapping_info.
 * When page fault in VM_LOCKED vma occurs, increase mlock_cnt of a page.
 * When munmap() or munlock() is called, declease mlock_cnt of pages
   in region.
 * remove mlocked page from lru patch will be necessary. no real benefit
   at this point.

Signed-off-by:	KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

---
 include/linux/mm.h       |    7 +++++
 include/linux/mm_types.h |    1 
 mm/memory.c              |   26 ++++++++++++++++---
 mm/mlock.c               |   64 +++++++++++++++++++++++++++++++++++++++++++++--
 mm/mmap.c                |    3 ++
 5 files changed, 96 insertions(+), 5 deletions(-)

Index: test-2.6.23-rc4-mm1/mm/mlock.c
===================================================================
--- test-2.6.23-rc4-mm1.orig/mm/mlock.c
+++ test-2.6.23-rc4-mm1/mm/mlock.c
@@ -12,6 +12,63 @@
 #include <linux/syscalls.h>
 #include <linux/sched.h>
 #include <linux/module.h>
+#include <linux/hugetlb.h>
+#include <linux/pagemap.h>
+#include <linux/fs.h>
+
+
+void set_page_mlocked(struct page *page)
+{
+	struct page_mapping_info *info;
+
+	info = page_mapping_info(page);
+	if (!info) {
+		info = alloc_page_mapping_info();
+		atomic_set(&info->mlock_cnt, 1);
+		if (!page_add_mapping_info(page, info))
+			free_page_mapping_info(info);
+	} else
+		atomic_inc(&info->mlock_cnt);
+}
+
+void unset_page_mlocked(struct page *page)
+{
+	struct page_mapping_info *info = page_mapping_info(page);
+	if (!info)
+		return ;
+	atomic_dec(&info->mlock_cnt);
+}
+
+int page_is_mlocked(struct page *page)
+{
+	struct page_mapping_info *info = page_mapping_info(page);
+	if (!info)
+		return 0;
+	return atomic_read(&info->mlock_cnt);
+}
+
+void mlock_region(struct vm_area_struct *vma, int lock,
+			unsigned long start, unsigned long end)
+{
+	struct page *page;
+
+	if (is_vm_hugetlb_page(vma))
+		return;
+
+	while (start < end) {
+		/* Page is not unmapped yet...then no need tor FOLL_GET */
+		page = follow_page(vma, start, 0);
+		if (page) {
+			lock_page(page);
+			if (lock)
+				set_page_mlocked(page);
+			else
+				unset_page_mlocked(page);
+			unlock_page(page);
+		}
+		start += PAGE_SIZE;
+	}
+}
 
 int can_do_mlock(void)
 {
@@ -72,9 +129,12 @@ success:
 	pages = (end - start) >> PAGE_SHIFT;
 	if (newflags & VM_LOCKED) {
 		pages = -pages;
-		if (!(newflags & VM_IO))
+		if (!(newflags & VM_IO)) {
+			mlock_region(vma, 1, start, end);
 			ret = make_pages_present(start, end);
-	}
+		}
+	} else
+		mlock_region(vma, 0, start, end);
 
 	mm->locked_vm -= pages;
 out:
Index: test-2.6.23-rc4-mm1/include/linux/mm_types.h
===================================================================
--- test-2.6.23-rc4-mm1.orig/include/linux/mm_types.h
+++ test-2.6.23-rc4-mm1/include/linux/mm_types.h
@@ -109,6 +109,7 @@ struct page_mapping_info {
 		struct anon_vma		*anon_vma;
 		struct address_space	*mapping;
 	};
+	atomic_t	mlock_cnt;	/* # of mlock()s on this page */
 };
 
 /*
Index: test-2.6.23-rc4-mm1/mm/memory.c
===================================================================
--- test-2.6.23-rc4-mm1.orig/mm/memory.c
+++ test-2.6.23-rc4-mm1/mm/memory.c
@@ -1640,7 +1640,8 @@ gotten:
 
 	if (mem_container_charge(new_page, mm))
 		goto oom_free_new;
-
+	if (vma->vm_flags & VM_LOCKED)
+		set_page_mlocked(new_page);
 	/*
 	 * Re-check the pte - we dropped the lock
 	 */
@@ -1672,8 +1673,11 @@ gotten:
 		/* Free the old page.. */
 		new_page = old_page;
 		ret |= VM_FAULT_WRITE;
-	} else
+	} else {
+		if (vma->vm_flags & VM_LOCKED)
+			unset_page_mlocked(new_page);
 		mem_container_uncharge_page(new_page);
+	}
 
 	if (new_page)
 		page_cache_release(new_page);
@@ -1681,6 +1685,7 @@ gotten:
 		page_cache_release(old_page);
 unlock:
 	pte_unmap_unlock(page_table, ptl);
+
 	if (dirty_page) {
 		/*
 		 * Yes, Virginia, this is actually required to prevent a race
@@ -2188,6 +2193,9 @@ static int do_anonymous_page(struct mm_s
 		if (mem_container_charge(page, mm))
 			goto oom_free_page;
 
+	if (vma->vm_flags & VM_LOCKED)
+		set_page_mlocked(page);
+
 	entry = mk_pte(page, vma->vm_page_prot);
 	entry = maybe_mkwrite(pte_mkdirty(entry), vma);
 
@@ -2197,6 +2205,10 @@ static int do_anonymous_page(struct mm_s
 	inc_mm_counter(mm, anon_rss);
 	lru_cache_add_active(page);
 	page_add_new_anon_rmap(page, vma, address);
+
+	if (vma->vm_flags & VM_LOCKED)
+		set_page_mlocked(page);
+
 	set_pte_at(mm, address, page_table, entry);
 
 	/* No need to invalidate - it was non-present before */
@@ -2205,6 +2217,8 @@ unlock:
 	pte_unmap_unlock(page_table, ptl);
 	return 0;
 release:
+	if (vma->vm_flags & VM_LOCKED)
+		unset_page_mlocked(page);
 	mem_container_uncharge_page(page);
 	page_cache_release(page);
 	goto unlock;
@@ -2325,6 +2339,12 @@ static int __do_fault(struct mm_struct *
 		ret = VM_FAULT_OOM;
 		goto out;
 	}
+	/*
+	 * If new page is page-cache, lock_page9) is held.
+	 * If new page is anon, page is not linked to objrmap yet.
+	 */
+	if (vma->vm_flags & VM_LOCKED)
+		set_page_mlocked(page);
 
 	page_table = pte_offset_map_lock(mm, pmd, address, &ptl);
 
@@ -2357,11 +2377,11 @@ static int __do_fault(struct mm_struct *
 				get_page(dirty_page);
 			}
 		}
-
 		/* no need to invalidate: a not-present page won't be cached */
 		update_mmu_cache(vma, address, entry);
 	} else {
 		mem_container_uncharge_page(page);
+
 		if (anon)
 			page_cache_release(page);
 		else
Index: test-2.6.23-rc4-mm1/mm/mmap.c
===================================================================
--- test-2.6.23-rc4-mm1.orig/mm/mmap.c
+++ test-2.6.23-rc4-mm1/mm/mmap.c
@@ -1750,6 +1750,9 @@ static void unmap_region(struct mm_struc
 	struct mmu_gather *tlb;
 	unsigned long nr_accounted = 0;
 
+	if (vma->vm_flags & VM_LOCKED)
+		mlock_region(vma, 0, start, end);
+
 	lru_add_drain();
 	tlb = tlb_gather_mmu(mm, 0);
 	update_hiwater_rss(mm);
Index: test-2.6.23-rc4-mm1/include/linux/mm.h
===================================================================
--- test-2.6.23-rc4-mm1.orig/include/linux/mm.h
+++ test-2.6.23-rc4-mm1/include/linux/mm.h
@@ -643,6 +643,13 @@ extern int can_do_mlock(void);
 extern int user_shm_lock(size_t, struct user_struct *);
 extern void user_shm_unlock(size_t, struct user_struct *);
 
+
+extern void set_page_mlocked(struct page *page);
+extern void unset_page_mlocked(struct page *page);
+extern void mlock_region(struct vm_area_struct *vma, int op,
+				unsigned long start, unsigned long end);
+extern int page_is_mlocked(struct page *page);
+
 /*
  * Parameter block passed down to zap_pte_range in exceptional cases.
  */

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
