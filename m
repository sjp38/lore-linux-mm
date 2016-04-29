Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id 483B06B0005
	for <linux-mm@kvack.org>; Fri, 29 Apr 2016 04:34:11 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id dx6so158424481pad.0
        for <linux-mm@kvack.org>; Fri, 29 Apr 2016 01:34:11 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTP id q187si15228074pfb.220.2016.04.29.01.34.09
        for <linux-mm@kvack.org>;
        Fri, 29 Apr 2016 01:34:10 -0700 (PDT)
Date: Fri, 29 Apr 2016 16:34:08 +0800
From: Aaron Lu <aaron.lu@intel.com>
Subject: [RFC PATCH] swap: choose swap device according to numa node
Message-ID: <20160429083408.GA20728@aaronlu.sh.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux MM <linux-mm@kvack.org>
Cc: "Chen, Tim C" <tim.c.chen@intel.com>, Huang Ying <ying.huang@intel.com>

If the system has more than one swap device and swap device has the node
information, we can make use of this information to decide which swap
device to use in get_swap_page.

The current code uses a priority based list, swap_avail_list, to decide
which swap device to use each time and if multiple swap devices share
the same priority, they are used round robin. This patch change the
previous single global swap_avail_list into a per-numa-node list, i.e.
for each numa node, it sees its own priority based list of available
swap devices. This will require checking a swap device's node value
during swap on time and then promote its priority(more on thie below)
in the swap_avail_list according to which node's list it is being added
to. Once this is done, there should be little, if not none, cost in
get_swap_page time.

The current swap device's priority is set as: user can set a >=0 value,
or the system will pick one by starting from -1 then downwards.
And the priority value in the swap_avail_list is the negated value of
the swap device's priority due to plist is sorted from low to high. The
new policy doesn't change the semantics for priority >=0 cases, the
previous starting from -1 then downwards now becomes starting from -2
then downwards. -1 is reserved as the promoted value.

Take an 4-node EX machine as an example, suppose 4 swap devices are
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
And their positions in the 4 swap_avail_lists[node] will be:
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

The test case used is:
https://git.kernel.org/cgit/linux/kernel/git/wfg/vm-scalability.git/tree/case-swap-w-seq
https://git.kernel.org/cgit/linux/kernel/git/wfg/vm-scalability.git/tree/usemem.c
What the test does is: start N process, each map a region of anonymous
space and then write to it sequentially to trigger swap outs.
On Haswell EP 2 node machine with 128GiB memory, two persistent memory
devices are created, each with a size of 48GiB sitting on a different
node are used as swap devices, they are swapped on without being
specified a priority value and the test result is:
1 task/write size is around 95GiB
throughput of v4.5: 1475358.0
throughput of the patch: 1751160.0
18% increase in throughput
16 task/write size of each is around 6.6GiB
throughput of v4.5: 2148972.4
throughput of the patch: 5713310.0
165% increase in throughput

The huge increase is partly due to the lock contention on the single
swapper_space's radix tree lock since v4.5 will always use the higher
priority swap device till it's full before using another one. Setting
them with the same priority could avoid this, so here are the results
considering this case:
1 task/write size is around 95GiB
throughput of v4.5: 1475358.0
throughput of v4.5(swap device with equal priority): 1707893.4
throughput of the patch: 1751160.0
almost the same for the latter two
16 task/write size of each is around 6.6GiB
throughput of v4.5: 2148972.4
throughput of v4.5(swap device with equal priority): 3804688.25
throughput of the patch: 5713310.0
increase reduced to 50%

Comments are appreciated.

Signed-off-by: Aaron Lu <aaron.lu@intel.com>
---
 include/linux/swap.h |  4 +--
 mm/swap.c            | 12 +++++++-
 mm/swapfile.c        | 81 ++++++++++++++++++++++++++++++++++------------------
 mm/vmscan.c          |  6 ++--
 4 files changed, 71 insertions(+), 32 deletions(-)

