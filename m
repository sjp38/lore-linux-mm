Received: from penguin.e-mind.com (penguin.e-mind.com [195.223.140.120])
	by kvack.org (8.8.7/8.8.7) with ESMTP id TAA04284
	for <linux-mm@kvack.org>; Fri, 15 Jan 1999 19:39:26 -0500
Date: Sat, 16 Jan 1999 00:56:58 +0100 (CET)
From: Andrea Arcangeli <andrea@e-mind.com>
Reply-To: Andrea Arcangeli <andrea@e-mind.com>
Subject: [patch] NEW: arca-vm-21, swapout via shrink_mmap using PG_dirty
In-Reply-To: <Pine.LNX.3.96.990114132019.2683B-100000@laser.bogus>
Message-ID: <Pine.LNX.3.96.990116002913.853C-100000@laser.bogus>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Steve Bergman <steve@netplus.net>, dlux@dlux.sch.bme.hu, "Nicholas J. Leon" <nicholas@binary9.net>, "Eric W. Biederman" <ebiederm+eric@ccr.net>
Cc: Linus Torvalds <torvalds@transmeta.com>, brent verner <damonbrent@earthlink.net>, "Garst R. Reese" <reese@isn.net>, Kalle Andersson <kalle.andersson@mbox303.swipnet.se>, Zlatko Calusic <Zlatko.Calusic@CARNet.hr>, Ben McCann <bmccann@indusriver.com>, bredelin@ucsd.edu, linux-kernel@vger.rutgers.edu, linux-mm@kvack.org, Alan Cox <alan@lxorguk.ukuu.org.uk>, "Stephen C. Tweedie" <sct@redhat.com>, Heinz Mauelshagen <mauelsha@ez-darmstadt.telekom.de>, Max <max@Linuz.sns.it>
List-ID: <linux-mm.kvack.org>

I did not understood what PG_dirty means until this afternoon I thought
"why not to move the rw_swap_page to shrink_mmap" and left swap_out() only
to allocate the in-order-swap-entry and its swap cache page? So I brute
moved the rw_swap_cache with obviously tons of races and worked for a
bit well ;).

Then I seen the PG_dirty comment of Linus in vmscan.c, and if I have
understood well it, I had to use PG_dirty to realize what I was going to
do.

So I hacked heavily all the afternoon and the evening and now seems to
work fine ;)). Really the free_user_and_cache() algorithm that I am using
in this patch is "new", never seen how it works with the usual swapout
code in swap_out() so I can't make raw comparison.

What I can say is that the global performances seems improved a lot (also
the OOM handling seems improved, try and you'll see). But the raw swapout
performances are been reduced (from 51 sec of arca-vm-19 to 61 sec).
Seems very good here though.

The patch merge also other my stuff like my update_shared_mapping()  that
is safe right now (at last as vmtruncate ;).  It fix also the for_each_mm
issue. I can cut-out the garbage if somebody needs...

Ah and the patch removed also the map_nr field since x86 should perform
equally well (and the removal saves some bits of memory). This is been an
idea from Max.

Don't use the patch without first doing a backup though since mm
corruption could happens since I could have done mistaken.

I would be interested if somebody could make comparison with arca-vm-19 or
pre[57] for example... but don't waste time doing many benchmarks if it
seems a lose under every side.

Probably in low memory (<=8m) this my new arca-vm-21 needs a:

echo 6 1 4 32 128 512 >/proc/sys/vm/pager

Thanks.

Here arca-vm-21 against 2.2.0-pre7:

Index: linux/mm/filemap.c
diff -u linux/mm/filemap.c:1.1.1.9 linux/mm/filemap.c:1.1.1.1.2.52
--- linux/mm/filemap.c:1.1.1.9	Thu Jan  7 12:21:35 1999
+++ linux/mm/filemap.c	Sat Jan 16 00:17:39 1999
@@ -5,6 +5,11 @@
  */
 
 /*
+ * update_shared_mappings(), Copyright (C) 1998  Andrea Arcangeli
+ * PG_dirty shrink_mmap swapout, Copyright (C) 1999  Andrea Arcangeli
+ */
+
+/*
  * This file handles the generic file mmap semantics used by
  * most "normal" filesystems (but you don't /have/ to use this:
  * the NFS filesystem used to do this differently, for example)
@@ -121,14 +126,11 @@
 int shrink_mmap(int priority, int gfp_mask)
 {
 	static unsigned long clock = 0;
-	unsigned long limit = num_physpages;
 	struct page * page;
-	int count;
-
-	count = (limit << 1) >> priority;
+	unsigned long count = (num_physpages << 1) >> priority;
 
 	page = mem_map + clock;
-	do {
+	while (count-- != 0) {
 		int referenced;
 
 		/* This works even in the presence of PageSkip because
@@ -144,10 +146,9 @@
 		if (PageSkip(page)) {
 			/* next_hash is overloaded for PageSkip */
 			page = page->next_hash;
-			clock = page->map_nr;
+			clock = page - mem_map;
 		}
 		
-		count--;
 		referenced = test_and_clear_bit(PG_referenced, &page->flags);
 
 		if (PageLocked(page))
@@ -160,21 +161,6 @@
 		if (atomic_read(&page->count) != 1)
 			continue;
 
-		/*
-		 * Is it a page swap page? If so, we want to
-		 * drop it if it is no longer used, even if it
-		 * were to be marked referenced..
-		 */
-		if (PageSwapCache(page)) {
-			if (referenced && swap_count(page->offset) != 1)
-				continue;
-			delete_from_swap_cache(page);
-			return 1;
-		}	
-
-		if (referenced)
-			continue;
-
 		/* Is it a buffer page? */
 		if (page->buffers) {
 			if (buffer_under_min())
@@ -184,6 +170,26 @@
 			return 1;
 		}
 
