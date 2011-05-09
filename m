Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id E76556B0011
	for <linux-mm@kvack.org>; Mon,  9 May 2011 14:16:34 -0400 (EDT)
Subject: Re: [BUG] fatal hang untarring 90GB file, possibly writeback
 related.
From: James Bottomley <James.Bottomley@suse.de>
In-Reply-To: <20110506080728.GC6591@suse.de>
References: <20110428171826.GZ4658@suse.de>
	 <1304015436.2598.19.camel@mulgrave.site> <20110428192104.GA4658@suse.de>
	 <1304020767.2598.21.camel@mulgrave.site>
	 <1304025145.2598.24.camel@mulgrave.site>
	 <1304030629.2598.42.camel@mulgrave.site> <20110503091320.GA4542@novell.com>
	 <1304431982.2576.5.camel@mulgrave.site>
	 <1304432553.2576.10.camel@mulgrave.site> <20110506074224.GB6591@suse.de>
	 <20110506080728.GC6591@suse.de>
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 09 May 2011 13:16:20 -0500
Message-ID: <1304964980.4865.53.camel@mulgrave.site>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Mel Gorman <mgorman@novell.com>, Jan Kara <jack@suse.cz>, colin.king@canonical.com, Chris Mason <chris.mason@oracle.com>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-ext4 <linux-ext4@vger.kernel.org>

On Fri, 2011-05-06 at 09:07 +0100, Mel Gorman wrote:
> On Fri, May 06, 2011 at 08:42:24AM +0100, Mel Gorman wrote:
> > 1. High-order allocations? You machine is using i915 and RPC, something
> >    neither of my test machine uses. i915 is potentially a source for
> >    high-order allocations. I'm attaching a perl script. Please run it as
> >    ./watch-highorder.pl --output /tmp/highorders.txt
> >    while you are running tar. When kswapd is running for about 30
> >    seconds, interrupt it with ctrl+c twice in quick succession and
> >    post /tmp/highorders.txt
> > 
> 
> Attached this time :/

Here's the output (loaded with tar, evolution and firefox).  The top
trace is different this time because your perl script perturbs the
system quite a bit.  This was with your slub allocation fix applied.

James

---
1 instances order=1 normal gfp_flags=GFP_KERNEL|GFP_NOWARN|GFP_NORETRY|GFP_COMP|
 => __alloc_pages_nodemask+0x737/0x772 <ffffffff810dc0bd>
 => alloc_pages_current+0xbe/0xd8 <ffffffff81105435>
 => alloc_slab_page+0x1c/0x4d <ffffffff8110c5da>
 => new_slab+0x50/0x199 <ffffffff8110dc24>
 => __slab_alloc+0x24a/0x328 <ffffffff8146ab66>
 => __kmalloc+0xb1/0x10d <ffffffff8110dfbb>
 => sg_kmalloc+0x24/0x26 <ffffffff81230eb9>
 => __sg_alloc_table+0x63/0x11c <ffffffff81230dbf>

1 instances order=1 atomic gfp_flags=GFP_ATOMIC|GFP_NOWARN|GFP_NORETRY|GFP_COMP|
 => __alloc_pages_nodemask+0x737/0x772 <ffffffff810dc0bd>
 => alloc_pages_current+0xbe/0xd8 <ffffffff81105435>
 => __page_cache_alloc+0x77/0x7e <ffffffff810d5778>
 => __do_page_cache_readahead+0x9b/0x177 <ffffffff810dd74b>
 => ra_submit+0x21/0x25 <ffffffff810dda8d>
 => ondemand_readahead+0x1c9/0x1d8 <ffffffff810ddc5a>
 => page_cache_sync_readahead+0x3d/0x40 <ffffffff810ddd49>
 => generic_file_aio_read+0x27d/0x5e0 <ffffffff810d64d0>

177 instances order=2 normal gfp_flags=GFP_NOFS|GFP_NOWARN|GFP_NORETRY|GFP_COMP|GFP_RECLAIMABLE|
 => __alloc_pages_nodemask+0x737/0x772 <ffffffff810dc0bd>
 => alloc_pages_current+0xbe/0xd8 <ffffffff81105435>
 => alloc_slab_page+0x1c/0x4d <ffffffff8110c5da>
 => new_slab+0x50/0x199 <ffffffff8110dc24>
 => __slab_alloc+0x24a/0x328 <ffffffff8146ab66>
 => kmem_cache_alloc+0x77/0x105 <ffffffff8110e42c>
 => radix_tree_preload+0x31/0x81 <ffffffff81229399>
 => add_to_page_cache_locked+0x56/0x118 <ffffffff810d57d5>

1 instances order=1 normal gfp_flags=GFP_KERNEL|GFP_NOWARN|GFP_NORETRY|GFP_COMP|
 => __alloc_pages_nodemask+0x737/0x772 <ffffffff810dc0bd>
 => alloc_pages_vma+0xf5/0xfa <ffffffff81107001>
 => do_wp_page+0x348/0x560 <ffffffff810ef711>
 => handle_pte_fault+0x73b/0x7a5 <ffffffff810f13b7>
 => handle_mm_fault+0x1bb/0x1ce <ffffffff810f1798>
 => do_page_fault+0x358/0x37a <ffffffff8147416e>
 => page_fault+0x25/0x30 <ffffffff81471415>

46 instances order=1 normal gfp_flags=GFP_KERNEL|GFP_NOWARN|GFP_NORETRY|GFP_COMP|
 => __alloc_pages_nodemask+0x737/0x772 <ffffffff810dc0bd>
 => alloc_pages_current+0xbe/0xd8 <ffffffff81105435>
 => alloc_slab_page+0x1c/0x4d <ffffffff8110c5da>
 => new_slab+0x50/0x199 <ffffffff8110dc24>
 => __slab_alloc+0x24a/0x328 <ffffffff8146ab66>
 => kmem_cache_alloc+0x77/0x105 <ffffffff8110e42c>
 => prepare_creds+0x26/0xae <ffffffff81074d4b>
 => sys_faccessat+0x37/0x162 <ffffffff8111d255>

1 instances order=1 atomic gfp_flags=GFP_ATOMIC|GFP_NOWARN|GFP_NORETRY|GFP_COMP|
 => __alloc_pages_nodemask+0x737/0x772 <ffffffff810dc0bd>
 => alloc_pages_current+0xbe/0xd8 <ffffffff81105435>
 => alloc_slab_page+0x1c/0x4d <ffffffff8110c5da>
 => new_slab+0x50/0x199 <ffffffff8110dc24>
 => __slab_alloc+0x24a/0x328 <ffffffff8146ab66>
 => kmem_cache_alloc_node+0x93/0x12d <ffffffff8110e199>
 => __alloc_skb+0x40/0x133 <ffffffff813b5df7>
 => __netdev_alloc_skb+0x1f/0x3b <ffffffff813b5f4a>

