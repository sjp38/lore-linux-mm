Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 865D46B0003
	for <linux-mm@kvack.org>; Mon,  9 Apr 2018 17:18:18 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id t1-v6so7794673plb.5
        for <linux-mm@kvack.org>; Mon, 09 Apr 2018 14:18:18 -0700 (PDT)
Received: from smtp2.provo.novell.com (smtp2.provo.novell.com. [137.65.250.81])
        by mx.google.com with ESMTPS id w2si748286pgt.485.2018.04.09.14.18.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 09 Apr 2018 14:18:17 -0700 (PDT)
From: Goldwyn Rodrigues <rgoldwyn@suse.com>
Subject: [PATCH v10 00/62] Convert page cache to XArray
References: <20180330034245.10462-1-willy@infradead.org>
Message-ID: <a27d5689-49d9-2802-3819-afd0f1f98483@suse.com>
Date: Mon, 9 Apr 2018 16:18:07 -0500
MIME-Version: 1.0
In-Reply-To: <20180330034245.10462-1-willy@infradead.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>, Jan Kara <jack@suse.cz>, Jeff Layton <jlayton@redhat.com>, Lukas Czerner <lczerner@redhat.com>, Ross Zwisler <ross.zwisler@linux.intel.com>, Christoph Hellwig <hch@lst.de>, Nicholas Piggin <npiggin@gmail.com>, Ryusuke Konishi <konishi.ryusuke@lab.ntt.co.jp>, linux-nilfs@vger.kernel.org, Jaegeuk Kim <jaegeuk@kernel.org>, Chao Yu <yuchao0@huawei.com>, linux-f2fs-devel@lists.sourceforge.net, Oleg Drokin <oleg.drokin@intel.com>, Andreas Dilger <andreas.dilger@intel.com>, James Simmons <jsimmons@infradead.org>, Mike Kravetz <mike.kravetz@oracle.com>

Hi Matthew,

On 03/29/2018 10:41 PM, Matthew Wilcox wrote:
> From: Matthew Wilcox <mawilcox@microsoft.com>
> 
> I'd like to thank Andrew for taking the first eight XArray patches
> into -next.  He's understandably nervous about taking the rest of the
> patches into -next given how few of the remaining patches have review
> tags on them.  So ... if you're on the cc, I'd really appreciate a review
> on something that you feel somewhat responsible for, eg the particular
> filesystem (nilfs, f2fs, lustre) that I've touched, or something in the
> mm/ or fs/ directories that you've worked on recently.
> 
> This is against next-20180329.

I tried these patches against next-20180329 and added the patch for the
bug reported by Mike Kravetz. I am getting the following BUG on ext4 and
xfs, running generic/048 tests of fstests. Each trace is from a
different instance/run.

BTW, for my convenience, do you have these patches in a public git tree?

[  222.007071] BUG: Bad page state in process kswapd0  pfn:132f25
[  222.007108] page:ffffd6f144cbc940 count:0 mapcount:0
mapping:ffff94b2735e3918 index:0x1
[  222.007140] flags: 0x4000000000000000()
[  222.007157] raw: 4000000000000000 ffff94b2735e3918 0000000000000001
00000000ffffffff
[  222.007186] raw: dead000000000100 dead000000000200 0000000000000000
0000000000000000
[  222.007216] page dumped because: non-NULL mapping
[  222.007288] CPU: 0 PID: 55 Comm: kswapd0 Tainted: G            E
4.16.0-rc7-next-20180329-xarray #2
[  222.007289] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996),
BIOS 1.0.0-prebuilt.qemu-project.org 04/01/2014
[  222.007290] Call Trace:
[  222.007297]  dump_stack+0x63/0x85
[  222.007300]  bad_page+0xd5/0x140
[  222.007302]  free_pages_check_bad+0x5f/0x70
[  222.007304]  free_pcppages_bulk+0x423/0x5c0
[  222.007308]  ? xas_load+0x3d/0xc0
[  222.007310]  free_unref_page_commit+0xad/0xd0
[  222.007312]  free_unref_page_list+0x101/0x190
[  222.007315]  release_pages+0x17c/0x3f0
[  222.007317]  __pagevec_release+0x2f/0x40
[  222.007319]  invalidate_mapping_pages+0x2d8/0x310
[  222.007323]  ? memcg_drain_all_list_lrus+0x120/0x120
[  222.007326]  inode_lru_isolate+0x131/0x180
[  222.007328]  __list_lru_walk_one.isra.7+0x92/0x150
[  222.007329]  ? iput+0x220/0x220
[  222.007331]  list_lru_walk_one+0x23/0x30
[  222.007332]  prune_icache_sb+0x40/0x60
[  222.007334]  super_cache_scan+0x137/0x1b0
[  222.007336]  shrink_slab.part.53+0x1ae/0x3a0
[  222.007338]  shrink_slab+0x35/0x40
[  222.007340]  shrink_node+0x158/0x490
[  222.007342]  balance_pgdat+0x149/0x320
[  222.007344]  kswapd+0x15f/0x400
[  222.007347]  ? wait_woken+0x80/0x80
[  222.007350]  kthread+0x121/0x140
[  222.007352]  ? balance_pgdat+0x320/0x320
[  222.007353]  ? kthread_create_worker_on_cpu+0x50/0x50
[  222.007356]  ret_from_fork+0x35/0x40
[  222.007357] Disabling lock debugging due to kernel taint




