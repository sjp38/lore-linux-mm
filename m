Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx141.postini.com [74.125.245.141])
	by kanga.kvack.org (Postfix) with SMTP id E008B6B0033
	for <linux-mm@kvack.org>; Wed, 10 Jul 2013 04:06:07 -0400 (EDT)
Date: Wed, 10 Jul 2013 10:06:05 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: linux-next: slab shrinkers: BUG at mm/list_lru.c:92
Message-ID: <20130710080605.GC4437@dhcp22.suse.cz>
References: <20130701012558.GB27780@dastard>
 <20130701075005.GA28765@dhcp22.suse.cz>
 <20130701081056.GA4072@dastard>
 <20130702092200.GB16815@dhcp22.suse.cz>
 <20130702121947.GE14996@dastard>
 <20130702124427.GG16815@dhcp22.suse.cz>
 <20130703112403.GP14996@dastard>
 <20130704163643.GF7833@dhcp22.suse.cz>
 <20130708125352.GC20149@dhcp22.suse.cz>
 <20130710023138.GO3438@dastard>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20130710023138.GO3438@dastard>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Chinner <david@fromorbit.com>
Cc: Glauber Costa <glommer@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Wed 10-07-13 12:31:39, Dave Chinner wrote:
[...]
> > 20761 [<ffffffffa0305fdd>] xlog_grant_head_wait+0xdd/0x1a0 [xfs]
> > [<ffffffffa0306166>] xlog_grant_head_check+0xc6/0xe0 [xfs]
> > [<ffffffffa030627f>] xfs_log_reserve+0xff/0x240 [xfs]
> > [<ffffffffa0302ac4>] xfs_trans_reserve+0x234/0x240 [xfs]
> > [<ffffffffa02c5999>] xfs_create+0x1a9/0x5c0 [xfs]
> > [<ffffffffa02bccca>] xfs_vn_mknod+0x8a/0x1a0 [xfs]
> > [<ffffffffa02bce0e>] xfs_vn_create+0xe/0x10 [xfs]
> > [<ffffffff811763dd>] vfs_create+0xad/0xd0
> > [<ffffffff81177e68>] lookup_open+0x1b8/0x1d0
> > [<ffffffff8117815e>] do_last+0x2de/0x780
> > [<ffffffff8117ae9a>] path_openat+0xda/0x400
> > [<ffffffff8117b303>] do_filp_open+0x43/0xa0
> > [<ffffffff81168ee0>] do_sys_open+0x160/0x1e0
> > [<ffffffff81168f9c>] sys_open+0x1c/0x20
> > [<ffffffff815830e9>] system_call_fastpath+0x16/0x1b
> > [<ffffffffffffffff>] 0xffffffffffffffff
> 
> That's an XFS log space issue, indicating that it has run out of
> space in IO the log and it is waiting for more to come free. That
> requires IO completion to occur.
>
> > [276962.652076] INFO: task xfs-data/sda9:930 blocked for more than 480 seconds.
> > [276962.652087] "echo 0 > /proc/sys/kernel/hung_task_timeout_secs" disables this message.
> > [276962.652093] xfs-data/sda9   D ffff88001ffb9cc8     0   930      2 0x00000000
> 
> Oh, that's why. This is the IO completion worker...

But that task doesn't seem to be stuck anymore (at least lockup watchdog
doesn't report it anymore and I have already rebooted to test with ext3
:/). I am sorry if the these lockups logs were more confusing than
helpful, but they happened _long_ time ago and the system obviously
recovered from them. I am pasting only the traces for processes in D
state here again for reference.

