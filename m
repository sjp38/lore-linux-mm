Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id 9EE876B0062
	for <linux-mm@kvack.org>; Thu, 20 Feb 2014 01:34:54 -0500 (EST)
Received: by mail-pa0-f51.google.com with SMTP id ld10so1500370pab.38
        for <linux-mm@kvack.org>; Wed, 19 Feb 2014 22:34:54 -0800 (PST)
Received: from ipmail04.adl6.internode.on.net (ipmail04.adl6.internode.on.net. [2001:44b8:8060:ff02:300:1:6:4])
        by mx.google.com with ESMTP id gp2si2165202pac.99.2014.02.19.22.34.52
        for <linux-mm@kvack.org>;
        Wed, 19 Feb 2014 22:34:53 -0800 (PST)
Date: Thu, 20 Feb 2014 17:34:30 +1100
From: Dave Chinner <david@fromorbit.com>
Subject: Re: Thread overran stack, or stack corrupted on 3.13.0
Message-ID: <20140220063430.GO13647@dastard>
References: <20140205151817.GA28502@paralelels.com>
 <alpine.DEB.2.02.1402051323100.14325@chino.kir.corp.google.com>
 <20140205221013.GA8794@paralelels.com>
 <alpine.DEB.2.02.1402051418140.18942@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1402051418140.18942@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Vagin <avagin@parallels.com>, Kent Overstreet <kmo@daterainc.com>, Jens Axboe <axboe@kernel.dk>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, Feb 05, 2014 at 02:19:32PM -0800, David Rientjes wrote:
