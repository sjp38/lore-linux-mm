Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id EDD4A6B007B
	for <linux-mm@kvack.org>; Sat, 18 Sep 2010 08:52:45 -0400 (EDT)
Date: Sat, 18 Sep 2010 08:52:34 -0400 (EDT)
From: caiqian@redhat.com
Message-ID: <290491919.1298351284814354705.JavaMail.root@zmail06.collab.prod.int.phx2.redhat.com>
In-Reply-To: <1296415999.1298271284814035815.JavaMail.root@zmail06.collab.prod.int.phx2.redhat.com>
Subject: cgroup oom regression introduced by
 6a5ce1b94e1e5979f8db579f77d6e08a5f44c13b
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: linux-mm <linux-mm@kvack.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, "M. Vefa Bicakci" <bicave@superonline.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, stable@kernel.org, akpm@linux-foundation.org
List-ID: <linux-mm.kvack.org>

This test hung the kernel without triggering oom.
# mount -t cgroup -o memory none /cgroup/memory/
# mkdir /cgroup/memory/A
# echo $$ >/cgroup/memory/A/tasks
# echo 4096M >/cgroup/memory/A/memory.limit_in_bytes
# echo 4096M >/cgroup/memory/A/memory.memsw.limit_in_bytes
# use malloc to allocate more than 4G memory.

Sometimes, this had been thrown out of console,
localhost.localdomain login: INFO: task sm1:5065 blocked for more than 120 seconds.
"echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
sm1           D 00000000fffca130     0  5065   5051 0x00000080
 ffff880c5f419c38 0000000000000086 ffff880c5f419bc8 ffffffff81034ca8
 ffff880100000000 0000000000015440 ffff880c608ab4e0 0000000000015440
 ffff880c608aba40 ffff880c5f419fd8 ffff880c608aba48 ffff880c5f419fd8
Call Trace:
 [<ffffffff81034ca8>] ? pvclock_clocksource_read+0x58/0xd0
 [<ffffffff810f2c60>] ? sync_page+0x0/0x50
 [<ffffffff81492553>] io_schedule+0x73/0xc0
 [<ffffffff810f2c9d>] sync_page+0x3d/0x50
 [<ffffffff81492cba>] __wait_on_bit_lock+0x5a/0xc0
 [<ffffffff810f2c37>] __lock_page+0x67/0x70
 [<ffffffff8107cf90>] ? wake_bit_function+0x0/0x50
 [<ffffffff810f2a6e>] ? find_get_page+0x1e/0xa0
 [<ffffffff810f4a5c>] filemap_fault+0x33c/0x450
 [<ffffffff81110524>] __do_fault+0x54/0x550
 [<ffffffff8113f30a>] ? __mem_cgroup_commit_charge+0x5a/0xa0
 [<ffffffff811132a2>] handle_mm_fault+0x1c2/0xc70
 [<ffffffff8149809c>] do_page_fault+0x11c/0x320
 [<ffffffff81494cd5>] page_fault+0x25/0x30

