Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f50.google.com (mail-la0-f50.google.com [209.85.215.50])
	by kanga.kvack.org (Postfix) with ESMTP id 548C56B0035
	for <linux-mm@kvack.org>; Wed,  5 Feb 2014 10:18:33 -0500 (EST)
Received: by mail-la0-f50.google.com with SMTP id ec20so439377lab.9
        for <linux-mm@kvack.org>; Wed, 05 Feb 2014 07:18:32 -0800 (PST)
Received: from relay.parallels.com (relay.parallels.com. [195.214.232.42])
        by mx.google.com with ESMTPS id ya3si15185785lbb.161.2014.02.05.07.18.21
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 05 Feb 2014 07:18:21 -0800 (PST)
Date: Wed, 5 Feb 2014 19:18:18 +0400
From: Andrew Vagin <avagin@parallels.com>
Subject: Thread overran stack, or stack corrupted on 3.13.0
Message-ID: <20140205151817.GA28502@paralelels.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="koi8-r"
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hello All,

My test server crashed a few days ago. The kernel was built from Linus'
git without any additional changes. I don't know how to reproduce this
bug.

[532284.563576] BUG: unable to handle kernel paging request at 0000000035c83420
[532284.564086] IP: [<ffffffff810caf17>] cpuacct_charge+0x97/0x1e0
[532284.564086] PGD 116369067 PUD 116368067 PMD 0
[532284.564086] Thread overran stack, or stack corrupted
[532284.564086] Oops: 0000 [#1] SMP
[532284.564086] Modules linked in: veth binfmt_misc ip6table_filter ip6_tables tun netlink_diag af_packet_diag udp_diag tcp_diag inet_diag unix_diag bridge stp llc btrfs libcrc32c xor raid6_pq microcode i2c_piix4 joydev virtio_balloon virtio_net pcspkr i2c_core virtio_blk virtio_pci virtio_ring virtio floppy
[532284.564086] CPU: 2 PID: 2487 Comm: cat Not tainted 3.13.0 #160
[532284.564086] Hardware name: Red Hat KVM, BIOS 0.5.1 01/01/2007
[532284.564086] task: ffff8800cdb60000 ti: ffff8801167ee000 task.ti: ffff8801167ee000
[532284.564086] RIP: 0010:[<ffffffff810caf17>]  [<ffffffff810caf17>] cpuacct_charge+0x97/0x1e0
[532284.564086] RSP: 0018:ffff8801167ee638  EFLAGS: 00010002
[532284.564086] RAX: 000000000000e540 RBX: 000000000006086c RCX: 000000000000000f
[532284.564086] RDX: ffffffff81c4e960 RSI: ffffffff81c50640 RDI: 0000000000000046
[532284.564086] RBP: ffff8801167ee668 R08: 0000000000000003 R09: 0000000000000001
[532284.564086] R10: 0000000000000001 R11: 0000000000000004 R12: ffff8800cdb60000
[532284.564086] R13: 00000000167ee038 R14: ffff8800db3576d8 R15: 000080ee26ec7dcf
[532284.564086] FS:  00007fc30ecc7740(0000) GS:ffff88011b200000(0000) knlGS:0000000000000000
[532284.564086] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
[532284.564086] CR2: 0000000035c83420 CR3: 000000011f966000 CR4: 00000000000006e0
[532284.564086] Stack:
[532284.564086]  ffffffff810cae80 ffff880100000014 ffff8800db333480 000000000006086c
[532284.564086]  ffff8800cdb60068 ffff8800cdb60000 ffff8801167ee6a8 ffffffff810b948f
[532284.564086]  ffff8801167ee698 ffff8800cdb60068 ffff8800db333480 0000000000000001
[532284.564086] Call Trace:
[532284.564086]  [<ffffffff810cae80>] ? cpuacct_css_alloc+0xb0/0xb0
[532284.564086]  [<ffffffff810b948f>] update_curr+0x13f/0x220
[532284.564086]  [<ffffffff810bfeb4>] dequeue_entity+0x24/0x5b0
[532284.564086]  [<ffffffff8101ea59>] ? sched_clock+0x9/0x10
[532284.564086]  [<ffffffff810c0489>] dequeue_task_fair+0x49/0x430
[532284.564086]  [<ffffffff810acbb3>] dequeue_task+0x73/0x90
[532284.564086]  [<ffffffff810acbf3>] deactivate_task+0x23/0x30
[532284.564086]  [<ffffffff81745b11>] __schedule+0x501/0x960
[532284.564086]  [<ffffffff817460b9>] schedule+0x29/0x70
[532284.564086]  [<ffffffff81744eac>] schedule_timeout+0x14c/0x2a0
[532284.564086]  [<ffffffff810835f0>] ? del_timer+0x70/0x70
[532284.564086]  [<ffffffff8174b7d0>] ? _raw_spin_unlock_irqrestore+0x40/0x80
[532284.564086]  [<ffffffff8174547f>] io_schedule_timeout+0x9f/0x100
[532284.564086]  [<ffffffff810d16dd>] ? trace_hardirqs_on+0xd/0x10
[532284.564086]  [<ffffffff81182b22>] mempool_alloc+0x152/0x180
[532284.564086]  [<ffffffff810c56e0>] ? bit_waitqueue+0xd0/0xd0
[532284.564086]  [<ffffffff810558c7>] ? kvm_clock_read+0x27/0x40

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
