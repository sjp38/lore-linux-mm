Subject: [RFC][PATCH 1/2] tracking dirty pages in shared mappings -V3
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <Pine.LNX.4.64.0605072338010.18611@schroedinger.engr.sgi.com>
References: <1146861313.3561.13.camel@lappy>
	 <445CA22B.8030807@cyberone.com.au> <1146922446.3561.20.camel@lappy>
	 <445CA907.9060002@cyberone.com.au> <1146929357.3561.28.camel@lappy>
	 <Pine.LNX.4.64.0605072338010.18611@schroedinger.engr.sgi.com>
Content-Type: text/plain
Date: Mon, 08 May 2006 21:20:33 +0200
Message-Id: <1147116034.16600.2.camel@lappy>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <clameter@sgi.com>
Cc: Nick Piggin <piggin@cyberone.com.au>, Linus Torvalds <torvalds@osdl.org>, Andi Kleen <ak@suse.de>, Rohit Seth <rohitseth@google.com>, Andrew Morton <akpm@osdl.org>, mbligh@google.com, hugh@veritas.com, riel@redhat.com, andrea@suse.de, arjan@infradead.org, apw@shadowen.org, mel@csn.ul.ie, marcelo@kvack.org, anton@samba.org, paulmck@us.ibm.com, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

From: Peter Zijlstra <a.p.zijlstra@chello.nl>

People expressed the need to track dirty pages in shared mappings.

Linus outlined the general idea of doing that through making clean
writable pages write-protected and taking the write fault.

This patch does exactly that, it makes pages in a shared writable
mapping write-protected. On write-fault the pages are marked dirty and
made writable. When the pages get synced with their backing store, the
write-protection is re-instated.

It survives a simple test and shows the dirty pages in /proc/vmstat.

Changes in -v3:

 - move set_page_dirty() outside pte lock (suggested by Christoph Lameter)

Changes in -v2:

 - only wrprotect pages from dirty capable mappings. (Nick Piggin)
 - move the writefault handling from do_wp_page() into handle_pte_fault(). 
   (Nick Piggin)
 - revert to the old install_page interface. (Nick Piggin)
 - also clear the pte dirty bit when we make pages read-only again.
   (spotted by Rik van Riel)
 - make page_wrprotect() return the number of reprotected ptes.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>

---

 include/linux/mm.h   |    2 +
 include/linux/rmap.h |    6 ++++
 mm/fremap.c          |   10 ++++++-
 mm/memory.c          |   34 +++++++++++++++++++++++---
 mm/page-writeback.c  |    9 +++++-
 mm/rmap.c            |   66 +++++++++++++++++++++++++++++++++++++++++++++++++++
 6 files changed, 120 insertions(+), 7 deletions(-)