+		if (referenced)
+			continue;
+
+		if (PageSwapCache(page)) {
+			unsigned long entry = page->offset;
+			if (PageTestandClearDirty(page) &&
+			    swap_count(entry) > 1)
+			{
+				if (!(gfp_mask & __GFP_IO))
+					continue;
+				entry = page->offset;
+				set_bit(PG_locked, &page->flags);
+				atomic_inc(&page->count);
+				rw_swap_page(WRITE, entry, page, 0);
+				atomic_dec(&page->count);
+			}
+			delete_from_swap_cache(page);
+			return 1;
+		}
+
 		/* is it a page-cache page? */
 		if (page->inode) {
 			if (pgcache_under_min())
@@ -191,8 +197,7 @@
 			remove_inode_page(page);
 			return 1;
 		}
-
-	} while (count > 0);
+	}
 	return 0;
 }
 
@@ -1165,6 +1170,74 @@
 	return mk_pte(page,vma->vm_page_prot);
 }
 
+static void update_one_shared_mapping(struct vm_area_struct *shared,
+				      unsigned long address, pte_t orig_pte)
+{
+	pgd_t *pgd;
+	pmd_t *pmd;
+	pte_t *pte;
+
+	pgd = pgd_offset(shared->vm_mm, address);
+	if (pgd_none(*pgd))
+		goto out;
+	if (pgd_bad(*pgd)) {
+		printk(KERN_ERR "update_shared_mappings: bad pgd (%08lx)\n",
+		       pgd_val(*pgd));
+		pgd_clear(pgd);
+		goto out;
+	}
+
+	pmd = pmd_offset(pgd, address);
+	if (pmd_none(*pmd))
+		goto out;
+	if (pmd_bad(*pmd))
+	{
+		printk(KERN_ERR "update_shared_mappings: bad pmd (%08lx)\n",
+		       pmd_val(*pmd));
+		pmd_clear(pmd);
+		goto out;
+	}
+
+	pte = pte_offset(pmd, address);
+
+	if (pte_val(pte_mkclean(pte_mkyoung(*pte))) !=
+	    pte_val(pte_mkclean(pte_mkyoung(orig_pte))))
+		goto out;
+
+	flush_page_to_ram(page(pte));
+	flush_cache_page(shared, address);
+	set_pte(pte, pte_mkclean(*pte));
+	flush_tlb_page(shared, address);
+
+ out:
+}
+
+static void update_shared_mappings(struct vm_area_struct *this,
+				   unsigned long address,
+				   pte_t orig_pte)
+{
+	if (this->vm_flags & VM_SHARED)
+	{
+		struct file * filp = this->vm_file;
+		if (filp)
+		{
+			struct inode * inode = filp->f_dentry->d_inode;
+			struct semaphore * s = &inode->i_sem;
+			struct vm_area_struct * shared;
+
+			down(s);
+			for (shared = inode->i_mmap; shared;
+			     shared = shared->vm_next_share)
+			{
+				if (shared->vm_mm == this->vm_mm)
+					continue;
+				update_one_shared_mapping(shared, address,
+							  orig_pte);
+			}
+			up(s);
+		}
+	}
+}
 
 static inline int filemap_sync_pte(pte_t * ptep, struct vm_area_struct *vma,
 	unsigned long address, unsigned int flags)
@@ -1184,6 +1257,7 @@
 		flush_tlb_page(vma, address);
 		page = pte_page(pte);
 		atomic_inc(&mem_map[MAP_NR(page)].count);
+		update_shared_mappings(vma, address, pte);
 	} else {
 		if (pte_none(pte))
 			return 0;
Index: linux/mm/mmap.c
diff -u linux/mm/mmap.c:1.1.1.2 linux/mm/mmap.c:1.1.1.1.2.12
--- linux/mm/mmap.c:1.1.1.2	Fri Nov 27 11:19:10 1998
+++ linux/mm/mmap.c	Wed Jan 13 21:23:38 1999
@@ -66,7 +66,7 @@
 	free += page_cache_size;
 	free += nr_free_pages;
 	free += nr_swap_pages;
-	free -= (page_cache.min_percent + buffer_mem.min_percent + 2)*num_physpages/100; 
+	free -= (pager_daemon.cache_min_percent + pager_daemon.buffer_min_percent + 2)*num_physpages/100; 
 	return free > pages;
 }
 
@@ -76,11 +76,16 @@
 	struct file * file = vma->vm_file;
 
 	if (file) {
+		struct semaphore * sem = &file->f_dentry->d_inode->i_sem;
+		struct file * file = vma->vm_file;
+
+		down(sem);
 		if (vma->vm_flags & VM_DENYWRITE)
 			file->f_dentry->d_inode->i_writecount++;
 		if(vma->vm_next_share)
 			vma->vm_next_share->vm_pprev_share = vma->vm_pprev_share;
 		*vma->vm_pprev_share = vma->vm_next_share;
+		up(sem);
 	}
 }
 
@@ -514,9 +519,6 @@
 		free = free->vm_next;
 		freed = 1;
 
-		mm->map_count--;
-		remove_shared_vm_struct(mpnt);
-
 		st = addr < mpnt->vm_start ? mpnt->vm_start : addr;
 		end = addr+len;
 		end = end > mpnt->vm_end ? mpnt->vm_end : end;
@@ -525,6 +527,9 @@
 		if (mpnt->vm_ops && mpnt->vm_ops->unmap)
 			mpnt->vm_ops->unmap(mpnt, st, size);
 
+		mm->map_count--;
+		remove_shared_vm_struct(mpnt);
+
 		flush_cache_range(mm, st, end);
 		zap_page_range(mm, st, size);
 		flush_tlb_range(mm, st, end);
