Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx181.postini.com [74.125.245.181])
	by kanga.kvack.org (Postfix) with SMTP id AED806B004D
	for <linux-mm@kvack.org>; Tue, 24 Jul 2012 05:56:05 -0400 (EDT)
From: Jiang Liu <jiang.liu@huawei.com>
Subject: [RFC PATCH v2] SLUB: enhance slub to handle memory nodes without normal memory
Date: Tue, 24 Jul 2012 17:55:10 +0800
Message-ID: <1343123710-4972-1-git-send-email-jiang.liu@huawei.com>
In-Reply-To: <alpine.DEB.2.00.1207181349370.22907@router.home>
References: <alpine.DEB.2.00.1207181349370.22907@router.home>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux-foundation.org>
Cc: WuJianguo <wujianguo@huawei.com>, Tony Luck <tony.luck@intel.com>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Mel Gorman <mgorman@suse.de>, Yinghai Lu <yinghai@kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan@kernel.org>, Keping Chen <chenkeping@huawei.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Jiang Liu <liuj97@gmail.com>

From: WuJianguo <wujianguo@huawei.com>

When handling a memory node with only movable zone, function
early_kmem_cache_node_alloc() will allocate a page from remote node but
still increase object count on local node, which will trigger a BUG_ON()
as below when hot-removing this memory node. Actually there's no need to
create kmem_cache_node for memory node with only movable zone at all.

