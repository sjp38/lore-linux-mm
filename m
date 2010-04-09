Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 8127360037E
	for <linux-mm@kvack.org>; Fri,  9 Apr 2010 09:44:34 -0400 (EDT)
Message-ID: <4BBF2F18.10507@humyo.com>
Date: Fri, 09 Apr 2010 14:43:52 +0100
From: John Berthels <john@humyo.com>
MIME-Version: 1.0
Subject: Re: PROBLEM + POSS FIX: kernel stack overflow, xfs, many disks, heavy
 write load, 8k stack, x86-64
References: <4BBC6719.7080304@humyo.com> <20100407140523.GJ11036@dastard> <4BBCAB57.3000106@humyo.com> <20100407234341.GK11036@dastard> <20100408030347.GM11036@dastard> <4BBDC92D.8060503@humyo.com> <4BBDEC9A.9070903@humyo.com> <20100408233837.GP11036@dastard>
In-Reply-To: <20100408233837.GP11036@dastard>
Content-Type: multipart/mixed;
 boundary="------------050902090101030701060106"
Sender: owner-linux-mm@kvack.org
To: Dave Chinner <david@fromorbit.com>
Cc: linux-kernel@vger.kernel.org, Nick Gregory <nick@humyo.com>, Rob Sanderson <rob@humyo.com>, xfs@oss.sgi.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------050902090101030701060106
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Dave Chinner wrote:

> So effectively the storage subsystem (NFS, filesystem, DM, MD,
> device drivers) have about 4K of stack to work in now. That seems to
> be a lot less than last time I looked at this, and we've been really
> careful not to increase XFS's stack usage for quite some time now.

OK. I should note that we have what appears to be a similar problem on a 
2.6.28 distro kernel, so I'm not sure this is a very recent change. (We 
see the lockups on that kernel, we haven't tried larger stacks + stack 
instrumentation on the earlier kernel).

Do you know if there are any obvious knobs to twiddle to make these 
codepaths less likely? The cluster is resilient against occasional 
server death, but frequent death is more annoying.

We're currently running with sysctls:

net.ipv4.ip_nonlocal_bind=1
kernel.panic=300
vm.dirty_background_ratio=3
vm.min_free_kbytes=16384

I'm not sure what circumstances force the memory reclaim (and why it 
doesn't come from discarding a cached page).

Is the problem is the DMA/DMA32 zone and we should try playing with 
lowmem_reserve_ratio? Is there anything else we could do to keep dirty 
pages out of the low zones?

Before trying THREAD_ORDER 2, we tried doubling the RAM in a couple of 
boxes from 2GB to 4GB without any significant reduction in the problem.

Lastly - if we end up stuck with THREAD_ORDER 2, does anyone know what 
symptoms to look out for to know if unable to allocate thread stacks due 
to fragmentation?

> I'll have to have a bit of a think on this one - if you could
> provide further stack traces as they get deeper (esp. if they go
> past 8k) that would be really handy.

Two of the worst offenders below. We have plenty to send if you would 
like more. Please let us know if you'd like us to try anything else or 
would like other info.

Thanks very much for your thoughts, suggestions and work so far, it's 
very much appreciated here.

regards,

jb


--------------050902090101030701060106
Content-Type: text/plain;
 name="stack_traces.txt"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="stack_traces.txt"

=== server16 ===

