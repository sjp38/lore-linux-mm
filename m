Date: Thu, 1 Jun 2000 19:31:24 -0300 (BRST)
From: Rik van Riel <riel@conectiva.com.br>
Subject: [PATCH] VM kswapd autotuning vs. -ac7
Message-ID: <Pine.LNX.4.21.0006011910340.1172-100000@duckman.distro.conectiva>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: linux-mm@kvack.org, linux-kernel@vger.rutgers.edu
List-ID: <linux-mm.kvack.org>

Hi,

this patch does the following things:
- move the starting page age to below the PG_AGE_ADV, so
  reclaimed pages have an advantage over pages which are
  new in the lru queue
- add two missing wake_up calls to buffer.c (I'm not 100%
  sure about these; I found them when digging through the
  classzone patch and they are consistent with other uses
  of the unused_list_lock
- if try_to_free_buffers waits on a page with buffers and
  succeeds in freeing them, return success (partly mined
  from classzone)
- __alloc_pages is responsible for waking up kswapd, however
  there seemed to be some flaws in the wakeup logic:
    - if kswapd is woken up too early, we free too much memory
      and waste CPU time
    - if kswapd is woken up too late, processes will call
      try_to_free_pages() themselves and stall; extremely
      bad for performance

The obvious solution is to have an auto-tuning algorithm where
the system tunes how often kswapd is woken up. To do that we
use the zone->zone_wake_kswapd and zone->low_on_memory flags.
Basically kswapd will always continue until no zone is low on
memory any more, sometimes resulting in one zone which has too
much free memory.

If we can keep all zones from being low on memory, allocations
can succeed immediately and applications can run fast. To ensure
that we must wake up kswapd often enough (but not too often).

The goal is to have every allocation happen in the second
"alloc loop" without any zones running low on memory. We achieve
this by waking up kswapd whenever we fall through the first loop
and it was longer than kswapd_pause ago that we last woke up
kswapd.

If we get a zone low on memory, we will half the value of
kswapd_pause so next time we'll wake up kswapd earlier. When
we never get low on memory, kswapd_pause will grow slowly over
time, balancing the halving of the period we did earlier.

I'm running some tests now and it seems that system performance
is good, kswapd overhead is quite a bit lower than before and
the amount of free memory is very stable (between freepages.low
and freepages.high, as it was called in 2.2 ;))

Please give this patch some exposure...

regards,

Rik
--
The Internet is not a network of computers. It is a network
of people. That is its real strength.

Wanna talk about the kernel?  irc.openprojects.net / #kernelnewbies
http://www.conectiva.com/		http://www.surriel.com/



--- linux-2.4.0-t1-ac7/fs/buffer.c.orig	Thu Jun  1 10:37:59 2000
+++ linux-2.4.0-t1-ac7/fs/buffer.c	Thu Jun  1 14:51:14 2000
@@ -1868,6 +1868,7 @@
 	}
 	
 	spin_unlock(&unused_list_lock);
+	wake_up(&buffer_wait);
 
 	return iosize;
 }
@@ -2004,6 +2005,8 @@
 		__put_unused_buffer_head(bh[bhind]);
 	}
 	spin_unlock(&unused_list_lock);
+	wake_up(&buffer_wait);
+
 	goto finished;
 }
 
@@ -2181,6 +2184,12 @@
 }
 
 /*
+ * Can the buffer be thrown out?
+ */
+#define BUFFER_BUSY_BITS	((1<<BH_Dirty) | (1<<BH_Lock) | (1<<BH_Protected))
+#define buffer_busy(bh)		(atomic_read(&(bh)->b_count) | ((bh)->b_state & BUFFER_BUSY_BITS))
+
+/*
  * Sync all the buffers on one page..
  *
  * If we have old buffers that are locked, we'll
@@ -2190,7 +2199,7 @@
  * This all is required so that we can free up memory
  * later.
  */
-static void sync_page_buffers(struct buffer_head *bh, int wait)
+static int sync_page_buffers(struct buffer_head *bh, int wait)
 {
 	struct buffer_head * tmp = bh;
 
@@ -2203,13 +2212,17 @@
 		} else if (buffer_dirty(p))
 			ll_rw_block(WRITE, 1, &p);
 	} while (tmp != bh);
-}
 