1 instances order=2 normal gfp_flags=GFP_TEMPORARY|GFP_NOWARN|GFP_NORETRY|GFP_COMP|
 => __alloc_pages_nodemask+0x737/0x772 <ffffffff810dc0bd>
 => alloc_pages_current+0xbe/0xd8 <ffffffff81105435>
 => alloc_slab_page+0x1c/0x4d <ffffffff8110c5da>
 => new_slab+0x50/0x199 <ffffffff8110dc24>
 => __slab_alloc+0x24a/0x328 <ffffffff8146ab66>
 => kmem_cache_alloc+0x77/0x105 <ffffffff8110e42c>
 => alloc_inode+0x30/0x78 <ffffffff811317f8>
 => new_inode+0x1b/0x4b <ffffffff8113185b>

16 instances order=9 normal gfp_flags=GFP_HIGHUSER_MOVABLE|GFP_NOWARN|GFP_NORETRY|GFP_COMP|GFP_NOMEMALLOC|
 => __alloc_pages_nodemask+0x737/0x772 <ffffffff810dc0bd>
 => alloc_pages_vma+0xf5/0xfa <ffffffff81107001>
 => do_huge_pmd_anonymous_page+0xbf/0x261 <ffffffff81115b6a>
 => handle_mm_fault+0x113/0x1ce <ffffffff810f16f0>
 => do_page_fault+0x358/0x37a <ffffffff8147416e>
 => page_fault+0x25/0x30 <ffffffff81471415>

5 instances order=3 atomic gfp_flags=GFP_ATOMIC|GFP_NOWARN|GFP_NORETRY|GFP_COMP|
 => __alloc_pages_nodemask+0x737/0x772 <ffffffff810dc0bd>
 => alloc_pages_current+0xbe/0xd8 <ffffffff81105435>
 => alloc_slab_page+0x1c/0x4d <ffffffff8110c5da>
 => new_slab+0x50/0x199 <ffffffff8110dc24>
 => __slab_alloc+0x24a/0x328 <ffffffff8146ab66>
 => __kmalloc_node_track_caller+0xcf/0x131 <ffffffff8110ffa6>
 => __alloc_skb+0x75/0x133 <ffffffff813b5e2c>
 => __netdev_alloc_skb+0x1f/0x3b <ffffffff813b5f4a>

252 instances order=2 normal gfp_flags=GFP_TEMPORARY|GFP_NOWARN|GFP_NORETRY|GFP_COMP|
 => __alloc_pages_nodemask+0x737/0x772 <ffffffff810dc0bd>
 => alloc_pages_current+0xbe/0xd8 <ffffffff81105435>
 => alloc_slab_page+0x1c/0x4d <ffffffff8110c5da>
 => new_slab+0x50/0x199 <ffffffff8110dc24>
 => __slab_alloc+0x24a/0x328 <ffffffff8146ab66>
 => kmem_cache_alloc+0x77/0x105 <ffffffff8110e42c>
 => radix_tree_preload+0x31/0x81 <ffffffff81229399>
 => add_to_page_cache_locked+0x56/0x118 <ffffffff810d57d5>

1 instances order=1 atomic gfp_flags=GFP_ATOMIC|GFP_NOWARN|GFP_NORETRY|GFP_COMP|
 => __alloc_pages_nodemask+0x737/0x772 <ffffffff810dc0bd>
 => alloc_pages_current+0xbe/0xd8 <ffffffff81105435>
 => alloc_slab_page+0x1c/0x4d <ffffffff8110c5da>
 => new_slab+0x50/0x199 <ffffffff8110dc24>
 => __slab_alloc+0x24a/0x328 <ffffffff8146ab66>
 => kmem_cache_alloc+0x77/0x105 <ffffffff8110e42c>
 => skb_clone+0x50/0x70 <ffffffff813b5d97>
 => packet_rcv+0x101/0x2b2 <ffffffff81441e80>

1 instances order=2 normal gfp_flags=GFP_TEMPORARY|GFP_NOWARN|GFP_NORETRY|GFP_COMP|
 => __alloc_pages_nodemask+0x737/0x772 <ffffffff810dc0bd>
 => alloc_pages_current+0xbe/0xd8 <ffffffff81105435>
 => alloc_slab_page+0x1c/0x4d <ffffffff8110c5da>
 => new_slab+0x50/0x199 <ffffffff8110dc24>
 => __slab_alloc+0x24a/0x328 <ffffffff8146ab66>
 => kmem_cache_alloc+0x77/0x105 <ffffffff8110e42c>
 => alloc_inode+0x30/0x78 <ffffffff811317f8>
 => iget_locked+0x61/0xdd <ffffffff8113239a>

1 instances order=2 normal gfp_flags=GFP_KERNEL|GFP_NOWARN|GFP_NORETRY|GFP_COMP|
 => __alloc_pages_nodemask+0x737/0x772 <ffffffff810dc0bd>
 => alloc_pages_current+0xbe/0xd8 <ffffffff81105435>
 => alloc_slab_page+0x1c/0x4d <ffffffff8110c5da>
 => new_slab+0x50/0x199 <ffffffff8110dc24>
 => __slab_alloc+0x24a/0x328 <ffffffff8146ab66>
 => __kmalloc+0xb1/0x10d <ffffffff8110dfbb>
 => sg_kmalloc+0x24/0x26 <ffffffff81230eb9>
 => __sg_alloc_table+0x63/0x11c <ffffffff81230dbf>

1 instances order=3 normal gfp_flags=GFP_KERNEL|GFP_NOWARN|GFP_NORETRY|GFP_COMP|
 => __alloc_pages_nodemask+0x737/0x772 <ffffffff810dc0bd>
 => alloc_pages_current+0xbe/0xd8 <ffffffff81105435>
 => alloc_slab_page+0x1c/0x4d <ffffffff8110c5da>
 => new_slab+0x50/0x199 <ffffffff8110dc24>
 => __slab_alloc+0x24a/0x328 <ffffffff8146ab66>
 => kmem_cache_alloc+0x77/0x105 <ffffffff8110e42c>
 => copy_process+0x66e/0x10c5 <ffffffff81053961>
 => do_fork+0x104/0x286 <ffffffff810544f7>

1 instances order=1 normal gfp_flags=GFP_KERNEL
 => __alloc_pages_nodemask+0x737/0x772 <ffffffff810dc0bd>
 => alloc_pages_current+0xbe/0xd8 <ffffffff81105435>
 => __get_free_pages+0xe/0x4a <ffffffff810d89d2>
 => copy_process+0xe1/0x10c5 <ffffffff810533d4>
 => do_fork+0x104/0x286 <ffffffff810544f7>
 => kernel_thread+0x75/0x77 <ffffffff81010bb6>
 => wait_for_helper+0x6b/0xa3 <ffffffff81068fca>
 => kernel_thread_helper+0x4/0x10 <ffffffff8100a9a4>

