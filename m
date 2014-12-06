Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com [209.85.212.169])
	by kanga.kvack.org (Postfix) with ESMTP id D8A9E6B0032
	for <linux-mm@kvack.org>; Sat,  6 Dec 2014 00:13:30 -0500 (EST)
Received: by mail-wi0-f169.google.com with SMTP id r20so3130592wiv.4
        for <linux-mm@kvack.org>; Fri, 05 Dec 2014 21:13:30 -0800 (PST)
Received: from mail-wi0-x22d.google.com (mail-wi0-x22d.google.com. [2a00:1450:400c:c05::22d])
        by mx.google.com with ESMTPS id o7si618973wiy.107.2014.12.05.21.13.29
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 05 Dec 2014 21:13:29 -0800 (PST)
Received: by mail-wi0-f173.google.com with SMTP id r20so510546wiv.12
        for <linux-mm@kvack.org>; Fri, 05 Dec 2014 21:13:29 -0800 (PST)
MIME-Version: 1.0
Date: Sat, 6 Dec 2014 13:13:29 +0800
Message-ID: <CAD2bSJ8u7vQob3thKpJPzD+5yx667Acmva59ui+bSuP=fiWXWQ@mail.gmail.com>
Subject: Question kernel BUG at mm/internal.h:81!
From: yuan zhao <yuan.zhao138@gmail.com>
Content-Type: multipart/alternative; boundary=047d7b450b1e00e1e105098541ef
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Minchan Kim <minchan@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>, Linus Torvalds <torvalds@linux-foundation.org>

--047d7b450b1e00e1e105098541ef
Content-Type: text/plain; charset=UTF-8

>
> hi, all

    I use android kernel(version 3.10).  There is a BUG ON
at mm/internal.h:81!
bug on source code is at function, seems like page->_count <= 0. I need
your help to fix the problem.
/*
 * This is meant to be called as the FOLL_GET operation of
 * follow_page() and it must be called while holding the proper PT
 * lock while the pte (or pmd_trans_huge) is still mapping the page.
 */
static inline void get_page_foll(struct page *page)
{
if (unlikely(PageTail(page)))
/*
 * This is safe only because
 * __split_huge_page_refcount() can't run under
 * get_page_foll() because we hold the proper PT lock.
 */
__get_page_tail_foll(page, true);
else {
/*
 * Getting a normal page or the head of a compound page
 * requires to already have an elevated page->_count.
 */
VM_BUG_ON(atomic_read(&page->_count) <= 0);
atomic_inc(&page->_count);
}
}

    dmesg:
[ 3042.652160]{1} kernel BUG at mm/internal.h:81!
[ 3042.657135]{1} Internal error: Oops - BUG: 0 [#1] PREEMPT SMP ARM
[ 2885.312530]{1} u2d:I: handle_ep0 USB_REQ_SET_CONFIGURATION
[ 3042.663970]{1} Modules linked in:[ 3042.667663]{1}
[ 3042.667877]{1} CPU: 1 PID: 140 Comm: debuggerd Tainted: G    B
 3.10.0-gb7e125e #1
[ 3042.676940]{1} task: e3adc800 ti: e2e64000 task.ti: e2e64000
[ 3042.683288]{1} PC is at follow_page_mask+0x154/0x25c
[ 3042.688842]{1} LR is at memblock_is_memory+0x10/0x20
[ 3042.694427]{1} pc : [<c01d83c4>]    lr : [<c01e5148>]    psr: 60010013
[ 3042.694427]{1} sp : e2e65de8  ip : c0ae2f90  fp : e2c87340
[ 3042.707885]{1} r10: 00000000  r9 : 00000000  r8 : c15aff60
[ 3042.714050]{1} r7 : c156ae3c  r6 : 2b7fb79f  r5 : c6738160  r4 : 00000016
[ 3042.721649]{1} r3 : 00000000  r2 : 00000001  r1 : 2b7fb000  r0 : c15aff60
[ 3042.729248]{1} Flags: nZCv  IRQs on  FIQs on  Mode SVC_32  ISA ARM
 Segment user
[ 3042.737548]{1} Control: 10c5387d  Table: 2928406a  DAC: 00000015
[ 3042.744262]{1}
[ 3042.744262]{1} PC: 0xc01d8344:
[ 3042.749664]{1} 8344  e5983000 e3130902 0a000019 e598301c e5932010
e3520000 ca000000 e7f001f2
[ 3042.759124]{1} 8364  e5982010 e3520000 0a000000 e7f001f2 e598200c
e3720001 5a000000 e7f001f2
[ 3042.768585]{1} 8384  e2832010 e1921f9f e2811001 e1820f91 e3300000
1afffffa e288300c e1932f9f
[ 3042.778045]{1} 83a4  e2822001 e1831f92 e3310000 1afffffa ea000009
e5983010 e3530000 ca000000
[ 3042.787506]{1} 83c4  e7f001f2 e2883010 e1932f9f e2822001 e1831f92
e3310000 1afffffa e3140002
[ 3042.796966]{1} 83e4  0a00000a e35a0000 0a000006 e3160040 1a000004
e5983000 e3130010 1a000001
[ 3042.806426]{1} 8404  e1a00008 ebffa8f9 e1a00008 ebffb5d3 e3140040
0a000011 e5953028 e3130a02
[ 3042.815917]{1} 8424  0a00000e e5983004 e3530000 0a00000b e3a00000
e1a01008 eb05a3db e3500000
[ 3042.825378]{1}
[ 3042.825378]{1} LR: 0xc01e50c8:
[ 3042.830017]{2} modem: zsp img load 0x1600000 byte.
[ 3042.836090]{1} 50c8  c095832c e1a03000 e1a02001 e59f0004 e1a01003
eaffff67 c095831c e1a03000
[ 3042.845550]{1} 50e8  e1a02001 e59f0004 e1a01003 eaffff61 c095831c
e59f3008 e5933010 e5930000
[ 3042.854980]{1} 5108  e12fff1e c0958318 e59f301c e5932004 e5933010
e2422001 e0831182 e7933182
[ 3042.864410]{1} 5128  e5910004 e0800003 e12fff1e c0958318 e1a01000
e59f0010 e92d4008 ebfffc7e
[ 3042.873840]{1} 5148  e2900001 13a00001 e8bd8008 c095831c e92d4070
e1a04000 e59f505c e1a06001
[ 3042.889709]{2} modem: run modem 14 time(s).
[ 3042.883270]{1} 5168  e1a01004 e2850004 ebfffc73 e3700001 03a00000
08bd8070 e5953010 e0832180
[ 3042.897369]{1} 5188  e7933180 e1530004 8a000009 e5920004 e0833000
e1e00004 e1560000 90844006
[ 3042.906799]{1} 51a8  80844000 e1530004 33a00000 23a00001 e8bd8070
e3a00000 e8bd8070 c0958318
[ 3042.916229]{1}
[ 3042.916229]{1} SP: 0xe2e65d68:
[ 3042.921569]{1} 5d68  00000000 00000000 00000101 e3171000 00000182
c01d8c54 e2e7d580 c0168bec
[ 3042.930999]{1} 5d88  00000000 c01d83c8 00000000 c000d718 00000000
c000d4ac c15aff60 2b7fb000
[ 3042.940429]{1} 5da8  00000001 00000000 00000016 c6738160 2b7fb79f
c156ae3c c15aff60 00000000
[ 3042.949890]{1} 5dc8  00000000 e2c87340 c0ae2f90 e2e65de8 c01e5148
c01d83c4 60010013 ffffffff
[ 3042.959320]{1} 5de8  c6738160 b6382fe0 00000000 00000016 d0f10d80
00000016 00000000 c01d9620
[ 3042.968749]{1} 5e08  547c2e1e 06146623 00000001 00000001 e2e64000
00000010 06146623 00000000
[ 3042.978179]{1} 5e28  00000011 e2e65ec4 b6382fe0 b6382fe0 00000004
e2c87340 e2e65ec4 e2c8737c
[ 3042.987609]{1} 5e48  d0f10d80 c01d97b8 00000016 e2e65e6c e2e65e68
00000000 00000000 c01f5a9c
[ 3042.997070]{1}
[ 3042.997070]{1} IP: 0xc0ae2f10:
[ 3043.002410]{1} 2f10  00000000 00000000 00000000 00000000 00000000
00000000 00000000 00000000
[ 3043.011840]{1} 2f30  00000000 00000000 00000000 00000000 00000000
00000000 00000000 00000000
[ 3043.021270]{1} 2f50  00000000 00000000 00000000 00000000 00000000
00000000 00000000 00000000
[ 3043.030731]{1} 2f70  00000000 00000000 00000000 00000000 00000000
00000000 00000000 00000001
[ 3043.040161]{1} 2f90  06400000 39000000 2b800000 13c00000 00000000
00000000 00000000 00000000
[ 3043.049591]{1} 2fb0  00000000 00000000 00000000 00000000 00000000
00000000 00000000 00000000
[ 3043.059020]{1} 2fd0  00000000 00000000 00000000 00000000 00000000
00000000 00000000 00000000
[ 3043.068450]{1} 2ff0  00000000 00000000 00000000 00000000 00000000
00000000 00000000 00000000
[ 3043.077880]{1}
[ 3043.077880]{1} FP: 0xe2c872c0:
[ 3043.083251]{1} 72c0  00000000 00000000 00000012 00000000 0000001a
c095ab6c 00000007 00000000
[ 3043.092681]{1} 72e0  00001d17 00000000 00000000 00000000 0000008d
00000000 00000000 00000000
[ 3043.102111]{1} 7300  d9739200 da20ecc0 00000000 00000000 00000004
00000000 00000000 00000000
[ 3043.111541]{1} 7320  22801000 00000020 00000000 00000000 44000480
02084010 02001004 00000000
[ 3043.120971]{1} 7340  c6738160 dbdd98a8 c6738160 c00150b0 c01dc500
b6f5f000 bf000000 00000000
[ 3043.130401]{1} 7360  b6f5f000 bed67000 ddd4c000 0000000c 00000001
00000062 00330033 00000001
[ 3043.139862]{1} 7380  0f5f0f5f e2c87384 e2c87384 e2c8738c e2c8738c
0000012b 00000c0c 00000cfb
[ 3043.149291]{1} 73a0  00000000 00000000 0000027e 00000133 00000022
00000000 0000000a b6f5d000
[ 3043.158721]{1}
[ 3043.158721]{1} R0: 0xc15afee0:
[ 3043.164062]{1} fee0  00080068 dbef9041 0006272f 00000000 00000001
c11f9c14 c13b3914 00000000
[ 3043.173492]{1} ff00  00080078 e35e0be1 000000b4 00000000 00000001
c122c5f4 c15aff34 00000000
[ 3043.182922]{1} ff20  00080078 e35e06e1 00000079 00000000 00000001
c15aff14 c11525d4 00000000
[ 3043.192352]{1} ff40  00000a20 e42f616c 00000001 ffffffff 00000002
c111e1b4 c111e274 e3d3c140
[ 3043.201782]{1} ff60  00000604 00000000 00000000 ffffffff 00000000
e1f59da0 c16dfc74 00000000
[ 3043.211242]{1} ff80  00000400 00000000 00000000 ffffffff 00000001
c15aff94 c15aff94 00000000
[ 3043.220672]{1} ffa0  00000400 00000000 00000000 ffffffff 00000001
c15affb4 c15affb4 00000000
[ 3043.230102]{1} ffc0  00000400 00000000 00000000 ffffffff 00000001
c15affd4 c15affd4 00000000
[ 3043.239532]{1}
[ 3043.239532]{1} R5: 0xc67380e0:
[ 3043.244873]{1} 80e0  00000000 00000000 00000000 c67380ec c67380ec
00000000 00000000 0005ef0e
[ 3043.254302]{1} 8100  00000000 00000000 5ef0f000 5f00c000 df52d3c8
c67380b0 c6738069 df52d3d8
[ 3043.263732]{1} 8120  c67380c0 00000000 cb3b5c00 0000079f 00200073
00000000 00000000 00000000
[ 3043.273162]{1} 8140  00000000 d3d0a608 d3d0a608 c9f86820 00000000
0005ef0f 00000000 00000000
[ 3043.282592]{1} 8160  b6285000 b6383000 dbeb52c0 00000000 dbeb52d0
00000000 00000000 b6285000
[ 3043.292022]{1} 8180  e2c87340 0000079f 10220051 ca480975 00000000
d734318c 000000fd c673819c
[ 3043.301452]{1} 81a0  c673819c 00000000 c0976080 00000000 c2e21600
e1574400 40092000 40093000
[ 3043.310882]{1} 81c0  dbde5948 d96a6528 d96a6539 00000000 00000000
00000000 e2c86700 0000079f
[ 3043.320343]{1}
[ 3043.320343]{1} R7: 0xc156adbc:
[ 3043.325683]{1} adbc  00000000 00000000 00000000 00000000 ffffffff
00000001 00100100 00200200
[ 3043.335113]{1} addc  00000000 00000000 00000000 00000000 ffffffff
00000000 00100100 00200200
[ 3043.344543]{1} adfc  00000000 00000000 00000000 00000000 ffffffff
00000001 00100100 00200200
[ 3043.353973]{1} ae1c  01200120 00000000 00000000 00000000 ffffffff
00000001 00100100 00200200
[ 3043.363403]{1} ae3c  004e004d 00000000 00000000 00000000 ffffffff
00000001 00100100 00200200
[ 3043.372833]{1} ae5c  00000000 00000000 00000000 00000000 ffffffff
00000001 00100100 00200200
[ 3043.382263]{1} ae7c  00000000 00000000 00000000 00000000 ffffffff
00000001 00100100 00200200
[ 3043.391693]{1} ae9c  00000000 00000000 00000000 00000000 ffffffff
00000001 00100100 00200200
[ 3043.401153]{1}
[ 3043.401153]{1} R8: 0xc15afee0:
[ 3043.406494]{1} fee0  00080068 dbef9041 0006272f 00000000 00000001
c11f9c14 c13b3914 00000000
[ 3043.415924]{1} ff00  00080078 e35e0be1 000000b4 00000000 00000001
c122c5f4 c15aff34 00000000
[ 3043.425354]{1} ff20  00080078 e35e06e1 00000079 00000000 00000001
c15aff14 c11525d4 00000000
[ 3043.434783]{1} ff40  00000a20 e42f616c 00000001 ffffffff 00000002
c111e1b4 c111e274 e3d3c140
[ 3043.444213]{1} ff60  00000604 00000000 00000000 ffffffff 00000000
e1f59da0 c16dfc74 00000000
[ 3043.453643]{1} ff80  00000400 00000000 00000000 ffffffff 00000001
c15aff94 c15aff94 00000000
[ 3043.463073]{1} ffa0  00000400 00000000 00000000 ffffffff 00000001
c15affb4 c15affb4 00000000
[ 3043.472503]{1} ffc0  00000400 00000000 00000000 ffffffff 00000001
c15affd4 c15affd4 00000000
[ 3043.481933]{1} Process debuggerd (pid: 140, stack limit = 0xe2e64238)
[ 3043.489135]{1} Stack: (0xe2e65de8 to 0xe2e66000)
[ 3043.494293]{1} 5de0:                   c6738160 b6382fe0 00000000
00000016 d0f10d80 00000016
[ 3043.503723]{1} 5e00: 00000000 c01d9620 547c2e1e 06146623 00000001
00000001 e2e64000 00000010
[ 3043.513153]{1} 5e20: 06146623 00000000 00000011 e2e65ec4 b6382fe0
b6382fe0 00000004 e2c87340
[ 3043.522583]{1} 5e40: e2e65ec4 e2c8737c d0f10d80 c01d97b8 00000016
e2e65e6c e2e65e68 00000000
[ 3043.532012]{1} 5e60: 00000000 c01f5a9c 00000000 00000000 00000001
e2c87340 e2e65ec4 b6382fe0
[ 3043.541442]{1} 5e80: d0f10d80 00000004 e2e64000 00000000 b6382fe0
c01d98d8 00000004 00000000
[ 3043.550872]{1} 5ea0: bedd1f34 00000001 00000001 bedd1f34 b6382fe0
c01499f8 00000000 b6382fe0
[ 3043.560302]{1} 5ec0: bedd1f34 00000000 d0f10d80 c0149b58 e2d1e9c8
00000002 e2ce1410 00000000
[ 3043.569732]{1} 5ee0: e2e65f80 00000000 00000000 c01f6be8 00000000
00000000 00000000 e2e65f00
[ 3043.579162]{1} 5f00: bedd1934 00000001 b6fbb951 00000006 bedd1994
00000012 00000000 00000000
[ 3043.588592]{1} 5f20: 00000000 00000000 00000000 00000000 d0f10d80
e2e64000 00000001 00000008
[ 3043.598052]{1} 5f40: b6382fe0 00000000 e2e65f84 c0166c54 00000003
60010013 00000000 00000000
[ 3043.607482]{1} 5f60: b6fbba2c d0f10d80 00000000 00000001 bedd1f34
b6382fe0 e2e64000 00000000
[ 3043.616912]{1} 5f80: b6fbba08 c01499b0 bedd1f34 b6382fe0 b63830e0
b6f84394 0000001a c000d984
[ 3043.626342]{1} 5fa0: 00000000 c000d800 b6382fe0 b63830e0 00000001
00002c46 b6382fe0 bedd1f34
[ 3043.635772]{1} 5fc0: b6382fe0 b63830e0 b6f84394 0000001a 00002c46
00000003 b6fbba02 b6fbba08
[ 3043.645202]{1} 5fe0: bedd23b8 bedd1f30 b6f596f4 b6f55128 80010010
00000001 00000000 00000000
[ 3043.654632]{1} [<c01d83c4>] (follow_page_mask+0x154/0x25c) from
[<c01d9620>] (__get_user_pages+0x34c/0x430)
[ 3043.665527]{1} [<c01d9620>] (__get_user_pages+0x34c/0x430) from
[<c01d97b8>] (__access_remote_vm+0x68/0x10c)
[ 3043.676513]{1} [<c01d97b8>] (__access_remote_vm+0x68/0x10c) from
[<c01d98d8>] (access_process_vm+0x44/0x58)
[ 3043.687408]{1} [<c01d98d8>] (access_process_vm+0x44/0x58) from
[<c01499f8>] (generic_ptrace_peekdata+0x1c/0x50)
[ 3043.698669]{1} [<c01499f8>] (generic_ptrace_peekdata+0x1c/0x50) from
[<c0149b58>] (ptrace_request+0xf8/0x588)
[ 3043.709777]{1} [<c0149b58>] (ptrace_request+0xf8/0x588) from
[<c01499b0>] (SyS_ptrace+0x4c8/0x4f4)
[ 3043.719787]{1} [<c01499b0>] (SyS_ptrace+0x4c8/0x4f4) from [<c000d800>]
(ret_fast_syscall+0x0/0x30)
[ 3043.729797]{1} Code: ea000009 e5983010 e3530000 ca000000 (e7f001f2)
[ 3043.736877]{1} ---[ end trace 1cea5be63dfbfc6c ]---
[ 3043.742340]{1} Kernel panic - not syncing: Fatal exception
[ 3043.742340]{2} CPU2: stopping
[ 3043.742370]{2} CPU: 2 PID: 12442 Comm: emsd Tainted: G    B D
 3.10.0-gb7e125e #1
[ 3043.742370]{2} [<c0012bc0>] (unwind_backtrace+0x0/0xe0) from
[<c0010b58>] (show_stack+0x10/0x14)
[ 3043.742401]{2} [<c0010b58>] (show_stack+0x10/0x14) from [<c0012030>]
(handle_IPI+0xc8/0x1a8)
[ 3043.742401]{2} [<c0012030>] (handle_IPI+0xc8/0x1a8) from [<c0008454>]
(gic_handle_irq+0x50/0x58)
[ 3043.742401]{2} [<c0008454>] (gic_handle_irq+0x50/0x58) from [<c000d400>]
(__irq_svc+0x40/0x70)
[ 3043.742431]{2} Exception stack(0xca489e38 to 0xca489e80)
[ 3043.742431]{2} 9e20:
  00000001 00000001
[ 3043.742431]{2} 9e40: 00000001 fefdeb24 c0926918 c184c0c0 c184c0c4
c0926450 00000001 fe0a2b24
[ 3043.742462]{2} 9e60: 00000005 c1855100 00000001 ca489e80 c0187580
c0187560 00010013 ffffffff
[ 3043.742462]{2} [<c000d400>] (__irq_svc+0x40/0x70) from [<c0187560>]
(smp_call_function_many+0x260/0x2b8)
[ 3043.742492]{2} [<c0187560>] (smp_call_function_many+0x260/0x2b8) from
[<c01875e8>] (on_each_cpu_mask+0x30/0x84)
[ 3043.742492]{2} [<c01875e8>] (on_each_cpu_mask+0x30/0x84) from
[<c01876d8>] (on_each_cpu_cond+0x9c/0xd0)
[ 3043.742492]{2} [<c01876d8>] (on_each_cpu_cond+0x9c/0xd0) from
[<c021d818>] (invalidate_bh_lrus+0x20/0x2c)
[ 3043.742523]{2} [<c021d818>] (invalidate_bh_lrus+0x20/0x2c) from
[<c02240ec>] (kill_bdev+0x1c/0x30)
[ 3043.742523]{2} [<c02240ec>] (kill_bdev+0x1c/0x30) from [<c02246b0>]
(__blkdev_put+0x98/0x14c)
[ 3043.742553]{2} [<c02246b0>] (__blkdev_put+0x98/0x14c) from [<c02248a0>]
(blkdev_close+0x18/0x20)
[ 3043.742553]{2} [<c02248a0>] (blkdev_close+0x18/0x20) from [<c01f7150>]
(__fput+0xe8/0x1ec)
[ 3043.742584]{2} [<c01f7150>] (__fput+0xe8/0x1ec) from [<c0159478>]
(task_work_run+0xb8/0xd0)
[ 3043.742584]{2} [<c0159478>] (task_work_run+0xb8/0xd0) from [<c0010724>]
(do_work_pending+0x80/0x94)
[ 3043.742584]{2} [<c0010724>] (do_work_pending+0x80/0x94) from
[<c000d840>] (work_pending+0xc/0x20)
[ 3043.742614]{3} CPU3: stopping
[ 3043.742614]{3} CPU: 3 PID: 0 Comm: swapper/3 Tainted: G    B D
 3.10.0-gb7e125e #1
[ 3043.742614]{3} [<c0012bc0>] (unwind_backtrace+0x0/0xe0) from
[<c0010b58>] (show_stack+0x10/0x14)
[ 3043.742645]{3} [<c0010b58>] (show_stack+0x10/0x14) from [<c0012030>]
(handle_IPI+0xc8/0x1a8)
[ 3043.742645]{3} [<c0012030>] (handle_IPI+0xc8/0x1a8) from [<c0008454>]
(gic_handle_irq+0x50/0x58)
[ 3043.742675]{3} [<c0008454>] (gic_handle_irq+0x50/0x58) from [<c000d400>]
(__irq_svc+0x40/0x70)
[ 3043.742675]{3} Exception stack(0xe447ff98 to 0xe447ffe0)
[ 3043.742675]{3} ff80:
  c1852908 00000000
[ 3043.742675]{3} ffa0: 001e4dfa c0019580 e447e000 e447e000 10c0387d
c0689f58 0640406a 410fc075
[ 3043.742706]{3} ffc0: 00000000 00000000 00000000 e447ffe0 c0019590
c0019598 a00d0013 ffffffff
[ 3043.742706]{3} [<c000d400>] (__irq_svc+0x40/0x70) from [<c0019598>]
(comip_wfi_do+0x18/0x1c)
[ 3043.742736]{3} [<c0019598>] (comip_wfi_do+0x18/0x1c) from [<c000e47c>]
(arch_cpu_idle+0x18/0x2c)
[ 3043.742736]{3} [<c000e47c>] (arch_cpu_idle+0x18/0x2c) from [<c017a8c8>]
(cpu_startup_entry+0x1bc/0x228)
[ 3043.742736]{3} [<c017a8c8>] (cpu_startup_entry+0x1bc/0x228) from
[<06a13084>] (0x6a13084)
[ 3043.742767]{0} CPU0: stopping
[ 3043.742767]{0} CPU: 0 PID: 0 Comm: swapper/0 Tainted: G    B D
 3.10.0-gb7e125e #1
[ 3043.742767]{0} [<c0012bc0>] (unwind_backtrace+0x0/0xe0) from
[<c0010b58>] (show_stack+0x10/0x14)
[ 3043.742797]{0} [<c0010b58>] (show_stack+0x10/0x14) from [<c0012030>]
(handle_IPI+0xc8/0x1a8)
[ 3043.742797]{0} [<c0012030>] (handle_IPI+0xc8/0x1a8) from [<c0008454>]
(gic_handle_irq+0x50/0x58)
[ 3043.742797]{0} [<c0008454>] (gic_handle_irq+0x50/0x58) from [<c000d400>]
(__irq_svc+0x40/0x70)
[ 3043.742828]{0} Exception stack(0xc0909f68 to 0xc0909fb0)
[ 3043.742828]{0} 9f60:                   c1837908 00000000 002f1012
c0019580 c0908000 c0908000
[ 3043.742828]{0} 9f80: c08fdbe8 c0689f58 0640406a 410fc075 00000000
00000000 00000000 c0909fb0
[ 3043.742858]{0} 9fa0: c0019590 c0019598 a0010013 ffffffff
[ 3043.742858]{0} [<c000d400>] (__irq_svc+0x40/0x70) from [<c0019598>]
(comip_wfi_do+0x18/0x1c)
[ 3043.742858]{0} [<c0019598>] (comip_wfi_do+0x18/0x1c) from [<c000e47c>]
(arch_cpu_idle+0x18/0x2c)
[ 3043.742889]{0} [<c000e47c>] (arch_cpu_idle+0x18/0x2c) from [<c017a8c8>]
(cpu_startup_entry+0x1bc/0x228)
[ 3043.742889]{0} [<c017a8c8>] (cpu_startup_entry+0x1bc/0x228) from
[<c08b77b0>] (start_kernel+0x2c4/0x324)

--047d7b450b1e00e1e105098541ef
Content-Type: text/html; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

<div dir=3D"ltr"><div class=3D"gmail_extra"><div class=3D"gmail_quote"><blo=
ckquote class=3D"gmail_quote" style=3D"margin:0px 0px 0px 0.8ex;border-left=
-width:1px;border-left-color:rgb(204,204,204);border-left-style:solid;paddi=
ng-left:1ex"><span class=3D""><font color=3D"#888888">hi, all</font></span>=
</blockquote><div>=C2=A0 =C2=A0 I use android kernel(version 3.10).=C2=A0 T=
here is a BUG ON at=C2=A0mm/internal.h:81!</div><div>bug on source code is =
at function, seems like page-&gt;_count &lt;=3D 0. I need your help to fix =
the problem.</div><div><div>/*</div><div>=C2=A0* This is meant to be called=
 as the FOLL_GET operation of</div><div>=C2=A0* follow_page() and it must b=
e called while holding the proper PT</div><div>=C2=A0* lock while the pte (=
or pmd_trans_huge) is still mapping the page.</div><div>=C2=A0*/</div><div>=
static inline void get_page_foll(struct page *page)</div><div>{</div><div><=
span class=3D"" style=3D"white-space:pre">	</span>if (unlikely(PageTail(pag=
e)))</div><div><span class=3D"" style=3D"white-space:pre">		</span>/*</div>=
<div><span class=3D"" style=3D"white-space:pre">		</span> * This is safe on=
ly because</div><div><span class=3D"" style=3D"white-space:pre">		</span> *=
 __split_huge_page_refcount() can&#39;t run under</div><div><span class=3D"=
" style=3D"white-space:pre">		</span> * get_page_foll() because we hold the=
 proper PT lock.</div><div><span class=3D"" style=3D"white-space:pre">		</s=
pan> */</div><div><span class=3D"" style=3D"white-space:pre">		</span>__get=
_page_tail_foll(page, true);</div><div><span class=3D"" style=3D"white-spac=
e:pre">	</span>else {</div><div><span class=3D"" style=3D"white-space:pre">=
		</span>/*</div><div><span class=3D"" style=3D"white-space:pre">		</span> =
* Getting a normal page or the head of a compound page</div><div><span clas=
s=3D"" style=3D"white-space:pre">		</span> * requires to already have an el=
evated page-&gt;_count.</div><div><span class=3D"" style=3D"white-space:pre=
">		</span> */</div><div><span class=3D"" style=3D"white-space:pre">		</spa=
n>VM_BUG_ON(atomic_read(&amp;page-&gt;_count) &lt;=3D 0);</div><div><span c=
lass=3D"" style=3D"white-space:pre">		</span>atomic_inc(&amp;page-&gt;_coun=
t);</div><div><span class=3D"" style=3D"white-space:pre">	</span>}</div><di=
v>}</div></div><div><br></div><div>=C2=A0 =C2=A0 dmesg:</div><div><div>[ 30=
42.652160]{1} kernel BUG at mm/internal.h:81!</div><div>[ 3042.657135]{1} I=
nternal error: Oops - BUG: 0 [#1] PREEMPT SMP ARM</div><div>[ 2885.312530]{=
1} u2d:I: handle_ep0 USB_REQ_SET_CONFIGURATION</div><div>[ 3042.663970]{1} =
Modules linked in:[ 3042.667663]{1}=C2=A0</div><div>[ 3042.667877]{1} CPU: =
1 PID: 140 Comm: debuggerd Tainted: G =C2=A0 =C2=A0B =C2=A0 =C2=A0 =C2=A0 =
=C2=A03.10.0-gb7e125e #1</div><div>[ 3042.676940]{1} task: e3adc800 ti: e2e=
64000 task.ti: e2e64000</div><div>[ 3042.683288]{1} PC is at follow_page_ma=
sk+0x154/0x25c</div><div>[ 3042.688842]{1} LR is at memblock_is_memory+0x10=
/0x20</div><div>[ 3042.694427]{1} pc : [&lt;c01d83c4&gt;] =C2=A0 =C2=A0lr :=
 [&lt;c01e5148&gt;] =C2=A0 =C2=A0psr: 60010013</div><div>[ 3042.694427]{1} =
