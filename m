Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx136.postini.com [74.125.245.136])
	by kanga.kvack.org (Postfix) with SMTP id 464126B13F0
	for <linux-mm@kvack.org>; Mon,  6 Feb 2012 14:40:38 -0500 (EST)
Received: by pbaa12 with SMTP id a12so6609642pba.14
        for <linux-mm@kvack.org>; Mon, 06 Feb 2012 11:40:37 -0800 (PST)
Date: Mon, 6 Feb 2012 11:40:08 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH] compact_pgdat: workaround lockdep warning in kswapd
Message-ID: <alpine.LSU.2.00.1202061129040.2144@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org

I get this lockdep warning from swapping load on linux-next
(20120201 but I expect the same from more recent days):

=================================
[ INFO: inconsistent lock state ]
3.3.0-rc2-next-20120201 #5 Not tainted
---------------------------------
inconsistent {RECLAIM_FS-ON-W} -> {IN-RECLAIM_FS-W} usage.
kswapd0/28 [HC0[0]:SC0[0]:HE1:SE1] takes:
 (pcpu_alloc_mutex){+.+.?.}, at: [<ffffffff810d6684>] pcpu_alloc+0x67/0x325
{RECLAIM_FS-ON-W} state was registered at:
  [<ffffffff81099b75>] mark_held_locks+0xd7/0x103
  [<ffffffff8109a13c>] lockdep_trace_alloc+0x85/0x9e
  [<ffffffff810f6bdc>] __kmalloc+0x6c/0x14b
  [<ffffffff810d57fd>] pcpu_mem_zalloc+0x59/0x62
  [<ffffffff810d5d16>] pcpu_extend_area_map+0x26/0xb1
  [<ffffffff810d679f>] pcpu_alloc+0x182/0x325
  [<ffffffff810d694d>] __alloc_percpu+0xb/0xd
  [<ffffffff8142ebfd>] snmp_mib_init+0x1e/0x2e
  [<ffffffff8185cd8d>] ipv4_mib_init_net+0x7a/0x184
  [<ffffffff813dc963>] ops_init.clone.0+0x6b/0x73
  [<ffffffff813dc9cc>] register_pernet_operations+0x61/0xa0
  [<ffffffff813dca8e>] register_pernet_subsys+0x29/0x42
  [<ffffffff8185d044>] inet_init+0x1ad/0x252
  [<ffffffff810002e3>] do_one_initcall+0x7a/0x12f
  [<ffffffff81832bc5>] kernel_init+0x9d/0x11e
  [<ffffffff814e51e4>] kernel_thread_helper+0x4/0x10
irq event stamp: 656613
hardirqs last  enabled at (656613): [<ffffffff814e0ddc>] __mutex_unlock_slowpath+0x104/0x128
hardirqs last disabled at (656612): [<ffffffff814e0d34>] __mutex_unlock_slowpath+0x5c/0x128
softirqs last  enabled at (655568): [<ffffffff8105b4a5>] __do_softirq+0x120/0x136
softirqs last disabled at (654757): [<ffffffff814e52dc>] call_softirq+0x1c/0x30

other info that might help us debug this:
 Possible unsafe locking scenario:

       CPU0
       ----
  lock(pcpu_alloc_mutex);
  <Interrupt>
    lock(pcpu_alloc_mutex);

 *** DEADLOCK ***

no locks held by kswapd0/28.

