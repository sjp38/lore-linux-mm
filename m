Received: from atlas.CARNet.hr (zcalusic@atlas.CARNet.hr [161.53.123.163])
	by kvack.org (8.8.7/8.8.7) with ESMTP id KAA03420
	for <linux-mm@kvack.org>; Mon, 18 Jan 1999 10:14:25 -0500
Subject: Removing swap lockmap...
Reply-To: Zlatko.Calusic@CARNet.hr
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="=-=-="
From: Zlatko Calusic <Zlatko.Calusic@CARNet.hr>
Date: 18 Jan 1999 16:12:51 +0100
Message-ID: <87iue47gy4.fsf@atlas.CARNet.hr>
Sender: owner-linux-mm@kvack.org
To: Linux-MM List <linux-mm@kvack.org>, Linux Kernel List <linux-kernel@vger.rutgers.edu>
List-ID: <linux-mm.kvack.org>

This is a MIME multipart message.  If you are reading
this, you shouldn't.

--=-=-=

I removed swap lockmap all together and, to my surprise, I can't
produce any ill behaviour on my system, not even under very heavy
swapping (in low memory condition).

I remember there were some issues when swap lockmap was removed in
2.1.89, so it was reintroduced later (processes were dying randomly).

Question is, why is everything running so smoothly now, even without
swap lockmap?

See for yourself, patch is attached (it is against testing/pre-8).


--=-=-=
Content-Disposition: attachment;
 filename=nolockmap
Content-Description: no-swap-lockmap

Index: 2207.4/include/linux/swap.h
--- 2207.4/include/linux/swap.h Thu, 14 Jan 1999 00:48:18 +0100 zcalusic (linux-2.1/w/b/28_swap.h 1.1.2.1.6.1.1.1.4.1.5.1 644)
+++ 2207.6/include/linux/swap.h Mon, 18 Jan 1999 13:07:04 +0100 zcalusic (linux-2.1/w/b/28_swap.h 1.1.2.1.6.1.1.1.4.1.5.1.1.1 644)
@@ -43,7 +43,6 @@
 	kdev_t swap_device;
 	struct dentry * swap_file;
 	unsigned short * swap_map;
-	unsigned char * swap_lockmap;
 	unsigned int lowest_bit;
 	unsigned int highest_bit;
 	unsigned int cluster_next;
@@ -79,7 +78,6 @@
 extern void rw_swap_page(int, unsigned long, char *, int);
 extern void rw_swap_page_nocache(int, unsigned long, char *);
 extern void rw_swap_page_nolock(int, unsigned long, char *, int);
-extern void swap_after_unlock_page (unsigned long entry);
 
 /* linux/mm/page_alloc.c */
 extern void swap_in(struct task_struct *, struct vm_area_struct *,
Index: 2207.4/include/linux/mm.h
--- 2207.4/include/linux/mm.h Mon, 18 Jan 1999 09:00:38 +0100 zcalusic (linux-2.1/z/b/9_mm.h 1.1.5.2.4.1.2.1.3.1.1.1 644)
+++ 2207.6/include/linux/mm.h Mon, 18 Jan 1999 13:07:04 +0100 zcalusic (linux-2.1/z/b/9_mm.h 1.1.5.2.4.1.2.1.3.1.1.2 644)
@@ -141,7 +141,7 @@
 #define PG_uptodate		 4
 #define PG_free_after		 5
 #define PG_decr_after		 6
-#define PG_swap_unlock_after	 7
+/* Unused			 7 */
 #define PG_DMA			 8
 #define PG_Slab			 9
 #define PG_swap_cache		10
@@ -156,7 +156,6 @@
 #define PageUptodate(page)	(test_bit(PG_uptodate, &(page)->flags))
 #define PageFreeAfter(page)	(test_bit(PG_free_after, &(page)->flags))
 #define PageDecrAfter(page)	(test_bit(PG_decr_after, &(page)->flags))
-#define PageSwapUnlockAfter(page) (test_bit(PG_swap_unlock_after, &(page)->flags))
 #define PageDMA(page)		(test_bit(PG_DMA, &(page)->flags))
 #define PageSlab(page)		(test_bit(PG_Slab, &(page)->flags))
 #define PageSwapCache(page)	(test_bit(PG_swap_cache, &(page)->flags))
Index: 2207.4/mm/swapfile.c
--- 2207.4/mm/swapfile.c Thu, 14 Jan 1999 00:48:18 +0100 zcalusic (linux-2.1/z/b/20_swapfile.c 1.2.7.1 644)
+++ 2207.6/mm/swapfile.c Mon, 18 Jan 1999 13:07:04 +0100 zcalusic (linux-2.1/z/b/20_swapfile.c 1.2.7.1.1.1 644)
@@ -41,8 +41,6 @@
 			offset = si->cluster_next++;
 			if (si->swap_map[offset])
 				continue;
-			if (test_bit(offset, si->swap_lockmap))
-				continue;
 			si->cluster_nr--;
 			goto got_page;
 		}
