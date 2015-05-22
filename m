Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f51.google.com (mail-wg0-f51.google.com [74.125.82.51])
	by kanga.kvack.org (Postfix) with ESMTP id F32C8829A8
	for <linux-mm@kvack.org>; Fri, 22 May 2015 10:51:37 -0400 (EDT)
Received: by wgfl8 with SMTP id l8so20199435wgf.2
        for <linux-mm@kvack.org>; Fri, 22 May 2015 07:51:37 -0700 (PDT)
Received: from mail-wg0-x22a.google.com (mail-wg0-x22a.google.com. [2a00:1450:400c:c00::22a])
        by mx.google.com with ESMTPS id ce7si4134029wjc.102.2015.05.22.07.51.36
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 22 May 2015 07:51:36 -0700 (PDT)
Received: by wgbgq6 with SMTP id gq6so20180086wgb.3
        for <linux-mm@kvack.org>; Fri, 22 May 2015 07:51:36 -0700 (PDT)
Date: Fri, 22 May 2015 16:51:34 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [Ext4][Bug] Deadlock in ext4 with memcg enabled.
Message-ID: <20150522145134.GA24484@dhcp22.suse.cz>
References: <555AE391.20806@kyup.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <555AE391.20806@kyup.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Nikolay Borisov <kernel@kyup.com>
Cc: linux-mm@kvack.org, tytso@mit.edu, Johannes Weiner <hannes@cmpxchg.org>

[CCing Johannes and keeping the full email with my comment inlined]

On Tue 19-05-15 10:17:37, Nikolay Borisov wrote:
> Hello,
> 
> On one of our servers we are observing deadlocks when fsync running. The
> kernel version in question is: 3.12.28
> 
> We've managed to acquire a backtrace from one of the hanging processes:
> 
> PID: 21575  TASK: ffff883f482ac200  CPU: 24  COMMAND: "exim"
>  #0 [ffff8824be1ab0e8] __schedule at ffffffff8158718f
>  #1 [ffff8824be1ab180] schedule at ffffffff81587634
>  #2 [ffff8824be1ab190] io_schedule at ffffffff81587707
>  #3 [ffff8824be1ab1b0] sleep_on_page at ffffffff810f50d9
>  #4 [ffff8824be1ab1c0] __wait_on_bit at ffffffff8158536a
>  #5 [ffff8824be1ab210] wait_on_page_bit at ffffffff810f52f2
>  #6 [ffff8824be1ab270] shrink_page_list at ffffffff81105fd5
>  #7 [ffff8824be1ab3b0] shrink_inactive_list at ffffffff81106b18
>  #8 [ffff8824be1ab4b0] shrink_lruvec at ffffffff8110716d
>  #9 [ffff8824be1ab5d0] shrink_zone at ffffffff811074ae
> #10 [ffff8824be1ab650] do_try_to_free_pages at ffffffff811076bb
> #11 [ffff8824be1ab6f0] try_to_free_mem_cgroup_pages at ffffffff81107bc6
> #12 [ffff8824be1ab770] mem_cgroup_reclaim at ffffffff811483e6
> #13 [ffff8824be1ab7c0] __mem_cgroup_try_charge at ffffffff8114cd6c
> #14 [ffff8824be1ab8e0] mem_cgroup_charge_common at ffffffff8114d742
> #15 [ffff8824be1ab920] mem_cgroup_cache_charge at ffffffff8114d82d
> #16 [ffff8824be1ab960] add_to_page_cache_locked at ffffffff810f5521
> #17 [ffff8824be1ab9a0] add_to_page_cache_lru at ffffffff810f562d
> #18 [ffff8824be1ab9c0] find_or_create_page at ffffffff810f6003
> #19 [ffff8824be1aba10] __getblk at ffffffff81181554
> #20 [ffff8824be1aba80] __read_extent_tree_block at ffffffff8120a05b
> #21 [ffff8824be1abad0] ext4_ext_find_extent at ffffffff8120a7c8
> #22 [ffff8824be1abb40] ext4_ext_map_blocks at ffffffff8120d176
> #23 [ffff8824be1abc30] ext4_map_blocks at ffffffff811eec6e
> #24 [ffff8824be1abcd0] ext4_writepages at ffffffff811f388b
> #25 [ffff8824be1abe40] do_writepages at ffffffff8110025b
> #26 [ffff8824be1abe50] __filemap_fdatawrite_range at ffffffff810f5881
> #27 [ffff8824be1abe90] filemap_write_and_wait_range at ffffffff810f590a
> #28 [ffff8824be1abec0] ext4_sync_file at ffffffff811ea2ac
> #29 [ffff8824be1abf00] vfs_fsync_range at ffffffff8117e573
> #30 [ffff8824be1abf10] vfs_fsync at ffffffff8117e597
> #31 [ffff8824be1abf20] do_fsync at ffffffff8117e7cc
> #32 [ffff8824be1abf70] sys_fdatasync at ffffffff8117e80e
> #33 [ffff8824be1abf80] system_call_fastpath at ffffffff81589ae2
>     RIP: 00002b0fde9246c0  RSP: 00007fffe7f8d080  RFLAGS: 00010202
>     RAX: 000000000000004b  RBX: ffffffff81589ae2  RCX: 00000000000000c6
>     RDX: 0000000001e226d8  RSI: 0000000001dd39e0  RDI: 0000000000000008
>     RBP: 0000000001dd39e0   R8: 0000000000001000   R9: 0000000000000000
>     R10: 00007fffe7f8cc30  R11: 0000000000000246  R12: ffffffff8117e80e
>     R13: ffff8824be1abf78  R14: 0000000000000064  R15: 0000000001dd41b0
>     ORIG_RAX: 000000000000004b  CS: 0033  SS: 002b
> 
> 
> The conclusion that I've drawn looking from the code and some offline
> discussions is that when fsync is requested ext4 starts marking pages
> for writeback (ext4_writepages). I think some heavy inlining is
> happening and ext4_map_blocks is being called from:
> 
>  ext4_writepages->mpage_map_and_submit_extent -> mpage_map_one_extent ->
> ext4_map_blocks
> 
> which in turn when trying to write the pages exceeds the memory cgroup
> limit which triggers the memory freeing logic. This, in turn, executes
> the wait_on_page_writeback(page) in shrink_page_list. E.g. the the memcg
> sees a page as being marked for writeback (presumably this is the same
> page which caused the OOM) so it sleeps to wait for the page to be
> written back, but since it is the writeback path that executed the page
> shrinking it causes a deadlock.

