From: kanoj@google.engr.sgi.com (Kanoj Sarcar)
Message-Id: <199907062049.NAA59707@google.engr.sgi.com>
Subject: [PATCH] 2.3.10 pre4 SMP/vm fixes
Date: Tue, 6 Jul 1999 13:49:55 -0700 (PDT)
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
Cc: torvalds@transmeta.com, Kanoj Sarcar <kanoj@google.engr.sgi.com>
List-ID: <linux-mm.kvack.org>

Linus,

Here's a couple of patches against 2.3.10-pre4, wrapped together, 
since they all aim at fixing SMP races in the pre4 code. I have
prepended the patch to each file with some comments about why it
is needed.

Thanks.

Kanoj
kanoj@engr.sgi.com

1. mremap() needs to protect against kswapd accessing/modifying
the pte, as well as concurrent file truncates cleaning the pte
for mmaped files. Also, the f_count bumping can be done without
kernel_lock.

--- mm/mremap.c	Fri Jul  2 13:09:01 1999
+++ /tmp/mremap.c	Tue Jul  6 11:40:26 1999
@@ -57,11 +57,13 @@
 	return pte;
 }
 
-static inline int copy_one_pte(pte_t * src, pte_t * dst)
+static inline int copy_one_pte(struct mm_struct *mm, pte_t * src, pte_t * dst)
 {
 	int error = 0;
-	pte_t pte = *src;
+	pte_t pte;
 
+	spin_lock(mm->page_table_lock);
+	pte = *src;
 	if (!pte_none(pte)) {
 		error++;
 		if (dst) {
@@ -70,6 +72,7 @@
 			error--;
 		}
 	}
+	spin_unlock(mm->page_table_lock);
 	return error;
 }
 
@@ -80,7 +83,7 @@
 
 	src = get_one_pte(mm, old_addr);
 	if (src)
-		error = copy_one_pte(src, alloc_one_pte(mm, new_addr));
+		error = copy_one_pte(mm, src, alloc_one_pte(mm, new_addr));
 	return error;
 }
 
@@ -134,9 +137,9 @@
 			new_vma->vm_start = new_addr;
 			new_vma->vm_end = new_addr+new_len;
 			new_vma->vm_offset = vma->vm_offset + (addr - vma->vm_start);
-			lock_kernel();
 			if (new_vma->vm_file)
 				atomic_inc(&new_vma->vm_file->f_count);
+			lock_kernel();
 			if (new_vma->vm_ops && new_vma->vm_ops->open)
 				new_vma->vm_ops->open(new_vma);
 			insert_vm_struct(current->mm, new_vma);

2. Here's the patch to make sure that mmap file truncation also grabs
the mm spinlock while cleaning the pte's. Note that it would have been
much preferable to grab the spin lock around the call to zap_page_range,
unfortunately, that is not possible because zap_page_range ->
zap_pmd_range -> zap_pte_range -> free_pte -> free_page_and_swap_cache ->
lock_page might sleep. As I was pointing out to Stephen Tweedie, there
is really no reason for free_page_and_swap_cache() to do a lock_page(),
except that free_page_and_swap_cache -> remove_from_swap_cache ->
remove_inode_page expects the page to be locked, else it panics. Also
note that remove_inode_page() grabs pagecache_lock, so it is probably
better not to do nested spin lock grabbing.

--- mm/memory.c	Tue Jul  6 10:52:37 1999
+++ /tmp/memory.c	Tue Jul  6 12:08:04 1999
@@ -322,7 +322,7 @@
 	}
 }
 
-static inline int zap_pte_range(pmd_t * pmd, unsigned long address, unsigned long size)
+static inline int zap_pte_range(struct mm_struct *mm, pmd_t * pmd, unsigned long address, unsigned long size)
 {
 	pte_t * pte;
 	int freed;
@@ -344,18 +344,20 @@
 		pte_t page;
 		if (!size)
 			break;
+		spin_lock(&mm->page_table_lock);
 		page = *pte;
 		pte++;
 		size--;
+		pte_clear(pte-1);
+		spin_unlock(&mm->page_table_lock);
 		if (pte_none(page))
 			continue;
-		pte_clear(pte-1);
 		freed += free_pte(page);
 	}
 	return freed;
 }
 
