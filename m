Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 4647D6B0071
	for <linux-mm@kvack.org>; Tue, 12 Jan 2010 20:47:05 -0500 (EST)
Date: Wed, 13 Jan 2010 10:30:06 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: [BUGFIX][PATCH] memcg: ensure list is empty at rmdir
Message-Id: <20100113103006.8cf3b23c.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <20100112140836.45e7fabb.nishimura@mxp.nes.nec.co.jp>
References: <20100112140836.45e7fabb.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, stable <stable@kernel.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

Current mem_cgroup_force_empty() only ensures mem->res.usage == 0 on success.
So there can be a case that the usage is zero but some of the LRUs are not
empty if all of those pages have already been uncharged by the owner process.

OTOH, mem_cgroup_del_lru_list(), which can be called asynchronously with rmdir,
accesses the mem_cgroup, so this access can cause a problem if it races with
rmdir because the mem_cgroup might have been freed by rmdir.

Actually, I saw a bug which seems to be caused by this race.

	[1530745.949906] BUG: unable to handle kernel NULL pointer dereference at 0000000000000230
	[1530745.950651] IP: [<ffffffff810fbc11>] mem_cgroup_del_lru_list+0x30/0x80
	[1530745.950651] PGD 3863de067 PUD 3862c7067 PMD 0
	[1530745.950651] Oops: 0002 [#1] SMP
	[1530745.950651] last sysfs file: /sys/devices/system/cpu/cpu7/cache/index1/shared_cpu_map
	[1530745.950651] CPU 3
	[1530745.950651] Modules linked in: configs ipt_REJECT xt_tcpudp iptable_filter ip_tables x_tables bridge stp nfsd nfs_acl auth_rpcgss exportfs autofs4 hidp rfcomm l2cap crc16 bluetooth lockd sunrpc ib_iser rdma_cm ib_cm iw_cm ib_sa ib_mad ib_core ib_addr iscsi_tcp bnx2i cnic uio ipv6 cxgb3i cxgb3 mdio libiscsi_tcp libiscsi scsi_transport_iscsi dm_mirror dm_multipath scsi_dh video output sbs sbshc battery ac lp kvm_intel kvm sg ide_cd_mod cdrom serio_raw tpm_tis tpm tpm_bios acpi_memhotplug button parport_pc parport rtc_cmos rtc_core rtc_lib e1000 i2c_i801 i2c_core pcspkr dm_region_hash dm_log dm_mod ata_piix libata shpchp megaraid_mbox sd_mod scsi_mod megaraid_mm ext3 jbd uhci_hcd ohci_hcd ehci_hcd [last unloaded: freq_table]
	[1530745.950651] Pid: 19653, comm: shmem_test_02 Tainted: G   M       2.6.32-mm1-00701-g2b04386 #3 Express5800/140Rd-4 [N8100-1065]
	[1530745.950651] RIP: 0010:[<ffffffff810fbc11>]  [<ffffffff810fbc11>] mem_cgroup_del_lru_list+0x30/0x80
	[1530745.950651] RSP: 0018:ffff8803863ddcb8  EFLAGS: 00010002
	[1530745.950651] RAX: 00000000000001e0 RBX: ffff8803abc02238 RCX: 00000000000001e0
	[1530745.950651] RDX: 0000000000000000 RSI: ffff88038611a000 RDI: ffff8803abc02238
	[1530745.950651] RBP: ffff8803863ddcc8 R08: 0000000000000002 R09: ffff8803a04c8643
	[1530745.950651] R10: 0000000000000000 R11: ffffffff810c7333 R12: 0000000000000000
	[1530745.950651] R13: ffff880000017f00 R14: 0000000000000092 R15: ffff8800179d0310
	[1530745.950651] FS:  0000000000000000(0000) GS:ffff880017800000(0000) knlGS:0000000000000000
	[1530745.950651] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
	[1530745.950651] CR2: 0000000000000230 CR3: 0000000379d87000 CR4: 00000000000006e0
	[1530745.950651] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
	[1530745.950651] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
	[1530745.950651] Process shmem_test_02 (pid: 19653, threadinfo ffff8803863dc000, task ffff88038612a8a0)
	[1530745.950651] Stack:
	[1530745.950651]  ffffea00040c2fe8 0000000000000000 ffff8803863ddd98 ffffffff810c739a
	[1530745.950651] <0> 00000000863ddd18 000000000000000c 0000000000000000 0000000000000000
	[1530745.950651] <0> 0000000000000002 0000000000000000 ffff8803863ddd68 0000000000000046
	[1530745.950651] Call Trace:
	[1530745.950651]  [<ffffffff810c739a>] release_pages+0x142/0x1e7
	[1530745.950651]  [<ffffffff810c778f>] ? pagevec_move_tail+0x6e/0x112
	[1530745.950651]  [<ffffffff810c781e>] pagevec_move_tail+0xfd/0x112
	[1530745.950651]  [<ffffffff810c78a9>] lru_add_drain+0x76/0x94
	[1530745.950651]  [<ffffffff810dba0c>] exit_mmap+0x6e/0x145
	[1530745.950651]  [<ffffffff8103f52d>] mmput+0x5e/0xcf
	[1530745.950651]  [<ffffffff81043ea8>] exit_mm+0x11c/0x129
	[1530745.950651]  [<ffffffff8108fb29>] ? audit_free+0x196/0x1c9
	[1530745.950651]  [<ffffffff81045353>] do_exit+0x1f5/0x6b7
	[1530745.950651]  [<ffffffff8106133f>] ? up_read+0x2b/0x2f
	[1530745.950651]  [<ffffffff8137d187>] ? lockdep_sys_exit_thunk+0x35/0x67
	[1530745.950651]  [<ffffffff81045898>] do_group_exit+0x83/0xb0
	[1530745.950651]  [<ffffffff810458dc>] sys_exit_group+0x17/0x1b
	[1530745.950651]  [<ffffffff81002c1b>] system_call_fastpath+0x16/0x1b
	[1530745.950651] Code: 54 53 0f 1f 44 00 00 83 3d cc 29 7c 00 00 41 89 f4 75 63 eb 4e 48 83 7b 08 00 75 04 0f 0b eb fe 48 89 df e8 18 f3 ff ff 44 89 e2 <48> ff 4c d0 50 48 8b 05 2b 2d 7c 00 48 39 43 08 74 39 48 8b 4b
	[1530745.950651] RIP  [<ffffffff810fbc11>] mem_cgroup_del_lru_list+0x30/0x80
	[1530745.950651]  RSP <ffff8803863ddcb8>
	[1530745.950651] CR2: 0000000000000230
	[1530745.950651] ---[ end trace c3419c1bb8acc34f ]---
	[1530745.950651] Fixing recursive fault but reboot is needed!

This patch tries to fix this bug by ensuring not only the usage is zero but also
all of the LRUs are empty. mem_cgroup_force_empty_list() checks the list is empty
or not, so we can make use of it.

Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: stable@kernel.org
---
This patch is based on 2.6.33-rc3, and can be applied to older versions too.

 mm/memcontrol.c |   11 ++++-------
 1 files changed, 4 insertions(+), 7 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index 488b644..954032b 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2586,7 +2586,7 @@ static int mem_cgroup_force_empty(struct mem_cgroup *mem, bool free_all)
 	if (free_all)
 		goto try_to_free;
 move_account:
-	while (mem->res.usage > 0) {
+	do {
 		ret = -EBUSY;
 		if (cgroup_task_count(cgrp) || !list_empty(&cgrp->children))
 			goto out;
@@ -2614,8 +2614,8 @@ move_account:
 		if (ret == -ENOMEM)
 			goto try_to_free;
 		cond_resched();
-	}
-	ret = 0;
+	/* "ret" should also be checked to ensure all lists are empty. */
+	} while (mem->res.usage > 0 || ret);
 out:
 	css_put(&mem->css);
 	return ret;
@@ -2648,10 +2648,7 @@ try_to_free:
 	}
 	lru_add_drain();
 	/* try move_account...there may be some *locked* pages. */
-	if (mem->res.usage)
-		goto move_account;
-	ret = 0;
-	goto out;
+	goto move_account;
 }
 
 int mem_cgroup_force_empty_write(struct cgroup *cont, unsigned int event)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