133 instances order=9 normal gfp_flags=GFP_HIGHUSER_MOVABLE|GFP_NOWARN|GFP_NORETRY|GFP_COMP|GFP_NOMEMALLOC|
 => __alloc_pages_nodemask+0x737/0x772 <ffffffff810dc0bd>
 => alloc_pages_vma+0xf5/0xfa <ffffffff81107001>
 => khugepaged+0x543/0xf2d <ffffffff81113cc1>
 => kthread+0x84/0x8c <ffffffff8106f2df>
 => kernel_thread_helper+0x4/0x10 <ffffffff8100a9a4>

593 instances order=3 normal gfp_flags=GFP_NOFS|GFP_NOWARN|GFP_NORETRY|GFP_COMP|GFP_RECLAIMABLE|
 => __alloc_pages_nodemask+0x737/0x772 <ffffffff810dc0bd>
 => alloc_pages_current+0xbe/0xd8 <ffffffff81105435>
 => alloc_slab_page+0x1c/0x4d <ffffffff8110c5da>
 => new_slab+0x50/0x199 <ffffffff8110dc24>
 => __slab_alloc+0x24a/0x328 <ffffffff8146ab66>
 => kmem_cache_alloc+0x77/0x105 <ffffffff8110e42c>
 => ext4_alloc_inode+0x1a/0x111 <ffffffff8119f498>
 => alloc_inode+0x1d/0x78 <ffffffff811317e5>

2 instances order=3 normal gfp_flags=GFP_KERNEL|GFP_NOWARN|GFP_NORETRY|GFP_COMP|
 => __alloc_pages_nodemask+0x737/0x772 <ffffffff810dc0bd>
 => alloc_pages_current+0xbe/0xd8 <ffffffff81105435>
 => alloc_slab_page+0x1c/0x4d <ffffffff8110c5da>
 => new_slab+0x50/0x199 <ffffffff8110dc24>
 => __slab_alloc+0x24a/0x328 <ffffffff8146ab66>
 => __kmalloc+0xb1/0x10d <ffffffff8110dfbb>
 => drm_malloc_ab+0x3b/0x53 [i915] <ffffffffa007fbd2>
 => i915_gem_execbuffer2+0x4f/0x12e [i915] <ffffffffa0080f81>

14 instances order=1 normal gfp_flags=GFP_TEMPORARY|GFP_NOWARN|GFP_NORETRY|GFP_COMP|
 => __alloc_pages_nodemask+0x737/0x772 <ffffffff810dc0bd>
 => alloc_pages_current+0xbe/0xd8 <ffffffff81105435>
 => alloc_slab_page+0x1c/0x4d <ffffffff8110c5da>
 => new_slab+0x50/0x199 <ffffffff8110dc24>
 => __slab_alloc+0x24a/0x328 <ffffffff8146ab66>
 => kmem_cache_alloc+0x77/0x105 <ffffffff8110e42c>
 => d_alloc+0x26/0x18d <ffffffff8112e4c5>
 => shmem_file_setup+0xb6/0x160 <ffffffff810e70ad>

38 instances order=1 normal gfp_flags=GFP_KERNEL|GFP_NOWARN|GFP_NORETRY|GFP_COMP|
 => __alloc_pages_nodemask+0x737/0x772 <ffffffff810dc0bd>
 => alloc_pages_current+0xbe/0xd8 <ffffffff81105435>
 => alloc_slab_page+0x1c/0x4d <ffffffff8110c5da>
 => new_slab+0x50/0x199 <ffffffff8110dc24>
 => __slab_alloc+0x24a/0x328 <ffffffff8146ab66>
 => kmem_cache_alloc+0x77/0x105 <ffffffff8110e42c>
 => mmap_region+0x1b7/0x446 <ffffffff810f6555>
 => do_mmap_pgoff+0x298/0x2f2 <ffffffff810f6a7c>

1 instances order=2 normal gfp_flags=GFP_KERNEL|GFP_NOWARN|GFP_NORETRY|GFP_COMP|
 => __alloc_pages_nodemask+0x737/0x772 <ffffffff810dc0bd>
 => alloc_pages_current+0xbe/0xd8 <ffffffff81105435>
 => alloc_slab_page+0x1c/0x4d <ffffffff8110c5da>
 => new_slab+0x50/0x199 <ffffffff8110dc24>
 => __slab_alloc+0x24a/0x328 <ffffffff8146ab66>
 => kmem_cache_alloc+0x77/0x105 <ffffffff8110e42c>
 => idr_pre_get+0x2d/0x6f <ffffffff812266c4>
 => drm_gem_handle_create+0x2f/0x82 [drm] <ffffffffa0024f75>

400 instances order=1 normal gfp_flags=GFP_KERNEL
 => __alloc_pages_nodemask+0x737/0x772 <ffffffff810dc0bd>
 => alloc_pages_current+0xbe/0xd8 <ffffffff81105435>
 => __get_free_pages+0xe/0x4a <ffffffff810d89d2>
 => copy_process+0xe1/0x10c5 <ffffffff810533d4>
 => do_fork+0x104/0x286 <ffffffff810544f7>
 => sys_clone+0x28/0x2a <ffffffff8101150e>
 => stub_clone+0x13/0x20 <ffffffff81009ea3>

9 instances order=1 normal gfp_flags=GFP_KERNEL|GFP_NOWARN|GFP_REPEAT|GFP_NORETRY|GFP_COMP|
 => __alloc_pages_nodemask+0x737/0x772 <ffffffff810dc0bd>
 => alloc_pages_current+0xbe/0xd8 <ffffffff81105435>
 => alloc_slab_page+0x1c/0x4d <ffffffff8110c5da>
 => new_slab+0x50/0x199 <ffffffff8110dc24>
 => __slab_alloc+0x24a/0x328 <ffffffff8146ab66>
 => kmem_cache_alloc_node+0x93/0x12d <ffffffff8110e199>
 => __alloc_skb+0x40/0x133 <ffffffff813b5df7>
 => sock_alloc_send_pskb+0xb4/0x2d7 <ffffffff813b238a>

1 instances order=2 normal gfp_flags=GFP_KERNEL|GFP_REPEAT|GFP_COMP
 => __alloc_pages_nodemask+0x737/0x772 <ffffffff810dc0bd>
 => alloc_pages_vma+0xf5/0xfa <ffffffff81107001>
 => handle_pte_fault+0x16f/0x7a5 <ffffffff810f0deb>
 => handle_mm_fault+0x1bb/0x1ce <ffffffff810f1798>
 => do_page_fault+0x358/0x37a <ffffffff8147416e>
 => page_fault+0x25/0x30 <ffffffff81471415>
 => unix_stream_recvmsg+0x40f/0x536 <ffffffff8143dbe0>
 => sock_aio_read.part.7+0x10d/0x121 <ffffffff813afa54>