-static inline int zap_pmd_range(pgd_t * dir, unsigned long address, unsigned long size)
+static inline int zap_pmd_range(struct mm_struct *mm, pgd_t * dir, unsigned long address, unsigned long size)
 {
 	pmd_t * pmd;
 	unsigned long end;
@@ -375,7 +377,7 @@
 		end = PGDIR_SIZE;
 	freed = 0;
 	do {
-		freed += zap_pte_range(pmd, address, end - address);
+		freed += zap_pte_range(mm, pmd, address, end - address);
 		address = (address + PMD_SIZE) & PMD_MASK; 
 		pmd++;
 	} while (address < end);
@@ -393,7 +395,7 @@
 
 	dir = pgd_offset(mm, address);
 	while (address < end) {
-		freed += zap_pmd_range(dir, address, end - address);
+		freed += zap_pmd_range(mm, dir, address, end - address);
 		address = (address + PGDIR_SIZE) & PGDIR_MASK;
 		dir++;
 	}


3. kswapd needs to grab the mm spinlock earlier, to prevent other
access/updates (like from file truncation), once we have removed
the kernel_lock from those paths.


--- mm/vmscan.c	Tue Jul  6 11:31:47 1999
+++ /tmp/vmscan.c	Tue Jul  6 11:29:49 1999
@@ -39,7 +39,6 @@
 	unsigned long page_addr;
 	struct page * page;
 
-	spin_lock(&tsk->mm->page_table_lock);
 	pte = *page_table;
 	if (!pte_present(pte))
 		goto out_failed;
@@ -48,8 +47,9 @@
 		goto out_failed;
 
 	page = mem_map + MAP_NR(page_addr);
+	spin_lock(&tsk->mm->page_table_lock);
 	if (pte_val(pte) != pte_val(*page_table))
-		goto out_failed;
+		goto out_failed_unlock;
 
 	/*
 	 * Dont be too eager to get aging right if
@@ -62,13 +62,13 @@
 		 */
 		set_pte(page_table, pte_mkold(pte));
 		set_bit(PG_referenced, &page->flags);
-		goto out_failed;
+		goto out_failed_unlock;
 	}
 
 	if (PageReserved(page)
 	    || PageLocked(page)
 	    || ((gfp_mask & __GFP_DMA) && !PageDMA(page)))
-		goto out_failed;
+		goto out_failed_unlock;
 
 	/*
 	 * Is the page already in the swap cache? If so, then
@@ -86,7 +86,7 @@
 		vma->vm_mm->rss--;
 		flush_tlb_page(vma, address);
 		__free_page(page);
-		goto out_failed;
+		goto out_failed_unlock;
 	}
 
 	/*
@@ -113,7 +113,7 @@
 	 * locks etc.
 	 */
 	if (!(gfp_mask & __GFP_IO))
-		goto out_failed;
+		goto out_failed_unlock;
 
 	/*
 	 * Ok, it's really dirty. That means that
@@ -174,8 +174,9 @@
 out_free_success:
 	__free_page(page);
 	return 1;
-out_failed:
+out_failed_unlock:
 	spin_unlock(&tsk->mm->page_table_lock);
+out_failed:
 	return 0;
 }
 

4. Now that smp_flush_tlb can not rely on kernel_lock for single
threading (eg from mremap()), it is safest to introduce a new lock 
to provide this protection. Without this lock, at best, irritating 
messages about stuck TLB IPIs will be generated on concurrent 
smp_flush_tlb()s. (I can not guess at worst case scenarios).
I have not attempted to look at the flush_cache_range/flush_tlb_range
type operations for other processors to determine whether they
would need similar protection.


--- arch/i386/kernel/smp.c	Tue Jul  6 10:52:32 1999
+++ /tmp/smp.c	Tue Jul  6 11:49:54 1999
@@ -91,6 +91,9 @@
 /* Kernel spinlock */
 spinlock_t kernel_flag = SPIN_LOCK_UNLOCKED;
 
+/* SMP tlb flush spinlock */
+spinlock_t tlbflush_lock = SPIN_LOCK_UNLOCKED;
+
 /*
  * function prototypes:
  */
@@ -1583,6 +1586,9 @@
 	 * until the AP CPUs have booted up!
 	 */
 	if (cpu_online_map) {
+
+		spin_lock(&tlbflush_lock);
+
 		/*
 		 * The assignment is safe because it's volatile so the
 		 * compiler cannot reorder it, because the i586 has
@@ -1624,6 +1630,7 @@
 			}
 		}
 		__restore_flags(flags);
+		spin_unlock(&tlbflush_lock);
 	}
 
 	/*
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
