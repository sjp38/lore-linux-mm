Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 2519290010C
	for <linux-mm@kvack.org>; Tue, 10 May 2011 11:57:39 -0400 (EDT)
Subject: Re: [BUG] fatal hang untarring 90GB file, possibly writeback
 related.
From: James Bottomley <James.Bottomley@HansenPartnership.com>
In-Reply-To: <1305041397.6737.12.camel@mulgrave.site>
References: <1304025145.2598.24.camel@mulgrave.site>
	 <1304030629.2598.42.camel@mulgrave.site> <20110503091320.GA4542@novell.com>
	 <1304431982.2576.5.camel@mulgrave.site>
	 <1304432553.2576.10.camel@mulgrave.site> <20110506074224.GB6591@suse.de>
	 <20110506080728.GC6591@suse.de> <1304964980.4865.53.camel@mulgrave.site>
	 <20110510102141.GA4149@novell.com> <1305036064.6737.8.camel@mulgrave.site>
	 <20110510143509.GD4146@suse.de>  <1305041397.6737.12.camel@mulgrave.site>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 10 May 2011 15:57:32 +0000
Message-ID: <1305043052.6737.17.camel@mulgrave.site>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Mel Gorman <mgorman@novell.com>, Jan Kara <jack@suse.cz>, colin.king@canonical.com, Chris Mason <chris.mason@oracle.com>, linux-fsdevel <linux-fsdevel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>, linux-ext4 <linux-ext4@vger.kernel.org>

