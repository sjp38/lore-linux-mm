Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 6B9C56B00A5
	for <linux-mm@kvack.org>; Mon, 18 Oct 2010 21:41:49 -0400 (EDT)
Received: from hch by bombadil.infradead.org with local (Exim 4.72 #1 (Red Hat Linux))
	id 1P818M-00013c-3X
	for linux-mm@kvack.org; Tue, 19 Oct 2010 01:36:58 +0000
Date: Mon, 18 Oct 2010 21:36:58 -0400
From: Christoph Hellwig <hch@infradead.org>
Subject: BUG in __insert_vmap_area
Message-ID: <20101019013658.GA4065@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

I just saw one of my VMs crashing after repeated xfstests runs.  It's
not the first set of runs I did on a -rc7 based kernel, so I'm not
sure how reproducible it will be:

[18890.464953] XFS mounting filesystem vdb5
[18890.466396] ------------[ cut here ]------------
[18890.467750] kernel BUG at /home/hch/work/linux-2.6/mm/vmalloc.c:305!
[18890.468879] invalid opcode: 0000 [#1] SMP 
[18890.468879] last sysfs file: /sys/devices/virtio-pci/virtio1/block/vdb/removable
[18890.468879] Modules linked in:
[18890.468879] 
[18890.468879] Pid: 12074, comm: mount Not tainted 2.6.36-rc7+ #427 /Bochs
[18890.468879] EIP: 0060:[<c01fccf7>] EFLAGS: 00010207 CPU: 0
[18890.468879] EIP is at __insert_vmap_area+0x87/0xb0
[18890.468879] EAX: d1b3755c EBX: c61513f0 ECX: 00000000 EDX: 00000000
[18890.468879] ESI: 00100000 EDI: fff00000 EBP: f4f5fcbc ESP: f4f5fcb4
[18890.468879]  DS: 007b ES: 007b FS: 00d8 GS: 0033 SS: 0068
[18890.468879] Process mount (pid: 12074, ti=f4f5e000 task=f4dbae70 task.ti=f4f5e000)
[18890.468879] Stack:
[18890.468879]  f8800000 00100000 f4f5fd0c c01fdfa2 00000000 00000000 00000246 000fffff
[18890.468879] <0> c61513f0 c61513f0 f8800000 f88fffff 00100000 f8900000 00000000 000fffff
[18890.468879] <0> fff00000 c01fe22d 00000246 f36d6148 00000003 f36d6148 f4f5fd5c c01fe288
[18890.468879] Call Trace:
[18890.468879]  [<c01fdfa2>] ? alloc_vmap_area+0x1f2/0x2e0
[18890.468879]  [<c01fe22d>] ? vm_map_ram+0x19d/0x470
[18890.468879]  [<c01fe288>] ? vm_map_ram+0x1f8/0x470
[18890.468879]  [<c01fe0f8>] ? vm_map_ram+0x68/0x470
[18890.468879]  [<c052da81>] ? _xfs_buf_map_pages+0x81/0xb0
[18890.468879]  [<c052dbe7>] ? xfs_buf_get_noaddr+0x137/0x190
[18890.468879]  [<c0513f3f>] ? xlog_alloc_log+0x18f/0x460
[18890.468879]  [<c0514265>] ? xfs_log_mount+0x55/0x180
[18890.468879]  [<c051ff48>] ? xfs_mountfs+0x348/0x6d0
[18890.468879]  [<c0176193>] ? __init_timer+0x63/0x70
[18890.468879]  [<c01761d3>] ? init_timer_key+0x33/0x70
[18890.468879]  [<c0520976>] ? xfs_mru_cache_create+0x126/0x160
[18890.468879]  [<c05365a5>] ? xfs_fs_fill_super+0x1a5/0x320
[18890.468879]  [<c02135e0>] ? get_sb_bdev+0x160/0x1a0
[18890.468879]  [<c0534371>] ? xfs_fs_get_sb+0x21/0x30
[18890.468879]  [<c0536400>] ? xfs_fs_fill_super+0x0/0x320
[18890.468879]  [<c02120c8>] ? vfs_kern_mount+0x48/0x110
[18890.468879]  [<c02121e9>] ? do_kern_mount+0x39/0xd0
[18890.468879]  [<c0229542>] ? do_mount+0x2d2/0x700
[18890.468879]  [<c01ee2d9>] ? strndup_user+0x49/0x60
[18890.468879]  [<c02299d6>] ? sys_mount+0x66/0xa0
[18890.468879]  [<c09e4bfd>] ? syscall_call+0x7/0xb
[18890.468879] Code: 0c 8b 56 18 8d 4b 18 89 43 1c 89 53 18 89 4e 18 89 4a 04 5b 5e 5d c3 90 8d 74 26 00 8b 53 04 3b 50 f4 76 07 8d 50 04 89 c1 eb 9d <0f> 0b eb fe a1 a4 d4 d6 c0 8d 53 18 c7 43 1c a4 d4 d6 c0 89 43

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
