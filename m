Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id F29F490011B
	for <linux-mm@kvack.org>; Tue, 10 May 2011 13:06:02 -0400 (EDT)
Subject: Re: [BUG] fatal hang untarring 90GB file, possibly writeback
 related.
From: James Bottomley <James.Bottomley@HansenPartnership.com>
In-Reply-To: <1305043052.6737.17.camel@mulgrave.site>
References: <1304025145.2598.24.camel@mulgrave.site>
	 <1304030629.2598.42.camel@mulgrave.site> <20110503091320.GA4542@novell.com>
	 <1304431982.2576.5.camel@mulgrave.site>
	 <1304432553.2576.10.camel@mulgrave.site> <20110506074224.GB6591@suse.de>
	 <20110506080728.GC6591@suse.de> <1304964980.4865.53.camel@mulgrave.site>
	 <20110510102141.GA4149@novell.com> <1305036064.6737.8.camel@mulgrave.site>
	 <20110510143509.GD4146@suse.de>  <1305041397.6737.12.camel@mulgrave.site>
	 <1305043052.6737.17.camel@mulgrave.site>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 10 May 2011 12:05:54 -0500
Message-ID: <1305047154.6737.22.camel@mulgrave.site>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Mel Gorman <mgorman@novell.com>, Jan Kara <jack@suse.cz>, colin.king@canonical.com, Chris Mason <chris.mason@oracle.com>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-ext4 <linux-ext4@vger.kernel.org>

