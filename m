Date: Tue, 9 Jan 2001 18:33:19 -0200 (BRST)
From: Marcelo Tosatti <marcelo@conectiva.com.br>
Subject: Re: Subtle MM bug
In-Reply-To: <Pine.LNX.4.10.10101081903450.1371-100000@penguin.transmeta.com>
Message-ID: <Pine.LNX.4.21.0101091654040.7377-100000@freak.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@transmeta.com>
Cc: "Stephen C. Tweedie" <sct@redhat.com>, "David S. Miller" <davem@redhat.com>, Rik van Riel <riel@conectiva.com.br>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, 8 Jan 2001, Linus Torvalds wrote:

> Try out 2.4.1-pre1 in testing.

The "while (!inactive_shortage())" should be "while (inactive_shortage())"
as Benjamin noted on lk.

The second problem is that background scanning is being done
unconditionally, and it should not. You end up getting all pages with the
same age if the system is idle. Look at this example (2.4.1-pre1):

MemTotal:       900148 kB
MemFree:        145060 kB
Cached:         725624 kB
Active:           3972 kB
Inact_dirty:    722940 kB
Inact_clean:         0 kB
Inact_target:      188 kB

> That kmem_cache_reap() thing still looks completely bogus, but I didn't
> touch it. It looks _so_ bogus that there must be some reason for doing it
> that ass-backwards way. Why should anybody have does a kmem_cache_reap()
> when we're _not_ short of free pages? That code just makes me very
> confused, so I'm not touching it.

This patch removes kmem_cache_reap() from refill_inactive() and moves it
to inside the free_shortage() check in do_try_to_free_pages().

It also changes the "while (!inactive_shortage())" mistake.

Comments?

diff -Nur linux.orig/include/linux/fs.h linux/include/linux/fs.h
--- linux.orig/include/linux/fs.h	Tue Jan  9 19:32:51 2001
+++ linux/include/linux/fs.h	Tue Jan  9 20:07:32 2001
@@ -985,7 +985,7 @@
 
 extern int fs_may_remount_ro(struct super_block *);
 
-extern int try_to_free_buffers(struct page *, int);
+extern void try_to_free_buffers(struct page *, int);
 extern void refile_buffer(struct buffer_head * buf);
 
 #define BUF_CLEAN	0
diff -Nur linux.orig/include/linux/swap.h linux/include/linux/swap.h
--- linux.orig/include/linux/swap.h	Tue Jan  9 19:32:51 2001
+++ linux/include/linux/swap.h	Tue Jan  9 20:07:38 2001
@@ -108,7 +108,7 @@
 extern int free_shortage(void);
 extern int inactive_shortage(void);
 extern void wakeup_kswapd(int);
-extern int try_to_free_pages(unsigned int gfp_mask);
+extern void try_to_free_pages(unsigned int gfp_mask);
 
 /* linux/mm/page_io.c */
 extern void rw_swap_page(int, struct page *, int);
diff -Nur linux.orig/mm/vmscan.c linux/mm/vmscan.c
--- linux.orig/mm/vmscan.c	Tue Jan  9 19:35:41 2001
+++ linux/mm/vmscan.c	Tue Jan  9 20:06:01 2001
@@ -825,9 +825,6 @@
 		count = (1 << page_cluster);
 	start_count = count;
 
-	/* Always trim SLAB caches when memory gets low. */
-	kmem_cache_reap(gfp_mask);
-
 	priority = 6;
 	do {
 		if (current->need_resched) {
@@ -842,16 +839,14 @@
 
 		/* If refill_inactive_scan failed, try to page stuff out.. */
 		swap_out(priority, gfp_mask);
-	} while (!inactive_shortage());
+	} while (inactive_shortage());
 
 done:
 	return (count < start_count);
 }
 
-static int do_try_to_free_pages(unsigned int gfp_mask, int user)
+static void do_try_to_free_pages(unsigned int gfp_mask, int user)
 {
-	int ret = 0;
-
 	/*
 	 * If we're low on free pages, move pages from the
 	 * inactive_dirty list to the inactive_clean list.
@@ -862,32 +857,24 @@
 	 */
 	if (free_shortage() || nr_inactive_dirty_pages > nr_free_pages() +
 			nr_inactive_clean_pages())
-		ret += page_launder(gfp_mask, user);
+		page_launder(gfp_mask, user);
 
 	/*
 	 * If needed, we move pages from the active list
 	 * to the inactive list.
 	 */
 	if (inactive_shortage())
-		ret += refill_inactive(gfp_mask, user);
+		refill_inactive(gfp_mask, user);
 
 	/* 	
-	 * Delete pages from the inode and dentry cache 
-	 * if memory is low. 
+	 * Delete pages from the inode and dentry cache and
+	 * reclaim unused slab cache if memory is low.
 	 */
 	if (free_shortage()) {
 		shrink_dcache_memory(6, gfp_mask);
 		shrink_icache_memory(6, gfp_mask);
-	} else { 
-
-		/*
-		 * Reclaim unused slab cache memory.
-		 */
 		kmem_cache_reap(gfp_mask);
-		ret = 1;
 	}
-
-	return ret;
 }
 
 DECLARE_WAIT_QUEUE_HEAD(kswapd_wait);
@@ -1029,17 +1016,13 @@
  * memory but are unable to sleep on kswapd because
  * they might be holding some IO locks ...
  */
-int try_to_free_pages(unsigned int gfp_mask)
+void try_to_free_pages(unsigned int gfp_mask)
 {
-	int ret = 1;
-
 	if (gfp_mask & __GFP_WAIT) {
 		current->flags |= PF_MEMALLOC;
-		ret = do_try_to_free_pages(gfp_mask, 1);
+		do_try_to_free_pages(gfp_mask, 1);
 		current->flags &= ~PF_MEMALLOC;
 	}
-
-	return ret;
 }
 
 DECLARE_WAIT_QUEUE_HEAD(kreclaimd_wait);


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