@@ -616,14 +621,18 @@
 	file = vmp->vm_file;
 	if (file) {
 		struct inode * inode = file->f_dentry->d_inode;
+		struct semaphore * sem = &inode->i_sem;
+
 		if (vmp->vm_flags & VM_DENYWRITE)
 			inode->i_writecount--;
       
+		down(sem);
 		/* insert vmp into inode's share list */
 		if((vmp->vm_next_share = inode->i_mmap) != NULL)
 			inode->i_mmap->vm_pprev_share = &vmp->vm_next_share;
 		inode->i_mmap = vmp;
 		vmp->vm_pprev_share = &inode->i_mmap;
+		up(sem);
 	}
 }
 
Index: linux/mm/page_alloc.c
diff -u linux/mm/page_alloc.c:1.1.1.9 linux/mm/page_alloc.c:1.1.1.1.2.32
--- linux/mm/page_alloc.c:1.1.1.9	Thu Jan 14 12:32:57 1999
+++ linux/mm/page_alloc.c	Fri Jan 15 21:48:00 1999
@@ -124,8 +124,7 @@
 	if (!PageReserved(page) && atomic_dec_and_test(&page->count)) {
 		if (PageSwapCache(page))
 			panic ("Freeing swap cache page");
-		page->flags &= ~(1 << PG_referenced);
-		free_pages_ok(page->map_nr, 0);
+		free_pages_ok(page - mem_map, 0);
 		return;
 	}
 }
@@ -141,7 +140,6 @@
 		if (atomic_dec_and_test(&map->count)) {
 			if (PageSwapCache(map))
 				panic ("Freeing swap cache pages");
-			map->flags &= ~(1 << PG_referenced);
 			free_pages_ok(map_nr, order);
 			return;
 		}
