Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 5800B44059E
	for <linux-mm@kvack.org>; Wed, 15 Feb 2017 11:05:43 -0500 (EST)
Received: by mail-qk0-f198.google.com with SMTP id 11so165785041qkl.4
        for <linux-mm@kvack.org>; Wed, 15 Feb 2017 08:05:43 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id s18si3119745qta.274.2017.02.15.08.05.41
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Feb 2017 08:05:41 -0800 (PST)
Date: Wed, 15 Feb 2017 11:05:39 -0500
From: Brian Foster <bfoster@redhat.com>
Subject: Re: [Bug 192981] New: page allocation stalls
Message-ID: <20170215160538.GA62565@bfoster.bfoster>
References: <bug-192981-27@https.bugzilla.kernel.org/>
 <20170123135111.13ac3e47110de10a4bd503ef@linux-foundation.org>
 <8f450abd-4e05-92d3-2533-72b05fea2012@beget.ru>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <8f450abd-4e05-92d3-2533-72b05fea2012@beget.ru>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Polakov <apolyakov@beget.ru>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-xfs@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org

On Wed, Feb 15, 2017 at 03:56:56PM +0300, Alexander Polakov wrote:
> On 01/24/2017 12:51 AM, Andrew Morton wrote:
> > 
> > 
> > (switched to email.  Please respond via emailed reply-to-all, not via the
> > bugzilla web interface).
> > 
> > A 2100 second page allocation stall!
> > 
> 
> I think we finally figured out the problem using Tetsuo Handa's mallocwd
> patch. It seems like it is in XFS direct reclaim path.
> 
> Here's how it goes:
> 
> memory is low, rsync goes into direct reclaim, locking xfs mutex in
> xfs_reclaim_inodes_nr():
> 
> 2017-02-14T00:12:59.811447+03:00 storage9 [24646.497290] MemAlloc:
> rsync(19706) flags=0x404840 switches=8692 seq=340
> gfp=0x27080c0(GFP_KERNEL_ACCOUNT|__GFP_ZERO|__GFP_NOTRACK) order=0
> delay=6795
> 2017-02-14T00:12:59.811447+03:00 storage9 [24646.497550] rsync           R
> 2017-02-14T00:12:59.811579+03:00 storage9     0 19706   5000 0x00000000
> 2017-02-14T00:12:59.811579+03:00 storage9 [24646.497690]  ffffa4361dc36c00
> 2017-02-14T00:12:59.811591+03:00 storage9  0000000c1dc36c00
> 2017-02-14T00:12:59.811591+03:00 storage9  ffffa4361dc36c00
> 2017-02-14T00:12:59.811724+03:00 storage9  ffffa44347792580
> 2017-02-14T00:12:59.811841+03:00 storage9
> 2017-02-14T00:12:59.811841+03:00 storage9 [24646.497951]  0000000000000000
> 2017-02-14T00:12:59.811846+03:00 storage9  ffffb1cab6343458
> 2017-02-14T00:12:59.811885+03:00 storage9  ffffffffb383e799
> 2017-02-14T00:12:59.811987+03:00 storage9  0000000000000000
> 2017-02-14T00:12:59.812103+03:00 storage9
> 2017-02-14T00:12:59.812103+03:00 storage9 [24646.498208]  ffffa443ffff7a00
> 2017-02-14T00:12:59.812103+03:00 storage9  0000000000000001
> 2017-02-14T00:12:59.812104+03:00 storage9  ffffb1cab6343448
> 2017-02-14T00:12:59.812233+03:00 storage9  0000000000000002
> 2017-02-14T00:12:59.812350+03:00 storage9
> 2017-02-14T00:12:59.812475+03:00 storage9 [24646.498462] Call Trace:
> 2017-02-14T00:12:59.812610+03:00 storage9 [24646.498587]
> [<ffffffffb383e799>] ? __schedule+0x179/0x5c8
> 2017-02-14T00:12:59.812733+03:00 storage9 [24646.498718]
> [<ffffffffb383ecc2>] ? schedule+0x32/0x80
> 2017-02-14T00:12:59.812869+03:00 storage9 [24646.498846]
> [<ffffffffb3841229>] ? schedule_timeout+0x159/0x2a0
> 2017-02-14T00:12:59.812997+03:00 storage9 [24646.498977]
> [<ffffffffb30f1450>] ? add_timer_on+0x130/0x130
> 2017-02-14T00:12:59.813130+03:00 storage9 [24646.499108]
> [<ffffffffb318ff13>] ? __alloc_pages_nodemask+0xe73/0x16b0
> 2017-02-14T00:12:59.813263+03:00 storage9 [24646.499240]
> [<ffffffffb31deb2a>] ? alloc_pages_current+0x9a/0x120
> 2017-02-14T00:12:59.813388+03:00 storage9 [24646.499371]
> [<ffffffffb33d1a51>] ? xfs_buf_allocate_memory+0x171/0x2c0
> 2017-02-14T00:12:59.813564+03:00 storage9 [24646.499503]
> [<ffffffffb337c48b>] ? xfs_buf_get_map+0x18b/0x1d0
> 2017-02-14T00:12:59.813654+03:00 storage9 [24646.499634]
> [<ffffffffb337cdcb>] ? xfs_buf_read_map+0x3b/0x160
> 2017-02-14T00:12:59.813783+03:00 storage9 [24646.499765]
> [<ffffffffb33b71b0>] ? xfs_trans_read_buf_map+0x1f0/0x490
> 2017-02-14T00:12:59.813931+03:00 storage9 [24646.499897]
> [<ffffffffb3362859>] ? xfs_imap_to_bp+0x79/0x120
> 2017-02-14T00:12:59.814056+03:00 storage9 [24646.500029]
> [<ffffffffb3394a38>] ? xfs_iflush+0x118/0x380
> 2017-02-14T00:12:59.814196+03:00 storage9 [24646.500158]
> [<ffffffffb30d6130>] ? wake_atomic_t_function+0x40/0x40
> 2017-02-14T00:12:59.814314+03:00 storage9 [24646.500289]
> [<ffffffffb3385af4>] ? xfs_reclaim_inode+0x274/0x3f0
> 2017-02-14T00:12:59.814444+03:00 storage9 [24646.500421]
> [<ffffffffb3385e29>] ? xfs_reclaim_inodes_ag+0x1b9/0x2c0
> 2017-02-14T00:12:59.814573+03:00 storage9 [24646.500553]
> [<ffffffffb345c6b8>] ? radix_tree_next_chunk+0x108/0x2a0
> 2017-02-14T00:12:59.814701+03:00 storage9 [24646.500685]
> [<ffffffffb30f0e31>] ? lock_timer_base+0x51/0x70
> 2017-02-14T00:12:59.814846+03:00 storage9 [24646.500814]
> [<ffffffffb345ca4e>] ? radix_tree_gang_lookup_tag+0xae/0x180
> 2017-02-14T00:12:59.814966+03:00 storage9 [24646.500946]
> [<ffffffffb336f588>] ? xfs_perag_get_tag+0x48/0x100
> 2017-02-14T00:12:59.815104+03:00 storage9 [24646.501079]
> [<ffffffffb31b63c1>] ? __list_lru_walk_one.isra.7+0x31/0x120
> 2017-02-14T00:12:59.815231+03:00 storage9 [24646.501212]
> [<ffffffffb322aed0>] ? iget5_locked+0x240/0x240
> 2017-02-14T00:12:59.815360+03:00 storage9 [24646.501342]
> [<ffffffffb33873c1>] ? xfs_reclaim_inodes_nr+0x31/0x40
> 2017-02-14T00:12:59.815489+03:00 storage9 [24646.501472]
> [<ffffffffb3213160>] ? super_cache_scan+0x1a0/0x1b0
> 2017-02-14T00:12:59.815629+03:00 storage9 [24646.501603]
> [<ffffffffb319bf62>] ? shrink_slab+0x262/0x440
> 2017-02-14T00:12:59.815760+03:00 storage9 [24646.501734]
> [<ffffffffb319cc8b>] ? drop_slab_node+0x2b/0x60
> 2017-02-14T00:12:59.815891+03:00 storage9 [24646.501864]
> [<ffffffffb319cd02>] ? drop_slab+0x42/0x70
> 2017-02-14T00:12:59.816020+03:00 storage9 [24646.501994]
> [<ffffffffb318abc0>] ? out_of_memory+0x220/0x560
> 2017-02-14T00:12:59.816160+03:00 storage9 [24646.502122]
> [<ffffffffb31903b2>] ? __alloc_pages_nodemask+0x1312/0x16b0
> 2017-02-14T00:12:59.816285+03:00 storage9 [24646.502255]
> [<ffffffffb31deb2a>] ? alloc_pages_current+0x9a/0x120
> 2017-02-14T00:12:59.816407+03:00 storage9 [24646.502386]
> [<ffffffffb304b803>] ? pte_alloc_one+0x13/0x40
> 2017-02-14T00:12:59.816536+03:00 storage9 [24646.502517]
> [<ffffffffb31be21f>] ? handle_mm_fault+0xc7f/0x14b0
> 2017-02-14T00:12:59.816659+03:00 storage9 [24646.502648]
> [<ffffffffb30461ff>] ? __do_page_fault+0x1cf/0x5a0
> 2017-02-14T00:12:59.816851+03:00 storage9 [24646.502777]
> [<ffffffffb3843362>] ? page_fault+0x22/0x30
> 

