Date: Wed, 6 Feb 2008 19:35:12 -0500
From: Rik van Riel <riel@redhat.com>
Subject: Re: [patch 05/19] split LRU lists into anon & file sets
Message-ID: <20080206193512.77b5f21f@bree.surriel.com>
In-Reply-To: <20080130175439.1AFD.KOSAKI.MOTOHIRO@jp.fujitsu.com>
References: <20080108210002.638347207@redhat.com>
	<20080130121152.1AF1.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	<20080130175439.1AFD.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Lee Schermerhorn <Lee.Schermerhorn@hp.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, 30 Jan 2008 17:57:54 +0900
KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:

> I found number of scan pages calculation bug.

My latest version of get_scan_ratio() works differently, with the
percentages always adding up to 100.  However, your patch gave me
the inspiration to (hopefully) find the bug in my version of the
code.
 
> 1. wrong calculation order

I do not believe my new code has this problem.  Of course, this
is purely due to luck :)

> 2. wrong fraction omission
> 
> 	nr[l] = zone->nr_scan[l] * percent[file] / 100;
> 
> 	when percent is very small,
> 	nr[l] become 0.

This is probably where the problem is.  Kind of.

I believe that the problem is that we scale nr[l] by the percentage,
instead of scaling the amount we add to zone->nr_scan[l] by the
percentage!

> @@ -1409,7 +1410,11 @@ static unsigned long shrink_zone(int pri
>  			 */
>  			zone->nr_scan[l] += (zone_page_state(zone,
>  				NR_INACTIVE_ANON + l) >> priority) + 1;
> -			nr[l] = zone->nr_scan[l] * percent[file] / 100;
> +			nr[l] = (zone->nr_scan[l] * percent[file] / 100) + 1;
> +			nr_max_scan = zone_page_state(zone, NR_INACTIVE_ANON+l);
> +			if (nr[l] > nr_max_scan)
> +				nr[l] = nr_max_scan;
> +
>  			if (nr[l] >= sc->swap_cluster_max)
>  				zone->nr_scan[l] = 0;
>  			else

With the fix below (against my latest tree), we always add at least one
to zone->nr_scan[l] and always make that increment count later on!

I am still recovering from my trip home (thanks to the airline companies
I spent 25 hours travelling, from door to door), so I may not get around
to actually testing this today:

Index: linux-2.6.24-rc6-mm1/mm/vmscan.c
===================================================================
--- linux-2.6.24-rc6-mm1.orig/mm/vmscan.c	2008-02-06 19:23:16.000000000 -0500
+++ linux-2.6.24-rc6-mm1/mm/vmscan.c	2008-02-06 19:22:55.000000000 -0500
@@ -1275,13 +1275,17 @@ static unsigned long shrink_zone(int pri
 	for_each_lru(l) {
 		if (scan_global_lru(sc)) {
 			int file = is_file_lru(l);
+			int scan;
 			/*
 			 * Add one to nr_to_scan just to make sure that the
-			 * kernel will slowly sift through the active list.
+			 * kernel will slowly sift through each list.
 			 */
-			zone->nr_scan[l] += (zone_page_state(zone,
-				NR_INACTIVE_ANON + l) >> priority) + 1;
-			nr[l] = zone->nr_scan[l] * percent[file] / 100;
+			scan = zone_page_state(zone, NR_INACTIVE_ANON + l);
+			scan >>= priority;
+			scan = (scan * percent[file]) / 100;
+
+			zone->nr_scan[l] += scan + 1;
+			nr[l] = zone->nr_scan[l];
 			if (nr[l] >= sc->swap_cluster_max)
 				zone->nr_scan[l] = 0;
 			else

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
