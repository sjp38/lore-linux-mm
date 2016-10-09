Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id D62B56B0069
	for <linux-mm@kvack.org>; Sun,  9 Oct 2016 03:24:28 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id m10so92597642ith.7
        for <linux-mm@kvack.org>; Sun, 09 Oct 2016 00:24:28 -0700 (PDT)
Received: from mail-io0-x231.google.com (mail-io0-x231.google.com. [2607:f8b0:4001:c06::231])
        by mx.google.com with ESMTPS id y142si30050904ioy.209.2016.10.09.00.24.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 09 Oct 2016 00:24:28 -0700 (PDT)
Received: by mail-io0-x231.google.com with SMTP id j37so84151122ioo.3
        for <linux-mm@kvack.org>; Sun, 09 Oct 2016 00:24:28 -0700 (PDT)
MIME-Version: 1.0
From: Wenwei Tao <ww.tao0320@gmail.com>
Date: Sun, 9 Oct 2016 15:24:27 +0800
Message-ID: <CACygaLCEsdDyERUACBqMfqupbvPyH7QOCcm3sE8nZuYbwfA=sQ@mail.gmail.com>
Subject: kernel BUG at mm/huge_memory.c:1187!
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi,

I open the Transparent  huge page and run the system and hit the bug
in huge_memory.c:

static void __split_huge_page_refcount(struct page *page)
                              .
                              .
                              .

     /* tail_page->_mapcount cannot change */
     BUG_ON(page_mapcount(page_tail) < 0);
                               .
                               .

In my understanding, the THP's tail page's mapcount is initialized to
-1,  page_mapcout(page_tail) should be 0.
Did anyone meet the same issue?

Thanks.

2016-09-28 02:12:08 [810422.485203] ------------[ cut here ]------------
2016-09-28 02:12:08 [810422.489974] kernel BUG at mm/huge_memory.c:1187!
2016-09-28 02:12:08 [810422.494742] invalid opcode: 0000 [#1] SMP
2016-09-28 02:12:08 [810422.499034] last sysfs file:
/sys/devices/system/cpu/online
2016-09-28 02:12:08 [810422.504757] CPU 31
2016-09-28 02:12:08 [810422.506775] Modules linked in: 8021q garp
bridge stp llc dell_rbu ipmi_devintf ipmi_si ipmi_msghandler bonding
ipv6 microcode  dca power_meter ext4 mbcache jbd2 ahci wmi dm_mirror
dm_region_hash dm_log dm_mod
2016-09-28 02:12:08 [810422.571439]
2016-09-28 02:12:08 [810422.573088] Pid: 10729, comm: observer
Tainted: G        W  ----------------   2.6.32-220.23.2.el6.x86_64
2016-09-28 02:12:08 [810422.586827] RIP: 0010:[]  [] split_huge_page+0x7c4/0x800
2016-09-28 02:12:08 [810422.595498] RSP: 0018:ffff887661c9fcd8  EFLAGS: 00010086
2016-09-28 02:12:08 [810422.600956] RAX: 00000000ffffffff RBX:
ffffea011b4d4000 RCX: ffffc9003018b000
2016-09-28 02:12:08 [810422.608300] RDX: 0000000000000002 RSI:
ffff887f4fb3b400 RDI: 0000000000000004
2016-09-28 02:12:08 [810422.615644] RBP: ffff887661c9fd88 R08:
000000000000007d R09: ffff880000000000
2016-09-28 02:12:08 [810422.622983] R10: 0000000000000000 R11:
0000000000000287 R12: ffffea011b4cdfc0
2016-09-28 02:12:08 [810422.630325] R13: 0000000000000000 R14:
ffffea011b4cd000 R15: 00000007f3253047
2016-09-28 02:12:08 [810422.637664] FS:  00007f43aed23700(0000)
GS:ffff8802723e0000(0000) knlGS:0000000000000000
2016-09-28 02:12:08 [810422.645957] CS:  0010 DS: 0000 ES: 0000 CR0:
0000000080050033
2016-09-28 02:12:08 [810422.651855] CR2: 00002b73a80013b0 CR3:
000000557a658000 CR4: 00000000001406e0
2016-09-28 02:12:08 [810422.659198] DR0: 0000000000000000 DR1:
0000000000000000 DR2: 0000000000000000
2016-09-28 02:12:08 [810422.666543] DR3: 0000000000000000 DR6:
00000000fffe0ff0 DR7: 0000000000000400
2016-09-28 02:12:08 [810422.673882] Process observer (pid: 10729,
threadinfo ffff887661c9e000, task ffff88787fb94040)
2016-09-28 02:12:08 [810422.682611] Stack:
2016-09-28 02:12:08 [810422.684779]  000000000000000e 0000000000000006
ffff887f46f4e640 ffff887882be22e0
2016-09-28 02:12:08 [810422.692213] <0> ffff887f46f4e6c8
0000000100000000 ffff887882be22f8 0000006cd0dcb067
2016-09-28 02:12:08 [810422.700185] <0> ffff887882be22d8
0000000181146034 ffffea011b4cd038 ffff88000002c1c0
2016-09-28 02:12:08 [810422.708420] Call Trace:
2016-09-28 02:12:08 [810422.711026]  [] __split_huge_page_pmd+0x81/0xc0
2016-09-28 02:12:08 [810422.717272]  [] split_huge_page_address+0x9a/0xa0
2016-09-28 02:12:08 [810422.723686]  [] __vma_adjust_trans_huge+0xd0/0xf0
2016-09-28 02:12:08 [810422.730102]  [] vma_adjust+0x4fa/0x590
2016-09-28 02:12:08 [810422.735566]  [] __split_vma+0x143/0x280
2016-09-28 02:12:08 [810422.741115]  [] do_munmap+0x25a/0x3a0
2016-09-28 02:12:08 [810422.746489]  [] sys_munmap+0x56/0x80
2016-09-28 02:12:08 [810422.751782]  [] system_call_fastpath+0x16/0x1b
2016-09-28 02:12:08 [810422.757939] Code: b0 fc ff ff 0f 0b 90 eb fd
49 8b 46 10 e9 d4 fc ff ff 0f 0b 0f 1f 00 eb fb 49 8b 06 a9 00 00 00
02 0f 84 1c fa ff ff f3 90 eb ee <0f> 0b eb fe 0f 0b 66 0f 1f 44 00 00
eb f8 0f 0b eb fe 0f 0b 0f
2016-09-28 02:12:08 [810422.778682] RIP  [] split_huge_page+0x7c4/0x800
2016-09-28 02:12:08 [810422.784947]  RSP
2016-09-28 02:12:08 [810422.789074] ---[ end trace a7919e7f17c0a727 ]---

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