sp : e2e65de8 =C2=A0ip : c0ae2f90 =C2=A0fp : e2c87340</div><div>[ 3042.7078=
85]{1} r10: 00000000 =C2=A0r9 : 00000000 =C2=A0r8 : c15aff60</div><div>[ 30=
42.714050]{1} r7 : c156ae3c =C2=A0r6 : 2b7fb79f =C2=A0r5 : c6738160 =C2=A0r=
4 : 00000016</div><div>[ 3042.721649]{1} r3 : 00000000 =C2=A0r2 : 00000001 =
=C2=A0r1 : 2b7fb000 =C2=A0r0 : c15aff60</div><div>[ 3042.729248]{1} Flags: =
nZCv =C2=A0IRQs on =C2=A0FIQs on =C2=A0Mode SVC_32 =C2=A0ISA ARM =C2=A0Segm=
ent user</div><div>[ 3042.737548]{1} Control: 10c5387d =C2=A0Table: 2928406=
a =C2=A0DAC: 00000015</div><div>[ 3042.744262]{1}=C2=A0</div><div>[ 3042.74=
4262]{1} PC: 0xc01d8344:</div><div>[ 3042.749664]{1} 8344 =C2=A0e5983000 e3=
130902 0a000019 e598301c e5932010 e3520000 ca000000 e7f001f2</div><div>[ 30=
42.759124]{1} 8364 =C2=A0e5982010 e3520000 0a000000 e7f001f2 e598200c e3720=
001 5a000000 e7f001f2</div><div>[ 3042.768585]{1} 8384 =C2=A0e2832010 e1921=
f9f e2811001 e1820f91 e3300000 1afffffa e288300c e1932f9f</div><div>[ 3042.=
778045]{1} 83a4 =C2=A0e2822001 e1831f92 e3310000 1afffffa ea000009 e5983010=
 e3530000 ca000000</div><div>[ 3042.787506]{1} 83c4 =C2=A0e7f001f2 e2883010=
 e1932f9f e2822001 e1831f92 e3310000 1afffffa e3140002</div><div>[ 3042.796=
966]{1} 83e4 =C2=A00a00000a e35a0000 0a000006 e3160040 1a000004 e5983000 e3=
130010 1a000001</div><div>[ 3042.806426]{1} 8404 =C2=A0e1a00008 ebffa8f9 e1=
a00008 ebffb5d3 e3140040 0a000011 e5953028 e3130a02</div><div>[ 3042.815917=
]{1} 8424 =C2=A00a00000e e5983004 e3530000 0a00000b e3a00000 e1a01008 eb05a=
3db e3500000</div><div>[ 3042.825378]{1}=C2=A0</div><div>[ 3042.825378]{1} =
LR: 0xc01e50c8:</div><div>[ 3042.830017]{2} modem: zsp img load 0x1600000 b=
yte.</div><div>[ 3042.836090]{1} 50c8 =C2=A0c095832c e1a03000 e1a02001 e59f=
0004 e1a01003 eaffff67 c095831c e1a03000</div><div>[ 3042.845550]{1} 50e8 =
=C2=A0e1a02001 e59f0004 e1a01003 eaffff61 c095831c e59f3008 e5933010 e59300=
00</div><div>[ 3042.854980]{1} 5108 =C2=A0e12fff1e c0958318 e59f301c e59320=
04 e5933010 e2422001 e0831182 e7933182</div><div>[ 3042.864410]{1} 5128 =C2=
=A0e5910004 e0800003 e12fff1e c0958318 e1a01000 e59f0010 e92d4008 ebfffc7e<=
/div><div>[ 3042.873840]{1} 5148 =C2=A0e2900001 13a00001 e8bd8008 c095831c =
e92d4070 e1a04000 e59f505c e1a06001</div><div>[ 3042.889709]{2} modem: run =
modem 14 time(s).</div><div>[ 3042.883270]{1} 5168 =C2=A0e1a01004 e2850004 =
ebfffc73 e3700001 03a00000 08bd8070 e5953010 e0832180</div><div>[ 3042.8973=
69]{1} 5188 =C2=A0e7933180 e1530004 8a000009 e5920004 e0833000 e1e00004 e15=
60000 90844006</div><div>[ 3042.906799]{1} 51a8 =C2=A080844000 e1530004 33a=
00000 23a00001 e8bd8070 e3a00000 e8bd8070 c0958318</div><div>[ 3042.916229]=
{1}=C2=A0</div><div>[ 3042.916229]{1} SP: 0xe2e65d68:</div><div>[ 3042.9215=
69]{1} 5d68 =C2=A000000000 00000000 00000101 e3171000 00000182 c01d8c54 e2e=
7d580 c0168bec</div><div>[ 3042.930999]{1} 5d88 =C2=A000000000 c01d83c8 000=
00000 c000d718 00000000 c000d4ac c15aff60 2b7fb000</div><div>[ 3042.940429]=
{1} 5da8 =C2=A000000001 00000000 00000016 c6738160 2b7fb79f c156ae3c c15aff=
60 00000000</div><div>[ 3042.949890]{1} 5dc8 =C2=A000000000 e2c87340 c0ae2f=
90 e2e65de8 c01e5148 c01d83c4 60010013 ffffffff</div><div>[ 3042.959320]{1}=
 5de8 =C2=A0c6738160 b6382fe0 00000000 00000016 d0f10d80 00000016 00000000 =
