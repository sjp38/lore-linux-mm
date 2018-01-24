Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id A62D4800D8
	for <linux-mm@kvack.org>; Wed, 24 Jan 2018 18:57:44 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id i1so3449340pgv.22
        for <linux-mm@kvack.org>; Wed, 24 Jan 2018 15:57:44 -0800 (PST)
Received: from mail.ewheeler.net (mx.ewheeler.net. [66.155.3.69])
        by mx.google.com with ESMTP id m12-v6si942513pln.737.2018.01.24.15.57.43
        for <linux-mm@kvack.org>;
        Wed, 24 Jan 2018 15:57:43 -0800 (PST)
Received: from localhost (localhost [127.0.0.1])
	by mail.ewheeler.net (Postfix) with ESMTP id E177EA0674
	for <linux-mm@kvack.org>; Wed, 24 Jan 2018 23:57:42 +0000 (UTC)
Received: from mail.ewheeler.net ([127.0.0.1])
	by localhost (mail.ewheeler.net [127.0.0.1]) (amavisd-new, port 10024)
	with LMTP id BGbp9KEv9BTI for <linux-mm@kvack.org>;
	Wed, 24 Jan 2018 23:57:42 +0000 (UTC)
Received: from mx.ewheeler.net (mx.ewheeler.net [66.155.3.69])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mail.ewheeler.net (Postfix) with ESMTPSA id 871F6A066F
	for <linux-mm@kvack.org>; Wed, 24 Jan 2018 23:57:42 +0000 (UTC)
Date: Wed, 24 Jan 2018 23:57:42 +0000 (UTC)
From: Eric Wheeler <linux-mm@lists.ewheeler.net>
Subject: Possible deadlock in v4.14.15 contention on shrinker_rwsem in
 shrink_slab()
Message-ID: <alpine.LRH.2.11.1801242349220.30642@mail.ewheeler.net>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org

Hello all,

We are getting processes stuck with /proc/pid/stack listing the following:

[<ffffffffac0cd0d2>] io_schedule+0x12/0x40
[<ffffffffac1b4695>] __lock_page+0x105/0x150
[<ffffffffac1b4dc1>] pagecache_get_page+0x161/0x210
[<ffffffffac1d4ab4>] shmem_unused_huge_shrink+0x334/0x3f0
[<ffffffffac251546>] super_cache_scan+0x176/0x180
[<ffffffffac1cb6c5>] shrink_slab+0x275/0x460
[<ffffffffac1d0b8e>] shrink_node+0x10e/0x320
[<ffffffffac1d0f3d>] node_reclaim+0x19d/0x250
[<ffffffffac1be0aa>] get_page_from_freelist+0x16a/0xac0
[<ffffffffac1bed87>] __alloc_pages_nodemask+0x107/0x290
[<ffffffffac06dbc3>] pte_alloc_one+0x13/0x40
[<ffffffffac1ef329>] __pte_alloc+0x19/0x100
[<ffffffffac1f17b8>] alloc_set_pte+0x468/0x4c0
[<ffffffffac1f184a>] finish_fault+0x3a/0x70
[<ffffffffac1f369a>] __handle_mm_fault+0x94a/0x1190
[<ffffffffac1f3fa4>] handle_mm_fault+0xc4/0x1d0
[<ffffffffac0682a3>] __do_page_fault+0x253/0x4d0
[<ffffffffac068553>] do_page_fault+0x33/0x120
[<ffffffffac8019dc>] page_fault+0x4c/0x60


For some reason io_schedule is not coming back, so shrinker_rwsem never 
gets an up_read. When this happens, other processes like libvirt get stuck 
trying to start VMs with the /proc/pid/stack of libvirtd looking like so, 
while register_shrinker waits for shrinker_rwsem to be released:

[<ffffffffac7538d3>] call_rwsem_down_write_failed+0x13/0x20
[<ffffffffac1cb985>] register_shrinker+0x45/0xa0
[<ffffffffac250f68>] sget_userns+0x468/0x4a0
[<ffffffffac25106a>] mount_nodev+0x2a/0xa0
[<ffffffffac251be4>] mount_fs+0x34/0x150
[<ffffffffac2701f2>] vfs_kern_mount+0x62/0x120
[<ffffffffac272a0e>] do_mount+0x1ee/0xc50
[<ffffffffac27377e>] SyS_mount+0x7e/0xd0
[<ffffffffac003831>] do_syscall_64+0x61/0x1a0
[<ffffffffac80012c>] entry_SYSCALL64_slow_path+0x25/0x25
[<ffffffffffffffff>] 0xffffffffffffffff


I seem to be able to reproduce this somewhat reliably, it will likely be 
stuck by tomorrow morning. Since it does seem to take a day to hang, I was 
hoping to avoid a bisect and see if anyone has seen this behavior or knows 
it to be fixed in 4.15-rc.

Note that we are using zram as our only swap device, but at the time that 
it shrink_slab() failed to return, there was plenty of memory available 
and no swap was in use.

The machine is generally responsive, but `sync` will hang forever and our 
only way out is `echo b > /proc/sysrq-trigger`.

Please suggest any additional information you might need for testing, and 
I am happy to try patches.

Thank you for your help!

--
Eric Wheeler

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
