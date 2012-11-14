Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx122.postini.com [74.125.245.122])
	by kanga.kvack.org (Postfix) with SMTP id AE2676B009B
	for <linux-mm@kvack.org>; Wed, 14 Nov 2012 04:48:22 -0500 (EST)
Received: by mail-pa0-f41.google.com with SMTP id fa10so201083pad.14
        for <linux-mm@kvack.org>; Wed, 14 Nov 2012 01:48:22 -0800 (PST)
Date: Wed, 14 Nov 2012 01:48:18 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: Re: [PATCH RFC] mm/swap: automatic tuning for swapin readahead
In-Reply-To: <20121106053628.GA1539@kernel.org>
Message-ID: <alpine.LNX.2.00.1211140109020.19427@eggly.anvils>
References: <506AACAC.2010609@openvz.org> <alpine.LSU.2.00.1210031337320.1415@eggly.anvils> <506DB816.9090107@openvz.org> <alpine.LSU.2.00.1210081451410.1384@eggly.anvils> <20121016005049.GA1467@kernel.org> <20121022073654.GA7821@kernel.org>
 <alpine.LNX.2.00.1210222141170.1136@eggly.anvils> <20121023055127.GA24239@kernel.org> <50869E6C.1080907@redhat.com> <20121024011356.GA6400@kernel.org> <20121106053628.GA1539@kernel.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Shaohua Li <shli@kernel.org>
Cc: Rik van Riel <riel@redhat.com>, Konstantin Khlebnikov <khlebnikov@openvz.org>, Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Wu Fengguang <fengguang.wu@intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Tue, 6 Nov 2012, Shaohua Li wrote:
> On Wed, Oct 24, 2012 at 09:13:56AM +0800, Shaohua Li wrote:
> > On Tue, Oct 23, 2012 at 09:41:00AM -0400, Rik van Riel wrote:
> > > On 10/23/2012 01:51 AM, Shaohua Li wrote:
> > > 
> > > >I have no strong point against the global state method. But I'd agree making the
> > > >heuristic simple is preferred currently. I'm happy about the patch if the '+1'
> > > >is removed.
> > > 
> > > Without the +1, how will you figure out when to re-enable readahead?
> > 
> > Below code in swapin_nr_pages can recover it.
> > +               if (offset == prev_offset + 1 || offset == prev_offset - 1)
> > +                       pages <<= 1;
> > 
> > Not perfect, but should work in some sort. This reminds me to think if
> > pagereadahead flag is really required, hit in swap cache is a more reliable way
> > to count readahead hit, and as Hugh mentioned, swap isn't vma bound.
> 
> Hugh,
> ping! Any chance you can check this again?

I apologize, Shaohua, my slowness must be very frustrating for you,
as it is for me too.

Thank you for pointing out how my first patch was reading two pages
instead of one in the random case, explaining its disappointing
performance there: odd how blind I was to that, despite taking stats.

I did experiment with removing the "+ 1" as you did, it worked well
in the random SSD case, but degraded performance in (all? I forget)
the other cases.

I failed to rescue the "algorithm" in that patch, and changed it a
week ago for an even simpler one, that has worked well for me so far.
When I sent you a quick private ack to your ping, I was puzzled by its
"too good to be true" initial test results: once I looked into those,
found my rearrangement of the test script had left out a swapoff,
so the supposed harddisk tests were actually swapping to SSD.

I've finally got around to assembling the results and writing up
some description, starting off from yours.  I think I've gone as
far as I can with this, and don't want to hold you up with further
delays: would it be okay if I simply hand this patch over to you now,
to test and expand upon and add your Sign-off and send in to akpm to
replace your original in mmotm - IF you are satisfied with it?


[PATCH] swap: add a simple detector for inappropriate swapin readahead

swapin readahead does a blind readahead, whether or not the swapin
is sequential.  This may be ok on harddisk, because large reads have
relatively small costs, and if the readahead pages are unneeded they
can be reclaimed easily - though, what if their allocation forced
reclaim of useful pages?  But on SSD devices large reads are more
expensive than small ones: if the readahead pages are unneeded,
reading them in caused significant overhead.

This patch adds very simplistic random read detection.  Stealing
the PageReadahead technique from Konstantin Khlebnikov's patch,
avoiding the vma/anon_vma sophistications of Shaohua Li's patch,
swapin_nr_pages() simply looks at readahead's current success
rate, and narrows or widens its readahead window accordingly.
There is little science to its heuristic: it's about as stupid
as can be whilst remaining effective.

The table below shows elapsed times (in centiseconds) when running
a single repetitive swapping load across a 1000MB mapping in 900MB
ram with 1GB swap (the harddisk tests had taken painfully too long
when I used mem=500M, but SSD shows similar results for that).

Vanilla is the 3.6-rc7 kernel on which I started; Shaohua denotes
his Sep 3 patch in mmotm and linux-next; HughOld denotes my Oct 1
patch which Shaohua showed to be defective; HughNew this Nov 14
patch, with page_cluster as usual at default of 3 (8-page reads);
HughPC4 this same patch with page_cluster 4 (16-page reads);
HughPC0 with page_cluster 0 (1-page reads: no readahead).

