Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx136.postini.com [74.125.245.136])
	by kanga.kvack.org (Postfix) with SMTP id 0E50D6B00A9
	for <linux-mm@kvack.org>; Mon,  1 Oct 2012 19:01:07 -0400 (EDT)
Received: by ied10 with SMTP id 10so16882838ied.14
        for <linux-mm@kvack.org>; Mon, 01 Oct 2012 16:01:06 -0700 (PDT)
Date: Mon, 1 Oct 2012 16:00:25 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH RFC] mm/swap: automatic tuning for swapin readahead
In-Reply-To: <20120906110836.22423.17638.stgit@zurg>
Message-ID: <alpine.LSU.2.00.1210011418270.2940@eggly.anvils>
References: <50460CED.6060006@redhat.com> <20120906110836.22423.17638.stgit@zurg>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@openvz.org>, Shaohua Li <shli@kernel.org>
Cc: Rik van Riel <riel@redhat.com>, Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Wu Fengguang <fengguang.wu@intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Shaohua, Konstantin,

Sorry that it takes me so long to to reply on these swapin readahead
bounding threads, but I had to try some things out before jumping in,
and only found time to experiment last week.

On Thu, 6 Sep 2012, Konstantin Khlebnikov wrote:
> This patch adds simple tracker for swapin readahread effectiveness, and tunes
> readahead cluster depending on it. It manage internal state [0..1024] and scales
> readahead order between 0 and value from sysctl vm.page-cluster (3 by default).
> Swapout and readahead misses decreases state, swapin and ra hits increases it:
> 
>  Swapin          +1		[page fault, shmem, etc... ]
>  Swapout         -10
>  Readahead hit   +10
>  Readahead miss  -1		[removing from swapcache unused readahead page]
> 
> If system is under serious memory pressure swapin readahead is useless, because
> pages in swap are highly fragmented and cache hit is mostly impossible. In this
> case swapin only leads to unnecessary memory allocations. But readahead helps to
> read all swapped pages back to memory if system recovers from memory pressure.
> 
> This patch inspired by patch from Shaohua Li
> http://www.spinics.net/lists/linux-mm/msg41128.html
> mine version uses system wide state rather than per-VMA counters.
> 
> Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>

While I appreciate the usefulness of the idea, I do have some issues
with both implementations - Shaohua's currently in mmotm and next,
and Konstantin's apparently overlooked.

Shaohua, things I don't care for in your patch,
but none of them thoroughly convincing killers:

1. As Konstantin mentioned (in other words), it dignifies the illusion
   that swap is somehow structured by vmas, rather than being a global
   pool allocated by accident of when pages fall to the bottom of lrus.

2. Following on from that, it's unable to extend its optimization to
   randomly accessed tmpfs files or shmem areas (and I don't want that
   horrid pseudo-vma stuff in shmem.c to be extended in any way to deal
   with this - I'd have replaced it years ago by alloc_page_mpol() if I
   had understood the since-acknowledged-broken mempolicy lifetimes).

3. Although putting swapra_miss into struct anon_vma was a neat memory-
   saving idea from Konstantin, anon_vmas are otherwise pretty much self-
   referential, never before holding any control information themselves:
   I hesitate to extend them in this way.

4. I have not actually performed the test to prove it (tell me if I'm
   plain wrong), but experience with trying to modify it tells me that
   if your vma (worse, your anon_vma) is sometimes used for sequential
   access and sometimes for random (or part of it for sequential and
   part of it for random), then a burst of randomness will switch
   readahead off it forever.

Konstantin, given that, I wanted to speak up for your version.
I admire the way you have confined it to swap_state.c (and without
relying upon the FAULT_FLAG_TRIED patch), and make neat use of
PageReadahead and lookup_swap_cache().

But when I compared it against vanilla or Shaohua's patch, okay it's
comparable (a few percent slower?) than Shaohua's on random, and works
on shmem where his fails - but it was 50% slower on sequential access
(when testing on this laptop with Intel SSD: not quite the same as in
the tests below, which I left your patch out of).

