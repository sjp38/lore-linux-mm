Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id EDA266B01EE
	for <linux-mm@kvack.org>; Tue,  6 Apr 2010 07:16:43 -0400 (EDT)
Date: Tue, 6 Apr 2010 12:16:19 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 00 of 41] Transparent Hugepage Support #17
Message-ID: <20100406111619.GD17882@csn.ul.ie>
References: <patchbomb.1270168887@v2.random> <20100405120906.0abe8e58.akpm@linux-foundation.org> <20100405193616.GA5125@elte.hu> <n2j84144f021004051326mab7cd8fbm949115748a3d78b6@mail.gmail.com> <alpine.LFD.2.00.1004051326380.21411@i5.linux-foundation.org> <t2q84144f021004051346o65f03e71r5b7bb19b433ce454@mail.gmail.com> <alpine.LFD.2.00.1004051347480.21411@i5.linux-foundation.org> <20100405232115.GM5825@random.random> <20100406093021.GC17882@csn.ul.ie> <BAA2AB49-DE66-4F22-B0E2-296522C2AF3E@mit.edu>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <BAA2AB49-DE66-4F22-B0E2-296522C2AF3E@mit.edu>
Sender: owner-linux-mm@kvack.org
To: Theodore Tso <tytso@MIT.EDU>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, Marcelo Tosatti <mtosatti@redhat.com>, Adam Litke <agl@us.ibm.com>, Avi Kivity <avi@redhat.com>, Izik Eidus <ieidus@redhat.com>, Hugh Dickins <hugh.dickins@tiscali.co.uk>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Dave Hansen <dave@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Mike Travis <travis@sgi.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Christoph Lameter <cl@linux-foundation.org>, Chris Wright <chrisw@sous-sol.org>, bpicco@redhat.com, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Arnd Bergmann <arnd@arndb.de>, "Michael S. Tsirkin" <mst@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

On Tue, Apr 06, 2010 at 06:32:28AM -0400, Theodore Tso wrote:
> 
> On Apr 6, 2010, at 5:30 AM, Mel Gorman wrote:
> > 
> > There is a good chance you could allocate a decent percentage of
> > memory as huge pages but as you are unlikely to have run hugeadm
> > --set-recommended-min_free_kbytes early in boot, it is also likely to trash
> > heavily and the success rates will not be very impressive.
> 

> Can you explain how hugeadm --set-recommended-min_free_kbytes works and
> how it achieves this magic?  Or can you send me a pointer to how this works?
> I've tried doing some Google searches, and I found the LWN article "Huge
> pages part 3: administration", but it doesn't go into a lot of detail how
> increasing vm.min_free_kbytes helps the anti fragmentation code.

Sure, the details of how and why it works are spread all over the place.
It's fairly simple really and related to how anti-fragmentation does its work.

Anti-frag divides up a zone into "arenas" where an arena is usually the
default huge page size - 2M on x86-64, 16M on ppc64 etc. Its objective is to
keep UNMOVABLE, RECLAIMABLE and MOVABLE pages within the same arenas using
multiple free lists. If a page within the desired arena is not available, it
falls back to using one of the other arenas. A fallback is a "fragmentation
event" as traced by the mm_page_alloc_extfrag event. A severe event is if a
small page is used and a benign event is if a large page (e.g. 2M) is moved
to the desired list. It's benign because pages of the same "migrate type"
continue to be allocated within the same arena.

How often these "fragmentation events" occur depends on pages of the
desired type being always available. This in turn depends on free pages
being available which is easiest to control by min_free_kbytes and is where
--set-recommended-min_free_kbytes comes in. By keeping a number of pages free,
the probability of a page of the desired type being available increases.

As there are three migrate-types we currently care about from an anti-frag
perspective, the recommended min_free_kbytes value depends on the number of
zones in the system and having 3 arenas worth of pages are kept free per
zone. Once set, there will, in most cases, be a page free of the required
type at allocation time. It can be observed in practice by tracing
mm_page_alloc_extfrag.

The next part of min_free_kbytes is related to the "reserve" blocks which
are only important to high-order atomic allocations. There is a maximum of
two reserve blocks per zone. For example, on a flat-memory system with one
grouping of memory, there would be a maximum of two reserve arenas. On a
NUMA system with two nodes, there would be a maximum of four. With multiple
groupings of memory such as 32-bit X86 with DMA, Normal and Highmem groups of
free-lists, there might be five reserve pageblocks, two each for the Normal
and HighMem groupings and just one for DMA as it is only 16MB worth of pages.

The final part of the recommended min_free_kbytes value is a sum of the
reserve arenas and the migrate-type arenas to ensure that pages of the
required type are free.

The function that works this out in libhugetlbfs is

long recommended_minfreekbytes(void)
{
        FILE *f;
        char buf[ZONEINFO_LINEBUF];
        int nr_zones = 0;
        long recommended_min;
        long pageblock_kbytes = kernel_default_hugepage_size() / 1024;

        /* Detect the number of zones in the system */
        f = fopen(PROCZONEINFO, "r");
        if (f == NULL) {
                WARNING("Unable to open " PROCZONEINFO);
                return 0;
        }
        while (fgets(buf, ZONEINFO_LINEBUF, f) != NULL) {
                if (strncmp(buf, "Node ", 5) == 0)
                        nr_zones++;
        }
        fclose(f);

        /* Make sure at least 2 pageblocks are free for MIGRATE_RESERVE */
        recommended_min = pageblock_kbytes * nr_zones * 2;

        /*
         * Make sure that on average at least two pageblocks are almost free
         * of another type, one for a migratetype to fall back to and a
         * second to avoid subsequent fallbacks of other types There are 3
         * MIGRATE_TYPES we care about.
         */
        recommended_min += pageblock_kbytes * nr_zones * 3 * 3;
        return recommended_min;
}

Does this clarify why min_free_kbytes helps and why the "recommended"
value is what it is?

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