2 instances order=1 normal gfp_flags=GFP_KERNEL
 => __alloc_pages_nodemask+0x737/0x772 <ffffffff810dc0bd>
 => alloc_pages_current+0xbe/0xd8 <ffffffff81105435>
 => __get_free_pages+0xe/0x4a <ffffffff810d89d2>
 => copy_process+0xe1/0x10c5 <ffffffff810533d4>
 => do_fork+0x104/0x286 <ffffffff810544f7>
 => kernel_thread+0x75/0x77 <ffffffff81010bb6>
 => __call_usermodehelper+0x43/0x76 <ffffffff81069132>
 => process_one_work+0x186/0x298 <ffffffff8106b3ca>

14 instances order=3 normal gfp_flags=GFP_KERNEL|GFP_NOWARN|GFP_REPEAT|GFP_NORETRY|GFP_COMP|
 => __alloc_pages_nodemask+0x737/0x772 <ffffffff810dc0bd>
 => alloc_pages_current+0xbe/0xd8 <ffffffff81105435>
 => alloc_slab_page+0x1c/0x4d <ffffffff8110c5da>
 => new_slab+0x50/0x199 <ffffffff8110dc24>
 => __slab_alloc+0x24a/0x328 <ffffffff8146ab66>
 => __kmalloc_node_track_caller+0xcf/0x131 <ffffffff8110ffa6>
 => __alloc_skb+0x75/0x133 <ffffffff813b5e2c>
 => sock_alloc_send_pskb+0xb4/0x2d7 <ffffffff813b238a>

781 instances order=2 normal gfp_flags=GFP_KERNEL|GFP_REPEAT|GFP_COMP
 => __alloc_pages_nodemask+0x737/0x772 <ffffffff810dc0bd>
 => kmalloc_large_node+0x56/0x95 <ffffffff8146a55d>
 => __kmalloc_node_track_caller+0x31/0x131 <ffffffff8110ff08>
 => __alloc_skb+0x75/0x133 <ffffffff813b5e2c>
 => sock_alloc_send_pskb+0xb4/0x2d7 <ffffffff813b238a>
 => sock_alloc_send_skb+0x15/0x17 <ffffffff813b25c2>
 => unix_stream_sendmsg+0x11e/0x2ec <ffffffff8143d217>
 => __sock_sendmsg+0x69/0x76 <ffffffff813af778>

1 instances order=1 normal gfp_flags=GFP_NOWARN|GFP_NORETRY|GFP_COMP|GFP_NOMEMALLOC|
 => __alloc_pages_nodemask+0x737/0x772 <ffffffff810dc0bd>
 => alloc_pages_current+0xbe/0xd8 <ffffffff81105435>
 => __get_free_pages+0xe/0x4a <ffffffff810d89d2>
 => __pollwait+0x5e/0xcc <ffffffff8112c9e7>
 => sock_poll_wait+0x18/0x1d <ffffffff8143cc50>
 => unix_poll+0x1c/0x9a <ffffffff8143cc71>
 => sock_poll+0x1a/0x1c <ffffffff813ad41a>
 => do_sys_poll+0x1fa/0x386 <ffffffff8112d75d>

48 instances order=1 normal gfp_flags=GFP_KERNEL|GFP_NOWARN|GFP_NORETRY|GFP_COMP|
 => __alloc_pages_nodemask+0x737/0x772 <ffffffff810dc0bd>
 => alloc_pages_current+0xbe/0xd8 <ffffffff81105435>
 => alloc_slab_page+0x1c/0x4d <ffffffff8110c5da>
 => new_slab+0x50/0x199 <ffffffff8110dc24>
 => __slab_alloc+0x24a/0x328 <ffffffff8146ab66>
 => kmem_cache_alloc+0x77/0x105 <ffffffff8110e42c>
 => __split_vma+0x6c/0x21b <ffffffff810f5099>
 => split_vma+0x20/0x22 <ffffffff810f59a6>

3 instances order=3 normal gfp_flags=GFP_KERNEL|GFP_NOWARN|GFP_NORETRY|GFP_COMP|
 => __alloc_pages_nodemask+0x737/0x772 <ffffffff810dc0bd>
 => alloc_pages_current+0xbe/0xd8 <ffffffff81105435>
 => alloc_slab_page+0x1c/0x4d <ffffffff8110c5da>
 => new_slab+0x50/0x199 <ffffffff8110dc24>
 => __slab_alloc+0x24a/0x328 <ffffffff8146ab66>
 => kmem_cache_alloc+0x77/0x105 <ffffffff8110e42c>
 => sk_prot_alloc+0x37/0x13a <ffffffff813b27d4>
 => sk_alloc+0x2c/0x8e <ffffffff813b2935>

24 instances order=2 normal gfp_flags=GFP_TEMPORARY|GFP_NOWARN|GFP_NORETRY|GFP_COMP|
 => __alloc_pages_nodemask+0x737/0x772 <ffffffff810dc0bd>
 => alloc_pages_current+0xbe/0xd8 <ffffffff81105435>
 => alloc_slab_page+0x1c/0x4d <ffffffff8110c5da>
 => new_slab+0x50/0x199 <ffffffff8110dc24>
 => __slab_alloc+0x24a/0x328 <ffffffff8146ab66>
 => kmem_cache_alloc+0x77/0x105 <ffffffff8110e42c>
 => proc_alloc_inode+0x20/0x91 <ffffffff8116829c>
 => alloc_inode+0x1d/0x78 <ffffffff811317e5>

1 instances order=1 normal gfp_flags=GFP_NOFS|GFP_NOWARN|GFP_NORETRY|GFP_COMP|GFP_RECLAIMABLE|
 => __alloc_pages_nodemask+0x737/0x772 <ffffffff810dc0bd>
 => alloc_pages_current+0xbe/0xd8 <ffffffff81105435>
 => alloc_slab_page+0x1c/0x4d <ffffffff8110c5da>
 => new_slab+0x50/0x199 <ffffffff8110dc24>
 => __slab_alloc+0x24a/0x328 <ffffffff8146ab66>
 => kmem_cache_alloc+0x77/0x105 <ffffffff8110e42c>
 => ext4_mb_new_blocks+0x118/0x3c2 <ffffffff811b73a7>
 => ext4_ext_map_blocks+0x192b/0x1b5b <ffffffff811b0a5d>

5 instances order=2 normal gfp_flags=GFP_TEMPORARY|GFP_NOWARN|GFP_NORETRY|GFP_COMP|
 => __alloc_pages_nodemask+0x737/0x772 <ffffffff810dc0bd>
 => alloc_pages_current+0xbe/0xd8 <ffffffff81105435>
 => alloc_slab_page+0x1c/0x4d <ffffffff8110c5da>
 => new_slab+0x50/0x199 <ffffffff8110dc24>
 => __slab_alloc+0x24a/0x328 <ffffffff8146ab66>
 => kmem_cache_alloc+0x77/0x105 <ffffffff8110e42c>
 => sock_alloc_inode+0x1d/0xaa <ffffffff813ad605>
 => alloc_inode+0x1d/0x78 <ffffffff811317e5>

