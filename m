Message-ID: <3969ED88.7238630B@uow.edu.au>
Date: Tue, 11 Jul 2000 01:36:40 +1000
From: Andrew Morton <andrewm@uow.edu.au>
MIME-Version: 1.0
Subject: Re: sys_exit() and zap_page_range()
References: <3965EC8E.5950B758@uow.edu.au>,
            <3965EC8E.5950B758@uow.edu.au> <20000709103011.A3469@fruits.uzix.org> <396910CE.64A79820@uow.edu.au>,
            <396910CE.64A79820@uow.edu.au> <20000710025342.A3826@fruits.uzix.org>
Content-Type: multipart/mixed; boundary="------------DCC423F6E755249668E63CEC"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Philipp Rumpf <prumpf@uzix.org>
Cc: "linux-mm@kvack.org" <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------DCC423F6E755249668E63CEC
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit

Philipp Rumpf wrote:
> 
> On Sun, Jul 09, 2000 at 11:54:54PM +0000, Andrew Morton wrote:
> > Philipp Rumpf wrote:
> > Hi, Philipp.
> >
> > > Here's a simple way:
> >
> > Already done it :)  It's apparent that not _all_ callers of z_p_r need
> > this treatment, so I've added an extra 'do_reschedule' flag.  I've also
> > moved the TLB flushing into this function.
> 
> It is ?  I must be missing something, but it looks to me like all calls
> to z_p_r can be done out of syscalls, with pretty much any size the user
> wants.

