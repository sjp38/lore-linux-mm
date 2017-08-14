Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id C87816B025F
	for <linux-mm@kvack.org>; Mon, 14 Aug 2017 01:30:52 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id v77so116997481pgb.15
        for <linux-mm@kvack.org>; Sun, 13 Aug 2017 22:30:52 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id e19si3684754pgk.199.2017.08.13.22.30.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 13 Aug 2017 22:30:50 -0700 (PDT)
Date: Mon, 14 Aug 2017 13:31:30 +0800
From: Aaron Lu <aaron.lu@intel.com>
Subject: [PATCH] swap: choose swap device according to numa node
Message-ID: <20170814053130.GD2369@aaronlu.sh.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm <linux-mm@kvack.org>, lkml <linux-kernel@vger.kernel.org>
Cc: "Chen, Tim C" <tim.c.chen@intel.com>, Huang Ying <ying.huang@intel.com>, "Kleen, Andi" <andi.kleen@intel.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Minchan Kim <minchan@kernel.org>

If the system has more than one swap device and swap device has the node
information, we can make use of this information to decide which swap
device to use in get_swap_pages() to get better performance.

The current code uses a priority based list, swap_avail_list, to decide
which swap device to use and if multiple swap devices share the same
priority, they are used round robin. This patch changes the previous
single global swap_avail_list into a per-numa-node list, i.e. for each
numa node, it sees its own priority based list of available swap devices.
Swap device's priority can be promoted on its matching node's swap_avail_list.

The current swap device's priority is set as: user can set a >=0 value,
or the system will pick one starting from -1 then downwards. The priority
value in the swap_avail_list is the negated value of the swap device's
due to plist being sorted from low to high. The new policy doesn't change
the semantics for priority >=0 cases, the previous starting from -1 then
downwards now becomes starting from -2 then downwards and -1 is reserved
as the promoted value.

Take 4-node EX machine as an example, suppose 4 swap devices are
available, each sit on a different node:
swapA on node 0
swapB on node 1
swapC on node 2
swapD on node 3

After they are all swapped on in the sequence of ABCD.

Current behaviour:
their priorities will be:
swapA: -1
swapB: -2
swapC: -3
swapD: -4
And their position in the global swap_avail_list will be:
swapA   -> swapB   -> swapC   -> swapD
prio:1     prio:2     prio:3     prio:4

New behaviour:
their priorities will be(note that -1 is skipped):
swapA: -2
swapB: -3
swapC: -4
swapD: -5
And their positions in the 4 swap_avail_lists[nid] will be:
swap_avail_lists[0]: /* node 0's available swap device list */
swapA   -> swapB   -> swapC   -> swapD
prio:1     prio:3     prio:4     prio:5
swap_avali_lists[1]: /* node 1's available swap device list */
swapB   -> swapA   -> swapC   -> swapD
prio:1     prio:2     prio:4     prio:5
swap_avail_lists[2]: /* node 2's available swap device list */
swapC   -> swapA   -> swapB   -> swapD
prio:1     prio:2     prio:3     prio:5
swap_avail_lists[3]: /* node 3's available swap device list */
swapD   -> swapA   -> swapB   -> swapC
prio:1     prio:2     prio:3     prio:4

To see the effect of the patch, a test that starts N process, each mmap
a region of anonymous memory and then continually write to it at random
position to trigger both swap in and out is used.

On a 2 node Skylake EP machine with 64GiB memory, two 170GB SSD drives
are used as swap devices with each attached to a different node, the
result is:

runtime=30m/processes=32/total test size=128G/each process mmap region=4G
kernel         throughput
vanilla        13306
auto-binding   15169 +14%

runtime=30m/processes=64/total test size=128G/each process mmap region=2G
kernel         throughput
vanilla        11885
auto-binding   14879 25%