Index: linux-2.6/include/linux/mm.h
===================================================================
--- linux-2.6.orig/include/linux/mm.h	2006-05-06 16:45:24.000000000 +0200
+++ linux-2.6/include/linux/mm.h	2006-05-06 16:51:01.000000000 +0200
@@ -183,6 +183,8 @@ extern unsigned int kobjsize(const void 
 #define VM_SequentialReadHint(v)	((v)->vm_flags & VM_SEQ_READ)
 #define VM_RandomReadHint(v)		((v)->vm_flags & VM_RAND_READ)
 
+#define VM_SharedWritable(v) (((v)->vm_flags & (VM_SHARED|VM_WRITE)) == (VM_SHARED|VM_WRITE))
+
 /*
  * mapping from the currently active vm_flags protection bits (the
  * low four bits) to a page protection mask..
Index: linux-2.6/mm/fremap.c
===================================================================
--- linux-2.6.orig/mm/fremap.c	2006-05-06 16:45:24.000000000 +0200
+++ linux-2.6/mm/fremap.c	2006-05-06 16:51:01.000000000 +0200
@@ -15,6 +15,7 @@
 #include <linux/rmap.h>
 #include <linux/module.h>
 #include <linux/syscalls.h>
+#include <linux/backing-dev.h>
 
 #include <asm/mmu_context.h>
 #include <asm/cacheflush.h>
@@ -79,9 +80,14 @@ int install_page(struct mm_struct *mm, s
 		inc_mm_counter(mm, file_rss);
 
 	flush_icache_page(vma, page);
-	set_pte_at(mm, addr, pte, mk_pte(page, prot));
+	pte_val = mk_pte(page, prot);
+	if (VM_SharedWritable(vma)) {
+		struct address_space *mapping = page_mapping(page);
+		if (mapping && mapping_cap_account_dirty(mapping))
+			pte_val = pte_wrprotect(pte_val);
+	}
+	set_pte_at(mm, addr, pte, pte_val);
 	page_add_file_rmap(page);
-	pte_val = *pte;
 	update_mmu_cache(vma, addr, pte_val);
 	err = 0;
 unlock:
Index: linux-2.6/mm/memory.c
===================================================================
--- linux-2.6.orig/mm/memory.c	2006-05-06 16:45:24.000000000 +0200
+++ linux-2.6/mm/memory.c	2006-05-08 18:20:49.000000000 +0200
@@ -49,6 +49,7 @@
 #include <linux/module.h>
 #include <linux/init.h>
 #include <linux/mm_page_replace.h>
+#include <linux/backing-dev.h>
 
 #include <asm/pgalloc.h>
 #include <asm/uaccess.h>
@@ -2077,6 +2078,7 @@ static int do_no_page(struct mm_struct *
 	unsigned int sequence = 0;
 	int ret = VM_FAULT_MINOR;
 	int anon = 0;
+	int dirty = 0;
 
 	pte_unmap(page_table);
 	BUG_ON(vma->vm_flags & VM_PFNMAP);
@@ -2150,6 +2152,11 @@ retry:
 		entry = mk_pte(new_page, vma->vm_page_prot);
 		if (write_access)
 			entry = maybe_mkwrite(pte_mkdirty(entry), vma);
+		else if (VM_SharedWritable(vma)) {
+			struct address_space *mapping = page_mapping(new_page);
+			if (mapping && mapping_cap_account_dirty(mapping))
+				entry = pte_wrprotect(entry);
+		}
 		set_pte_at(mm, address, page_table, entry);
 		if (anon) {
 			inc_mm_counter(mm, anon_rss);
@@ -2159,6 +2166,10 @@ retry:
 		} else {
 			inc_mm_counter(mm, file_rss);
 			page_add_file_rmap(new_page);
+			if (write_access) {
+				get_page(new_page);
+				dirty++;
+			}
 		}
 	} else {
 		/* One of our sibling threads was faster, back out. */
@@ -2171,6 +2182,10 @@ retry:
 	lazy_mmu_prot_update(entry);
 unlock:
 	pte_unmap_unlock(page_table, ptl);
+	if (dirty) {
+		set_page_dirty(new_page);
+		put_page(new_page);
+	}
 	return ret;
 oom:
 	page_cache_release(new_page);
@@ -2235,6 +2250,7 @@ static inline int handle_pte_fault(struc
 	pte_t entry;
 	pte_t old_entry;
 	spinlock_t *ptl;
+	struct page *page = NULL;
 
 	old_entry = entry = *pte;
 	if (!pte_present(entry)) {
@@ -2257,12 +2273,20 @@ static inline int handle_pte_fault(struc
 	if (unlikely(!pte_same(*pte, entry)))
 		goto unlock;
 	if (write_access) {
-		if (!pte_write(entry))
-			return do_wp_page(mm, vma, address,
-					pte, pmd, ptl, entry);
+		if (!pte_write(entry)) {
+			if (!VM_SharedWritable(vma)) {
+				return do_wp_page(mm, vma, address,
+						pte, pmd, ptl, entry);
+			} else {
+				entry = pte_mkwrite(entry);
+				page = vm_normal_page(vma, address, entry);
+				get_page(page);
+			}
+		}
 		entry = pte_mkdirty(entry);
 	}
 	entry = pte_mkyoung(entry);
+
 	if (!pte_same(old_entry, entry)) {
 		ptep_set_access_flags(vma, address, pte, entry, write_access);
 		update_mmu_cache(vma, address, entry);
@@ -2279,6 +2303,10 @@ static inline int handle_pte_fault(struc
 	}
 unlock:
 	pte_unmap_unlock(pte, ptl);
+	if (page) {
+		set_page_dirty(page);
+		put_page(page);
+	}
 	return VM_FAULT_MINOR;
 }
 
Index: linux-2.6/mm/page-writeback.c
===================================================================
--- linux-2.6.orig/mm/page-writeback.c	2006-05-06 16:45:24.000000000 +0200
+++ linux-2.6/mm/page-writeback.c	2006-05-06 16:51:01.000000000 +0200
@@ -29,6 +29,7 @@
 #include <linux/sysctl.h>
 #include <linux/cpu.h>
 #include <linux/syscalls.h>
+#include <linux/rmap.h>
 
 /*
  * The maximum number of pages to writeout in a single bdflush/kupdate
@@ -725,8 +726,10 @@ int test_clear_page_dirty(struct page *p
 						page_index(page),
 						PAGECACHE_TAG_DIRTY);
 			write_unlock_irqrestore(&mapping->tree_lock, flags);
-			if (mapping_cap_account_dirty(mapping))
+			if (mapping_cap_account_dirty(mapping)) {
+				page_wrprotect(page);
 				dec_page_state(nr_dirty);
+			}
 			return 1;
 		}
 		write_unlock_irqrestore(&mapping->tree_lock, flags);
@@ -756,8 +759,10 @@ int clear_page_dirty_for_io(struct page 
 
 	if (mapping) {
 		if (TestClearPageDirty(page)) {
-			if (mapping_cap_account_dirty(mapping))
+			if (mapping_cap_account_dirty(mapping)) {
+				page_wrprotect(page);
 				dec_page_state(nr_dirty);
+			}
 			return 1;
 		}
 		return 0;
Index: linux-2.6/mm/rmap.c
===================================================================
--- linux-2.6.orig/mm/rmap.c	2006-05-06 16:45:24.000000000 +0200
+++ linux-2.6/mm/rmap.c	2006-05-06 16:51:01.000000000 +0200
@@ -478,6 +478,72 @@ int page_referenced(struct page *page, i
 	return referenced;
 }
 
+static int page_wrprotect_one(struct page *page, struct vm_area_struct *vma)
+{
+	struct mm_struct *mm = vma->vm_mm;
+	unsigned long address;
+	pte_t *pte, entry;
+	spinlock_t *ptl;
+	int ret = 0;
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
+	entry = pte_mkclean(pte_wrprotect(*pte));
+	ptep_establish(vma, address, pte, entry);
+	update_mmu_cache(vma, address, entry);
+	lazy_mmu_prot_update(entry);
+	ret = 1;
+
+unlock:
+	pte_unmap_unlock(pte, ptl);
+out:
+	return ret;
+}
+
+static int page_wrprotect_file(struct page *page)
+{
+	struct address_space *mapping = page->mapping;
+	pgoff_t pgoff = page->index << (PAGE_CACHE_SHIFT - PAGE_SHIFT);
+	struct vm_area_struct *vma;
+	struct prio_tree_iter iter;
+	int ret = 0;
+
+	BUG_ON(PageAnon(page));
+
+	spin_lock(&mapping->i_mmap_lock);
+
+	vma_prio_tree_foreach(vma, &iter, &mapping->i_mmap, pgoff, pgoff) {
+		if (VM_SharedWritable(vma))
+			ret += page_wrprotect_one(page, vma);
+	}
+
+	spin_unlock(&mapping->i_mmap_lock);
+	return ret;
+}
+
+int page_wrprotect(struct page *page)
+{
+	int ret = 0;
+
+	BUG_ON(!PageLocked(page));
+
+	if (page_mapped(page) && page->mapping) {
+		if (!PageAnon(page))
+			ret = page_wrprotect_file(page);
+	}
+
+	return ret;
+}
+
 /**
  * page_set_anon_rmap - setup new anonymous rmap
  * @page:	the page to add the mapping to
Index: linux-2.6/include/linux/rmap.h
===================================================================
--- linux-2.6.orig/include/linux/rmap.h	2006-05-06 16:45:24.000000000 +0200
+++ linux-2.6/include/linux/rmap.h	2006-05-06 16:51:01.000000000 +0200
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
