Message-ID: <40CAA904.8080305@yahoo.com.au>
Date: Sat, 12 Jun 2004 16:56:04 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: Keeping mmap'ed files in core regression in 2.6.7-rc
References: <20040608142918.GA7311@traveler.cistron.net>
In-Reply-To: <20040608142918.GA7311@traveler.cistron.net>
Content-Type: multipart/mixed;
 boundary="------------070500000901040105060001"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Miquel van Smoorenburg <miquels@cistron.nl>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------070500000901040105060001
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Miquel van Smoorenburg wrote:

> Now I tried 2.6.7-rc2 and -rc3 (well rc2-bk-latest-before-rc3) and
> with those kernels, performance goes to hell because no matter
> how much I tune, the kernel will throw out the mmap'ed pages first.
> RSS of the innd process hovers around 200-250 MB instead of 600.
> 
> Ideas ?
> 

Can you try the following patch please?

--------------070500000901040105060001
Content-Type: text/x-patch;
 name="vm-revert-fix.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="vm-revert-fix.patch"

 linux-2.6-npiggin/mm/vmscan.c |    7 ++-----
 1 files changed, 2 insertions(+), 5 deletions(-)

diff -puN mm/vmscan.c~vm-revert-fix mm/vmscan.c
--- linux-2.6/mm/vmscan.c~vm-revert-fix	2004-06-12 16:53:02.000000000 +1000
+++ linux-2.6-npiggin/mm/vmscan.c	2004-06-12 16:54:26.000000000 +1000
@@ -813,9 +813,8 @@ shrink_caches(struct zone **zones, int p
 		struct zone *zone = zones[i];
 		int max_scan;
 
-		zone->temp_priority = priority;
-		if (zone->prev_priority > priority)
-			zone->prev_priority = priority;
+		if (zone->free_pages < zone->pages_high)
+			zone->temp_priority = priority;
 
 		if (zone->all_unreclaimable && priority != DEF_PRIORITY)
 			continue;	/* Let kswapd poll it */
@@ -996,8 +995,6 @@ scan:
 					all_zones_ok = 0;
 			}
 			zone->temp_priority = priority;
-			if (zone->prev_priority > priority)
-				zone->prev_priority = priority;
 			max_scan = (zone->nr_active + zone->nr_inactive)
 								>> priority;
 			reclaimed = shrink_zone(zone, max_scan, GFP_KERNEL,

_

--------------070500000901040105060001--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
