Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f177.google.com (mail-io0-f177.google.com [209.85.223.177])
	by kanga.kvack.org (Postfix) with ESMTP id 7EBE7828E6
	for <linux-mm@kvack.org>; Wed,  3 Feb 2016 08:18:00 -0500 (EST)
Received: by mail-io0-f177.google.com with SMTP id g73so54550904ioe.3
        for <linux-mm@kvack.org>; Wed, 03 Feb 2016 05:18:00 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id c1si12329193igx.68.2016.02.03.05.17.59
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 03 Feb 2016 05:17:59 -0800 (PST)
Date: Wed, 3 Feb 2016 14:17:49 +0100
From: Mateusz Guzik <mguzik@redhat.com>
Subject: Re: [PATCH 1/3] mm: migrate: do not touch page->mem_cgroup of live
 pages
Message-ID: <20160203131748.GB15520@mguzik>
References: <1454109573-29235-1-git-send-email-hannes@cmpxchg.org>
 <1454109573-29235-2-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <1454109573-29235-2-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vladimir Davydov <vdavydov@virtuozzo.com>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Fri, Jan 29, 2016 at 06:19:31PM -0500, Johannes Weiner wrote:
> Changing a page's memcg association complicates dealing with the page,
> so we want to limit this as much as possible. Page migration e.g. does
> not have to do that. Just like page cache replacement, it can forcibly
> charge a replacement page, and then uncharge the old page when it gets
> freed. Temporarily overcharging the cgroup by a single page is not an
> issue in practice, and charging is so cheap nowadays that this is much
> preferrable to the headache of messing with live pages.
> 
> The only place that still changes the page->mem_cgroup binding of live
> pages is when pages move along with a task to another cgroup. But that
> path isolates the page from the LRU, takes the page lock, and the move
> lock (lock_page_memcg()). That means page->mem_cgroup is always stable
> in callers that have the page isolated from the LRU or locked. Lighter
> unlocked paths, like writeback accounting, can use lock_page_memcg().
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
[..]
> @@ -372,12 +373,13 @@ int migrate_page_move_mapping(struct address_space *mapping,
>  	 * Now we know that no one else is looking at the page:
>  	 * no turning back from here.
>  	 */
> -	set_page_memcg(newpage, page_memcg(page));
>  	newpage->index = page->index;
>  	newpage->mapping = page->mapping;
>  	if (PageSwapBacked(page))
>  		SetPageSwapBacked(newpage);
>  
> +	mem_cgroup_migrate(page, newpage);
> +
>  	get_page(newpage);	/* add cache reference */
>  	if (PageSwapCache(page)) {
>  		SetPageSwapCache(newpage);
> @@ -457,9 +459,11 @@ int migrate_huge_page_move_mapping(struct address_space *mapping,
>  		return -EAGAIN;
>  	}
>  
> -	set_page_memcg(newpage, page_memcg(page));
>  	newpage->index = page->index;
>  	newpage->mapping = page->mapping;
> +
> +	mem_cgroup_migrate(page, newpage);
> +
>  	get_page(newpage);
>  
>  	radix_tree_replace_slot(pslot, newpage);

I ran trinity on recent linux-next and got the lockdep splat below and if I
read it right, this is the culprit.  In particular, mem_cgroup_migrate was put
in an area covered by spin_lock_irq(&mapping->tree_lock), but stuff it calls
enables and disables interrupts on its own.

[  105.084225] =================================
[  105.096026] [ INFO: inconsistent lock state ]
[  105.107896] 4.5.0-rc2-next-20160203dupa+ #121 Not tainted
[  105.119904] ---------------------------------
[  105.131667] inconsistent {IN-HARDIRQ-W} -> {HARDIRQ-ON-W} usage.
[  105.144052] trinity-c3/1600 [HC0[0]:SC0[0]:HE1:SE1] takes:
[  105.155944]  (&(&mapping->tree_lock)->rlock){?.-.-.}, at: [<ffffffff8121d9b1>] migrate_page_move_mapping+0x71/0x4f0
[  105.179744] {IN-HARDIRQ-W} state was registered at:
[  105.191556]   [<ffffffff810d56ef>] __lock_acquire+0x79f/0xbf0
[  105.203521]   [<ffffffff810d632a>] lock_acquire+0xca/0x1c0
[  105.215447]   [<ffffffff819f72b5>] _raw_spin_lock_irqsave+0x55/0x90
[  105.227537]   [<ffffffff811b8307>] test_clear_page_writeback+0x67/0x2a0
[  105.239612]   [<ffffffff811a743f>] end_page_writeback+0x1f/0xa0
[  105.251622]   [<ffffffff81284816>] end_buffer_async_write+0xd6/0x1b0
[  105.263649]   [<ffffffff81283828>] end_bio_bh_io_sync+0x28/0x40
[  105.276160]   [<ffffffff81473900>] bio_endio+0x40/0x60
[  105.288599]   [<ffffffff817373ed>] dec_pending+0x15d/0x320
[  105.301083]   [<ffffffff81737e2b>] clone_endio+0x5b/0xe0
[  105.313418]   [<ffffffff81473900>] bio_endio+0x40/0x60
[  105.325763]   [<ffffffff8147bbf2>] blk_update_request+0xb2/0x3b0
[  105.338236]   [<ffffffff814867aa>] blk_mq_end_request+0x1a/0x70
[  105.350626]   [<ffffffff8164bcff>] virtblk_request_done+0x3f/0x70
[  105.363303]   [<ffffffff814852d3>] __blk_mq_complete_request_remote+0x13/0x20
[  105.387289]   [<ffffffff81116f1b>] flush_smp_call_function_queue+0x7b/0x150
[  105.399903]   [<ffffffff81117c23>] generic_smp_call_function_single_interrupt+0x13/0x60
[  105.423568]   [<ffffffff81041697>] smp_call_function_single_interrupt+0x27/0x40
[  105.446971]   [<ffffffff819f88e6>] call_function_single_interrupt+0x96/0xa0
[  105.459109]   [<ffffffff8121510e>] kmem_cache_alloc+0x27e/0x2e0
[  105.471141]   [<ffffffff811ab8dc>] mempool_alloc_slab+0x1c/0x20
[  105.483200]   [<ffffffff811abe29>] mempool_alloc+0x79/0x1b0
[  105.495195]   [<ffffffff814721b6>] bio_alloc_bioset+0x146/0x220
[  105.507268]   [<ffffffff81739103>] __split_and_process_bio+0x253/0x4f0
[  105.519505]   [<ffffffff8173966a>] dm_make_request+0x7a/0x110
[  105.531563]   [<ffffffff8147b3b6>] generic_make_request+0x166/0x2c0
[  105.544062]   [<ffffffff8147b587>] submit_bio+0x77/0x150
[  105.556195]   [<ffffffff81285dff>] submit_bh_wbc+0x12f/0x160
[  105.568461]   [<ffffffff81288228>] __block_write_full_page.constprop.41+0x138/0x3b0
[  105.591728]   [<ffffffff8128858c>] block_write_full_page+0xec/0x110
[  105.603869]   [<ffffffff81289088>] blkdev_writepage+0x18/0x20
[  105.616272]   [<ffffffff811b4796>] __writepage+0x16/0x50
[  105.628206]   [<ffffffff811b6e50>] write_cache_pages+0x2c0/0x620
[  105.640298]   [<ffffffff811b7204>] generic_writepages+0x54/0x80
[  105.652244]   [<ffffffff811b7f11>] do_writepages+0x21/0x40
[  105.664204]   [<ffffffff811a97f6>] __filemap_fdatawrite_range+0xc6/0x100
[  105.676241]   [<ffffffff811a988f>] filemap_write_and_wait+0x2f/0x60
[  105.688339]   [<ffffffff81289b8f>] __sync_blockdev+0x1f/0x40
[  105.700350]   [<ffffffff81289bc3>] sync_blockdev+0x13/0x20
[  105.712352]   [<ffffffff813430e9>] jbd2_journal_recover+0x119/0x130
[  105.724532]   [<ffffffff81348e90>] jbd2_journal_load+0xe0/0x390
[  105.736533]   [<ffffffff81406925>] ext4_load_journal+0x5ef/0x6b8
[  105.748581]   [<ffffffff813132d3>] ext4_fill_super+0x1ad3/0x2a10
[  105.760597]   [<ffffffff81249d9c>] mount_bdev+0x18c/0x1c0
[  105.772574]   [<ffffffff81302675>] ext4_mount+0x15/0x20
[  105.784489]   [<ffffffff8124a669>] mount_fs+0x39/0x170
[  105.796406]   [<ffffffff8126a59b>] vfs_kern_mount+0x6b/0x150
[  105.808386]   [<ffffffff8126d1fd>] do_mount+0x24d/0xed0
[  105.820355]   [<ffffffff8126e193>] SyS_mount+0x83/0xd0
[  105.832317]   [<ffffffff819f743c>] entry_SYSCALL_64_fastpath+0x1f/0xbd
[  105.844390] irq event stamp: 341784
[  105.856114] hardirqs last  enabled at (341783): [<ffffffff8104c6da>] flat_send_IPI_mask+0x8a/0xc0
[  105.879644] hardirqs last disabled at (341784): [<ffffffff819f698f>] _raw_spin_lock_irq+0x1f/0x80
[  105.903369] softirqs last  enabled at (341744): [<ffffffff8107b933>] __do_softirq+0x343/0x480
[  105.926856] softirqs last disabled at (341739): [<ffffffff8107bdc6>] irq_exit+0x106/0x120
[  105.950499] 
[  105.950499] other info that might help us debug this:
[  105.973803]  Possible unsafe locking scenario:
[  105.973803] 
[  105.997202]        CPU0
[  106.008754]        ----
[  106.020265]   lock(&(&mapping->tree_lock)->rlock);
[  106.032196]   <Interrupt>
[  106.043832]     lock(&(&mapping->tree_lock)->rlock);
[  106.055891] 
[  106.055891]  *** DEADLOCK ***
[  106.055891] 
[  106.090289] 2 locks held by trinity-c3/1600:
[  106.102049]  #0:  (&mm->mmap_sem){++++++}, at: [<ffffffff8105aeef>] __do_page_fault+0x15f/0x470
[  106.125631]  #1:  (&(&mapping->tree_lock)->rlock){?.-.-.}, at: [<ffffffff8121d9b1>] migrate_page_move_mapping+0x71/0x4f0
[  106.149777] 
[  106.149777] stack backtrace:
[  106.172646] CPU: 3 PID: 1600 Comm: trinity-c3 Not tainted 4.5.0-rc2-next-20160203dupa+ #121
[  106.196137] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2011
[  106.208200]  0000000000000086 00000000cf42937f ffff88004bdef630 ffffffff814acb6d
[  106.231859]  ffff88004e0e0000 ffffffff82f17fb0 ffff88004bdef680 ffffffff811a47e9
[  106.255250]  0000000000000000 ffff880000000001 ffff880000000001 0000000000000000
[  106.278647] Call Trace:
[  106.290201]  [<ffffffff814acb6d>] dump_stack+0x85/0xc8
[  106.302013]  [<ffffffff811a47e9>] print_usage_bug+0x1eb/0x1fc
[  106.314144]  [<ffffffff810d2f70>] ? print_shortest_lock_dependencies+0x1d0/0x1d0
[  106.337708]  [<ffffffff810d490d>] mark_lock+0x20d/0x290
[  106.349493]  [<ffffffff810d4a01>] mark_held_locks+0x71/0x90
[  106.361462]  [<ffffffff819f6afc>] ? _raw_spin_unlock_irq+0x2c/0x40
[  106.373469]  [<ffffffff810d4ac9>] trace_hardirqs_on_caller+0xa9/0x1c0
[  106.385466]  [<ffffffff810d4bed>] trace_hardirqs_on+0xd/0x10
[  106.397421]  [<ffffffff819f6afc>] _raw_spin_unlock_irq+0x2c/0x40
[  106.409417]  [<ffffffff8123171e>] commit_charge+0xbe/0x390
[  106.421310]  [<ffffffff81233f25>] mem_cgroup_migrate+0x135/0x360
[  106.433352]  [<ffffffff8121da72>] migrate_page_move_mapping+0x132/0x4f0
[  106.445369]  [<ffffffff8121e68b>] migrate_page+0x2b/0x50
[  106.457301]  [<ffffffff8121ea2a>] buffer_migrate_page+0x10a/0x150
[  106.469260]  [<ffffffff8121e743>] move_to_new_page+0x93/0x270
[  106.481209]  [<ffffffff811f0a07>] ? try_to_unmap+0xa7/0x170
[  106.493094]  [<ffffffff811ef170>] ? page_remove_rmap+0x2a0/0x2a0
[  106.505052]  [<ffffffff811edb40>] ? __hugepage_set_anon_rmap+0x80/0x80
[  106.517130]  [<ffffffff8121f2b6>] migrate_pages+0x846/0xac0
[  106.528993]  [<ffffffff811d6570>] ? __reset_isolation_suitable+0x120/0x120
[  106.541061]  [<ffffffff811d7c90>] ? isolate_freepages_block+0x4e0/0x4e0
[  106.553068]  [<ffffffff811d8f1d>] compact_zone+0x33d/0xa80
[  106.565026]  [<ffffffff811d96db>] compact_zone_order+0x7b/0xc0
[  106.576944]  [<ffffffff811d9a0a>] try_to_compact_pages+0x13a/0x2e0
[  106.588948]  [<ffffffff8123f829>] __alloc_pages_direct_compact+0x3b/0xf9
[  106.600995]  [<ffffffff8123fbcc>] __alloc_pages_slowpath.constprop.87+0x2e5/0x886
[  106.624383]  [<ffffffff811b3a66>] __alloc_pages_nodemask+0x456/0x460
[  106.636380]  [<ffffffff8120aa0b>] alloc_pages_vma+0x28b/0x2d0
[  106.648440]  [<ffffffff81226d9e>] do_huge_pmd_anonymous_page+0x13e/0x540
[  106.660497]  [<ffffffff811e46e4>] handle_mm_fault+0x7e4/0x980
[  106.672585]  [<ffffffff811e3f59>] ? handle_mm_fault+0x59/0x980
[  106.684595]  [<ffffffff8105af5d>] __do_page_fault+0x1cd/0x470
[  106.696524]  [<ffffffff8105b2ee>] trace_do_page_fault+0x6e/0x250
[  106.708477]  [<ffffffff81054c3a>] do_async_page_fault+0x1a/0xb0
[  106.720407]  [<ffffffff819f9488>] async_page_fault+0x28/0x30

-- 
Mateusz Guzik

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