3 instances order=2 atomic gfp_flags=GFP_ATOMIC|GFP_NOWARN|GFP_NORETRY|GFP_COMP|
 => __alloc_pages_nodemask+0x737/0x772 <ffffffff810dc0bd>
 => alloc_pages_current+0xbe/0xd8 <ffffffff81105435>
 => alloc_slab_page+0x1c/0x4d <ffffffff8110c5da>
 => new_slab+0x50/0x199 <ffffffff8110dc24>
 => __slab_alloc+0x24a/0x328 <ffffffff8146ab66>
 => kmem_cache_alloc+0x77/0x105 <ffffffff8110e42c>
 => dst_alloc+0x48/0xaa <ffffffff813c6652>
 => __ip_route_output_key+0x561/0x764 <ffffffff813ee4f3>

3 instances order=1 normal gfp_flags=GFP_NOWARN|GFP_NORETRY|GFP_COMP|GFP_NOMEMALLOC|
 => __alloc_pages_nodemask+0x737/0x772 <ffffffff810dc0bd>
 => alloc_pages_current+0xbe/0xd8 <ffffffff81105435>
 => __get_free_pages+0xe/0x4a <ffffffff810d89d2>
 => __pollwait+0x5e/0xcc <ffffffff8112c9e7>
 => sock_poll_wait+0x18/0x1d <ffffffff8143cc50>
 => unix_poll+0x1c/0x9a <ffffffff8143cc71>
 => sock_poll+0x1a/0x1c <ffffffff813ad41a>
 => do_select+0x2fb/0x4f5 <ffffffff8112cf13>

4 instances order=1 normal gfp_flags=GFP_KERNEL|GFP_NOWARN|GFP_NORETRY|GFP_COMP|
 => __alloc_pages_nodemask+0x737/0x772 <ffffffff810dc0bd>
 => alloc_pages_current+0xbe/0xd8 <ffffffff81105435>
 => alloc_slab_page+0x1c/0x4d <ffffffff8110c5da>
 => new_slab+0x50/0x199 <ffffffff8110dc24>
 => __slab_alloc+0x24a/0x328 <ffffffff8146ab66>
 => kmem_cache_alloc+0x77/0x105 <ffffffff8110e42c>
 => __split_vma+0x6c/0x21b <ffffffff810f5099>
 => do_munmap+0x194/0x30b <ffffffff810f57ad>

229 instances order=1 normal gfp_flags=GFP_KERNEL|GFP_NOWARN|GFP_NORETRY|GFP_COMP|
 => __alloc_pages_nodemask+0x737/0x772 <ffffffff810dc0bd>
 => alloc_pages_current+0xbe/0xd8 <ffffffff81105435>
 => alloc_slab_page+0x1c/0x4d <ffffffff8110c5da>
 => new_slab+0x50/0x199 <ffffffff8110dc24>
 => __slab_alloc+0x24a/0x328 <ffffffff8146ab66>
 => kmem_cache_alloc+0x77/0x105 <ffffffff8110e42c>
 => dup_mm+0x1f8/0x486 <ffffffff81053039>
 => copy_process+0x917/0x10c5 <ffffffff81053c0a>

1 instances order=1 normal gfp_flags=GFP_KERNEL|GFP_NOWARN|GFP_NORETRY|GFP_COMP|
 => __alloc_pages_nodemask+0x737/0x772 <ffffffff810dc0bd>
 => alloc_pages_current+0xbe/0xd8 <ffffffff81105435>
 => alloc_slab_page+0x1c/0x4d <ffffffff8110c5da>
 => new_slab+0x50/0x199 <ffffffff8110dc24>
 => __slab_alloc+0x24a/0x328 <ffffffff8146ab66>
 => kmem_cache_alloc+0x77/0x105 <ffffffff8110e42c>
 => bprm_mm_init+0x70/0x1a0 <ffffffff811239aa>
 => do_execve+0xd6/0x277 <ffffffff81123dd4>

2 instances order=2 atomic gfp_flags=GFP_ATOMIC|GFP_NOWARN|GFP_NORETRY|GFP_COMP|
 => __alloc_pages_nodemask+0x737/0x772 <ffffffff810dc0bd>
 => alloc_pages_current+0xbe/0xd8 <ffffffff81105435>
 => alloc_slab_page+0x1c/0x4d <ffffffff8110c5da>
 => new_slab+0x50/0x199 <ffffffff8110dc24>
 => __slab_alloc+0x24a/0x328 <ffffffff8146ab66>
 => __kmalloc_node_track_caller+0xcf/0x131 <ffffffff8110ffa6>
 => __alloc_skb+0x75/0x133 <ffffffff813b5e2c>
 => find_skb+0x3a/0x82 <ffffffff813d1996>

2 instances order=1 normal gfp_flags=GFP_KERNEL|GFP_NOWARN|GFP_NORETRY|GFP_COMP|
 => __alloc_pages_nodemask+0x737/0x772 <ffffffff810dc0bd>
 => alloc_pages_current+0xbe/0xd8 <ffffffff81105435>
 => alloc_slab_page+0x1c/0x4d <ffffffff8110c5da>
 => new_slab+0x50/0x199 <ffffffff8110dc24>
 => __slab_alloc+0x24a/0x328 <ffffffff8146ab66>
 => kmem_cache_alloc+0x77/0x105 <ffffffff8110e42c>
 => __split_vma+0x6c/0x21b <ffffffff810f5099>
 => do_munmap+0x15f/0x30b <ffffffff810f5778>

1 instances order=1 normal gfp_flags=GFP_NOWARN|GFP_NORETRY|GFP_COMP|GFP_NOMEMALLOC|
 => __alloc_pages_nodemask+0x737/0x772 <ffffffff810dc0bd>
 => alloc_pages_vma+0xf5/0xfa <ffffffff81107001>
 => handle_pte_fault+0x16f/0x7a5 <ffffffff810f0deb>
 => handle_mm_fault+0x1bb/0x1ce <ffffffff810f1798>
 => do_page_fault+0x358/0x37a <ffffffff8147416e>
 => page_fault+0x25/0x30 <ffffffff81471415>

501 instances order=1 normal gfp_flags=GFP_KERNEL|GFP_NOWARN|GFP_NORETRY|GFP_COMP|
 => __alloc_pages_nodemask+0x737/0x772 <ffffffff810dc0bd>
 => alloc_pages_current+0xbe/0xd8 <ffffffff81105435>
 => alloc_slab_page+0x1c/0x4d <ffffffff8110c5da>
 => new_slab+0x50/0x199 <ffffffff8110dc24>
 => __slab_alloc+0x24a/0x328 <ffffffff8146ab66>
 => kmem_cache_alloc+0x77/0x105 <ffffffff8110e42c>
 => get_empty_filp+0x7a/0x141 <ffffffff8111f2d1>
 => do_filp_open+0xe7/0x60a <ffffffff81129bcf>