Possibly - but I don't want to put reschedules into places unless
they're demonstrated to cause scheduling stalls.  Probably just haven't
run the right tests :(


> > It strikes me that the TLB flush race can be avoided by simply deferring
> > the actual free_page until _after_ the flush.  So
> > free_page_and_swap_cache simply appends them to a passed-in list rather
> > than returning them to the buddy allocator.  zap_page_range can then
> > free the pages after the flush.
> 
> In fact, both the tlb flushing and the cache invalidating/flushing (we don't
> really need to flush the cache if we're zapping the last mapping) belong in
> zap_page_range.

I did that.

>  Right now three callers don't do the tlb/cache flushes:
>  exit_mmap and move_page_tables should be fine with doing the cache/tlb
> invalidates;  read_zero_pagealigned doesn't want to have intermediate invalid
> ptes, so I would say it's buggy now.

Not hard to change.

> > > [PAGE_SIZE*4 is low, I suspect.]
> >
> > zap_page_range zaps 1000 pages per millisecond, so I'm doing 1000 at a
> > time.
> 
> I think we should be able to live with that for 2.4, unless the tlb flushing
> race is really bad.  It looks like a rather theoretical possibility limited
> to SMP systems to me.

hmm..

Anyway, I have the perfect reimplementation which fixes the race and the
damn thing crashes after 5-10 minutes of load and I _cannot_ see what
I've done wrong.  I basically implemented Manfred's initial suggestion
of deferring the page freeing until after the TLB flush.

Can you please cast an eye over the attached patch and pick out why it
would die?  The only sensible diag I got out of it was for one crash
where this test in __free_pages_ok() died:

        if (page->mapping)
                BUG();

It is solid if you disable ZPR_DEFER_FREE_PAGE.  This is on a
uniprocessor.  I thought there may be a race between an interrupt
routine's kmalloc(GFP_ATOMIC) and the local_tlb_flush, so I put a big
local_irq_disable() around the whole thing and it _still_ died.

Need sleep....
--------------DCC423F6E755249668E63CEC
Content-Type: text/plain; charset=us-ascii;
 name="low-latency.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="low-latency.patch"

--- linux-2.4.0-test3-pre7/include/linux/sched.h	Sun Jul  9 21:30:17 2000
+++ linux-akpm/include/linux/sched.h	Mon Jul 10 23:33:54 2000
@@ -146,6 +146,8 @@
 extern signed long FASTCALL(schedule_timeout(signed long timeout));
 asmlinkage void schedule(void);
 
+#define conditional_schedule() do { if (current->need_resched) schedule(); } while (0)
+
 /*
  * The default fd array needs to be at least BITS_PER_LONG,
  * as this is the granularity returned by copy_fdset().
@@ -348,6 +350,7 @@
    	u32 self_exec_id;
 /* Protection of (de-)allocation: mm, files, fs, tty */
 	spinlock_t alloc_lock;
+	int curr_syscall;
 };
 
 /*
@@ -423,6 +426,7 @@
     blocked:		{{0}},						\
     sigqueue:		NULL,						\
     sigqueue_tail:	&tsk.sigqueue,					\
+    curr_syscall:	0,						\
     alloc_lock:		SPIN_LOCK_UNLOCKED				\
 }
 
--- linux-2.4.0-test3-pre7/include/linux/mm.h	Sun Jul  9 21:30:17 2000
+++ linux-akpm/include/linux/mm.h	Mon Jul 10 23:33:54 2000
@@ -142,6 +142,7 @@
  */
 typedef struct page {
 	struct list_head list;
+	struct list_head akpm_list;
 	struct address_space *mapping;
 	unsigned long index;
 	struct page *next_hash;
@@ -178,6 +179,11 @@
 				/* bits 21-30 unused */
 #define PG_reserved		31
 
+/* Actions for zap_page_range() */
+#define ZPR_FLUSH_CACHE		1	/* Do flush_cache_range() prior to releasing pages */
+#define ZPR_FLUSH_TLB		2	/* Do flush_tlb_range() after releasing pages */
+#define ZPR_DEFER_FREE_PAGE	4	/* Defer passing of pages to free_page until after flush_tlb_range() */
+#define ZPR_COND_RESCHED	8	/* Do a conditional_reschedule() occasionally */
 
 /* Make it prettier to test the above... */
 #define Page_Uptodate(page)	test_bit(PG_uptodate, &(page)->flags)
@@ -399,7 +405,7 @@
 
 extern int map_zero_setup(struct vm_area_struct *);
 
-extern void zap_page_range(struct mm_struct *mm, unsigned long address, unsigned long size);
+extern void zap_page_range(struct mm_struct *mm, unsigned long address, unsigned long size, int actions);
 extern int copy_page_range(struct mm_struct *dst, struct mm_struct *src, struct vm_area_struct *vma);
 extern int remap_page_range(unsigned long from, unsigned long to, unsigned long size, pgprot_t prot);
 extern int zeromap_page_range(unsigned long from, unsigned long size, pgprot_t prot);
--- linux-2.4.0-test3-pre7/include/linux/swap.h	Thu May 25 12:52:41 2000
+++ linux-akpm/include/linux/swap.h	Mon Jul 10 23:33:54 2000
@@ -108,7 +108,7 @@
 extern void __delete_from_swap_cache(struct page *page);
 extern void delete_from_swap_cache(struct page *page);
 extern void delete_from_swap_cache_nolock(struct page *page);
-extern void free_page_and_swap_cache(struct page *page);
+extern void free_page_and_swap_cache(struct page *page, struct list_head *reaped_pages);
 
 /* linux/mm/swapfile.c */
 extern unsigned int nr_swapfiles;
--- linux-2.4.0-test3-pre7/mm/swap_state.c	Sun Jul  9 21:30:17 2000
+++ linux-akpm/mm/swap_state.c	Mon Jul 10 22:53:11 2000
@@ -125,7 +125,7 @@
  * this page if it is the last user of the page. Can not do a lock_page,
  * as we are holding the page_table_lock spinlock.
  */
-void free_page_and_swap_cache(struct page *page)
+void free_page_and_swap_cache(struct page *page, struct list_head *reaped_pages)
 {
 	/* 
 	 * If we are the only user, then try to free up the swap cache. 
@@ -136,7 +136,12 @@
 		}
 		UnlockPage(page);
 	}
-	page_cache_release(page);
+	if (reaped_pages) {
+		if (put_page_testzero(page))
+			list_add(&page->akpm_list, reaped_pages);
+	} else {
+		page_cache_release(page);
+	}
 }
 
 
--- linux-2.4.0-test3-pre7/mm/filemap.c	Sun Jul  9 21:30:17 2000
+++ linux-akpm/mm/filemap.c	Mon Jul 10 21:50:43 2000
@@ -160,6 +160,7 @@
 	start = (lstart + PAGE_CACHE_SIZE - 1) >> PAGE_CACHE_SHIFT;
 
 repeat:
+	conditional_schedule();		/* sys_unlink() */
 	head = &mapping->pages;
 	spin_lock(&pagecache_lock);
 	curr = head->next;
@@ -450,6 +451,7 @@
 
 		page_cache_get(page);
 		spin_unlock(&pagecache_lock);
+		conditional_schedule();		/* sys_msync() */
 		lock_page(page);
 
 		/* The buffers could have been free'd while we waited for the page lock */
@@ -1081,6 +1083,8 @@
 		 * "pos" here (the actor routine has to update the user buffer
 		 * pointers and the remaining count).
 		 */
+		conditional_schedule();		/* sys_read() */
+
 		nr = actor(desc, page, offset, nr);
 		offset += nr;
 		index += offset >> PAGE_CACHE_SHIFT;
@@ -1533,6 +1537,7 @@
 	 * vma/file is guaranteed to exist in the unmap/sync cases because
 	 * mmap_sem is held.
 	 */
+	conditional_schedule();		/* sys_msync() */
 	return page->mapping->a_ops->writepage(file, page);
 }
 
@@ -2022,9 +2027,8 @@
 	if (vma->vm_flags & VM_LOCKED)
 		return -EINVAL;
 
-	flush_cache_range(vma->vm_mm, start, end);
-	zap_page_range(vma->vm_mm, start, end - start);
-	flush_tlb_range(vma->vm_mm, start, end);
+	zap_page_range(vma->vm_mm, start, end - start,
+			ZPR_FLUSH_CACHE|ZPR_FLUSH_TLB|ZPR_DEFER_FREE_PAGE|ZPR_COND_RESCHED);
 	return 0;
 }
 
@@ -2487,6 +2491,8 @@
 	while (count) {
 		unsigned long bytes, index, offset;
 		char *kaddr;
+
+		conditional_schedule();		/* sys_write() */
 
 		/*
 		 * Try to find the page in the cache. If it isn't there,
--- linux-2.4.0-test3-pre7/fs/buffer.c	Sun Jul  9 21:30:16 2000
+++ linux-akpm/fs/buffer.c	Sun Jul  9 23:51:04 2000
@@ -2123,6 +2123,7 @@
 				__wait_on_buffer(p);
 		} else if (buffer_dirty(p))
 			ll_rw_block(WRITE, 1, &p);
+		conditional_schedule();		/* sys_msync() */
 	} while (tmp != bh);
 }
 
