Date: Thu, 16 Aug 2001 00:09:26 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: 0-order allocation problem 
In-Reply-To: <Pine.LNX.4.33.0108151304340.2714-100000@penguin.transmeta.com>
Message-ID: <Pine.LNX.4.21.0108152343460.972-100000@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: Marcelo Tosatti <marcelo@conectiva.com.br>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 15 Aug 2001, Linus Torvalds wrote:
> 
> So something like the appended (UNTESTED!) should be better. How does it
> work for you?

Many thanks for your explanation.  You've convinced me that
create_buffers() has very good reason to make that effort.

Your patch works fine for me, for getting things moving again.
I'm not sure if you thought it would stop my "0-order allocation failed"
messages: no, I still get a batch of those before it settles back to work.

A variant of your patch appended below.  Ignore me if I'm blowing
you off track, but I just noticed "The Curse of the Incas" in vmscan.c;
and cannot look at that block of __alloc_pages() without remarking:

1. Why test free_shortage() in the high-order case?  The caller has
   asked for a high-order allocation, and is prepared to wait: we
   haven't found what the caller needs yet, we certainly should not
   wait forever, but we should try harder: it's irrelevant whether
   there's a free shortage or not - we've found a contiguity shortage.
2. It should not return NULL on failure at that point,
   should print the allocation failure message before returning.
3. Allocation failure message would do well to show gfp_mask too.

Hugh

--- linux-2.4.9-pre4/fs/buffer.c	Wed Aug 15 06:51:47 2001
+++ linux/fs/buffer.c	Wed Aug 15 22:23:16 2001
@@ -794,6 +794,17 @@
 		goto retry;
 }
 
+static void free_more_memory(void)
+{
+	balance_dirty(NODEV);
+	page_launder(GFP_NOFS, 0);
+	wakeup_bdflush();
+	wakeup_kswapd();
+	current->policy |= SCHED_YIELD;
+	__set_current_state(TASK_RUNNING);
+	schedule();
+}
+
 /*
  * We used to try various strange things. Let's not.
  * We'll just try to balance dirty buffers, and possibly
@@ -802,15 +813,8 @@
  */
 static void refill_freelist(int size)
 {
-	if (!grow_buffers(size)) {
-		balance_dirty(NODEV);
-		page_launder(GFP_NOFS, 0);		
-		wakeup_bdflush();
-		wakeup_kswapd();
-		current->policy |= SCHED_YIELD;
-		__set_current_state(TASK_RUNNING);
-		schedule();
-	}
+	if (!grow_buffers(size))
+		free_more_memory();
 }
 
 void init_buffer(struct buffer_head *bh, bh_end_io_t *handler, void *private)
@@ -1408,9 +1412,7 @@
 	 */
 	run_task_queue(&tq_disk);
 
-	current->policy |= SCHED_YIELD;
-	__set_current_state(TASK_RUNNING);
-	schedule();
+	free_more_memory();
 	goto try_again;
 }
 
--- linux-2.4.9-pre4/mm/page_alloc.c	Wed Aug 15 06:51:49 2001
+++ linux/mm/page_alloc.c	Wed Aug 15 23:02:11 2001
@@ -283,6 +283,7 @@
 {
 	zone_t **zone;
 	int direct_reclaim = 0;
+	int loop = 0;
 	struct page * page;
 
 	/*
@@ -448,16 +449,17 @@
 		 * to give up than to deadlock the kernel looping here.
 		 */
 		if (gfp_mask & __GFP_WAIT) {
-			if (!order || free_shortage()) {
-				int progress = try_to_free_pages(gfp_mask);
-				if (progress || (gfp_mask & __GFP_FS))
+			int progress = try_to_free_pages(gfp_mask);
+			if (order) {
+				if (loop++ < 4)
 					goto try_again;
-				/*
-				 * Fail in case no progress was made and the
-				 * allocation may not be able to block on IO.
-				 */
-				return NULL;
-			}
+			} else if (progress || (gfp_mask & __GFP_IO))
+				goto try_again;
+			/*
+			 * Fail in case no progress was made and the
+			 * allocation may not be able to block on IO.
+			 */
+			goto fail;
 		}
 	}
 
@@ -501,8 +503,9 @@
 			return page;
 	}
 
+fail:
 	/* No luck.. */
-	printk(KERN_ERR "__alloc_pages: %lu-order allocation failed.\n", order);
+	printk(KERN_ERR "__alloc_pages: %lu-order allocation failed (gfp_mask 0x%x).\n", order, gfp_mask);
 	return NULL;
 }
 
--- linux-2.4.9-pre4/mm/vmscan.c	Wed Aug 15 06:51:49 2001
+++ linux/mm/vmscan.c	Wed Aug 15 23:09:54 2001
@@ -779,7 +779,7 @@
 {
 	pg_data_t *pgdat;
 	unsigned int global_target = freepages.high + inactive_target;
-	unsigned int global_incative = 0;
+	unsigned int global_inactive = 0;
 
 	pgdat = pgdat_list;
 	do {
@@ -788,6 +788,9 @@
 			zone_t *zone = pgdat->node_zones + i;
 			unsigned int inactive;
 
+			if (!zone->size)
+				continue;
+
 			inactive  = zone->inactive_dirty_pages;
 			inactive += zone->inactive_clean_pages;
 			inactive += zone->free_pages;
@@ -796,13 +799,13 @@
 			if (inactive < zone->pages_high)
 				return 1;
 
-			global_incative += inactive;
+			global_inactive += inactive;
 		}
 		pgdat = pgdat->node_next;
 	} while (pgdat);
 
 	/* Global shortage? */
-	return global_incative < global_target;
+	return global_inactive < global_target;
 }
 
 /*

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