18 instances order=1 normal gfp_flags=GFP_NOWARN|GFP_NORETRY|GFP_COMP|GFP_NOMEMALLOC|
 => __alloc_pages_nodemask+0x737/0x772 <ffffffff810dc0bd>
 => alloc_pages_current+0xbe/0xd8 <ffffffff81105435>
 => alloc_slab_page+0x1c/0x4d <ffffffff8110c5da>
 => new_slab+0x50/0x199 <ffffffff8110dc24>
 => __slab_alloc+0x24a/0x328 <ffffffff8146ab66>
 => kmem_cache_alloc+0x77/0x105 <ffffffff8110e42c>
 => bvec_alloc_bs+0xae/0xcc <ffffffff81144d61>
 => bio_alloc_bioset+0x75/0xc3 <ffffffff81144df4>

1370 instances order=1 normal gfp_flags=GFP_TEMPORARY|GFP_NOWARN|GFP_NORETRY|GFP_COMP|
 => __alloc_pages_nodemask+0x737/0x772 <ffffffff810dc0bd>
 => alloc_pages_current+0xbe/0xd8 <ffffffff81105435>
 => alloc_slab_page+0x1c/0x4d <ffffffff8110c5da>
 => new_slab+0x50/0x199 <ffffffff8110dc24>
 => __slab_alloc+0x24a/0x328 <ffffffff8146ab66>
 => kmem_cache_alloc+0x77/0x105 <ffffffff8110e42c>
 => d_alloc+0x26/0x18d <ffffffff8112e4c5>
 => d_alloc_and_lookup+0x2c/0x6b <ffffffff81126d0e>

1 instances order=2 normal gfp_flags=GFP_KERNEL|GFP_NOWARN|GFP_NORETRY|GFP_COMP|
 => __alloc_pages_nodemask+0x737/0x772 <ffffffff810dc0bd>
 => alloc_pages_current+0xbe/0xd8 <ffffffff81105435>
 => alloc_slab_page+0x1c/0x4d <ffffffff8110c5da>
 => new_slab+0x50/0x199 <ffffffff8110dc24>
 => __slab_alloc+0x24a/0x328 <ffffffff8146ab66>
 => __kmalloc+0xb1/0x10d <ffffffff8110dfbb>
 => kzalloc.constprop.1+0x13/0x15 [i915] <ffffffffa007fbfd>
 => i915_gem_do_execbuffer+0x306/0x1116 [i915] <ffffffffa007ff05>

1 instances order=1 normal gfp_flags=GFP_KERNEL|GFP_NOWARN|GFP_NORETRY|GFP_COMP|
 => __alloc_pages_nodemask+0x737/0x772 <ffffffff810dc0bd>
 => alloc_pages_current+0xbe/0xd8 <ffffffff81105435>
 => alloc_slab_page+0x1c/0x4d <ffffffff8110c5da>
 => new_slab+0x50/0x199 <ffffffff8110dc24>
 => __slab_alloc+0x24a/0x328 <ffffffff8146ab66>
 => kmem_cache_alloc+0x77/0x105 <ffffffff8110e42c>
 => taskstats_exit+0x5b/0x2e3 <ffffffff810b0810>
 => do_exit+0x22a/0x6ef <ffffffff8105841f>

17 instances order=1 normal gfp_flags=GFP_TEMPORARY|GFP_NOWARN|GFP_NORETRY|GFP_COMP|
 => __alloc_pages_nodemask+0x737/0x772 <ffffffff810dc0bd>
 => alloc_pages_current+0xbe/0xd8 <ffffffff81105435>
 => alloc_slab_page+0x1c/0x4d <ffffffff8110c5da>
 => new_slab+0x50/0x199 <ffffffff8110dc24>
 => __slab_alloc+0x24a/0x328 <ffffffff8146ab66>
 => kmem_cache_alloc+0x77/0x105 <ffffffff8110e42c>
 => d_alloc+0x26/0x18d <ffffffff8112e4c5>
 => proc_fill_cache+0x82/0x135 <ffffffff8116903b>

99 instances order=1 atomic gfp_flags=GFP_ATOMIC|GFP_NOWARN|GFP_NORETRY|GFP_COMP|GFP_NOMEMALLOC|
 => __alloc_pages_nodemask+0x737/0x772 <ffffffff810dc0bd>
 => alloc_pages_current+0xbe/0xd8 <ffffffff81105435>
 => alloc_slab_page+0x1c/0x4d <ffffffff8110c5da>
 => new_slab+0x50/0x199 <ffffffff8110dc24>
 => __slab_alloc+0x24a/0x328 <ffffffff8146ab66>
 => kmem_cache_alloc+0x77/0x105 <ffffffff8110e42c>
 => mempool_alloc_slab+0x15/0x17 <ffffffff810d6e81>
 => mempool_alloc+0x68/0x116 <ffffffff810d70f6>

1 instances order=1 atomic gfp_flags=GFP_ATOMIC|GFP_NOWARN|GFP_NORETRY|GFP_COMP|
 => __alloc_pages_nodemask+0x737/0x772 <ffffffff810dc0bd>
 => alloc_pages_current+0xbe/0xd8 <ffffffff81105435>
 => alloc_slab_page+0x1c/0x4d <ffffffff8110c5da>
 => new_slab+0x50/0x199 <ffffffff8110dc24>
 => __slab_alloc+0x24a/0x328 <ffffffff8146ab66>
 => kmem_cache_alloc+0x77/0x105 <ffffffff8110e42c>
 => inet_twsk_alloc+0x31/0x11e <ffffffff813f8a16>
 => tcp_time_wait+0xb9/0x29a <ffffffff8140e24f>

26 instances order=1 normal gfp_flags=GFP_NOWARN|GFP_NORETRY|GFP_COMP|GFP_NOMEMALLOC|
 => __alloc_pages_nodemask+0x737/0x772 <ffffffff810dc0bd>
 => alloc_pages_current+0xbe/0xd8 <ffffffff81105435>
 => __page_cache_alloc+0x77/0x7e <ffffffff810d5778>
 => grab_cache_page_write_begin+0x54/0x9e <ffffffff810d5943>
 => ext4_da_write_begin+0x13f/0x20e <ffffffff81196376>
 => generic_file_buffered_write+0x109/0x23a <ffffffff810d5408>
 => __generic_file_aio_write+0x242/0x272 <ffffffff810d617d>
 => generic_file_aio_write+0x58/0xa6 <ffffffff810d6205>

1 instances order=2 normal gfp_flags=GFP_KERNEL|GFP_NOWARN|GFP_NORETRY|GFP_COMP|
 => __alloc_pages_nodemask+0x737/0x772 <ffffffff810dc0bd>
 => alloc_pages_current+0xbe/0xd8 <ffffffff81105435>
 => alloc_slab_page+0x1c/0x4d <ffffffff8110c5da>
 => new_slab+0x50/0x199 <ffffffff8110dc24>
 => __slab_alloc+0x24a/0x328 <ffffffff8146ab66>
 => __kmalloc+0xb1/0x10d <ffffffff8110dfbb>
 => drm_malloc_ab+0x3b/0x53 [i915] <ffffffffa007fbd2>
 => i915_gem_do_execbuffer+0x64a/0x1116 [i915] <ffffffffa0080249>

