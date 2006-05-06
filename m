Message-ID: <445CA22B.8030807@cyberone.com.au>
Date: Sat, 06 May 2006 23:18:35 +1000
From: Nick Piggin <piggin@cyberone.com.au>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH] tracking dirty pages in shared mappings
References: <1146861313.3561.13.camel@lappy>
In-Reply-To: <1146861313.3561.13.camel@lappy>
Content-Type: multipart/mixed;
 boundary="------------020009050506000506050106"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Linus Torvalds <torvalds@osdl.org>, Andi Kleen <ak@suse.de>, Rohit Seth <rohitseth@google.com>, Andrew Morton <akpm@osdl.org>, clameter@sgi.com, mbligh@google.com, hugh@veritas.com, riel@redhat.com, andrea@suse.de, arjan@infradead.org, apw@shadowen.org, mel@csn.ul.ie, marcelo@kvack.org, anton@samba.org, paulmck@us.ibm.com, linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------020009050506000506050106
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Peter Zijlstra wrote:

>People expressed the need to track dirty pages in shared mappings.
>Linus outlined the general idea of doing that through making clean
>writable pages write-protected and taking the write fault.
>
>This patch does exactly that, it makes pages in a shared writable
>mapping write-protected. On write-fault the pages are marked dirty and
>made writable. When the pages get synced with their backing store, the
>write-protection is re-instated.
>
>It survives a simple test and shows the dirty pages in /proc/vmstat.
>
>Comments?
>

Looks pretty good. Christoph and I were looking at ways to improve
performance impact of this, and skipping the extra work for particular
(eg. shmem) mappings might be a good idea?

Attached is a patch with a couple of things I've currently got.

In the long run, I'd like to be able to set_page_dirty and
balance_dirty_pages outside of both ptl and mmap_sem, for performance
reasons. That will require a reworking of arch code though :(



--------------020009050506000506050106
Content-Type: text/plain;
 name="mm-track-dirty-mmap-fixes.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="mm-track-dirty-mmap-fixes.patch"

Index: linux-2.6/mm/memory.c
===================================================================
--- linux-2.6.orig/mm/memory.c	2006-05-06 23:05:10.000000000 +1000
+++ linux-2.6/mm/memory.c	2006-05-06 23:13:16.000000000 +1000
@@ -48,6 +48,7 @@
 #include <linux/rmap.h>
 #include <linux/module.h>
 #include <linux/init.h>
+#include <linux/backing-dev.h>
 
 #include <asm/pgalloc.h>
 #include <asm/uaccess.h>
@@ -1466,18 +1467,6 @@ static int do_wp_page(struct mm_struct *
 		}
 	}
 
-	if (VM_SharedWritable(vma)) {
-		flush_cache_page(vma, address, pte_pfn(orig_pte));
-		entry = pte_mkyoung(orig_pte);
-		entry = pte_mkwrite(pte_mkdirty(entry));
-		ptep_set_access_flags(vma, address, page_table, entry, 1);
-		update_mmu_cache(vma, address, entry);
-		lazy_mmu_prot_update(entry);
-		ret |= VM_FAULT_WRITE;
-		set_page_dirty(old_page);
-		goto unlock;
-	}
-
 	/*
 	 * Ok, we need to copy. Oh, well..
 	 */
@@ -2131,8 +2120,11 @@ retry:
 		entry = mk_pte(new_page, vma->vm_page_prot);
 		if (write_access)
 			entry = maybe_mkwrite(pte_mkdirty(entry), vma);
