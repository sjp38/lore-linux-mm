Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id 8D80C6B0005
	for <linux-mm@kvack.org>; Sat,  2 Mar 2013 15:57:17 -0500 (EST)
Received: by mail-vc0-f177.google.com with SMTP id m18so2653418vcm.8
        for <linux-mm@kvack.org>; Sat, 02 Mar 2013 12:57:16 -0800 (PST)
MIME-Version: 1.0
Date: Sat, 2 Mar 2013 22:57:16 +0200
Message-ID: <CA+ydwtruzDg+qs5r1pSVV5DAceXRhPeAqCDM+GUyK5Jn_J83Gw@mail.gmail.com>
Subject: kmemleak BUG: unable to handle kernel paging request at ffffc90000c68000
From: Tommi Rantala <tt.rantala@gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>
Cc: Dave Jones <davej@redhat.com>, LKML <linux-kernel@vger.kernel.org>

Hello,

Hit the following BUG while fuzzing the kernel with trinity in a qemu
virtual machine as the root user.

The kernel is b0af9cd9aab60ceb17d3ebabb9fdf4ff0a99cf50 (Merge tag
'lzo-update-signature-20130226' of
git://github.com/markus-oberhumer/linux).

[   78.001652] kmemleak: Cannot allocate a kmemleak_object structure
[   78.003647] kmemleak: Kernel memory leak detector disabled
[   78.059339] device-mapper: ioctl: Unable to rename non-existent device, =
 to =E2=96=92
[   78.339932] BUG: unable to handle kernel paging request at ffffc90000c68=
000
[   78.340712] IP: [<ffffffff8136b5b0>] crc32_le+0x60/0x110
[   78.340712] PGD 7cc73067 PUD 7cc74067 PMD 7ad1e067 PTE 0
[   78.340712] Oops: 0000 [#1] SMP
[   78.340712] CPU 0
[   78.340712] Pid: 1399, comm: kmemleak Not tainted 3.8.0+ #93 Bochs Bochs
[   78.340712] RIP: 0010:[<ffffffff8136b5b0>]  [<ffffffff8136b5b0>]
crc32_le+0x60/0x110
[   78.340712] RSP: 0000:ffff88007a4f7da0  EFLAGS: 00010046
[   78.340712] RAX: 0000000000000000 RBX: ffff8800290c2450 RCX: 00000000000=
00028
[   78.340712] RDX: 0000000000000f00 RSI: ffffc90000c68000 RDI: ffffc90000c=
67ffc
[   78.340712] RBP: ffff88007a4f7da8 R08: 0000000000000000 R09: 00000000000=
00001
[   78.340712] R10: 0000000000000000 R11: ffffc90000c67ffc R12: 00000000000=
00286
[   78.340712] R13: 0000000000000000 R14: 000000000007fffe R15: 00000000000=
00040
[   78.340712] FS:  0000000000000000(0000) GS:ffff88007f800000(0000)
knlGS:0000000000000000
[   78.340712] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[   78.340712] CR2: ffffc90000c68000 CR3: 000000000aba2000 CR4: 00000000000=
006f0
[   78.340712] DR0: 0000000000000000 DR1: 0000000000000000 DR2: 00000000000=
00000
[   78.340712] DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 00000000000=
00400
[   78.340712] Process kmemleak (pid: 1399, threadinfo
ffff88007a4f6000, task ffff88007ae68000)
[   78.340712] Stack:
[   78.340712]  ffff8800290c2450 ffff88007a4f7e18 ffffffff811a40af
ffffffff811a3fa0
[   78.340712]  ffffffff820d041d 2222222222222222 0000000000000286
2222222222222222
[   78.340712]  ffff8800290c24a0 ffffffff811a4860 00000000000927c0
0000000000000000
[   78.340712] Call Trace:
[   78.340712]  [<ffffffff811a40af>] kmemleak_scan+0x58f/0x8d0
[   78.340712]  [<ffffffff811a3fa0>] ? kmemleak_scan+0x480/0x8d0
[   78.340712]  [<ffffffff811a4860>] ? kmemleak_write+0x470/0x470
[   78.340712]  [<ffffffff811a4860>] ? kmemleak_write+0x470/0x470
[   78.340712]  [<ffffffff811a48ca>] kmemleak_scan_thread+0x6a/0xd0
[   78.340712]  [<ffffffff810bfd71>] kthread+0xd1/0xe0
[   78.340712]  [<ffffffff810f351d>] ? trace_hardirqs_on+0xd/0x10
[   78.340712]  [<ffffffff810bfca0>] ? __kthread_bind+0x40/0x40
[   78.340712]  [<ffffffff81cdcdfc>] ret_from_fork+0x7c/0xb0
[   78.340712]  [<ffffffff810bfca0>] ? __kthread_bind+0x40/0x40
[   78.340712] Code: 00 40 f6 c6 03 75 da 0f 1f 40 00 49 89 d2 48 c1
ea 03 4c 8d 5e fc 41 83 e2 07 48 85 d2 0f 84 82 00 00 00 4c 89 df 45
31 c0 66 90 <8b> 5f 04 48 83 c7 08 49 83 c0 01 8b 0f 31 c3 89 d8 44 0f
b6 cb
[   78.340712] RIP  [<ffffffff8136b5b0>] crc32_le+0x60/0x110
[   78.340712]  RSP <ffff88007a4f7da0>
[   78.340712] CR2: ffffc90000c68000
[   78.340712] ---[ end trace 93ec389b16e7ea85 ]---

Tommi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
