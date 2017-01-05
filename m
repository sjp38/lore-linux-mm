Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 271FE6B0069
	for <linux-mm@kvack.org>; Thu,  5 Jan 2017 14:50:00 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id 5so1505711996pgi.2
        for <linux-mm@kvack.org>; Thu, 05 Jan 2017 11:50:00 -0800 (PST)
Received: from NAM03-DM3-obe.outbound.protection.outlook.com (mail-dm3nam03on0044.outbound.protection.outlook.com. [104.47.41.44])
        by mx.google.com with ESMTPS id d21si76827367pgh.276.2017.01.05.11.49.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 05 Jan 2017 11:49:59 -0800 (PST)
Date: Thu, 5 Jan 2017 20:49:44 +0100
From: Robert Richter <robert.richter@cavium.com>
Subject: Re: [PATCH 2/2] arm64: mm: enable CONFIG_HOLES_IN_ZONE for NUMA
Message-ID: <20170105194944.GY4930@rric.localdomain>
References: <1481706707-6211-1-git-send-email-ard.biesheuvel@linaro.org>
 <1481706707-6211-3-git-send-email-ard.biesheuvel@linaro.org>
 <20170104132831.GD18193@arm.com>
 <CAKv+Gu8MdpVDCSjfum7AMtbgR6cTP5H+67svhDSu6bkaijvvyg@mail.gmail.com>
 <20170104140223.GF18193@arm.com>
 <20170105112407.GU4930@rric.localdomain>
 <20170105120819.GH679@arm.com>
 <20170105122200.GV4930@rric.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <20170105122200.GV4930@rric.localdomain>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Will Deacon <will.deacon@arm.com>
Cc: Ard Biesheuvel <ard.biesheuvel@linaro.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Catalin Marinas <catalin.marinas@arm.com>, Andrew Morton <akpm@linux-foundation.org>, Hanjun Guo <hanjun.guo@linaro.org>, Yisheng Xie <xieyisheng1@huawei.com>, James Morse <james.morse@arm.com>

On 05.01.17 13:22:00, Robert Richter wrote:
> On 05.01.17 12:08:20, Will Deacon wrote:
> > I really can't see how the fix causes a crash, and I couldn't reproduce
> > it on any of my boards, nor could any of the Linaro folk afaik. Are you
> > definitely running mainline with just these two patches from Ard?
> 
> Yes, just both patches applied. Various other solutions were working.

I have retested the same kernel (v4.9 based) as before and now it
boots fine including rtc-efi device registration (it was crashing
there):

 rtc-efi rtc-efi: rtc core: registered rtc-efi as rtc0

There could be a difference in firmware and mem setup, though I also
downgraded the firmware to test it, but can't reproduce it anymore. I
could reliable trigger the crash the first time.

FTR the oops.

-Robert


Unable to handle kernel paging request at virtual address 20251000
pgd = ffff000009090000
[20251000] *pgd=0000010ffff90003
, *pud=0000010ffff90003
, *pmd=0000000fdc030003
, *pte=00e8832000250707

