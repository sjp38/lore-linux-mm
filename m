Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx167.postini.com [74.125.245.167])
	by kanga.kvack.org (Postfix) with SMTP id 3469A6B004D
	for <linux-mm@kvack.org>; Wed,  1 Aug 2012 09:44:19 -0400 (EDT)
Date: Wed, 1 Aug 2012 09:44:13 -0400
From: Dave Jones <davej@redhat.com>
Subject: Replace BUG() in mpol_to_str with -EINVAL
Message-ID: <20120801134413.GA10153@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Linux Kernel <linux-kernel@vger.kernel.org>

I just hit this bug while bisecting another (so it's against a 3.4 kernel,
though the code doesn't seem to be any different in Linus' current tree).


kernel BUG at mm/mempolicy.c:2546!
invalid opcode: 0000 [#1] SMP 
CPU 2 
Modules linked in: tun fuse binfmt_misc caif_socket caif phonet bluetooth rfkill can llc2 pppoe pppox ppp_generic slhc irda crc_ccitt rds af_key decnet rose x25 atm netrom appletalk ipx p8023 psnap p8022 llc ax25 ip6t_REJECT nf_conntrack_ipv6 nf_defrag_ipv6 xt_state nf_conntrack ip6table_filter ip6_tables crc32c_intel ghash_clmulni_intel microcode usb_debug pcspkr i2c_i801 e1000e nfsd nfs_acl auth_rpcgss lockd sunrpc i915 video i2c_algo_bit drm_kms_helper drm i2c_core [last unloaded: scsi_wait_scan]

Pid: 23988, comm: trinity-child2 Not tainted 3.4.0-rc7+ #23
RIP: 0010:[<ffffffff811a3b16>]  [<ffffffff811a3b16>] mpol_to_str+0x156/0x360
RSP: 0018:ffff88010197fc98  EFLAGS: 00010202
RAX: 0000000000006b6b RBX: ffff880109a34000 RCX: 0000000000000000
RDX: ffff8801464984a0 RSI: 0000000000000032 RDI: ffff88010197fdbe
RBP: ffff88010197fd48 R08: 00000000000992f0 R09: ffffffff819ce9fa
R10: 0000000000000001 R11: 0000000000000003 R12: ffff88010197fdbe
R13: 0000000000000032 R14: 0000000000006b6b R15: ffff880141c3e880
FS:  00007fa1e5216740(0000) GS:ffff880148000000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 0000000000000000 CR3: 00000001426dd000 CR4: 00000000001407e0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
Process trinity-child2 (pid: 23988, threadinfo ffff88010197e000, task ffff88007821a670)
Stack:
 ffff88010197fcb8 ffffffff81340b85 ffff88013e4292c8 0000000000000000
 ffff88010197fcd8 ffffffff81670a6b ffff88013e4292c0 ffff8801464984a0
 ffff88010197fd08 ffffffff811a2f8e 00007fd34e935fff 0000000000000000
Call Trace:
 [<ffffffff81340b85>] ? do_raw_spin_unlock+0x75/0xd0
 [<ffffffff81670a6b>] ? _raw_spin_unlock+0x2b/0x50
 [<ffffffff811a2f8e>] ? mpol_shared_policy_lookup+0x5e/0x80
 [<ffffffff81171740>] ? shmem_get_policy+0x30/0x40
 [<ffffffff8122f235>] show_numa_map+0xd5/0x450
 [<ffffffff8122fb50>] ? gather_hugetbl_stats+0x70/0x70
 [<ffffffff8122fae0>] ? pagemap_hugetlb_range+0xf0/0xf0
 [<ffffffff8122e6a2>] ? m_start+0xa2/0x180
 [<ffffffff8122f5e3>] show_pid_numa_map+0x13/0x20
 [<ffffffff811eaf32>] traverse+0xf2/0x230
 [<ffffffff811eb74b>] seq_read+0x34b/0x3e0
 [<ffffffff811c60ec>] vfs_read+0xac/0x180
 [<ffffffff811c6382>] sys_pread64+0xa2/0xc0
 [<ffffffff8167a0ad>] system_call_fastpath+0x1a/0x1f
Code: 19 00 48 98 48 01 c3 89 d8 44 29 e0 48 8b 5d d8 4c 8b 65 e0 4c 8b 6d e8 4c 8b 75 f0 4c 8b 7d f8 c9 c3 0f 1f 00 66 83 f8 03 76 0a <0f> 0b 0f 1f 84 00 00 00 00 00 85 c9 0f 84 08 01 00 00 48 8b 8a 
RIP  [<ffffffff811a3b16>] mpol_to_str+0x156/0x360

Signed-off-by: Dave Jones <davej@redhat.com>

diff --git a/mm/mempolicy.c b/mm/mempolicy.c
index bd92431..4ada3be 100644
--- a/mm/mempolicy.c
+++ b/mm/mempolicy.c
@@ -2562,7 +2562,7 @@ int mpol_to_str(char *buffer, int maxlen, struct mempolicy *pol, int no_context)
 		break;
 
 	default:
-		BUG();
+		return -EINVAL;
 	}
 
 	l = strlen(policy_modes[mode]);


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
