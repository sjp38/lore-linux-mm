Received: from dax.scot.redhat.com (sct@dax.scot.redhat.com [195.89.149.242])
	by kvack.org (8.8.7/8.8.7) with ESMTP id RAA00208
	for <linux-mm@kvack.org>; Mon, 7 Dec 1998 17:05:52 -0500
Date: Mon, 7 Dec 1998 22:04:35 GMT
Message-Id: <199812072204.WAA01733@dax.scot.redhat.com>
From: "Stephen C. Tweedie" <sct@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Subject: Re: [PATCH] VM improvements for 2.1.131
In-Reply-To: <199812071801.SAA06360@dax.scot.redhat.com>
References: <98Dec7.104648gmt.66310@gateway.ukaea.org.uk>
	<Pine.LNX.3.96.981207140223.23360K-100000@mirkwood.dummy.home>
	<199812071801.SAA06360@dax.scot.redhat.com>
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Cc: Neil Conway <nconway.list@ukaea.org.uk>, Linux MM <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.rutgers.edu>, Stephen Tweedie <sct@redhat.com>, Andrea Arcangeli <andrea@e-mind.com>, Alan Cox <number6@the-village.bc.nu>
List-ID: <linux-mm.kvack.org>

Hi,

On Mon, 7 Dec 1998 18:01:31 GMT, "Stephen C. Tweedie" <sct@redhat.com>
said:

>> what we really need is somebody to try it out on 4M and
>> 8M machines...

> Been doing that.  2.1.130 is the fastest kernel ever in 8MB (using
> defrag builds over NFS as a benchmark): 25% faster that 2.0.36.  2.1.131
> is consistently about 10% slower at the same job than 130 (but still
> faster than 2.0 ever was).

Right: 2.1.131 + Rik's fixes + my fix to Rik's fixes (see below) has set
a new record for my 8MB benchmarks.  In 64MB, it is behaving much more
rationally than older kernels: still very very very fast, especially
interactively, but with no massive cache growth and swap storms when
doing filesystem intensive operations, and swap throughput when we _do_
swap is great.

I've changed your readahead stuff to look like:

	struct page *page_map = lookup_swap_cache(entry);

	if (!page_map) {
                swapin_readahead(entry);
		page_map = read_swap_cache(entry);
	}

which is the right way to do it: we don't want to start a readahead on a
swap hit, because that will try to extend the readahead "zone" one page
at a time as we hit existing pages in the cache.  That ends up with
one-page writes, with terrible performance if we have other IO activity
on the same disk.  I also tuned the readahead down to 8 pages, for the
tests on 8MB: we can make this tunable later.  

I also fixed the readahead logic itself to start with the correct
initial page (previously you were doing a "++i" in the for () condition,
which means we were skipping the first page in the readahead).  Now that
the readahead is being submitted before we do the wait-for-page, we need
to make absolutely sure to include the required page in the readahead
set.

Finally, I'll experiment with making the readahead a granularity-based
thing, so that we read an aligned block of (say) 64k from swap at a
time.  By starting the readahead on such a boundary rather than at the
current page, we can page in entire regions of swap very rapidly given a
random pattern of page hits.

For now, this is looking very good indeed.

--Stephen

----------------------------------------------------------------
--- include/linux/swap.h.~1~	Mon Dec  7 12:05:54 1998
+++ include/linux/swap.h	Mon Dec  7 18:55:55 1998
@@ -90,6 +90,7 @@
 extern struct page * read_swap_cache_async(unsigned long, int);
 #define read_swap_cache(entry) read_swap_cache_async(entry, 1);
 extern int FASTCALL(swap_count(unsigned long));
+extern struct page * lookup_swap_cache(unsigned long); 
 /*
  * Make these inline later once they are working properly.
  */
