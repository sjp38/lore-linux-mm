Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 182FB6B025E
	for <linux-mm@kvack.org>; Fri,  6 Jan 2017 00:22:41 -0500 (EST)
Received: by mail-qt0-f198.google.com with SMTP id t56so28888222qte.3
        for <linux-mm@kvack.org>; Thu, 05 Jan 2017 21:22:41 -0800 (PST)
Received: from mail-qt0-x243.google.com (mail-qt0-x243.google.com. [2607:f8b0:400d:c0d::243])
        by mx.google.com with ESMTPS id r18si1726315qtr.45.2017.01.05.21.22.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 Jan 2017 21:22:40 -0800 (PST)
Received: by mail-qt0-x243.google.com with SMTP id a29so4791502qtb.1
        for <linux-mm@kvack.org>; Thu, 05 Jan 2017 21:22:40 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <cbbf14fd-a1cc-2463-ba67-acd6d61e9db1@linaro.org>
References: <20161216165437.21612-1-rrichter@cavium.com> <CAKv+Gu_SmTNguC=tSCwYOL2kx-DogLvSYRZc56eGP=JhdrUOsA@mail.gmail.com>
 <c74d6ec6-16ba-dccc-3b0d-a8bedcb46dc5@linaro.org> <cbbf14fd-a1cc-2463-ba67-acd6d61e9db1@linaro.org>
From: Prakash B <bjsprakash.linux@gmail.com>
Date: Fri, 6 Jan 2017 10:52:39 +0530
Message-ID: <CACJhumfqWkXXpbJomjJ1jM5B3kG+1Jk9EvGWR50_u-AO1ySXfg@mail.gmail.com>
Subject: Re: [PATCH v3] arm64: mm: Fix NOMAP page initialization
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hanjun Guo <hanjun.guo@linaro.org>
Cc: Ard Biesheuvel <ard.biesheuvel@linaro.org>, Robert Richter <rrichter@cavium.com>, Mark Rutland <mark.rutland@arm.com>, Yisheng Xie <xieyisheng1@huawei.com>, David Daney <david.daney@cavium.com>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Russell King <linux@armlinux.org.uk>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, James Morse <james.morse@arm.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>

Hi Hanjun,


> a update here, tested on 4.9,
>
>  - Applied Ard's two patches only
>  - Applied Robert's patch only
>
> Both of them can work fine on D05 with NUMA enabled, which means
> boot ok and LTP MM stress test is passed.

It is  not related to this patch set.
LTP "cpuset01" test  crashes with latest 4.9,  4.10-rc1 and 4.10-rc2 kernels on
Thunderx 2S .  Do you see any such behaviour on D05.

Any idea what might be causing this issue.


  227.627546] cpuset01: page allocation stalls for 10096ms, order:0,
mode:0x24200ca(GFP_HIGHUSER_MOVABLE)
[  227.627586] CPU: 53 PID: 11017 Comm: cpuset01 Not tainted 4.9.04kNUMA+ #2
[  227.627591] Hardware name: www.cavium.com ThunderX Unknown/ThunderX
Unknown, BIOS 0.3 Aug 24 2016
[  227.627599] Call trace:
[  227.627623] [<ffff000008089f10>] dump_backtrace+0x0/0x238
[  227.627640] [<ffff00000808a16c>] show_stack+0x24/0x30
[  227.627656] [<ffff00000846fb50>] dump_stack+0x94/0xb4
[  227.627679] [<ffff0000081eb4f8>] warn_alloc+0x138/0x150
[  227.627686] [<ffff0000081ec0a4>] __alloc_pages_nodemask+0xb04/0xcf0
[  227.627697] [<ffff000008245988>] alloc_pages_vma+0xc8/0x270
[  227.627715] [<ffff00000821f604>] handle_mm_fault+0xc8c/0xfd8
[  227.627732] [<ffff00000809a488>] do_page_fault+0x2c0/0x368
[  227.627744] [<ffff0000080812ec>] do_mem_abort+0x6c/0xe0
[  227.627752] Exception stack(0xffff801f55823e00 to 0xffff801f55823f30)
[  227.627763] 3e00: 0000000000000000 0000ffff92682000
ffffffffffffffff 0000ffff9252b3e8
[  227.627774] 3e20: 0000000020000000 0000000000000000
000000000000a000 0000000000000003
[  227.627785] 3e40: 0000000000000022 ffffffffffffffff
0000000000000123 00000000000000de
[  227.627793] 3e60: ffff000008972000 0000000000000015
ffff801f55823e90 0000000000040900
[  227.627800] 3e80: 0000000000000000 ffff0000080836f0
0000000000000000 0000ffff92682000
[  227.627809] 3ea0: ffffffffffffffff 0000ffff92575d8c
0000000000000000 0000000000040900
[  227.627819] 3ec0: 0000ffff92682000 00000000000000f7
0000000000004fc0 0000000000000022
[  227.627828] 3ee0: 0000000000000000 0000000000000000
0000ffff925f5508 f7f7f7f7f7f7f7f7
[  227.627838] 3f00: 0000ffff92686ff0 0000000000002ab8
0101010101010101 0000000000000020
[  227.627847] 3f20: 0000000000000000 0000000000000000
[  227.627858] [<ffff000008083324>] el0_da+0x18/0x1c
[  227.627865] Mem-Info:
[  227.627899] active_anon:38613 inactive_anon:8174 isolated_anon:0
                active_file:25148 inactive_file:64173 isolated_file:0
                unevictable:742 dirty:0 writeback:0 unstable:0
                slab_reclaimable:29066 slab_unreclaimable:67304
                mapped:22876 shmem:2597 pagetables:1240 bounce:0
                free:65582521 free_pcp:1834 free_cma:0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
