Subject: [RFC][PATCH] tracking dirty pages in shared mappings
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Content-Type: text/plain
Date: Fri, 05 May 2006 22:35:13 +0200
Message-Id: <1146861313.3561.13.camel@lappy>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@osdl.org>
Cc: Andi Kleen <ak@suse.de>, Rohit Seth <rohitseth@google.com>, Andrew Morton <akpm@osdl.org>, clameter@sgi.com, mbligh@google.com, hugh@veritas.com, riel@redhat.com, andrea@suse.de, piggin@cyberone.com.au, arjan@infradead.org, apw@shadowen.org, mel@csn.ul.ie, marcelo@kvack.org, anton@samba.org, paulmck@us.ibm.com, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

People expressed the need to track dirty pages in shared mappings.
Linus outlined the general idea of doing that through making clean
writable pages write-protected and taking the write fault.

This patch does exactly that, it makes pages in a shared writable
mapping write-protected. On write-fault the pages are marked dirty and
made writable. When the pages get synced with their backing store, the
write-protection is re-instated.

It survives a simple test and shows the dirty pages in /proc/vmstat.

Comments?

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>

---

 include/linux/mm.h   |    5 +++-
 include/linux/rmap.h |    6 +++++
 mm/filemap.c         |    3 +-
 mm/fremap.c          |    9 +++++--
 mm/memory.c          |   16 +++++++++++++
 mm/page-writeback.c  |    2 +
 mm/rmap.c            |   61 +++++++++++++++++++++++++++++++++++++++++++++++++++
 mm/shmem.c           |    2 -
 8 files changed, 98 insertions(+), 6 deletions(-)

