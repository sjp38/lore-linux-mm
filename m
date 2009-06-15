Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 66D646B004F
	for <linux-mm@kvack.org>; Mon, 15 Jun 2009 14:25:11 -0400 (EDT)
Date: Mon, 15 Jun 2009 20:22:17 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [patch v3] swap: virtual swap readahead
Message-ID: <20090615182216.GA1661@cmpxchg.org>
References: <20090610173249.50e19966.kamezawa.hiroyu@jp.fujitsu.com> <20090610085638.GA32511@localhost> <1244626976.13761.11593.camel@twins> <20090610095950.GA514@localhost> <1244628314.13761.11617.camel@twins> <20090610113214.GA5657@localhost> <20090610102516.08f7300f@jbarnes-x200> <20090611052228.GA20100@localhost> <20090611101741.GA1974@cmpxchg.org> <20090612015927.GA6804@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090612015927.GA6804@localhost>
Sender: owner-linux-mm@kvack.org
To: Wu Fengguang <fengguang.wu@intel.com>
Cc: "Barnes, Jesse" <jesse.barnes@intel.com>, Peter Zijlstra <peterz@infradead.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Andi Kleen <andi@firstfloor.org>, Minchan Kim <minchan.kim@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Fri, Jun 12, 2009 at 09:59:27AM +0800, Wu Fengguang wrote:
> On Thu, Jun 11, 2009 at 06:17:42PM +0800, Johannes Weiner wrote:
> > On Thu, Jun 11, 2009 at 01:22:28PM +0800, Wu Fengguang wrote:
> > > Unfortunately, after fixing it up the swap readahead patch still performs slow
> > > (even worse this time):
> > 
> > Thanks for doing the tests.  Do you know if the time difference comes
> > from IO or CPU time?
> > 
> > Because one reason I could think of is that the original code walks
> > the readaround window in two directions, starting from the target each
> > time but immediately stops when it encounters a hole where the new
> > code just skips holes but doesn't abort readaround and thus might
> > indeed read more slots.
> > 
> > I have an old patch flying around that changed the physical ra code to
> > use a bitmap that is able to represent holes.  If the increased time
> > is waiting for IO, I would be interested if that patch has the same
> > negative impact.
> 
> You can send me the patch :)

Okay, attached is a rebase against latest -mmotm.

> But for this patch it is IO bound. The CPU iowait field actually is
> going up as the test goes on:

It's probably the larger ra window then which takes away the bandwidth
needed to load the new executables.  This sucks.  Would be nice to
have 'optional IO' for readahead that is dropped when normal-priority
IO requests are coming in...  Oh, we have READA for bios.  But it
doesn't seem to implement dropping requests on load (or I am blind).

	Hannes

---

diff --git a/include/linux/swap.h b/include/linux/swap.h
index c88b366..119ad43 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -284,7 +284,7 @@ extern swp_entry_t get_swap_page(void);
 extern swp_entry_t get_swap_page_of_type(int);
 extern void swap_duplicate(swp_entry_t);
 extern int swapcache_prepare(swp_entry_t);
-extern int valid_swaphandles(swp_entry_t, unsigned long *);
+extern pgoff_t valid_swaphandles(swp_entry_t, unsigned long *, unsigned long);
 extern void swap_free(swp_entry_t);
 extern void swapcache_free(swp_entry_t, struct page *page);
 extern int free_swap_and_cache(swp_entry_t);