------------[ cut here ]------------
kernel BUG at mm/slub.c:3590!
invalid opcode: 0000 [#1] SMP
CPU 61
Modules linked in: autofs4 sunrpc cpufreq_ondemand acpi_cpufreq freq_table
mperf ip6t_REJECT nf_conntrack_ipv6 nf_defrag_ipv6 ip6table_filter ip6_tables
ipv6 vfat fat dm_mirror dm_region_hash dm_log uinput iTCO_wdt
iTCO_vendor_support coretemp hwmon kvm_intel kvm crc32c_intel
ghash_clmulni_intel serio_raw pcspkr cdc_ether usbnet mii i2c_i801 i2c_core sg
lpc_ich mfd_core shpchp ioatdma i7core_edac edac_core igb dca bnx2 ext4
mbcache jbd2 sr_mod cdrom sd_mod crc_t10dif aesni_intel cryptd aes_x86_64
aes_generic bfa scsi_transport_fc scsi_tgt pata_acpi ata_generic ata_piix
megaraid_sas dm_mod [last unloaded: microcode]

Pid: 46287, comm: sh Not tainted 3.5.0-rc4-pgtable-00215-g35f0828-dirty #85
IBM System x3850 X5 -[7143O3G]-/Node 1, Processor Card
RIP: 0010:[<ffffffff81160b2a>]  [<ffffffff81160b2a>]
slab_memory_callback+0x1ba/0x1c0
RSP: 0018:ffff880efdcb7c68  EFLAGS: 00010202
RAX: 0000000000000001 RBX: ffff880f7ec06100 RCX: 0000000100400001
RDX: 0000000100400002 RSI: ffff880f7ec02000 RDI: ffff880f7ec06100
RBP: ffff880efdcb7c78 R08: ffff88107b6fb098 R09: ffffffff81160a00
R10: 0000000000000000 R11: 0000000000000000 R12: 0000000000000019
R13: 00000000fffffffb R14: 0000000000000000 R15: ffffffff81abe930
FS:  00007f709f342700(0000) GS:ffff880f7f3a0000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: 0000003b5a874570 CR3: 0000000f0da20000 CR4: 00000000000007e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process sh (pid: 46287, threadinfo ffff880efdcb6000, task ffff880f0fa50000)
Stack:
 0000000000000004 ffff880efdcb7da8 ffff880efdcb7cb8 ffffffff81524af5
 0000000000000001 ffffffff81a8b620 ffffffff81a8b640 0000000000000004
 ffff880efdcb7da8 00000000ffffffff ffff880efdcb7d08 ffffffff8107a89a
Call Trace:
 [<ffffffff81524af5>] notifier_call_chain+0x55/0x80
 [<ffffffff8107a89a>] __blocking_notifier_call_chain+0x5a/0x80
 [<ffffffff8107a8d6>] blocking_notifier_call_chain+0x16/0x20
 [<ffffffff81352f0b>] memory_notify+0x1b/0x20
 [<ffffffff81507104>] offline_pages+0x624/0x700
 [<ffffffff811619de>] remove_memory+0x1e/0x20
 [<ffffffff813530cc>] memory_block_change_state+0x13c/0x2e0
 [<ffffffff81153e96>] ? alloc_pages_current+0xb6/0x120
 [<ffffffff81353332>] store_mem_state+0xc2/0xd0
 [<ffffffff8133e190>] dev_attr_store+0x20/0x30
 [<ffffffff811e2d4f>] sysfs_write_file+0xef/0x170
 [<ffffffff81173e28>] vfs_write+0xc8/0x190
 [<ffffffff81173ff1>] sys_write+0x51/0x90
 [<ffffffff81528d29>] system_call_fastpath+0x16/0x1b
Code: 8b 3d cb fd c4 00 be d0 00 00 00 e8 71 de ff ff 48 85 c0 75 9c 48 c7 c7
c0 7f a5 81 e8 c0 89 f1 ff b8 0d 80 00 00 e9 69 fe ff ff <0f> 0b eb fe 66 90
55 48 89 e5 41 57 41 56 41 55 41 54 53 48 83
RIP  [<ffffffff81160b2a>] slab_memory_callback+0x1ba/0x1c0
 RSP <ffff880efdcb7c68>
---[ end trace 749e9e9a67c78c12 ]---

Signed-off-by: Jianguo Wu <wujianguo@huawei.com>
Signed-off-by: Jiang Liu <liuj97@gmail.com>
---
 mm/slub.c |   44 +++++++++++++++++++++++++++++++++-----------
 1 files changed, 33 insertions(+), 11 deletions(-)

diff --git a/mm/slub.c b/mm/slub.c
index 8c691fa..3976745 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -2803,6 +2803,17 @@ static inline int alloc_kmem_cache_cpus(struct kmem_cache *s)
 
 static struct kmem_cache *kmem_cache_node;
 
+static bool node_has_normal_memory(int node)
+{
+	int i;
+
+	for (i = ZONE_NORMAL; i >= 0; i--)
+		if (populated_zone(&NODE_DATA(node)->node_zones[i]))
+			return true;
+
+	return false;
+}
+
 /*
  * No kmalloc_node yet so do it by hand. We know that this is the first
  * slab on the node for this slabcache. There are no concurrent accesses
@@ -2866,6 +2877,10 @@ static int init_kmem_cache_nodes(struct kmem_cache *s)
 	for_each_node_state(node, N_NORMAL_MEMORY) {
 		struct kmem_cache_node *n;
 
+		/* Do not create kmem_cache_node for node without normal memory */
+		if (!node_has_normal_memory(node))
+			continue;
+
 		if (slab_state == DOWN) {
 			early_kmem_cache_node_alloc(node);
 			continue;
@@ -3178,9 +3193,11 @@ static inline int kmem_cache_close(struct kmem_cache *s)
 	for_each_node_state(node, N_NORMAL_MEMORY) {
 		struct kmem_cache_node *n = get_node(s, node);
 
-		free_partial(s, n);
-		if (n->nr_partial || slabs_node(s, node))
-			return 1;
+		if (n) {
+			free_partial(s, n);
+			if (n->nr_partial || slabs_node(s, node))
+				return 1;
+		}
 	}
 	free_kmem_cache_nodes(s);
 	return 0;
@@ -3509,7 +3526,7 @@ int kmem_cache_shrink(struct kmem_cache *s)
 	for_each_node_state(node, N_NORMAL_MEMORY) {
 		n = get_node(s, node);
 
-		if (!n->nr_partial)
+		if (!n || !n->nr_partial)
 			continue;
 
 		for (i = 0; i < objects; i++)
@@ -4170,7 +4187,8 @@ static long validate_slab_cache(struct kmem_cache *s)
 	for_each_node_state(node, N_NORMAL_MEMORY) {
 		struct kmem_cache_node *n = get_node(s, node);
 
-		count += validate_slab_node(s, n, map);
+		if (n)
+			count += validate_slab_node(s, n, map);
 	}
 	kfree(map);
 	return count;
@@ -4339,7 +4357,7 @@ static int list_locations(struct kmem_cache *s, char *buf,
 		unsigned long flags;
 		struct page *page;
 
-		if (!atomic_long_read(&n->nr_slabs))
+		if (!n || !atomic_long_read(&n->nr_slabs))
 			continue;
 
 		spin_lock_irqsave(&n->list_lock, flags);
@@ -4534,11 +4552,13 @@ static ssize_t show_slab_objects(struct kmem_cache *s,
 		for_each_node_state(node, N_NORMAL_MEMORY) {
 			struct kmem_cache_node *n = get_node(s, node);
 
-		if (flags & SO_TOTAL)
-			x = atomic_long_read(&n->total_objects);
-		else if (flags & SO_OBJECTS)
-			x = atomic_long_read(&n->total_objects) -
-				count_partial(n, count_free);
+			if (!n)
+				continue;
+			if (flags & SO_TOTAL)
+				x = atomic_long_read(&n->total_objects);
+			else if (flags & SO_OBJECTS)
+				x = atomic_long_read(&n->total_objects) -
+					count_partial(n, count_free);
 
 			else
 				x = atomic_long_read(&n->nr_slabs);
@@ -4552,6 +4572,8 @@ static ssize_t show_slab_objects(struct kmem_cache *s,
 		for_each_node_state(node, N_NORMAL_MEMORY) {
 			struct kmem_cache_node *n = get_node(s, node);
 
+			if (!n)
+				continue;
 			if (flags & SO_TOTAL)
 				x = count_partial(n, count_total);
 			else if (flags & SO_OBJECTS)
-- 
1.7.1


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