On Tue, 2011-05-10 at 15:57 +0000, James Bottomley wrote:
> On Tue, 2011-05-10 at 10:29 -0500, James Bottomley wrote:
> > On Tue, 2011-05-10 at 15:35 +0100, Mel Gorman wrote:
> > > On Tue, May 10, 2011 at 09:01:04AM -0500, James Bottomley wrote:
> > > > On Tue, 2011-05-10 at 11:21 +0100, Mel Gorman wrote:
> > > > > I really would like to hear if the fix makes a big difference or
> > > > > if we need to consider forcing SLUB high-order allocations bailing
> > > > > at the first sign of trouble (e.g. by masking out __GFP_WAIT in
> > > > > allocate_slab). Even with the fix applied, kswapd might be waking up
> > > > > less but processes will still be getting stalled in direct compaction
> > > > > and direct reclaim so it would still be jittery.
> > > > 
> > > > "the fix" being this
> > > > 
> > > > https://lkml.org/lkml/2011/3/5/121
> > > > 
> > > 
> > > Drop this for the moment. It was a long shot at best and there is little
> > > evidence the problem is in this area.
> > > 
> > > I'm attaching two patches. The first is the NO_KSWAPD one to stop
> > > kswapd being woken up by SLUB using speculative high-orders. The second
> > > one is more drastic and prevents slub entering direct reclaim or
> > > compaction. It applies on top of patch 1. These are both untested and
> > > afraid are a bit rushed as well :(
> > 
> > Preliminary results with both patches applied still show kswapd
> > periodically going up to 99% but it doesn't stay there, it comes back
> > down again (and, obviously, the system doesn't hang).
> 
> This is a second run with the watch highorders.
> 
> At the end of the run, the system hung temporarily and now comes back
> with CPU3 spinning in all system time at kswapd shrink_slab

Here's a trace in the same situation with the ftrace stack entries
bumped to 16 as requested on IRC.  There was no hang for this one.

James

---

1 instances order=3 normal gfp_flags=GFP_IO|GFP_NOWARN|GFP_NORETRY|GFP_COMP|
 => __alloc_pages_nodemask+0x754/0x792 <ffffffff810dc0de>
 => alloc_pages_current+0xbe/0xd8 <ffffffff81105459>
 => alloc_slab_page+0x1c/0x4d <ffffffff8110c5fe>
 => new_slab+0x50/0x199 <ffffffff8110dc48>
 => __slab_alloc+0x24a/0x328 <ffffffff8146ab86>
 => kmem_cache_alloc+0x77/0x105 <ffffffff8110e450>
 => shmem_alloc_inode+0x1a/0x2f <ffffffff810e58c4>
 => alloc_inode+0x1d/0x78 <ffffffff81131809>
 => new_inode+0x1b/0x4b <ffffffff8113187f>
 => shmem_get_inode+0x45/0x1f6 <ffffffff810e49b3>
 => shmem_file_setup+0xe4/0x160 <ffffffff810e70ff>
 => drm_gem_object_init+0x34/0x61 [drm] <ffffffffa0024ffc>
 => i915_gem_alloc_object+0x41/0x111 [i915] <ffffffffa007e4cd>
 => i915_gem_create_ioctl+0x3f/0xcf [i915] <ffffffffa007e5dc>
 => drm_ioctl+0x29e/0x37b [drm] <ffffffffa0023815>
 => do_vfs_ioctl+0x47e/0x4bf <ffffffff8112c070>

701 instances order=3 atomic gfp_flags=GFP_ATOMIC|GFP_NOWARN|GFP_NORETRY|GFP_COMP|GFP_NOMEMALLOC|
 => __alloc_pages_nodemask+0x754/0x792 <ffffffff810dc0de>
 => alloc_pages_current+0xbe/0xd8 <ffffffff81105459>
 => alloc_slab_page+0x1c/0x4d <ffffffff8110c5fe>
 => new_slab+0x50/0x199 <ffffffff8110dc48>
 => __slab_alloc+0x24a/0x328 <ffffffff8146ab86>
 => kmem_cache_alloc+0x77/0x105 <ffffffff8110e450>
 => mempool_alloc_slab+0x15/0x17 <ffffffff810d6e85>
 => mempool_alloc+0x68/0x116 <ffffffff810d70fa>
 => scsi_sg_alloc+0x2d/0x2f <ffffffff812f9e90>
 => __sg_alloc_table+0x63/0x11c <ffffffff81230ddf>
 => scsi_alloc_sgtable+0x2a/0x4f <ffffffff812f9ebc>
 => scsi_init_sgtable+0x21/0x61 <ffffffff812f9f02>
 => scsi_init_io+0x32/0x13b <ffffffff812f9f74>
 => scsi_setup_fs_cmnd+0xb9/0xbe <ffffffff812fa1b0>
 => sd_prep_fn+0x27b/0xb6d <ffffffff813026e9>
 => blk_peek_request+0xe1/0x1b6 <ffffffff81213411>

189 instances order=2 normal gfp_flags=GFP_NOWARN|GFP_NORETRY|GFP_COMP|GFP_NOMEMALLOC|
 => __alloc_pages_nodemask+0x754/0x792 <ffffffff810dc0de>
 => alloc_pages_current+0xbe/0xd8 <ffffffff81105459>
 => alloc_slab_page+0x1c/0x4d <ffffffff8110c5fe>
 => new_slab+0x50/0x199 <ffffffff8110dc48>
 => __slab_alloc+0x24a/0x328 <ffffffff8146ab86>
 => kmem_cache_alloc+0x77/0x105 <ffffffff8110e450>
 => mempool_alloc_slab+0x15/0x17 <ffffffff810d6e85>
 => mempool_alloc+0x68/0x116 <ffffffff810d70fa>
 => get_request+0x180/0x262 <ffffffff812124f6>
 => get_request_wait+0x35/0x193 <ffffffff81212f71>
 => __make_request+0x2b4/0x400 <ffffffff81213898>
 => generic_make_request+0x2ae/0x328 <ffffffff8121212f>
 => submit_bio+0xde/0xfd <ffffffff81212287>
 => submit_bh+0xe6/0x105 <ffffffff81140a6f>
 => __block_write_full_page+0x1e7/0x2d7 <ffffffff81141fac>
 => block_write_full_page_endio+0x8a/0x97 <ffffffff81143671>

1 instances order=1 atomic gfp_flags=GFP_ATOMIC|GFP_NOWARN|GFP_NORETRY|GFP_COMP|
 => __alloc_pages_nodemask+0x754/0x792 <ffffffff810dc0de>
 => alloc_pages_current+0xbe/0xd8 <ffffffff81105459>
 => alloc_slab_page+0x1c/0x4d <ffffffff8110c5fe>
 => new_slab+0x50/0x199 <ffffffff8110dc48>
 => __slab_alloc+0x24a/0x328 <ffffffff8146ab86>
 => kmem_cache_alloc+0x77/0x105 <ffffffff8110e450>
 => inet_twsk_alloc+0x31/0x11e <ffffffff813f8a36>
 => tcp_time_wait+0xb9/0x29a <ffffffff8140e26f>
 => tcp_fin+0x7b/0x10f <ffffffff8140191a>
 => tcp_data_queue+0x1e4/0x876 <ffffffff8140207f>
 => tcp_rcv_state_process+0x880/0x8cf <ffffffff81404f67>
 => tcp_v4_do_rcv+0x312/0x363 <ffffffff8140b698>
 => tcp_v4_rcv+0x434/0x69b <ffffffff8140d209>
 => ip_local_deliver_finish+0x13d/0x1ae <ffffffff813f104d>
 => NF_HOOK.constprop.3+0x51/0x58 <ffffffff813f0eb2>
 => ip_local_deliver+0x4f/0x54 <ffffffff813f1205>

1 instances order=1 normal gfp_flags=GFP_NOWARN|GFP_NORETRY|GFP_COMP|GFP_NOMEMALLOC|
 => __alloc_pages_nodemask+0x754/0x792 <ffffffff810dc0de>
 => alloc_pages_current+0xbe/0xd8 <ffffffff81105459>
 => alloc_slab_page+0x1c/0x4d <ffffffff8110c5fe>
 => new_slab+0x50/0x199 <ffffffff8110dc48>
 => __slab_alloc+0x24a/0x328 <ffffffff8146ab86>
 => kmem_cache_alloc+0x77/0x105 <ffffffff8110e450>
 => mempool_alloc_slab+0x15/0x17 <ffffffff810d6e85>
 => mempool_alloc+0x68/0x116 <ffffffff810d70fa>
 => bio_alloc_bioset+0x35/0xc3 <ffffffff81144dd8>
 => bio_alloc+0x15/0x24 <ffffffff81144ef5>
 => submit_bh+0x6d/0x105 <ffffffff811409f6>
 => __ext4_get_inode_loc+0x2ec/0x344 <ffffffff81191333>
 => ext4_iget+0x58/0x64c <ffffffff81192a48>
 => ext4_lookup+0x93/0xf3 <ffffffff8119a79b>
 => d_alloc_and_lookup+0x45/0x6b <ffffffff81126d4b>
 => __lookup_hash+0x7f/0x88 <ffffffff81127eaa>

9 instances order=1 normal gfp_flags=GFP_IO|GFP_NOWARN|GFP_REPEAT|GFP_NORETRY|GFP_COMP|
 => __alloc_pages_nodemask+0x754/0x792 <ffffffff810dc0de>
 => alloc_pages_current+0xbe/0xd8 <ffffffff81105459>
 => alloc_slab_page+0x1c/0x4d <ffffffff8110c5fe>
 => new_slab+0x50/0x199 <ffffffff8110dc48>
 => __slab_alloc+0x24a/0x328 <ffffffff8146ab86>
 => kmem_cache_alloc_node+0x93/0x12d <ffffffff8110e1bd>
 => __alloc_skb+0x40/0x133 <ffffffff813b5e17>
 => sock_alloc_send_pskb+0xb4/0x2d7 <ffffffff813b23aa>
 => sock_alloc_send_skb+0x15/0x17 <ffffffff813b25e2>
 => unix_stream_sendmsg+0x11e/0x2ec <ffffffff8143d237>
 => __sock_sendmsg+0x69/0x76 <ffffffff813af798>
 => sock_aio_write+0xb9/0xc9 <ffffffff813af85e>
 => do_sync_readv_writev+0xb9/0xfe <ffffffff8111e79d>
 => do_readv_writev+0xa7/0x11e <ffffffff8111ea03>
 => vfs_writev+0x45/0x47 <ffffffff8111eabf>
 => sys_writev+0x4a/0x93 <ffffffff8111ebe2>

1 instances order=3 normal gfp_flags=GFP_IO|GFP_NOWARN|GFP_NORETRY|GFP_COMP|
 => __alloc_pages_nodemask+0x754/0x792 <ffffffff810dc0de>
 => alloc_pages_current+0xbe/0xd8 <ffffffff81105459>
 => alloc_slab_page+0x1c/0x4d <ffffffff8110c5fe>
 => new_slab+0x50/0x199 <ffffffff8110dc48>
 => __slab_alloc+0x24a/0x328 <ffffffff8146ab86>
 => kmem_cache_alloc+0x77/0x105 <ffffffff8110e450>
 => sk_prot_alloc+0x37/0x13a <ffffffff813b27f4>
 => sk_alloc+0x2c/0x8e <ffffffff813b2955>
 => unix_create1+0x4e/0x14d <ffffffff8143cae7>
 => unix_stream_connect+0x98/0x431 <ffffffff8143ecc6>
 => sys_connect+0x98/0xd6 <ffffffff813b0437>
 => system_call_fastpath+0x16/0x1b <ffffffff81009b82>

5 instances order=1 normal gfp_flags=GFP_IO|GFP_NOWARN|GFP_NORETRY|GFP_COMP|
 => __alloc_pages_nodemask+0x754/0x792 <ffffffff810dc0de>
 => alloc_pages_current+0xbe/0xd8 <ffffffff81105459>
 => alloc_slab_page+0x1c/0x4d <ffffffff8110c5fe>
 => new_slab+0x50/0x199 <ffffffff8110dc48>
 => __slab_alloc+0x24a/0x328 <ffffffff8146ab86>
 => kmem_cache_alloc+0x77/0x105 <ffffffff8110e450>
 => get_empty_filp+0x7a/0x141 <ffffffff8111f2f5>
 => alloc_file+0x1e/0xbf <ffffffff8111f3da>
 => create_read_pipe+0x2b/0x5b <ffffffff81125ffe>
 => do_pipe_flags+0x4e/0xf4 <ffffffff8112607c>
 => sys_pipe2+0x1c/0x5c <ffffffff8112613e>
 => sys_pipe+0x10/0x12 <ffffffff8112618e>
 => system_call_fastpath+0x16/0x1b <ffffffff81009b82>

6 instances order=3 atomic gfp_flags=GFP_ATOMIC|GFP_NOWARN|GFP_NORETRY|GFP_COMP|
 => __alloc_pages_nodemask+0x754/0x792 <ffffffff810dc0de>
 => alloc_pages_current+0xbe/0xd8 <ffffffff81105459>
 => alloc_slab_page+0x1c/0x4d <ffffffff8110c5fe>
 => new_slab+0x50/0x199 <ffffffff8110dc48>
 => __slab_alloc+0x24a/0x328 <ffffffff8146ab86>
 => __kmalloc_node_track_caller+0xcf/0x131 <ffffffff8110ffca>
 => __alloc_skb+0x75/0x133 <ffffffff813b5e4c>
 => __netdev_alloc_skb+0x1f/0x3b <ffffffff813b5f6a>
 => e1000_alloc_rx_buffers+0x8b/0x14e [e1000e] <ffffffffa01bfb58>
 => e1000_clean_rx_irq+0x2a6/0x2df [e1000e] <ffffffffa01c05a9>
 => e1000_clean+0x73/0x228 [e1000e] <ffffffffa01c0a07>
 => net_rx_action+0xa9/0x1ac <ffffffff813bfea2>
 => __do_softirq+0xd2/0x19d <ffffffff8105abe0>
 => call_softirq+0x1c/0x30 <ffffffff8100aa9c>
 => do_softirq+0x46/0x81 <ffffffff8100c0c1>
 => irq_exit+0x49/0x8b <ffffffff8105ad64>

48 instances order=1 normal gfp_flags=GFP_NOWARN|GFP_NORETRY|GFP_COMP|GFP_NOMEMALLOC|
 => __alloc_pages_nodemask+0x754/0x792 <ffffffff810dc0de>
 => alloc_pages_current+0xbe/0xd8 <ffffffff81105459>
 => __page_cache_alloc+0x77/0x7e <ffffffff810d577c>
 => grab_cache_page_write_begin+0x54/0x9e <ffffffff810d5947>
 => ext4_da_write_begin+0x13f/0x20e <ffffffff8119639a>
 => generic_file_buffered_write+0x109/0x23a <ffffffff810d540c>
 => __generic_file_aio_write+0x242/0x272 <ffffffff810d6181>
 => generic_file_aio_write+0x58/0xa6 <ffffffff810d6209>
 => ext4_file_write+0x1dc/0x234 <ffffffff8118e898>
 => do_sync_write+0xbf/0xff <ffffffff8111dd6f>
 => vfs_write+0xac/0xf3 <ffffffff8111e3e5>
 => sys_write+0x4a/0x6e <ffffffff8111e5d4>
 => system_call_fastpath+0x16/0x1b <ffffffff81009b82>

1 instances order=1 normal gfp_flags=GFP_NOWARN|GFP_NORETRY|GFP_COMP|GFP_NOMEMALLOC|
 => __alloc_pages_nodemask+0x754/0x792 <ffffffff810dc0de>
 => alloc_pages_current+0xbe/0xd8 <ffffffff81105459>
 => __page_cache_alloc+0x77/0x7e <ffffffff810d577c>
 => __do_page_cache_readahead+0x9b/0x177 <ffffffff810dd76f>
 => ra_submit+0x21/0x25 <ffffffff810ddab1>
 => filemap_fault+0x17b/0x36c <ffffffff810d6ade>
 => __do_fault+0x55/0x377 <ffffffff810ee88b>
 => handle_pte_fault+0x2a7/0x7a5 <ffffffff810f0f47>
 => handle_mm_fault+0x1bb/0x1ce <ffffffff810f17bc>
 => do_page_fault+0x358/0x37a <ffffffff814741ae>
 => page_fault+0x25/0x30 <ffffffff81471455>

16 instances order=2 normal gfp_flags=GFP_IO|GFP_NOWARN|GFP_NORETRY|GFP_COMP|GFP_RECLAIMABLE|
 => __alloc_pages_nodemask+0x754/0x792 <ffffffff810dc0de>
 => alloc_pages_current+0xbe/0xd8 <ffffffff81105459>
 => alloc_slab_page+0x1c/0x4d <ffffffff8110c5fe>
 => new_slab+0x50/0x199 <ffffffff8110dc48>
 => __slab_alloc+0x24a/0x328 <ffffffff8146ab86>
 => kmem_cache_alloc+0x77/0x105 <ffffffff8110e450>
 => radix_tree_preload+0x31/0x81 <ffffffff812293bd>
 => add_to_page_cache_locked+0x56/0x118 <ffffffff810d57d9>
 => add_to_page_cache_lru+0x2a/0x58 <ffffffff810d58c5>
 => do_read_cache_page+0x63/0x127 <ffffffff810d59f4>
 => read_cache_page_gfp+0x1e/0x28 <ffffffff810d5ad6>
 => i915_gem_object_bind_to_gtt+0x249/0x45b [i915] <ffffffffa007b0ad>
 => i915_gem_object_pin+0xc7/0x13c [i915] <ffffffffa007d609>
 => i915_gem_execbuffer_reserve+0x1b1/0x2fc [i915] <ffffffffa007f76d>
 => i915_gem_do_execbuffer+0x45b/0x1116 [i915] <ffffffffa008005a>
 => i915_gem_execbuffer2+0xcc/0x12e [i915] <ffffffffa0080ffe>

409 instances order=1 normal gfp_flags=GFP_NOWARN|GFP_NORETRY|GFP_COMP|GFP_NOMEMALLOC|
 => __alloc_pages_nodemask+0x754/0x792 <ffffffff810dc0de>
 => alloc_pages_current+0xbe/0xd8 <ffffffff81105459>
 => alloc_slab_page+0x1c/0x4d <ffffffff8110c5fe>
 => new_slab+0x50/0x199 <ffffffff8110dc48>
 => __slab_alloc+0x24a/0x328 <ffffffff8146ab86>
 => kmem_cache_alloc+0x77/0x105 <ffffffff8110e450>
 => mempool_alloc_slab+0x15/0x17 <ffffffff810d6e85>
 => mempool_alloc+0x68/0x116 <ffffffff810d70fa>
 => bio_alloc_bioset+0x35/0xc3 <ffffffff81144dd8>
 => bio_alloc+0x15/0x24 <ffffffff81144ef5>
 => submit_bh+0x6d/0x105 <ffffffff811409f6>
 => jbd2_journal_commit_transaction+0x6e4/0x1052 <ffffffff811c56a6>
 => kjournald2+0xc9/0x20a <ffffffff811c9764>
 => kthread+0x84/0x8c <ffffffff8106f2df>
 => kernel_thread_helper+0x4/0x10 <ffffffff8100a9a4>

4 instances order=1 normal gfp_flags=GFP_NOWARN|GFP_NORETRY|GFP_COMP|GFP_NOMEMALLOC|
 => __alloc_pages_nodemask+0x754/0x792 <ffffffff810dc0de>
 => alloc_pages_current+0xbe/0xd8 <ffffffff81105459>
 => alloc_slab_page+0x1c/0x4d <ffffffff8110c5fe>
 => new_slab+0x50/0x199 <ffffffff8110dc48>
 => __slab_alloc+0x24a/0x328 <ffffffff8146ab86>
 => kmem_cache_alloc+0x77/0x105 <ffffffff8110e450>
 => mempool_alloc_slab+0x15/0x17 <ffffffff810d6e85>
 => mempool_alloc+0x68/0x116 <ffffffff810d70fa>
 => bio_alloc_bioset+0x35/0xc3 <ffffffff81144dd8>
 => clone_bio+0x41/0xdb <ffffffff81382d3d>
 => __split_and_process_bio+0x23d/0x4ea <ffffffff813837d0>
 => dm_request+0x160/0x172 <ffffffff81383bdd>
 => generic_make_request+0x2ae/0x328 <ffffffff8121212f>
 => submit_bio+0xde/0xfd <ffffffff81212287>
 => mpage_readpages+0xf0/0x104 <ffffffff81148e05>
 => ext4_readpages+0x1d/0x1f <ffffffff8119174d>

1 instances order=1 normal gfp_flags=GFP_IO|GFP_NOWARN|GFP_NORETRY|GFP_COMP|
 => __alloc_pages_nodemask+0x754/0x792 <ffffffff810dc0de>
 => alloc_pages_current+0xbe/0xd8 <ffffffff81105459>
 => alloc_slab_page+0x1c/0x4d <ffffffff8110c5fe>
 => new_slab+0x50/0x199 <ffffffff8110dc48>
 => __slab_alloc+0x24a/0x328 <ffffffff8146ab86>
 => kmem_cache_alloc+0x77/0x105 <ffffffff8110e450>
 => copy_vma+0xe3/0x1e9 <ffffffff810f5cd3>
 => move_vma+0x8a/0x1fb <ffffffff810f7edb>
 => do_mremap+0x40e/0x46a <ffffffff810f845a>
 => sys_mremap+0x54/0x76 <ffffffff810f850a>
 => system_call_fastpath+0x16/0x1b <ffffffff81009b82>

5 instances order=2 normal gfp_flags=GFP_IO|GFP_NOWARN|GFP_NORETRY|GFP_COMP|GFP_RECLAIMABLE|
 => __alloc_pages_nodemask+0x754/0x792 <ffffffff810dc0de>
 => alloc_pages_current+0xbe/0xd8 <ffffffff81105459>
 => alloc_slab_page+0x1c/0x4d <ffffffff8110c5fe>
 => new_slab+0x50/0x199 <ffffffff8110dc48>
 => __slab_alloc+0x24a/0x328 <ffffffff8146ab86>
 => kmem_cache_alloc+0x77/0x105 <ffffffff8110e450>
 => radix_tree_preload+0x31/0x81 <ffffffff812293bd>
 => add_to_page_cache_locked+0x56/0x118 <ffffffff810d57d9>
 => add_to_page_cache_lru+0x2a/0x58 <ffffffff810d58c5>
 => do_read_cache_page+0x63/0x127 <ffffffff810d59f4>
 => read_cache_page_gfp+0x1e/0x28 <ffffffff810d5ad6>
 => i915_gem_object_bind_to_gtt+0x249/0x45b [i915] <ffffffffa007b0ad>
 => i915_gem_fault+0x85/0x18e [i915] <ffffffffa007d287>
 => __do_fault+0x55/0x377 <ffffffff810ee88b>
 => handle_pte_fault+0x2a7/0x7a5 <ffffffff810f0f47>
 => handle_mm_fault+0x1bb/0x1ce <ffffffff810f17bc>

1 instances order=2 normal gfp_flags=GFP_IO|GFP_NOWARN|GFP_NORETRY|GFP_COMP|
 => __alloc_pages_nodemask+0x754/0x792 <ffffffff810dc0de>
 => alloc_pages_current+0xbe/0xd8 <ffffffff81105459>
 => alloc_slab_page+0x1c/0x4d <ffffffff8110c5fe>
 => new_slab+0x50/0x199 <ffffffff8110dc48>
 => __slab_alloc+0x24a/0x328 <ffffffff8146ab86>
 => __kmalloc+0xb1/0x10d <ffffffff8110dfdf>
 => kzalloc.constprop.1+0x13/0x15 [i915] <ffffffffa007fbfd>
 => i915_gem_do_execbuffer+0x306/0x1116 [i915] <ffffffffa007ff05>
 => i915_gem_execbuffer2+0xcc/0x12e [i915] <ffffffffa0080ffe>
 => drm_ioctl+0x29e/0x37b [drm] <ffffffffa0023815>
 => do_vfs_ioctl+0x47e/0x4bf <ffffffff8112c070>
 => sys_ioctl+0x56/0x7b <ffffffff8112c107>
 => system_call_fastpath+0x16/0x1b <ffffffff81009b82>

5 instances order=3 normal gfp_flags=GFP_IO|GFP_NOWARN|GFP_NORETRY|GFP_COMP|
 => __alloc_pages_nodemask+0x754/0x792 <ffffffff810dc0de>
 => alloc_pages_current+0xbe/0xd8 <ffffffff81105459>
 => alloc_slab_page+0x1c/0x4d <ffffffff8110c5fe>
 => new_slab+0x50/0x199 <ffffffff8110dc48>
 => __slab_alloc+0x24a/0x328 <ffffffff8146ab86>
 => kmem_cache_alloc+0x77/0x105 <ffffffff8110e450>
 => copy_process+0xc6/0x10c5 <ffffffff810533b9>
 => do_fork+0x104/0x286 <ffffffff810544f7>
 => sys_clone+0x28/0x2a <ffffffff8101150e>
 => stub_clone+0x13/0x20 <ffffffff81009ea3>

4 instances order=1 normal gfp_flags=GFP_NOWARN|GFP_NORETRY|GFP_COMP|GFP_NOMEMALLOC|
 => __alloc_pages_nodemask+0x754/0x792 <ffffffff810dc0de>
 => alloc_pages_current+0xbe/0xd8 <ffffffff81105459>
 => alloc_slab_page+0x1c/0x4d <ffffffff8110c5fe>
 => new_slab+0x50/0x199 <ffffffff8110dc48>
 => __slab_alloc+0x24a/0x328 <ffffffff8146ab86>
 => kmem_cache_alloc+0x77/0x105 <ffffffff8110e450>
 => mempool_alloc_slab+0x15/0x17 <ffffffff810d6e85>
 => mempool_alloc+0x68/0x116 <ffffffff810d70fa>
 => bio_alloc_bioset+0x35/0xc3 <ffffffff81144dd8>
 => bio_alloc+0x15/0x24 <ffffffff81144ef5>
 => submit_bh+0x6d/0x105 <ffffffff811409f6>
 => ext4_mb_init_cache+0x1e6/0x52b <ffffffff811b45c8>
 => ext4_mb_load_buddy+0x134/0x30f <ffffffff811b4b1c>
 => ext4_mb_regular_allocator+0x13c/0x275 <ffffffff811b6637>
 => ext4_mb_new_blocks+0x17f/0x3c2 <ffffffff811b7432>
 => ext4_ext_map_blocks+0x192b/0x1b5b <ffffffff811b0a81>

102 instances order=1 normal gfp_flags=GFP_NOWARN|GFP_NORETRY|GFP_COMP|GFP_NOMEMALLOC|
 => __alloc_pages_nodemask+0x754/0x792 <ffffffff810dc0de>
 => alloc_pages_current+0xbe/0xd8 <ffffffff81105459>
 => alloc_slab_page+0x1c/0x4d <ffffffff8110c5fe>
 => new_slab+0x50/0x199 <ffffffff8110dc48>
 => __slab_alloc+0x24a/0x328 <ffffffff8146ab86>
 => kmem_cache_alloc+0x77/0x105 <ffffffff8110e450>
 => mempool_alloc_slab+0x15/0x17 <ffffffff810d6e85>
 => mempool_alloc+0x68/0x116 <ffffffff810d70fa>
 => bio_alloc_bioset+0x35/0xc3 <ffffffff81144dd8>
 => bio_alloc+0x15/0x24 <ffffffff81144ef5>
 => submit_bh+0x6d/0x105 <ffffffff811409f6>
 => ll_rw_block+0x84/0xa3 <ffffffff811410f4>
 => __breadahead+0x2e/0x39 <ffffffff81141c86>
 => __ext4_get_inode_loc+0x2c4/0x344 <ffffffff8119130b>
 => ext4_iget+0x58/0x64c <ffffffff81192a48>
 => ext4_lookup+0x93/0xf3 <ffffffff8119a79b>

1 instances order=2 normal gfp_flags=GFP_NOWARN|GFP_NORETRY|GFP_COMP|GFP_NOMEMALLOC|
 => __alloc_pages_nodemask+0x754/0x792 <ffffffff810dc0de>
 => alloc_pages_current+0xbe/0xd8 <ffffffff81105459>
 => alloc_slab_page+0x1c/0x4d <ffffffff8110c5fe>
 => new_slab+0x50/0x199 <ffffffff8110dc48>
 => __slab_alloc+0x24a/0x328 <ffffffff8146ab86>
 => kmem_cache_alloc+0x77/0x105 <ffffffff8110e450>
 => mempool_alloc_slab+0x15/0x17 <ffffffff810d6e85>
 => mempool_alloc+0x68/0x116 <ffffffff810d70fa>
 => get_request+0x180/0x262 <ffffffff812124f6>
 => get_request_wait+0x35/0x193 <ffffffff81212f71>
 => __make_request+0x2b4/0x400 <ffffffff81213898>
 => generic_make_request+0x2ae/0x328 <ffffffff8121212f>
 => submit_bio+0xde/0xfd <ffffffff81212287>
 => mpage_readpages+0xf0/0x104 <ffffffff81148e05>
 => ext4_readpages+0x1d/0x1f <ffffffff8119174d>
 => __do_page_cache_readahead+0x100/0x177 <ffffffff810dd7d4>

3 instances order=1 normal gfp_flags=GFP_IO|GFP_NOWARN|GFP_NORETRY|GFP_COMP|
 => __alloc_pages_nodemask+0x754/0x792 <ffffffff810dc0de>
 => alloc_pages_current+0xbe/0xd8 <ffffffff81105459>
 => alloc_slab_page+0x1c/0x4d <ffffffff8110c5fe>
 => new_slab+0x50/0x199 <ffffffff8110dc48>
 => __slab_alloc+0x24a/0x328 <ffffffff8146ab86>
 => kmem_cache_alloc+0x77/0x105 <ffffffff8110e450>
 => __split_vma+0x6c/0x21b <ffffffff810f50bd>
 => split_vma+0x20/0x22 <ffffffff810f59ca>
 => mprotect_fixup+0x105/0x65b <ffffffff810f70ad>
 => sys_mprotect+0x197/0x209 <ffffffff810f779a>
 => system_call_fastpath+0x16/0x1b <ffffffff81009b82>

14 instances order=1 atomic gfp_flags=GFP_ATOMIC|GFP_NOWARN|GFP_NORETRY|GFP_COMP|
 => __alloc_pages_nodemask+0x754/0x792 <ffffffff810dc0de>
 => alloc_pages_current+0xbe/0xd8 <ffffffff81105459>
 => alloc_slab_page+0x1c/0x4d <ffffffff8110c5fe>
 => new_slab+0x50/0x199 <ffffffff8110dc48>
 => __slab_alloc+0x24a/0x328 <ffffffff8146ab86>
 => kmem_cache_alloc+0x77/0x105 <ffffffff8110e450>
 => scsi_pool_alloc_command+0x29/0x68 <ffffffff812f3063>
 => scsi_host_alloc_command+0x1f/0x6b <ffffffff812f30e9>
 => __scsi_get_command+0x1b/0x96 <ffffffff812f3150>
 => scsi_get_command+0x3d/0xa5 <ffffffff812f3283>
 => scsi_setup_fs_cmnd+0x6e/0xbe <ffffffff812fa165>
 => sd_prep_fn+0x27b/0xb6d <ffffffff813026e9>
 => blk_peek_request+0xe1/0x1b6 <ffffffff81213411>
 => scsi_request_fn+0x82/0x421 <ffffffff812f9a5f>
 => __generic_unplug_device+0x34/0x38 <ffffffff81212f38>
 => generic_unplug_device+0x2d/0x3d <ffffffff812131f0>

7 instances order=1 normal gfp_flags=GFP_IO|GFP_NOWARN|GFP_NORETRY|GFP_COMP|
 => __alloc_pages_nodemask+0x754/0x792 <ffffffff810dc0de>
 => alloc_pages_current+0xbe/0xd8 <ffffffff81105459>
 => alloc_slab_page+0x1c/0x4d <ffffffff8110c5fe>
 => new_slab+0x50/0x199 <ffffffff8110dc48>
 => __slab_alloc+0x24a/0x328 <ffffffff8146ab86>
 => kmem_cache_alloc+0x77/0x105 <ffffffff8110e450>
 => __split_vma+0x6c/0x21b <ffffffff810f50bd>
 => split_vma+0x20/0x22 <ffffffff810f59ca>
 => mprotect_fixup+0x125/0x65b <ffffffff810f70cd>
 => sys_mprotect+0x197/0x209 <ffffffff810f779a>
 => system_call_fastpath+0x16/0x1b <ffffffff81009b82>

1 instances order=2 normal gfp_flags=GFP_IO|GFP_NOWARN|GFP_NORETRY|GFP_COMP|GFP_RECLAIMABLE|
 => __alloc_pages_nodemask+0x754/0x792 <ffffffff810dc0de>
 => alloc_pages_current+0xbe/0xd8 <ffffffff81105459>
 => alloc_slab_page+0x1c/0x4d <ffffffff8110c5fe>
 => new_slab+0x50/0x199 <ffffffff8110dc48>
 => __slab_alloc+0x24a/0x328 <ffffffff8146ab86>
 => kmem_cache_alloc+0x77/0x105 <ffffffff8110e450>
 => radix_tree_preload+0x31/0x81 <ffffffff812293bd>
 => add_to_page_cache_locked+0x56/0x118 <ffffffff810d57d9>
 => add_to_page_cache_lru+0x2a/0x58 <ffffffff810d58c5>
 => find_or_create_page+0x5a/0x8a <ffffffff810d5b6d>
 => __getblk+0x137/0x23a <ffffffff81141b55>
 => ext4_getblk+0x8e/0x153 <ffffffff811957c0>
 => ext4_bread+0x16/0x66 <ffffffff8119589b>
 => ext4_mkdir+0x159/0x33e <ffffffff8119b786>
 => vfs_mkdir+0x5f/0x9b <ffffffff81128b01>
 => sys_mkdirat+0x97/0xe8 <ffffffff8112a3dd>

4 instances order=3 normal gfp_flags=GFP_IO|GFP_NOWARN|GFP_REPEAT|GFP_NORETRY|GFP_COMP|
 => __alloc_pages_nodemask+0x754/0x792 <ffffffff810dc0de>
 => alloc_pages_current+0xbe/0xd8 <ffffffff81105459>
 => alloc_slab_page+0x1c/0x4d <ffffffff8110c5fe>
 => new_slab+0x50/0x199 <ffffffff8110dc48>
 => __slab_alloc+0x24a/0x328 <ffffffff8146ab86>
 => __kmalloc_node_track_caller+0xcf/0x131 <ffffffff8110ffca>
 => __alloc_skb+0x75/0x133 <ffffffff813b5e4c>
 => sock_alloc_send_pskb+0xb4/0x2d7 <ffffffff813b23aa>
 => sock_alloc_send_skb+0x15/0x17 <ffffffff813b25e2>
 => unix_stream_sendmsg+0x11e/0x2ec <ffffffff8143d237>
 => __sock_sendmsg+0x69/0x76 <ffffffff813af798>
 => sock_sendmsg+0xa1/0xb6 <ffffffff813af90f>
 => sys_sendmsg+0x237/0x2b5 <ffffffff813b0cd9>
 => system_call_fastpath+0x16/0x1b <ffffffff81009b82>

2 instances order=3 normal gfp_flags=GFP_IO|GFP_NOWARN|GFP_REPEAT|GFP_NORETRY|GFP_COMP|
 => __alloc_pages_nodemask+0x754/0x792 <ffffffff810dc0de>
 => alloc_pages_current+0xbe/0xd8 <ffffffff81105459>
 => alloc_slab_page+0x1c/0x4d <ffffffff8110c5fe>
 => new_slab+0x50/0x199 <ffffffff8110dc48>
 => __slab_alloc+0x24a/0x328 <ffffffff8146ab86>
 => __kmalloc_node_track_caller+0xcf/0x131 <ffffffff8110ffca>
 => __alloc_skb+0x75/0x133 <ffffffff813b5e4c>
 => sock_alloc_send_pskb+0xb4/0x2d7 <ffffffff813b23aa>
 => sock_alloc_send_skb+0x15/0x17 <ffffffff813b25e2>
 => unix_stream_sendmsg+0x11e/0x2ec <ffffffff8143d237>
 => __sock_sendmsg+0x69/0x76 <ffffffff813af798>
 => sock_aio_write+0xb9/0xc9 <ffffffff813af85e>
 => do_sync_readv_writev+0xb9/0xfe <ffffffff8111e79d>
 => do_readv_writev+0xa7/0x11e <ffffffff8111ea03>
 => vfs_writev+0x45/0x47 <ffffffff8111eabf>
 => sys_writev+0x4a/0x93 <ffffffff8111ebe2>

1 instances order=1 normal gfp_flags=GFP_NOWARN|GFP_NORETRY|GFP_COMP|GFP_NOMEMALLOC|
 => __alloc_pages_nodemask+0x754/0x792 <ffffffff810dc0de>
 => alloc_pages_current+0xbe/0xd8 <ffffffff81105459>
 => alloc_slab_page+0x1c/0x4d <ffffffff8110c5fe>
 => new_slab+0x50/0x199 <ffffffff8110dc48>
 => __slab_alloc+0x24a/0x328 <ffffffff8146ab86>
 => kmem_cache_alloc+0x77/0x105 <ffffffff8110e450>
 => mempool_alloc_slab+0x15/0x17 <ffffffff810d6e85>
 => mempool_alloc+0x68/0x116 <ffffffff810d70fa>
 => bio_alloc_bioset+0x35/0xc3 <ffffffff81144dd8>
 => bio_alloc+0x15/0x24 <ffffffff81144ef5>
 => submit_bh+0x6d/0x105 <ffffffff811409f6>
 => ext4_mb_init_cache+0x1e6/0x52b <ffffffff811b45c8>
 => ext4_mb_init_group+0x100/0x281 <ffffffff8146b9f8>
 => ext4_mb_good_group+0x58/0xdb <ffffffff811b4965>
 => ext4_mb_regular_allocator+0x125/0x275 <ffffffff811b6620>
 => ext4_mb_new_blocks+0x17f/0x3c2 <ffffffff811b7432>

39 instances order=1 normal gfp_flags=GFP_NOWARN|GFP_NORETRY|GFP_COMP|GFP_NOMEMALLOC|
 => __alloc_pages_nodemask+0x754/0x792 <ffffffff810dc0de>
 => alloc_pages_current+0xbe/0xd8 <ffffffff81105459>
 => alloc_slab_page+0x1c/0x4d <ffffffff8110c5fe>
 => new_slab+0x50/0x199 <ffffffff8110dc48>
 => __slab_alloc+0x24a/0x328 <ffffffff8146ab86>
 => kmem_cache_alloc+0x77/0x105 <ffffffff8110e450>
 => mempool_alloc_slab+0x15/0x17 <ffffffff810d6e85>
 => mempool_alloc+0x68/0x116 <ffffffff810d70fa>
 => bio_alloc_bioset+0x35/0xc3 <ffffffff81144dd8>
 => bio_alloc+0x15/0x24 <ffffffff81144ef5>
 => submit_bh+0x6d/0x105 <ffffffff811409f6>
 => ll_rw_block+0x84/0xa3 <ffffffff811410f4>
 => __breadahead+0x2e/0x39 <ffffffff81141c86>
 => __ext4_get_inode_loc+0x2c4/0x344 <ffffffff8119130b>
 => ext4_get_inode_loc+0x2e/0x33 <ffffffff81192936>
 => ext4_reserve_inode_write+0x26/0x83 <ffffffff81193de1>

66 instances order=1 atomic gfp_flags=GFP_ATOMIC|GFP_NOWARN|GFP_NORETRY|GFP_COMP|GFP_NOMEMALLOC|
 => __alloc_pages_nodemask+0x754/0x792 <ffffffff810dc0de>
 => alloc_pages_current+0xbe/0xd8 <ffffffff81105459>
 => alloc_slab_page+0x1c/0x4d <ffffffff8110c5fe>
 => new_slab+0x50/0x199 <ffffffff8110dc48>
 => __slab_alloc+0x24a/0x328 <ffffffff8146ab86>
 => kmem_cache_alloc+0x77/0x105 <ffffffff8110e450>
 => mempool_alloc_slab+0x15/0x17 <ffffffff810d6e85>
 => mempool_alloc+0x68/0x116 <ffffffff810d70fa>
 => scsi_sg_alloc+0x2d/0x2f <ffffffff812f9e90>
 => __sg_alloc_table+0x63/0x11c <ffffffff81230ddf>
 => scsi_alloc_sgtable+0x2a/0x4f <ffffffff812f9ebc>
 => scsi_init_sgtable+0x21/0x61 <ffffffff812f9f02>
 => scsi_init_io+0x32/0x13b <ffffffff812f9f74>
 => scsi_setup_fs_cmnd+0xb9/0xbe <ffffffff812fa1b0>
 => sd_prep_fn+0x27b/0xb6d <ffffffff813026e9>
 => blk_peek_request+0xe1/0x1b6 <ffffffff81213411>

2 instances order=2 normal gfp_flags=GFP_KERNEL|GFP_REPEAT|GFP_COMP
 => __alloc_pages_nodemask+0x754/0x792 <ffffffff810dc0de>
 => alloc_pages_current+0xbe/0xd8 <ffffffff81105459>
 => __page_cache_alloc+0x77/0x7e <ffffffff810d577c>
 => do_read_cache_page+0x48/0x127 <ffffffff810d59d9>
 => read_cache_page_gfp+0x1e/0x28 <ffffffff810d5ad6>
 => i915_gem_object_bind_to_gtt+0x249/0x45b [i915] <ffffffffa007b0ad>
 => i915_gem_object_pin+0xc7/0x13c [i915] <ffffffffa007d609>
 => i915_gem_execbuffer_reserve+0x1b1/0x2fc [i915] <ffffffffa007f76d>
 => i915_gem_do_execbuffer+0x45b/0x1116 [i915] <ffffffffa008005a>
 => i915_gem_execbuffer2+0xcc/0x12e [i915] <ffffffffa0080ffe>
 => drm_ioctl+0x29e/0x37b [drm] <ffffffffa0023815>
 => do_vfs_ioctl+0x47e/0x4bf <ffffffff8112c070>
 => sys_ioctl+0x56/0x7b <ffffffff8112c107>
 => system_call_fastpath+0x16/0x1b <ffffffff81009b82>

148 instances order=9 normal gfp_flags=GFP_HIGHUSER_MOVABLE|GFP_NOWARN|GFP_NORETRY|GFP_COMP|GFP_NOMEMALLOC|
 => __alloc_pages_nodemask+0x754/0x792 <ffffffff810dc0de>
 => alloc_pages_vma+0xf5/0xfa <ffffffff81107025>
 => khugepaged+0x543/0xf2d <ffffffff81113ce5>
 => kthread+0x84/0x8c <ffffffff8106f2df>
 => kernel_thread_helper+0x4/0x10 <ffffffff8100a9a4>

526 instances order=3 normal gfp_flags=GFP_IO|GFP_NOWARN|GFP_NORETRY|GFP_COMP|GFP_RECLAIMABLE|
 => __alloc_pages_nodemask+0x754/0x792 <ffffffff810dc0de>
 => alloc_pages_current+0xbe/0xd8 <ffffffff81105459>
 => alloc_slab_page+0x1c/0x4d <ffffffff8110c5fe>
 => new_slab+0x50/0x199 <ffffffff8110dc48>
 => __slab_alloc+0x24a/0x328 <ffffffff8146ab86>
 => kmem_cache_alloc+0x77/0x105 <ffffffff8110e450>
 => ext4_alloc_inode+0x1a/0x111 <ffffffff8119f4bc>
 => alloc_inode+0x1d/0x78 <ffffffff81131809>
 => new_inode+0x1b/0x4b <ffffffff8113187f>
 => ext4_new_inode+0xa1/0xcf2 <ffffffff8118f9cb>
 => ext4_create+0xbc/0x13e <ffffffff8119b32e>
 => vfs_create+0x6c/0x8e <ffffffff81128c64>
 => do_last+0x166/0x2df <ffffffff81129993>
 => do_filp_open+0x2ac/0x60a <ffffffff81129db8>
 => do_sys_open+0x60/0xf2 <ffffffff8111d95b>
 => sys_openat+0x11/0x13 <ffffffff8111da20>

17 instances order=1 atomic gfp_flags=GFP_ATOMIC|GFP_NOWARN|GFP_NORETRY|GFP_COMP|
 => __alloc_pages_nodemask+0x754/0x792 <ffffffff810dc0de>
 => alloc_pages_current+0xbe/0xd8 <ffffffff81105459>
 => alloc_slab_page+0x1c/0x4d <ffffffff8110c5fe>
 => new_slab+0x50/0x199 <ffffffff8110dc48>
 => __slab_alloc+0x24a/0x328 <ffffffff8146ab86>
 => kmem_cache_alloc+0x77/0x105 <ffffffff8110e450>
 => scsi_pool_alloc_command+0x29/0x68 <ffffffff812f3063>
 => scsi_host_alloc_command+0x1f/0x6b <ffffffff812f30e9>
 => __scsi_get_command+0x1b/0x96 <ffffffff812f3150>
 => scsi_get_command+0x3d/0xa5 <ffffffff812f3283>
 => scsi_setup_fs_cmnd+0x6e/0xbe <ffffffff812fa165>
 => sd_prep_fn+0x27b/0xb6d <ffffffff813026e9>
 => blk_peek_request+0xe1/0x1b6 <ffffffff81213411>
 => scsi_request_fn+0x82/0x421 <ffffffff812f9a5f>
 => __generic_unplug_device+0x34/0x38 <ffffffff81212f38>
 => __make_request+0x3a3/0x400 <ffffffff81213987>

43 instances order=1 normal gfp_flags=GFP_NOWARN|GFP_NORETRY|GFP_COMP|GFP_NOMEMALLOC|
 => __alloc_pages_nodemask+0x754/0x792 <ffffffff810dc0de>
 => alloc_pages_current+0xbe/0xd8 <ffffffff81105459>
 => alloc_slab_page+0x1c/0x4d <ffffffff8110c5fe>
 => new_slab+0x50/0x199 <ffffffff8110dc48>
 => __slab_alloc+0x24a/0x328 <ffffffff8146ab86>
 => kmem_cache_alloc+0x77/0x105 <ffffffff8110e450>
 => mempool_alloc_slab+0x15/0x17 <ffffffff810d6e85>
 => mempool_alloc+0x68/0x116 <ffffffff810d70fa>
 => bio_alloc_bioset+0x35/0xc3 <ffffffff81144dd8>
 => bio_alloc+0x15/0x24 <ffffffff81144ef5>
 => submit_bh+0x6d/0x105 <ffffffff811409f6>
 => ll_rw_block+0x84/0xa3 <ffffffff811410f4>
 => __breadahead+0x2e/0x39 <ffffffff81141c86>
 => __ext4_get_inode_loc+0x2c4/0x344 <ffffffff8119130b>
 => ext4_get_inode_loc+0x2e/0x33 <ffffffff81192936>
 => ext4_xattr_get+0x57/0x213 <ffffffff811baf2b>

1 instances order=1 normal gfp_flags=GFP_IO|GFP_NOWARN|GFP_NORETRY|GFP_COMP|
 => __alloc_pages_nodemask+0x754/0x792 <ffffffff810dc0de>
 => alloc_pages_current+0xbe/0xd8 <ffffffff81105459>
 => alloc_slab_page+0x1c/0x4d <ffffffff8110c5fe>
 => new_slab+0x50/0x199 <ffffffff8110dc48>
 => __slab_alloc+0x24a/0x328 <ffffffff8146ab86>
 => __kmalloc+0xb1/0x10d <ffffffff8110dfdf>
 => drm_malloc_ab+0x3b/0x53 [i915] <ffffffffa007fbd2>
 => i915_gem_execbuffer2+0x4f/0x12e [i915] <ffffffffa0080f81>
 => drm_ioctl+0x29e/0x37b [drm] <ffffffffa0023815>
 => do_vfs_ioctl+0x47e/0x4bf <ffffffff8112c070>
 => sys_ioctl+0x56/0x7b <ffffffff8112c107>
 => system_call_fastpath+0x16/0x1b <ffffffff81009b82>

6 instances order=1 normal gfp_flags=GFP_IO|GFP_NOWARN|GFP_NORETRY|GFP_COMP|
 => __alloc_pages_nodemask+0x754/0x792 <ffffffff810dc0de>
 => alloc_pages_current+0xbe/0xd8 <ffffffff81105459>
 => alloc_slab_page+0x1c/0x4d <ffffffff8110c5fe>
 => new_slab+0x50/0x199 <ffffffff8110dc48>
 => __slab_alloc+0x24a/0x328 <ffffffff8146ab86>
 => kmem_cache_alloc+0x77/0x105 <ffffffff8110e450>
 => mmap_region+0x1b7/0x446 <ffffffff810f6579>
 => do_mmap_pgoff+0x298/0x2f2 <ffffffff810f6aa0>
 => sys_mmap_pgoff+0x115/0x164 <ffffffff810f6c0f>
 => sys_mmap+0x22/0x24 <ffffffff8100da68>
 => system_call_fastpath+0x16/0x1b <ffffffff81009b82>

763 instances order=1 normal gfp_flags=GFP_IO|GFP_NOWARN|GFP_NORETRY|GFP_COMP|
 => __alloc_pages_nodemask+0x754/0x792 <ffffffff810dc0de>
 => alloc_pages_current+0xbe/0xd8 <ffffffff81105459>
 => alloc_slab_page+0x1c/0x4d <ffffffff8110c5fe>
 => new_slab+0x50/0x199 <ffffffff8110dc48>
 => __slab_alloc+0x24a/0x328 <ffffffff8146ab86>
 => kmem_cache_alloc+0x77/0x105 <ffffffff8110e450>
 => get_empty_filp+0x7a/0x141 <ffffffff8111f2f5>
 => do_filp_open+0xe7/0x60a <ffffffff81129bf3>
 => do_sys_open+0x60/0xf2 <ffffffff8111d95b>
 => sys_open+0x20/0x22 <ffffffff8111da0d>
 => system_call_fastpath+0x16/0x1b <ffffffff81009b82>

59 instances order=3 normal gfp_flags=GFP_IO|GFP_NOWARN|GFP_NORETRY|GFP_COMP|GFP_RECLAIMABLE|
 => __alloc_pages_nodemask+0x754/0x792 <ffffffff810dc0de>
 => alloc_pages_current+0xbe/0xd8 <ffffffff81105459>
 => alloc_slab_page+0x1c/0x4d <ffffffff8110c5fe>
 => new_slab+0x50/0x199 <ffffffff8110dc48>
 => __slab_alloc+0x24a/0x328 <ffffffff8146ab86>
 => kmem_cache_alloc+0x77/0x105 <ffffffff8110e450>
 => ext4_alloc_inode+0x1a/0x111 <ffffffff8119f4bc>
 => alloc_inode+0x1d/0x78 <ffffffff81131809>
 => new_inode+0x1b/0x4b <ffffffff8113187f>
 => ext4_new_inode+0xa1/0xcf2 <ffffffff8118f9cb>
 => ext4_mkdir+0x10b/0x33e <ffffffff8119b738>
 => vfs_mkdir+0x5f/0x9b <ffffffff81128b01>
 => sys_mkdirat+0x97/0xe8 <ffffffff8112a3dd>
 => system_call_fastpath+0x16/0x1b <ffffffff81009b82>

83 instances order=1 normal gfp_flags=GFP_IO|GFP_NOWARN|GFP_NORETRY|GFP_COMP|
 => __alloc_pages_nodemask+0x754/0x792 <ffffffff810dc0de>
 => alloc_pages_current+0xbe/0xd8 <ffffffff81105459>
 => alloc_slab_page+0x1c/0x4d <ffffffff8110c5fe>
 => new_slab+0x50/0x199 <ffffffff8110dc48>
 => __slab_alloc+0x24a/0x328 <ffffffff8146ab86>
 => kmem_cache_alloc+0x77/0x105 <ffffffff8110e450>
 => dup_mm+0x1f8/0x486 <ffffffff81053039>
 => copy_process+0x917/0x10c5 <ffffffff81053c0a>
 => do_fork+0x104/0x286 <ffffffff810544f7>
 => sys_clone+0x28/0x2a <ffffffff8101150e>
 => stub_clone+0x13/0x20 <ffffffff81009ea3>

4 instances order=3 normal gfp_flags=GFP_NOWARN|GFP_NORETRY|GFP_COMP|GFP_NOMEMALLOC|
 => __alloc_pages_nodemask+0x754/0x792 <ffffffff810dc0de>
 => alloc_pages_current+0xbe/0xd8 <ffffffff81105459>
 => alloc_slab_page+0x1c/0x4d <ffffffff8110c5fe>
 => new_slab+0x50/0x199 <ffffffff8110dc48>
 => __slab_alloc+0x24a/0x328 <ffffffff8146ab86>
 => kmem_cache_alloc+0x77/0x105 <ffffffff8110e450>
 => bvec_alloc_bs+0xae/0xcc <ffffffff81144d85>
 => bio_alloc_bioset+0x75/0xc3 <ffffffff81144e18>
 => bio_alloc+0x15/0x24 <ffffffff81144ef5>
 => mpage_alloc+0x2a/0x84 <ffffffff8114866b>
 => do_mpage_readpage+0x38c/0x468 <ffffffff81148bcf>
 => mpage_readpages+0xbe/0x104 <ffffffff81148dd3>
 => ext4_readpages+0x1d/0x1f <ffffffff8119174d>
 => __do_page_cache_readahead+0x100/0x177 <ffffffff810dd7d4>
 => ra_submit+0x21/0x25 <ffffffff810ddab1>
 => ondemand_readahead+0x1c9/0x1d8 <ffffffff810ddc7e>

33 instances order=1 atomic gfp_flags=GFP_ATOMIC|GFP_NOWARN|GFP_NORETRY|GFP_COMP|
 => __alloc_pages_nodemask+0x754/0x792 <ffffffff810dc0de>
 => alloc_pages_current+0xbe/0xd8 <ffffffff81105459>
 => alloc_slab_page+0x1c/0x4d <ffffffff8110c5fe>
 => new_slab+0x50/0x199 <ffffffff8110dc48>
 => __slab_alloc+0x24a/0x328 <ffffffff8146ab86>
 => kmem_cache_alloc+0x77/0x105 <ffffffff8110e450>
 => scsi_pool_alloc_command+0x29/0x68 <ffffffff812f3063>
 => scsi_host_alloc_command+0x1f/0x6b <ffffffff812f30e9>
 => __scsi_get_command+0x1b/0x96 <ffffffff812f3150>
 => scsi_get_command+0x3d/0xa5 <ffffffff812f3283>
 => scsi_setup_fs_cmnd+0x6e/0xbe <ffffffff812fa165>
 => sd_prep_fn+0x27b/0xb6d <ffffffff813026e9>
 => blk_peek_request+0xe1/0x1b6 <ffffffff81213411>
 => scsi_request_fn+0x82/0x421 <ffffffff812f9a5f>
 => __generic_unplug_device+0x34/0x38 <ffffffff81212f38>
 => elv_insert+0x172/0x17b <ffffffff8120dae8>

1 instances order=1 normal gfp_flags=GFP_KERNEL
 => __alloc_pages_nodemask+0x754/0x792 <ffffffff810dc0de>
 => alloc_pages_vma+0xf5/0xfa <ffffffff81107025>
 => do_wp_page+0x348/0x560 <ffffffff810ef735>
 => handle_pte_fault+0x73b/0x7a5 <ffffffff810f13db>
 => handle_mm_fault+0x1bb/0x1ce <ffffffff810f17bc>
 => do_page_fault+0x358/0x37a <ffffffff814741ae>
 => page_fault+0x25/0x30 <ffffffff81471455>

1 instances order=1 normal gfp_flags=GFP_IO|GFP_NOWARN|GFP_NORETRY|GFP_COMP|GFP_RECLAIMABLE|
 => __alloc_pages_nodemask+0x754/0x792 <ffffffff810dc0de>
 => alloc_pages_current+0xbe/0xd8 <ffffffff81105459>
 => alloc_slab_page+0x1c/0x4d <ffffffff8110c5fe>
 => new_slab+0x50/0x199 <ffffffff8110dc48>
 => __slab_alloc+0x24a/0x328 <ffffffff8146ab86>
 => kmem_cache_alloc+0x77/0x105 <ffffffff8110e450>
 => d_alloc+0x26/0x18d <ffffffff8112e4e9>
 => d_alloc_and_lookup+0x2c/0x6b <ffffffff81126d32>
 => do_lookup+0x23a/0x287 <ffffffff81127dde>
 => link_path_walk+0x239/0x3b8 <ffffffff81128469>
 => do_path_lookup+0x4d/0xf6 <ffffffff8112881b>
 => do_filp_open+0x129/0x60a <ffffffff81129c35>
 => do_sys_open+0x60/0xf2 <ffffffff8111d95b>
 => sys_open+0x20/0x22 <ffffffff8111da0d>
 => system_call_fastpath+0x16/0x1b <ffffffff81009b82>

1 instances order=1 normal gfp_flags=GFP_NOWARN|GFP_NORETRY|GFP_COMP|GFP_NOMEMALLOC|
 => __alloc_pages_nodemask+0x754/0x792 <ffffffff810dc0de>
 => alloc_pages_current+0xbe/0xd8 <ffffffff81105459>
 => alloc_slab_page+0x1c/0x4d <ffffffff8110c5fe>
 => new_slab+0x50/0x199 <ffffffff8110dc48>
 => __slab_alloc+0x24a/0x328 <ffffffff8146ab86>
 => kmem_cache_alloc+0x77/0x105 <ffffffff8110e450>
 => mempool_alloc_slab+0x15/0x17 <ffffffff810d6e85>
 => mempool_alloc+0x68/0x116 <ffffffff810d70fa>
 => bio_alloc_bioset+0x35/0xc3 <ffffffff81144dd8>
 => bio_alloc+0x15/0x24 <ffffffff81144ef5>
 => submit_bh+0x6d/0x105 <ffffffff811409f6>
 => __ext4_get_inode_loc+0x2ec/0x344 <ffffffff81191333>
 => ext4_get_inode_loc+0x2e/0x33 <ffffffff81192936>
 => ext4_xattr_get+0x57/0x213 <ffffffff811baf2b>
 => ext4_xattr_security_get+0x2a/0x2c <ffffffff811bc92d>
 => generic_getxattr+0x57/0x60 <ffffffff81137e27>

1 instances order=3 atomic gfp_flags=GFP_ATOMIC|GFP_NOWARN|GFP_NORETRY|GFP_COMP|
 => __alloc_pages_nodemask+0x754/0x792 <ffffffff810dc0de>
 => alloc_pages_current+0xbe/0xd8 <ffffffff81105459>
 => alloc_slab_page+0x1c/0x4d <ffffffff8110c5fe>
 => new_slab+0x50/0x199 <ffffffff8110dc48>
 => __slab_alloc+0x24a/0x328 <ffffffff8146ab86>
 => __kmalloc+0xb1/0x10d <ffffffff8110dfdf>
 => kcalloc+0x38/0x3a <ffffffff811f5ff2>
 => security_get_user_sids+0x1c2/0x369 <ffffffff811f8503>
 => sel_write_user+0xd6/0x19d <ffffffff811ef5b3>
 => selinux_transaction_write+0x5b/0x77 <ffffffff811edbfc>
 => vfs_write+0xac/0xf3 <ffffffff8111e3e5>
 => sys_write+0x4a/0x6e <ffffffff8111e5d4>
 => system_call_fastpath+0x16/0x1b <ffffffff81009b82>

15 instances order=2 normal gfp_flags=GFP_IO|GFP_NOWARN|GFP_NORETRY|GFP_COMP|GFP_RECLAIMABLE|
 => __alloc_pages_nodemask+0x754/0x792 <ffffffff810dc0de>
 => alloc_pages_current+0xbe/0xd8 <ffffffff81105459>
 => alloc_slab_page+0x1c/0x4d <ffffffff8110c5fe>
 => new_slab+0x50/0x199 <ffffffff8110dc48>
 => __slab_alloc+0x24a/0x328 <ffffffff8146ab86>
 => kmem_cache_alloc+0x77/0x105 <ffffffff8110e450>
 => proc_alloc_inode+0x20/0x91 <ffffffff811682c0>
 => alloc_inode+0x1d/0x78 <ffffffff81131809>
 => new_inode+0x1b/0x4b <ffffffff8113187f>
 => proc_pid_make_inode+0x14/0xb7 <ffffffff811697c0>
 => proc_pident_instantiate+0x22/0xb1 <ffffffff8116c202>
 => proc_pident_lookup+0x84/0xa3 <ffffffff8116c3ce>
 => proc_tgid_base_lookup+0x1a/0x1c <ffffffff8116c43f>
 => d_alloc_and_lookup+0x45/0x6b <ffffffff81126d4b>
 => do_lookup+0x23a/0x287 <ffffffff81127dde>
 => link_path_walk+0x239/0x3b8 <ffffffff81128469>

213 instances order=1 normal gfp_flags=GFP_KERNEL
 => __alloc_pages_nodemask+0x754/0x792 <ffffffff810dc0de>
 => alloc_pages_current+0xbe/0xd8 <ffffffff81105459>
 => __get_free_pages+0xe/0x4a <ffffffff810d89d6>
 => copy_process+0xe1/0x10c5 <ffffffff810533d4>
 => do_fork+0x104/0x286 <ffffffff810544f7>
 => sys_clone+0x28/0x2a <ffffffff8101150e>
 => stub_clone+0x13/0x20 <ffffffff81009ea3>

140162 instances order=1 normal gfp_flags=GFP_NOWARN|GFP_NORETRY|GFP_COMP|GFP_NOMEMALLOC|
 => __alloc_pages_nodemask+0x754/0x792 <ffffffff810dc0de>
 => alloc_pages_current+0xbe/0xd8 <ffffffff81105459>
 => alloc_slab_page+0x1c/0x4d <ffffffff8110c5fe>
 => new_slab+0x50/0x199 <ffffffff8110dc48>
 => __slab_alloc+0x24a/0x328 <ffffffff8146ab86>
 => kmem_cache_alloc+0x77/0x105 <ffffffff8110e450>
 => mempool_alloc_slab+0x15/0x17 <ffffffff810d6e85>
 => mempool_alloc+0x68/0x116 <ffffffff810d70fa>
 => bio_alloc_bioset+0x35/0xc3 <ffffffff81144dd8>
 => bio_alloc+0x15/0x24 <ffffffff81144ef5>
 => submit_bh+0x6d/0x105 <ffffffff811409f6>
 => __block_write_full_page+0x1e7/0x2d7 <ffffffff81141fac>
 => block_write_full_page_endio+0x8a/0x97 <ffffffff81143671>
 => block_write_full_page+0x15/0x17 <ffffffff81143693>
 => mpage_da_submit_io+0x31a/0x395 <ffffffff811935d8>
 => mpage_da_map_and_submit+0x2ca/0x2e0 <ffffffff81196e88>

2 instances order=1 normal gfp_flags=GFP_IO|GFP_NOWARN|GFP_NORETRY|GFP_COMP|GFP_RECLAIMABLE|
 => __alloc_pages_nodemask+0x754/0x792 <ffffffff810dc0de>
 => alloc_pages_current+0xbe/0xd8 <ffffffff81105459>
 => alloc_slab_page+0x1c/0x4d <ffffffff8110c5fe>
 => new_slab+0x50/0x199 <ffffffff8110dc48>
 => __slab_alloc+0x24a/0x328 <ffffffff8146ab86>
 => kmem_cache_alloc+0x77/0x105 <ffffffff8110e450>
 => d_alloc+0x26/0x18d <ffffffff8112e4e9>
 => d_alloc_and_lookup+0x2c/0x6b <ffffffff81126d32>
 => __lookup_hash+0x7f/0x88 <ffffffff81127eaa>
 => lookup_hash+0x19/0x1b <ffffffff81127ecc>
 => lookup_create+0x4e/0x94 <ffffffff81127f1c>
 => sys_mkdirat+0x43/0xe8 <ffffffff8112a389>
 => system_call_fastpath+0x16/0x1b <ffffffff81009b82>

53 instances order=1 normal gfp_flags=GFP_NOWARN|GFP_NORETRY|GFP_COMP|GFP_NOMEMALLOC|
 => __alloc_pages_nodemask+0x754/0x792 <ffffffff810dc0de>
 => alloc_pages_current+0xbe/0xd8 <ffffffff81105459>
 => alloc_slab_page+0x1c/0x4d <ffffffff8110c5fe>
 => new_slab+0x50/0x199 <ffffffff8110dc48>
 => __slab_alloc+0x24a/0x328 <ffffffff8146ab86>
 => kmem_cache_alloc+0x77/0x105 <ffffffff8110e450>
 => mempool_alloc_slab+0x15/0x17 <ffffffff810d6e85>
 => mempool_alloc+0x68/0x116 <ffffffff810d70fa>
 => bio_alloc_bioset+0x35/0xc3 <ffffffff81144dd8>
 => clone_bio+0x41/0xdb <ffffffff81382d3d>
 => __split_and_process_bio+0x23d/0x4ea <ffffffff813837d0>
 => dm_request+0x160/0x172 <ffffffff81383bdd>
 => generic_make_request+0x2ae/0x328 <ffffffff8121212f>
 => submit_bio+0xde/0xfd <ffffffff81212287>
 => submit_bh+0xe6/0x105 <ffffffff81140a6f>
 => jbd2_journal_commit_transaction+0x6e4/0x1052 <ffffffff811c56a6>

31 instances order=1 atomic gfp_flags=GFP_ATOMIC|GFP_NOWARN|GFP_NORETRY|GFP_COMP|
 => __alloc_pages_nodemask+0x754/0x792 <ffffffff810dc0de>
 => alloc_pages_current+0xbe/0xd8 <ffffffff81105459>
 => alloc_slab_page+0x1c/0x4d <ffffffff8110c5fe>
 => new_slab+0x50/0x199 <ffffffff8110dc48>
 => __slab_alloc+0x24a/0x328 <ffffffff8146ab86>
 => kmem_cache_alloc+0x77/0x105 <ffffffff8110e450>
 => scsi_pool_alloc_command+0x29/0x68 <ffffffff812f3063>
 => scsi_host_alloc_command+0x1f/0x6b <ffffffff812f30e9>
 => __scsi_get_command+0x1b/0x96 <ffffffff812f3150>
 => scsi_get_command+0x3d/0xa5 <ffffffff812f3283>
 => scsi_setup_fs_cmnd+0x6e/0xbe <ffffffff812fa165>
 => sd_prep_fn+0x27b/0xb6d <ffffffff813026e9>
 => blk_peek_request+0xe1/0x1b6 <ffffffff81213411>
 => scsi_request_fn+0x82/0x421 <ffffffff812f9a5f>
 => __blk_run_queue+0x4a/0x7a <ffffffff81212b10>
 => blk_run_queue+0x28/0x3c <ffffffff81212bf9>

1 instances order=3 atomic gfp_flags=GFP_ATOMIC|GFP_NOWARN|GFP_NORETRY|GFP_COMP|GFP_NOMEMALLOC|
 => __alloc_pages_nodemask+0x754/0x792 <ffffffff810dc0de>
 => alloc_pages_current+0xbe/0xd8 <ffffffff81105459>
 => __page_cache_alloc+0x77/0x7e <ffffffff810d577c>
 => grab_cache_page_write_begin+0x54/0x9e <ffffffff810d5947>
 => ext4_da_write_begin+0x13f/0x20e <ffffffff8119639a>
 => generic_file_buffered_write+0x109/0x23a <ffffffff810d540c>
 => __generic_file_aio_write+0x242/0x272 <ffffffff810d6181>
 => generic_file_aio_write+0x58/0xa6 <ffffffff810d6209>
 => ext4_file_write+0x1dc/0x234 <ffffffff8118e898>
 => do_sync_write+0xbf/0xff <ffffffff8111dd6f>
 => vfs_write+0xac/0xf3 <ffffffff8111e3e5>
 => sys_write+0x4a/0x6e <ffffffff8111e5d4>
 => system_call_fastpath+0x16/0x1b <ffffffff81009b82>

8 instances order=2 normal gfp_flags=GFP_IO|GFP_NOWARN|GFP_REPEAT|GFP_NORETRY|GFP_COMP|
 => __alloc_pages_nodemask+0x754/0x792 <ffffffff810dc0de>
 => alloc_pages_current+0xbe/0xd8 <ffffffff81105459>
 => alloc_slab_page+0x1c/0x4d <ffffffff8110c5fe>
 => new_slab+0x50/0x199 <ffffffff8110dc48>
 => __slab_alloc+0x24a/0x328 <ffffffff8146ab86>
 => __kmalloc_node_track_caller+0xcf/0x131 <ffffffff8110ffca>
 => __alloc_skb+0x75/0x133 <ffffffff813b5e4c>
 => sock_alloc_send_pskb+0xb4/0x2d7 <ffffffff813b23aa>
 => sock_alloc_send_skb+0x15/0x17 <ffffffff813b25e2>
 => unix_stream_sendmsg+0x11e/0x2ec <ffffffff8143d237>
 => __sock_sendmsg+0x69/0x76 <ffffffff813af798>
 => sock_aio_write+0xb9/0xc9 <ffffffff813af85e>
 => do_sync_readv_writev+0xb9/0xfe <ffffffff8111e79d>
 => do_readv_writev+0xa7/0x11e <ffffffff8111ea03>
 => vfs_writev+0x45/0x47 <ffffffff8111eabf>
 => sys_writev+0x4a/0x93 <ffffffff8111ebe2>

2 instances order=1 normal gfp_flags=GFP_NOWARN|GFP_NORETRY|GFP_COMP|GFP_NOMEMALLOC|
 => __alloc_pages_nodemask+0x754/0x792 <ffffffff810dc0de>
 => alloc_pages_current+0xbe/0xd8 <ffffffff81105459>
 => __get_free_pages+0xe/0x4a <ffffffff810d89d6>
 => __pollwait+0x5e/0xcc <ffffffff8112ca0b>
 => sock_poll_wait+0x18/0x1d <ffffffff8143cc70>
 => unix_poll+0x1c/0x9a <ffffffff8143cc91>
 => sock_poll+0x1a/0x1c <ffffffff813ad43a>
 => do_sys_poll+0x1fa/0x386 <ffffffff8112d781>
 => sys_poll+0x51/0xbb <ffffffff8112d9b0>
 => system_call_fastpath+0x16/0x1b <ffffffff81009b82>

2 instances order=1 normal gfp_flags=GFP_IO|GFP_NOWARN|GFP_REPEAT|GFP_NORETRY|GFP_COMP|
 => __alloc_pages_nodemask+0x754/0x792 <ffffffff810dc0de>
 => alloc_pages_current+0xbe/0xd8 <ffffffff81105459>
 => alloc_slab_page+0x1c/0x4d <ffffffff8110c5fe>
 => new_slab+0x50/0x199 <ffffffff8110dc48>
 => __slab_alloc+0x24a/0x328 <ffffffff8146ab86>
 => kmem_cache_alloc_node+0x93/0x12d <ffffffff8110e1bd>
 => __alloc_skb+0x40/0x133 <ffffffff813b5e17>
 => sock_alloc_send_pskb+0xb4/0x2d7 <ffffffff813b23aa>
 => sock_alloc_send_skb+0x15/0x17 <ffffffff813b25e2>
 => unix_stream_sendmsg+0x11e/0x2ec <ffffffff8143d237>
 => __sock_sendmsg+0x69/0x76 <ffffffff813af798>
 => sock_sendmsg+0xa1/0xb6 <ffffffff813af90f>
 => sys_sendmsg+0x237/0x2b5 <ffffffff813b0cd9>
 => system_call_fastpath+0x16/0x1b <ffffffff81009b82>

3 instances order=1 normal gfp_flags=GFP_IO|GFP_NOWARN|GFP_NORETRY|GFP_COMP|
 => __alloc_pages_nodemask+0x754/0x792 <ffffffff810dc0de>
 => alloc_pages_current+0xbe/0xd8 <ffffffff81105459>
 => alloc_slab_page+0x1c/0x4d <ffffffff8110c5fe>
 => new_slab+0x50/0x199 <ffffffff8110dc48>
 => __slab_alloc+0x24a/0x328 <ffffffff8146ab86>
 => kmem_cache_alloc+0x77/0x105 <ffffffff8110e450>
 => get_empty_filp+0x7a/0x141 <ffffffff8111f2f5>
 => alloc_file+0x1e/0xbf <ffffffff8111f3da>
 => create_write_pipe+0x151/0x1bf <ffffffff81125f35>
 => do_pipe_flags+0x32/0xf4 <ffffffff81126060>
 => sys_pipe2+0x1c/0x5c <ffffffff8112613e>
 => sys_pipe+0x10/0x12 <ffffffff8112618e>
 => system_call_fastpath+0x16/0x1b <ffffffff81009b82>

1 instances order=3 normal gfp_flags=GFP_IO|GFP_NOWARN|GFP_NORETRY|GFP_COMP|
 => __alloc_pages_nodemask+0x754/0x792 <ffffffff810dc0de>
 => alloc_pages_current+0xbe/0xd8 <ffffffff81105459>
 => alloc_slab_page+0x1c/0x4d <ffffffff8110c5fe>
 => new_slab+0x50/0x199 <ffffffff8110dc48>
 => __slab_alloc+0x24a/0x328 <ffffffff8146ab86>
 => kmem_cache_alloc+0x77/0x105 <ffffffff8110e450>
 => dup_fd+0x33/0x25f <ffffffff81133573>
 => copy_process+0x5b8/0x10c5 <ffffffff810538ab>
 => do_fork+0x104/0x286 <ffffffff810544f7>
 => sys_clone+0x28/0x2a <ffffffff8101150e>
 => stub_clone+0x13/0x20 <ffffffff81009ea3>

2 instances order=1 normal gfp_flags=GFP_NOWARN|GFP_NORETRY|GFP_COMP|GFP_NOMEMALLOC|
 => __alloc_pages_nodemask+0x754/0x792 <ffffffff810dc0de>
 => alloc_pages_current+0xbe/0xd8 <ffffffff81105459>
 => alloc_slab_page+0x1c/0x4d <ffffffff8110c5fe>
 => new_slab+0x50/0x199 <ffffffff8110dc48>
 => __slab_alloc+0x24a/0x328 <ffffffff8146ab86>
 => kmem_cache_alloc+0x77/0x105 <ffffffff8110e450>
 => mempool_alloc_slab+0x15/0x17 <ffffffff810d6e85>
 => mempool_alloc+0x68/0x116 <ffffffff810d70fa>
 => bio_alloc_bioset+0x35/0xc3 <ffffffff81144dd8>
 => bio_alloc+0x15/0x24 <ffffffff81144ef5>
 => submit_bh+0x6d/0x105 <ffffffff811409f6>
 => __ext4_get_inode_loc+0x2ec/0x344 <ffffffff81191333>
 => ext4_get_inode_loc+0x2e/0x33 <ffffffff81192936>
 => ext4_xattr_set_handle+0xca/0x3f0 <ffffffff811bb1b1>
 => ext4_init_security+0x61/0x82 <ffffffff811bc9d3>
 => ext4_new_inode+0xb69/0xcf2 <ffffffff81190493>

1 instances order=1 atomic gfp_flags=GFP_ATOMIC|GFP_NOWARN|GFP_NORETRY|GFP_COMP|
 => __alloc_pages_nodemask+0x754/0x792 <ffffffff810dc0de>
 => alloc_pages_current+0xbe/0xd8 <ffffffff81105459>
 => alloc_slab_page+0x1c/0x4d <ffffffff8110c5fe>
 => new_slab+0x50/0x199 <ffffffff8110dc48>
 => __slab_alloc+0x24a/0x328 <ffffffff8146ab86>
 => kmem_cache_alloc+0x77/0x105 <ffffffff8110e450>
 => skb_clone+0x50/0x70 <ffffffff813b5db7>
 => dev_hard_start_xmit+0xd1/0x535 <ffffffff813c1660>
 => sch_direct_xmit+0x6b/0x147 <ffffffff813d7173>
 => dev_queue_xmit+0x2ac/0x461 <ffffffff813c1d70>
 => neigh_resolve_output+0x205/0x236 <ffffffff813ca2be>
 => ip_finish_output2+0x1cc/0x20f <ffffffff813f3979>
 => ip_finish_output+0x65/0x6a <ffffffff813f42a9>
 => ip_output+0x8c/0x91 <ffffffff813f49f2>
 => dst_output+0x14/0x16 <ffffffff813f34d7>
 => ip_local_out+0x20/0x24 <ffffffff813f435f>

3 instances order=1 normal gfp_flags=GFP_NOWARN|GFP_NORETRY|GFP_COMP|GFP_NOMEMALLOC|
 => __alloc_pages_nodemask+0x754/0x792 <ffffffff810dc0de>
 => alloc_pages_current+0xbe/0xd8 <ffffffff81105459>
 => __get_free_pages+0xe/0x4a <ffffffff810d89d6>
 => __pollwait+0x5e/0xcc <ffffffff8112ca0b>
 => sock_poll_wait+0x18/0x1d <ffffffff8143cc70>
 => unix_poll+0x1c/0x9a <ffffffff8143cc91>
 => sock_poll+0x1a/0x1c <ffffffff813ad43a>
 => do_select+0x2fb/0x4f5 <ffffffff8112cf37>
 => core_sys_select+0x163/0x202 <ffffffff8112d294>
 => sys_select+0x91/0xb9 <ffffffff8112d3c4>
 => system_call_fastpath+0x16/0x1b <ffffffff81009b82>

2 instances order=3 normal gfp_flags=GFP_NOWARN|GFP_NORETRY|GFP_COMP|GFP_NOMEMALLOC|
 => __alloc_pages_nodemask+0x754/0x792 <ffffffff810dc0de>
 => alloc_pages_current+0xbe/0xd8 <ffffffff81105459>
 => alloc_slab_page+0x1c/0x4d <ffffffff8110c5fe>
 => new_slab+0x50/0x199 <ffffffff8110dc48>
 => __slab_alloc+0x24a/0x328 <ffffffff8146ab86>
 => kmem_cache_alloc+0x77/0x105 <ffffffff8110e450>
 => bvec_alloc_bs+0xae/0xcc <ffffffff81144d85>
 => bio_alloc_bioset+0x75/0xc3 <ffffffff81144e18>
 => bio_alloc+0x15/0x24 <ffffffff81144ef5>
 => mpage_alloc+0x2a/0x84 <ffffffff8114866b>
 => do_mpage_readpage+0x38c/0x468 <ffffffff81148bcf>
 => mpage_readpages+0xbe/0x104 <ffffffff81148dd3>
 => ext4_readpages+0x1d/0x1f <ffffffff8119174d>
 => __do_page_cache_readahead+0x100/0x177 <ffffffff810dd7d4>
 => ra_submit+0x21/0x25 <ffffffff810ddab1>
 => filemap_fault+0x17b/0x36c <ffffffff810d6ade>

1 instances order=1 normal gfp_flags=GFP_IO|GFP_NOWARN|GFP_NORETRY|GFP_COMP|
 => __alloc_pages_nodemask+0x754/0x792 <ffffffff810dc0de>
 => alloc_pages_current+0xbe/0xd8 <ffffffff81105459>
 => alloc_slab_page+0x1c/0x4d <ffffffff8110c5fe>
 => new_slab+0x50/0x199 <ffffffff8110dc48>
 => __slab_alloc+0x24a/0x328 <ffffffff8146ab86>
 => kmem_cache_alloc+0x77/0x105 <ffffffff8110e450>
 => get_empty_filp+0x7a/0x141 <ffffffff8111f2f5>
 => do_filp_open+0xe7/0x60a <ffffffff81129bf3>
 => open_exec+0x26/0x82 <ffffffff8112265e>
 => load_elf_binary+0x1df/0x175f <ffffffff8115c1a8>
 => search_binary_handler+0xb6/0x22e <ffffffff81122ce3>
 => do_execve+0x17e/0x277 <ffffffff81123ea0>
 => sys_execve+0x43/0x5a <ffffffff81011553>
 => stub_execve+0x6c/0xc0 <ffffffff81009fdc>

210 instances order=2 normal gfp_flags=GFP_IO|GFP_NOWARN|GFP_NORETRY|GFP_COMP|GFP_RECLAIMABLE|
 => __alloc_pages_nodemask+0x754/0x792 <ffffffff810dc0de>
 => alloc_pages_current+0xbe/0xd8 <ffffffff81105459>
 => alloc_slab_page+0x1c/0x4d <ffffffff8110c5fe>
 => new_slab+0x50/0x199 <ffffffff8110dc48>
 => __slab_alloc+0x24a/0x328 <ffffffff8146ab86>
 => kmem_cache_alloc+0x77/0x105 <ffffffff8110e450>
 => radix_tree_preload+0x31/0x81 <ffffffff812293bd>
 => add_to_page_cache_locked+0x56/0x118 <ffffffff810d57d9>
 => add_to_page_cache_lru+0x2a/0x58 <ffffffff810d58c5>
 => grab_cache_page_write_begin+0x6d/0x9e <ffffffff810d5960>
 => ext4_da_write_begin+0x13f/0x20e <ffffffff8119639a>
 => generic_file_buffered_write+0x109/0x23a <ffffffff810d540c>
 => __generic_file_aio_write+0x242/0x272 <ffffffff810d6181>
 => generic_file_aio_write+0x58/0xa6 <ffffffff810d6209>
 => ext4_file_write+0x1dc/0x234 <ffffffff8118e898>
 => do_sync_write+0xbf/0xff <ffffffff8111dd6f>

6 instances order=1 normal gfp_flags=GFP_IO|GFP_NOWARN|GFP_NORETRY|GFP_COMP|
 => __alloc_pages_nodemask+0x754/0x792 <ffffffff810dc0de>
 => alloc_pages_current+0xbe/0xd8 <ffffffff81105459>
 => alloc_slab_page+0x1c/0x4d <ffffffff8110c5fe>
 => new_slab+0x50/0x199 <ffffffff8110dc48>
 => __slab_alloc+0x24a/0x328 <ffffffff8146ab86>
 => kmem_cache_alloc+0x77/0x105 <ffffffff8110e450>
 => get_empty_filp+0x7a/0x141 <ffffffff8111f2f5>
 => do_filp_open+0xe7/0x60a <ffffffff81129bf3>
 => do_sys_open+0x60/0xf2 <ffffffff8111d95b>
 => sys_openat+0x11/0x13 <ffffffff8111da20>
 => system_call_fastpath+0x16/0x1b <ffffffff81009b82>

8 instances order=9 normal gfp_flags=GFP_HIGHUSER_MOVABLE|GFP_NOWARN|GFP_NORETRY|GFP_COMP|GFP_NOMEMALLOC|
 => __alloc_pages_nodemask+0x754/0x792 <ffffffff810dc0de>
 => alloc_pages_vma+0xf5/0xfa <ffffffff81107025>
 => do_huge_pmd_anonymous_page+0xbf/0x261 <ffffffff81115b8e>
 => handle_mm_fault+0x113/0x1ce <ffffffff810f1714>
 => do_page_fault+0x358/0x37a <ffffffff814741ae>
 => page_fault+0x25/0x30 <ffffffff81471455>

4 instances order=1 normal gfp_flags=GFP_NOWARN|GFP_NORETRY|GFP_COMP|GFP_NOMEMALLOC|
 => __alloc_pages_nodemask+0x754/0x792 <ffffffff810dc0de>
 => alloc_pages_current+0xbe/0xd8 <ffffffff81105459>
 => alloc_slab_page+0x1c/0x4d <ffffffff8110c5fe>
 => new_slab+0x50/0x199 <ffffffff8110dc48>
 => __slab_alloc+0x24a/0x328 <ffffffff8146ab86>
 => kmem_cache_alloc+0x77/0x105 <ffffffff8110e450>
 => mempool_alloc_slab+0x15/0x17 <ffffffff810d6e85>
 => mempool_alloc+0x68/0x116 <ffffffff810d70fa>
 => bio_alloc_bioset+0x35/0xc3 <ffffffff81144dd8>
 => clone_bio+0x41/0xdb <ffffffff81382d3d>
 => __split_and_process_bio+0x23d/0x4ea <ffffffff813837d0>
 => dm_request+0x160/0x172 <ffffffff81383bdd>
 => generic_make_request+0x2ae/0x328 <ffffffff8121212f>
 => submit_bio+0xde/0xfd <ffffffff81212287>
 => submit_bh+0xe6/0x105 <ffffffff81140a6f>
 => ll_rw_block+0x84/0xa3 <ffffffff811410f4>

5 instances order=1 normal gfp_flags=GFP_NOWARN|GFP_NORETRY|GFP_COMP|GFP_NOMEMALLOC|
 => __alloc_pages_nodemask+0x754/0x792 <ffffffff810dc0de>
 => alloc_pages_current+0xbe/0xd8 <ffffffff81105459>
 => alloc_slab_page+0x1c/0x4d <ffffffff8110c5fe>
 => new_slab+0x50/0x199 <ffffffff8110dc48>
 => __slab_alloc+0x24a/0x328 <ffffffff8146ab86>
 => kmem_cache_alloc+0x77/0x105 <ffffffff8110e450>
 => mempool_alloc_slab+0x15/0x17 <ffffffff810d6e85>
 => mempool_alloc+0x68/0x116 <ffffffff810d70fa>
 => bio_alloc_bioset+0x35/0xc3 <ffffffff81144dd8>
 => bio_alloc+0x15/0x24 <ffffffff81144ef5>
 => submit_bh+0x6d/0x105 <ffffffff811409f6>
 => __ext4_get_inode_loc+0x2ec/0x344 <ffffffff81191333>
 => ext4_iget+0x58/0x64c <ffffffff81192a48>
 => ext4_lookup+0x93/0xf3 <ffffffff8119a79b>
 => d_alloc_and_lookup+0x45/0x6b <ffffffff81126d4b>
 => do_lookup+0x23a/0x287 <ffffffff81127dde>

257 instances order=1 normal gfp_flags=GFP_NOWARN|GFP_NORETRY|GFP_COMP|GFP_NOMEMALLOC|
 => __alloc_pages_nodemask+0x754/0x792 <ffffffff810dc0de>
 => alloc_pages_current+0xbe/0xd8 <ffffffff81105459>
 => alloc_slab_page+0x1c/0x4d <ffffffff8110c5fe>
 => new_slab+0x50/0x199 <ffffffff8110dc48>
 => __slab_alloc+0x24a/0x328 <ffffffff8146ab86>
 => kmem_cache_alloc+0x77/0x105 <ffffffff8110e450>
 => mempool_alloc_slab+0x15/0x17 <ffffffff810d6e85>
 => mempool_alloc+0x68/0x116 <ffffffff810d70fa>
 => bio_alloc_bioset+0x35/0xc3 <ffffffff81144dd8>
 => bio_alloc+0x15/0x24 <ffffffff81144ef5>
 => submit_bh+0x6d/0x105 <ffffffff811409f6>
 => __block_write_full_page+0x1e7/0x2d7 <ffffffff81141fac>
 => block_write_full_page_endio+0x8a/0x97 <ffffffff81143671>
 => block_write_full_page+0x15/0x17 <ffffffff81143693>
 => ext4_writepage+0x201/0x210 <ffffffff81193854>
 => shrink_page_list+0x3c7/0x6de <ffffffff810e22a1>

809 instances order=2 normal gfp_flags=GFP_KERNEL|GFP_REPEAT|GFP_COMP
 => __alloc_pages_nodemask+0x754/0x792 <ffffffff810dc0de>
 => kmalloc_large_node+0x56/0x95 <ffffffff8146a57d>
 => __kmalloc_node_track_caller+0x31/0x131 <ffffffff8110ff2c>
 => __alloc_skb+0x75/0x133 <ffffffff813b5e4c>
 => sock_alloc_send_pskb+0xb4/0x2d7 <ffffffff813b23aa>
 => sock_alloc_send_skb+0x15/0x17 <ffffffff813b25e2>
 => unix_stream_sendmsg+0x11e/0x2ec <ffffffff8143d237>
 => __sock_sendmsg+0x69/0x76 <ffffffff813af798>
 => sock_aio_write+0xb9/0xc9 <ffffffff813af85e>
 => do_sync_readv_writev+0xb9/0xfe <ffffffff8111e79d>
 => do_readv_writev+0xa7/0x11e <ffffffff8111ea03>
 => vfs_writev+0x45/0x47 <ffffffff8111eabf>
 => sys_writev+0x4a/0x93 <ffffffff8111ebe2>
 => system_call_fastpath+0x16/0x1b <ffffffff81009b82>

2 instances order=3 normal gfp_flags=GFP_IO|GFP_NOWARN|GFP_NORETRY|GFP_COMP|GFP_RECLAIMABLE|
 => __alloc_pages_nodemask+0x754/0x792 <ffffffff810dc0de>
 => alloc_pages_current+0xbe/0xd8 <ffffffff81105459>
 => alloc_slab_page+0x1c/0x4d <ffffffff8110c5fe>
 => new_slab+0x50/0x199 <ffffffff8110dc48>
 => __slab_alloc+0x24a/0x328 <ffffffff8146ab86>
 => kmem_cache_alloc+0x77/0x105 <ffffffff8110e450>
 => ext4_alloc_inode+0x1a/0x111 <ffffffff8119f4bc>
 => alloc_inode+0x1d/0x78 <ffffffff81131809>
 => iget_locked+0x61/0xdd <ffffffff811323be>
 => ext4_iget+0x2c/0x64c <ffffffff81192a1c>
 => ext4_lookup+0x93/0xf3 <ffffffff8119a79b>
 => d_alloc_and_lookup+0x45/0x6b <ffffffff81126d4b>
 => do_lookup+0x23a/0x287 <ffffffff81127dde>
 => link_path_walk+0x239/0x3b8 <ffffffff81128469>
 => do_path_lookup+0x4d/0xf6 <ffffffff8112881b>
 => do_filp_open+0x129/0x60a <ffffffff81129c35>

1 instances order=1 normal gfp_flags=GFP_IO|GFP_NOWARN|GFP_NORETRY|GFP_COMP|
 => __alloc_pages_nodemask+0x754/0x792 <ffffffff810dc0de>
 => alloc_pages_current+0xbe/0xd8 <ffffffff81105459>
 => alloc_slab_page+0x1c/0x4d <ffffffff8110c5fe>
 => new_slab+0x50/0x199 <ffffffff8110dc48>
 => __slab_alloc+0x24a/0x328 <ffffffff8146ab86>
 => kmem_cache_alloc+0x77/0x105 <ffffffff8110e450>
 => get_empty_filp+0x7a/0x141 <ffffffff8111f2f5>
 => alloc_file+0x1e/0xbf <ffffffff8111f3da>
 => shmem_file_setup+0x125/0x160 <ffffffff810e7140>
 => drm_gem_object_init+0x34/0x61 [drm] <ffffffffa0024ffc>
 => i915_gem_alloc_object+0x41/0x111 [i915] <ffffffffa007e4cd>
 => i915_gem_create_ioctl+0x3f/0xcf [i915] <ffffffffa007e5dc>
 => drm_ioctl+0x29e/0x37b [drm] <ffffffffa0023815>
 => do_vfs_ioctl+0x47e/0x4bf <ffffffff8112c070>
 => sys_ioctl+0x56/0x7b <ffffffff8112c107>
 => system_call_fastpath+0x16/0x1b <ffffffff81009b82>

99 instances order=1 normal gfp_flags=GFP_NOWARN|GFP_NORETRY|GFP_COMP|GFP_NOMEMALLOC|
 => __alloc_pages_nodemask+0x754/0x792 <ffffffff810dc0de>
 => alloc_pages_current+0xbe/0xd8 <ffffffff81105459>
 => alloc_slab_page+0x1c/0x4d <ffffffff8110c5fe>
 => new_slab+0x50/0x199 <ffffffff8110dc48>
 => __slab_alloc+0x24a/0x328 <ffffffff8146ab86>
 => kmem_cache_alloc+0x77/0x105 <ffffffff8110e450>
 => mempool_alloc_slab+0x15/0x17 <ffffffff810d6e85>
 => mempool_alloc+0x68/0x116 <ffffffff810d70fa>
 => bio_alloc_bioset+0x35/0xc3 <ffffffff81144dd8>
 => bio_alloc+0x15/0x24 <ffffffff81144ef5>
 => mpage_alloc+0x2a/0x84 <ffffffff8114866b>
 => do_mpage_readpage+0x38c/0x468 <ffffffff81148bcf>
 => mpage_readpages+0xbe/0x104 <ffffffff81148dd3>
 => ext4_readpages+0x1d/0x1f <ffffffff8119174d>
 => __do_page_cache_readahead+0x100/0x177 <ffffffff810dd7d4>
 => ra_submit+0x21/0x25 <ffffffff810ddab1>

24 instances order=1 normal gfp_flags=GFP_NOWARN|GFP_NORETRY|GFP_COMP|GFP_NOMEMALLOC|
 => __alloc_pages_nodemask+0x754/0x792 <ffffffff810dc0de>
 => alloc_pages_current+0xbe/0xd8 <ffffffff81105459>
 => __page_cache_alloc+0x77/0x7e <ffffffff810d577c>
 => __do_page_cache_readahead+0x9b/0x177 <ffffffff810dd76f>
 => ra_submit+0x21/0x25 <ffffffff810ddab1>
 => ondemand_readahead+0x1c9/0x1d8 <ffffffff810ddc7e>
 => page_cache_async_readahead+0x7b/0xa3 <ffffffff810ddd08>
 => generic_file_aio_read+0x2bd/0x5e0 <ffffffff810d6514>
 => do_sync_read+0xbf/0xff <ffffffff8111de6e>
 => vfs_read+0xa9/0xf0 <ffffffff8111e4d5>
 => sys_read+0x4a/0x6e <ffffffff8111e566>
 => system_call_fastpath+0x16/0x1b <ffffffff81009b82>

21 instances order=1 normal gfp_flags=GFP_IO|GFP_NOWARN|GFP_NORETRY|GFP_COMP|
 => __alloc_pages_nodemask+0x754/0x792 <ffffffff810dc0de>
 => alloc_pages_current+0xbe/0xd8 <ffffffff81105459>
 => alloc_slab_page+0x1c/0x4d <ffffffff8110c5fe>
 => new_slab+0x50/0x199 <ffffffff8110dc48>
 => __slab_alloc+0x24a/0x328 <ffffffff8146ab86>
 => kmem_cache_alloc+0x77/0x105 <ffffffff8110e450>
 => prepare_creds+0x26/0xae <ffffffff81074d4b>
 => sys_faccessat+0x37/0x162 <ffffffff8111d279>
 => sys_access+0x18/0x1a <ffffffff8111d3bc>
 => system_call_fastpath+0x16/0x1b <ffffffff81009b82>

1 instances order=2 normal gfp_flags=GFP_KERNEL|GFP_COMP|GFP_ZERO
 => __alloc_pages_nodemask+0x754/0x792 <ffffffff810dc0de>
 => alloc_pages_current+0xbe/0xd8 <ffffffff81105459>
 => __get_free_pages+0xe/0x4a <ffffffff810d89d6>
 => kmalloc_order_trace+0x2c/0x5e <ffffffff8110c73c>
 => __kmalloc+0x37/0x10d <ffffffff8110df65>
 => kzalloc.constprop.19+0xe/0x10 <ffffffff810b8d8c>
 => tracing_open_pipe+0x40/0x147 <ffffffff810b907a>
 => __dentry_open+0x161/0x283 <ffffffff8111c980>
 => nameidata_to_filp+0x60/0x67 <ffffffff8111d8f4>
 => finish_open+0xa1/0x17f <ffffffff8112974f>
 => do_filp_open+0x186/0x60a <ffffffff81129c92>
 => do_sys_open+0x60/0xf2 <ffffffff8111d95b>
 => sys_open+0x20/0x22 <ffffffff8111da0d>
 => system_call_fastpath+0x16/0x1b <ffffffff81009b82>

1 instances order=1 normal gfp_flags=GFP_NOWARN|GFP_NORETRY|GFP_COMP|GFP_NOMEMALLOC|
 => __alloc_pages_nodemask+0x754/0x792 <ffffffff810dc0de>
 => alloc_pages_current+0xbe/0xd8 <ffffffff81105459>
 => alloc_slab_page+0x1c/0x4d <ffffffff8110c5fe>
 => new_slab+0x50/0x199 <ffffffff8110dc48>
 => __slab_alloc+0x24a/0x328 <ffffffff8146ab86>
 => kmem_cache_alloc+0x77/0x105 <ffffffff8110e450>
 => mempool_alloc_slab+0x15/0x17 <ffffffff810d6e85>
 => mempool_alloc+0x68/0x116 <ffffffff810d70fa>
 => bio_alloc_bioset+0x35/0xc3 <ffffffff81144dd8>
 => clone_bio+0x41/0xdb <ffffffff81382d3d>
 => __split_and_process_bio+0x23d/0x4ea <ffffffff813837d0>
 => dm_request+0x160/0x172 <ffffffff81383bdd>
 => generic_make_request+0x2ae/0x328 <ffffffff8121212f>
 => submit_bio+0xde/0xfd <ffffffff81212287>
 => do_mpage_readpage+0x34a/0x468 <ffffffff81148b8d>
 => mpage_readpages+0xbe/0x104 <ffffffff81148dd3>

2 instances order=2 normal gfp_flags=GFP_IO|GFP_NOWARN|GFP_NORETRY|GFP_COMP|GFP_RECLAIMABLE|
 => __alloc_pages_nodemask+0x754/0x792 <ffffffff810dc0de>
 => alloc_pages_current+0xbe/0xd8 <ffffffff81105459>
 => alloc_slab_page+0x1c/0x4d <ffffffff8110c5fe>
 => new_slab+0x50/0x199 <ffffffff8110dc48>
 => __slab_alloc+0x24a/0x328 <ffffffff8146ab86>
 => kmem_cache_alloc+0x77/0x105 <ffffffff8110e450>
 => radix_tree_preload+0x31/0x81 <ffffffff812293bd>
 => add_to_page_cache_locked+0x56/0x118 <ffffffff810d57d9>
 => add_to_page_cache_lru+0x2a/0x58 <ffffffff810d58c5>
 => find_or_create_page+0x5a/0x8a <ffffffff810d5b6d>
 => __getblk+0x137/0x23a <ffffffff81141b55>
 => __ext4_get_inode_loc+0x118/0x344 <ffffffff8119115f>
 => ext4_get_inode_loc+0x2e/0x33 <ffffffff81192936>
 => ext4_xattr_set_handle+0xca/0x3f0 <ffffffff811bb1b1>
 => ext4_init_security+0x61/0x82 <ffffffff811bc9d3>
 => ext4_new_inode+0xb69/0xcf2 <ffffffff81190493>

8 instances order=1 normal gfp_flags=GFP_NOWARN|GFP_NORETRY|GFP_COMP|GFP_NOMEMALLOC|
 => __alloc_pages_nodemask+0x754/0x792 <ffffffff810dc0de>
 => alloc_pages_current+0xbe/0xd8 <ffffffff81105459>
 => alloc_slab_page+0x1c/0x4d <ffffffff8110c5fe>
 => new_slab+0x50/0x199 <ffffffff8110dc48>
 => __slab_alloc+0x24a/0x328 <ffffffff8146ab86>
 => kmem_cache_alloc+0x77/0x105 <ffffffff8110e450>
 => mempool_alloc_slab+0x15/0x17 <ffffffff810d6e85>
 => mempool_alloc+0x68/0x116 <ffffffff810d70fa>
 => bio_alloc_bioset+0x35/0xc3 <ffffffff81144dd8>
 => bio_alloc+0x15/0x24 <ffffffff81144ef5>
 => submit_bh+0x6d/0x105 <ffffffff811409f6>
 => ll_rw_block+0x84/0xa3 <ffffffff811410f4>
 => __breadahead+0x2e/0x39 <ffffffff81141c86>
 => __ext4_get_inode_loc+0x2c4/0x344 <ffffffff8119130b>
 => ext4_get_inode_loc+0x2e/0x33 <ffffffff81192936>
 => ext4_xattr_set_handle+0xca/0x3f0 <ffffffff811bb1b1>

58 instances order=1 normal gfp_flags=GFP_IO|GFP_NOWARN|GFP_NORETRY|GFP_COMP|GFP_RECLAIMABLE|
 => __alloc_pages_nodemask+0x754/0x792 <ffffffff810dc0de>
 => alloc_pages_current+0xbe/0xd8 <ffffffff81105459>
 => alloc_slab_page+0x1c/0x4d <ffffffff8110c5fe>
 => new_slab+0x50/0x199 <ffffffff8110dc48>
 => __slab_alloc+0x24a/0x328 <ffffffff8146ab86>
 => kmem_cache_alloc+0x77/0x105 <ffffffff8110e450>
 => d_alloc+0x26/0x18d <ffffffff8112e4e9>
 => d_alloc_and_lookup+0x2c/0x6b <ffffffff81126d32>
 => __lookup_hash+0x7f/0x88 <ffffffff81127eaa>
 => lookup_hash+0x19/0x1b <ffffffff81127ecc>
 => do_last+0xcf/0x2df <ffffffff811298fc>
 => do_filp_open+0x2ac/0x60a <ffffffff81129db8>
 => do_sys_open+0x60/0xf2 <ffffffff8111d95b>
 => sys_openat+0x11/0x13 <ffffffff8111da20>
 => system_call_fastpath+0x16/0x1b <ffffffff81009b82>

5 instances order=2 normal gfp_flags=GFP_IO|GFP_NOWARN|GFP_NORETRY|GFP_COMP|GFP_RECLAIMABLE|
 => __alloc_pages_nodemask+0x754/0x792 <ffffffff810dc0de>
 => alloc_pages_current+0xbe/0xd8 <ffffffff81105459>
 => alloc_slab_page+0x1c/0x4d <ffffffff8110c5fe>
 => new_slab+0x50/0x199 <ffffffff8110dc48>
 => __slab_alloc+0x24a/0x328 <ffffffff8146ab86>
 => kmem_cache_alloc+0x77/0x105 <ffffffff8110e450>
 => radix_tree_preload+0x31/0x81 <ffffffff812293bd>
 => add_to_page_cache_locked+0x56/0x118 <ffffffff810d57d9>
 => add_to_page_cache_lru+0x2a/0x58 <ffffffff810d58c5>
 => mpage_readpages+0x99/0x104 <ffffffff81148dae>
 => ext4_readpages+0x1d/0x1f <ffffffff8119174d>
 => __do_page_cache_readahead+0x100/0x177 <ffffffff810dd7d4>
 => ondemand_readahead+0x15a/0x1d8 <ffffffff810ddc0f>
 => page_cache_sync_readahead+0x3d/0x40 <ffffffff810ddd6d>
 => generic_file_aio_read+0x27d/0x5e0 <ffffffff810d64d4>
 => do_sync_read+0xbf/0xff <ffffffff8111de6e>

2 instances order=1 normal gfp_flags=GFP_IO|GFP_NOWARN|GFP_NORETRY|GFP_COMP|
 => __alloc_pages_nodemask+0x754/0x792 <ffffffff810dc0de>
 => alloc_pages_current+0xbe/0xd8 <ffffffff81105459>
 => alloc_slab_page+0x1c/0x4d <ffffffff8110c5fe>
 => new_slab+0x50/0x199 <ffffffff8110dc48>
 => __slab_alloc+0x24a/0x328 <ffffffff8146ab86>
 => kmem_cache_alloc+0x77/0x105 <ffffffff8110e450>
 => get_empty_filp+0x7a/0x141 <ffffffff8111f2f5>
 => alloc_file+0x1e/0xbf <ffffffff8111f3da>
 => create_read_pipe+0x2b/0x5b <ffffffff81125ffe>
 => do_pipe_flags+0x4e/0xf4 <ffffffff8112607c>
 => sys_pipe2+0x1c/0x5c <ffffffff8112613e>
 => system_call_fastpath+0x16/0x1b <ffffffff81009b82>

9 instances order=1 normal gfp_flags=GFP_KERNEL
 => __alloc_pages_nodemask+0x754/0x792 <ffffffff810dc0de>
 => alloc_pages_current+0xbe/0xd8 <ffffffff81105459>
 => __get_free_pages+0xe/0x4a <ffffffff810d89d6>
 => copy_process+0xe1/0x10c5 <ffffffff810533d4>
 => do_fork+0x104/0x286 <ffffffff810544f7>
 => kernel_thread+0x75/0x77 <ffffffff81010bb6>
 => kthreadd+0xe7/0x124 <ffffffff8106f61f>
 => kernel_thread_helper+0x4/0x10 <ffffffff8100a9a4>

1 instances order=1 normal gfp_flags=GFP_IO|GFP_NOWARN|GFP_NORETRY|GFP_COMP|
 => __alloc_pages_nodemask+0x754/0x792 <ffffffff810dc0de>
 => alloc_pages_current+0xbe/0xd8 <ffffffff81105459>
 => __page_cache_alloc+0x77/0x7e <ffffffff810d577c>
 => grab_cache_page_write_begin+0x54/0x9e <ffffffff810d5947>
 => ext4_da_write_begin+0x13f/0x20e <ffffffff8119639a>
 => generic_file_buffered_write+0x109/0x23a <ffffffff810d540c>
 => __generic_file_aio_write+0x242/0x272 <ffffffff810d6181>
 => generic_file_aio_write+0x58/0xa6 <ffffffff810d6209>
 => ext4_file_write+0x1dc/0x234 <ffffffff8118e898>
 => do_sync_write+0xbf/0xff <ffffffff8111dd6f>
 => vfs_write+0xac/0xf3 <ffffffff8111e3e5>
 => sys_write+0x4a/0x6e <ffffffff8111e5d4>
 => system_call_fastpath+0x16/0x1b <ffffffff81009b82>

1 instances order=3 normal gfp_flags=GFP_IO|GFP_NOWARN|GFP_NORETRY|GFP_COMP|
 => __alloc_pages_nodemask+0x754/0x792 <ffffffff810dc0de>
 => alloc_pages_current+0xbe/0xd8 <ffffffff81105459>
 => alloc_slab_page+0x1c/0x4d <ffffffff8110c5fe>
 => new_slab+0x50/0x199 <ffffffff8110dc48>
 => __slab_alloc+0x24a/0x328 <ffffffff8146ab86>
 => __kmalloc+0xb1/0x10d <ffffffff8110dfdf>
 => drm_malloc_ab+0x3b/0x53 [i915] <ffffffffa007fbd2>
 => i915_gem_do_execbuffer+0x64a/0x1116 [i915] <ffffffffa0080249>
 => i915_gem_execbuffer2+0xcc/0x12e [i915] <ffffffffa0080ffe>
 => drm_ioctl+0x29e/0x37b [drm] <ffffffffa0023815>
 => do_vfs_ioctl+0x47e/0x4bf <ffffffff8112c070>
 => sys_ioctl+0x56/0x7b <ffffffff8112c107>
 => system_call_fastpath+0x16/0x1b <ffffffff81009b82>

1 instances order=2 atomic gfp_flags=GFP_ATOMIC|GFP_NOWARN|GFP_NORETRY|GFP_COMP|
 => __alloc_pages_nodemask+0x754/0x792 <ffffffff810dc0de>
 => alloc_pages_current+0xbe/0xd8 <ffffffff81105459>
 => alloc_slab_page+0x1c/0x4d <ffffffff8110c5fe>
 => new_slab+0x50/0x199 <ffffffff8110dc48>
 => __slab_alloc+0x24a/0x328 <ffffffff8146ab86>
 => kmem_cache_alloc+0x77/0x105 <ffffffff8110e450>
 => dst_alloc+0x48/0xaa <ffffffff813c6672>
 => __ip_route_output_key+0x561/0x764 <ffffffff813ee513>
 => tcp_v4_connect+0x121/0x47d <ffffffff8140becf>
 => inet_stream_connect+0xa8/0x25f <ffffffff81418e24>
 => sys_connect+0x98/0xd6 <ffffffff813b0437>
 => system_call_fastpath+0x16/0x1b <ffffffff81009b82>

1 instances order=2 normal gfp_flags=GFP_KERNEL|GFP_REPEAT|GFP_COMP
 => __alloc_pages_nodemask+0x754/0x792 <ffffffff810dc0de>
 => kmalloc_large_node+0x56/0x95 <ffffffff8146a57d>
 => __kmalloc_node_track_caller+0x31/0x131 <ffffffff8110ff2c>
 => __alloc_skb+0x75/0x133 <ffffffff813b5e4c>
 => sock_alloc_send_pskb+0xb4/0x2d7 <ffffffff813b23aa>
 => sock_alloc_send_skb+0x15/0x17 <ffffffff813b25e2>
 => unix_stream_sendmsg+0x11e/0x2ec <ffffffff8143d237>
 => __sock_sendmsg+0x69/0x76 <ffffffff813af798>
 => sock_aio_write+0xb9/0xc9 <ffffffff813af85e>
 => do_sync_write+0xbf/0xff <ffffffff8111dd6f>
 => vfs_write+0xb3/0xf3 <ffffffff8111e3ec>
 => sys_write+0x4a/0x6e <ffffffff8111e5d4>
 => system_call_fastpath+0x16/0x1b <ffffffff81009b82>

1 instances order=1 atomic gfp_flags=GFP_ATOMIC|GFP_NOWARN|GFP_NORETRY|GFP_COMP|
 => __alloc_pages_nodemask+0x754/0x792 <ffffffff810dc0de>
 => alloc_pages_current+0xbe/0xd8 <ffffffff81105459>
 => alloc_slab_page+0x1c/0x4d <ffffffff8110c5fe>
 => new_slab+0x50/0x199 <ffffffff8110dc48>
 => __slab_alloc+0x24a/0x328 <ffffffff8146ab86>
 => kmem_cache_alloc+0x77/0x105 <ffffffff8110e450>
 => __nf_conntrack_alloc+0xc9/0x1af <ffffffff813e4533>
 => nf_conntrack_in+0x2f6/0x77a <ffffffff813e490f>
 => ipv4_conntrack_local+0x46/0x4a <ffffffff8142864c>
 => nf_iterate+0x48/0x83 <ffffffff813e1cb8>
 => nf_hook_slow+0x6a/0xe9 <ffffffff813e1d5d>
 => nf_hook_thresh.constprop.8+0x42/0x44 <ffffffff813f42f0>
 => __ip_local_out+0x49/0x4d <ffffffff813f433b>
 => ip_local_out+0x13/0x24 <ffffffff813f4352>
 => ip_queue_xmit+0x2b3/0x30e <ffffffff813f4616>
 => tcp_transmit_skb+0x708/0x739 <ffffffff81407217>

1 instances order=2 atomic gfp_flags=GFP_ATOMIC|GFP_NOWARN|GFP_NORETRY|GFP_COMP|
 => __alloc_pages_nodemask+0x754/0x792 <ffffffff810dc0de>
 => alloc_pages_current+0xbe/0xd8 <ffffffff81105459>
 => alloc_slab_page+0x1c/0x4d <ffffffff8110c5fe>
 => new_slab+0x50/0x199 <ffffffff8110dc48>
 => __slab_alloc+0x24a/0x328 <ffffffff8146ab86>
 => kmem_cache_alloc+0x77/0x105 <ffffffff8110e450>
 => dst_alloc+0x48/0xaa <ffffffff813c6672>
 => __ip_route_output_key+0x561/0x764 <ffffffff813ee513>
 => ip_route_output_flow+0x2c/0x1ea <ffffffff813ee742>
 => ip4_datagram_connect+0x18d/0x298 <ffffffff8140ede5>
 => inet_dgram_connect+0x65/0x6c <ffffffff81418b9d>
 => sys_connect+0x98/0xd6 <ffffffff813b0437>
 => system_call_fastpath+0x16/0x1b <ffffffff81009b82>

1 instances order=9 normal gfp_flags=GFP_HIGHUSER_MOVABLE|GFP_NOWARN|GFP_NORETRY|GFP_COMP|GFP_NOMEMALLOC|
 => __alloc_pages_nodemask+0x754/0x792 <ffffffff810dc0de>
 => alloc_pages_vma+0xf5/0xfa <ffffffff81107025>
 => do_huge_pmd_wp_page+0x15a/0x637 <ffffffff81114a25>
 => handle_mm_fault+0x169/0x1ce <ffffffff810f176a>
 => do_page_fault+0x358/0x37a <ffffffff814741ae>
 => page_fault+0x25/0x30 <ffffffff81471455>

1 instances order=1 normal gfp_flags=GFP_NOWARN|GFP_NORETRY|GFP_COMP|GFP_NOMEMALLOC|
 => __alloc_pages_nodemask+0x754/0x792 <ffffffff810dc0de>
 => alloc_pages_current+0xbe/0xd8 <ffffffff81105459>
 => __page_cache_alloc+0x77/0x7e <ffffffff810d577c>
 => find_or_create_page+0x41/0x8a <ffffffff810d5b54>
 => __getblk+0x137/0x23a <ffffffff81141b55>
 => __breadahead+0x12/0x39 <ffffffff81141c6a>
 => __ext4_get_inode_loc+0x2c4/0x344 <ffffffff8119130b>
 => ext4_iget+0x58/0x64c <ffffffff81192a48>
 => ext4_lookup+0x93/0xf3 <ffffffff8119a79b>
 => d_alloc_and_lookup+0x45/0x6b <ffffffff81126d4b>
 => do_lookup+0x23a/0x287 <ffffffff81127dde>
 => link_path_walk+0x239/0x3b8 <ffffffff81128469>
 => do_path_lookup+0x4d/0xf6 <ffffffff8112881b>
 => user_path_at+0x57/0x94 <ffffffff811294e0>
 => sys_faccessat+0xa0/0x162 <ffffffff8111d2e2>
 => sys_access+0x18/0x1a <ffffffff8111d3bc>

2 instances order=1 normal gfp_flags=GFP_IO|GFP_NOWARN|GFP_NORETRY|GFP_COMP|GFP_RECLAIMABLE|
 => __alloc_pages_nodemask+0x754/0x792 <ffffffff810dc0de>
 => alloc_pages_current+0xbe/0xd8 <ffffffff81105459>
 => alloc_slab_page+0x1c/0x4d <ffffffff8110c5fe>
 => new_slab+0x50/0x199 <ffffffff8110dc48>
 => __slab_alloc+0x24a/0x328 <ffffffff8146ab86>
 => kmem_cache_alloc+0x77/0x105 <ffffffff8110e450>
 => d_alloc+0x26/0x18d <ffffffff8112e4e9>
 => shmem_file_setup+0xb6/0x160 <ffffffff810e70d1>
 => drm_gem_object_init+0x34/0x61 [drm] <ffffffffa0024ffc>
 => i915_gem_alloc_object+0x41/0x111 [i915] <ffffffffa007e4cd>
 => i915_gem_create_ioctl+0x3f/0xcf [i915] <ffffffffa007e5dc>
 => drm_ioctl+0x29e/0x37b [drm] <ffffffffa0023815>
 => do_vfs_ioctl+0x47e/0x4bf <ffffffff8112c070>
 => sys_ioctl+0x56/0x7b <ffffffff8112c107>
 => system_call_fastpath+0x16/0x1b <ffffffff81009b82>

416 instances order=1 normal gfp_flags=GFP_NOWARN|GFP_NORETRY|GFP_COMP|GFP_NOMEMALLOC|
 => __alloc_pages_nodemask+0x754/0x792 <ffffffff810dc0de>
 => alloc_pages_current+0xbe/0xd8 <ffffffff81105459>
 => alloc_slab_page+0x1c/0x4d <ffffffff8110c5fe>
 => new_slab+0x50/0x199 <ffffffff8110dc48>
 => __slab_alloc+0x24a/0x328 <ffffffff8146ab86>
 => kmem_cache_alloc+0x77/0x105 <ffffffff8110e450>
 => mempool_alloc_slab+0x15/0x17 <ffffffff810d6e85>
 => mempool_alloc+0x68/0x116 <ffffffff810d70fa>
 => bio_alloc_bioset+0x35/0xc3 <ffffffff81144dd8>
 => bio_alloc+0x15/0x24 <ffffffff81144ef5>
 => submit_bh+0x6d/0x105 <ffffffff811409f6>
 => __block_write_full_page+0x1e7/0x2d7 <ffffffff81141fac>
 => block_write_full_page_endio+0x8a/0x97 <ffffffff81143671>
 => block_write_full_page+0x15/0x17 <ffffffff81143693>
 => blkdev_writepage+0x18/0x1a <ffffffff811460b8>
 => __writepage+0x15/0x2e <ffffffff810dca43>

13 instances order=2 normal gfp_flags=GFP_IO|GFP_NOWARN|GFP_NORETRY|GFP_COMP|GFP_RECLAIMABLE|
 => __alloc_pages_nodemask+0x754/0x792 <ffffffff810dc0de>
 => alloc_pages_current+0xbe/0xd8 <ffffffff81105459>
 => alloc_slab_page+0x1c/0x4d <ffffffff8110c5fe>
 => new_slab+0x50/0x199 <ffffffff8110dc48>
 => __slab_alloc+0x24a/0x328 <ffffffff8146ab86>
 => kmem_cache_alloc+0x77/0x105 <ffffffff8110e450>
 => radix_tree_preload+0x31/0x81 <ffffffff812293bd>
 => add_to_page_cache_locked+0x56/0x118 <ffffffff810d57d9>
 => add_to_page_cache_lru+0x2a/0x58 <ffffffff810d58c5>
 => mpage_readpages+0x99/0x104 <ffffffff81148dae>
 => ext4_readpages+0x1d/0x1f <ffffffff8119174d>
 => __do_page_cache_readahead+0x100/0x177 <ffffffff810dd7d4>
 => ra_submit+0x21/0x25 <ffffffff810ddab1>
 => filemap_fault+0x17b/0x36c <ffffffff810d6ade>
 => __do_fault+0x55/0x377 <ffffffff810ee88b>
 => handle_pte_fault+0x2a7/0x7a5 <ffffffff810f0f47>

58 instances order=1 normal gfp_flags=GFP_NOWARN|GFP_NORETRY|GFP_COMP|GFP_NOMEMALLOC|
 => __alloc_pages_nodemask+0x754/0x792 <ffffffff810dc0de>
 => alloc_pages_current+0xbe/0xd8 <ffffffff81105459>
 => alloc_slab_page+0x1c/0x4d <ffffffff8110c5fe>
 => new_slab+0x50/0x199 <ffffffff8110dc48>
 => __slab_alloc+0x24a/0x328 <ffffffff8146ab86>
 => kmem_cache_alloc+0x77/0x105 <ffffffff8110e450>
 => bvec_alloc_bs+0xae/0xcc <ffffffff81144d85>
 => bio_alloc_bioset+0x75/0xc3 <ffffffff81144e18>
 => clone_bio+0x41/0xdb <ffffffff81382d3d>
 => __split_and_process_bio+0x23d/0x4ea <ffffffff813837d0>
 => dm_request+0x160/0x172 <ffffffff81383bdd>
 => generic_make_request+0x2ae/0x328 <ffffffff8121212f>
 => submit_bio+0xde/0xfd <ffffffff81212287>
 => do_mpage_readpage+0x34a/0x468 <ffffffff81148b8d>
 => mpage_readpages+0xbe/0x104 <ffffffff81148dd3>
 => ext4_readpages+0x1d/0x1f <ffffffff8119174d>

1 instances order=1 normal gfp_flags=GFP_IO|GFP_NOWARN|GFP_NORETRY|GFP_COMP|GFP_RECLAIMABLE|
 => __alloc_pages_nodemask+0x754/0x792 <ffffffff810dc0de>
 => alloc_pages_current+0xbe/0xd8 <ffffffff81105459>
 => alloc_slab_page+0x1c/0x4d <ffffffff8110c5fe>
 => new_slab+0x50/0x199 <ffffffff8110dc48>
 => __slab_alloc+0x24a/0x328 <ffffffff8146ab86>
 => kmem_cache_alloc+0x77/0x105 <ffffffff8110e450>
 => d_alloc+0x26/0x18d <ffffffff8112e4e9>
 => d_alloc_and_lookup+0x2c/0x6b <ffffffff81126d32>
 => __lookup_hash+0x7f/0x88 <ffffffff81127eaa>
 => lookup_hash+0x19/0x1b <ffffffff81127ecc>
 => do_last+0xcf/0x2df <ffffffff811298fc>
 => do_filp_open+0x2ac/0x60a <ffffffff81129db8>
 => do_sys_open+0x60/0xf2 <ffffffff8111d95b>
 => sys_open+0x20/0x22 <ffffffff8111da0d>
 => system_call_fastpath+0x16/0x1b <ffffffff81009b82>

7727 instances order=1 normal gfp_flags=GFP_NOWARN|GFP_NORETRY|GFP_COMP|GFP_NOMEMALLOC|
 => __alloc_pages_nodemask+0x754/0x792 <ffffffff810dc0de>
 => alloc_pages_current+0xbe/0xd8 <ffffffff81105459>
 => alloc_slab_page+0x1c/0x4d <ffffffff8110c5fe>
 => new_slab+0x50/0x199 <ffffffff8110dc48>
 => __slab_alloc+0x24a/0x328 <ffffffff8146ab86>
 => kmem_cache_alloc+0x77/0x105 <ffffffff8110e450>
 => mempool_alloc_slab+0x15/0x17 <ffffffff810d6e85>
 => mempool_alloc+0x68/0x116 <ffffffff810d70fa>
 => bio_alloc_bioset+0x35/0xc3 <ffffffff81144dd8>
 => clone_bio+0x41/0xdb <ffffffff81382d3d>
 => __split_and_process_bio+0x23d/0x4ea <ffffffff813837d0>
 => dm_request+0x160/0x172 <ffffffff81383bdd>
 => generic_make_request+0x2ae/0x328 <ffffffff8121212f>
 => submit_bio+0xde/0xfd <ffffffff81212287>
 => submit_bh+0xe6/0x105 <ffffffff81140a6f>
 => __block_write_full_page+0x1e7/0x2d7 <ffffffff81141fac>

1 instances order=1 normal gfp_flags=GFP_IO|GFP_NOWARN|GFP_NORETRY|GFP_COMP|
 => __alloc_pages_nodemask+0x754/0x792 <ffffffff810dc0de>
 => alloc_pages_current+0xbe/0xd8 <ffffffff81105459>
 => alloc_slab_page+0x1c/0x4d <ffffffff8110c5fe>
 => new_slab+0x50/0x199 <ffffffff8110dc48>
 => __slab_alloc+0x24a/0x328 <ffffffff8146ab86>
 => kmem_cache_alloc+0x77/0x105 <ffffffff8110e450>
 => __split_vma+0x6c/0x21b <ffffffff810f50bd>
 => do_munmap+0x194/0x30b <ffffffff810f57d1>
 => mmap_region+0x9b/0x446 <ffffffff810f645d>
 => do_mmap_pgoff+0x298/0x2f2 <ffffffff810f6aa0>
 => sys_mmap_pgoff+0x115/0x164 <ffffffff810f6c0f>
 => sys_mmap+0x22/0x24 <ffffffff8100da68>
 => system_call_fastpath+0x16/0x1b <ffffffff81009b82>

1 instances order=1 normal gfp_flags=GFP_KERNEL
 => __alloc_pages_nodemask+0x754/0x792 <ffffffff810dc0de>
 => alloc_pages_current+0xbe/0xd8 <ffffffff81105459>
 => __get_free_pages+0xe/0x4a <ffffffff810d89d6>
 => copy_process+0xe1/0x10c5 <ffffffff810533d4>
 => do_fork+0x104/0x286 <ffffffff810544f7>
 => kernel_thread+0x75/0x77 <ffffffff81010bb6>
 => __call_usermodehelper+0x43/0x76 <ffffffff81069132>
 => process_one_work+0x186/0x298 <ffffffff8106b3ca>
 => worker_thread+0xda/0x15d <ffffffff8106bf29>
 => kthread+0x84/0x8c <ffffffff8106f2df>
 => kernel_thread_helper+0x4/0x10 <ffffffff8100a9a4>

18 instances order=1 normal gfp_flags=GFP_NOWARN|GFP_NORETRY|GFP_COMP|GFP_NOMEMALLOC|
 => __alloc_pages_nodemask+0x754/0x792 <ffffffff810dc0de>
 => alloc_pages_current+0xbe/0xd8 <ffffffff81105459>
 => alloc_slab_page+0x1c/0x4d <ffffffff8110c5fe>
 => new_slab+0x50/0x199 <ffffffff8110dc48>
 => __slab_alloc+0x24a/0x328 <ffffffff8146ab86>
 => kmem_cache_alloc+0x77/0x105 <ffffffff8110e450>
 => bvec_alloc_bs+0xae/0xcc <ffffffff81144d85>
 => bio_alloc_bioset+0x75/0xc3 <ffffffff81144e18>
 => clone_bio+0x41/0xdb <ffffffff81382d3d>
 => __split_and_process_bio+0x23d/0x4ea <ffffffff813837d0>
 => dm_request+0x160/0x172 <ffffffff81383bdd>
 => generic_make_request+0x2ae/0x328 <ffffffff8121212f>
 => submit_bio+0xde/0xfd <ffffffff81212287>
 => mpage_readpages+0xf0/0x104 <ffffffff81148e05>
 => ext4_readpages+0x1d/0x1f <ffffffff8119174d>
 => __do_page_cache_readahead+0x100/0x177 <ffffffff810dd7d4>

1 instances order=3 normal gfp_flags=GFP_IO|GFP_NOWARN|GFP_NORETRY|GFP_COMP|GFP_RECLAIMABLE|
 => __alloc_pages_nodemask+0x754/0x792 <ffffffff810dc0de>
 => alloc_pages_current+0xbe/0xd8 <ffffffff81105459>
 => alloc_slab_page+0x1c/0x4d <ffffffff8110c5fe>
 => new_slab+0x50/0x199 <ffffffff8110dc48>
 => __slab_alloc+0x24a/0x328 <ffffffff8146ab86>
 => kmem_cache_alloc+0x77/0x105 <ffffffff8110e450>
 => ext4_alloc_inode+0x1a/0x111 <ffffffff8119f4bc>
 => alloc_inode+0x1d/0x78 <ffffffff81131809>
 => iget_locked+0x61/0xdd <ffffffff811323be>
 => ext4_iget+0x2c/0x64c <ffffffff81192a1c>
 => ext4_lookup+0x93/0xf3 <ffffffff8119a79b>
 => d_alloc_and_lookup+0x45/0x6b <ffffffff81126d4b>
 => do_lookup+0x23a/0x287 <ffffffff81127dde>
 => link_path_walk+0x14b/0x3b8 <ffffffff8112837b>
 => do_filp_open+0x1eb/0x60a <ffffffff81129cf7>
 => do_sys_open+0x60/0xf2 <ffffffff8111d95b>

1 instances order=2 normal gfp_flags=GFP_IO|GFP_NOWARN|GFP_NORETRY|GFP_COMP|GFP_RECLAIMABLE|
 => __alloc_pages_nodemask+0x754/0x792 <ffffffff810dc0de>
 => alloc_pages_current+0xbe/0xd8 <ffffffff81105459>
 => alloc_slab_page+0x1c/0x4d <ffffffff8110c5fe>
 => new_slab+0x50/0x199 <ffffffff8110dc48>
 => __slab_alloc+0x24a/0x328 <ffffffff8146ab86>
 => kmem_cache_alloc+0x77/0x105 <ffffffff8110e450>
 => radix_tree_preload+0x31/0x81 <ffffffff812293bd>
 => add_to_page_cache_locked+0x56/0x118 <ffffffff810d57d9>
 => add_to_page_cache_lru+0x2a/0x58 <ffffffff810d58c5>
 => find_or_create_page+0x5a/0x8a <ffffffff810d5b6d>
 => ext4_mb_load_buddy+0x1f7/0x30f <ffffffff811b4bdf>
 => ext4_free_blocks+0x41d/0x6ba <ffffffff811b7a92>
 => ext4_ext_truncate+0x361/0x78a <ffffffff811b1012>
 => ext4_truncate+0xa1/0x4d9 <ffffffff8119598c>
 => ext4_evict_inode+0x13f/0x228 <ffffffff811978e9>
 => evict+0x21/0x89 <ffffffff81131b92>

149 instances order=2 normal gfp_flags=GFP_IO|GFP_NOWARN|GFP_NORETRY|GFP_COMP|GFP_RECLAIMABLE|
 => __alloc_pages_nodemask+0x754/0x792 <ffffffff810dc0de>
 => alloc_pages_current+0xbe/0xd8 <ffffffff81105459>
 => alloc_slab_page+0x1c/0x4d <ffffffff8110c5fe>
 => new_slab+0x50/0x199 <ffffffff8110dc48>
 => __slab_alloc+0x24a/0x328 <ffffffff8146ab86>
 => kmem_cache_alloc+0x77/0x105 <ffffffff8110e450>
 => radix_tree_preload+0x31/0x81 <ffffffff812293bd>
 => add_to_page_cache_locked+0x56/0x118 <ffffffff810d57d9>
 => add_to_page_cache_lru+0x2a/0x58 <ffffffff810d58c5>
 => mpage_readpages+0x99/0x104 <ffffffff81148dae>
 => ext4_readpages+0x1d/0x1f <ffffffff8119174d>
 => __do_page_cache_readahead+0x100/0x177 <ffffffff810dd7d4>
 => ra_submit+0x21/0x25 <ffffffff810ddab1>
 => ondemand_readahead+0x1c9/0x1d8 <ffffffff810ddc7e>
 => page_cache_async_readahead+0x7b/0xa3 <ffffffff810ddd08>
 => generic_file_aio_read+0x2bd/0x5e0 <ffffffff810d6514>

High-order normal allocations: 152966
High-order atomic allocations: 875


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