c01d9620</div><div>[ 3042.968749]{1} 5e08 =C2=A0547c2e1e 06146623 00000001 =
00000001 e2e64000 00000010 06146623 00000000</div><div>[ 3042.978179]{1} 5e=
28 =C2=A000000011 e2e65ec4 b6382fe0 b6382fe0 00000004 e2c87340 e2e65ec4 e2c=
8737c</div><div>[ 3042.987609]{1} 5e48 =C2=A0d0f10d80 c01d97b8 00000016 e2e=
65e6c e2e65e68 00000000 00000000 c01f5a9c</div><div>[ 3042.997070]{1}=C2=A0=
</div><div>[ 3042.997070]{1} IP: 0xc0ae2f10:</div><div>[ 3043.002410]{1} 2f=
10 =C2=A000000000 00000000 00000000 00000000 00000000 00000000 00000000 000=
00000</div><div>[ 3043.011840]{1} 2f30 =C2=A000000000 00000000 00000000 000=
00000 00000000 00000000 00000000 00000000</div><div>[ 3043.021270]{1} 2f50 =
=C2=A000000000 00000000 00000000 00000000 00000000 00000000 00000000 000000=
00</div><div>[ 3043.030731]{1} 2f70 =C2=A000000000 00000000 00000000 000000=
00 00000000 00000000 00000000 00000001</div><div>[ 3043.040161]{1} 2f90 =C2=
=A006400000 39000000 2b800000 13c00000 00000000 00000000 00000000 00000000<=
/div><div>[ 3043.049591]{1} 2fb0 =C2=A000000000 00000000 00000000 00000000 =
00000000 00000000 00000000 00000000</div><div>[ 3043.059020]{1} 2fd0 =C2=A0=
00000000 00000000 00000000 00000000 00000000 00000000 00000000 00000000</di=
v><div>[ 3043.068450]{1} 2ff0 =C2=A000000000 00000000 00000000 00000000 000=
00000 00000000 00000000 00000000</div><div>[ 3043.077880]{1}=C2=A0</div><di=
v>[ 3043.077880]{1} FP: 0xe2c872c0:</div><div>[ 3043.083251]{1} 72c0 =C2=A0=
00000000 00000000 00000012 00000000 0000001a c095ab6c 00000007 00000000</di=
v><div>[ 3043.092681]{1} 72e0 =C2=A000001d17 00000000 00000000 00000000 000=
0008d 00000000 00000000 00000000</div><div>[ 3043.102111]{1} 7300 =C2=A0d97=
39200 da20ecc0 00000000 00000000 00000004 00000000 00000000 00000000</div><=
div>[ 3043.111541]{1} 7320 =C2=A022801000 00000020 00000000 00000000 440004=
80 02084010 02001004 00000000</div><div>[ 3043.120971]{1} 7340 =C2=A0c67381=
60 dbdd98a8 c6738160 c00150b0 c01dc500 b6f5f000 bf000000 00000000</div><div=
>[ 3043.130401]{1} 7360 =C2=A0b6f5f000 bed67000 ddd4c000 0000000c 00000001 =
00000062 00330033 00000001</div><div>[ 3043.139862]{1} 7380 =C2=A00f5f0f5f =
e2c87384 e2c87384 e2c8738c e2c8738c 0000012b 00000c0c 00000cfb</div><div>[ =
3043.149291]{1} 73a0 =C2=A000000000 00000000 0000027e 00000133 00000022 000=
00000 0000000a b6f5d000</div><div>[ 3043.158721]{1}=C2=A0</div><div>[ 3043.=
158721]{1} R0: 0xc15afee0:</div><div>[ 3043.164062]{1} fee0 =C2=A000080068 =
dbef9041 0006272f 00000000 00000001 c11f9c14 c13b3914 00000000</div><div>[ =
3043.173492]{1} ff00 =C2=A000080078 e35e0be1 000000b4 00000000 00000001 c12=
2c5f4 c15aff34 00000000</div><div>[ 3043.182922]{1} ff20 =C2=A000080078 e35=
e06e1 00000079 00000000 00000001 c15aff14 c11525d4 00000000</div><div>[ 304=
3.192352]{1} ff40 =C2=A000000a20 e42f616c 00000001 ffffffff 00000002 c111e1=
b4 c111e274 e3d3c140</div><div>[ 3043.201782]{1} ff60 =C2=A000000604 000000=
00 00000000 ffffffff 00000000 e1f59da0 c16dfc74 00000000</div><div>[ 3043.2=
11242]{1} ff80 =C2=A000000400 00000000 00000000 ffffffff 00000001 c15aff94 =
c15aff94 00000000</div><div>[ 3043.220672]{1} ffa0 =C2=A000000400 00000000 =
00000000 ffffffff 00000001 c15affb4 c15affb4 00000000</div><div>[ 3043.2301=
02]{1} ffc0 =C2=A000000400 00000000 00000000 ffffffff 00000001 c15affd4 c15=
affd4 00000000</div><div>[ 3043.239532]{1}=C2=A0</div><div>[ 3043.239532]{1=
} R5: 0xc67380e0:</div><div>[ 3043.244873]{1} 80e0 =C2=A000000000 00000000 =
00000000 c67380ec c67380ec 00000000 00000000 0005ef0e</div><div>[ 3043.2543=
02]{1} 8100 =C2=A000000000 00000000 5ef0f000 5f00c000 df52d3c8 c67380b0 c67=
38069 df52d3d8</div><div>[ 3043.263732]{1} 8120 =C2=A0c67380c0 00000000 cb3=
b5c00 0000079f 00200073 00000000 00000000 00000000</div><div>[ 3043.273162]=
{1} 8140 =C2=A000000000 d3d0a608 d3d0a608 c9f86820 00000000 0005ef0f 000000=
00 00000000</div><div>[ 3043.282592]{1} 8160 =C2=A0b6285000 b6383000 dbeb52=
c0 00000000 dbeb52d0 00000000 00000000 b6285000</div><div>[ 3043.292022]{1}=
 8180 =C2=A0e2c87340 0000079f 10220051 ca480975 00000000 d734318c 000000fd =
