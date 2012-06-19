Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx198.postini.com [74.125.245.198])
	by kanga.kvack.org (Postfix) with SMTP id F2DDD6B006C
	for <linux-mm@kvack.org>; Tue, 19 Jun 2012 10:50:52 -0400 (EDT)
From: Michal Hocko <mhocko@suse.cz>
Subject: [PATCH -mm] memcg: prevent from OOM with too many dirty pages
Date: Tue, 19 Jun 2012 16:50:04 +0200
Message-Id: <1340117404-30348-1-git-send-email-mhocko@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujtisu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, Rik van Riel <riel@redhat.com>, Ying Han <yinghan@google.com>, Greg Thelen <gthelen@google.com>, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Fengguang Wu <fengguang.wu@intel.com>

Current implementation of dirty pages throttling is not memcg aware which makes
it easy to have LRUs full of dirty pages which might lead to memcg OOM if the
hard limit is small and so the lists are scanned faster than pages written
back.

This patch fixes the problem by throttling the allocating process (possibly
a writer) during the hard limit reclaim by waiting on PageReclaim pages.
We are waiting only for PageReclaim pages because those are the pages
that made one full round over LRU and that means that the writeback is much
slower than scanning.
The solution is far from being ideal - long term solution is memcg aware
dirty throttling - but it is meant to be a band aid until we have a real
fix.
We are seeing this happening during nightly backups which are placed into
containers to prevent from eviction of the real working set.

The change affects only memcg reclaim and only when we encounter PageReclaim
pages which is a signal that the reclaim doesn't catch up on with the writers
so somebody should be throttled. This could be potentially unfair because it
could be somebody else from the group who gets throttled on behalf of the
writer but as writers need to allocate as well and they allocate in higher rate
the probability that only innocent processes would be penalized is not that
high.

I have tested this change by a simple dd copying /dev/zero to tmpfs or ext3
running under small memcg (1G copy under 5M, 60M, 300M and 2G containers) and
dd got killed by OOM killer every time. With the patch I could run the dd with
the same size under 5M controller without any OOM.
The issue is more visible with slower devices for output.

* With the patch
================
* tmpfs size=2G
---------------
$ vim cgroup_cache_oom_test.sh
$ ./cgroup_cache_oom_test.sh 5M
using Limit 5M for group
1000+0 records in
1000+0 records out
1048576000 bytes (1.0 GB) copied, 30.4049 s, 34.5 MB/s
$ ./cgroup_cache_oom_test.sh 60M
using Limit 60M for group
1000+0 records in
1000+0 records out
1048576000 bytes (1.0 GB) copied, 31.4561 s, 33.3 MB/s
$ ./cgroup_cache_oom_test.sh 300M
using Limit 300M for group
1000+0 records in
1000+0 records out
1048576000 bytes (1.0 GB) copied, 20.4618 s, 51.2 MB/s
$ ./cgroup_cache_oom_test.sh 2G
using Limit 2G for group
1000+0 records in
1000+0 records out
1048576000 bytes (1.0 GB) copied, 1.42172 s, 738 MB/s

* ext3
------
$ ./cgroup_cache_oom_test.sh 5M
using Limit 5M for group
1000+0 records in
1000+0 records out
1048576000 bytes (1.0 GB) copied, 27.9547 s, 37.5 MB/s
$ ./cgroup_cache_oom_test.sh 60M
using Limit 60M for group
1000+0 records in
1000+0 records out
1048576000 bytes (1.0 GB) copied, 30.3221 s, 34.6 MB/s
$ ./cgroup_cache_oom_test.sh 300M
using Limit 300M for group
1000+0 records in
1000+0 records out
1048576000 bytes (1.0 GB) copied, 24.5764 s, 42.7 MB/s
$ ./cgroup_cache_oom_test.sh 2G
using Limit 2G for group
1000+0 records in
1000+0 records out
1048576000 bytes (1.0 GB) copied, 3.35828 s, 312 MB/s

* Without the patch
===================
* tmpfs size=2G
---------------
$ ./cgroup_cache_oom_test.sh 5M
using Limit 5M for group
./cgroup_cache_oom_test.sh: line 46:  4668 Killed                  dd if=/dev/zero of=$OUT/zero bs=1M count=$count
$ ./cgroup_cache_oom_test.sh 60M
using Limit 60M for group
1000+0 records in
1000+0 records out
1048576000 bytes (1.0 GB) copied, 25.4989 s, 41.1 MB/s
$ ./cgroup_cache_oom_test.sh 300M
using Limit 300M for group
1000+0 records in
1000+0 records out
1048576000 bytes (1.0 GB) copied, 24.3928 s, 43.0 MB/s
$ ./cgroup_cache_oom_test.sh 2G
using Limit 2G for group
1000+0 records in
1000+0 records out
1048576000 bytes (1.0 GB) copied, 1.49797 s, 700 MB/s

* ext3
------
$ ./cgroup_cache_oom_test.sh 5M
using Limit 5M for group
./cgroup_cache_oom_test.sh: line 46:  4689 Killed                  dd if=/dev/zero of=$OUT/zero bs=1M count=$count
$ ./cgroup_cache_oom_test.sh 60M
using Limit 60M for group
./cgroup_cache_oom_test.sh: line 46:  4692 Killed                  dd if=/dev/zero of=$OUT/zero bs=1M count=$count
$ ./cgroup_cache_oom_test.sh 300M
using Limit 300M for group
1000+0 records in
1000+0 records out
1048576000 bytes (1.0 GB) copied, 20.248 s, 51.8 MB/s
$ ./cgroup_cache_oom_test.sh 2G
using Limit 2G for group
1000+0 records in
1000+0 records out
1048576000 bytes (1.0 GB) copied, 2.85201 s, 368 MB/s

Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujtisu.com>
Cc: Mel Gorman <mgorman@suse.de>
Cc: Minchan Kim <minchan@kernel.org>
Cc: Rik van Riel <riel@redhat.com>
Cc: Ying Han <yinghan@google.com>
Cc: Greg Thelen <gthelen@google.com>
Cc: Hugh Dickins <hughd@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
Cc: Fengguang Wu <fengguang.wu@intel.com>
Acked-by: Johannes Weiner <hannes@cmpxchg.org>
Reviewed-by: Fengguang Wu <fengguang.wu@intel.com>
Signed-off-by: Michal Hocko <mhocko@suse.cz>
---
 mm/vmscan.c |   17 ++++++++++++++---
 1 file changed, 14 insertions(+), 3 deletions(-)

diff --git a/mm/vmscan.c b/mm/vmscan.c
index c978ce4..7cccd81 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -720,9 +720,20 @@ static unsigned long shrink_page_list(struct list_head *page_list,
 			(PageSwapCache(page) && (sc->gfp_mask & __GFP_IO));
 
 		if (PageWriteback(page)) {
-			nr_writeback++;
-			unlock_page(page);
-			goto keep;
+			/*
+			 * memcg doesn't have any dirty pages throttling so we
+			 * could easily OOM just because too many pages are in
+			 * writeback from reclaim and there is nothing else to
+			 * reclaim.
+			 */
+			if (PageReclaim(page)
+					&& may_enter_fs && !global_reclaim(sc))
+				wait_on_page_writeback(page);
+			else {
+				nr_writeback++;
+				unlock_page(page);
+				goto keep;
+			}
 		}
 
 		references = page_check_references(page, sc);
-- 
1.7.10

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
