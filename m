Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx141.postini.com [74.125.245.141])
	by kanga.kvack.org (Postfix) with SMTP id 485616B0068
	for <linux-mm@kvack.org>; Tue, 29 May 2012 09:51:05 -0400 (EDT)
Date: Tue, 29 May 2012 15:51:01 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [RFC -mm] memcg: prevent from OOM with too many dirty pages
Message-ID: <20120529135101.GD15293@tiehlicka.suse.cz>
References: <1338219535-7874-1-git-send-email-mhocko@suse.cz>
 <20120529030857.GA7762@localhost>
 <20120529072853.GD1734@cmpxchg.org>
 <20120529084848.GC10469@localhost>
 <20120529093511.GE1734@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120529093511.GE1734@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Fengguang Wu <fengguang.wu@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujtisu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Ying Han <yinghan@google.com>, Greg Thelen <gthelen@google.com>, Hugh Dickins <hughd@google.com>

On Tue 29-05-12 11:35:11, Johannes Weiner wrote:
[...]
>         if (nr_writeback && nr_writeback >= (nr_taken >> (DEF_PRIORITY-priority)))
>                 wait_iff_congested(zone, BLK_RW_ASYNC, HZ/10);
> 
> But the problem is the part declaring the zone congested:
> 
>         /*
>          * Tag a zone as congested if all the dirty pages encountered were
>          * backed by a congested BDI. In this case, reclaimers should just
>          * back off and wait for congestion to clear because further reclaim
>          * will encounter the same problem
>          */
>         if (nr_dirty && nr_dirty == nr_congested && global_reclaim(sc))
>                 zone_set_flag(mz->zone, ZONE_CONGESTED);
> 
> Note the global_reclaim().  It would be nice to have these two operate
> against the lruvec of sc->target_mem_cgroup and mz->zone instead.  The
> problem is that ZONE_CONGESTED clearing happens in kswapd alone, which
> is not necessarily involved in a memcg-constrained load, so we need to
> find clearing sites that work for both global and memcg reclaim.

