Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id BA1366B0038
	for <linux-mm@kvack.org>; Sat,  8 Oct 2016 08:14:48 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id o68so32229066qkf.3
        for <linux-mm@kvack.org>; Sat, 08 Oct 2016 05:14:48 -0700 (PDT)
Received: from mail-qk0-x241.google.com (mail-qk0-x241.google.com. [2607:f8b0:400d:c09::241])
        by mx.google.com with ESMTPS id o18si12069560qki.199.2016.10.08.05.14.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 08 Oct 2016 05:14:47 -0700 (PDT)
Received: by mail-qk0-x241.google.com with SMTP id n66so3965123qkf.0
        for <linux-mm@kvack.org>; Sat, 08 Oct 2016 05:14:47 -0700 (PDT)
Received: from [10.0.0.22] (modemcable020.227-83-70.mc.videotron.ca. [70.83.227.20])
        by smtp.gmail.com with ESMTPSA id u63sm8467120qkd.16.2016.10.08.05.14.46
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Sat, 08 Oct 2016 05:14:46 -0700 (PDT)
From: Jean-Francois Dagenais <jeff.dagenais@gmail.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: quoted-printable
Subject: help for random Padding overwritten
Message-Id: <FFB991A5-E3A4-48A1-9111-83F4F8319ADD@gmail.com>
Date: Sat, 8 Oct 2016 08:14:46 -0400
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

Hi guys!

I'll make this quick. I've followed other examples in the kernel to =
write a
small test DMA client driver. I expose a char device for accessing the =
data
copied from a BRAM block in PL to a dma_alloc_coherent buffer which I =
then
simple_read_from_buffer to the user.

This is using linux-xlnx on zedboard (zynq-7000). The xilinx-v2016.2 is =
up to
date with v4.4.11. Was using slab (default yocto config), switch to slub =
to help
debugging the problem.

After going past the fact that turning on kobject debugging will will =
cause OOPS
when doing: while modprobe uio; do modprobe uio -r; done; long enough. I =
have
finally got my char device driver to work. It is a platform_driver and =
it binds
using devicetree.

When I open the char file, I alloc, prepare buffer, submit and wait =
completion
before returning. I copy the allocated buffer to user on read(), then =
free
everything on close.

After (usually) many "hexdump -C /dev/mydevice0", running slabinfo -v =
will give
one of these:


<3>[  248.544034] BUG skbuff_head_cache (Not tainted): Padding =
overwritten. 0xde11ffe4-0xde11ffe7
<3>[  248.544095] =
--------------------------------------------------------------------------=
---
<3>[  248.544095]=20
<4>[  248.544171] Disabling lock debugging due to kernel taint
<3>[  248.544211] INFO: Slab 0xdffba3c0 objects=3D21 used=3D20 =
fp=3D0xde11f980 flags=3D0x4081
<4>[  248.544271] CPU: 0 PID: 715 Comm: kworker/0:1H Tainted: G    B     =
      4.4.11-jfd3.4.52-yocto-standard #57
