Message-ID: <400F738A.40505@cyberone.com.au>
Date: Thu, 22 Jan 2004 17:54:02 +1100
From: Nick Piggin <piggin@cyberone.com.au>
MIME-Version: 1.0
Subject: Re: [BENCHMARKS] Namesys VM patches improve kbuild
References: <400F630F.80205@cyberone.com.au> <20040121223608.1ea30097.akpm@osdl.org>
In-Reply-To: <20040121223608.1ea30097.akpm@osdl.org>
Content-Type: multipart/mixed;
 boundary="------------040507030701090601050801"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-mm@kvack.org, Nikita@Namesys.COM
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------040507030701090601050801
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit



Andrew Morton wrote:

>Nick Piggin <piggin@cyberone.com.au> wrote:
>
>>Hi,
>>
>>The two namesys patches help kbuild quite a lot here.
>>http://www.kerneltrap.org/~npiggin/vm/1/
>>
>>The patches can be found at
>>http://thebsh.namesys.com/snapshots/LATEST/extra/
>>
>
>I played with these back in July.  Had a few stability problems then but
>yes, they did speed up some workloads a lot.
>
>
>
>>I don't have much to comment on the patches. They do include
>>some cleanup stuff which should be broken out.
>>
>
>Yup.  <dig, dig>  See below - it's six months old though.
>
>
>>I don't really understand the dont-rotate-active-list patch:
>>I don't see why we're losing LRU information because the pages
>>that go to the head of the active list get their referenced
>>bits cleared.
>>
>
>Yes, I do think that the "LRU" is a bit of a misnomer - it's very
>approximate and only really suits simple workloads.  I suspect that once
>things get hot and heavy the "lru" is only four-deep:
>unreferenced/inactive, referenced/inactive, unreferenced/active and
>referenced/active.
>

Yep that was my thinking.

>
>Can you test the patches separately, see what bits are actually helping?
>


OK, I'll see how the second chance one alone does. By the way, what
do you think of this? Did I miss something non obvious?

Seems to make little difference on the benchmarks. Without the patch,
the active list would generally be attacked more aggressively.


--------------040507030701090601050801
Content-Type: text/plain;
 name="vm-fix-shrink-zone.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="vm-fix-shrink-zone.patch"


Use the actual number of pages difference when trying to keep the inactive
list 1/2 the size of the active list (1/3 the size of all pages) instead of
a meaningless ratio.


 linux-2.6-npiggin/mm/vmscan.c |   37 +++++++++++++++++++------------------
 1 files changed, 19 insertions(+), 18 deletions(-)

diff -puN mm/vmscan.c~vm-fix-shrink-zone mm/vmscan.c
--- linux-2.6/mm/vmscan.c~vm-fix-shrink-zone	2004-01-22 14:47:25.000000000 +1100
+++ linux-2.6-npiggin/mm/vmscan.c	2004-01-22 16:25:04.000000000 +1100
@@ -745,38 +745,39 @@ static int
 shrink_zone(struct zone *zone, int max_scan, unsigned int gfp_mask,
 	const int nr_pages, int *nr_mapped, struct page_state *ps, int priority)
 {
-	unsigned long ratio;
+	unsigned long imbalance;
+	unsigned long nr_refill_inact;
 
 	/*
 	 * Try to keep the active list 2/3 of the size of the cache.  And
 	 * make sure that refill_inactive is given a decent number of pages.
 	 *
-	 * The "ratio+1" here is important.  With pagecache-intensive workloads
-	 * the inactive list is huge, and `ratio' evaluates to zero all the
-	 * time.  Which pins the active list memory.  So we add one to `ratio'
-	 * just to make sure that the kernel will slowly sift through the
-	 * active list.
+	 * Keeping imbalance > 0 is important.  With pagecache-intensive loads
+	 * the inactive list is huge, and imbalance evaluates to zero all the
+	 * time which would pin the active list memory.
 	 */
-	ratio = (unsigned long)nr_pages * zone->nr_active /
-				((zone->nr_inactive | 1) * 2);
-	atomic_add(ratio+1, &zone->refill_counter);
-	if (atomic_read(&zone->refill_counter) > SWAP_CLUSTER_MAX) {
-		int count;
-
+	imbalance = zone->nr_active - (zone->nr_inactive*2);
+	if (imbalance <= 0)
+		imbalance = 1;
+	else {
 		/*
 		 * Don't try to bring down too many pages in one attempt.
 		 * If this fails, the caller will increase `priority' and
 		 * we'll try again, with an increased chance of reclaiming
 		 * mapped memory.
 		 */
-		count = atomic_read(&zone->refill_counter);
-		if (count > SWAP_CLUSTER_MAX * 4)
-			count = SWAP_CLUSTER_MAX * 4;
+
+		imbalance >>= priority;
+	}
+
+	atomic_add(imbalance, &zone->refill_counter);
+	nr_refill_inact = atomic_read(&zone->refill_counter);
+	if (nr_refill_inact > SWAP_CLUSTER_MAX) {
 		atomic_set(&zone->refill_counter, 0);
-		refill_inactive_zone(zone, count, ps, priority);
+		refill_inactive_zone(zone, nr_refill_inact, ps, priority);
 	}
-	return shrink_cache(nr_pages, zone, gfp_mask,
-				max_scan, nr_mapped);
+
+	return shrink_cache(nr_pages, zone, gfp_mask, max_scan, nr_mapped);
 }
 
 /*

_

--------------040507030701090601050801--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
