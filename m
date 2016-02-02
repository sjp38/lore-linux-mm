Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f179.google.com (mail-ob0-f179.google.com [209.85.214.179])
	by kanga.kvack.org (Postfix) with ESMTP id 95E616B0253
	for <linux-mm@kvack.org>; Mon,  1 Feb 2016 20:23:59 -0500 (EST)
Received: by mail-ob0-f179.google.com with SMTP id ba1so136181480obb.3
        for <linux-mm@kvack.org>; Mon, 01 Feb 2016 17:23:59 -0800 (PST)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id g84si20948302oib.130.2016.02.01.17.23.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 01 Feb 2016 17:23:58 -0800 (PST)
From: Mike Kravetz <mike.kravetz@oracle.com>
Subject: kernel BUG at mm/hugetlb.c:1218!
Message-ID: <56B00529.6080807@oracle.com>
Date: Mon, 1 Feb 2016 17:23:53 -0800
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-mm@kvack.org" <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Michal Hocko <mhocko@suse.cz>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, David Rientjes <rientjes@google.com>

I just noticed that recent mmotm and linux-next kernels will not boot if
you attempt to preallocate 1G huge pages at boot time (on x86).  To
preallocate, simply add "hugepagesz=1G hugepages=1" to kernel command
line.  I have not yet started to debug.  However, based on the
"BUG_ON(page_mapcount(page));" I am guessing it is related to recent
mapcount/refcount changes.

[    0.465644] ------------[ cut here ]------------
[    0.467640] kernel BUG at mm/hugetlb.c:1218!
[    0.468745] invalid opcode: 0000 [#1] SMP
[    0.469989] Modules linked in:
[    0.470867] CPU: 0 PID: 1 Comm: swapper/0 Not tainted 4.4.0 #1
[    0.471724] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996),
BIOS 1.8.1-20150318_183358- 04/01/2014
[    0.473162] task: ffff880236290000 ti: ffff880236298000 task.ti:
ffff880236298000
[    0.474417] RIP: 0010:[<ffffffff811e3422>]  [<ffffffff811e3422>]
free_huge_page+0x2a2/0x2b0
[    0.475791] RSP: 0000:ffff88023629bdc8  EFLAGS: 00010202
[    0.476583] RAX: 0000000000000001 RBX: ffffffff81f97d60 RCX:
ffffea000700001f
[    0.477555] RDX: 0000000000000000 RSI: ffffffff81f993d0 RDI:
ffffea0007000000
[    0.478697] RBP: ffff88023629bdf0 R08: 00000000001c0000 R09:
ffffea0007000001
[    0.479636] R10: 0000000000040000 R11: ffffffff81f993be R12:
ffffea0007000000
[    0.480572] R13: 0200000000004000 R14: 0000000000000000 R15:
ffffea0007000000
[    0.481519] FS:  0000000000000000(0000) GS:ffff88023fc00000(0000)
knlGS:0000000000000000
[    0.482991] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[    0.484018] CR2: 00000000ffffffff CR3: 0000000001c09000 CR4:
00000000001406f0
[    0.485210] Stack:
[    0.485782]  ffffea0007000000 ffffffff81f97d60 0000000000000001
ffffea0000000000
[    0.487462]  ffffea0007000000 ffff88023629be08 ffffffff811a0a30
ffffea0007000000
[    0.489175]  ffff88023629be20 ffffffff811a103a ffff8801c0000000
ffff88023629be88
[    0.490873] Call Trace:
[    0.491507]  [<ffffffff811a0a30>] __put_compound_page+0x30/0x50
[    0.492549]  [<ffffffff811a103a>] __put_page+0x1a/0x40
[    0.493498]  [<ffffffff81d80e76>] hugetlb_init+0x5c0/0x5d4
[    0.494500]  [<ffffffff81002113>] ? do_one_initcall+0xa3/0x200
[    0.495528]  [<ffffffff81d808b6>] ? hugetlb_add_hstate+0x180/0x180
[    0.497509]  [<ffffffff81d808b6>] ? hugetlb_add_hstate+0x180/0x180
[    0.498366]  [<ffffffff81002123>] do_one_initcall+0xb3/0x200
[    0.499173]  [<ffffffff810b52f5>] ? parse_args+0x295/0x4b0
[    0.499965]  [<ffffffff81d52192>] kernel_init_freeable+0x16d/0x207
[    0.500815]  [<ffffffff81750640>] ? rest_init+0x80/0x80
[    0.501586]  [<ffffffff8175064e>] kernel_init+0xe/0xe0
[    0.509314]  [<ffffffff8175c7cf>] ret_from_fork+0x3f/0x70
[    0.510117]  [<ffffffff81750640>] ? rest_init+0x80/0x80
[    0.510886] Code: c0 01 e9 7e fe ff ff 48 c7 c6 28 8b a5 81 4c 89 e7
e8 93 b8 fd ff 0f 0b 0f 0b 48 c7 c6 e0 75 a5 81 4c 89 e7 e8 80 b8 fd ff
0f 0b <0f> 0b 66 66 66 2e 0f 1f 84 00 00 00 00 00 0f 1f 44 00 00 55 48
[    0.516745] RIP  [<ffffffff811e3422>] free_huge_page+0x2a2/0x2b0
[    0.517650]  RSP <ffff88023629bdc8>
[    0.518303] ---[ end trace 6f9049db529aa0d6 ]---
[    0.519043] Kernel panic - not syncing: Attempted to kill init!
exitcode=0x0000000b
[    0.519043]
[    0.520782] ---[ end Kernel panic - not syncing: Attempted to kill
init! exitcode=0x0000000b
[    0.520782]

-- 
Mike Kravetz

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
