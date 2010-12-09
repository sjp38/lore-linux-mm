Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id CC1436B0087
	for <linux-mm@kvack.org>; Thu,  9 Dec 2010 13:48:39 -0500 (EST)
Date: Thu, 9 Dec 2010 19:47:42 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 51 of 66] set recommended min free kbytes
Message-ID: <20101209184742.GH19131@random.random>
References: <patchbomb.1288798055@v2.random>
 <e4c3f336872db7bfbf58.1288798106@v2.random>
 <20101118161623.GB8135@csn.ul.ie>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20101118161623.GB8135@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-mm@kvack.org, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Ingo Molnar <mingo@elte.hu>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Chris Mason <chris.mason@oracle.com>, Borislav Petkov <bp@alien8.de>
List-ID: <linux-mm.kvack.org>

On Thu, Nov 18, 2010 at 04:16:24PM +0000, Mel Gorman wrote:
> > +	/* Make sure at least 2 hugepages are free for MIGRATE_RESERVE */
> > +	recommended_min = HPAGE_PMD_NR * nr_zones * 2;
> > +
> 
> The really important value is pageblock_nr_pages here. It'll just happen
> to work on x86 and x86-64 but anti-fragmentation is really about
> pageblocks, not PMDs.
> 
> > +	/*
> > +	 * Make sure that on average at least two pageblocks are almost free
> > +	 * of another type, one for a migratetype to fall back to and a
> > +	 * second to avoid subsequent fallbacks of other types There are 3
> > +	 * MIGRATE_TYPES we care about.
> > +	 */
> > +	recommended_min += HPAGE_PMD_NR * nr_zones * 3 * 3;
> > +
> 
> Same on the use of pageblock_nr_pages. Also, you can replace 3 with
> MIGRATE_PCPTYPES.
> 
> > +	/* don't ever allow to reserve more than 5% of the lowmem */
> > +	recommended_min = min(recommended_min,
> > +			      (unsigned long) nr_free_buffer_pages() / 20);
> > +	recommended_min <<= (PAGE_SHIFT-10);
> > +
> > +	if (recommended_min > min_free_kbytes) {
> > +		min_free_kbytes = recommended_min;
> > +		setup_per_zone_wmarks();
> > +	}
> 
> 
> The timing this is called is important. Would you mind doing a quick
> debugging check by adding a printk to setup_zone_migrate_reserve() to ensure
> MIGRATE_RESERVE is getting set on sensible pageblocks? (see where the comment
> Suitable for reserving if this block is movable is) If MIGRATE_RESERVE blocks
> are not being created in a sensible fashion, atomic high-order allocations
> will suffer in mysterious ways.
> 
> SEtting the higher min free kbytes from userspace happens to work because
> the system is initialised and MIGRATE_MOVABLE exists but that might not be
> the case when automatically set like this patch.

When min_free_kbytes doesn't need to be increased (like huge system
with lots of ram) setup_per_zone_wmarks wasn't called in the
late_initcall where this code runs, and the original
setup_per_zone_wmarks apparently wasn't calling
setup_zone_migrate_reserve (how can it be?).

Anyway now I patched it like this and it seems to work properly with
the unconditional setup_per_zone_wmarks in
late_initcall(set_recommended_min_free_kbytes).

diff --git a/mm/huge_memory.c b/mm/huge_memory.c
--- a/mm/huge_memory.c
+++ b/mm/huge_memory.c
@@ -103,7 +103,7 @@ static int set_recommended_min_free_kbyt
 		nr_zones++;
 
 	/* Make sure at least 2 hugepages are free for MIGRATE_RESERVE */
-	recommended_min = HPAGE_PMD_NR * nr_zones * 2;
+	recommended_min = pageblock_nr_pages * nr_zones * 2;
 
 	/*
 	 * Make sure that on average at least two pageblocks are almost free
@@ -111,17 +111,17 @@ static int set_recommended_min_free_kbyt
 	 * second to avoid subsequent fallbacks of other types There are 3
 	 * MIGRATE_TYPES we care about.
 	 */
-	recommended_min += HPAGE_PMD_NR * nr_zones * 3 * 3;
+	recommended_min += pageblock_nr_pages * nr_zones *
+			   MIGRATE_PCPTYPES * MIGRATE_PCPTYPES;
 
 	/* don't ever allow to reserve more than 5% of the lowmem */
 	recommended_min = min(recommended_min,
 			      (unsigned long) nr_free_buffer_pages() / 20);
 	recommended_min <<= (PAGE_SHIFT-10);
 
-	if (recommended_min > min_free_kbytes) {
+	if (recommended_min > min_free_kbytes)
 		min_free_kbytes = recommended_min;
-		setup_per_zone_wmarks();
-	}
+	setup_per_zone_wmarks();
 	return 0;
 }
 late_initcall(set_recommended_min_free_kbytes);
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -3188,6 +3188,7 @@ static void setup_zone_migrate_reserve(s
 	 */
 	reserve = min(2, reserve);
 
+	printk("reserve start %d\n", reserve);
 	for (pfn = start_pfn; pfn < end_pfn; pfn += pageblock_nr_pages) {
 		if (!pfn_valid(pfn))
 			continue;
@@ -3226,6 +3227,7 @@ static void setup_zone_migrate_reserve(s
 			move_freepages_block(zone, page, MIGRATE_MOVABLE);
 		}
 	}
+	printk("reserve end %d\n", reserve);
 }
 
 /*



hugeadm with CONFIG_TRANSPARENT_HUGEPAGE=n leads to:

reserve start 1
reserve end 0
reserve start 2
reserve end 0
reserve start 2
reserve end 0
reserve start 0
reserve end 0
reserve start 0
reserve end 0
reserve start 0
reserve end 0
reserve start 2
reserve end 0
reserve start 0
reserve end 0

With CONFIG_TRANSPARENT_HUGEPAGE=Y I boot I see:

reserve start 1
reserve end 0
reserve start 2
reserve end 0
reserve start 2
reserve end 0
reserve start 0
reserve end 0
reserve start 0
reserve end 0
reserve start 0
reserve end 0
reserve start 2
reserve end 0
reserve start 0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
