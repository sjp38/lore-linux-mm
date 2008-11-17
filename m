From: Izik Eidus <ieidus@redhat.com>
Subject: [PATCH 1/4] Rmap: Add page_wrprotect() function.
Date: Mon, 17 Nov 2008 04:20:29 +0200
Message-Id: <1226888432-3662-2-git-send-email-ieidus@redhat.com>
In-Reply-To: <1226888432-3662-1-git-send-email-ieidus@redhat.com>
References: <1226888432-3662-1-git-send-email-ieidus@redhat.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, kvm@vger.kernel.org, aarcange@redhat.com, chrisw@redhat.com, avi@redhat.com, dlaor@redhat.com, kamezawa.hiroyu@jp.fujitsu.com, cl@linux-foundation.org, corbet@lwn.net, ieidus@redhat.com
List-ID: <linux-mm.kvack.org>

this patch add new function called page_wrprotect(),
page_wrprotect() is used to take a page and mark all the pte that
point into it as readonly.

The function is working by walking the rmap of the page, and setting
each pte realted to the page as readonly.

The odirect_sync parameter is used to protect against possible races
with odirect while we are marking the pte as readonly,
as noted by Andrea Arcanglei:

"While thinking at get_user_pages_fast I figured another worse way
things can go wrong with ksm and o_direct: think a thread writing
constantly to the last 512bytes of a page, while another thread read
and writes to/from the first 512bytes of the page. We can lose
O_DIRECT reads, the very moment we mark any pte wrprotected..."

Signed-off-by: Izik Eidus <ieidus@redhat.com>
---
 include/linux/rmap.h |   11 ++++
 mm/rmap.c            |  129 ++++++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 140 insertions(+), 0 deletions(-)

diff --git a/include/linux/rmap.h b/include/linux/rmap.h
index 89f0564..795ac1b 100644
--- a/include/linux/rmap.h
+++ b/include/linux/rmap.h
@@ -121,6 +121,10 @@ static inline int try_to_munlock(struct page *page)
 }
 #endif
 
+#ifdef CONFIG_PAGE_SHARING
+int page_wrprotect(struct page *page, int *odirect_sync, int count_offset);
+#endif
+
 #else	/* !CONFIG_MMU */
 
 #define anon_vma_init()		do {} while (0)
@@ -135,6 +139,13 @@ static inline int page_mkclean(struct page *page)
 	return 0;
 }
 
+#ifdef CONFIG_PAGE_SHARING
+static inline int page_wrprotect(struct page *page, int *odirect_sync,
+				 int count_offset)
+{
+	return 0;
+}
+#endif
 
 #endif	/* CONFIG_MMU */
 
diff --git a/mm/rmap.c b/mm/rmap.c
index 1099394..4c6fed3 100644
--- a/mm/rmap.c
+++ b/mm/rmap.c
@@ -576,6 +576,135 @@ int page_mkclean(struct page *page)
 }
 EXPORT_SYMBOL_GPL(page_mkclean);
 
+#ifdef CONFIG_PAGE_SHARING
+
+static int page_wrprotect_one(struct page *page, struct vm_area_struct *vma,
+			      int *odirect_sync, int count_offset)
+{
+	struct mm_struct *mm = vma->vm_mm;
+	unsigned long address;
+	pte_t *pte;
+	spinlock_t *ptl;
+	int ret = 0;
+
+	address = vma_address(page, vma);
+	if (address == -EFAULT)
+		goto out;
+
+	pte = page_check_address(page, mm, address, &ptl, 0);
+	if (!pte)
+		goto out;
+
+	if (pte_write(*pte)) {
+		pte_t entry;
+
+		/*
+		 * Check that no O_DIRECT or similar I/O is in progress on the
+		 * page
+		 */
+		if ((page_mapcount(page) + count_offset) != page_count(page)) {
+			*odirect_sync = 0;
+			goto out_unlock;
+		}
+		flush_cache_page(vma, address, pte_pfn(*pte));
+		entry = ptep_clear_flush_notify(vma, address, pte);
+		entry = pte_wrprotect(entry);
+		set_pte_at(mm, address, pte, entry);
+	}
+	ret = 1;
+
+out_unlock:
+	pte_unmap_unlock(pte, ptl);
+out:
+	return ret;
+}
+
+static int page_wrprotect_file(struct page *page, int *odirect_sync,
+			       int count_offset)
+{
+	struct address_space *mapping;
+	struct prio_tree_iter iter;
+	struct vm_area_struct *vma;
+	pgoff_t pgoff = page->index << (PAGE_CACHE_SHIFT - PAGE_SHIFT);
+	int ret = 0;
+
+	mapping = page_mapping(page);
+	if (!mapping)
+		return ret;
+
+	spin_lock(&mapping->i_mmap_lock);
+
+	vma_prio_tree_foreach(vma, &iter, &mapping->i_mmap, pgoff, pgoff)
+		ret += page_wrprotect_one(page, vma, odirect_sync,
+					  count_offset);
+
+	spin_unlock(&mapping->i_mmap_lock);
+
+	return ret;
+}
+
+static int page_wrprotect_anon(struct page *page, int *odirect_sync,
+			       int count_offset)
+{
+	struct vm_area_struct *vma;
+	struct anon_vma *anon_vma;
+	int ret = 0;
+
+	anon_vma = page_lock_anon_vma(page);
+	if (!anon_vma)
+		return ret;
+
+	/*
+	 * If the page is inside the swap cache, its _count number was
+	 * increased by one, therefore we have to increase count_offset by one.
+	 */
+	if (PageSwapCache(page))
+		count_offset++;
+
+	list_for_each_entry(vma, &anon_vma->head, anon_vma_node)
+		ret += page_wrprotect_one(page, vma, odirect_sync,
+					  count_offset);
+
+	page_unlock_anon_vma(anon_vma);
+
+	return ret;
+}
+
+/**
+ * page_wrprotect - set all ptes pointing to a page as readonly
+ * @page:         the page to set as readonly
+ * @odirect_sync: boolean value that is set to 0 when some of the ptes were not
+ *                marked as readonly beacuse page_wrprotect_one() was not able
+ *                to mark this ptes as readonly without opening window to a race
+ *                with odirect
+ * @count_offset: number of times page_wrprotect() caller had called get_page()
+ *                on the page
+ *
+ * returns the number of ptes which were marked as readonly.
+ * (ptes that were readonly before this function was called are counted as well)
+ */
+int page_wrprotect(struct page *page, int *odirect_sync, int count_offset)
+{
+	int ret = 0;
+
+	/*
+	 * Page lock is needed for anon pages for the PageSwapCache check,
+	 * and for page_mapping for filebacked pages
+	 */
+	BUG_ON(!PageLocked(page));
+
+	*odirect_sync = 1;
+	if (PageAnon(page))
+		ret = page_wrprotect_anon(page, odirect_sync, count_offset);
+	else
+		ret = page_wrprotect_file(page, odirect_sync, count_offset);
+
+	return ret;
+}
+EXPORT_SYMBOL(page_wrprotect);
+
+#endif
+
 /**
  * __page_set_anon_rmap - setup new anonymous rmap
  * @page:	the page to add the mapping to
-- 
1.6.0.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