17252.906122] ------------[ cut here ]------------
[17252.906124] kernel BUG at fs/inode.c:512!
[17252.906150] invalid opcode: 0000 [#1] SMP PTI
[17252.906467] CPU: 2 PID: 31588 Comm: umount Tainted: G            E
 4.16.0-rc7-next-20180329-xarray #2
[17252.906492] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996),
BIOS 1.0.0-prebuilt.qemu-project.org 04/01/2014
[17252.906523] RIP: 0010:clear_inode+0x8a/0xa0
[17252.906536] RSP: 0018:ffffba2302213d28 EFLAGS: 00010086
[17252.906552] RAX: 0000000000000000 RBX: ffff8f1efb3976d8 RCX:
0000000000000000
[17252.906571] RDX: 0000000000000001 RSI: ffffffffffffffff RDI:
ffff8f1efb397858
[17252.906590] RBP: ffffba2302213d38 R08: 0000000000000000 R09:
0000000000000000
[17252.906609] R10: ffffba2302213ae8 R11: ffffba2302213ae8 R12:
ffff8f1efb397858
[17252.906628] R13: ffffffffc067e580 R14: ffff8f1dcc4281e8 R15:
ffff8f1ef9fddc68
[17252.906648] FS:  00007f6b9eae0fc0(0000) GS:ffff8f1effd00000(0000)
knlGS:0000000000000000
[17252.906670] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[17252.906686] CR2: 000055927e5f2118 CR3: 00000000ab29a000 CR4:
00000000000006e0
[17252.906708] DR0: 0000000000000000 DR1: 0000000000000000 DR2:
0000000000000000
[17252.906728] DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7:
0000000000000400
[17252.906747] Call Trace:
[17252.906786]  ext4_clear_inode+0x1a/0x80 [ext4]
[17252.906808]  ext4_evict_inode+0x54/0x590 [ext4]
[17252.906823]  evict+0xca/0x1a0
[17252.906833]  dispose_list+0x39/0x50
[17252.906844]  evict_inodes+0x158/0x170
[17252.906857]  generic_shutdown_super+0x44/0x120
[17252.906871]  kill_block_super+0x27/0x50
[17252.906883]  deactivate_locked_super+0x48/0x80
[17252.906897]  deactivate_super+0x40/0x60
[17252.906910]  cleanup_mnt+0x3f/0x80
[17252.906921]  __cleanup_mnt+0x12/0x20
[17252.906933]  task_work_run+0x9d/0xc0
[17252.907593]  exit_to_usermode_loop+0xa5/0xb0
[17252.908237]  do_syscall_64+0x14a/0x1e0
[17252.908884]  entry_SYSCALL_64_after_hwframe+0x3d/0xa2
[17252.909522] RIP: 0033:0x7f6b9e3b2a57
[17252.910154] RSP: 002b:00007ffff1d2e6f8 EFLAGS: 00000246 ORIG_RAX:
00000000000000a6
[17252.910810] RAX: 0000000000000000 RBX: 000055927e5e7970 RCX:
00007f6b9e3b2a57
[17252.911462] RDX: 0000000000000001 RSI: 0000000000000000 RDI:
000055927e5f08b0
[17252.912109] RBP: 0000000000000000 R08: 0000000000000004 R09:
00000000ffffffff
[17252.912765] R10: 000055927e5f08d0 R11: 0000000000000246 R12:
000055927e5f08b0
[17252.913420] R13: 00007f6b9e8cd1c4 R14: 000055927e5e7b50 R15:
0000000000000000
[17252.914053] Code: 74 2d a8 40 75 2b 48 8b 83 30 01 00 00 48 8d 93 30
01 00 00 48 39 c2 75 1a 48 c7 83 a0 00 00 00 60 00 00 00 5b 41 5c 5d c3
0f 0b <0f> 0b 0f 0b 0f 0b 0f 0b 0f 0b 66 90 66 2e 0f 1f 84 00 00 00 00
[17252.915348] RIP: clear_inode+0x8a/0xa0 RSP: ffffba2302213d28
[17252.915968] ---[ end trace eca08dd7383f4777 ]---