<4>[  248.544332] Hardware name: Xilinx Zynq Platform
<4>[  248.544384] Workqueue: rpciod xs_udp_data_receive_workfn
<4>[  248.544454] [<c0018634>] (unwind_backtrace) from [<c0014750>] =
(show_stack+0x10/0x14)
<4>[  248.544524] [<c0014750>] (show_stack) from [<c025e954>] =
(dump_stack+0xa8/0xd4)
<4>[  248.544588] [<c025e954>] (dump_stack) from [<c01133f0>] =
(slab_err+0x84/0xa8)
<4>[  248.544641] [<c01133f0>] (slab_err) from [<c01136fc>] =
(slab_pad_check.part.4+0xd0/0x140)
<4>[  248.544704] [<c01136fc>] (slab_pad_check.part.4) from [<c01137f8>] =
(check_slab+0x8c/0x10c)
<4>[  248.544771] [<c01137f8>] (check_slab) from [<c011bb34>] =
(free_debug_processing+0xa0/0x374)
<4>[  248.544839] [<c011bb34>] (free_debug_processing) from [<c011be54>] =
(__slab_free+0x4c/0x424)
<4>[  248.544904] [<c011be54>] (__slab_free) from [<c0114e98>] =
(kmem_cache_free+0x214/0x21c)
<4>[  248.544972] [<c0114e98>] (kmem_cache_free) from [<c0413d78>] =
(skb_free_datagram+0x10/0x3c)
<4>[  248.545040] [<c0413d78>] (skb_free_datagram) from [<c0522790>] =
(xs_udp_data_receive_workfn+0xe8/0x1b0)
<4>[  248.545116] [<c0522790>] (xs_udp_data_receive_workfn) from =
[<c00405d0>] (process_one_work+0x198/0x42c)
<4>[  248.545186] [<c00405d0>] (process_one_work) from [<c00408ac>] =
(worker_thread+0x48/0x4b0)
<4>[  248.545253] [<c00408ac>] (worker_thread) from [<c0046fc8>] =
(kthread+0x104/0x11c)
<4>[  248.545316] [<c0046fc8>] (kthread) from [<c0010510>] =
(ret_from_fork+0x14/0x24)
<3>[  248.545374] Padding de11ff68: 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a =
5a 5a 5a 5a  ZZZZZZZZZZZZZZZZ
<3>[  248.545433] Padding de11ff78: 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a =
5a 5a 5a 5a  ZZZZZZZZZZZZZZZZ
<3>[  248.545492] Padding de11ff88: 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a =
5a 5a 5a 5a  ZZZZZZZZZZZZZZZZ
<3>[  248.545549] Padding de11ff98: 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a =
5a 5a 5a 5a  ZZZZZZZZZZZZZZZZ
<3>[  248.545607] Padding de11ffa8: 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a =
5a 5a 5a 5a  ZZZZZZZZZZZZZZZZ
<3>[  248.545665] Padding de11ffb8: 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a =
5a 5a 5a 5a  ZZZZZZZZZZZZZZZZ
<3>[  248.545722] Padding de11ffc8: 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a =
5a 5a 5a 5a  ZZZZZZZZZZZZZZZZ
<3>[  248.545780] Padding de11ffd8: 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a =
00 00 60 1f  ZZZZZZZZZZZZ..`.
<3>[  248.545839] FIX skbuff_head_cache: Restoring =
0xde11ff68-0xde11ffe7=3D0x5a

after a reboot, and removed DMA-API debug and many other debug features:

<3>[  191.164893] =
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D
<3>[  191.164951] BUG vm_area_struct (Tainted: G    B          ): =
Padding overwritten. 0xddca2fe4-0xddca2fe7
<3>[  191.164994] =
--------------------------------------------------------------------------=
---
<3>[  191.164994]=20
<3>[  191.165054] INFO: Slab 0xdffb1440 objects=3D15 used=3D15 fp=3D0x  =
(null) flags=3D0x0081
<4>[  191.165100] CPU: 1 PID: 1823 Comm: hexdump Tainted: G    B         =
  4.4.11-jfd3.4.52-yocto-standard #58
<4>[  191.165144] Hardware name: Xilinx Zynq Platform
<4>[  191.165168] Backtrace:=20
<4>[  191.165221] [<c0014838>] (dump_backtrace) from [<c0014a28>] =
(show_stack+0x18/0x1c)
<4>[  191.165263]  r6:00000000 r5:20070093 r4:c06fcc78 r3:dc8ba60b
<4>[  191.165326] [<c0014a10>] (show_stack) from [<c022bd4c>] =
(dump_stack+0x9c/0xb0)
<4>[  191.165380] [<c022bcb0>] (dump_stack) from [<c00ee318>] =
(slab_err+0x8c/0xa8)
<4>[  191.165409]  r6:df469000 r5:c06ee408 r4:dffb1440 r3:de4c6000
<4>[  191.165461] [<c00ee290>] (slab_err) from [<c00ee634>] =
(slab_pad_check.part.3+0xd8/0x148)
<4>[  191.165501]  r3:ddca2fe4 r2:c0615b88
<4>[  191.165530]  r6:df469000 r5:ddca2fe7 r4:ddca2fe8
<4>[  191.165575] [<c00ee55c>] (slab_pad_check.part.3) from [<c00ee738>] =
(check_slab+0x94/0x114)
<4>[  191.165615]  r9:00000000 r8:df469000 r7:df468400 r6:df469000 =
r5:00000001 r4:dffb1440
<4>[  191.165687] [<c00ee6a4>] (check_slab) from [<c00f49a0>] =
(free_debug_processing+0xac/0x370)
<4>[  191.165727]  r6:ddca2738 r5:dffb1440 r4:ddca2738
<4>[  191.165772] [<c00f48f4>] (free_debug_processing) from [<c00f4cb8>] =
(__slab_free+0x54/0x368)
<4>[  191.165813]  r10:de4c6028 r9:de4c6000 r8:dffb1440 r7:df469000 =
r6:ddca2738 r5:00010d00
<4>[  191.165873]  r4:dffb1440
<4>[  191.165905] [<c00f4c64>] (__slab_free) from [<c00f05a8>] =
(kmem_cache_free+0x1cc/0x1d0)
<4>[  191.165945]  r10:de4c6028 r9:de4c6000 r8:dffb1440 r7:00000001 =
r6:ddca2738 r5:de4c7e68
<4>[  191.166005]  r4:df469000
<4>[  191.166046] [<c00f03dc>] (kmem_cache_free) from [<c00d99b0>] =
(remove_vma+0x64/0x6c)
<4>[  191.166086]  r10:de836300 r9:00000001 r8:de72f478 r7:de72f440 =
r6:00000001 r5:de4a8e70
<4>[  191.166145]  r4:ddca2738
<4>[  191.166179] [<c00d994c>] (remove_vma) from [<c00dce88>] =
(exit_mmap+0x168/0x1f0)
<4>[  191.166219]  r5:00000022 r4:ddca2738
<4>[  191.166264] [<c00dcd20>] (exit_mmap) from [<c00237b4>] =
(mmput+0x48/0xd0)
<4>[  191.166293]  r6:b6f05798 r5:00000000 r4:de72f440
<4>[  191.166339] [<c002376c>] (mmput) from [<c00273f0>] =
(do_exit+0x280/0x958)
<4>[  191.166367]  r6:b6f05798 r5:00000000 r4:de836670 r3:00000000
<4>[  191.166417] [<c0027170>] (do_exit) from [<c0028a20>] =
(do_group_exit+0x44/0xc4)
<4>[  191.166455]  r7:000000f8
<4>[  191.166486] [<c00289dc>] (do_group_exit) from [<c0028ab8>] =
(__wake_up_parent+0x0/0x28)
<4>[  191.166526]  r6:b6f05798 r5:00000000 r4:00000001 r3:00000000
<4>[  191.166578] [<c0028aa0>] (SyS_exit_group) from [<c00107e0>] =
(ret_fast_syscall+0x0/0x3c)
<3>[  191.166625] Padding ddca2f60: 00 00 00 00 00 00 00 00 01 00 00 00 =
fc 03 00 00  ................
<3>[  191.166669] Padding ddca2f70: 21 c4 ff ff 5a 5a 5a 5a 5a 5a 5a 5a =
5a 5a 5a 5a  !...ZZZZZZZZZZZZ
<3>[  191.166713] Padding ddca2f80: 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a =
5a 5a 5a 5a  ZZZZZZZZZZZZZZZZ
<3>[  191.166755] Padding ddca2f90: 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a =
5a 5a 5a 5a  ZZZZZZZZZZZZZZZZ
<3>[  191.166798] Padding ddca2fa0: 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a =
5a 5a 5a 5a  ZZZZZZZZZZZZZZZZ
<3>[  191.166841] Padding ddca2fb0: 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a =
5a 5a 5a 5a  ZZZZZZZZZZZZZZZZ
<3>[  191.166883] Padding ddca2fc0: 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a =
5a 5a 5a 5a  ZZZZZZZZZZZZZZZZ
<3>[  191.166926] Padding ddca2fd0: 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a 5a =
5a 5a 5a 5a  ZZZZZZZZZZZZZZZZ
<3>[  191.166969] Padding ddca2fe0: 5a 5a 5a 5a 00 00 5c 1f              =
            ZZZZ..\.
<3>[  191.167011] FIX vm_area_struct: Restoring =
0xddca2f60-0xddca2fe7=3D0x5a

The slab and addresses mentioned are pretty random, but they tend to be =
around
0xdd... and 0xde....

Running a couple of more DMAs, then slabinfo -v will reproduce another =
error,
the only constant being the "00 00 60 1f" pattern. This pattern is =
pretty
consistent once booted. A reboot changes this pattern.

I've enabled way more tracing, trying who may have owned this chunk of =
RAM
before. Maybe they are still holding onto it even if it's free. Maybe a =
kref
counting error like a missing "_get"?

In desperation. I have looked for this pattern in /dev/mem (hexdump -C =
/dev/mem
|grep "00 00 5c 1f") and found it at physical 0x007437b0 and 0x042688f0.
Thinking being who is holding onto this value and copying it to the =
overwritten
padding area.

I'd like to stop messing around and debug this like a pro. What tools =
and/or
keywords and/or technique should I know and use here?

Thanks a million for the pointers! (ha, pointers...) /jfd=

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
