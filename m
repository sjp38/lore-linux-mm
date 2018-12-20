Return-Path: <linux-kernel-owner@vger.kernel.org>
From: Pingfan Liu <kernelfans@gmail.com>
Subject: [PATCHv2 2/3] mm/numa: build zonelist when alloc for device on offline node
Date: Thu, 20 Dec 2018 17:50:38 +0800
Message-Id: <1545299439-31370-3-git-send-email-kernelfans@gmail.com>
In-Reply-To: <1545299439-31370-1-git-send-email-kernelfans@gmail.com>
References: <1545299439-31370-1-git-send-email-kernelfans@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
To: linux-mm@kvack.org
Cc: Pingfan Liu <kernelfans@gmail.com>, linuxppc-dev@lists.ozlabs.org, x86@kernel.org, linux-kernel@vger.kernel.org, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Bjorn Helgaas <bhelgaas@google.com>, Jonathan Cameron <Jonathan.Cameron@huawei.com>, David Rientjes <rientjes@google.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Borislav Petkov <bp@alien8.de>, "H. Peter Anvin" <hpa@zytor.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, Michael Ellerman <mpe@ellerman.id.au>
List-ID: <linux-mm.kvack.org>

I hit a bug on an AMD machine, with kexec -l nr_cpus=4 option. It is due to
some pgdat is not instanced when specifying nr_cpus, e.g, on x86, not
initialized by init_cpu_to_node()->init_memory_less_node(). But
device->numa_node info is used as preferred_nid param for
__alloc_pages_nodemask(), which causes NULL reference
  ac->zonelist = node_zonelist(preferred_nid, gfp_mask);
Although this bug is detected on x86, it should affect all archs, where
a machine with a numa-node having no memory, if nr_cpus prevents the
instance of the node, and the device on the node tries to allocate memory
with device->numa_node info.
There are two alternative methods to fix the bug.
-1. Make all possible numa nodes be instanced. This should be done for all
archs
-2. Using zonelist instead of pgdat when encountering un-instanced node,
and only do this when needed.
This patch adopts the 2nd method, uses possible_zonelist[] to mirror
node_zonelists[], and tries to build zonelist for the offline node when needed.

Notes about the crashing info:
-1. kexec -l with nr_cpus=4
-2. system info
  NUMA node0 CPU(s):     0,8,16,24
  NUMA node1 CPU(s):     2,10,18,26
  NUMA node2 CPU(s):     4,12,20,28
  NUMA node3 CPU(s):     6,14,22,30
  NUMA node4 CPU(s):     1,9,17,25
  NUMA node5 CPU(s):     3,11,19,27
  NUMA node6 CPU(s):     5,13,21,29
  NUMA node7 CPU(s):     7,15,23,31
