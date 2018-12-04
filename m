Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f199.google.com (mail-pg1-f199.google.com [209.85.215.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2F7506B6C7B
	for <linux-mm@kvack.org>; Mon,  3 Dec 2018 22:06:14 -0500 (EST)
Received: by mail-pg1-f199.google.com with SMTP id f9so8127123pgs.13
        for <linux-mm@kvack.org>; Mon, 03 Dec 2018 19:06:14 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v12sor21549609pfj.17.2018.12.03.19.06.12
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 03 Dec 2018 19:06:12 -0800 (PST)
From: Pingfan Liu <kernelfans@gmail.com>
Subject: [PATCH] mm/alloc: fallback to first node if the wanted node offline
Date: Tue,  4 Dec 2018 11:05:57 +0800
Message-Id: <1543892757-4323-1-git-send-email-kernelfans@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Pingfan Liu <kernelfans@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Vlastimil Babka <vbabka@suse.cz>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Bjorn Helgaas <bhelgaas@google.com>, Jonathan Cameron <Jonathan.Cameron@huawei.com>

During my test on some AMD machine, with kexec -l nr_cpus=x option, the
kernel failed to bootup, because some node's data struct can not be allocated,
e.g, on x86, initialized by init_cpu_to_node()->init_memory_less_node(). But
device->numa_node info is used as preferred_nid param for
__alloc_pages_nodemask(), which causes NULL reference
  ac->zonelist = node_zonelist(preferred_nid, gfp_mask);
This patch tries to fix the issue by falling back to the first online node,
when encountering such corner case.

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
commit 0d76bcc960e6057750fcf556b65da13f8bbdfd2b
Author: Bjorn Helgaas <bhelgaas@google.com>
Date:   Tue Nov 13 08:38:17 2018 -0600

    Revert "ACPI/PCI: Pay attention to device-specific _PXM node values"

This bug is covered and not triggered on my test AMD machine.
But it should still exist since dev->numa_node info can be set by other
method on other archs when using nr_cpus param

Signed-off-by: Pingfan Liu <kernelfans@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Michal Hocko <mhocko@suse.com>
Cc: Vlastimil Babka <vbabka@suse.cz>
Cc: Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: Bjorn Helgaas <bhelgaas@google.com>
Cc: Jonathan Cameron <Jonathan.Cameron@huawei.com>
---
 include/linux/gfp.h | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/include/linux/gfp.h b/include/linux/gfp.h
index 76f8db0..8324953 100644
--- a/include/linux/gfp.h
+++ b/include/linux/gfp.h
@@ -453,6 +453,8 @@ static inline int gfp_zonelist(gfp_t flags)
  */
 static inline struct zonelist *node_zonelist(int nid, gfp_t flags)
 {
+	if (unlikely(!node_online(nid)))
+		nid = first_online_node;
 	return NODE_DATA(nid)->node_zonelists + gfp_zonelist(flags);
 }
 
-- 
2.7.4