I thought that's probably due to some off-by-one or other trivial bug
in the patch; but when I looked to correct it, I found that I just
don't understand what your heuristics are up to, the +1s and -1s
and +10s and -10s.  Maybe it's an off-by-ten, I haven't a clue.

Perhaps, with a trivial bugfix, and comments added, yours will be
great.  But it drove me to steal some of your ideas, combining with
a simple heuristic that even I can understand: patch below.

If I boot with mem=900M (and 1G swap: either on hard disk sda, or
on Vertex II SSD sdb), and mmap anonymous 1000M (either MAP_PRIVATE,
or MAP_SHARED for a shmem object), and either cycle sequentially round
that making 5M touches (spaced a page apart), or make 5M random touches,
then here are the times in centisecs that I see (but it's only elapsed
that I've been worrying about).

3.6-rc7 swapping to hard disk:
    124 user    6154 system   73921 elapsed -rc7 sda seq
    102 user    8862 system  895392 elapsed -rc7 sda random
    130 user    6628 system   73601 elapsed -rc7 sda shmem seq
    194 user    8610 system 1058375 elapsed -rc7 sda shmem random

3.6-rc7 swapping to SSD:
    116 user    5898 system   24634 elapsed -rc7 sdb seq
     96 user    8166 system   43014 elapsed -rc7 sdb random
    110 user    6410 system   24959 elapsed -rc7 sdb shmem seq
    208 user    8024 system   45349 elapsed -rc7 sdb shmem random

3.6-rc7 + Shaohua's patch (and FAULT_FLAG_RETRY check in do_swap_page), HDD:
    116 user    6258 system   76210 elapsed shli sda seq
     80 user    7716 system  831243 elapsed shli sda random
    128 user    6640 system   73176 elapsed shli sda shmem seq
    212 user    8522 system 1053486 elapsed shli sda shmem random

3.6-rc7 + Shaohua's patch (and FAULT_FLAG_RETRY check in do_swap_page), SSD:
    126 user    5734 system   24198 elapsed shli sdb seq
     90 user    7356 system   26146 elapsed shli sdb random
    128 user    6396 system   24932 elapsed shli sdb shmem seq
    192 user    8006 system   45215 elapsed shli sdb shmem random

3.6-rc7 + my patch, swapping to hard disk:
    126 user    6252 system   75611 elapsed hugh sda seq
     70 user    8310 system  871569 elapsed hugh sda random
    130 user    6790 system   73855 elapsed hugh sda shmem seq
    148 user    7734 system  827935 elapsed hugh sda shmem random

3.6-rc7 + my patch, swapping to SSD:
    116 user    5996 system   24673 elapsed hugh sdb seq
     76 user    7568 system   28075 elapsed hugh sdb random
    132 user    6468 system   25052 elapsed hugh sdb shmem seq
    166 user    7220 system   28249 elapsed hugh sdb shmem random

Mine does look slightly slower than Shaohua's there (except,
of course, on the shmem random): maybe it's just noise,
maybe I have some edge condition to improve, don't know yet.

These tests are, of course, at the single process extreme; I've also
tried my heavy swapping loads, but have not yet discerned a clear
trend on all machines from those.

Shaohua, Konstantin, do you have any time to try my patch against
whatever loads you were testing with, to see if it's a contender?

Thanks,
Hugh

 include/linux/page-flags.h |    4 +-
 mm/swap_state.c            |   51 ++++++++++++++++++++++++++++++++---
 2 files changed, 50 insertions(+), 5 deletions(-)

--- 3.6.0/include/linux/page-flags.h	2012-08-03 08:31:26.904842267 -0700
+++ linux/include/linux/page-flags.h	2012-09-28 22:02:00.008166986 -0700
@@ -228,9 +228,9 @@ PAGEFLAG(OwnerPriv1, owner_priv_1) TESTC
 TESTPAGEFLAG(Writeback, writeback) TESTSCFLAG(Writeback, writeback)
 PAGEFLAG(MappedToDisk, mappedtodisk)
 