-3. panic stack
[...]
[    5.721547] atomic64_test: passed for x86-64 platform with CX8 and with SSE
[    5.729187] pcieport 0000:00:01.1: Signaling PME with IRQ 34
[    5.735187] pcieport 0000:00:01.2: Signaling PME with IRQ 35
[    5.741168] pcieport 0000:00:01.3: Signaling PME with IRQ 36
[    5.747189] pcieport 0000:00:07.1: Signaling PME with IRQ 37
[    5.754061] pcieport 0000:00:08.1: Signaling PME with IRQ 39
[    5.760727] pcieport 0000:20:07.1: Signaling PME with IRQ 40
[    5.766955] pcieport 0000:20:08.1: Signaling PME with IRQ 42
[    5.772742] BUG: unable to handle kernel paging request at 0000000000002088
[    5.773618] PGD 0 P4D 0
[    5.773618] Oops: 0000 [#1] SMP NOPTI
[    5.773618] CPU: 2 PID: 1 Comm: swapper/0 Not tainted 4.20.0-rc1+ #3
[    5.773618] Hardware name: Dell Inc. PowerEdge R7425/02MJ3T, BIOS 1.4.3 06/29/2018
[    5.773618] RIP: 0010:__alloc_pages_nodemask+0xe2/0x2a0
[    5.773618] Code: 00 00 44 89 ea 80 ca 80 41 83 f8 01 44 0f 44 ea 89 da c1 ea 08 83 e2 01 88 54 24 20 48 8b 54 24 08 48 85 d2 0f 85 46 01 00 00 <3b> 77 08 0f 82 3d 01 00 00 48 89 f8 44 89 ea 48 89
e1 44 89 e6 89
[    5.773618] RSP: 0018:ffffaa600005fb20 EFLAGS: 00010246
[    5.773618] RAX: 0000000000000000 RBX: 00000000006012c0 RCX: 0000000000000000
[    5.773618] RDX: 0000000000000000 RSI: 0000000000000002 RDI: 0000000000002080
[    5.773618] RBP: 00000000006012c0 R08: 0000000000000000 R09: 0000000000000002
[    5.773618] R10: 00000000006080c0 R11: 0000000000000002 R12: 0000000000000000
[    5.773618] R13: 0000000000000001 R14: 0000000000000000 R15: 0000000000000002
[    5.773618] FS:  0000000000000000(0000) GS:ffff8c69afe00000(0000) knlGS:0000000000000000
[    5.773618] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[    5.773618] CR2: 0000000000002088 CR3: 000000087e00a000 CR4: 00000000003406e0
[    5.773618] Call Trace:
[    5.773618]  new_slab+0xa9/0x570
[    5.773618]  ___slab_alloc+0x375/0x540
[    5.773618]  ? pinctrl_bind_pins+0x2b/0x2a0
[    5.773618]  __slab_alloc+0x1c/0x38
[    5.773618]  __kmalloc_node_track_caller+0xc8/0x270
[    5.773618]  ? pinctrl_bind_pins+0x2b/0x2a0
[    5.773618]  devm_kmalloc+0x28/0x60
[    5.773618]  pinctrl_bind_pins+0x2b/0x2a0
[    5.773618]  really_probe+0x73/0x420
[    5.773618]  driver_probe_device+0x115/0x130
[    5.773618]  __driver_attach+0x103/0x110
[    5.773618]  ? driver_probe_device+0x130/0x130
[    5.773618]  bus_for_each_dev+0x67/0xc0
[    5.773618]  ? klist_add_tail+0x3b/0x70
[    5.773618]  bus_add_driver+0x41/0x260
[    5.773618]  ? pcie_port_setup+0x4d/0x4d
[    5.773618]  driver_register+0x5b/0xe0
[    5.773618]  ? pcie_port_setup+0x4d/0x4d
[    5.773618]  do_one_initcall+0x4e/0x1d4
[    5.773618]  ? init_setup+0x25/0x28
[    5.773618]  kernel_init_freeable+0x1c1/0x26e
[    5.773618]  ? loglevel+0x5b/0x5b
[    5.773618]  ? rest_init+0xb0/0xb0
[    5.773618]  kernel_init+0xa/0x110
[    5.773618]  ret_from_fork+0x22/0x40
[    5.773618] Modules linked in:
[    5.773618] CR2: 0000000000002088
[    5.773618] ---[ end trace 1030c9120a03d081 ]---
[...]

Other notes about the reproduction of this bug:
After appling the following patch:
'commit 0d76bcc960e6 ("Revert "ACPI/PCI: Pay attention to device-specific
_PXM node values"")'
This bug is covered and not triggered on my test AMD machine.
But it should still exist since dev->numa_node info can be set by other
method on other archs when using nr_cpus param

Signed-off-by: Pingfan Liu <kernelfans@gmail.com>
Cc: linuxppc-dev@lists.ozlabs.org
Cc: x86@kernel.org
Cc: linux-kernel@vger.kernel.org
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Vlastimil Babka <vbabka@suse.cz>
Cc: Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: Bjorn Helgaas <bhelgaas@google.com>
Cc: Jonathan Cameron <Jonathan.Cameron@huawei.com>
Cc: David Rientjes <rientjes@google.com>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Ingo Molnar <mingo@redhat.com>
Cc: Borislav Petkov <bp@alien8.de>
Cc: "H. Peter Anvin" <hpa@zytor.com>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: Paul Mackerras <paulus@samba.org>
Cc: Michael Ellerman <mpe@ellerman.id.au>
---
 include/linux/gfp.h | 10 +++++++++-
 mm/page_alloc.c     | 52 ++++++++++++++++++++++++++++++++++++++++++++++------
 2 files changed, 55 insertions(+), 7 deletions(-)

diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index 0705164..0ddf809 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -442,6 +442,9 @@ static inline int gfp_zonelist(gfp_t flags)
 	return ZONELIST_FALLBACK;
 }
 
+extern struct zonelist *possible_zonelists[];
+extern int build_fallback_zonelists(int node);
+
 /*
  * We get the zone list from the current node and the gfp_mask.
  * This zone list contains a maximum of MAXNODES*MAX_NR_ZONES zones.
@@ -453,7 +456,12 @@ static inline int gfp_zonelist(gfp_t flags)
  */
 static inline struct zonelist *node_zonelist(int nid, gfp_t flags)
 {
-	return NODE_DATA(nid)->node_zonelists + gfp_zonelist(flags);
+	if (unlikely(!possible_zonelists[nid])) {
+		WARN_ONCE(1, "alloc from offline node: %d\n", nid);
+		if (unlikely(build_fallback_zonelists(nid)))
+			nid = first_online_node;
+	}
+	return possible_zonelists[nid] + gfp_zonelist(flags);
 }
 
 #ifndef HAVE_ARCH_FREE_PAGE
diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index 17dbf6e..608b51d 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -121,6 +121,8 @@ nodemask_t node_states[NR_NODE_STATES] __read_mostly = {
 };
 EXPORT_SYMBOL(node_states);
 
+struct zonelist *possible_zonelists[MAX_NUMNODES] __read_mostly;
+
 /* Protect totalram_pages and zone->managed_pages */
 static DEFINE_SPINLOCK(managed_page_count_lock);
 
@@ -5180,7 +5182,6 @@ static int find_next_best_node(int node, nodemask_t *used_node_mask)
 	return best_node;
 }
 
-
 /*
  * Build zonelists ordered by node and zones within node.
  * This results in maximum locality--normal zone overflows into local
@@ -5222,6 +5223,7 @@ static void build_thisnode_zonelists(struct zonelist *node_zonelists,
 	zonerefs->zone_idx = 0;
 }
 
+
 /*
  * Build zonelists ordered by zone and nodes within zones.
  * This results in conserving DMA zone[s] until all Normal memory is
@@ -5229,7 +5231,8 @@ static void build_thisnode_zonelists(struct zonelist *node_zonelists,
  * may still exist in local DMA zone.
  */
 
-static void build_zonelists(struct zonelist *node_zonelists, int local_node)
+static void build_zonelists(struct zonelist *node_zonelists,
+	int local_node, bool exclude_self)
 {
 	static int node_order[MAX_NUMNODES];
 	int node, load, nr_nodes = 0;
@@ -5240,6 +5243,8 @@ static void build_zonelists(struct zonelist *node_zonelists, int local_node)
 	load = nr_online_nodes;
 	prev_node = local_node;
 	nodes_clear(used_mask);
+	if (exclude_self)
+		node_set(local_node, used_mask);
 
 	memset(node_order, 0, sizeof(node_order));
 	while ((node = find_next_best_node(local_node, &used_mask)) >= 0) {
@@ -5258,7 +5263,40 @@ static void build_zonelists(struct zonelist *node_zonelists, int local_node)
 	}
 
 	build_zonelists_in_node_order(node_zonelists, node_order, nr_nodes);
-	build_thisnode_zonelists(node_zonelists, local_node);
+	if (!exclude_self)
+		build_thisnode_zonelists(node_zonelists, local_node);
+	possible_zonelists[local_node] = node_zonelists;
+}
+
+/* this is rare case in which building zonelists for offline node, but
+ * there is dev used on it
+ */
+int build_fallback_zonelists(int node)
+{
+	static DEFINE_SPINLOCK(lock);
+	nodemask_t *used_mask;
+	struct zonelist *zl;
+	int ret = 0;
+
+	spin_lock(&lock);
+	if (unlikely(possible_zonelists[node] != NULL))
+		goto unlock;
+
+	used_mask = kmalloc(sizeof(nodemask_t), GFP_ATOMIC);
+	zl = kmalloc(sizeof(struct zonelist)*MAX_ZONELISTS, GFP_ATOMIC);
+	if (unlikely(!used_mask || !zl)) {
+		ret = -ENOMEM;
+		kfree(used_mask);
+		kfree(zl);
+		goto unlock;
+	}
+
+	__nodes_complement(used_mask, &node_online_map, MAX_NUMNODES);
+	build_zonelists(zl, node, true);
+	kfree(used_mask);
+unlock:
+	spin_unlock(&lock);
+	return ret;
 }
 
 #ifdef CONFIG_HAVE_MEMORYLESS_NODES
@@ -5283,7 +5321,8 @@ static void setup_min_unmapped_ratio(void);
 static void setup_min_slab_ratio(void);
 #else	/* CONFIG_NUMA */
 
-static void build_zonelists(struct zonelist *node_zonelists, int local_node)
+static void build_zonelists(struct zonelist *node_zonelists,
+	int local_node, bool _unused)
 {
 	int node, local_node;
 	struct zoneref *zonerefs;
@@ -5357,12 +5396,13 @@ static void __build_all_zonelists(void *data)
 	 * building zonelists is fine - no need to touch other nodes.
 	 */
 	if (self && !node_online(self->node_id)) {
-		build_zonelists(self->node_zonelists, self->node_id);
+		build_zonelists(self->node_zonelists, self->node_id, false);
 	} else {
 		for_each_online_node(nid) {
 			pg_data_t *pgdat = NODE_DATA(nid);
 
-			build_zonelists(pgdat->node_zonelists, pgdat->node_id);
+			build_zonelists(pgdat->node_zonelists, pgdat->node_id,
+				false);
 		}
 
 #ifdef CONFIG_HAVE_MEMORYLESS_NODES
-- 
2.7.4