diff --git a/mm/swap_state.c b/mm/swap_state.c
index 42cd38e..c9f9c97 100644
--- a/mm/swap_state.c
+++ b/mm/swap_state.c
@@ -348,10 +348,10 @@ struct page *read_swap_cache_async(swp_entry_t entry, gfp_t gfp_mask,
 struct page *swapin_readahead(swp_entry_t entry, gfp_t gfp_mask,
 			struct vm_area_struct *vma, unsigned long addr)
 {
-	int nr_pages;
-	struct page *page;
+	unsigned long nr_slots = 1 << page_cluster;
+	DECLARE_BITMAP(slots, nr_slots);
 	unsigned long offset;
-	unsigned long end_offset;
+	pgoff_t base;
 
 	/*
 	 * Get starting offset for readaround, and number of pages to read.
@@ -360,11 +360,15 @@ struct page *swapin_readahead(swp_entry_t entry, gfp_t gfp_mask,
 	 * more likely that neighbouring swap pages came from the same node:
 	 * so use the same "addr" to choose the same node for each swap read.
 	 */
-	nr_pages = valid_swaphandles(entry, &offset);
-	for (end_offset = offset + nr_pages; offset < end_offset; offset++) {
-		/* Ok, do the async read-ahead now */
-		page = read_swap_cache_async(swp_entry(swp_type(entry), offset),
-						gfp_mask, vma, addr);
+	base = valid_swaphandles(entry, slots, nr_slots);
+	for (offset = find_first_bit(slots, nr_slots);
+	     offset < nr_slots;
+	     offset = find_next_bit(slots, nr_slots, offset + 1)) {
+		struct page *page;
+		swp_entry_t tmp;
+
+		tmp = swp_entry(swp_type(entry), base + offset);
+		page = read_swap_cache_async(tmp, gfp_mask, vma, addr);
 		if (!page)
 			break;
 		page_cache_release(page);
diff --git a/mm/swapfile.c b/mm/swapfile.c
index d1ade1a..27771dd 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -2163,25 +2163,28 @@ get_swap_info_struct(unsigned type)
 	return &swap_info[type];
 }
 
+static int swap_inuse(unsigned long count)
+{
+	int swapcount = swap_count(count);
+	return swapcount && swapcount != SWAP_MAP_BAD;
+}
+
 /*
  * swap_lock prevents swap_map being freed. Don't grab an extra
  * reference on the swaphandle, it doesn't matter if it becomes unused.
  */
-int valid_swaphandles(swp_entry_t entry, unsigned long *offset)
+pgoff_t valid_swaphandles(swp_entry_t entry, unsigned long *slots,
+			unsigned long nr_slots)
 {
 	struct swap_info_struct *si;
-	int our_page_cluster = page_cluster;
-	pgoff_t target, toff;
-	pgoff_t base, end;
-	int nr_pages = 0;
-
-	if (!our_page_cluster)	/* no readahead */
-		return 0;
+	pgoff_t target, base, end;
 
+	bitmap_zero(slots, nr_slots);
 	si = &swap_info[swp_type(entry)];
 	target = swp_offset(entry);
-	base = (target >> our_page_cluster) << our_page_cluster;
-	end = base + (1 << our_page_cluster);
+	base = target & ~(nr_slots - 1);
+	end = base + nr_slots;
+
 	if (!base)		/* first page is swap header */
 		base++;
 
@@ -2189,28 +2192,10 @@ int valid_swaphandles(swp_entry_t entry, unsigned long *offset)
 	if (end > si->max)	/* don't go beyond end of map */
 		end = si->max;
 
-	/* Count contiguous allocated slots above our target */
-	for (toff = target; ++toff < end; nr_pages++) {
-		/* Don't read in free or bad pages */
-		if (!si->swap_map[toff])
-			break;
-		if (swap_count(si->swap_map[toff]) == SWAP_MAP_BAD)
-			break;
-	}
-	/* Count contiguous allocated slots below our target */
-	for (toff = target; --toff >= base; nr_pages++) {
-		/* Don't read in free or bad pages */
-		if (!si->swap_map[toff])
-			break;
-		if (swap_count(si->swap_map[toff]) == SWAP_MAP_BAD)
-			break;
-	}
-	spin_unlock(&swap_lock);
+	while (end-- > base)
+		if (end == target || swap_inuse(si->swap_map[end]))
+			set_bit(end - base, slots);
 
-	/*
-	 * Indicate starting offset, and return number of pages to get:
-	 * if only 1, say 0, since there's then no readahead to be done.
-	 */
-	*offset = ++toff;
-	return nr_pages? ++nr_pages: 0;
+	spin_unlock(&swap_lock);
+	return base;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