@@ -51,8 +49,6 @@
 	for (offset = si->lowest_bit; offset <= si->highest_bit ; offset++) {
 		if (si->swap_map[offset])
 			continue;
-		if (test_bit(offset, si->swap_lockmap))
-			continue;
 		si->lowest_bit = offset;
 got_page:
 		si->swap_map[offset] = 1;
@@ -423,8 +419,6 @@
 	p->swap_device = 0;
 	vfree(p->swap_map);
 	p->swap_map = NULL;
-	vfree(p->swap_lockmap);
-	p->swap_lockmap = NULL;
 	p->flags = 0;
 	err = 0;
 
@@ -489,9 +483,7 @@
 	static int least_priority = 0;
 	union swap_header *swap_header = 0;
 	int swap_header_version;
-	int lock_map_size = PAGE_SIZE;
 	int nr_good_pages = 0;
-	unsigned long tmp_lock_map = 0;
 	
 	lock_kernel();
 	if (!capable(CAP_SYS_ADMIN))
@@ -509,7 +501,6 @@
 	p->swap_file = NULL;
 	p->swap_device = 0;
 	p->swap_map = NULL;
-	p->swap_lockmap = NULL;
 	p->lowest_bit = 0;
 	p->highest_bit = 0;
 	p->cluster_nr = 0;
@@ -569,9 +560,7 @@
 		goto bad_swap;
 	}
 
-	p->swap_lockmap = (char *) &tmp_lock_map;
 	rw_swap_page_nocache(READ, SWP_ENTRY(type,0), (char *) swap_header);
-	p->swap_lockmap = NULL;
 
 	if (!memcmp("SWAP-SPACE",swap_header->magic.magic,10))
 		swap_header_version = 1;
@@ -649,7 +638,6 @@
 				p->swap_map[page] = SWAP_MAP_BAD;
 		}
 		nr_good_pages = swap_header->info.last_page - i;
-		lock_map_size = (p->max + 7) / 8;
 		if (error) 
 			goto bad_swap;
 	}
@@ -660,11 +648,6 @@
 		goto bad_swap;
 	}
 	p->swap_map[0] = SWAP_MAP_BAD;
-	if (!(p->swap_lockmap = vmalloc (lock_map_size))) {
-		error = -ENOMEM;
-		goto bad_swap;
-	}
-	memset(p->swap_lockmap,0,lock_map_size);
 	p->flags = SWP_WRITEOK;
 	p->pages = nr_good_pages;
 	nr_swap_pages += nr_good_pages;
@@ -691,15 +674,12 @@
 	if(filp.f_op && filp.f_op->release)
 		filp.f_op->release(filp.f_dentry->d_inode,&filp);
 bad_swap_2:
-	if (p->swap_lockmap)
-		vfree(p->swap_lockmap);
 	if (p->swap_map)
 		vfree(p->swap_map);
 	dput(p->swap_file);
 	p->swap_device = 0;
 	p->swap_file = NULL;
 	p->swap_map = NULL;
-	p->swap_lockmap = NULL;
 	p->flags = 0;
 out:
 	if (swap_header)
Index: 2207.4/mm/page_io.c
--- 2207.4/mm/page_io.c Tue, 29 Dec 1998 15:51:24 +0100 zcalusic (linux-2.1/z/b/22_page_io.c 1.2.6.1.1.1 644)
+++ 2207.6/mm/page_io.c Mon, 18 Jan 1999 13:07:04 +0100 zcalusic (linux-2.1/z/b/22_page_io.c 1.2.6.1.1.1.6.1 644)
@@ -18,8 +18,6 @@
 
 #include <asm/pgtable.h>
 
-static struct wait_queue * lock_queue = NULL;
-
 /*
  * Reads or writes a swap page.
  * wait=1: start I/O and wait for completion. wait=0: start asynchronous I/O.
@@ -85,12 +83,6 @@
 	}
 
 	if (PageSwapCache(page)) {
-		/* Make sure we are the only process doing I/O with this swap page. */
-		while (test_and_set_bit(offset,p->swap_lockmap)) {
-			run_task_queue(&tq_disk);
-			sleep_on(&lock_queue);
-		}
-
 		/* 
 		 * Make sure that we have a swap cache association for this
 		 * page.  We need this to find which swap page to unlock once
@@ -162,11 +154,6 @@
 		/* Do some cleaning up so if this ever happens we can hopefully
 		 * trigger controlled shutdown.
 		 */
