Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id AE30E6B0011
	for <linux-mm@kvack.org>; Wed, 27 Apr 2011 20:37:38 -0400 (EDT)
Date: Thu, 28 Apr 2011 10:37:27 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: [BUG] fatal hang untarring 90GB file, possibly writeback
 related.
Message-ID: <20110428003727.GL12436@dastard>
References: <1303920553.2583.7.camel@mulgrave.site>
 <1303921583-sup-4021@think>
 <1303923000.2583.8.camel@mulgrave.site>
 <1303923177-sup-2603@think>
 <1303924902.2583.13.camel@mulgrave.site>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1303924902.2583.13.camel@mulgrave.site>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: James Bottomley <James.Bottomley@HansenPartnership.com>
Cc: Chris Mason <chris.mason@oracle.com>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>

On Wed, Apr 27, 2011 at 12:21:42PM -0500, James Bottomley wrote:
> On Wed, 2011-04-27 at 12:54 -0400, Chris Mason wrote:
> > Ok, I'd try turning it on so we catch the sleeping with a spinlock held
> > case better.
> 
> Will do, that's CONFIG_PREEMPT (rather than CONFIG_PREEMPT_VOLUNTARY)?
> 
> This is the trace with sysrq-l and sysrq-w
> 
> The repro this time doesn't have a soft lockup, just the tar is hung and
> one of my CPUs is in 99% system.
> 
> James 
> 
> ---
> [  454.742935] flush-253:2     D 0000000000000000     0   793      2 0x00000000
> [  454.745425]  ffff88006355b710 0000000000000046 ffff88006355b6b0 ffffffff00000000
> [  454.747955]  ffff880037ee9700 ffff88006355bfd8 ffff88006355bfd8 0000000000013b40
> [  454.750506]  ffffffff81a0b020 ffff880037ee9700 ffff88006355b710 000000018106e7c3
> [  454.753048] Call Trace:
> [  454.755537]  [<ffffffff811c82b8>] do_get_write_access+0x1c6/0x38d
> [  454.758071]  [<ffffffff8106e88b>] ? autoremove_wake_function+0x3d/0x3d
> [  454.760644]  [<ffffffff811c8588>] jbd2_journal_get_write_access+0x2b/0x42
> [  454.763206]  [<ffffffff8118ea4f>] ? ext4_read_block_bitmap+0x54/0x2d0
> [  454.765770]  [<ffffffff811b5888>] __ext4_journal_get_write_access+0x58/0x66
> [  454.768353]  [<ffffffff811b8dbe>] ext4_mb_mark_diskspace_used+0x70/0x2ae
> [  454.770942]  [<ffffffff811bb10e>] ext4_mb_new_blocks+0x1c8/0x3c2
> [  454.773501]  [<ffffffff811b4628>] ext4_ext_map_blocks+0x1961/0x1c04
> [  454.776082]  [<ffffffff8122ed78>] ? radix_tree_gang_lookup_tag_slot+0x81/0xa2
> [  454.778711]  [<ffffffff810d55f9>] ? find_get_pages_tag+0x3b/0xd6
> [  454.781323]  [<ffffffff811967fa>] ext4_map_blocks+0x112/0x1e7
> [  454.783894]  [<ffffffff811984e8>] mpage_da_map_and_submit+0x93/0x2cd
> [  454.786491]  [<ffffffff81198de5>] ext4_da_writepages+0x2c1/0x44d
> [  454.789090]  [<ffffffff810ddeb4>] do_writepages+0x21/0x2a
> [  454.791703]  [<ffffffff8113cbb7>] writeback_single_inode+0xb2/0x1bc
> [  454.794334]  [<ffffffff8113cf03>] writeback_sb_inodes+0xcd/0x161
> [  454.796962]  [<ffffffff8113d407>] writeback_inodes_wb+0x119/0x12b
> [  454.799582]  [<ffffffff8113d607>] wb_writeback+0x1ee/0x335
> [  454.802204]  [<ffffffff81080be3>] ? arch_local_irq_save+0x15/0x1b
> [  454.804803]  [<ffffffff8147be3a>] ? _raw_spin_lock_irqsave+0x12/0x2f
> [  454.807427]  [<ffffffff8113d891>] wb_do_writeback+0x143/0x19d
> [  454.810077]  [<ffffffff8147acc7>] ? schedule_timeout+0xb0/0xde
> [  454.812776]  [<ffffffff8113d973>] bdi_writeback_thread+0x88/0x1e5
> [  454.815464]  [<ffffffff8113d8eb>] ? wb_do_writeback+0x19d/0x19d
> [  454.818129]  [<ffffffff8106e157>] kthread+0x84/0x8c
> [  454.820808]  [<ffffffff81483764>] kernel_thread_helper+0x4/0x10
> [  454.823452]  [<ffffffff8106e0d3>] ? kthread_worker_fn+0x148/0x148
> [  454.826103]  [<ffffffff81483760>] ? gs_change+0x13/0x13

Looks like it is blocked waiting for the journal.