-/*
- * Can the buffer be thrown out?
- */
-#define BUFFER_BUSY_BITS	((1<<BH_Dirty) | (1<<BH_Lock) | (1<<BH_Protected))
-#define buffer_busy(bh)		(atomic_read(&(bh)->b_count) | ((bh)->b_state & BUFFER_BUSY_BITS))
+	do {
+		struct buffer_head *p = tmp;
+		tmp = tmp->b_this_page;
+		if (buffer_busy(p))
+			return 0;
+	} while (tmp != bh);
+
+	/* Success. Now try_to_free_buffers can free the page. */
+	return 1;
+}
 
 /*
  * try_to_free_buffers() checks if all the buffers on this particular page
@@ -2227,6 +2240,7 @@
 	struct buffer_head * tmp, * bh = page->buffers;
 	int index = BUFSIZE_INDEX(bh->b_size);
 
+again:
 	spin_lock(&lru_list_lock);
 	write_lock(&hash_table_lock);
 	spin_lock(&free_list[index].lock);
@@ -2272,7 +2286,8 @@
 	spin_unlock(&free_list[index].lock);
 	write_unlock(&hash_table_lock);
 	spin_unlock(&lru_list_lock);	
-	sync_page_buffers(bh, wait);
+	if (sync_page_buffers(bh, wait))
+		goto again;
 	return 0;
 }
 
--- linux-2.4.0-t1-ac7/mm/page_alloc.c.orig	Wed May 31 14:08:50 2000
+++ linux-2.4.0-t1-ac7/mm/page_alloc.c	Thu Jun  1 16:56:43 2000
@@ -222,6 +222,8 @@
 {
 	zone_t **zone = zonelist->zones;
 	extern wait_queue_head_t kswapd_wait;
+	static int last_woke_kswapd;
+	static int kswapd_pause = HZ;
 
 	/*
 	 * (If anyone calls gfp from interrupts nonatomically then it
@@ -248,9 +250,22 @@
 		}
 	}
 
-	/* All zones are in need of kswapd. */
-	if (waitqueue_active(&kswapd_wait))
+	/*
+	 * Kswapd should be freeing enough memory to satisfy all allocations
+	 * immediately.  Calling try_to_free_pages from processes will slow
+	 * down the system a lot.  On the other hand, waking up kswapd too
+	 * often means wasted memory and cpu time.
+	 *
+	 * We tune the kswapd pause interval in such a way that kswapd is
+	 * always just agressive enough to free the amount of memory we
+	 * want freed.
+	 */
+	if (waitqueue_active(&kswapd_wait) &&
+			time_after(jiffies, last_woke_kswapd + kswapd_pause)) {
+		kswapd_pause++;
+		last_woke_kswapd = jiffies;
 		wake_up_interruptible(&kswapd_wait);
+	}
 
 	/*
 	 * Ok, we don't have any zones that don't need some
@@ -267,6 +282,11 @@
 				z->low_on_memory = 1;
 			if (page)
 				return page;
+		} else {
+			/* We didn't kick kswapd often enough... */
+			kswapd_pause /= 2;
+			if (waitqueue_active(&kswapd_wait))
+				wake_up_interruptible(&kswapd_wait);
 		}
 	}
 
--- linux-2.4.0-t1-ac7/mm/filemap.c.orig	Wed May 31 14:08:50 2000
+++ linux-2.4.0-t1-ac7/mm/filemap.c	Thu Jun  1 12:15:58 2000
@@ -334,13 +334,6 @@
 
 		count--;
 		/*
-		 * Page is from a zone we don't care about.
-		 * Don't drop page cache entries in vain.
-		 */
-		if (page->zone->free_pages > page->zone->pages_high)
-			goto dispose_continue;
-
-		/*
 		 * Avoid unscalable SMP locking for pages we can
 		 * immediate tell are untouchable..
 		 */
@@ -374,6 +367,13 @@
 				goto made_buffer_progress;
 			}
 		}
+
+		/*
+		 * Page is from a zone we don't care about.
+		 * Don't drop page cache entries in vain.
+		 */
+		if (page->zone->free_pages > page->zone->pages_high)
+			goto unlock_continue;
 
 		/* Take the pagecache_lock spinlock held to avoid
 		   other tasks to notice the page while we are looking at its
--- linux-2.4.0-t1-ac7/include/linux/swap.h.orig	Wed May 31 21:00:06 2000
+++ linux-2.4.0-t1-ac7/include/linux/swap.h	Thu Jun  1 11:51:25 2000
@@ -166,7 +166,7 @@
  * The 2.4 code, however, is mostly simple and stable ;)
  */
 #define PG_AGE_MAX	64
-#define PG_AGE_START	5
+#define PG_AGE_START	2
 #define PG_AGE_ADV	3
 #define PG_AGE_DECL	1
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