My understanding is that the page is marked by PageWriteback only when
the IO has been already prepared and will terminate in a finit time
(assuming the storage is not broken or the networking storage is not
disconnected - I would expect that such an IO would timeout eventually
and fail).

Is it possible that the IO cannot finish in your case for some reason?

What we do there is not ideal but it is a poor's man throttling as we
do not have per-memcg dirty throttling and so OOM killer due to memcg
full of dirty pages is too easy to happen.

> This deadlock then causes other processes on the system to enter D
> state, waiting on trying to acquire a certain inode->i_mutex.
> 
> Here are example backtraces from such processes:
> 
> PID: 57416  TASK: ffff88230e5cb180  CPU: 19  COMMAND: "licd"
>  #0 [ffff882378f93bf8] __schedule at ffffffff8158718f
>  #1 [ffff882378f93c90] schedule at ffffffff81587634
>  #2 [ffff882378f93ca0] schedule_preempt_disabled at ffffffff81587919
>  #3 [ffff882378f93cb0] __mutex_lock_slowpath at ffffffff8158613f
>  #4 [ffff882378f93d30] mutex_lock at ffffffff815861f6
>  #5 [ffff882378f93d50] generic_file_aio_write at ffffffff810f73cc
>  #6 [ffff882378f93da0] ext4_file_write at ffffffff811e975c
>  #7 [ffff882378f93e50] do_sync_write at ffffffff8115324b
>  #8 [ffff882378f93ee0] vfs_write at ffffffff81153788
>  #9 [ffff882378f93f20] sys_write at ffffffff81153d6a
> #10 [ffff882378f93f80] system_call_fastpath at ffffffff81589ae2
>     RIP: 00002b01bbc22520  RSP: 00007ffff4772888  RFLAGS: 00000246
>     RAX: 0000000000000001  RBX: ffffffff81589ae2  RCX: ffffffffffffffff
>     RDX: 0000000000000033  RSI: 0000000001c052a0  RDI: 0000000000000003
>     RBP: 00002b01bb329588   R8: 0000000000000001   R9: 00000000004059e8
>     R10: 00007ffff4772800  R11: 0000000000000246  R12: 00007ffff4773380
>     R13: 00007ffff4773310  R14: 0000000000000003  R15: 0000000001c052a0
>     ORIG_RAX: 0000000000000001  CS: 0033  SS: 002b
> 
> 
> and
> 
> PID: 55775  TASK: ffff8801aba4e300  CPU: 29  COMMAND: "crond"
>  #0 [ffff880893a8bbf8] __schedule at ffffffff8158718f
>  #1 [ffff880893a8bc90] schedule at ffffffff81587634
>  #2 [ffff880893a8bca0] schedule_preempt_disabled at ffffffff81587919
>  #3 [ffff880893a8bcb0] __mutex_lock_slowpath at ffffffff8158613f
>  #4 [ffff880893a8bd30] mutex_lock at ffffffff815861f6
>  #5 [ffff880893a8bd50] generic_file_aio_write at ffffffff810f73cc
>  #6 [ffff880893a8bda0] ext4_file_write at ffffffff811e975c
>  #7 [ffff880893a8be50] do_sync_write at ffffffff8115324b
>  #8 [ffff880893a8bee0] vfs_write at ffffffff81153788
>  #9 [ffff880893a8bf20] sys_write at ffffffff81153d6a
> #10 [ffff880893a8bf80] system_call_fastpath at ffffffff81589ae2
>     RIP: 00002b4aad8ad520  RSP: 00007fff96b0c7b8  RFLAGS: 00010202
>     RAX: 0000000000000001  RBX: ffffffff81589ae2  RCX: 0000000096b0cd47
>     RDX: 0000000000000074  RSI: 0000000000bcbd30  RDI: 0000000000000004
>     RBP: 00007fff96b0d110   R8: 0000000000bcbd30   R9: 2f6c61636f6c2f72
>     R10: 6c2f7261762f6831  R11: 0000000000000246  R12: 0000000000000000
>     R13: 0000000000000000  R14: 00007fff96b0f100  R15: 0000000000402500
>     ORIG_RAX: 0000000000000001  CS: 0033  SS: 002b
> 
> 
> I had initially sent this to linux-ext4
> (http://www.spinics.net/lists/linux-ext4/msg48012.html) and got a
> response from Thedore Ts'o that the likely culprit could be in
> grow_dev_pages (called from __getblk -> __getblk_slow -> grow_buffer ->
> grow_dev_pages) since in it the __GFP_NOFS flag is explicitly cleared. I
> can see that in newer kernel (4.0) there is now a _gfp version of the
> api which takes into consideration the user-passed gfp mask which would
> fix this case. I've yet to test whether the same problem is exhibited on
> newer kernel.
> 
> 
> Regards,
> Nikolay
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
