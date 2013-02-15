Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx161.postini.com [74.125.245.161])
	by kanga.kvack.org (Postfix) with SMTP id 822C46B009B
	for <linux-mm@kvack.org>; Fri, 15 Feb 2013 18:04:10 -0500 (EST)
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
 format=flowed
Content-Transfer-Encoding: 7bit
Date: Sat, 16 Feb 2013 01:04:06 +0200
From: Denys Fedoryshchenko <denys@visp.net.lb>
Subject: kernel BUG at mm/slub.c:3409, 3.8.0-rc7
Message-ID: <9699daeed06dc8837f792bfdf486da45@visp.net.lb>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: cl@linux-foundation.org, penberg@kernel.org, mpm@selenic.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi

Worked for a while on 3.8.0-rc7, generally it is fine, then suddenly 
laptop stopped responding to keyboard and mouse.
Sure it can be memory corruption by some other module, but maybe not. 
Worth to report i guess.
After reboot checked logs and found this:

Feb 16 00:40:17 localhost kernel: [23260.079253] ------------[ cut here 
]------------
Feb 16 00:40:17 localhost kernel: [23260.079257] kernel BUG at 
mm/slub.c:3409!
Feb 16 00:40:17 localhost kernel: [23260.079259] invalid opcode: 0000 
[#1] SMP
Feb 16 00:40:17 localhost kernel: [23260.079262] Modules linked in: 
ipt_MASQUERADE iptable_nat nf_nat_ipv4 nf_nat nf_conntrack_ipv4 
nf_defrag_ipv4 xt_state nf_conntrack ipt_REJECT xt_CHECKSUM 
iptable_mangle iptable_filter ip_tables tun bridge stp llc nouveau 
snd_hda_codec_hdmi coretemp kvm_intel snd_hda_codec_realtek uvcvideo 
videobuf2_vmalloc snd_hda_intel videobuf2_memops videobuf2_core kvm 
mxm_wmi wmi videodev hwmon ttm snd_hda_codec drm_kms_helper rtl8192se 
rtlwifi nvidiafb mei lpc_ich mfd_core i2c_i801 snd_hwdep
Feb 16 00:40:17 localhost kernel: [23260.079295] CPU 0
Feb 16 00:40:17 localhost kernel: [23260.079298] Pid: 3811, comm: 
kworker/0:1 Tainted: G        W    3.8.0-rc7-lap #1 TOSHIBA Satellite 
A665/NWQAA
Feb 16 00:40:17 localhost kernel: [23260.079300] RIP: 
0010:[<ffffffff810d9ed1>]  [<ffffffff810d9ed1>] kfree+0x31/0xb1
Feb 16 00:40:17 localhost kernel: [23260.079306] RSP: 
0018:ffff88012b02fd28  EFLAGS: 00010246
Feb 16 00:40:17 localhost kernel: [23260.079308] RAX: 8000000000000000 
RBX: ffff8801029fcb40 RCX: 000000000079b6df
Feb 16 00:40:17 localhost kernel: [23260.079310] RDX: 8000000000000000 
RSI: ffff88017d79f480 RDI: ffff8801029fcb40
Feb 16 00:40:17 localhost kernel: [23260.079312] RBP: ffff88012b02fd48 
R08: 0000000000014b60 R09: 0000000000000001
Feb 16 00:40:17 localhost kernel: [23260.079313] R10: ffff880100000000 
R11: 0000000000000001 R12: ffffea00040a7f00
Feb 16 00:40:17 localhost kernel: [23260.079315] R13: ffff8801bfc15e00 
R14: ffff8801bfc0d380 R15: ffff88012b02fda8
Feb 16 00:40:17 localhost kernel: [23260.079317] FS:  
0000000000000000(0000) GS:ffff8801bfc00000(0000) knlGS:0000000000000000
Feb 16 00:40:17 localhost kernel: [23260.079319] CS:  0010 DS: 0000 ES: 
0000 CR0: 000000008005003b
Feb 16 00:40:17 localhost kernel: [23260.079321] CR2: 000035ffe6f63008 
CR3: 0000000001a0c000 CR4: 00000000000007f0
Feb 16 00:40:17 localhost kernel: [23260.079322] DR0: 0000000000000000 
DR1: 0000000000000000 DR2: 0000000000000000
Feb 16 00:40:17 localhost kernel: [23260.079324] DR3: 0000000000000000 
DR6: 00000000ffff0ff0 DR7: 0000000000000400
Feb 16 00:40:17 localhost kernel: [23260.079326] Process kworker/0:1 
(pid: 3811, threadinfo ffff88012b02e000, task ffff8801b0300000)
Feb 16 00:40:17 localhost kernel: [23260.079327] Stack:
Feb 16 00:40:17 localhost kernel: [23260.079329]  ffff8801019fcb50 
ffff8801029fcb40 ffff8801bfc15e00 ffff8801bfc0d380
Feb 16 00:40:17 localhost kernel: [23260.079332]  ffff88012b02fd68 
ffffffff8125fe88 ffff880165c0a600 ffff8801019fcb50
Feb 16 00:40:17 localhost kernel: [23260.079336]  ffff88012b02fdf8 
ffffffff810441f0 ffffffff81044183 ffff88012b02ffd8
Feb 16 00:40:17 localhost kernel: [23260.079339] Call Trace:
Feb 16 00:40:17 localhost kernel: [23260.079344]  [<ffffffff8125fe88>] 
acpi_os_execute_deferred+0x2a/0x2f
Feb 16 00:40:17 localhost kernel: [23260.079348]  [<ffffffff810441f0>] 
process_one_work+0x1d8/0x2eb
Feb 16 00:40:17 localhost kernel: [23260.079351]  [<ffffffff81044183>] 
? process_one_work+0x16b/0x2eb
Feb 16 00:40:17 localhost kernel: [23260.079354]  [<ffffffff8125fe5e>] 
? acpi_os_wait_events_complete+0x1e/0x1e
Feb 16 00:40:17 localhost kernel: [23260.079357]  [<ffffffff8104603d>] 
worker_thread+0x13e/0x1c1
Feb 16 00:40:17 localhost kernel: [23260.079360]  [<ffffffff81045eff>] 
? manage_workers+0x250/0x250
Feb 16 00:40:17 localhost kernel: [23260.079363]  [<ffffffff81049d14>] 
kthread+0xa5/0xad
Feb 16 00:40:17 localhost kernel: [23260.079366]  [<ffffffff81049c6f>] 
? __init_kthread_worker+0x56/0x56
Feb 16 00:40:17 localhost kernel: [23260.079370]  [<ffffffff8153eeec>] 
ret_from_fork+0x7c/0xb0
Feb 16 00:40:17 localhost kernel: [23260.079373]  [<ffffffff81049c6f>] 
? __init_kthread_worker+0x56/0x56
Feb 16 00:40:17 localhost kernel: [23260.079374] Code: 89 e5 41 56 41 
55 41 54 53 48 89 fb 0f 86 90 00 00 00 e8 74 e1 ff ff 49 89 c4 48 8b 00 
a8 80 75 20 49 f7 04 24 00 c0 00 00 75 02 <0f> 0b 4c 89 e7 e8 44 d0 ff 
ff 4c 89 e7 89 c6 e8 7d 2d fd ff eb
Feb 16 00:40:17 localhost kernel: [23260.079409] RIP  
[<ffffffff810d9ed1>] kfree+0x31/0xb1
Feb 16 00:40:17 localhost kernel: [23260.079412]  RSP 
<ffff88012b02fd28>
Feb 16 00:40:17 localhost kernel: [23260.079414] ---[ end trace 
bae1313833245122 ]---
Feb 16 00:40:17 localhost kernel: [23260.079450] BUG: unable to handle 
kernel paging request at ffffffffffffffa8
Feb 16 00:40:17 localhost kernel: [23260.079452] IP: 
[<ffffffff81049f54>] kthread_data+0xb/0x11
Feb 16 00:40:17 localhost kernel: [23260.079455] PGD 1a0e067 PUD 
1a0f067 PMD 0
Feb 16 00:40:17 localhost kernel: [23260.079458] Oops: 0000 [#2] SMP
Feb 16 00:40:17 localhost kernel: [23260.079461] Modules linked in: 
ipt_MASQUERADE iptable_nat nf_nat_ipv4 nf_nat nf_conntrack_ipv4 
nf_defrag_ipv4 xt_state nf_conntrack ipt_REJECT xt_CHECKSUM 
iptable_mangle iptable_filter ip_tables tun bridge stp llc nouveau 
snd_hda_codec_hdmi coretemp kvm_intel snd_hda_codec_realtek uvcvideo 
videobuf2_vmalloc snd_hda_intel videobuf2_memops videobuf2_core kvm 
mxm_wmi wmi videodev hwmon ttm snd_hda_codec drm_kms_helper rtl8192se 
rtlwifi nvidiafb mei lpc_ich mfd_core i2c_i801 snd_hwdep
Feb 16 00:40:17 localhost kernel: [23260.079490] CPU 0
Feb 16 00:40:17 localhost kernel: [23260.079492] Pid: 3811, comm: 
kworker/0:1 Tainted: G      D W    3.8.0-rc7-lap #1 TOSHIBA Satellite 
A665/NWQAA
Feb 16 00:40:17 localhost kernel: [23260.079494] RIP: 
0010:[<ffffffff81049f54>]  [<ffffffff81049f54>] kthread_data+0xb/0x11
Feb 16 00:40:17 localhost kernel: [23260.079497] RSP: 
0018:ffff88012b02f998  EFLAGS: 00010092
Feb 16 00:40:17 localhost kernel: [23260.079499] RAX: 0000000000000000 
RBX: ffff8801bfc11cc0 RCX: ffff8801bfc11d68
Feb 16 00:40:17 localhost kernel: [23260.079501] RDX: 0000000000000000 
RSI: 0000000000000000 RDI: ffff8801b0300000
Feb 16 00:40:17 localhost kernel: [23260.079502] RBP: ffff88012b02f998 
R08: ffffffff81b6a160 R09: 000000000000b451
Feb 16 00:40:17 localhost kernel: [23260.079504] R10: ffffffff81a23330 
R11: ffff8801b4989180 R12: ffff8801b03003c8
Feb 16 00:40:17 localhost kernel: [23260.079506] R13: 0000000000000000 
R14: 0000000000000000 R15: 0000000000000006
Feb 16 00:40:17 localhost kernel: [23260.079508] FS:  
0000000000000000(0000) GS:ffff8801bfc00000(0000) knlGS:0000000000000000
Feb 16 00:40:17 localhost kernel: [23260.079510] CS:  0010 DS: 0000 ES: 
0000 CR0: 000000008005003b
Feb 16 00:40:17 localhost kernel: [23260.079511] CR2: ffffffffffffffa8 
CR3: 0000000001a0c000 CR4: 00000000000007f0
Feb 16 00:40:17 localhost kernel: [23260.079513] DR0: 0000000000000000 
DR1: 0000000000000000 DR2: 0000000000000000
Feb 16 00:40:17 localhost kernel: [23260.079515] DR3: 0000000000000000 
DR6: 00000000ffff0ff0 DR7: 0000000000000400
Feb 16 00:40:17 localhost kernel: [23260.079517] Process kworker/0:1 
(pid: 3811, threadinfo ffff88012b02e000, task ffff8801b0300000)
Feb 16 00:40:17 localhost kernel: [23260.079518] Stack:
Feb 16 00:40:17 localhost kernel: [23260.079519]  ffff88012b02f9c8 
ffffffff810464bd ffffffff81537e7a ffff8801bfc11cc0
Feb 16 00:40:17 localhost kernel: [23260.079523]  ffff8801b03003c8 
ffff88012b02f7d8 ffff88012b02fa78 ffffffff81537ef6
Feb 16 00:40:17 localhost kernel: [23260.079526]  ffff88012b02fa18 
0000000000000246 ffffffff81a05000 0000000000011cc0
Feb 16 00:40:17 localhost kernel: [23260.079529] Call Trace:
Feb 16 00:40:17 localhost kernel: [23260.079533]  [<ffffffff810464bd>] 
wq_worker_sleeping+0x15/0x78
Feb 16 00:40:17 localhost kernel: [23260.079536]  [<ffffffff81537e7a>] 
? __schedule+0xe5/0x58b
Feb 16 00:40:17 localhost kernel: [23260.079539]  [<ffffffff81537ef6>] 
__schedule+0x161/0x58b
Feb 16 00:40:17 localhost kernel: [23260.079542]  [<ffffffff8153859c>] 
schedule+0x5f/0x61
Feb 16 00:40:17 localhost kernel: [23260.079546]  [<ffffffff81034b56>] 
do_exit+0x8e8/0x8ea
Feb 16 00:40:17 localhost kernel: [23260.079549]  [<ffffffff8103267e>] 
? kmsg_dump+0x1f/0x112
Feb 16 00:40:17 localhost kernel: [23260.079552]  [<ffffffff8153a5df>] 
oops_end+0xb2/0xba
Feb 16 00:40:17 localhost kernel: [23260.079555]  [<ffffffff810052ad>] 
die+0x55/0x60
Feb 16 00:40:17 localhost kernel: [23260.079558]  [<ffffffff8153a082>] 
do_trap+0x6b/0x132
Feb 16 00:40:17 localhost kernel: [23260.079562]  [<ffffffff81002fa6>] 
do_invalid_op+0x93/0x9c
Feb 16 00:40:17 localhost kernel: [23260.079565]  [<ffffffff810d9ed1>] 
? kfree+0x31/0xb1
Feb 16 00:40:17 localhost kernel: [23260.079569]  [<ffffffff8122cb5d>] 
? trace_hardirqs_off_thunk+0x3a/0x3c
Feb 16 00:40:17 localhost kernel: [23260.079572]  [<ffffffff81539a49>] 
? restore_args+0x30/0x30
Feb 16 00:40:17 localhost kernel: [23260.079575]  [<ffffffff81540225>] 
invalid_op+0x15/0x20
Feb 16 00:40:17 localhost kernel: [23260.079578]  [<ffffffff810d9ed1>] 
? kfree+0x31/0xb1
Feb 16 00:40:17 localhost kernel: [23260.079581]  [<ffffffff810d9ebd>] 
? kfree+0x1d/0xb1
Feb 16 00:40:17 localhost kernel: [23260.079584]  [<ffffffff8125fe88>] 
acpi_os_execute_deferred+0x2a/0x2f
Feb 16 00:40:17 localhost kernel: [23260.079586]  [<ffffffff810441f0>] 
process_one_work+0x1d8/0x2eb
Feb 16 00:40:17 localhost kernel: [23260.079589]  [<ffffffff81044183>] 
? process_one_work+0x16b/0x2eb
Feb 16 00:40:17 localhost kernel: [23260.079592]  [<ffffffff8125fe5e>] 
? acpi_os_wait_events_complete+0x1e/0x1e
Feb 16 00:40:17 localhost kernel: [23260.079595]  [<ffffffff8104603d>] 
worker_thread+0x13e/0x1c1
Feb 16 00:40:17 localhost kernel: [23260.079598]  [<ffffffff81045eff>] 
? manage_workers+0x250/0x250
Feb 16 00:40:17 localhost kernel: [23260.079600]  [<ffffffff81049d14>] 
kthread+0xa5/0xad
Feb 16 00:40:17 localhost kernel: [23260.079603]  [<ffffffff81049c6f>] 
? __init_kthread_worker+0x56/0x56
Feb 16 00:40:17 localhost kernel: [23260.079606]  [<ffffffff8153eeec>] 
ret_from_fork+0x7c/0xb0
Feb 16 00:40:17 localhost kernel: [23260.079608]  [<ffffffff81049c6f>] 
? __init_kthread_worker+0x56/0x56
Feb 16 00:40:17 localhost kernel: [23260.079610] Code: 48 89 e5 65 48 
8b 04 25 80 b9 00 00 48 8b 80 70 03 00 00 48 8b 40 98 c9 48 c1 e8 02 83 
e0 01 c3 55 48 8b 87 70 03 00 00 48 89 e5 <48> 8b 40 a8 c9 c3 55 48 89 
e5 65 48 8b 04 25 80 b9 00 00 48 8b
Feb 16 00:40:17 localhost kernel: [23260.079644] RIP  
[<ffffffff81049f54>] kthread_data+0xb/0x11
Feb 16 00:40:17 localhost kernel: [23260.079647]  RSP 
<ffff88012b02f998>
Feb 16 00:40:17 localhost kernel: [23260.079648] CR2: ffffffffffffffa8
Feb 16 00:40:17 localhost kernel: [23260.079650] ---[ end trace 
bae1313833245123 ]---
Feb 16 00:40:17 localhost kernel: [23260.079652] Fixing recursive fault 
but reboot is needed!

---
Denys Fedoryshchenko, Network Engineer, Virtual ISP S.A.L.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
