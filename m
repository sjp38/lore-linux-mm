Date: Sun, 14 Jan 2001 00:39:35 -0200 (BRST)
From: Marcelo Tosatti <marcelo@conectiva.com.br>
Subject: Re: pre2 swap_out() changes
In-Reply-To: <87y9wffz64.fsf@atlas.iskon.hr>
Message-ID: <Pine.LNX.4.21.0101132353360.11917-100000@freak.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Zlatko Calusic <zlatko@iskon.hr>
Cc: Linus Torvalds <torvalds@transmeta.com>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On 13 Jan 2001, Zlatko Calusic wrote:

> Hm, what I noticed is completely the opposite. pre2 seems a little bit
> reluctant to swap out, and when it does it looks like it picks wrong
> pages. During the compile sessions (results above) pre2 had long
> periods where it just tried to get its working set in memory and
> during that time all 32 processes were on hold. Thus only 129% CPU
> usage and much longer total time.
> 
> On the other hand, 2.4.0 + Marcelo kept both processors busy at all
> times. Sometimes only few processes were TASK_RUNNING, but the system
> _never_ got in the situation where it had spare unused CPU cycles.
> 
> If I start typical make -j2 compile my %CPU time is also 182% or 183%,
> so 2.4.0 was _really_ good.

Linus,

It seems that one of the reasons for the performance slowdown in pre2 is
that we allow too many dirty buffers in memory (now we have a lot of
processes generating dirty buffers from page_launder()).

Another problem with pre2 is that we do reclaim the slab caches *if* we
are under free memory shortage. Your "horribly bogus, danger" comment on a
previous email was right, unfortunately.

The problem is that buffer_head's are in slab cache (bh_cachep) and we
need those buffer_head's to free memory (swapout and sync).

As usual, the patch. (it also changes some other things which we discussed
previously)

Comments?

diff -Nur --exclude-from=exclude linux.orig/fs/buffer.c linux/fs/buffer.c
--- linux.orig/fs/buffer.c	Sat Jan 13 19:19:00 2001
+++ linux/fs/buffer.c	Sat Jan 13 21:20:40 2001
@@ -2406,11 +2406,13 @@
 	spin_unlock(&lru_list_lock);
 	if (wait) {
 		sync_page_buffers(bh, wait);
+
 		/* We waited synchronously, so we can free the buffers. */
 		if (wait > 1 && !loop) {
 			loop = 1;
 			goto cleaned_buffers_try_again;
 		}
+		wakeup_bdflush(0);
 	}
 	return 0;
 }
@@ -2713,7 +2715,7 @@
 		CHECK_EMERGENCY_SYNC
 
 		flushed = flush_dirty_buffers(0);
-		if (free_shortage())
+		if (free_shortage()) 
 			flushed += page_launder(GFP_KERNEL, 0);
 
 		/*
diff -Nur --exclude-from=exclude linux.orig/mm/page_alloc.c linux/mm/page_alloc.c
--- linux.orig/mm/page_alloc.c	Sat Jan 13 19:19:04 2001
+++ linux/mm/page_alloc.c	Sat Jan 13 21:19:30 2001
@@ -452,11 +452,11 @@
 		 * 	  the inactive clean list. (done by page_launder)
 		 */
 		if (gfp_mask & __GFP_WAIT) {
-			shrink_icache_memory(6, gfp_mask);
-			shrink_dcache_memory(6, gfp_mask);
-			kmem_cache_reap(gfp_mask);
+			memory_pressure++;
 
-			page_launder(gfp_mask, 1);
+			try_to_free_pages(gfp_mask);
+
+			wakeup_bdflush(0);
 
 			if (!order)
 				goto try_again;
diff -Nur --exclude-from=exclude linux.orig/mm/vmscan.c linux/mm/vmscan.c
--- linux.orig/mm/vmscan.c	Sat Jan 13 19:19:04 2001
+++ linux/mm/vmscan.c	Sat Jan 13 21:22:29 2001
@@ -74,7 +74,8 @@
 drop_pte:
 		UnlockPage(page);
 		mm->rss--;
-		deactivate_page(page);
+		if (!page->age)
+			deactivate_page(page);
 		page_cache_release(page);
 		return;
 	}
@@ -262,9 +263,9 @@
 #define SWAP_SHIFT 5
 #define SWAP_MIN 8
 
-static inline int swap_amount(struct mm_struct *mm)
+static inline int swap_amount(struct mm_struct *mm, int dec)
 {
-	int nr = mm->rss >> SWAP_SHIFT;
+	int nr = (mm->rss >> SWAP_SHIFT) / (atomic_read(&mm->mm_users) - dec);
 	return nr < SWAP_MIN ? SWAP_MIN : nr;
 }
 
@@ -274,10 +275,6 @@
 	int retval = 0;
 	struct mm_struct *mm = current->mm;
 
-	/* Always start by trying to penalize the process that is allocating memory */
-	if (mm)
-		retval = swap_out_mm(mm, swap_amount(mm));
-
 	/* Then, look at the other mm's */
 	counter = mmlist_nr >> priority;
 	do {
@@ -298,7 +295,7 @@
 		spin_unlock(&mmlist_lock);
 
 		/* Walk about 6% of the address space each time */
-		retval |= swap_out_mm(mm, swap_amount(mm));
+		retval |= swap_out_mm(mm, swap_amount(mm, 1));
 		mmput(mm);
 	} while (--counter >= 0);
 	return retval;
@@ -491,7 +488,7 @@
 
 			result = writepage(page);
 			page_cache_release(page);
-
+			
 			/* And re-start the thing.. */
 			spin_lock(&pagemap_lru_lock);
 			if (result != 1)
@@ -851,6 +848,7 @@
 	if (free_shortage()) {
 		shrink_dcache_memory(DEF_PRIORITY, gfp_mask);
 		shrink_icache_memory(DEF_PRIORITY, gfp_mask);
+	} else {	
 		kmem_cache_reap(gfp_mask);
 	} 
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