--- linux-2.4.0-test3-pre7/mm/memory.c	Tue May 16 05:00:33 2000
+++ linux-akpm/mm/memory.c	Tue Jul 11 01:27:26 2000
@@ -259,7 +259,7 @@
 /*
  * Return indicates whether a page was freed so caller can adjust rss
  */
-static inline int free_pte(pte_t page)
+static inline int free_pte(pte_t page, struct list_head *reaped_pages)
 {
 	if (pte_present(page)) {
 		unsigned long nr = pte_pagenr(page);
@@ -269,7 +269,7 @@
 		 * free_page() used to be able to clear swap cache
 		 * entries.  We may now have to do it manually.  
 		 */
-		free_page_and_swap_cache(mem_map+nr);
+		free_page_and_swap_cache(mem_map+nr, reaped_pages);
 		return 1;
 	}
 	swap_free(pte_to_swp_entry(page));
@@ -280,11 +280,12 @@
 {
 	if (!pte_none(page)) {
 		printk("forget_pte: old mapping existed!\n");
-		free_pte(page);
+		free_pte(page, NULL);
 	}
 }
 
-static inline int zap_pte_range(struct mm_struct *mm, pmd_t * pmd, unsigned long address, unsigned long size)
+static inline int zap_pte_range(struct mm_struct *mm, pmd_t * pmd, unsigned long address,
+				unsigned long size, struct list_head *reaped_pages)
 {
 	pte_t * pte;
 	int freed;
@@ -312,12 +313,13 @@
 		pte_clear(pte-1);
 		if (pte_none(page))
 			continue;
-		freed += free_pte(page);
+		freed += free_pte(page, reaped_pages);
 	}
 	return freed;
 }
 
