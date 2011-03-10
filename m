Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 83DBC8D003A
	for <linux-mm@kvack.org>; Thu, 10 Mar 2011 19:05:00 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 5744D3EE0BD
	for <linux-mm@kvack.org>; Fri, 11 Mar 2011 09:04:57 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 393E645DE6A
	for <linux-mm@kvack.org>; Fri, 11 Mar 2011 09:04:57 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 120F345DE67
	for <linux-mm@kvack.org>; Fri, 11 Mar 2011 09:04:57 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 028661DB803F
	for <linux-mm@kvack.org>; Fri, 11 Mar 2011 09:04:57 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id AC54AE08003
	for <linux-mm@kvack.org>; Fri, 11 Mar 2011 09:04:56 +0900 (JST)
Date: Fri, 11 Mar 2011 08:58:33 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH] mm: check zone->all_unreclaimable in
 all_unreclaimable()
Message-Id: <20110311085833.874c6c0e.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <AANLkTi=q=YMrT7Uta+wGm47VZ5N6meybAQTgjKGsDWFw@mail.gmail.com>
References: <1299325456-2687-1-git-send-email-avagin@openvz.org>
	<20110305152056.GA1918@barrios-desktop>
	<4D72580D.4000208@gmail.com>
	<20110305155316.GB1918@barrios-desktop>
	<4D7267B6.6020406@gmail.com>
	<20110305170759.GC1918@barrios-desktop>
	<20110307135831.9e0d7eaa.akpm@linux-foundation.org>
	<AANLkTinDhorLusBju=Gn3bh1VsH1jrv0qixbU3SGWiqa@mail.gmail.com>
	<20110309143704.194e8ee1.kamezawa.hiroyu@jp.fujitsu.com>
	<AANLkTi=q=YMrT7Uta+wGm47VZ5N6meybAQTgjKGsDWFw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrew Vagin <avagin@gmail.com>, Andrey Vagin <avagin@openvz.org>, Mel Gorman <mel@csn.ul.ie>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, 10 Mar 2011 15:58:29 +0900
Minchan Kim <minchan.kim@gmail.com> wrote:

> Hi Kame,
> 
> Sorry for late response.
> I had a time to test this issue shortly because these day I am very busy.
> This issue was interesting to me.
> So I hope taking a time for enough testing when I have a time.
> I should find out root cause of livelock.
> 

Thanks. I and Kosaki-san reproduced the bug with swapless system.
Now, Kosaki-san is digging and found some issue with scheduler boost at OOM
and lack of enough "wait" in vmscan.c.

I myself made patch like attached one. This works well for returning TRUE at
all_unreclaimable() but livelock(deadlock?) still happens.
I wonder vmscan itself isn't a key for fixing issue.
Then, I'd like to wait for Kosaki-san's answer ;)

I'm now wondering how to catch fork-bomb and stop it (without using cgroup). 
I think the problem is that fork-bomb is faster than killall...

Thanks,
-Kame
==

This is just a debug patch.

---
 mm/vmscan.c |   58 ++++++++++++++++++++++++++++++++++++++++++++++++++++++----
 1 file changed, 54 insertions(+), 4 deletions(-)

Index: mmotm-0303/mm/vmscan.c
===================================================================
--- mmotm-0303.orig/mm/vmscan.c
+++ mmotm-0303/mm/vmscan.c
@@ -1983,9 +1983,55 @@ static void shrink_zones(int priority, s
 	}
 }
 
-static bool zone_reclaimable(struct zone *zone)
+static bool zone_seems_empty(struct zone *zone, struct scan_control *sc)
 {
-	return zone->pages_scanned < zone_reclaimable_pages(zone) * 6;
+	unsigned long nr, wmark, free, isolated, lru;
+
+	/*
+	 * If scanned, zone->pages_scanned is incremented and this can
+ 	 * trigger OOM.
+ 	 */
+	if (sc->nr_scanned)
+		return false;
+
+	free = zone_page_state(zone, NR_FREE_PAGES);
+	isolated = zone_page_state(zone, NR_ISOLATED_FILE);
+	if (nr_swap_pages)
+		isolated += zone_page_state(zone, NR_ISOLATED_ANON);
+
+	/* In we cannot do scan, don't count LRU pages. */
+	if (!zone->all_unreclaimable) {
+		lru = zone_page_state(zone, NR_ACTIVE_FILE);
+		lru += zone_page_state(zone, NR_INACTIVE_FILE);
+		if (nr_swap_pages) {
+			lru += zone_page_state(zone, NR_ACTIVE_ANON);
+			lru += zone_page_state(zone, NR_INACTIVE_ANON);
+		}
+	} else
+		lru = 0;
+	nr = free + isolated + lru;
+	wmark = min_wmark_pages(zone);
+	wmark += zone->lowmem_reserve[gfp_zone(sc->gfp_mask)];
+	wmark += 1 << sc->order;
+	printk("thread %d/%ld all %d scanned %ld pages %ld/%ld/%ld/%ld/%ld/%ld\n",
+		current->pid, sc->nr_scanned, zone->all_unreclaimable,
+		zone->pages_scanned,
+		nr,free,isolated,lru,
+		zone_reclaimable_pages(zone), wmark);
+	/*
+	 * In some case (especially noswap), almost all page cache are paged out
+	 * and we'll see the amount of reclaimable+free pages is smaller than
+	 * zone->min. In this case, we canoot expect any recovery other
+	 * than OOM-KILL. We can't reclaim memory enough for usual tasks.
+	 */
+
+	return nr <= wmark;
+}
+
+static bool zone_reclaimable(struct zone *zone, struct scan_control *sc)
+{
+	/* zone_reclaimable_pages() can return 0, we need <= */
+	return zone->pages_scanned <= zone_reclaimable_pages(zone) * 6;
 }
 
 /*
@@ -2006,11 +2052,15 @@ static bool all_unreclaimable(struct zon
 			continue;
 		if (!cpuset_zone_allowed_hardwall(zone, GFP_KERNEL))
 			continue;
-		if (zone_reclaimable(zone)) {
+		if (zone_seems_empty(zone, sc))
+			continue;
+		if (zone_reclaimable(zone, sc)) {
 			all_unreclaimable = false;
 			break;
 		}
 	}
+	if (all_unreclaimable)
+		printk("all_unreclaimable() returns TRUE\n");
 
 	return all_unreclaimable;
 }
@@ -2456,7 +2506,7 @@ loop_again:
 			if (zone->all_unreclaimable)
 				continue;
 			if (!compaction && nr_slab == 0 &&
-			    !zone_reclaimable(zone))
+			    !zone_reclaimable(zone, &sc))
 				zone->all_unreclaimable = 1;
 			/*
 			 * If we've done a decent amount of scanning and

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