6 instances order=1 normal gfp_flags=GFP_KERNEL
 => __alloc_pages_nodemask+0x737/0x772 <ffffffff810dc0bd>
 => alloc_pages_current+0xbe/0xd8 <ffffffff81105435>
 => __get_free_pages+0xe/0x4a <ffffffff810d89d2>
 => copy_process+0xe1/0x10c5 <ffffffff810533d4>
 => do_fork+0x104/0x286 <ffffffff810544f7>
 => kernel_thread+0x75/0x77 <ffffffff81010bb6>
 => kthreadd+0xe7/0x124 <ffffffff8106f61f>
 => kernel_thread_helper+0x4/0x10 <ffffffff8100a9a4>

2 instances order=1 atomic gfp_flags=GFP_ATOMIC|GFP_NOWARN|GFP_NORETRY|GFP_COMP|
 => __alloc_pages_nodemask+0x737/0x772 <ffffffff810dc0bd>
 => alloc_pages_current+0xbe/0xd8 <ffffffff81105435>
 => alloc_slab_page+0x1c/0x4d <ffffffff8110c5da>
 => new_slab+0x50/0x199 <ffffffff8110dc24>
 => __slab_alloc+0x24a/0x328 <ffffffff8146ab66>
 => kmem_cache_alloc_node+0x93/0x12d <ffffffff8110e199>
 => __alloc_skb+0x40/0x133 <ffffffff813b5df7>
 => find_skb+0x3a/0x82 <ffffffff813d1996>

131 instances order=1 atomic gfp_flags=GFP_ATOMIC|GFP_NOWARN|GFP_NORETRY|GFP_COMP|
 => __alloc_pages_nodemask+0x737/0x772 <ffffffff810dc0bd>
 => alloc_pages_current+0xbe/0xd8 <ffffffff81105435>
 => alloc_slab_page+0x1c/0x4d <ffffffff8110c5da>
 => new_slab+0x50/0x199 <ffffffff8110dc24>
 => __slab_alloc+0x24a/0x328 <ffffffff8146ab66>
 => kmem_cache_alloc+0x77/0x105 <ffffffff8110e42c>
 => scsi_pool_alloc_command+0x29/0x68 <ffffffff812f3047>
 => scsi_host_alloc_command+0x1f/0x6b <ffffffff812f30cd>

6 instances order=1 normal gfp_flags=GFP_TEMPORARY|GFP_NOWARN|GFP_NORETRY|GFP_COMP|
 => __alloc_pages_nodemask+0x737/0x772 <ffffffff810dc0bd>
 => alloc_pages_current+0xbe/0xd8 <ffffffff81105435>
 => alloc_slab_page+0x1c/0x4d <ffffffff8110c5da>
 => new_slab+0x50/0x199 <ffffffff8110dc24>
 => __slab_alloc+0x24a/0x328 <ffffffff8146ab66>
 => kmem_cache_alloc+0x77/0x105 <ffffffff8110e42c>
 => d_alloc+0x26/0x18d <ffffffff8112e4c5>
 => d_alloc_pseudo+0x18/0x46 <ffffffff8112e6a7>

6 instances order=3 normal gfp_flags=GFP_NOWARN|GFP_NORETRY|GFP_COMP|GFP_NOMEMALLOC|
 => __alloc_pages_nodemask+0x737/0x772 <ffffffff810dc0bd>
 => alloc_pages_current+0xbe/0xd8 <ffffffff81105435>
 => alloc_slab_page+0x1c/0x4d <ffffffff8110c5da>
 => new_slab+0x50/0x199 <ffffffff8110dc24>
 => __slab_alloc+0x24a/0x328 <ffffffff8146ab66>
 => kmem_cache_alloc+0x77/0x105 <ffffffff8110e42c>
 => bvec_alloc_bs+0xae/0xcc <ffffffff81144d61>
 => bio_alloc_bioset+0x75/0xc3 <ffffffff81144df4>

11 instances order=3 normal gfp_flags=GFP_KERNEL|GFP_NOWARN|GFP_NORETRY|GFP_COMP|
 => __alloc_pages_nodemask+0x737/0x772 <ffffffff810dc0bd>
 => alloc_pages_current+0xbe/0xd8 <ffffffff81105435>
 => alloc_slab_page+0x1c/0x4d <ffffffff8110c5da>
 => new_slab+0x50/0x199 <ffffffff8110dc24>
 => __slab_alloc+0x24a/0x328 <ffffffff8146ab66>
 => kmem_cache_alloc+0x77/0x105 <ffffffff8110e42c>
 => shmem_alloc_inode+0x1a/0x2f <ffffffff810e58a0>
 => alloc_inode+0x1d/0x78 <ffffffff811317e5>

4 instances order=3 normal gfp_flags=GFP_KERNEL|GFP_NOWARN|GFP_NORETRY|GFP_COMP|
 => __alloc_pages_nodemask+0x737/0x772 <ffffffff810dc0bd>
 => alloc_pages_current+0xbe/0xd8 <ffffffff81105435>
 => alloc_slab_page+0x1c/0x4d <ffffffff8110c5da>
 => new_slab+0x50/0x199 <ffffffff8110dc24>
 => __slab_alloc+0x24a/0x328 <ffffffff8146ab66>
 => __kmalloc+0xb1/0x10d <ffffffff8110dfbb>
 => drm_malloc_ab+0x3b/0x53 [i915] <ffffffffa007fbd2>
 => i915_gem_do_execbuffer+0x64a/0x1116 [i915] <ffffffffa0080249>

680 instances order=3 atomic gfp_flags=GFP_ATOMIC|GFP_NOWARN|GFP_NORETRY|GFP_COMP|GFP_NOMEMALLOC|
 => __alloc_pages_nodemask+0x737/0x772 <ffffffff810dc0bd>
 => alloc_pages_current+0xbe/0xd8 <ffffffff81105435>
 => alloc_slab_page+0x1c/0x4d <ffffffff8110c5da>
 => new_slab+0x50/0x199 <ffffffff8110dc24>
 => __slab_alloc+0x24a/0x328 <ffffffff8146ab66>
 => kmem_cache_alloc+0x77/0x105 <ffffffff8110e42c>
 => mempool_alloc_slab+0x15/0x17 <ffffffff810d6e81>
 => mempool_alloc+0x68/0x116 <ffffffff810d70f6>

