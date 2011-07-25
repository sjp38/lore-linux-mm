Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 7C3FF6B0169
	for <linux-mm@kvack.org>; Mon, 25 Jul 2011 17:13:34 -0400 (EDT)
Date: Mon, 25 Jul 2011 23:13:28 +0200
From: Johannes Weiner <jweiner@redhat.com>
Subject: Re: [patch] mm: thp: disable defrag for page faults per default
Message-ID: <20110725211328.GA14474@redhat.com>
References: <1311626321-14364-1-git-send-email-jweiner@redhat.com>
 <20110725210148.GP18528@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110725210148.GP18528@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi Andrea,

On Mon, Jul 25, 2011 at 11:01:48PM +0200, Andrea Arcangeli wrote:
> Hello Johannes,
> 
> On Mon, Jul 25, 2011 at 10:38:41PM +0200, Johannes Weiner wrote:
> > With defrag mode enabled per default, huge page allocations pass
> > __GFP_WAIT and may drop compaction into sync-mode where they wait for
> > pages under writeback.
> > 
> > I observe applications hang for several minutes(!) when they fault in
> > huge pages and compaction starts to wait on in-"flight" USB stick IO.
> > 
> > This patch disables defrag mode for page fault allocations unless the
> > VMA is madvised explicitely.  Khugepaged will continue to allocate
> > with __GFP_WAIT per default, but stalls are not a problem of
> > application responsiveness there.
> 
> Allocating memory without __GFP_WAIT means THP it's like disabled
> except when there's plenty of memory free after boot, even trying with
> __GFP_WAIT and without compaction would be better than that. We don't
> want to modify all apps, just a few special ones should have the
> madvise like qemu-kvm for example (for embedded in case there's
> embedded virt).
> 
> If you want to make compaction and migrate run without ever dropping
> into sync-mode (or aborting if we've to wait on too many pages) I
> think it'd be a whole lot better.

Agreed, this makes more sense.

> If you could show the SYSRQ+T during the minute wait it'd be
> interesting too.

Sure thing.  It's firefox while I copy stuff to a USB stick.  In the
first one, it's just waiting for a page to finish writeback:

[171252.437688] firefox         D 000000010a31e6b7     0  8502   1110 0x00000000
[171252.437691]  ffff88001e91f8a8 0000000000000082 ffff880000000000 ffff88001e91ffd8
[171252.437693]  ffff88001e91ffd8 0000000000004000 ffffffff8180b020 ffff8800456e4680
[171252.437696]  ffff88001e91f7e8 ffffffff810cd4ed ffffea00028d4500 000000000000000e
[171252.437699] Call Trace:
[171252.437701]  [<ffffffff810cd4ed>] ? __pagevec_free+0x2d/0x40
[171252.437703]  [<ffffffff810d044c>] ? release_pages+0x24c/0x280
[171252.437705]  [<ffffffff81099448>] ? ktime_get_ts+0xa8/0xe0
[171252.437707]  [<ffffffff810c5040>] ? file_read_actor+0x170/0x170
[171252.437709]  [<ffffffff8156ac8a>] io_schedule+0x8a/0xd0
[171252.437711]  [<ffffffff810c5049>] sleep_on_page+0x9/0x10
[171252.437713]  [<ffffffff8156b0f7>] __wait_on_bit+0x57/0x80
[171252.437715]  [<ffffffff810c5630>] wait_on_page_bit+0x70/0x80
[171252.437718]  [<ffffffff810916c0>] ? autoremove_wake_function+0x40/0x40
[171252.437720]  [<ffffffff810f98a5>] migrate_pages+0x2a5/0x490
[171252.437722]  [<ffffffff810f5940>] ? suitable_migration_target+0x50/0x50
[171252.437724]  [<ffffffff810f6234>] compact_zone+0x4e4/0x770
[171252.437727]  [<ffffffff810f65e0>] compact_zone_order+0x80/0xb0
[171252.437729]  [<ffffffff810f66cd>] try_to_compact_pages+0xbd/0xf0
[171252.437731]  [<ffffffff810cc608>] __alloc_pages_direct_compact+0xa8/0x180
[171252.437734]  [<ffffffff810ccbdb>] __alloc_pages_nodemask+0x4fb/0x720
[171252.437736]  [<ffffffff810fbfe3>] do_huge_pmd_wp_page+0x4c3/0x740
[171252.437738]  [<ffffffff81094fff>] ? hrtimer_start_range_ns+0xf/0x20
[171252.437740]  [<ffffffff810e3f9c>] handle_mm_fault+0x1bc/0x2f0
[171252.437743]  [<ffffffff8102e6c6>] ? __switch_to+0x1e6/0x2c0
[171252.437745]  [<ffffffff810511b2>] do_page_fault+0x132/0x430
[171252.437747]  [<ffffffff810a4995>] ? sys_futex+0x105/0x1a0
[171252.437749]  [<ffffffff8156cf9f>] page_fault+0x1f/0x30

Here it is trying to do writeback itself and gets stuck on the clogged
request queue:

[1292004.173328] firefox         D 0000000000000000     0 30407   8429 0x00000080
[1292004.173328]  ffff880023e73598 0000000000000082 ffff880000000000 ffff880114a64590
[1292004.173328]  ffff880023e73fd8 ffff880023e73fd8 0000000000013840 0000000000013840
[1292004.173328]  ffff880117f29730 ffff880114a64590 ffff8800cfc940c8 0000000123e73600
[1292004.173328] Call Trace:
[1292004.173328]  [<ffffffff8147439c>] io_schedule+0x47/0x62
[1292004.173328]  [<ffffffff8121683f>] get_request_wait+0x10a/0x193
[1292004.173328]  [<ffffffff8106f26e>] ? autoremove_wake_function+0x0/0x3d
[1292004.173328]  [<ffffffff8121705c>] __make_request+0x2b4/0x400
[1292004.173328]  [<ffffffff81111757>] ? kmem_cache_alloc+0x90/0x105
[1292004.173328]  [<ffffffff81215928>] generic_make_request+0x2ae/0x328
[1292004.173328]  [<ffffffff810da079>] ? mempool_alloc_slab+0x15/0x17
[1292004.173328]  [<ffffffff81215a80>] submit_bio+0xde/0xfd
[1292004.173328]  [<ffffffff81148155>] ? bio_alloc_bioset+0x4c/0xc3
[1292004.173328]  [<ffffffff810ecb79>] ? inc_zone_page_state+0x27/0x29
[1292004.173328]  [<ffffffff81143db7>] submit_bh+0xe6/0x105
[1292004.173328]  [<ffffffff811452f4>] __block_write_full_page+0x1e7/0x2d7
[1292004.173328]  [<ffffffff811496c4>] ? blkdev_get_block+0x0/0x69
[1292004.173328]  [<ffffffff81146acf>] ? end_buffer_async_write+0x0/0x134
[1292004.173328]  [<ffffffff81146acf>] ? end_buffer_async_write+0x0/0x134
[1292004.173328]  [<ffffffff811496c4>] ? blkdev_get_block+0x0/0x69
[1292004.173328]  [<ffffffff811469b9>] block_write_full_page_endio+0x8a/0x97
[1292004.173328]  [<ffffffff811469db>] block_write_full_page+0x15/0x17
[1292004.173328]  [<ffffffff8114941c>] blkdev_writepage+0x18/0x1a
[1292004.173328]  [<ffffffff8111534a>] move_to_new_page+0x10e/0x1a1
[1292004.173328]  [<ffffffff81115732>] migrate_pages+0x246/0x38c
[1292004.173328]  [<ffffffff8110b787>] ? compaction_alloc+0x0/0x2a3
[1292004.173328]  [<ffffffff8110bf73>] compact_zone+0x3e7/0x5ca
[1292004.173328]  [<ffffffff8110c2e5>] compact_zone_order+0x94/0x9f
[1292004.173328]  [<ffffffff8110c381>] try_to_compact_pages+0x91/0xe3
[1292004.173328]  [<ffffffff8146e867>] __alloc_pages_direct_compact+0xa7/0x16d
[1292004.173328]  [<ffffffff810df0e6>] __alloc_pages_nodemask+0x6ad/0x77f
[1292004.173328]  [<ffffffff8110a321>] alloc_pages_vma+0xf5/0xfa
[1292004.173328]  [<ffffffff81118e6c>] do_huge_pmd_anonymous_page+0xbf/0x261
[1292004.173328]  [<ffffffff810f13cf>] ? pmd_offset+0x19/0x3f
[1292004.173328]  [<ffffffff810f4750>] handle_mm_fault+0x113/0x1ce
[1292004.173328]  [<ffffffff81478f30>] do_page_fault+0x358/0x37a
[1292004.173328]  [<ffffffff810f9e55>] ? do_mmap_pgoff+0x29f/0x2f9
[1292004.173328]  [<ffffffff81129e21>] ? path_put+0x1f/0x23
[1292004.173328]  [<ffffffff814761d5>] page_fault+0x25/0x30

> There was also some compaction bug that would lead to minutes of stall
> in congestion_wait, those are fixed in current kernels.

I think that is a different issue, this happens on most recent
kernels, too.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
