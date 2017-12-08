Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f198.google.com (mail-wr0-f198.google.com [209.85.128.198])
	by kanga.kvack.org (Postfix) with ESMTP id 34E5F6B0038
	for <linux-mm@kvack.org>; Fri,  8 Dec 2017 10:12:03 -0500 (EST)
Received: by mail-wr0-f198.google.com with SMTP id f4so6167184wre.9
        for <linux-mm@kvack.org>; Fri, 08 Dec 2017 07:12:03 -0800 (PST)
Received: from the.earth.li (the.earth.li. [2001:41c8:10:b1f:c0ff:ee:15:900d])
        by mx.google.com with ESMTPS id r2si1286200wmb.113.2017.12.08.07.12.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 08 Dec 2017 07:12:01 -0800 (PST)
Date: Fri, 8 Dec 2017 15:11:59 +0000
From: Jonathan McDowell <noodles@earth.li>
Subject: ACPI issues on cold power on [bisected]
Message-ID: <20171208151159.urdcrzl5qpfd6jnu@earth.li>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-acpi@vger.kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Joonsoo Kim <iamjoonsoo.kim@lge.com>

I've been sitting on this for a while and should have spent time to
investigate sooner, but it's been an odd failure mode that wasn't quite
obvious.

In 4.9 if I cold power on my laptop (Dell E7240) it fails to boot - I
don't see anything after grub says its booting. In 4.10 onwards the
laptop boots, but I get an Oops as part of the boot and ACPI is unhappy
(no suspend, no clean poweroff, no ACPI buttons). The Oops is below;
taken from 4.12 as that's the most recent error dmesg I have saved but
also seen back in 4.10. It's always address 0x30 for the dereference.

Rebooting the laptop does not lead to these problems; it's *only* from a
complete cold boot that they arise (which didn't help me in terms of
being able to reliably bisect). Once I realised that I was able to
bisect, but it leads me to an odd commit:

86d9f48534e800e4d62cdc1b5aaf539f4c1d47d6
(mm/slab: fix kmemcg cache creation delayed issue)

If I revert this then I can cold boot without problems.

Also I don't see the problem with a stock Debian kernel, I think because
the ACPI support is modularised.

Config, dmesg + bisect log at:

https://the.earth.li/~noodles/acpi-problem/

-------
BUG: unable to handle kernel NULL pointer dereference at 0000000000000030
IP: netlink_broadcast_filtered+0x1d/0x3e0
PGD 0 
P4D 0 

Oops: 0000 [#1] SMP
Modules linked in:
CPU: 0 PID: 41 Comm: kworker/0:1 Not tainted 4.12.0 #1
Hardware name: Dell Inc. Latitude E7240/07RPNV, BIOS A21 05/08/2017
Workqueue: kacpi_notify acpi_os_execute_deferred
task: ffff914e4c321240 task.stack: ffffa3bd4017c000
RIP: 0010:netlink_broadcast_filtered+0x1d/0x3e0
RSP: 0000:ffffa3bd4017fd90 EFLAGS: 00010286
RAX: 0000000000000001 RBX: ffff914e4c82b300 RCX: 0000000000000000
RDX: 0000000000000000 RSI: 0000000001080020 RDI: ffff914e4c82b300
RBP: ffff914e4c305614 R08: 0000000001080020 R09: 0000000000000000
R10: 0000000000000014 R11: ffffffffb8a31d40 R12: 0000000000000000
R13: 0000000000000000 R14: ffff914e4c305614 R15: 0000000000000000
FS:  0000000000000000(0000) GS:ffff914e5ea00000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 0000000000000030 CR3: 0000000236c09000 CR4: 00000000001406f0
Call Trace:
 ? __kmalloc_reserve.isra.37+0x24/0x70
 ? __nlmsg_put+0x63/0x80
 ? netlink_broadcast+0xa/0x10
 ? acpi_bus_generate_netlink_event+0x10d/0x150
 ? acpi_ev_notify_dispatch+0x37/0x4c
 ? acpi_os_execute_deferred+0xb/0x20
 ? process_one_work+0x1cf/0x3c0
 ? worker_thread+0x42/0x3c0
 ? __schedule+0x26c/0x660
 ? kthread+0xf7/0x130
 ? create_worker+0x190/0x190
 ? kthread_create_on_node+0x40/0x40
 ? ret_from_fork+0x22/0x30
Code: c8 c3 66 90 66 2e 0f 1f 84 00 00 00 00 00 41 57 41 89 cf 41 56 41 55 49 89 fd 48 89 f7 44 89 c6 41 54 41 89 d4 55 53 48 83 ec 38 <49> 8b 6d 30 44 89 44 24 24 4c 89 4c 24 28 e8 a0 ec ff ff 48 c7 
RIP: netlink_broadcast_filtered+0x1d/0x3e0 RSP: ffffa3bd4017fd90
CR2: 0000000000000030
---[ end trace f8e25281792d4743 ]---

J.

-- 
/-\                             | 101 things you can't have too much
|@/  Debian GNU/Linux Developer |       of : 47 - More coffee.
\-                              |

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
