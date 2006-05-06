Subject: Re: [RFC][PATCH] tracking dirty pages in shared mappings
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <445CA907.9060002@cyberone.com.au>
References: <1146861313.3561.13.camel@lappy>
	 <445CA22B.8030807@cyberone.com.au> <1146922446.3561.20.camel@lappy>
	 <445CA907.9060002@cyberone.com.au>
Content-Type: multipart/mixed; boundary="=-7Qrh7IQJ/6X/jTx5QYRB"
Date: Sat, 06 May 2006 17:29:17 +0200
Message-Id: <1146929357.3561.28.camel@lappy>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <piggin@cyberone.com.au>
Cc: Linus Torvalds <torvalds@osdl.org>, Andi Kleen <ak@suse.de>, Rohit Seth <rohitseth@google.com>, Andrew Morton <akpm@osdl.org>, clameter@sgi.com, mbligh@google.com, hugh@veritas.com, riel@redhat.com, andrea@suse.de, arjan@infradead.org, apw@shadowen.org, mel@csn.ul.ie, marcelo@kvack.org, anton@samba.org, paulmck@us.ibm.com, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

--=-7Qrh7IQJ/6X/jTx5QYRB
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

On Sat, 2006-05-06 at 23:47 +1000, Nick Piggin wrote:

> Yep. Let's not distract from getting the basic mechanism working though.
> balance_dirty_pages would be patch 2..n ;)

Attached are both a new version of the shared_mapping_dirty patch, and
balance_dirty_pages; to be applied in that order. 

It makes my testcase survive and not OOM like it used to.

> BTW. It is unconventional (outside the read hints stuff) to use macros like
> this. I guess real VM hackers have to know what is intended by any given esoteric
> combination of flags in any given context.
> 
> Not that I hate it.
> 
> But if we're going to start using it, we should work out a sane convention and
> stick to it. "StudlyCaps" seem to be out of favour, and using a vma_ prefix would
> be more sensible.

Not a real fan of "StudlyCaps" myself either, just adapting to whatever
was there.

This macro was born because I find writing the same thing more than
twice a nuisance and errorprone. However if ppl feel otherwise I'm fine
with either writing it out explicitly or renaming the thing,
suggestions?

PeterZ



--=-7Qrh7IQJ/6X/jTx5QYRB
Content-Disposition: attachment; filename=balance_dirty_pages.patch
Content-Type: text/x-patch; name=balance_dirty_pages.patch; charset=utf-8
Content-Transfer-Encoding: 7bit

 mm/memory.c |   18 ++++++++++++++++--
 1 file changed, 16 insertions(+), 2 deletions(-)

Index: linux-2.6/mm/memory.c
===================================================================
--- linux-2.6.orig/mm/memory.c	2006-05-06 16:51:01.000000000 +0200
+++ linux-2.6/mm/memory.c	2006-05-06 17:15:16.000000000 +0200
@@ -50,6 +50,7 @@
 #include <linux/init.h>
 #include <linux/mm_page_replace.h>
 #include <linux/backing-dev.h>
+#include <linux/writeback.h>
 
 #include <asm/pgalloc.h>
 #include <asm/uaccess.h>
