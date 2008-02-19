Date: Tue, 19 Feb 2008 14:44:48 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Subject: [RFC][PATCH] the proposal of improve page reclaim by throttle
Message-Id: <20080219134715.7E90.KOSAKI.MOTOHIRO@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Rik van Riel <riel@redhat.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: kosaki.motohiro@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

background
========================================
current VM implementation doesn't has limit of # of parallel reclaim.
when heavy workload, it bring to 2 bad things
  - heavy lock contention
  - unnecessary swap out

abount 2 month ago, KAMEZA Hiroyuki proposed the patch of page 
reclaim throttle and explain it improve reclaim time.
	http://marc.info/?l=linux-mm&m=119667465917215&w=2

but unfortunately it works only memcgroup reclaim.
Today, I implement it again for support global reclaim and mesure it.


test machine, method and result
==================================================
<test machine>
	CPU:  IA64 x8
	MEM:  8GB
	SWAP: 2GB

<test method>
	got hackbench from
		http://people.redhat.com/mingo/cfs-scheduler/tools/hackbench.c

	$ /usr/bin/time hackbench 120 process 1000

	this parameter mean consume all physical memory and 
	1GB swap space on my test environment.

<test result (average of 3 times measurement)>

before:
	hackbench result:		282.30
	/usr/bin/time result
		user:			14.16
		sys:			1248.47
		elapse:			432.93
		major fault:		29026
	max parallel reclaim tasks:	1298
	max consumption time of
	 try_to_free_pages():		70394 

after:
	hackbench result:		30.36
	/usr/bin/time result
		user:			14.26
		sys:			294.44
		elapse:			118.01
		major fault:		3064
	max parallel reclaim tasks:	4
	max consumption time of
	 try_to_free_pages():		12234 


conclusion
=========================================
this patch improve 3 things.
1. reduce unnecessary swap
   (see above major fault. about 90% reduced)
2. improve throughput performance
   (see above hackbench result. about 90% reduced)
3. improve interactive performance.
   (see above max consumption of try_to_free_pages.
    about 80% reduced)
4. reduce lock contention.
   (see above sys time. about 80% reduced)


Now, we got about 1000% performance improvement of hackbench :)



foture works
==========================================================
 - more discussion with memory controller guys.



Signed-off-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
CC: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
CC: Balbir Singh <balbir@linux.vnet.ibm.com>
CC: Rik van Riel <riel@redhat.com>
CC: Lee Schermerhorn <Lee.Schermerhorn@hp.com>

---
 include/linux/nodemask.h |    1 
 mm/vmscan.c              |   49 +++++++++++++++++++++++++++++++++++++++++++++--
 2 files changed, 48 insertions(+), 2 deletions(-)

Index: b/include/linux/nodemask.h
===================================================================
--- a/include/linux/nodemask.h	2008-02-19 13:58:05.000000000 +0900
+++ b/include/linux/nodemask.h	2008-02-19 13:58:23.000000000 +0900
@@ -431,6 +431,7 @@ static inline int num_node_state(enum no
 
 #define num_online_nodes()	num_node_state(N_ONLINE)
 #define num_possible_nodes()	num_node_state(N_POSSIBLE)
+#define num_highmem_nodes()	num_node_state(N_HIGH_MEMORY)
 #define node_online(node)	node_state((node), N_ONLINE)
 #define node_possible(node)	node_state((node), N_POSSIBLE)
 
Index: b/mm/vmscan.c
===================================================================
--- a/mm/vmscan.c	2008-02-19 13:58:05.000000000 +0900
+++ b/mm/vmscan.c	2008-02-19 14:04:06.000000000 +0900
@@ -127,6 +127,11 @@ long vm_total_pages;	/* The total number
 static LIST_HEAD(shrinker_list);
 static DECLARE_RWSEM(shrinker_rwsem);
 
+static atomic_t nr_reclaimers = ATOMIC_INIT(0);
+static DECLARE_WAIT_QUEUE_HEAD(reclaim_throttle_waitq);
+#define RECLAIM_LIMIT (2 * num_highmem_nodes())
+
+
 #ifdef CONFIG_CGROUP_MEM_CONT
 #define scan_global_lru(sc)	(!(sc)->mem_cgroup)
 #else
@@ -1421,6 +1426,46 @@ out:
 	return ret;
 }
 
+static unsigned long try_to_free_pages_throttled(struct zone **zones,
+						 int order,
+						 gfp_t gfp_mask,
+						 struct scan_control *sc)
+{
+	unsigned long nr_reclaimed = 0;
+	unsigned long start_time;
+	int i;
+
+	start_time = jiffies;
+
+	wait_event(reclaim_throttle_waitq,
+		   atomic_add_unless(&nr_reclaimers, 1, RECLAIM_LIMIT));
+
+	/* more reclaim until needed? */
+	if (unlikely(time_after(jiffies, start_time + HZ))) {
+		for (i = 0; zones[i] != NULL; i++) {
+			struct zone *zone = zones[i];
+			int classzone_idx = zone_idx(zones[0]);
+
+			if (!populated_zone(zone))
+				continue;
+
+			if (zone_watermark_ok(zone, order, 4*zone->pages_high,
+					      classzone_idx, 0)) {
+				nr_reclaimed = 1;
+				goto out;
+			}
+		}
+	}
+
+	nr_reclaimed = do_try_to_free_pages(zones, gfp_mask, sc);
+
+out:
+	atomic_dec(&nr_reclaimers);
+	wake_up_all(&reclaim_throttle_waitq);
+
+	return nr_reclaimed;
+}
+
 unsigned long try_to_free_pages(struct zone **zones, int order, gfp_t gfp_mask)
 {
 	struct scan_control sc = {
@@ -1434,7 +1479,7 @@ unsigned long try_to_free_pages(struct z
 		.isolate_pages = isolate_pages_global,
 	};
 
-	return do_try_to_free_pages(zones, gfp_mask, &sc);
+	return try_to_free_pages_throttled(zones, order, gfp_mask, &sc);
 }
 
 #ifdef CONFIG_CGROUP_MEM_CONT
@@ -1456,7 +1501,7 @@ unsigned long try_to_free_mem_cgroup_pag
 	int target_zone = gfp_zone(GFP_HIGHUSER_MOVABLE);
 
 	zones = NODE_DATA(numa_node_id())->node_zonelists[target_zone].zones;
-	if (do_try_to_free_pages(zones, sc.gfp_mask, &sc))
+	if (try_to_free_pages_throttled(zones, 0, sc.gfp_mask, &sc))
 		return 1;
 	return 0;
 }


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
