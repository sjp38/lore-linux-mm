From: kanoj@google.engr.sgi.com (Kanoj Sarcar)
Message-Id: <199907080719.AAA00822@google.engr.sgi.com>
Subject: [RFT][PATCH] 2.3.10 pre5 SMP/vm fixes
Date: Thu, 8 Jul 1999 00:19:09 -0700 (PDT)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
Cc: torvalds@transmeta.com, Kanoj Sarcar <kanoj@google.engr.sgi.com>
List-ID: <linux-mm.kvack.org>

This set of 5 patches tries to fix SMP races in the 2.3.10-pre5
kernel. I have prepended some comments before each patch.

Kanoj
kanoj@engr.sgi.com

*****************************************************************
1. Provide smp protection for ia32 tlb flushing (mremap() invokes
flush_tlb_all() without holding kernel_lock).
*****************************************************************

--- linux.old/include/asm-i386/bitops.h	Wed Jul  7 08:16:57 1999
+++ linux/include/asm-i386/bitops.h	Wed Jul  7 10:23:11 1999
@@ -49,6 +49,14 @@
 		:"Ir" (nr));
 }
 
+extern __inline__ void set_bits(int orval, volatile void * addr)
+{
+	__asm__ __volatile__( LOCK_PREFIX
+		"orl %1,%0"
+		:"=m" (ADDR)
+		:"r" (orval));
+}
+
 extern __inline__ void clear_bit(int nr, volatile void * addr)
 {
 	__asm__ __volatile__( LOCK_PREFIX
--- linux.old/arch/i386/kernel/smp.c	Wed Jul  7 08:16:33 1999
+++ linux/arch/i386/kernel/smp.c	Wed Jul  7 10:21:40 1999
@@ -1592,7 +1592,7 @@
 		 * locked or.
 		 */
 
-		smp_invalidate_needed = cpu_online_map;
+		set_bits(cpu_online_map, &smp_invalidate_needed);
 
 		/*
 		 * Processors spinning on some lock with IRQs disabled

*****************************************************************
2. Provide protection between file msync and kswapd/shrink_mmap 
reclaiming a filecache page.
*****************************************************************

--- linux.old/mm/filemap.c	Wed Jul  7 08:17:03 1999
+++ linux/mm/filemap.c	Wed Jul  7 11:59:23 1999
@@ -1498,16 +1498,18 @@
 static inline int filemap_sync_pte(pte_t * ptep, struct vm_area_struct *vma,
 	unsigned long address, unsigned int flags)
 {
-	pte_t pte = *ptep;
+	pte_t pte;
 	unsigned long pageaddr;
 	struct page *page;
 	int error;
 
+	spin_lock(&vma->vm_mm->page_table_lock);
+	pte = *ptep;
 	if (!(flags & MS_INVALIDATE)) {
 		if (!pte_present(pte))
-			return 0;
+			goto out;
 		if (!pte_dirty(pte))
-			return 0;
+			goto out;
 		flush_page_to_ram(pte_page(pte));
 		flush_cache_page(vma, address);
 		set_pte(ptep, pte_mkclean(pte));
@@ -1517,23 +1519,27 @@
 		get_page(page);
 	} else {
 		if (pte_none(pte))
-			return 0;
+			goto out;
 		flush_cache_page(vma, address);
 		pte_clear(ptep);
 		flush_tlb_page(vma, address);
 		if (!pte_present(pte)) {
 			swap_free(pte_val(pte));
-			return 0;
+			goto out;
 		}
 		pageaddr = pte_page(pte);
 		if (!pte_dirty(pte) || flags == MS_INVALIDATE) {
 			page_cache_free(pageaddr);
-			return 0;
+			goto out;
 		}
 	}
+	spin_unlock(&vma->vm_mm->page_table_lock);
 	error = filemap_write_page(vma, address - vma->vm_start + vma->vm_offset, pageaddr, 1);
 	page_cache_free(pageaddr);
 	return error;
+out:
+	spin_unlock(&vma->vm_mm->page_table_lock);
+	return(0);
 }
 
 static inline int filemap_sync_pte_range(pmd_t * pmd,

*****************************************************************
3. In mm/memory.c, a new comment claims:
"The adding of pages is protected by the MM semaphore"
which is not quite correct, since swapoff does not hold this semaphore. 
A patch against this has been posted at

     http://humbolt.nl.linux.org/lists/linux-mm/1999-06/msg00075.html

This patch also fixes races between swapoff and fork, exit, mremap and 
async swap readaheads during page faults.

In the absence of this patch in 2.3, and if we ever want to run swapoff
while kswapd is active (ie, kernel_lock is eliminated from either of 
these paths), the following changes are needed.
*****************************************************************

--- linux.old/mm/swapfile.c	Wed Jul  7 08:17:03 1999
+++ linux/mm/swapfile.c	Wed Jul  7 11:40:15 1999
@@ -171,24 +171,27 @@
 {
 	pte_t pte = *dir;
 
+	spin_lock(&vma->vm_mm->page_table_lock);
 	if (pte_none(pte))
-		return;
+		goto out;
 	if (pte_present(pte)) {
 		/* If this entry is swap-cached, then page must already
                    hold the right address for any copies in physical
                    memory */
 		if (pte_page(pte) != page)
-			return;
+			goto out;
 		/* We will be removing the swap cache in a moment, so... */
 		set_pte(dir, pte_mkdirty(pte));
-		return;
+		goto out;
 	}
 	if (pte_val(pte) != entry)
-		return;
+		goto out;
 	set_pte(dir, pte_mkdirty(mk_pte(page, vma->vm_page_prot)));
 	swap_free(entry);
 	get_page(mem_map + MAP_NR(page));
 	++vma->vm_mm->rss;
+out:
+	spin_unlock(&vma->vm_mm->page_table_lock);
 }
 
 static inline void unuse_pmd(struct vm_area_struct * vma, pmd_t *dir,

*****************************************************************
4. If we want to eliminate kernel_lock from the fork/dup_mmap and 
mmap() paths, the following changes are needed to protect against 
kswapd.
*****************************************************************

--- linux.old/mm/memory.c	Wed Jul  7 08:17:03 1999
+++ linux/mm/memory.c	Wed Jul  7 14:25:41 1999
@@ -246,6 +246,7 @@
 			src_pte = pte_offset(src_pmd, address);
 			dst_pte = pte_offset(dst_pmd, address);
 			
+			spin_lock(&vma->vm_mm->page_table_lock);
 			do {
 				pte_t pte = *src_pte;
 				unsigned long page_nr;
@@ -277,11 +278,14 @@
 				get_page(mem_map + page_nr);
 			
 cont_copy_pte_range:		address += PAGE_SIZE;
-				if (address >= end)
+				if (address >= end) {
+					spin_unlock(&vma->vm_mm->page_table_lock);
 					goto out;
+				}
 				src_pte++;
 				dst_pte++;
 			} while ((unsigned long)src_pte & PTE_TABLE_MASK);
+			spin_unlock(&vma->vm_mm->page_table_lock);
 		
 cont_copy_pmd_range:	src_pmd++;
 			dst_pmd++;
@@ -421,8 +425,11 @@
 	do {
 		pte_t zero_pte = pte_wrprotect(mk_pte(ZERO_PAGE(address),
 		                               prot));
-		pte_t oldpage = *pte;
+		pte_t oldpage;
+		spin_lock(&current->mm->page_table_lock);
+		oldpage = *pte;
 		set_pte(pte, zero_pte);
+		spin_unlock(&current->mm->page_table_lock);
 		forget_pte(oldpage);
 		address += PAGE_SIZE;
 		pte++;
@@ -489,12 +496,15 @@
 		end = PMD_SIZE;
 	do {
 		unsigned long mapnr;
-		pte_t oldpage = *pte;
+		pte_t oldpage;
+		spin_lock(&current->mm->page_table_lock);
+		oldpage = *pte;
 		pte_clear(pte);
 
 		mapnr = MAP_NR(__va(phys_addr));
 		if (mapnr >= max_mapnr || PageReserved(mem_map+mapnr))
  			set_pte(pte, mk_pte_phys(phys_addr, prot));
+		spin_unlock(&current->mm->page_table_lock);
 		forget_pte(oldpage);
 		address += PAGE_SIZE;
 		phys_addr += PAGE_SIZE;

*****************************************************************
5. vmtruncate() grabs a spinlock i_shared_lock, then invokes
zap_page_range, which might finally go to sleep via calls to
zap_pmd_range -> zap_pte_range -> free_pte -> free_page_and_swap_cache ->
lock_page. This patch tries to fix that by removing the lock_page
from free_page_and_swap_cache(), which lets i_shared_lock stay a
spinlock. As far as I can see, the need to have the lock_page in
the swap-cache code is to satisfy the validity check PageLocked(page)
in remove_inode_page <- remove_from_swap_cache <- delete_from_swap_cache.
And the same check in block_flushpage. Note that pages in the swap cache
do not have associated buffers, so a block_flushpage is not really needed
for these pages. If this patch is taken, the page_table_lock grabbing
in zap_pte_range, zeromap_pte_range and remap_pte_range can be done at
the zap_page_range, zeromap_pmd_range and remap_pmd_range, although
I have not included those changes here.

If there is any more intricate reason for the lock_page's in the swap 
cache code, a different fix needs to be applied.
*****************************************************************

--- linux.old/mm/swap_state.c	Wed Jul  7 08:17:03 1999
+++ linux/mm/swap_state.c	Wed Jul  7 21:56:48 1999
@@ -42,7 +42,7 @@
 	NULL,				/* get_block */
 	NULL,				/* readpage */
 	NULL,				/* writepage */
-	block_flushpage,		/* flushpage */
+	NULL,				/* flushpage */
 	NULL,				/* truncate */
 	NULL,				/* permission */
 	NULL,				/* smap */
@@ -214,9 +214,7 @@
 		   page_address(page), page_count(page));
 #endif
 	PageClearSwapCache(page);
-	if (inode->i_op->flushpage)
-		inode->i_op->flushpage(inode, page, 0);
-	remove_inode_page(page);
+	remove_inode_page_nolock(page);
 }
 
 /*
@@ -245,11 +243,7 @@
  */
 void delete_from_swap_cache(struct page *page)
 {
-	lock_page(page);
-
 	__delete_from_swap_cache(page);
-
-	UnlockPage(page);
 	page_cache_release(page);
 }
 
@@ -265,7 +259,6 @@
 	/* 
 	 * If we are the only user, then free up the swap cache. 
 	 */
-	lock_page(page);
 	if (PageSwapCache(page) && !is_page_shared(page)) {
 		long entry = page->offset;
 		remove_from_swap_cache(page);
@@ -272,7 +265,6 @@
 		swap_free(entry);
 		page_cache_release(page);
 	}
-	UnlockPage(page);
 	
 	__free_page(page);
 }
--- linux.old/mm/filemap.c	Wed Jul  7 08:17:03 1999
+++ linux/mm/filemap.c	Wed Jul  7 22:03:49 1999
@@ -99,6 +99,15 @@
 	spin_unlock(&pagecache_lock);
 }
 
+void remove_inode_page_nolock(struct page *page)
+{
+	spin_lock(&pagecache_lock);
+	remove_page_from_inode_queue(page);
+	remove_page_from_hash_queue(page);
+	page->inode = NULL;
+	spin_unlock(&pagecache_lock);
+}
+
 void invalidate_inode_pages(struct inode * inode)
 {
 	struct page ** p;
--- linux.old/include/linux/mm.h	Wed Jul  7 08:17:00 1999
+++ linux/include/linux/mm.h	Wed Jul  7 22:04:19 1999
@@ -344,6 +344,7 @@
 
 /* filemap.c */
 extern void remove_inode_page(struct page *);
+extern void remove_inode_page_nolock(struct page *);
 extern unsigned long page_unuse(struct page *);
 extern int shrink_mmap(int, int);
 extern void truncate_inode_pages(struct inode *, unsigned long);
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
