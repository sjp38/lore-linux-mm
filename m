Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 339FC6B0069
	for <linux-mm@kvack.org>; Mon, 28 Nov 2016 04:38:55 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id c4so206361529pfb.7
        for <linux-mm@kvack.org>; Mon, 28 Nov 2016 01:38:55 -0800 (PST)
Received: from EUR01-VE1-obe.outbound.protection.outlook.com (mail-ve1eur01on0047.outbound.protection.outlook.com. [104.47.1.47])
        by mx.google.com with ESMTPS id a28si54286528pgn.295.2016.11.28.01.38.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 28 Nov 2016 01:38:54 -0800 (PST)
From: Wei Chen <Wei.Chen@arm.com>
Subject: Kernel Panics on Xen ARM64 for Domain0 and Guest
Date: Mon, 28 Nov 2016 09:38:46 +0000
Message-ID: <AM5PR0802MB2452C895A95FA378D6F3783D9E8A0@AM5PR0802MB2452.eurprd08.prod.outlook.com>
Content-Language: en-US
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
MIME-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "tj@kernel.org" <tj@kernel.org>, "zijun_hu@htc.com" <zijun_hu@htc.com>
Cc: "cl@linux.com" <cl@linux.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "xen-devel@lists.xenproject.org" <xen-devel@lists.xenproject.org>, Julien
 Grall <Julien.Grall@arm.com>, Kaly Xin <Kaly.Xin@arm.com>, Steve Capper <Steve.Capper@arm.com>

Hi,

I have found a commit in "PER-CPU MEMORY ALLOCATOR" will panic the
kernels that are runing on ARM64 Xen (include Domain0 and Guest).

commit 3ca45a46f8af8c4a92dd8a08eac57787242d5021
percpu: ensure the requested alignment is power of two

If I revert this commit, the Kernels can work properly on ARM64 Xen.