Index: linux-2.6/include/linux/mm.h
===================================================================
--- linux-2.6.orig/include/linux/mm.h	2006-05-04 21:34:06.000000000 +0200
+++ linux-2.6/include/linux/mm.h	2006-05-05 19:07:58.000000000 +0200
@@ -183,6 +183,9 @@ extern unsigned int kobjsize(const void 
 #define VM_SequentialReadHint(v)	((v)->vm_flags & VM_SEQ_READ)
 #define VM_RandomReadHint(v)		((v)->vm_flags & VM_RAND_READ)
 
+#define VM_SharedWritable(v)		(((v)->vm_flags & (VM_SHARED | VM_MAYSHARE)) && \
+					 ((v)->vm_flags & VM_WRITE))
+
 /*
  * mapping from the currently active vm_flags protection bits (the
  * low four bits) to a page protection mask..
@@ -721,7 +724,7 @@ static inline void unmap_shared_mapping_
 
 extern int vmtruncate(struct inode * inode, loff_t offset);
 extern int vmtruncate_range(struct inode * inode, loff_t offset, loff_t end);
-extern int install_page(struct mm_struct *mm, struct vm_area_struct *vma, unsigned long addr, struct page *page, pgprot_t prot);
+extern int install_page(struct mm_struct *mm, struct vm_area_struct *vma, unsigned long addr, struct page *page, pgprot_t prot, int wrprotect);
 extern int install_file_pte(struct mm_struct *mm, struct vm_area_struct *vma, unsigned long addr, unsigned long pgoff, pgprot_t prot);
 
 #ifdef CONFIG_MMU
Index: linux-2.6/mm/filemap.c
===================================================================
--- linux-2.6.orig/mm/filemap.c	2006-05-04 21:34:06.000000000 +0200
+++ linux-2.6/mm/filemap.c	2006-05-05 19:10:37.000000000 +0200
@@ -1627,7 +1627,8 @@ repeat:
 		return -ENOMEM;
 
 	if (page) {
-		err = install_page(mm, vma, addr, page, prot);
+		err = install_page(mm, vma, addr, page, prot,
+				VM_SharedWritable(vma));
 		if (err) {
 			page_cache_release(page);
 			return err;
Index: linux-2.6/mm/fremap.c
===================================================================
--- linux-2.6.orig/mm/fremap.c	2006-05-04 21:34:06.000000000 +0200
+++ linux-2.6/mm/fremap.c	2006-05-04 22:33:49.000000000 +0200
@@ -49,7 +49,8 @@ static int zap_pte(struct mm_struct *mm,
  * previously existing mapping.
  */
 int install_page(struct mm_struct *mm, struct vm_area_struct *vma,
-		unsigned long addr, struct page *page, pgprot_t prot)
+		unsigned long addr, struct page *page, pgprot_t prot,
+		int wrprotect)
 {
 	struct inode *inode;
 	pgoff_t size;
@@ -79,9 +80,11 @@ int install_page(struct mm_struct *mm, s
 		inc_mm_counter(mm, file_rss);
 
 	flush_icache_page(vma, page);
-	set_pte_at(mm, addr, pte, mk_pte(page, prot));
+	pte_val = mk_pte(page, prot);
+	if (wrprotect)
+		pte_val = pte_wrprotect(pte_val);
+	set_pte_at(mm, addr, pte, pte_val);
 	page_add_file_rmap(page);
-	pte_val = *pte;
 	update_mmu_cache(vma, addr, pte_val);
 	err = 0;
 unlock:
Index: linux-2.6/mm/memory.c
===================================================================
--- linux-2.6.orig/mm/memory.c	2006-05-04 21:34:06.000000000 +0200
+++ linux-2.6/mm/memory.c	2006-05-05 19:37:14.000000000 +0200
@@ -1495,6 +1495,18 @@ static int do_wp_page(struct mm_struct *
 		}
 	}
 
+	if (VM_SharedWritable(vma)) {
+		flush_cache_page(vma, address, pte_pfn(orig_pte));
+		entry = pte_mkyoung(orig_pte);
+		entry = pte_mkwrite(pte_mkdirty(entry));
+		ptep_set_access_flags(vma, address, page_table, entry, 1);
+		update_mmu_cache(vma, address, entry);
+		lazy_mmu_prot_update(entry);
+		ret |= VM_FAULT_WRITE;
+		set_page_dirty(old_page);
+		goto unlock;
+	}
+
 	/*
 	 * Ok, we need to copy. Oh, well..
 	 */
@@ -2150,6 +2162,8 @@ retry:
 		entry = mk_pte(new_page, vma->vm_page_prot);
 		if (write_access)
 			entry = maybe_mkwrite(pte_mkdirty(entry), vma);
+		else if (VM_SharedWritable(vma))
+			entry = pte_wrprotect(entry);
 		set_pte_at(mm, address, page_table, entry);
 		if (anon) {
 			inc_mm_counter(mm, anon_rss);
@@ -2159,6 +2173,8 @@ retry:
 		} else {
 			inc_mm_counter(mm, file_rss);
 			page_add_file_rmap(new_page);
+			if (write_access)
+				set_page_dirty(new_page);
 		}
 	} else {
 		/* One of our sibling threads was faster, back out. */
Index: linux-2.6/mm/shmem.c
===================================================================
--- linux-2.6.orig/mm/shmem.c	2006-05-04 21:34:06.000000000 +0200
+++ linux-2.6/mm/shmem.c	2006-05-04 22:12:54.000000000 +0200
@@ -1270,7 +1270,7 @@ static int shmem_populate(struct vm_area
 		/* Page may still be null, but only if nonblock was set. */
 		if (page) {
 			mark_page_accessed(page);
-			err = install_page(mm, vma, addr, page, prot);
+			err = install_page(mm, vma, addr, page, prot, 0);
 			if (err) {
 				page_cache_release(page);
 				return err;
Index: linux-2.6/mm/page-writeback.c
===================================================================
--- linux-2.6.orig/mm/page-writeback.c	2006-05-04 16:30:46.000000000 +0200
+++ linux-2.6/mm/page-writeback.c	2006-05-05 13:40:08.000000000 +0200
@@ -725,6 +725,7 @@ int test_clear_page_dirty(struct page *p
 						page_index(page),
 						PAGECACHE_TAG_DIRTY);
 			write_unlock_irqrestore(&mapping->tree_lock, flags);
+			page_wrprotect(page);
 			if (mapping_cap_account_dirty(mapping))
 				dec_page_state(nr_dirty);
 			return 1;
@@ -756,6 +757,7 @@ int clear_page_dirty_for_io(struct page 
 
 	if (mapping) {
 		if (TestClearPageDirty(page)) {
+			page_wrprotect(page);
 			if (mapping_cap_account_dirty(mapping))
 				dec_page_state(nr_dirty);
 			return 1;
Index: linux-2.6/mm/rmap.c
===================================================================
--- linux-2.6.orig/mm/rmap.c	2006-05-04 19:27:42.000000000 +0200
+++ linux-2.6/mm/rmap.c	2006-05-05 22:00:34.000000000 +0200
@@ -478,6 +478,67 @@ int page_referenced(struct page *page, i
 	return referenced;
 }
 
+static int page_wrprotect_one(struct page *page, struct vm_area_struct *vma)
+{
+	struct mm_struct *mm = vma->vm_mm;
+	unsigned long address;
+	pte_t *pte, entry;
+	spinlock_t *ptl;
+
+	address = vma_address(page, vma);
+	if (address == -EFAULT)
+		goto out;
+
+	pte = page_check_address(page, mm, address, &ptl);
+	if (!pte)
+		goto out;
+
+	if (!pte_write(*pte))
+		goto unlock;
+
+	entry = pte_wrprotect(*pte);
+	ptep_establish(vma, address, pte, entry);
+	update_mmu_cache(vma, address, entry);
+	lazy_mmu_prot_update(entry);
+
+unlock:
+	pte_unmap_unlock(pte, ptl);
+out:
+	return 0;
+}
+
+static int page_wrprotect_file(struct page *page)
+{
+	struct address_space *mapping = page->mapping;
+	pgoff_t pgoff = page->index << (PAGE_CACHE_SHIFT - PAGE_SHIFT);
+	struct vm_area_struct *vma;
+	struct prio_tree_iter iter;
+
+	BUG_ON(PageAnon(page));
+
+	spin_lock(&mapping->i_mmap_lock);
+
+	vma_prio_tree_foreach(vma, &iter, &mapping->i_mmap, pgoff, pgoff) {
+		if (VM_SharedWritable(vma))
+			page_wrprotect_one(page, vma);
+	}
+
+	spin_unlock(&mapping->i_mmap_lock);
+	return 0;
+}
+
+int page_wrprotect(struct page *page)
+{
+	BUG_ON(!PageLocked(page));
+
+	if (page_mapped(page) && page->mapping) {
+		if (!PageAnon(page))
+			page_wrprotect_file(page);
+	}
+
+	return 0;
+}
+
 /**
  * page_set_anon_rmap - setup new anonymous rmap
  * @page:	the page to add the mapping to
Index: linux-2.6/include/linux/rmap.h
===================================================================
--- linux-2.6.orig/include/linux/rmap.h	2006-05-05 14:02:45.000000000 +0200
+++ linux-2.6/include/linux/rmap.h	2006-05-05 14:03:04.000000000 +0200
@@ -105,6 +105,12 @@ pte_t *page_check_address(struct page *,
  */
 unsigned long page_address_in_vma(struct page *, struct vm_area_struct *);
 
+/*
+ * Used to writeprotect clean pages, in order to count nr_dirty for shared
+ * mappings
+ */
+int page_wrprotect(struct page *);
+
 #else	/* !CONFIG_MMU */
 
 #define anon_vma_init()		do {} while (0)


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
