Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f42.google.com (mail-la0-f42.google.com [209.85.215.42])
	by kanga.kvack.org (Postfix) with ESMTP id B169E82F99
	for <linux-mm@kvack.org>; Fri,  2 Oct 2015 06:18:25 -0400 (EDT)
Received: by lafb9 with SMTP id b9so1729347laf.0
        for <linux-mm@kvack.org>; Fri, 02 Oct 2015 03:18:25 -0700 (PDT)
Received: from forward-corp1o.mail.yandex.net (forward-corp1o.mail.yandex.net. [2a02:6b8:0:1a2d::1010])
        by mx.google.com with ESMTPS id l8si4451065lfb.29.2015.10.02.03.18.24
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 02 Oct 2015 03:18:24 -0700 (PDT)
Subject: [PATCH] ovs: do not allocate memory from offline numa node
From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Date: Fri, 02 Oct 2015 13:18:22 +0300
Message-ID: <20151002101822.12499.27658.stgit@buzz>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: dev@openvswitch.org, Pravin Shelar <pshelar@nicira.com>, "David S. Miller" <davem@davemloft.net>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org

When openvswitch tries allocate memory from offline numa node 0:
stats = kmem_cache_alloc_node(flow_stats_cache, GFP_KERNEL | __GFP_ZERO, 0)
It catches VM_BUG_ON(nid < 0 || nid >= MAX_NUMNODES || !node_online(nid))
[ replaced with VM_WARN_ON(!node_online(nid)) recently ] in linux/gfp.h
This patch disables numa affinity in this case.

Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>

---