The following is the log:
[    0.385467] Detected PIPT I-cache on CPU1
[    0.391064] CPU1: Booted secondary processor [411fd072]
[    0.421553] Detected PIPT I-cache on CPU2
[    0.427149] CPU2: Booted secondary processor [411fd072]
[    0.457643] Detected PIPT I-cache on CPU3
[    0.463236] CPU3: Booted secondary processor [411fd072]
[    0.493737] Detected PIPT I-cache on CPU4
[    0.499331] CPU4: Booted secondary processor [411fd072]
[    0.529825] Detected PIPT I-cache on CPU5
[    0.535416] CPU5: Booted secondary processor [411fd072]
[    0.565918] Detected PIPT I-cache on CPU6
[    0.571513] CPU6: Booted secondary processor [411fd072]
[    0.602006] Detected PIPT I-cache on CPU7
[    0.607597] CPU7: Booted secondary processor [411fd072]
[    0.607645] Brought up 8 CPUs
[    0.676227] SMP: Total of 8 processors activated.
[    0.681009] CPU features: detected feature: 32-bit EL0 Support
[    0.687007] CPU: All CPU(s) started at EL1
[    0.691126] alternatives: patching kernel code
[    0.697383] devtmpfs: initialized
[    0.701439] DMI not present or invalid.
[    0.705290] clocksource: jiffies: mask: 0xffffffff max_cycles:
0xffffffff, max_idle_ns: 7645041785100000 ns
[    0.715243] pinctrl core: initialized pinctrl subsystem
[    0.720696] NET: Registered protocol family 16
[    0.725396] Unable to handle kernel NULL pointer dereference at
virtual address 00000000
[    0.733391] pgd =3D ffff000008bfd000
[    0.736852] [00000000] *pgd=3D000000823fffe003[    0.740941] Internal
error: Oops: 96000004 [#1] PREEMPT SMP
[    0.746577] CPU: 0 PID: 1 Comm: swapper/0 Tainted: G        W
4.9.0-rc1-00001-g3ca45a4 #69
[    0.755430] Hardware name: AMD Seattle (Rev.B0) Development Board
(Overdrive) (DT)
[    0.763067] task: ffff8001f6cb8000 task.stack: ffff8001f6ca4000
[    0.769060] PC is at bind_evtchn_to_irq+0x1c/0x108
[    0.773917] LR is at bind_evtchn_to_irqhandler+0x28/0x90
[    0.779298] pc : [<ffff000008483124>] lr : [<ffff000008483498>]
pstate: 60000045
[    0.786765] sp : ffff8001f6ca7cc0
[    0.790147] x29: ffff8001f6ca7cc0 [    0.793359] x28: 0000000000000000
[    0.796834]
[    0.798393] x27: ffff000008af8f60 [    0.801605] x26: ffff000008ac3d78
[    0.805077]
[    0.806639] x25: ffff000008a76fb0 [    0.809851] x24: ffff000008a804e4
[    0.813323]
[    0.814885] x23: ffff000008b726e8 [    0.818101] x22: ffff000008a123e8
[    0.821569]
[    0.823131] x21: 0000000000000001 [    0.826343] x20: ffff000008bd7000
[    0.829815]
[    0.831377] x19: ffff000008486608 [    0.834589] x18: 0000000000000000
[    0.838061]
[    0.839623] x17: 00000000105d2c2d [    0.842835] x16: 00000000deadbeef
[    0.846310]
[    0.847869] x15: ffff8001f6c2691c [    0.851081] x14: ffffffffffffffff
[    0.854553]
[    0.856115] x13: ffff8001f6c26150 [    0.859327] x12: 0000000000000008
[    0.862799]
[    0.864361] x11: 0101010101010101 [    0.867573] x10: 7f7f7f7f7f7f7f7f
[    0.871048]
[    0.872607] x9 : ffff8001fff2b458 [    0.875819] x8 : ffff7e0007d930c0
[    0.879291]
[    0.880853] x7 : 0000000000000000 [    0.884065] x6 : 0000000003ffffff
[    0.887537]
[    0.889099] x5 : 0000000000000000 [    0.892315] x4 : ffff000008b726e8
[    0.895783]
[    0.897345] x3 : ffff000008a123e8 [    0.900557] x2 : 0000000000000000
[    0.904029]
[    0.905591] x1 : ffff000008bd7000 [    0.908803] x0 : 0000000000000000
[    0.912275]
[    0.913837]
[    0.915401] Process swapper/0 (pid: 1, stack limit =3D 0xffff8001f6ca402=
0)
[    0.922171] Stack: (0xffff8001f6ca7cc0 to 0xffff8001f6ca8000)
[    0.927987] 7cc0: ffff8001f6ca7cf0 ffff000008483498 ffff000008486608
ffff000008bd7000
[    0.935889] 7ce0: 0000000000000000 0000000000000000 ffff8001f6ca7d30
ffff000008486a94
[    0.943784] 7d00: 0000000000000000 ffff000008bd7000 ffff8001f64c3000
ffff000008bd73b8
[    0.951683] 7d20: ffff000008b31000 ffff00000822de1c ffff8001f6ca7d50
ffff000008488218
[    0.959582] 7d40: ffff000008bd72b8 ffff000008bd73b8 ffff8001f6ca7d80
ffff000008aa8fc8
[    0.967484] 7d60: 0000000000000000 ffff000008bd7000 ffff8001f6ca7d80
ffff000008aa8e50
[    0.975379] 7d80: ffff8001f6ca7dd0 ffff000008a80c6c ffff8001f6ca4000
ffff000008aa8d70
[    0.983278] 7da0: ffff000008ac3da8 0000000000000000 ffff000008bae000
ffff000008a804e4
[    0.991177] 7dc0: 000000017ff07ff0 ffff000008a80c6c ffff8001f6ca7e40
ffff000008a80ea0
[    0.999081] 7de0: 000000000000012b ffff000008bae000 ffff000008ac3da8
0000000000000002
[    1.006975] 7e00: ffff000008af8f00 0000000000000000 ffff8001f6ca7e40
ffff0000089b7f10
[    1.014873] 7e20: 0000000200000002 0000000000000000 0000000000000000
ffff000008a76fb0
[    1.022772] 7e40: ffff8001f6ca7ea0 ffff000008815698 ffff000008815688
0000000000000000
[    1.030675] 7e60: 0000000000000000 0000000000000000 0000000000000000
0000000000000000
[    1.038570] 7e80: 0000000000000000 0000000000000000 0000000000000000
0000000000000000
[    1.046469] 7ea0: 0000000000000000 ffff000008082b30 ffff000008815688
0000000000000000
[    1.054367] 7ec0: 0000000000000000 0000000000000000 0000000000000000
0000000000000000
[    1.062270] 7ee0: 0000000000000000 0000000000000000 0000000000000000
0000000000000000
[    1.070165] 7f00: 0000000000000000 0000000000000000 0000000000000000
0000000000000000
[    1.078064] 7f20: 0000000000000000 0000000000000000 0000000000000000
0000000000000000
[    1.085962] 7f40: 0000000000000000 0000000000000000 0000000000000000
0000000000000000
[    1.093865] 7f60: 0000000000000000 0000000000000000 0000000000000000
0000000000000000
[    1.101760] 7f80: 0000000000000000 0000000000000000 0000000000000000
0000000000000000
[    1.109659] 7fa0: 0000000000000000 0000000000000000 0000000000000000
0000000000000000
[    1.117557] 7fc0: 0000000000000000 0000000000000005 0000000000000000
0000000000000000
[    1.125460] 7fe0: 0000000000000000 0000000000000000 0000000000000000
0000000000000000
[    1.133355] Call trace:
[    1.135876] Exception stack(0xffff8001f6ca7af0 to 0xffff8001f6ca7c20)
[    1.142383] 7ae0:                                   ffff000008486608
0001000000000000
[    1.150282] 7b00: ffff8001f6ca7cc0 ffff000008483124 ffff000008bd2cf0
ffff000008a1ad00
[    1.158180] 7b20: 0000000000000001 ffff8001f6c10190 ffff8001f6ca7c20
ffff000008158648
[    1.166079] 7b40: ffff000008baf000 00000000024080c0 0000000000000000
0000000000000000
[    1.173978] 7b60: ffff000008b25b18 ffff000008b25000 ffff000008a76fb0
0000000000000001
[    1.181880] 7b80: 00000000024080c0 0000000000000000 0000000000000000
ffff000008bd7000
[    1.189775] 7ba0: 0000000000000000 ffff000008a123e8 ffff000008b726e8
0000000000000000
[    1.197674] 7bc0: 0000000003ffffff 0000000000000000 ffff7e0007d930c0
ffff8001fff2b458
[    1.205573] 7be0: 7f7f7f7f7f7f7f7f 0101010101010101 0000000000000008
ffff8001f6c26150
[    1.213472] 7c00: ffffffffffffffff ffff8001f6c2691c 00000000deadbeef
00000000105d2c2d
[    1.221372] [<ffff000008483124>] bind_evtchn_to_irq+0x1c/0x108
[    1.227274] [<ffff000008483498>] bind_evtchn_to_irqhandler+0x28/0x90
[    1.233698] [<ffff000008486a94>] xb_init_comms+0x6c/0xf8
[    1.239078] [<ffff000008488218>] xs_init+0xa8/0x1d0
[    1.244028] [<ffff000008aa8fc8>] xenbus_init+0x258/0x2e4
[    1.249408] [<ffff000008a80c6c>] do_one_initcall+0x84/0x114
[    1.255050] [<ffff000008a80ea0>] kernel_init_freeable+0x1a4/0x244
[    1.261212] [<ffff000008815698>] kernel_init+0x10/0x100
[    1.266507] [<ffff000008082b30>] ret_from_fork+0x10/0x20
[    1.271889] Code: f90013f5 2a0003f5 f9414820 a90153f3 (f9400000)
[    1.278065] ---[ end trace 1a0c84ed669d59e3 ]---
[    1.282747] Kernel panic - not syncing: Attempted to kill init!
exitcode=3D0x0000000b
[    1.282747]
[    1.292025] SMP: stopping secondary CPUs
[    1.296045] ---[ end Kernel panic - not syncing: Attempted to kill
init! exitcode=3D0x0000000b


--
Regards,
Wei Chen
IMPORTANT NOTICE: The contents of this email and any attachments are confid=
ential and may also be privileged. If you are not the intended recipient, p=
lease notify the sender immediately and do not disclose the contents to any=
 other person, use it for any purpose, or store or copy the information in =
any medium. Thank you.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