OK, I have tried it with a simpler approach:
diff --git a/mm/vmscan.c b/mm/vmscan.c
index c978ce4..e45cf2a 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1294,8 +1294,12 @@ shrink_inactive_list(unsigned long nr_to_scan, struct lruvec *lruvec,
 	 *                     isolated page is PageWriteback
 	 */
 	if (nr_writeback && nr_writeback >=
-			(nr_taken >> (DEF_PRIORITY - sc->priority)))
-		wait_iff_congested(zone, BLK_RW_ASYNC, HZ/10);
+			(nr_taken >> (DEF_PRIORITY - sc->priority))) {
+		if (global_reclaim(sc))
+			wait_iff_congested(zone, BLK_RW_ASYNC, HZ/10);
+		else
+			congestion_wait(BLK_RW_ASYNC, HZ/10);
+	}
 
 	trace_mm_vmscan_lru_shrink_inactive(zone->zone_pgdat->node_id,
 		zone_idx(zone),

without 'lruvec-zone' congestion flag and it worked reasonably well, for
my testcase at least (no OOM). We still could stall even if we managed
to writeback pages in the meantime but we should at least prevent from
the problem you are mentioning (most of the time).

The issue with pagevec zone tagging is, as you mentioned, that the
flag clearing places are not that easy to get right because we do
not have anything like zone_watermark_ok in a memcg context. I am even
thinking whether it is possible without per-memcg dirtly accounting.

To be honest, I was considering congestion waiting at the beginning as
well but I hate using an arbitrary timeout when we are, in fact, waiting
for a specific event.
Nevertheless I do acknowledge your concern with accidental page reclaim
pages in the middle of the LRU because of clean page cache which would
lead to an unnecessary stalls.

I have updated the test case to do a parallel read with the write (read
from an existing file, same size, out=/dev/null) and compared the results:

* congestion_wait approach
==========================
* input file on a tmpfs so the read should be really fast:
----------------------------------------------------------
$ ./cgroup_cache_oom_test.sh 5M
using Limit 5M for group
read 1048576000 bytes (1.0 GB) copied, 0.785611 s, 1.3 GB/s
write 1048576000 bytes (1.0 GB) copied, 27.4083 s, 38.3 MB/s
$ ./cgroup_cache_oom_test.sh 60M
using Limit 60M for group
read 1048576000 bytes (1.0 GB) copied, 0.844437 s, 1.2 GB/s
write 1048576000 bytes (1.0 GB) copied, 29.9868 s, 35.0 MB/s
$ ./cgroup_cache_oom_test.sh 300M
using Limit 300M for group
read 1048576000 bytes (1.0 GB) copied, 0.793694 s, 1.3 GB/s
write 1048576000 bytes (1.0 GB) copied, 21.3534 s, 49.1 MB/s
$ ./cgroup_cache_oom_test.sh 2G
using Limit 2G for group
read 1048576000 bytes (1.0 GB) copied, 1.44286 s, 727 MB/s
write 1048576000 bytes (1.0 GB) copied, 20.8535 s, 50.3 MB/s

* input file on the ext3 (same partition)
-----------------------------------------
$ ./cgroup_cache_oom_test.sh 5M
using Limit 5M for group
write 1048576000 bytes (1.0 GB) copied, 49.7673 s, 21.1 MB/s
read 1048576000 bytes (1.0 GB) copied, 59.5391 s, 17.6 MB/s
$ ./cgroup_cache_oom_test.sh 60M
using Limit 60M for group
write 1048576000 bytes (1.0 GB) copied, 36.8087 s, 28.5 MB/s
read 1048576000 bytes (1.0 GB) copied, 50.1079 s, 20.9 MB/s
$ ./cgroup_cache_oom_test.sh 300M
using Limit 300M for group
write 1048576000 bytes (1.0 GB) copied, 29.9918 s, 35.0 MB/s
read 1048576000 bytes (1.0 GB) copied, 47.2997 s, 22.2 MB/s
$ ./cgroup_cache_oom_test.sh 2G
using Limit 2G for group
write 1048576000 bytes (1.0 GB) copied, 27.6548 s, 37.9 MB/s
read 1048576000 bytes (1.0 GB) copied, 41.6577 s, 25.2 MB/s

* PageReclaim approach [congestion is 100%]
======================
* input file on a tmpfs:
------------------------
$ ./cgroup_cache_oom_test.sh 5M
using Limit 5M for group
read 1048576000 bytes (1.0 GB) copied, 0.820246 s, 1.3 GB/s	[104.4%]
write 1048576000 bytes (1.0 GB) copied, 28.6641 s, 36.6 MB/s	[104.5%]
$ ./cgroup_cache_oom_test.sh 60M
using Limit 60M for group
read 1048576000 bytes (1.0 GB) copied, 0.858179 s, 1.2 GB/s	[101.6%]
write 1048576000 bytes (1.0 GB) copied, 32.4644 s, 32.3 MB/s	[108.2%]
$ ./cgroup_cache_oom_test.sh 300M
using Limit 300M for group
read 1048576000 bytes (1.0 GB) copied, 0.853459 s, 1.2 GB/s	[107.5%]
write 1048576000 bytes (1.0 GB) copied, 25.0716 s, 41.8 MB/s	[117.4%]
$ ./cgroup_cache_oom_test.sh 2G
using Limit 2G for group
read 1048576000 bytes (1.0 GB) copied, 0.854251 s, 1.2 GB/s	[ 59.2%]
write 1048576000 bytes (1.0 GB) copied, 14.7382 s, 71.1 MB/s	[ 70.7%]

* input file on the ext3 (same partition)
-----------------------------------------
$ ./cgroup_cache_oom_test.sh 5M
using Limit 5M for group
read 1048576000 bytes (1.0 GB) copied, 57.1462 s, 18.3 MB/s	[114.8%]
write 1048576000 bytes (1.0 GB) copied, 64.8275 s, 16.2 MB/s	[108.9%]
$ ./cgroup_cache_oom_test.sh 60M
using Limit 60M for group
write 1048576000 bytes (1.0 GB) copied, 37.4216 s, 28.0 MB/s	[101.7%]
read 1048576000 bytes (1.0 GB) copied, 49.3022 s, 21.3 MB/s	[ 98.4%]
$ ./cgroup_cache_oom_test.sh 300M
using Limit 300M for group
write 1048576000 bytes (1.0 GB) copied, 30.2872 s, 34.6 MB/s	[101.0%]
read 1048576000 bytes (1.0 GB) copied, 48.9104 s, 21.4 MB/s	[103.4%]
$ ./cgroup_cache_oom_test.sh 2G
using Limit 2G for group
write 1048576000 bytes (1.0 GB) copied, 21.1995 s, 49.5 MB/s	[ 76.7%]
read 1048576000 bytes (1.0 GB) copied, 49.1416 s, 21.3 MB/s	[118.8%]

As a conclusion congestion wait performs better (even though I haven't
done repeated testing to see what is the deviation) when the
reader/writer size doesn't fit into the memcg, while it performs much
worse (at least for writer) if it does fit.

I will play with that some more
-- 
Michal Hocko
SUSE Labs
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    
Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
