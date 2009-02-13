Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id ED61C6B009D
	for <linux-mm@kvack.org>; Thu, 12 Feb 2009 19:16:51 -0500 (EST)
Received: by ti-out-0910.google.com with SMTP id u3so597094tia.8
        for <linux-mm@kvack.org>; Thu, 12 Feb 2009 16:16:50 -0800 (PST)
Date: Fri, 13 Feb 2009 09:16:15 +0900
From: MinChan Kim <minchan.kim@gmail.com>
Subject: [patch 2/2 v2] vmscan: clip swap_cluster_max in shrink_all_memory()
Message-Id: <20090213091615.28e6a689.minchan.kim@barrios-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, MinChan Kim <minchan.kim@gmail.com>, "Rafael J. Wysocki" <rjw@sisk.pl>, Nigel Cunningham <ncunningham-lkml@crca.org.au>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>


I just remaked this patch based on my first patch '[patch 1/2] shrink_all_memory(): use sc.nr_reclaimed' due to hunk.
Notice that original patch is written by Hannes. 
I just inserted reviewed-by of me and acked-by of Nigel and Rafael.

---
From: Johannes Weiner <hannes@cmpxchg.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, MinChan Kim <minchan.kim@gmail.com>, "Rafael J. Wysocki" <rjw@sisk.pl>, Nigel Cunningham <ncunningham-lkml@crca.org.au>, Rik van Riel <riel@redhat.com>
Subject: [patch 2/2] vmscan: clip swap_cluster_max in shrink_all_memory()
Date: Thu, 12 Feb 2009 12:36:11 +0100
User-Agent: quilt/0.47-1
shrink_inactive_list() scans in sc->swap_cluster_max chunks until it
hits the scan limit it was passed.

shrink_inactive_list()
{
	do {
		isolate_pages(swap_cluster_max)
		shrink_page_list()
	} while (nr_scanned < max_scan);
}

This assumes that swap_cluster_max is not bigger than the scan limit
because the latter is checked only after at least one iteration.

In shrink_all_memory() sc->swap_cluster_max is initialized to the
overall reclaim goal in the beginning but not decreased while reclaim
is making progress which leads to subsequent calls to
shrink_inactive_list() reclaiming way too much in the one iteration
that is done unconditionally.

Set sc->swap_cluster_max always to the proper goal before doing
  shrink_all_zones()
    shrink_list()
      shrink_inactive_list().

While the current shrink_all_memory() happily reclaims more than
actually requested, this patch fixes it to never exceed the goal:

unpatched
   wanted=10000 reclaimed=13356
   wanted=10000 reclaimed=19711
   wanted=10000 reclaimed=10289
   wanted=10000 reclaimed=17306
   wanted=10000 reclaimed=10700
   wanted=10000 reclaimed=10004
   wanted=10000 reclaimed=13301
   wanted=10000 reclaimed=10976
   wanted=10000 reclaimed=10605
   wanted=10000 reclaimed=10088
   wanted=10000 reclaimed=15000

patched
   wanted=10000 reclaimed=10000
   wanted=10000 reclaimed=9599
   wanted=10000 reclaimed=8476
   wanted=10000 reclaimed=8326
   wanted=10000 reclaimed=10000
   wanted=10000 reclaimed=10000
   wanted=10000 reclaimed=9919
   wanted=10000 reclaimed=10000
   wanted=10000 reclaimed=10000
   wanted=10000 reclaimed=10000
   wanted=10000 reclaimed=10000
   wanted=10000 reclaimed=9624
   wanted=10000 reclaimed=10000
   wanted=10000 reclaimed=10000
   wanted=8500 reclaimed=8092
   wanted=316 reclaimed=316


Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
Reviewed-by: MinChan Kim <minchan.kim@gmail.com>
Acked-by: Nigel Cunningham <ncunningham@crca.org.au>
Acked-by: "Rafael J. Wysocki" <rjw@sisk.pl>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Rik van Riel <riel@redhat.com>


---
 mm/vmscan.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 172e394..ed329c4 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -2114,7 +2114,6 @@ unsigned long shrink_all_memory(unsigned long nr_pages)
 	struct scan_control sc = {
 		.gfp_mask = GFP_KERNEL,
 		.may_unmap = 0,
-		.swap_cluster_max = nr_pages,
 		.may_writepage = 1,
 		.isolate_pages = isolate_pages_global,
 	};
@@ -2156,6 +2155,7 @@ unsigned long shrink_all_memory(unsigned long nr_pages)
 			unsigned long nr_to_scan = nr_pages - sc.nr_reclaimed;
 
 			sc.nr_scanned = 0;
+			sc.swap_cluster_max = nr_to_scan;
 			shrink_all_zones(nr_to_scan, prio, pass, &sc);
 			if (sc.nr_reclaimed >= nr_pages) 
 				goto out;
-- 
1.5.4.3



-- 
Kinds Regards
MinChan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