8 instances order=3 normal gfp_flags=GFP_KERNEL|GFP_NOWARN|GFP_NORETRY|GFP_COMP|
 => __alloc_pages_nodemask+0x737/0x772 <ffffffff810dc0bd>
 => alloc_pages_current+0xbe/0xd8 <ffffffff81105435>
 => alloc_slab_page+0x1c/0x4d <ffffffff8110c5da>
 => new_slab+0x50/0x199 <ffffffff8110dc24>
 => __slab_alloc+0x24a/0x328 <ffffffff8146ab66>
 => kmem_cache_alloc+0x77/0x105 <ffffffff8110e42c>
 => copy_process+0xc6/0x10c5 <ffffffff810533b9>
 => do_fork+0x104/0x286 <ffffffff810544f7>

4 instances order=9 normal gfp_flags=GFP_HIGHUSER_MOVABLE|GFP_NOWARN|GFP_NORETRY|GFP_COMP|GFP_NOMEMALLOC|
 => __alloc_pages_nodemask+0x737/0x772 <ffffffff810dc0bd>
 => alloc_pages_vma+0xf5/0xfa <ffffffff81107001>
 => do_huge_pmd_wp_page+0x15a/0x637 <ffffffff81114a01>
 => handle_mm_fault+0x169/0x1ce <ffffffff810f1746>
 => do_page_fault+0x358/0x37a <ffffffff8147416e>
 => page_fault+0x25/0x30 <ffffffff81471415>

193 instances order=2 normal gfp_flags=GFP_NOWARN|GFP_NORETRY|GFP_COMP|GFP_NOMEMALLOC|
 => __alloc_pages_nodemask+0x737/0x772 <ffffffff810dc0bd>
 => alloc_pages_current+0xbe/0xd8 <ffffffff81105435>
 => alloc_slab_page+0x1c/0x4d <ffffffff8110c5da>
 => new_slab+0x50/0x199 <ffffffff8110dc24>
 => __slab_alloc+0x24a/0x328 <ffffffff8146ab66>
 => kmem_cache_alloc+0x77/0x105 <ffffffff8110e42c>
 => mempool_alloc_slab+0x15/0x17 <ffffffff810d6e81>
 => mempool_alloc+0x68/0x116 <ffffffff810d70f6>

140358 instances order=1 normal gfp_flags=GFP_NOWARN|GFP_NORETRY|GFP_COMP|GFP_NOMEMALLOC|
 => __alloc_pages_nodemask+0x737/0x772 <ffffffff810dc0bd>
 => alloc_pages_current+0xbe/0xd8 <ffffffff81105435>
 => alloc_slab_page+0x1c/0x4d <ffffffff8110c5da>
 => new_slab+0x50/0x199 <ffffffff8110dc24>
 => __slab_alloc+0x24a/0x328 <ffffffff8146ab66>
 => kmem_cache_alloc+0x77/0x105 <ffffffff8110e42c>
 => mempool_alloc_slab+0x15/0x17 <ffffffff810d6e81>
 => mempool_alloc+0x68/0x116 <ffffffff810d70f6>

3 instances order=2 normal gfp_flags=GFP_KERNEL|GFP_NOWARN|GFP_REPEAT|GFP_NORETRY|GFP_COMP|
 => __alloc_pages_nodemask+0x737/0x772 <ffffffff810dc0bd>
 => alloc_pages_current+0xbe/0xd8 <ffffffff81105435>
 => alloc_slab_page+0x1c/0x4d <ffffffff8110c5da>
 => new_slab+0x50/0x199 <ffffffff8110dc24>
 => __slab_alloc+0x24a/0x328 <ffffffff8146ab66>
 => __kmalloc_node_track_caller+0xcf/0x131 <ffffffff8110ffa6>
 => __alloc_skb+0x75/0x133 <ffffffff813b5e2c>
 => sock_alloc_send_pskb+0xb4/0x2d7 <ffffffff813b238a>

17 instances order=1 normal gfp_flags=GFP_NOWARN|GFP_NORETRY|GFP_COMP|GFP_NOMEMALLOC|
 => __alloc_pages_nodemask+0x737/0x772 <ffffffff810dc0bd>
 => alloc_pages_current+0xbe/0xd8 <ffffffff81105435>
 => __page_cache_alloc+0x77/0x7e <ffffffff810d5778>
 => __do_page_cache_readahead+0x9b/0x177 <ffffffff810dd74b>
 => ra_submit+0x21/0x25 <ffffffff810dda8d>
 => ondemand_readahead+0x1c9/0x1d8 <ffffffff810ddc5a>
 => page_cache_async_readahead+0x7b/0xa3 <ffffffff810ddce4>
 => generic_file_aio_read+0x2bd/0x5e0 <ffffffff810d6510>

9 instances order=2 normal gfp_flags=GFP_KERNEL|GFP_NOWARN|GFP_NORETRY|GFP_COMP|
 => __alloc_pages_nodemask+0x737/0x772 <ffffffff810dc0bd>
 => alloc_pages_current+0xbe/0xd8 <ffffffff81105435>
 => alloc_slab_page+0x1c/0x4d <ffffffff8110c5da>
 => new_slab+0x50/0x199 <ffffffff8110dc24>
 => __slab_alloc+0x24a/0x328 <ffffffff8146ab66>
 => __kmalloc+0xb1/0x10d <ffffffff8110dfbb>
 => kzalloc.constprop.15+0x13/0x15 [i915] <ffffffffa007a956>
 => i915_gem_alloc_object+0x27/0x111 [i915] <ffffffffa007e4b3>

14 instances order=1 normal gfp_flags=GFP_KERNEL|GFP_NOWARN|GFP_NORETRY|GFP_COMP|
 => __alloc_pages_nodemask+0x737/0x772 <ffffffff810dc0bd>
 => alloc_pages_current+0xbe/0xd8 <ffffffff81105435>
 => alloc_slab_page+0x1c/0x4d <ffffffff8110c5da>
 => new_slab+0x50/0x199 <ffffffff8110dc24>
 => __slab_alloc+0x24a/0x328 <ffffffff8146ab66>
 => kmem_cache_alloc+0x77/0x105 <ffffffff8110e42c>
 => get_empty_filp+0x7a/0x141 <ffffffff8111f2d1>
 => alloc_file+0x1e/0xbf <ffffffff8111f3b6>

1 instances order=2 normal gfp_flags=GFP_KERNEL|GFP_COMP|GFP_ZERO
 => __alloc_pages_nodemask+0x737/0x772 <ffffffff810dc0bd>
 => alloc_pages_current+0xbe/0xd8 <ffffffff81105435>
 => __get_free_pages+0xe/0x4a <ffffffff810d89d2>
 => kmalloc_order_trace+0x2c/0x5e <ffffffff8110c718>
 => __kmalloc+0x37/0x10d <ffffffff8110df41>
 => kzalloc.constprop.19+0xe/0x10 <ffffffff810b8d8c>
 => tracing_open_pipe+0x40/0x147 <ffffffff810b907a>
 => __dentry_open+0x161/0x283 <ffffffff8111c95c>

High-order normal allocations: 145450
High-order atomic allocations: 927
 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
