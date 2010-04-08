Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 5735B600337
	for <linux-mm@kvack.org>; Thu,  8 Apr 2010 10:45:29 -0400 (EDT)
Message-ID: <4BBDEC9A.9070903@humyo.com>
Date: Thu, 08 Apr 2010 15:47:54 +0100
From: John Berthels <john@humyo.com>
MIME-Version: 1.0
Subject: Re: PROBLEM + POSS FIX: kernel stack overflow, xfs, many disks, heavy
 write load, 8k stack, x86-64
References: <4BBC6719.7080304@humyo.com> <20100407140523.GJ11036@dastard> <4BBCAB57.3000106@humyo.com> <20100407234341.GK11036@dastard> <20100408030347.GM11036@dastard> <4BBDC92D.8060503@humyo.com>
In-Reply-To: <4BBDC92D.8060503@humyo.com>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Dave Chinner <david@fromorbit.com>
Cc: linux-kernel@vger.kernel.org, Nick Gregory <nick@humyo.com>, Rob Sanderson <rob@humyo.com>, xfs@oss.sgi.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

John Berthels wrote:
> I'll reply again after it's been running long enough to draw conclusions.
We're getting pretty close on the 8k stack on this box now. It's running 
2.6.33.2 + your patch, with THREAD_ORDER 1, stack tracing and 
CONFIG_LOCKDEP=y. (Sorry that LOCKDEP is on, please advise if that's 
going to throw the figures and we'll restart the test systems with new 
kernels).

This is significantly more than 5.6K, so it shows a potential problem? 
Or is 720 bytes enough headroom?

jb

[ 4005.541869] apache2 used greatest stack depth: 2480 bytes left
[ 4005.541973] apache2 used greatest stack depth: 2240 bytes left
[ 4005.542070] apache2 used greatest stack depth: 1936 bytes left
[ 4005.542614] apache2 used greatest stack depth: 1616 bytes left
[ 5531.406529] apache2 used greatest stack depth: 720 bytes left

$ cat /sys/kernel/debug/tracing/stack_trace
        Depth    Size   Location    (55 entries)
        -----    ----   --------
  0)     7440      48   add_partial+0x26/0x90
  1)     7392      64   __slab_free+0x1a9/0x380
  2)     7328      64   kmem_cache_free+0xb9/0x160
  3)     7264      16   free_buffer_head+0x25/0x50
  4)     7248      64   try_to_free_buffers+0x79/0xc0
  5)     7184     160   xfs_vm_releasepage+0xda/0x130 [xfs]
  6)     7024      16   try_to_release_page+0x33/0x60
  7)     7008     384   shrink_page_list+0x585/0x860
  8)     6624     528   shrink_zone+0x636/0xdc0
  9)     6096     112   do_try_to_free_pages+0xc2/0x3c0
 10)     5984     112   try_to_free_pages+0x64/0x70
 11)     5872     256   __alloc_pages_nodemask+0x3d2/0x710
 12)     5616      48   alloc_pages_current+0x8c/0xe0
 13)     5568      32   __page_cache_alloc+0x67/0x70
 14)     5536      80   find_or_create_page+0x50/0xb0
 15)     5456     160   _xfs_buf_lookup_pages+0x145/0x350 [xfs]
 16)     5296      64   xfs_buf_get+0x74/0x1d0 [xfs]
 17)     5232      48   xfs_buf_read+0x2f/0x110 [xfs]
 18)     5184      80   xfs_trans_read_buf+0x2bf/0x430 [xfs]
 19)     5104      80   xfs_btree_read_buf_block+0x5d/0xb0 [xfs]
 20)     5024      80   xfs_btree_lookup_get_block+0x84/0xf0 [xfs]
 21)     4944     176   xfs_btree_lookup+0xd7/0x490 [xfs]
 22)     4768      16   xfs_alloc_lookup_ge+0x1c/0x20 [xfs]
 23)     4752     144   xfs_alloc_ag_vextent_near+0x58/0xb30 [xfs]
 24)     4608      32   xfs_alloc_ag_vextent+0xe5/0x140 [xfs]
 25)     4576      96   xfs_alloc_vextent+0x49f/0x630 [xfs]
 26)     4480     160   xfs_bmbt_alloc_block+0xbe/0x1d0 [xfs]
 27)     4320     208   xfs_btree_split+0xb3/0x6a0 [xfs]
 28)     4112      96   xfs_btree_make_block_unfull+0x151/0x190 [xfs]
 29)     4016     224   xfs_btree_insrec+0x39c/0x5b0 [xfs]
 30)     3792     128   xfs_btree_insert+0x86/0x180 [xfs]
 31)     3664     352   xfs_bmap_add_extent_delay_real+0x564/0x1670 [xfs]
 32)     3312     208   xfs_bmap_add_extent+0x41c/0x450 [xfs]
 33)     3104     448   xfs_bmapi+0x982/0x1200 [xfs]
 34)     2656     256   xfs_iomap_write_allocate+0x248/0x3c0 [xfs]
 35)     2400     208   xfs_iomap+0x3d8/0x410 [xfs]
 36)     2192      32   xfs_map_blocks+0x2c/0x30 [xfs]
 37)     2160     256   xfs_page_state_convert+0x443/0x730 [xfs]
 38)     1904      64   xfs_vm_writepage+0xab/0x160 [xfs]
 39)     1840      32   __writepage+0x1a/0x60
 40)     1808     288   write_cache_pages+0x1f7/0x400
 41)     1520      16   generic_writepages+0x27/0x30
 42)     1504      48   xfs_vm_writepages+0x5a/0x70 [xfs]
 43)     1456      16   do_writepages+0x24/0x40
 44)     1440      64   writeback_single_inode+0xf1/0x3e0
 45)     1376     128   writeback_inodes_wb+0x31e/0x510
 46)     1248      16   writeback_inodes_wbc+0x1e/0x20
 47)     1232     224   balance_dirty_pages_ratelimited_nr+0x277/0x410
 48)     1008     192   generic_file_buffered_write+0x19b/0x240
 49)      816     288   xfs_write+0x849/0x930 [xfs]
 50)      528      16   xfs_file_aio_write+0x5b/0x70 [xfs]
 51)      512     272   do_sync_write+0xd1/0x120
 52)      240      48   vfs_write+0xcb/0x1a0
 53)      192      64   sys_write+0x55/0x90
 54)      128     128   system_call_fastpath+0x16/0x1b

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
