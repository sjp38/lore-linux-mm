Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 1562B6B004D
	for <linux-mm@kvack.org>; Wed, 11 Nov 2009 14:34:32 -0500 (EST)
Received: by bwz7 with SMTP id 7so1492952bwz.6
        for <linux-mm@kvack.org>; Wed, 11 Nov 2009 11:34:29 -0800 (PST)
Message-ID: <4AFB11C1.9070105@lwfinger.net>
Date: Wed, 11 Nov 2009 13:34:25 -0600
From: Larry Finger <Larry.Finger@lwfinger.net>
MIME-Version: 1.0
Subject: Question regarding BUG in mm/slub.c
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
Cc: Michael Buesch <mbuesch@freenet.de>
List-ID: <linux-mm.kvack.org>

One of the users of a BCM4312 device hit the BUG in the mm/slub.c version of
kfree in the following code fragment:

        page = virt_to_head_page(x);
        if (unlikely(!PageSlab(page))) {
                BUG_ON(!PageCompound(page));
                kmemleak_free(x);
                put_page(page);
                return;
        }

What is the meaning of PageCompound(page) being zero?

For completeness, the system log output is:

Nov 11 14:31:31 doughnut ntpd[398]: kernel time sync status change 2001
Nov 11 14:36:57 doughnut ntpd[398]: synchronized to 130.88.200.4, stratum 2
Nov 11 14:37:31 doughnut kernel: ------------[ cut here ]------------
Nov 11 14:37:31 doughnut kernel: kernel BUG at mm/slub.c:2969!
Nov 11 14:37:31 doughnut kernel: invalid opcode: 0000 [#1] SMP
Nov 11 14:37:31 doughnut kernel: last sysfs file:
/sys/devices/pci0000:00/0000:00:02.1/resource
Nov 11 14:37:31 doughnut kernel: Modules linked in:
Nov 11 14:37:31 doughnut kernel:
Nov 11 14:37:31 doughnut kernel: Pid: 343, comm: irq/17-b43 Not tainted
(2.6.32-rc6-wl #1) Inspiron 910
Nov 11 14:37:31 doughnut kernel: EIP: 0060:[<c107a5b9>] EFLAGS: 00010246 CPU: 0
Nov 11 14:37:31 doughnut kernel: EIP is at kfree+0xa9/0xb0
Nov 11 14:37:31 doughnut kernel: EAX: dededede EBX: f68f8200 ECX: 40000000 EDX:
c19b9da0
Nov 11 14:37:31 doughnut kernel: ESI: ef000000 EDI: 00000400 EBP: f72c5400 ESP:
f6a3ded0
Nov 11 14:37:31 doughnut kernel:  DS: 007b ES: 007b FS: 00d8 GS: 00e0 SS: 0068
Nov 11 14:37:31 doughnut kernel: Process irq/17-b43 (pid: 343, ti=f6a3c000
task=f73fa380 task.ti=f6a3c000)
Nov 11 14:37:31 doughnut kernel: Stack:
Nov 11 14:37:31 doughnut kernel:  000e7ef0 c1021c31 f68f8200 ef000000 00000400
c12d47ce c13ee7c0 f73fa380
Nov 11 14:37:31 doughnut kernel: <0> 7fff7fff dededede 00000000 c141c934
f7093458 f6a3df64 f73b7000 f72c5400
Nov 11 14:37:31 doughnut kernel: <0> f72c5400 f6a3df64 00000000 c12d0556
00000000 c12c0b77 00000046 00000046
Nov 11 14:37:31 doughnut kernel: Call Trace:
Nov 11 14:37:31 doughnut kernel:  [<c1021c31>] ? update_curr_rt+0x251/0x2c0
Nov 11 14:37:31 doughnut kernel:  [<c12d47ce>] ? b43_dma_handle_txstatus+0xbe/0x270
Nov 11 14:37:31 doughnut kernel:  [<c12d0556>] ? b43_handle_txstatus+0x36/0x60
Nov 11 14:37:31 doughnut kernel:  [<c12c0b77>] ? b43_do_interrupt_thread+0x1d7/0x5d0
Nov 11 14:37:31 doughnut kernel:  [<c12c0f85>] ?
b43_interrupt_thread_handler+0x15/0x30
Nov 11 14:37:31 doughnut kernel:  [<c1050a94>] ? irq_thread+0x104/0x1d0
Nov 11 14:37:31 doughnut kernel:  [<c101d320>] ? complete+0x40/0x60
Nov 11 14:37:31 doughnut kernel:  [<c1050990>] ? irq_thread+0x0/0x1d0
Nov 11 14:37:31 doughnut kernel:  [<c1039c64>] ? kthread+0x74/0x80
Nov 11 14:37:31 doughnut kernel:  [<c1039bf0>] ? kthread+0x0/0x80
Nov 11 14:37:31 doughnut kernel:  [<c10038cf>] ? kernel_thread_helper+0x7/0x18
Nov 11 14:37:31 doughnut kernel: Code: e8 1d fc ff ff eb d9 66 f7 c1 00 c0 74 1d
8b 5c 24 08 89 d0 8b 74 24 0c 8b 7c 24 10 83 c4 14 e9 8e 24 fe ff 8b 52 0c 8b 0a
eb 84 <0f> 0b eb fe 8d 76 00 83 e8 60 e9 48 ff ff ff 90 8d b4 26 00 00
Nov 11 14:37:31 doughnut kernel: EIP: [<c107a5b9>] kfree+0xa9/0xb0 SS:ESP
0068:f6a3ded0
Nov 11 14:37:31 doughnut kernel: ---[ end trace 021257f2296ca88f ]---
Nov 11 14:37:31 doughnut kernel: exiting task "irq/17-b43" (343) is an active
IRQ thread (irq 17)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