-		if (PageSwapCache(page)) {
-			if (!test_and_clear_bit(offset,p->swap_lockmap))
-				printk("swap_after_unlock_page: lock already cleared\n");
-			wake_up(&lock_queue);
-		}
 		atomic_dec(&page->count);
 		return;
 	}
@@ -174,19 +161,11 @@
  		set_bit(PG_decr_after, &page->flags);
  		atomic_inc(&nr_async_pages);
  	}
- 	if (PageSwapCache(page)) {
- 		/* only lock/unlock swap cache pages! */
- 		set_bit(PG_swap_unlock_after, &page->flags);
- 	}
  	set_bit(PG_free_after, &page->flags);
 
  	/* block_size == PAGE_SIZE/zones_used */
  	brw_page(rw, page, dev, zones, block_size, 0);
  
- 	/* Note! For consistency we do all of the logic,
- 	 * decrementing the page count, and unlocking the page in the
- 	 * swap lock map - in the IO completion handler.
- 	 */
  	if (!wait) 
  		return;
  	wait_on_page(page);
@@ -202,34 +181,6 @@
 #endif
 }
 
-/* Note: We could remove this totally asynchronous function,
- * and improve swap performance, and remove the need for the swap lock map,
- * by not removing pages from the swap cache until after I/O has been
- * processed and letting remove_from_page_cache decrement the swap count
- * just before it removes the page from the page cache.
- */
-/* This is run when asynchronous page I/O has completed. */
-void swap_after_unlock_page (unsigned long entry)
-{
-	unsigned long type, offset;
-	struct swap_info_struct * p;
-
-	type = SWP_TYPE(entry);
-	if (type >= nr_swapfiles) {
-		printk("swap_after_unlock_page: bad swap-device\n");
-		return;
-	}
-	p = &swap_info[type];
-	offset = SWP_OFFSET(entry);
-	if (offset >= p->max) {
-		printk("swap_after_unlock_page: weirdness\n");
-		return;
-	}
-	if (!test_and_clear_bit(offset,p->swap_lockmap))
-		printk("swap_after_unlock_page: lock already cleared\n");
-	wake_up(&lock_queue);
-}
-
 /* A simple wrapper so the base function doesn't need to enforce
  * that all swap pages go through the swap cache!
  */
@@ -287,12 +238,6 @@
 	clear_bit(PG_swap_cache, &page->flags);
 }
 
-/*
- * shmfs needs a version that doesn't put the page in the page cache!
- * The swap lock map insists that pages be in the page cache!
- * Therefore we can't use it.  Later when we can remove the need for the
- * lock map and we can reduce the number of functions exported.
- */
 void rw_swap_page_nolock(int rw, unsigned long entry, char *buffer, int wait)
 {
 	struct page *page = mem_map + MAP_NR((unsigned long) buffer);
Index: 2207.4/mm/page_alloc.c
--- 2207.4/mm/page_alloc.c Thu, 14 Jan 1999 00:48:18 +0100 zcalusic (linux-2.1/z/b/26_page_alloc 1.2.6.1.1.2.4.1.1.1.3.1 644)
+++ 2207.6/mm/page_alloc.c Mon, 18 Jan 1999 13:07:04 +0100 zcalusic (linux-2.1/z/b/26_page_alloc 1.2.6.1.1.2.4.1.1.1.3.2 644)
@@ -368,8 +368,6 @@
 			break;
 		if (swapdev->swap_map[offset] == SWAP_MAP_BAD)
 			break;
-		if (test_bit(offset, swapdev->swap_lockmap))
-			break;
 
 		/* Ok, do the async read-ahead now */
 		new_page = read_swap_cache_async(SWP_ENTRY(SWP_TYPE(entry), offset), 0);
Index: 2207.4/fs/buffer.c
--- 2207.4/fs/buffer.c Mon, 18 Jan 1999 09:00:38 +0100 zcalusic (linux-2.1/G/b/41_buffer.c 1.1.1.1.1.3.2.1.2.1.3.1 644)
+++ 2207.6/fs/buffer.c Mon, 18 Jan 1999 13:07:04 +0100 zcalusic (linux-2.1/G/b/41_buffer.c 1.1.1.1.1.3.2.1.2.1.3.2 644)
@@ -1141,8 +1141,6 @@
 			atomic_read(&nr_async_pages));
 #endif
 	}
-	if (test_and_clear_bit(PG_swap_unlock_after, &page->flags))
-		swap_after_unlock_page(page->offset);
 	if (test_and_clear_bit(PG_free_after, &page->flags))
 		__free_page(page);
 }

--=-=-=


-- 
Zlatko

--=-=-=--
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
