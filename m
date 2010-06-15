Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id C80F16B01D5
	for <linux-mm@kvack.org>; Tue, 15 Jun 2010 13:37:59 -0400 (EDT)
Date: Tue, 15 Jun 2010 18:31:50 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [RFC PATCH 0/6] Do not call ->writepage[s] from direct reclaim
 and use a_ops->writepages() where possible
Message-ID: <20100615163150.GJ28052@random.random>
References: <1275987745-21708-1-git-send-email-mel@csn.ul.ie>
 <20100615140011.GD28052@random.random>
 <20100615141122.GA27893@infradead.org>
 <20100615142219.GE28052@random.random>
 <20100615144342.GA3339@infradead.org>
 <20100615150850.GF28052@random.random>
 <20100615152526.GA3468@infradead.org>
 <20100615154516.GG28052@random.random>
 <20100615162600.GA9910@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20100615162600.GA9910@infradead.org>
Sender: owner-linux-mm@kvack.org
To: Christoph Hellwig <hch@infradead.org>
Cc: Mel Gorman <mel@csn.ul.ie>, linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Tue, Jun 15, 2010 at 12:26:00PM -0400, Christoph Hellwig wrote:
> On Tue, Jun 15, 2010 at 05:45:16PM +0200, Andrea Arcangeli wrote:
> > On Tue, Jun 15, 2010 at 11:25:26AM -0400, Christoph Hellwig wrote:
> > > hand can happen from context that already is say 4 or 6 kilobytes
> > > into stack usage.  And the callchain from kmalloc() into ->writepage
> > 
> > Mel's stack trace of 5k was still not realistic as it doesn't call
> > writepage there. I was just asking the 6k example vs msync.
> 
> FYI here is the most recent one that Michael Monnerie reported after he
> hit it on a production machine.  It's what finally prompted us to add
> the check in ->writepage:
> 
> [21877.948005] BUG: scheduling while atomic: rsync/2345/0xffff8800
> [21877.948005] Modules linked in: af_packet nfs lockd fscache nfs_acl auth_rpcgss sunrpc ipv6 ramzswap xvmalloc lzo_decompress lzo_compress loop dm_mod reiserfs xfs exportfs xennet xenblk cdrom
> [21877.948005] Pid: 2345, comm: rsync Not tainted 2.6.31.12-0.2-xen #1
> [21877.948005] Call Trace:
> [21877.949649]  [<ffffffff800119b9>] try_stack_unwind+0x189/0x1b0
> [21877.949659]  [<ffffffff8000f466>] dump_trace+0xa6/0x1e0
> [21877.949666]  [<ffffffff800114c4>] show_trace_log_lvl+0x64/0x90
> [21877.949676]  [<ffffffff80011513>] show_trace+0x23/0x40
> [21877.949684]  [<ffffffff8046b92c>] dump_stack+0x81/0x9e
> [21877.949695]  [<ffffffff8003f398>] __schedule_bug+0x78/0x90
> [21877.949702]  [<ffffffff8046c97c>] thread_return+0x1d7/0x3fb
> [21877.949709]  [<ffffffff8046cf85>] schedule_timeout+0x195/0x200
> [21877.949717]  [<ffffffff8046be2b>] wait_for_common+0x10b/0x230
> [21877.949726]  [<ffffffff8046c09b>] wait_for_completion+0x2b/0x50
> [21877.949768]  [<ffffffffa009e741>] xfs_buf_iowait+0x31/0x80 [xfs]
> [21877.949894]  [<ffffffffa009ea30>] _xfs_buf_read+0x70/0x80 [xfs]
> [21877.949992]  [<ffffffffa009ef8b>] xfs_buf_read_flags+0x8b/0xd0 [xfs]
> [21877.950089]  [<ffffffffa0091ab9>] xfs_trans_read_buf+0x1e9/0x320 [xfs]
> [21877.950174]  [<ffffffffa005b278>] xfs_btree_read_buf_block+0x68/0xe0 [xfs]
> [21877.950232]  [<ffffffffa005b99e>] xfs_btree_lookup_get_block+0x8e/0x110 [xfs]
> [21877.950281]  [<ffffffffa005c0af>] xfs_btree_lookup+0xdf/0x4d0 [xfs]
> [21877.950329]  [<ffffffffa0042b77>] xfs_alloc_lookup_eq+0x27/0x50 [xfs]
> [21877.950361]  [<ffffffffa0042f09>] xfs_alloc_fixup_trees+0x249/0x370 [xfs]
> [21877.950397]  [<ffffffffa0044c30>] xfs_alloc_ag_vextent_near+0x4e0/0x9a0 [xfs]
> [21877.950432]  [<ffffffffa00451f5>] xfs_alloc_ag_vextent+0x105/0x160 [xfs]
> [21877.950471]  [<ffffffffa0045bb4>] xfs_alloc_vextent+0x3b4/0x4b0 [xfs]
> [21877.950504]  [<ffffffffa0058da8>] xfs_bmbt_alloc_block+0xf8/0x210 [xfs]
> [21877.950550]  [<ffffffffa005e3b7>] xfs_btree_split+0xc7/0x720 [xfs]
> [21877.950597]  [<ffffffffa005ef8c>] xfs_btree_make_block_unfull+0x15c/0x1c0 [xfs]
> [21877.950643]  [<ffffffffa005f3ff>] xfs_btree_insrec+0x40f/0x5c0 [xfs]
> [21877.950689]  [<ffffffffa005f651>] xfs_btree_insert+0xa1/0x1b0 [xfs]
> [21877.950748]  [<ffffffffa005325e>] xfs_bmap_add_extent_delay_real+0x82e/0x12a0 [xfs]
> [21877.950787]  [<ffffffffa00540f4>] xfs_bmap_add_extent+0x424/0x450 [xfs]
> [21877.950833]  [<ffffffffa00573f3>] xfs_bmapi+0xda3/0x1320 [xfs]
> [21877.950879]  [<ffffffffa007c248>] xfs_iomap_write_allocate+0x1d8/0x3f0 [xfs]
> [21877.950953]  [<ffffffffa007d089>] xfs_iomap+0x2c9/0x300 [xfs]
> [21877.951021]  [<ffffffffa009a1b8>] xfs_map_blocks+0x38/0x60 [xfs]
> [21877.951108]  [<ffffffffa009b93a>] xfs_page_state_convert+0x3fa/0x720 [xfs]
> [21877.951204]  [<ffffffffa009bde4>] xfs_vm_writepage+0x84/0x160 [xfs]
> [21877.951301]  [<ffffffff800e3603>] pageout+0x143/0x2b0
> [21877.951308]  [<ffffffff800e514e>] shrink_page_list+0x26e/0x650
> [21877.951314]  [<ffffffff800e5803>] shrink_inactive_list+0x2d3/0x7c0
> [21877.951320]  [<ffffffff800e5d4b>] shrink_list+0x5b/0x110
> [21877.951325]  [<ffffffff800e5f71>] shrink_zone+0x171/0x250
> [21877.951330]  [<ffffffff800e60d3>] shrink_zones+0x83/0x120
> [21877.951336]  [<ffffffff800e620e>] do_try_to_free_pages+0x9e/0x380
> [21877.951342]  [<ffffffff800e6607>] try_to_free_pages+0x77/0xa0