> [  454.828711] jbd2/dm-2-8     D 0000000000000000     0   799      2 0x00000000
> [  454.831390]  ffff88006d59db10 0000000000000046 ffff88006d59daa0 ffffffff00000000
> [  454.834094]  ffff88006deb4500 ffff88006d59dfd8 ffff88006d59dfd8 0000000000013b40
> [  454.836788]  ffffffff81a0b020 ffff88006deb4500 ffff88006d59dad0 000000016d59dad0
> [  454.839453] Call Trace:
> [  454.842098]  [<ffffffff810d5904>] ? lock_page+0x3e/0x3e
> [  454.844738]  [<ffffffff810d5904>] ? lock_page+0x3e/0x3e
> [  454.847303]  [<ffffffff8147a7c9>] io_schedule+0x63/0x7e
> [  454.849877]  [<ffffffff810d5912>] sleep_on_page+0xe/0x12
> [  454.852469]  [<ffffffff8147aea9>] __wait_on_bit+0x48/0x7b
> [  454.855021]  [<ffffffff810d5a8c>] wait_on_page_bit+0x72/0x74
> [  454.857583]  [<ffffffff8106e88b>] ? autoremove_wake_function+0x3d/0x3d
> [  454.860171]  [<ffffffff810d5b6b>] filemap_fdatawait_range+0x84/0x163
> [  454.862744]  [<ffffffff810d5c6e>] filemap_fdatawait+0x24/0x26
> [  454.865299]  [<ffffffff811c94a2>] jbd2_journal_commit_transaction+0x922/0x1194
> [  454.867892]  [<ffffffff81008714>] ? __switch_to+0xc6/0x220
> [  454.870496]  [<ffffffff811cd3b6>] kjournald2+0xc9/0x20a
> [  454.873103]  [<ffffffff8106e84e>] ? remove_wait_queue+0x3a/0x3a
> [  454.875690]  [<ffffffff811cd2ed>] ? commit_timeout+0x10/0x10
> [  454.878327]  [<ffffffff8106e157>] kthread+0x84/0x8c
> [  454.880961]  [<ffffffff81483764>] kernel_thread_helper+0x4/0x10
> [  454.883604]  [<ffffffff8106e0d3>] ? kthread_worker_fn+0x148/0x148
> [  454.886262]  [<ffffffff81483760>] ? gs_change+0x13/0x13

which is blocked waiting for _data_ IO completion.

> [  454.888875] tar             D ffff88006e573af8     0   991    838 0x00000000
> [  454.891546]  ffff880037f5b8a8 0000000000000086 ffff8801002a1d40 0000000000000282
> [  454.894213]  ffff88006d644500 ffff880037f5bfd8 ffff880037f5bfd8 0000000000013b40
> [  454.896889]  ffff8801002b4500 ffff88006d644500 ffff880037f5b8a8 ffffffff8106e7c3
> [  454.899530] Call Trace:
> [  454.902118]  [<ffffffff8106e7c3>] ? prepare_to_wait+0x6c/0x78
> [  454.904724]  [<ffffffff811c82b8>] do_get_write_access+0x1c6/0x38d
> [  454.907344]  [<ffffffff8106e88b>] ? autoremove_wake_function+0x3d/0x3d
> [  454.909967]  [<ffffffff811991cc>] ? ext4_dirty_inode+0x33/0x4c
> [  454.912574]  [<ffffffff811c8588>] jbd2_journal_get_write_access+0x2b/0x42
> [  454.915192]  [<ffffffff811b5888>] __ext4_journal_get_write_access+0x58/0x66
> [  454.917819]  [<ffffffff81195526>] ext4_reserve_inode_write+0x41/0x83
> [  454.920459]  [<ffffffff811955e4>] ext4_mark_inode_dirty+0x7c/0x1f0
> [  454.923070]  [<ffffffff811991cc>] ext4_dirty_inode+0x33/0x4c
> [  454.925660]  [<ffffffff8113c3d6>] __mark_inode_dirty+0x2f/0x175
> [  454.928247]  [<ffffffff81143a0d>] generic_write_end+0x6c/0x7e
> [  454.930865]  [<ffffffff811983f6>] ext4_da_write_end+0x1a5/0x204
> [  454.933454]  [<ffffffff810d5e9d>] generic_file_buffered_write+0x17e/0x23a
> [  454.936062]  [<ffffffff810d6c9d>] __generic_file_aio_write+0x242/0x272
> [  454.938648]  [<ffffffff810d6d2e>] generic_file_aio_write+0x61/0xba
> [  454.941288]  [<ffffffff8118fe00>] ext4_file_write+0x1dc/0x234
> [  454.943909]  [<ffffffff8111edab>] do_sync_write+0xbf/0xff
> [  454.946501]  [<ffffffff8114b9fc>] ? fsnotify+0x1eb/0x217
> [  454.949114]  [<ffffffff811f1866>] ? selinux_file_permission+0x58/0xb4
> [  454.951736]  [<ffffffff811e9cfe>] ? security_file_permission+0x2e/0x33
> [  454.954349]  [<ffffffff8111f196>] ? rw_verify_area+0xb0/0xcd
> [  454.956943]  [<ffffffff8111f421>] vfs_write+0xac/0xf3
> [  454.959530]  [<ffffffff8111f610>] sys_write+0x4a/0x6e
> [  454.962129]  [<ffffffff81482642>] system_call_fastpath+0x16/0x1b

And tar is blocked waiting for the journal, too.

Looks like a case of a ordered mode data writeback journal stall
(the same basic problem as the ext3 fsync sync-the-world issue).

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