diff --git a/include/linux/swap.h b/include/linux/swap.h
index d18b65c53dbb..eafda3ac42eb 100644
--- a/include/linux/swap.h
+++ b/include/linux/swap.h
@@ -207,7 +207,7 @@ struct swap_info_struct {
 	unsigned long	flags;		/* SWP_USED etc: see above */
 	signed short	prio;		/* swap priority of this type */
 	struct plist_node list;		/* entry in swap_active_head */
-	struct plist_node avail_list;	/* entry in swap_avail_head */
+	struct plist_node avail_lists[MAX_NUMNODES];	/* entry in swap_avail_head */
 	signed char	type;		/* strange name for an index */
 	unsigned int	max;		/* extent of the swap_map */
 	unsigned char *swap_map;	/* vmalloc'ed array of usage counts */
@@ -308,7 +308,7 @@ extern void lru_add_drain_all(void);
 extern void rotate_reclaimable_page(struct page *page);
 extern void deactivate_file_page(struct page *page);
 extern void deactivate_page(struct page *page);
-extern void swap_setup(void);
+extern int swap_setup(void);
 
 extern void add_page_to_unevictable_list(struct page *page);
 
diff --git a/mm/swap.c b/mm/swap.c
index 09fe5e97714a..fad3368bb0d1 100644
--- a/mm/swap.c
+++ b/mm/swap.c
@@ -943,14 +943,22 @@ EXPORT_SYMBOL(pagevec_lookup_tag);
 /*
  * Perform any setup for the swap system
  */
-void __init swap_setup(void)
+int __init swap_setup(void)
 {
 	unsigned long megs = totalram_pages >> (20 - PAGE_SHIFT);
 #ifdef CONFIG_SWAP
 	int i;
+	extern struct plist_head *swap_avail_heads;
 
 	for (i = 0; i < MAX_SWAPFILES; i++)
 		spin_lock_init(&swapper_spaces[i].tree_lock);
+
+	swap_avail_heads = kmalloc(nr_node_ids * sizeof(struct plist_head), GFP_KERNEL);
+	if (!swap_avail_heads)
+		return -ENOMEM;
+
+	for (i = 0; i < nr_node_ids; i++)
+		plist_head_init(&swap_avail_heads[i]);
 #endif
 
 	/* Use a smaller cluster for small-memory machines */
@@ -962,4 +970,6 @@ void __init swap_setup(void)
 	 * Right now other parts of the system means that we
 	 * _really_ don't want to cluster much more
 	 */
+
+	return 0;
 }
diff --git a/mm/swapfile.c b/mm/swapfile.c
index d2c37365e2d6..7f154f03eea6 100644
--- a/mm/swapfile.c
+++ b/mm/swapfile.c
@@ -50,7 +50,7 @@ static unsigned int nr_swapfiles;
 atomic_long_t nr_swap_pages;
 /* protected with swap_lock. reading in vm_swap_full() doesn't need lock */
 long total_swap_pages;
-static int least_priority;
+static int least_priority = -1;
 
 static const char Bad_file[] = "Bad swap file entry ";
 static const char Unused_file[] = "Unused swap file entry ";
@@ -75,7 +75,7 @@ PLIST_HEAD(swap_active_head);
  * is held and the locking order requires swap_lock to be taken
  * before any swap_info_struct->lock.
  */
-static PLIST_HEAD(swap_avail_head);
+struct plist_head *swap_avail_heads;
 static DEFINE_SPINLOCK(swap_avail_lock);
 
 struct swap_info_struct *swap_info[MAX_SWAPFILES];
@@ -481,6 +481,16 @@ new_cluster:
 	*scan_base = tmp;
 }
 
+static void del_from_avail_list(struct swap_info_struct *p)
+{
+	int i;
+
+	spin_lock(&swap_avail_lock);
+	for (i = 0; i < nr_node_ids; i++)
+		plist_del(&p->avail_lists[i], &swap_avail_heads[i]);
+	spin_unlock(&swap_avail_lock);
+}
+
 static unsigned long scan_swap_map(struct swap_info_struct *si,
 				   unsigned char usage)
 {
@@ -583,9 +593,7 @@ checks:
 	if (si->inuse_pages == si->pages) {
 		si->lowest_bit = si->max;
 		si->highest_bit = 0;
-		spin_lock(&swap_avail_lock);
-		plist_del(&si->avail_list, &swap_avail_head);
-		spin_unlock(&swap_avail_lock);
+		del_from_avail_list(si);
 	}
 	si->swap_map[offset] = usage;
 	inc_cluster_info_page(si, si->cluster_info, offset);
@@ -637,22 +645,24 @@ swp_entry_t get_swap_page(void)
 {
 	struct swap_info_struct *si, *next;
 	pgoff_t offset;
+	int node;
 
 	if (atomic_long_read(&nr_swap_pages) <= 0)
 		goto noswap;
 	atomic_long_dec(&nr_swap_pages);
 
 	spin_lock(&swap_avail_lock);
+	node = numa_node_id();
 
 start_over:
-	plist_for_each_entry_safe(si, next, &swap_avail_head, avail_list) {
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
@@ -662,7 +672,7 @@ start_over:
 			WARN(!(si->flags & SWP_WRITEOK),
 			     "swap_info %d in list but !SWP_WRITEOK\n",
 			     si->type);
-			plist_del(&si->avail_list, &swap_avail_head);
+			plist_del(&si->avail_lists[node], &swap_avail_heads[node]);
 			spin_unlock(&si->lock);
 			goto nextsi;
 		}
@@ -686,7 +696,7 @@ nextsi:
 		 * list may have been modified; so if next is still in the
 		 * swap_avail_head list then try it, otherwise start over.
 		 */
-		if (plist_node_empty(&next->avail_list))
+		if (plist_node_empty(&next->avail_lists[node]))
 			goto start_over;
 	}
 
@@ -755,6 +765,17 @@ out:
 	return NULL;
 }
 
