Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id A7C6D620002
	for <linux-mm@kvack.org>; Wed, 23 Dec 2009 06:24:03 -0500 (EST)
Message-ID: <4B31FDCF.9050208@linux.intel.com>
Date: Wed, 23 Dec 2009 19:23:59 +0800
From: Haicheng Li <haicheng.li@linux.intel.com>
MIME-Version: 1.0
Subject: Re: [PATCH] slab: initialize unused alien cache entry as NULL at
 alloc_alien_cache().
References: <4B30BDA8.1070904@linux.intel.com> <alpine.DEB.2.00.0912220945250.12048@router.home> <4B31BE44.1070308@linux.intel.com> <4B31EC7C.7000302@gmail.com> <20091223102343.GD20539@basil.fritz.box>
In-Reply-To: <20091223102343.GD20539@basil.fritz.box>
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andi Kleen <andi@firstfloor.org>
Cc: Eric Dumazet <eric.dumazet@gmail.com>, Christoph Lameter <cl@linux-foundation.org>, linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>, Matt Mackall <mpm@selenic.com>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

Andi Kleen wrote:
>> Then, this is a violation of the first statement :
>>
>> nr_node_ids = 1 + nid of highest POSSIBLE node.
>>
>> If your system allows hotplugging of new nodes, then POSSIBLE nodes should include them
>> at boot time.
> 
> Agreed, nr_node_ids must be possible nodes.
> 
> It should have been set up by the SRAT parser (modulo regressions)
> 
> Haicheng, did you verify with printk it's really incorrect at this point?

Yup. See below debug patch & Oops info.

If we can make sure that SRAT parser must be able to detect out all possible node (even 
the node, cpu+mem, is not populated on the motherboard), it would be ACPI Parser issue or 
BIOS issue rather than a slab issue. In such case, I think this patch might become a 
workaround for buggy system board; and we might need to look into ACPI SRAT parser code as 
well:).


---
diff --git a/mm/slab.c b/mm/slab.c
index 7dfa481..3a4e1f4 100644
--- a/mm/slab.c
+++ b/mm/slab.c
@@ -1032,6 +1032,9 @@ static void reap_alien(struct kmem_cache *cachep, struct kmem_list3 *l3)
  	if (l3->alien) {
  		struct array_cache *ac = l3->alien[node];

+		if (node >= nr_node_ids)
+			printk("node=%d, nr_node_ids=%d, ac=%p\n",
+				node, nr_node_ids, ac);
  		if (ac && ac->avail && spin_trylock_irq(&ac->lock)) {
  			__drain_alien_cache(cachep, ac, node);
  			spin_unlock_irq(&ac->lock);


---
[  151.732864] node=3, nr_node_ids=2, ac=(null)
[  151.732873] node=3, nr_node_ids=2, ac=(null)
[  151.732882] node=3, nr_node_ids=2, ac=(null)
[  151.732889] node=3, nr_node_ids=2, ac=(null)
[  151.732897] node=3, nr_node_ids=2, ac=000000004b31f78f
[  151.732941] BUG: unable to handle kernel paging request at 000000004b31f78f
[  151.741026] IP: [<ffffffff810bd460>] cache_reap+0x8d/0x252
[  151.747363] PGD 0
[  151.749793] Oops: 0000 [#1] SMP
[  151.753658] last sysfs file: /sys/kernel/kexec_crash_loaded
[  151.759990] CPU
[  151.762509] Modules linked in: ipv6 autofs4 rfcomm l2cap crc16 bluetooth rfkill 
binfmt_misc dm_mirror dm_region_hash dm_log dm_multipath dm_mod video output sbs sbshc fan 
battery ac parport_pc lp parport joydev usbhid sr_mod cdrom processor thermal thermal_sys 
container button rtc_cmos rtc_core rtc_lib i2c_i801 i2c_core pcspkr uhci_hcd ohci_hcd 
ehci_hcd usbcore
[  151.802035] Pid: 120, comm: events/21 Not tainted 2.6.32-haicheng-cpuhp #34 Server
[  151.810911] RIP: 0010:[<ffffffff810bd460>]  [<ffffffff810bd460>] cache_reap+0x8d/0x252
[  151.815485] RSP: 0018:ffff88027e81ddf0  EFLAGS: 00010202
[  151.815491] RAX: 000000000000003d RBX: 000000004b31f78f RCX: 0000000000000000
[  151.815496] RDX: ffff88027f3f5040 RSI: 0000000000000001 RDI: 0000000000000286
[  151.815503] RBP: ffff88027e81de30 R08: 0000000000000002 R09: ffffffff8105ee06
[  151.815507] R10: ffff88027e81dbe0 R11: ffffffff81066722 R12: ffff88047f223080
[  151.815513] R13: ffff88047dd201c0 R14: 0000000000000003 R15: fffffffff00000c6
[  151.815518] FS:  0000000000000000(0000) GS:ffff88028b540000(0000) knlGS:0000000000000000
[  151.815524] CS:  0010 DS: 0018 ES: 0018 CR0: 000000008005003b
[  151.815528] CR2: 000000004b31f78f CR3: 0000000001001000 CR4: 00000000000006e0
[  151.815533] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[  151.815538] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[  151.815547] Process events/21 (pid: 120, threadinfo ffff88027e81c000, task 
ffff88027f3f5040)
[  151.815550] Stack:
[  151.817896]  ffff88027e81de30 ffff88028b5517c0 0000000100000000 ffff88027e81de80
[  151.817908] <0> ffff88028b556d80 ffff88028b5517c0 ffffffff810bd3d3 fffffffff00000c6
[  151.817918] <0> ffff88027e81dec0 ffffffff81058d0c ffffffff81058cb6 ffffffff81376fea
[  151.817928] Call Trace:
[  151.820772]  [<ffffffff810bd3d3>] ? cache_reap+0x0/0x252
[  151.820786]  [<ffffffff81058d0c>] worker_thread+0x17a/0x27b
[  151.820793]  [<ffffffff81058cb6>] ? worker_thread+0x124/0x27b
[  151.820806]  [<ffffffff81376fea>] ? thread_return+0x3e/0xee
[  151.820816]  [<ffffffff8105bbbc>] ? autoremove_wake_function+0x0/0x38
[  151.820827]  [<ffffffff81058b92>] ? worker_thread+0x0/0x27b
[  151.820833]  [<ffffffff8105babe>] kthread+0x7d/0x87
[  151.820848]  [<ffffffff81012daa>] child_rip+0xa/0x20
[  151.820857]  [<ffffffff81012710>] ? restore_args+0x0/0x30
[  151.820863]  [<ffffffff8105ba41>] ? kthread+0x0/0x87
[  151.820874]  [<ffffffff81012da0>] ? child_rip+0x0/0x20
[  151.820879] Code: 77 48 63 c6 41 89 f6 48 8b 1c c2 8b 15 be 28 6e 00 39 d6 7c 11 48 89 
d9 48 c7 c7 97 98 4c 81 31 c0 e8 23 bf f8 ff 48 85 db 74 4d <83> 3b 00 74 48 48 83 3d 83 
ab 66 00 00 75 04 0f 0b eb fe fa 66
[  151.845235] RIP  [<ffffffff810bd460>] cache_reap+0x8d/0x252
[  151.845255]  RSP <ffff88027e81ddf0>
[  151.845260] CR2: 000000004b31f78f
[  151.845415] ---[ end trace be6e21fde5d02b06 ]---

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
