Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id E8E756B0098
	for <linux-mm@kvack.org>; Fri, 13 Jun 2014 02:27:01 -0400 (EDT)
Received: by mail-pd0-f171.google.com with SMTP id ft15so1776510pdb.2
        for <linux-mm@kvack.org>; Thu, 12 Jun 2014 23:27:01 -0700 (PDT)
Received: from ipmail07.adl2.internode.on.net (ipmail07.adl2.internode.on.net. [2001:44b8:8060:ff02:300:1:2:7])
        by mx.google.com with ESMTP id eb4si1039451pbb.113.2014.06.12.23.26.59
        for <linux-mm@kvack.org>;
        Thu, 12 Jun 2014 23:27:00 -0700 (PDT)
Date: Fri, 13 Jun 2014 16:26:45 +1000
From: Dave Chinner <david@fromorbit.com>
Subject: Re: XFS WARN_ON in xfs_vm_writepage
Message-ID: <20140613062645.GZ9508@dastard>
References: <20140613051631.GA9394@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140613051631.GA9394@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Jones <davej@redhat.com>, xfs@oss.sgi.com, Linux Kernel <linux-kernel@vger.kernel.org>
Cc: linux-mm@kvack.org

[cc linux-mm]

On Fri, Jun 13, 2014 at 01:16:31AM -0400, Dave Jones wrote:
> Just hit this on Linus' tree from earlier this afternoon..
> 
> WARNING: CPU: 3 PID: 19721 at fs/xfs/xfs_aops.c:971 xfs_vm_writepage+0x5ce/0x630 [xfs]()
> CPU: 3 PID: 19721 Comm: trinity-c61 Not tainted 3.15.0+ #3
>  0000000000000009 000000004f70ab82 ffff8801d5ebf578 ffffffff8373215c
>  0000000000000000 ffff8801d5ebf5b0 ffffffff8306f7cd ffff88023dd543e0
>  ffffea000254a3c0 ffff8801d5ebf820 ffffea000254a3e0 ffff8801d5ebf728
> Call Trace:
>  [<ffffffff8373215c>] dump_stack+0x4e/0x7a
>  [<ffffffff8306f7cd>] warn_slowpath_common+0x7d/0xa0
>  [<ffffffff8306f8fa>] warn_slowpath_null+0x1a/0x20
>  [<ffffffffc023068e>] xfs_vm_writepage+0x5ce/0x630 [xfs]
>  [<ffffffff8373f1ab>] ? preempt_count_sub+0xab/0x100
>  [<ffffffff83347315>] ? __percpu_counter_add+0x85/0xc0
>  [<ffffffff8316f759>] shrink_page_list+0x8f9/0xb90
>  [<ffffffff83170123>] shrink_inactive_list+0x253/0x510
>  [<ffffffff83170c93>] shrink_lruvec+0x563/0x6c0
>  [<ffffffff83170e2b>] shrink_zone+0x3b/0x100
>  [<ffffffff831710e1>] shrink_zones+0x1f1/0x3c0
>  [<ffffffff83171414>] try_to_free_pages+0x164/0x380
>  [<ffffffff83163e52>] __alloc_pages_nodemask+0x822/0xc90
>  [<ffffffff83169eb2>] ? pagevec_lru_move_fn+0x122/0x140
>  [<ffffffff831abeff>] alloc_pages_vma+0xaf/0x1c0
>  [<ffffffff8318a931>] handle_mm_fault+0xa31/0xc50
>  [<ffffffff831845c0>] ? follow_page_mask+0x1f0/0x320
>  [<ffffffff8318491b>] __get_user_pages+0x22b/0x660
>  [<ffffffff831b5093>] ? kmem_cache_alloc+0x183/0x210
>  [<ffffffff8318ce7e>] __mlock_vma_pages_range+0x9e/0xd0
>  [<ffffffff8318d6ba>] __mm_populate+0xca/0x180
>  [<ffffffff83179033>] vm_mmap_pgoff+0xd3/0xe0
>  [<ffffffff8318fbd6>] SyS_mmap_pgoff+0x116/0x2c0
>  [<ffffffff83011ced>] ? syscall_trace_enter+0x14d/0x2a0
>  [<ffffffff830084c2>] SyS_mmap+0x22/0x30
>  [<ffffffff837436ef>] tracesys+0xdd/0xe2
> 
> 
>  970         if (WARN_ON_ONCE((current->flags & (PF_MEMALLOC|PF_KSWAPD)) ==
>  971                         PF_MEMALLOC))

What were you running at the time? The XFS warning is there to
indicate that memory reclaim is doing something it shouldn't (i.e.
dirty page writeback from direct reclaim), so this is one for the mm
folk to work out...

Cheers,

Dave.
-- 
Dave Chinner
david@fromorbit.com

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
