Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f182.google.com (mail-ob0-f182.google.com [209.85.214.182])
	by kanga.kvack.org (Postfix) with ESMTP id 062AC6B0038
	for <linux-mm@kvack.org>; Wed, 19 Aug 2015 08:14:55 -0400 (EDT)
Received: by obkg7 with SMTP id g7so2232245obk.3
        for <linux-mm@kvack.org>; Wed, 19 Aug 2015 05:14:54 -0700 (PDT)
Received: from mail-ob0-f173.google.com (mail-ob0-f173.google.com. [209.85.214.173])
        by mx.google.com with ESMTPS id a125si331684oig.88.2015.08.19.05.14.53
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 19 Aug 2015 05:14:53 -0700 (PDT)
Received: by obbwr7 with SMTP id wr7so2257567obb.2
        for <linux-mm@kvack.org>; Wed, 19 Aug 2015 05:14:53 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <55AFD8D0.9020308@samsung.com>
References: <1431698344-28054-1-git-send-email-a.ryabinin@samsung.com>
	<1431698344-28054-6-git-send-email-a.ryabinin@samsung.com>
	<CACRpkdaRJJjCXR=vK1M2YhR26JZfGoBB+jcqz8r2MhERfxRzqA@mail.gmail.com>
	<CAPAsAGy-r8Z2N09wKV+e0kLfbwxd-eWK6N5Xajsnqq9jfyWqcQ@mail.gmail.com>
	<CACRpkdZmHLMxosLXjyOPdkavo=UNzmTcHOLF5vV4cS1ULfbq6A@mail.gmail.com>
	<CAPAsAGw-iawTpjJh66rQN5fqBFT6UBZCcv2eKx7JTqCXzhzpsw@mail.gmail.com>
	<CACRpkdY2i2M27gP_fXawkFrC_GFgWaKr5rEn6d47refNPiEk=g@mail.gmail.com>
	<55AE56DB.4040607@samsung.com>
	<CACRpkdYaqK8upK-3b01JbO_y+sHnk4-Hm1MfvjSy0tKUkFREtQ@mail.gmail.com>
	<55AFD8D0.9020308@samsung.com>
Date: Wed, 19 Aug 2015 14:14:53 +0200
Message-ID: <CACRpkdaJVRuLTCh585rLEjua2TpnLsALhLdu0ma56TBA=C+EiQ@mail.gmail.com>
Subject: Re: [PATCH v2 5/5] arm64: add KASan support
From: Linus Walleij <linus.walleij@linaro.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <a.ryabinin@samsung.com>
Cc: Andrey Ryabinin <ryabinin.a.a@gmail.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Dmitry Vyukov <dvyukov@google.com>, Alexander Potapenko <glider@google.com>, David Keitel <dkeitel@codeaurora.org>, Arnd Bergmann <arnd@arndb.de>, Andrew Morton <akpm@linux-foundation.org>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Wed, Jul 22, 2015 at 7:54 PM, Andrey Ryabinin <a.ryabinin@samsung.com> wrote:

> So here is updated version:
>         git://github.com/aryabinin/linux.git kasan/arm_v0_1
>
> The code is still ugly in some places and it probably have some bugs.
> Lightly tested on exynos 5410/5420.

I compiled this for various ARM platforms and tested to boot.
I used GCC version 4.9.3 20150113 (prerelease) (Linaro).

I get these compilation warnings no matter what I compile,
I chose to ignore them:

WARNING: vmlinux.o(.meminit.text+0x2c):
Section mismatch in reference from the function kasan_pte_populate()
to the function
.init.text:kasan_alloc_block.constprop.7()
The function __meminit kasan_pte_populate() references
a function __init kasan_alloc_block.constprop.7().
If kasan_alloc_block.constprop.7 is only used by kasan_pte_populate then
annotate kasan_alloc_block.constprop.7 with a matching annotation.

WARNING: vmlinux.o(.meminit.text+0x98):
Section mismatch in reference from the function kasan_pmd_populate()
to the function
.init.text:kasan_alloc_block.constprop.7()
The function __meminit kasan_pmd_populate() references
a function __init kasan_alloc_block.constprop.7().
If kasan_alloc_block.constprop.7 is only used by kasan_pmd_populate then
annotate kasan_alloc_block.constprop.7 with a matching annotation.

These KASan outline tests run fine:

kasan test: kmalloc_oob_right out-of-bounds to right
kasan test: kmalloc_oob_left out-of-bounds to left
kasan test: kmalloc_node_oob_right kmalloc_node(): out-of-bounds to right
kasan test: kmalloc_large_oob_rigth kmalloc large allocation:
out-of-bounds to right
kasan test: kmalloc_oob_krealloc_more out-of-bounds after krealloc more
kasan test: kmalloc_oob_krealloc_less out-of-bounds after krealloc less
kasan test: kmalloc_oob_16 kmalloc out-of-bounds for 16-bytes access
kasan test: kmalloc_oob_in_memset out-of-bounds in memset
kasan test: kmalloc_uaf use-after-free
kasan test: kmalloc_uaf_memset use-after-free in memset
kasan test: kmalloc_uaf2 use-after-free after another kmalloc
kasan test: kmem_cache_oob out-of-bounds in kmem_cache_alloc