And with xfs:

[  818.192680] ------------[ cut here ]------------
[  818.192682] kernel BUG at fs/inode.c:512!
[  818.192710] invalid opcode: 0000 [#1] SMP PTI
[  818.193034] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996),
BIOS 1.0.0-prebuilt.qemu-project.org 04/01/2014
[  818.193063] RIP: 0010:clear_inode+0x8a/0xa0
[  818.193075] RSP: 0018:ffffa8ced21cbd70 EFLAGS: 00010086
[  818.193090] RAX: 0000000000000000 RBX: ffff933521e294f8 RCX:
0000000000000000
[  818.193108] RDX: 0000000000000001 RSI: ffffffffffffffff RDI:
ffff933521e29678
[  818.193127] RBP: ffffa8ced21cbd80 R08: 0000000000000000 R09:
0000000000000000
[  818.193145] R10: ffffa8ced21cbb18 R11: ffffa8ced21cbb18 R12:
ffff933521e29678
[  818.193164] R13: ffffffffc0921920 R14: ffff9334afd1f8b8 R15:
ffff933523592c68
[  818.193183] FS:  00007f3da7d1dfc0(0000) GS:ffff93353fd80000(0000)
knlGS:0000000000000000
[  818.193203] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
[  818.193219] CR2: 00005577f6a42118 CR3: 00000000b52ae000 CR4:
00000000000006e0
[  818.193241] DR0: 0000000000000000 DR1: 0000000000000000 DR2:
0000000000000000
[  818.193260] DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7:
0000000000000400
[  818.193278] Call Trace:
[  818.193290]  evict+0x190/0x1a0
[  818.193300]  dispose_list+0x39/0x50
[  818.193311]  evict_inodes+0x158/0x170
[  818.193324]  generic_shutdown_super+0x44/0x120
[  818.193337]  kill_block_super+0x27/0x50
[  818.193349]  deactivate_locked_super+0x48/0x80
[  818.193362]  deactivate_super+0x40/0x60
[  818.193374]  cleanup_mnt+0x3f/0x80
[  818.193385]  __cleanup_mnt+0x12/0x20
[  818.193397]  task_work_run+0x9d/0xc0
[  818.193410]  exit_to_usermode_loop+0xa5/0xb0
[  818.193423]  do_syscall_64+0x14a/0x1e0
[  818.193435]  entry_SYSCALL_64_after_hwframe+0x3d/0xa2
[  818.193450] RIP: 0033:0x7f3da75efa57
[  818.194081] RSP: 002b:00007fff9bf60d08 EFLAGS: 00000246 ORIG_RAX:
00000000000000a6
[  818.194724] RAX: 0000000000000000 RBX: 00005577f6a37970 RCX:
00007f3da75efa57
[  818.195328] RDX: 0000000000000001 RSI: 0000000000000000 RDI:
00005577f6a40ff0
[  818.195937] RBP: 0000000000000000 R08: 0000000000000003 R09:
00000000ffffffff
[  818.196540] R10: 00005577f6a41010 R11: 0000000000000246 R12:
00005577f6a40ff0
[  818.197150] R13: 00007f3da7b0a1c4 R14: 00005577f6a37b50 R15:
0000000000000000
[  818.197761] Code: 74 2d a8 40 75 2b 48 8b 83 30 01 00 00 48 8d 93 30
01 00 00 48 39 c2 75 1a 48 c7 83 a0 00 00 00 60 00 00 00 5b 41 5c 5d c3
0f 0b <0f> 0b 0f 0b 0f 0b 0f 0b 0f 0b 66 90 66 2e 0f 1f 84 00 00 00 00
[  818.198996] RIP: clear_inode+0x8a/0xa0 RSP: ffffa8ced21cbd70
[  818.199556] ---[ end trace d7d41ef1791143ea ]---
[ 1976.784393] ------------[ cut here ]------------




-- 
Goldwyn
