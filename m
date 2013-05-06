Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx161.postini.com [74.125.245.161])
	by kanga.kvack.org (Postfix) with SMTP id 5051F6B011D
	for <linux-mm@kvack.org>; Mon,  6 May 2013 04:11:51 -0400 (EDT)
Date: Mon, 6 May 2013 04:11:50 -0400 (EDT)
From: CAI Qian <caiqian@redhat.com>
Message-ID: <182191740.7632050.1367827910594.JavaMail.root@redhat.com>
In-Reply-To: <1229089404.7626676.1367827736964.JavaMail.root@redhat.com>
Subject: 3.9.0: system deadlock at semctl running selinux testsuite
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>
Cc: linux-mm <linux-mm@kvack.org>

The serial console was kept flooding by the message below until the system
was dead entirely running the upstream selinux testsuite. Never saw any of
those during the previous RC testing.

[ 3208.133005] BUG: soft lockup - CPU#1 stuck for 22s! [semctl:32186] 
[ 3208.133005] Modules linked in: nfsv3 nfs_acl nfsv2 nfs lockd sunrpc fscache nfnetlink_log nfnetlink bluetooth rfkill arc4 md4 nls_utf8 cifs dns_resolver nf_tproxy_core nls_koi8_u nls_cp932 ts_kmp sctp nf_conntrack_netbios_ns nf_conntrack_broadcast ipt_MASQUERADE ip6table_mangle ip6t_REJECT nf_conntrack_ipv6 nf_defrag_ipv6 iptable_nat nf_nat_ipv4 nf_nat iptable_mangle ipt_REJECT nf_conntrack_ipv4 nf_defrag_ipv4 xt_conntrack nf_conntrack ebtable_filter ebtables ip6table_filter ip6_tables iptable_filter ip_tables sg pcspkr microcode i2c_piix4 virtio_balloon xfs libcrc32c ata_generic pata_acpi cirrus syscopyarea sysfillrect sysimgblt drm_kms_helper ttm drm virtio_net virtio_blk ata_piix libata i2c_core floppy dm_mirror dm_region_hash dm_log dm_mod [last unloaded: zlib_deflate] 
[ 3208.133005] CPU: 1 PID: 32186 Comm: semctl Tainted: G    B   W    3.9.0+ #1 
[ 3208.133005] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011 
[ 3208.133005] task: ffff880064e40000 ti: ffff88006f68c000 task.ti: ffff88006f68c000 
[ 3208.133005] RIP: 0010:[<ffffffff815f7632>]  [<ffffffff815f7632>] _raw_spin_lock+0x22/0x30 
[ 3208.133005] RSP: 0018:ffff88006f68dec8  EFLAGS: 00000202 
[ 3208.133005] RAX: 0000000000000007 RBX: ffff88003726eca0 RCX: 0000000000000004 
[ 3208.133005] RDX: 0000000000000005 RSI: ffffffff81951828 RDI: ffff88006f9fc220 
[ 3208.133005] RBP: ffff88006f68dec8 R08: ffffffff81951820 R09: 0000000000000000 
[ 3208.133005] R10: 00007fff0f388a40 R11: 0000000000000001 R12: ffffffff815fb02c 
[ 3208.133005] R13: ffff88006f68df38 R14: ffff88005fae86c0 R15: ffff88006f68df58 
[ 3208.133005] FS:  00007f7033ca3740(0000) GS:ffff88007fd00000(0000) knlGS:0000000000000000 
[ 3208.133005] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033 
[ 3208.133005] CR2: 00007f70337cdfb0 CR3: 000000006ef89000 CR4: 00000000000006e0 
[ 3208.133005] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000 
[ 3208.133005] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400 
[ 3208.133005] Stack: 
[ 3208.133005]  ffff88006f68df38 ffffffff8126fe85 000003ff64e40000 ffffffff81951820 
[ 3208.133005]  ffffffff81951830 ffff88006f68df60 ffff88006f68df50 ffffffff81951850 
[ 3208.133005]  0000000000000002 0000000000000000 00000000004005f0 00007fff0f388e30 
[ 3208.133005] Call Trace: 
[ 3208.133005]  [<ffffffff8126fe85>] ipcget+0x105/0x1a0 
[ 3208.133005]  [<ffffffff81273a1a>] SyS_semget+0x6a/0x80 
[ 3208.133005]  [<ffffffff81271760>] ? sem_security+0x10/0x10 
[ 3208.133005]  [<ffffffff81271750>] ? wake_up_sem_queue_do+0x60/0x60 
[ 3208.133005]  [<ffffffff812716c0>] ? SyS_msgrcv+0x20/0x20 
[ 3208.133005]  [<ffffffff815ff942>] system_call_fastpath+0x16/0x1b 
[ 3208.133005] Code: 2e 0f 1f 84 00 00 00 00 00 0f 1f 44 00 00 55 48 89 e5 b8 00 00 01 00 f0 0f c1 07 89 c2 c1 ea 10 66 39 c2 74 0e 0f 1f 40 00 f3 90 <0f> b7 07 66 39 d0 75 f6 5d c3 90 90 90 90 0f 1f 44 00 00 55 48  
[ 3236.133005] BUG: soft lockup - CPU#1 stuck for 22s! [semctl:32186] 
[ 3236.133005] Modules linked in: nfsv3 nfs_acl nfsv2 nfs lockd sunrpc fscache nfnetlink_log nfnetlink bluetooth rfkill arc4 md4 nls_utf8 cifs dns_resolver nf_tproxy_core nls_koi8_u nls_cp932 ts_kmp sctp nf_conntrack_netbios_ns nf_conntrack_broadcast ipt_MASQUERADE ip6table_mangle ip6t_REJECT nf_conntrack_ipv6 nf_defrag_ipv6 iptable_nat nf_nat_ipv4 nf_nat iptable_mangle ipt_REJECT nf_conntrack_ipv4 nf_defrag_ipv4 xt_conntrack nf_conntrack ebtable_filter ebtables ip6table_filter ip6_tables iptable_filter ip_tables sg pcspkr microcode i2c_piix4 virtio_balloon xfs libcrc32c ata_generic pata_acpi cirrus syscopyarea sysfillrect sysimgblt drm_kms_helper ttm drm virtio_net virtio_blk ata_piix libata i2c_core floppy dm_mirror dm_region_hash dm_log dm_mod [last unloaded: zlib_deflate] 
[ 3236.133005] CPU: 1 PID: 32186 Comm: semctl Tainted: G    B   W    3.9.0+ #1 
[ 3236.133005] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011 
[ 3236.133005] task: ffff880064e40000 ti: ffff88006f68c000 task.ti: ffff88006f68c000 
[ 3236.133005] RIP: 0010:[<ffffffff815f7632>]  [<ffffffff815f7632>] _raw_spin_lock+0x22/0x30 
[ 3236.133005] RSP: 0018:ffff88006f68dec8  EFLAGS: 00000202 
[ 3236.133005] RAX: 0000000000000007 RBX: ffff88003726eca0 RCX: 0000000000000004 
[ 3236.133005] RDX: 0000000000000005 RSI: ffffffff81951828 RDI: ffff88006f9fc220 
[ 3236.133005] RBP: ffff88006f68dec8 R08: ffffffff81951820 R09: 0000000000000000 
[ 3236.133005] R10: 00007fff0f388a40 R11: 0000000000000001 R12: ffffffff815fb02c 
[ 3236.133005] R13: ffff88006f68df38 R14: ffff88005fae86c0 R15: ffff88006f68df58 
[ 3236.133005] FS:  00007f7033ca3740(0000) GS:ffff88007fd00000(0000) knlGS:0000000000000000 
[ 3236.133005] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033 
[ 3236.133005] CR2: 00007f70337cdfb0 CR3: 000000006ef89000 CR4: 00000000000006e0 
[ 3236.133005] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000 
[ 3236.133005] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400 
[ 3236.133005] Stack: 
[ 3236.133005]  ffff88006f68df38 ffffffff8126fe85 000003ff64e40000 ffffffff81951820 
[ 3236.133005]  ffffffff81951830 ffff88006f68df60 ffff88006f68df50 ffffffff81951850 
[ 3236.133005]  0000000000000002 0000000000000000 00000000004005f0 00007fff0f388e30 
[ 3236.133005] Call Trace: 
[ 3236.133005]  [<ffffffff8126fe85>] ipcget+0x105/0x1a0 
[ 3236.133005]  [<ffffffff81273a1a>] SyS_semget+0x6a/0x80 
[ 3236.133005]  [<ffffffff81271760>] ? sem_security+0x10/0x10 
[ 3236.133005]  [<ffffffff81271750>] ? wake_up_sem_queue_do+0x60/0x60 
[ 3236.133005]  [<ffffffff812716c0>] ? SyS_msgrcv+0x20/0x20 
[ 3236.133005]  [<ffffffff815ff942>] system_call_fastpath+0x16/0x1b 
[ 3236.133005] Code: 2e 0f 1f 84 00 00 00 00 00 0f 1f 44 00 00 55 48 89 e5 b8 00 00 01 00 f0 0f c1 07 89 c2 c1 ea 10 66 39 c2 74 0e 0f 1f 40 00 f3 90 <0f> b7 07 66 39 d0 75 f6 5d c3 90 90 90 90 0f 1f 44 00 00 55 48  
[ 3242.673005] INFO: rcu_sched self-detected stall on CPU { 1}  (t=60000 jiffies g=408763 c=408762 q=1690761) 
[ 3242.673005] sending NMI to all CPUs: 
[ 3242.673005] NMI backtrace for cpu 1 
[ 3242.673005] CPU: 1 PID: 32186 Comm: semctl Tainted: G    B   W    3.9.0+ #1 
[ 3242.673005] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011 
[ 3242.673005] task: ffff880064e40000 ti: ffff88006f68c000 task.ti: ffff88006f68c000 
[ 3242.673005] RIP: 0010:[<ffffffff8102c1ef>]  [<ffffffff8102c1ef>] flat_send_IPI_mask+0x5f/0x80 
[ 3242.673005] RSP: 0018:ffff88007fd03d68  EFLAGS: 00010046 
[ 3242.673005] RAX: 0000000000000c00 RBX: 0000000000000c00 RCX: 0000000000000006 
[ 3242.673005] RDX: ffffffff818e7e20 RSI: 0000000000000002 RDI: 0000000000000300 
[ 3242.673005] RBP: ffff88007fd03d98 R08: ffffffff819cecc0 R09: 000000000001db68 
[ 3242.673005] R10: 0000000000000000 R11: 000000000001db67 R12: 0000000000000092 
[ 3242.673005] R13: 0000000000000003 R14: ffff88007fd0dd40 R15: 000000000019cc89 
[ 3242.673005] FS:  00007f7033ca3740(0000) GS:ffff88007fd00000(0000) knlGS:0000000000000000 
[ 3242.673005] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033 
[ 3242.673005] CR2: 00007f70337cdfb0 CR3: 000000006ef89000 CR4: 00000000000006e0 
[ 3242.673005] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000 
[ 3242.673005] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400 
[ 3242.673005] Stack: 
[ 3242.673005]  ffff88007fd03db8 ffff880000000002 ffff88007fd03db8 0000000000002710 
[ 3242.673005]  0000000000000001 ffffffff8191f980 ffff88007fd03da8 ffffffff8102c275 
[ 3242.673005]  ffff88007fd03dc8 ffffffff81027627 0000000000000000 ffffffff8191f980 
[ 3242.673005] Call Trace: 
[ 3242.673005]  <IRQ>  
[ 3242.673005]  [<ffffffff8102c275>] flat_send_IPI_all+0x65/0x70 
[ 3242.673005]  [<ffffffff81027627>] arch_trigger_all_cpu_backtrace+0x67/0xb0 
[ 3242.673005]  [<ffffffff810e7fb3>] rcu_check_callbacks+0x303/0x5e0 
[ 3242.673005]  [<ffffffff8105ef38>] update_process_times+0x48/0x80 
[ 3242.673005]  [<ffffffff810a834e>] tick_sched_handle.isra.8+0x2e/0x70 
[ 3242.673005]  [<ffffffff810a84ec>] tick_sched_timer+0x4c/0x80 
[ 3242.673005]  [<ffffffff81076c5f>] __run_hrtimer+0x6f/0x1b0 
[ 3242.673005]  [<ffffffff810a84a0>] ? tick_sched_do_timer+0x40/0x40 
[ 3242.673005]  [<ffffffff81077577>] hrtimer_interrupt+0x107/0x240 
[ 3242.673005]  [<ffffffff816012e9>] smp_apic_timer_interrupt+0x69/0x99 
[ 3242.673005]  [<ffffffff8160057a>] apic_timer_interrupt+0x6a/0x70 
[ 3242.673005]  <EOI>  
[ 3242.673005]  [<ffffffff815f7632>] ? _raw_spin_lock+0x22/0x30 
[ 3242.673005]  [<ffffffff8126fe85>] ipcget+0x105/0x1a0 
[ 3242.673005]  [<ffffffff81273a1a>] SyS_semget+0x6a/0x80 
[ 3242.673005]  [<ffffffff81271760>] ? sem_security+0x10/0x10 
[ 3242.673005]  [<ffffffff81271750>] ? wake_up_sem_queue_do+0x60/0x60 
[ 3242.673005]  [<ffffffff812716c0>] ? SyS_msgrcv+0x20/0x20 
[ 3242.673005]  [<ffffffff815ff942>] system_call_fastpath+0x16/0x1b 
[ 3242.673005] Code: 25 00 a3 5f ff f6 c4 10 75 f2 44 89 e8 c1 e0 18 89 04 25 10 a3 5f ff 89 f0 09 d8 80 cf 04 83 fe 02 0f 44 c3 89 04 25 00 a3 5f ff <41> 54 9d 48 83 c4 18 5b 41 5c 41 5d 5d c3 89 75 d8 ff 92 50 01  
[ 3242.675012] NMI backtrace for cpu 0 
[ 3242.675012] CPU: 0 PID: 0 Comm: swapper/0 Tainted: G    B   W    3.9.0+ #1 
[ 3242.675012] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011 
[ 3242.675012] task: ffffffff818da440 ti: ffffffff818ca000 task.ti: ffffffff818ca000 
[ 3242.675012] RIP: 0010:[<ffffffff8100a3ac>]  [<ffffffff8100a3ac>] default_idle+0x1c/0xb0 
[ 3242.675012] RSP: 0018:ffffffff818cbee8  EFLAGS: 00000286 
[ 3242.675012] RAX: 00000000ffffffed RBX: ffffffff818cbfd8 RCX: 0100000000000000 
[ 3242.675012] RDX: 0100000000000000 RSI: 0000000000000000 RDI: 0000000000000000 
[ 3242.675012] RBP: ffffffff818cbef8 R08: 0000000000000000 R09: 0000000000000000 
[ 3242.675012] R10: 0000000000000000 R11: 0000000000000000 R12: 0000000000000000 
[ 3242.675012] R13: ffffffff818cbfd8 R14: ffffffff818cbfd8 R15: 0000000000000000 
[ 3242.675012] FS:  0000000000000000(0000) GS:ffff88007fc00000(0000) knlGS:0000000000000000 
[ 3242.675012] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b 
[ 3242.675012] CR2: 00007fbee5878420 CR3: 000000007ab49000 CR4: 00000000000006f0 
[ 3242.675012] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000 
[ 3242.675012] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400 
[ 3242.675012] Stack: 
[ 3242.675012]  ffffffff818cbfd8 ffffffff818cbfd8 ffffffff818cbf08 ffffffff8100ac1e 
[ 3242.675012]  ffffffff818cbf58 ffffffff8109eae9 ffffffff818cbfd8 ffffffff81a8e2e0 
[ 3242.675012]  ffff88007ffa4780 ffffffffffffffff ffffffff81a86020 ffffffff81a8e2e0 
[ 3242.675012] Call Trace: 
[ 3242.675012]  [<ffffffff8100ac1e>] arch_cpu_idle+0x1e/0x30 
[ 3242.675012]  [<ffffffff8109eae9>] cpu_startup_entry+0x89/0x210 
[ 3242.675012]  [<ffffffff815d50c7>] rest_init+0x77/0x80 
[ 3242.675012]  [<ffffffff819f1e6d>] start_kernel+0x3f9/0x406 
[ 3242.675012]  [<ffffffff819f1873>] ? repair_env_string+0x5e/0x5e 
[ 3242.675012]  [<ffffffff819f15a3>] x86_64_start_reservations+0x2a/0x2c 
[ 3242.675012]  [<ffffffff819f1673>] x86_64_start_kernel+0xce/0xd2 
[ 3242.675012] Code: 89 e5 e8 48 eb 06 00 5d c3 66 0f 1f 44 00 00 0f 1f 44 00 00 55 48 89 e5 41 54 65 44 8b 24 25 1c b0 00 00 53 0f 1f 44 00 00 fb f4 <65> 44 8b 24 25 1c b0 00 00 0f 1f 44 00 00 5b 41 5c 5d c3 90 e8 

CAI Qian 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
