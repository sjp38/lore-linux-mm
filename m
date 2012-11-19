Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx159.postini.com [74.125.245.159])
	by kanga.kvack.org (Postfix) with SMTP id 755656B005D
	for <linux-mm@kvack.org>; Sun, 18 Nov 2012 21:33:56 -0500 (EST)
Received: by mail-da0-f41.google.com with SMTP id e20so428397dak.14
        for <linux-mm@kvack.org>; Sun, 18 Nov 2012 18:33:55 -0800 (PST)
Date: Mon, 19 Nov 2012 10:33:47 +0800
From: Shaohua Li <shli@kernel.org>
Subject: Re: [PATCH RFC] mm/swap: automatic tuning for swapin readahead
Message-ID: <20121119023347.GA18578@kernel.org>
References: <506DB816.9090107@openvz.org>
 <alpine.LSU.2.00.1210081451410.1384@eggly.anvils>
 <20121016005049.GA1467@kernel.org>
 <20121022073654.GA7821@kernel.org>
 <alpine.LNX.2.00.1210222141170.1136@eggly.anvils>
 <20121023055127.GA24239@kernel.org>
 <50869E6C.1080907@redhat.com>
 <20121024011356.GA6400@kernel.org>
 <20121106053628.GA1539@kernel.org>
 <alpine.LNX.2.00.1211140109020.19427@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LNX.2.00.1211140109020.19427@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Rik van Riel <riel@redhat.com>, Konstantin Khlebnikov <khlebnikov@openvz.org>, Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Wu Fengguang <fengguang.wu@intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, Nov 14, 2012 at 01:48:18AM -0800, Hugh Dickins wrote:
> On Tue, 6 Nov 2012, Shaohua Li wrote:
> > On Wed, Oct 24, 2012 at 09:13:56AM +0800, Shaohua Li wrote:
> > > On Tue, Oct 23, 2012 at 09:41:00AM -0400, Rik van Riel wrote:
> > > > On 10/23/2012 01:51 AM, Shaohua Li wrote:
> > > > 
> > > > >I have no strong point against the global state method. But I'd agree making the
> > > > >heuristic simple is preferred currently. I'm happy about the patch if the '+1'
> > > > >is removed.
> > > > 
> > > > Without the +1, how will you figure out when to re-enable readahead?
> > > 
> > > Below code in swapin_nr_pages can recover it.
> > > +               if (offset == prev_offset + 1 || offset == prev_offset - 1)
> > > +                       pages <<= 1;
> > > 
> > > Not perfect, but should work in some sort. This reminds me to think if
> > > pagereadahead flag is really required, hit in swap cache is a more reliable way
> > > to count readahead hit, and as Hugh mentioned, swap isn't vma bound.
> > 
> > Hugh,
> > ping! Any chance you can check this again?
> 
> I apologize, Shaohua, my slowness must be very frustrating for you,
> as it is for me too.

Not at all, thanks for looking at it.
 
> Thank you for pointing out how my first patch was reading two pages
> instead of one in the random case, explaining its disappointing
> performance there: odd how blind I was to that, despite taking stats.
> 
> I did experiment with removing the "+ 1" as you did, it worked well
> in the random SSD case, but degraded performance in (all? I forget)
> the other cases.
> 
> I failed to rescue the "algorithm" in that patch, and changed it a
> week ago for an even simpler one, that has worked well for me so far.
> When I sent you a quick private ack to your ping, I was puzzled by its
> "too good to be true" initial test results: once I looked into those,
> found my rearrangement of the test script had left out a swapoff,
> so the supposed harddisk tests were actually swapping to SSD.
> 
> I've finally got around to assembling the results and writing up
> some description, starting off from yours.  I think I've gone as
> far as I can with this, and don't want to hold you up with further
> delays: would it be okay if I simply hand this patch over to you now,
> to test and expand upon and add your Sign-off and send in to akpm to
> replace your original in mmotm - IF you are satisfied with it?

I played the patch more. It works as expected in random access case, but in
sequential case, it has regression against vanilla, maybe because I'm using a
two sockets machine. I explained the reason in below patch and changelog.