If we switch stack here, we're done...

I surely agree Mel's series is much safer than the recent change that
adds the PF_MEMALLOC. Also note I grepped current mainline, so this
xfs change is not recent but _very_ recent and probably hasn't been
tested with heavy VM pressure to verify it doesn't introduce early
OOM.

Definitely go with Mel's code rather than a blind PF_MEMALLOC check in
writepage. But I'd prefer if we switch stack and solve
ext4_write_inode too etc..

> [21877.951349]  [<ffffffff800dbfa3>] __alloc_pages_slowpath+0x2d3/0x5c0
> [21877.951355]  [<ffffffff800dc3e1>] __alloc_pages_nodemask+0x151/0x160
> [21877.951362]  [<ffffffff800d44b7>] __page_cache_alloc+0x27/0x50
> [21877.951368]  [<ffffffff800d68ca>] grab_cache_page_write_begin+0x9a/0xe0
> [21877.951376]  [<ffffffff8014bdfe>] block_write_begin+0xae/0x120
> [21877.951396]  [<ffffffffa009ac24>] xfs_vm_write_begin+0x34/0x50 [xfs]
> [21877.951482]  [<ffffffff800d4b31>] generic_perform_write+0xc1/0x1f0
> [21877.951489]  [<ffffffff800d5d00>] generic_file_buffered_write+0x90/0x160
> [21877.951512]  [<ffffffffa00a4711>] xfs_write+0x521/0xb60 [xfs]
> [21877.951624]  [<ffffffffa009fb80>] xfs_file_aio_write+0x70/0xa0 [xfs]
> [21877.951711]  [<ffffffff80118c42>] do_sync_write+0x102/0x160
> [21877.951718]  [<ffffffff80118fc8>] vfs_write+0xd8/0x1c0
> [21877.951723]  [<ffffffff8011995b>] sys_write+0x5b/0xa0
> [21877.951729]  [<ffffffff8000c868>] system_call_fastpath+0x16/0x1b
> [21877.951736]  [<00007fc41b0fab10>] 0x7fc41b0fab10
> [21877.951750] BUG: unable to handle kernel paging request at 0000000108743280
> [21877.951755] IP: [<ffffffff80034832>] dequeue_task+0x72/0x110
> [21877.951766] PGD 31c6f067 PUD 0 
> [21877.951770] Thread overran stack, or stack corrupted
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