14442 [<ffffffff811011a9>] sleep_on_page+0x9/0x10
[<ffffffff8110150f>] wait_on_page_bit+0x6f/0x80
[<ffffffff81114e43>] shrink_page_list+0x503/0x790
[<ffffffff8111570b>] shrink_inactive_list+0x1bb/0x570
[<ffffffff81115ef9>] shrink_lruvec+0xf9/0x330
[<ffffffff8111660a>] mem_cgroup_shrink_node_zone+0xda/0x140
[<ffffffff81163382>] mem_cgroup_soft_reclaim+0xb2/0x140
[<ffffffff811634af>] mem_cgroup_soft_limit_reclaim+0x9f/0x270
[<ffffffff81116418>] shrink_zones+0x108/0x220
[<ffffffff8111776a>] do_try_to_free_pages+0x8a/0x360
[<ffffffff81117d90>] try_to_free_pages+0x130/0x180
[<ffffffff8110a2fe>] __alloc_pages_slowpath+0x39e/0x790
[<ffffffff8110a8ea>] __alloc_pages_nodemask+0x1fa/0x210
[<ffffffff8114d1b0>] alloc_pages_vma+0xa0/0x120
[<ffffffff8113fe93>] read_swap_cache_async+0x113/0x160
[<ffffffff8113ffe1>] swapin_readahead+0x101/0x190
[<ffffffff8112e93f>] do_swap_page+0xef/0x5e0
[<ffffffff8112f94d>] handle_pte_fault+0x1bd/0x240
[<ffffffff8112fcbf>] handle_mm_fault+0x2ef/0x400
[<ffffffff8157e927>] __do_page_fault+0x237/0x4f0
[<ffffffff8157ebe9>] do_page_fault+0x9/0x10
[<ffffffff8157b348>] page_fault+0x28/0x30
[<ffffffffffffffff>] 0xffffffffffffffff
14962 [<ffffffff811011a9>] sleep_on_page+0x9/0x10
[<ffffffff8110150f>] wait_on_page_bit+0x6f/0x80
[<ffffffff81114e43>] shrink_page_list+0x503/0x790
[<ffffffff8111570b>] shrink_inactive_list+0x1bb/0x570
[<ffffffff81115ef9>] shrink_lruvec+0xf9/0x330
[<ffffffff8111660a>] mem_cgroup_shrink_node_zone+0xda/0x140
[<ffffffff81163382>] mem_cgroup_soft_reclaim+0xb2/0x140
[<ffffffff811634af>] mem_cgroup_soft_limit_reclaim+0x9f/0x270
[<ffffffff81116418>] shrink_zones+0x108/0x220
[<ffffffff8111776a>] do_try_to_free_pages+0x8a/0x360
[<ffffffff81117d90>] try_to_free_pages+0x130/0x180
[<ffffffff8110a2fe>] __alloc_pages_slowpath+0x39e/0x790
[<ffffffff8110a8ea>] __alloc_pages_nodemask+0x1fa/0x210
[<ffffffff8114d1b0>] alloc_pages_vma+0xa0/0x120
[<ffffffff81129ebb>] do_anonymous_page+0x16b/0x350
[<ffffffff8112f9c5>] handle_pte_fault+0x235/0x240
[<ffffffff8112fcbf>] handle_mm_fault+0x2ef/0x400
[<ffffffff8157e927>] __do_page_fault+0x237/0x4f0
[<ffffffff8157ebe9>] do_page_fault+0x9/0x10
[<ffffffff8157b348>] page_fault+0x28/0x30
[<ffffffffffffffff>] 0xffffffffffffffff
20757 [<ffffffffa0305fdd>] xlog_grant_head_wait+0xdd/0x1a0 [xfs]
[<ffffffffa0306166>] xlog_grant_head_check+0xc6/0xe0 [xfs]
[<ffffffffa030627f>] xfs_log_reserve+0xff/0x240 [xfs]
[<ffffffffa0302ac4>] xfs_trans_reserve+0x234/0x240 [xfs]
[<ffffffffa02c62d0>] xfs_free_eofblocks+0x180/0x250 [xfs]
[<ffffffffa02c68e6>] xfs_release+0x106/0x1d0 [xfs]
[<ffffffffa02b3b20>] xfs_file_release+0x10/0x20 [xfs]
[<ffffffff8116c86d>] __fput+0xbd/0x240
[<ffffffff8116ca49>] ____fput+0x9/0x10
[<ffffffff81063221>] task_work_run+0xb1/0xe0
[<ffffffff810029e0>] do_notify_resume+0x90/0x1d0
[<ffffffff815833a2>] int_signal+0x12/0x17
[<ffffffffffffffff>] 0xffffffffffffffff
20758 [<ffffffffa0305fdd>] xlog_grant_head_wait+0xdd/0x1a0 [xfs]
[<ffffffffa0306166>] xlog_grant_head_check+0xc6/0xe0 [xfs]
[<ffffffffa030627f>] xfs_log_reserve+0xff/0x240 [xfs]
[<ffffffffa0302ac4>] xfs_trans_reserve+0x234/0x240 [xfs]
[<ffffffffa02c5999>] xfs_create+0x1a9/0x5c0 [xfs]
[<ffffffffa02bccca>] xfs_vn_mknod+0x8a/0x1a0 [xfs]
[<ffffffffa02bce0e>] xfs_vn_create+0xe/0x10 [xfs]
[<ffffffff811763dd>] vfs_create+0xad/0xd0
[<ffffffff81177e68>] lookup_open+0x1b8/0x1d0
[<ffffffff8117815e>] do_last+0x2de/0x780
[<ffffffff8117ae9a>] path_openat+0xda/0x400
[<ffffffff8117b303>] do_filp_open+0x43/0xa0
[<ffffffff81168ee0>] do_sys_open+0x160/0x1e0
[<ffffffff81168f9c>] sys_open+0x1c/0x20
[<ffffffff815830e9>] system_call_fastpath+0x16/0x1b
[<ffffffffffffffff>] 0xffffffffffffffff
20761 [<ffffffffa0305fdd>] xlog_grant_head_wait+0xdd/0x1a0 [xfs]
[<ffffffffa0306166>] xlog_grant_head_check+0xc6/0xe0 [xfs]
[<ffffffffa030627f>] xfs_log_reserve+0xff/0x240 [xfs]
[<ffffffffa0302ac4>] xfs_trans_reserve+0x234/0x240 [xfs]
[<ffffffffa02c5999>] xfs_create+0x1a9/0x5c0 [xfs]
[<ffffffffa02bccca>] xfs_vn_mknod+0x8a/0x1a0 [xfs]
[<ffffffffa02bce0e>] xfs_vn_create+0xe/0x10 [xfs]
[<ffffffff811763dd>] vfs_create+0xad/0xd0
[<ffffffff81177e68>] lookup_open+0x1b8/0x1d0
[<ffffffff8117815e>] do_last+0x2de/0x780
[<ffffffff8117ae9a>] path_openat+0xda/0x400
[<ffffffff8117b303>] do_filp_open+0x43/0xa0
[<ffffffff81168ee0>] do_sys_open+0x160/0x1e0
[<ffffffff81168f9c>] sys_open+0x1c/0x20
[<ffffffff815830e9>] system_call_fastpath+0x16/0x1b
[<ffffffffffffffff>] 0xffffffffffffffff

We are wating for page under writeback but neither of the 2 paths starts
in xfs code. So I do not think waiting for PageWriteback causes a
deadlock here.

[...]
> ... is running IO completion work and trying to commit a transaction
> that is blocked in memory allocation which is waiting for IO
> completion. It's disappeared up it's own fundamental orifice.
> 
> Ok, this has absolutely nothing to do with the LRU changes - this is
> a pre-existing XFS/mm interaction problem from around 3.2. The
> question is now this: how the hell do I get memory allocation to not
> block waiting on IO completion here? This is already being done in
> GFP_NOFS allocation context here....

Just for reference. wait_on_page_writeback is issued only for memcg
reclaim because there is no other throttling mechanism to prevent from
too many dirty pages on the list, thus pre-mature OOM killer. See
e62e384e9d (memcg: prevent OOM with too many dirty pages) for more
details. The original patch relied on may_enter_fs but that check
disappeared by later changes by c3b94f44fc (memcg: further prevent OOM
with too many dirty pages).
-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
