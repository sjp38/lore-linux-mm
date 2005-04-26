From: Nikita Danilov <nikita@clusterfs.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Message-ID: <17005.63388.871003.456599@gargle.gargle.HOWL>
Date: Tue, 26 Apr 2005 12:11:08 +0400
Subject: Re: [PATCH]: VM 4/8 dont-rotate-active-list
In-Reply-To: <20050425205141.0b756263.akpm@osdl.org>
References: <16994.40620.892220.121182@gargle.gargle.HOWL>
	<20050425205141.0b756263.akpm@osdl.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Andrew Morton writes:

[...]

 > 
 > I'll plop this into -mm to see what happens.  That should give us decent
 > stability testing, but someone is going to have to do a ton of performance
 > testing to justify an upstream merge, please.

I decided to drop this patch locally, actually. The version you merged
doesn't behave as advertised: due to merge error l_active is not used in
refill_inactive_zone() at all. As a result all mapped pages are simply
parked behind scan page.

In my micro-benchmark workload (cyclical dirtying of mmaped file larger
than physical memory) this obviously helps, because reclaim_mapped state
is quickly reached and after that, mapped pages fall through to inactive
list independently of their referenced bits. But such behavior is hard
to justify in a general case.

Once I fixed the patch to take page_referenced() into account it stopped
making any improvement in mmap micro-benchmark. But hey, if it is
already in -mm let's test it, nobody understands how VM should work
anyway. :-)

Below is a fix for -mm version that places page place-holders for NUMA
nodes into separate cache lines. Suggested by Nick Piggin.

Nikita.

Reduce cache contention by placing scan pages into separate cache lines.

Signed-off-by: Nikita Danilov <nikita@clusterfs.com>

--- mm/page_alloc.c.orig	2005-04-26 11:54:47.000000000 +0400
+++ mm/page_alloc.c	2005-04-26 11:53:38.000000000 +0400
@@ -1619,7 +1619,9 @@ void zone_init_free_lists(struct pglist_
 #endif
 
 /* dummy pages used to scan active lists */
-static struct page scan_pages[MAX_NUMNODES][MAX_NR_ZONES];
+static struct node_scan_pages {
+	struct page page[MAX_NR_ZONES];
+} ____cacheline_aligned_in_smp scan_pages[MAX_NUMNODES];
 
 /*
  * Set up the zone data structures:
@@ -1705,7 +1707,7 @@ static void __init free_area_init_core(s
 		zone->nr_inactive = 0;
 
 		/* initialize dummy page used for scanning */
-		scan_page = &scan_pages[nid][j];
+		scan_page = &scan_pages[nid].page[j];
 		zone->scan_page = scan_page;
 		memset(scan_page, 0, sizeof *scan_page);
 		scan_page->flags =
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