-static inline int zap_pmd_range(struct mm_struct *mm, pgd_t * dir, unsigned long address, unsigned long size)
+static inline int zap_pmd_range(struct mm_struct *mm, pgd_t * dir, unsigned long address,
+				unsigned long size, struct list_head *reaped_pages)
 {
 	pmd_t * pmd;
 	unsigned long end;
@@ -337,7 +339,7 @@
 		end = PGDIR_SIZE;
 	freed = 0;
 	do {
-		freed += zap_pte_range(mm, pmd, address, end - address);
+		freed += zap_pte_range(mm, pmd, address, end - address, reaped_pages);
 		address = (address + PMD_SIZE) & PMD_MASK; 
 		pmd++;
 	} while (address < end);
@@ -347,7 +349,8 @@
 /*
  * remove user pages in a given range.
  */
-void zap_page_range(struct mm_struct *mm, unsigned long address, unsigned long size)
+static void do_zap_page_range(	struct mm_struct *mm, unsigned long address,
+				unsigned long size, struct list_head *reaped_pages)
 {
 	pgd_t * dir;
 	unsigned long end = address + size;
@@ -366,7 +369,7 @@
 		BUG();
 	spin_lock(&mm->page_table_lock);
 	do {
-		freed += zap_pmd_range(mm, dir, address, end - address);
+		freed += zap_pmd_range(mm, dir, address, end - address, reaped_pages);
 		address = (address + PGDIR_SIZE) & PGDIR_MASK;
 		dir++;
 	} while (address && (address < end));
@@ -381,6 +384,42 @@
 	}
 }
 
+#define MAX_ZAP_BYTES 512*PAGE_SIZE	/* 1 millisec @ 250 MHz */
+
+void zap_page_range(struct mm_struct *mm, unsigned long address, unsigned long size, int actions)
+{
+	LIST_HEAD(reaped_pages_list);
+	struct list_head *reaped_pages;
+
+//	actions &= ~ZPR_DEFER_FREE_PAGE;
+
+	reaped_pages = (actions & ZPR_DEFER_FREE_PAGE) ? &reaped_pages_list : NULL;
+
+	while (size) {
+		unsigned long chunk = size;
+		if (actions & ZPR_COND_RESCHED && chunk > MAX_ZAP_BYTES)
+			chunk = MAX_ZAP_BYTES;
+		if (actions & ZPR_FLUSH_CACHE)
+			flush_cache_range(mm, address, address + chunk);
+		do_zap_page_range(mm, address, chunk, reaped_pages);
+		if (actions & ZPR_FLUSH_TLB)
+			flush_tlb_range(mm, address, address + chunk);
+		if (actions & ZPR_DEFER_FREE_PAGE) {
+			struct list_head *l;
+			for (l = reaped_pages_list.next; l != &reaped_pages_list; ) {
+				struct list_head *next = l->next;
+				__free_pages_ok(list_entry(l, struct page, akpm_list), 0);
+				l = next;
+			}
+		}
+//		if (actions & ZPR_FLUSH_TLB)
+			local_flush_tlb();	/* Is this needed? */
+		if (actions & ZPR_COND_RESCHED)
+			conditional_schedule();
+		address += chunk;
+		size -= chunk;
+	}
+}
 
 /*
  * Do a quick page-table lookup for a single page. 
@@ -961,9 +1000,7 @@
 
 		/* mapping wholly truncated? */
 		if (mpnt->vm_pgoff >= pgoff) {
-			flush_cache_range(mm, start, end);
-			zap_page_range(mm, start, len);
-			flush_tlb_range(mm, start, end);
+			zap_page_range(mm, start, len, ZPR_FLUSH_CACHE|ZPR_FLUSH_TLB|ZPR_DEFER_FREE_PAGE);
 			continue;
 		}
 