Reverted the following commit from mmotm tree made the problem go away.
commit 6a5ce1b94e1e5979f8db579f77d6e08a5f44c13b
Author: Minchan Kim <minchan.kim@gmail.com>
Date:   Thu Sep 16 01:17:26 2010 +0200

    M.  Vefa Bicakci reported 2.6.35 kernel hang up when hibernation on his
    32bit 3GB mem machine.
    (https://bugzilla.kernel.org/show_bug.cgi?id=16771). Also he bisected
    the regression to
    
      commit bb21c7ce18eff8e6e7877ca1d06c6db719376e3c
      Author: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
      Date:   Fri Jun 4 14:15:05 2010 -0700
    
         vmscan: fix do_try_to_free_pages() return value when priority==0 reclaim failure
    
    At first impression, this seemed very strange because the above commit
    only chenged function return value and hibernate_preallocate_memory()
    ignore return value of shrink_all_memory().  But it's related.
    
    Now, page allocation from hibernation code may enter infinite loop if the
    system has highmem.  The reasons are that vmscan don't care enough OOM
    case when oom_killer_disabled.
    
    The problem sequence is following as.
    
    1. hibernation
    2. oom_disable
    3. alloc_pages
    4. do_try_to_free_pages
           if (scanning_global_lru(sc) && !all_unreclaimable)
                   return 1;
    
    If kswapd is not freozen, it would set zone->all_unreclaimable to 1 and
    then shrink_zones maybe return true(ie, all_unreclaimable is true).  So at
    last, alloc_pages could go to _nopage_.  If it is, it should have no
    problem.
    
    This patch adds all_unreclaimable check to protect in direct reclaim path,
    too.  It can care of hibernation OOM case and help bailout
    all_unreclaimable case slightly.
    
    Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
    Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
    Reported-by: M. Vefa Bicakci <bicave@superonline.com>
    Acked-by: Rafael J. Wysocki <rjw@sisk.pl>
    Reviewed-by: Johannes Weiner <hannes@cmpxchg.org>
    Cc: Rik van Riel <riel@redhat.com>
    Cc: <stable@kernel.org>
    Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

diff --git a/mm/vmscan.c b/mm/vmscan.c
index 225a759..f56a8c3 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -1804,12 +1804,11 @@ static void shrink_zone(int priority, struct zone *zone,
  * If a zone is deemed to be full of pinned pages then just give it a light
  * scan then give up on it.
  */
-static bool shrink_zones(int priority, struct zonelist *zonelist,
+static void shrink_zones(int priority, struct zonelist *zonelist,
 					struct scan_control *sc)
 {
 	struct zoneref *z;
 	struct zone *zone;
-	bool all_unreclaimable = true;
 
 	for_each_zone_zonelist_nodemask(zone, z, zonelist,
 					gfp_zone(sc->gfp_mask), sc->nodemask) {
@@ -1827,8 +1826,36 @@ static bool shrink_zones(int priority, struct zonelist *zonelist,
 		}
 
 		shrink_zone(priority, zone, sc);
-		all_unreclaimable = false;
 	}
+}
+
+static inline bool zone_reclaimable(struct zone *zone)
+{
+	return zone->pages_scanned < zone_reclaimable_pages(zone) * 6;
+}
+
+static inline bool all_unreclaimable(struct zonelist *zonelist,
+		struct scan_control *sc)
+{
+	struct zoneref *z;
+	struct zone *zone;
+	bool all_unreclaimable = true;
+
+	if (!scanning_global_lru(sc))
+		return false;
+
+	for_each_zone_zonelist_nodemask(zone, z, zonelist,
+			gfp_zone(sc->gfp_mask), sc->nodemask) {
+		if (!populated_zone(zone))
+			continue;
+		if (!cpuset_zone_allowed_hardwall(zone, GFP_KERNEL))
+			continue;
+		if (zone_reclaimable(zone)) {
+			all_unreclaimable = false;
+			break;
+		}
+	}
+
 	return all_unreclaimable;
 }
 
@@ -1852,7 +1879,6 @@ static unsigned long do_try_to_free_pages(struct zonelist *zonelist,
 					struct scan_control *sc)
 {
 	int priority;
-	bool all_unreclaimable;
 	unsigned long total_scanned = 0;
 	struct reclaim_state *reclaim_state = current->reclaim_state;
 	struct zoneref *z;
@@ -1869,7 +1895,7 @@ static unsigned long do_try_to_free_pages(struct zonelist *zonelist,
 		sc->nr_scanned = 0;
 		if (!priority)
 			disable_swap_token();
-		all_unreclaimable = shrink_zones(priority, zonelist, sc);
+		shrink_zones(priority, zonelist, sc);
 		/*
 		 * Don't shrink slabs when reclaiming memory from
 		 * over limit cgroups
@@ -1931,7 +1957,7 @@ out:
 		return sc->nr_reclaimed;
 
 	/* top priority shrink_zones still had more to do? don't OOM, then */
-	if (scanning_global_lru(sc) && !all_unreclaimable)
+	if (!all_unreclaimable(zonelist, sc))
 		return 1;
 
 	return 0;
@@ -2197,8 +2223,7 @@ loop_again:
 			total_scanned += sc.nr_scanned;
 			if (zone->all_unreclaimable)
 				continue;
-			if (nr_slab == 0 &&
-			    zone->pages_scanned >= (zone_reclaimable_pages(zone) * 6))
+			if (nr_slab == 0 && !zone_reclaimable(zone))
 				zone->all_unreclaimable = 1;
 			/*
 			 * If we've done a decent amount of scanning and

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