@@ -163,7 +161,7 @@
 			if (!dma || CAN_DMA(ret)) { \
 				unsigned long map_nr; \
 				(prev->next = ret->next)->prev = prev; \
-				map_nr = ret->map_nr; \
+				map_nr = ret - mem_map; \
 				MARK_USED(map_nr, new_order, area); \
 				nr_free_pages -= 1 << order; \
 				EXPAND(ret, map_nr, order, new_order, area); \
@@ -212,19 +210,18 @@
 		 * further thought.
 		 */
 		if (!(current->flags & PF_MEMALLOC)) {
-			static int trashing = 0;
 			int freed;
 
 			if (nr_free_pages > freepages.min) {
-				if (!trashing)
+				if (!current->trashing)
 					goto ok_to_allocate;
 				if (nr_free_pages > freepages.low) {
-					trashing = 0;
+					current->trashing = 0;
 					goto ok_to_allocate;
 				}
 			}
 
-			trashing = 1;
+			current->trashing = 1;
 			current->flags |= PF_MEMALLOC;
 			freed = try_to_free_pages(gfp_mask);
 			current->flags &= ~PF_MEMALLOC;
@@ -322,7 +319,6 @@
 		--p;
 		atomic_set(&p->count, 0);
 		p->flags = (1 << PG_DMA) | (1 << PG_reserved);
-		p->map_nr = p - mem_map;
 	} while (p > mem_map);
 
 	for (i = 0 ; i < NR_MEM_LISTS ; i++) {
@@ -361,7 +357,7 @@
 		if (offset >= swapdev->max)
 			break;
 		/* Don't block on I/O for read-ahead */
-		if (atomic_read(&nr_async_pages) >= pager_daemon.swap_cluster)
+		if (atomic_read(&nr_async_pages) >= pager_daemon.max_async_pages)
 			break;
 		/* Don't read in bad or busy pages */
 		if (!swapdev->swap_map[offset])
Index: linux/mm/page_io.c
diff -u linux/mm/page_io.c:1.1.1.4 linux/mm/page_io.c:1.1.1.1.2.7
--- linux/mm/page_io.c:1.1.1.4	Tue Dec 29 01:39:20 1998
+++ linux/mm/page_io.c	Fri Jan 15 21:48:00 1999
@@ -58,7 +58,7 @@
 	}
 
 	/* Don't allow too many pending pages in flight.. */
-	if (atomic_read(&nr_async_pages) > pager_daemon.swap_cluster)
+	if (atomic_read(&nr_async_pages) > pager_daemon.max_async_pages)
 		wait = 1;
 
 	p = &swap_info[type];
@@ -233,10 +233,8 @@
 /* A simple wrapper so the base function doesn't need to enforce
  * that all swap pages go through the swap cache!
  */
-void rw_swap_page(int rw, unsigned long entry, char *buf, int wait)
+void rw_swap_page(int rw, unsigned long entry, struct page *page, int wait)
 {
-	struct page *page = mem_map + MAP_NR(buf);
-
 	if (page->inode && page->inode != &swapper_inode)
 		panic ("Tried to swap a non-swapper page");
 
@@ -281,7 +279,7 @@
 	page->inode = &swapper_inode;
 	page->offset = entry;
 	atomic_inc(&page->count);	/* Protect from shrink_mmap() */
-	rw_swap_page(rw, entry, buffer, 1);
+	rw_swap_page(rw, entry, page, 1);
 	atomic_dec(&page->count);
 	page->inode = 0;
 	clear_bit(PG_swap_cache, &page->flags);
Index: linux/mm/swap.c
diff -u linux/mm/swap.c:1.1.1.6 linux/mm/swap.c:1.1.1.1.2.18
--- linux/mm/swap.c:1.1.1.6	Mon Jan 11 22:24:24 1999
+++ linux/mm/swap.c	Sat Jan 16 00:00:55 1999
@@ -40,28 +40,19 @@
 };
 
 /* How many pages do we try to swap or page in/out together? */
-int page_cluster = 4; /* Default value modified in swap_setup() */
+int page_cluster = 5; /* Default readahead 32 pages every time */
 
 /* We track the number of pages currently being asynchronously swapped
    out, so that we don't try to swap TOO many pages out at once */
 atomic_t nr_async_pages = ATOMIC_INIT(0);
 
-buffer_mem_t buffer_mem = {
-	2,	/* minimum percent buffer */
-	10,	/* borrow percent buffer */
-	60	/* maximum percent buffer */
-};
-
-buffer_mem_t page_cache = {
-	2,	/* minimum percent page cache */
-	15,	/* borrow percent page cache */
-	75	/* maximum */
-};
-
 pager_daemon_t pager_daemon = {
-	512,	/* base number for calculating the number of tries */
-	SWAP_CLUSTER_MAX,	/* minimum number of tries */
-	SWAP_CLUSTER_MAX,	/* do swap I/O in clusters of this size */
+	10,	/* starting priority of try_to_free_pages() */
+	1,	/* minimum percent buffer */
+	5,	/* minimum percent page cache */
+	32,	/* number of tries we do on every try_to_free_pages() */
+	128,	/* do swap I/O in clusters of this size */
+	512	/* max number of async swapped-out pages on the fly */
 };
 
 /*
@@ -75,6 +66,4 @@
 		page_cluster = 2;
 	else if (num_physpages < ((32 * 1024 * 1024) >> PAGE_SHIFT))
 		page_cluster = 3;
-	else
-		page_cluster = 4;
 }
Index: linux/mm/swap_state.c
diff -u linux/mm/swap_state.c:1.1.1.6 linux/mm/swap_state.c:1.1.1.1.2.13
--- linux/mm/swap_state.c:1.1.1.6	Thu Jan 14 12:32:57 1999
+++ linux/mm/swap_state.c	Fri Jan 15 23:23:54 1999
@@ -213,6 +213,7 @@
 	       "entry %08lx)\n",
 	       page_address(page), atomic_read(&page->count), entry);
 #endif
+	PageClearDirty(page);
 	remove_from_swap_cache (page);
 	swap_free (entry);
 }
@@ -320,7 +321,7 @@
 		goto out_free_page;
 
 	set_bit(PG_locked, &new_page->flags);
-	rw_swap_page(READ, entry, (char *) new_page_addr, wait);
+	rw_swap_page(READ, entry, new_page, wait);
 #ifdef DEBUG_SWAP
 	printk("DebugVM: read_swap_cache_async created "
 	       "entry %08lx at %p\n",
Index: linux/mm/swapfile.c
diff -u linux/mm/swapfile.c:1.1.1.3 linux/mm/swapfile.c:1.1.1.1.2.6
--- linux/mm/swapfile.c:1.1.1.3	Mon Jan 11 22:24:24 1999
+++ linux/mm/swapfile.c	Wed Jan 13 00:00:04 1999
@@ -23,7 +23,6 @@
 
 struct swap_info_struct swap_info[MAX_SWAPFILES];
 
-#define SWAPFILE_CLUSTER 256
 
 static inline int scan_swap_map(struct swap_info_struct *si)
 {
@@ -31,7 +30,7 @@
 	/* 
 	 * We try to cluster swap pages by allocating them
 	 * sequentially in swap.  Once we've allocated
-	 * SWAPFILE_CLUSTER pages this way, however, we resort to
+	 * SWAP_CLUSTER pages this way, however, we resort to
 	 * first-free allocation, starting a new cluster.  This
 	 * prevents us from scattering swap pages all over the entire
 	 * swap partition, so that we reduce overall disk seek times
@@ -47,7 +46,7 @@
 			goto got_page;
 		}
 	}
-	si->cluster_nr = SWAPFILE_CLUSTER;
+	si->cluster_nr = SWAP_CLUSTER;
 	for (offset = si->lowest_bit; offset <= si->highest_bit ; offset++) {
 		if (si->swap_map[offset])
 			continue;
Index: linux/mm/vmalloc.c
diff -u linux/mm/vmalloc.c:1.1.1.2 linux/mm/vmalloc.c:1.1.1.1.2.3
--- linux/mm/vmalloc.c:1.1.1.2	Fri Nov 27 11:19:11 1998
+++ linux/mm/vmalloc.c	Thu Dec 31 18:55:11 1998
@@ -10,6 +10,7 @@
 #include <asm/uaccess.h>
 
 static struct vm_struct * vmlist = NULL;
+static spinlock_t	  vmlist_spinlock;
 
 static inline void free_area_pte(pmd_t * pmd, unsigned long address, unsigned long size)
 {
@@ -158,17 +159,21 @@
 	if (!area)
 		return NULL;
 	addr = VMALLOC_START;
+	spin_lock(&vmlist_spinlock);
 	for (p = &vmlist; (tmp = *p) ; p = &tmp->next) {
 		if (size + addr < (unsigned long) tmp->addr)
 			break;
-		if (addr > VMALLOC_END-size)
+		if (addr > VMALLOC_END-size) {
+			spin_unlock(&vmlist_spinlock);
 			return NULL;
+		}
 		addr = tmp->size + (unsigned long) tmp->addr;
 	}
 	area->addr = (void *)addr;
 	area->size = size + PAGE_SIZE;
 	area->next = *p;
 	*p = area;
+	spin_unlock(&vmlist_spinlock);
 	return area;
 }
 
@@ -182,14 +187,18 @@
 		printk("Trying to vfree() bad address (%p)\n", addr);
 		return;
 	}
+	spin_lock(&vmlist_spinlock);
 	for (p = &vmlist ; (tmp = *p) ; p = &tmp->next) {
 		if (tmp->addr == addr) {
 			*p = tmp->next;
-			vmfree_area_pages(VMALLOC_VMADDR(tmp->addr), tmp->size);
+			spin_unlock(&vmlist_spinlock);
+			vmfree_area_pages(VMALLOC_VMADDR(tmp->addr),
+					  tmp->size - PAGE_SIZE);
 			kfree(tmp);
 			return;
 		}
 	}
+	spin_unlock(&vmlist_spinlock);
 	printk("Trying to vfree() nonexistent vm area (%p)\n", addr);
 }
 
@@ -222,6 +231,7 @@
 	if ((unsigned long) addr + count < count)
 		count = -(unsigned long) addr;
 
+	spin_lock(&vmlist_spinlock);
 	for (tmp = vmlist; tmp; tmp = tmp->next) {
 		vaddr = (char *) tmp->addr;
 		if (addr >= vaddr + tmp->size - PAGE_SIZE)
@@ -245,5 +255,6 @@
 		} while (--n > 0);
 	}
 finished:
+	spin_unlock(&vmlist_spinlock);
 	return buf - buf_start;
 }
Index: linux/mm/vmscan.c
diff -u linux/mm/vmscan.c:1.1.1.12 linux/mm/vmscan.c:1.1.1.1.2.98
--- linux/mm/vmscan.c:1.1.1.12	Mon Jan 11 22:24:24 1999
+++ linux/mm/vmscan.c	Sat Jan 16 00:06:41 1999
@@ -10,6 +10,12 @@
  *  Version: $Id: vmscan.c,v 1.5 1998/02/23 22:14:28 sct Exp $
  */
 
+/*
+ * free_user_and_cache() and always async swapout original idea.
+ * PG_dirty shrink_mmap swapout
+ * Copyright (C) 1999  Andrea Arcangeli
+ */
+
 #include <linux/slab.h>
 #include <linux/kernel_stat.h>
 #include <linux/swap.h>
@@ -20,6 +26,8 @@
 
 #include <asm/pgtable.h>
 
+int swapout_interval = HZ;
+
 /*
  * The swap-out functions return 1 if they successfully
  * threw something out, and we got a free page. It returns
@@ -53,12 +61,7 @@
 		return 0;
 
 	if (pte_young(pte)) {
-		/*
-		 * Transfer the "accessed" bit from the page
-		 * tables to the global page map.
-		 */
 		set_pte(page_table, pte_mkold(pte));
-		set_bit(PG_referenced, &page_map->flags);
 		return 0;
 	}
 
