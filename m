Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 73B77900137
	for <linux-mm@kvack.org>; Fri, 12 Aug 2011 02:59:31 -0400 (EDT)
Date: Fri, 12 Aug 2011 08:58:58 +0200
From: Johannes Weiner <jweiner@redhat.com>
Subject: Re: [patch 2/2] mm: vmscan: drop nr_force_scan[] from get_scan_count
Message-ID: <20110812065858.GA6916@redhat.com>
References: <1313094715-31187-1-git-send-email-jweiner@redhat.com>
 <1313094715-31187-2-git-send-email-jweiner@redhat.com>
 <CAEwNFnBp7JBWpuaT=ZKDyfQTQqOe_mT0CLFAw9LWo10GoXaFnQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CAEwNFnBp7JBWpuaT=ZKDyfQTQqOe_mT0CLFAw9LWo10GoXaFnQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Ying Han <yinghan@google.com>, Balbir Singh <bsingharora@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Mel Gorman <mel@csn.ul.ie>

On Fri, Aug 12, 2011 at 08:44:34AM +0900, Minchan Kim wrote:
> On Fri, Aug 12, 2011 at 5:31 AM, Johannes Weiner <jweiner@redhat.com> wrote:
> > The nr_force_scan[] tuple holds the effective scan numbers for anon
> > and file pages in case the situation called for a forced scan and the
> > regularly calculated scan numbers turned out zero.
> >
> > However, the effective scan number can always be assumed to be
> > SWAP_CLUSTER_MAX right before the division into anon and file.  The
> > numerators and denominator are properly set up for all cases, be it
> > force scan for just file, just anon, or both, to do the right thing.
> >
> > Signed-off-by: Johannes Weiner <jweiner@redhat.com>
> 
> Reviewed-by: Minchan Kim <minchan.kim@gmail.com>

Thanks.

> There is a nitpick at below.

> > @@ -1927,20 +1917,10 @@ out:
> >                scan = zone_nr_lru_pages(zone, sc, l);
> >                if (priority || noswap) {
> >                        scan >>= priority;
> > +                       if (!scan && force_scan)
> > +                               scan = SWAP_CLUSTER_MAX;
> >                        scan = div64_u64(scan * fraction[file], denominator);
> >                }
> > -
> > -               /*
> > -                * If zone is small or memcg is small, nr[l] can be 0.
> > -                * This results no-scan on this priority and priority drop down.
> > -                * For global direct reclaim, it can visit next zone and tend
> > -                * not to have problems. For global kswapd, it's for zone
> > -                * balancing and it need to scan a small amounts. When using
> > -                * memcg, priority drop can cause big latency. So, it's better
> > -                * to scan small amount. See may_noscan above.
> > -                */
> 
> Please move this comment with tidy-up at where making force_scan true.
> Of course, we can find it by git log[246e87a9393] but as I looked the
> git log, it explain this comment indirectly and it's not
> understandable to newbies. I think this comment is more understandable
> than changelog in git.

I guess you are right, I am a bit overeager when deleting comments.
How is this?

---
From: Johannes Weiner <jweiner@redhat.com>
Subject: [patch] mm: vmscan: drop nr_force_scan[] from get_scan_count

The nr_force_scan[] tuple holds the effective scan numbers for anon
and file pages in case the situation called for a forced scan and the
regularly calculated scan numbers turned out zero.

However, the effective scan number can always be assumed to be
SWAP_CLUSTER_MAX right before the division into anon and file.  The
numerators and denominator are properly set up for all cases, be it
force scan for just file, just anon, or both, to do the right thing.

Signed-off-by: Johannes Weiner <jweiner@redhat.com>
Cc: Minchan Kim <minchan.kim@gmail.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Michal Hocko <mhocko@suse.cz>
Cc: Ying Han <yinghan@google.com>
Cc: Balbir Singh <bsingharora@gmail.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Cc: Mel Gorman <mel@csn.ul.ie>
---
 mm/vmscan.c |   36 ++++++++++++------------------------
 1 files changed, 12 insertions(+), 24 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 96061d7..a6ca076 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1831,12 +1831,19 @@ static void get_scan_count(struct zone *zone, struct scan_control *sc,
 	enum lru_list l;
 	int noswap = 0;
 	bool force_scan = false;
-	unsigned long nr_force_scan[2];
 
-	/* kswapd does zone balancing and need to scan this zone */
+	/*
+	 * If the zone or memcg is small, nr[l] can be 0.  This
+	 * results in no scanning on this priority and a potential
+	 * priority drop.  Global direct reclaim can go to the next
+	 * zone and tends to have no problems. Global kswapd is for
+	 * zone balancing and it needs to scan a minimum amount. When
+	 * reclaiming for a memcg, a priority drop can cause high
+	 * latencies, so it's better to scan a minimum amount there as
+	 * well.
+	 */
 	if (scanning_global_lru(sc) && current_is_kswapd())
 		force_scan = true;
-	/* memcg may have small limit and need to avoid priority drop */
 	if (!scanning_global_lru(sc))
 		force_scan = true;
 
@@ -1846,8 +1853,6 @@ static void get_scan_count(struct zone *zone, struct scan_control *sc,
 		fraction[0] = 0;
 		fraction[1] = 1;
 		denominator = 1;
-		nr_force_scan[0] = 0;
-		nr_force_scan[1] = SWAP_CLUSTER_MAX;
 		goto out;
 	}
 
@@ -1864,8 +1869,6 @@ static void get_scan_count(struct zone *zone, struct scan_control *sc,
 			fraction[0] = 1;
 			fraction[1] = 0;
 			denominator = 1;
-			nr_force_scan[0] = SWAP_CLUSTER_MAX;
-			nr_force_scan[1] = 0;
 			goto out;
 		}
 	}
@@ -1914,11 +1917,6 @@ static void get_scan_count(struct zone *zone, struct scan_control *sc,
 	fraction[0] = ap;
 	fraction[1] = fp;
 	denominator = ap + fp + 1;
-	if (force_scan) {
-		unsigned long scan = SWAP_CLUSTER_MAX;
-		nr_force_scan[0] = div64_u64(scan * ap, denominator);
-		nr_force_scan[1] = div64_u64(scan * fp, denominator);
-	}
 out:
 	for_each_evictable_lru(l) {
 		int file = is_file_lru(l);
@@ -1927,20 +1925,10 @@ out:
 		scan = zone_nr_lru_pages(zone, sc, l);
 		if (priority || noswap) {
 			scan >>= priority;
+			if (!scan && force_scan)
+				scan = SWAP_CLUSTER_MAX;
 			scan = div64_u64(scan * fraction[file], denominator);
 		}
-
-		/*
-		 * If zone is small or memcg is small, nr[l] can be 0.
-		 * This results no-scan on this priority and priority drop down.
-		 * For global direct reclaim, it can visit next zone and tend
-		 * not to have problems. For global kswapd, it's for zone
-		 * balancing and it need to scan a small amounts. When using
-		 * memcg, priority drop can cause big latency. So, it's better
-		 * to scan small amount. See may_noscan above.
-		 */
-		if (!scan && force_scan)
-			scan = nr_force_scan[file];
 		nr[l] = scan;
 	}
 }
-- 
1.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
