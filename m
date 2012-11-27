Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx108.postini.com [74.125.245.108])
	by kanga.kvack.org (Postfix) with SMTP id BD7A46B004D
	for <linux-mm@kvack.org>; Tue, 27 Nov 2012 16:18:19 -0500 (EST)
Received: by mail-ee0-f41.google.com with SMTP id d41so8857812eek.14
        for <linux-mm@kvack.org>; Tue, 27 Nov 2012 13:18:18 -0800 (PST)
Message-ID: <50B52E17.8020205@suse.cz>
Date: Tue, 27 Nov 2012 22:18:15 +0100
From: Jiri Slaby <jslaby@suse.cz>
MIME-Version: 1.0
Subject: kernel BUG at mm/huge_memory.c:212!
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

Hi,

I've hit BUG_ON(atomic_dec_and_test(&huge_zero_refcount)) in
put_huge_zero_page right now. There are some "Bad rss-counter state"
before that, but those are perhaps unrelated as I saw many of them in
the previous -next. But even with yesterday's next I got the BUG.

[ 7395.654928] BUG: Bad rss-counter state mm:ffff8800088289c0 idx:1 val:-1
[ 7417.652911] BUG: Bad rss-counter state mm:ffff880008829a00 idx:1 val:-1
[ 7423.317027] BUG: Bad rss-counter state mm:ffff8800088296c0 idx:1 val:-1
[ 7463.737596] BUG: Bad rss-counter state mm:ffff88000882ad80 idx:1 val:-2
[ 7486.462237] BUG: Bad rss-counter state mm:ffff880008829040 idx:1 val:-2
[ 7499.118560] BUG: Bad rss-counter state mm:ffff880008829040 idx:1 val:-2
[ 7507.000464] BUG: Bad rss-counter state mm:ffff880008828000 idx:1 val:-2
[ 7512.898902] BUG: Bad rss-counter state mm:ffff880008829380 idx:1 val:-2
[ 7522.299066] BUG: Bad rss-counter state mm:ffff8800088296c0 idx:1 val:-2
[ 7530.471048] BUG: Bad rss-counter state mm:ffff8800088296c0 idx:1 val:-2
[ 7597.602661] BUG: 'atomic_dec_and_test(&huge_zero_refcount)' is true!
[ 7597.602683] ------------[ cut here ]------------
[ 7597.602711] kernel BUG at /l/latest/linux/mm/huge_memory.c:212!
[ 7597.602732] invalid opcode: 0000 [#1] SMP
[ 7597.602751] Modules linked in: vfat fat dvb_usb_dib0700 dib0090
dib7000p dib7000m dib0070 dib8000 dib3000mc dibx000_common microcode
[ 7597.602811] CPU 1
[ 7597.602823] Pid: 1221, comm: java Not tainted
3.7.0-rc6-next-20121126_64+ #1698 To Be Filled By O.E.M. To Be Filled By
O.E.M./To be filled by O.E.M.
[ 7597.602867] RIP: 0010:[<ffffffff8116839e>]  [<ffffffff8116839e>]
put_huge_zero_page+0x2e/0x30
[ 7597.602902] RSP: 0000:ffff8801a58cdd48  EFLAGS: 00010292
[ 7597.602921] RAX: 0000000000000038 RBX: ffff880183cc0d00 RCX:
0000000000000007
[ 7597.602944] RDX: 00000000000000b5 RSI: 0000000000000046 RDI:
ffffffff81dc605c
[ 7597.602967] RBP: ffff8801a58cdd48 R08: 746127203a475542 R09:
000000000000047b
[ 7597.602990] R10: 6365645f63696d6f R11: 7365745f646e615f R12:
00007fd4b3e00000
[ 7597.603014] R13: 00007fd4b3dcc000 R14: ffff8801bdebab00 R15:
8000000001d94225
[ 7597.603037] FS:  00007fd4c7ebe700(0000) GS:ffff8801cbc80000(0000)
knlGS:0000000000000000
[ 7597.603064] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[ 7597.603083] CR2: 00007fd4b3dcc498 CR3: 000000017d6bc000 CR4:
00000000000007e0
[ 7597.603106] DR0: 0000000000000000 DR1: 0000000000000000 DR2:
0000000000000000
[ 7597.603129] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7:
0000000000000400
[ 7597.603152] Process java (pid: 1221, threadinfo ffff8801a58cc000,
task ffff8801a4655be0)
[ 7597.603178] Stack:
[ 7597.603187]  ffff8801a58cddc8 ffffffff8116b8d4 ffff8801a38cb000
ffff8801bdebab00
[ 7597.603219]  ffff880183cc0d00 00000001a38cb067 ffffea0006cccb40
ffff8801a3911cf0
[ 7597.603250]  00000001b332d000 00007fd4b3c00000 ffff880183cc0d00
00007fd4b3dcc498
[ 7597.603282] Call Trace:
[ 7597.603293]  [<ffffffff8116b8d4>] do_huge_pmd_wp_page+0x7e4/0x900
[ 7597.603316]  [<ffffffff81148755>] handle_mm_fault+0x145/0x330
[ 7597.603337]  [<ffffffff81071e45>] __do_page_fault+0x145/0x480
[ 7597.603358]  [<ffffffff810b42c5>] ? sched_clock_local+0x25/0xa0
[ 7597.603378]  [<ffffffff810b4ec8>] ? __enqueue_entity+0x78/0x80
[ 7597.603400]  [<ffffffff810d0efd>] ? sys_futex+0x8d/0x190
[ 7597.603420]  [<ffffffff810721be>] do_page_fault+0xe/0x10
[ 7597.603440]  [<ffffffff816b7c72>] page_fault+0x22/0x30
[ 7597.603458] Code: 66 90 f0 ff 0d c0 05 cf 00 0f 94 c0 84 c0 75 02 f3
c3 55 48 c7 c6 60 51 97 81 48 c7 c7 1a 82 94 81 48 89 e5 31 c0 e8 25 60
54 00 <0f> 0b 66 66 66 66 90 55 48 89 e5 53 48 83 ec 08 48 83 7e 08 00
[ 7597.603640] RIP  [<ffffffff8116839e>] put_huge_zero_page+0x2e/0x30
[ 7597.603664]  RSP <ffff8801a58cdd48>
[ 7597.636299] ---[ end trace 241e96a56fc0cf87 ]---
[ 7612.907136] SysRq : Keyboard mode set to system default

thanks,
-- 
js
suse labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
