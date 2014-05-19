From: Michal Hocko <mhocko@suse.cz>
Subject: [PATCH] memcg: fix swapcache charge from kernel thread context
Date: Mon, 19 May 2014 10:27:56 +0200
Message-ID: <1400488076-3820-1-git-send-email-mhocko@suse.cz>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Hugh Dickins <hughd@google.com>, Branimir Maksimovic <branimir.maksimovic@gmail.com>, Stephan Kulow <coolo@suse.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
List-Id: linux-mm.kvack.org

284f39afeaa4 (mm: memcg: push !mm handling out to page cache charge
function) explicitly checks for page cache charges without any mm
context (from kernel thread context[1]).

This seemed to be the only possible case where memory could be charged
without mm context so 03583f1a631c (memcg: remove unnecessary !mm check
from try_get_mem_cgroup_from_mm()) removed the mm check from
get_mem_cgroup_from_mm. This however caused another NULL ptr dereference
during early boot when loopback kernel thread splices to tmpfs as reported
by Stephan Kulow:

BUG: unable to handle kernel NULL pointer dereference at 0000000000000360
IP: [<ffffffff81196aab>] get_mem_cgroup_from_mm.isra.42+0x2b/0x60
PGD 5082067 PUD 83c3067 PMD 0
Oops: 0000 [#1] SMP
Modules linked in: btrfs dm_multipath dm_mod scsi_dh multipath raid10 raid456 async_raid6_recov async_memcpy async_pq raid6_pq async_xor xor async_tx raid1 raid0 md_mod parport_pc parport nls_utf8 isofs usb_storage iscsi_ibft iscsi_boot_sysfs arc4 ecb fan thermal nfs lockd fscache nls_iso8859_1 nls_cp437 sg st hid_generic usbhid af_packet sunrpc sr_mod cdrom ata_generic uhci_hcd virtio_net virtio_blk ehci_hcd usbcore ata_piix floppy processor button usb_common virtio_pci virtio_ring virtio edd squashfs loop
 ppa]
CPU: 0 PID: 97 Comm: loop1 Not tainted 3.15.0-rc5-5-default #1
Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
task: ffff880039b7a390 ti: ffff880038efe000 task.ti: ffff880038efe000
RIP: 0010:[<ffffffff81196aab>]  [<ffffffff81196aab>] get_mem_cgroup_from_mm.isra.42+0x2b/0x60
RSP: 0018:ffff880038effa40  EFLAGS: 00010246
RAX: 0000000000000000 RBX: ffffea00001e5140 RCX: 0000000000000020
RDX: ffff88003c365020 RSI: ffffea00001e5140 RDI: 0000000000000360
RBP: ffff880038effa78 R08: 0000000000000ab3 R09: ffff880039572248
R10: 0000000000002ace R11: 0000000000000000 R12: 0000000000000010
R13: 0000000000000000 R14: ffff880038c72448 R15: 00000000fffffffe
FS:  00007fb0042ed880(0000) GS:ffff88003c000000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
CR2: 0000000000000360 CR3: 0000000005e2b000 CR4: 00000000000006f0
Stack:
 ffffffff8119bae0 0000000000000000 0000000000000000 ffffea00001e5140
 0000000000000001 00000000ffffffef ffffffff8119c04b 0000000000000000
 ffff880038c722f8 0000000000000ab3 ffffffff8115129b 00000000000001d7
Call Trace:
 [<ffffffff8119bae0>] __mem_cgroup_try_charge_swapin+0x40/0xe0
 [<ffffffff8119c04b>] mem_cgroup_charge_file+0x8b/0xd0
 [<ffffffff8115129b>] shmem_getpage_gfp+0x66b/0x7b0
 [<ffffffff811518cf>] shmem_file_splice_read+0x18f/0x430
 [<ffffffff811ceff2>] splice_direct_to_actor+0xa2/0x1c0
 [<ffffffffa00019ea>] do_lo_receive+0x5a/0x60 [loop]
 [<ffffffffa0002158>] loop_thread+0x298/0x720 [loop]
 [<ffffffff810778d6>] kthread+0xc6/0xe0
 [<ffffffff815c0dbc>] ret_from_fork+0x7c/0xb0
Code: 66 66 66 66 90 eb 24 66 0f 1f 84 00 00 00 00 00 f6 40 48 01 75 3a 48 8b 50 18 f6 c2 03 75 32 65 ff 02 ba 01 00 00 00 84 d2 75 25 <48> 8b 07 48 85 c0 74 10 48 8b 80 70 08 00 00 48 8b 40 60 48 85
RIP  [<ffffffff81196aab>] get_mem_cgroup_from_mm.isra.42+0x2b/0x60
 RSP <ffff880038effa40>
CR2: 0000000000000360

Also Branimir Maksimovic reported the following oops which is tiggered
for the swapcache charge path from the accounting code for kernel threads:

[  388.522494] CPU: 1 PID: 160 Comm: kworker/u8:5 Tainted: P           OE 3.15.0-rc5-core2-custom #159
[  388.522496] Hardware name: System manufacturer System Product Name/MAXIMUSV GENE, BIOS 1903 08/19/2013
[  388.522498] task: ffff880404e349b0 ti: ffff88040486a000 task.ti: ffff88040486a000
[  388.522500] RIP: 0010:[<ffffffff81185b0b>] [<ffffffff81185b0b>] get_mem_cgroup_from_mm.isra.42+0x2b/0x60
[  388.522504] RSP: 0000:ffff88040486bab8  EFLAGS: 00010246
[  388.522506] RAX: 0000000000000000 RBX: ffffea000a416340 RCX: 0000000000000a40
[  388.522508] RDX: ffff88041efe8a40 RSI: ffffea000a416340 RDI: 0000000000000340
[  388.522509] RBP: ffff88040486bab8 R08: 000000000001cb56 R09: 0000000000072d5a
[  388.522511] R10: 0000000000000000 R11: 0000000000000005 R12: ffff88040486bb00
[  388.522512] R13: 00000000000000d0 R14: 0000000000000000 R15: ffff8803f3fe82f8
[  388.522515] FS:  0000000000000000(0000) GS:ffff88041ec80000(0000) knlGS:0000000000000000
[  388.522517] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  388.522518] CR2: 0000000000000340 CR3: 00000003ee44d000 CR4: 00000000001407e0
[  388.522520] Stack:
[  388.522521]  ffff88040486baf0 ffffffff8118abf5 ffffffff8112ce1a 0000000000000000
[  388.522524]  ffffea000a416340 0000000000000003 00000000ffffffef ffff88040486bb18
[  388.522527]  ffffffff8118b1cc ffff88040486baf8 000000000001cb56 0000000000000000
[  388.522530] Call Trace:
[  388.522536]  [<ffffffff8118abf5>] __mem_cgroup_try_charge_swapin+0x45/0xf0
[  388.522539]  [<ffffffff8112ce1a>] ? __lock_page+0x6a/0x70
[  388.522543]  [<ffffffff8118b1cc>] mem_cgroup_charge_file+0x9c/0xe0
[  388.522548]  [<ffffffff8114599c>] shmem_getpage_gfp+0x62c/0x770
[  388.522552]  [<ffffffff81145b18>] shmem_write_begin+0x38/0x40
[  388.522555]  [<ffffffff8112d1c5>] generic_perform_write+0xc5/0x1c0
[  388.522559]  [<ffffffff811ad53a>] ? file_update_time+0x8a/0xd0
[  388.522563]  [<ffffffff8112f211>] __generic_file_aio_write+0x1d1/0x3f0
[  388.522567]  [<ffffffff81084fc1>] ? enqueue_entity+0x291/0xb90
[  388.522570]  [<ffffffff8112f47f>] generic_file_aio_write+0x4f/0xc0
[  388.522574]  [<ffffffff81192eaa>] do_sync_write+0x5a/0x90
[  388.522578]  [<ffffffff810c53c1>] do_acct_process+0x4b1/0x550
[  388.522582]  [<ffffffff810c5acd>] acct_process+0x6d/0xa0
[  388.522587]  [<ffffffff810667d0>] ? manage_workers.isra.25+0x2a0/0x2a0
[  388.522590]  [<ffffffff8104d937>] do_exit+0x827/0xa70
[  388.522594]  [<ffffffff8106699e>] ? worker_thread+0x1ce/0x3a0
[  388.522597]  [<ffffffff810667d0>] ? manage_workers.isra.25+0x2a0/0x2a0
[  388.522600]  [<ffffffff8106cad3>] kthread+0xc3/0xf0
[  388.522604]  [<ffffffff8106ca10>] ? kthread_create_on_node+0x180/0x180
[  388.522608]  [<ffffffff816bfe6c>] ret_from_fork+0x7c/0xb0
[  388.522611]  [<ffffffff8106ca10>] ? kthread_create_on_node+0x180/0x180

This patch fixes the issue by reintroducing mm check into get_mem_cgroup_from_mm.
We could do the same trick in __mem_cgroup_try_charge_swapin as we do
for the regular page cache path but it is not worth troubles. The check
is not that expensive and it is better to have get_mem_cgroup_from_mm
more robust.

[1] - http://marc.info/?l=linux-mm&m=139463617808941&w=2

Fixes: 03583f1a631c (3.15-rc1)
Reported-and-tested-by: Stephan Kulow <coolo@suse.com>
Reported-by: Branimir Maksimovic <branimir.maksimovic@gmail.com>
Signed-off-by: Michal Hocko <mhocko@suse.cz>
---
 mm/memcontrol.c | 26 +++++++++++++-------------
 1 file changed, 13 insertions(+), 13 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 2cb81478d30c..2248a648a127 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -1061,9 +1061,17 @@ static struct mem_cgroup *get_mem_cgroup_from_mm(struct mm_struct *mm)
 
 	rcu_read_lock();
 	do {
-		memcg = mem_cgroup_from_task(rcu_dereference(mm->owner));
-		if (unlikely(!memcg))
+		/*
+		 * Page cache or loopback insertions can happen without an
+		 * actual mm context, e.g. during disk probing on boot
+		 */
+		if (unlikely(!mm))
 			memcg = root_mem_cgroup;
+		else {
+			memcg = mem_cgroup_from_task(rcu_dereference(mm->owner));
+			if (unlikely(!memcg))
+				memcg = root_mem_cgroup;
+		}
 	} while (!css_tryget(&memcg->css));
 	rcu_read_unlock();
 	return memcg;
@@ -3857,17 +3865,9 @@ int mem_cgroup_charge_file(struct page *page, struct mm_struct *mm,
 		return 0;
 	}
 
-	/*
-	 * Page cache insertions can happen without an actual mm
-	 * context, e.g. during disk probing on boot.
-	 */
-	if (unlikely(!mm))
-		memcg = root_mem_cgroup;
-	else {
-		memcg = mem_cgroup_try_charge_mm(mm, gfp_mask, 1, true);
-		if (!memcg)
-			return -ENOMEM;
-	}
+	memcg = mem_cgroup_try_charge_mm(mm, gfp_mask, 1, true);
+	if (!memcg)
+		return -ENOMEM;
 	__mem_cgroup_commit_charge(memcg, page, 1, type, false);
 	return 0;
 }
-- 
2.0.0.rc2
