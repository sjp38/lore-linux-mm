Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id 0C5C96B0038
	for <linux-mm@kvack.org>; Fri, 16 Dec 2016 14:50:22 -0500 (EST)
Received: by mail-wm0-f71.google.com with SMTP id g23so10674325wme.4
        for <linux-mm@kvack.org>; Fri, 16 Dec 2016 11:50:22 -0800 (PST)
Received: from mx0a-00082601.pphosted.com (mx0b-00082601.pphosted.com. [67.231.153.30])
        by mx.google.com with ESMTPS id q187si4826620wmb.99.2016.12.16.11.50.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Dec 2016 11:50:20 -0800 (PST)
Subject: Re: OOM: Better, but still there on 4.9
References: <20161215225702.GA27944@boerne.fritz.box>
 <20161216073941.GA26976@dhcp22.suse.cz>
From: Chris Mason <clm@fb.com>
Message-ID: <1e7af6ae-ff31-2678-11e2-aa22cf554d8d@fb.com>
Date: Fri, 16 Dec 2016 14:50:07 -0500
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

Reading harder, its possible those pagecache pages are all from the 
btree inode.  They shouldn't be pinned by btrfs, kswapd should be able 
to wander in and free a good chunk.  What btrfs wants to happen is for 
this allocation to sit and wait for kswapd to make progress.

-chris

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