@@ -981,7 +1018,7 @@
 			start = (start + ~PAGE_MASK) & PAGE_MASK;
 		}
 		flush_cache_range(mm, start, end);
-		zap_page_range(mm, start, len);
+		zap_page_range(mm, start, len, ZPR_DEFER_FREE_PAGE);
 		flush_tlb_range(mm, start, end);
 	} while ((mpnt = mpnt->vm_next_share) != NULL);
 out_unlock:
--- linux-2.4.0-test3-pre7/mm/mmap.c	Sun Jul  9 21:30:17 2000
+++ linux-akpm/mm/mmap.c	Mon Jul 10 21:53:42 2000
@@ -340,9 +340,8 @@
 	vma->vm_file = NULL;
 	fput(file);
 	/* Undo any partial mapping done by a device driver. */
-	flush_cache_range(mm, vma->vm_start, vma->vm_end);
-	zap_page_range(mm, vma->vm_start, vma->vm_end - vma->vm_start);
-	flush_tlb_range(mm, vma->vm_start, vma->vm_end);
+	zap_page_range(mm, vma->vm_start, vma->vm_end - vma->vm_start,
+			ZPR_FLUSH_CACHE|ZPR_FLUSH_TLB|ZPR_DEFER_FREE_PAGE);
 free_vma:
 	kmem_cache_free(vm_area_cachep, vma);
 	return error;
@@ -711,10 +710,8 @@
 		}
 		remove_shared_vm_struct(mpnt);
 		mm->map_count--;
-
-		flush_cache_range(mm, st, end);
-		zap_page_range(mm, st, size);
-		flush_tlb_range(mm, st, end);
+		zap_page_range(mm, st, size,
+			ZPR_FLUSH_CACHE|ZPR_FLUSH_TLB|ZPR_DEFER_FREE_PAGE|ZPR_COND_RESCHED);
 
 		/*
 		 * Fix the mapping, and free the old area if it wasn't reused.
@@ -864,7 +861,7 @@
 		}
 		mm->map_count--;
 		remove_shared_vm_struct(mpnt);
-		zap_page_range(mm, start, size);
+		zap_page_range(mm, start, size, ZPR_COND_RESCHED);
 		if (mpnt->vm_file)
 			fput(mpnt->vm_file);
 		kmem_cache_free(vm_area_cachep, mpnt);
--- linux-2.4.0-test3-pre7/mm/mremap.c	Sat Jun 24 15:39:47 2000
+++ linux-akpm/mm/mremap.c	Mon Jul 10 21:54:30 2000
@@ -118,8 +118,7 @@
 	flush_cache_range(mm, new_addr, new_addr + len);
 	while ((offset += PAGE_SIZE) < len)
 		move_one_page(mm, new_addr + offset, old_addr + offset);
-	zap_page_range(mm, new_addr, len);
-	flush_tlb_range(mm, new_addr, new_addr + len);
+	zap_page_range(mm, new_addr, len, ZPR_FLUSH_TLB|ZPR_DEFER_FREE_PAGE);
 	return -1;
 }
 
--- linux-2.4.0-test3-pre7/drivers/char/mem.c	Sat Jun 24 15:39:43 2000
+++ linux-akpm/drivers/char/mem.c	Mon Jul 10 21:58:33 2000
@@ -373,8 +373,7 @@
 		if (count > size)
 			count = size;
 
-		flush_cache_range(mm, addr, addr + count);
-		zap_page_range(mm, addr, count);
+		zap_page_range(mm, addr, count, ZPR_FLUSH_CACHE);
         	zeromap_page_range(addr, count, PAGE_COPY);
         	flush_tlb_range(mm, addr, addr + count);
 

--------------DCC423F6E755249668E63CEC--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