--- mm/page_alloc.c.~1~	Fri Nov 27 12:36:42 1998
+++ mm/page_alloc.c	Mon Dec  7 20:42:36 1998
@@ -360,6 +360,35 @@
 }
 
 /*
+ * Primitive swap readahead code. We simply read the
+ * next 8 entries in the swap area. This method is
+ * chosen because it doesn't cost us any seek time.
+ * We also make sure to queue the 'original' request
+ * together with the readahead ones...
+ */
+void swapin_readahead(unsigned long entry) {
+        int i;
+        struct page *new_page;
+	unsigned long offset = SWP_OFFSET(entry);
+	struct swap_info_struct *swapdev = SWP_TYPE(entry) + swap_info;
+
+	for (i = 0; i < 8; i++) {
+	      if (offset >= swapdev->max
+		              || nr_free_pages - atomic_read(&nr_async_pages) <
+			      (freepages.high + freepages.low)/2)
+		      return;
+	      if (!swapdev->swap_map[offset] ||
+                              test_bit(offset, swapdev->swap_lockmap))
+		      continue;
+	      new_page = read_swap_cache_async(SWP_ENTRY(SWP_TYPE(entry), offset), 0);
+	      if (new_page != NULL)
+                      __free_page(new_page);
+	      offset++;
+	}
+	return;
+}
+
+/*
  * The tests may look silly, but it essentially makes sure that
  * no other process did a swap-in on us just as we were waiting.
  *
@@ -370,10 +399,12 @@
 	pte_t * page_table, unsigned long entry, int write_access)
 {
 	unsigned long page;
-	struct page *page_map;
-	
-	page_map = read_swap_cache(entry);
+	struct page *page_map = lookup_swap_cache(entry);
 
+	if (!page_map) {
+                swapin_readahead(entry);
+		page_map = read_swap_cache(entry);
+	}
 	if (pte_val(*page_table) != entry) {
 		if (page_map)
 			free_page_and_swap_cache(page_address(page_map));
--- mm/page_io.c.~1~	Fri Nov 27 12:36:42 1998
+++ mm/page_io.c	Mon Dec  7 18:55:55 1998
@@ -60,7 +60,7 @@
 	}
 
 	/* Don't allow too many pending pages in flight.. */
-	if (atomic_read(&nr_async_pages) > SWAP_CLUSTER_MAX)
+	if (atomic_read(&nr_async_pages) > pager_daemon.swap_cluster)
 		wait = 1;
 
 	p = &swap_info[type];
--- mm/swap.c.~1~	Mon Dec  7 12:05:54 1998
+++ mm/swap.c	Mon Dec  7 18:55:55 1998
@@ -61,14 +61,14 @@
 swapstat_t swapstats = {0};
 
 buffer_mem_t buffer_mem = {
-	5,	/* minimum percent buffer */
-	10,	/* borrow percent buffer */
+	1,	/* minimum percent buffer */
+	20,	/* borrow percent buffer */
 	60	/* maximum percent buffer */
 };
 
 buffer_mem_t page_cache = {
-	5,	/* minimum percent page cache */
-	15,	/* borrow percent page cache */
+	1,	/* minimum percent page cache */
+	30,	/* borrow percent page cache */
 	75	/* maximum */
 };
 
--- mm/swap_state.c.~1~	Fri Nov 27 12:36:42 1998
+++ mm/swap_state.c	Mon Dec  7 18:55:55 1998
@@ -258,9 +258,10 @@
  * incremented.
  */
 
-static struct page * lookup_swap_cache(unsigned long entry)
+struct page * lookup_swap_cache(unsigned long entry)
 {
 	struct page *found;
+	swap_cache_find_total++;
 	
 	while (1) {
 		found = find_page(&swapper_inode, entry);
@@ -268,8 +269,10 @@
 			return 0;
 		if (found->inode != &swapper_inode || !PageSwapCache(found))
 			goto out_bad;
-		if (!PageLocked(found))
+		if (!PageLocked(found)) {
+			swap_cache_find_success++;
 			return found;
+		}
 		__free_page(found);
 		__wait_on_page(found);
 	}
--- mm/vmscan.c.~1~	Mon Dec  7 12:05:54 1998
+++ mm/vmscan.c	Mon Dec  7 18:55:55 1998
@@ -432,6 +432,8 @@
 
 	if (buffer_over_borrow() || pgcache_over_borrow())
 		state = 0;
+	if (atomic_read(&nr_async_pages) > pager_daemon.swap_cluster / 2)
+		shrink_mmap(i, gfp_mask);
 
 	switch (state) {
 		do {
--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
