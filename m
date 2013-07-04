Return-Path: <owner-linux-mm@kvack.org>
Message-ID: <51D51B66.3000301@cn.fujitsu.com>
Date: Thu, 04 Jul 2013 14:51:18 +0800
From: Gu Zheng <guz.fnst@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [WiP]: aio support for migrating pages (Re: [PATCH V2 1/2] mm:
 hotplug: implement non-movable version of get_user_pages() called get_user_pages_non_movable())
References: <20130515132453.GB11497@suse.de> <5194748A.5070700@cn.fujitsu.com> <20130517002349.GI1008@kvack.org> <5195A3F4.70803@cn.fujitsu.com> <20130517143718.GK1008@kvack.org> <519AD6F8.2070504@cn.fujitsu.com> <20130521022733.GT1008@kvack.org> <51B6F107.80501@cn.fujitsu.com> <20130611144525.GB14404@kvack.org> <51D12E7B.6080301@cn.fujitsu.com> <20130702180008.GQ16399@kvack.org>
In-Reply-To: <20130702180008.GQ16399@kvack.org>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Benjamin LaHaise <bcrl@kvack.org>
Cc: Tang Chen <tangchen@cn.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Minchan Kim <minchan@kernel.org>, akpm@linux-foundation.org, viro@zeniv.linux.org.uk, khlebnikov@openvz.org, walken@google.com, kamezawa.hiroyu@jp.fujitsu.com, riel@redhat.com, rientjes@google.com, isimatu.yasuaki@jp.fujitsu.com, wency@cn.fujitsu.com, laijs@cn.fujitsu.com, jiang.liu@huawei.com, zab@redhat.com, jmoyer@redhat.com, linux-mm@kvack.org, linux-aio@kvack.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, Marek Szyprowski <m.szyprowski@samsung.com>

On 07/03/2013 02:00 AM, Benjamin LaHaise wrote:

> On Mon, Jul 01, 2013 at 03:23:39PM +0800, Gu Zheng wrote:
>> Hi Ben,
>> Are you still working on this patch?
>> As you know, using the current anon inode will lead to more than one instance of
>> aio can not work. Have you found a way to fix this issue? Or can we use some
>> other ones to replace the anon inode?
> 
> This patch hasn't been a high priority for me.  I would really appreciate 
> it if someone could confirm that this patch does indeed fix the hotplug 
> page migration issue by testing it in a system that hits the bug.  Removing 
> the anon_inode bits isn't too much work, but I'd just like to have some 
> confirmation that this fix is considered to be "good enough" for the 
> problem at hand before spending any further time on it.  There was talk of 
> using another approach, but it's not clear if there was any progress.

Hi Ben,
      When I test your patch on kernel 3.10, the kernel panic when aio job
complete or exit, exactly in aio_free_ring(), the following is a part of dmesg.

Thanks,
Gu

kernel BUG at mm/swap.c:163!