apache2 used greatest stack depth: 7208 bytes left

        Depth    Size   Location    (72 entries)
        -----    ----   --------
  0)     8336     304   select_task_rq_fair+0x235/0xad0
  1)     8032      96   try_to_wake_up+0x189/0x3f0
  2)     7936      16   default_wake_function+0x12/0x20
  3)     7920      32   autoremove_wake_function+0x16/0x40
  4)     7888      64   __wake_up_common+0x5a/0x90
  5)     7824      64   __wake_up+0x48/0x70
  6)     7760      64   insert_work+0x9f/0xb0
  7)     7696      48   __queue_work+0x36/0x50
  8)     7648      16   queue_work_on+0x4d/0x60
  9)     7632      16   queue_work+0x1f/0x30
 10)     7616      16   queue_delayed_work+0x2d/0x40
 11)     7600      32   ata_pio_queue_task+0x35/0x40
 12)     7568      48   ata_sff_qc_issue+0x146/0x2f0
 13)     7520      96   mv_qc_issue+0x12d/0x540 [sata_mv]
 14)     7424      96   ata_qc_issue+0x1fe/0x320
 15)     7328      64   ata_scsi_translate+0xae/0x1a0
 16)     7264      64   ata_scsi_queuecmd+0xbf/0x2f0
 17)     7200      48   scsi_dispatch_cmd+0x114/0x2b0
 18)     7152      96   scsi_request_fn+0x419/0x590
 19)     7056      32   __blk_run_queue+0x82/0x150
 20)     7024      48   elv_insert+0x1aa/0x2d0
 21)     6976      48   __elv_add_request+0x83/0xd0
 22)     6928      96   __make_request+0x139/0x490
 23)     6832     208   generic_make_request+0x3df/0x4d0
 24)     6624      80   submit_bio+0x7c/0x100
 25)     6544      96   _xfs_buf_ioapply+0x128/0x2c0 [xfs]
 26)     6448      48   xfs_buf_iorequest+0x75/0xd0 [xfs]
 27)     6400      32   xlog_bdstrat_cb+0x4d/0x60 [xfs]
 28)     6368      80   xlog_sync+0x218/0x510 [xfs]
 29)     6288      64   xlog_state_release_iclog+0xbb/0x100 [xfs]
 30)     6224     160   xlog_state_sync+0x1ab/0x230 [xfs]
 31)     6064      32   _xfs_log_force+0x5a/0x80 [xfs]
 32)     6032      32   xfs_log_force+0x18/0x40 [xfs]
 33)     6000      64   xfs_alloc_search_busy+0x14b/0x160 [xfs]
 34)     5936     112   xfs_alloc_get_freelist+0x130/0x170 [xfs]
 35)     5824      48   xfs_allocbt_alloc_block+0x33/0x70 [xfs]
 36)     5776     208   xfs_btree_split+0xb3/0x6a0 [xfs]
 37)     5568      96   xfs_btree_make_block_unfull+0x151/0x190 [xfs]
 38)     5472     224   xfs_btree_insrec+0x39c/0x5b0 [xfs]
 39)     5248     128   xfs_btree_insert+0x86/0x180 [xfs]
 40)     5120     144   xfs_free_ag_extent+0x33b/0x7b0 [xfs]
 41)     4976     224   xfs_alloc_fix_freelist+0x120/0x490 [xfs]
 42)     4752      96   xfs_alloc_vextent+0x1f5/0x630 [xfs]
 43)     4656     272   xfs_bmap_btalloc+0x497/0xa70 [xfs]
 44)     4384      16   xfs_bmap_alloc+0x21/0x40 [xfs]
 45)     4368     448   xfs_bmapi+0x85e/0x1200 [xfs]
 46)     3920     256   xfs_iomap_write_allocate+0x248/0x3c0 [xfs]
 47)     3664     208   xfs_iomap+0x3d8/0x410 [xfs]
 48)     3456      32   xfs_map_blocks+0x2c/0x30 [xfs]
 49)     3424     256   xfs_page_state_convert+0x443/0x730 [xfs]
 50)     3168      64   xfs_vm_writepage+0xab/0x160 [xfs]
 51)     3104     384   shrink_page_list+0x65e/0x840
 52)     2720     528   shrink_zone+0x63f/0xe10
 53)     2192     112   do_try_to_free_pages+0xc2/0x3c0
 54)     2080     128   try_to_free_pages+0x77/0x80
 55)     1952     240   __alloc_pages_nodemask+0x3e4/0x710
 56)     1712      48   alloc_pages_current+0x8c/0xe0
 57)     1664      32   __page_cache_alloc+0x67/0x70
 58)     1632     144   __do_page_cache_readahead+0xd3/0x220
 59)     1488      16   ra_submit+0x21/0x30
 60)     1472      80   ondemand_readahead+0x11d/0x250
 61)     1392      64   page_cache_async_readahead+0xa9/0xe0
 62)     1328     592   __generic_file_splice_read+0x48a/0x530
 63)      736      48   generic_file_splice_read+0x4f/0x90
 64)      688      96   xfs_splice_read+0xf2/0x130 [xfs]
 65)      592      32   xfs_file_splice_read+0x4b/0x50 [xfs]
 66)      560      64   do_splice_to+0x77/0xb0
 67)      496     112   splice_direct_to_actor+0xcc/0x1c0
 68)      384      80   do_splice_direct+0x57/0x80
 69)      304      96   do_sendfile+0x16c/0x1e0
 70)      208      80   sys_sendfile64+0x8d/0xb0
 71)      128     128   system_call_fastpath+0x16/0x1b

=== server9 ===

