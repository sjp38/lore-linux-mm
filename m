Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx134.postini.com [74.125.245.134])
	by kanga.kvack.org (Postfix) with SMTP id 0AC706B002B
	for <linux-mm@kvack.org>; Fri, 10 Aug 2012 13:20:31 -0400 (EDT)
Message-ID: <502542C7.8050306@sandia.gov>
Date: Fri, 10 Aug 2012 11:20:07 -0600
From: "Jim Schutt" <jaschut@sandia.gov>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 0/5] Improve hugepage allocation success rates
 under load V3
References: <1344520165-24419-1-git-send-email-mgorman@suse.de>
 <5023FE83.4090200@sandia.gov> <20120809204630.GJ12690@suse.de>
 <50243BE0.9060007@sandia.gov> <20120810110225.GO12690@suse.de>
In-Reply-To: <20120810110225.GO12690@suse.de>
Content-Type: text/plain;
 charset=utf-8;
 format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Linux-MM <linux-mm@kvack.org>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan@kernel.org>, LKML <linux-kernel@vger.kernel.org>

On 08/10/2012 05:02 AM, Mel Gorman wrote:
> On Thu, Aug 09, 2012 at 04:38:24PM -0600, Jim Schutt wrote:

>>>
>>> Ok, this is an untested hack and I expect it would drop allocation success
>>> rates again under load (but not as much). Can you test again and see what
>>> effect, if any, it has please?
>>>
>>> ---8<---
>>> mm: compaction: back out if contended
>>>
>>> ---
>>
>> <snip>
>>
>> Initial testing with this patch looks very good from
>> my perspective; CPU utilization stays reasonable,
>> write-out rate stays high, no signs of stress.
>> Here's an example after ~10 minutes under my test load:
>>

Hmmm, I wonder if I should have tested this patch longer,
in view of the trouble I ran into testing the new patch?
See below.

