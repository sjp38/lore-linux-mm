Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx204.postini.com [74.125.245.204])
	by kanga.kvack.org (Postfix) with SMTP id 1DAB46B005A
	for <linux-mm@kvack.org>; Tue, 17 Jul 2012 12:52:32 -0400 (EDT)
Received: by pbbrp2 with SMTP id rp2so1326765pbb.14
        for <linux-mm@kvack.org>; Tue, 17 Jul 2012 09:52:31 -0700 (PDT)
From: Jiang Liu <liuj97@gmail.com>
Subject: [PATCH] mm/slub: fix a BUG_ON() when offlining a memory node and CONFIG_SLUB_DEBUG is on
Date: Wed, 18 Jul 2012 00:50:16 +0800
Message-Id: <1342543816-10853-1-git-send-email-jiang.liu@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@kernel.org>, Matt Mackall <mpm@selenic.com>, Mel Gorman <mgorman@suse.de>
Cc: Jianguo Wu <wujianguo@huawei.com>, Jiang Liu <jiang.liu@huawei.com>, Tony Luck <tony.luck@intel.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, David Rientjes <rientjes@google.com>, Minchan Kim <minchan@kernel.org>, Keping Chen <chenkeping@huawei.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Jiang Liu <liuj97@gmail.com>

From: Jianguo Wu <wujianguo@huawei.com>

From: Jianguo Wu <wujianguo@huawei.com>

SLUB allocator may cause a BUG_ON() when offlining a memory node if
CONFIG_SLUB_DEBUG is on. The scenario is:

1) when creating kmem_cache_node slab, it cause inc_slabs_node() twice.
early_kmem_cache_node_alloc
	->new_slab
		->inc_slabs_node
	->inc_slabs_node

2) Later when offlining a memory node, it triggers the BUG_ON() in function
slab_mem_offline_callback() due to the extra inc_slabs_node() in function
early_kmem_cache_node_alloc().
{
		if (n) {
			/*
			 * if n->nr_slabs > 0, slabs still exist on the node
			 * that is going down. We were unable to free them,
			 * and offline_pages() function shouldn't call this
			 * callback. So, we must fail.
			 */
			BUG_ON(slabs_node(s, offline_node));
}

------------[ cut here ]------------
kernel BUG at mm/slub.c:3590!
invalid opcode: 0000 [#1] SMP
CPU 61
Modules linked in: autofs4 sunrpc cpufreq_ondemand acpi_cpufreq freq_table mperf ip6t_REJECT nf_conntrack_ipv6 nf_defrag_ipv6 ip6table_filter ip6_tables ipv6 vfat fat dm_mirror dm_region_hash dm_log uinput iTCO_wdt iTCO_vendor_support coretemp hwmon kvm_intel kvm crc32c_intel ghash_clmulni_intel serio_raw pcspkr cdc_ether usbnet mii i2c_i801 i2c_core sg lpc_ich mfd_core shpchp ioatdma i7core_edac edac_core igb dca bnx2 ext4 mbcache jbd2 sr_mod cdrom sd_mod crc_t10dif aesni_intel cryptd aes_x86_64 aes_generic bfa scsi_transport_fc scsi_tgt pata_acpi ata_generic ata_piix megaraid_sas dm_mod [last unloaded: microcode]

Pid: 46287, comm: sh Not tainted 3.5.0-rc4-pgtable-00215-g35f0828-dirty #85 IBM System x3850 X5 -[7143O3G]-/Node 1, Processor Card
RIP: 0010:[<ffffffff81160b2a>]  [<ffffffff81160b2a>] slab_memory_callback+0x1ba/0x1c0
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
Code: 8b 3d cb fd c4 00 be d0 00 00 00 e8 71 de ff ff 48 85 c0 75 9c 48 c7 c7 c0 7f a5 81 e8 c0 89 f1 ff b8 0d 80 00 00 e9 69 fe ff ff <0f> 0b eb fe 66 90 55 48 89 e5 41 57 41 56 41 55 41 54 53 48 83
RIP  [<ffffffff81160b2a>] slab_memory_callback+0x1ba/0x1c0
 RSP <ffff880efdcb7c68>
---[ end trace 749e9e9a67c78c12 ]---


Signed-off-by: Jianguo Wu <wujianguo@huawei.com>
Signed-off-by: Jiang Liu <liuj97@gmail.com>
---
 mm/slub.c |    1 -
 1 file changed, 1 deletion(-)

diff --git a/mm/slub.c b/mm/slub.c
index 8c691fa..f8276db 100644
--- a/mm/slub.c
+++ b/mm/slub.c
@@ -2840,7 +2840,6 @@ static void early_kmem_cache_node_alloc(int node)
 	init_tracking(kmem_cache_node, n);
 #endif
 	init_kmem_cache_node(n);
-	inc_slabs_node(kmem_cache_node, node, page->objects);
 
 	add_partial(n, page, DEACTIVATE_TO_HEAD);
 }
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