> On Thu, 6 Feb 2014, Andrew Vagin wrote:
> 
> > [532284.563576] BUG: unable to handle kernel paging request at 0000000035c83420
> > [532284.564086] IP: [<ffffffff810caf17>] cpuacct_charge+0x97/0x1e0
> > [532284.564086] PGD 116369067 PUD 116368067 PMD 0
> > [532284.564086] Thread overran stack, or stack corrupted
> > [532284.564086] Oops: 0000 [#1] SMP
> > [532284.564086] Modules linked in: veth binfmt_misc ip6table_filter ip6_tables tun netlink_diag af_packet_diag udp_diag tcp_diag inet_diag unix_diag bridge stp llc btrfs libcrc32c xor raid6_pq microcode i2c_piix4 joydev virtio_balloon virtio_net pcspkr i2c_core virtio_blk virtio_pci virtio_ring virtio floppy
> > [532284.564086] CPU: 2 PID: 2487 Comm: cat Not tainted 3.13.0 #160
> > [532284.564086] Hardware name: Red Hat KVM, BIOS 0.5.1 01/01/2007
> > [532284.564086] task: ffff8800cdb60000 ti: ffff8801167ee000 task.ti: ffff8801167ee000
> > [532284.564086] RIP: 0010:[<ffffffff810caf17>]  [<ffffffff810caf17>] cpuacct_charge+0x97/0x1e0
> > [532284.564086] RSP: 0018:ffff8801167ee638  EFLAGS: 00010002
> > [532284.564086] RAX: 000000000000e540 RBX: 000000000006086c RCX: 000000000000000f
> > [532284.564086] RDX: ffffffff81c4e960 RSI: ffffffff81c50640 RDI: 0000000000000046
> > [532284.564086] RBP: ffff8801167ee668 R08: 0000000000000003 R09: 0000000000000001
> > [532284.564086] R10: 0000000000000001 R11: 0000000000000004 R12: ffff8800cdb60000
> > [532284.564086] R13: 00000000167ee038 R14: ffff8800db3576d8 R15: 000080ee26ec7dcf
> > [532284.564086] FS:  00007fc30ecc7740(0000) GS:ffff88011b200000(0000) knlGS:0000000000000000
> > [532284.564086] CS:  0010 DS: 0000 ES: 0000 CR0: 000000008005003b
> > [532284.564086] CR2: 0000000035c83420 CR3: 000000011f966000 CR4: 00000000000006e0
> > [532284.564086] Stack:
> > [532284.564086]  ffffffff810cae80 ffff880100000014 ffff8800db333480 000000000006086c
> > [532284.564086]  ffff8800cdb60068 ffff8800cdb60000 ffff8801167ee6a8 ffffffff810b948f
> > [532284.564086]  ffff8801167ee698 ffff8800cdb60068 ffff8800db333480 0000000000000001
> > [532284.564086] Call Trace:
> > [532284.564086]  [<ffffffff810cae80>] ? cpuacct_css_alloc+0xb0/0xb0
> > [532284.564086]  [<ffffffff810b948f>] update_curr+0x13f/0x220
> > [532284.564086]  [<ffffffff810bfeb4>] dequeue_entity+0x24/0x5b0
> > [532284.564086]  [<ffffffff8101ea59>] ? sched_clock+0x9/0x10
> > [532284.564086]  [<ffffffff810c0489>] dequeue_task_fair+0x49/0x430
> > [532284.564086]  [<ffffffff810acbb3>] dequeue_task+0x73/0x90
> > [532284.564086]  [<ffffffff810acbf3>] deactivate_task+0x23/0x30
> > [532284.564086]  [<ffffffff81745b11>] __schedule+0x501/0x960
> > [532284.564086]  [<ffffffff817460b9>] schedule+0x29/0x70
> > [532284.564086]  [<ffffffff81744eac>] schedule_timeout+0x14c/0x2a0
> > [532284.564086]  [<ffffffff810835f0>] ? del_timer+0x70/0x70
> > [532284.564086]  [<ffffffff8174b7d0>] ? _raw_spin_unlock_irqrestore+0x40/0x80
> > [532284.564086]  [<ffffffff8174547f>] io_schedule_timeout+0x9f/0x100
> > [532284.564086]  [<ffffffff810d16dd>] ? trace_hardirqs_on+0xd/0x10
> > [532284.564086]  [<ffffffff81182b22>] mempool_alloc+0x152/0x180
> > [532284.564086]  [<ffffffff810c56e0>] ? bit_waitqueue+0xd0/0xd0
> > [532284.564086]  [<ffffffff810558c7>] ? kvm_clock_read+0x27/0x40
> > [532284.564086]  [<ffffffff8123c89b>] bio_alloc_bioset+0x10b/0x1e0
> > [532284.564086]  [<ffffffff811c2f00>] ? end_swap_bio_read+0xc0/0xc0
> > [532284.564086]  [<ffffffff811c2f00>] ? end_swap_bio_read+0xc0/0xc0
> > [532284.564086]  [<ffffffff811c2810>] get_swap_bio+0x30/0x90
> > [532284.564086]  [<ffffffff811c2f00>] ? end_swap_bio_read+0xc0/0xc0
> > [532284.564086]  [<ffffffff811c2aa0>] __swap_writepage+0x150/0x230
> > [532284.564086]  [<ffffffff8174b83b>] ? _raw_spin_unlock+0x2b/0x40
> > [532284.564086]  [<ffffffff811c43b3>] ? page_swapcount+0x53/0x70
> > [532284.564086]  [<ffffffff811c2bc3>] swap_writepage+0x43/0x90
> > [532284.564086]  [<ffffffff81194faf>] shrink_page_list+0x6cf/0xaa0
> > [532284.564086]  [<ffffffff81196022>] shrink_inactive_list+0x1c2/0x5b0
> > [532284.564086]  [<ffffffff810d1c59>] ? __lock_acquire+0x249/0x1800
> > [532284.564086]  [<ffffffff81196a75>] shrink_lruvec+0x335/0x600
> > [532284.564086]  [<ffffffff811ecd45>] ? mem_cgroup_iter+0x1f5/0x510
> > [532284.564086]  [<ffffffff81196dd6>] shrink_zone+0x96/0x1d0
> > [532284.564086]  [<ffffffff81197853>] do_try_to_free_pages+0x103/0x600
> > [532284.564086]  [<ffffffff81184b2f>] ? zone_watermark_ok+0x1f/0x30
> > [532284.564086]  [<ffffffff8119811c>] try_to_free_pages+0xdc/0x230
> > [532284.564086]  [<ffffffff81187dfd>] ? drain_pages+0xad/0xe0
> > [532284.564086]  [<ffffffff8118ad94>] __alloc_pages_nodemask+0xa14/0xc90
> > [532284.564086]  [<ffffffff810b5d35>] ? sched_clock_local+0x25/0x90
> > [532284.564086]  [<ffffffff811d1f36>] alloc_pages_current+0x126/0x200
> > [532284.564086]  [<ffffffff811d97f5>] ? new_slab+0x2e5/0x390
> > [532284.564086]  [<ffffffff811d97dd>] ? new_slab+0x2cd/0x390
> > [532284.564086]  [<ffffffff811d97f5>] new_slab+0x2e5/0x390
> > [532284.564086]  [<ffffffff811dc553>] __slab_alloc+0x3f3/0x700
> > [532284.564086]  [<ffffffff811dd0ff>] ? kmem_cache_alloc+0x27f/0x2a0
> > [532284.564086]  [<ffffffff810b5e58>] ? sched_clock_cpu+0xb8/0x110
> > [532284.564086]  [<ffffffff811828c5>] ? mempool_alloc_slab+0x15/0x20
> > [532284.564086]  [<ffffffff811e98ae>] ? rcu_read_unlock+0x2e/0x70
> > [532284.564086]  [<ffffffff811f06e8>] ? __memcg_kmem_get_cache+0x58/0x2b0
> > [532284.564086]  [<ffffffff811dd0ff>] kmem_cache_alloc+0x27f/0x2a0
> > [532284.564086]  [<ffffffff811828c5>] ? mempool_alloc_slab+0x15/0x20
> > [532284.564086]  [<ffffffff811828c5>] mempool_alloc_slab+0x15/0x20
> > [532284.564086]  [<ffffffff81182a30>] mempool_alloc+0x60/0x180
> > [532284.564086]  [<ffffffff8123c89b>] bio_alloc_bioset+0x10b/0x1e0
> > [532284.564086]  [<ffffffff8124366b>] mpage_alloc+0x3b/0xa0
> > [532284.564086]  [<ffffffff81243b69>] do_mpage_readpage+0x329/0x650
> > [532284.564086]  [<ffffffff8117fa5f>] ? add_to_page_cache_locked+0x10f/0x200
> > [532284.564086]  [<ffffffff81243fe9>] mpage_readpages+0xe9/0x140
> > [532284.564086]  [<ffffffff81296f10>] ? ext4_get_block_write+0x20/0x20
> > [532284.564086]  [<ffffffff81296f10>] ? ext4_get_block_write+0x20/0x20
> > [532284.564086]  [<ffffffff81295877>] ext4_readpages+0x47/0x60
> > [532284.564086]  [<ffffffff8118e918>] __do_page_cache_readahead+0x2c8/0x370
> > [532284.564086]  [<ffffffff8118e76b>] ? __do_page_cache_readahead+0x11b/0x370
> > [532284.564086]  [<ffffffff810b5e58>] ? sched_clock_cpu+0xb8/0x110
> > [532284.564086]  [<ffffffff81180aa0>] ? find_get_pages_tag+0x330/0x330
> > [532284.564086]  [<ffffffff8118e9e1>] ra_submit+0x21/0x30
> > [532284.564086]  [<ffffffff811814e2>] filemap_fault+0x372/0x480
> > [532284.564086]  [<ffffffff811afdf2>] __do_fault+0x72/0x5c0
> > [532284.564086]  [<ffffffff811b06e6>] handle_mm_fault+0x3a6/0xf10
> > [532284.564086]  [<ffffffff8174fc2f>] ? __do_page_fault+0x14f/0x530
> > [532284.564086]  [<ffffffff8174fca1>] __do_page_fault+0x1c1/0x530
> > [532284.564086]  [<ffffffff8101ea59>] ? sched_clock+0x9/0x10
> > [532284.564086]  [<ffffffff810b5d35>] ? sched_clock_local+0x25/0x90
> > [532284.564086]  [<ffffffff810b5e58>] ? sched_clock_cpu+0xb8/0x110
> > [532284.564086]  [<ffffffff810ccd4d>] ? trace_hardirqs_off+0xd/0x10
> > [532284.564086]  [<ffffffff810b5f1f>] ? local_clock+0x6f/0x80
> > [532284.564086]  [<ffffffff810d0c55>] ? lock_release_holdtime+0x35/0x1a0
> > [532284.564086]  [<ffffffff81393bbd>] ? trace_hardirqs_off_thunk+0x3a/0x3c
> > [532284.564086]  [<ffffffff817501ae>] do_page_fault+0xe/0x10
> > [532284.564086]  [<ffffffff8174c078>] page_fault+0x28/0x30
> > [532284.564086]  [<ffffffff81393e42>] ? __clear_user+0x42/0x70
> > [532284.564086]  [<ffffffff81393e21>] ? __clear_user+0x21/0x70
> > [532284.564086]  [<ffffffff81393ea8>] clear_user+0x38/0x40
> > [532284.564086]  [<ffffffff8125dbfd>] padzero+0x2d/0x40
> > [532284.564086]  [<ffffffff8125e7ea>] load_elf_binary+0x8ca/0x1d40
> > [532284.564086]  [<ffffffff810b5e58>] ? sched_clock_cpu+0xb8/0x110
> > [532284.564086]  [<ffffffff810d0c55>] ? lock_release_holdtime+0x35/0x1a0
> > [532284.564086]  [<ffffffff810558c7>] ? kvm_clock_read+0x27/0x40
> > [532284.564086]  [<ffffffff8101ea59>] ? sched_clock+0x9/0x10
> > [532284.564086]  [<ffffffff810b5d35>] ? sched_clock_local+0x25/0x90
> > [532284.564086]  [<ffffffff81203fd3>] search_binary_handler+0xb3/0x1c0
> > [532284.564086]  [<ffffffff8109bdf0>] ? get_pid_task+0x120/0x120
> > [532284.564086]  [<ffffffff81205ecd>] do_execve_common+0x71d/0x990
> > [532284.564086]  [<ffffffff81205e14>] ? do_execve_common+0x664/0x990
> > [532284.564086]  [<ffffffff81206207>] do_execve+0x37/0x40
> > [532284.564086]  [<ffffffff8120624d>] SyS_execve+0x3d/0x60
> > [532284.564086]  [<ffffffff81755759>] stub_execve+0x69/0xa0
> > [532284.564086] Code: 00 00 e8 5d 03 02 00 85 c0 74 0d 80 3d e6 bc c2 00 00 0f 84 d4 00 00 00 49 8b 56 48 4d 63 ed 0f 1f 44 00 00 48 8b 82 b8 00 00 00 <4a> 03 04 ed 60 32 d1 81 48 01 18 48 8b 52 40 48 85 d2 75 e5 e8
> > [532284.564086] RIP  [<ffffffff810caf17>] cpuacct_charge+0x97/0x1e0
> > [532284.564086]  RSP <ffff8801167ee638>
> > [532284.564086] CR2: 0000000035c83420
> > 
> > 
> 
> Looks like bio_alloc_bioset() recursion.  Adding Kent Overstreet and Jens 
> for ideas.

Actually, I'd say it's a bug in do_mpage_readpage, as it's using
GFP_KERNEL allocation when it calls bio_alloc(), so it's telling
memory reclaim that IO recursion is just fine. I'd guess that
allocation a bio in a filesystem layer should be GFP_NOFS or
GFP_NOIO context to avoid this....

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
