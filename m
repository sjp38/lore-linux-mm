Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail7.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id mB8D3V3j031080
	for <linux-mm@kvack.org> (envelope-from kosaki.motohiro@jp.fujitsu.com);
	Mon, 8 Dec 2008 22:03:31 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 1774145DE59
	for <linux-mm@kvack.org>; Mon,  8 Dec 2008 22:03:31 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id E4A3645DE51
	for <linux-mm@kvack.org>; Mon,  8 Dec 2008 22:03:30 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id B9E081DB8043
	for <linux-mm@kvack.org>; Mon,  8 Dec 2008 22:03:30 +0900 (JST)
Received: from m108.s.css.fujitsu.com (m108.s.css.fujitsu.com [10.249.87.108])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 651E21DB803F
	for <linux-mm@kvack.org>; Mon,  8 Dec 2008 22:03:30 +0900 (JST)
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: Re: [PATCH] vmscan: skip freeing memory from zones with lots free
In-Reply-To: <20081208205842.53F8.KOSAKI.MOTOHIRO@jp.fujitsu.com>
References: <20081129195357.813D.KOSAKI.MOTOHIRO@jp.fujitsu.com> <20081208205842.53F8.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Message-Id: <20081208220016.53FB.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Date: Mon,  8 Dec 2008 22:03:29 +0900 (JST)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>
Cc: kosaki.motohiro@jp.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Peter Zijlstra <peterz@infradead.org>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Lameter <cl@linux-foundation.org>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

>               2.6.28-rc6
>             + evice streaming first          + skip freeing memory
>             + rvr bail out
>             + kosaki bail out improve
> 
> nr_group      125     130      135               125     130      135
> 	    ----------------------------------------------------------
> 	    67.302   68.269   77.161		89.450   75.328  173.437 
> 	    72.616   72.712   79.060 		69.843 	 74.145   76.217 
> 	    72.475   75.712   77.735 		73.531 	 76.426   85.527 
> 	    69.229   73.062   78.814 		72.472 	 74.891   75.129 
> 	    71.551   74.392   78.564 		69.423 	 73.517   75.544 
> 	    69.227   74.310   78.837 		72.543 	 75.347   79.237 
> 	    70.759   75.256   76.600 		70.477 	 77.848   90.981 
> 	    69.966   76.001   78.464 		71.792 	 78.722   92.048 
> 	    69.068   75.218   80.321 		71.313 	 74.958   78.113 
> 	    72.057   77.151   79.068 		72.306 	 75.644   79.888 
> 
> avg	    70.425   74.208   78.462 		73.315 	 75.683   90.612 
> std	     1.665    2.348    1.007  	 	 5.516 	  1.514   28.218 
> min	    67.302   68.269   76.600 		69.423 	 73.517   75.129 
> max	    72.616   77.151   80.321 		89.450 	 78.722  173.437 
> 
> 
> 	-> 1 - 10% slow down
> 	   because zone_watermark_ok() is a bit slow function.
> 

Next, I'd like to talk about why I think the reason is zone_watermark_ok().

I have zone_watermark_ok() improvement patch.
following patch developed for another issue.

However I observed it solve rvr patch performance degression.


<with following patch>

              2.6.28-rc6
            + evice streaming first          + skip freeing memory
            + rvr bail out		     + this patch
            + kosaki bail out improve

nr_group      125     130      135               125     130      135
	    ----------------------------------------------------------
	    67.302   68.269   77.161  		68.534 	75.733 	79.416 
	    72.616   72.712   79.060  		70.868 	74.264 	76.858 
	    72.475   75.712   77.735  		73.215 	80.278 	81.033 
	    69.229   73.062   78.814  		70.780 	72.518 	75.764 
	    71.551   74.392   78.564  		69.631 	77.252 	77.131 
	    69.227   74.310   78.837  		72.325 	72.723 	79.274 
	    70.759   75.256   76.600  		70.328 	74.046 	75.783 
	    69.966   76.001   78.464  		69.014 	72.566 	77.236 
	    69.068   75.218   80.321  		68.373 	76.447 	76.015 
	    72.057   77.151   79.068  		74.403 	72.794 	75.872 
                                      		