@@ -2078,6 +2079,7 @@ static int do_no_page(struct mm_struct *
 	unsigned int sequence = 0;
 	int ret = VM_FAULT_MINOR;
 	int anon = 0;
+	int dirty = 0;
 
 	pte_unmap(page_table);
 	BUG_ON(vma->vm_flags & VM_PFNMAP);
@@ -2165,8 +2167,10 @@ retry:
 		} else {
 			inc_mm_counter(mm, file_rss);
 			page_add_file_rmap(new_page);
-			if (write_access)
+			if (write_access) {
 				set_page_dirty(new_page);
+				dirty++;
+			}
 		}
 	} else {
 		/* One of our sibling threads was faster, back out. */
@@ -2179,6 +2183,8 @@ retry:
 	lazy_mmu_prot_update(entry);
 unlock:
 	pte_unmap_unlock(page_table, ptl);
+	if (dirty)
+		balance_dirty_pages_ratelimited_nr(mapping, dirty);
 	return ret;
 oom:
 	page_cache_release(new_page);
@@ -2243,6 +2249,8 @@ static inline int handle_pte_fault(struc
 	pte_t entry;
 	pte_t old_entry;
 	spinlock_t *ptl;
+	struct address_space *mapping;
+	int dirty = 0;
 
 	old_entry = entry = *pte;
 	if (!pte_present(entry)) {
@@ -2273,8 +2281,11 @@ static inline int handle_pte_fault(struc
 				struct page *page;
 				entry = pte_mkwrite(entry);
 				page = vm_normal_page(vma, address, entry);
-				if (page)
+				if (page) {
 					set_page_dirty(page);
+					mapping = page_mapping(page);
+					dirty++;
+				}
 			}
 		}
 		entry = pte_mkdirty(entry);
@@ -2297,6 +2308,9 @@ static inline int handle_pte_fault(struc
 	}
 unlock:
 	pte_unmap_unlock(pte, ptl);
+	if (dirty && mapping)
+		balance_dirty_pages_ratelimited_nr(mapping, dirty);
+
 	return VM_FAULT_MINOR;
 }
 

--=-7Qrh7IQJ/6X/jTx5QYRB
Content-Disposition: attachment; filename=shared_mapping_dirty.patch
Content-Type: text/x-patch; name=shared_mapping_dirty.patch; charset=utf-8
Content-Transfer-Encoding: 7bit


From: Peter Zijlstra <a.p.zijlstra@chello.nl>

People expressed the need to track dirty pages in shared mappings.

Linus outlined the general idea of doing that through making clean
writable pages write-protected and taking the write fault.

This patch does exactly that, it makes pages in a shared writable
mapping write-protected. On write-fault the pages are marked dirty and
made writable. When the pages get synced with their backing store, the
write-protection is re-instated.

It survives a simple test and shows the dirty pages in /proc/vmstat.

Changes in -v2:

 - only wrprotect pages from dirty capable mappings. (Nick Piggin)
 - move the writefault handling from do_wp_page() into handle_pte_fault(). 
   (Nick Piggin)
 - revert to the old install_page interface. (Nick Piggin)
 - also clear the pte dirty bit when we make pages read-only again.
   (spotted by Rik van Riel)
 - make page_wrprotect() return the number of reprotected ptes.

Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>

 include/linux/mm.h   |    2 +
 include/linux/rmap.h |    6 ++++
 mm/fremap.c          |   10 ++++++-
 mm/memory.c          |   24 ++++++++++++++++--
 mm/page-writeback.c  |    9 +++++-
 mm/rmap.c            |   66 +++++++++++++++++++++++++++++++++++++++++++++++++++
 6 files changed, 110 insertions(+), 7 deletions(-)

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
+++ linux-2.6/mm/memory.c	2006-05-06 17:20:57.000000000 +0200
@@ -49,6 +49,7 @@
 #include <linux/module.h>
 #include <linux/init.h>
 #include <linux/mm_page_replace.h>
+#include <linux/backing-dev.h>
 
 #include <asm/pgalloc.h>
 #include <asm/uaccess.h>
@@ -2150,6 +2151,11 @@ retry:
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
@@ -2159,6 +2165,8 @@ retry:
 		} else {
 			inc_mm_counter(mm, file_rss);
 			page_add_file_rmap(new_page);
+			if (write_access)
+				set_page_dirty(new_page);
 		}
 	} else {
 		/* One of our sibling threads was faster, back out. */
@@ -2257,12 +2265,22 @@ static inline int handle_pte_fault(struc
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
+				struct page *page;
+				entry = pte_mkwrite(entry);
+				page = vm_normal_page(vma, address, entry);
+				if (page)
+					set_page_dirty(page);
+			}
+		}
 		entry = pte_mkdirty(entry);
 	}
 	entry = pte_mkyoung(entry);
+
 	if (!pte_same(old_entry, entry)) {
 		ptep_set_access_flags(vma, address, pte, entry, write_access);
 		update_mmu_cache(vma, address, entry);
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

--=-7Qrh7IQJ/6X/jTx5QYRB--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