invalid opcode: 0000 [#1] SMP

Modules linked in: ebtable_nat ebtables ipt_MASQUERADE iptable_nat nf_nat_ipv4
nf_nat xt_CHECKSUM iptable_mangle bridge stp llc autofs4 sunrpc cpufreq_ondemand
ipt_REJECT nf_conntrack_ipv4 nf_defrag_ipv4 iptable_filter ip6t_REJECT
nf_conntrack_ipv6 nf_defrag_ipv6 xt_state nf_conntrack ip6table_filter
ip6_tables ipv6 vfat fat dm_mirror dm_region_hash dm_log dm_mod vhost_net
macvtap macvlan tun uinput iTCO_wdt iTCO_vendor_support acpi_cpufreq freq_table
mperf coretemp kvm_intel kvm crc32c_intel microcode pcspkr sg i2c_i801 lpc_ich
mfd_core ioatdma i7core_edac edac_core e1000e igb dca i2c_algo_bit i2c_core ptp
pps_core ext4(F) jbd2(F) mbcache(F) sd_mod(F) crc_t10dif(F) megaraid_sas(F)
mptsas(F) mptscsih(F) mptbase(F) scsi_transport_sas(F)

CPU: 4 PID: 100 Comm: kworker/4:1 Tainted: GF            3.10.0-aio-migrate+
#107
Hardware name: FUJITSU-SV PRIMEQUEST 1800E/SB, BIOS PRIMEQUEST 1000 Series BIOS
Version 89.32 DP Proto 08/16/2012
Workqueue: events kill_ioctx_work

task: ffff8807dda974e0 ti: ffff8807dda98000 task.ti: ffff8807dda98000

RIP: 0010:[<ffffffff8111a9a8>]  [<ffffffff8111a9a8>] put_page+0x48/0x60

RSP: 0018:ffff8807dda99cd8  EFLAGS: 00010246

RAX: 0000000000000000 RBX: ffff8807be1f1e00 RCX: 0000000000000001

RDX: 0000000000000000 RSI: 0000000000000000 RDI: ffffea001b196c80

RBP: ffff8807dda99cd8 R08: 0000000000000000 R09: 0000000000000000

R10: ffff8807ffbb5f00 R11: 000000000000005a R12: 0000000000000001

R13: 0000000000000000 R14: ffff8807dda974e0 R15: ffff8807be1f1ec8

FS:  0000000000000000(0000) GS:ffff8807fd680000(0000) knlGS:0000000000000000

CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b

CR2: 0000003b826dc7d0 CR3: 0000000001a0b000 CR4: 00000000000007e0

DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000

DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400

Stack:

 ffff8807dda99d18 ffffffff811b11f6 0000000000000000 0000000200000000

 ffff8807be1f1e00 ffff8807be1f1e80 000000000000000c 0000000000000000

 ffff8807dda99dc8 ffffffff811b21a2 00000001000438ec ffff8807fd692d00

Call Trace:

 [<ffffffff811b11f6>] aio_free_ring+0x96/0x1c0

 [<ffffffff811b21a2>] free_ioctx+0x1f2/0x250

 [<ffffffff81081a5d>] ? idle_balance+0xed/0x140

 [<ffffffff811b221a>] put_ioctx+0x1a/0x30

 [<ffffffff811b24af>] kill_ioctx_work+0x2f/0x40

 [<ffffffff81060933>] process_one_work+0x183/0x490

 [<ffffffff81061ac0>] worker_thread+0x120/0x3a0

 [<ffffffff810619a0>] ? manage_workers+0x160/0x160

 [<ffffffff8106786e>] kthread+0xce/0xe0

 [<ffffffff810677a0>] ? kthread_freezable_should_stop+0x70/0x70

 [<ffffffff8154b79c>] ret_from_fork+0x7c/0xb0

 [<ffffffff810677a0>] ? kthread_freezable_should_stop+0x70/0x70

Code: 07 00 c0 75 1f f0 ff 4f 1c 0f 94 c0 84 c0 75 0b c9 66 90 c3 0f 1f 80 00 00
00 00 e8 53 fe ff ff c9 66 90 c3 e8 7a fe ff ff c9 c3 <0f> 0b 66 0f 1f 44 00 00
eb f8 48 8b 47 30 eb bc 0f 1f 84 00 00
RIP  [<ffffffff8111a9a8>] put_page+0x48/0x60

 RSP <ffff8807dda99cd8>

---[ end trace b5e2c17407c840d8 ]---

Jul  4 15:49:50 BUG: unable to handle kernel paging request at ffffffffffffffd8

IP: [<ffffffff81067140>] kthread_data+0x10/0x20

PGD 1a0c067 PUD 1a0e067 PMD 0

Oops: 0000 [#2] SMP

Modules linked in: ebtable_nat ebtables ipt_MASQUERADE iptable_nat nf_nat_ipv4
nf_nat xt_CHECKSUM iptable_mangle bridge stp llc autofs4 sunrpc cpufreq_ondemand
ipt_REJECT nf_conntrack_ipv4 nf_defrag_ipv4 iptable_filter ip6t_REJECT
nf_conntrack_ipv6 nf_defrag_ipv6 xt_state nf_conntrack ip6table_filter
ip6_tables ipv6 vfat fat dm_mirror dm_region_hash dm_log dm_mod vhost_net
macvtap macvlan tun uinput iTCO_wdt iTCO_vendor_support acpi_cpufreq freq_table
mperf coretemp kvm_intel kvm crc32c_intel microcode pcspkr sg i2c_i801 lpc_ich
mfd_core ioatdma i7core_edac edac_core e1000e igb dca i2c_algo_bit i2c_core ptp
pps_core ext4(F) jbd2(F) mbcache(F) sd_mod(F) crc_t10dif(F) megaraid_sas(F)
mptsas(F) mptscsih(F) mptbase(F) scsi_transport_sas(F)

CPU: 4 PID: 100 Comm: kworker/4:1 Tainted: GF     D      3.10.0-aio-migrate+
#107
Hardware name: FUJITSU-SV PRIMEQUEST 1800E/SB, BIOS PRIMEQUEST 1000 Series BIOS
Version 89.32 DP Proto 08/16/2012
task: ffff8807dda974e0 ti: ffff8807dda98000 task.ti: ffff8807dda98000

RIP: 0010:[<ffffffff81067140>]  [<ffffffff81067140>] kthread_data+0x10/0x20

RSP: 0018:ffff8807dda999b8  EFLAGS: 00010092

RAX: 0000000000000000 RBX: 0000000000000004 RCX: ffffffff81da3ea0

RDX: 0000000000000000 RSI: 0000000000000004 RDI: ffff8807dda974e0

RBP: ffff8807dda999b8 R08: ffff8807dda97550 R09: 0000000000000006

R10: 0000000000000000 R11: 0000000000000000 R12: 0000000000000004

R13: ffff8807dda97ab8 R14: 0000000000000001 R15: 0000000000000006

FS:  0000000000000000(0000) GS:ffff8807fd680000(0000) knlGS:0000000000000000

CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b

CR2: 0000000000000028 CR3: 0000000001a0b000 CR4: 00000000000007e0

DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000

DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400

Stack:

 ffff8807dda999d8 ffffffff8105e155 ffff8807dda999d8 ffff8807fd692d00

 ffff8807dda99a68 ffffffff8154168b ffff8807dda99fd8 0000000000012d00

 ffff8807dda98010 0000000000012d00 0000000000012d00 0000000000012d00

Call Trace:

 [<ffffffff8105e155>] wq_worker_sleeping+0x15/0xa0

 [<ffffffff8154168b>] __schedule+0x5ab/0x6f0

 [<ffffffff81239992>] ? put_io_context_active+0xc2/0xf0

 [<ffffffff815419a9>] schedule+0x29/0x70

 [<ffffffff81047795>] do_exit+0x2d5/0x480

 [<ffffffff81544029>] oops_end+0xa9/0xf0

 [<ffffffff810058eb>] die+0x5b/0x90

 [<ffffffff81543b8b>] do_trap+0xcb/0x170

 [<ffffffff81546e22>] ? __atomic_notifier_call_chain+0x12/0x20

 [<ffffffff81003565>] do_invalid_op+0x95/0xb0

 [<ffffffff8111a9a8>] ? put_page+0x48/0x60

 [<ffffffff8111c411>] ? truncate_inode_pages_range+0x201/0x500

 [<ffffffff8154c8e8>] invalid_op+0x18/0x20

 [<ffffffff8111a9a8>] ? put_page+0x48/0x60

 [<ffffffff8111c829>] ? truncate_setsize+0x19/0x20

 [<ffffffff811b11f6>] aio_free_ring+0x96/0x1c0

 [<ffffffff811b21a2>] free_ioctx+0x1f2/0x250

 [<ffffffff81081a5d>] ? idle_balance+0xed/0x140

 [<ffffffff811b221a>] put_ioctx+0x1a/0x30

 [<ffffffff811b24af>] kill_ioctx_work+0x2f/0x40

 [<ffffffff81060933>] process_one_work+0x183/0x490

 [<ffffffff81061ac0>] worker_thread+0x120/0x3a0

 [<ffffffff810619a0>] ? manage_workers+0x160/0x160

 [<ffffffff8106786e>] kthread+0xce/0xe0

 [<ffffffff810677a0>] ? kthread_freezable_should_stop+0x70/0x70

 [<ffffffff8154b79c>] ret_from_fork+0x7c/0xb0

 [<ffffffff810677a0>] ? kthread_freezable_should_stop+0x70/0x70

Code: 80 05 00 00 48 8b 40 c8 c9 48 c1 e8 02 83 e0 01 c3 66 2e 0f 1f 84 00 00 00
00 00 55 48 89 e5 66 66 66 66 90 48 8b 87 80 05 00 00 <48> 8b 40 d8 c9 c3 66 2e
0f 1f 84 00 00 00 00 00 55 48 89 e5 66
RIP  [<ffffffff81067140>] kthread_data+0x10/0x20

 RSP <ffff8807dda999b8>

CR2: ffffffffffffffd8

---[ end trace b5e2c17407c840d9 ]---

DP kernel: -----Fixing recursive fault but reboot is needed!

-------[ cut here ]------------

Jul  4 15:49:50 DP kernel: kernel BUG at mm/swap.c:163!

Jul  4 15:49:50 DP kernel: invalid opcode: 0000 [#1] SMP

Jul  4 15:49:50 DP kernel: Modules linked in: ebtable_nat ebtables
ipt_MASQUERADE iptable_nat nf_nat_ipv4 nf_nat xt_CHECKSUM iptable_mangle bridge
stp llc autofs4 sunrpc cpufreq_ondemand ipt_REJECT nf_conntrack_ipv4
nf_defrag_ipv4 iptable_filter ip6t_REJECT nf_conntrack_ipv6 nf_defrag_ipv6
xt_state nf_conntrack ip6table_filter ip6_tables ipv6 vfat fat dm_mirror
dm_region_hash dm_log dm_mod vhost_net macvtap macvlan tun uinput iTCO_wdt
iTCO_vendor_support acpi_cpufreq freq_table mperf coretemp kvm_intel kvm
crc32c_intel microcode pcspkr sg i2c_i801 lpc_ich mfd_core ioatdma i7core_edac
edac_core e1000e igb dca i2c_algo_bit i2c_core ptp pps_core ext4(F) jbd2(F)
mbcache(F) sd_mod(F) crc_t10dif(F) megaraid_sas(F) mptsas(F) mptscsih(F)
mptbase(F) scsi_transport_sas(F)
Jul  4 15:49:50 DP kernel: CPU: 4 PID: 100 Comm: kworker/4:1 Tainted: GF
    3.10.0-aio-migrate+ #107
Jul  4 15:49:50 DP kernel: Hardware name: FUJITSU-SV PRIMEQUEST 1800E/SB, BIOS
PRIMEQUEST 1000 Series BIOS Version 89.32 DP Proto 08/16/2012

Jul  4 15:49:50 DP kernel: Workqueue: events kill_ioctx_work

Jul  4 15:49:50 DP kernel: task: ffff8807dda974e0 ti: ffff8807dda98000 task.ti:
ffff8807dda98000
Jul  4 15:49:50 DP kernel: RIP: 0010:[<ffffffff8111a9a8>]  [<ffffffff8111a9a8>]
put_page+0x48/0x60
Jul  4 15:49:50 DP kernel: RSP: 0018:ffff8807dda99cd8  EFLAGS: 00010246

Jul  4 15:49:50 DP kernel: RAX: 0000000000000000 RBX: ffff8807be1f1e00 RCX:
0000000000000001
Jul  4 15:49:50 DP kernel: RDX: 0000000000000000 RSI: 0000000000000000 RDI:
ffffea001b196c80
Jul  4 15:49:50 DP kernel: RBP: ffff8807dda99cd8 R08: 0000000000000000 R09:
0000000000000000
Jul  4 15:49:50 DP kernel: R10: ffff8807ffbb5f00 R11: 000000000000005a R12:
0000000000000001
Jul  4 15:49:50 DP kernel: R13: 0000000000000000 R14: ffff8807dda974e0 R15:
ffff8807be1f1ec8
Jul  4 15:49:50 DP kernel: FS:  0000000000000000(0000) GS:ffff8807fd680000(0000)
knlGS:0000000000000000
Jul  4 15:49:50 DP kernel: CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b

Jul  4 15:49:50 DP kernel: CR2: 0000003b826dc7d0 CR3: 0000000001a0b000 CR4:
00000000000007e0
Jul  4 15:49:50 DP kernel: DR0: 0000000000000000 DR1: 0000000000000000 DR2:
0000000000000000
Jul  4 15:49:50 DP kernel: DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7:
0000000000000400
Jul  4 15:49:50 DP kernel: Stack:

Jul  4 15:49:50 DP kernel: ffff8807dda99d18 ffffffff811b11f6 0000000000000000
0000000200000000
Jul  4 15:49:50 DP kernel: ffff8807be1f1e00 ffff8807be1f1e80 000000000000000c
0000000000000000
Jul  4 15:49:50 DP kernel: ffff8807dda99dc8 ffffffff811b21a2 00000001000438ec
ffff8807fd692d00
Jul  4 15:49:50 DP kernel: Call Trace:

Jul  4 15:49:50 DP kernel: [<ffffffff811b11f6>] aio_free_ring+0x96/0x1c0

Jul  4 15:49:50 DP kernel: [<ffffffff811b21a2>] free_ioctx+0x1f2/0x250

Jul  4 15:49:50 DP kernel: [<ffffffff81081a5d>] ? idle_balance+0xed/0x140

Jul  4 15:49:50 DP kernel: [<ffffffff811b221a>] put_ioctx+0x1a/0x30

Jul  4 15:49:50 DP kernel: [<ffffffff811b24af>] kill_ioctx_work+0x2f/0x40

Jul  4 15:49:50 DP kernel: [<ffffffff81060933>] process_one_work+0x183/0x490

Jul  4 15:49:50 DP kernel: [<ffffffff81061ac0>] worker_thread+0x120/0x3a0

Jul  4 15:49:50 DP kernel: [<ffffffff810619a0>] ? manage_workers+0x160/0x160

Jul  4 15:49:50 DP kernel: [<ffffffff8106786e>] kthread+0xce/0xe0

Jul  4 15:49:50 DP kernel: [<ffffffff810677a0>] ?
kthread_freezable_should_stop+0x70/0x70
Jul  4 15:49:50 DP kernel: [<ffffffff8154b79c>] ret_from_fork+0x7c/0xb0

Jul  4 15:49:50 DP kernel: [<ffffffff810677a0>] ?
kthread_freezable_should_stop+0x70/0x70
Jul  4 15:49:50 DP kernel: Code: 07 00 c0 75 1f f0 ff 4f 1c 0f 94 c0 84 c0 75 0b
c9 66 90 c3 0f 1f 80 00 00 00 00 e8 53 fe ff ff c9 66 90 c3 e8 7a fe ff ff c9 c3
<0f> 0b 66 0f 1f 44 00 00 eb f8 48 8b 47 30 eb bc 0f 1f 84 00 00
Jul  4 15:49:50 DP kernel: RIP  [<ffffffff8111a9a8>] put_page+0x48/0x60

Jul  4 15:49:50 DP kernel: RSP <ffff8807dda99cd8>

Jul  4 15:49:50 DP kernel: ---[ end trace b5e2c17407c840d8 ]---

INFO: rcu_sched detected stalls on CPUs/tasks: { 4} (detected by 9, t=21056
jiffies, g=4158, c=4157, q=1040)
sending NMI to all CPUs:

NMI backtrace for cpu 4

CPU: 4 PID: 100 Comm: kworker/4:1 Tainted: GF     D      3.10.0-aio-migrate+
#107
Hardware name: FUJITSU-SV PRIMEQUEST 1800E/SB, BIOS PRIMEQUEST 1000 Series BIOS
Version 89.32 DP Proto 08/16/2012
task: ffff8807dda974e0 ti: ffff8807dda98000 task.ti: ffff8807dda98000

RIP: 0010:[<ffffffff81542cd2>]  [<ffffffff81542cd2>]
_raw_spin_lock_irq+0x22/0x30
RSP: 0018:ffff8807dda99618  EFLAGS: 00000002

RAX: 000000000000497c RBX: ffff8807fd692d00 RCX: ffff8807dda98010

RDX: 000000000000497e RSI: ffffffff815419a9 RDI: ffff8807fd692d00

RBP: ffff8807dda99618 R08: 0000000000000004 R09: 0000000000000100

R10: 00000000000009fe R11: 00000000000009fe R12: 0000000000000004

R13: 0000000000000009 R14: 0000000000000009 R15: 0000000000000000

FS:  0000000000000000(0000) GS:ffff8807fd680000(0000) knlGS:0000000000000000

CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b

CR2: 0000000000000028 CR3: 0000000001a0b000 CR4: 00000000000007e0

DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000

DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400

Stack:

 ffff8807dda996a8 ffffffff815411b6 ffff8807dda99fd8 0000000000012d00

 ffff8807dda98010 0000000000012d00 0000000000012d00 0000000000012d00

 ffff8807dda99fd8 0000000000012d00 ffff8807dda974e0 ffff8807dda996c8

Call Trace:

 [<ffffffff815411b6>] __schedule+0xd6/0x6f0

 [<ffffffff815419a9>] schedule+0x29/0x70

 [<ffffffff810478ea>] do_exit+0x42a/0x480

 [<ffffffff81544029>] oops_end+0xa9/0xf0

 [<ffffffff81035c3e>] no_context+0x11e/0x1f0

 [<ffffffff81035e2d>] __bad_area_nosemaphore+0x11d/0x220

 [<ffffffff81035f43>] bad_area_nosemaphore+0x13/0x20

 [<ffffffff815469b5>] __do_page_fault+0xc5/0x490

 [<ffffffff810d4a97>] ? call_rcu_sched+0x17/0x20

 [<ffffffff8125d3da>] ? strlcpy+0x4a/0x60

 [<ffffffff81546d8e>] do_page_fault+0xe/0x10

 [<ffffffff815434f2>] page_fault+0x22/0x30

 [<ffffffff81067140>] ? kthread_data+0x10/0x20

 [<ffffffff8105e155>] wq_worker_sleeping+0x15/0xa0

 [<ffffffff8154168b>] __schedule+0x5ab/0x6f0

 [<ffffffff81239992>] ? put_io_context_active+0xc2/0xf0

 [<ffffffff815419a9>] schedule+0x29/0x70

 [<ffffffff81047795>] do_exit+0x2d5/0x480

 [<ffffffff81544029>] oops_end+0xa9/0xf0

 [<ffffffff810058eb>] die+0x5b/0x90

 [<ffffffff81543b8b>] do_trap+0xcb/0x170

 [<ffffffff81546e22>] ? __atomic_notifier_call_chain+0x12/0x20

 [<ffffffff81003565>] do_invalid_op+0x95/0xb0

 [<ffffffff8111a9a8>] ? put_page+0x48/0x60

 [<ffffffff8111c411>] ? truncate_inode_pages_range+0x201/0x500

 [<ffffffff8154c8e8>] invalid_op+0x18/0x20

 [<ffffffff8111a9a8>] ? put_page+0x48/0x60

 [<ffffffff8111c829>] ? truncate_setsize+0x19/0x20

 [<ffffffff811b11f6>] aio_free_ring+0x96/0x1c0

 [<ffffffff811b21a2>] free_ioctx+0x1f2/0x250

 [<ffffffff81081a5d>] ? idle_balance+0xed/0x140

 [<ffffffff811b221a>] put_ioctx+0x1a/0x30

 [<ffffffff811b24af>] kill_ioctx_work+0x2f/0x40

 [<ffffffff81060933>] process_one_work+0x183/0x490

 [<ffffffff81061ac0>] worker_thread+0x120/0x3a0

 [<ffffffff810619a0>] ? manage_workers+0x160/0x160

 [<ffffffff8106786e>] kthread+0xce/0xe0

 [<ffffffff810677a0>] ? kthread_freezable_should_stop+0x70/0x70

 [<ffffffff8154b79c>] ret_from_fork+0x7c/0xb0

 [<ffffffff810677a0>] ? kthread_freezable_should_stop+0x70/0x70

Code: 66 0f 1f 84 00 00 00 00 00 55 48 89 e5 66 66 66 66 90 fa b8 00 00 01 00 f0
0f c1 07 89 c2 c1 ea 10 66 39 c2 74 0d 0f 1f 00 f3 90 <0f> b7 07 66 39 c2 75 f6
c9 c3 0f 1f 40 00 55 48 89 e5 66 66 66
NMI backtrace for cpu 1


> 
> 		-ben


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