@@ -66,9 +69,6 @@
 	 * Is the page already in the swap cache? If so, then
 	 * we can just drop our reference to it without doing
 	 * any IO - it's already up-to-date on disk.
-	 *
-	 * Return 0, as we didn't actually free any real
-	 * memory, and we should just continue our scan.
 	 */
 	if (PageSwapCache(page_map)) {
 		entry = page_map->offset;
@@ -77,8 +77,9 @@
 drop_pte:
 		vma->vm_mm->rss--;
 		flush_tlb_page(vma, address);
+		entry = atomic_read(&page_map->count);
 		__free_page(page_map);
-		return 0;
+		return entry <= 2;
 	}
 
 	/*
@@ -86,11 +87,6 @@
 	 * by just paging it in again, and we can just drop
 	 * it..
 	 *
-	 * However, this won't actually free any real
-	 * memory, as the page will just be in the page cache
-	 * somewhere, and as such we should just continue
-	 * our scan.
-	 *
 	 * Basically, this just makes it possible for us to do
 	 * some real work in the future in "shrink_mmap()".
 	 */
@@ -127,7 +123,10 @@
 	 * That would get rid of a lot of problems.
 	 */
 	if (vma->vm_ops && vma->vm_ops->swapout) {
-		pid_t pid = tsk->pid;
+		pid_t pid;
+		if (!(gfp_mask & __GFP_IO))
+			return 0;
+		pid = tsk->pid;
 		vma->vm_mm->rss--;
 		if (vma->vm_ops->swapout(vma, address - vma->vm_start + vma->vm_offset, page_table))
 			kill_proc(pid, SIGBUS, 1);
@@ -151,14 +150,9 @@
 	set_pte(page_table, __pte(entry));
 	flush_tlb_page(vma, address);
 	swap_duplicate(entry);	/* One for the process, one for the swap cache */
-	add_to_swap_cache(page_map, entry);
-	/* We checked we were unlocked way up above, and we
-	   have been careful not to stall until here */
-	set_bit(PG_locked, &page_map->flags);
-
-	/* OK, do a physical asynchronous write to swap.  */
-	rw_swap_page(WRITE, entry, (char *) page, 0);
-
+ 	add_to_swap_cache(page_map, entry);
+	if (PageTestandSetDirty(page_map))
+		printk(KERN_ERR "VM: page was just marked dirty!\n");
 	__free_page(page_map);
 	return 1;
 }
@@ -199,7 +193,7 @@
 
 	do {
 		int result;
-		tsk->swap_address = address + PAGE_SIZE;
+		tsk->mm->swap_address = address + PAGE_SIZE;
 		result = try_to_swap_out(tsk, vma, address, pte, gfp_mask);
 		if (result)
 			return result;
@@ -271,7 +265,7 @@
 	/*
 	 * Go through process' page directory.
 	 */
-	address = p->swap_address;
+	address = p->mm->swap_address;
 
 	/*
 	 * Find the proper vm-area
@@ -293,8 +287,8 @@
 	}
 
 	/* We didn't find anything for the process */
-	p->swap_cnt = 0;
-	p->swap_address = 0;
+	p->mm->swap_cnt = 0;
+	p->mm->swap_address = 0;
 	return 0;
 }
 
@@ -303,10 +297,11 @@
  * N.B. This function returns only 0 or 1.  Return values != 1 from
  * the lower level routines result in continued processing.
  */