-		else if (VM_SharedWritable(vma))
-			entry = pte_wrprotect(entry);
+		else if (VM_SharedWritable(vma)) {
+			struct address_space *mapping = page_mapping(new_page);
+			if (mapping && mapping_cap_account_dirty(mapping))
+				entry = pte_wrprotect(entry);
+		}
 		set_pte_at(mm, address, page_table, entry);
 		if (anon) {
 			inc_mm_counter(mm, anon_rss);
@@ -2241,12 +2233,22 @@ static inline int handle_pte_fault(struc
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
Index: linux-2.6/include/linux/mm.h
===================================================================
--- linux-2.6.orig/include/linux/mm.h	2006-05-06 23:05:10.000000000 +1000
+++ linux-2.6/include/linux/mm.h	2006-05-06 23:06:17.000000000 +1000
@@ -183,8 +183,7 @@ extern unsigned int kobjsize(const void 
 #define VM_SequentialReadHint(v)	((v)->vm_flags & VM_SEQ_READ)
 #define VM_RandomReadHint(v)		((v)->vm_flags & VM_RAND_READ)
 
-#define VM_SharedWritable(v)		(((v)->vm_flags & (VM_SHARED | VM_MAYSHARE)) && \
-					 ((v)->vm_flags & VM_WRITE))
+#define VM_SharedWritable(v)		((v)->vm_flags & (VM_SHARED|VM_WRITE))
 
 /*
  * mapping from the currently active vm_flags protection bits (the
@@ -724,7 +723,7 @@ static inline void unmap_shared_mapping_
 
 extern int vmtruncate(struct inode * inode, loff_t offset);
 extern int vmtruncate_range(struct inode * inode, loff_t offset, loff_t end);
-extern int install_page(struct mm_struct *mm, struct vm_area_struct *vma, unsigned long addr, struct page *page, pgprot_t prot, int wrprotect);
+extern int install_page(struct mm_struct *mm, struct vm_area_struct *vma, unsigned long addr, struct page *page, pgprot_t prot);
 extern int install_file_pte(struct mm_struct *mm, struct vm_area_struct *vma, unsigned long addr, unsigned long pgoff, pgprot_t prot);
 
 #ifdef CONFIG_MMU
Index: linux-2.6/mm/filemap.c
===================================================================
--- linux-2.6.orig/mm/filemap.c	2006-05-06 23:05:10.000000000 +1000
+++ linux-2.6/mm/filemap.c	2006-05-06 23:06:17.000000000 +1000
@@ -1582,8 +1582,7 @@ repeat:
 		return -ENOMEM;
 
 	if (page) {
-		err = install_page(mm, vma, addr, page, prot,
-				VM_SharedWritable(vma));
+		err = install_page(mm, vma, addr, page, prot);
 		if (err) {
 			page_cache_release(page);
 			return err;
Index: linux-2.6/mm/fremap.c
===================================================================
--- linux-2.6.orig/mm/fremap.c	2006-05-06 23:05:10.000000000 +1000
+++ linux-2.6/mm/fremap.c	2006-05-06 23:07:17.000000000 +1000
@@ -15,6 +15,7 @@
 #include <linux/rmap.h>
 #include <linux/module.h>
 #include <linux/syscalls.h>
+#include <linux/backing-dev.h>
 
 #include <asm/mmu_context.h>
 #include <asm/cacheflush.h>
@@ -49,8 +50,7 @@ static int zap_pte(struct mm_struct *mm,
  * previously existing mapping.
  */
 int install_page(struct mm_struct *mm, struct vm_area_struct *vma,
-		unsigned long addr, struct page *page, pgprot_t prot,
-		int wrprotect)
+		unsigned long addr, struct page *page, pgprot_t prot)
 {
 	struct inode *inode;
 	pgoff_t size;
@@ -81,8 +81,11 @@ int install_page(struct mm_struct *mm, s
 
 	flush_icache_page(vma, page);
 	pte_val = mk_pte(page, prot);
-	if (wrprotect)
-		pte_val = pte_wrprotect(pte_val);
+	if (VM_SharedWritable(vma)) {
+		struct address_space *mapping = page_mapping(page);
+		if (mapping && mapping_cap_account_dirty(mapping))
+			pte_val = pte_wrprotect(pte_val);
+	}
 	set_pte_at(mm, addr, pte, pte_val);
 	page_add_file_rmap(page);
 	update_mmu_cache(vma, addr, pte_val);
Index: linux-2.6/mm/shmem.c
===================================================================
--- linux-2.6.orig/mm/shmem.c	2006-05-06 23:05:10.000000000 +1000
+++ linux-2.6/mm/shmem.c	2006-05-06 23:06:17.000000000 +1000
@@ -1270,7 +1270,7 @@ static int shmem_populate(struct vm_area
 		/* Page may still be null, but only if nonblock was set. */
 		if (page) {
 			mark_page_accessed(page);
-			err = install_page(mm, vma, addr, page, prot, 0);
+			err = install_page(mm, vma, addr, page, prot);
 			if (err) {
 				page_cache_release(page);
 				return err;
Index: linux-2.6/mm/page-writeback.c
===================================================================
--- linux-2.6.orig/mm/page-writeback.c	2006-05-06 23:05:10.000000000 +1000
+++ linux-2.6/mm/page-writeback.c	2006-05-06 23:06:28.000000000 +1000
@@ -29,6 +29,7 @@
 #include <linux/sysctl.h>
 #include <linux/cpu.h>
 #include <linux/syscalls.h>
+#include <linux/rmap.h>
 
 /*
  * The maximum number of pages to writeout in a single bdflush/kupdate
@@ -725,9 +726,10 @@ int test_clear_page_dirty(struct page *p
 						page_index(page),
 						PAGECACHE_TAG_DIRTY);
 			write_unlock_irqrestore(&mapping->tree_lock, flags);
-			page_wrprotect(page);
-			if (mapping_cap_account_dirty(mapping))
+			if (mapping_cap_account_dirty(mapping)) {
+				page_wrprotect(page);
 				dec_page_state(nr_dirty);
+			}
 			return 1;
 		}
 		write_unlock_irqrestore(&mapping->tree_lock, flags);
@@ -757,9 +759,10 @@ int clear_page_dirty_for_io(struct page 
 
 	if (mapping) {
 		if (TestClearPageDirty(page)) {
-			page_wrprotect(page);
-			if (mapping_cap_account_dirty(mapping))
+			if (mapping_cap_account_dirty(mapping)) {
+				page_wrprotect(page);
 				dec_page_state(nr_dirty);
+			}
 			return 1;
 		}
 		return 0;

--------------020009050506000506050106--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