+static void add_to_avail_list(struct swap_info_struct *p)
+{
+	int i;
+
+	spin_lock(&swap_avail_lock);
+	WARN_ON(!plist_node_empty(&p->avail_lists[0]));
+	for (i = 0; i < nr_node_ids; i++)
+		plist_add(&p->avail_lists[i], &swap_avail_heads[i]);
+	spin_unlock(&swap_avail_lock);
+}
+
 static unsigned char swap_entry_free(struct swap_info_struct *p,
 				     swp_entry_t entry, unsigned char usage)
 {
@@ -797,14 +818,8 @@ static unsigned char swap_entry_free(struct swap_info_struct *p,
 		if (offset > p->highest_bit) {
 			bool was_full = !p->highest_bit;
 			p->highest_bit = offset;
-			if (was_full && (p->flags & SWP_WRITEOK)) {
-				spin_lock(&swap_avail_lock);
-				WARN_ON(!plist_node_empty(&p->avail_list));
-				if (plist_node_empty(&p->avail_list))
-					plist_add(&p->avail_list,
-						  &swap_avail_head);
-				spin_unlock(&swap_avail_lock);
-			}
+			if (was_full && (p->flags & SWP_WRITEOK))
+				add_to_avail_list(p);
 		}
 		atomic_long_inc(&nr_swap_pages);
 		p->inuse_pages--;
@@ -1772,6 +1787,8 @@ static void _enable_swap_info(struct swap_info_struct *p, int prio,
 				unsigned char *swap_map,
 				struct swap_cluster_info *cluster_info)
 {
+	int i;
+
 	if (prio >= 0)
 		p->prio = prio;
 	else
@@ -1781,7 +1798,16 @@ static void _enable_swap_info(struct swap_info_struct *p, int prio,
 	 * low-to-high, while swap ordering is high-to-low
 	 */
 	p->list.prio = -p->prio;
-	p->avail_list.prio = -p->prio;
+	for (i = 0; i < nr_node_ids; i++) {
+		if (p->prio >= 0)
+			p->avail_lists[i].prio = -p->prio;
+		else {
+			if (p->bdev && p->bdev->bd_disk->node_id == i)
+				p->avail_lists[i].prio = 1;
+			else
+				p->avail_lists[i].prio = -p->prio;
+		}
+	}
 	p->swap_map = swap_map;
 	p->cluster_info = cluster_info;
 	p->flags |= SWP_WRITEOK;
@@ -1800,9 +1826,7 @@ static void _enable_swap_info(struct swap_info_struct *p, int prio,
 	 * swap_info_struct.
 	 */
 	plist_add(&p->list, &swap_active_head);
-	spin_lock(&swap_avail_lock);
-	plist_add(&p->avail_list, &swap_avail_head);
-	spin_unlock(&swap_avail_lock);
+	add_to_avail_list(p);
 }
 
 static void enable_swap_info(struct swap_info_struct *p, int prio,
@@ -1876,17 +1900,18 @@ SYSCALL_DEFINE1(swapoff, const char __user *, specialfile)
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
+		int i;
 
 		plist_for_each_entry_continue(si, &swap_active_head, list) {
 			si->prio++;
 			si->list.prio--;
-			si->avail_list.prio--;
+			for (i = 0; i < nr_node_ids; i++)
+				if (si->avail_lists[i].prio != 1)
+					si->avail_lists[i].prio--;
 		}
 		least_priority++;
 	}
@@ -2121,6 +2146,7 @@ static struct swap_info_struct *alloc_swap_info(void)
 {
 	struct swap_info_struct *p;
 	unsigned int type;
+	int i;
 
 	p = kzalloc(sizeof(*p), GFP_KERNEL);
 	if (!p)
@@ -2156,7 +2182,8 @@ static struct swap_info_struct *alloc_swap_info(void)
 	}
 	INIT_LIST_HEAD(&p->first_swap_extent.list);
 	plist_node_init(&p->list, 0);
-	plist_node_init(&p->avail_list, 0);
+	for (i = 0; i < nr_node_ids; i++)
+		plist_node_init(&p->avail_lists[i], 0);
 	p->flags = SWP_USED;
 	spin_unlock(&swap_lock);
 	spin_lock_init(&p->lock);
diff --git a/mm/vmscan.c b/mm/vmscan.c
index 71b1c29948db..dd7e44a315b0 100644
--- a/mm/vmscan.c
+++ b/mm/vmscan.c
@@ -3659,9 +3659,11 @@ void kswapd_stop(int nid)
 
 static int __init kswapd_init(void)
 {
-	int nid;
+	int nid, err;
 
-	swap_setup();
+	err = swap_setup();
+	if (err)
+		return err;
 	for_each_node_state(nid, N_MEMORY)
  		kswapd_run(nid);
 	hotcpu_notifier(cpu_callback, 0);
-- 
2.5.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