Signed-off-by: Aaron Lu <aaron.lu@intel.com>
---
A previous version was sent without catching much attention:
https://lkml.org/lkml/2016/7/4/633
I'm sending again with some minor modifications and after test showed
performance gains for SSD.

 Documentation/vm/swap_numa.txt |  18 +++++++
 include/linux/swap.h           |   2 +-
 mm/swapfile.c                  | 113 +++++++++++++++++++++++++++++++----------
 3 files changed, 106 insertions(+), 27 deletions(-)
 create mode 100644 Documentation/vm/swap_numa.txt

diff --git a/Documentation/vm/swap_numa.txt b/Documentation/vm/swap_numa.txt
new file mode 100644
index 000000000000..e63fe485567c
--- /dev/null
+++ b/Documentation/vm/swap_numa.txt
@@ -0,0 +1,18 @@
+If the system has more than one swap device and swap device has the node
+information, we can make use of this information to decide which swap
+device to use in get_swap_pages() to get better performance.
+
+The current code uses a priority based list, swap_avail_list, to decide
+which swap device to use and if multiple swap devices share the same
+priority, they are used round robin. This change here replaces the single
+global swap_avail_list with a per-numa-node list, i.e. for each numa node,
+it sees its own priority based list of available swap devices. Swap
+device's priority can be promoted on its matching node's swap_avail_list.
+
+The current swap device's priority is set as: user can set a >=0 value,
+or the system will pick one starting from -1 then downwards. The priority
+value in the swap_avail_list is the negated value of the swap device's
+due to plist being sorted from low to high. The new policy doesn't change
+the semantics for priority >=0 cases, the previous starting from -1 then
+downwards now becomes starting from -2 then downwards and -1 is reserved
+as the promoted value.
diff --git a/include/linux/swap.h b/include/linux/swap.h
index d83d28e53e62..28262fe683ad 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -211,7 +211,7 @@ struct swap_info_struct {
 	unsigned long	flags;		/* SWP_USED etc: see above */
 	signed short	prio;		/* swap priority of this type */
 	struct plist_node list;		/* entry in swap_active_head */
-	struct plist_node avail_list;	/* entry in swap_avail_head */
+	struct plist_node avail_lists[MAX_NUMNODES];/* entry in swap_avail_heads */
 	signed char	type;		/* strange name for an index */
 	unsigned int	max;		/* extent of the swap_map */
 	unsigned char *swap_map;	/* vmalloc'ed array of usage counts */
diff --git a/mm/swapfile.c b/mm/swapfile.c
index 6ba4aab2db0b..e9696f082a1a 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -60,7 +60,7 @@ atomic_long_t nr_swap_pages;
 EXPORT_SYMBOL_GPL(nr_swap_pages);
 /* protected with swap_lock. reading in vm_swap_full() doesn't need lock */
 long total_swap_pages;
-static int least_priority;
+static int least_priority = -1;
 
 static const char Bad_file[] = "Bad swap file entry ";
 static const char Unused_file[] = "Unused swap file entry ";
@@ -85,7 +85,7 @@ PLIST_HEAD(swap_active_head);
  * is held and the locking order requires swap_lock to be taken
  * before any swap_info_struct->lock.
  */
-static PLIST_HEAD(swap_avail_head);
+struct plist_head *swap_avail_heads;
 static DEFINE_SPINLOCK(swap_avail_lock);
 
 struct swap_info_struct *swap_info[MAX_SWAPFILES];
@@ -580,6 +580,20 @@ static bool scan_swap_map_try_ssd_cluster(struct swap_info_struct *si,
 	return found_free;
 }
 
+static void __del_from_avail_list(struct swap_info_struct *p)
+{
+	int nid;
+	for_each_node(nid)
+		plist_del(&p->avail_lists[nid], &swap_avail_heads[nid]);
+}
+
+static void del_from_avail_list(struct swap_info_struct *p)
+{
+	spin_lock(&swap_avail_lock);
+	__del_from_avail_list(p);
+	spin_unlock(&swap_avail_lock);
+}
+
 static void swap_range_alloc(struct swap_info_struct *si, unsigned long offset,
 			     unsigned int nr_entries)
 {
@@ -593,12 +607,22 @@ static void swap_range_alloc(struct swap_info_struct *si, unsigned long offset,
 	if (si->inuse_pages == si->pages) {
 		si->lowest_bit = si->max;
 		si->highest_bit = 0;
-		spin_lock(&swap_avail_lock);
-		plist_del(&si->avail_list, &swap_avail_head);
-		spin_unlock(&swap_avail_lock);
+		del_from_avail_list(si);
 	}
 }
 
+static void add_to_avail_list(struct swap_info_struct *p)
+{
+	int nid;
+
+	spin_lock(&swap_avail_lock);
+	for_each_node(nid) {
+		WARN_ON(!plist_node_empty(&p->avail_lists[nid]));
+		plist_add(&p->avail_lists[nid], &swap_avail_heads[nid]);
+	}
+	spin_unlock(&swap_avail_lock);
+}
+
 static void swap_range_free(struct swap_info_struct *si, unsigned long offset,
 			    unsigned int nr_entries)
 {
@@ -611,13 +635,8 @@ static void swap_range_free(struct swap_info_struct *si, unsigned long offset,
 		bool was_full = !si->highest_bit;
 
 		si->highest_bit = end;
-		if (was_full && (si->flags & SWP_WRITEOK)) {
-			spin_lock(&swap_avail_lock);
-			WARN_ON(!plist_node_empty(&si->avail_list));
-			if (plist_node_empty(&si->avail_list))
-				plist_add(&si->avail_list, &swap_avail_head);
-			spin_unlock(&swap_avail_lock);
-		}
+		if (was_full && (si->flags & SWP_WRITEOK))
+			add_to_avail_list(si);
 	}
 	atomic_long_add(nr_entries, &nr_swap_pages);
 	si->inuse_pages -= nr_entries;
@@ -898,6 +917,7 @@ int get_swap_pages(int n_goal, bool cluster, swp_entry_t swp_entries[])
 	struct swap_info_struct *si, *next;
 	long avail_pgs;
 	int n_ret = 0;
+	int node;
 
 	/* Only single cluster request supported */
 	WARN_ON_ONCE(n_goal > 1 && cluster);
@@ -917,14 +937,15 @@ int get_swap_pages(int n_goal, bool cluster, swp_entry_t swp_entries[])
 	spin_lock(&swap_avail_lock);
 
 start_over:
-	plist_for_each_entry_safe(si, next, &swap_avail_head, avail_list) {
+	node = numa_node_id();
+	plist_for_each_entry_safe(si, next, &swap_avail_heads[node], avail_lists[node]) {
 		/* requeue si to after same-priority siblings */
-		plist_requeue(&si->avail_list, &swap_avail_head);
+		plist_requeue(&si->avail_lists[node], &swap_avail_heads[node]);
 		spin_unlock(&swap_avail_lock);
 		spin_lock(&si->lock);
 		if (!si->highest_bit || !(si->flags & SWP_WRITEOK)) {
 			spin_lock(&swap_avail_lock);
-			if (plist_node_empty(&si->avail_list)) {
+			if (plist_node_empty(&si->avail_lists[node])) {
 				spin_unlock(&si->lock);
 				goto nextsi;
 			}
@@ -934,7 +955,7 @@ int get_swap_pages(int n_goal, bool cluster, swp_entry_t swp_entries[])
 			WARN(!(si->flags & SWP_WRITEOK),
 			     "swap_info %d in list but !SWP_WRITEOK\n",
 			     si->type);
-			plist_del(&si->avail_list, &swap_avail_head);
+			__del_from_avail_list(si);
 			spin_unlock(&si->lock);
 			goto nextsi;
 		}
@@ -962,7 +983,7 @@ int get_swap_pages(int n_goal, bool cluster, swp_entry_t swp_entries[])
 		 * swap_avail_head list then try it, otherwise start over
 		 * if we have not gotten any slots.
 		 */
-		if (plist_node_empty(&next->avail_list))
+		if (plist_node_empty(&next->avail_lists[node]))
 			goto start_over;
 	}
 
@@ -2226,10 +2247,24 @@ static int setup_swap_extents(struct swap_info_struct *sis, sector_t *span)
 	return generic_swapfile_activate(sis, swap_file, span);
 }
 
+static int swap_node(struct swap_info_struct *p)
+{
+	struct block_device *bdev;
+
+	if (p->bdev)
+		bdev = p->bdev;
+	else
+		bdev = p->swap_file->f_inode->i_sb->s_bdev;
+
+	return bdev ? bdev->bd_disk->node_id : NUMA_NO_NODE;
+}
+
 static void _enable_swap_info(struct swap_info_struct *p, int prio,
 				unsigned char *swap_map,
 				struct swap_cluster_info *cluster_info)
 {
+	int i;
+
 	if (prio >= 0)
 		p->prio = prio;
 	else
@@ -2239,7 +2274,16 @@ static void _enable_swap_info(struct swap_info_struct *p, int prio,
 	 * low-to-high, while swap ordering is high-to-low
 	 */
 	p->list.prio = -p->prio;
-	p->avail_list.prio = -p->prio;
+	for_each_node(i) {
+		if (p->prio >= 0)
+			p->avail_lists[i].prio = -p->prio;
+		else {
+			if (swap_node(p) == i)
+				p->avail_lists[i].prio = 1;
+			else
+				p->avail_lists[i].prio = -p->prio;
+		}
+	}
 	p->swap_map = swap_map;
 	p->cluster_info = cluster_info;
 	p->flags |= SWP_WRITEOK;
@@ -2258,9 +2302,7 @@ static void _enable_swap_info(struct swap_info_struct *p, int prio,
 	 * swap_info_struct.
 	 */
 	plist_add(&p->list, &swap_active_head);
-	spin_lock(&swap_avail_lock);
-	plist_add(&p->avail_list, &swap_avail_head);
-	spin_unlock(&swap_avail_lock);
+	add_to_avail_list(p);
 }
 
 static void enable_swap_info(struct swap_info_struct *p, int prio,
@@ -2345,17 +2387,19 @@ SYSCALL_DEFINE1(swapoff, const char __user *, specialfile)
 		spin_unlock(&swap_lock);
 		goto out_dput;
 	}
-	spin_lock(&swap_avail_lock);
-	plist_del(&p->avail_list, &swap_avail_head);
-	spin_unlock(&swap_avail_lock);
+	del_from_avail_list(p);
 	spin_lock(&p->lock);
 	if (p->prio < 0) {
 		struct swap_info_struct *si = p;
+		int nid;
 
 		plist_for_each_entry_continue(si, &swap_active_head, list) {
 			si->prio++;
 			si->list.prio--;
-			si->avail_list.prio--;
+			for_each_node(nid) {
+				if (si->avail_lists[nid].prio != 1)
+					si->avail_lists[nid].prio--;
+			}
 		}
 		least_priority++;
 	}
@@ -2596,6 +2640,7 @@ static struct swap_info_struct *alloc_swap_info(void)
 {
 	struct swap_info_struct *p;
 	unsigned int type;
+	int i;
 
 	p = kzalloc(sizeof(*p), GFP_KERNEL);
 	if (!p)
@@ -2631,7 +2676,8 @@ static struct swap_info_struct *alloc_swap_info(void)
 	}
 	INIT_LIST_HEAD(&p->first_swap_extent.list);
 	plist_node_init(&p->list, 0);
-	plist_node_init(&p->avail_list, 0);
+	for_each_node(i)
+		plist_node_init(&p->avail_lists[i], 0);
 	p->flags = SWP_USED;
 	spin_unlock(&swap_lock);
 	spin_lock_init(&p->lock);
@@ -3457,3 +3503,18 @@ static void free_swap_count_continuations(struct swap_info_struct *si)
 		}
 	}
 }
+
+static int __init swapfile_init(void)
+{
+	int nid;
+
+	swap_avail_heads = kmalloc(nr_node_ids * sizeof(struct plist_head), GFP_KERNEL);
+	if (!swap_avail_heads)
+		return -ENOMEM;
+
+	for_each_node(nid)
+		plist_head_init(&swap_avail_heads[nid]);
+
+	return 0;
+}
+subsys_initcall(swapfile_init);
-- 
2.13.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
