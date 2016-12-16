Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id B3C6E6B0260
	for <linux-mm@kvack.org>; Fri, 16 Dec 2016 13:15:29 -0500 (EST)
Received: by mail-pg0-f72.google.com with SMTP id b1so10885108pgc.5
        for <linux-mm@kvack.org>; Fri, 16 Dec 2016 10:15:29 -0800 (PST)
Received: from mx0a-00082601.pphosted.com (mx0a-00082601.pphosted.com. [67.231.145.42])
        by mx.google.com with ESMTPS id n4si8855964pfn.9.2016.12.16.10.15.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Dec 2016 10:15:28 -0800 (PST)
Subject: Re: OOM: Better, but still there on 4.9
References: <20161215225702.GA27944@boerne.fritz.box>
 <20161216073941.GA26976@dhcp22.suse.cz>
From: Chris Mason <clm@fb.com>
Message-ID: <1da4691d-d0da-a620-020c-c2e968c2a5ec@fb.com>
Date: Fri, 16 Dec 2016 13:15:18 -0500
MIME-Version: 1.0
In-Reply-To: <20161216073941.GA26976@dhcp22.suse.cz>
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Nils Holland <nholland@tisys.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, David Sterba <dsterba@suse.cz>, linux-btrfs@vger.kernel.org