c673819c</div><div>[ 3043.301452]{1} 81a0 =C2=A0c673819c 00000000 c0976080 =
00000000 c2e21600 e1574400 40092000 40093000</div><div>[ 3043.310882]{1} 81=
c0 =C2=A0dbde5948 d96a6528 d96a6539 00000000 00000000 00000000 e2c86700 000=
0079f</div><div>[ 3043.320343]{1}=C2=A0</div><div>[ 3043.320343]{1} R7: 0xc=
156adbc:</div><div>[ 3043.325683]{1} adbc =C2=A000000000 00000000 00000000 =
00000000 ffffffff 00000001 00100100 00200200</div><div>[ 3043.335113]{1} ad=
dc =C2=A000000000 00000000 00000000 00000000 ffffffff 00000000 00100100 002=
00200</div><div>[ 3043.344543]{1} adfc =C2=A000000000 00000000 00000000 000=
00000 ffffffff 00000001 00100100 00200200</div><div>[ 3043.353973]{1} ae1c =
=C2=A001200120 00000000 00000000 00000000 ffffffff 00000001 00100100 002002=
00</div><div>[ 3043.363403]{1} ae3c =C2=A0004e004d 00000000 00000000 000000=
00 ffffffff 00000001 00100100 00200200</div><div>[ 3043.372833]{1} ae5c =C2=
=A000000000 00000000 00000000 00000000 ffffffff 00000001 00100100 00200200<=
/div><div>[ 3043.382263]{1} ae7c =C2=A000000000 00000000 00000000 00000000 =
ffffffff 00000001 00100100 00200200</div><div>[ 3043.391693]{1} ae9c =C2=A0=
00000000 00000000 00000000 00000000 ffffffff 00000001 00100100 00200200</di=
v><div>[ 3043.401153]{1}=C2=A0</div><div>[ 3043.401153]{1} R8: 0xc15afee0:<=
/div><div>[ 3043.406494]{1} fee0 =C2=A000080068 dbef9041 0006272f 00000000 =
00000001 c11f9c14 c13b3914 00000000</div><div>[ 3043.415924]{1} ff00 =C2=A0=
00080078 e35e0be1 000000b4 00000000 00000001 c122c5f4 c15aff34 00000000</di=
v><div>[ 3043.425354]{1} ff20 =C2=A000080078 e35e06e1 00000079 00000000 000=
00001 c15aff14 c11525d4 00000000</div><div>[ 3043.434783]{1} ff40 =C2=A0000=
00a20 e42f616c 00000001 ffffffff 00000002 c111e1b4 c111e274 e3d3c140</div><=
div>[ 3043.444213]{1} ff60 =C2=A000000604 00000000 00000000 ffffffff 000000=
00 e1f59da0 c16dfc74 00000000</div><div>[ 3043.453643]{1} ff80 =C2=A0000004=
00 00000000 00000000 ffffffff 00000001 c15aff94 c15aff94 00000000</div><div=
>[ 3043.463073]{1} ffa0 =C2=A000000400 00000000 00000000 ffffffff 00000001 =
c15affb4 c15affb4 00000000</div><div>[ 3043.472503]{1} ffc0 =C2=A000000400 =
00000000 00000000 ffffffff 00000001 c15affd4 c15affd4 00000000</div><div>[ =
3043.481933]{1} Process debuggerd (pid: 140, stack limit =3D 0xe2e64238)</d=
iv><div>[ 3043.489135]{1} Stack: (0xe2e65de8 to 0xe2e66000)</div><div>[ 304=
3.494293]{1} 5de0: =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 c6738160 b6382fe0 00000000 00000016 d0f10d80 00000016</div><div>[ 30=
43.503723]{1} 5e00: 00000000 c01d9620 547c2e1e 06146623 00000001 00000001 e=
2e64000 00000010</div><div>[ 3043.513153]{1} 5e20: 06146623 00000000 000000=
11 e2e65ec4 b6382fe0 b6382fe0 00000004 e2c87340</div><div>[ 3043.522583]{1}=
 5e40: e2e65ec4 e2c8737c d0f10d80 c01d97b8 00000016 e2e65e6c e2e65e68 00000=