avg	    70.425   74.208   78.462  		70.747 	74.862 	77.438 
std	     1.665    2.348    1.007  		 1.921 	 2.428 	 1.752 
min	    67.302   68.269   76.600  		68.373 	72.518 	75.764 
max	    72.616   77.151   80.321  		74.403 	80.278 	81.033 


	-> ok, performance degression disappeared.



===========================
Subject: [PATCH] mm: zone_watermark_ok() doesn't require small fragment block


Currently, zone_watermark_ok() has a bit unfair logic.

example, 

  Called zone_watermark_ok(zone, 2, pages_min, 0, 0);
  pages_min  = 64
  free pages = 80

case A.

     order    nr_pages
   --------------------
      2         5
      1        10
      0        30

	-> zone_watermark_ok() return 1

case B.

     order    nr_pages
   --------------------
      3        10 
      2         0
      1         0
      0         0

        -> zone_watermark_ok() return 0


IOW, current zone_watermark_ok() tend to prefer small fragment block.

If dividing large block to small block by buddy is slow, abeve logic is reasonable.
However its assumption is not formed at all. linux buddy can treat large block efficiently.


In the order aspect, zone_watermark_ok() is called from get_page_from_freelist() everytime.
The get_page_from_freelist() is one of king of fast path.
In general, fast path require to
  - if system has much memory, it work as fast as possible.
  - if system doesn't have enough memory, it doesn't need to fast processing.
    but need to avoid oom as far as possible.

Unfortunately, following loop has reverse performance tendency.

        for (o = 0; o < order; o++) {
                free_pages -= z->free_area[o].nr_free << o;
                min >>= 1;
                if (free_pages <= min)
                        return 0;
        }

If the system doesn't have enough memory, above loop bail out soon.
But the system have enough memory, this loop work just number of order times.


This patch change zone_watermark_ok() logic to prefer large contenious block.


Result:

  test machine:
    CPU: ia64 x 8
    MEM: 8GB

  benchmark: 
    $ tbench 8  (three times mesurement)

    tbench works between about 600sec.
    alloc_pages() and zone_watermark_ok() are called about 15,000,000 times.


              2.6.28-rc6                        this patch

       throughput    max-latency       throughput       max-latency
        ---------------------------------------------------------
        1480.92		20.896		1,490.27	19.606 
	1483.94		19.202		1,482.86 	21.082 
	1478.93		22.215		1,490.57 	23.493 

avg	1,481.26 	20.771  	1,487.90 	21.394 
std	    2.06 	 1.233		    3.56	 1.602 
min	1,478.93 	19.202  	1,477.86 	19.606
max	1,483.94 	22.215  	1,490.57 	23.493 


throughput improve about 5MB/sec. it over measurement wobbly.


Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
CC: Nick Piggin <npiggin@suse.de>
CC: Christoph Lameter <cl@linux-foundation.org>
---
 mm/page_alloc.c |   16 ++++++----------
 1 file changed, 6 insertions(+), 10 deletions(-)

Index: b/mm/page_alloc.c
===================================================================
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -1227,7 +1227,7 @@ static inline int should_fail_alloc_page
 int zone_watermark_ok(struct zone *z, int order, unsigned long mark,
 		      int classzone_idx, int alloc_flags)
 {
-	/* free_pages my go negative - that's OK */
+	/* free_pages may go negative - that's OK */
 	long min = mark;
 	long free_pages = zone_page_state(z, NR_FREE_PAGES) - (1 << order) + 1;
 	int o;
@@ -1239,17 +1239,13 @@ int zone_watermark_ok(struct zone *z, in
 
 	if (free_pages <= min + z->lowmem_reserve[classzone_idx])
 		return 0;
-	for (o = 0; o < order; o++) {
-		/* At the next order, this order's pages become unavailable */
-		free_pages -= z->free_area[o].nr_free << o;
 
-		/* Require fewer higher order pages to be free */
-		min >>= 1;
-
-		if (free_pages <= min)
-			return 0;
+	for (o = order; o < MAX_ORDER; o++) {
+		if (z->free_area[o].nr_free)
+			return 1;
 	}
-	return 1;
+
+	return 0;
 }
 
 #ifdef CONFIG_NUMA



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
