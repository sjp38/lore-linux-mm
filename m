Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 6E0E18E00E5
	for <linux-mm@kvack.org>; Wed, 12 Dec 2018 06:58:44 -0500 (EST)
Received: by mail-pg1-f197.google.com with SMTP id a2so11966369pgt.11
        for <linux-mm@kvack.org>; Wed, 12 Dec 2018 03:58:44 -0800 (PST)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id p75sor27902745pfj.18.2018.12.12.03.58.43
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 12 Dec 2018 03:58:43 -0800 (PST)
Date: Wed, 12 Dec 2018 14:58:37 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] mm, memcg: fix reclaim deadlock with writeback
Message-ID: <20181212115837.zragenml27av3fqm@kshutemo-mobl1>
References: <20181211132645.31053-1-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181211132645.31053-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Liu Bo <bo.liu@linux.alibaba.com>, Jan Kara <jack@suse.cz>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Michal Hocko <mhocko@suse.com>

On Tue, Dec 11, 2018 at 02:26:45PM +0100, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> Liu Bo has experienced a deadlock between memcg (legacy) reclaim and the
> ext4 writeback
> task1:
> [<ffffffff811aaa52>] wait_on_page_bit+0x82/0xa0
> [<ffffffff811c5777>] shrink_page_list+0x907/0x960
> [<ffffffff811c6027>] shrink_inactive_list+0x2c7/0x680
> [<ffffffff811c6ba4>] shrink_node_memcg+0x404/0x830
> [<ffffffff811c70a8>] shrink_node+0xd8/0x300
> [<ffffffff811c73dd>] do_try_to_free_pages+0x10d/0x330
> [<ffffffff811c7865>] try_to_free_mem_cgroup_pages+0xd5/0x1b0
> [<ffffffff8122df2d>] try_charge+0x14d/0x720
> [<ffffffff812320cc>] memcg_kmem_charge_memcg+0x3c/0xa0
> [<ffffffff812321ae>] memcg_kmem_charge+0x7e/0xd0
> [<ffffffff811b68a8>] __alloc_pages_nodemask+0x178/0x260
> [<ffffffff8120bff5>] alloc_pages_current+0x95/0x140
> [<ffffffff81074247>] pte_alloc_one+0x17/0x40
> [<ffffffff811e34de>] __pte_alloc+0x1e/0x110
> [<ffffffffa06739de>] alloc_set_pte+0x5fe/0xc20
> [<ffffffff811e5d93>] do_fault+0x103/0x970
> [<ffffffff811e6e5e>] handle_mm_fault+0x61e/0xd10
> [<ffffffff8106ea02>] __do_page_fault+0x252/0x4d0
> [<ffffffff8106ecb0>] do_page_fault+0x30/0x80
> [<ffffffff8171bce8>] page_fault+0x28/0x30
> [<ffffffffffffffff>] 0xffffffffffffffff
> 
> task2:
> [<ffffffff811aadc6>] __lock_page+0x86/0xa0
> [<ffffffffa02f1e47>] mpage_prepare_extent_to_map+0x2e7/0x310 [ext4]
> [<ffffffffa08a2689>] ext4_writepages+0x479/0xd60
> [<ffffffff811bbede>] do_writepages+0x1e/0x30
> [<ffffffff812725e5>] __writeback_single_inode+0x45/0x320
> [<ffffffff81272de2>] writeback_sb_inodes+0x272/0x600
> [<ffffffff81273202>] __writeback_inodes_wb+0x92/0xc0
> [<ffffffff81273568>] wb_writeback+0x268/0x300
> [<ffffffff81273d24>] wb_workfn+0xb4/0x390
> [<ffffffff810a2f19>] process_one_work+0x189/0x420
> [<ffffffff810a31fe>] worker_thread+0x4e/0x4b0
> [<ffffffff810a9786>] kthread+0xe6/0x100
> [<ffffffff8171a9a1>] ret_from_fork+0x41/0x50
> [<ffffffffffffffff>] 0xffffffffffffffff
> 
> He adds
> : task1 is waiting for the PageWriteback bit of the page that task2 has
> : collected in mpd->io_submit->io_bio, and tasks2 is waiting for the LOCKED
> : bit the page which tasks1 has locked.
> 
> More precisely task1 is handling a page fault and it has a page locked
> while it charges a new page table to a memcg. That in turn hits a memory
> limit reclaim and the memcg reclaim for legacy controller is waiting on
> the writeback but that is never going to finish because the writeback
> itself is waiting for the page locked in the #PF path. So this is
> essentially ABBA deadlock.
> 
> Waiting for the writeback in legacy memcg controller is a workaround
> for pre-mature OOM killer invocations because there is no dirty IO
> throttling available for the controller. There is no easy way around
> that unfortunately. Therefore fix this specific issue by pre-allocating
> the page table outside of the page lock. We have that handy
> infrastructure for that already so simply reuse the fault-around pattern
> which already does this.
> 
> Reported-and-Debugged-by: Liu Bo <bo.liu@linux.alibaba.com>
> Signed-off-by: Michal Hocko <mhocko@suse.com>
> ---
> Hi,
> this has been originally reported here [1]. While it could get worked
> around in the fs, catching the allocation early sounds like a preferable
> approach. Liu Bo has noted that he is not able to reproduce this anymore
> because kmem accounting has been disabled in their workload but this
> should be quite straightforward to review.
> 
> There are probably other hidden __GFP_ACCOUNT | GFP_KERNEL allocations
> from under a fs page locked but they should be really rare. I am not
> aware of a better solution unfortunately.

Okay, I have spent some time on the issue and was not able to find a
better solution too. But I cannot say I like it.

I think we need to spend more time on making ->prealloc_pte useful: looks
like it would help to convert vmf_insert_* helpers to take struct vm_fault
* as input and propagate it down to pmd population point. Otherwise DAX
and drivers would alloacate the page table for nothing.

Have you considered if we need anything similar for anon path? Is it
possible to have similar deadlock with swaping rather than writeback?

-- 
 Kirill A. Shutemov