000</div><div>[ 3043.532012]{1} 5e60: 00000000 c01f5a9c 00000000 00000000 0=
0000001 e2c87340 e2e65ec4 b6382fe0</div><div>[ 3043.541442]{1} 5e80: d0f10d=
80 00000004 e2e64000 00000000 b6382fe0 c01d98d8 00000004 00000000</div><div=
>[ 3043.550872]{1} 5ea0: bedd1f34 00000001 00000001 bedd1f34 b6382fe0 c0149=
9f8 00000000 b6382fe0</div><div>[ 3043.560302]{1} 5ec0: bedd1f34 00000000 d=
0f10d80 c0149b58 e2d1e9c8 00000002 e2ce1410 00000000</div><div>[ 3043.56973=
2]{1} 5ee0: e2e65f80 00000000 00000000 c01f6be8 00000000 00000000 00000000 =
e2e65f00</div><div>[ 3043.579162]{1} 5f00: bedd1934 00000001 b6fbb951 00000=
006 bedd1994 00000012 00000000 00000000</div><div>[ 3043.588592]{1} 5f20: 0=
0000000 00000000 00000000 00000000 d0f10d80 e2e64000 00000001 00000008</div=
><div>[ 3043.598052]{1} 5f40: b6382fe0 00000000 e2e65f84 c0166c54 00000003 =
60010013 00000000 00000000</div><div>[ 3043.607482]{1} 5f60: b6fbba2c d0f10=
d80 00000000 00000001 bedd1f34 b6382fe0 e2e64000 00000000</div><div>[ 3043.=
616912]{1} 5f80: b6fbba08 c01499b0 bedd1f34 b6382fe0 b63830e0 b6f84394 0000=
001a c000d984</div><div>[ 3043.626342]{1} 5fa0: 00000000 c000d800 b6382fe0 =
b63830e0 00000001 00002c46 b6382fe0 bedd1f34</div><div>[ 3043.635772]{1} 5f=
c0: b6382fe0 b63830e0 b6f84394 0000001a 00002c46 00000003 b6fbba02 b6fbba08=
</div><div>[ 3043.645202]{1} 5fe0: bedd23b8 bedd1f30 b6f596f4 b6f55128 8001=
0010 00000001 00000000 00000000</div><div>[ 3043.654632]{1} [&lt;c01d83c4&g=
t;] (follow_page_mask+0x154/0x25c) from [&lt;c01d9620&gt;] (__get_user_page=
s+0x34c/0x430)</div><div>[ 3043.665527]{1} [&lt;c01d9620&gt;] (__get_user_p=
ages+0x34c/0x430) from [&lt;c01d97b8&gt;] (__access_remote_vm+0x68/0x10c)</=
div><div>[ 3043.676513]{1} [&lt;c01d97b8&gt;] (__access_remote_vm+0x68/0x10=
c) from [&lt;c01d98d8&gt;] (access_process_vm+0x44/0x58)</div><div>[ 3043.6=
87408]{1} [&lt;c01d98d8&gt;] (access_process_vm+0x44/0x58) from [&lt;c01499=
f8&gt;] (generic_ptrace_peekdata+0x1c/0x50)</div><div>[ 3043.698669]{1} [&l=
t;c01499f8&gt;] (generic_ptrace_peekdata+0x1c/0x50) from [&lt;c0149b58&gt;]=
 (ptrace_request+0xf8/0x588)</div><div>[ 3043.709777]{1} [&lt;c0149b58&gt;]=
 (ptrace_request+0xf8/0x588) from [&lt;c01499b0&gt;] (SyS_ptrace+0x4c8/0x4f=
4)</div><div>[ 3043.719787]{1} [&lt;c01499b0&gt;] (SyS_ptrace+0x4c8/0x4f4) =
from [&lt;c000d800&gt;] (ret_fast_syscall+0x0/0x30)</div><div>[ 3043.729797=
]{1} Code: ea000009 e5983010 e3530000 ca000000 (e7f001f2)=C2=A0</div><div>[=
 3043.736877]{1} ---[ end trace 1cea5be63dfbfc6c ]---</div><div>[ 3043.7423=
40]{1} Kernel panic - not syncing: Fatal exception</div><div>[ 3043.742340]=
{2} CPU2: stopping</div><div>[ 3043.742370]{2} CPU: 2 PID: 12442 Comm: emsd=
 Tainted: G =C2=A0 =C2=A0B D =C2=A0 =C2=A0 =C2=A03.10.0-gb7e125e #1</div><d=