>
> Excellent, so it is contention that is the problem.
>
>> <SNIP>
>> I'll continue testing tomorrow to be sure nothing
>> shows up after continued testing.
>>
>> If this passes your allocation success rate testing,
>> I'm happy with this performance for 3.6 - if not, I'll
>> be happy to test any further patches.
>>
>
> It does impair allocation success rates as I expected (they're still ok
> but not as high as I'd like) so I implemented the following instead. It
> attempts to backoff when contention is detected or compaction is taking
> too long. It does not backoff as quickly as the first prototype did so
> I'd like to see if it addresses your problem or not.
>
>> I really appreciate getting the chance to test out
>> your patchset.
>>
>
> I appreciate that you have a workload that demonstrates the problem and
> will test patches. I will not abuse this and hope the keep the revisions
> to a minimum.
>
> Thanks.
>
> ---8<---
> mm: compaction: Abort async compaction if locks are contended or taking too long


Hmmm, while testing this patch, a couple of my servers got
stuck after ~30 minutes or so, like this:

[ 2515.869936] INFO: task ceph-osd:30375 blocked for more than 120 seconds.
[ 2515.876630] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
[ 2515.884447] ceph-osd        D 0000000000000000     0 30375      1 0x00000000
[ 2515.891531]  ffff8802e1a99e38 0000000000000082 ffff88056b38e298 ffff8802e1a99fd8
[ 2515.899013]  ffff8802e1a98010 ffff8802e1a98000 ffff8802e1a98000 ffff8802e1a98000
[ 2515.906482]  ffff8802e1a99fd8 ffff8802e1a98000 ffff880697d31700 ffff8802e1a84500
[ 2515.913968] Call Trace:
[ 2515.916433]  [<ffffffff8147fded>] schedule+0x5d/0x60
[ 2515.921417]  [<ffffffff81480b25>] rwsem_down_failed_common+0x105/0x140
[ 2515.927938]  [<ffffffff81480b73>] rwsem_down_write_failed+0x13/0x20
[ 2515.934195]  [<ffffffff8124bcd3>] call_rwsem_down_write_failed+0x13/0x20
[ 2515.940934]  [<ffffffff8147edc5>] ? down_write+0x45/0x50
[ 2515.946244]  [<ffffffff81127b62>] sys_mprotect+0xd2/0x240
[ 2515.951640]  [<ffffffff81489412>] system_call_fastpath+0x16/0x1b
[ 2515.957646] INFO: task ceph-osd:95698 blocked for more than 120 seconds.
[ 2515.964330] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
[ 2515.972141] ceph-osd        D 0000000000000000     0 95698      1 0x00000000
[ 2515.979223]  ffff8802b049fe38 0000000000000082 ffff88056b38e2a0 ffff8802b049ffd8
[ 2515.986700]  ffff8802b049e010 ffff8802b049e000 ffff8802b049e000 ffff8802b049e000
[ 2515.994176]  ffff8802b049ffd8 ffff8802b049e000 ffff8809832ddc00 ffff880611592e00
[ 2516.001653] Call Trace:
[ 2516.004111]  [<ffffffff8147fded>] schedule+0x5d/0x60
[ 2516.009072]  [<ffffffff81480b25>] rwsem_down_failed_common+0x105/0x140
[ 2516.015589]  [<ffffffff81480b73>] rwsem_down_write_failed+0x13/0x20
[ 2516.021861]  [<ffffffff8124bcd3>] call_rwsem_down_write_failed+0x13/0x20
[ 2516.028555]  [<ffffffff8147edc5>] ? down_write+0x45/0x50
[ 2516.033859]  [<ffffffff81127b62>] sys_mprotect+0xd2/0x240
[ 2516.039248]  [<ffffffff81489412>] system_call_fastpath+0x16/0x1b
[ 2516.045248] INFO: task ceph-osd:95699 blocked for more than 120 seconds.
[ 2516.051934] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
[ 2516.059753] ceph-osd        D 0000000000000000     0 95699      1 0x00000000
[ 2516.066832]  ffff880c022d3dc8 0000000000000082 ffff880c022d2000 ffff880c022d3fd8
[ 2516.074302]  ffff880c022d2010 ffff880c022d2000 ffff880c022d2000 ffff880c022d2000
[ 2516.081784]  ffff880c022d3fd8 ffff880c022d2000 ffff8806224cc500 ffff88096b64dc00
[ 2516.089254] Call Trace:
[ 2516.091702]  [<ffffffff8147fded>] schedule+0x5d/0x60
[ 2516.096656]  [<ffffffff81480b25>] rwsem_down_failed_common+0x105/0x140
[ 2516.103176]  [<ffffffff81480b73>] rwsem_down_write_failed+0x13/0x20
[ 2516.109443]  [<ffffffff8124bcd3>] call_rwsem_down_write_failed+0x13/0x20
[ 2516.116134]  [<ffffffff8147edc5>] ? down_write+0x45/0x50
[ 2516.121442]  [<ffffffff8111362e>] vm_mmap_pgoff+0x6e/0xb0
[ 2516.126861]  [<ffffffff8112486a>] sys_mmap_pgoff+0x18a/0x190
[ 2516.132552]  [<ffffffff8124bd6e>] ? trace_hardirqs_on_thunk+0x3a/0x3c
[ 2516.138985]  [<ffffffff81006b22>] sys_mmap+0x22/0x30
[ 2516.143945]  [<ffffffff81489412>] system_call_fastpath+0x16/0x1b
[ 2516.149949] INFO: task ceph-osd:95816 blocked for more than 120 seconds.
[ 2516.156632] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
[ 2516.164444] ceph-osd        D 0000000000000000     0 95816      1 0x00000000
[ 2516.171521]  ffff880332991e38 0000000000000082 ffff880332991de8 ffff880332991fd8
[ 2516.178992]  ffff880332990010 ffff880332990000 ffff880332990000 ffff880332990000
[ 2516.186466]  ffff880332991fd8 ffff880332990000 ffff880697d31700 ffff880a92c32e00
[ 2516.193937] Call Trace:
[ 2516.196396]  [<ffffffff8147fded>] schedule+0x5d/0x60
[ 2516.201354]  [<ffffffff81480b25>] rwsem_down_failed_common+0x105/0x140
[ 2516.207886]  [<ffffffff81480b73>] rwsem_down_write_failed+0x13/0x20
[ 2516.214138]  [<ffffffff8124bcd3>] call_rwsem_down_write_failed+0x13/0x20
[ 2516.220843]  [<ffffffff8147edc5>] ? down_write+0x45/0x50
[ 2516.226145]  [<ffffffff81127b62>] sys_mprotect+0xd2/0x240
[ 2516.231548]  [<ffffffff81489412>] system_call_fastpath+0x16/0x1b
[ 2516.237545] INFO: task ceph-osd:95838 blocked for more than 120 seconds.
[ 2516.244248] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
[ 2516.252067] ceph-osd        D 0000000000000000     0 95838      1 0x00000000
[ 2516.259159]  ffff8803f8281e38 0000000000000082 ffff88056b38e2a8 ffff8803f8281fd8
[ 2516.266627]  ffff8803f8280010 ffff8803f8280000 ffff8803f8280000 ffff8803f8280000
[ 2516.274094]  ffff8803f8281fd8 ffff8803f8280000 ffff8809a45f8000 ffff880691d41700
[ 2516.281573] Call Trace:
[ 2516.284028]  [<ffffffff8147fded>] schedule+0x5d/0x60
[ 2516.289000]  [<ffffffff81480b25>] rwsem_down_failed_common+0x105/0x140
[ 2516.295513]  [<ffffffff81480b73>] rwsem_down_write_failed+0x13/0x20
[ 2516.301764]  [<ffffffff8124bcd3>] call_rwsem_down_write_failed+0x13/0x20
[ 2516.308450]  [<ffffffff8147edc5>] ? down_write+0x45/0x50
[ 2516.313753]  [<ffffffff81127b62>] sys_mprotect+0xd2/0x240
[ 2516.319157]  [<ffffffff81489412>] system_call_fastpath+0x16/0x1b
[ 2516.325154] INFO: task ceph-osd:95861 blocked for more than 120 seconds.
[ 2516.331844] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
[ 2516.339665] ceph-osd        D 0000000000000000     0 95861      1 0x00000000
[ 2516.346742]  ffff8805026e9e38 0000000000000082 ffff88056b38e2a0 ffff8805026e9fd8
[ 2516.354221]  ffff8805026e8010 ffff8805026e8000 ffff8805026e8000 ffff8805026e8000
[ 2516.361698]  ffff8805026e9fd8 ffff8805026e8000 ffff880611592e00 ffff880948df0000
[ 2516.369174] Call Trace:
[ 2516.371623]  [<ffffffff8147fded>] schedule+0x5d/0x60
[ 2516.376582]  [<ffffffff81480b25>] rwsem_down_failed_common+0x105/0x140
[ 2516.383149]  [<ffffffff81480b73>] rwsem_down_write_failed+0x13/0x20
[ 2516.389404]  [<ffffffff8124bcd3>] call_rwsem_down_write_failed+0x13/0x20
[ 2516.396091]  [<ffffffff8147edc5>] ? down_write+0x45/0x50
[ 2516.401397]  [<ffffffff81127b62>] sys_mprotect+0xd2/0x240
[ 2516.406818]  [<ffffffff81489412>] system_call_fastpath+0x16/0x1b
[ 2516.412868] INFO: task ceph-osd:95899 blocked for more than 120 seconds.
[ 2516.419557] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
[ 2516.427371] ceph-osd        D 0000000000000000     0 95899      1 0x00000000
[ 2516.434466]  ffff8801eaa9dd50 0000000000000082 0000000000000000 ffff8801eaa9dfd8
[ 2516.442020]  ffff8801eaa9c010 ffff8801eaa9c000 ffff8801eaa9c000 ffff8801eaa9c000
[ 2516.449594]  ffff8801eaa9dfd8 ffff8801eaa9c000 ffff8800865e5c00 ffff8802b356c500
[ 2516.457079] Call Trace:
[ 2516.459534]  [<ffffffff8147fded>] schedule+0x5d/0x60
[ 2516.464519]  [<ffffffff81480b25>] rwsem_down_failed_common+0x105/0x140
[ 2516.471044]  [<ffffffff81480b95>] rwsem_down_read_failed+0x15/0x17
[ 2516.477222]  [<ffffffff8124bca4>] call_rwsem_down_read_failed+0x14/0x30
[ 2516.483830]  [<ffffffff8147ee07>] ? down_read+0x37/0x40
[ 2516.489050]  [<ffffffff81484c49>] do_page_fault+0x239/0x4a0
[ 2516.494627]  [<ffffffff8124bdaa>] ? trace_hardirqs_off_thunk+0x3a/0x6c
[ 2516.501143]  [<ffffffff8148154f>] page_fault+0x1f/0x30


I tried to capture a perf trace while this was going on, but it
never completed.  "ps" on this system reports lots of kernel threads
and some user-space stuff, but hangs part way through - no ceph
executables in the output, oddly.

I can retest your earlier patch for a longer period, to
see if it does the same thing, or I can do some other thing
if you tell me what it is.

Also, FWIW I sorted a little through SysRq-T output from such
a system; these bits looked interesting:

[ 3663.685097] INFO: rcu_sched self-detected stall on CPU { 17}  (t=60000 jiffies)
[ 3663.685099] sending NMI to all CPUs:
[ 3663.685101] NMI backtrace for cpu 0
[ 3663.685102] CPU 0 Modules linked in: btrfs zlib_deflate ib_ipoib rdma_ucm ib_ucm ib_uverbs ib_umad rdma_cm ib_cm iw_cm ib_addr ipv6 ib_sa iw_cxgb4 dm_mirror dm_region_hash dm_log dm_round_robin dm_multipath scsi_dh vhost_net macvtap macvlan tun uinput sg joydev sd_mod hid_generic coretemp hwmon kvm crc32c_intel ghash_clmulni_intel aesni_intel cryptd aes_x86_64 microcode serio_raw pcspkr ata_piix libata button mlx4_ib ib_mad ib_core mlx4_en mlx4_core mpt2sas scsi_transport_sas raid_class scsi_mod cxgb4 i2c_i801 i2c_core lpc_ich mfd_core ehci_hcd uhci_hcd i7core_edac edac_core dm_mod ioatdma nfs nfs_acl auth_rpcgss fscache lockd sunrpc broadcom tg3 bnx2 igb dca e1000 [last unloaded: scsi_wait_scan]
[ 3663.685138]
[ 3663.685140] Pid: 100027, comm: ceph-osd Not tainted 3.5.0-00019-g472719a #221 Supermicro X8DTH-i/6/iF/6F/X8DTH
[ 3663.685142] RIP: 0010:[<ffffffff81480ed5>]  [<ffffffff81480ed5>] _raw_spin_lock_irqsave+0x45/0x60
[ 3663.685148] RSP: 0018:ffff880a08191898  EFLAGS: 00000012
[ 3663.685149] RAX: ffff88063fffcb00 RBX: ffff88063fffcb00 RCX: 00000000000000c5
[ 3663.685149] RDX: 00000000000000bf RSI: 000000000000015a RDI: ffff88063fffcb00
[ 3663.685150] RBP: ffff880a081918a8 R08: 0000000000000000 R09: 0000000000000000
[ 3663.685151] R10: ffff88063fffcb98 R11: ffff88063fffcc38 R12: 0000000000000246
[ 3663.685152] R13: ffff88063fffcba8 R14: ffff88063fffcb90 R15: ffff88063fffc680
[ 3663.685153] FS:  00007fff90ae0700(0000) GS:ffff880627c00000(0000) knlGS:0000000000000000
[ 3663.685154] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[ 3663.685155] CR2: ffffffffff600400 CR3: 00000002b8fbe000 CR4: 00000000000007f0
[ 3663.685156] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[ 3663.685157] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[ 3663.685158] Process ceph-osd (pid: 100027, threadinfo ffff880a08190000, task ffff880a9a29ae00)
[ 3663.685158] Stack:
[ 3663.685159]  000000000000130a 0000000000000000 ffff880a08191948 ffffffff8111a760
[ 3663.685162]  ffffffff81a13420 0000000000000009 ffffea000004c240 0000000000000000
[ 3663.685165]  ffff88063fffcba0 000000003fffcb98 ffff880a08191a18 0000000000001600
[ 3663.685168] Call Trace:
[ 3663.685169]  [<ffffffff8111a760>] isolate_migratepages_range+0x150/0x4e0
[ 3663.685173]  [<ffffffff8111a5b0>] ? isolate_freepages+0x330/0x330
[ 3663.685175]  [<ffffffff8111af5b>] compact_zone+0x46b/0x4f0
[ 3663.685178]  [<ffffffff8111b3f8>] compact_zone_order+0xe8/0x100
[ 3663.685180]  [<ffffffff8111b4b6>] try_to_compact_pages+0xa6/0x110
[ 3663.685182]  [<ffffffff81100339>] __alloc_pages_direct_compact+0xd9/0x250
[ 3663.685187]  [<ffffffff81100883>] __alloc_pages_slowpath+0x3d3/0x750
[ 3663.685190]  [<ffffffff81100d3e>] __alloc_pages_nodemask+0x13e/0x1d0
[ 3663.685192]  [<ffffffff8113c894>] alloc_pages_vma+0x124/0x150
[ 3663.685195]  [<ffffffff8114e065>] do_huge_pmd_anonymous_page+0xf5/0x1e0
[ 3663.685199]  [<ffffffff81121bcd>] handle_mm_fault+0x21d/0x320
[ 3663.685202]  [<ffffffff8124bca4>] ? call_rwsem_down_read_failed+0x14/0x30
[ 3663.685205]  [<ffffffff81484e49>] do_page_fault+0x439/0x4a0
[ 3663.685208]  [<ffffffff8124bdaa>] ? trace_hardirqs_off_thunk+0x3a/0x6c
[ 3663.685211]  [<ffffffff8148154f>] page_fault+0x1f/0x30
[ 3663.685213] Code: 8b 14 25 48 b7 00 00 83 82 44 e0 ff ff 01 ba 00 01 00 00 f0 66 0f c1 13 89 d1 66 c1 e9 08 38 d1 74 0d 0f 1f 40 00 f3 90 0f b6 13 <38> d1 75 f7 5b 4c 89 e0 41 5c c9 c3 66 66 66 66 66 66 2e 0f 1f
[ 3663.685238] NMI backtrace for cpu 3
[ 3663.685239] CPU 3 Modules linked in: btrfs zlib_deflate ib_ipoib rdma_ucm ib_ucm ib_uverbs ib_umad rdma_cm ib_cm iw_cm ib_addr ipv6 ib_sa iw_cxgb4 dm_mirror dm_region_hash dm_log dm_round_robin dm_multipath scsi_dh vhost_net macvtap macvlan tun uinput sg joydev sd_mod hid_generic coretemp hwmon kvm crc32c_intel ghash_clmulni_intel aesni_intel cryptd aes_x86_64 microcode serio_raw pcspkr ata_piix libata button mlx4_ib ib_mad ib_core mlx4_en mlx4_core mpt2sas scsi_transport_sas raid_class scsi_mod cxgb4 i2c_i801 i2c_core lpc_ich mfd_core ehci_hcd uhci_hcd i7core_edac edac_core dm_mod ioatdma nfs nfs_acl auth_rpcgss fscache lockd sunrpc broadcom tg3 bnx2 igb dca e1000 [last unloaded: scsi_wait_scan]
[ 3663.685273]
[ 3663.685274] Pid: 101503, comm: ceph-osd Not tainted 3.5.0-00019-g472719a #221 Supermicro X8DTH-i/6/iF/6F/X8DTH
[ 3663.685276] RIP: 0010:[<ffffffff81480ed2>]  [<ffffffff81480ed2>] _raw_spin_lock_irqsave+0x42/0x60
[ 3663.685280] RSP: 0018:ffff8806bce17898  EFLAGS: 00000006
[ 3663.685280] RAX: ffff88063fffcb00 RBX: ffff88063fffcb00 RCX: 00000000000000cb
[ 3663.685281] RDX: 00000000000000c5 RSI: 000000000000015a RDI: ffff88063fffcb00
[ 3663.685282] RBP: ffff8806bce178a8 R08: 0000000000000000 R09: 0000000000000000
[ 3663.685283] R10: ffff88063fffcb98 R11: ffff88063fffcc38 R12: 0000000000000246
[ 3663.685284] R13: ffff88063fffcba8 R14: ffff88063fffcb90 R15: ffff88063fffc680
[ 3663.685285] FS:  00007fffc8e60700(0000) GS:ffff880627c60000(0000) knlGS:0000000000000000
[ 3663.685286] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[ 3663.685287] CR2: ffffffffff600400 CR3: 00000002cbd8c000 CR4: 00000000000007e0
[ 3663.685287] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[ 3663.685288] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[ 3663.685289] Process ceph-osd (pid: 101503, threadinfo ffff8806bce16000, task ffff880c06580000)
[ 3663.685290] Stack:
[ 3663.685290]  0000000000001212 0000000000000000 ffff8806bce17948 ffffffff8111a760
[ 3663.685294]  ffff8806244d5c00 0000000000000009 ffffea0000048440 0000000000000000
[ 3663.685297]  ffff88063fffcba0 000000003fffcb98 ffff8806bce17a18 0000000000001600
[ 3663.685300] Call Trace:
[ 3663.685301]  [<ffffffff8111a760>] isolate_migratepages_range+0x150/0x4e0
[ 3663.685304]  [<ffffffff8111a5b0>] ? isolate_freepages+0x330/0x330
[ 3663.685306]  [<ffffffff8111af5b>] compact_zone+0x46b/0x4f0
[ 3663.685308]  [<ffffffff814018c4>] ? ip_finish_output+0x274/0x300
[ 3663.685311]  [<ffffffff8111b3f8>] compact_zone_order+0xe8/0x100
[ 3663.685314]  [<ffffffff8111b4b6>] try_to_compact_pages+0xa6/0x110
[ 3663.685316]  [<ffffffff81100339>] __alloc_pages_direct_compact+0xd9/0x250
[ 3663.685319]  [<ffffffff813b655b>] ? release_sock+0x6b/0x80
[ 3663.685322]  [<ffffffff81100883>] __alloc_pages_slowpath+0x3d3/0x750
[ 3663.685325]  [<ffffffff81100d3e>] __alloc_pages_nodemask+0x13e/0x1d0
[ 3663.685327]  [<ffffffff8113c894>] alloc_pages_vma+0x124/0x150
[ 3663.685330]  [<ffffffff8114e065>] do_huge_pmd_anonymous_page+0xf5/0x1e0
[ 3663.685332]  [<ffffffff81121bcd>] handle_mm_fault+0x21d/0x320
[ 3663.685335]  [<ffffffff8124bca4>] ? call_rwsem_down_read_failed+0x14/0x30
[ 3663.685337]  [<ffffffff81484e49>] do_page_fault+0x439/0x4a0
[ 3663.685340]  [<ffffffff8106707d>] ? up_write+0x1d/0x20
[ 3663.685343]  [<ffffffff81113656>] ? vm_mmap_pgoff+0x96/0xb0
[ 3663.685347]  [<ffffffff8124bdaa>] ? trace_hardirqs_off_thunk+0x3a/0x6c
[ 3663.685349]  [<ffffffff8148154f>] page_fault+0x1f/0x30
[ 3663.685352] Code: ff 65 48 8b 14 25 48 b7 00 00 83 82 44 e0 ff ff 01 ba 00 01 00 00 f0 66 0f c1 13 89 d1 66 c1 e9 08 38 d1 74 0d 0f 1f 40 00 f3 90 <0f> b6 13 38 d1 75 f7 5b 4c 89 e0 41 5c c9 c3 66 66 66 66 66 66
[ 3663.685378] NMI backtrace for cpu 6
[ 3663.685379] CPU 6 Modules linked in: btrfs zlib_deflate ib_ipoib rdma_ucm ib_ucm ib_uverbs ib_umad rdma_cm ib_cm iw_cm ib_addr ipv6 ib_sa iw_cxgb4 dm_mirror dm_region_hash dm_log dm_round_robin dm_multipath scsi_dh vhost_net macvtap macvlan tun uinput sg joydev sd_mod hid_generic coretemp hwmon kvm crc32c_intel ghash_clmulni_intel aesni_intel cryptd aes_x86_64 microcode serio_raw pcspkr ata_piix libata button mlx4_ib ib_mad ib_core mlx4_en mlx4_core[ 3663.685402] Uhhuh. NMI received for unknown reason 3d on CPU 3.
[ 3663.685403]  mpt2sas[ 3663.685404] Do you have a strange power saving mode enabled?
[ 3663.685405]  scsi_transport_sas[ 3663.685406] Dazed and confused, but trying to continue
[ 3663.685407]  raid_class scsi_mod cxgb4 i2c_i801 i2c_core lpc_ich mfd_core ehci_hcd uhci_hcd i7core_edac edac_core dm_mod ioatdma nfs nfs_acl auth_rpcgss fscache lockd sunrpc broadcom tg3 bnx2 igb dca e1000 [last unloaded: scsi_wait_scan]
[ 3663.685420]
[ 3663.685422] Pid: 102943, comm: ceph-osd Not tainted 3.5.0-00019-g472719a #221 Supermicro X8DTH-i/6/iF/6F/X8DTH
[ 3663.685424] RIP: 0010:[<ffffffff81480ed2>]  [<ffffffff81480ed2>] _raw_spin_lock_irqsave+0x42/0x60
[ 3663.685430] RSP: 0018:ffff88065c111898  EFLAGS: 00000006
[ 3663.685430] RAX: ffff88063fffcb00 RBX: ffff88063fffcb00 RCX: 00000000000000d9
[ 3663.685431] RDX: 00000000000000c5 RSI: 000000000000015a RDI: ffff88063fffcb00
[ 3663.685432] RBP: ffff88065c1118a8 R08: 0000000000000000 R09: 0000000000000000
[ 3663.685433] R10: ffff88063fffcb98 R11: ffff88063fffcc38 R12: 0000000000000246
[ 3663.685433] R13: ffff88063fffcba8 R14: ffff88063fffcb90 R15: ffff88063fffc680
[ 3663.685434] FS:  00007fffc693b700(0000) GS:ffff880c3fc00000(0000) knlGS:0000000000000000
[ 3663.685435] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[ 3663.685436] CR2: ffffffffff600400 CR3: 000000048d1b1000 CR4: 00000000000007e0
[ 3663.685437] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[ 3663.685438] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[ 3663.685439] Process ceph-osd (pid: 102943, threadinfo ffff88065c110000, task ffff880737b9ae00)
[ 3663.685439] Stack:
[ 3663.685440]  0000000000001d31 0000000000000000 ffff88065c111948 ffffffff8111a760
[ 3663.685444]  ffff8806245b2e00 ffff88065c1118c8 0000000000000006 0000000000000000
[ 3663.685447]  ffff88063fffcba0 000000003fffcb98 ffff88065c111a18 0000000000002000
[ 3663.685450] Call Trace:
[ 3663.685451]  [<ffffffff8111a760>] isolate_migratepages_range+0x150/0x4e0
[ 3663.685455]  [<ffffffff8111a5b0>] ? isolate_freepages+0x330/0x330
[ 3663.685458]  [<ffffffff8111af5b>] compact_zone+0x46b/0x4f0
[ 3663.685460]  [<ffffffff8111b3f8>] compact_zone_order+0xe8/0x100
[ 3663.685462]  [<ffffffff8111b4b6>] try_to_compact_pages+0xa6/0x110
[ 3663.685464]  [<ffffffff81100339>] __alloc_pages_direct_compact+0xd9/0x250
[ 3663.685469]  [<ffffffff81100883>] __alloc_pages_slowpath+0x3d3/0x750
[ 3663.685471]  [<ffffffff81100d3e>] __alloc_pages_nodemask+0x13e/0x1d0
[ 3663.685474]  [<ffffffff8113c894>] alloc_pages_vma+0x124/0x150
[ 3663.685477]  [<ffffffff8114e065>] do_huge_pmd_anonymous_page+0xf5/0x1e0
[ 3663.685481]  [<ffffffff81121bcd>] handle_mm_fault+0x21d/0x320
[ 3663.685483]  [<ffffffff8124bca4>] ? call_rwsem_down_read_failed+0x14/0x30
[ 3663.685487]  [<ffffffff81484e49>] do_page_fault+0x439/0x4a0
[ 3663.685490]  [<ffffffff8106707d>] ? up_write+0x1d/0x20
[ 3663.685493]  [<ffffffff81113656>] ? vm_mmap_pgoff+0x96/0xb0
[ 3663.685497]  [<ffffffff8124bdaa>] ? trace_hardirqs_off_thunk+0x3a/0x6c
[ 3663.685500]  [<ffffffff8148154f>] page_fault+0x1f/0x30
[ 3663.685502] Code: ff 65 48 8b 14 25 48 b7 00 00 83 82 44 e0 ff ff 01 ba 00 01 00 00 f0 66 0f c1 13 89 d1 66 c1 e9 08 38 d1 74 0d 0f 1f 40 00 f3 90 <0f> b6 13 38 d1 75 f7 5b 4c 89 e0 41 5c c9 c3 66 66 66 66 66 66
[ 3663.685527] NMI backtrace for cpu 1
[ 3663.685528] CPU 1 Modules linked in: btrfs zlib_deflate ib_ipoib rdma_ucm ib_ucm ib_uverbs ib_umad rdma_cm ib_cm iw_cm ib_addr ipv6 ib_sa iw_cxgb4 dm_mirror dm_region_hash dm_log dm_round_robin dm_multipath scsi_dh vhost_net macvtap macvlan tun uinput sg joydev sd_mod hid_generic coretemp hwmon kvm crc32c_intel ghash_clmulni_intel aesni_intel cryptd aes_x86_64 microcode serio_raw pcspkr ata_piix libata button mlx4_ib ib_mad ib_core mlx4_en mlx4_core mpt2sas scsi_transport_sas raid_class scsi_mod cxgb4 i2c_i801 i2c_core lpc_ich mfd_core ehci_hcd uhci_hcd i7core_edac edac_core dm_mod ioatdma nfs nfs_acl auth_rpcgss fscache lockd sunrpc broadcom tg3 bnx2 igb dca e1000 [last unloaded: scsi_wait_scan]
[ 3663.685562]
[ 3663.685563] Pid: 30029, comm: ceph-osd Not tainted 3.5.0-00019-g472719a #221 Supermicro X8DTH-i/6/iF/6F/X8DTH
[ 3663.685565] RIP: 0010:[<ffffffff81480ed2>]  [<ffffffff81480ed2>] _raw_spin_lock_irqsave+0x42/0x60
[ 3663.685569] RSP: 0018:ffff880563ae1898  EFLAGS: 00000006
[ 3663.685569] RAX: ffff88063fffcb00 RBX: ffff88063fffcb00 RCX: 00000000000000d6
[ 3663.685570] RDX: 00000000000000c5 RSI: 000000000000015a RDI: ffff88063fffcb00
[ 3663.685571] RBP: ffff880563ae18a8 R08: 0000000000000000 R09: 0000000000000000
[ 3663.685572] R10: ffff88063fffcb98 R11: ffff88063fffcc38 R12: 0000000000000246
[ 3663.685573] R13: ffff88063fffcba8 R14: ffff88063fffcb90 R15: ffff88063fffc680
[ 3663.685574] FS:  00007fffe86c9700(0000) GS:ffff880627c20000(0000) knlGS:0000000000000000
[ 3663.685575] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[ 3663.685576] CR2: ffffffffff600400 CR3: 00000002cc584000 CR4: 00000000000007e0
[ 3663.685577] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[ 3663.685577] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[ 3663.685578] Process ceph-osd (pid: 30029, threadinfo ffff880563ae0000, task ffff880563adc500)
[ 3663.685579] Stack:
[ 3663.685579]  000000000000167f 0000000000000000 ffff880563ae1948 ffffffff8111a760
[ 3663.685583]  ffff88063fffcc38 ffff88063fffcb98 000000000000256b 0000000000000000
[ 3663.685586]  ffff88063fffcba0 0000000000000004 ffff880563ae1a18 0000000000001a00
[ 3663.685589] Call Trace:
[ 3663.685590]  [<ffffffff8111a760>] isolate_migratepages_range+0x150/0x4e0
[ 3663.685593]  [<ffffffff8111a5b0>] ? isolate_freepages+0x330/0x330
[ 3663.685595]  [<ffffffff8111af5b>] compact_zone+0x46b/0x4f0
[ 3663.685597]  [<ffffffff8111b3f8>] compact_zone_order+0xe8/0x100
[ 3663.685599]  [<ffffffff8111b4b6>] try_to_compact_pages+0xa6/0x110
[ 3663.685601]  [<ffffffff81100339>] __alloc_pages_direct_compact+0xd9/0x250
[ 3663.685604]  [<ffffffff81100883>] __alloc_pages_slowpath+0x3d3/0x750
[ 3663.685607]  [<ffffffff81100d3e>] __alloc_pages_nodemask+0x13e/0x1d0
[ 3663.685609]  [<ffffffff8113c894>] alloc_pages_vma+0x124/0x150
[ 3663.685612]  [<ffffffff8114e065>] do_huge_pmd_anonymous_page+0xf5/0x1e0
[ 3663.685614]  [<ffffffff81121bcd>] handle_mm_fault+0x21d/0x320
[ 3663.685616]  [<ffffffff8124bca4>] ? call_rwsem_down_read_failed+0x14/0x30
[ 3663.685619]  [<ffffffff81484e49>] do_page_fault+0x439/0x4a0
[ 3663.685621]  [<ffffffff8106707d>] ? up_write+0x1d/0x20
[ 3663.685623]  [<ffffffff81113656>] ? vm_mmap_pgoff+0x96/0xb0
[ 3663.685626]  [<ffffffff8124bdaa>] ? trace_hardirqs_off_thunk+0x3a/0x6c
[ 3663.685628]  [<ffffffff8148154f>] page_fault+0x1f/0x30
[ 3663.685630] Code: ff 65 48 8b 14 25 48 b7 00 00 83 82 44 e0 ff ff 01 ba 00 01 00 00 f0 66 0f c1 13 89 d1 66 c1 e9 08 38 d1 74 0d 0f 1f 40 00 f3 90 <0f> b6 13 38 d1 75 f7 5b 4c 89 e0 41 5c c9 c3 66 66 66 66 66 66
[ 3663.685656] NMI backtrace for cpu 12
[ 3663.685656] CPU 12 Modules linked in: btrfs zlib_deflate ib_ipoib rdma_ucm ib_ucm ib_uverbs ib_umad rdma_cm ib_cm iw_cm ib_addr ipv6 ib_sa iw_cxgb4 dm_mirror dm_region_hash dm_log dm_round_robin dm_multipath scsi_dh vhost_net macvtap macvlan tun uinput sg joydev sd_mod hid_generic coretemp hwmon kvm crc32c_intel ghash_clmulni_intel aesni_intel cryptd aes_x86_64 microcode serio_raw pcspkr ata_piix libata button mlx4_ib ib_mad ib_core mlx4_en mlx4_core mpt2sas scsi_transport_sas raid_class scsi_mod cxgb4 i2c_i801 i2c_core lpc_ich mfd_core ehci_hcd uhci_hcd i7core_edac edac_core dm_mod ioatdma nfs nfs_acl auth_rpcgss fscache lockd sunrpc broadcom tg3 bnx2 igb dca e1000 [last unloaded: scsi_wait_scan]
[ 3663.685687]
[ 3663.685688] Pid: 97037, comm: ceph-osd Not tainted 3.5.0-00019-g472719a #221 Supermicro X8DTH-i/6/iF/6F/X8DTH
[ 3663.685690] RIP: 0010:[<ffffffff81480ed2>]  [<ffffffff81480ed2>] _raw_spin_lock_irqsave+0x42/0x60
[ 3663.685693] RSP: 0018:ffff880092839898  EFLAGS: 00000016
[ 3663.685694] RAX: ffff88063fffcb00 RBX: ffff88063fffcb00 RCX: 00000000000000d4
[ 3663.685694] RDX: 00000000000000c5 RSI: 000000000000015a RDI: ffff88063fffcb00
[ 3663.685695] RBP: ffff8800928398a8 R08: 0000000000000000 R09: 0000000000000000
[ 3663.685696] R10: ffff88063fffcb98 R11: ffff88063fffcc38 R12: 0000000000000246
[ 3663.685697] R13: ffff88063fffcba8 R14: ffff88063fffcb90 R15: ffff88063fffc680
[ 3663.685698] FS:  00007fffcb183700(0000) GS:ffff880627cc0000(0000) knlGS:0000000000000000
[ 3663.685699] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[ 3663.685700] CR2: ffffffffff600400 CR3: 0000000411741000 CR4: 00000000000007e0
[ 3663.685701] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[ 3663.685702] Uhhuh. NMI received for unknown reason 3d on CPU 6.
[ 3663.685703] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[ 3663.685704] Do you have a strange power saving mode enabled?
[ 3663.685705] Process ceph-osd (pid: 97037, threadinfo ffff880092838000, task ffff8805d127dc00)
[ 3663.685706] Dazed and confused, but trying to continue
[ 3663.685707] Stack:
[ 3663.685707]  000000000000358a 0000000000000000 ffff880092839948 ffffffff8111a760
[ 3663.685711]  ffff8806245c4500 ffff8800928398c8 000000000000000c 0000000000000000
[ 3663.685714]  ffff88063fffcba0 000000003fffcb98 ffff880092839a18 0000000000003800
[ 3663.685717] Call Trace:
[ 3663.685717]  [<ffffffff8111a760>] isolate_migratepages_range+0x150/0x4e0
[ 3663.685720]  [<ffffffff8111a5b0>] ? isolate_freepages+0x330/0x330
[ 3663.685722]  [<ffffffff8111af5b>] compact_zone+0x46b/0x4f0
[ 3663.685724]  [<ffffffff8111b3f8>] compact_zone_order+0xe8/0x100
[ 3663.685727]  [<ffffffff8111b4b6>] try_to_compact_pages+0xa6/0x110
[ 3663.685729]  [<ffffffff81100339>] __alloc_pages_direct_compact+0xd9/0x250
[ 3663.685731]  [<ffffffff81100883>] __alloc_pages_slowpath+0x3d3/0x750
[ 3663.685734]  [<ffffffff81100d3e>] __alloc_pages_nodemask+0x13e/0x1d0
[ 3663.685736]  [<ffffffff8113c894>] alloc_pages_vma+0x124/0x150
[ 3663.685738]  [<ffffffff8114e065>] do_huge_pmd_anonymous_page+0xf5/0x1e0
[ 3663.685740]  [<ffffffff81121bcd>] handle_mm_fault+0x21d/0x320
[ 3663.685743]  [<ffffffff8124bca4>] ? call_rwsem_down_read_failed+0x14/0x30
[ 3663.685745]  [<ffffffff81484e49>] do_page_fault+0x439/0x4a0
[ 3663.685747]  [<ffffffff8106707d>] ? up_write+0x1d/0x20
[ 3663.685749]  [<ffffffff81113656>] ? vm_mmap_pgoff+0x96/0xb0
[ 3663.685752]  [<ffffffff8124bdaa>] ? trace_hardirqs_off_thunk+0x3a/0x6c
[ 3663.685754]  [<ffffffff8148154f>] page_fault+0x1f/0x30
[ 3663.685756] Code: ff 65 48 8b 14 25 48 b7 00 00 83 82 44 e0 ff ff 01 ba 00 01 00 00 f0 66 0f c1 13 89 d1 66 c1 e9 08 38 d1 74 0d 0f 1f 40 00 f3 90 <0f> b6 13 38 d1 75 f7 5b 4c 89 e0 41 5c c9 c3 66 66 66 66 66 66
[ 3663.685781] NMI backtrace for cpu 14
[ 3663.685782] CPU 14 Modules linked in: btrfs zlib_deflate ib_ipoib rdma_ucm ib_ucm ib_uverbs ib_umad rdma_cm ib_cm iw_cm ib_addr ipv6 ib_sa iw_cxgb4 dm_mirror dm_region_hash dm_log dm_round_robin dm_multipath scsi_dh vhost_net macvtap macvlan tun uinput sg joydev sd_mod hid_generic coretemp hwmon kvm crc32c_intel ghash_clmulni_intel aesni_intel cryptd aes_x86_64 microcode serio_raw pcspkr ata_piix libata button mlx4_ib ib_mad ib_core mlx4_en mlx4_core mpt2sas scsi_transport_sas raid_class scsi_mod cxgb4 i2c_i801 i2c_core lpc_ich mfd_core ehci_hcd uhci_hcd i7core_edac edac_core dm_mod ioatdma nfs nfs_acl auth_rpcgss fscache lockd sunrpc broadcom tg3 bnx2 igb dca e1000 [last unloaded: scsi_wait_scan]
[ 3663.685815]
[ 3663.685816] Pid: 97590, comm: ceph-osd Not tainted 3.5.0-00019-g472719a #221 Supermicro X8DTH-i/6/iF/6F/X8DTH
[ 3663.685818] RIP: 0010:[<ffffffff81480ed2>]  [<ffffffff81480ed2>] _raw_spin_lock_irqsave+0x42/0x60
[ 3663.685821] RSP: 0018:ffff8803f97a9898  EFLAGS: 00000002
[ 3663.685822] RAX: ffff88063fffcb00 RBX: ffff88063fffcb00 RCX: 00000000000000c6
[ 3663.685823] RDX: 00000000000000c5 RSI: 000000000000015a RDI: ffff88063fffcb00
[ 3663.685823] RBP: ffff8803f97a98a8 R08: 0000000000000000 R09: 0000000000000000
[ 3663.685824] R10: ffff88063fffcb98 R11: ffff88063fffcc38 R12: 0000000000000246
[ 3663.685825] R13: ffff88063fffcba8 R14: ffff88063fffcb90 R15: ffff88063fffc680
[ 3663.685826] FS:  00007fffca577700(0000) GS:ffff880627d00000(0000) knlGS:0000000000000000
[ 3663.685827] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[ 3663.685828] CR2: ffffffffff600400 CR3: 00000002e0986000 CR4: 00000000000007e0
[ 3663.685828] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[ 3663.685829] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[ 3663.685830] Process ceph-osd (pid: 97590, threadinfo ffff8803f97a8000, task ffff88045554c500)
[ 3663.685831] Stack:
[ 3663.685831]  0000000000001cc3 0000000000000000 ffff8803f97a9948 ffffffff8111a760
[ 3663.685834]  ffff8806245d8000 ffff8803f97a98c8 000000000000000e 0000000000000000
[ 3663.685838]  ffff88063fffcba0 000000003fffcb98 ffff8803f97a9a18 0000000000002000
[ 3663.685841] Call Trace:
[ 3663.685842]  [<ffffffff8111a760>] isolate_migratepages_range+0x150/0x4e0
[ 3663.685844]  [<ffffffff8111a5b0>] ? isolate_freepages+0x330/0x330
[ 3663.685847]  [<ffffffff8111af5b>] compact_zone+0x46b/0x4f0
[ 3663.685849]  [<ffffffff8111b3f8>] compact_zone_order+0xe8/0x100
[ 3663.685851]  [<ffffffff8111b4b6>] try_to_compact_pages+0xa6/0x110
[ 3663.685853]  [<ffffffff81100339>] __alloc_pages_direct_compact+0xd9/0x250
[ 3663.685856]  [<ffffffff81100883>] __alloc_pages_slowpath+0x3d3/0x750
[ 3663.685859]  [<ffffffff81100d3e>] __alloc_pages_nodemask+0x13e/0x1d0
[ 3663.685861]  [<ffffffff8113c894>] alloc_pages_vma+0x124/0x150
[ 3663.685864]  [<ffffffff8114e065>] do_huge_pmd_anonymous_page+0xf5/0x1e0
[ 3663.685866]  [<ffffffff81121bcd>] handle_mm_fault+0x21d/0x320
[ 3663.685868]  [<ffffffff8124bca4>] ? call_rwsem_down_read_failed+0x14/0x30
[ 3663.685871]  [<ffffffff81484e49>] do_page_fault+0x439/0x4a0
[ 3663.685873]  [<ffffffff8106707d>] ? up_write+0x1d/0x20
[ 3663.685875]  [<ffffffff81113656>] ? vm_mmap_pgoff+0x96/0xb0
[ 3663.685878]  [<ffffffff8124bdaa>] ? trace_hardirqs_off_thunk+0x3a/0x6c
[ 3663.685880]  [<ffffffff8148154f>] page_fault+0x1f/0x30
[ 3663.685882] Code: ff 65 48 8b 14 25 48 b7 00 00 83 82 44 e0 ff ff 01 ba 00 01 00 00 f0 66 0f c1 13 89 d1 66 c1 e9 08 38 d1 74 0d 0f 1f 40 00 f3 90 <0f> b6 13 38 d1 75 f7 5b 4c 89 e0 41 5c c9 c3 66 66 66 66 66 66
[ 3663.685907] NMI backtrace for cpu 2
[ 3663.685908] CPU 2 Modules linked in: btrfs zlib_deflate ib_ipoib rdma_ucm ib_ucm ib_uverbs ib_umad rdma_cm ib_cm iw_cm ib_addr ipv6 ib_sa iw_cxgb4 dm_mirror dm_region_hash dm_log dm_round_robin dm_multipath scsi_dh vhost_net macvtap macvlan tun uinput sg joydev sd_mod hid_generic coretemp hwmon kvm crc32c_intel ghash_clmulni_intel aesni_intel cryptd aes_x86_64 microcode serio_raw pcspkr ata_piix libata button mlx4_ib ib_mad ib_core mlx4_en mlx4_core mpt2sas scsi_transport_sas raid_class scsi_mod cxgb4 i2c_i801 i2c_core lpc_ich mfd_core ehci_hcd uhci_hcd i7core_edac edac_core dm_mod ioatdma nfs nfs_acl auth_rpcgss fscache lockd sunrpc broadcom tg3 bnx2 igb dca e1000 [last unloaded: scsi_wait_scan]
[ 3663.685939]
[ 3663.685941] Pid: 100053, comm: ceph-osd Not tainted 3.5.0-00019-g472719a #221 Supermicro X8DTH-i/6/iF/6F/X8DTH
[ 3663.685943] RIP: 0010:[<ffffffff81480ed2>]  [<ffffffff81480ed2>] _raw_spin_lock_irqsave+0x42/0x60
[ 3663.685946] RSP: 0018:ffff8808da685898  EFLAGS: 00000012
[ 3663.685947] RAX: ffff88063fffcb00 RBX: ffff88063fffcb00 RCX: 00000000000000d3
[ 3663.685948] RDX: 00000000000000c6 RSI: 000000000000015a RDI: ffff88063fffcb00
[ 3663.685948] RBP: ffff8808da6858a8 R08: 0000000000000000 R09: 0000000000000000
[ 3663.685949] R10: ffff88063fffcb98 R11: ffff88063fffcc38 R12: 0000000000000246
[ 3663.685950] R13: ffff88063fffcba8 R14: ffff88063fffcb90 R15: ffff88063fffc680
[ 3663.685951] FS:  00007fff92c01700(0000) GS:ffff880627c40000(0000) knlGS:0000000000000000
[ 3663.685952] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[ 3663.685953] CR2: ffffffffff600400 CR3: 00000002b8fbe000 CR4: 00000000000007e0
[ 3663.685954] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[ 3663.685954] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[ 3663.685955] Process ceph-osd (pid: 100053, threadinfo ffff8808da684000, task ffff880a05a92e00)
[ 3663.685956] Stack:
[ 3663.685956]  000000000000119b 0000000000000000 ffff8808da685948 ffffffff8111a760
[ 3663.685959]  ffff8806244d4500 ffff8808da6858c8 0000000000000002 0000000000000000
[ 3663.685962]  ffff88063fffcba0 000000003fffcb98 ffff8808da685a18 0000000000001400
[ 3663.685966] Call Trace:
[ 3663.685966]  [<ffffffff8111a760>] isolate_migratepages_range+0x150/0x4e0
[ 3663.685969]  [<ffffffff8111a5b0>] ? isolate_freepages+0x330/0x330
[ 3663.685971]  [<ffffffff8111af5b>] compact_zone+0x46b/0x4f0
[ 3663.685973]  [<ffffffff8111b3f8>] compact_zone_order+0xe8/0x100
[ 3663.685976]  [<ffffffff8111b4b6>] try_to_compact_pages+0xa6/0x110
[ 3663.685978]  [<ffffffff81100339>] __alloc_pages_direct_compact+0xd9/0x250
[ 3663.685981]  [<ffffffff81100883>] __alloc_pages_slowpath+0x3d3/0x750
[ 3663.685983]  [<ffffffff81100d3e>] __alloc_pages_nodemask+0x13e/0x1d0
[ 3663.685986]  [<ffffffff8113c894>] alloc_pages_vma+0x124/0x150
[ 3663.685988]  [<ffffffff8114e065>] do_huge_pmd_anonymous_page+0xf5/0x1e0
[ 3663.685990]  [<ffffffff81121bcd>] handle_mm_fault+0x21d/0x320
[ 3663.685992]  [<ffffffff8124bca4>] ? call_rwsem_down_read_failed+0x14/0x30
[ 3663.685995]  [<ffffffff81484e49>] do_page_fault+0x439/0x4a0
[ 3663.685997]  [<ffffffff8124bdaa>] ? trace_hardirqs_off_thunk+0x3a/0x6c
[ 3663.685999]  [<ffffffff8148154f>] page_fault+0x1f/0x30
[ 3663.686001] Code: ff 65 48 8b 14 25 48 b7 00 00 83 82 44 e0 ff ff 01 ba 00 01 00 00 f0 66 0f c1 13 89 d1 66 c1 e9 08 38 d1 74 0d 0f 1f 40 00 f3 90 <0f> b6 13 38 d1 75 f7 5b 4c 89 e0 41 5c c9 c3 66 66 66 66 66 66
[ 3663.686028] NMI backtrace for cpu 11
[ 3663.686028] CPU 11 Modules linked in: btrfs zlib_deflate ib_ipoib rdma_ucm ib_ucm ib_uverbs ib_umad rdma_cm ib_cm iw_cm ib_addr ipv6 ib_sa iw_cxgb4 dm_mirror dm_region_hash dm_log dm_round_robin dm_multipath scsi_dh vhost_net macvtap macvlan tun uinput sg joydev sd_mod hid_generic coretemp hwmon kvm crc32c_intel ghash_clmulni_intel aesni_intel cryptd aes_x86_64 microcode serio_raw pcspkr ata_piix libata button mlx4_ib ib_mad ib_core mlx4_en mlx4_core mpt2sas scsi_transport_sas raid_class scsi_mod cxgb4 i2c_i801 i2c_core lpc_ich mfd_core ehci_hcd uhci_hcd i7core_edac edac_core dm_mod ioatdma nfs nfs_acl auth_rpcgss fscache lockd sunrpc broadcom tg3 bnx2 igb dca e1000 [last unloaded: scsi_wait_scan]
[ 3663.686062]
[ 3663.686064] Pid: 97756, comm: ceph-osd Not tainted 3.5.0-00019-g472719a #221 Supermicro X8DTH-i/6/iF/6F/X8DTH
[ 3663.686066] RIP: 0010:[<ffffffff81480ed5>]  [<ffffffff81480ed5>] _raw_spin_lock_irqsave+0x45/0x60
[ 3663.686069] RSP: 0018:ffff880b11ecd898  EFLAGS: 00000006
[ 3663.686070] RAX: ffff88063fffcb00 RBX: ffff88063fffcb00 RCX: 00000000000000d8
[ 3663.686070] RDX: 00000000000000c6 RSI: 000000000000015a RDI: ffff88063fffcb00
[ 3663.686071] RBP: ffff880b11ecd8a8 R08: 0000000000000000 R09: 0000000000000000
[ 3663.686072] R10: ffff88063fffcb98 R11: ffff88063fffcc38 R12: 0000000000000246
[ 3663.686073] R13: ffff88063fffcba8 R14: ffff88063fffcb90 R15: ffff88063fffc680
[ 3663.686074] FS:  00007ffff36df700(0000) GS:ffff880c3fca0000(0000) knlGS:0000000000000000
[ 3663.686075] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[ 3663.686076] CR2: ffffffffff600400 CR3: 00000002cae55000 CR4: 00000000000007e0
[ 3663.686077] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[ 3663.686078] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[ 3663.686079] Process ceph-osd (pid: 97756, threadinfo ffff880b11ecc000, task ffff880a79a51700)
[ 3663.686079] Stack:
[ 3663.686080]  0000000000001b3e 0000000000000000 ffff880b11ecd948 ffffffff8111a760
[ 3663.686083]  ffff8806245c2e00 ffff880b11ecd8c8 000000000000000b 0000000000000000
[ 3663.686086]  ffff88063fffcba0 000000003fffcb98 ffff880b11ecda18 0000000000001e00
[ 3663.686089] Call Trace:
[ 3663.686090]  [<ffffffff8111a760>] isolate_migratepages_range+0x150/0x4e0
[ 3663.686093]  [<ffffffff8111a5b0>] ? isolate_freepages+0x330/0x330
[ 3663.686095]  [<ffffffff8111af5b>] compact_zone+0x46b/0x4f0
[ 3663.686097]  [<ffffffff8111b3f8>] compact_zone_order+0xe8/0x100
[ 3663.686099]  [<ffffffff8111b4b6>] try_to_compact_pages+0xa6/0x110
[ 3663.686102]  [<ffffffff81100339>] __alloc_pages_direct_compact+0xd9/0x250
[ 3663.686105]  [<ffffffff81100883>] __alloc_pages_slowpath+0x3d3/0x750
[ 3663.686107]  [<ffffffff81100d3e>] __alloc_pages_nodemask+0x13e/0x1d0
[ 3663.686110]  [<ffffffff8113c894>] alloc_pages_vma+0x124/0x150
[ 3663.686112]  [<ffffffff8114e065>] do_huge_pmd_anonymous_page+0xf5/0x1e0
[ 3663.686114]  [<ffffffff81121bcd>] handle_mm_fault+0x21d/0x320
[ 3663.686117]  [<ffffffff81484e49>] do_page_fault+0x439/0x4a0
[ 3663.686119]  [<ffffffff8106707d>] ? up_write+0x1d/0x20
[ 3663.686121]  [<ffffffff81113656>] ? vm_mmap_pgoff+0x96/0xb0
[ 3663.686124]  [<ffffffff8124bdaa>] ? trace_hardirqs_off_thunk+0x3a/0x6c
[ 3663.686126]  [<ffffffff8148154f>] page_fault+0x1f/0x30
[ 3663.686129] Code: 8b 14 25 48 b7 00 00 83 82 44 e0 ff ff 01 ba 00 01 00 00 f0 66 0f c1 13 89 d1 66 c1 e9 08 38 d1 74 0d 0f 1f 40 00 f3 90 0f b6 13 <38> d1 75 f7 5b 4c 89 e0 41 5c c9 c3 66 66 66 66 66 66 2e 0f 1f
[ 3663.686155] NMI backtrace for cpu 20
[ 3663.686155] CPU 20 Modules linked in: btrfs zlib_deflate ib_ipoib rdma_ucm ib_ucm ib_uverbs ib_umad rdma_cm ib_cm iw_cm ib_addr ipv6 ib_sa iw_cxgb4 dm_mirror dm_region_hash dm_log dm_round_robin dm_multipath scsi_dh vhost_net macvtap macvlan tun uinput sg joydev sd_mod hid_generic coretemp hwmon kvm crc32c_intel ghash_clmulni_intel aesni_intel cryptd aes_x86_64 microcode serio_raw pcspkr ata_piix libata button mlx4_ib ib_mad ib_core mlx4_en mlx4_core mpt2sas scsi_transport_sas raid_class scsi_mod cxgb4 i2c_i801 i2c_core lpc_ich mfd_core ehci_hcd uhci_hcd i7core_edac edac_core dm_mod ioatdma nfs nfs_acl auth_rpcgss fscache lockd sunrpc broadcom tg3 bnx2 igb dca e1000 [last unloaded: scsi_wait_scan]
[ 3663.686189]
[ 3663.686190] Pid: 97755, comm: ceph-osd Not tainted 3.5.0-00019-g472719a #221 Supermicro X8DTH-i/6/iF/6F/X8DTH
[ 3663.686193] RIP: 0010:[<ffffffff81480ed5>]  [<ffffffff81480ed5>] _raw_spin_lock_irqsave+0x45/0x60
[ 3663.686196] RSP: 0018:ffff88066d5af898  EFLAGS: 00000002
[ 3663.686196] RAX: ffff88063fffcb00 RBX: ffff88063fffcb00 RCX: 00000000000000cd
[ 3663.686197] RDX: 00000000000000c6 RSI: 000000000000015a RDI: ffff88063fffcb00
[ 3663.686198] RBP: ffff88066d5af8a8 R08: 0000000000000000 R09: 0000000000000000
[ 3663.686199] R10: ffff88063fffcb98 R11: ffff88063fffcc38 R12: 0000000000000246
[ 3663.686199] R13: ffff88063fffcba8 R14: ffff88063fffcb90 R15: ffff88063fffc680
[ 3663.686200] Uhhuh. NMI received for unknown reason 2d on CPU 11.
[ 3663.686201] FS:  00007ffff3ee0700(0000) GS:ffff880c3fd00000(0000) knlGS:0000000000000000
[ 3663.686202] Do you have a strange power saving mode enabled?
[ 3663.686203] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[ 3663.686203] Dazed and confused, but trying to continue
[ 3663.686204] CR2: ffffffffff600400 CR3: 00000002cae55000 CR4: 00000000000007e0
[ 3663.686205] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[ 3663.686206] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[ 3663.686207] Process ceph-osd (pid: 97755, threadinfo ffff88066d5ae000, task ffff880a79a52e00)
[ 3663.686207] Stack:
[ 3663.686208]  0000000000001cbf 0000000000000000 ffff88066d5af948 ffffffff8111a760
[ 3663.686211]  ffff8806245e9700 ffff88066d5af8c8 0000000000000014 0000000000000000
[ 3663.686214]  ffff88063fffcba0 000000003fffcb98 ffff88066d5afa18 0000000000002000
[ 3663.686217] Call Trace:
[ 3663.686218]  [<ffffffff8111a760>] isolate_migratepages_range+0x150/0x4e0
[ 3663.686221]  [<ffffffff8111a5b0>] ? isolate_freepages+0x330/0x330
[ 3663.686223]  [<ffffffff8111af5b>] compact_zone+0x46b/0x4f0
[ 3663.686225]  [<ffffffff8111b3f8>] compact_zone_order+0xe8/0x100
[ 3663.686228]  [<ffffffff8111b4b6>] try_to_compact_pages+0xa6/0x110
[ 3663.686230]  [<ffffffff81100339>] __alloc_pages_direct_compact+0xd9/0x250
[ 3663.686233]  [<ffffffff81100883>] __alloc_pages_slowpath+0x3d3/0x750
[ 3663.686236]  [<ffffffff81100d3e>] __alloc_pages_nodemask+0x13e/0x1d0
[ 3663.686238]  [<ffffffff8113c894>] alloc_pages_vma+0x124/0x150
[ 3663.686240]  [<ffffffff8114e065>] do_huge_pmd_anonymous_page+0xf5/0x1e0
[ 3663.686243]  [<ffffffff81121bcd>] handle_mm_fault+0x21d/0x320
[ 3663.686245]  [<ffffffff8124bca4>] ? call_rwsem_down_read_failed+0x14/0x30
[ 3663.686247]  [<ffffffff81484e49>] do_page_fault+0x439/0x4a0
[ 3663.686250]  [<ffffffff8106707d>] ? up_write+0x1d/0x20
[ 3663.686252]  [<ffffffff81113656>] ? vm_mmap_pgoff+0x96/0xb0
[ 3663.686254]  [<ffffffff8124bdaa>] ? trace_hardirqs_off_thunk+0x3a/0x6c
[ 3663.686257]  [<ffffffff8148154f>] page_fault+0x1f/0x30
[ 3663.686259] Code: 8b 14 25 48 b7 00 00 83 82 44 e0 ff ff 01 ba 00 01 00 00 f0 66 0f c1 13 89 d1 66 c1 e9 08 38 d1 74 0d 0f 1f 40 00 f3 90 0f b6 13 <38> d1 75 f7 5b 4c 89 e0 41 5c c9 c3 66 66 66 66 66 66 2e 0f 1f
[ 3663.686284] NMI backtrace for cpu 13
[ 3663.686285] CPU 13 Modules linked in: btrfs zlib_deflate ib_ipoib rdma_ucm ib_ucm ib_uverbs ib_umad rdma_cm ib_cm iw_cm ib_addr ipv6 ib_sa iw_cxgb4 dm_mirror dm_region_hash dm_log dm_round_robin dm_multipath scsi_dh vhost_net macvtap macvlan tun uinput sg joydev sd_mod hid_generic coretemp hwmon kvm crc32c_intel[ 3663.686300] Uhhuh. NMI received for unknown reason 2d on CPU 12.
[ 3663.686300]  ghash_clmulni_intel[ 3663.686301] Do you have a strange power saving mode enabled?
[ 3663.686301]  aesni_intel[ 3663.686302] Dazed and confused, but trying to continue
[ 3663.686302]  cryptd aes_x86_64 microcode serio_raw pcspkr ata_piix libata button mlx4_ib ib_mad ib_core mlx4_en mlx4_core mpt2sas scsi_transport_sas raid_class scsi_mod cxgb4 i2c_i801 i2c_core lpc_ich mfd_core ehci_hcd uhci_hcd i7core_edac edac_core dm_mod ioatdma nfs nfs_acl auth_rpcgss fscache lockd sunrpc broadcom tg3 bnx2 igb dca e1000 [last unloaded: scsi_wait_scan]
[ 3663.686318]
[ 3663.686319] Pid: 98427, comm: ceph-osd Not tainted 3.5.0-00019-g472719a #221 Supermicro X8DTH-i/6/iF/6F/X8DTH
[ 3663.686321] RIP: 0010:[<ffffffff81480ed0>]  [<ffffffff81480ed0>] _raw_spin_lock_irqsave+0x40/0x60
[ 3663.686324] RSP: 0018:ffff880356409898  EFLAGS: 00000016
[ 3663.686324] RAX: ffff88063fffcb00 RBX: ffff88063fffcb00 RCX: 00000000000000d2
[ 3663.686325] RDX: 00000000000000c6 RSI: 000000000000015a RDI: ffff88063fffcb00
[ 3663.686326] RBP: ffff8803564098a8 R08: 0000000000000000 R09: 0000000000000000
[ 3663.686327] R10: ffff88063fffcb98 R11: ffff88063fffcc38 R12: 0000000000000246
[ 3663.686327] R13: ffff88063fffcba8 R14: ffff88063fffcb90 R15: ffff88063fffc680
[ 3663.686328] FS:  00007fffc794b700(0000) GS:ffff880627ce0000(0000) knlGS:0000000000000000
[ 3663.686329] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[ 3663.686330] CR2: ffffffffff600400 CR3: 00000002bc512000 CR4: 00000000000007e0
[ 3663.686331] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
[ 3663.686332] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000400
[ 3663.686333] Process ceph-osd (pid: 98427, threadinfo ffff880356408000, task ffff880027de5c00)
[ 3663.686333] Stack:
[ 3663.686333]  0000000000001061 0000000000000000 ffff880356409948 ffffffff8111a760
[ 3663.686337]  ffff8806245c5c00 ffff8803564098c8 000000000000000d 0000000000000000
[ 3663.686340]  ffff88063fffcba0 000000003fffcb98 ffff880356409a18 0000000000001400
[ 3663.686343] Call Trace:
[ 3663.686343]  [<ffffffff8111a760>] isolate_migratepages_range+0x150/0x4e0
[ 3663.686346]  [<ffffffff8111a5b0>] ? isolate_freepages+0x330/0x330
[ 3663.686348]  [<ffffffff8111af5b>] compact_zone+0x46b/0x4f0
[ 3663.686350]  [<ffffffff8111b3f8>] compact_zone_order+0xe8/0x100
[ 3663.686352]  [<ffffffff8111b4b6>] try_to_compact_pages+0xa6/0x110
[ 3663.686354]  [<ffffffff81100339>] __alloc_pages_direct_compact+0xd9/0x250
[ 3663.686357]  [<ffffffff81100883>] __alloc_pages_slowpath+0x3d3/0x750
[ 3663.686360]  [<ffffffff81100d3e>] __alloc_pages_nodemask+0x13e/0x1d0
[ 3663.686362]  [<ffffffff8113c894>] alloc_pages_vma+0x124/0x150
[ 3663.686364]  [<ffffffff8114e065>] do_huge_pmd_anonymous_page+0xf5/0x1e0
[ 3663.686366]  [<ffffffff81121bcd>] handle_mm_fault+0x21d/0x320
[ 3663.686368]  [<ffffffff8124bca4>] ? call_rwsem_down_read_failed+0x14/0x30
[ 3663.686370]  [<ffffffff81484e49>] do_page_fault+0x439/0x4a0
[ 3663.686373]  [<ffffffff8106707d>] ? up_write+0x1d/0x20
[ 3663.686375]  [<ffffffff81113656>] ? vm_mmap_pgoff+0x96/0xb0
[ 3663.686377]  [<ffffffff8124bdaa>] ? trace_hardirqs_off_thunk+0x3a/0x6c
[ 3663.686379]  [<ffffffff8148154f>] page_fault+0x1f/0x30
[ 3663.686381] Code: 6a c5 ff 65 48 8b 14 25 48 b7 00 00 83 82 44 e0 ff ff 01 ba 00 01 00 00 f0 66 0f c1 13 89 d1 66 c1 e9 08 38 d1 74 0d 0f 1f 40 00 <f3> 90 0f b6 13 38 d1 75 f7 5b 4c 89 e0 41 5c c9 c3 66 66 66 66


Please let me know what I can do next to help sort this out.

Thanks -- Jim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
