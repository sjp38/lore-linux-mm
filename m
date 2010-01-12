Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id BCD546B0078
	for <linux-mm@kvack.org>; Tue, 12 Jan 2010 00:10:39 -0500 (EST)
Date: Tue, 12 Jan 2010 14:08:36 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: [RFC][BUGFIX][PATCH] memcg: ensure list is empty at rmdir
Message-Id: <20100112140836.45e7fabb.nishimura@mxp.nes.nec.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: linux-mm <linux-mm@kvack.org>
Cc: Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

I see a bug bellow at the end of last week after a very long run(more than 17days)
while testing mmotm-2009-12-10-17-19 + move charge patch.


[1530745.949906] BUG: unable to handle kernel NULL pointer dereference at 0000000000000230
[1530745.950651] IP: [<ffffffff810fbc11>] mem_cgroup_del_lru_list+0x30/0x80
[1530745.950651] PGD 3863de067 PUD 3862c7067 PMD 0
[1530745.950651] Oops: 0002 [#1] SMP
[1530745.950651] last sysfs file: /sys/devices/system/cpu/cpu7/cache/index1/shared_cpu_map
[1530745.950651] CPU 3
[1530745.950651] Modules linked in: configs ipt_REJECT xt_tcpudp iptable_filter ip_tables
x_tables bridge stp nfsd nfs_acl auth_rpcgss exportfs autofs4 hidp rfcomm l2cap crc16 blue
tooth lockd sunrpc ib_iser rdma_cm ib_cm iw_cm ib_sa ib_mad ib_core ib_addr iscsi_tcp bnx2
i cnic uio ipv6 cxgb3i cxgb3 mdio libiscsi_tcp libiscsi scsi_transport_iscsi dm_mirror dm_
multipath scsi_dh video output sbs sbshc battery ac lp kvm_intel kvm sg ide_cd_mod cdrom s
erio_raw tpm_tis tpm tpm_bios acpi_memhotplug button parport_pc parport rtc_cmos rtc_core
rtc_lib e1000 i2c_i801 i2c_core pcspkr dm_region_hash dm_log dm_mod ata_piix libata shpchp
 megaraid_mbox sd_mod scsi_mod megaraid_mm ext3 jbd uhci_hcd ohci_hcd ehci_hcd [last unloa
ded: freq_table]
[1530745.950651] Pid: 19653, comm: shmem_test_02 Tainted: G   M       2.6.32-mm1-00701-g2b
04386 #3 Express5800/140Rd-4 [N8100-1065]
[1530745.950651] RIP: 0010:[<ffffffff810fbc11>]  [<ffffffff810fbc11>] mem_cgroup_del_lru_l
ist+0x30/0x80
[1530745.950651] RSP: 0018:ffff8803863ddcb8  EFLAGS: 00010002
[1530745.950651] RAX: 00000000000001e0 RBX: ffff8803abc02238 RCX: 00000000000001e0
[1530745.950651] RDX: 0000000000000000 RSI: ffff88038611a000 RDI: ffff8803abc02238
[1530745.950651] RBP: ffff8803863ddcc8 R08: 0000000000000002 R09: ffff8803a04c8643
[1530745.950651] R10: 0000000000000000 R11: ffffffff810c7333 R12: 0000000000000000
[1530745.950651] R13: ffff880000017f00 R14: 0000000000000092 R15: ffff8800179d0310
[1530745.950651] FS:  0000000000000000(0000) GS:ffff880017800000(0000) knlGS:0000000000000
000
[1530745.950651] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[1530745.950651] CR2: 0000000000000230 CR3: 0000000379d87000 CR4: 00000000000006e0
[1530745.950651] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[1530745.950651] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[1530745.950651] Process shmem_test_02 (pid: 19653, threadinfo ffff8803863dc000, task ffff
88038612a8a0)
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
[1530745.950651] Code: 54 53 0f 1f 44 00 00 83 3d cc 29 7c 00 00 41 89 f4 75 63 eb 4e 48 8
3 7b 08 00 75 04 0f 0b eb fe 48 89 df e8 18 f3 ff ff 44 89 e2 <48> ff 4c d0 50 48 8b 05 2b
 2d 7c 00 48 39 43 08 74 39 48 8b 4b
[1530745.950651] RIP  [<ffffffff810fbc11>] mem_cgroup_del_lru_list+0x30/0x80
[1530745.950651]  RSP <ffff8803863ddcb8>
[1530745.950651] CR2: 0000000000000230
[1530745.950651] ---[ end trace c3419c1bb8acc34f ]---
[1530745.950651] Fixing recursive fault but reboot is needed!


gdb says:

(gdb) list *0xffffffff810fbc11
0xffffffff810fbc11 is in mem_cgroup_del_lru_list (mm/memcontrol.c:683).
warning: Source file is more recent than executable.
678             /*
679              * We don't check PCG_USED bit. It's cleared when the "page" is finally
680              * removed from global LRU.
681              */
682             mz = page_cgroup_zoneinfo(pc);
683             MEM_CGROUP_ZSTAT(mz, lru) -= 1;
684             if (mem_cgroup_is_root(pc->mem_cgroup))
685                     return;
686             VM_BUG_ON(list_empty(&pc->lru));
687             list_del_init(&pc->lru);
(gdb) disassemble mem_cgroup_del_lru_list
Dump of assembler code for function mem_cgroup_del_lru_list:
0xffffffff810fbbe1 <mem_cgroup_del_lru_list+0>: push   %rbp
0xffffffff810fbbe2 <mem_cgroup_del_lru_list+1>: mov    %rsp,%rbp
0xffffffff810fbbe5 <mem_cgroup_del_lru_list+4>: push   %r12
0xffffffff810fbbe7 <mem_cgroup_del_lru_list+6>: push   %rbx
0xffffffff810fbbe8 <mem_cgroup_del_lru_list+7>: callq  0xffffffff81002900 <mcount>
0xffffffff810fbbed <mem_cgroup_del_lru_list+12>:        cmpl   $0x0,0x7c29cc(%rip)        # 0xffffffff818be5c0 <mem_cgroup_subsys+96>
0xffffffff810fbbf4 <mem_cgroup_del_lru_list+19>:        mov    %esi,%r12d
0xffffffff810fbbf7 <mem_cgroup_del_lru_list+22>:        jne    0xffffffff810fbc5c <mem_cgroup_del_lru_list+123>
0xffffffff810fbbf9 <mem_cgroup_del_lru_list+24>:        jmp    0xffffffff810fbc49 <mem_cgroup_del_lru_list+104>
0xffffffff810fbbfb <mem_cgroup_del_lru_list+26>:        cmpq   $0x0,0x8(%rbx)
0xffffffff810fbc00 <mem_cgroup_del_lru_list+31>:        jne    0xffffffff810fbc06 <mem_cgroup_del_lru_list+37>
0xffffffff810fbc02 <mem_cgroup_del_lru_list+33>:        ud2a
0xffffffff810fbc04 <mem_cgroup_del_lru_list+35>:        jmp    0xffffffff810fbc04 <mem_cgroup_del_lru_list+35>
0xffffffff810fbc06 <mem_cgroup_del_lru_list+37>:        mov    %rbx,%rdi
0xffffffff810fbc09 <mem_cgroup_del_lru_list+40>:        callq  0xffffffff810faf26 <page_cgroup_zoneinfo>
0xffffffff810fbc0e <mem_cgroup_del_lru_list+45>:        mov    %r12d,%edx
0xffffffff810fbc11 <mem_cgroup_del_lru_list+48>:        decq   0x50(%rax,%rdx,8)
0xffffffff810fbc16 <mem_cgroup_del_lru_list+53>:        mov    0x7c2d2b(%rip),%rax        # 0xffffffff818be948 <root_mem_cgroup>
0xffffffff810fbc1d <mem_cgroup_del_lru_list+60>:        cmp    %rax,0x8(%rbx)
0xffffffff810fbc21 <mem_cgroup_del_lru_list+64>:        je     0xffffffff810fbc5c <mem_cgroup_del_lru_list+123>
0xffffffff810fbc23 <mem_cgroup_del_lru_list+66>:        mov    0x18(%rbx),%rcx
0xffffffff810fbc27 <mem_cgroup_del_lru_list+70>:        lea    0x18(%rbx),%rdx
0xffffffff810fbc2b <mem_cgroup_del_lru_list+74>:        cmp    %rdx,%rcx
0xffffffff810fbc2e <mem_cgroup_del_lru_list+77>:        jne    0xffffffff810fbc34 <mem_cgroup_del_lru_list+83>
0xffffffff810fbc30 <mem_cgroup_del_lru_list+79>:        ud2a
0xffffffff810fbc32 <mem_cgroup_del_lru_list+81>:        jmp    0xffffffff810fbc32 <mem_cgroup_del_lru_list+81>
0xffffffff810fbc34 <mem_cgroup_del_lru_list+83>:        mov    0x8(%rdx),%rax
0xffffffff810fbc38 <mem_cgroup_del_lru_list+87>:        mov    %rax,0x8(%rcx)
0xffffffff810fbc3c <mem_cgroup_del_lru_list+91>:        mov    %rcx,(%rax)
0xffffffff810fbc3f <mem_cgroup_del_lru_list+94>:        mov    %rdx,0x8(%rdx)
0xffffffff810fbc43 <mem_cgroup_del_lru_list+98>:        mov    %rdx,0x18(%rbx)
0xffffffff810fbc47 <mem_cgroup_del_lru_list+102>:       jmp    0xffffffff810fbc5c <mem_cgroup_del_lru_list+123>
0xffffffff810fbc49 <mem_cgroup_del_lru_list+104>:       callq  0xffffffff810ff5e9 <lookup_page_cgroup>
0xffffffff810fbc4e <mem_cgroup_del_lru_list+109>:       mov    %rax,%rbx
0xffffffff810fbc51 <mem_cgroup_del_lru_list+112>:       lock btrl $0x3,(%rax)
0xffffffff810fbc56 <mem_cgroup_del_lru_list+117>:       sbb    %eax,%eax
0xffffffff810fbc58 <mem_cgroup_del_lru_list+119>:       test   %eax,%eax
0xffffffff810fbc5a <mem_cgroup_del_lru_list+121>:       jne    0xffffffff810fbbfb <mem_cgroup_del_lru_list+26>
0xffffffff810fbc5c <mem_cgroup_del_lru_list+123>:       pop    %rbx
0xffffffff810fbc5d <mem_cgroup_del_lru_list+124>:       pop    %r12
0xffffffff810fbc5f <mem_cgroup_del_lru_list+126>:       leaveq
0xffffffff810fbc60 <mem_cgroup_del_lru_list+127>:       retq
End of assembler dump.


These outputs mean that MEM_CGROUP_ZSTAT() is called with @mz = 0x00000000000001e0.
So I suspect that the mem_cgroup has already been freed by rmdir at this point.

I found a race condition which seems to be the root cause of this problem.
If it is a valid fix, I think it should go to stable too.

Any comments?


Thanks,
Daisuke Nishimura.
===
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>

Current mem_cgroup_force_empty() only ensures mem->res.usage == 0 on success.
So there can be a case that the usage is zero but some of the LRUs are not
empty if all of those pages have already been uncharged by the owner process.

OTOH, mem_cgroup_del_lru_list(), which can be called asynchronously with rmdir,
accesses the mem_cgroup, so this access might cause a problem if it races with
rmdir because the mem_cgroup might be freed by rmdir.

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
all of the LRUs are empty. mem_cgroup_del_lru_list() checks the list is empty
or not, so we can make use of it.

Signed-off-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
---
 mm/memcontrol.c |   10 +++-------
 1 files changed, 3 insertions(+), 7 deletions(-)

diff --git a/mm/memcontrol.c b/mm/memcontrol.c
index ffca2ab..46c15ca 100644
--- a/mm/memcontrol.c
+++ b/mm/memcontrol.c
@@ -2726,7 +2726,7 @@ static int mem_cgroup_force_empty(struct mem_cgroup *mem, bool free_all)
 	if (free_all)
 		goto try_to_free;
 move_account:
-	while (mem->res.usage > 0) {
+	do {
 		ret = -EBUSY;
 		if (cgroup_task_count(cgrp) || !list_empty(&cgrp->children))
 			goto out;
@@ -2754,8 +2754,7 @@ move_account:
 		if (ret == -ENOMEM)
 			goto try_to_free;
 		cond_resched();
-	}
-	ret = 0;
+	} while (mem->res.usage > 0 || ret);
 out:
 	css_put(&mem->css);
 	return ret;
@@ -2788,10 +2787,7 @@ try_to_free:
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
1.5.6.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