Below is an addon patch above Hugh's patch. We can apply Hugh's patch first and
then this one if it's ok, or just merge them to one patch. AKPM, what's your
suggestion?

Thanks,
Shaohua

Subject: mm/swap: improve swapin readahead heuristic

swapout always tries to find a cluster to do swap. The cluster is shared by all
processes (kswapds, direct page reclaim) who do swap. The result is swapout
adjacent memory could cause interleave access pattern to disk. We do aggressive
swapin in non-random access case to avoid skip swapin in interleave access
pattern.

This really isn't the fault of swapin, but before we improve swapout algorithm
(for example, give each CPU a swap cluster), aggressive swapin gives better
performance for sequential access.

With below patch, the heurisic becomes:
1. swapin max_pages pages for any hit
2. otherwise swapin last_readahead_pages*3/4 pages

Test is done at a two sockets machine (7G memory), so at least 3 tasks are
doing swapout (2 kswapd, and one direct page reclaim). sequential test is 1
thread accessing 14G memory, random test is 24 threads random accessing 14G
memory. Data is time.

		Rand		Seq
vanilla		5678		434
Hugh		2829		625
Hugh+belowpatch	2785		401

For both rand and seq access, below patch gets good performance. And even
slightly better than vanilla in seq. Not quite sure about the reason, but I'd
suspect this is because there are some daemons doing small random swap.

Signed-off-by: Shaohua Li <shli@fusionio.com>
Cc: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: Hugh Dickins <hughd@google.com>
Cc: Rik van Riel <riel@redhat.com>
Cc: Wu Fengguang <fengguang.wu@intel.com>
Cc: Minchan Kim <minchan@kernel.org>
---
 mm/swap_state.c |   31 ++++++++++++++++---------------
 1 file changed, 16 insertions(+), 15 deletions(-)

Index: linux/mm/swap_state.c
===================================================================
--- linux.orig/mm/swap_state.c	2012-11-19 09:08:58.171621096 +0800
+++ linux/mm/swap_state.c	2012-11-19 10:01:28.016023822 +0800
@@ -359,6 +359,7 @@ struct page *read_swap_cache_async(swp_e
 unsigned long swapin_nr_pages(unsigned long offset)
 {
 	static unsigned long prev_offset;
+	static atomic_t last_readahead_pages;
 	unsigned int pages, max_pages;
 
 	max_pages = 1 << ACCESS_ONCE(page_cluster);
@@ -366,29 +367,29 @@ unsigned long swapin_nr_pages(unsigned l
 		return 1;
 
 	/*
-	 * This heuristic has been found to work well on both sequential and
-	 * random loads, swapping to hard disk or to SSD: please don't ask
-	 * what the "+ 2" means, it just happens to work well, that's all.
+	 * swapout always tries to find a cluster to do swap. The cluster is
+	 * shared by all processes (kswapds, direct page reclaim) who do swap.
+	 * The result is swapout adjacent memory could cause interleave access
+	 * pattern to disk. We do aggressive swapin in non-random access case
+	 * to avoid skip swapin in interleave access pattern.
 	 */
-	pages = atomic_xchg(&swapin_readahead_hits, 0) + 2;
-	if (pages == 2) {
+	pages = atomic_xchg(&swapin_readahead_hits, 0);
+	if (!pages) {
 		/*
 		 * We can have no readahead hits to judge by: but must not get
 		 * stuck here forever, so check for an adjacent offset instead
 		 * (and don't even bother to check whether swap type is same).
 		 */
-		if (offset != prev_offset + 1 && offset != prev_offset - 1)
-			pages = 1;
+		if (offset != prev_offset + 1 && offset != prev_offset - 1) {
+			pages = atomic_read(&last_readahead_pages) * 3 / 4;
+			pages = max_t(unsigned int, pages, 1);
+		} else
+			pages = max_pages;
 		prev_offset = offset;
-	} else {
-		unsigned int roundup = 4;
-		while (roundup < pages)
-			roundup <<= 1;
-		pages = roundup;
-	}
-
-	if (pages > max_pages)
+	} else
 		pages = max_pages;
+
+	atomic_set(&last_readahead_pages, pages);
 	return pages;
 }
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