-static int swap_out(unsigned int priority, int gfp_mask)
+static int grow_freeable(unsigned int priority, int gfp_mask)
 {
 	struct task_struct * p, * pbest;
-	int counter, assign, max_cnt;
+	int counter, assign;
+	unsigned long max_cnt;
 
 	/* 
 	 * We make one or two passes through the task list, indexed by 
@@ -325,8 +320,6 @@
 	counter = nr_tasks / (priority+1);
 	if (counter < 1)
 		counter = 1;
-	if (counter > nr_tasks)
-		counter = nr_tasks;
 
 	for (; counter >= 0; counter--) {
 		assign = 0;
@@ -338,13 +331,13 @@
 		for (; p != &init_task; p = p->next_task) {
 			if (!p->swappable)
 				continue;
-	 		if (p->mm->rss <= 0)
+	 		if (p->mm->rss == 0)
 				continue;
 			/* Refresh swap_cnt? */
 			if (assign)
-				p->swap_cnt = p->mm->rss;
-			if (p->swap_cnt > max_cnt) {
-				max_cnt = p->swap_cnt;
+				p->mm->swap_cnt = p->mm->rss;
+			if (p->mm->swap_cnt > max_cnt) {
+				max_cnt = p->mm->swap_cnt;
 				pbest = p;
 			}
 		}
@@ -376,7 +369,7 @@
        char *revision="$Revision: 1.5 $", *s, *e;
 
        swap_setup();
-       
+
        if ((s = strchr(revision, ':')) &&
            (e = strchr(s, '$')))
                s++, i = e - s;
@@ -406,12 +399,6 @@
 	strcpy(current->comm, "kswapd");
 
 	/*
-	 * Hey, if somebody wants to kill us, be our guest. 
-	 * Don't come running to mama if things don't work.
-	 */
-	siginitsetinv(&current->blocked, sigmask(SIGKILL));
-	
-	/*
 	 * Tell the memory management that we're a "memory allocator",
 	 * and that if we need more memory we should get access to it
 	 * regardless (see "__get_free_pages()"). "kswapd" should
@@ -426,11 +413,10 @@
 	current->flags |= PF_MEMALLOC;
 
 	while (1) {
-		if (signal_pending(current))
-			break;
-		current->state = TASK_INTERRUPTIBLE;
 		run_task_queue(&tq_disk);
-		schedule_timeout(HZ);
+		current->state = TASK_INTERRUPTIBLE;
+		flush_signals(current);
+		schedule_timeout(swapout_interval);
 
 		/*
 		 * kswapd isn't even meant to keep up with anything,
@@ -438,13 +424,37 @@
 		 * point is to make sure that the system doesn't stay
 		 * forever in a really bad memory squeeze.
 		 */
-		if (nr_free_pages < freepages.high)
+		if (nr_free_pages < freepages.min)
 			try_to_free_pages(GFP_KSWAPD);
 	}
 
 	return 0;
 }
 
+static int free_user_and_cache(int priority, int gfp_mask)
+{
+	int freed, grown = 0;
+	static int need_freeable = 0;
+
+	freed = shrink_mmap(priority, gfp_mask);
+
+	if (need_freeable)
+	{
+		grown = grow_freeable(priority, gfp_mask);
+		if (freed)
+			need_freeable = 0;
+	} else {
+		freed = shrink_mmap(priority, gfp_mask);
+		if (!freed)
+		{
+			grown = grow_freeable(priority, gfp_mask);
+			need_freeable = 1;
+		}
+	}
+
+	return freed || grown;
+}
+
 /*
  * We need to make the locks finer granularity, but right
  * now we need this so that we can do page allocations
@@ -457,34 +467,35 @@
 int try_to_free_pages(unsigned int gfp_mask)
 {
 	int priority;
-	int count = SWAP_CLUSTER_MAX;
+	static int state = 0;
+	int count = pager_daemon.tries;
 
 	lock_kernel();
 
 	/* Always trim SLAB caches when memory gets low. */
 	kmem_cache_reap(gfp_mask);
 
-	priority = 6;
-	do {
-		while (shrink_mmap(priority, gfp_mask)) {
-			if (!--count)
-				goto done;
-		}
-
-		/* Try to get rid of some shared memory pages.. */
-		while (shm_swap(priority, gfp_mask)) {
-			if (!--count)
-				goto done;
-		}
-	
-		/* Then, try to page stuff out.. */
-		while (swap_out(priority, gfp_mask)) {
-			if (!--count)
-				goto done;
-		}
+	priority = pager_daemon.priority;
+	switch (state)
+	{
+		do {
+		case 0:
+			while (free_user_and_cache(priority, gfp_mask)) {
+				if (!--count)
+					goto done;
+			}
+			state = 1;
+		case 1:
+			/* Try to get rid of some shared memory pages.. */
+			while (shm_swap(priority, gfp_mask)) {
+				if (!--count)
+					goto done;
+			}
+			state = 0;
 
-		shrink_dcache_memory(priority, gfp_mask);
-	} while (--priority >= 0);
+			shrink_dcache_memory(priority, gfp_mask);
+		} while (--priority >= 0);
+	}
 done:
 	unlock_kernel();
 
Index: linux/kernel/fork.c
diff -u linux/kernel/fork.c:1.1.1.6 linux/kernel/fork.c:1.1.1.1.2.10
--- linux/kernel/fork.c:1.1.1.6	Mon Jan 11 22:24:21 1999
+++ linux/kernel/fork.c	Mon Jan 11 22:56:09 1999
@@ -209,16 +209,19 @@
 		tmp->vm_next = NULL;
 		file = tmp->vm_file;
 		if (file) {
+			struct semaphore * s = &file->f_dentry->d_inode->i_sem;
 			file->f_count++;
 			if (tmp->vm_flags & VM_DENYWRITE)
 				file->f_dentry->d_inode->i_writecount--;
-      
+
+			down(s);
 			/* insert tmp into the share list, just after mpnt */
 			if((tmp->vm_next_share = mpnt->vm_next_share) != NULL)
 				mpnt->vm_next_share->vm_pprev_share =
 					&tmp->vm_next_share;
 			mpnt->vm_next_share = tmp;
 			tmp->vm_pprev_share = &mpnt->vm_next_share;
+			up(s);
 		}
 
 		/* Copy the pages, but defer checking for errors */