These two tests seems to not trigger KASan BUG()s, and seemse to
be like so on all hardware, so I guess it is this kind of test
that requires GCC 5.0:

kasan test: kasan_stack_oob out-of-bounds on stack
kasan test: kasan_global_oob out-of-bounds global variable


Hardware test targets:

Ux500 (ARMv7):

On Ux500 I get a real slow boot (as exepected) and after
enabling the test cases produce KASan warnings
expectedly.

MSM APQ8060 (ARMv7):

Also a real slow boot and the expected KASan warnings when
running the tests.

Integrator/AP (ARMv5):

This one mounted with an ARMv5 ARM926 tile. It boots nicely
(but takes forever) with KASan and run all test cases (!) just like
for the other platforms but before reaching userspace this happens:

Unable to handle kernel paging request at virtual address 00021144
pgd = c5a74000
[00021144] *pgd=00000000
Internal error: Oops: 5 [#1] PREEMPT ARM
Modules linked in:
CPU: 0 PID: 24 Comm: modprobe Tainted: G    B
4.2.0-rc2-77613-g11c2df68e4a8 #1
Hardware name: ARM Integrator/AP (Device Tree)
task: c69f8cc0 ti: c5a68000 task.ti: c5a68000
PC is at v4wbi_flush_user_tlb_range+0x10/0x4c
LR is at move_page_tables+0x320/0x46c
pc : [<c00182d0>]    lr : [<c00ce9d0>]    psr: 60000013
sp : c5a6bd78  ip : c5a70000  fp : 9f000000
r10: 9eaab000  r9 : ffaab000  r8 : 0093d34f
r7 : c5a782ac  r6 : c5a68000  r5 : 9effe000  r4 : c0900044
r3 : 00021000  r2 : c5a4c000  r1 : 9f000000  r0 : 9effe000
Flags: nZCv  IRQs on  FIQs on  Mode SVC_32  ISA ARM  Segment user
Control: 0005317f  Table: 05a74000  DAC: 00000015
Process modprobe (pid: 24, stack limit = 0xc5a68190)
Stack: (0xc5a6bd78 to 0xc5a6c000)
bd60:                                                       9f000000 00002000
bd80: 00000000 9f000000 c5a4c000 00000000 00000000 c5a4c020 c5a68000 c5a68004
bda0: c5a4c000 9effe000 00000000 c5a4c000 c59a6540 c5a4c004 c5a70034 c59a65cc
bdc0: 9effe000 00000000 00002000 c00f4558 00002000 00000000 00000000 9f000000
bde0: 9eaa9000 c5a70000 9eaab000 c5a4c04c 00000000 c5a4c000 00000000 00000000
be00: 00000000 00000000 00000000 0f4a4438 b0a5485b 8881364f c0910aec 00000000
be20: 00000000 00000000 c69f8cc0 0f4a4438 c0910aec 00000018 9f000000 c59a68c0
be40: c69f8cc0 c592db40 c59a6540 c592db50 9f000000 c59a68c0 c69f8cc0 00c00000
be60: c5a6be68 c015694c c59a6540 00000080 c5a4aa80 c59a65d8 c5e9bc00 c592db6c
be80: c6a0da00 c592db40 00000001 00000000 c59a6540 c00f4f10 00000000 00002000
bea0: 9f000000 c5a4c000 c69f8cc0 c00f5008 00000017 c5a6bec4 00000000 00000008
bec0: 9efff000 c00b5160 c7e937a0 c00a4684 00000000 c7e937a0 9efff000 c09089a8
bee0: c09089b0 c59a6540 c0908590 fffffff8 c59a65d4 c5a68000 c5a68004 c00f4b28
bf00: c59a65c8 00000001 00000018 c69f8cc0 c5a4ab60 00000018 c6a38000 c59a6540
bf20: 00000001 c59a65e8 c59a65cc c00f6fec c090476c 00000000 c59a65c8 0000038f
bf40: c5a4c028 c59a65c0 c59a65f0 c5a4c004 00000000 c69f8ec0 00000000 c6a38000
bf60: c5a11a00 c5a4ab60 00000000 00000000 ffffffff 00000000 00000000 c00f71a4
bf80: 00000000 ffffffff 00000000 c00361fc c5a11a00 c0036044 00000000 00000000
bfa0: 00000000 00000000 00000000 c000aa60 00000000 00000000 00000000 00000000
bfc0: 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
bfe0: 00000000 00000000 00000000 00000000 00000013 00000000 00002000 41000001
[<c00182d0>] (v4wbi_flush_user_tlb_range) from [<9f000000>] (0x9f000000)
Code: e592c020 e3cd3d7f e3c3303f e593300c (e5933144)
---[ end trace 7fa2f634c630ab6d ]---


Compaq iPAQ H3600 (ARMv4):

This is an ARMv4 machine, SA1100-based. It boots nicely
with KASan and run all test cases (!) just like for the other platforms
but before reaching userspace this happens:

Unable to handle kernel paging request at virtual address e3e57b43
pgd = c08e8000
[e3e57b43] *pgd=00000000
Internal error: Oops: 408eb003 [#1] PREEMPT ARM
Modules linked in:
CPU: 0 PID: 944 Comm: modprobe Tainted: G    B
4.2.0-rc2-77612-g66bb8b6c242c #1
Hardware name: Compaq iPAQ H3600
task: c14d4880 ti: c08dc000 task.ti: c08dc000
PC is at v4wb_flush_user_tlb_range+0x10/0x48
LR is at change_protection_range+0x3c8/0x464
pc : [<c001cb10>]    lr : [<c00c9d58>]    psr: 20000013
sp : c08dfd20  ip : c08e6000  fp : 00000000
r10: c08dc000  r9 : c08ea7c8  r8 : 00000001
r7 : 9f000000  r6 : 9f000000  r5 : c08ed800  r4 : c1ff834f
r3 : e3e579ff  r2 : c08ec000  r1 : 9f000000  r0 : 9effe000
Flags: nzCv  IRQs on  FIQs on  Mode SVC_32  ISA ARM  Segment user
Control: c08eb17f  Table: c08eb17f  DAC: 00000015
Process modprobe (pid: 944, stack limit = 0xc08dc190)
Stack: (0xc08dfd20 to 0xc08e0000)
fd20: 00000001 9f000000 9effffff c08ec000 00000181 c08dc004 c14bc050 c08ea7c0
fd40: c08dc000 c08e6000 9effe000 c08e6170 c0800d90 00000000 c08ec000 00118177
fd60: 9effe000 00000000 00118173 9f000000 c08e6000 c00c9f50 00000000 00000000
fd80: 00000000 0009effe 00000000 c00e9868 00000000 00000002 c08ef000 00000000
fda0: 00000000 c08ec000 c12d4000 c08ec004 c08e6034 c12d408c 00118177 9effe000
fdc0: 001b8000 c00f0a24 00118177 ffffa1d9 00000000 00100177 00000000 00000000
fde0: 00000000 00000000 00000000 c08ec000 00000000 00000000 00000000 00000000
fe00: 00000000 673bd3e6 80a09842 cd271319 c08087f8 00000000 00000000 00000000
fe20: c14d4880 673bd3e6 c08087f8 000003b0 9f000000 c08f0000 c14d4880 c0ace8c0
fe40: c12d4000 c0ace8d0 9f000000 c08f0000 c14d4880 00c00000 c08dfe60 c015474c
fe60: c12d4000 00000080 c08e5d20 c12d4098 c08f0d80 c0ace8ec c14bc000 c0ace8c0
fe80: 00000002 00000000 9f000000 00000000 c12d4000 c00f14dc 00000000 00002000
fea0: 9f000000 c08ec000 c14d4880 c00f15d4 00000017 c08dfec4 00000000 9efff000
fec0: 00000000 c00b0eb4 c1f38f00 c00a3590 00000000 c0801f28 c12d4000 c08dc000
fee0: c08dc004 fffffff8 c0801b10 c12d4094 00000000 c00f118c c12d4098 c12d4088
ff00: 00000001 c12d4001 000003b0 c14d4880 c08e5e00 000003b0 c1494300 c12d4000
ff20: 00000001 c12d40a8 c12d408c c00f35e8 c07fdd8c 00000000 c12d4088 0000038f
ff40: c08ec028 c12d4080 c12d40b0 c08ec004 00000000 c14d4a80 00000000 c1494300
ff60: c08db300 c08e5e00 00000000 00000000 ffffffff 00000000 00000000 c00f3778
ff80: 00000000 ffffffff 00000000 c0038f3c c08db300 c0038d40 00000000 00000000
ffa0: 00000000 00000000 00000000 c00108a0 00000000 00000000 00000000 00000000
ffc0: 00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000
ffe0: 00000000 00000000 00000000 00000000 00000013 00000000 e85b38dd 6e46c80d
[<c001cb10>] (v4wb_flush_user_tlb_range) from [<c08ec000>] (0xc08ec000)
Code: e592c020 e3cd3d7f e3c3303f e593300c (e5933144)
---[ end trace 66be5d28dde42c9f ]---
random: nonblocking pool is initialized

So it seems v4wb_flush_user_tlb_range+0x10/0x48 is the culprit
on these two systems. It is in arch/arm/mm/tlb-v4wb.S.

Uninstrumenting these files with ASAN_SANITIZE_tlb-v4wb.o := n does
not help.

I then tested on the Footbridge, another ARMv4 system, the oldest I have
SA110-based. This passes decompression and then you may *think* it hangs.
But it doesn't. It just takes a few minutes to boot with KASan
instrumentation, then all tests run fine also on this hardware.
The crash logs scroll by on the physical console.

They keep scrolling forever however, and are still scrolling as I
write this. I suspect some real memory usage bugs to be causing it,
as it is exercising some ages old code that didn't see much scrutiny
in recent years.


Yours,
Linus Walleij

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
