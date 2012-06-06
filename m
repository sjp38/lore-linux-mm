Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx122.postini.com [74.125.245.122])
	by kanga.kvack.org (Postfix) with SMTP id E32098D0001
	for <linux-mm@kvack.org>; Wed,  6 Jun 2012 15:03:00 -0400 (EDT)
Date: Wed, 6 Jun 2012 12:53:40 -0400
From: Dave Jones <davej@redhat.com>
Subject: kernel BUG at mm/memory.c:1228!
Message-ID: <20120606165330.GA27744@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linux Kernel <linux-kernel@vger.kernel.org>
Cc: linux-mm@kvack.org

I hit this in overnight testing..

------------[ cut here ]------------
kernel BUG at mm/memory.c:1228!
invalid opcode: 0000 [#1] PREEMPT SMP 
CPU 0 
Modules linked in: ipt_ULOG tun fuse dccp_ipv6 dccp_ipv4 dccp nfnetlink binfmt_misc sctp libcrc32c caif_socket caif phonet bluetooth rfkill can llc2 pppoe pppox ppp_generic slhc irda crc_ccitt rds af_key decnet rose x25 atm netrom appletalk ipx p8023 psnap p8022 llc ax25 ip6t_REJECT nf_conntrack_ipv6 nf_defrag_ipv6 xt_state nf_conntrack ip6table_filter ip6_tables kvm_intel kvm crc32c_intel ghash_clmulni_intel serio_raw microcode usb_debug pcspkr i2c_i801 e1000e nfsd nfs_acl auth_rpcgss lockd sunrpc i915 video i2c_algo_bit drm_kms_helper drm i2c_core [last unloaded: scsi_wait_scan]

Pid: 30885, comm: trinity-child0 Not tainted 3.5.0-rc1+ #61
RIP: 0010:[<ffffffff8116a4f2>]  [<ffffffff8116a4f2>] unmap_single_vma+0x6f2/0x750
RSP: 0000:ffff880119c4dab8  EFLAGS: 00010246
RAX: ffff880116976300 RBX: 0000000100001000 RCX: ffff880000000000
RDX: ffff880117c59000 RSI: 0000000100000fff RDI: ffff880119c4dbe0
RBP: ffff880119c4db78 R08: 0000000000000000 R09: 0000000000000000
R10: 0000000000000001 R11: 0000000000000000 R12: ffffffffffffffff
R13: 0000000100000000 R14: 0000000100000000 R15: ffff880119c4dbe0
FS:  00007fd1f2624740(0000) GS:ffff880147c00000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 000000000256f000 CR3: 0000000116e19000 CR4: 00000000001407f0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process trinity-child0 (pid: 30885, threadinfo ffff880119c4c000, task ffff880117dc0000)
Stack:
 0000000019c4dad8 0000000000000070 0000000100000fff 0000000100000fff
 0000000100001000 ffff880116e19000 0000000100000fff ffff88013f500020
 0000000100001000 ffff880116976300 ffff880116976360 000000013d559160
Call Trace:
 [<ffffffff8116ad22>] unmap_vmas+0x52/0xa0
 [<ffffffff81172934>] exit_mmap+0xb4/0x150
 [<ffffffff81046033>] mmput+0x83/0xf0
 [<ffffffff8104f2b8>] exit_mm+0x108/0x130
 [<ffffffff8164dd2b>] ? _raw_spin_unlock_irq+0x3b/0x60
 [<ffffffff8104f444>] do_exit+0x164/0xb90
 [<ffffffff81062781>] ? get_signal_to_deliver+0x291/0x930
 [<ffffffff810b1e7e>] ? put_lock_stats.isra.23+0xe/0x40
 [<ffffffff8164dd20>] ? _raw_spin_unlock_irq+0x30/0x60
 [<ffffffff810501bc>] do_group_exit+0x4c/0xc0
 [<ffffffff810627be>] get_signal_to_deliver+0x2ce/0x930
 [<ffffffff8100225f>] do_signal+0x3f/0x610
 [<ffffffff81630000>] ? ich6_lpc_generic_decode+0x12/0x73
 [<ffffffff8163fb4b>] ? is_prefetch.isra.13+0xd8/0x1fd
 [<ffffffff8164e443>] ? error_sti+0x5/0x6
 [<ffffffff8164e08e>] ? retint_signal+0x11/0x83
 [<ffffffff810028d8>] do_notify_resume+0x88/0xc0
 [<ffffffff8164e0c3>] retint_signal+0x46/0x83
Code: 40 49 89 04 24 e9 a4 fd ff ff 0f 1f 80 00 00 00 00 48 8b 55 98 48 8b 7d a0 4c 89 e9 4c 89 f6 e8 15 dd ff ff e9 a9 fd ff ff 0f 0b <0f> 0b 48 8b 7d a0 31 d2 31 f6 e8 1f 97 ec ff e9 74 f9 ff ff 48 
RIP  [<ffffffff8116a4f2>] unmap_single_vma+0x6f2/0x750
 RSP <ffff880119c4dab8>
---[ end trace 9e2b5f3bc9692250 ]---


That's this in zap_pmd_range


1227                         if (next - addr != HPAGE_PMD_SIZE) {
1228                                 VM_BUG_ON(!rwsem_is_locked(&tlb->mm->mmap_sem));
1229                                 split_huge_page_pmd(vma->vm_mm, pmd);

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
