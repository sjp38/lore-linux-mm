Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx156.postini.com [74.125.245.156])
	by kanga.kvack.org (Postfix) with SMTP id 047876B0062
	for <linux-mm@kvack.org>; Wed,  6 Jun 2012 22:34:24 -0400 (EDT)
Message-ID: <4FD01229.4020607@redhat.com>
Date: Thu, 07 Jun 2012 10:30:01 +0800
From: Zhouping Liu <zliu@redhat.com>
MIME-Version: 1.0
Subject: Re: AutoNUMA15
References: <1337965359-29725-1-git-send-email-aarcange@redhat.com> <20120529133627.GA7637@shutemov.name> <20120529154308.GA10790@dhcp-27-244.brq.redhat.com> <20120531180834.GP21339@redhat.com>
In-Reply-To: <20120531180834.GP21339@redhat.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Petr Holasek <pholasek@redhat.com>, "Kirill A. Shutemov" <kirill@shutemov.name>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Hillf Danton <dhillf@gmail.com>, Dan Smith <danms@us.ibm.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>, Christoph Lameter <cl@linux.com>, caiqian@redhat.com

On 06/01/2012 02:08 AM, Andrea Arcangeli wrote:
> Hi,
>
> On Tue, May 29, 2012 at 05:43:09PM +0200, Petr Holasek wrote:
>> Similar problem with __autonuma_migrate_page_remove here.
>>
>> [ 1945.516632] ------------[ cut here ]------------
>> [ 1945.516636] WARNING: at lib/list_debug.c:50 __list_del_entry+0x63/0xd0()
>> [ 1945.516642] Hardware name: ProLiant DL585 G5
>> [ 1945.516651] list_del corruption, ffff88017d68b068->next is LIST_POISON1 (dead000000100100)
>> [ 1945.516682] Modules linked in: ipt_MASQUERADE nf_conntrack_netbios_ns nf_conntrack_broadcast ip6table_mangle lockd ip6t_REJECT sunrpc nf_conntrack_ipv6 nf_defrag_ipv6 ip6table_filter ip6_tables iptable_nat nf_nat iptable_mangle nf_conntrack_ipv4 nf_defrag_ipv4 xt_conntrack nf_conntrack mperf freq_table kvm_amd kvm pcspkr amd64_edac_mod edac_core serio_raw bnx2 microcode edac_mce_amd shpchp k10temp hpilo ipmi_si ipmi_msghandler hpwdt qla2xxx hpsa ata_generic pata_acpi scsi_transport_fc scsi_tgt cciss pata_amd radeon i2c_algo_bit drm_kms_helper ttm drm i2c_core [last unloaded: scsi_wait_scan]
>> [ 1945.516694] Pid: 150, comm: knuma_migrated0 Tainted: G        W    3.4.0aa_alpha+ #3
>> [ 1945.516701] Call Trace:
>> [ 1945.516710]  [<ffffffff8105788f>] warn_slowpath_common+0x7f/0xc0
>> [ 1945.516717]  [<ffffffff81057986>] warn_slowpath_fmt+0x46/0x50
>> [ 1945.516726]  [<ffffffff812f9713>] __list_del_entry+0x63/0xd0
>> [ 1945.516735]  [<ffffffff812f9791>] list_del+0x11/0x40
>> [ 1945.516743]  [<ffffffff81165b98>] __autonuma_migrate_page_remove+0x48/0x80
>> [ 1945.516746]  [<ffffffff81165e66>] knuma_migrated+0x296/0x8a0
>> [ 1945.516749]  [<ffffffff8107a200>] ? wake_up_bit+0x40/0x40
>> [ 1945.516758]  [<ffffffff81165bd0>] ? __autonuma_migrate_page_remove+0x80/0x80
>> [ 1945.516766]  [<ffffffff81079cc3>] kthread+0x93/0xa0
>> [ 1945.516780]  [<ffffffff81626f24>] kernel_thread_helper+0x4/0x10
>> [ 1945.516791]  [<ffffffff81079c30>] ? flush_kthread_worker+0x80/0x80
>> [ 1945.516798]  [<ffffffff81626f20>] ? gs_change+0x13/0x13
>> [ 1945.516800] ---[ end trace 7cab294af87bd79f ]---
> I didn't manage to reproduce it on my hardware but it seems this was
> caused by the autonuma_migrate_split_huge_page: the tail page list
> linking wasn't surrounded by the compound lock to make list insertion
> and migrate_nid setting atomic like it happens everywhere else (the
> caller holding the lock on the head page wasn't enough to make the
> tails stable too).
>
> I released an AutoNUMA15 branch that includes all pending fixes:
>
> git clone --reference linux -b autonuma15 git://git.kernel.org/pub/scm/linux/kernel/git/andrea/aa.git

hi, Andrea and all

when I tested autonuma patch set, kernel panic occurred in the process 
of starting with new compiled kernel,
also I found the issue in latest Linus tree(3.5.0-rc1), partial call 
trace are:

[    2.635443] kernel BUG at include/linux/gfp.h:318!
[    2.642998] invalid opcode: 0000 [#1] SMP
[    2.651148] CPU 0
[    2.653911] Modules linked in:
[    2.662388]
[    2.664657] Pid: 1, comm: swapper/0 Not tainted 3.4.0+ #1 HP ProLiant 
DL585 G7
[    2.677609] RIP: 0010:[<ffffffff811b044d>]  [<ffffffff811b044d>] 
new_slab+0x26d/0x310
[    2.692803] RSP: 0018:ffff880135ad3c80  EFLAGS: 00010246
[    2.702541] RAX: 0000000000000000 RBX: ffff880137008c80 RCX: 
ffff8801377db780
[    2.716402] RDX: ffff880135bf8000 RSI: 0000000000000003 RDI: 
00000000000052d0
[    2.728471] RBP: ffff880135ad3cb0 R08: 0000000000000000 R09: 
0000000000000000
[    2.743791] R10: 0000000000000001 R11: 0000000000000000 R12: 
00000000000040d0
[    2.756111] R13: ffff880137008c80 R14: 0000000000000001 R15: 
0000000000030027
[    2.770428] FS:  0000000000000000(0000) GS:ffff880137600000(0000) 
knlGS:0000000000000000
[    2.786319] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[    2.798100] CR2: 0000000000000000 CR3: 000000000196b000 CR4: 
00000000000007f0
[    2.810264] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 
0000000000000000
[    2.824889] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 
0000000000000400
[    2.836882] Process swapper/0 (pid: 1, threadinfo ffff880135ad2000, 
task ffff880135bf8000)
[    2.856452] Stack:
[    2.859175]  ffff880135ad3ca0 0000000000000002 0000000000000001 
ffff880137008c80
[    2.872325]  ffff8801377db760 ffff880137008c80 ffff880135ad3db0 
ffffffff8167632f
[    2.887248]  ffffffff8167e0e7 0000000000000000 ffff8801377db780 
ffff8801377db770
[    2.899666] Call Trace:
[    2.906792]  [<ffffffff8167632f>] __slab_alloc+0x351/0x4d2
[    2.914238]  [<ffffffff8167e0e7>] ? mutex_lock_nested+0x2e7/0x390
[    2.925157]  [<ffffffff813350d8>] ? alloc_cpumask_var_node+0x28/0x90
[    2.939430]  [<ffffffff81c81e50>] ? sched_init_smp+0x16a/0x3b4
[    2.949790]  [<ffffffff811b1a04>] kmem_cache_alloc_node_trace+0xa4/0x250
[    2.964259]  [<ffffffff8109e72f>] ? kzalloc+0xf/0x20
[    2.976298]  [<ffffffff81c81e50>] ? sched_init_smp+0x16a/0x3b4
[    2.984664]  [<ffffffff81c81e50>] sched_init_smp+0x16a/0x3b4
[    2.997217]  [<ffffffff81c66d57>] kernel_init+0xe3/0x215
[    3.006848]  [<ffffffff810d4c3d>] ? trace_hardirqs_on_caller+0x10d/0x1a0
[    3.020673]  [<ffffffff8168c3b4>] kernel_thread_helper+0x4/0x10
[    3.031154]  [<ffffffff81682470>] ? retint_restore_args+0x13/0x13
[    3.040816]  [<ffffffff81c66c74>] ? start_kernel+0x401/0x401
[    3.052881]  [<ffffffff8168c3b0>] ? gs_change+0x13/0x13
[    3.061692] Code: 1f 80 00 00 00 00 fa 66 66 90 66 66 90 e8 cc e2 f1 
ff e9 71 fe ff ff 0f 1f 80 00 00 00 00 e8 8b 25 ff ff 49 89 c5 e9 4a fe 
ff ff <0f> 0b 0f 0b 49 8b 45 00 31 c9 f6 c4 40 74 04 41 8b 4d 68 ba 00
[    3.095893] RIP  [<ffffffff811b044d>] new_slab+0x26d/0x310
[    3.107828]  RSP <ffff880135ad3c80>
[    3.114024] ---[ end trace e696d6ddf3adb276 ]---
[    3.121541] swapper/0 used greatest stack depth: 4768 bytes left
[    3.143784] Kernel panic - not syncing: Attempted to kill init! 
exitcode=0x0000000b
[    3.143784]

such above errors occurred in my two boxes:
in one machine, which has 120Gb RAM and 8 numa nodes with AMD CPU, 
kernel panic occurred in autonuma15 and Linus tree(3.5.0-rc1)
but in another one, which has 16Gb RAM and 4 numa nodes with AMD CPU, 
kernel panic only occurred in autonuma15, no such issues in Linus tree,

whole panic info is available in 
http://www.sanweiying.org/download/kernel_panic_log
and config file in http://www.sanweiying.org/download/config

please feel free to tell me if you need more detailed info.

Thanks,
Zhouping

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