@@ -511,6 +514,7 @@
 
 	p->did_exec = 0;
 	p->swappable = 0;
+	p->trashing = 0;
 	p->state = TASK_UNINTERRUPTIBLE;
 
 	copy_flags(clone_flags, p);
Index: linux/kernel/sysctl.c
diff -u linux/kernel/sysctl.c:1.1.1.6 linux/kernel/sysctl.c:1.1.1.1.2.12
--- linux/kernel/sysctl.c:1.1.1.6	Mon Jan 11 22:24:22 1999
+++ linux/kernel/sysctl.c	Wed Jan 13 21:23:38 1999
@@ -32,7 +32,7 @@
 
 /* External variables not in a header file. */
 extern int panic_timeout;
-extern int console_loglevel, C_A_D;
+extern int console_loglevel, C_A_D, swapout_interval;
 extern int bdf_prm[], bdflush_min[], bdflush_max[];
 extern char binfmt_java_interpreter[], binfmt_java_appletviewer[];
 extern int sysctl_overcommit_memory;
@@ -216,6 +216,8 @@
 };
 
 static ctl_table vm_table[] = {
+	{VM_SWAPOUT, "swapout_interval",
+	 &swapout_interval, sizeof(int), 0644, NULL, &proc_dointvec},
 	{VM_FREEPG, "freepages", 
 	 &freepages, sizeof(freepages_t), 0644, NULL, &proc_dointvec},
 	{VM_BDFLUSH, "bdflush", &bdf_prm, 9*sizeof(int), 0600, NULL,
@@ -223,11 +225,7 @@
 	 &bdflush_min, &bdflush_max},
 	{VM_OVERCOMMIT_MEMORY, "overcommit_memory", &sysctl_overcommit_memory,
 	 sizeof(sysctl_overcommit_memory), 0644, NULL, &proc_dointvec},
-	{VM_BUFFERMEM, "buffermem",
-	 &buffer_mem, sizeof(buffer_mem_t), 0644, NULL, &proc_dointvec},
-	{VM_PAGECACHE, "pagecache",
-	 &page_cache, sizeof(buffer_mem_t), 0644, NULL, &proc_dointvec},
-	{VM_PAGERDAEMON, "kswapd",
+	{VM_PAGERDAEMON, "pager",
 	 &pager_daemon, sizeof(pager_daemon_t), 0644, NULL, &proc_dointvec},
 	{VM_PGT_CACHE, "pagetable_cache", 
 	 &pgt_cache_water, 2*sizeof(int), 0600, NULL, &proc_dointvec},
Index: linux/include/linux/mm.h
diff -u linux/include/linux/mm.h:1.1.1.6 linux/include/linux/mm.h:1.1.1.1.2.23
--- linux/include/linux/mm.h:1.1.1.6	Mon Jan 11 22:23:57 1999
+++ linux/include/linux/mm.h	Fri Jan 15 23:23:53 1999
@@ -118,12 +118,10 @@
 	unsigned long offset;
 	struct page *next_hash;
 	atomic_t count;
-	unsigned int unused;
 	unsigned long flags;	/* atomic flags, some possibly updated asynchronously */
 	struct wait_queue *wait;
 	struct page **pprev_hash;
 	struct buffer_head * buffers;
-	unsigned long map_nr;	/* page->map_nr == page - mem_map */
 } mem_map_t;
 
 /* Page flag bit values */
@@ -165,6 +163,7 @@
 
 #define PageClearSlab(page)	(clear_bit(PG_Slab, &(page)->flags))
 #define PageClearSwapCache(page)(clear_bit(PG_swap_cache, &(page)->flags))
+#define PageClearDirty(page)	(clear_bit(PG_dirty, &(page)->flags))
 
 #define PageTestandClearDirty(page) \
 			(test_and_clear_bit(PG_dirty, &(page)->flags))
@@ -302,8 +301,7 @@
 
 /* filemap.c */
 extern void remove_inode_page(struct page *);
-extern unsigned long page_unuse(struct page *);
-extern int shrink_mmap(int, int);
+extern int FASTCALL(shrink_mmap(int, int));
 extern void truncate_inode_pages(struct inode *, unsigned long);
 extern unsigned long get_cached_page(struct inode *, unsigned long, int);
 extern void put_cached_page(unsigned long);
@@ -387,9 +385,9 @@
 }
 
 #define buffer_under_min()	((buffermem >> PAGE_SHIFT) * 100 < \
-				buffer_mem.min_percent * num_physpages)
-#define pgcache_under_min()	(page_cache_size * 100 < \
-				page_cache.min_percent * num_physpages)
+				pager_daemon.buffer_min_percent * num_physpages)
+#define pgcache_under_min()	((page_cache_size-swapper_inode.i_nrpages) * 100 < \
+				pager_daemon.cache_min_percent * num_physpages)
 
 #endif /* __KERNEL__ */
 
Index: linux/include/linux/pagemap.h
diff -u linux/include/linux/pagemap.h:1.1.1.1 linux/include/linux/pagemap.h:1.1.1.1.2.3
--- linux/include/linux/pagemap.h:1.1.1.1	Fri Nov 20 00:01:16 1998
+++ linux/include/linux/pagemap.h	Fri Jan 15 21:47:58 1999
@@ -14,7 +14,7 @@
 
 static inline unsigned long page_address(struct page * page)
 {
-	return PAGE_OFFSET + PAGE_SIZE * page->map_nr;
+	return PAGE_OFFSET + ((page - mem_map) << PAGE_SHIFT);
 }
 
 #define PAGE_HASH_BITS 11