iv>[ 3043.742370]{2} [&lt;c0012bc0&gt;] (unwind_backtrace+0x0/0xe0) from [&=
lt;c0010b58&gt;] (show_stack+0x10/0x14)</div><div>[ 3043.742401]{2} [&lt;c0=
010b58&gt;] (show_stack+0x10/0x14) from [&lt;c0012030&gt;] (handle_IPI+0xc8=
/0x1a8)</div><div>[ 3043.742401]{2} [&lt;c0012030&gt;] (handle_IPI+0xc8/0x1=
a8) from [&lt;c0008454&gt;] (gic_handle_irq+0x50/0x58)</div><div>[ 3043.742=
401]{2} [&lt;c0008454&gt;] (gic_handle_irq+0x50/0x58) from [&lt;c000d400&gt=
;] (__irq_svc+0x40/0x70)</div><div>[ 3043.742431]{2} Exception stack(0xca48=
9e38 to 0xca489e80)</div><div>[ 3043.742431]{2} 9e20: =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 00000001 00000001</div><div>[ 3043.742431]{2} 9e40: 00=
000001 fefdeb24 c0926918 c184c0c0 c184c0c4 c0926450 00000001 fe0a2b24</div>=
<div>[ 3043.742462]{2} 9e60: 00000005 c1855100 00000001 ca489e80 c0187580 c=
0187560 00010013 ffffffff</div><div>[ 3043.742462]{2} [&lt;c000d400&gt;] (_=
_irq_svc+0x40/0x70) from [&lt;c0187560&gt;] (smp_call_function_many+0x260/0=
x2b8)</div><div>[ 3043.742492]{2} [&lt;c0187560&gt;] (smp_call_function_man=
y+0x260/0x2b8) from [&lt;c01875e8&gt;] (on_each_cpu_mask+0x30/0x84)</div><d=
iv>[ 3043.742492]{2} [&lt;c01875e8&gt;] (on_each_cpu_mask+0x30/0x84) from [=
&lt;c01876d8&gt;] (on_each_cpu_cond+0x9c/0xd0)</div><div>[ 3043.742492]{2} =
[&lt;c01876d8&gt;] (on_each_cpu_cond+0x9c/0xd0) from [&lt;c021d818&gt;] (in=
validate_bh_lrus+0x20/0x2c)</div><div>[ 3043.742523]{2} [&lt;c021d818&gt;] =
(invalidate_bh_lrus+0x20/0x2c) from [&lt;c02240ec&gt;] (kill_bdev+0x1c/0x30=
)</div><div>[ 3043.742523]{2} [&lt;c02240ec&gt;] (kill_bdev+0x1c/0x30) from=
 [&lt;c02246b0&gt;] (__blkdev_put+0x98/0x14c)</div><div>[ 3043.742553]{2} [=
&lt;c02246b0&gt;] (__blkdev_put+0x98/0x14c) from [&lt;c02248a0&gt;] (blkdev=
_close+0x18/0x20)</div><div>[ 3043.742553]{2} [&lt;c02248a0&gt;] (blkdev_cl=
ose+0x18/0x20) from [&lt;c01f7150&gt;] (__fput+0xe8/0x1ec)</div><div>[ 3043=
.742584]{2} [&lt;c01f7150&gt;] (__fput+0xe8/0x1ec) from [&lt;c0159478&gt;] =
(task_work_run+0xb8/0xd0)</div><div>[ 3043.742584]{2} [&lt;c0159478&gt;] (t=
ask_work_run+0xb8/0xd0) from [&lt;c0010724&gt;] (do_work_pending+0x80/0x94)=
</div><div>[ 3043.742584]{2} [&lt;c0010724&gt;] (do_work_pending+0x80/0x94)=
 from [&lt;c000d840&gt;] (work_pending+0xc/0x20)</div><div>[ 3043.742614]{3=
} CPU3: stopping</div><div>[ 3043.742614]{3} CPU: 3 PID: 0 Comm: swapper/3 =
Tainted: G =C2=A0 =C2=A0B D =C2=A0 =C2=A0 =C2=A03.10.0-gb7e125e #1</div><di=
v>[ 3043.742614]{3} [&lt;c0012bc0&gt;] (unwind_backtrace+0x0/0xe0) from [&l=
t;c0010b58&gt;] (show_stack+0x10/0x14)</div><div>[ 3043.742645]{3} [&lt;c00=
10b58&gt;] (show_stack+0x10/0x14) from [&lt;c0012030&gt;] (handle_IPI+0xc8/=
0x1a8)</div><div>[ 3043.742645]{3} [&lt;c0012030&gt;] (handle_IPI+0xc8/0x1a=
8) from [&lt;c0008454&gt;] (gic_handle_irq+0x50/0x58)</div><div>[ 3043.7426=
75]{3} [&lt;c0008454&gt;] (gic_handle_irq+0x50/0x58) from [&lt;c000d400&gt;=
] (__irq_svc+0x40/0x70)</div><div>[ 3043.742675]{3} Exception stack(0xe447f=
f98 to 0xe447ffe0)</div><div>[ 3043.742675]{3} ff80: =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0 c1852908 00000000</div><div>[ 3043.742675]{3} ffa0: 00=
1e4dfa c0019580 e447e000 e447e000 10c0387d c0689f58 0640406a 410fc075</div>=
<div>[ 3043.742706]{3} ffc0: 00000000 00000000 00000000 e447ffe0 c0019590 c=
0019598 a00d0013 ffffffff</div><div>[ 3043.742706]{3} [&lt;c000d400&gt;] (_=
_irq_svc+0x40/0x70) from [&lt;c0019598&gt;] (comip_wfi_do+0x18/0x1c)</div><=
div>[ 3043.742736]{3} [&lt;c0019598&gt;] (comip_wfi_do+0x18/0x1c) from [&lt=
;c000e47c&gt;] (arch_cpu_idle+0x18/0x2c)</div><div>[ 3043.742736]{3} [&lt;c=
000e47c&gt;] (arch_cpu_idle+0x18/0x2c) from [&lt;c017a8c8&gt;] (cpu_startup=
_entry+0x1bc/0x228)</div><div>[ 3043.742736]{3} [&lt;c017a8c8&gt;] (cpu_sta=
rtup_entry+0x1bc/0x228) from [&lt;06a13084&gt;] (0x6a13084)</div><div>[ 304=
3.742767]{0} CPU0: stopping</div><div>[ 3043.742767]{0} CPU: 0 PID: 0 Comm:=
 swapper/0 Tainted: G =C2=A0 =C2=A0B D =C2=A0 =C2=A0 =C2=A03.10.0-gb7e125e =