HDD for swapping to harddisk, SSD for swapping to VertexII SSD.
Seq for sequential access to the mapping, cycling five times around;
Rand for the same number of random touches.  Anon for a MAP_PRIVATE
anon mapping; Shmem for a MAP_SHARED anon mapping, equivalent to tmpfs.

One weakness of Shaohua's vma/anon_vma approach was that it did
not optimize Shmem: seen below.  Konstantin's approach was perhaps
mistuned, 50% slower on Seq: did not compete and is not shown below.

HDD        Vanilla Shaohua HughOld HughNew HughPC4 HughPC0
Seq Anon     73921   76210   75611   76904   78191  121542
Seq Shmem    73601   73176   73855   72947   74543  118322
Rand Anon   895392  831243  871569  845197  846496  841680
Rand Shmem 1058375 1053486  827935  764955  764376  756489

SSD        Vanilla Shaohua HughOld HughNew HughPC4 HughPC0
Seq Anon     24634   24198   24673   25107   21614   70018
Seq Shmem    24959   24932   25052   25703   22030   69678
Rand Anon    43014   26146   28075   25989   26935   25901
Rand Shmem   45349   45215   28249   24268   24138   24332

These tests are, of course, two extremes of a very simple case:
under heavier mixed loads I've not yet observed any consistent
improvement or degradation, and wider testing would be welcome.

Original-patch-by: Shaohua Li <shli@fusionio.com>
Original-patch-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
Signed-off-by: Hugh Dickins <hughd@google.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: Wu Fengguang <fengguang.wu@intel.com>
Cc: Minchan Kim <minchan@kernel.org>
---

 include/linux/page-flags.h |    4 +-
 mm/swap_state.c            |   55 +++++++++++++++++++++++++++++++++--
 2 files changed, 54 insertions(+), 5 deletions(-)

--- 3.7-rc5/include/linux/page-flags.h	2012-09-30 16:47:46.000000000 -0700
+++ linux/include/linux/page-flags.h	2012-11-11 09:45:30.908591576 -0800
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
--- 3.7-rc5/mm/swap_state.c	2012-09-30 16:47:46.000000000 -0700
+++ linux/mm/swap_state.c	2012-11-11 09:50:06.520598126 -0800
@@ -53,6 +53,8 @@ static struct {
 	unsigned long find_total;
 } swap_cache_info;
 
+static atomic_t swapin_readahead_hits = ATOMIC_INIT(4);
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
+			atomic_inc(&swapin_readahead_hits);
+	}
 
 	INC_CACHE_INFO(find_total);
 	return page;
@@ -351,6 +356,42 @@ struct page *read_swap_cache_async(swp_e
 	return found_page;
 }
 
+unsigned long swapin_nr_pages(unsigned long offset)
+{
+	static unsigned long prev_offset;
+	unsigned int pages, max_pages;
+
+	max_pages = 1 << ACCESS_ONCE(page_cluster);
+	if (max_pages <= 1)
+		return 1;
+
+	/*
+	 * This heuristic has been found to work well on both sequential and
+	 * random loads, swapping to hard disk or to SSD: please don't ask
+	 * what the "+ 2" means, it just happens to work well, that's all.
+	 */
+	pages = atomic_xchg(&swapin_readahead_hits, 0) + 2;
+	if (pages == 2) {
+		/*
+		 * We can have no readahead hits to judge by: but must not get
+		 * stuck here forever, so check for an adjacent offset instead
+		 * (and don't even bother to check whether swap type is same).
+		 */
+		if (offset != prev_offset + 1 && offset != prev_offset - 1)
+			pages = 1;
+		prev_offset = offset;
+	} else {
+		unsigned int roundup = 4;
+		while (roundup < pages)
+			roundup <<= 1;
+		pages = roundup;
+	}
+
+	if (pages > max_pages)
+		pages = max_pages;
+	return pages;
+}
+
 /**
  * swapin_readahead - swap in pages in hope we need them soon
  * @entry: swap entry of this memory
@@ -374,11 +415,16 @@ struct page *swapin_readahead(swp_entry_
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
+	if (!mask)
+		goto skip;
+
 	/* Read a page_cluster sized and aligned cluster around offset. */
 	start_offset = offset & ~mask;
 	end_offset = offset | mask;
@@ -392,10 +438,13 @@ struct page *swapin_readahead(swp_entry_
 						gfp_mask, vma, addr);
 		if (!page)
 			continue;
+		if (offset != entry_offset)
+			SetPageReadahead(page);
 		page_cache_release(page);
 	}
 	blk_finish_plug(&plug);
 
 	lru_add_drain();	/* Push any new pages onto the LRU now */
+skip:
 	return read_swap_cache_async(entry, gfp_mask, vma, addr);
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