-/* PG_readahead is only used for file reads; PG_reclaim is only for writes */
+/* PG_readahead is only used for reads; PG_reclaim is only for writes */
 PAGEFLAG(Reclaim, reclaim) TESTCLEARFLAG(Reclaim, reclaim)
-PAGEFLAG(Readahead, reclaim)		/* Reminder to do async read-ahead */
+PAGEFLAG(Readahead, reclaim) TESTCLEARFLAG(Readahead, reclaim)
 
 #ifdef CONFIG_HIGHMEM
 /*
--- 3.6.0/mm/swap_state.c	2012-08-03 08:31:27.076842271 -0700
+++ linux/mm/swap_state.c	2012-09-28 23:32:59.752577966 -0700
@@ -53,6 +53,8 @@ static struct {
 	unsigned long find_total;
 } swap_cache_info;
 
+static atomic_t swapra_hits = ATOMIC_INIT(0);
+
 void show_swap_cache_info(void)
 {
 	printk("%lu pages in swap cache\n", total_swapcache_pages);
@@ -265,8 +267,11 @@ struct page * lookup_swap_cache(swp_entr
 
 	page = find_get_page(&swapper_space, entry.val);
 
-	if (page)
+	if (page) {
 		INC_CACHE_INFO(find_success);
+		if (TestClearPageReadahead(page))
+			atomic_inc(&swapra_hits);
+	}
 
 	INC_CACHE_INFO(find_total);
 	return page;
@@ -351,6 +356,41 @@ struct page *read_swap_cache_async(swp_e
 	return found_page;
 }
 
+unsigned long swapin_nr_pages(unsigned long offset)
+{
+	static unsigned long prev_offset;
+	static unsigned int swapin_pages = 8;
+	unsigned int used, half, pages, max_pages;
+
+	used = atomic_xchg(&swapra_hits, 0) + 1;
+	pages = ACCESS_ONCE(swapin_pages);
+	half = pages >> 1;
+
+	if (!half) {
+		/*
+		 * We can have no readahead hits to judge by: but must not get
+		 * stuck here forever, so check for an adjacent offset instead
+		 * (and don't even bother to check if swap type is the same).
+		 */
+		if (offset == prev_offset + 1 || offset == prev_offset - 1)
+			pages <<= 1;
+		prev_offset = offset;
+	} else if (used < half) {
+		/* Less than half were used?  Then halve the window size */
+		pages = half;
+	} else if (used > half) {
+		/* More than half were used?  Then double the window size */
+		pages <<= 1;
+	}
+
+	max_pages = 1 << ACCESS_ONCE(page_cluster);
+	if (pages > max_pages)
+		pages = max_pages;
+	if (ACCESS_ONCE(swapin_pages) != pages)
+		swapin_pages = pages;
+	return pages;
+}
+
 /**
  * swapin_readahead - swap in pages in hope we need them soon
  * @entry: swap entry of this memory
@@ -374,11 +414,14 @@ struct page *swapin_readahead(swp_entry_
 			struct vm_area_struct *vma, unsigned long addr)
 {
 	struct page *page;
-	unsigned long offset = swp_offset(entry);
+	unsigned long entry_offset = swp_offset(entry);
+	unsigned long offset = entry_offset;
 	unsigned long start_offset, end_offset;
-	unsigned long mask = (1UL << page_cluster) - 1;
+	unsigned long mask;
 	struct blk_plug plug;
 
+	mask = swapin_nr_pages(offset) - 1;
+
 	/* Read a page_cluster sized and aligned cluster around offset. */
 	start_offset = offset & ~mask;
 	end_offset = offset | mask;
@@ -392,6 +435,8 @@ struct page *swapin_readahead(swp_entry_
 						gfp_mask, vma, addr);
 		if (!page)
 			continue;
+		if (offset != entry_offset)
+			SetPageReadahead(page);
 		page_cache_release(page);
 	}
 	blk_finish_plug(&plug);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