On 12/16/2016 02:39 AM, Michal Hocko wrote:
> [CC linux-mm and btrfs guys]
>
> On Thu 15-12-16 23:57:04, Nils Holland wrote:
> [...]
>> Of course, none of this are workloads that are new / special in any
>> way - prior to 4.8, I never experienced any issues doing the exact
>> same things.
>>
>> Dec 15 19:02:16 teela kernel: kworker/u4:5 invoked oom-killer: gfp_mask=0x2400840(GFP_NOFS|__GFP_NOFAIL), nodemask=0, order=0, oom_score_adj=0
>> Dec 15 19:02:18 teela kernel: kworker/u4:5 cpuset=/ mems_allowed=0
>> Dec 15 19:02:18 teela kernel: CPU: 1 PID: 2603 Comm: kworker/u4:5 Not tainted 4.9.0-gentoo #2
>> Dec 15 19:02:18 teela kernel: Hardware name: Hewlett-Packard Compaq 15 Notebook PC/21F7, BIOS F.22 08/06/2014
>> Dec 15 19:02:18 teela kernel: Workqueue: writeback wb_workfn (flush-btrfs-1)
>> Dec 15 19:02:18 teela kernel:  eff0b604 c142bcce eff0b734 00000000 eff0b634 c1163332 00000000 00000292
>> Dec 15 19:02:18 teela kernel:  eff0b634 c1431876 eff0b638 e7fb0b00 e7fa2900 e7fa2900 c1b58785 eff0b734
>> Dec 15 19:02:18 teela kernel:  eff0b678 c110795f c1043895 eff0b664 c11075c7 00000007 00000000 00000000
>> Dec 15 19:02:18 teela kernel: Call Trace:
>> Dec 15 19:02:18 teela kernel:  [<c142bcce>] dump_stack+0x47/0x69
>> Dec 15 19:02:18 teela kernel:  [<c1163332>] dump_header+0x60/0x178
>> Dec 15 19:02:18 teela kernel:  [<c1431876>] ? ___ratelimit+0x86/0xe0
>> Dec 15 19:02:18 teela kernel:  [<c110795f>] oom_kill_process+0x20f/0x3d0
>> Dec 15 19:02:18 teela kernel:  [<c1043895>] ? has_capability_noaudit+0x15/0x20
>> Dec 15 19:02:18 teela kernel:  [<c11075c7>] ? oom_badness.part.13+0xb7/0x130
>> Dec 15 19:02:18 teela kernel:  [<c1107df9>] out_of_memory+0xd9/0x260
>> Dec 15 19:02:18 teela kernel:  [<c110ba0b>] __alloc_pages_nodemask+0xbfb/0xc80
>> Dec 15 19:02:18 teela kernel:  [<c110414d>] pagecache_get_page+0xad/0x270
>> Dec 15 19:02:18 teela kernel:  [<c13664a6>] alloc_extent_buffer+0x116/0x3e0
>> Dec 15 19:02:18 teela kernel:  [<c1334a2e>] btrfs_find_create_tree_block+0xe/0x10
>> Dec 15 19:02:18 teela kernel:  [<c132a57f>] btrfs_alloc_tree_block+0x1ef/0x5f0
>> Dec 15 19:02:18 teela kernel:  [<c130f7c3>] __btrfs_cow_block+0x143/0x5f0
>> Dec 15 19:02:18 teela kernel:  [<c130fe1a>] btrfs_cow_block+0x13a/0x220
>> Dec 15 19:02:18 teela kernel:  [<c13132f1>] btrfs_search_slot+0x1d1/0x870
>> Dec 15 19:02:18 teela kernel:  [<c132fcdd>] btrfs_lookup_file_extent+0x4d/0x60
>> Dec 15 19:02:18 teela kernel:  [<c1354fe6>] __btrfs_drop_extents+0x176/0x1070
>> Dec 15 19:02:18 teela kernel:  [<c1150377>] ? kmem_cache_alloc+0xb7/0x190
>> Dec 15 19:02:18 teela kernel:  [<c133dbb5>] ? start_transaction+0x65/0x4b0
>> Dec 15 19:02:18 teela kernel:  [<c1150597>] ? __kmalloc+0x147/0x1e0
>> Dec 15 19:02:18 teela kernel:  [<c1345005>] cow_file_range_inline+0x215/0x6b0
>> Dec 15 19:02:18 teela kernel:  [<c13459fc>] cow_file_range.isra.49+0x55c/0x6d0
>> Dec 15 19:02:18 teela kernel:  [<c1361795>] ? lock_extent_bits+0x75/0x1e0
>> Dec 15 19:02:18 teela kernel:  [<c1346d51>] run_delalloc_range+0x441/0x470
>> Dec 15 19:02:18 teela kernel:  [<c13626e4>] writepage_delalloc.isra.47+0x144/0x1e0
>> Dec 15 19:02:18 teela kernel:  [<c1364548>] __extent_writepage+0xd8/0x2b0
>> Dec 15 19:02:18 teela kernel:  [<c1365c4c>] extent_writepages+0x25c/0x380
>> Dec 15 19:02:18 teela kernel:  [<c1342cd0>] ? btrfs_real_readdir+0x610/0x610
>> Dec 15 19:02:18 teela kernel:  [<c133ff0f>] btrfs_writepages+0x1f/0x30
>> Dec 15 19:02:18 teela kernel:  [<c110ff85>] do_writepages+0x15/0x40
>> Dec 15 19:02:18 teela kernel:  [<c1190a95>] __writeback_single_inode+0x35/0x2f0
>> Dec 15 19:02:18 teela kernel:  [<c119112e>] writeback_sb_inodes+0x16e/0x340
>> Dec 15 19:02:18 teela kernel:  [<c119145a>] wb_writeback+0xaa/0x280
>> Dec 15 19:02:18 teela kernel:  [<c1191de8>] wb_workfn+0xd8/0x3e0
>> Dec 15 19:02:18 teela kernel:  [<c104fd34>] process_one_work+0x114/0x3e0
>> Dec 15 19:02:18 teela kernel:  [<c1050b4f>] worker_thread+0x2f/0x4b0
>> Dec 15 19:02:18 teela kernel:  [<c1050b20>] ? create_worker+0x180/0x180
>> Dec 15 19:02:18 teela kernel:  [<c10552e7>] kthread+0x97/0xb0
>> Dec 15 19:02:18 teela kernel:  [<c1055250>] ? __kthread_parkme+0x60/0x60
>> Dec 15 19:02:18 teela kernel:  [<c19b5cb7>] ret_from_fork+0x1b/0x28
>> Dec 15 19:02:18 teela kernel: Mem-Info:
>> Dec 15 19:02:18 teela kernel: active_anon:58685 inactive_anon:90 isolated_anon:0
>>                                active_file:274324 inactive_file:281962 isolated_file:0
>
> OK, so there is still some anonymous memory that could be swapped out
> and quite a lot of page cache. This might be harder to reclaim because
> the allocation is a GFP_NOFS request which is limited in its reclaim
> capabilities. It might be possible that those pagecache pages are pinned
> in some way by the the filesystem.
>
>>                                unevictable:0 dirty:649 writeback:0 unstable:0
>>                                slab_reclaimable:40662 slab_unreclaimable:17754
>>                                mapped:7382 shmem:202 pagetables:351 bounce:0
>>                                free:206736 free_pcp:332 free_cma:0
>> Dec 15 19:02:18 teela kernel: Node 0 active_anon:234740kB inactive_anon:360kB active_file:1097296kB inactive_file:1127848kB unevictable:0kB isolated(anon):0kB isolated(file):0kB mapped:29528kB dirty:2596kB writeback:0kB shmem:0kB shmem_thp: 0kB shmem_pmdmapped: 184320kB anon_thp: 808kB writeback_tmp:0kB unstable:0kB pages_scanned:0 all_unreclaimable? no
>> Dec 15 19:02:18 teela kernel: DMA free:3952kB min:788kB low:984kB high:1180kB active_anon:0kB inactive_anon:0kB active_file:7316kB inactive_file:0kB unevictable:0kB writepending:96kB present:15992kB managed:15916kB mlocked:0kB slab_reclaimable:3200kB slab_unreclaimable:1408kB kernel_stack:0kB pagetables:0kB bounce:0kB free_pcp:0kB local_pcp:0kB free_cma:0kB
>> Dec 15 19:02:18 teela kernel: lowmem_reserve[]: 0 813 3474 3474
>> Dec 15 19:02:18 teela kernel: Normal free:41332kB min:41368kB low:51708kB high:62048kB active_anon:0kB inactive_anon:0kB active_file:532748kB inactive_file:44kB unevictable:0kB writepending:24kB present:897016kB managed:836248kB mlocked:0kB slab_reclaimable:159448kB slab_unreclaimable:69608kB kernel_stack:1112kB pagetables:1404kB bounce:0kB free_pcp:528kB local_pcp:340kB free_cma:0kB
>
> And this shows that there is no anonymous memory in the lowmem zone.
> Note that this request cannot use the highmem zone so no swap out would
> help. So if we are not able to reclaim those pages on the file LRU then
> we are out of luck
>
>> Dec 15 19:02:18 teela kernel: lowmem_reserve[]: 0 0 21292 21292
>> Dec 15 19:02:18 teela kernel: HighMem free:781660kB min:512kB low:34356kB high:68200kB active_anon:234740kB inactive_anon:360kB active_file:557232kB inactive_file:1127804kB unevictable:0kB writepending:2592kB present:2725384kB managed:2725384kB mlocked:0kB slab_reclaimable:0kB slab_unreclaimable:0kB kernel_stack:0kB pagetables:0kB bounce:0kB free_pcp:800kB local_pcp:608kB free_cma:0kB
>
> That being said, the OOM killer invocation is clearly pointless and
> pre-mature. We normally do not invoke it normally for GFP_NOFS requests
> exactly for these reasons. But this is GFP_NOFS|__GFP_NOFAIL which
> behaves differently. I am about to change that but my last attempt [1]
> has to be rethought.
>
> Now another thing is that the __GFP_NOFAIL which has this nasty side
> effect has been introduced by me d1b5c5671d01 ("btrfs: Prevent from
> early transaction abort") in 4.3 so I am quite surprised that this has
> shown up only in 4.8. Anyway there might be some other changes in the
> btrfs which could make it more subtle.
>
> I believe the right way to go around this is to pursue what I've started
> in [1]. I will try to prepare something for testing today for you. Stay
> tuned. But I would be really happy if somebody from the btrfs camp could
> check the NOFS aspect of this allocation. We have already seen
> allocation stalls from this path quite recently

Just double checking, are you asking why we're using GFP_NOFS to avoid 
going into btrfs from the btrfs writepages call, or are you asking why 
we aren't allowing highmem?

For why we're not using highmem, it goes back to 2011:

commit a65917156e345946dbde3d7effd28124c6d6a8c2
Btrfs: stop using highmem for extent_buffers

The short answer is that kmap + shared caching pointer between threads 
made it hugely complex.  I gave up and dropped the highmem part.

-chris

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