#1</div><div>[ 3043.742767]{0} [&lt;c0012bc0&gt;] (unwind_backtrace+0x0/0xe=
0) from [&lt;c0010b58&gt;] (show_stack+0x10/0x14)</div><div>[ 3043.742797]{=
0} [&lt;c0010b58&gt;] (show_stack+0x10/0x14) from [&lt;c0012030&gt;] (handl=
e_IPI+0xc8/0x1a8)</div><div>[ 3043.742797]{0} [&lt;c0012030&gt;] (handle_IP=
I+0xc8/0x1a8) from [&lt;c0008454&gt;] (gic_handle_irq+0x50/0x58)</div><div>=
[ 3043.742797]{0} [&lt;c0008454&gt;] (gic_handle_irq+0x50/0x58) from [&lt;c=
000d400&gt;] (__irq_svc+0x40/0x70)</div><div>[ 3043.742828]{0} Exception st=
ack(0xc0909f68 to 0xc0909fb0)</div><div>[ 3043.742828]{0} 9f60: =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 c1837908 00000000 002f=
1012 c0019580 c0908000 c0908000</div><div>[ 3043.742828]{0} 9f80: c08fdbe8 =
c0689f58 0640406a 410fc075 00000000 00000000 00000000 c0909fb0</div><div>[ =
3043.742858]{0} 9fa0: c0019590 c0019598 a0010013 ffffffff</div><div>[ 3043.=
742858]{0} [&lt;c000d400&gt;] (__irq_svc+0x40/0x70) from [&lt;c0019598&gt;]=
 (comip_wfi_do+0x18/0x1c)</div><div>[ 3043.742858]{0} [&lt;c0019598&gt;] (c=
omip_wfi_do+0x18/0x1c) from [&lt;c000e47c&gt;] (arch_cpu_idle+0x18/0x2c)</d=
iv><div>[ 3043.742889]{0} [&lt;c000e47c&gt;] (arch_cpu_idle+0x18/0x2c) from=
 [&lt;c017a8c8&gt;] (cpu_startup_entry+0x1bc/0x228)</div><div>[ 3043.742889=
]{0} [&lt;c017a8c8&gt;] (cpu_startup_entry+0x1bc/0x228) from [&lt;c08b77b0&=
gt;] (start_kernel+0x2c4/0x324)</div></div></div></div></div>

--047d7b450b1e00e1e105098541ef--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
