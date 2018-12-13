Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id 93F758E0014
	for <linux-mm@kvack.org>; Thu, 13 Dec 2018 17:46:46 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id p15so2765650pfk.7
        for <linux-mm@kvack.org>; Thu, 13 Dec 2018 14:46:46 -0800 (PST)
Received: from out30-130.freemail.mail.aliyun.com (out30-130.freemail.mail.aliyun.com. [115.124.30.130])
        by mx.google.com with ESMTPS id q13si2515378pgj.86.2018.12.13.14.46.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 13 Dec 2018 14:46:44 -0800 (PST)
Date: Thu, 13 Dec 2018 14:43:14 -0800
From: Liu Bo <bo.liu@linux.alibaba.com>
Subject: Re: [PATCH v3] mm, memcg: fix reclaim deadlock with writeback
Message-ID: <20181213224313.jty2h5cxlchtisez@US-160370MP2.local>
Reply-To: bo.liu@linux.alibaba.com
References: <20181212155055.1269-1-mhocko@kernel.org>
 <20181213092221.27270-1-mhocko@kernel.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181213092221.27270-1-mhocko@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill@shutemov.name>, Jan Kara <jack@suse.cz>, Dave Chinner <david@fromorbit.com>, Theodore Ts'o <tytso@mit.edu>, Johannes Weiner <hannes@cmpxchg.org>, Vladimir Davydov <vdavydov.dev@gmail.com>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, Shakeel Butt <shakeelb@google.com>, Michal Hocko <mhocko@suse.com>, Stable tree <stable@vger.kernel.org>

On Thu, Dec 13, 2018 at 10:22:21AM +0100, Michal Hocko wrote:
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
> essentially ABBA deadlock:
>                                         lock_page(A)
>                                         SetPageWriteback(A)
>                                         unlock_page(A)
> lock_page(B)
>                                         lock_page(B)
> pte_alloc_pne
>   shrink_page_list
>     wait_on_page_writeback(A)
>                                         SetPageWriteback(B)
>                                         unlock_page(B)
> 
>                                         # flush A, B to clear the writeback
> 
> This accumulating of more pages to flush is used by several filesystems
> to generate a more optimal IO patterns.
> 
> Waiting for the writeback in legacy memcg controller is a workaround
> for pre-mature OOM killer invocations because there is no dirty IO
> throttling available for the controller. There is no easy way around
> that unfortunately. Therefore fix this specific issue by pre-allocating
> the page table outside of the page lock. We have that handy
> infrastructure for that already so simply reuse the fault-around pattern
> which already does this.
> 
> There are probably other hidden __GFP_ACCOUNT | GFP_KERNEL allocations
> from under a fs page locked but they should be really rare. I am not
> aware of a better solution unfortunately.
> 

Thanks for the update.

Looks good to me.

Reviewed-by: Liu Bo <bo.liu@linux.alibaba.com>

thanks,
-liubo

> Reported-and-Debugged-by: Liu Bo <bo.liu@linux.alibaba.com>
> Cc: stable
> Fixes: c3b94f44fcb0 ("memcg: further prevent OOM with too many dirty pages")
> Signed-off-by: Michal Hocko <mhocko@suse.com>
> ---
>  mm/memory.c | 11 +++++++++++
>  1 file changed, 11 insertions(+)
> 
> diff --git a/mm/memory.c b/mm/memory.c
> index 4ad2d293ddc2..bb78e90a9b70 100644
> --- a/mm/memory.c
> +++ b/mm/memory.c
> @@ -2993,6 +2993,17 @@ static vm_fault_t __do_fault(struct vm_fault *vmf)
>  	struct vm_area_struct *vma = vmf->vma;
>  	vm_fault_t ret;
>  
> +	/*
> +	 * Preallocate pte before we take page_lock because this might lead to
> +	 * deadlocks for memcg reclaim which waits for pages under writeback.
> +	 */
> +	if (pmd_none(*vmf->pmd) && !vmf->prealloc_pte) {
> +		vmf->prealloc_pte = pte_alloc_one(vmf->vma->vm_mm, vmf->address);
> +		if (!vmf->prealloc_pte)
> +			return VM_FAULT_OOM;
> +		smp_wmb(); /* See comment in __pte_alloc() */
> +	}
> +
>  	ret = vma->vm_ops->fault(vmf);
>  	if (unlikely(ret & (VM_FAULT_ERROR | VM_FAULT_NOPAGE | VM_FAULT_RETRY |
>  			    VM_FAULT_DONE_COW)))
> -- 
> 2.19.2