<4>[   24.368805] ------------[ cut here ]------------
<2>[   24.368846] kernel BUG at include/linux/gfp.h:325!
<4>[   24.368868] invalid opcode: 0000 [#1] SMP
<4>[   24.368892] Modules linked in: openvswitch vxlan udp_tunnel ip6_udp_tunnel gre libcrc32c kvm_amd kvm crc32_pclmul ghash_clmulni_intel aesni_intel ablk_helper cryptd lrw mgag200 ttm drm_kms_helper drm gf128mul glue_helper serio_raw aes_x86_64 sysimgblt sysfillrect syscopyarea sp5100_tco amd64_edac_mod edac_core edac_mce_amd i2c_piix4 k10temp fam15h_power microcode raid10 raid456 async_raid6_recov async_memcpy async_pq async_xor async_tx xor raid6_pq raid1 raid0 igb multipath i2c_algo_bit i2c_core linear dca psmouse ptp ahci pata_atiixp pps_core libahci
<4>[   24.369225] CPU: 22 PID: 987 Comm: ovs-vswitchd Not tainted 3.18.19-24 #1
<4>[   24.369255] Hardware name: Supermicro H8DGU/H8DGU, BIOS 3.0b       05/07/2013
<4>[   24.369286] task: ffff8807f2433240 ti: ffff8807ec9a0000 task.ti: ffff8807ec9a0000
<4>[   24.369317] RIP: 0010:[<ffffffff8119da34>]  [<ffffffff8119da34>] new_slab+0x2d4/0x380
<4>[   24.369359] RSP: 0018:ffff8807ec9a35d8  EFLAGS: 00010246
<4>[   24.369383] RAX: 0000000000000000 RBX: ffff8807ff403c00 RCX: 0000000000000000
<4>[   24.369412] RDX: 0000000000000000 RSI: 0000000000000000 RDI: 00000000002012d0
<4>[   24.369441] RBP: ffff8807ec9a3608 R08: ffff8807f193cfe0 R09: 000000010080000a
<4>[   24.369471] R10: 00000000f193cf01 R11: 0000000000015f38 R12: 0000000000000000
<4>[   24.369501] R13: 0000000000000080 R14: 0000000000000000 R15: 00000000000000d0
<4>[   24.369531] FS:  00007febb0cbe980(0000) GS:ffff8807ffd80000(0000) knlGS:0000000000000000
<4>[   24.369563] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
<4>[   24.369588] CR2: 00007efc53abc1b8 CR3: 00000007f213f000 CR4: 00000000000407e0
<4>[   24.369618] Stack:
<4>[   24.369630]  ffff8807ec9a3618 0000000000000000 0000000000000000 ffff8807ffd958c0
<4>[   24.369669]  ffff8807ff403c00 00000000000080d0 ffff8807ec9a36f8 ffffffff816cc548
<4>[   24.370755]  ffff8807ec9a3708 0000000000000296 0000000000000004 0000000000000000
<4>[   24.371777] Call Trace:
<4>[   24.372929]  [<ffffffff816cc548>] __slab_alloc+0x33b/0x459
<4>[   24.374179]  [<ffffffffa0192a09>] ? ovs_flow_alloc+0x59/0x110 [openvswitch]
<4>[   24.375390]  [<ffffffff8114da93>] ? get_page_from_freelist+0x483/0x9f0
<4>[   24.376623]  [<ffffffff8136b15e>] ? memzero_explicit+0xe/0x10
<4>[   24.377767]  [<ffffffffa0192a09>] ? ovs_flow_alloc+0x59/0x110 [openvswitch]
<4>[   24.378951]  [<ffffffff8119e12c>] kmem_cache_alloc_node+0x9c/0x1b0
<4>[   24.379916]  [<ffffffff8119f08b>] ? kmem_cache_alloc+0x18b/0x1a0
<4>[   24.390806]  [<ffffffffa01929cd>] ? ovs_flow_alloc+0x1d/0x110 [openvswitch]
<4>[   24.391779]  [<ffffffffa0192a09>] ovs_flow_alloc+0x59/0x110 [openvswitch]
<4>[   24.392875]  [<ffffffffa018b18b>] ovs_flow_cmd_new+0x5b/0x360 [openvswitch]
<4>[   24.394004]  [<ffffffff8114e16c>] ? __alloc_pages_nodemask+0x16c/0xaf0
<4>[   24.394973]  [<ffffffff815bba77>] ? __alloc_skb+0x87/0x2a0
<4>[   24.395926]  [<ffffffff8138b240>] ? nla_parse+0x90/0x110
<4>[   24.476276]  [<ffffffff815fe453>] genl_family_rcv_msg+0x373/0x3d0
<4>[   24.477704]  [<ffffffff811a09dc>] ? __kmalloc_node_track_caller+0x6c/0x220
<4>[   24.478859]  [<ffffffff815fe4f4>] genl_rcv_msg+0x44/0x80
<4>[   24.479987]  [<ffffffff815fe4b0>] ? genl_family_rcv_msg+0x3d0/0x3d0
<4>[   24.481325]  [<ffffffff815fda49>] netlink_rcv_skb+0xb9/0xe0
<4>[   24.482466]  [<ffffffff815fdd6c>] genl_rcv+0x2c/0x40
<4>[   24.483554]  [<ffffffff815fd04b>] netlink_unicast+0x12b/0x1c0
<4>[   24.484739]  [<ffffffff815fd472>] netlink_sendmsg+0x392/0x6d0
<4>[   24.485942]  [<ffffffff815b2f9f>] sock_sendmsg+0xaf/0xc0
<4>[   24.486953]  [<ffffffff815fd2e2>] ? netlink_sendmsg+0x202/0x6d0
<4>[   24.487969]  [<ffffffff815b3622>] ___sys_sendmsg.part.19+0x322/0x330
<4>[   24.489167]  [<ffffffff815b3839>] ? SYSC_sendto+0xf9/0x130
<4>[   24.490217]  [<ffffffff815b367a>] ___sys_sendmsg+0x4a/0x70
<4>[   24.491162]  [<ffffffff815b40c9>] __sys_sendmsg+0x49/0x90
<4>[   24.492082]  [<ffffffff815b4129>] SyS_sendmsg+0x19/0x20
<4>[   24.493181]  [<ffffffff816d6c09>] system_call_fastpath+0x12/0x17
<4>[   24.494124] Code: 40 e9 ea fe ff ff 90 e8 6b 69 ff ff 49 89 c4 e9 07 fe ff ff 4c 89 f7 ff d0 e9 26 ff ff ff 49 c7 04 06 00 00 00 00 e9 3c ff ff ff <0f> 0b ba 00 10 00 00 be 5a 00 00 00 4c 89 ef 48 d3 e2 e8 65 2a
<1>[   24.496071] RIP  [<ffffffff8119da34>] new_slab+0x2d4/0x380
<4>[   24.497152]  RSP <ffff8807ec9a35d8>
<4>[   24.498945] ---[ end trace 6f97360ff4a9ee45 ]---
---
 net/openvswitch/flow_table.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/openvswitch/flow_table.c b/net/openvswitch/flow_table.c
index f2ea83ba4763..c7f74aab34b9 100644
--- a/net/openvswitch/flow_table.c
+++ b/net/openvswitch/flow_table.c
@@ -93,7 +93,8 @@ struct sw_flow *ovs_flow_alloc(void)
 
 	/* Initialize the default stat node. */
 	stats = kmem_cache_alloc_node(flow_stats_cache,
-				      GFP_KERNEL | __GFP_ZERO, 0);
+				      GFP_KERNEL | __GFP_ZERO,
+				      node_online(0) ? 0 : NUMA_NO_NODE);
 	if (!stats)
 		goto err;
 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