[223269.859411] apache2 used greatest stack depth: 7088 bytes left

        Depth    Size   Location    (62 entries)
        -----    ----   --------

  0)     8528      32   down_trylock+0x1e/0x50
  1)     8496      80   _xfs_buf_find+0x12f/0x290 [xfs]
  2)     8416      64   xfs_buf_get+0x61/0x1c0 [xfs]
  3)     8352      48   xfs_buf_read+0x2f/0x110 [xfs]
  4)     8304      48   xfs_buf_readahead+0x61/0x90 [xfs]
  5)     8256      48   xfs_btree_readahead_sblock+0xea/0xf0 [xfs]
  6)     8208      16   xfs_btree_readahead+0x5f/0x90 [xfs]
  7)     8192     112   xfs_btree_increment+0x2e/0x2b0 [xfs]
  8)     8080     176   xfs_btree_rshift+0x2f2/0x530 [xfs]
  9)     7904     272   xfs_btree_delrec+0x4a3/0x1020 [xfs]
 10)     7632      64   xfs_btree_delete+0x40/0xd0 [xfs]
 11)     7568      96   xfs_alloc_fixup_trees+0x7d/0x350 [xfs]
 12)     7472     144   xfs_alloc_ag_vextent_near+0x916/0xb30 [xfs]
 13)     7328      32   xfs_alloc_ag_vextent+0xe5/0x140 [xfs]
 14)     7296      96   xfs_alloc_vextent+0x49f/0x630 [xfs]
 15)     7200     160   xfs_bmbt_alloc_block+0xbe/0x1d0 [xfs]
 16)     7040     208   xfs_btree_split+0xb3/0x6a0 [xfs]
 17)     6832      96   xfs_btree_make_block_unfull+0x151/0x190 [xfs]
 18)     6736     224   xfs_btree_insrec+0x39c/0x5b0 [xfs]
 19)     6512     128   xfs_btree_insert+0x86/0x180 [xfs]
 20)     6384     352   xfs_bmap_add_extent_delay_real+0x41e/0x1660 [xfs]
 21)     6032     208   xfs_bmap_add_extent+0x41c/0x450 [xfs]
 22)     5824     448   xfs_bmapi+0x982/0x1200 [xfs]
 23)     5376     256   xfs_iomap_write_allocate+0x248/0x3c0 [xfs]
 24)     5120     208   xfs_iomap+0x3d8/0x410 [xfs]
 25)     4912      32   xfs_map_blocks+0x2c/0x30 [xfs]
 26)     4880     256   xfs_page_state_convert+0x443/0x730 [xfs]
 27)     4624      64   xfs_vm_writepage+0xab/0x160 [xfs]
 28)     4560     384   shrink_page_list+0x65e/0x840
 29)     4176     528   shrink_zone+0x63f/0xe10
 30)     3648     112   do_try_to_free_pages+0xc2/0x3c0
 31)     3536     128   try_to_free_pages+0x77/0x80
 32)     3408     240   __alloc_pages_nodemask+0x3e4/0x710
 33)     3168      48   alloc_pages_current+0x8c/0xe0
 34)     3120      80   new_slab+0x247/0x300
 35)     3040      96   __slab_alloc+0x137/0x490
 36)     2944      64   kmem_cache_alloc+0x110/0x120
 37)     2880      64   kmem_zone_alloc+0x9a/0xe0 [xfs]
 38)     2816      32   kmem_zone_zalloc+0x1e/0x50 [xfs]
 39)     2784      32   _xfs_trans_alloc+0x38/0x80 [xfs]
 40)     2752      96   xfs_trans_alloc+0x9f/0xb0 [xfs]
 41)     2656     256   xfs_iomap_write_allocate+0xf1/0x3c0 [xfs]
 42)     2400     208   xfs_iomap+0x3d8/0x410 [xfs]
 43)     2192      32   xfs_map_blocks+0x2c/0x30 [xfs]
 44)     2160     256   xfs_page_state_convert+0x443/0x730 [xfs]
 45)     1904      64   xfs_vm_writepage+0xab/0x160 [xfs]
 46)     1840      32   __writepage+0x17/0x50
 47)     1808     288   write_cache_pages+0x1f7/0x400
 48)     1520      16   generic_writepages+0x24/0x30
 49)     1504      48   xfs_vm_writepages+0x5c/0x80 [xfs]
 50)     1456      16   do_writepages+0x21/0x40
 51)     1440      64   writeback_single_inode+0xeb/0x3c0
 52)     1376     128   writeback_inodes_wb+0x318/0x510
 53)     1248      16   writeback_inodes_wbc+0x1e/0x20
 54)     1232     224   balance_dirty_pages_ratelimited_nr+0x269/0x3a0
 55)     1008     192   generic_file_buffered_write+0x19b/0x240
 56)      816     288   xfs_write+0x837/0x920 [xfs]
 57)      528      16   xfs_file_aio_write+0x5b/0x70 [xfs]
 58)      512     272   do_sync_write+0xd1/0x120
 59)      240      48   vfs_write+0xcb/0x1a0
 60)      192      64   sys_write+0x55/0x90
 61)      128     128   system_call_fastpath+0x16/0x1b

--------------050902090101030701060106--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