Index: linux/include/linux/sched.h
diff -u linux/include/linux/sched.h:1.1.1.6 linux/include/linux/sched.h:1.1.1.1.2.13
--- linux/include/linux/sched.h:1.1.1.6	Mon Jan 11 22:24:03 1999
+++ linux/include/linux/sched.h	Thu Jan 14 12:42:58 1999
@@ -169,6 +174,7 @@
 	unsigned long rss, total_vm, locked_vm;
 	unsigned long def_flags;
 	unsigned long cpu_vm_mask;
+	unsigned long swap_cnt, swap_address;
 	/*
 	 * This is an architecture-specific pointer: the portable
 	 * part of Linux does not know about any segments.
@@ -177,15 +183,17 @@
 };
 
 #define INIT_MM {					\
-		&init_mmap, NULL, swapper_pg_dir, 	\
+		&init_mmap, NULL, swapper_pg_dir,	\
 		ATOMIC_INIT(1), 1,			\
 		MUTEX,					\
 		0,					\
 		0, 0, 0, 0,				\
-		0, 0, 0, 				\
+		0, 0, 0,				\
 		0, 0, 0, 0,				\
 		0, 0, 0,				\
-		0, 0, NULL }
+		0, 0,					\
+		0, 0,					\
+		NULL }
 
 struct signal_struct {
 	atomic_t		count;
@@ -270,8 +278,7 @@
 /* mm fault and swap info: this can arguably be seen as either mm-specific or thread-specific */
 	unsigned long min_flt, maj_flt, nswap, cmin_flt, cmaj_flt, cnswap;
 	int swappable:1;
-	unsigned long swap_address;
-	unsigned long swap_cnt;		/* number of pages to swap on next pass */
+	int trashing:1;
 /* process credentials */
 	uid_t uid,euid,suid,fsuid;
 	gid_t gid,egid,sgid,fsgid;
@@ -355,7 +362,7 @@
 /* utime */	{0,0,0,0},0, \
 /* per CPU times */ {0, }, {0, }, \
 /* flt */	0,0,0,0,0,0, \
-/* swp */	0,0,0, \
+/* swp */	0,0, \
 /* process credentials */					\
 /* uid etc */	0,0,0,0,0,0,0,0,				\
 /* suppl grps*/ 0, {0,},					\
Index: linux/include/linux/swap.h
diff -u linux/include/linux/swap.h:1.1.1.6 linux/include/linux/swap.h:1.1.1.1.2.19
--- linux/include/linux/swap.h:1.1.1.6	Mon Jan 11 22:24:05 1999
+++ linux/include/linux/swap.h	Fri Jan 15 21:47:58 1999
@@ -33,7 +33,7 @@
 #define SWP_USED	1
 #define SWP_WRITEOK	3
 
-#define SWAP_CLUSTER_MAX 32
+#define SWAP_CLUSTER	(pager_daemon.swap_cluster)
 
 #define SWAP_MAP_MAX	0x7fff
 #define SWAP_MAP_BAD	0x8000
@@ -76,7 +76,7 @@
 extern int try_to_free_pages(unsigned int gfp_mask);
 
 /* linux/mm/page_io.c */
-extern void rw_swap_page(int, unsigned long, char *, int);
+extern void rw_swap_page(int, unsigned long, struct page *, int);
 extern void rw_swap_page_nocache(int, unsigned long, char *);
 extern void rw_swap_page_nolock(int, unsigned long, char *, int);
 extern void swap_after_unlock_page (unsigned long entry);
@@ -134,13 +134,6 @@
 extern unsigned long swap_cache_find_total;
 extern unsigned long swap_cache_find_success;
 #endif
-
-extern inline unsigned long in_swap_cache(struct page *page)
-{
-	if (PageSwapCache(page))
-		return page->offset;
-	return 0;
-}
 
 /*
  * Work out if there are any other processes sharing this page, ignoring
Index: linux/include/linux/swapctl.h
diff -u linux/include/linux/swapctl.h:1.1.1.4 linux/include/linux/swapctl.h:1.1.1.1.2.9
--- linux/include/linux/swapctl.h:1.1.1.4	Mon Jan 11 22:24:05 1999
+++ linux/include/linux/swapctl.h	Fri Jan 15 23:23:53 1999
@@ -4,32 +4,23 @@
 #include <asm/page.h>
 #include <linux/fs.h>
 
-typedef struct buffer_mem_v1
+typedef struct freepages_s
 {
-	unsigned int	min_percent;
-	unsigned int	borrow_percent;
-	unsigned int	max_percent;
-} buffer_mem_v1;
-typedef buffer_mem_v1 buffer_mem_t;
-extern buffer_mem_t buffer_mem;
-extern buffer_mem_t page_cache;
-
-typedef struct freepages_v1
-{
 	unsigned int	min;
 	unsigned int	low;
 	unsigned int	high;
-} freepages_v1;
-typedef freepages_v1 freepages_t;
+} freepages_t;
 extern freepages_t freepages;
 
-typedef struct pager_daemon_v1
+typedef struct pager_daemon_s
 {
-	unsigned int	tries_base;
-	unsigned int	tries_min;
+	unsigned int	priority;
+	unsigned int	buffer_min_percent;
+	unsigned int	cache_min_percent;
+	unsigned int	tries;
 	unsigned int	swap_cluster;
-} pager_daemon_v1;
-typedef pager_daemon_v1 pager_daemon_t;
+	unsigned int	max_async_pages;
+} pager_daemon_t;
 extern pager_daemon_t pager_daemon;
 
 #endif /* _LINUX_SWAPCTL_H */



--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
