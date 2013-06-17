Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx144.postini.com [74.125.245.144])
	by kanga.kvack.org (Postfix) with SMTP id 187BD6B0033
	for <linux-mm@kvack.org>; Mon, 17 Jun 2013 10:18:24 -0400 (EDT)
Date: Mon, 17 Jun 2013 16:18:22 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: linux-next: slab shrinkers: BUG at mm/list_lru.c:92
Message-ID: <20130617141822.GF5018@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>, Glauber Costa <glommer@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

Hi,
I managed to trigger:
[ 1015.776029] kernel BUG at mm/list_lru.c:92!
[ 1015.776029] invalid opcode: 0000 [#1] SMP
[ 1015.776029] Modules linked in: edd nfsv3 nfs_acl nfs fscache lockd sunrpc af_packet bridge stp llc cpufreq_conservative cpufreq_userspace cpufreq_powersave powernow_k8 fuse loop dm_mod ohci_pci ohci_hcd ehci_hcd usbcore e1000 kvm_amd kvm tg3 usb_common ptp pps_core sg shpchp edac_core pci_hotplug sr_mod k8temp i2c_amd8111 i2c_amd756 amd_rng edac_mce_amd button serio_raw cdrom pcspkr processor thermal_sys scsi_dh_emc scsi_dh_rdac scsi_dh_hp_sw scsi_dh ata_generic sata_sil pata_amd
[ 1015.776029] CPU: 5 PID: 10480 Comm: cc1 Not tainted 3.10.0-rc4-next-20130607nextbadpagefix+ #1
[ 1015.776029] Hardware name: AMD A8440/WARTHOG, BIOS PW2A00-5 09/23/2005
[ 1015.776029] task: ffff8800327fc240 ti: ffff88003a59a000 task.ti: ffff88003a59a000
[ 1015.776029] RIP: 0010:[<ffffffff81122d9c>]  [<ffffffff81122d9c>] list_lru_walk_node+0x10c/0x140
[ 1015.776029] RSP: 0018:ffff88003a59b7a8  EFLAGS: 00010286
[ 1015.776029] RAX: ffffffffffffffff RBX: ffff880002f7ae80 RCX: ffff880002f7ae80
[ 1015.776029] RDX: 0000000000000000 RSI: ffff8800370dacc0 RDI: ffff880002f7ad88
[ 1015.776029] RBP: ffff88003a59b808 R08: 0000000000000000 R09: ffff88001ffeafc0
[ 1015.776029] R10: 0000000000000002 R11: 0000000000000000 R12: ffff8800370dacc0
[ 1015.776029] R13: 0000000000000227 R14: ffff880002fb6850 R15: ffff8800370dacc8
[ 1015.776029] FS:  00002aaaaaada600(0000) GS:ffff88001f300000(0000) knlGS:0000000000000000
[ 1015.776029] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[ 1015.776029] CR2: 00000000025aac5c CR3: 000000001cf9d000 CR4: 00000000000007e0
[ 1015.776029] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[ 1015.776029] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[ 1015.776029] Stack:
[ 1015.776029]  ffff8800151c6440 ffff88003a59b820 ffff88003a59b828 ffffffff8117e4a0
[ 1015.776029]  000000008117e6e1 ffff88003e174c48 00ff88003a59b828 ffff88003a59b828
[ 1015.776029]  000000000000021f ffff88003e174800 ffff88003a59b9f8 0000000000000220
[ 1015.776029] Call Trace:
[ 1015.776029]  [<ffffffff8117e4a0>] ? insert_inode_locked+0x160/0x160
[ 1015.776029]  [<ffffffff8117e74c>] prune_icache_sb+0x3c/0x60
[ 1015.776029]  [<ffffffff81167a2e>] super_cache_scan+0x12e/0x1b0
[ 1015.776029]  [<ffffffff8110f3da>] shrink_slab_node+0x13a/0x250
[ 1015.776029]  [<ffffffff8111256b>] shrink_slab+0xab/0x120
[ 1015.776029]  [<ffffffff81113784>] do_try_to_free_pages+0x264/0x360
[ 1015.776029]  [<ffffffff81113bd0>] try_to_free_pages+0x130/0x180
[ 1015.776029]  [<ffffffff81106fce>] __alloc_pages_slowpath+0x39e/0x790
[ 1015.776029]  [<ffffffff811075ba>] __alloc_pages_nodemask+0x1fa/0x210
[ 1015.776029]  [<ffffffff81147470>] alloc_pages_vma+0xa0/0x120
[ 1015.776029]  [<ffffffff81124c33>] do_anonymous_page+0x133/0x300
[ 1015.776029]  [<ffffffff8112a10d>] handle_pte_fault+0x22d/0x240
[ 1015.776029]  [<ffffffff81122f58>] ? list_lru_add+0x68/0xe0
[ 1015.776029]  [<ffffffff8112a3e3>] handle_mm_fault+0x2c3/0x3e0
[ 1015.776029]  [<ffffffff815a4997>] __do_page_fault+0x227/0x4e0
[ 1015.776029]  [<ffffffff81002930>] ? do_notify_resume+0x90/0x1d0
[ 1015.776029]  [<ffffffff81163d18>] ? fsnotify_access+0x68/0x80
[ 1015.776029]  [<ffffffff811660a4>] ? file_sb_list_del+0x44/0x50
[ 1015.776029]  [<ffffffff81060b05>] ? task_work_add+0x55/0x70
[ 1015.776029]  [<ffffffff81166214>] ? fput+0x74/0xd0
[ 1015.776029]  [<ffffffff815a4c59>] do_page_fault+0x9/0x10
[ 1015.776029]  [<ffffffff815a1632>] page_fault+0x22/0x30
[ 1015.776029] Code: b3 66 0f 1f 44 00 00 48 8b 03 48 8b 53 08 48 89 50 08 48 89 02 49 8b 44 24 10 49 89 5c 24 10 4c 89 3b 48 89 43 08 48 89 18 eb 89 <0f> 0b eb fe 8b 55 c4 48 8b 45 c8 f0 0f b3 10 e9 69 ff ff ff 66
[ 1015.776029] RIP  [<ffffffff81122d9c>] list_lru_walk_node+0x10c/0x140

with Linux next (next-20130607) with https://lkml.org/lkml/2013/6/17/203
on top. 

This is obviously BUG_ON(nlru->nr_items < 0) and 
ffffffff81122d0b:       48 85 c0                test   %rax,%rax
ffffffff81122d0e:       49 89 44 24 18          mov    %rax,0x18(%r12)
ffffffff81122d13:       0f 84 87 00 00 00       je     ffffffff81122da0 <list_lru_walk_node+0x110>
ffffffff81122d19:       49 83 7c 24 18 00       cmpq   $0x0,0x18(%r12)
ffffffff81122d1f:       78 7b                   js     ffffffff81122d9c <list_lru_walk_node+0x10c>
[...]
ffffffff81122d9c:       0f 0b                   ud2

RAX is -1UL.

I assume that the current backtrace is of no use and it would most
probably be some shrinker which doesn't behave.

Any idea how to pin this down?

Thanks!
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