stack backtrace:
Pid: 28, comm: kswapd0 Not tainted 3.3.0-rc2-next-20120201 #5
Call Trace:
 [<ffffffff810981f4>] print_usage_bug+0x1bf/0x1d0
 [<ffffffff81096c3e>] ? print_irq_inversion_bug+0x1d9/0x1d9
 [<ffffffff810982c0>] mark_lock_irq+0xbb/0x22e
 [<ffffffff810c5399>] ? free_hot_cold_page+0x13d/0x14f
 [<ffffffff81098684>] mark_lock+0x251/0x331
 [<ffffffff81098893>] mark_irqflags+0x12f/0x141
 [<ffffffff81098e32>] __lock_acquire+0x58d/0x753
 [<ffffffff810d6684>] ? pcpu_alloc+0x67/0x325
 [<ffffffff81099433>] lock_acquire+0x54/0x6a
 [<ffffffff810d6684>] ? pcpu_alloc+0x67/0x325
 [<ffffffff8107a5b8>] ? add_preempt_count+0xa9/0xae
 [<ffffffff814e0a21>] mutex_lock_nested+0x5e/0x315
 [<ffffffff810d6684>] ? pcpu_alloc+0x67/0x325
 [<ffffffff81098f81>] ? __lock_acquire+0x6dc/0x753
 [<ffffffff810c9fb0>] ? __pagevec_release+0x2c/0x2c
 [<ffffffff810d6684>] pcpu_alloc+0x67/0x325
 [<ffffffff810c9fb0>] ? __pagevec_release+0x2c/0x2c
 [<ffffffff810d694d>] __alloc_percpu+0xb/0xd
 [<ffffffff8106c35e>] schedule_on_each_cpu+0x23/0x110
 [<ffffffff810c9fcb>] lru_add_drain_all+0x10/0x12
 [<ffffffff810f126f>] __compact_pgdat+0x20/0x182
 [<ffffffff810f15c2>] compact_pgdat+0x27/0x29
 [<ffffffff810c306b>] ? zone_watermark_ok+0x1a/0x1c
 [<ffffffff810cdf6f>] balance_pgdat+0x732/0x751
 [<ffffffff810ce0ed>] kswapd+0x15f/0x178
 [<ffffffff810cdf8e>] ? balance_pgdat+0x751/0x751
 [<ffffffff8106fd11>] kthread+0x84/0x8c
 [<ffffffff814e51e4>] kernel_thread_helper+0x4/0x10
 [<ffffffff810787ed>] ? finish_task_switch+0x85/0xea
 [<ffffffff814e3861>] ? retint_restore_args+0xe/0xe
 [<ffffffff8106fc8d>] ? __init_kthread_worker+0x56/0x56
 [<ffffffff814e51e0>] ? gs_change+0xb/0xb

The RECLAIM_FS notations indicate that it's doing the GFP_FS checking
that Nick hacked into lockdep a while back: I think we're intended to
read that "<Interrupt>" in the DEADLOCK scenario as "<Direct reclaim>".

I'm hazy, I have not reached any conclusion as to whether it's right
to complain or not; but I believe it's uneasy about kswapd now doing
the mutex_lock(&pcpu_alloc_mutex) which lru_add_drain_all() entails.
Nor have I reached any conclusion as to whether it's important for
kswapd to do that draining or not.

But so as not to get blocked on this, with lockdep disabled from giving
further reports, here's a patch which removes the lru_add_drain_all()
from kswapd's callpath (and calls it only once from compact_nodes(),
instead of once per node).

Signed-off-by: Hugh Dickins <hughd@google.com>
---

 mm/compaction.c |   22 ++++++++++++----------
 1 file changed, 12 insertions(+), 10 deletions(-)

--- 3.2-rc2-next/mm/compaction.c	2012-01-31 22:37:00.756147798 -0800
+++ linux/mm/compaction.c	2012-02-05 10:09:24.172839142 -0800
@@ -671,9 +671,6 @@ static int __compact_pgdat(pg_data_t *pg
 	int zoneid;
 	struct zone *zone;
 
-	/* Flush pending updates to the LRU lists */
-	lru_add_drain_all();
-
 	for (zoneid = 0; zoneid < MAX_NR_ZONES; zoneid++) {
 
 		zone = &pgdat->node_zones[zoneid];
@@ -718,17 +715,12 @@ int compact_pgdat(pg_data_t *pgdat, int
 
 static int compact_node(int nid)
 {
-	pg_data_t *pgdat;
 	struct compact_control cc = {
 		.order = -1,
 		.sync = true,
 	};
 
-	if (nid < 0 || nid >= nr_node_ids || !node_online(nid))
-		return -EINVAL;
-	pgdat = NODE_DATA(nid);
-
-	return __compact_pgdat(pgdat, &cc);
+	return __compact_pgdat(NODE_DATA(nid), &cc);
 }
 
 /* Compact all nodes in the system */
@@ -736,6 +728,9 @@ static int compact_nodes(void)
 {
 	int nid;
 
+	/* Flush pending updates to the LRU lists */
+	lru_add_drain_all();
+
 	for_each_online_node(nid)
 		compact_node(nid);
 
@@ -768,7 +763,14 @@ ssize_t sysfs_compact_node(struct device
 			struct device_attribute *attr,
 			const char *buf, size_t count)
 {
-	compact_node(dev->id);
+	int nid = dev->id;
+
+	if (nid >= 0 && nid < nr_node_ids && node_online(nid)) {
+		/* Flush pending updates to the LRU lists */
+		lru_add_drain_all();
+
+		compact_node(nid);
+	}
 
 	return count;
 }

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