On Tue, 2011-05-10 at 10:29 -0500, James Bottomley wrote:
> On Tue, 2011-05-10 at 15:35 +0100, Mel Gorman wrote:
> > On Tue, May 10, 2011 at 09:01:04AM -0500, James Bottomley wrote:
> > > On Tue, 2011-05-10 at 11:21 +0100, Mel Gorman wrote:
> > > > I really would like to hear if the fix makes a big difference or
> > > > if we need to consider forcing SLUB high-order allocations bailing
> > > > at the first sign of trouble (e.g. by masking out __GFP_WAIT in
> > > > allocate_slab). Even with the fix applied, kswapd might be waking up
> > > > less but processes will still be getting stalled in direct compaction
> > > > and direct reclaim so it would still be jittery.
> > > 
> > > "the fix" being this
> > > 
> > > https://lkml.org/lkml/2011/3/5/121
> > > 
> > 
> > Drop this for the moment. It was a long shot at best and there is little
> > evidence the problem is in this area.
> > 
> > I'm attaching two patches. The first is the NO_KSWAPD one to stop
> > kswapd being woken up by SLUB using speculative high-orders. The second
> > one is more drastic and prevents slub entering direct reclaim or
> > compaction. It applies on top of patch 1. These are both untested and
> > afraid are a bit rushed as well :(
> 
> Preliminary results with both patches applied still show kswapd
> periodically going up to 99% but it doesn't stay there, it comes back
> down again (and, obviously, the system doesn't hang).

This is a second run with the watch highorders.

At the end of the run, the system hung temporarily and now comes back
with CPU3 spinning in all system time at kswapd shrink_slab

James

---

97 instances order=1 atomic gfp_flags=GFP_ATOMIC|GFP_NOWARN|GFP_NORETRY|GFP_COMP|
 => __alloc_pages_nodemask+0x754/0x792 <ffffffff810dc0da>
 => alloc_pages_current+0xbe/0xd8 <ffffffff81105455>
 => alloc_slab_page+0x1c/0x4d <ffffffff8110c5fa>
 => new_slab+0x50/0x199 <ffffffff8110dc44>
 => __slab_alloc+0x24a/0x328 <ffffffff8146ab86>
 => kmem_cache_alloc+0x77/0x105 <ffffffff8110e44c>
 => scsi_pool_alloc_command+0x29/0x68 <ffffffff812f3063>
 => scsi_host_alloc_command+0x1f/0x6b <ffffffff812f30e9>

127 instances order=1 normal gfp_flags=GFP_KERNEL
 => __alloc_pages_nodemask+0x754/0x792 <ffffffff810dc0da>
 => alloc_pages_current+0xbe/0xd8 <ffffffff81105455>
 => __get_free_pages+0xe/0x4a <ffffffff810d89d2>
 => copy_process+0xe1/0x10c5 <ffffffff810533d4>
 => do_fork+0x104/0x286 <ffffffff810544f7>
 => sys_clone+0x28/0x2a <ffffffff8101150e>
 => stub_clone+0x13/0x20 <ffffffff81009ea3>

2 instances order=3 normal gfp_flags=GFP_NOWARN|GFP_NORETRY|GFP_COMP|GFP_NOMEMALLOC|
 => __alloc_pages_nodemask+0x754/0x792 <ffffffff810dc0da>
 => alloc_pages_current+0xbe/0xd8 <ffffffff81105455>
 => alloc_slab_page+0x1c/0x4d <ffffffff8110c5fa>
 => new_slab+0x50/0x199 <ffffffff8110dc44>
 => __slab_alloc+0x24a/0x328 <ffffffff8146ab86>
 => kmem_cache_alloc+0x77/0x105 <ffffffff8110e44c>
 => bvec_alloc_bs+0xae/0xcc <ffffffff81144d81>
 => bio_alloc_bioset+0x75/0xc3 <ffffffff81144e14>

47 instances order=2 normal gfp_flags=GFP_IO|GFP_NOWARN|GFP_NORETRY|GFP_COMP|GFP_RECLAIMABLE|
 => __alloc_pages_nodemask+0x754/0x792 <ffffffff810dc0da>
 => alloc_pages_current+0xbe/0xd8 <ffffffff81105455>
 => alloc_slab_page+0x1c/0x4d <ffffffff8110c5fa>
 => new_slab+0x50/0x199 <ffffffff8110dc44>
 => __slab_alloc+0x24a/0x328 <ffffffff8146ab86>
 => kmem_cache_alloc+0x77/0x105 <ffffffff8110e44c>
 => radix_tree_preload+0x31/0x81 <ffffffff812293b9>
 => add_to_page_cache_locked+0x56/0x118 <ffffffff810d57d5>

1 instances order=1 normal gfp_flags=GFP_IO|GFP_NOWARN|GFP_NORETRY|GFP_COMP|
 => __alloc_pages_nodemask+0x754/0x792 <ffffffff810dc0da>
 => alloc_pages_current+0xbe/0xd8 <ffffffff81105455>
 => alloc_slab_page+0x1c/0x4d <ffffffff8110c5fa>
 => new_slab+0x50/0x199 <ffffffff8110dc44>
 => __slab_alloc+0x24a/0x328 <ffffffff8146ab86>
 => kmem_cache_alloc_trace+0x7b/0xd8 <ffffffff8110e2ce>
 => inode_doinit_with_dentry+0x124/0x45c <ffffffff811e96db>
 => selinux_d_instantiate+0x1c/0x1e <ffffffff811e9a2f>

3 instances order=2 normal gfp_flags=GFP_IO|GFP_NOWARN|GFP_NORETRY|GFP_COMP|
 => __alloc_pages_nodemask+0x754/0x792 <ffffffff810dc0da>
 => alloc_pages_current+0xbe/0xd8 <ffffffff81105455>
 => alloc_slab_page+0x1c/0x4d <ffffffff8110c5fa>
 => new_slab+0x50/0x199 <ffffffff8110dc44>
 => __slab_alloc+0x24a/0x328 <ffffffff8146ab86>
 => __kmalloc+0xb1/0x10d <ffffffff8110dfdb>
 => kzalloc.constprop.15+0x13/0x15 [i915] <ffffffffa007a956>
 => i915_gem_alloc_object+0x27/0x111 [i915] <ffffffffa007e4b3>

4 instances order=1 normal gfp_flags=GFP_IO|GFP_NOWARN|GFP_NORETRY|GFP_COMP|
 => __alloc_pages_nodemask+0x754/0x792 <ffffffff810dc0da>
 => alloc_pages_current+0xbe/0xd8 <ffffffff81105455>
 => alloc_slab_page+0x1c/0x4d <ffffffff8110c5fa>
 => new_slab+0x50/0x199 <ffffffff8110dc44>
 => __slab_alloc+0x24a/0x328 <ffffffff8146ab86>
 => kmem_cache_alloc+0x77/0x105 <ffffffff8110e44c>
 => mmap_region+0x1b7/0x446 <ffffffff810f6575>
 => do_mmap_pgoff+0x298/0x2f2 <ffffffff810f6a9c>

27 instances order=1 normal gfp_flags=GFP_NOWARN|GFP_NORETRY|GFP_COMP|GFP_NOMEMALLOC|
 => __alloc_pages_nodemask+0x754/0x792 <ffffffff810dc0da>
 => alloc_pages_current+0xbe/0xd8 <ffffffff81105455>
 => __page_cache_alloc+0x77/0x7e <ffffffff810d5778>
 => __do_page_cache_readahead+0x9b/0x177 <ffffffff810dd76b>
 => ra_submit+0x21/0x25 <ffffffff810ddaad>
 => ondemand_readahead+0x1c9/0x1d8 <ffffffff810ddc7a>
 => page_cache_async_readahead+0x7b/0xa3 <ffffffff810ddd04>
 => generic_file_aio_read+0x2bd/0x5e0 <ffffffff810d6510>

159 instances order=2 normal gfp_flags=GFP_NOWARN|GFP_NORETRY|GFP_COMP|GFP_NOMEMALLOC|
 => __alloc_pages_nodemask+0x754/0x792 <ffffffff810dc0da>
 => alloc_pages_current+0xbe/0xd8 <ffffffff81105455>
 => alloc_slab_page+0x1c/0x4d <ffffffff8110c5fa>
 => new_slab+0x50/0x199 <ffffffff8110dc44>
 => __slab_alloc+0x24a/0x328 <ffffffff8146ab86>
 => kmem_cache_alloc+0x77/0x105 <ffffffff8110e44c>
 => mempool_alloc_slab+0x15/0x17 <ffffffff810d6e81>
 => mempool_alloc+0x68/0x116 <ffffffff810d70f6>

446 instances order=1 normal gfp_flags=GFP_IO|GFP_NOWARN|GFP_NORETRY|GFP_COMP|
 => __alloc_pages_nodemask+0x754/0x792 <ffffffff810dc0da>
 => alloc_pages_current+0xbe/0xd8 <ffffffff81105455>
 => alloc_slab_page+0x1c/0x4d <ffffffff8110c5fa>
 => new_slab+0x50/0x199 <ffffffff8110dc44>
 => __slab_alloc+0x24a/0x328 <ffffffff8146ab86>
 => kmem_cache_alloc+0x77/0x105 <ffffffff8110e44c>
 => get_empty_filp+0x7a/0x141 <ffffffff8111f2f1>
 => do_filp_open+0xe7/0x60a <ffffffff81129bef>

1 instances order=3 normal gfp_flags=GFP_IO|GFP_NOWARN|GFP_NORETRY|GFP_COMP|
 => __alloc_pages_nodemask+0x754/0x792 <ffffffff810dc0da>
 => alloc_pages_current+0xbe/0xd8 <ffffffff81105455>
 => alloc_slab_page+0x1c/0x4d <ffffffff8110c5fa>
 => new_slab+0x50/0x199 <ffffffff8110dc44>
 => __slab_alloc+0x24a/0x328 <ffffffff8146ab86>
 => kmem_cache_alloc+0x77/0x105 <ffffffff8110e44c>
 => arch_dup_task_struct+0x42/0x8b <ffffffff81010f47>
 => copy_process+0xf9/0x10c5 <ffffffff810533ec>

1 instances order=3 normal gfp_flags=GFP_IO|GFP_NOWARN|GFP_NORETRY|GFP_COMP|
 => __alloc_pages_nodemask+0x754/0x792 <ffffffff810dc0da>
 => alloc_pages_current+0xbe/0xd8 <ffffffff81105455>
 => alloc_slab_page+0x1c/0x4d <ffffffff8110c5fa>
 => new_slab+0x50/0x199 <ffffffff8110dc44>
 => __slab_alloc+0x24a/0x328 <ffffffff8146ab86>
 => __kmalloc_node_track_caller+0xcf/0x131 <ffffffff8110ffc6>
 => __alloc_skb+0x75/0x133 <ffffffff813b5e4c>
 => sk_stream_alloc_skb+0x38/0xd3 <ffffffff813fc5a9>

1 instances order=1 atomic gfp_flags=GFP_ATOMIC|GFP_NOWARN|GFP_NORETRY|GFP_COMP|GFP_NOMEMALLOC|
 => __alloc_pages_nodemask+0x754/0x792 <ffffffff810dc0da>
 => alloc_pages_current+0xbe/0xd8 <ffffffff81105455>
 => __page_cache_alloc+0x77/0x7e <ffffffff810d5778>
 => grab_cache_page_write_begin+0x54/0x9e <ffffffff810d5943>
 => ext4_da_write_begin+0x13f/0x20e <ffffffff81196396>
 => generic_file_buffered_write+0x109/0x23a <ffffffff810d5408>
 => __generic_file_aio_write+0x242/0x272 <ffffffff810d617d>
 => generic_file_aio_write+0x58/0xa6 <ffffffff810d6205>

25 instances order=1 normal gfp_flags=GFP_IO|GFP_NOWARN|GFP_NORETRY|GFP_COMP|
 => __alloc_pages_nodemask+0x754/0x792 <ffffffff810dc0da>
 => alloc_pages_current+0xbe/0xd8 <ffffffff81105455>
 => alloc_slab_page+0x1c/0x4d <ffffffff8110c5fa>
 => new_slab+0x50/0x199 <ffffffff8110dc44>
 => __slab_alloc+0x24a/0x328 <ffffffff8146ab86>
 => kmem_cache_alloc+0x77/0x105 <ffffffff8110e44c>
 => get_empty_filp+0x7a/0x141 <ffffffff8111f2f1>
 => alloc_file+0x1e/0xbf <ffffffff8111f3d6>

115 instances order=1 normal gfp_flags=GFP_NOWARN|GFP_NORETRY|GFP_COMP|GFP_NOMEMALLOC|
 => __alloc_pages_nodemask+0x754/0x792 <ffffffff810dc0da>
 => alloc_pages_current+0xbe/0xd8 <ffffffff81105455>
 => alloc_slab_page+0x1c/0x4d <ffffffff8110c5fa>
 => new_slab+0x50/0x199 <ffffffff8110dc44>
 => __slab_alloc+0x24a/0x328 <ffffffff8146ab86>
 => kmem_cache_alloc+0x77/0x105 <ffffffff8110e44c>
 => bvec_alloc_bs+0xae/0xcc <ffffffff81144d81>
 => bio_alloc_bioset+0x75/0xc3 <ffffffff81144e14>

56 instances order=1 normal gfp_flags=GFP_IO|GFP_NOWARN|GFP_NORETRY|GFP_COMP|GFP_RECLAIMABLE|
 => __alloc_pages_nodemask+0x754/0x792 <ffffffff810dc0da>
 => alloc_pages_current+0xbe/0xd8 <ffffffff81105455>
 => alloc_slab_page+0x1c/0x4d <ffffffff8110c5fa>
 => new_slab+0x50/0x199 <ffffffff8110dc44>
 => __slab_alloc+0x24a/0x328 <ffffffff8146ab86>
 => kmem_cache_alloc+0x77/0x105 <ffffffff8110e44c>
 => d_alloc+0x26/0x18d <ffffffff8112e4e5>
 => d_alloc_and_lookup+0x2c/0x6b <ffffffff81126d2e>

1 instances order=1 normal gfp_flags=GFP_NOWARN|GFP_NORETRY|GFP_COMP|GFP_NOMEMALLOC|
 => __alloc_pages_nodemask+0x754/0x792 <ffffffff810dc0da>
 => alloc_pages_current+0xbe/0xd8 <ffffffff81105455>
 => alloc_slab_page+0x1c/0x4d <ffffffff8110c5fa>
 => new_slab+0x50/0x199 <ffffffff8110dc44>
 => __slab_alloc+0x24a/0x328 <ffffffff8146ab86>
 => kmem_cache_alloc+0x77/0x105 <ffffffff8110e44c>
 => alloc_buffer_head+0x21/0x49 <ffffffff81141405>
 => alloc_page_buffers+0x32/0xce <ffffffff81141533>

9 instances order=9 normal gfp_flags=GFP_HIGHUSER_MOVABLE|GFP_NOWARN|GFP_NORETRY|GFP_COMP|GFP_NOMEMALLOC|
 => __alloc_pages_nodemask+0x754/0x792 <ffffffff810dc0da>
 => alloc_pages_vma+0xf5/0xfa <ffffffff81107021>
 => khugepaged+0x543/0xf2d <ffffffff81113ce1>
 => kthread+0x84/0x8c <ffffffff8106f2df>
 => kernel_thread_helper+0x4/0x10 <ffffffff8100a9a4>

347 instances order=3 normal gfp_flags=GFP_IO|GFP_NOWARN|GFP_NORETRY|GFP_COMP|GFP_RECLAIMABLE|
 => __alloc_pages_nodemask+0x754/0x792 <ffffffff810dc0da>
 => alloc_pages_current+0xbe/0xd8 <ffffffff81105455>
 => alloc_slab_page+0x1c/0x4d <ffffffff8110c5fa>
 => new_slab+0x50/0x199 <ffffffff8110dc44>
 => __slab_alloc+0x24a/0x328 <ffffffff8146ab86>
 => kmem_cache_alloc+0x77/0x105 <ffffffff8110e44c>
 => ext4_alloc_inode+0x1a/0x111 <ffffffff8119f4b8>
 => alloc_inode+0x1d/0x78 <ffffffff81131805>

56 instances order=1 normal gfp_flags=GFP_NOWARN|GFP_NORETRY|GFP_COMP|GFP_NOMEMALLOC|
 => __alloc_pages_nodemask+0x754/0x792 <ffffffff810dc0da>
 => alloc_pages_current+0xbe/0xd8 <ffffffff81105455>
 => __page_cache_alloc+0x77/0x7e <ffffffff810d5778>
 => grab_cache_page_write_begin+0x54/0x9e <ffffffff810d5943>
 => ext4_da_write_begin+0x13f/0x20e <ffffffff81196396>
 => generic_file_buffered_write+0x109/0x23a <ffffffff810d5408>
 => __generic_file_aio_write+0x242/0x272 <ffffffff810d617d>
 => generic_file_aio_write+0x58/0xa6 <ffffffff810d6205>

60 instances order=1 normal gfp_flags=GFP_IO|GFP_NOWARN|GFP_NORETRY|GFP_COMP|
 => __alloc_pages_nodemask+0x754/0x792 <ffffffff810dc0da>
 => alloc_pages_current+0xbe/0xd8 <ffffffff81105455>
 => alloc_slab_page+0x1c/0x4d <ffffffff8110c5fa>
 => new_slab+0x50/0x199 <ffffffff8110dc44>
 => __slab_alloc+0x24a/0x328 <ffffffff8146ab86>
 => kmem_cache_alloc+0x77/0x105 <ffffffff8110e44c>
 => dup_mm+0x1f8/0x486 <ffffffff81053039>
 => copy_process+0x917/0x10c5 <ffffffff81053c0a>

1 instances order=1 normal gfp_flags=GFP_IO|GFP_NOWARN|GFP_NORETRY|GFP_COMP|
 => __alloc_pages_nodemask+0x754/0x792 <ffffffff810dc0da>
 => alloc_pages_current+0xbe/0xd8 <ffffffff81105455>
 => alloc_slab_page+0x1c/0x4d <ffffffff8110c5fa>
 => new_slab+0x50/0x199 <ffffffff8110dc44>
 => __slab_alloc+0x24a/0x328 <ffffffff8146ab86>
 => kmem_cache_alloc+0x77/0x105 <ffffffff8110e44c>
 => bprm_mm_init+0x70/0x1a0 <ffffffff811239ca>
 => do_execve+0xd6/0x277 <ffffffff81123df4>

6 instances order=9 normal gfp_flags=GFP_HIGHUSER_MOVABLE|GFP_NOWARN|GFP_NORETRY|GFP_COMP|GFP_NOMEMALLOC|
 => __alloc_pages_nodemask+0x754/0x792 <ffffffff810dc0da>
 => alloc_pages_vma+0xf5/0xfa <ffffffff81107021>
 => do_huge_pmd_anonymous_page+0xbf/0x261 <ffffffff81115b8a>
 => handle_mm_fault+0x113/0x1ce <ffffffff810f1710>
 => do_page_fault+0x358/0x37a <ffffffff814741ae>
 => page_fault+0x25/0x30 <ffffffff81471455>

6 instances order=3 normal gfp_flags=GFP_IO|GFP_NOWARN|GFP_REPEAT|GFP_NORETRY|GFP_COMP|
 => __alloc_pages_nodemask+0x754/0x792 <ffffffff810dc0da>
 => alloc_pages_current+0xbe/0xd8 <ffffffff81105455>
 => alloc_slab_page+0x1c/0x4d <ffffffff8110c5fa>
 => new_slab+0x50/0x199 <ffffffff8110dc44>
 => __slab_alloc+0x24a/0x328 <ffffffff8146ab86>
 => __kmalloc_node_track_caller+0xcf/0x131 <ffffffff8110ffc6>
 => __alloc_skb+0x75/0x133 <ffffffff813b5e4c>
 => sock_alloc_send_pskb+0xb4/0x2d7 <ffffffff813b23aa>

2 instances order=1 normal gfp_flags=GFP_IO|GFP_NOWARN|GFP_NORETRY|GFP_COMP|
 => __alloc_pages_nodemask+0x754/0x792 <ffffffff810dc0da>
 => alloc_pages_current+0xbe/0xd8 <ffffffff81105455>
 => alloc_slab_page+0x1c/0x4d <ffffffff8110c5fa>
 => new_slab+0x50/0x199 <ffffffff8110dc44>
 => __slab_alloc+0x24a/0x328 <ffffffff8146ab86>
 => kmem_cache_alloc+0x77/0x105 <ffffffff8110e44c>
 => do_brk+0x1cd/0x293 <ffffffff810f5fd8>
 => load_elf_binary+0xd2d/0x175f <ffffffff8115ccf2>

4 instances order=1 normal gfp_flags=GFP_KERNEL
 => __alloc_pages_nodemask+0x754/0x792 <ffffffff810dc0da>
 => alloc_pages_current+0xbe/0xd8 <ffffffff81105455>
 => __get_free_pages+0xe/0x4a <ffffffff810d89d2>
 => copy_process+0xe1/0x10c5 <ffffffff810533d4>
 => do_fork+0x104/0x286 <ffffffff810544f7>
 => kernel_thread+0x75/0x77 <ffffffff81010bb6>
 => kthreadd+0xe7/0x124 <ffffffff8106f61f>
 => kernel_thread_helper+0x4/0x10 <ffffffff8100a9a4>

4 instances order=1 normal gfp_flags=GFP_IO|GFP_NOWARN|GFP_REPEAT|GFP_NORETRY|GFP_COMP|
 => __alloc_pages_nodemask+0x754/0x792 <ffffffff810dc0da>
 => alloc_pages_current+0xbe/0xd8 <ffffffff81105455>
 => alloc_slab_page+0x1c/0x4d <ffffffff8110c5fa>
 => new_slab+0x50/0x199 <ffffffff8110dc44>
 => __slab_alloc+0x24a/0x328 <ffffffff8146ab86>
 => kmem_cache_alloc_node+0x93/0x12d <ffffffff8110e1b9>
 => __alloc_skb+0x40/0x133 <ffffffff813b5e17>
 => sock_alloc_send_pskb+0xb4/0x2d7 <ffffffff813b23aa>

534 instances order=2 normal gfp_flags=GFP_KERNEL|GFP_REPEAT|GFP_COMP
 => __alloc_pages_nodemask+0x754/0x792 <ffffffff810dc0da>
 => kmalloc_large_node+0x56/0x95 <ffffffff8146a57d>
 => __kmalloc_node_track_caller+0x31/0x131 <ffffffff8110ff28>
 => __alloc_skb+0x75/0x133 <ffffffff813b5e4c>
 => sock_alloc_send_pskb+0xb4/0x2d7 <ffffffff813b23aa>
 => sock_alloc_send_skb+0x15/0x17 <ffffffff813b25e2>
 => unix_stream_sendmsg+0x11e/0x2ec <ffffffff8143d237>
 => __sock_sendmsg+0x69/0x76 <ffffffff813af798>

1 instances order=2 normal gfp_flags=GFP_KERNEL|GFP_COMP|GFP_ZERO
 => __alloc_pages_nodemask+0x754/0x792 <ffffffff810dc0da>
 => alloc_pages_current+0xbe/0xd8 <ffffffff81105455>
 => __get_free_pages+0xe/0x4a <ffffffff810d89d2>
 => kmalloc_order_trace+0x2c/0x5e <ffffffff8110c738>
 => __kmalloc+0x37/0x10d <ffffffff8110df61>
 => kzalloc.constprop.19+0xe/0x10 <ffffffff810b8d8c>
 => tracing_open_pipe+0x40/0x147 <ffffffff810b907a>
 => __dentry_open+0x161/0x283 <ffffffff8111c97c>

1 instances order=1 normal gfp_flags=GFP_NOWARN|GFP_NORETRY|GFP_COMP|GFP_NOMEMALLOC|
 => __alloc_pages_nodemask+0x754/0x792 <ffffffff810dc0da>
 => alloc_pages_current+0xbe/0xd8 <ffffffff81105455>
 => __page_cache_alloc+0x77/0x7e <ffffffff810d5778>
 => __do_page_cache_readahead+0x9b/0x177 <ffffffff810dd76b>
 => ra_submit+0x21/0x25 <ffffffff810ddaad>
 => filemap_fault+0x17b/0x36c <ffffffff810d6ada>
 => __do_fault+0x55/0x377 <ffffffff810ee887>
 => handle_pte_fault+0x2a7/0x7a5 <ffffffff810f0f43>

55 instances order=1 atomic gfp_flags=GFP_ATOMIC|GFP_NOWARN|GFP_NORETRY|GFP_COMP|GFP_NOMEMALLOC|
 => __alloc_pages_nodemask+0x754/0x792 <ffffffff810dc0da>
 => alloc_pages_current+0xbe/0xd8 <ffffffff81105455>
 => alloc_slab_page+0x1c/0x4d <ffffffff8110c5fa>
 => new_slab+0x50/0x199 <ffffffff8110dc44>
 => __slab_alloc+0x24a/0x328 <ffffffff8146ab86>
 => kmem_cache_alloc+0x77/0x105 <ffffffff8110e44c>
 => mempool_alloc_slab+0x15/0x17 <ffffffff810d6e81>
 => mempool_alloc+0x68/0x116 <ffffffff810d70f6>

8 instances order=3 normal gfp_flags=GFP_IO|GFP_NOWARN|GFP_NORETRY|GFP_COMP|
 => __alloc_pages_nodemask+0x754/0x792 <ffffffff810dc0da>
 => alloc_pages_current+0xbe/0xd8 <ffffffff81105455>
 => alloc_slab_page+0x1c/0x4d <ffffffff8110c5fa>
 => new_slab+0x50/0x199 <ffffffff8110dc44>
 => __slab_alloc+0x24a/0x328 <ffffffff8146ab86>
 => kmem_cache_alloc+0x77/0x105 <ffffffff8110e44c>
 => shmem_alloc_inode+0x1a/0x2f <ffffffff810e58c0>
 => alloc_inode+0x1d/0x78 <ffffffff81131805>

563 instances order=3 atomic gfp_flags=GFP_ATOMIC|GFP_NOWARN|GFP_NORETRY|GFP_COMP|GFP_NOMEMALLOC|
 => __alloc_pages_nodemask+0x754/0x792 <ffffffff810dc0da>
 => alloc_pages_current+0xbe/0xd8 <ffffffff81105455>
 => alloc_slab_page+0x1c/0x4d <ffffffff8110c5fa>
 => new_slab+0x50/0x199 <ffffffff8110dc44>
 => __slab_alloc+0x24a/0x328 <ffffffff8146ab86>
 => kmem_cache_alloc+0x77/0x105 <ffffffff8110e44c>
 => mempool_alloc_slab+0x15/0x17 <ffffffff810d6e81>
 => mempool_alloc+0x68/0x116 <ffffffff810d70f6>

12 instances order=1 normal gfp_flags=GFP_IO|GFP_NOWARN|GFP_NORETRY|GFP_COMP|
 => __alloc_pages_nodemask+0x754/0x792 <ffffffff810dc0da>
 => alloc_pages_current+0xbe/0xd8 <ffffffff81105455>
 => alloc_slab_page+0x1c/0x4d <ffffffff8110c5fa>
 => new_slab+0x50/0x199 <ffffffff8110dc44>
 => __slab_alloc+0x24a/0x328 <ffffffff8146ab86>
 => kmem_cache_alloc+0x77/0x105 <ffffffff8110e44c>
 => __split_vma+0x6c/0x21b <ffffffff810f50b9>
 => split_vma+0x20/0x22 <ffffffff810f59c6>

5 instances order=2 normal gfp_flags=GFP_IO|GFP_NOWARN|GFP_REPEAT|GFP_NORETRY|GFP_COMP|
 => __alloc_pages_nodemask+0x754/0x792 <ffffffff810dc0da>
 => alloc_pages_current+0xbe/0xd8 <ffffffff81105455>
 => alloc_slab_page+0x1c/0x4d <ffffffff8110c5fa>
 => new_slab+0x50/0x199 <ffffffff8110dc44>
 => __slab_alloc+0x24a/0x328 <ffffffff8146ab86>
 => __kmalloc_node_track_caller+0xcf/0x131 <ffffffff8110ffc6>
 => __alloc_skb+0x75/0x133 <ffffffff813b5e4c>
 => sock_alloc_send_pskb+0xb4/0x2d7 <ffffffff813b23aa>

1 instances order=1 normal gfp_flags=GFP_NOWARN|GFP_NORETRY|GFP_COMP|GFP_NOMEMALLOC|
 => __alloc_pages_nodemask+0x754/0x792 <ffffffff810dc0da>
 => alloc_pages_current+0xbe/0xd8 <ffffffff81105455>
 => __get_free_pages+0xe/0x4a <ffffffff810d89d2>
 => __pollwait+0x5e/0xcc <ffffffff8112ca07>
 => sock_poll_wait+0x18/0x1d <ffffffff8143cc70>
 => unix_poll+0x1c/0x9a <ffffffff8143cc91>
 => sock_poll+0x1a/0x1c <ffffffff813ad43a>
 => do_select+0x2fb/0x4f5 <ffffffff8112cf33>

145216 instances order=1 normal gfp_flags=GFP_NOWARN|GFP_NORETRY|GFP_COMP|GFP_NOMEMALLOC|
 => __alloc_pages_nodemask+0x754/0x792 <ffffffff810dc0da>
 => alloc_pages_current+0xbe/0xd8 <ffffffff81105455>
 => alloc_slab_page+0x1c/0x4d <ffffffff8110c5fa>
 => new_slab+0x50/0x199 <ffffffff8110dc44>
 => __slab_alloc+0x24a/0x328 <ffffffff8146ab86>
 => kmem_cache_alloc+0x77/0x105 <ffffffff8110e44c>
 => mempool_alloc_slab+0x15/0x17 <ffffffff810d6e81>
 => mempool_alloc+0x68/0x116 <ffffffff810d70f6>

48 instances order=2 normal gfp_flags=GFP_IO|GFP_NOWARN|GFP_NORETRY|GFP_COMP|GFP_RECLAIMABLE|
 => __alloc_pages_nodemask+0x754/0x792 <ffffffff810dc0da>
 => alloc_pages_current+0xbe/0xd8 <ffffffff81105455>
 => alloc_slab_page+0x1c/0x4d <ffffffff8110c5fa>
 => new_slab+0x50/0x199 <ffffffff8110dc44>
 => __slab_alloc+0x24a/0x328 <ffffffff8146ab86>
 => kmem_cache_alloc+0x77/0x105 <ffffffff8110e44c>
 => proc_alloc_inode+0x20/0x91 <ffffffff811682bc>
 => alloc_inode+0x1d/0x78 <ffffffff81131805>

1 instances order=3 normal gfp_flags=GFP_IO|GFP_NOWARN|GFP_NORETRY|GFP_COMP|
 => __alloc_pages_nodemask+0x754/0x792 <ffffffff810dc0da>
 => alloc_pages_current+0xbe/0xd8 <ffffffff81105455>
 => alloc_slab_page+0x1c/0x4d <ffffffff8110c5fa>
 => new_slab+0x50/0x199 <ffffffff8110dc44>
 => __slab_alloc+0x24a/0x328 <ffffffff8146ab86>
 => kmem_cache_alloc+0x77/0x105 <ffffffff8110e44c>
 => copy_process+0xc6/0x10c5 <ffffffff810533b9>
 => do_fork+0x104/0x286 <ffffffff810544f7>

31 instances order=1 normal gfp_flags=GFP_IO|GFP_NOWARN|GFP_NORETRY|GFP_COMP|
 => __alloc_pages_nodemask+0x754/0x792 <ffffffff810dc0da>
 => alloc_pages_current+0xbe/0xd8 <ffffffff81105455>
 => alloc_slab_page+0x1c/0x4d <ffffffff8110c5fa>
 => new_slab+0x50/0x199 <ffffffff8110dc44>
 => __slab_alloc+0x24a/0x328 <ffffffff8146ab86>
 => kmem_cache_alloc+0x77/0x105 <ffffffff8110e44c>
 => prepare_creds+0x26/0xae <ffffffff81074d4b>
 => sys_faccessat+0x37/0x162 <ffffffff8111d275>

1 instances order=3 atomic gfp_flags=GFP_ATOMIC|GFP_NOWARN|GFP_NORETRY|GFP_COMP|
 => __alloc_pages_nodemask+0x754/0x792 <ffffffff810dc0da>
 => alloc_pages_current+0xbe/0xd8 <ffffffff81105455>
 => alloc_slab_page+0x1c/0x4d <ffffffff8110c5fa>
 => new_slab+0x50/0x199 <ffffffff8110dc44>
 => __slab_alloc+0x24a/0x328 <ffffffff8146ab86>
 => __kmalloc_node_track_caller+0xcf/0x131 <ffffffff8110ffc6>
 => __alloc_skb+0x75/0x133 <ffffffff813b5e4c>
 => __netdev_alloc_skb+0x1f/0x3b <ffffffff813b5f6a>

High-order normal allocations: 147471
High-order atomic allocations: 720


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