You're in inode reclaim, blocked on a memory allocation for an inode
buffer required to flush a dirty inode. I suppose this means that the
backing buffer for the inode has already been reclaimed and must be
re-read, which ideally wouldn't have occurred before the inode is
flushed.

> But it cannot get memory, because it's low (?). So it stays blocked.
> 
> Other processes do the same but they can't get past the mutex in
> xfs_reclaim_inodes_nr():
> 
...
> Which finally leads to "Kernel panic - not syncing: Out of memory and no
> killable processes..." as no process is able to proceed.
> 
> I quickly hacked this:
> 
> diff --git a/fs/xfs/xfs_icache.c b/fs/xfs/xfs_icache.c
> index 9ef152b..8adfb0a 100644
> --- a/fs/xfs/xfs_icache.c
> +++ b/fs/xfs/xfs_icache.c
> @@ -1254,7 +1254,7 @@ struct xfs_inode *
>         xfs_reclaim_work_queue(mp);
>         xfs_ail_push_all(mp->m_ail);
> 
> -       return xfs_reclaim_inodes_ag(mp, SYNC_TRYLOCK | SYNC_WAIT,
> &nr_to_scan);
> +       return 0; // xfs_reclaim_inodes_ag(mp, SYNC_TRYLOCK | SYNC_WAIT,
> &nr_to_scan);
>  }
> 

So you've disabled inode reclaim completely...

The bz shows you have non-default vm settings such as
'vm.vfs_cache_pressure = 200.' My understanding is that prefers
aggressive inode reclaim, yet the code workaround here is to bypass XFS
inode reclaim. Out of curiousity, have you reproduced this problem using
the default vfs_cache_pressure value (or if so, possibly moving it in
the other direction)?

Brian

> 
> We ran 2 of our machines with this patch for a night, no more lockups/stalls
> were detected.
> 
> xfsaild does its work asynchronously, so xfs_inodes don't run wild as
> confirmed by slabtop.
> 
> I put netconsole logs here: http://aplkv.beget.tech/lkml/xfs/ for anyone
> interested.
> 
> -- 
> Alexander Polakov | system software engineer | https://beget.com
> --
> To unsubscribe from this list: send the line "unsubscribe linux-xfs" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