Internal error: Oops: 96000047 [#1] SMP
Modules linked in:
CPU: 49 PID: 1 Comm: swapper/0 Tainted: G        W       4.9.0.0.vanilla10-00002-g429605e9ab0a #1
Hardware name: www.cavium.com ThunderX CRB-2S/ThunderX CRB-2S, BIOS 0.3 Sep 13 2016
task: ffff800feee6bc00 task.stack: ffff800fec050000
PC is at 0x201ff820
LR is at 0x201fdfc0
pc : [<00000000201ff820>] lr : [<00000000201fdfc0>] pstate: 20000045
sp : ffff800fec053b70
x29: ffff800fec053bc0 x28: 0000000000000000 
x27: ffff000008ce3e08 x26: ffff000008c52568 
x25: ffff000008bf045c x24: ffff000008bdb828 
x23: 0000000000000000 x22: 0000000000000040 
x21: ffff800fec053bb8 x20: 0000000020251000 
x19: ffff800fec053c20 x18: 0000000000000000 
x17: 0000000000000000 x16: 00000000bbb67a65 
x15: ffffffffffffffff x14: ffff810016ea291c 
x13: ffff810016ea2181 x12: 0000000000000030 
x11: 0101010101010101 x10: 7f7f7f7f7f7f7f7f 
x9 : feff716475687163 x8 : ffffffffffffffff 
x7 : 83f0680000000000 x6 : 0000000000000000 
x5 : ffff800fc187aab9 x4 : 0002000000000000 
x3 : ffff800fec053bb8 x2 : 0000000000000000 
x1 : 83f0680000000000 x0 : 0000000020251000 

Process swapper/0 (pid: 1, stack limit = 0xffff800fec050020)
Stack: (0xffff800fec053b70 to 0xffff800fec054000)
3b60:                                   ffff800fec053c20 ffff800fec053c20
3b80: ffff800fec053c10 00000000201fd500 ffff000008e660d0 ffff800fec053c20
3ba0: ffff0000086eb954 ffff0000086eb930 ffff800fec053bc0 ffff0000086eb934
3bc0: ffff800fec053bf0 ffff000008c3eef4 ffff000008e602a0 ffff000008e602b0
3be0: ffff000008e60740 ffff000008e60768 ffff800fec053c30 ffff000008586c88
3c00: 00000000ffffffed ffff00000858023c ffff800fec053c30 ffff000008586c68
3c20: 0000000000000000 ffff000008e602b0 ffff800fec053c60 ffff0000085845d4
3c40: ffff000008e602b0 ffff000009049000 0000000000000000 ffff000008e60768
3c60: ffff800fec053ca0 ffff0000085848ac ffff000008e602b0 ffff000008e60310
3c80: ffff000008e60768 0000000000000000 ffff000008e4d000 ffff000008bdb828
3ca0: ffff800fec053cd0 ffff000008581e08 0000000000000000 ffff000008e60768
3cc0: ffff000008584788 0000000000000000 ffff800fec053d10 ffff000008583c30
3ce0: ffff000008e60768 ffff810fed477c00 ffff000008e4deb0 0000000000000000
3d00: ffff800fe54554a8 ffff810fed478e68 ffff800fec053d30 ffff000008583668
3d20: ffff000008e60768 ffff810fed477c00 ffff800fec053d70 ffff000008585430
3d40: ffff000008e60768 0000000000000000 ffff000008c3eed0 ffff000008e60768
3d60: ffff000008ef0000 0000000000000000 ffff800fec053d90 ffff000008586e3c
3d80: ffff000008e60740 0000000000000000 ffff800fec053dc0 ffff000008c3eec8
3da0: ffff000008c3eea8 ffff800fec050000 0000000000000000 0000000000000006
3dc0: ffff800fec053dd0 ffff000008082d94 ffff800fec053e40 ffff000008bf0d0c
3de0: 00000000000000f3 ffff000008ef0000 ffff000008c52578 0000000000000006
3e00: ffff000008ce3600 0000000000000000 ffff000008da2428 ffff000008ab2fa8
3e20: 0000000000000000 0000000600000006 ffff000008bf045c ffff000008bdb828
3e40: ffff800fec053ea0 ffff00000885e7a0 ffff00000885e788 0000000000000000
3e60: 0000000000000000 0000000000000000 0000000000000000 0000000000000000
3e80: 0000000000000000 0000000000000000 0000000000000000 0000000000000000
3ea0: 0000000000000000 ffff000008082b30 ffff00000885e788 0000000000000000
3ec0: 0000000000000000 0000000000000000 0000000000000000 0000000000000000
3ee0: 0000000000000000 0000000000000000 0000000000000000 0000000000000000
3f00: 0000000000000000 0000000000000000 0000000000000000 0000000000000000
3f20: 0000000000000000 0000000000000000 0000000000000000 0000000000000000
3f40: 0000000000000000 0000000000000000 0000000000000000 0000000000000000
3f60: 0000000000000000 0000000000000000 0000000000000000 0000000000000000
3f80: 0000000000000000 0000000000000000 0000000000000000 0000000000000000
3fa0: 0000000000000000 0000000000000000 0000000000000000 0000000000000000
3fc0: 0000000000000000 0000000000000005 0000000000000000 0000000000000000
3fe0: 0000000000000000 0000000000000000 0000000000000000 0000000000000000
Call trace:
Exception stack(0xffff800fec0539a0 to 0xffff800fec053ad0)
39a0: ffff800fec053c20 0001000000000000 ffff800fec053b70 00000000201ff820
39c0: 0000000000000000 ffff810000412890 ffff800fec0539f0 ffff000008405534
39e0: ffff810000412890 ffff810016e90e30 ffff800fec053a20 ffff00000840682c
3a00: 0000000000000000 ffff800fc168f880 0000000000000000 ffff00000840668c
3a20: ffff800fec053ac0 ffff0000084069f8 ffff00000903e7b0 0000000000000001
3a40: 0000000020251000 83f0680000000000 0000000000000000 ffff800fec053bb8
3a60: 0002000000000000 ffff800fc187aab9 0000000000000000 83f0680000000000
3a80: ffffffffffffffff feff716475687163 7f7f7f7f7f7f7f7f 0101010101010101
3aa0: 0000000000000030 ffff810016ea2181 ffff810016ea291c ffffffffffffffff
3ac0: 00000000bbb67a65 0000000000000000
[<00000000201ff820>] 0x201ff820
[<ffff000008c3eef4>] efi_rtc_probe+0x24/0x78
[<ffff000008586c88>] platform_drv_probe+0x60/0xc8
[<ffff0000085845d4>] driver_probe_device+0x26c/0x420
[<ffff0000085848ac>] __driver_attach+0x124/0x128
[<ffff000008581e08>] bus_for_each_dev+0x70/0xb0
[<ffff000008583c30>] driver_attach+0x30/0x40
[<ffff000008583668>] bus_add_driver+0x200/0x2b8
[<ffff000008585430>] driver_register+0x68/0x100
[<ffff000008586e3c>] __platform_driver_probe+0x84/0x128
[<ffff000008c3eec8>] efi_rtc_driver_init+0x20/0x28
[<ffff000008082d94>] do_one_initcall+0x44/0x138
[<ffff000008bf0d0c>] kernel_init_freeable+0x1ac/0x24c
[<ffff00000885e7a0>] kernel_init+0x18/0x110
[<ffff000008082b30>] ret_from_fork+0x10/0x20
Code: f9400000 d5033d9f d65f03c0 d5033e9f (f9000001) 
---[ end trace e420ef9636e3c9b2 ]---
Kernel panic - not syncing: Attempted to kill init! exitcode=0x0000000b

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
